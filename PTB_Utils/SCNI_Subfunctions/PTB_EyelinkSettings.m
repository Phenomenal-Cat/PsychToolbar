%=========================== SCNI_EyelinkSettings.m ===========================
% This function provides a graphical user interface for setting parameters 
% related to the digital and analog I/O channels of DataPixx2. Parameters 
% can be saved and loaded, and the updated parameters are returned in the 
% structure 'Params'.
%
% INPUTS:
%   DefaultInputs: 	optional string containing full path of .mat
%                 	file containing previously saved parameters.
% OUTPUT:
%   Params.DPx.:    Structure containing channel assignments for all 
%                   DataPixx2 channels    
%
%==========================================================================

function ParamsOut = SCNI_EyelinkSettings(ParamsFile)

persistent Params Fig;

%============ Initialize GUI
GUItag      = 'SCNI_EyelinkSettings';           % String to use as GUI window tag
Fieldname   = 'EL';                             % Params structure fieldname for DataPixx info
if ~exist('OpenGUI','var')
    OpenGUI = 1;
end
if ~exist('ParamsFile','var')
    ParamsFile = [];
end
[Params, Success]  = SCNI_InitGUI(GUItag, Fieldname, ParamsFile, OpenGUI);


if Success < 1
    Params.EL.active_eye                    = 'BOTH';                          	% set eye(s) to record
    Params.EL.binocular_enabled             = 'YES';                         	% enable binocular tracking
    Params.EL.head_subsample_rate           = '0';                           	% normal (no anti-reflection)
    Params.EL.heuristic_filter              = 'ON';                             % ON for filter (normal)	
    Params.EL.pupil_size_diameter           = 'NO';                             % no to diameter (= yes for pupil area)
    Params.EL.simulate_head_camera          = 'NO';                             % NO to use head camera
    Params.EL.calibration_type              = 'HV9';                            % Use a 9 point calibration
    Params.EL.enable_automatic_calibration  = 'YES';                            % YES (default)
    Params.EL.automatic_calibration_pacing  = '1000';                           % 1000ms (default)
    Params.EL.recording_parse_type          = 'GAZE';                      
    Params.EL.saccade_velocity_threshold    = '35';                             % set parser (conservative saccade thresholds)
    Params.EL.saccade_acceleration_threshold = '9500'; 
    Params.EL.saccade_motion_threshold      = '0.0';                                           
    Params.EL.saccade_pursuit_fixup         = '60';                                               
    Params.EL.fixation_update_interval      = '0';                                             
    Params.EL.file_event_filter             = 'LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON';     % set EDF file contents
    Params.EL.link_event_filter             = 'LEFT,RIGHT,FIXATION,BUTTON';                           % set link data (used for gaze cursor)
    Params.EL.link_sample_data              = 'LEFT,RIGHT,GAZE,AREA';          
    Params.EL.Host_IP                       = '159.40.249.29';                  % IP address of EyeLink II host PC
    Params.EL.Host_Port                     = '';
    Params.EL.Host                          = '';
    Params.EL.AnalogVoltRange               = [-5, 5];                          
    
elseif Success > 1
    return;
end


%========================= OPEN GUI WINDOW ================================
Fig.Handle          = figure;                                           % Assign GUI arbitrary integer      
setappdata(0,GUItag,Fig.Handle);
Fig.FontSize        = 12;
Fig.TitleFontSize   = 16;
Fig.Rect            = [0 200 600 860];                               	% Specify figure window rectangle
Fig.PannelSize      = [300, 650];                                       
Fig.PannelElWidths  = [30, 120];
set(Fig.Handle,     'Name','SCNI: Eyelink settings',...              	% Open a figure window with specified title
                    'Tag','SCNI_EyelinkSettings',...                 	% Set figure tag
                    'Renderer','OpenGL',...                             % Use OpenGL renderer
                    'OuterPosition', Fig.Rect,...                       % position figure window
                    'NumberTitle','off',...                             % Remove figure number from title
                    'Resize', 'off',...                                 % Prevent resizing of GUI window
                    'Menu','none',...                                   % Turn off memu
                    'Toolbar','none');                                  % Turn off toolbars to save space
Fig.Background  = get(Fig.Handle, 'Color');                           	% Get default figure background color
Fig.Margin      = 20;                                                 	% Set margin between UI panels (pixels)                                 
Fig.Fields      = fieldnames(Params);                                 	% Get parameter field names



%============= CREATE MAIN PANEL
Fig.TopPanelHandle = uipanel('BackgroundColor',Fig.Background,...
                    'Units','pixels',...
                    'Position',[20, Fig.Rect(4)-150, Fig.Rect(3)-40, 120],...
                    'Parent',Fig.Handle); 
Fig.Logo        = imread('Logo_EyeLink.png');
Fig.LogoAx    	= axes('box','off','units','pixels','position', [10, 10, 100, 100],'color',Fig.Background, 'Parent', Fig.TopPanelHandle);
image(Fig.Logo);
axis off;
if ~exist('Eyelink.m', 'file')
    Params.EL.ToolboxFound  = 0;
    Params.EL.Initialized   = 0;
else
    Params.EL.ToolboxFound = 1;
    try
        Params.EL.Initialized   = Eyelink('Initialize');  
        [version, versionString]= Eyelink('GetTrackerVersion');
        Params.EL.Tracker       = versionString;
    catch
        Params.EL.Initialized   = 0;
        Params.EL.Tracker       = [];
    end
    if Params.EL.Initialized < 0
        Params.EL.Initialized = 0;
    end
end
    
%     eval(sprintf('Eyelink(''command'', ''%s = %s'');', Fieldname{f}, eval(sprintf('Params.EL.%s', Fieldname{f}))));
%     Eyelink('Message', 'DISPLAY_COORDS %d %d %d %d',Display.Rect(1),Display.Rect(2),Display.Rect(3),Display.Rect(4));   
%     Eyelink('message', 'SCNI_EyeLinkSettings.m');        	% Send message to EyeLink that setup has started


Fig.MainStrings     = {'EyeLink toolbox?','EyeLink initialized?','Host IP address','Host port','Initialize'};
Fig.MainResults     = {Params.EL.ToolboxFound, Params.EL.Initialized, Params.EL.Host_IP, Params.EL.Host_Port, []};
Fig.MainStyles      = {'','','edit','edit','pushbutton'};
Fig.DetectionColors = [1,0,0; 0,1,0];
Ypos = 90;
for n = 1:numel(Fig.MainStrings)
    if n < 3
        Fig.Mh(n) = uicontrol('Style', 'checkbox','String',Fig.MainStrings{n},'value',Fig.MainResults{n},'enable','off','Position', [140,Ypos, 120,20],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left');
        Fig.Mdh(n) = uicontrol('Style', 'text','String','','Position', [260,Ypos+2, 18,18],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left','backgroundcolor', Fig.DetectionColors(Fig.MainResults{n}+1,:));
    elseif ismember(n, [3,4])
      	Fig.Mh(n) = uicontrol('Style', 'text','String',Fig.MainStrings{n},'Position', [140,Ypos, 120,20],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left');
        Fig.Mdh(n) = uicontrol('Style', 'edit','String',Fig.MainResults{n},'Position', [260,Ypos+2, 120,18],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left');
    elseif n == 5
        Fig.Mdh(n) = uicontrol('Style', Fig.MainStyles{n},'String',Fig.MainStrings{n},'Position', [140,Ypos+2, 120,18],'Parent',Fig.TopPanelHandle,'HorizontalAlignment', 'left','callback',{@Initialize});
    end
    Ypos = Ypos-20;
end

%======== Set group controls positions
Fig.UnusedChanCol           = [0.5,0.5,0.5];
Fig.UsedChanCol             = [0, 1, 0];
Fig.PannelNames             = {'Host PC','Settings','Events'};
Fig.HostFields              = {'IP address','Port number'};
Fig.EventFields             = {};

%============= CREATE PANELS
for p = 1:numel(Fig.PannelNames)
    if p == 1
        BoxXpos(p) 	= Fig.Margin + (Fig.PannelSize(1)+Fig.Margin)*(p-1);
        BoxYpos(p)  = Fig.Rect(4)-450-160;
        PannelSize  = [Fig.PannelSize(1), 450];
    elseif p == 2
        BoxXpos(p) 	= BoxXpos(1);
        BoxYpos(p)  = BoxYpos(1)-180-20;
        PannelSize  = [Fig.PannelSize(1), 180];
    else
      	BoxXpos(p) 	= Fig.Margin + (Fig.PannelSize(1)+Fig.Margin)*(p-2);
        BoxYpos(p)  = Fig.Rect(4)-Fig.PannelSize(2)-120;
        PannelSize  = Fig.PannelSize;
    end
    PannelPos{p}    = [BoxXpos(p), BoxYpos(p), PannelSize]; 
    
    Fig.PanelHandle(p) = uipanel( 'Title',Fig.PannelNames{p},...
                    'FontSize',Fig.TitleFontSize,...
                    'BackgroundColor',Fig.Background,...
                    'Units','pixels',...
                    'Position',PannelPos{p},...
                    'Parent',Fig.Handle); 
    
    Ypos         	= PannelPos{p}(4)-Fig.Margin*2.5;
    ChannelList     = eval(Fig.AllPannelChannels{p});               % Get channel numbers for this pannel
    ChannelNames    = eval(Fig.AllPannelChannelnames{p});           % Get I/O names that can be assigned to this pannel
    ChannelAssign   = eval(Fig.AllPannelChannelAssign{p});          % Get channel assignments
    if numel(ChannelAssign) < numel(ChannelList)
        NoneIndx = find(~cellfun(@isempty, strfind(ChannelNames, 'None')));
        ChannelAssign(end+1:numel(ChannelList)) = NoneIndx;
    end
    
    %============= CREATE FIELDS
    for n = 1:numel(ChannelList)
        Fig.ChH(p,n) = uicontrol('Style', 'text','String',ChannelList{n},'Position', [Fig.Margin,Ypos,Fig.PannelElWidths(1),20],'Parent',Fig.PanelHandle(p),'HorizontalAlignment', 'left');
        Fig.h(p,n) = uicontrol('Style', 'popup','String',ChannelNames,'value', ChannelAssign(n), 'Position', [Fig.PannelElWidths(1)+10,Ypos,Fig.PannelElWidths(2),20],'Parent',Fig.PanelHandle(p),'HorizontalAlignment', 'left','Callback',{@ChannelUpdate,p,n});
        if strfind(ChannelNames{ChannelAssign(n)}, 'None')
            set(Fig.ChH(p,n), 'BackgroundColor', Fig.UnusedChanCol);
        else
            set(Fig.ChH(p,n), 'BackgroundColor', Fig.UsedChanCol);
        end
        Ypos = Ypos-25;
    end
%     set(h(1:numel(SystemLabels)), 'BackgroundColor', Fig.Background);

end




%================= OPTIONS PANEL
uicontrol(  'Style', 'pushbutton',...
            'String','Load',...
            'parent', Fig.Handle,...
            'tag','Load',...
            'units','pixels',...
            'Position', [Fig.Margin,20,100,30],...
            'TooltipString', 'Use current inputs',...
            'FontSize', Fig.FontSize, ...
            'HorizontalAlignment', 'left',...
            'Callback', {@OptionSelect, 1});   
uicontrol(  'Style', 'pushbutton',...
            'String','Save',...
            'parent', Fig.Handle,...
            'tag','Save',...
            'units','pixels',...
            'Position', [140,20,100,30],...
            'TooltipString', 'Save current inputs to file',...
            'FontSize', Fig.FontSize, ...
            'HorizontalAlignment', 'left',...
            'Callback', {@OptionSelect, 2});    
uicontrol(  'Style', 'pushbutton',...
            'String','Continue',...
            'parent', Fig.Handle,...
            'tag','Continue',...
            'units','pixels',...
            'Position', [260,20,100,30],...
            'TooltipString', 'Exit',...
            'FontSize', Fig.FontSize, ...
            'HorizontalAlignment', 'left',...
            'Callback', {@OptionSelect, 3});         

hs = guihandles(Fig.Handle);                                % get UI handles
guidata(Fig.Handle, hs);                                    % store handles
set(Fig.Handle, 'HandleVisibility', 'callback');            % protect from command line
drawnow;
% uiwait(Fig.Handle);
ParamsOut = Params;




%% ========================= UICALLBACK FUNCTIONS =========================
    function ChannelUpdate(hObj, Evnt, Indx1, Indx2)
 
        %========== Update channel color code
        Selection = get(hObj, 'value');
        Channelnames = eval(Fig.AllPannelChannelnames{Indx1});
        if strcmp(Channelnames{Selection},'None')
            set(Fig.ChH(Indx1, Indx2), 'BackgroundColor', Fig.UnusedChanCol);
        else
            set(Fig.ChH(Indx1, Indx2), 'BackgroundColor', Fig.UsedChanCol);
        end
        
        %========== Update params
        switch Indx1 
            case 1  %========= ANALOG IN
                Params.DPx.AnalogInAssign(Indx2) = Selection;
                
            case 2  %========= ANALOG OUT
                Params.DPx.AnalogOutAssign(Indx2) = Selection;
                
            case 3  %========= DIGITAL IN
                Params.DPx.DigitalInAssign(Indx2) = Selection;
                
            case 4  %========= DIGITAL OUT
                Params.DPx.DigitalOutAssign(Indx2) = Selection;
                
        end
       
    end

    %==================== SHUT DOWN EYELINK
    function Cleanup
        Eyelink('Stoprecording');       % stop recording eye-movements
        Eyelink('CloseFile');           % close data file
        WaitSecs(1.0);                  % give tracker time to execute commands
        Eyelink('Shutdown');            % shut down tracker
    end

    %========= Test EyeLink recording
    function Success = TestEyelinkRecord()
        Success = 0;
        Eyelink('StartRecording');                              % Start EyeLink recording for test trial
        WaitSecs(1);
        if Eyelink('CheckRecording') ~=0                        % Check that EyeLink is recording
            Eyelink('CheckRecording')
            error('Problem with Eyelink!');
        end
        Eyelink('Stoprecording');                               % stop recording eye-movements
    end

    %==================== DISPLAY EYE VIDEO IN PTB WINDOW
    function DisplayEye(win)
        if nargin == 0
            win = Screen('OpenWindow', max(Screen('Screens')), [255 255 0], [0 0 800 600]);       % Open a new window for eye image display
        end
        el = EyelinkInitDefaults(win);                    	% Initialize 'el' eyelink struct with proper defaults for output to window 'w'
        DisplayVideo = 1;
        Result = EyelinkInit([], DisplayVideo);            	% Initialize Eyelink connection with callback function and eye camera image display   
        if ~Result
            fprintf('Eyelink Init aborted.\n');
            cleanup;
            return;
        end
        Result = Eyelink('StartSetup',DisplayVideo);        % Perform tracker setup: The flag 1 requests interactive setup with video display 

    end

    %==================== INITIALIZE CONNECTION TO EYELINK
    function Initialize(Obj, Event, Indx)
        Initialized   = Eyelink('Initialize');  
        if Initialized < 1
            Params.EL.Initialized = 0;
        else
            Params.EL.Initialized = 1;
        end
        set(Fig.Mh(2),'value',Params.EL.Initialized);
        set(Fig.Mdh(2),'backgroundcolor', Fig.DetectionColors(Params.EL.Initialized+1,:));
    end

    %==================== OPTIONS
    function OptionSelect(Obj, Event, Indx)

        switch Indx
            case 1      %================ LOAD PARAMETERS FILE
                [Filename, Pathname, Indx] = uigetfile('*.mat','Load parameters file', Params.Dir);
                Params.File = fullfile(Pathname, Filename);
                SCNI_EyelinkSettings(Params.File);

            case 2      %================ SAVE PARAMETERS TO FILE
                if exist(Params.File,'file')
                    ButtonName = questdlg(sprintf('A parameters file named ''%s'' already exists. Would you like to overwrite that file?', Params.File), ...
                         'File already exists!', ...
                         'Overwrite', 'Rename', 'Cancel', 'Overwrite');
                     if strcmp(ButtonName,'Cancel')
                         return;
                     end
                end
                [Filename, Pathname, Indx] = uiputfile('*.mat','Save parameters file', Params.File);
                if Filename == 0
                    return;
                end
                Params.File = fullfile(Pathname, Filename);
                DPx = Params.DPx;
                save(Params.File, 'DPx', '-append');
                msgbox(sprintf('Parameters file saved to ''%s''!', Params.File),'Saved');

            case 3      %================ CLOSE PARAMETERS GUI
                ParamsOut = [];         % Clear params
                close(Fig.Handle);      % Close GUI figure
                return;
        end
    end

end