function Params = PTB_PlayMovies(Params)

%=========================== PTB_PlayMovies.m =============================
% This function serves as a template for how to write an experiment using
% the SCNI toolbar subfunctions. As is, this particular function allows the
% experimenter to present one or more movie files in an order of their
% choosing (e.g. a block design for fMRI experiments, or pseudorandomly for
% neurophysiology). The numerous variables can be adjusted by running the
% accompanying PTB_MovieSettings app and saving to your parameters file.
%
%==========================================================================

%================= SET DEFAULT PARAMETERS
if nargin == 0 || ~isfield(Params, 'Movie') || ~isfield(Params, 'Design')
    Params  = NTB_MovieSettings(Params, 0);
end

%================= PRE-ALLOCATE RUN AND REWARD FIELDS
Params.Movie.TrialsPerRun       = ceil(Params.Movie.RunDuration/(Params.Movie.Duration+Params.Movie.ISI))*100;
Params.Run.ValidFixations       = nan(Params.Movie.TrialsPerRun, Params.Movie.Duration*Params.DPx.AnalogInRate, 3);
Params.Run.LastRewardTime       = GetSecs;
Params.Run.StartTime            = GetSecs;
Params.Run.LastPress            = GetSecs;
Params.Run.TextColor            = [1,1,1]*255;
Params.Run.TextRect             = [100, 100, [100, 100]+[200,300]];
Params.Run.Duration             = Params.Movie.RunDuration;
Params.Run.MaxTrialDur          = Params.Movie.Duration;
Params.Run.MovieCount           = 1;                            % Start movie count at 1
Params.Run.TrialCount           = 1;
Params.Run.ExpQuit              = 0;
Params.Run.EndRun               = 0;
Params.Run.CurrentFile          = Params.Movie.AllFiles{4};
Params.Run.StimIsOn             = 0;
Params.Run.NoTTLs               = 35;

Params.Reward.Proportion        = 0.7;                          % Set proportion of reward interval that fixation must be maintained for (0-1)
Params.Reward.MeanIRI           = 4;                            % Set mean interval between reward delivery (seconds)
Params.Reward.RandIRI           = 2;                            % Set random jitter between reward delivery intervals (seconds)
Params.Reward.LastRewardTime    = GetSecs;                      % Initialize last reward delivery time (seconds)
Params.Reward.NextRewardInt     = Params.Reward.MeanIRI + rand(1)*Params.Reward.RandIRI;           	% Generate random interval before first reward delivery (seconds)
Params.Reward.TTLDur            = 0.05;                         % Set TTL pulse duration (seconds)
Params.Reward.RunCount          = 0;                            % Count how many reward delvieries in this run
Params.DPx.UseDPx               = 1;                            % Use DataPixx?

if ~isfield(Params, 'Eye')
    Params = SCNI_EyeCalibSettings(Params);
end


%================= INITIALIZE SETTINGS
Params  = SCNI_DataPixxInit(Params);                                % Initialize DataPixx
Params 	= SCNI_InitializeGrid(Params);                              % Initialize experimenter's display grid
Params	= SCNI_GetPDrect(Params, Params.Display.UseSBS3D);          % Initialize photodiode location(s)
Params  = SCNI_InitKeyboard(Params);                                % Initialize keyboard shortcuts
Params  = NTB_ScreenRects(Params);                                  

%================= LOAD FIRST MOVIE FILE
[mov, Movie.duration, Movie.fps, Movie.width, Movie.height, Movie.count, Movie.AR] = Screen('OpenMovie', Params.Display.win, Params.Run.CurrentFile); 
Params.Run.mov              = mov;
[~,Params.Movie.Filename]   = fileparts(Params.Run.CurrentFile);  
if isempty(Params.Movie.Duration)
    Params.Movie.Duration = Movie.duration;
end

%================= GENERATE EXPERIMENTAL DESIGN
Params.Run.MovieIndx = randperm(numel(Params.Movie.AllFiles));
%Params.Run.MovieIndx = randi(numel(Params.Movie.AllFiles), [1, Params.Movie.TrialsPerRun]);  	% <<<< RANDOMIZED (FUDGE) movie order

%================= GENERATE FIXATION TEXTURE
Fix.Size        = Params.Movie.FixSize*Params.Display.PixPerDeg;
if Params.Movie.FixType > 1
    Fix.Type        = Params.Movie.FixType-1;           % Fixation marker format
    Fix.Color       = Params.Movie.FixColor;           	% Fixation marker color (RGB, 0-1)
    Fix.MarkerSize  = Params.Movie.FixSize;            	% Fixation marker diameter (degrees)
    Fix.LineWidth   = 4;                                % Fixation marker line width (pixels)
    Params.Movie.FixTex = SCNI_GenerateFixMarker(Fix, Params);
end

%================= BEGIN RUN
Params.Movie.SyncToScanner = 0;
if Params.Movie.SyncToScanner == 1
    PulsePolarity  = -1;
    ScannerOn       = SCNI_WaitForTTL(Params, 5, PulsePolarity, 1);
end
FrameOnset                  = GetSecs;
while Params.Run.EndRun == 0 && (GetSecs-Params.Run.StartTime) < Params.Movie.RunDuration
    
    Params.Run.MovieStartTime   = GetSecs;
	if Params.Run.MovieCount > 1
        SCNI_SendEventCode(Params.Run.MovieIndx(Params.Run.MovieCount), Params);                             % Send event code to connected neurophys systems
        Params.Run.CurrentFile      = Params.Movie.AllFiles{Params.Run.MovieIndx(Params.Run.MovieCount)};   
        [~,Params.Movie.Filename]   = fileparts(Params.Run.CurrentFile);  
        [mov, Movie.duration, Movie.fps, Movie.width, Movie.height, Movie.count, Movie.AR] = Screen('OpenMovie', Params.Display.win, Params.Run.CurrentFile); 
        Params.Run.mov = mov;
        if Params.Movie.SBS == 0
            Params.Movie.SourceRect{1}  = [1, 1, Movie.width, Movie.height];
        end
	end

    %================= Initialize DataPixx/ send event codes
    AdcStatus = SCNI_StartADC(Params);                                  % Start DataPixx ADC
    SCNI_SendEventCode('Trial_Start', Params);                       	% Send event code to connected neurophys systems

   	%================= START PLAYBACK
    Screen('PlayMovie',mov, Params.Movie.Rate, Params.Movie.Loop, Params.Movie.AudioOn*Params.Movie.AudioVol);
    %Screen('SetmovieTimeIndex',mov, Params.Movie.StartTime, 1);  
    
    %================= WAIT FOR ISI TO ELAPSE
    Params.Run.StimOffTime  = GetSecs;
    while (GetSecs - Params.Run.StimOffTime) < Params.Movie.ISI
        Screen('FillRect', Params.Display.win, Params.Movie.Background*255);                                             	% Clear previous frame
        for Eye = 1:NoEyes 
            if Params.Display.PD.Position > 1
                Screen('FillOval', Params.Display.win, Params.Display.PD.Color{1}*255, Params.Display.PD.SubRect(Eye,:));
                Screen('FillOval', Params.Display.win, Params.Display.PD.Color{1}*255, Params.Display.PD.ExpRect);
            end
            if Params.Movie.FixOn == 1
                Screen('DrawTexture', Params.Display.win, Params.Movie.FixTex, [], Params.Display.FixRectMonk(Eye,:));  	% Draw fixation marker
            end
        end

        %=============== Check current eye position
        Eye         = SCNI_GetEyePos(Params);
        EyeRect   	= repmat(round(Eye(Params.Eye.EyeToUse).Pixels),[1,2])+[-10,-10,10,10];                        % Get screen coordinates of current gaze position (pixels)
        [FixIn, FixDist]= SCNI_IsInFixWin(Eye(Params.Eye.EyeToUse).Pixels, [], Params.Movie.FixOn==0, Params); 	% Check if gaze position is inside fixation window

        %=============== Check whether to deliver reward
        %ValidFixNans 	= find(isnan(Params.Run.ValidFixations(Params.Run.TrialCount,:,1)), 1);                     % Find first NaN elements in fix vector
     	%Params.Run.ValidFixations(Params.Run.TrialCount, ValidFixNans,:) = [GetSecs, FixDist, FixIn];               % Save current fixation result to matrix
        try
            Params       	= SCNI_CheckReward(Params);   
        catch
            disp('Fail!')
        end
        
        
        %=============== Draw experimenter's overlay
        if Params.Display.Exp.GridOn == 1
            Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye, Params.Display.Grid.BullsEyeWidth);                % Draw grid lines
            Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye(:,2:2:end), Params.Display.Grid.BullsEyeWidth+2);   % Draw even lines thicker
            Screen('DrawLines', Params.Display.win, Params.Display.Grid.Meridians, 1, Params.Display.Exp.GridColor*255);                
        end
       if Params.Display.Exp.GazeWinOn == 1
            if Params.Movie.FixType > 1
                Screen('FrameOval', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, Params.Movie.GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
            elseif Params.Movie.FixType == 1
                Screen('FrameRect', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, Params.Movie.GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
            end
        end
        if Params.Movie.FixOn == 1                                                                                                  % Draw fixation marker
            Screen('DrawTexture', Params.Display.win, Params.Movie.FixTex, [], Params.Display.FixRectExp);
        end
        if Eye(Params.Eye.EyeToUse).Pixels(1) < Params.Display.Rect(3)
            Screen('FillOval', Params.Display.win, Params.Display.Exp.EyeColor(FixIn+1,:)*255, EyeRect);                            % Draw current gaze position
        end
        Params       	= SCNI_UpdateStats(Params);

      	%=============== Draw to screen and record time
        [~,ISIoffset]  	= Screen('Flip', Params.Display.win); 
        if Params.Run.StimIsOn == 1                                         	% If the stimulus was ON during the last frame...
            Params.Run.StimIsOn = 0;                                        	% Change state (stimulus is now off)
            SCNI_SendEventCode('Stim_Off', Params);                           	% Send event code to connected neurophys systems
            Params.Run.StimOffTime = ISIoffset;                                	% Record time stamp at which stimulus was removed
        elseif Params.Run.StimIsOn == 0
            if Params.Run.MovieCount == 1                                      	% If this is the first stimulus of the current trial...                                                          
                SCNI_SendEventCode('Fix_On', Params);                        	% Send event code to connected neurophys systems
            end
        end

        Params = SCNI_CheckKeys(Params);                                                                                    % Check for keyboard input
    end

    %================= Wait for TTL sync?
    if Params.Run.MovieCount == 1 && ~isempty(Params.DPx.ScannerChannel)              	% If this is the first trial...
        ScannerOn               = SCNI_WaitForTTL(Params, Params.Run.NoTTLs, 1, 1);   	% Wait for TTL pulses from MRI scanner
        Params.Run.StartTime  	= GetSecs;                                              % Reset start time to after TTLs
    end
    
    %================= BEGIN CURRENT MOVIE PLAYBACK
    Params.Run.StimOnTime = GetSecs;
    Screen('SetmovieTimeIndex',mov, Params.Movie.StartTime, 1);  
    while Params.Run.EndRun == 0 && (FrameOnset(end)-Params.Run.StimOnTime) < Params.Movie.Duration
        
        %=============== Get next frame and draw to displays
       	MovieTex = Screen('GetMovieImage', Params.Display.win, mov);                                                    % Get texture handle for next frame
        Screen('FillRect', Params.Display.win, Params.Movie.Background*255);                                             	% Clear previous frame
        if MovieTex > 0
            Screen('DrawTexture', Params.Display.win, MovieTex, Params.Movie.SourceRect{1}, Params.Movie.RectExp, Params.Movie.Rotation, [], Params.Movie.Contrast);      % Draw to the experimenter's display
            Screen('DrawTexture', Params.Display.win, MovieTex, Params.Movie.SourceRectMonk, Params.Movie.RectMonk, Params.Movie.Rotation, [], Params.Movie.Contrast);   % Draw to the subject's display
        end
     	for Eye = 1:NoEyes  
            currentbuffer = Screen('SelectStereoDrawBuffer', Params.Display.win, Eye-1);                                    % Select the correct stereo buffer
            if Params.Display.PD.Position > 1
                Screen('FillOval', Params.Display.win, Params.Display.PD.Color{2}*255, Params.Display.PD.SubRect(Eye,:));
                Screen('FillOval', Params.Display.win, Params.Display.PD.Color{2}*255, Params.Display.PD.ExpRect);
            end
            if Params.Movie.FixOn == 1
                Screen('DrawTexture', Params.Display.win, Params.Movie.FixTex, [], Params.Display.FixRectMonk(Eye,:));  	% Draw fixation marker
            end
        end

        %=============== Check current eye position
        Eye         = SCNI_GetEyePos(Params);
        EyeRect   	= repmat(round(Eye(Params.Eye.EyeToUse).Pixels),[1,2])+[-10,-10,10,10];                     % Get screen coordinates of current gaze position (pixels)
        [FixIn, FixDist]= SCNI_IsInFixWin(Eye(Params.Eye.EyeToUse).Pixels, [], Params.Movie.FixOn==0, Params);	% Check if gaze position is inside fixation window

        %=============== Check whether to deliver reward
        %ValidFixNans 	= find(isnan(Params.Run.ValidFixations(Params.Run.TrialCount,:,1)), 1);                 % Find first NaN elements in fix vector
%      	try
%             Params.Run.ValidFixations(Params.Run.TrialCount, ValidFixNans,:) = [GetSecs, FixDist, FixIn];       % Save current fixation result to matrix
%         catch
%             disp('Error')
%         end
        Params       	= SCNI_CheckReward(Params);                                                      

        %=============== Draw experimenter's overlay
        if Params.Display.Exp.GridOn == 1
            Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye, Params.Display.Grid.BullsEyeWidth);                % Draw grid lines
            Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye(:,2:2:end), Params.Display.Grid.BullsEyeWidth+2);   % Draw even lines thicker
            Screen('DrawLines', Params.Display.win, Params.Display.Grid.Meridians, 1, Params.Display.Exp.GridColor*255);                
        end
        if Params.Display.Exp.GazeWinOn == 1
            if Params.Movie.FixType > 1
                Screen('FrameOval', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, Params.Movie.GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
            elseif Params.Movie.FixType == 1
                Screen('FrameRect', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, Params.Movie.GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
            end
        end
        if Params.Movie.FixOn == 1                                                                                              % Draw fixation marker
            Screen('DrawTexture', Params.Display.win, Params.Movie.FixTex, [], Params.Display.FixRectExp);
        end
        if Eye(Params.Eye.EyeToUse).Pixels(1) < Params.Display.Rect(3)
            Screen('FillOval', Params.Display.win, Params.Display.Exp.EyeColor(FixIn+1,:)*255, EyeRect);                        % Draw current gaze position                       % Draw current gaze position
        end                                             
        Params         = SCNI_UpdateStats(Params);                                      % Update statistics on experimenter's screen
        
       	%=============== Draw to screen and record time
        [VBL FrameOnset(end+1)] = Screen('Flip', Params.Display.win);                	% Flip next frame
        if Params.Run.StimIsOn == 0                                                    	% If this is first frame of stimulus presentation...
            SCNI_SendEventCode('Stim_On', Params);                                     	% Send event code to connected neurophys systems
            Params.Run.StimIsOn     = 1;                                              	% Change flag to show movie has started
            Params.Run.StimOnTime   = FrameOnset(end);                                	% Record stimulus onset time
        end

        %=============== 
        [Params] = SCNI_CheckKeys(Params);                                              % Check for keyboard input
        if MovieTex > 0
            Screen('Close', MovieTex);                                                 	% Close the last movie frame texture
        end
    end

    %================= END MOVIE PLAYBACK
    MovieEndTime = Screen('GetMovieTimeIndex', mov);
    Screen('CloseMovie',mov);
    Params.Run.MovieCount = Params.Run.MovieCount+1;
    %Params.Run.TrialCount   = Params.Run.TrialCount+1;                                  % Count as one completed trial
    Params = SCNI_GiveReward(Params);                               % <<<< TEMP JUICE FIX
end

%================= END RUN
Screen('FillRect', Params.Display.win, Params.Movie.Background*255);                    % Clear previous frame
Screen('Flip', Params.Display.win);                                                     % Flip next frame


%================= PRINT PLAYBACK STATISTICS
if isfield(Params.Toolbar, 'Debug') && Params.Toolbar.DebugMode == 1
    Frametimes      = diff(FrameOnset);
    meanFrameRate   = mean(Frametimes(2:end))*1000;
    semFrameRate    = (std(Frametimes(2:end))*1000)/sqrt(numel(Frametimes(2:end)));
    fprintf('Frames shown............%.0f\n', numel(Frametimes));
    fprintf('Movie end time..........%.0f seconds\n', MovieEndTime);
    fprintf('Mean frame duration.....%.0f ms +/- %.0f ms\n', meanFrameRate, semFrameRate);
    fprintf('Max frame duration......%.0f ms\n', max(Frametimes)*1000);
end

end


%================= UPDATE EXPERIMENTER'S DISPLAY STATS
function Params = SCNI_UpdateStats(Params)

    %=============== Initialize experimenter display
    if ~isfield(Params.Run, 'BlockImg')
    	Params.Run.Bar.Length   = 800;                                                                  % Specify length of progress bar (pixels)
        Params.Run.Bar.Labels   = {'Run %','Fix %'};
        Params.Run.Bar.Colors   = {[1,0,0], [0,1,0]};
        Params.Run.Bar.Img      = ones([50,Params.Run.Bar.Length]).*255;                             	% Create blank background image
        Params.Run.Bar.ImgTex 	= Screen('MakeTexture', Params.Display.win, Params.Run.Bar.Img);        % Generate texture handle for block design image
        for p = 10:10:90
            PercRect = [0, 0, p/100*Params.Run.Bar.Length, size(Params.Run.Bar.Img,1)]; 
        	Screen('FrameRect',Params.Run.Bar.ImgTex, [0.5,0.5,0.5]*255, PercRect, 2);
        end
        for B = 1:numel(Params.Run.Bar.Labels)
            Params.Run.Bar.TextRect{B}  = [20, Params.Display.Rect(4)-(B*100)];
            Params.Run.Bar.Rect{B}      = [200, Params.Display.Rect(4)-(B*100)-50, 200+Params.Run.Bar.Length, Params.Display.Rect(4)-(B*100)]; % Specify onscreen position to draw block design
            Params.Run.Bar.Overlay{B}   = zeros(size(Params.Run.Bar.Img));                              
            for ch = 1:3                                                                                
                Params.Run.Bar.Overlay{B}(:,:,ch) = Params.Run.Bar.Colors{B}(ch)*255;
            end
            Params.Run.Bar.Overlay{B}(:,:,4) = 0.5*255;                                               	% Set progress bar overlay opacity (0-255)
            Params.Run.Bar.ProgTex{B}  = Screen('MakeTexture', Params.Display.win, Params.Run.Bar.Overlay{B});            	% Create a texture handle for overlay
        end
        
        Params.Run.TextFormat    = ['Movie file      %s\n\n',...
                                    'Time elapsed    %02d:%02.0f\n\n',...
                                    'Time remaining  %02d:%02.0f\n\n',...
                                    'Reward count    %d\n\n',...
                                    'Valid fixation  %.0f %%'];
        if Params.Display.Rect(3) > 1920
           Screen('TextSize', Params.Display.win, 40);
           Screen('TextFont', Params.Display.win, 'Courier');
        end
        if Params.Movie.PlayMultiple == 1 && Params.Movie.Duration < Params.Movie.RunDuration           % If multiple movies are presented per trial
            Params.Run.TextFormat = [Params.Run.TextFormat, '\n\n',...                                  % Add movie count field
                                    'Movie count    %d'];
        end
    end

	Params.Run.ValidFixPercent = 100;%nanmean(nanmean(Params.Run.ValidFixations(1:Params.Run.TrialCount,:,3)))*100; <<<< TEMPORARY FIX

    %========= Update clock
%     if Params.Movie.Paused == 1   
%          Params.Run.CurrentTime   = Params.Movie.PauseTime;
%     elseif Params.Movie.Paused == 0 
        Params.Run.CurrentTime   = GetSecs-Params.Run.StartTime;                                            % Calulate time elapsed
%     end
    Params.Run.CurrentMins      = floor(Params.Run.CurrentTime/60);                    
    Params.Run.TotalMins        = floor(Params.Run.Duration/60);
    Params.Run.CurrentSecs      = rem(Params.Run.CurrentTime, 60);
    Params.Run.CurrentPercent   = (Params.Run.CurrentTime/Params.Run.Duration)*100;
	Params.Run.TextContent      = {Params.Movie.Filename, [Params.Run.CurrentMins, Params.Run.CurrentSecs, Params.Run.TotalMins-Params.Run.CurrentMins-1, 60-Params.Run.CurrentSecs, Params.Reward.RunCount, Params.Run.ValidFixPercent]};
    if Params.Movie.PlayMultiple == 1 && Params.Movie.Duration < Params.Movie.RunDuration                   % If multiple movies are presented per trial
        Params.Run.TextContent{2} = [Params.Run.TextContent{2}, Params.Run.MovieCount];                     % Append movie count
    end
    Params.Run.TextString       = sprintf(Params.Run.TextFormat, Params.Run.TextContent{1}, Params.Run.TextContent{2});

    %========= Update stats bars
    Params.Run.Bar.Prog = {Params.Run.CurrentPercent, Params.Run.ValidFixPercent};
    for B = 1:numel(Params.Run.Bar.Labels)
        Screen('DrawTexture', Params.Display.win, Params.Run.Bar.ImgTex, [], Params.Run.Bar.Rect{B});
        Screen('FrameRect', Params.Display.win, [0,0,0], Params.Run.Bar.Rect{B}, 3);
        if Params.Run.CurrentPercent > 0
            Params.Run.BlockProgLen      = Params.Run.Bar.Length*(Params.Run.Bar.Prog{B}/100);
            Params.Run.BlockProgRect     = [Params.Run.Bar.Rect{B}([1,2]), Params.Run.BlockProgLen+Params.Run.Bar.Rect{B}(1), Params.Run.Bar.Rect{B}(4)];
            Screen('DrawTexture',Params.Display.win, Params.Run.Bar.ProgTex{B}, [], Params.Run.BlockProgRect);
            Screen('FrameRect',Params.Display.win, [0,0,0], Params.Run.BlockProgRect, 3);
            DrawFormattedText(Params.Display.win, Params.Run.Bar.Labels{B}, Params.Run.Bar.TextRect{B}(1), Params.Run.Bar.TextRect{B}(2), Params.Run.TextColor);
        end
    end
    DrawFormattedText(Params.Display.win, Params.Run.TextString, Params.Run.TextRect(1), Params.Run.TextRect(2), Params.Run.TextColor);
end