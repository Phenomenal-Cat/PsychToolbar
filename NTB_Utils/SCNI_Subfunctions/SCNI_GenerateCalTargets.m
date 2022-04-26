function Params = SCNI_GenerateCalTargets(Params)

%====================== SCNI_GenerateCalTargets.m =========================
% Generate screen coordinates for eye-tracker calibration targets.


if ~isfield(Params, 'Eye')
    error('Eye calibration target positions cannot be generated without running SCNI_EyeCalibSettings.m!');
end

Cal.TotalTrials       = Params.Eye.TrialsPerRun*Params.Eye.StimPerTrial;                               	% Total number of trials per run
Cal.RepsPerLoc        = ceil(Cal.TotalTrials/Params.Eye.NoPoints);                                      
Cal.LocationOrder     = randperm(Params.Eye.NoPoints, Params.Eye.NoPoints);  
for r = 1:Cal.RepsPerLoc
    Cal.LocationOrder	= [Cal.LocationOrder, randperm(Params.Eye.NoPoints, Params.Eye.NoPoints)];    	% Generate pseudo-random order of locations
end
Cal.FixmarkerRect     = [0, 0, Params.Eye.MarkerDiam*Params.Display.PixPerDeg];                        	% Size of fixation marker rect (pixels)
Cal.GazeSourceRect    = [0, 0, Params.Eye.FixDist*2*Params.Display.PixPerDeg];                        	% Size of gaze window rect (pixels)

%============= GENERATE TARGET POSITIONS (DEGREES)
if Params.Eye.CalType == 1          %======= Rectangular target grid
    StepSize    = 1/Params.Eye.NoPoint;
  	x           = -1:StepSize:1;
    y           = x;
    [X,Y]       = meshgrid(x,y);
    Cal.FixLocDirections  = [reshape(X,[numel(X),1]), reshape(Y,[numel(Y),1])];
    Cal.FixLocations      = Cal.FixLocDirections*Params.Eye.PointDist;
    
elseif Params.Eye.CalType == 2      %======= Radial taget grid
    Cal.FixLocAngles        = 0:45:315;
    Cal.Radii               = linspace(Params.Eye.PointDist, Params.Eye.PointDist*Params.Eye.NoPoint, Params.Eye.NoPoint);
    Cal.FixLocDirections    = [0,0];
    for r = 1:numel(Cal.Radii)
        Cal.FixLocDirections    = [Cal.FixLocDirections; sind(Cal.FixLocAngles')*Cal.Radii(r), cosd(Cal.FixLocAngles')*Cal.Radii(r)];
    end
    Cal.FixLocations      = Cal.FixLocDirections;
end
Cal.FixLocations      = Cal.FixLocations.*repmat(Params.Display.PixPerDeg,[Params.Eye.NoPoints,1]);          % Scale grid to specified eccentricity (pixels)
Cal.FixLocations      = Cal.FixLocations + repmat(Params.Display.Rect([3,4])/2, [Params.Eye.NoPoints,1]);  	 % Add half a display width and height offsets to center locations
Cal.FixLocationsDeg   = Cal.FixLocDirections*Params.Eye.PointDist; 

   
%============= ADJUST FOR STEREOSCOPIC PRESENTATION
if Params.Display.UseSBS3D == 0                                                                               	% If presenting in 2D...
    Cal.MonkFixLocations = Cal.FixLocations + repmat(Params.Display.Rect([3,1]), [Params.Eye.NoPoints,1]);      % Add an additional display width offset for subject's screen  
elseif Params.Display.UseSBS3D == 1
    Cal.MonkFixLocations{1} = Cal.FixLocations.*[0.5,1] + repmat(Params.Display.Rect([3,1]), [Params.Eye.NoPoints,1]);
    Cal.MonkFixLocations{2} = Cal.FixLocations.*[0.5,1] + repmat(Params.Display.Rect([3,1])*1.5, [Params.Eye.NoPoints,1]);	% Add an additional display width + half offset for subject's screen  
    
    %================ Add horizontal binocular disparities
    if Params.Eye.DispPix ~= 0
       Cal.MonkFixLocations{1}(:,1) = Cal.MonkFixLocations{1}(:,1)+Params.Eye.DispPix;
       Cal.MonkFixLocations{2}(:,1) = Cal.MonkFixLocations{2}(:,1)-Params.Eye.DispPix;
    end
end



%============= CONVERT TARGET POSITIONS TO SCREEN RECTS (PIXELS)
for n = 1:size(Cal.FixLocations,1)                                                                              % For each fixation coordinate...
    Cal.FixRects{n}(1,:) = CenterRectOnPoint(Cal.FixmarkerRect, Cal.FixLocations(n,1), Cal.FixLocations(n,2));  % Generate PTB rect argument
    Cal.GazeRect{n}(1,:) = CenterRectOnPoint(Cal.GazeSourceRect, Cal.FixLocations(n,1), Cal.FixLocations(n,2));	%
    if Params.Display.UseSBS3D == 1  
    	Cal.MonkeyFixRect{n}(1,:)  = CenterRectOnPoint(Cal.FixmarkerRect./[1,1,2,1], Cal.MonkFixLocations{1}(n,1), Cal.MonkFixLocations{1}(n,2)); 	% Center a horizontally squashed fixation rectangle in a half screen rectangle
        Cal.MonkeyFixRect{n}(2,:)  = CenterRectOnPoint(Cal.FixmarkerRect./[1,1,2,1], Cal.MonkFixLocations{2}(n,1), Cal.MonkFixLocations{2}(n,2)); 
    elseif Params.Display.UseSBS3D == 0
        Cal.MonkeyFixRect{n}       = CenterRectOnPoint(Cal.FixmarkerRect, Cal.MonkFixLocations(n,1), Cal.MonkFixLocations(n,2)); 
    end
end

Params.Eye.Target = Cal;