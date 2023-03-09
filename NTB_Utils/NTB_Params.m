classdef NTB_Params < handle
    
    % https://www.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html
    % https://www.mathworks.com/matlabcentral/answers/441430-how-to-return-values-from-mlapp-to-the-m-caller
    
    properties 
        Block
        Design
        Display
        DPx
        Eye
        Exp
        File
        Grid
        Image
        Key
        Lever
        Movie
        NI
        Reward
        TDT
        P
    end

    methods ( Static, Access = public )

        %======= Constructor
        function np = NTB_Params(Params)
            if nargin > 0
                if ~isstruct(Params)
                    error('Input to NTB_Params method must be a struct!\n');
                end
                Fieldnames = fieldnames(Params);
                for f = 1:numel(Fieldnames)
                    try
                        eval(sprintf('np.%s = Params.%s;', Fieldnames{f}, Fieldnames{f}));
                    catch
                        fprintf('Unable to add field ''%s'' to Params class object!\n', Fieldnames{f});
                    end
                end
            end

        end
            
        
    end

end