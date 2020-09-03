function [C] = NTB_Params2csv(ParamsFile)

OutputDir = fileparts(mfilename('fullpath'));
if nargin == 0
    ParamsFile = 'NTB_MH02183714MACLT.mat';
end
if ~exist(ParamsFile, 'file')
    [file, path] = uigetfile('Select params file');
    ParamsFile = fullfile(path, file);
end
[~,file] = fileparts(ParamsFile);
Params = load(ParamsFile);
Fields = fieldnames(Params);
for f1 = 1:numel(Fields)
    if ~strcmp(class(eval(sprintf('Params.%s', Fields{f1}))), 'struct')
       break; 
    end
  	Subfields = fieldnames(eval(sprintf('Params.%s', Fields{f1})));
    C = {};
   	RowCount = 1;
    for f2 = 1:numel(Subfields)
        Subsubfields = fieldnames(eval(sprintf('Params.%s.%s', Fields{f1}, Subfields{f2})));
        for f3 = 1:numel(Subsubfields)
            if f3 == 1
                C{RowCount, 1} = sprintf('%s', Subfields{f2});
            end
            C{RowCount, 2} = sprintf('Params.%s.%s.%s', Fields{f1}, Subfields{f2}, Subsubfields{f3});
            RowCount = RowCount+1;
        end
    end
    
    writecell(C, fullfile(OutputDir, sprintf('%s.csv', Fields{f1})));
end

