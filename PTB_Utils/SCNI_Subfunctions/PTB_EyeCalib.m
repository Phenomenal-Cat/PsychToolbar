function Params = SCNI_EyeCalib(Params)

%=========================== SCNI_EyeCalib.m ==============================
% This function runs an eye position calibration routiune by intermittently
% presenting a fixation marker either centrally or at one of 8 peripheral
% locations. Through manual input by the experimenter, or via statistical
% analysis, values are calculated to convert the raw eye position voltages
% into scree-centered coordinates (pixels and degrees of visual angle).
%
%==========================================================================


%================= SET DEFAULT PARAMETERS
if nargin == 0 || ~isfield(Params,'Eye')
    Params = SCNI_EyeCalibSettings(Params, 0);
end

%================= PRE-ALLOCATE RUN AND REWARD FIELDS
Params.Run.ValidFixations       = nan(Params.Eye.TrialsPerRun, round((Params.Eye.Duration+Params.Eye.ISIms)*10^-3*Params.DPx.AnalogInRate), 3);
Params.Run.LastRewardTime       = GetSecs;
Params.Run.StartTime            = GetSecs;
Params.Run.LastPress            = GetSecs;
Params.Run.TextColor            = [1,1,1]*255;
Params.Run.TextRect             = [100, 100, [100, 100]+[200,300]];
Params.Run.MaxTrialDur          = (Params.Eye.StimPerTrial*(Params.Eye.Duration+Params.Eye.ISIms)+Params.Eye.ISIms*2)*10^-3;
Params.Run.TrialCount           = 1;                            % Start trial count at 1
Params.Run.StimCount            = 1;
Params.Run.ExpQuit              = 0;
Params.Run.StimIsOn             = 0;
Params.Run.EyeColors            = {[0,0,1], [1,0,0], [1,0,1]};
Params.Run.ValidTrial           = 1;

if ~isfield(Params.Run, 'Number')                               % If run count field does not exist...
    Params.Run.Number          	= 1;                            % This is the first run of the session
else
    Params.Run.Number          	= Params.Run.Number + 1;        % Advance run count
end
    
Params.Reward.Proportion        = 0.7;                          % Set proportion of reward interval that fixation must be maintained for (0-1)
Params.Reward.MeanIRI           = 0.5;                          % Set mean interval between trial end and reward delivery (seconds)
Params.Reward.RandIRI           = 0.25;                      	% Set random jitter between reward delivery intervals (seconds)
Params.Reward.TTLDur            = 0.05;                         % Set TTL pulse duration (seconds)
Params.Reward.RunCount          = 0;                            % Count how many reward delvieries in this run
Params.DPx.UseDPx               = 1;                            % Use DataPixx?

%================= OPEN NEW PTB WINDOW?
Params = SCNI_OpenWindow(Params);

%================= INITIALIZE SETTINGS
Params 	= SCNI_InitializeGrid(Params);
Params	= SCNI_GetPDrect(Params, Params.Display.UseSBS3D);
Params  = SCNI_DataPixxInit(Params);
Params  = SCNI_InitKeyboard(Params);


%================= GENERATE FIXATION TEXTURE
switch Params.Eye.MarkerType
    case 1  	%============ Dot fixation marker
        Fix.Type        = Params.Eye.MarkerType;            % Fixation marker format = dot
        Fix.Color       = Params.Eye.MarkerColor;       	% Fixation marker color (RGB, 0-1)
        Fix.MarkerSize  = Params.Eye.MarkerDiam;          	% Fixation marker diameter (degrees)
        Fix.LineWidth   = 4;                                % Fixation marker line width (pixels)
        Fix.Size        = Fix.MarkerSize*Params.Display.PixPerDeg;
        Params.Eye.FixTex = SCNI_GenerateFixMarker(Fix, Params);
    
    case 2   	%============ Image fixation marker
        
        
    case 3      %============ Movie fixation marker
        
        
end

%================ PREPARE GRID FOR EXP. DISPLAY
Params = SCNI_InitializeGrid(Params);

%================= CACLULATE TARGET POSITIONS
Params.Eye.NoPoints = Params.Eye.NoPointsList{Params.Eye.CalType}(Params.Eye.NoPoint);
Params              = SCNI_GenerateCalTargets(Params);
Params.Eye.GazeRect = [1, 1, Params.Eye.FixDist.*Params.Display.PixPerDeg];

if Params.Eye.CalMode == 1              % Is mouse simulation mode is selected...
    Params.Eye.EyeToUse = 1;            % Default to left eye only
end

if Params.Display.UseSBS3D == 0
    NoEyes           	= 1;
elseif Params.Display.UseSBS3D == 1
    NoEyes              = 2;
end


%% ============================ BEGIN RUN =================================
FrameOnset              = GetSecs;

while Params.Run.TrialCount < Params.Eye.TrialsPerRun && Params.Run.ExpQuit == 0

    %================= Initialize DataPixx/ send event codes
    AdcStatus = SCNI_StartADC(Params);                                  % Start DataPixx ADC
%     Datapixx('RegWrRd'); 
%     WaitSecs(0.01);
    SCNI_SendEventCode('Trial_Start', Params);                       	% Send event code to connected neurophys systems

    for StimNo = 1:Params.Eye.StimPerTrial                              % Loop through stimuli for this trial
        Params.Run.CurrentStimNo = StimNo;
        if Params.Eye.CenterOnly == 1
            LocIndx     = find(ismember(Params.Eye.Target.FixLocDirections,[0,0],'rows'));
        elseif Params.Eye.CenterOnly == 0
            LocIndx     = Params.Eye.Target.LocationOrder(Params.Run.StimCount);
        end
        GazeRect    = Params.Eye.Target.GazeRect{LocIndx};
        Params.Eye.GazeRect = GazeRect;
        
        %% ================== WAIT FOR ISI TO ELAPSE ======================
        Params.Run.StimOffTime  = GetSecs;
        while (GetSecs - Params.Run.StimOffTime) < Params.Eye.ISIms/10^3 && Params.Run.ExpQuit == 0
            
            Screen('FillRect', Params.Display.win, Params.Display.Exp.BackgroundColor*255);                                             % Clear previous frame
            for Eye = 1:NoEyes 
                if Params.Display.PD.Position > 1
                    Screen('FillOval', Params.Display.win, Params.Display.PD.Color{1}*255, Params.Display.PD.SubRect(Eye,:));
                    Screen('FillOval', Params.Display.win, Params.Display.PD.Color{1}*255, Params.Display.PD.ExpRect);
                end
            end

            %=============== Check current eye position
            Eye         = SCNI_GetEyePos(Params);                                                           % Get screen coordinates of current gaze position (pixels)
            EyeRect   	= repmat(round(Eye(Params.Eye.EyeToUse).Pixels([1,2])),[1,2]) +[-10,-10,10,10]; 	% Prepare rect to draw current gaze position
            [FixIn, FixDist]= SCNI_IsInFixWin(Eye(Params.Eye.EyeToUse).Pixels, Params.Eye.Target.FixLocations(LocIndx,:), [], Params);            % Check if gaze position is inside fixation window
            
            %=============== Check whether to deliver reward
            ValidFixNans 	= find(isnan(Params.Run.ValidFixations(Params.Run.TrialCount,:,1)), 1);         % Find first NaN elements in fix vector
            Params.Run.ValidFixations(Params.Run.TrialCount, ValidFixNans,:) = [GetSecs, FixDist, FixIn];   % Save current fixation result to matrix                                                      

            %=============== Draw experimenter's overlay
            if Params.Display.Exp.GridOn == 1
                Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye, Params.Display.Grid.BullsEyeWidth);                % Draw grid lines
                Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye(:,2:2:end), Params.Display.Grid.BullsEyeWidth+2);   % Draw even lines thicker
                Screen('DrawLines', Params.Display.win, Params.Display.Grid.Meridians, 1, Params.Display.Exp.GridColor*255);                
            end
            if Params.Display.Exp.GazeWinOn == 1
                if Params.Eye.MarkerType == 1
                    Screen('FrameOval', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
                elseif Params.Eye.MarkerType > 1
                    Screen('FrameRect', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
                end
            end
            if Eye(Params.Eye.EyeToUse).Pixels(1) < Params.Display.Rect(3)
                Screen('FillOval', Params.Display.win, Params.Display.Exp.EyeColor(FixIn+1,:)*255, EyeRect);                            % Draw current gaze position
            end
            Params       	= SCNI_UpdateStats(Params);
            
            %=============== Draw to screen and record time
            [~,ISIoffset]  	= Screen('Flip', Params.Display.win); 
            if Params.Run.StimIsOn == 1                                                                 % If the stimulus was ON during the last frame...
                Params.Run.StimIsOn = 0;                                                                % Change state (stimulus is now off)
                SCNI_SendEventCode('Stim_Off', Params);                                                 % Send event code to connected neurophys systems
                Params.Run.StimOffTime = ISIoffset;                                                     % Record time stamp at which stimulus was removed
            elseif Params.Run.StimIsOn == 0
                if StimNo == 1                                                                          % If this is the first stimulus of the current trial...                                                          
                    SCNI_SendEventCode('Fix_On', Params);                                             	% Send event code to connected neurophys systems
                end
            end
            
            %=============== Check experimenter's input
            Params = CheckKeys(Params);                                                     % Check for keyboard input
            if isfield(Params.Toolbar,'StopButton') && get(Params.Toolbar.StopButton,'value')==1     	% Check for toolbar input
                Params.Run.ExpQuit = 1;
            end
        end

        %================= SET NEXT STIMULUS RECT
        FixRectExp     = Params.Eye.Target.FixRects{LocIndx};
        FixRectMonk    = Params.Eye.Target.MonkeyFixRect{LocIndx};

        
        %=============== Get next texture
        if Params.Eye.MarkerType > 1
            %Stim    = Params.Design.StimMatrix(Params.Run.Number, Params.Run.StimCount);             	% Get stimulus number from design matrix
            Stim    = randi(numel(Params.Eye.ImgTex));
            Params.Eye.FixTex = Params.Eye.ImgTex(Stim);                                                % Get texture handle for next stimulus
        end
        SCNI_SendEventCode(LocIndx, Params);                                                           	% Send stimulus position number to neurophys. system 


        %% ================= BEGIN NEXT IMAGE PRESENTATION ================
        Params.Run.StimOnTime = GetSecs;
        while (GetSecs-Params.Run.StimOnTime) < Params.Eye.Duration/10^3 && Params.Run.ExpQuit == 0

            
            %=============== Begin drawing to displays
            Screen('FillRect', Params.Display.win, Params.Display.Exp.BackgroundColor*255);               	% Clear previous frame                                                                          
          	for Eye = 1:NoEyes     
                %============ Draw photodiode marker
                if Params.Display.PD.Position > 1
                    Screen('FillOval', Params.Display.win, Params.Display.PD.Color{2}*255, Params.Display.PD.SubRect(Eye,:));
                    Screen('FillOval', Params.Display.win, Params.Display.PD.Color{2}*255, Params.Display.PD.ExpRect);
                end
                %============ Draw fixation marker
             	Screen('DrawTexture', Params.Display.win, Params.Eye.FixTex, [], FixRectMonk(Eye,:), [], [], Params.Eye.MarkerContrast);  	% Draw fixation marker
            end

            %=============== Check current eye position
        	Eye         = SCNI_GetEyePos(Params);                                                           % Get screen coordinates of current gaze position (pixels)
          	EyeRect   	= repmat(round(Eye(Params.Eye.EyeToUse).Pixels([1,2])),[1,2]) +[-10,-10,10,10]; 	% Prepare rect to draw current gaze position
            [FixIn, FixDist]= SCNI_IsInFixWin(Eye(Params.Eye.EyeToUse).Pixels, Params.Eye.Target.FixLocations(LocIndx,:), [], Params);            % Check if gaze position is inside fixation window
            
            %=============== Check whether to deliver reward
            ValidFixNans 	= find(isnan(Params.Run.ValidFixations(Params.Run.TrialCount,:,:)), 1);       	% Find first NaN elements in fix matrix
            Params.Run.ValidFixations(Params.Run.TrialCount, ValidFixNans,:) = [GetSecs, FixDist, FixIn];  	% Save current fixation result to matrix                                                          

            %=============== Draw experimenter's overlay
            if Params.Display.Exp.GridOn == 1
                Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye, Params.Display.Grid.BullsEyeWidth);                % Draw grid lines
                Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye(:,2:2:end), Params.Display.Grid.BullsEyeWidth+2);   % Draw even lines thicker
                Screen('DrawLines', Params.Display.win, Params.Display.Grid.Meridians, 1, Params.Display.Exp.GridColor*255);                
            end
            if Params.Display.Exp.GazeWinOn == 1
                if Params.Eye.MarkerType == 1
                    Screen('FrameOval', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
                elseif Params.Eye.MarkerType > 1
                    Screen('FrameRect', Params.Display.win, Params.Display.Exp.GazeWinColor(FixIn+1,:)*255, GazeRect, 3); 	% Draw border of gaze window that subject must fixate within
                end
            end
            Screen('DrawTexture', Params.Display.win, Params.Eye.FixTex, [], FixRectExp, [], [], Params.Eye.MarkerContrast);  	% Draw fixation marker
            if Eye(Params.Eye.EyeToUse).Pixels(1) < Params.Display.Rect(3)
                Screen('FillOval', Params.Display.win, Params.Display.Exp.EyeColor(FixIn+1,:)*255, EyeRect);    % Draw current gaze position
            end
            Params         = SCNI_UpdateStats(Params);                                                      % Update statistics on experimenter's screen
            
            %=============== Draw to screen and record time
            [VBL FrameOnset(end+1)] = Screen('Flip', Params.Display.win);                                   % Flip next frame
            if Params.Run.StimIsOn == 0                                                                     % If this is first frame of stimulus presentation...
                SCNI_SendEventCode('Stim_On', Params);                                                      % Send event code to connected neurophys systems
                Params.Run.StimIsOn     = 1;                                                              	% Change flag to show movie has started
                Params.Run.StimOnTime   = FrameOnset(end);                                                  % Record stimulus onset time
            end
            
            %=============== Check experimenter's input
            Params = CheckKeys(Params);                                                         % Check for keyboard input
            if isfield(Params.Toolbar,'StopButton') && get(Params.Toolbar.StopButton,'value') == 1
                Params.Run.ExpQuit = 1;
            end

        end
        Params.Run.StimCount = Params.Run.StimCount+1;                                                      % Count as one stimulus presentation
    end
    

    %% ================= WAIT FOR ITI TO ELAPSE
    Params.Run.RewardGiven = 0;
    while (GetSecs - FrameOnset(end)) < Params.Eye.ITIms/10^3 && Params.Run.ExpQuit == 0
        for Eye = 1:NoEyes 
            Screen('FillRect', Params.Display.win, Params.Display.Exp.BackgroundColor*255);                                             	% Clear previous frame
            if Params.Display.PD.Position > 1
                Screen('FillOval', Params.Display.win, Params.Display.PD.Color{1}*255, Params.Display.PD.SubRect(Eye,:));
                Screen('FillOval', Params.Display.win, Params.Display.PD.Color{1}*255, Params.Display.PD.ExpRect);
            end
        end

        %=============== Check current eye position
        Eye         = SCNI_GetEyePos(Params);                                                               % Get screen coordinates of current gaze position (pixels)
      	EyeRect   	= repmat(round(Eye(Params.Eye.EyeToUse).Pixels),[1,2]) +[-10,-10,10,10];                % Prepare rect to draw current gaze position                                                       

        %=============== Draw experimenter's overlay
        if Params.Display.Exp.GridOn == 1
            Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye, Params.Display.Grid.BullsEyeWidth);                % Draw grid lines
            Screen('FrameOval', Params.Display.win, Params.Display.Exp.GridColor*255, Params.Display.Grid.Bullseye(:,2:2:end), Params.Display.Grid.BullsEyeWidth+2);   % Draw even lines thicker
            Screen('DrawLines', Params.Display.win, Params.Display.Grid.Meridians, 1, Params.Display.Exp.GridColor*255);                
        end
        if Eye(Params.Eye.EyeToUse).Pixels(1) < Params.Display.Rect(3)
            Screen('FillOval', Params.Display.win, Params.Display.Exp.EyeColor(FixIn+1,:)*255, EyeRect);                            % Draw current gaze position
        end
        Params       	= SCNI_UpdateStats(Params);

        %=============== Draw to screen and record time
        [~,ISIoffset]  	= Screen('Flip', Params.Display.win); 
        if Params.Run.StimIsOn == 1
            Params.Run.StimIsOn     = 0;
            SCNI_SendEventCode('Stim_Off', Params);                                                         % Send event code to connected neurophys systems
            SCNI_SendEventCode('Fix_Off', Params);                                                          % Send event code to connected neurophys systems
            Params.Run.StimOffTime      = ISIoffset;
            Params.Run.StimOnTime       = ISIoffset;
            
            %=============== Check performance
            Params 	= SCNI_CheckTrialEyePos(Params);
            Params.Reward.NextRewardInt	= Params.Reward.MeanIRI + rand(1)*Params.Reward.RandIRI;           	% Generate random interval before first reward delivery (seconds)
        end
        
        %=============== Give reward
        if Params.Run.ValidTrial == 1 && Params.Run.RewardGiven == 0
            if GetSecs >= Params.Run.StimOffTime+Params.Reward.NextRewardInt    % If next reward is scheduled...
                Params = SCNI_GiveReward(Params);
                Params.Run.RewardGiven = 1;
            end
        end
        
        %=============== Check experimenter's input
        Params = CheckKeys(Params);                                                     % Check for keyboard input
        if isfield(Params.Toolbar,'StopButton') && get(Params.Toolbar.StopButton,'value')==1    	% Check for toolbar input
            Params.Run.ExpQuit = 1;
        end
    end
    Params.Run.TrialCount = Params.Run.TrialCount+1;        % Count as one trial
    
end


%============== Run was aborted by experimenter
if Params.Run.ExpQuit == 1
    

end
    
SCNI_SendEventCode('Block_End', Params);   
SCNI_EndRun(Params);
 

end



%% ============================ SUBFUNCTIONS ==============================

%=============== CHECK FOR EXPERIMENTER INPUT
function [Params] = CheckKeys(Params)
    Params.Run.ExpQuit = 0;
    [keyIsDown,secs,keyCode] = KbCheck([], Params.Eye.KeysList);        	% Check keyboard for relevant key presses 
    if keyIsDown && secs > Params.Run.LastPress+Params.Eye.Keys.Interval 	% If key is pressed and it's more than 100ms since last key press...
        Params.Run.LastPress   = secs;                                    	% Log time of current key press
        if keyCode(Params.Eye.Keys.Stop) == 1                           	% Experimenter pressed quit key
            SCNI_SendEventCode('ExpAborted', Params);                     	% Inform neurophys. system
            SCNI_EndRun(Params);
            Params.Run.ExpQuit = 1;
        elseif keyCode(Params.Eye.Keys.Reward) == 1                      	% Experimenter pressed manual reward key
            Params = SCNI_GiveReward(Params);
        elseif keyCode(Params.Eye.Keys.Audio) == 1                          % Experimenter pressed play sound key
            Params = SCNI_PlaySound(Params); 
        elseif keyCode(Params.Eye.Keys.Center) == 1                         % Experimenter pressed 'center' key
            Params = SCNI_UpdateCenter(Params);
        elseif keyCode(Params.Eye.Keys.ChangeEye) == 1                      % Experimenter pressed 'next eye' key
            if Params.Eye.CalMode > 1
                Params.Eye.EyeToUse = Params.Eye.EyeToUse + 1;
                if Params.Eye.EyeToUse > 3
                    Params.Eye.EyeToUse = 1;
                end
            end
        elseif keyCode(Params.Eye.Keys.GainInc) == 1 
            Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected) = Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected)+Params.Eye.GainIncrement;
            
        elseif keyCode(Params.Eye.Keys.GainDec) == 1 
            Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected) = Params.Eye.Cal.Gain{Params.Eye.EyeToUse}(Params.Eye.XYselected)-Params.Eye.GainIncrement;
            
        elseif keyCode(Params.Eye.Keys.ChangeXY) == 1 
            Params.Eye.XYselected = Params.Eye.XYselected + 1;
          	if Params.Eye.XYselected > 2
                Params.Eye.XYselected = 1;
            end
        elseif keyCode(Params.Eye.Keys.Invert) == 1
            Params.Eye.Cal.Sign{Params.Eye.EyeToUse}(Params.Eye.XYselected) = -Params.Eye.Cal.Sign{Params.Eye.EyeToUse}(Params.Eye.XYselected);
      	elseif keyCode(Params.Eye.Keys.Save) == 1
            %Params = SaveCal(Params);
    	elseif keyCode(Params.Eye.Keys.Mouse) == 1
            Params = SCNI_UpdateCenterFromMouse(Params);
        end
    end
end

%=============== SAVE CALIBRATION PARAMETERS
function SaveCal(Params)
    
    
end

%=============== UPDATE CENTER GAZE POSITION
function Params = SCNI_UpdateCenter(Params)
    Eye         = SCNI_GetEyePos(Params);                                   % Get screen coordinates of current gaze position (pixels)
    Params.Eye.Cal.Offset{Params.Eye.EyeToUse}  =  -Eye(Params.Eye.EyeToUse).Volts;
end

%=============== UPDATE CENTER GAZE POSITION BASED ON MOUSE CURSOR
function Params = SCNI_UpdateCenterFromMouse(Params)
    [EyeX, EyeY, buttons] = GetMouse(Params.Display.win);                                   % Get mouse cursor position (relative to top left)
    if EyeX > 0 && EyeY > 0
        Eye.Pixels  = [EyeX, EyeY];                                                        	% 
        Eye.PixCntr = Eye.Pixels-Params.Display.Rect([3,4])/2;                           	% Center coordinates
        Eye.Degrees = Eye.PixCntr./Params.Display.PixPerDeg;                              	% Convert pixels to degrees
        Eye.Volts   = (Eye.Degrees./Params.Eye.Cal.Gain{Params.Eye.EyeToUse})+Params.Eye.Cal.Offset{Params.Eye.EyeToUse};	% Convert degrees to volts
        Eye.Volts
        Params.Eye.Cal.Offset{Params.Eye.EyeToUse}  =  -Eye.Volts;                          % Update voltage offset
    end
end

%=============== END RUN
function SCNI_EndRun(Params)
    Screen('FillRect', Params.Display.win, Params.Display.Exp.BackgroundColor*255);     % Clear screens
    Screen('Flip', Params.Display.win); 
    ListenChar(1); 
    return;
end

%================= UPDATE EXPERIMENTER'S DISPLAY STATSc
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
        
        Params.Run.TextFormat    = ['Run             %d\n\n',...
                                    'Trial #         %d / %d\n\n',...
                                    'Stim #          %d / %d\n\n',...
                                    'Time elapsed    %02d:%02.0f\n\n',...
                                    'Reward count    %d\n\n',...
                                    'Valid fixation  %.0f %%'];
        Params.Run.EyeTextFormat = ['Offset (V)      %.2f,  %.2f\n\n',...
                                    'Gain (deg/V)    %.2f,  %.2f\n\n',...
                                    'Invert          %d,    %d\n\n'];
        if Params.Display.Rect(3) > 1920
           Screen('TextSize', Params.Display.win, 40);
           Screen('TextFont', Params.Display.win, 'Courier');
        end
        Params.Run.GainBoxRects{1}    = repmat([Params.Run.TextRect(1)+350, sum(Params.Run.TextRect([2,4]))+200],[1,2]) + [0,0,160,80];
        Params.Run.GainBoxRects{2}    = Params.Run.GainBoxRects{1}+[180,0,180,0];
    end

	Params.Run.ValidFixPercent = nanmean(nanmean(Params.Run.ValidFixations(1:Params.Run.TrialCount,:,3)))*100;

    %========= Update clock
	Params.Run.CurrentTime      = GetSecs-Params.Run.StartTime;                                            % Calulate time elapsed
    Params.Run.CurrentMins      = floor(Params.Run.CurrentTime/60);                    
    Params.Run.CurrentSecs      = rem(Params.Run.CurrentTime, 60);
    Params.Run.CurrentPercent   = (Params.Run.TrialCount/Params.Eye.TrialsPerRun)*100;
	Params.Run.TextContent      = [Params.Run.Number, Params.Run.TrialCount, Params.Eye.TrialsPerRun, Params.Run.CurrentStimNo, Params.Eye.StimPerTrial, Params.Run.CurrentMins, Params.Run.CurrentSecs, Params.Reward.RunCount, Params.Run.ValidFixPercent];
    Params.Run.TextString       = sprintf(Params.Run.TextFormat, Params.Run.TextContent);

    Params.Run.EyeTextContent   = [Params.Eye.Cal.Offset{Params.Eye.EyeToUse}, Params.Eye.Cal.Gain{Params.Eye.EyeToUse}, Params.Eye.Cal.Sign{Params.Eye.EyeToUse}];
    Params.Run.EyeTextString    = [sprintf('Eye             %s\n\n', Params.Eye.Cal.Labels{Params.Eye.EyeToUse}), sprintf(Params.Run.EyeTextFormat, Params.Run.EyeTextContent)];
    
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
    DrawFormattedText(Params.Display.win, Params.Run.EyeTextString, Params.Run.TextRect(1), sum(Params.Run.TextRect([2,4]))+100, Params.Run.EyeColors{Params.Eye.EyeToUse}*255);
    Screen('FrameRect', Params.Display.win, [0,255,255], Params.Run.GainBoxRects{Params.Eye.XYselected}, 3);
end