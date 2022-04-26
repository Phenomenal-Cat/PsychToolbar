function FixTexture = NTB_GenerateFixMarker(Fix, Params)

%======================= SCNI_GenerateFixMarker ===========================
% Draw a fixation marker with the features specified by input struct Fix 
% to a PTB texture and return the texture handle.
%     ____    ___ __  _______
%    /    |  /  //  //  ____/    Neurophysiology Imaging Facility Core
%   /  /| | /  //  //  /___      Building 49 Convent Drive
%  /  / | |/  //  //  ____/      NATIONAL INSTITUTES OF HEALTH
% /__/  |____//__//__/          
%==========================================================================

if ~isfield(Params.Display, 'Win')
    error('No PTB window handle was found in ''Params'' input!');
end
if ~exist('Fix','var') || isempty(Fix)
    Fix.MarkerSize  = 1;
    Fix.Color       = [0,1,0];
    Fix.Type        = 1;
    Fix.LineWidth   = 2;
end

FixSize   	= round(Fix.MarkerSize*Params.Display.Basic.PixPerDeg); % Convert fixation marker diameter from degrees to pixels
FixIm      	= zeros(FixSize(1)+2, FixSize(2)+2, 4);                 % Create an M x N x 4 matrix
FixTexture	= Screen('MakeTexture', Params.Display.Win, FixIm); 	% Create a PTB texture from the blank matrix
FixRect    	= [0,0,FixSize];                                        

switch Fix.Type
    case 1                                                          %============== FILLED CIRCLE
        Screen('FillOval', FixTexture, Fix.Color*255, [0,0,FixSize-[2,0]]);
    case 2                                                          %============== CROSS
        FixPos = [FixSize(1)/2, -FixSize(2)/2, 0, 0; 0, 0, FixSize(1)/2, -FixSize(2)/2];            % Specify line positions
        %Screen('FillOval', FixTexture, Params.Display.Exp.BackgroundColor*255, [0,0,FixSize]);   	% Draw filled circle same color as background
        Screen('DrawLines', FixTexture, FixPos, Fix.LineWidth, Fix.Color*255, FixSize/2);           % Draw cross in center
    case 3                                                          %============== SOLID SQUARE
        Screen('FillRect', FixTexture, Fix.Color*255, [0,0,FixSize]);
    case 4                                                          %============== BINOCULAR CROSSHAIRS
        FixPos = [FixSize(1)/2, FixSize(2)/4, 0, 0; 0, 0, FixSize(1)/2, FixSize(2)/4];
        Screen('DrawLines', FixTexture, FixPos, Fix.LineWidth, Fix.Color, FixSize/2);
        Screen('FrameRect', FixTexture, Fix.Color*255, CenterRect([0 0 FixSize]/2, FixRect), Fix.LineWidth);
end