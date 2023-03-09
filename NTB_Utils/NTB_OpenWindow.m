function Params = NTB_OpenWindow(Params)

if ismac
    fprintf('This code is running on an Apple Mac, which is not supported hardware for timing critical vision experiments. PTB sync tests will be truned off!\n');
    Screen('Preference', 'SkipSyncTests', 1);
end

%================= OPEN NEW PTB WINDOW 
HideCursor;                                                                         % Hide mouse cursor
winPtr = Screen('Windows');                                                         % Find all current PTB window pointers
if ~isfield(Params.Display, 'Win') || isempty(winPtr)                               % If a PTB window is not already open...
    Screen('Preference', 'VisualDebugLevel', Params.Display.PTB.VisualDebugLevel);  % Set debug level
    if Params.Display.Dome.On == 1                      %% <<<<<< FIX FOR DOME DISPLYAS!
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', Params.Display.Dome.CalibFile);
        Params.Display.Win = PsychImaging('OpenWindow', Params.Display.Screen.ID, Params.Display.Screen.BackgroundColor, Params.Display.Screen.XScreenRect);
    else
        [Params.Display.Win] = Screen('OpenWindow', Params.Display.Screen.ID, Params.Display.Screen.BackgroundColor, Params.Display.Screen.XScreenRect,[],[], [], []);
    end
    Screen('BlendFunction', Params.Display.Win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  	% Enable alpha transparency channel
    Screen('ColorRange', Params.Display.Win, 255);                          
end