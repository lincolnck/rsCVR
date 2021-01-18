%% preprocessGUI.m
% This script generates a Graphic User Interface intended to help users
% preprocess their CO2 Trace data text files. The GUI is compatible with
% CO2 Trace Data obtained from Philips NM3, Respironics Capnograph, and
% Biopac CO2 recording systems.
%
% Compatible with MATLAB 2016b or later.
%
% Operation:
%       1. Using the drop-down menu in the lower left corner of the GUI,
%   the user should select their device used to record the CO2 Trace. If
%   the device is not seen in the menu then the data format is likely not
%   supported. To process a previously processed recording, select the
%   option [Preprocessed Data].
%       2. Use the "Load CO2 Trace" button to extract the data from the CO2
%   recording and display it in the plot. If this step fails, ensure that
%   the proper device was selected in the drop-down menu.
%       3. The user may change the edit-able fields titled "Begin Chop",
%   "End Chop", "Scale", and "Shift" to alter the data as needed. The plot
%   should adjust its display as the fields are edited. This "chopping" may
%   also be executed by dragging and dropping the slider bars below the
%   plot.
%       4. When the user is satisfied with their changes, the export button
%   can be used to create a Preprocessed CO2 Trace text file. By default,
%   the GUI exports the new file to the same path with the same name as the
%   old file, postfixed with the message "_chopped". This may be changed by
%   altering the "Postfix" checkbox or by editing the path in the field
%   below the export button.
%
% Notes: 
%       * The Scale and Shift fields act as "m" and "b" constants in the
%   line equation y = m*x + b for the loaded CO2 data. For example, a Scale
%   value of 2 doubles each CO2 value, while a Shift value of 5 increases
%   each CO2 value by 5.
%       * See systemValues.biopacChannel under the systemValue Components
%   subtitle if a different channel is needed for recordings from Biopac
%   devices.
%       * See systemValues.postfixString to change the string added on the
%   end of exported files.
%       * If uexpected bugs occur, try using the reset button to resart the
%   program.
%       * Feel free to contact Zachary Baker at zbaker3@jhmi.edu or Dr.
%   Hanzhang Lu at hlu3@jhmi.edu with any questions or problems.



%% Setup

clear; close all; fclose('all'); clc;

% suppress warning thrown by normal GUI function
warning('off','MATLAB:handle_graphics:exceptions:SceneNode')



%% Structure Components

% use systemValues global structure to keep track of important data
% save all user interface components into global uiObjects structure
global systemValues uiObjects
systemValues = struct();
uiObjects = struct();



%% systemValue Components

% can be used to automatically populate the export edit with a specified
% directory (leave as empty string otherwise)
systemValues.permaDir = '';

% turn on to supress the success message box after a successful export
systemValues.noMsgBoxFlag = 0;

% when the user selects the biopac device option, this value will determine
% which channel the data is read from (the value is usually set to 1)
systemValues.biopacChannel = 1;

% allows GUI to remember previous path during subsequent file selection
systemValues.defPath = pwd;

% determines phrase postfixed to the end of exported files' names (provided
% that "postfix" is checked on)
systemValues.postfixString = '_chopped';

% can be used to modify the default scale and shift so they needn't be
% typed each time a trace is loaded (must be strings)
systemValues.initScale = '1';
systemValues.initShift = '0';



%% UI Components

uiObjects.f = figure('units','normalized','position',[0.05,0.3,0.9,0.6]);

uiObjects.a = axes('units','normalized','position',[0.05,0.35,0.9,0.6]);
xlabel('Time (s)')
ylabel('CO2 (mmHg)')
hold on

uiObjects.deviceDropDown = uicontrol('style','popupmenu','units',...
    'normalized','position',[0.05,0.125,0.15,0.05],'string',...
    {'-- Select recording device --','Philips NM3',...
    'Respironics Capnograph',['Biopac (channel '...
    num2str(systemValues.biopacChannel) ')'],'[Preprocessed Data]'},...
    'fontsize',14,'callback',@deviceDropDownCallback);

uiObjects.loadSubjectButton = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.22,0.125,0.1,0.05],'string','Load CO2 Trace',...
    'fontsize',14,'callback',@loadSubjectButtonCallback,'enable','off');

uiObjects.loadMessage = uicontrol('style','text','units','normalized',...
    'position',[0.325,0.118,0.07,0.05],'string','Loading...',...
    'fontsize',14,'visible','off');

uiObjects.postfixBox = uicontrol('style','checkbox','units','normalized',...
    'position',[0.95,0.02,0.05,0.05],'string','Postfix','value',1,...
    'callback',@postfixBoxCallback);

uiObjects.startChopText = uicontrol('style','text','units','normalized',...
    'position',[0.425,0.15,0.1,0.05],'string','Begin Chop (s)',...
    'fontsize',12);

uiObjects.startChopEdit = uicontrol('style','edit','units','normalized',...
    'position',[0.425,0.11,0.1,0.05],'string','','fontsize',14,...
    'callback',@chopEditCallback,'enable','off','userdata',1);

uiObjects.endChopText = uicontrol('style','text','units','normalized',...
    'position',[0.525,0.15,0.1,0.05],'string','End Chop (s)',...
    'fontsize',12);

uiObjects.endChopEdit = uicontrol('style','edit','units','normalized',...
    'position',[0.525,0.11,0.1,0.05],'string','','fontsize',14,...
    'callback',@chopEditCallback,'enable','off','userdata',2);

uiObjects.scaleTermText = uicontrol('style','text','units','normalized',...
    'position',[0.42,0.01,0.04,0.05],'string','Scale:','fontsize',12);

uiObjects.scaleTermEdit = uicontrol('style','edit','units','normalized',...
    'position',[0.46,0.02,0.04,0.05],'string','1','fontsize',12,...
    'callback',@shiftScaleCallback,'enable','off','userdata',1);

uiObjects.shiftTermText = uicontrol('style','text','units','normalized',...
    'position',[0.52,0.01,0.04,0.05],'string','Shift:','fontsize',12);

uiObjects.shiftTermEdit = uicontrol('style','edit','units','normalized',...
    'position',[0.56,0.02,0.04,0.05],'string','0','fontsize',12,...
    'callback',@shiftScaleCallback,'enable','off','userdata',2);

uiObjects.exportEdit = uicontrol('style','edit','units','normalized',...
    'position',[0.65,0.08,0.325,0.05],'string','','fontsize',8);

uiObjects.exportButton = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.8,0.15,0.1,0.05],'string','Export',...
    'fontsize',14,'callback',@exportCallback,'enable','off');

uiObjects.exportMessage = uicontrol('style','text','units','normalized',...
    'position',[0.9,0.142,0.1,0.05],'string','Exporting...',...
    'fontsize',14,'visible','off');

uiObjects.resetButton = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.9,0.96,0.075,0.03],'string','Reset',...
    'fontsize',10,'callback',@resetCallback);

uiObjects.quickChop1 = uicontrol('style','slider','units','normalized',...
'position',[0.05,0.22,0.9,0.025],'enable','off','userdata',1,'callback',...
@quickChopCallback,'backgroundcolor',[0.6,0.6,0.6]);
uiObjects.quickChop2 = uicontrol('style','slider','units','normalized',...
'position',[0.05,0.25,0.9,0.025],'enable','off','userdata',2,'callback',...
@quickChopCallback,'backgroundcolor',[0.6,0.6,0.6]);

uiObjects.lis1 = addlistener(uiObjects.quickChop1,'Value','PreSet',...
    @lisCallback1);
uiObjects.lis2 = addlistener(uiObjects.quickChop2,'Value','PreSet',...
    @lisCallback2);
uiObjects.plotQuickChop = [];



%% Callbacks and Support Functions

function deviceDropDownCallback(~,~)
% Only allow recording to be loaded if user selects a recording device. If
% the user selects [Preprocessed Data] then the GUI will use samples for
% the x-axis units, rather than seconds.

    global uiObjects
    
    if get(uiObjects.deviceDropDown,'value') == 1
        set(uiObjects.loadSubjectButton,'enable','off')
    elseif get(uiObjects.deviceDropDown,'value') == 2 ||...
            get(uiObjects.deviceDropDown,'value') == 3 ||...
            get(uiObjects.deviceDropDown,'value') == 4
        set(uiObjects.loadSubjectButton,'enable','on')
        xlabel('Time (s)')
        set(uiObjects.startChopText,'string','Begin Chop (s)')
        set(uiObjects.endChopText,'string','End Chop (s)')
    end
    if get(uiObjects.deviceDropDown,'value') == 5
        set(uiObjects.loadSubjectButton,'enable','on')
        xlabel('Time (samples)')
        set(uiObjects.startChopText,'string','Begin Chop (samples)')
        set(uiObjects.endChopText,'string','End Chop (samples)')
    end

end

function loadSubjectButtonCallback(~,~)
% Prompt user to select a text file. Then extract CO2 data according to
% the user's specified recording device. Then enable other uiComponents.

    global uiObjects systemValues
    
    [file, path] = uigetfile('*.txt;*.TXT;*.csv','Select a CO2 Trace',...
        systemValues.defPath);
    if path ~= 0
        systemValues.defPath = path;
    else
        return
    end
    
    set(uiObjects.loadMessage,'visible','on')
    drawnow
    
    systemValues.filePath = [path file];
    title(uiObjects.a,systemValues.filePath)
    [pth,nme,ext] = fileparts(systemValues.filePath);
    if ~isempty(systemValues.permaDir)
        pth = systemValues.permaDir;
    end
    systemValues.pth = pth;
    systemValues.nme = nme;
    systemValues.ext = ext;
    updateExportEditString();
    set(uiObjects.startChopEdit,'string','')
    systemValues.start = '';
    set(uiObjects.endChopEdit,'string','')
    systemValues.end = '';
    set(uiObjects.scaleTermEdit,'string',systemValues.initScale)
    systemValues.scale = systemValues.initScale;
    set(uiObjects.shiftTermEdit,'string',systemValues.initShift)
    systemValues.shift = systemValues.initShift;
    
    cla(uiObjects.a)
    
    drawPlot(1);
    
    set(uiObjects.exportButton,'enable','on')
    set(uiObjects.startChopEdit,'enable','on')
    set(uiObjects.endChopEdit,'enable','on')
    set(uiObjects.scaleTermEdit,'enable','on')
    set(uiObjects.shiftTermEdit,'enable','on')
    updateQuickChop()
    set(uiObjects.quickChop1,'enable','on')
    set(uiObjects.quickChop2,'enable','on')    

    set(uiObjects.loadMessage,'visible','off')
    shiftScaleCallback(uiObjects.scaleTermEdit,0);
    shiftScaleCallback(uiObjects.shiftTermEdit,0);
    
end

function chopEditCallback(source,~)
% Properly update the plot after the user chops the data (but only if the
% given value is a valid, logical chop).

    global uiObjects systemValues
    
    bool = drawPlot(0);
    
    if bool == 0
        if source.UserData == 1
            set(source,'string',systemValues.start)
        elseif source.UserData == 2
            set(source,'string',systemValues.end)
        end
    else
        systemValues.start = uiObjects.startChopEdit.String;
        systemValues.end = uiObjects.endChopEdit.String;
    end

    updateQuickChop()
    
end

function quickChopCallback(source,~)

    global uiObjects

    delete(uiObjects.plotQuickChop)
    if source.UserData == 1
        uiObjects.startChopEdit.String = source.Value;
        chopEditCallback(uiObjects.startChopEdit)
    elseif source.UserData == 2
        uiObjects.endChopEdit.String = source.Value;
        chopEditCallback(uiObjects.endChopEdit)
    end

end

function lisCallback1(source,eventdata)

    global systemValues uiObjects
    
    idx = find(systemValues.time < get(uiObjects.quickChop1,'Value'));
    dataMarks = systemValues.co2Data(idx);
    timeMarks = systemValues.time(idx);
    delete(uiObjects.plotQuickChop)
    uiObjects.plotQuickChop = plot(timeMarks,dataMarks,'r');

end

function lisCallback2(source,eventdata)

    global systemValues uiObjects
    
    idx = find(systemValues.time > get(uiObjects.quickChop2,'Value'));
    dataMarks = systemValues.co2Data(idx);
    timeMarks = systemValues.time(idx);
    delete(uiObjects.plotQuickChop)
    uiObjects.plotQuickChop = plot(timeMarks,dataMarks,'r');

end

function shiftScaleCallback(source,eventdata)
% Properly update the plot after the user scales or shifts the data (but
% only if the given value is a valid, logical scale or shift).

    global uiObjects systemValues
    
    bool = drawPlot(0);
    
    if bool == 0
        if source.UserData == 1
            set(source,'string',systemValues.scale)
        elseif source.UserData == 2
            set(source,'string',systemValues.shift)
        end
    else
        systemValues.scale = uiObjects.scaleTermEdit.String;
        systemValues.shift = uiObjects.shiftTermEdit.String;
        
        if str2double(systemValues.scale) ~= 1 ||...
                str2double(systemValues.shift) ~= 0
            systemValues.postfixString = '_scaleShift_chopped';
        else
            systemValues.postfixString = '_chopped';
        end
        updateExportEditString();
    end

end

function postfixBoxCallback(source,~)
% Adjust the export-file path accrding to the postfix's value.

    global uiObjects systemValues
    
    if strcmp(uiObjects.exportButton.Enable,'off')
        return
    else
        if source.Value == 1
            set(uiObjects.exportEdit,'string',...
                [systemValues.pth filesep systemValues.nme...
                systemValues.postfixString '.txt'])
        elseif source.Value == 0
            set(uiObjects.exportEdit,'string',...
                [systemValues.pth filesep systemValues.nme '.txt'])
        end
    end

end

function exportCallback(~,~)
% Send preprocessed data to a Preprocessed CO2 Trace file (this file is a
% text document containing a single column of float values). Offers a
% warning message if the export-file path already exists.

    global uiObjects systemValues
    
    set(uiObjects.exportMessage,'visible','on')

    newFile = uiObjects.exportEdit.String;

    if exist(newFile,'file')
        answer = questdlg(['WARNING: File already exists'...
            newline newline newFile newline newline ...
            'Replace it? This action cannot be undone.'],...
            'File already exists','Cancel');
        if ~strcmp(answer,'Yes')
            msgbox('Cancelled')
            set(uiObjects.exportMessage,'visible','off')
            return
        end
    end
    dlmwrite(newFile, systemValues.co2Data);
    if ~systemValues.noMsgBoxFlag
        msgbox('Success')
    else
        disp('Success')
    end
    set(uiObjects.exportMessage,'visible','off')

end

function resetCallback(~,~)
% Reset everything and re-run GUI.

    clear; close all; fclose('all'); clc;
    run(mfilename)

end

function bool = drawPlot(reload)
% Extract CO2 data and sampleRate (if required by the argument) and plot
% accordingly. Return 0 if a problem occurs with the user's adjustments.

    global uiObjects systemValues

    bool = 0;
    
    if reload
        [co2Data, sampleRate] = getCo2Data(systemValues.filePath);
    else
        co2Data = systemValues.co2DataALL;
        sampleRate = systemValues.sampleRate;
    end
    startVal = str2double(uiObjects.startChopEdit.String);
    endVal = str2double(uiObjects.endChopEdit.String);
    if startVal < 0 || endVal < 0
        return
    end
    if isnan(startVal)
        if ~isempty(uiObjects.startChopEdit.String)
            return
        end
        startVal = -inf;
    end
    if isnan(endVal)
        if ~isempty(uiObjects.endChopEdit.String)
            return
        end
        endVal = inf;
    end
    if endVal <= startVal
        return
    end
    scale = str2double(uiObjects.scaleTermEdit.String);
    shift = str2double(uiObjects.shiftTermEdit.String);
    if isnan(scale) || isnan(shift)
        return
    end
    
    systemValues.co2DataALL = co2Data;
    
    % previously processed data does not include timing information, so the
    % data is plotted according to samples
    if get(uiObjects.deviceDropDown,'value') == 5
        time = [0:length(co2Data)-1];
    else
        time = [0:length(co2Data)-1]./sampleRate;
    end
    
    [~, mask] = find(time>=startVal & time<=endVal);
    time = time(mask);
    co2Data = (co2Data(mask).*scale)+shift;
    
    cla(uiObjects.a)
    
    plot(uiObjects.a,time,co2Data,'linewidth',2)
    title(systemValues.filePath)
    if get(uiObjects.deviceDropDown,'value') == 5
        xlabel('Time (samples)')
    else
        xlabel('Time (s)')
    end
    ylabel('CO2 (mmHg)')
    
    systemValues.sampleRate = sampleRate;
    systemValues.time = time;
    systemValues.co2Data = co2Data;
    
    bool = 1;

end

function [co2Data, sampleRate] = getCo2Data(file)
% Read co2Data from text file according to user's device specification.
% Also return sampleRate based on the device specification and possibly
% information in the text file.

    global uiObjects systemValues
    
    if uiObjects.deviceDropDown.Value == 2
        
        sampleRate = 100;
        fid = fopen(file,'r');
        data = textscan(fid,'%s%f','delimiter',',','headerlines',1);
        fclose(fid);
        zeroIdx = find(strcmp(data{1},'ZEROING'));
        data{1}(zeroIdx) = [];
        data{2}(zeroIdx) = [];
        co2Data = data{2};
        
    elseif uiObjects.deviceDropDown.Value == 3
        
        sampleRate = 48;
        fid = fopen(file,'r');
        data = textscan(fid,'%s','delimiter',newline);
        fclose(fid);
        text = data{1};
        vals = [];
        for i = 1:size(text,1)
            if text{i,1}(1) == 'c'
                vals(end+1) = str2double(text{i,1}(2:end));
            end
        end
        co2Data = vals';
        
    elseif uiObjects.deviceDropDown.Value == 4
        
        fid = fopen(file,'r');
        data = textscan(fid,'%s','delimiter',newline);
        fclose(fid);
        data = data{1};
        sampleRateLine = data{2};
        tempSampleRateVals = split(sampleRateLine,' ');
        if ~isequal(size(tempSampleRateVals),[2 1]) ||...
                ~strcmp(tempSampleRateVals{2},'msec/sample') ||...
                isnan(str2double(tempSampleRateVals{1}))
            error('Unexpected sampleRateLine behavior')
        end
        period = str2double(tempSampleRateVals{1})/1000;
        sampleRate = 1/period;
        
        numChannelsLine = data{3};
        tempNumChannelVals = split(numChannelsLine,' ');
        if ~isequal(size(tempNumChannelVals),[2 1]) ||...
                ~strcmp(tempNumChannelVals{2},'channels') ||...
                isnan(str2double(tempNumChannelVals{1}))
            error('Unexpected numChannelsLine behavior')
        end
        numChannels = str2double(tempNumChannelVals{1});
        
        startingLine = 6 + (2*numChannels);
        vals = zeros(length(startingLine:size(data,1)),1);
        for i = startingLine:size(data,1)
             dataTemp = split(data{i},sprintf('\t'));
             vals(i-startingLine+1) =...
                 str2double(dataTemp{systemValues.biopacChannel});
        end
        co2Data = vals;
        
    elseif uiObjects.deviceDropDown.Value == 5
        sampleRate = NaN;
        fid = fopen(file,'r');
        data = textscan(fid,'%f');
        fclose(fid);
        co2Data = data{1};
    else
        error('Impossible value for uiObjects.deviceDropDown.Value')
    end

end

function updateQuickChop()

    global uiObjects

    low = uiObjects.a.XLim(1);
    high = uiObjects.a.XLim(2);

    set(uiObjects.quickChop1,'min',low)
    set(uiObjects.quickChop1,'max',high)
    set(uiObjects.quickChop1,'value',low)

    set(uiObjects.quickChop2,'min',low)
    set(uiObjects.quickChop2,'max',high)
    set(uiObjects.quickChop2,'value',high)
    
    delete(uiObjects.plotQuickChop)

end

function updateExportEditString()

    global uiObjects systemValues

    if get(uiObjects.postfixBox,'value')
            set(uiObjects.exportEdit,'string',...
                [systemValues.pth filesep systemValues.nme...
                systemValues.postfixString '.txt'])
        else
            set(uiObjects.exportEdit,'string',[systemValues.pth filesep...
                systemValues.nme '.txt'])
    end
end
