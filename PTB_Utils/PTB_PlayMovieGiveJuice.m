% PTB_PlayMovieGiveJuice.m

%function PTB_PlayMovieGiveJuice(Number)

MovieOn = 1;
n = 1;
FixOn = 0;

% Set reward schedule
%addpath(genpath('/nifvault/projects/murphyap_NIF/NIF_Code/NIF-Toolbar/PTB_Utils/PTB_Subfunctions'))
RewardInterval  = 3; 
StartTime       = GetSecs;
RewardGiven     = 0;


%================= INITIALIZE SETTINGS
% Params.DPx.Installed = 1;
Params  = PTB_LoadParams();
Params  = PTB_DataPixxInit(Params);                                % Initialize DataPixx
Params 	= PTB_InitializeGrid(Params);                              % Initialize experimenter's display grid
Params	= PTB_GetPDrect(Params, Params.Display.UseSBS3D);          % Initialize photodiode location(s)
Params  = PTB_InitKeyboard(Params);                                % Initialize keyboard shortcuts
Params  = PTB_ScreenRects(Params);                                  

Params = PTB_EyeCalibSettings(Params);

% Open movie file
Params = load('PTB_nif-stim-dpx.mat');
Params.Display.Win = Screen('OpenWindow', 1);
    
%Params.Run.CurrentFile = '/home/lab/Videos/MurphyMovies/Lucid_Concat.mp4';
%Params.StimDir = '/home/lab/Videos/MurphyMovies/NIF_Dome/';
%Params.StimDir = '/home/lab/Videos/MurphyMovies/HarishMovies/';
%Params.StimDir = '/home/lab/Videos/RussMovies/RussMoviesWMV/';
%Params.StimDir = '/home/lab/Videos/MurphyMovies/ShortClipRuns/';
Params.StimDir = '/home/lab/Videos/MurphyMovies/MacaqueDocs/';

x = dir(Params.StimDir);
MovFiles = {x.name};
MovFiles = MovFiles(3:end);


if n >3
    Loop = -1;
    n = n-2;
else
    Loop = 1;
end
fprintf('Playing movie %s (%d)...\n', MovFiles{n}, n)
Params.Run.CurrentFile = fullfile(Params.StimDir, MovFiles{n});

[mov, Movie.duration, Movie.fps, Movie.width, Movie.height, Movie.count, Movie.AR] = Screen('OpenMovie', Params.Display.Win, Params.Run.CurrentFile); 
Screen('PlayMovie',mov, Loop);
RectExp = [0,0,1920,1080];
RectMonk = RectExp+[1920,0,1920,0];


Fix.Type        = 1;                                        % Fixation marker format
Fix.Color       = [0,1,0];                                 	% Fixation marker color (RGB, 0-1)
Fix.MarkerSize  = 1;                                        % Fixation marker diameter (degrees)
Fix.LineWidth   = 4;                                        % Fixation marker line width (pixels)
Fix.Size        = Fix.MarkerSize*20;
FixTex          = PTB_GenerateFixMarker(Fix, Params);
FixRectExp      = CenterRect([0,0,Fix.Size,Fix.Size],RectExp);
FixRectMonk      = CenterRect([0,0,Fix.Size,Fix.Size],RectMonk);

SolenoidDurationMs = 100;  
fprintf('Press ''space'' to give reward (%d ms) or ''Esc'' to quit.\n', SolenoidDurationMs)
LastPress   = GetSecs;
RewardCount = 0;
LastReward  = GetSecs;
TimeOut     = 0;
NoTTLs      = 4;

Params.DPx.AnalogIn.Options{7}  = 'Scanner TTL';
Params.DPx.AnalogIn.Options{12} = 'None';
% Params.Display.Win = Params.Display.win;

Polarity        = 1;
PrintOutput     = 1;
ScannerOn       = PTB_WaitForTTL(Params, NoTTLs, Polarity, PrintOutput);

% Start run
while 1
    if MovieOn == 1
        MovieTex = Screen('GetMovieImage', Params.Display.Win, mov);    
        Screen('DrawTexture', Params.Display.Win, MovieTex,  [], RectExp);
        Screen('DrawTexture', Params.Display.Win, MovieTex,  [], RectMonk);
        Screen('Close', MovieTex);
        if FixOn == 1
            Screen('DrawTexture', Params.Display.Win, FixTex,  [], FixRectExp);
            Screen('DrawTexture', Params.Display.Win, FixTex,  [], FixRectMonk);
        end
        Screen('flip', Params.Display.Win);
    end
    
    %=============== Check current eye position
    Eye         = PTB_GetEyePos(Params);
    EyeRect   	= repmat(round(Eye(Params.Eye.EyeToUse).Pixels),[1,2])+[-10,-10,10,10]; 
    [FixIn, FixDist]= PTB_IsInFixWin(Eye(Params.Eye.EyeToUse).Pixels, [], Params.Movie.FixOn==0, Params);	% Check if gaze position is inside fixation window


    if RewardGiven == 0
        if mod(floor(GetSecs - StartTime), RewardInterval) == 0
            Datapixx('SetDacSchedule', 0, ParamsDPx.DPx.AnalogOutRate, ParamsDPx.DPx.ndacsamples, ParamsDPx.DPx.RewardChnl, ParamsDPx.DPx.dacBuffAddr, ParamsDPx.DPx.ndacsamples);
            Datapixx('StartDacSchedule');
            Datapixx('RegWrRd');

            fprintf('Reward given!\n');
            RewardGiven = 1;
        end
    elseif RewardGiven == 1 && mod(floor(GetSecs - StartTime), RewardInterval) == 1
        RewardGiven = 0;
    end
    
    
end


Screen('CloseAll');
fprintf('Movie ended after %.1 minutes', (GetSecs-StartTime)/60);

