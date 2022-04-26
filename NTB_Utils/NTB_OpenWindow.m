function Params = NTB_OpenWindow(Params)

%================= OPEN NEW PTB WINDOW 
HideCursor;                                                                         % Hide mouse cursor
winPtr = Screen('Windows');                                                         % Find all current PTB window pointers
if ~isfield(Params.Display, 'Win') || isempty(winPtr)                               % If a PTB window is not already open...
    Screen('Preference', 'VisualDebugLevel', Params.Display.PTB.VisualDebugLevel);  % Set debug level
    [Params.Display.Win]    = Screen('OpenWindow', Params.Display.Screen.ID, Params.Display.Screen.BackgroundColor, Params.Display.Screen.XScreenRect,[],[], [], []);
    Screen('BlendFunction', Params.Display.Win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  	% Enable alpha transparency channel
    Screen('ColorRange', Params.Display.Win, 255);                          
end