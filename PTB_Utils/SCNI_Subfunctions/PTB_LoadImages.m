function H = SCNI_LoadImages(Params, StimDirs, FileFormat, BckgDirs)

%========================== SCNI_LoadImages.m =============================
% This function loads all images of the specified format from the specified
% directories, and performs any requested editing before loading them into
% PsychToolbox offscreen textures, stored in GPU memory (VRAM). The handles
% of the offscreen textures are returned ready for fast drawing to screen.
%
% 
%==========================================================================


%================ Find all image files in specified directories
if ischar(StimDirs)
    StimDirs = {StimDirs};
end
for nd = 1:numel(StimDirs)                                              % For each directory provided...
    StimFiles{nd} = dir(fullfile(StimDirs{nd},['*', FileFormat]));      % Find all files of specified format in condition directory
    if isempty(StimFiles{nd})                                           
        error('Stimulus directory ''%s'' does not contain any %s images!', StimDirs{nd}, FileFormat);
    end
    if exist('BckgDirs','var')
        BckgFiles{nd} = dir(fullfile(BckgDirs{nd},['*', FileFormat]));      
    end
    StimPerDir(nd) = numel(StimFiles{nd});                              % Count how many images in this directory
end
TotalStim       = sum(StimPerDir);                                     	% Total stimulus tally
LoadingTextPosX = 'center';
LoadingTextPosY = 80;
if Params.Display.Exp.BackgroundColor(1) < 127                          % If background color is dark..
    TextColor = [255 255 255];                                          % Use white text
else                                                                    % Otherwise...
    TextColor = [0 0 0];                                                % Use black text
end
wbh             = waitbar(0, '');                                      	% Open a waitbar figure


%================ Loop through image files
for nd = 1:numel(StimDirs)                                            	% For each stimulus directory...

    if isfield(Params,'window')                                                                 % If a PTB window is open...
        currentbuffer = Screen('SelectStereoDrawBuffer', Params.window, ExperimenterBuffer);  % Select experimenter's display    
        Screen('FillRect', Params.window, Params.Display.Exp.BackgroundColor(1));               % Clear background
        DrawFormattedText(Params.window, sprintf('Loading image %d/%d...', n, TotalStim), LoadingTextPosX, LoadingTextPosY, TextColor);
        Screen('Flip', Params.window, [], 0);                                                	% Draw to experimenter display
    end
    
    for Stim = 1:numel(StimFiles{Cond})                                                        % For each file...

        %============= Update experimenter display
        message = sprintf('Loading image %d of %d (Condition %d/ %d)...\n',Stim,numel(StimFiles{Cond}),Cond,NoCond);
        waitbar(Stim/numel(StimFiles{Cond}), wbh, message);                                     % Update waitbar
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();                                      % Check if escape key is pressed
        if keyIsDown && keyCode(KbName('Escape'))                                             	% If so...
            break;                                                                              % Break out of loop
        end

        %============= Load next file
        img = imread(fullfile(StimDir{Cond}, StimFiles{Cond}(Stim).name));                      % Load image file
        [a,b, imalpha] = imread(fullfile(StimDir{Cond}, StimFiles{Cond}(Stim).name));           % Read alpha channel
        if ~isempty(imalpha)                                                                    % If image file contains transparency data...
            img(:,:,4) = imalpha;                                                               % Combine into a single RGBA image matrix
        else
            img(:,:,4) = ones(size(img,1),size(img,2))*255;
        end
        if [size(img,2), size(img,1)] ~= ImgSize                                                % If X and Y dimensions of image don't match requested...
            img = imresize(img, ImgSize([2,1]));                                                % Resize image
        end
        if Stim_Color == 0                                                                      % If color was set to zero...
            img(:,:,1:3) = repmat(rgb2gray(img(:,:,1:3)),[1,1,3]);                              % Convert RGB(A) image to grayscale
        end

        if ~isempty(imalpha) && Stim_AddBckgrnd == 1 && ~isempty(BckgrndDir{Cond})              % If image contains transparent pixels...         
            Background = imread(fullfile(BckgrndDir{Cond}, BackgroundFiles{Cond}(Stim).name));	% Read in phase scrambled version of stimulus
            Background = imresize(Background, ImgSize);                                         % Resize background image
            if Stim_Color == 0
                Background = repmat(rgb2gray(Background),[1,1,3]);
            end
            Background(:,:,4) = ones(size(Background(:,:,1)))*255;
            BlockBKGs{Cond}(Stim) = Screen('MakeTexture', Params.window, Background);         % Create a PTB offscreen texture for the background
        else
            BlockBKGs{Cond}(Stim) = 0;
        end
        BlockIMGs{Cond}(Stim) = Screen('MakeTexture', Params.window, img);                    % Create a PTB offscreen texture for the stimulus
    end

end

delete(wbh);                                                                                    % Close the waitbar figure window
Screen('FillRect', Params.window, Col_bckgrndRGB);                                            % Clear background
Screen('Flip', Params.window);