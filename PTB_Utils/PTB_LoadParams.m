function Params = PTB_LoadParams(app, ParamsFile)

%========================= PTB_LoadParams.m ===============================
% Loads PsychToolbar parameters from .mat file. By default, this function
% searches the local /PTB_Params folder for a .mat filename containing the
% local computer's hostname, and returns the 'Params' object.
%==========================================================================

if nargin == 2
    if ~exist(ParamsFile, 'file')
        msg = sprintf('The requested params file ''%s'' was not found on the Matlab path or in the current directory!', ParamsFile);
        uiconfirm(app.NIFToolbarUIFigure, msg, 'Params not found');
    else
        prm     = load(ParamsFile);         % Load params from .mat file
        if class(p) == 'struct'             % If params is a structure...
            Params  = PTB_Params(prm);      % Create instance of PTB_Params object class from struct data
        else
            Params = prm;
        end
        return;
    end
elseif nargin == 0

end

DefaultParams = 'PTB_defaults.mat';


%===== Load default params info for this host
[~, P.CompName]   = system('hostname');
[P.RootDir]       = fileparts(fileparts(mfilename('fullpath')));
if ~exist('play.png','file')
    addpath(genpath(P.RootDir));
end
P.ParamsPrefix    = 'PTB';
P.ParamsFile      = sprintf('%s_%s.mat', P.ParamsPrefix, deblank(P.CompName));
P.ParamsDir       = fullfile(P.RootDir, 'PTB_Params');
P.AllParamsPaths  = wildcardsearch(P.ParamsDir, sprintf('%s_*.mat', P.ParamsPrefix));
if isempty(P.AllParamsPaths)
    msg = sprintf('The default params file for this computer (''%s'') was not found on the matlab path!', P.ParamsFile);
    if exist('app', 'var')
        ans = uiconfirm(app.PsychToolbarUIFigure, sprintf('%s\n%s', msg, q), 'Create new params?','Cancel','OK');
    end
    if strcmp(ans, 'OK')
        [success, msg, id] = copyfile(fullfile(P.ParamsDir, DefaultParams), fullfile(P.ParamsDir, P.ParamsFile));
    end

elseif ~isempty(P.AllParamsPaths)
    for n = 1:numel(P.AllParamsPaths)
        [~,P.AllParamsFiles{n}]   = fileparts(P.AllParamsPaths{n});
        P.AllParamsFiles{n}       = [P.AllParamsFiles{n}, '.mat'];
    end
    P.AllParamsFiles{end+1} = 'Create new';
end

%==== Load default or create new params file
if ~exist(fullfile(P.ParamsDir, P.ParamsFile), 'file')
    msg = sprintf('The default params file for this computer (''%s'') was not found on the matlab path!', P.ParamsFile);
    q = sprintf('Would you like to create a new default parameters file named %s for this computer?', P.ParamsFile);
    if exist('app', 'var')
        ans = uiconfirm(app.PsychToolbarUIFigure, sprintf('%s\n%s', msg, q), 'Create new params?','Cancel','OK');
    else
        ans = 'Cancel';
    end
    if strcmp(ans, 'Cancel')
        return;
    else
        [success, msg, id] = copyfile(fullfile(P.ParamsDir, DefaultParams), fullfile(P.ParamsDir, P.ParamsFile));
    end
end

%==== Load parameters
prm   = load(fullfile(P.ParamsDir, P.ParamsFile));      % Load parameters struct
prm.P = P;                              % Append local params info
if class(prm) == 'struct'               % If params is a structure...
    Params  = PTB_Params(prm);          % Create instance of PTB_Params object class from struct data
else
    Params = prm;
end
