
% Visual test stimulus for fMRI block

Params = load('NTB_MH02183714MACLT.mat');
Params.Display.Basic.PixPerDeg = Params.Display.Basic.Rect([3,4])./Params.Display.Basic.ScreenDims;


%====== Generate dyamic continuous flash suppresion texture frames
DCFS.Duration       = 2;                % loop duration (seconds)
DCFS.FrameRate      = 10;               % frequency of texel repositioning (Hz) [default = 10Hz]
DCFS.TextureSize    = [40, 40];         % width x height of stimulus texture (degrees)
DCFS.TexelSize      = 5;                % width x height of texture elements (degrees)
DCFS.Color          = 1;                % 0 = grayscale, 1 = color
DCFS.Background     = [127,127,127];    % Background color [R,G,B]
DCFS.TexelsPerFrame = 400;

%===== Open PTB window and generate stim textures
Screen('Preference', 'SkipSyncTests', 1);
Params.Display.Screen.BackgroundColor = DCFS.Background;
Params  = NTB_OpenWindow(Params);
Display = Params.Display;
DCFStextures  = NTB_GenerateDCFS(DCFS, Display, 0, 1);

%===== Generate fixation marker
Fix.MarkerSize  = 2;
Fix.Color       = [255,0,0];
Fix.Type        = 1;
Fix.LineWidth   = 2;
FixTexture      = NTB_GenerateFixMarker(Fix, Params);


%====== Presentaiton params
BlockDuration   = 5;     % Duration in seconds
NoBlocks        = 6;        


Screen('FillRect', Display.Win, DCFS.Background);
DrawFormattedText(Params.Display.Win, 'Press any key to begin.', 500,'center', [1,1,1]*255);
Screen('Flip',Display.Win);
Start = 0;
KbName('UnifyKeyNames');
% while Start == 0
%     [keyIsDown,secs,keyCode] = KbCheck();
%     if any(keyIsDown)
%         Start = 1;
%         break;
%     end
% end

%ScannerOn = NTB_WaitForTTL(Params, 4, 1, 1);



%===== Begin stimulus presentation loop
StartTime = GetSecs;
for b = 1:NoBlocks
    BlockStart(b) = GetSecs;
    while GetSecs < BlockStart(b)+BlockDuration
        [keyIsDown,secs,keyCode] = KbCheck();
        if any(keyIsDown)
            break;
        end
        if mod(b,2) == 1
            Screen('FillRect', Display.Win, DCFS.Background);
            Screen('DrawTexture', Display.Win, FixTexture);
            Screen('Flip',Display.Win);
        elseif mod(b,2) == 0
            for f = 1:numel(DCFStextures)
                [keyIsDown,secs,keyCode] = KbCheck();
                if any(keyIsDown)
                    break;
                end
                Screen('DrawTexture', Display.Win, DCFStextures(f));
                Screen('DrawTexture', Display.Win, FixTexture);
                Screen('Flip',Display.Win);
            end
        end
        
    end
    
end
sca;
