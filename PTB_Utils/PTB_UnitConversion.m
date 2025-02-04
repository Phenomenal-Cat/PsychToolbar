function Out = NTB_UnitConversion(input, unitin, Display)

%======================= NTB_UnitConversion.m =============================
% Convert between units used to specify on-screen size. Conversion requires
% the correct information about the display and viewing geometry contained
% in the NTB 'Display' structure that must be provided. The output is a
% structure with fields for each unit type.
%==========================================================================

%===== Check inputs
AcceptedUnits  = {'Pixels','DVA','Cm','Inches'};
if ~ischar(unitin)
    error('Input ''unit'' must be a string (class of input received was %s).\n', class(unitin));
end
if ~any(strcmpi(AcceptedUnits, unitin))
    error('Input ''unitin'' was not recognized as an accepted unit. Please use one of the following: %s\n', AcceptedUnits{:});
end
if ~isstruct(Display)
    error('Input ''Display'' must be NTB structure containing display setting fields!');
end

%===== Convert units

switch unitin
    case 'Pixels'
        Out.Pixels = input;
        if numel(input) == 2
            Out.DVA     = Out.Pixels./Display.Basic.PixPerDeg;
            Out.Cm      = Out.Pixels./Display.Basic.PixPerCm;
        else
            Out.DVA     = Out.Pixels/mean(Display.Basic.PixPerDeg);
            Out.Cm      = Out.Pixels/mean(Display.Basic.PixPerCm);
        end
        Out.Inches = Out.Cm/2.45;

    case 'DVA'
        Out.DVA = input;
        if numel(input) == 2
            Out.Pixels  = Out.DVA.*Display.Basic.PixPerDeg;
            Out.Cm      = Out.Pixels./Display.Basic.PixPerCm;
        else
            Out.Pixels  = Out.DVA*mean(Display.Basic.PixPerDeg);
            Out.Cm      = Out.Pixels/mean(Display.Basic.PixPerCm);
        end
        Out.Inches = Out.Cm/2.45;
        
    case 'Cm'
        Out.Cm  = input;
        if numel(input) == 2
            Out.Pixels  = Out.Cm.*Display.Basic.PixPerCm;
            Out.DVA     = Out.Pixels./Display.Basic.PixPerDeg;
        else
            Out.Pixels  = Out.Cm*mean(Display.Basic.PixPerCm);
            Out.DVA     = Out.Pixels/mean(Display.Basic.PixPerDeg);
        end
        Out.Inches = Out.Cm/2.45;
        
    case 'Inches'
        Out.Inches  = input;
        Out.Cm      = Out.Inches*2.45;
        if numel(input) == 2
            Out.Pixels  = Out.Cm.*Display.Basic.PixPerCm;
            Out.DVA     = Out.Pixels./Display.Basic.PixPerDeg;
        else
            Out.Pixels  = Out.Cm*mean(Display.Basic.PixPerCm);
            Out.DVA     = Out.Pixels/mean(Display.Basic.PixPerDeg);
        end
end
