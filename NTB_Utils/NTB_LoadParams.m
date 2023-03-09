function Params = NTB_LoadParams(app, ParamsFile)

if nargin == 2
    if ~exist(ParamsFile, 'file')
        msg = sprintf('The requested params file ''%s'' was not found on the Matlab path or in the current directory!', ParamsFile);
        uiconfirm(app.NIFToolbarUIFigure, msg, 'Params not found');
    else
        prm     = load(ParamsFile);         % Load params from .mat file
        if class(p) == 'struct'             % If params is a structure...
            Params  = NTB_Params(prm);      % Create instance of NTB_Params object class from struct data
        else
            Params = prm;
        end
        return;
    end
end

%===== Load default params info for this host
[~, P.CompName]   = system('hostname');
[P.RootDir]       = fileparts(fileparts(mfilename('fullpath')));
if ~exist('play.png','file')
    addpath(genpath(P.RootDir));
end
P.ParamsPrefix    = 'NTB';
P.ParamsFile      = sprintf('%s_%s.mat', P.ParamsPrefix, deblank(P.CompName));
P.ParamsDir       = fullfile(P.RootDir, 'NTB_Params');
P.AllParamsPaths  = wildcardsearch(P.ParamsDir, sprintf('%s_*.mat', P.ParamsPrefix));
for n = 1:numel(P.AllParamsPaths)
    [~,P.AllParamsFiles{n}]   = fileparts(P.AllParamsPaths{n});
    P.AllParamsFiles{n}       = [P.AllParamsFiles{n}, '.mat'];
end
P.AllParamsFiles{end+1} = 'Create new';

%==== Load default or create new params file
if ~exist(P.ParamsFile, 'file')
    msg = sprintf('The default params file for this computer (''%s'') was not found on the matlab path!', P.ParamsFile);
    q = sprintf('Would you like to create a new default parameters file named %s for this computer?', P.ParamsFile);
    ans = uiconfirm(app.NIFToolbarUIFigure, sprintf('%s\n%s', msg, q), 'Create new params?','Cancel','OK');
else
    prm   = load(P.ParamsFile);             % Load parameters struct
    prm.P = P;                              % Append local params info
    if class(prm) == 'struct'               % If params is a structure...
        Params  = NTB_Params(prm);          % Create instance of NTB_Params object class from struct data
    else
        Params = prm;
    end
end