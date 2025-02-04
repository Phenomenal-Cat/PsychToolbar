
% PlayMovieGiveJuice.m

MovieOn = 1;

% Set reward schedule
addpath(genpath('/nifvault/projects/murphyap_NIF/NIF_Code/NIF-Toolbar/NTB_Utils/SCNI_Subfunctions'))
RewardInterval = 10; 
StartTime = GetSecs;
RewardGiven = 0;
ParamsDPx = load('/nifvault/projects/murphya/SCNI_Datapixx/SCNI_Toolbar/SCNI_Parameters/vpixx-HP-Z240-Tower-Workstation.mat');
% ParamsDPx = load('/nifvault/projects/murphyap_NIF/NIF_Code/NIF-Toolbar/NTB_Params/NTB_MH02183714MACLT.mat');
ParamsDPx = SCNI_DataPixxInit(ParamsDPx);
ParamsDPx.DPx.RewardChnl = 1;


% Open movie file
if MovieOn == 1
    Params.Display.win = Screen('OpenWindow', 1);
    Params.Run.CurrentFile = '/home/lab/Videos/MurphyMovies/ShortClip Runs/Localizer_ShortClips_Run_2.mpg';
    [mov, Movie.duration, Movie.fps, Movie.width, Movie.height, Movie.count, Movie.AR] = Screen('OpenMovie', Params.Display.win, Params.Run.CurrentFile); 
    Screen('PlayMovie',mov, 1);
    RectExp = [0,0,1920,1080];
    RectMonk = RectExp+[1920,0,1920,0];
end


% Start run
while 1
    if MovieOn == 1
        MovieTex = Screen('GetMovieImage', Params.Display.win, mov);    
        Screen('DrawTexture', Params.Display.win, MovieTex,  [], RectExp);
        Screen('DrawTexture', Params.Display.win, MovieTex,  [], RectMonk);
        Screen('Close', MovieTex);
        Screen('flip', Params.Display.win);
    end
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

sca;