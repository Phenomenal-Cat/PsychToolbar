% Test manual reward

function EyePos = ManualRewardTest()


SubjectIndx = 1; % <<<<<<<<<< Change this number to select subject (1 = Palak, 2 = Peshwari )
SubjectNames = {'Palak','Peshwari'};

if strcmp(SubjectNames{SubjectIndx}, 'Palak')
    SolenoidDurationMs  = 300; 
    FixType             = 1;    % 0 = none; 1 = fix dot; 2 = faces
    FixDur              = 4;   % Duration of fixation marker presentation (seconds)
    FixRewardRate       = 0.5;  % Seconds
    FixWidthPx          = 30;   % Width of fixation marker / image in pixels 
    PresentImages       = 1;    % Present large images in background?
    ImWidthPx           = 800;  % Diameter of background image (pixels)

elseif strcmp(SubjectNames{SubjectIndx}, 'Peshwari')
    SolenoidDurationMs  = 300; 
    FixType             = 1;    % 0 = none; 1 = fix dot; 2 = faces
    FixDur              = 10;    % Duration of fixation marker presentation (seconds)
    FixRewardRate       = 0.75;  %Seconds
    FixWidthPx          = 50;  % Width of fixation marker / image in pixels
    PresentImages       = 0;
    ImWidthPx           = 800;  % Disameter of backgroudn image (pixels)
end
AutomaticReward    = false;        
RewardInterval     = 8;
TimeOutDur         = 4; 
FixInterval         = 0; 
FixPosCenterOnly    = 1;
FixColorRandom      = 0;
FixColor            = [0,1,1]*255;

Screen('Preference','SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
ListenChar(2);

if ~IsWin
    BackgroundRGB   = [127,127,127]/4;
    win             = Screen('OpenWindow', 1, BackgroundRGB);
    ScreenDims      = Screen('Rect',1).*[1,1,0.5,1];
    ImageDir        = '/home/lab/Documents/NIF/FixTraining/FixFaces/';
    AllFiles        = dir(ImageDir);
    AllFiles        = {AllFiles(3:end).name};
    RewardKey       = 'space';

elseif IsWin
    BackgroundRGB   = [127,127,127]/2;
    Resolution      = [0,0,1920,1080];
    WindowsRect     = [Resolution(3), 0, Resolution(3)*3, Resolution(4)]; 
    win             = Screen('OpenWindow', 0, BackgroundRGB, WindowsRect);
    ScreenDims      = Resolution;
    ImageDir        = 'C:\Users\nifsupport.MH02183165DT\Documents\Stimuli\PrimFace_01';
    AllFiles        = dir(ImageDir);
    AllFiles        = {AllFiles(4:end).name};
    RewardKey       = 'r';
end

Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('ColorRange', win, 255);   
Screen('FillRect', win, BackgroundRGB);
Screen('Flip', win);
KbName('UnifyKeyNames');

%========== Fixation settings
FixDims     = [0,0,FixWidthPx,FixWidthPx];
FixReqDims  = [0,0,200,200];
FixOffsets  = [0,0;  0,1; 1,1; 1,0; 1,-1; 0,-1; -1,-1; -1,0; -1,1];
FixOffsetPx = 400;
ImDims      = [0,0,ImWidthPx,ImWidthPx];
ImRect{1}   = CenterRect(ImDims,ScreenDims);
ImRect{2}   = ImRect{1}+[ScreenDims(3), 0, ScreenDims(3), 0];
if FixPosCenterOnly == 1
    FixRect{1,1}  = CenterRect(FixDims,ScreenDims);
    FixRect{1,2}  = FixRect{1,1}+[ScreenDims(3), 0, ScreenDims(3), 0];
    FixReqRect{1,1} = CenterRect(FixReqDims,ScreenDims);
    FixReqRect{1,2} = FixReqRect{1,1}+[ScreenDims(3), 0, ScreenDims(3), 0];
    
elseif FixPosCenterOnly == 0
    for n = 1:size(FixOffsets,1)
        FixRect{n,1}  = CenterRect(FixDims,ScreenDims) + repmat([FixOffsets(n,:)*FixOffsetPx],[1,2]);
        FixRect{n,2}  = FixRect{n,1}+[ScreenDims(3), 0, ScreenDims(3), 0];
        FixReqRect{n,1} = CenterRect(FixReqDims,ScreenDims) + repmat([FixOffsets(n,:)*FixOffsetPx],[1,2]);
        FixReqRect{n,2} = FixReqRect{n,1}+[ScreenDims(3), 0, ScreenDims(3), 0];
    end
end

FixIsOn     = 0;   
FixOnset    = GetSecs;
FixOffset   = GetSecs;
LastFlip    = GetSecs;      
if FixType == 2 || PresentImages == 1
    FaceRect = [];
    for f = 1:numel(AllFiles)
        fprintf('Loading image %d / %d to offscreen texture...\n', f, numel(AllFiles));
        FaceIm = imread(fullfile(ImageDir, AllFiles{f}));
        [~,~,FaceAlpha] = imread(fullfile(ImageDir, AllFiles{f}));
        FaceIm = double(FaceIm);
        FaceIm(:,:,4) = double(FaceAlpha);
        FaceTex{f} = Screen('MakeTexture', win, FaceIm);
    end
end

%========= General DataPixx settings;
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('DisableDinDebounce');
Datapixx('SetDinLog');
Datapixx('StartDinLog');
Datapixx('SetDoutValues',0);
Datapixx('RegWrRd');
Datapixx('DisableDacAdcLoopback');
Datapixx('EnableAdcFreeRunning');
Datapixx('RegWrRd');


%===== DAC channels
nChannels = Datapixx('GetDacNumChannels');
dacRanges = Datapixx('GetDacRanges');  
dacBufferAddress     = 8e6;  

%===== ADC channels
nAChannels      = Datapixx('GetAdcNumChannels');
adcChannels     = 1:10;
adcRanges       = Datapixx('GetAdcRanges');
analogInRate    = 1000;
adcBufferAddress = 4e6;                                                                            % Set DataPixx internal ADC buffer address

Datapixx('SetAdcSchedule', 0, analogInRate, 0, adcChannels, adcBufferAddress, 2000); %300000);
Datapixx('StartAdcSchedule');
Datapixx('RegWrRd');

if IsWin
    EyeChannels = [1,2];
    EyePos.Gain = [150,150];
elseif ~IsWin
    EyeChannels = [4,5];
    EyePos.Gain = [400,400];
end
EyePos.V  = [];
EyePos.OffsetV = [0,0];
nSamples        = 10;  
EyePosColor     = {[1,0,0]*255, [0,1,0]*255};
EyePos.Px       = zeros(nSamples,2);
EyeIsIn         = 0;
NewFixPos       = 1;
FixStartTime    = GetSecs;
FixEndTime      = GetSecs;


fprintf('Press ''space'' to give reward (%d ms) or ''Esc'' to quit.\n', SolenoidDurationMs)
LastPress = GetSecs;
RewardCount = 0;
LastReward  = GetSecs;
TimeOut = 0;
while 1  

    %============ Check user input
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyIsDown & GetSecs > LastPress+0.2          
        LastPress = secs;
        if keyCode(KbName(RewardKey))
            RewardCount = RewardCount+1;
            fprintf('Giving reward %d...\n', RewardCount);             
            RewardTime = GiveReward(SolenoidDurationMs);
        elseif keyCode(KbName('t'))
            if TimeOut == 0
                TimeOut = 1;
                TimeOutStart = GetSecs;
                fprintf('Time out started!')
            end
        elseif keyCode(KbName('Escape'))
            Screen('CloseAll');
            ListenChar(0);
            %clc;
            return; 
        elseif keyCode(KbName('c'))
            EyePos.OffsetV = XYposV;
            fprintf('Eye position center calibrated: %d\n', EyePos.OffsetV);
        elseif keyCode(KbName('uparrow'))
            EyePos.Gain = EyePos.Gain+[20,20];
            fprintf('Eye position gain increased: %d, %d!\n', EyePos.Gain);
        elseif keyCode(KbName('downarrow'))
            EyePos.Gain = EyePos.Gain-[20,20];
            fprintf('Eye position gain decreased: %d, %d!\n', EyePos.Gain);
        elseif keyCode(KbName('p'))
            PlotData(EyePos);
        end
    end


    %============ Draw fixation marker image to screen
    if FixIsOn == 0
        if GetSecs > FixOffset+FixInterval
            FixIsOn =1;
            FixOnset = LastFlip;
            NewFixPos = randi(size(FixRect,1));
            if FixColorRandom == 1
                FixColor    = randi(255,[1,3]);     
            end
            if exist('FaceTex','var')
                NextIm = randi(numel(FaceTex));
            else
                NextIm = [];
            end
            fprintf('Fix on!\n')
        end
    elseif FixIsOn == 1
        if GetSecs > FixOnset+FixDur
            FixIsOn =0;
            FixOffset = LastFlip;
            fprintf('Fix off   !\n')
        end
    end
    Screen('FillRect', win, BackgroundRGB);
    
    %============ Draw background / distractor images to screen
    if PresentImages == 1
        for s = 1:2
            Screen('DrawTexture', win, FaceTex{NextIm}, [], ImRect{s},[],[],1);
        end
    end
    %============ Draw fixation marker image to screen
    if FixIsOn == 1
        for s = 1:2
            if FixType == 1
                Screen('FillOval', win, FixColor, FixRect{NewFixPos, s});
            elseif FixType == 2            
                Screen('DrawTexture', win, FaceTex{NextIm}, [], FixRect{NewFixPos,s});
            end
        end
        Screen('FrameOval', win, EyePosColor{EyeIsIn+1}, FixReqRect{NewFixPos, 1}, 3);
    end
      

    %=========== Check eye position
    Datapixx('RegWrRd');                                                        % Updating registers
    Datapixx('GetAdcStatus');                                                   % Checking ADC status
    Datapixx('RegWrRd');   
    adcDataVoltages = Datapixx('GetAdcVoltages');
    Datapixx('RegWrRd');   
    XYposV = adcDataVoltages(EyeChannels);     
    XYposPx = (XYposV.*EyePos.Gain) - (EyePos.OffsetV.*EyePos.Gain) + ScreenDims([3,4])/2;
    EyePos.V = [EyePos.V; XYposV];
    EyePos.Px = [EyePos.Px; XYposPx];
    XYposPx = mean(EyePos.Px(end-nSamples:end,:),1);
    XYposStd = std(EyePos.Px(end-nSamples:end,:),1);
%     EyeMarker = [0,0,XYposStd];
    EyeMarker = [0,0,20,20];
    if XYposPx(1) < ScreenDims(3)
        if IsInRect(XYposPx(1), XYposPx(2), FixReqRect{NewFixPos, 1})
            if EyeIsIn == 0
                FixStartTime = GetSecs;
            end
            EyeIsIn = 1;
        else
            if EyeIsIn == 1
                FixEndTime = GetSecs;
            end
            EyeIsIn = 0;
        end
        EyePosRect = CenterRectOnPoint(EyeMarker,XYposPx(1), XYposPx(2));
        Screen('FillOval', win, EyePosColor{EyeIsIn+1}, EyePosRect);
    end   
    LastFlip = Screen('Flip', win);
    


    if TimeOut == 1
        if GetSecs > (TimeOutStart + TimeOutDur)
            TimeOut = 0;
            %fprintf('Timeout start: %d\nTimeout Duration: %d', TimeOutStart, TimeOutDur)
        end
    end

   %============ Fixation earned reward
    if EyeIsIn == 1
        FixDurElapsed = GetSecs - FixStartTime;
        if FixDurElapsed > FixRewardRate*NoRewards
            fprintf('Giving reward %d...\n', RewardCount); 
            LastReward = GiveReward(SolenoidDurationMs);
            RewardCount = RewardCount+1;  
            NoRewards = NoRewards+1;
        end
    elseif EyeIsIn == 0
        NoRewards = 1;
    end

    %============ Give reward
    if AutomaticReward && TimeOut == 0
        if GetSecs > LastReward+RewardInterval
            fprintf('Giving reward %d...\n', RewardCount);   
            LastReward = GiveReward(SolenoidDurationMs);
            RewardCount = RewardCount+1;  

        end
    end
end



    function RewardTime = GiveReward(SolenoidDurationMs)
         %==== Set to high
        for channel = 0:nChannels-1
            channelVoltages(1,channel+1) = channel;
            channelVoltages(2,channel+1) = dacRanges(1, channel+1);
        end
        channelVoltages(2,:) = 5;
        Datapixx('SetDacVoltages', channelVoltages);
        Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
        StartTime = GetSecs;
    
        %==== Wait time
        while GetSecs < StartTime+SolenoidDurationMs/10^3
    
        end
    
        %==== Set to low
        for channel = 0:nChannels-1
            channelVoltages(1,channel+1) = channel;
            channelVoltages(2,channel+1) = dacRanges(1, channel+1);
        end
        channelVoltages(2,:) = 0;
        Datapixx('SetDacVoltages', channelVoltages);
        Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
    
        RewardTime = GetSecs;
    end

    function PlotData(EyePos)
        figure;
        for n = 1:size(EyePos.V,2)
            plot(EyePos.V(:,n));
            hold on;
        end
        grid on;
        box off;
        xlabel('Time (samples)')
        ylabel('Voltage (V)')
        legend({'Eye X','Eye Y','Pupil'});
        drawnow;
    end

end
