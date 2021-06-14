function Params = NTB_ScreenRects(Params)

%======================== NTB_ScreenRects.m ===============================
% This function calculates the on-screen rectangle coodinates (PsychToolbox 
% 'rects') for drawing stimuli based on the selected display parameters.
% Specifically it deals with the issues of multiple displays mapped as a single
% 'X-screen' and side-by-side stereoscopic 3D content.

%% 
if Params.Movie.Fullscreen == 1
    
    ScreenAR    = Params.Display.Rect(3)/Params.Display.Rect(4);
    MovieAR     = Movie.width/Movie.height;
    if ScreenAR == MovieAR
        Params.Movie.RectExp    = Params.Display.Rect;
    elseif ScreenAR < MovieAR
        YOffset              	= abs((Params.Display.Rect(4)- Params.Display.Rect(3)/MovieAR)/2);
        Params.Movie.RectExp    = [Params.Display.Rect(1), YOffset, Params.Display.Rect(3), Params.Display.Rect(4)-YOffset];
    elseif ScreenAR > MovieAR
        XOffset              	= abs((Params.Display.Rect(3)- Params.Display.Rect(4)/MovieAR)/2);
        Params.Movie.RectExp    = [XOffset, Params.Display.Rect(2), Params.Display.Rect(3)-XOffset, Params.Display.Rect(4)];
    end
    Params.Movie.RectMonk   = Params.Movie.RectExp + [Params.Display.Rect(3), 0, Params.Display.Rect(3), 0];
    Params.Movie.GazeRect  	= Params.Movie.RectExp;
    
elseif Params.Movie.Fullscreen == 0
    MovieWidthPix           = Params.Movie.SizeDeg*Params.Display.PixPerDeg(2);
    MovieHeightPix          = (Movie.height/Movie.width)*MovieWidthPix;
    Params.Movie.RectExp    = CenterRect([1, 1, MovieWidthPix, MovieHeightPix], Params.Display.Rect); 
    Params.Movie.RectMonk   = Params.Movie.RectExp + [Params.Display.Rect(3), 0, Params.Display.Rect(3), 0];
    Params.Movie.GazeRect 	= Params.Movie.RectExp + [-1,-1, 1, 1]*Params.Movie.GazeRectBorder*Params.Display.PixPerDeg(1);  	% Rectangle specifying gaze window on experimenter's display (overridden if fullscreen is selected)
end

if Params.Movie.FixOn == 1
    Params.Movie.GazeRect 	= CenterRect([1,1,2*Params.Movie.GazeRectBorder.*Params.Display.PixPerDeg], Params.Display.Rect); 
end

%% Side-by-side Stereoscopic Content
if Params.Movie.SBS == 1                    % If frames are rendered as SBS stereo 3D...
    if Params.Display.UseSBS3D == 1         % If presentation in SBS3D was requested...
        NoEyes                          = 2;
        Params.Movie.SourceRect{1}      = [1, 1, Movie.width/2, Movie.height];
        Params.Movie.SourceRect{2}      = [(Movie.width/2)+1, 1, Movie.width, Movie.height];
        Params.Movie.SourceRectMonk     = [];
        Params.Display.FixRectExp      	= CenterRect([1, 1, Fix.Size], Params.Display.Rect);
        Params.Display.FixRectMonk(1,:)	= CenterRect([1, 1, Fix.Size./[2,1]], Params.Display.Rect./[1,1,2,1]) + [Params.Display.Rect(3),0,Params.Display.Rect(3),0]; 
        Params.Display.FixRectMonk(2,:)	= Params.Display.FixRectMonk(1,:) + Params.Display.Rect([3,1,3,1]).*[0.5,0,0.5,0];
    
    elseif Params.Display.UseSBS3D == 0     	% If presentation in 2B was requested...
        NoEyes                          = 1;
        Params.Movie.SourceRect{1}      = [1, 1, Movie.width/2, Movie.height];
        Params.Movie.SourceRectMonk     = Params.Movie.SourceRect{1};
        Params.Display.FixRectExp      	= CenterRect([1, 1, Fix.Size], Params.Display.Rect);
        Params.Display.FixRectMonk(1,:)	= CenterRect([1, 1, Fix.Size], Params.Display.Rect + [Params.Display.Rect(3), 0, Params.Display.Rect(3), 0]); 
        Params.Display.FixRectMonk(2,:)	= Params.Display.FixRectMonk(1,:);
    end
    
elseif Params.Movie.SBS == 0
    NoEyes                          = 1;
    Params.Movie.SourceRect{1}    	= [1, 1, Movie.width, Movie.height];
    Params.Movie.SourceRectMonk     = [];
 	Params.Display.FixRectExp      	= CenterRect([1, 1, Fix.Size], Params.Display.Rect);
    Params.Display.FixRectMonk(1,:)	= CenterRect([1, 1, Fix.Size], Params.Display.Rect + [Params.Display.Rect(3), 0, Params.Display.Rect(3), 0]); 
    Params.Display.FixRectMonk(2,:)	= Params.Display.FixRectMonk(1,:);
end
Params.Eye.GazeRect = Params.Movie.GazeRect;
