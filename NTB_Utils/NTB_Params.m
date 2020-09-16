classdef NTB_Params < handle
    
    properties 
        Display
        DPx
        Eye
        File
        Key
        Reward
    end

    
    methods
        function set.Display(obj,Display)
            obj.Display = Display;
        end
        function set.DPx(obj,DPx)
            obj.DPx = DPx;
        end
        
    end
    
    methods ( Static, Access = public )
        
        function setFields(obj, v)
            obj.Display = v;
        end

        function obj = Struct2Obj(Params)
            if ~isstruct(Params)
                error('Struct2Obj method requires a Params struct input!\n');
            end
            Fieldnames = fieldnames(Params);
            for f = 1:numel(Fieldnames)
                try
                    eval(sprintf('obj.%s = Params.%s;', Fieldnames{f}, Fieldnames{f}));
                catch
                    fprintf('Unable to add field ''%s'' to Params class object!\n', Fieldnames{f});
                end
            end
        end
        
        
    end

end