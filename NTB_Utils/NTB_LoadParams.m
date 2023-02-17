function Params = NTB_LoadParams(ParamsFile)

if nargin == 1
    if ~exist(ParamsFile, 'file')
        msg = sprintf('The requested params file ''%s'' was not found on the Matlab path or in the current directory!', ParamsFile);
    else
        p       = load(ParamsFile);         % Load params from .mat file
        if class(p) == 'struct'             % If params is a structure...
            Params  = NTB_Params(p);        % Create instance of NTB_Params object class from struct data
        else
            Params = p;
        end
        return;
    end
end

%===== Load default params file for this host
[~, CompName]   = system('hostname');
[RootDir]       = fileparts(fileparts(mfilename('fullpath')));
if ~exist('play.png','file')
    addpath(genpath(RootDir));
end
ParamsPrefix    = 'NTB';
ParamsFile      = sprintf('%s_%s.mat', ParamsPrefix, deblank(CompName));
if ~exist(ParamsFile, 'file')
    msg = sprintf('The default params file for this computer (''%s'') was not found on the matlab path!', ParamsFile);
    q = sprintf('Would you like to create a new default parameters file named %s for this computer?', ParamsFile);
    questdlg(q)
else
    p   = load(ParamsFile);             % Load parameters struct
    if class(p) == 'struct'             % If params is a structure...
        Params  = NTB_Params(p);        % Create instance of NTB_Params object class from struct data
    else
        Params = p;
    end
end



