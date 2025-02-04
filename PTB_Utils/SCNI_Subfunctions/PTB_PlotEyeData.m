function Params = SCNI_PlotEyeData(Params)

%========================= SCNI_PlotEyeTrace.m ============================
% Plots eye data for a single trial of eye calibration and allows the user 
% to manually adjust the offset and gain parameters.
%
%
%==========================================================================


%========= Check whether eye data figure window is already open
if nargin == 0 || ~isfield(s, 'Fig') || ~ishandle(Fig.Handle)
    Fig.Background    = [0.9,0.9,0.9];
    Fig.Fontsize      = 14;
    Fig.GazeWinPos    = [1, 400, 1100, 600];
    if ismac && exist('c','var')
        Fig.GazeWinPos = Fig.GazeWinPos+[Params.Display.Rect(3)*2,0,0,0];
    end
    Fig.Handle        = figure('name','SCNI_PlotEyeData','position',Fig.GazeWinPos,'color',Fig.Background);
    FirstPlot           = 1;
    
 	%========= Set default analysis parameters based on assumptions about reaction time
    s.VoltageRange      = [-5, 5];                          % Range of ADC voltages (V)
    s.InitWinTimes      = [0, 0.1];                         % Time window of initial eye position (seconds from target onset)
    s.SacWinTimes       = [0.2, 0.3];                       % Time window of likely saccade to target (seconds from target onset)
    s.FixWinTimes       = [0.3, 0.5];                       % Time window of likely fixation on target (seconds from target onset)
    s.EpochColors       = [1, 0 0; 1 1 0; 0 1 0];           
    s.EpochNames        = {'Pre', 'Saccade', 'Fix'};
    Fig.ChangeInc     = 0.05;                             % Increment size when adjusting voltages with arrow keys (V)
    Fig.EpochInc  	= 10;                               % Increment size when adjusting time windows with arrow keys (ms)
    

 	c.EyeInvertX        = 0;
    c.EyeInvertY        = 0;

    %========= Parse input EyePos
    if nargin > 0
        NoEyeChannels      	= min(size(EyePos));
    else
        NoEyeChannels      	= 2;
    end
    if NoEyeChannels<4                                      % If eye data matrix only contains less than 4 channels...
        Params.Eye.Cal.Labels    = {'Left eye'};                 % Only use left eye    
        Fig.EyeIndx{1}   	= [1,2];                        % Channel indices for left eye (X and Y)
        Fig.EyeIndx{2}   	= [];
        Fig.PupilIndx    	= [];
    end
    if NoEyeChannels == 4
        Fig.EyeIndx{1} 	= [1,2];                        % Channel indices for left eye (X and Y)
        Fig.EyeIndx{2}   	= [3,4];                        % Channel indices for right eye (X and Y)
        Fig.PupilIndx    	= [];
    elseif NoEyeChannels == 6
        Fig.EyeIndx{1}  	= [1,2];
        Fig.EyeIndx{2}  	= [4,5];
        Fig.PupilIndx   	= [3,6];
    end
       
    
elseif isfield(s, 'Fig') && ishandle(Fig.Handle)
    c.EyePos    = EyePos;         	% Update eye position for current trial
    FirstPlot   = 0;              	% This is not the first trial to be plotted
    figure(Fig.Handle);           % Make figure window active
    delete(s.ph);                   % Delete plotted data from previous trial
    for n = 1:numel(Fig.bph)      % For each box plot handle...
        delete(Fig.bph{n});       % Delete box and whisker plots
    end
end





Samples         = StimOnsetSamples(stim):StimOffsetSamples(stim); 
GazeRect        = Params.Eye.Target.GazeRect{LocIndices(stim)};
InRect          = (EyeDataPixScreen(1,Samples) >= GazeRect(RectLeft) & EyeDataPixScreen(1,Samples) <= GazeRect(RectRight) & ...
                    EyeDataPixScreen(2,Samples) >= GazeRect(RectTop) & EyeDataPixScreen(2,Samples) <= GazeRect(RectBottom));
PropFix(stim)   = sum(InRect)/numel(InRect);

%=============== GET STIMULUS LOCATIONS
if Params.Eye.CenterOnly == 1
    LocIndices     = repmat(find(ismember(Params.Eye.Target.FixLocDirections,[0,0],'rows')), [1, Params.Eye.StimPerTrial]);
elseif Params.Eye.CenterOnly == 0
    LocIndices     = Params.Eye.Target.LocationOrder((Params.Run.StimCount-Params.Eye.StimPerTrial):(Params.Run.StimCount-1));
end    


%=================== PLOT NEW DATA
if FirstPlot == 1
    Fig.Axh(1) = axes('units','normalized','position',[0.05, 0.05, 0.26, 0.8],'tickdir','out');
else
    axes(Fig.Axh(1));
end




s.ph(1) = plot(EyePos(1,:), EyePos(2,:),'-k','color', [0.5, 0.5, 0.5]);
hold on;
for stim = 1:
    GazeRect = Params.Eye.Target.GazeRect{LocIndices(stim)};
    plot(Params.Display.Rect([1,3]), Params.Display.Rect([4,4])/2, '--k', 'linewidth',2);
    hold on;
    plot(Params.Display.Rect([3,3])/2, Params.Display.Rect([2,4]), '--k', 'linewidth',2);
    patch(GazeRect([1,3,3,1]), GazeRect([2,2,4,4]), [0,0,0,0], 'facecolor','none','edgecolor',[1,0,0]);
    plot(EyeDataPixScreen(1,Samples), EyeDataPixScreen(2,Samples), '-b', 'linewidth',2);
    MedianFix = [median(EyePos(1,EpochWinSamples{n})), median(EyePos(2,EpochWinSamples{n}))];
    s.ph(n+2) = DrawCircle(MedianFix, 0.5, [0 1 0], 0.3, 1);
    axis equal
    set(gca,'xlim', Params.Display.Rect([1,3]), 'ylim', Params.Display.Rect([2,4]),'tickdir','out');
    grid on;
    box off;
end


if FirstPlot == 1
    legend(s.ph(2:4), s.EpochNames, 'location', 'northwest','fontsize', Fig.Fontsize);
    grid on
    axis equal
    set(Fig.Axh(1), 'xlim', s.VoltageRange, 'ylim', s.VoltageRange, 'xtick', s.VoltageRange(1):1:s.VoltageRange(2),'color', [0.75,0.75,0.75]);
    xlabel(Fig.Axh(1),'X voltage (V)','fontsize', Fig.Fontsize);
    ylabel(Fig.Axh(1),'Y voltage (V)','fontsize', Fig.Fontsize);
    Fig.Vcenter(1) = plot(s.VoltageRange, [0 0], '--k');
    Fig.Vcenter(2) = plot([0 0], s.VoltageRange, '--k');
    
    %========== Plot in DVA
    Fig.Axh(2) = axes('Position',get(Fig.Axh(1),'position'),'XAxisLocation','top','YAxisLocation','right','Color','none','tickdir','out');
    Fig.Axh(2).XColor = 'r';                                      % Set DVA axis color
    Fig.Axh(2).YColor = 'r';                                      % Set DVA axis color
  	axis tight                                                      
    DVA_Xrange = (s.VoltageRange-c.EyeOffset(1))*c.EyeGain(1);      % Calculate range of possible DVA values from voltage range
    DVA_Yrange = (s.VoltageRange-c.EyeOffset(2))*c.EyeGain(2);      % Calculate range of possible DVA values from voltage range
    set(Fig.Axh(2), 'xlim', DVA_Xrange, 'ylim', DVA_Yrange);      % Set axis limits based on calculated range
  	xlabel(Fig.Axh(2),'X position (degrees)','fontsize', Fig.Fontsize);
    ylabel(Fig.Axh(2),'Y position (degrees)','fontsize', Fig.Fontsize);
    grid on                                                         
    Fig.DisplayFrame = rectangle('position', [0,0,Params.Display.RectDeg]-[Params.Display.RectDeg,0,0]/2,'edgecolor',[1 0 0],'linewidth',2);
    hold on
    Fig.DVAcenter(1) = plot(DVA_Xrange, [0 0], '--r');            % Draw cross-hairs to mark center of display (DVA)
    Fig.DVAcenter(2) = plot([0 0], DVA_Yrange, '--r');            % Draw cross-hairs to mark center of display (DVA)
    h = DrawCircle([0,0], 1, [0 0 0], 1, 0);                        % Draw circle to mark center of screen (0 DVA)
    daspect([1, diff(DVA_Yrange)/diff(DVA_Xrange), 1]);             % Set aspect ratio of plot in DVA
    
else
    DVA_Xrange = (s.VoltageRange-c.EyeOffset(1))*c.EyeGain(1);      % Calculate range of possible DVA values from voltage range
    DVA_Yrange = (s.VoltageRange-c.EyeOffset(2))*c.EyeGain(2);      % Calculate range of possible DVA values from voltage range
    set(Fig.Axh(2), 'xlim', DVA_Xrange, 'ylim', DVA_Yrange);      % Set axis limits based on calculated range
    daspect([1, diff(DVA_Yrange)/diff(DVA_Xrange), 1]);             % Set aspect ratio of plot in DVA
end
    
%=================== EYE POSITION TIME COURSE
if FirstPlot == 1
    Fig.Axh(3) = subplot(2,3,2);
else
    axes(Fig.Axh(3));
end
Fig.TimeStamps = (1:size(EyePos,2))*Params.DPx.AnalogInRate/1000;

s.ph(5) = plot(Fig.TimeStamps, EyePos(1,:),'-r','color',[1,0.5,0.5]);
hold on;
s.ph(6) = plot(Fig.TimeStamps, EyePos(2,:),'-b','color',[0.5,0.5,1]);
s.ph(7) = plot(s.FixWinTimes*Params.DPx.AnalogInRate, repmat(mean(EyePos(1,EpochWinSamples{3})),[1,2]),'-r','linewidth',2);
s.ph(8) = plot(s.FixWinTimes*Params.DPx.AnalogInRate, repmat(mean(EyePos(2,EpochWinSamples{3})),[1,2]),'-b','linewidth',2);
if FirstPlot == 1
    xlabel('Time (ms)','fontsize', Fig.Fontsize);
    ylabel('Voltage (V)','fontsize', Fig.Fontsize);
    grid on;
    legend(s.ph(7:8),{'X','Y'},'fontsize', Fig.Fontsize);
    Ylims = s.VoltageRange;
    Fig.EpochH(1) = patch(s.InitWinTimes([1,1,2,2])*Params.DPx.AnalogInRate, Ylims([1,2,2,1]), zeros(1,4),'facecolor',s.EpochColors(1,:),'facealpha', 0.3,'edgecolor', 'none');
    Fig.EpochH(2) = patch(s.SacWinTimes([1,1,2,2])*Params.DPx.AnalogInRate, Ylims([1,2,2,1]), zeros(1,4),'facecolor',s.EpochColors(2,:),'facealpha', 0.3,'edgecolor', 'none');
    Fig.EpochH(3) = patch(s.FixWinTimes([1,1,2,2])*Params.DPx.AnalogInRate, Ylims([1,2,2,1]), zeros(1,4),'facecolor',s.EpochColors(3,:),'facealpha', 0.3,'edgecolor', 'none');
    plot([0, TargetDuration*Params.DPx.AnalogInRate], [0 0], '-k', 'linewidth', 4);
    uistack(Fig.EpochH, 'bottom')
end


%=================== BOX AND WHISKER PLOTS
if FirstPlot == 1
	Fig.Axh(4) = subplot(2,3,5);
else
    axes(Fig.Axh(4));
end
EyePosDist   = sqrt(c.EyePos(1,:).^2 + c.EyePos(2,:).^2);                      % Combine X and Y vectors into single position vector
for n = 1:3
    Fig.bph{n} = boxplot(EyePosDist(:,EpochWinSamples{n}),'Notch','on','boxstyle','filled','colors',s.EpochColors(n,:));
    hold on
    for ch = 1:numel(Fig.bph{n})
        set(Fig.bph{n}(ch), 'Xdata', get(Fig.bph{n}(ch), 'Xdata')+n-1);
    end
	set(Fig.bph{n}(5), 'color', [0,0,0]);
	set(Fig.bph{n}(6), 'color', [0,0,0], 'linewidth', 2);
end
set(gca, 'xlim',[0.5, 3.5]);
if FirstPlot == 1
    grid on;
    ylabel('Distance from target (V)','fontsize', Fig.Fontsize)
    set(gca, 'xlim',[0.5, 3.5], 'xtick',1:3, 'xticklabel', s.EpochNames,'ylim',[0, s.VoltageRange(2)],'fontsize', Fig.Fontsize);
end

UpdatePlots;

%% ========================= ADD GUI CONTROLS =============================
if FirstPlot == 1
    Fig.PannelPos     = [0.66,0.42,0.33,0.55];
    Fig.ArrowColor    = [0.7,0.9,1];
    Fig.Labels        = {'Offset (V)','Gain (deg/V)', 'Range (V)'};
    Fig.EpochLabels   = {'Onset', 'Saccade', 'Fixation'};
    Fig.EpochValues   = {s.InitWinTimes, s.SacWinTimes, s.FixWinTimes};
    Fig.ButtonLabels  = {'Invert X','Invert Y'};
    Fig.ButtonValues  = {c.EyeInvertX, c.EyeInvertY};
    Fig.Values        = {c.EyeOffset, c.EyeGain, s.VoltageRange};
    Fig.PanelHandle   = uipanel('Title','Eye tracker calibration',...
                        'FontSize', Fig.Fontsize+2,...
                        'BackgroundColor',Fig.Background,...
                        'Units','normalized',...
                        'Position',Fig.PannelPos,...
                        'Parent', Fig.Handle); 

   	YposStart = [280,255,230];
    uicontrol('Style', 'text','String', 'Method', 'Position', [20, YposStart(1), 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize,'backgroundcolor', Fig.Background);
    uicontrol('Style', 'Popup','String', {'Manual','Automated (time)','Automated (position)'}, 'Position', [110, YposStart(1), 160, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize,'Callback',{@ChangeMethod});
    uicontrol('Style', 'text','String', 'Select eye', 'Position', [20, YposStart(2), 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize,'backgroundcolor', Fig.Background);
    Fig.EyeSelectH = uicontrol('Style', 'Popup','String', Params.Eye.Cal.Labels, 'Position', [110, YposStart(2), 160, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize,'Callback',{@ChangeEye},'value', Params.Eye.EyeToUse);
    uicontrol('Style', 'text','String', 'X', 'Position', [120, YposStart(3), 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
    uicontrol('Style', 'text','String', 'Y', 'Position', [220, YposStart(3), 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);

    Ypos = YposStart(3)-20;
    for n = 1:numel(Fig.Labels)
        uicontrol('Style', 'text','String',Fig.Labels{n},'Position', [20, Ypos, 100, 20],'Parent',Fig.PanelHandle, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
        Xpos = 120;
        for xy = 1:2
            Fig.Edit(n, xy)     = uicontrol('Style', 'Edit','String', sprintf('%.2f', Fig.Values{n}(xy)), 'Position', [Xpos,Ypos,50,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibUpdate,1,n,xy});
            Fig.Arrow(n, xy, 1) = uicontrol('Style', 'PushButton', 'String', '<','Position', [Xpos+50,Ypos,20,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibUpdate,2,n,xy}, 'backgroundcolor', Fig.ArrowColor);
            Fig.Arrow(n, xy, 2) = uicontrol('Style', 'PushButton', 'String', '>','Position', [Xpos+70,Ypos,20,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@CalibUpdate,3,n,xy}, 'backgroundcolor', Fig.ArrowColor);
            Xpos = Xpos + 100;
        end
        Ypos = Ypos-25;
    end

    Ypos = Ypos - 15;
    uicontrol('Style', 'text','String', 'Start (ms)', 'Position', [120, Ypos, 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
    uicontrol('Style', 'text','String', 'End (ms)', 'Position', [220, Ypos, 80, 20], 'HorizontalAlignment', 'left', 'Parent', Fig.PanelHandle,'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
    Ypos = Ypos - 25;
    for n = 1:numel(Fig.EpochLabels)
        uicontrol('Style', 'text','String',Fig.EpochLabels{n},'Position', [20, Ypos, 100, 20],'Parent',Fig.PanelHandle, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
        Xpos = 120;
        for r = 1:2
            Fig.TimeRange(n, r) = uicontrol('Style', 'Edit','String', sprintf('%.0f', Fig.EpochValues{n}(r)*10^3), 'Position', [Xpos,Ypos,50,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@EpochUpdate,1,n,r});
            Fig.Arrow(n, xy, 1) = uicontrol('Style', 'PushButton', 'String', '<','Position', [Xpos+50,Ypos,20,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@EpochUpdate,2,n,r}, 'backgroundcolor', Fig.ArrowColor);
            Fig.Arrow(n, xy, 2) = uicontrol('Style', 'PushButton', 'String', '>','Position', [Xpos+70,Ypos,20,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@EpochUpdate,3,n,r}, 'backgroundcolor', Fig.ArrowColor);
            Xpos = Xpos + 100;
        end
        Ypos = Ypos - 25;
    end
    
    Xpos = 120;
    for n = 1:numel(Fig.ButtonLabels)
        Fig.ButtonH(n) = uicontrol('Style', 'ToggleButton', 'String', Fig.ButtonLabels{n}, 'value', Fig.ButtonValues{n} ,'Position', [Xpos,Ypos,80,20],'Parent',Fig.PanelHandle,'HorizontalAlignment', 'left','FontSize', Fig.Fontsize,'Callback',{@InvertAxis,n});
        Xpos = Xpos + 100;
    end
    
    
    %============= STATUS PANNEL
    Fig.PannelPos2    = [0.66,0.18,0.33,0.22];
    Fig.PanelHandle2	= uipanel('Title','Calibration status',...
                        'FontSize', Fig.Fontsize+2,...
                        'BackgroundColor',Fig.Background,...
                        'Units','normalized',...
                        'Position',Fig.PannelPos2,...
                        'Parent', Fig.Handle); 
    Fig.Labels2     	= {'Eye detected','Criteria met','Fix. deviation','X:Y ratio'};
    Fig.Values2       = {10, 'Yes', 1.5, 0.5};
    Fig.StringFormat  = {'%.0f%%','%s','%.2f (dva)','%.3f'};
  	Ypos = 80;
    for n = 1:numel(Fig.Labels2)
        uicontrol('Style', 'text','String',Fig.Labels2{n},'Position', [20, Ypos, 100, 20],'Parent',Fig.PanelHandle2, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
        Fig.StatusString(n) = uicontrol('Style', 'text','String',sprintf(Fig.StringFormat{n}, Fig.Values2{n}),'Position', [150, Ypos, 100, 20],'Parent',Fig.PanelHandle2, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
        Ypos = Ypos - 25;
    end
    
    %============= OUTPUT PANNEL
    Fig.PannelPos3    = [0.66,0.02,0.33,0.15];
    Fig.PanelHandle3	= uipanel('Title','Output',...
                        'FontSize', Fig.Fontsize+2,...
                        'BackgroundColor',Fig.Background,...
                        'Units','normalized',...
                        'Position',Fig.PannelPos3,...
                        'Parent', Fig.Handle); 
    Ypos = 40;
    uicontrol('Style', 'text','String','Filename','Position', [20, Ypos, 100, 20],'Parent',Fig.PanelHandle3, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background);
    Fig.MatfileH = uicontrol('Style', 'edit','String',Fig.CalibFilename,'Position', [140, Ypos, 200, 20],'Parent',Fig.PanelHandle3, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize);
    uicontrol('Style', 'pushbutton','String','...','Position', [320, Ypos, 20, 20],'Parent',Fig.PanelHandle3, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'callback', {@CalibOutput, 1},'tooltip','Select previous calibration');
    Ypos = Ypos - 25;
    uicontrol('Style', 'pushbutton','String','Load','Position', [20, Ypos, 100, 20],'Parent',Fig.PanelHandle3, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background, 'callback', {@CalibOutput, 1});
    uicontrol('Style', 'pushbutton','String','Save','Position', [140, Ypos, 100, 20],'Parent',Fig.PanelHandle3, 'HorizontalAlignment', 'left', 'FontSize', Fig.Fontsize, 'backgroundcolor', Fig.Background, 'callback', {@CalibOutput, 2});
end

%============= Load previous calibration parameters
% LoadCalibration(Fig.CalibFilename);


%% ========================== SUBFUNCTIONS ================================

    %================ Draw a filled circle
    function h = DrawCircle(xy, rad, rgb, alpha, filled)
        h = rectangle('Position',[-rad,-rad,rad*2,rad*2]+[xy,0,0],'Curvature',1);
        if filled == 0
            set(h, 'edgecolor', [rgb, alpha]);
        elseif filled == 1
            set(h, 'facecolor', [rgb, alpha],'edgecolor','none');
        end
    end

    %================ CHANGE METHOD
    function ChangeMethod(hObj, Event, Indx)
        Indx = get(hObj, 'value');
        switch Indx
            case 1
                set(Fig.Edit, 'enable', 'on');
                set(Fig.Arrow, 'enable', 'on');
                set(Fig.TimeRange, 'enable', 'off');
            case 2
                set(Fig.TimeRange, 'enable', 'on');
                set(Fig.Edit, 'enable', 'off');
                set(Fig.Arrow, 'enable', 'off');
            case 3

        end

    end

    %================ CHANGE EYE
    function ChangeEye(hObj, Event, Indx)
        Params.Eye.EyeToUse = get(hObj, 'value');
        switch Params.Eye.Cal.Labels{Params.Eye.EyeToUse}
            case 'Left eye'
                EyeData = EyePos(1:2,:);
            case 'Right eye'
                EyeData = EyePos(3:4,:);
            case 'Version (L+R)'
                EyeData = EyePos(1:2,:) + EyePos(3:4,:);
        end
        %======= Update GUI values for selected eye
        for n = 1:numel(Fig.Labels)
            for xy = 1:2
                set(Fig.Edit(n, xy), 'String', sprintf('%.2f', Fig.Values{n}(xy)));
            end
        end

    end

    %================ INVERT EYE POSITION VOLTAGES
    function InvertAxis(hObj, Event, Indx)
        if Indx == 1
            c.EyeInvertX = get(hObj,'value');
        elseif Indx == 2
            c.EyeInvertY = get(hObj,'value');
        end
        if c.EyeInvertX == 1
            set(Fig.Axh(1), 'Xdir', 'reverse');
        elseif c.EyeInvertX == 0
            set(Fig.Axh(1), 'Xdir', 'normal');
        end
        if c.EyeInvertY == 1
            set(Fig.Axh(1), 'Ydir', 'reverse');
        elseif c.EyeInvertY == 0
            set(Fig.Axh(1), 'Ydir', 'normal');
        end 
        
    end

    %================ UPDATE CALIBRATION VALUES
    function CalibUpdate(hObj, Event, Indx1, Indx2, Indx3)
        switch Indx1
             case 1     %============= New edit value was entered
                String = get(hObj, 'String');
    %             if Indx3 == 1 && str2num(String)< Fig.Values{Indx2}(2)
    %                 Fig.Values{Indx2}(Indx3) = str2num(String);
    %             elseif Indx3 == 2 && str2num(String)> Fig.Values{Indx2}(1)
                    Fig.Values{Indx2}(Indx3) = str2num(String);
    %             else
    %                 
    %             end

             case 2     %============= Down arrow button was pressed
                Fig.Values{Indx2}(Indx3) = Fig.Values{Indx2}(Indx3)-Fig.ChangeInc;
                set(Fig.Edit(Indx2, Indx3), 'string', sprintf('%.2f', Fig.Values{Indx2}(Indx3)));

             case 3     %============= Up arrow button was pressed
                Fig.Values{Indx2}(Indx3) = Fig.Values{Indx2}(Indx3)+Fig.ChangeInc;
                set(Fig.Edit(Indx2, Indx3), 'string', sprintf('%.2f', Fig.Values{Indx2}(Indx3)));
         end
         c.EyeOffset    = Fig.Values{1};
         c.EyeGain      = Fig.Values{2};
         s.VoltageRange = Fig.Values{3};
         UpdatePlots;
    end

    %================ UPDATE CALIBRATION PLOTS
    function UpdatePlots

        %========= Update axes 1 range
        if diff(s.VoltageRange) <= 10
            VoltageTicks = round(s.VoltageRange(1)):1:s.VoltageRange(2);
        else
           VoltageTicks = round(s.VoltageRange(1)):2:s.VoltageRange(2);
        end
        set(Fig.Axh(1), 'xlim', s.VoltageRange, 'ylim', s.VoltageRange, 'xtick', VoltageTicks, 'ytick', VoltageTicks);
        set(Fig.Axh(3), 'ylim', s.VoltageRange, 'ytick', VoltageTicks);
        set(Fig.Vcenter(1), 'xdata', s.VoltageRange);
        set(Fig.Vcenter(2), 'ydata', s.VoltageRange);
        DVA_Xrange = (s.VoltageRange-c.EyeOffset(1))*c.EyeGain(1);
        DVA_Yrange = (s.VoltageRange-c.EyeOffset(2))*c.EyeGain(2);
        set(Fig.Axh(2), 'xlim', DVA_Xrange, 'ylim', DVA_Yrange);
        set(Fig.EpochH, 'Ydata', s.VoltageRange([1,2,2,1]));
        set(Fig.Axh(2), 'position', get(Fig.Axh(1),'position'));
        set(Fig.DVAcenter(1),'Xdata',DVA_Xrange);
        set(Fig.DVAcenter(2),'Ydata',DVA_Yrange);
        axes(Fig.Axh(2));
        daspect([1, diff(DVA_Yrange)/diff(DVA_Xrange), 1]);     % Set aspect ratio of plot in DVA

        %========= Update box plots
%         UpdateBoxPlot(1);
%         UpdateBoxPlot(2);
%         UpdateBoxPlot(3);
    end

    %================ UPDATE PARAMETERS FOR AUTOMATED CALIBRATION
    function EpochUpdate(hObj, Event, Indx1, Indx2, Indx3)

        switch Indx1
            case 1     %============= New edit value was entered
                if str2num(get(hObj,'string'))/10^3 >= 0 && str2num(get(hObj,'string'))/10^3 < Fig.TimeStamps(end)/10^3
                    Fig.EpochValues{Indx2}(Indx3) = str2num(get(hObj,'string'))/10^3;
                end

            case 2     %============= Down arrow button was pressed
                if Fig.EpochValues{Indx2}(Indx3) >= (Fig.EpochInc/10^3)
                    Fig.EpochValues{Indx2}(Indx3) = Fig.EpochValues{Indx2}(Indx3)-(Fig.EpochInc/10^3);
                    set(Fig.TimeRange(Indx2, Indx3), 'string', sprintf('%.0f', Fig.EpochValues{Indx2}(Indx3)*10^3));
                end

            case 3     %============= Up arrow button was pressed
                if Fig.EpochValues{Indx2}(Indx3) < Fig.TimeStamps(end)/10^3
                    Fig.EpochValues{Indx2}(Indx3) = Fig.EpochValues{Indx2}(Indx3)+(Fig.EpochInc/10^3);
                    set(Fig.TimeRange(Indx2, Indx3), 'string', sprintf('%.0f', Fig.EpochValues{Indx2}(Indx3)*10^3));
                end

        end
        set(Fig.EpochH(Indx2), 'xdata', Fig.EpochValues{Indx2}([1,1,2,2])*Params.DPx.AnalogInRate);     % Update epoch patch location

        %========== Update epoch stats
        s.InitWinTimes  = Fig.EpochValues{1};
        s.SacWinTimes   = Fig.EpochValues{2};
        s.FixWinTimes   = Fig.EpochValues{3};
        for n = 1:3
            EpochWinSamples{n}  = round(Fig.EpochValues{n}(1)*Params.DPx.AnalogInRate)+1:round(Fig.EpochValues{n}(2)*Params.DPx.AnalogInRate);
        end

        if Indx2 == 3   % For fixation epoch update...
            if Params.Eye.EyeToUse <= 2
                set(s.ph(7), 'Xdata', s.FixWinTimes*Params.DPx.AnalogInRate, 'Ydata', repmat(mean(c.EyePos(Fig.EyeIndx{Params.Eye.EyeToUse}(1),EpochWinSamples{3})),[1,2]));
                set(s.ph(8), 'Xdata', s.FixWinTimes*Params.DPx.AnalogInRate, 'Ydata', repmat(mean(c.EyePos(Fig.EyeIndx{Params.Eye.EyeToUse}(2),EpochWinSamples{3})),[1,2]));
            elseif Params.Eye.EyeToUse == 3


            end
        end
        UpdateBoxPlot(Indx2);

    end

    %=============== UPDATE BOX PLOTS
    function UpdateBoxPlot(Indx)
        axes(Fig.Axh(4));
        delete(Fig.bph{Indx});
        Fig.bph{Indx} = boxplot(EyePosDist(:,EpochWinSamples{Indx}),'Notch','on','boxstyle','filled','colors',s.EpochColors(Indx,:));
        for ch = 1:numel(Fig.bph{Indx})
            set(Fig.bph{Indx}(ch), 'Xdata', get(Fig.bph{Indx}(ch), 'Xdata')+Indx-1);
        end
        set(Fig.Axh(4),'xlim',[0.5, 3.5]);
    end


    %=============== LOAD OR SAVE CALIBRATION PARAMETERS
    function CalibOutput(hObj, Event, Indx)
        CalibFilename = get(Fig.MatfileH, 'string');
        switch Indx
            case 1  %============= Load a previous calibration
                [file, path] = uigetfile('*.mat','Load previous calibration', CalibFilename);
                if file ~= 0
                    CalibFilename = fullfile(path, file);
                    LoadCalibration(CalibFilename);
                end

            case 2  %============= Save calibration
                [file, path] = uiputfile('*.mat','Save calibration', CalibFilename);
                Fig.Handle = [];
                if file ~= 0
                    CalibFilename = fullfile(path, file);
                    SaveCalibration(CalibFilename);
                end
        end

    end

    %=============== SAVE
    function SaveCalibration(Filename)

        save(Filename, 's','c');
    end

    %=============== LOAD
    function LoadCalibration(Filename)
        set(Fig.MatfileH, 'string', Filename);
        New = load(Filename);

        Params.Eye.EyeToUse        = New.Params.Eye.EyeToUse;
        set(Fig.EyeSelectH, 'value', Params.Eye.EyeToUse);    
        for n = 1:3
            for xy = 1:2
                Fig.Values{n}(xy) = New.Fig.Values{n}(xy);
                set(Fig.Edit(n, xy), 'String', sprintf('%.2f', Fig.Values{n}(xy)));
            end
        end
        c.EyeInvertX = 0;
        c.EyeInvertY = 0;
        set(Fig.ButtonH(1),'value',c.EyeInvertX);
        set(Fig.ButtonH(2),'value',c.EyeInvertY);

      	c.EyeOffset    = Fig.Values{1};
       	c.EyeGain      = Fig.Values{2};
      	s.VoltageRange = Fig.Values{3};
        
        UpdatePlots;

    end

end
