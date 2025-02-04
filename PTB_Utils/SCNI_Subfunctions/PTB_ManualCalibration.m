function Cal = SCNI_ManualCalibration(Cal)



global Fig

if ~isfield(Cal, 'Window') || Cal.Window == 0
    Fig.Background  = [0.9,0.9,0.9];
    Fig.Fontsize    = 16;
    Fig.ScaleFactor = 2;
    Fig.ChangeInc   = 0.05;                             
    Fig.GazeWinPos  = [1, 1, 350, 150]*Fig.ScaleFactor;
    Fig.Handle      = figure(   'name','SCNI_ManualCalibration',...
                                'position',Fig.GazeWinPos,...
                                'menu','none',...
                                'color',Fig.Background);
    Fig.Labels      = {'Offset (V)','Gain (deg/V)', 'Range (V)'};
    Fig.Buttons     = {'Load','Save','Close'};
    Fig.ArrowColor  = [0.7,0.9,1];
    Fig.Values      = {Cal.EyeOffset, Cal.EyeGain, Cal.VoltageRange}; 
    Ypos            = 250:(-25*Fig.ScaleFactor):0;
    Xpos            = (120*Fig.ScaleFactor):(100*Fig.ScaleFactor):800;
    ButtonSize      = [20,20]*Fig.ScaleFactor;
    uicontrol('Style', 'text','String', 'X', 'Position', [Xpos(1), Ypos(1), 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.Handle,'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
    uicontrol('Style', 'text','String', 'Y', 'Position', [Xpos(2), Ypos(1), 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.Handle,'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
    for n = 1:numel(Fig.Labels)
        uicontrol('Style', 'text','String', Fig.Labels{n},'Position', [20, Ypos(n+1), 100*Fig.ScaleFactor, 20*Fig.ScaleFactor],'Parent',Fig.Handle, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
        for xy = 1:2
            Fig.Edit(n, xy)     = uicontrol('Style', 'Edit','String', sprintf('%.2f', Fig.Values{n}(xy)), 'Position', [Xpos(xy),Ypos(n+1),50*Fig.ScaleFactor,ButtonSize(2)],'Parent', Fig.Handle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibUpdate,1,n,xy});
            Fig.Arrow(n, xy, 1) = uicontrol('Style', 'PushButton', 'String', '<','Position', [Xpos(xy)+50*Fig.ScaleFactor,Ypos(n+1),ButtonSize],'Parent',Fig.Handle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibUpdate,2,n,xy}, 'backgroundcolor', Fig.ArrowColor);
            Fig.Arrow(n, xy, 2) = uicontrol('Style', 'PushButton', 'String', '>','Position', [Xpos(xy)+70*Fig.ScaleFactor,Ypos(n+1),ButtonSize],'Parent',Fig.Handle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibUpdate,3,n,xy}, 'backgroundcolor', Fig.ArrowColor);
        end
    end
    Cal.Window = 1;
    for b = 1:numel(Fig.Buttons)
         uicontrol('Style', 'pushbutton', 'String', Fig.Buttons{b}, 'Position', [20+(b-1)*120, 20, 100, 25],'Parent',Fig.Handle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibOutput, b});
    end
    
else

    %================ Get current GUI values
	for n = 1:size(Fig.Edit, 1)
        for xy = 1:size(Fig.Edit, 2)
            Fig.Values{n}(xy) = str2num(get(Fig.Edit(n, xy), 'string'));
        end
    end
    Cal.EyeOffset       = Fig.Values{1};
    Cal.EyeGain         = Fig.Values{2};
    Cal.VoltageRange    = Fig.Values{3};

end


%% ======================== NESTED CALLBACK FUNCTIONS =====================

    %================ UPDATE CALIBRATION VALUES
    function Cal = CalibUpdate(hObj, Event, Indx1, Indx2, Indx3)
        switch Indx1
             case 1     %============= New edit value was entered
                String = get(hObj, 'String');
                Fig.Values{Indx2}(Indx3) = str2num(String);

             case 2     %============= Down arrow button was pressed
                Fig.Values{Indx2}(Indx3) = Fig.Values{Indx2}(Indx3)-Fig.ChangeInc;
                set(Fig.Edit(Indx2, Indx3), 'string', sprintf('%.2f', Fig.Values{Indx2}(Indx3)));

             case 3     %============= Up arrow button was pressed
                Fig.Values{Indx2}(Indx3) = Fig.Values{Indx2}(Indx3)+Fig.ChangeInc;
                set(Fig.Edit(Indx2, Indx3), 'string', sprintf('%.2f', Fig.Values{Indx2}(Indx3)));
         end
         Cal.EyeOffset    = Fig.Values{1};
         Cal.EyeGain      = Fig.Values{2};
         Cal.VoltageRange = Fig.Values{3};

    end

    %=============== LOAD OR SAVE CALIBRATION PARAMETERS
    function CalibOutput(hObj, Event, Indx)

        switch Indx
            case 1  %============= Load a previous calibration
                [file, path] = uigetfile('*.mat','Load previous calibration');
                if file ~= 0
                    CalibFilename   = fullfile(path, file);
                    load(CalibFilename);
                    Fig.Values      = {Cal.EyeOffset, Cal.EyeGain, Cal.VoltageRange}; 
                    for n = 1:size(Fig.Edit, 1)
                        for xy = 1:size(Fig.Edit, 2)
                            set(Fig.Edit(n, xy), 'string', num2str(Fig.Values{n}(xy)));
                        end
                    end
                end

            case 2  %============= Save calibration
                [file, path] = uiputfile('*.mat','Save calibration');
                if file ~= 0
                    for n = 1:size(Fig.Edit, 1)
                        for xy = 1:size(Fig.Edit, 2)
                            Fig.Values{n}(xy) = str2num(get(Fig.Edit(n, xy), 'string'));
                        end
                    end
                    Cal.EyeOffset       = Fig.Values{1};
                    Cal.EyeGain         = Fig.Values{2};
                    Cal.VoltageRange    = Fig.Values{3};
                    Cal = rmfield(Cal, 'Window');
                    CalibFilename   = fullfile(path, file);
                    save(CalibFilename, 'Cal');
                end
            case 3
                Cal.Window = 0;
                close(Fig.Handle);
                return;
        end

    end

end
