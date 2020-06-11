function FrontEnd_SB()

% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all GUI stuff in one structure and all data stuff in another. As the app
% grows, we might consider making these objects rather than structures.

% built with the toolbox 'GUI Layout Toolbox' version 2.3.3.0 (10/2018).
% Newer version (2.3.4.) is available (02/2019)!

% Use of the uimulticollistbox function available here: https://se.mathworks.com/matlabcentral/fileexchange/42670-multi-column-listbox
% It has been modified to comply to MatLab2018a.

dbstop if error
open_Waiting_Window ;
builtversion =  '2.3.4' ;

IsExeFile = 0 ;
if ~IsExeFile
    CheckToolBox(builtversion) ;
end
%Check the internet connection
if ~isnetavl
    NoInternetConnection = 1;
end

data = createData();
gui = createInterface();

% Now update the GUI with the current data

createcontextmenu;
drawbuttons();
UserProfile(gui.Profile);
updateInterface();
redrawDemo();
LaunchFunction();
delete(guiwait.Figure) ;
set(gui.Window,'Visible','on');
enableDefaultInteractivity(gui.AxesMap)
% Explicitly call the demo display so that it gets included if we deploy
        
displayEndOfDemoMessage('')
    function LaunchFunction
        % Launch functions before the GUI gets displayed
       Eventdata.EventName = 'Action' ; 
       Enabletech(gui.PhotoVol,Eventdata)
       Enabletech(gui.WindTurbine,Eventdata)
       Enabletech(gui.FuelCell,Eventdata) 
    end
%-------------------------------------------------------------------------%
    function open_Waiting_Window
        guiwait.Figure = figure( ...
                                'Name', 'Smart house model - University of Oulu', ...
                                'NumberTitle', 'off', ...
                                'MenuBar', 'none', ...
                                'Toolbar', 'none', ...
                                'HandleVisibility', 'on',...
                                'Visible','off');
        mainLayout = uix.HBox( 'Parent', guiwait.Figure, 'Spacing', 3 );
        
        AxesFigure = axes(mainLayout,'Tag','AxesFigure');
        
        filename = 'Logo_UOulu.png';
        
        GetPath = mfilename('fullpath');
        ParentFolder = GetPath(1:max(strfind(GetPath,filesep)));
        
        var=strcat(ParentFolder,'Images',filesep,filename);
        ORI_IMG=imread(var);
        
        if ishandle( AxesFigure )
            delete( AxesFigure );
        end
        
        fig = figure( 'Visible', 'off' );
        AxesFigure = gca();
        set(AxesFigure,'Units','pixels','position',[0 0 4444 5876]);
        set(AxesFigure,'Units','pixels');
        
        resizePos = get(AxesFigure,'Position');
        ORI_IMG = imresize(ORI_IMG, [resizePos(4) resizePos(3)]);
        imshow(ORI_IMG);
        
        cmap = colormap( AxesFigure );
        set( AxesFigure, 'Parent', mainLayout );
        
        set(AxesFigure,'Units','normalized','position',[0 0 1 1]);
        
        colormap( AxesFigure, cmap );
        
%         axis(gui.AxesFigure);
        close( fig );
        
        str = [char(169),' University of Oulu, 2019'] ;
        
        position = [0.1 0.5 0.3 0.3];
        axes('Position', position,...
                 'Visible',  'off',...
                 'Parent',   mainLayout);
        text(0,0.5,str,'Units','Normalized')
        
        set(mainLayout,'Widths',[-1 -1])
        
        % Set the size of the figure
        Pos = guiwait.Figure.Position ;
        Pos(3) = Pos(3) / 2 ; % Width
        Pos(4) = Pos(4) / 2.5 ; % Height
        guiwait.Figure.Position = Pos ;
        
        scrsz = get(groot,'ScreenSize');
        WLeft = scrsz(3) / 2 - Pos(3) / 2 ; % Half the window
        WHeight = scrsz(4) / 2 - Pos(4) / 2 ; % Half the window
        
        set(guiwait.Figure,'Position',[WLeft WHeight Pos(3) Pos(4)]) ;
        pause(.2);
        set(guiwait.Figure,'Visible', 'on') ;
        undecorateFig(guiwait.Figure);
        pause(.2);
    end %open_Waiting_Window
%-------------------------------------------------------------------------%
    function data = createData()
        % Create the shared data-structure for this application
        PanelList = {
            'Time setting'               'datesetting'      'Select simulation time'
            'Electricity contract'       'ElecCont'         'Select electricity contract'
            'User type'                  'UserType'         'Select User type'
            'House details'              'Housedetail'      'Set house details'
            'Control options'            'ContOpt'          'Select control options'
            'Small-scale production'     'ssprod'           'Select small-scale production'
            'Thermal characteristics'    'thermchar'        'Set thermal characteristics'
            };
        [varname] = variable_names;
        
        if verLessThan('matlab','9.5')
            % -- Code to run in MATLAB R2018a and earlier here --
            ToolTipString = 'TooltipString' ;
        else
            % -- Code to run in MATLAB R2018b and later here --
            ToolTipString = 'TooltipString' ; % Normally 'Tooltip' but it does not seem to work
        end
        
        
        TipToolLength = 10 ; % this is expressed in cm. It is used to defined how many lines are needed to fit the tip text
        
        PriceList = varname.ContElec.Comparefield{1};
        PriceList(2:end+1,:) = PriceList(1:end,:);
        PriceList(1,:) = {'Select...'};
        
        PriceTime = varname.Contract.Comparefield{1};
        PriceTime(2:end+1,:) = PriceTime(1:end,:);
        PriceTime(1,:) = {'Select...'};
        
        UserProfile = varname.Profile.Comparefield{2};
        UserProfile(2:end+1,:) = UserProfile(1:end,:);
        UserProfile(1,:) = {'Select...'};
        
        MeterSys = varname.Metering.Comparefield{2};
        MeterSys(2:end+1,:) = MeterSys(1:end,:);
        MeterSys(1,:) = {'Select...'};
        
        Rating = varname.clWashMach.Comparefield{1};
        Rating(2:end+1,:) = Rating(1:end,:);
        Rating(1,:) = {'Select...'};
        
        SimulationTimeFrame_Var = {'Select...'
                                   'TRY2012'
                                   'TRY2050'};
                               
        coordsDefault = [25.456 25.480 65.051 65.064];
        
        PV_Variable = {'Select...'
                       'NbrmodTot'
                       'Nbrmodser'
                       'Nbrmodpar'
                       'Aspect'
                       'Tilt'
                       'Voc'
                       'Isc'
                       'MaxPowerPV'
                       'LengthPV'
                       'WidthPV'
                       'NOCT'
                       'VTempCoff'};  
        wind_Variable = {'Select...'
                       'WTPowertot'
                       'WindSpeed'
                       'Lambdanom'
                       'Cp'
                       'MaxPowerWT'
                       'Baserotspeed'
                       'Pitch'
                       'EfficiencyWT'};
        FC_Variable = {'Select...'
                       'MaxPowerFC'
                       };
        BD_Variable = {'Select...'
                       'Building_Area'
                       'hgt'
                       'lgts'
                       'lgte'
                       'pitchangle'
                       'aws'
                       'awe'
                       'awn'
                       'aww'
                       'ad'
                       };
        TP_Variable = {'Select...'
                       'uvs'
                       'uve'
                       'uvn'
                       'uvw'
                       'uvsw'
                       'uvew'
                       'uvnw'
                       'uvww'
                       'uvd'
                       'uvf'
                       'uvr'
                       'n50'
                       'gwindow'
                       };
                   
        Ventil_Variable = {'Select...'
                           'N0'
                           'Heat_recovery_ventil_annual'
                           'vent_elec'
                           } ;
                       
        Heating_Variable = {'Select...'
                            'Temp_Set'
                            'NbrBatteries'
                            'prcntage'
                            'Building_storage_constant'
                            'Temp_cooling'
                            'PVprice'
                            'BatteryPrice'
                            'BatteryCapacity'
                            'ProfitBattery'
                            'RoundTripEfficiency'
                            'BatteryEmissions'
                            'PVEmissions'
                            'ChargingHours'
                            'T_inlet'
                            } ;
                   
        BD_dimensions = {'Default'
                         'Define'} ;
                     
        Heating_dimensions = {'Default'
                              'Define'
                              'Database'
                              };
                     
        Var2Change = {'PV_Variable'         'Spec2DefinePV'
                      'wind_Variable'       'Spec2DefineWind'
                      'FC_Variable'         'Spec2DefineFC'
                      'Ventil_Variable'     'Spec2DefineVentVar'
                      'TP_Variable'         'Spec2DefineTPVar'
                      'BD_Variable'         'Spec2DefineBDVar'
                      'Heating_Variable'    'Spec2DefineHeatingVar'
                      } ;
                       %   
        FC_Power = varname.MaxPowerFC.Comparefield{2};
        FC_Power(2:end+1,:) = FC_Power(1:end,:);
        FC_Power(1,:) = {'Select...'};
        
        Lightopt = varname.clLight.Comparefield{2};
        Lightopt(2:end+1,:) = Lightopt(1:end,:);
        Lightopt(1,:) = {'Select...'};
        
        nbrInhabitant = varname.inhabitants.Comparefield{2};
        nbrInhabitant(2:end+1,:) = nbrInhabitant(1:end,:);
        nbrInhabitant(1,:) = {'Select...'};
        
        AppliancesList = {
            'Washing machine';'Dish washer';'Hobs';'Kettle';'Electric Oven';...
            'Coffee maker';'Microwave';'Toaster';'Waffle';'Fridge';'Television';...
            'Laptop';'Shaver';'Hair dryer';'Stereo';'Vacuum cleaner';'Telephone charger';...
            'Iron';'Electric heater';'Sauna';'Radio';'Lighting System'
            };
        AppliancesList(:,2)={'Rate';'Rate';'None';'Rate';'Rate';'Rate';'Rate';'Rate';...
                             'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';...
                             'Rate';'None';'None';'Rate';'Rate'
                             };
        AppliancesList(:,3)={'WashMach';'DishWash';'Elec';'Kettle';'Oven';'Coffee';'MW';'Toas';...
                             'Waff';'Fridge';'Tele';'Laptop';'Shaver';'Hair';'Stereo';'Vacuum';'Charger';...
                             'Iron';'Elecheat';'Sauna';'Radio';''
                             };
        AppliancesList(:,4)={'clWashMach';'clDishWash';'';'clKettle';'clOven';'clCoffee';'clMW';'clToas';...
                             'clWaff';'clFridge';'clTele';'clLaptop';'clShaver';'clHair';'clStereo';'clVacuum';'clCharger';...
                             'clIron';'';'';'clRadio';'clLight'
                             };
        ApplianceMax       = {'Washing machine' 1 1 1 1 1 1
                            'Dish washer'     1 1 1 1 1 1
                            'Hobs'            1 1 1 1 1 1
                            'Kettle'          1 1 1 1 1 1 
                            'Electric Oven'   1 1 1 1 1 1
                            'Coffee maker'    1 1 1 1 1 1
                            'Microwave'       1 1 1 1 1 1
                            'Toaster'         1 1 1 1 1 2
                            'Waffle'          1 1 1 1 1 1
                            'Fridge'          1 1 1 1 1 1
                            'Television'      1 1 1 2 2 3
                            'Laptop'          1 2 4 5 6 7
                            'Shaver'          1 1 1 2 2 3
                            'Hair dryer'      1 1 1 2 2 2
                            'Stereo'          1 2 2 2 3 4
                            'Vacuum cleaner'  1 1 1 1 1 1
                            'Telephone charger' 2 4 5 6 8 10
                            'Iron'              1 1 1 1 1 1
                            'Electric heater'   1 1 1 1 1 1
                            'Sauna'             1 1 1 1 1 1
                            'Radio'             1 1 2 3 4 5 
                            'Lighting System'   1 1 1 1 1 1               
        } ;
        
        LanguagesAll = Languages ;
        if ismac
            MachineInfo.name = getenv('USER') ;
        else
            MachineInfo = whoami;
        end
        
        Lang2display = LanguagesAll.LanguagesRegional ;
        FileFormat = {'pdf' 'html' 'docx'} ;
        VarReport.Author.Name = MachineInfo.name    ;
            VarReport.Author.Type = 'edit'              ;
            VarReport.Author.Button = 'off'             ;
            VarReport.Author.ButtonName = ''             ;
            VarReport.Author.NameDefault = MachineInfo.name             ;
        VarReport.Publisher.Name = ''    ;
            VarReport.Publisher.Type = 'edit'              ;
            VarReport.Publisher.Button = 'off'             ;
            VarReport.Publisher.ButtonName = ''             ;
            VarReport.Publisher.NameDefault = 'No Institution'             ;
        VarReport.Title.Name = 'House Details'    ;
            VarReport.Title.Type = 'edit'              ;
            VarReport.Title.Button = 'off'             ;
            VarReport.Title.ButtonName = ''             ;
            VarReport.Title.NameDefault = 'House Details'             ;
         VarReport.Subtitle.Name = ''    ;
            VarReport.Subtitle.Type = 'edit'              ;
            VarReport.Subtitle.Button = 'off'             ;
            VarReport.Subtitle.ButtonName = ''             ;   
            VarReport.Subtitle.NameDefault = ''             ;
         VarReport.Logo.Name = ''    ;
            VarReport.Logo.Type = 'edit'              ;
            VarReport.Logo.Button = 'on'             ;
            VarReport.Logo.ButtonName = '...'             ;    
            VarReport.Logo.NameDefault = ''             ;
         VarReport.Language.Name = Lang2display    ;
            VarReport.Language.Type = 'popup'              ;
            VarReport.Language.Button = 'off'             ;
            VarReport.Language.ButtonName = ''             ;
            VarReport.Language.NameDefault = 'en'             ;
         VarReport.FileFormat.Name = FileFormat    ;
            VarReport.FileFormat.Type = 'popup'              ;
            VarReport.FileFormat.Button = 'off'             ;
            VarReport.FileFormat.ButtonName = ''             ; 
            VarReport.FileFormat.NameDefault = 'pdf'             ;
        VarReport.DisplayDef.Name = ''    ;
            VarReport.DisplayDef.Type = 'checkbox'              ;
            VarReport.DisplayDef.Button = 'off'             ;
            VarReport.DisplayDef.ButtonName = 'On/Off'             ; 
            VarReport.DisplayDef.NameDefault = '0'             ;
            VarReport.DisplayDef.ToolTip = 'Tick the box if you want to display only the user defined input in the house. In this case, all the default values will not be reported'             ;
    
        fontlist = {8 9 10 11 12 14 16 18 20 22 24 26 28 36 48 72} ;    
        FontName = 'MS Reference Sans Serif' ;
        
        SummaryStructure = struct ;
        savedname = '' ;     
        Filter = {};
        Filtermode = 0 ;
        [Nbr_Building,~] = HouseType;
        Originalarray = {} ;
        %%% Set the headers
        % Set the house number and then the 
        % Set the output format for the date
        formatOut = 'dd/mm/yy';
        str{Nbr_Building,3} = [] ;
        for i=1:Nbr_Building
            str{i,1} = strcat('House ',num2str(i));
            str{i,2} = datestr(now,formatOut);
            str{i,3} = datestr(now,formatOut);
        end
        HouseStr{size(str,1)} = [] ;    
        for i = 1:size(str,1)
            HouseStr{i} = {};
        end
        
        selectedDemo = 1;
        data = struct( ...
            'PanelListFullName', {PanelList(:,1)'}, ...
            'PanelListabbreviation', {PanelList(:,2)'}, ...
            'PanelListTitle', {PanelList(:,3)'}, ...
            'SelectedDemo', selectedDemo ,...
            'HouseList',{HouseStr}, ...
            'PriceList',{PriceList},...
            'PriceTime',{PriceTime},...
            'UserProfile',{UserProfile},...
            'MeterSys',{MeterSys},...
            'AppliancesList',{AppliancesList},...
            'savedname',savedname,...
            'nbrInhabitant',{nbrInhabitant},...
            'Rating',{Rating},...
            'Lightopt',{Lightopt},...
            'Filter',{Filter},...
            'Filtermode',Filtermode,...
            'PV_Variable',{PV_Variable},...
            'wind_Variable',{wind_Variable},...
            'FC_Variable',{FC_Variable},...
            'FC_Power',{FC_Power},...
            'Originalarray',{Originalarray},...
            'datastructure',varname,...
            'ApplianceMax',{ApplianceMax},...
            'varname',{varname},...
            'varlongname',{0},...
            'TipToolLength',{TipToolLength},...
            'ToolTipString',{ToolTipString},...
            'BD_Variable',{BD_Variable},...
            'Var2Change',{Var2Change},...
            'BD_dimensions',{BD_dimensions},...
            'Heating_dimensions',{Heating_dimensions},...
            'fontlist',{fontlist},...
            'FontName',{FontName},...
            'LanguagesAll',{LanguagesAll},...
            'VarReport',{VarReport},...
            'TP_Variable',{TP_Variable},...
            'Ventil_Variable',{Ventil_Variable},...
            'Heating_Variable',{Heating_Variable},...
            'SummaryStructure',SummaryStructure,...
            'SimulationTimeFrame_Var',{SimulationTimeFrame_Var},...
            'coordsDefault',{coordsDefault});
     end % createData

function gui = createInterface()
        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();
        % Open a window and add some menus
        gui.Window = figure( ...
            'Name', 'Smart house model - University of Oulu', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off',...
            'Visible','off');
        set(gui.Window,'Position',[gui.Window.Position(1) gui.Window.Position(2) 950 600]);

        movegui(gui.Window,'center')
        
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'New', 'Callback', @File ,'Separator','on');
        uimenu( gui.FileMenu, 'Label', 'Import...','Callback', @File ,'Accelerator','I');
        uimenu( gui.FileMenu, 'Label', 'Save all', 'Callback', @File,'Separator','on' ,'Accelerator','S');
        uimenu( gui.FileMenu, 'Label', 'Save file as...','Separator','on' , 'Callback', @File);
        uimenu( gui.FileMenu, 'Label', 'Save selected as...', 'Callback', @File );
        uimenu( gui.FileMenu, 'Label', 'Save each house individually', 'Callback', @File );
        uimenu( gui.FileMenu, 'Label', 'Import Saved Databases', 'MenuSelectedFcn', @SaveDatabase, 'Tag', 'Database', 'Accelerator', 'B', 'Separator', 'on'); % JARI
        uimenu( gui.FileMenu, 'Label', 'Save Database selections', 'MenuSelectedFcn', @SaveDatabase, 'Tag', 'SaveDatabase', 'Accelerator', 'N') ;                   % JARI
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @File,'Separator','on', 'Accelerator','Q' );
        
        
        % + Edit menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'Edit' );
        uimenu( gui.FileMenu, 'Label', 'Add', 'Callback', @onEdit,'Accelerator','A');
        uimenu( gui.FileMenu, 'Label', 'Copy', 'Callback', @onEdit);
        uimenu( gui.FileMenu, 'Label', 'Delete', 'Callback', @onEdit);
        uimenu( gui.FileMenu, 'Label', 'Import', 'Callback', @onEdit);
        
        % + View menu
        gui.ViewMenu = uimenu( gui.Window, 'Label', 'View' );
        displayssubmenu = uimenu( gui.ViewMenu, 'Label', 'Display');
            gui.DisplayUT = uimenu( displayssubmenu, 'Label', 'User types', 'Callback', @onDisplay,'Checked','off');
        uimenu( gui.ViewMenu, 'Label', 'Filter...','Callback', @onDisplay);
        uimenu( gui.ViewMenu, 'Label', 'Reset Filter','Callback', @onDisplay);
        gui.DisplayVarName = uimenu( gui.ViewMenu, 'Label', 'Use variable long name','Callback', @onDisplay,'Checked','off');
        uimenu( gui.ViewMenu, 'Label', 'Report','Callback', @onDisplay);
        uimenu( gui.ViewMenu, 'Label', 'Delete all waiting bars','Callback', @onDisplay,'Separator','on');
        uimenu( gui.ViewMenu, 'Label', 'View map','Callback', @onDisplay,'Separator','on');
        uimenu( gui.ViewMenu, 'Label', 'View houses list','Callback', @onDisplay);
        
        % + Simulation menu
        helpMenu = uimenu( gui.Window, 'Label', 'Simulation' );
        uimenu( helpMenu, 'Label', 'Run', 'Callback', @onRun );
        uimenu( helpMenu, 'Label', 'Run Selected', 'Callback', @onRun )
        
        % + Tools menu
        helpMenu = uimenu( gui.Window, 'Label', 'Tools' );
        uimenu( helpMenu, 'Label', 'Preferences', 'Callback', @onTools );
        
        % + Help menu
        helpMenu = uimenu( gui.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        uimenu( helpMenu, 'Label', 'Contacts', 'Callback', @onHelp );
        uimenu( helpMenu, 'Label', 'Feedbacks...', 'Callback', @onHelp );
        uimenu( helpMenu, 'Label', 'Check for update', 'Callback', @Checkforupdate ,'Separator','on');
        % Screen size of the computer on which this code is run
        ScreenSize = get(0,'ScreenSize') ;
        Ratio2Apply = 0.8 ;
        
        if verLessThan('matlab','7.6')
            % -- Code to run in MATLAB R2007b and earlier here --
            gui.Handle_Graphics = 'fFigureClient' ;
        elseif verLessThan('matlab','8.4')
            % -- Code to run in MATLAB R2014a and earlier here --
            gui.Handle_Graphics = 'fHG1Client' ;
        else
            % -- Code to run in MATLAB R2014b and later here --
            gui.Handle_Graphics = 'fHG2Client' ;
        end
        
        jFrame = get(gui.Window,'JavaFrame');
        jMenuBar = jFrame.(gui.Handle_Graphics).getMenuBar;
        pause(.1)
        jFileMenu = jMenuBar.getComponent(0);
        jFileMenu.doClick; % open the File menu
        jFileMenu.doClick; % close the menu
        pause(.1)
        
%         y = getjframe(gui.Window) ; % Does not work from MatLab 2018b....

        Path = mfilename('fullpath') ;
        folder = dbstack ;
        filename = folder.file ;
        filename_noext = erase(filename,'.m') ;
        filePath = erase(Path,filename_noext) ;
        
        s = strcat(filePath,'Images',filesep,'LogosSaveAll.png');
        if exist(s, 'file') == 2
            % The file exist at that location
            setIconMenu(jMenuBar, 'Save all' ,s);
            % If not then do not put any logo
        else
            warning('Logo Save All not located under ...\Images\') ;
        end
        
        s = strcat(filePath,'Images',filesep,'LogosPreferences.png');
        if exist(s, 'file') == 2
            % The file exist at that location
            setIconMenu(jMenuBar, 'Preferences' ,s);
            % If not then do not put any logo
        else
            warning('Logo Preferences not located under ...\Images\') ;
        end
        
        %%%%
        % TO ADD
        % gui.DisplayVarName = uimenu( gui.ViewMenu, 'Label', 'Use variable long name','Callback', @onDisplay,'Checked','off');
        %%%%%
        
        % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );
        
        % + Create the panels
        % + Panel Control
        controlPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Specifications:' );
        ViewingPanel = uix.VBox( ...
            'Parent', mainLayout) ;
        EditPanel = uix.VBox( ...
            'Parent', mainLayout);
        
        gui.SelSetting = uipanel(...
            'Parent',EditPanel) ;
        gui.SettingOpt = uix.BoxPanel( ...
            'Parent', EditPanel, ...
            'Title', 'Settings','HelpFcn', @onPanelHelp );
        gui.p = uix.CardPanel( 'Parent', gui.SettingOpt, 'Padding', 5 );

        for i = 1:numel(data.PanelListFullName)
            Panelname = strcat('Panel',data.PanelListabbreviation{i}) ;
            PanelTitle = data.PanelListTitle{i} ;
            gui.(Panelname) = uix.Panel('Parent',gui.p, 'Title', PanelTitle,'Tag',Panelname) ;                
        end
        
        gui.ViewPanel = uix.BoxPanel( ...
            'Parent', ViewingPanel, ...
            'Title', 'Viewing: ...');
        
        gui.ViewPanel1 = uix.CardPanel( ...
            'Parent', gui.ViewPanel);
        
            %%% Draw the house panel
        gui.HouseList = uix.Panel('Parent',gui.ViewPanel1,'Tag','ScrollPanelView') ;
        
        gui.ScrollPanelView = uix.ScrollingPanel('Parent', gui.HouseList);
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ScrollPanelView );        
        
        gui.Housedrawing = uix.Grid( 'Parent', gui.ViewContainer, 'Spacing', 5,'visible','on' ) ;    
        
            %%% Draw the Map panel
        gui.MapPanel = uix.VBox('Parent',gui.ViewPanel1,'Tag','MapPanel') ;
            %%% Create Map Panel header for searching places, change the
            %%% layout, or modify the resolution
            gui.MapHeader = uix.HBox('Parent',gui.MapPanel, 'Spacing', 5) ;
                gui.MapPlaces = uicontrol('Parent',gui.MapHeader,'Style','edit',...
                                                                 'string','University of Oulu') ;
                    MapResolutionList = {0 -1 -2 -3 -4};
                gui.MapResolution = uicontrol('Parent',gui.MapHeader,'Style','popup',...
                                                                 'String',MapResolutionList) ;
                    MapLayoutList = {'osm', 'hot', 'ocm', 'opm','landscape','outdoors'} ;
                gui.MapLayout = uicontrol('Parent',gui.MapHeader,'Style','popup',...
                                                                 'String',MapLayoutList) ;
            gui.MapUpdater = uix.HBox('Parent',gui.MapPanel, 'Spacing', 5) ;
                gui.MapUpdaterLocation = uicontrol('Parent',gui.MapUpdater,'Style','pushbutton',...
                                                                       'String','Update Location',...
                                                                       'callback',@MapSearch,...
                                                                       'tag','MapUpdaterLocation') ;
                gui.MapUpdaterResolution = uicontrol('Parent',gui.MapUpdater,'Style','pushbutton',...
                                                                       'String','Update Resolution',...
                                                                       'callback',@MapSearch,...
                                                                       'tag','MapUpdaterResolution') ;
                gui.MapUpdaterLayout = uicontrol('Parent',gui.MapUpdater,'Style','pushbutton',...
                                                                       'String','Update Layout',...
                                                                       'callback',@MapSearch,...
                                                                       'tag','MapUpdaterLayout') ;
                gui.MapUpdaterAll = uicontrol('Parent',gui.MapUpdater,'Style','pushbutton',...
                                                                       'String','Update All',...
                                                                       'callback',@MapSearch,...
                                                                       'tag','MapUpdaterAll',...
                                                                       'Backgroundcolor','w') ;
                                                                   
                figMap = figure( 'Visible', 'on' );
                
%                 set(figMap,'WindowButtonDownFcn',@clickcallback)
                zoom on
                
                gui.AxesMap = gca();
                enableDefaultInteractivity(gui.AxesMap)
                
                
                set(gui.AxesMap,'Units','normalized','position',[0 0 1 1]);
                set(gui.AxesMap,'Units','pixels');
                
%                 gui.AxesFigure = axes(gui.MainPanelUsertypes,'Tag','AxesFigure');
                
                cmap = colormap( gui.AxesMap );
                set( gui.AxesMap, 'Parent', gui.MapPanel  );
                
                Map(data.coordsDefault, [], gui.AxesMap, -2);
                
                set(gui.AxesMap,'Units','normalized',...
                                'position',[0 0 1 1],...
                                'PlotBoxAspectRatio',[1 0.95 1],...
                                'OuterPosition',[0 0 1 1]);
                            
                colormap( gui.AxesMap, cmap );    
                
                % Enable zoom and span of the axes
                
                enableDefaultInteractivity(gui.AxesMap) ;
        %         axis(gui.AxesFigure);
                close( figMap );
        
        % + Adjust the main layout
        set( gui.MapPanel,'Heights',[23 23 -1])    ;
        set( mainLayout, 'Widths', [-1,-2,-1]  );
        set( ViewingPanel, 'Heights', -1  ); %50 , -1
        set( EditPanel, 'Heights', [45,-1]  );
        
        % + Create the controls
        controlLayout = uix.VBox( 'Parent', controlPanel, ...
            'Padding', 3, 'Spacing', 3 ,'Tag','controlLayout');
        
        gui.HouseSel = uix.BoxPanel( ...
            'Parent', controlLayout, ...
            'Title', 'House Selection', ...
            'HelpFcn', @onPanelHelp );
        gui.HouseContainer = uicontainer( ...
            'Parent', gui.HouseSel );
        
        gui.ListBox = uicontrol( 'Style', 'list', ...
            'BackgroundColor', 'w', ...
            'Parent', controlLayout, ...
            'String', {}, ...
            'Value', 1, ...
            'Max',2,...
            'Tag','ListBox',...
            'Min',0,...
            'Callback', @onListSelection);
        
        set( controlLayout, 'Heights', [50 -1] ); % Make the list fill the space

        % + Create the House selection view
        selectionbox1 = uix.HBox( 'Parent', gui.HouseContainer ) ;
        
        gui.checkboxDS = uicontrol('Parent', selectionbox1,'Style', 'checkbox',...
                       'Tag','checkboxDS',...
                       'Position',[0.5 0 1 1],...
                       'String','Use the same data for each house',...
                       'Callback', @checkboxDS_Callback,...
                       'backgroundcolor',get(selectionbox1,'backgroundcolor'));                    

        set( selectionbox1, 'Widths', -1 );
        
        % + Create button interface
        gui.Buttonmenu = uix.HBox( 'Parent', gui.SelSetting,'Padding',3 ,'Spacing',2,...
            'Backgroundcolor',[1 1 1], 'Tag','cbutton') ;
        
        Butttonwidth = 30 ;
        
        ButtonSpaceNeeded = numel(data.PanelListFullName)*(Butttonwidth+gui.Buttonmenu.Spacing)...
                            - gui.Buttonmenu.Spacing + 3 * gui.Buttonmenu.Padding ;
        cbuttwidth(1:numel(data.PanelListFullName)) = Butttonwidth ;
        
        % Data Setting Button menu
        for i = 1:numel(data.PanelListFullName)
            Buttonname = strcat('cbutt',data.PanelListabbreviation{i}) ;
            ButtonTip = data.PanelListTitle{i} ;
            gui.(Buttonname) = uicontrol( 'Parent', gui.Buttonmenu,...
                                'Style','pushbutton',...
                                'Tag',Buttonname,...
                                'Callback', @Butt1action_Callback,...
                                'ButtonDownFcn', @rightclickbutton,...
                                'Tooltip',ButtonTip,...
                                'Backgroundcolor',[1 1 1]);              
        end
        
        set( gui.Buttonmenu, 'Widths', cbuttwidth) ;
        set( mainLayout, 'MinimumWidths', [100,100,ButtonSpaceNeeded]  );        
        % + Create the interface for Settings
        
        Maindate = uix.VBox( 'Parent', gui.Paneldatesetting, 'Spacing', 3 );% Jari's change %Maindate = uix.HBox( 'Parent', gui.Paneldatesetting, 'Spacing', 5 );
        
        selectionbox = uix.VBox( 'Parent', Maindate ) ;

        Startdatebox  = uix.HBox( 'Parent', selectionbox ) ;
        EndDatebox    = uix.HBox( 'Parent', selectionbox ) ;

        formatOut = 'dd/mm/yyyy';
        uicontrol('Parent',Startdatebox,'Style','Text',...
                                        'String','Starting Date')
        [~,Tip] = createStrToolTip(data.datastructure.StartingDate.Tooltip,...
                                   data.datastructure.StartingDate.LongName) ;
                               
        gui.StartingDate = uicontrol(Startdatebox,'Style', 'edit',...
                                                  'String',datestr(now,formatOut),...
                                                  'Tag','StartingDate',...
                                                  'backgroundcolor',get(Startdatebox,'backgroundcolor'),...
                                                  data.ToolTipString,Tip,...
                                                  'Callback', @Date_Callback);
                   
        uicontrol('Parent',Startdatebox,...
                  'Style','PushButton',...
                  'String','Calendar',...
                  'Tag','StartingDate_button',...
                  'Callback', @Date_Callback)

        uicontrol('Parent',EndDatebox,...
                  'Style','Text',...
                  'String','Ending Date')
              
        [~,Tip] = createStrToolTip(data.datastructure.EndingDate.Tooltip,...
                                   data.datastructure.EndingDate.LongName) ;
        gui.EndingDate = uicontrol(EndDatebox,'Style', 'edit',...
                                              'String',datestr(now,formatOut),...
                                              'Tag','EndingDate',...
                                              'backgroundcolor',get(EndDatebox,'backgroundcolor'),...
                                              data.ToolTipString,Tip,...
                                              'Callback', @Date_Callback);
                   
        uicontrol('Parent',EndDatebox,...
                  'Style','PushButton',...
                  'String','Calendar',...
                  'Tag','EndingDate_button',...
                  'Callback', @Date_Callback)
              
              % JARI'S ADDITION
              
        gui.FileAdditionMain = uix.VBox('Parent', Maindate, 'Spacing', 3);
        gui.FileAdditionPanel = uipanel('Parent', gui.FileAdditionMain, 'Title', 'File Addition'); %, 'Spacing', 5);
        gui.FileAddition = uix.VBox('Parent', gui.FileAdditionPanel); %, 'Title', 'File Addition'); % Maindate); %, 'Title', 'Add your own files');
        gui.TemperatureBox = uix.VBox('Parent', gui.FileAddition);
        gui.ChangeTemperature = uicontrol('Parent', gui.TemperatureBox, ...
                                            'Style', 'text', ...
                                            'String', 'Temperature file...', ...
                                            'Tag', 'ChangeTemperature');
                                        
        gui.TemperatureMain = uix.VBox('Parent', gui.TemperatureBox);
            gui.TemperatureDir      = uix.VBox('Parent', gui.TemperatureMain);
                gui.TemperatureFile     = uicontrol('Parent', gui.TemperatureDir, ...
                                            'String', 'Select Temperature file...', ...
                                            'Style', 'edit',...
                                            'enable', 'off',...
                                            'Tag', 'TemperatureFile');
            gui.TemperatureButtons      = uix.HBox('Parent', gui.TemperatureMain);
                gui.TemperatureAddition = uicontrol('Parent', gui.TemperatureButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Add', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Temperature');
                gui.TemperatureRemoval = uicontrol('Parent', gui.TemperatureButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Remove', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Temperature');
                                        
        gui.RadiationBox = uix.VBox('Parent', gui.FileAddition);
                                        
        gui.ChangeRadiation = uicontrol('Parent', gui.RadiationBox, ...
                                            'Style', 'text', ...
                                            'String', 'Radiation file...', ...
                                            'Tag', 'ChangeRadiation');
                                        
        gui.RadiationMain = uix.VBox('Parent', gui.RadiationBox);
            gui.RadiationDir      = uix.VBox('Parent', gui.RadiationMain);
                gui.RadiationFile     = uicontrol('Parent', gui.RadiationDir, ...
                                            'Style', 'edit', ...
                                            'String', 'Select Radiation file...', ...
                                            'enable', 'off',...
                                            'Tag', 'RadiationFile');
            gui.RadiationButtons      = uix.HBox('Parent', gui.RadiationMain);
                gui.RadiationAddition = uicontrol('Parent', gui.RadiationButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Add', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Radiation');
                gui.RadiationRemoval = uicontrol('Parent', gui.RadiationButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Remove', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Radiation');
                                        
        gui.PriceBox = uix.VBox('Parent', gui.FileAddition);
                                        
        gui.ChangePrice = uicontrol('Parent', gui.PriceBox, ...
                                            'Style', 'text', ...
                                            'String', 'Price file...', ...
                                            'Tag', 'ChangePrice');
                                        
        gui.PriceMain = uix.VBox('Parent', gui.PriceBox);
            gui.PriceDir      = uix.VBox('Parent', gui.PriceMain);
                gui.PriceFile     = uicontrol('Parent', gui.PriceDir, ...
                                            'Style', 'edit', ...
                                            'String', 'Select Price file...', ...
                                            'enable', 'off',...
                                            'Tag', 'PriceFile');
            gui.PriceButtons      = uix.HBox('Parent', gui.PriceMain);
                gui.PriceAddition = uicontrol('Parent', gui.PriceButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Add', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Price');
                gui.PriceRemoval = uicontrol('Parent', gui.PriceButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Remove', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Price');
                                        
        gui.EmissionBox = uix.VBox('Parent', gui.FileAddition);
                                        
        gui.ChangeEmission = uicontrol('Parent', gui.EmissionBox, ...
                                            'Style', 'text', ...
                                            'String', 'Emission file...', ...
                                            'Tag', 'ChangeEmission');
                                        
        gui.EmissionMain = uix.VBox('Parent', gui.EmissionBox);
            gui.EmissionDir      = uix.VBox('Parent', gui.EmissionMain);
                gui.EmissionFile     = uicontrol('Parent', gui.EmissionDir, ...
                                            'Style', 'edit', ...
                                            'String', 'Select Emission file...', ...
                                            'enable', 'off',...
                                            'Tag', 'EmissionFile');
            gui.EmissionButtons      = uix.HBox('Parent', gui.EmissionMain);
                gui.EmissionAddition = uicontrol('Parent', gui.EmissionButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Add', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Emission');
                gui.EmissionRemoval = uicontrol('Parent', gui.EmissionButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Remove', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'Emission');
                                        
        gui.DataSetStartsMain = uix.VBox('Parent', Maindate, 'Spacing', 3);
                                        
        gui.DataSetStartsPanel = uix.Panel('Parent', gui.DataSetStartsMain, 'Title', 'Database Start Years'); %, 'Spacing', 5);
                                        
        gui.DataSetStarts = uix.VBox('Parent', gui.DataSetStartsPanel, 'Spacing', 5); % Maindate, 'Spacing', 2);
        
%             gui.DataSetDefinition = uix.VBox('Parent', gui.DataSetStarts);
%             
%                 gui.DataSetDefinitionText = uicontrol('Parent', gui.DataSetDefinition, ...
%                                                     'Style', 'text', ...
%                                                     'String', 'Define the Start year of defined databases:');
                                        
            gui.DataSetStartsTemp = uix.VBox('Parent', gui.DataSetStarts);
        
                gui.StartOfDataSetTempText = uicontrol('Parent', gui.DataSetStartsTemp, ...
                                                    'Style', 'text',...
                                                    'String', 'Temperature and Radiation');
                                                
            gui.StartOfDataSetTemp = uix.HBox('Parent', gui.DataSetStarts);
        
                gui.StartYearTempRad = uicontrol('Parent', gui.StartOfDataSetTemp, ...
                                            'Style', 'edit', ...
                                            'String', '2000', ...
                                            'Tag', 'Temperature&Radiation');
                                        
                gui.StartYearDataSetButtonTemp = uicontrol('Parent', gui.StartOfDataSetTemp, ...
                                                    'Style', 'pushbutton', ...
                                                    'String', 'Add', ...
                                                    'callback', @DataSetStart, ...
                                                    'Tag', 'AdditionTemp&Rad');
                                                
            gui.DataSetStartsPrice = uix.VBox('Parent', gui.DataSetStarts);
            
                gui.StartOfDataSetPriceText = uicontrol('Parent', gui.DataSetStartsPrice, ...
                                                    'Style', 'text',...
                                                    'String', 'Electricity Price and Emissions:');
                                                
            gui.StartOfDataSetPrice = uix.HBox('Parent', gui.DataSetStarts);
        
                gui.StartYearPriceEmissions = uicontrol('Parent', gui.StartOfDataSetPrice, ...
                                            'Style', 'edit', ...
                                            'String', '2004', ...
                                            'Tag', 'Price&Emission');
                                        
                gui.StartYearDataSetButtonPrice = uicontrol('Parent', gui.StartOfDataSetPrice, ...
                                                    'Style', 'pushbutton', ...
                                                    'String', 'Add', ...
                                                    'callback', @DataSetStart, ...
                                                    'Tag', 'AdditionPrice&Emission');
                                                
            gui.SimulationTimeFrame = uix.VBox('Parent', gui.DataSetStarts);
            
                gui.SimulationTimeFrameBox = uix.VBox('Parent', gui.SimulationTimeFrame);
            
                    gui.SimulationTimeFrameText = uicontrol('Parent', gui.SimulationTimeFrameBox, ...
                                                            'Style', 'text',...
                                                            'String', 'Forecasting method'); % for forecasting global irradiance
                                                        
                gui.SimulationTimeFramePopUp = uix.VBox('Parent', gui.SimulationTimeFrame);
                                                    
                    gui.SimulationTimeFrameSelection = uicontrol('Parent', gui.SimulationTimeFramePopUp, ...
                                                        'Style', 'popup', ...
                                                        'String', data.SimulationTimeFrame_Var, ...
                                                        'Tag', 'SimulationTimeFrame', ...
                                                        'enable', 'on', ...
                                                        'callback', @SimulationTimeFrameSetting, ...
                                                        data.ToolTipString, Tip);
                                                    
                                        
        % END OF JARI'S ADDITION
        
        

        set(selectionbox, 'Heights', [25 25]);
        set(Maindate, 'Heights', [50 290 157]);  % JArI % 50 300 122
        set(gui.TemperatureBox, 'Heights', [15 50]);    % J
        set(gui.TemperatureMain, 'Height', [25 25]);    % J
        set(gui.RadiationBox, 'Heights', [15 50]);      % J
        set(gui.RadiationMain, 'Height', [25 25]);      % J
        set(gui.PriceBox, 'Heights', [15 50]);          % J
        set(gui.PriceMain, 'Height', [25 25]);          % J
        set(gui.EmissionBox, 'Heights', [15 50]);       % J
        set(gui.EmissionMain, 'Height', [25 25]);       % J
        set(gui.DataSetStarts, 'Height', [15 25 15 25 50]); %[15 15 25 15 25 45]); % J % 30 25 30 25
        set(gui.SimulationTimeFrame, 'Height', [15 30]); % J
%         set(gui.SimulationTimeFrame, 'Height', [-1 -1]);    % J
        set(gui.StartOfDataSetTemp, 'Widths', [-4 -1]);     % J
        set(gui.StartOfDataSetPrice, 'Widths', [-4 -1]);    % J
%         set(Maindate, 'Widths', [-1 -1]); %set(Maindate, 'Widths', -1);
        set(Startdatebox,'Widths',[-1 73 73]);
        set(EndDatebox,'Widths',[-1 73 73]);
        % + Create the interface for Contracts
        
        MainPanelContracts = uix.HBox('Parent',gui.PanelElecCont, 'Spacing', 5 ) ;       
            % Add the Contract
        Maincontract = uix.VBox('Parent',MainPanelContracts, 'Spacing', 5 ) ;
        [~,Tip] = createStrToolTip(data.datastructure.ContElec.Tooltip,...
                                   data.datastructure.ContElec.LongName) ;
        gui.ContElec = uicontrol('Parent', Maincontract,...
                                    'Style','popup',...
                                    'String',data.PriceList(:),...
                                    'Tag','ContElec',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
                                
            % Add the Alternative time use
        [~,Tip] = createStrToolTip(data.datastructure.Contract.Tooltip,...
                                   data.datastructure.Contract.LongName) ;    
        gui.Contract = uicontrol('Parent', Maincontract,...
                                    'Style','popup',...
                                    'String',data.PriceTime(:),...
                                    'Tag','Contract',...
                                    'enable','off',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
            % Add the price limitation
        [~,Tip] = createStrToolTip(data.datastructure.Low_Price.Tooltip,...
                                   data.datastructure.Low_Price.LongName) ;
        gui.Low_Price = uicontrol('Parent', Maincontract,...
                                    'Style','edit',...
                                    'String','-99999',...
                                    'Tag','Low_Price',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
        [~,Tip] = createStrToolTip(data.datastructure.High_Price.Tooltip,...
                                   data.datastructure.High_Price.LongName) ;
        gui.High_Price = uicontrol('Parent', Maincontract,...
                                    'Style','edit',...
                                    'String','99999',...
                                    'Tag','High_Price',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
                                
       set(MainPanelContracts,'Widths',-1)                    ;   
       set(Maincontract,'Heights',[20 20 20 20])              ; 
       
       % + Create the interface for the *User types*
       gui.MainPanelUsertypes = uix.VBox('Parent',gui.PanelUserType, 'Spacing', 5 ) ; 
       PanelUSerResponse = uix.VBox('Parent',gui.MainPanelUsertypes ) ; 
       
                    % Set the button group
       gui.User_Type = uibuttongroup(PanelUSerResponse,'Title','User Response',...
                              'Tag','User_Type');
            [~,Tip] = createStrToolTip(data.datastructure.User_Type.Tooltip,...
                                       data.datastructure.User_Type.LongName) ;
            gui.radiobuttonBrown = uicontrol(gui.User_Type,'Style', 'radiobutton',...
                                   'Tag','radiobuttonBrown',...
                                   'String','Brown User',...
                                   'Units','normalized',...
                                   'position',[0 0.75 1 0.2],...
                                   'Callback', @radiobutton_Callback,...
                                    data.ToolTipString,Tip);
            gui.radiobuttonOrange = uicontrol(gui.User_Type,'Style', 'radiobutton',...
                                   'Tag','radiobuttonOrange',...
                                   'String','Orange User',...
                                   'Units','normalized',...
                                   'position',[0 0.5 1 0.2],...
                                   'Callback', @radiobutton_Callback,...
                                    data.ToolTipString,Tip);
            gui.radiobuttonGreen = uicontrol(gui.User_Type,'Style', 'radiobutton',...
                                   'Tag','radiobuttonGreen',...
                                   'Units','normalized',...
                                   'position',[0 0.25 1 0.2],...
                                   'String','Green User',...
                                   'Callback', @radiobutton_Callback,... 
                                   data.ToolTipString,Tip) ;
                    % Set the User profile
            [~,Tip] = createStrToolTip(data.datastructure.Profile.Tooltip,...
                                       data.datastructure.Profile.LongName) ;     
        gui.Profile = uicontrol('Parent', gui.MainPanelUsertypes,...
                                    'Style','popup',...
                                    'String',data.UserProfile(:),...
                                    'Tag','Profile',...
                                    'Value',1,...
                                    'Callback',@UserProfile,... 
                                   data.ToolTipString,Tip) ;
        gui.AxesFigure = axes(gui.MainPanelUsertypes,'Tag','AxesFigure');
        %uix.Empty('Parent', gui.MainPanelUsertypes)  ;                   
                                
        set(gui.MainPanelUsertypes,'Heights',[100 -1 150]);
        
        % + Create the interface for the Control options
        MainPanelControl = uix.VBoxFlex('Parent',gui.PanelContOpt,'Spacing', 5 ) ;
        PanelMetering = uix.HBox('Parent',MainPanelControl) ;
        PanelControlOpt = uix.VBox('Parent',MainPanelControl) ;
        
        uicontrol('Parent',PanelMetering,...
                  'Style','text',...
                  'String','Metering system')
        [~,Tip] = createStrToolTip(data.datastructure.Metering.Tooltip,...
                                   data.datastructure.Metering.LongName) ;     
        gui.Metering = uicontrol('Parent',PanelMetering,...
                           'Style','popup',...
                           'String',data.MeterSys(:),...
                           'Tag','Metering',...
                           'Callback',@SaveEdit,... 
                           data.ToolTipString,Tip) ;
        [~,Tip] = createStrToolTip(data.datastructure.Self.Tooltip,...
                                   data.datastructure.Self.LongName) ;     
        gui.Self = uicontrol('Parent',PanelControlOpt,...
                           'Style','checkbox',...
                           'String','Self-consumption',...
                           'Tag','Self',...
                           'Callback',@ControlOpt,... 
                           data.ToolTipString,Tip) ;
        [~,Tip] = createStrToolTip(data.datastructure.Comp.Tooltip,...
                                   data.datastructure.Comp.LongName) ;     
        gui.Comp = uicontrol('Parent',PanelControlOpt,...
                           'Style','checkbox',...
                           'String','Share comparison',...
                           'Tag','Comp',...
                           'Callback',@ControlOpt,... 
                           data.ToolTipString,Tip) ;
        [~,Tip] = createStrToolTip(data.datastructure.Goal.Tooltip,...
                                   data.datastructure.Goal.LongName) ;     
        gui.Goal = uicontrol('Parent',PanelControlOpt,...
                           'Style','checkbox',...
                           'String','Goal setting',...
                           'Tag','Goal',...
                           'Callback',@ControlOpt,... 
                           data.ToolTipString,Tip) ;
        [~,Tip] = createStrToolTip(data.datastructure.Bill.Tooltip,...
                                   data.datastructure.Bill.LongName) ;     
        gui.Bill = uicontrol('Parent',PanelControlOpt,...
                           'Style','checkbox',...
                           'String','Billing',...
                           'Tag','Bill',...
                           'Callback',@ControlOpt,... 
                           data.ToolTipString,Tip) ;  
         set( PanelControlOpt, 'Heights', [25 25 25 25], 'Spacing', 5 );
         set( MainPanelControl, 'Heights', [25 -1], 'Spacing', 5 );
         
         % + Create the interface for the House details
         gui.ScrollHDpanel = uix.ScrollingPanel('Parent', gui.PanelHousedetail);
         gui.ViewContainerHDpanel = uicontainer('Parent', gui.ScrollHDpanel ); 
         
             gui.MainPanel_HD = uix.VBox('Parent',gui.ViewContainerHDpanel,'Spacing', 5 ) ;
             gui.panel{1} = uix.BoxPanel('Parent',gui.MainPanel_HD,'Title','General',...
                                         'MinimizeFcn', {@nMinimize_HD, 3,'Limit'},...
                                         'Padding',2,'HelpFcn', @onPanelHelp);
                SplitPG = uix.VBox('Parent',gui.panel{1},'Spacing', 5 ) ;
                    NbrInhBox = uix.HBox('Parent',SplitPG,'Spacing', 5 ) ;
                    NbrRoomBox = uix.HBox('Parent',SplitPG,'Spacing', 5 ) ;
                    
             gui.panel{2} = uix.BoxPanel('Parent',gui.MainPanel_HD,'Title','Location',...
                                         'MinimizeFcn', {@nMinimize_HD, 2,'Limit'},...
                                         'Padding',2,'HelpFcn', @onPanelHelp);
                SplitPL = uix.VBox('Parent',gui.panel{2},'Spacing', 5 ) ;
                    LatBox = uix.HBox('Parent',SplitPL,'Spacing', 5 ) ;
                    LongBox = uix.HBox('Parent',SplitPL,'Spacing', 5 ) ;
                    gui.SetLoc = uicontrol('Parent',SplitPL,'Style','pushbutton',...
                                                            'string','Set location on map',...
                                                            'callback',@LiveData,...
                                                            'Tag','SetLoc');
                    
             gui.panel{3} = uix.BoxPanel('Parent',gui.MainPanel_HD,'Title','Appliances',...
                                         'MinimizeFcn', {@nMinimize_HD, 1,'NoLimit'},...
                                         'Padding',2,'HelpFcn', @onPanelHelp);
                 gui.SplitApp = uix.VBox('Parent',gui.panel{3},'Spacing', 5 ) ;
                     AppAdd = uix.HBox('Parent',gui.SplitApp,'Spacing', 5 ) ;
                 
                % Set the General Panel
                 textinh = uicontrol('Parent',NbrInhBox,'Style','text',...
                           'String','Number of inhabitants') ;
                 [~,Tip] = createStrToolTip(data.datastructure.inhabitants.Tooltip,...
                                            data.datastructure.inhabitants.LongName) ;     
                 gui.inhabitants = uicontrol('Parent',NbrInhBox,'Style','popup',...
                                             'String',data.nbrInhabitant(:),...
                                             'Tag','inhabitants',...
                                             'Callback',@SaveEdit,...
                                             data.ToolTipString,Tip) ;  
                 uicontrol('Parent',NbrRoomBox,'Style','text',...
                           'String','Number of room(s)') ;
                 [~,Tip] = createStrToolTip(data.datastructure.nbrRoom.Tooltip,...
                                            data.datastructure.nbrRoom.LongName) ;    
                 gui.nbrRoom = uicontrol('Parent',NbrRoomBox,'Style','edit',...
                                         'String','1',...
                                         'Tag','nbrRoom',...
                                         'Callback',@SaveEdit,...
                                         'KeyPressFcn',@LiveData,...
                                         data.ToolTipString,Tip) ;
               
                % Set the location Panel
                 textLat = uicontrol('Parent',LatBox,'Style','text',...
                           'String','Latitude') ;
                 [~,Tip] = createStrToolTip(data.datastructure.Latitude.Tooltip,...
                                            data.datastructure.Latitude.LongName) ; 
                 gui.Latitude = uicontrol('Parent',LatBox,'Style','edit',...
                                          'String',data.datastructure.Latitude.Defaultcreate,...
                                          'Callback',@SaveEdit,...
                                          'KeyPressFcn',@LiveData,...
                                          'Tag','Latitude',...
                                          data.ToolTipString,Tip) ;
                 uicontrol('Parent',LongBox,'Style','text',...
                           'String','Latitude') ;
                 [~,Tip] = createStrToolTip(data.datastructure.Longitude.Tooltip,...
                                            data.datastructure.Longitude.LongName) ; 
                 gui.Longitude = uicontrol('Parent',LongBox,'Style','edit',...
                                           'String',data.datastructure.Longitude.Defaultcreate,...
                                           'Callback',@SaveEdit,...
                                           'KeyPressFcn',@LiveData,...
                                           'Tag','Longitude',...
                                           data.ToolTipString,Tip) ;
               
                % Set the Appliances Panel
                     uicontrol('Parent',AppAdd,'Style','text',...
                           'String','Appliances') ;
                 gui.AddAppliance = uicontrol('Parent',AppAdd,'Style','pushbutton',...
                           'String','+',...
                           data.ToolTipString,'Add appliances',...
                           'Tag','AddAppliance',...
                           'Callback',@AddApplianceCallback) ;
                 gui.RemoveAppliance = uicontrol('Parent',AppAdd,'Style','pushbutton',...
                           'String','-',...
                           'Tag','RemoveAppliance',...
                           data.ToolTipString,'Remove appliances',...
                           'enable','off',...
                           'Callback',@AddApplianceCallback) ;
                       
                 str={'Appliance' 'Rate' 'Qty'}   ;   
                 
                 gui.multicolumnApp = uimulticollist('Parent',gui.SplitApp,...
                                  'string', str,...
                                  'columnColour', {'BLACK' 'BLACK' 'BLACK' },...
                                  'tag','multicolumnApp', ...
                                  'callback', @ListApplianceSelection, ...
                                  'ButtonDownFcn', @ModificationSelection);    
                 uimulticollist( gui.multicolumnApp, 'setRow1Header', 'on' )     ;
                 uimulticollist( gui.multicolumnApp, 'applyUIFilter', 'on' )     ;
% JARI'S CHECK
                  
        pos1 = get(textinh,'Extent');
        set(NbrInhBox,'Widths',[pos1(3) -1]);
        set(NbrRoomBox,'Widths',[pos1(3) -1]);
        
        pos2 = get(textLat,'Extent');
        set(LatBox,'Widths',[pos2(3) -1]);
        set(LongBox,'Widths',[pos2(3) -1]);
        
        set(SplitPG,'Heights',[pos1(4) pos1(4)]) ; 
        set(SplitPL,'Heights',[pos2(4) pos2(4) pos2(4)]) ; 
        
        set(AppAdd,'Widths',[-1 25 25]);
        set(gui.SplitApp,'Heights',[25 -1]) ;
        
        [PanelSize1] = PanelinnerSize(gui.panel{1}) ;
        [PanelSize2] = PanelinnerSize(gui.panel{2}) ;
        
        set(gui.ScrollHDpanel,'MinimumHeights',Ratio2Apply*ScreenSize(4)) ;
        
        set(gui.MainPanel_HD,'Heights',[PanelSize1 PanelSize2 -1]) ;
        
        % + Create the interface for the Small-scale production
        gui.ScrollSSPpanel = uix.ScrollingPanel('Parent', gui.Panelssprod);
        gui.ViewContainerSSPpanel = uicontainer('Parent', gui.ScrollSSPpanel ); 
        gui.MainPanel_SSP = uix.VBox('Parent',gui.ViewContainerSSPpanel,'Spacing', 5 ) ;
        
             gui.SSPpanel{1} = uix.BoxPanel('Parent',gui.MainPanel_SSP,'Title','Photovoltaic panels',...
                                            'MinimizeFcn', {@nMinimize_HD, 3,'Limit'},...
                                            'Padding',2,'HelpFcn', @onPanelHelp,...
                                            'Tag','Panel3');
                    
             
                SplitPV = uix.VBox('Parent',gui.SSPpanel{1},'Spacing', 5 ) ;
                    gui.PVTech = uix.HBox('Parent',SplitPV,'Spacing', 5 ) ;
                    gui.PVSpec = uix.VBox('Parent',SplitPV,'Spacing', 5 ) ;
                    
             
             gui.SSPpanel{2} = uix.BoxPanel('Parent',gui.MainPanel_SSP,'Title','Wind power',...
                                            'MinimizeFcn', {@nMinimize_HD, 2,'Limit'},...
                                            'Padding',2,'HelpFcn', @onPanelHelp,...
                                            'Tag','Panel2');
             
                Splitwind = uix.VBox('Parent',gui.SSPpanel{2},'Spacing', 5 ) ;
                    gui.windTech = uix.HBox('Parent',Splitwind,'Spacing', 5 ) ;
                    gui.windSpec = uix.VBox('Parent',Splitwind,'Spacing', 5) ;
                    
             gui.SSPpanel{3} = uix.BoxPanel('Parent',gui.MainPanel_SSP,'Title','Fuel cells',...
                                            'MinimizeFcn', {@nMinimize_HD, 1,'Limit'},...
                                            'Padding',2,'HelpFcn', @onPanelHelp,...
                                            'Tag','Panel1');
             
                SplitFC = uix.VBox('Parent',gui.SSPpanel{3},'Spacing', 5 ) ;
                    gui.FCTech = uix.HBox('Parent',SplitFC,'Spacing', 5 ) ;
                    gui.FCSpec = uix.VBox('Parent',SplitFC,'Spacing', 5 ) ;
             
             str={'Criteria' 'Input Value'}   ;  
             % Setup the PV Panels panel
             [~,Tip] = createStrToolTip(data.datastructure.PhotoVol.Tooltip,...
                                        data.datastructure.PhotoVol.LongName) ; 
             gui.PhotoVol = uicontrol('Parent',gui.PVTech,...
                                         'Style','checkbox',...
                                         'string','Install PV',...
                                         'Callback',@Enabletech, 'value',0,...
                                         data.ToolTipString,Tip,...
                                         'Tag','PhotoVol') ;
             
             gui.Spec2DefinePV = uicontrol('Parent',gui.PVSpec,'Style','popup',...
                                           'Tag','Spec2DefinePV','string',data.PV_Variable(:),...
                                           data.ToolTipString,'Select the variable you want to define') ;
                   AddPVSpec = uix.HBox('Parent',gui.PVSpec,'Spacing', 5 ) ;                    
                         gui.Spec2InputPV = uicontrol('Parent',AddPVSpec,'Style','edit',...
                                                       'Tag','Spec2InputPV');
                         gui.Spec2AddPV = uicontrol('Parent',AddPVSpec,'Style','pushbutton',...
                                                       'Tag','Spec2AddPV','string','+',...
                                                       'Callback',@AddSpec);
                         gui.Spec2RemovePV = uicontrol('Parent',AddPVSpec,'Style','pushbutton',...
                                                       'Tag','Spec2RemovePV','string','-',...
                                                       'Callback',@AddSpec);
                                                   
             gui.Spec2ListPV = uimulticollist('Parent',gui.PVSpec,...
                                  'string', str,...
                                  'columnColour', {'BLACK' 'BLACK'},...
                                  'tag','Spec2ListPV',...
                                  'Callback',@ListSPPSelection); 
             set(SplitPV,'Heights',[23 -1] ); 
             set(gui.PVSpec,'Heights',[23 23 -1] );
             set(AddPVSpec,'Widths',[-1 20 20]);
             set(gui.ScrollSSPpanel,'MinimumHeights',Ratio2Apply*ScreenSize(4)) ;
             
             % Setup the Wind power panel
             gui.WindTurbine = uicontrol('Parent',gui.windTech,...
                                           'Style','checkbox',...
                                           'string','Install wind turbine',...
                                           'Tag','WindTurbine',...
                                           'Callback',@Enabletech, 'value',0);
             
             gui.Spec2DefineWind = uicontrol('Parent',gui.windSpec,'Style','popup',...
                                           'Tag','Spec2DefineWind','string',data.wind_Variable(:),...
                                           data.ToolTipString,'Select the variable you want to define') ;
                   AddWindSpec = uix.HBox('Parent',gui.windSpec,'Spacing', 5 ) ;                    
                         gui.Spec2InputWind = uicontrol('Parent',AddWindSpec,'Style','edit',...
                                                       'Tag','Spec2InputWind');
                         gui.Spec2AddWind = uicontrol('Parent',AddWindSpec,'Style','pushbutton',...
                                                       'Tag','Spec2AddWind','string','+',...
                                                       'Callback',@AddSpec);
                         gui.Spec2RemoveWind = uicontrol('Parent',AddWindSpec,'Style','pushbutton',...
                                                       'Tag','Spec2RemoveWind','string','-',...
                                                       'Callback',@AddSpec);
              
             gui.Spec2ListWind = uimulticollist('Parent',gui.windSpec,...
                                  'string', str,...
                                  'columnColour', {'BLACK' 'BLACK'},...
                                  'tag','Spec2ListWind',...
                                  'Callback',@ListSPPSelection); 
             set(Splitwind,'Heights',[23 -1] ); 
             set(gui.windSpec,'Heights',[23 23 -1] );
             set(AddWindSpec,'Widths',[-1 20 20]);
             
             % Setup the Fuel cell panel 
             gui.FuelCell = uicontrol('Parent',gui.FCTech,...
                                         'Style','checkbox',...
                                         'string','Install Fuel cells',...
                                         'Tag','FuelCell',...
                                         'Callback',@Enabletech, 'value',0);
             
             gui.Spec2DefineFC = uicontrol('Parent',gui.FCSpec,'Style','popup',...
                                           'Tag','Spec2DefineFC','string',data.FC_Variable(:),...
                                           data.ToolTipString,'Select the variable you want to define') ;
                   AddFCSpec = uix.HBox('Parent',gui.FCSpec,'Spacing', 5 ) ;                    
                         gui.Spec2InputFC = uicontrol('Parent',AddFCSpec,'Style','popup',...
                                                       'Tag','Spec2InputFC','string',data.FC_Power(:));
                         gui.Spec2AddFC = uicontrol('Parent',AddFCSpec,'Style','pushbutton',...
                                                       'Tag','Spec2AddFC','string','+',...
                                                       'Callback',@AddSpec);
                         gui.Spec2RemoveFC = uicontrol('Parent',AddFCSpec,'Style','pushbutton',...
                                                       'Tag','Spec2RemoveFC','string','-',...
                                                       'Callback',@AddSpec);
                                                   
             gui.Spec2ListFC = uimulticollist('Parent',gui.FCSpec,...
                                  'string', str,...
                                  'columnColour', {'BLACK' 'BLACK'},...
                                  'tag','Spec2ListFC',...
                                  'Callback',@ListSPPSelection); 
             set(SplitFC,'Heights',[23 -1] ); 
             set(gui.FCSpec,'Heights',[23 23 -1] );
             set(AddFCSpec,'Widths',[-1 20 20]);
             
        % + Create the interface for the Thermal characteristics
        gui.ScrollTCpanel = uix.ScrollingPanel('Parent', gui.Panelthermchar);
        gui.ViewContainerTCpanel = uicontainer('Parent', gui.ScrollTCpanel ); 
        gui.MainPanel_TC = uix.VBox('Parent',gui.ViewContainerTCpanel,'Spacing', 5 ) ;
        
        gui.TCpanel{1} = uix.BoxPanel('Parent',gui.MainPanel_TC,'Title','Building dimension',...
                                            'MinimizeFcn', {@nMinimize_HD, 4,'NoLimit'},...
                                            'Padding',2,'HelpFcn', @onPanelHelp,...
                                            'Tag','Panel4');
            gui.SplitBD = uix.VBox('Parent',gui.TCpanel{1},'Spacing', 5 ) ;
                uicontrol('Parent',gui.SplitBD,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Building Dimension');
                gui.DefineBDVar = uicontrol('Parent',gui.SplitBD,...
                                                    'Style','popup',...
                                                    'Tag','DefineBDVar',...
                                                    'string',data.BD_dimensions(:),...
                                                    'callback',@Spec2InputBDVar);
                uicontrol('Parent',gui.SplitBD,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Specific Variables',...
                          'enable','off');
                gui.Spec2DefineBDVar = uicontrol('Parent',gui.SplitBD,...
                                                'Style','popup',...
                                                'Tag','Spec2DefineBDVar',...
                                                'string',data.BD_Variable(:),...
                                                'enable','off');
                gui.AddBDVarSpec = uix.HBox('Parent',gui.SplitBD,'Spacing', 5 ) ;
                    gui.Spec2InputBDVar = uicontrol('Parent',gui.AddBDVarSpec,...
                                                   'Style','edit',...
                                                   'Tag','Spec2InputBDVar',...
                                                'enable','off');
                    gui.Spec2AddBDVar = uicontrol('Parent',gui.AddBDVarSpec,...
                                               'Style','pushbutton',...
                                               'Tag','Spec2AddBDVar',...
                                               'string','+',...
                                               'Callback',@AddSpec,...
                                                'enable','off');
                    gui.Spec2RemoveBDVar = uicontrol('Parent',gui.AddBDVarSpec,...
                                                  'Style','pushbutton',...
                                                  'Tag','Spec2RemoveBDVar',...
                                                  'string','-',...
                                                  'Callback',@AddSpec,...
                                                'enable','off');
                gui.Spec2ListBDVar = uimulticollist('Parent',gui.SplitBD,...
                                                    'string', str,...
                                                    'columnColour', {'BLACK' 'BLACK'},...
                                                    'tag','Spec2ListBDVar',...
                                                    'Callback',@ListSPPSelection,...
                                                'enable','off'); 
                
        gui.TCpanel{2} = uix.BoxPanel('Parent',gui.MainPanel_TC,'Title','Thermal Performances',...
                                            'MinimizeFcn', {@nMinimize_HD, 3,'NoLimit'},...
                                            'Padding',2,'HelpFcn', @onPanelHelp,...
                                            'Tag','Panel3');
             gui.SplitTP = uix.VBox('Parent',gui.TCpanel{2},'Spacing', 5 ) ;
                uicontrol('Parent',gui.SplitTP,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Thermal performance');
                gui.DefineTPVar = uicontrol('Parent',gui.SplitTP,...
                                                    'Style','popup',...
                                                    'Tag','DefineTPVar',...
                                                    'String',data.Heating_dimensions(:),...
                                                    'callback',@HeatingDatabase);
                                                    %'string',data.BD_dimensions(:),...
                                                    %'callback',@Spec2InputBDVar);
                uicontrol('Parent',gui.SplitTP,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Specific Variables',...
                                                'enable','off');
                gui.Spec2DefineTPVar = uicontrol('Parent',gui.SplitTP,...
                                                'Style','popup',...
                                                'Tag','Spec2DefineTPVar',...
                                                'string',data.TP_Variable(:),...
                                                'enable','off');
                gui.AddTPVarSpec = uix.HBox('Parent',gui.SplitTP,'Spacing', 5 ) ;
                    gui.Spec2InputTPVar = uicontrol('Parent',gui.AddTPVarSpec,...
                                                   'Style','edit',...
                                                   'Tag','Spec2InputTPVar',...
                                                'enable','off');
                    gui.Spec2AddTPVar = uicontrol('Parent',gui.AddTPVarSpec,...
                                               'Style','pushbutton',...
                                               'Tag','Spec2AddTPVar',...
                                               'string','+',...
                                               'Callback',@AddSpec,...
                                                'enable','off');
                    gui.Spec2RemoveTPVar = uicontrol('Parent',gui.AddTPVarSpec,...
                                                  'Style','pushbutton',...
                                                  'Tag','Spec2RemoveTPVar',...
                                                  'string','-',...
                                                  'Callback',@AddSpec,...
                                                'enable','off');
                gui.Spec2ListTPVar = uimulticollist('Parent',gui.SplitTP,...
                                                    'string', str,...
                                                    'columnColour', {'BLACK' 'BLACK'},...
                                                    'tag','Spec2ListTPVar',...
                                                    'Callback',@ListSPPSelection,...
                                                'enable','off');                           

        gui.TCpanel{3} = uix.BoxPanel('Parent',gui.MainPanel_TC,'Title','Ventilation',...
                                            'MinimizeFcn', {@nMinimize_HD, 2,'NoLimit'},...
                                            'Padding',2,'HelpFcn', @onPanelHelp,...
                                            'Tag','Panel2');
                   gui.SplitVent = uix.VBox('Parent',gui.TCpanel{3},'Spacing', 5 ) ;
               gui.VentSys = uix.HBox('Parent',gui.SplitVent,'Spacing', 5 ) ;
                           uicontrol('Parent',gui.VentSys,...
                                            'HorizontalAlignment','left',...
                                            'Style','text',...
                                            'String','Ventilation system');
                           gui.Ventil = uicontrol('Parent',gui.VentSys,...
                                                                        'Style','popup',...
                                                                        'Tag','Ventil',...
                                                                        'String',data.varname.Ventil.Exception(:),...
                                                                        'Callback',@HeatingTechnologySetting);
                                                                    
                gui.DefineVentVar = uicontrol('Parent',gui.SplitVent,...
                                                    'Style','popup',...
                                                    'Tag','DefineVentVar',...
                                                    'string',data.BD_dimensions(:),...
                                                    'callback',@Spec2InputBDVar);
                uicontrol('Parent',gui.SplitVent,...
                                'HorizontalAlignment','left',...
                                'Style','text',...
                                'String','Specific Variables',...
                                                'enable','off');
                gui.Spec2DefineVentVar = uicontrol('Parent',gui.SplitVent,...
                                                'Style','popup',...
                                                'Tag','Spec2DefineVentVar',...
                                                'string',data.Ventil_Variable(:),...
                                                'enable','off');
                gui.AddVentVarSpec = uix.HBox('Parent',gui.SplitVent,'Spacing', 5 ) ;
                    gui.Spec2InputVentVar = uicontrol('Parent',gui.AddVentVarSpec,...
                                                   'Style','edit',...
                                                   'Tag','Spec2InputVentVar',...
                                                'enable','off');
                    gui.Spec2AddVentVar = uicontrol('Parent',gui.AddVentVarSpec,...
                                               'Style','pushbutton',...
                                               'Tag','Spec2AddVentVar',...
                                               'string','+',...
                                               'Callback',@AddSpec,...
                                                'enable','off');
                    gui.Spec2RemoveVentVar = uicontrol('Parent',gui.AddVentVarSpec,...
                                                  'Style','pushbutton',...
                                                  'Tag','Spec2RemoveVentVar',...
                                                  'string','-',...
                                                  'Callback',@AddSpec,...
                                                'enable','off');
                gui.Spec2ListVentVar = uimulticollist('Parent',gui.SplitVent,...
                                                    'string', str,...
                                                    'columnColour', {'BLACK' 'BLACK'},...
                                                    'tag','Spec2ListVentVar',...
                                                    'Callback',@ListSPPSelection,...
                                                'enable','off');                           
                                            
    gui.TCpanel{4} = uix.BoxPanel('Parent',gui.MainPanel_TC,'Title','Heating Technology',...
                                        'MinimizeFcn', {@nMinimize_HD, 1, 'NoLimit'},...
                                        'Padding', 2, 'HelpFcn', @onPanelHelp,...
                                        'Tag', 'Panel1');
                                    
            gui.SplitHeating = uix.VBox('Parent',gui.TCpanel{4},'Spacing',5);
            
                gui.HeatingSelection = uix.HBox('Parent', gui.SplitHeating, 'Spacing', 5);
                                uicontrol('Parent',gui.HeatingSelection,...
                                           'HorizontalAlignment', 'left', ...
                                           'Style', 'text', ...
                                           'String', 'Heating type');
                                
                    gui.HeatingTechnology = uicontrol('Parent', gui.HeatingSelection,...
                                                      'Style', 'popupmenu',...
                                                      'Tag', 'HeatingTechnology',...
                                                      'String', data.varname.HeatingTechnology.Exception(:),...
                                                      'callback', @HeatingSelection);
            
                gui.HeatingSys = uix.HBox('Parent',gui.SplitHeating,'Spacing',5);
                                uicontrol('Parent',gui.HeatingSys,...
                                            'HorizontalAlignment','left',...
                                            'Style','text',...
                                            'String','Choose Heating');
                                        
                    gui.Heating_Tech = uicontrol('Parent',gui.HeatingSys,...
                                                'Style','popupmenu',...
                                                'Tag','Heating_Tech',...
                                                'String',data.varname.Heating_Tech.Exception(:),...
                                                'Callback', @HeatingTechnologySetting); %@SaveEdit); %@Spec2InputBDVar);
                                            
                gui.ChargingSys = uix.HBox('Parent',gui.SplitHeating,'Spacing',5);
                                uicontrol('Parent',gui.ChargingSys,...
                                            'HorizontalAlignment','left',...
                                            'Style','text',...
                                            'String','Charging strategy');

                        gui.Charging_strategy = uicontrol('Parent',gui.ChargingSys,...
                                                        'Style','popupmenu',...
                                                        'Tag','Charging_strategy',...
                                                        'String',data.varname.Charging_strategy.Exception(:),...
                                                        'callback',@HeatingTechnologySetting,...
                                                        'enable', 'off');
                                                    
                gui.ComfortSys = uix.HBox('Parent',gui.SplitHeating,'Spacing',5);
                                uicontrol('Parent',gui.ComfortSys,...
                                            'Style','text',...
                                            'HorizontalAlignment','left',...
                                            'String','Comfort Level');
                                        
                        gui.ComfortLimit = uicontrol('Parent',gui.ComfortSys,...
                                            'Style','popupmenu',...
                                            'Tag','ComfortLimit',...
                                            'String',data.varname.ComfortLimit.Exception(:),...
                                            'callback',@HeatingTechnologySetting);
                                        
                                        
                                            
                gui.DefineHeatingVar = uicontrol('Parent',gui.SplitHeating,...
                                                    'Style','popupmenu',...
                                                    'Tag','DefineHeatingVar',...
                                                    'string',data.BD_dimensions(:),...
                                                    'callback',@Spec2InputBDVar);
                                                    %'String',data.Heating_dimensions(:),...
                                                    %'callback',@HeatingDatabase);%@Spec2InputBDVar);
                                                
                    
                    
                gui.HeatingSpecificVar = uicontrol('Parent',gui.SplitHeating,...
                                                        'HorizontalAlignment','left',...
                                                        'Style','text',...
                                                        'String','Heating Variables',...
                                                        'enable', 'off');
                                                    
                gui.Spec2DefineHeatingVar = uicontrol('Parent',gui.SplitHeating,...
                                                            'Style','popupmenu',...
                                                            'Tag','Spec2DefineHeatingVar',...
                                                            'String',data.Heating_Variable(:),... %data.Heating_Var(:),...
                                                            'enable','off');
                                                        
                            gui.AddHeatingVarSpec = uix.HBox('Parent',gui.SplitHeating,'Spacing',5);
                            
                                    gui.Spec2InputHeatingVar = uicontrol('Parent',gui.AddHeatingVarSpec,...
                                                                        'Style','edit',...
                                                                        'Tag','Spec2InputHeatingVar',...
                                                                        'enable','off');
                                                                    
                                    gui.Spec2AddHeatingVar = uicontrol('Parent',gui.AddHeatingVarSpec,...
                                                                        'Style','pushbutton',...
                                                                        'String','+',...
                                                                        'Tag','Spec2AddHeatingVar',...
                                                                        'Callback',@AddSpec,...
                                                                        'enable','off');
                                                                    
                                    gui.Spec2RemoveHeatingVar = uicontrol('Parent',gui.AddHeatingVarSpec,...
                                                                            'Style','pushbutton',...
                                                                            'String','-',...
                                                                            'Tag','Spec2RemoveHeatingVar',...
                                                                            'Callback',@AddSpec,...
                                                                            'enable','off');
                                                        
                            gui.Spec2ListHeatingVar = uimulticollist('Parent',gui.SplitHeating,...
                                                                'string',str,...
                                                                'columnColour',{'Black' 'Black'},...
                                                                'tag','Spec2ListHeatingVar',...
                                                                'callback',@ListSPPSelection,...
                                                                'enable','off');
                                        
       set(gui.SplitBD,'Heights',[15 23 15 23 23 -1] );  
       set(gui.SplitTP,'Heights',[15 23 15 23 23 -1] );  
       set(gui.SplitVent,'Heights',[23 23 15 23 23 -1] );  
       set(gui.SplitHeating,'Heights',[23 23 23 23 23 15 23 23 -1] );
       
       set(gui.AddBDVarSpec,'Widths',[-4 -1 -1]);
       set(gui.AddTPVarSpec,'Widths',[-4 -1 -1]);
       set(gui.AddVentVarSpec,'Widths',[-4 -1 -1]);
       set(gui.AddHeatingVarSpec,'Widths',[-4 -1 -1]);
       
        for i = 1:length(gui.TCpanel)
            set(gui.TCpanel{i}, 'Minimized', true)
        end
       
%        gui.TCpanel{4}.Position = [1 1 193 50];
%        set(gui.SplitHeating,'Position',[1 1 23 23]);
       set(gui.MainPanel_TC,'Heights', [25 25 25 25]); %[-1 -1 -1 -1]) ;
       set(gui.ScrollTCpanel,'MinimumHeights',Ratio2Apply*ScreenSize(4)) ;
       
    end % createInterface
%-------------------------------------------------------------------------%
    function [X,Y] = mouseMove (~,~)
        C = get (gui.Window, 'CurrentPoint');
        X = C(1,1) ;
        Y = C(1,2) ;
    end
%-------------------------------------------------------------------------%
    function testnouse()
        import java.awt.Robot;
            mouse = Robot;
            [X,Y] = mouseMove ;
            mouse.mouseMove(X, Y);
%             screenSize = get(0, 'screensize');
            mouse.mouseMove(X + 10, Y + 10)
            pause(0.00001);
    end
%-------------------------------------------------------------------------%
function LiveData(src,Eventdata)
    Error = CheckHouseExist ;
    
%     e.g.
%     coordsHelsinki = [24.7828 25.2545 59.9225 60.2978];

    if Error
        return;
    end
    
    switch src.Tag
        case 'SetLoc'
            % Draw the point for the selected house
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        
            for i = 1:numel(HouseSelected)
                HouseTag =  HouseSelected{i} ;
                
                % Check if the House ROI alrady exist
                PointExist = 1 ;
                try
                    data.Map.(HouseTag) ;
                catch
                    PointExist = 0 ;
                end
                if PointExist
                     delete(data.Map.(HouseTag))   
                end
                data.Map.(HouseTag) = drawpoint(gui.AxesMap) ;
                data.Map.(HouseTag).Label = HouseTag ;
                SaveData('Latitude',HouseTag,data.Map.(HouseTag).Position(2)) ;
                SaveData('Longitude',HouseTag,data.Map.(HouseTag).Position(1))
            end
            gui.Latitude.String = num2str(data.Map.(HouseTag).Position(2)) ;
            gui.Longitude.String = num2str(data.Map.(HouseTag).Position(1)) ;
            
        otherwise
            
    end
%     NewStr = ed_kpfcn(src,Eventdata) ;
%     z.EventName = 'KeyPress';
%     SaveEdirt(src,z)      ;
end %LiveData
%-------------------------------------------------------------------------%
    function Error = CheckHouseExist
        Error = 0 ;
        if isempty(gui.ListBox.String)||isempty(gui.ListBox.String{1})
            errordlg('You  must create a house first before using this function','Missing house input')
            Error = 1 ; 
        end
    end %CheckHouseExist
%-------------------------------------------------------------------------%
function [NewStr] = ed_kpfcn(src,Eventdata)
    % Keypressfcn for editbox
    try 
        actionsat = data.SaveEditUpdate ;
    catch
        % The variable was not set yet ;
        data.SaveEditUpdate = 0 ;
        actionsat = data.SaveEditUpdate ;
    end
    if actionsat == 1
%         return;
    end
    PreviousValue = src.String ;
    data.SaveEditUpdate = 1 ;
    PKey = Eventdata.Character ;
    jEdit = findjobj(src);
    CursorPos = jEdit.CaretPosition ;
    try
        datatype = data.varname.(src.Tag).Type ;
    catch
        datatype = 'double' ;
    end
    switch datatype
        case 'string'
            
        case 'double'
                % This is a numeric value
               if strcmp(Eventdata.Key,'backspace')
                    if length(src.String) == (CursorPos + 1)
                        NewStr = src.String(1:end-1); 
                    elseif CursorPos == 1
                        NewStr = src.String(2:end);
                    elseif CursorPos == 0
                        NewStr = src.String(2:end) ;
                    else
                        NewStr = [src.String(1:(CursorPos - 1)) src.String((CursorPos + 1):end)]  ;
                    end
                elseif isempty(PKey) % It includes any key that are neither numeric or strings
                    return
                elseif isnan(str2double(PKey))
                    % This means that the pressed key was not a double value
                    if sum(strcmp(PKey,{'.',','}))
                        
                    elseif isa(PKey,'string')
                        err = {'Input value must be numerical'} ;
                        uiwait(msgbox(err,'Error','modal')) ;
                        src.String = PreviousValue ;
                        return
                    elseif isa(PKey,'char')
                        % This might be some other key such as the delete
                        % key
                        if sum(strcmp(Eventdata.Key,{'delete'}))                          
                            length(src.String);
                            SplitStr = regexp(src.String, '\w{1,1}', 'match') ;
                            if isempty(SplitStr)
                                % This means that the original value was
                                % empty
                                src.String = '' ;
                            elseif CursorPos == 0
                                NewStr = src.String(2:end);
                            elseif CursorPos == 1 && length(src.String) > 1
                                NewStr = [PKey src.String] ;
                            elseif CursorPos >= length(src.String)
                                NewStr = [src.String PKey] ;
                            else
                                NewStr = [src.String(1:(CursorPos - 1)) src.String((CursorPos + 1):end)]  ;
                            end

                        elseif sum(strcmp(Eventdata.Key,{'leftarrow' 'rightarrow' 'uparrow' 'downarrow'}))
                            NewStr = src.String ;
                            return
                        elseif sum(strcmp(PKey,{'+' '-'}))
                            if CursorPos == 1
                                if isempty(PreviousValue)
                                    PreviousValue = '0' ;
                                end
                                Test = [PKey PreviousValue] ;
                                NewStr = src.String ;
                                if isnan(str2double(Test))
                                    err = {'Input value must be numerical'} ;
                                    uiwait(msgbox(err,'Error','modal')) ;
                                    src.String = PreviousValue ;
                                    return
                                end
                            elseif isnan(str2double(PKey))
                                err = {'Input value must be numerical'} ;
                                uiwait(msgbox(err,'Error','modal')) ;
                                src.String = PreviousValue ;
                                return
                            end
                        else
                            err = {'Input value must be numerical'} ;
                            uiwait(msgbox(err,'Error','modal')) ;
                            src.String = PreviousValue ;
                            return
                        end
                    end
               else
                    Var = str2double(PKey) ;
                    if isreal(Var) 
                        % This means that this is a real number
                        SplitStr = regexp(src.String, '\w{1,1}', 'match') ;
                        if isempty(SplitStr)
                            % This means that the original value was
                            % empty
                            NewStr = PKey ;
                        elseif CursorPos == 0
                            % that should not happen
%                                 src.String = src.String(1:end-1); 
%                                 y1 = src.String(1:end-1)
                        elseif CursorPos == 1 && length(src.String) > 1
                            NewStr = [PKey src.String] ;
                        elseif CursorPos >= length(src.String)
                            NewStr = [src.String PKey] ;
                        else
                            NewStr = strcat(SplitStr{1:(CursorPos-1)}) ;
                        end
                        try 
                            NewStr ;
                        catch
                            return
                        end
                        src.String = NewStr ;
                    else
                        % This means that this is an imaginary number ('i')
                        % and should be reagarded as a string
                        err = {'Input value must be numerical'} ;
                        msgbox(err,'Error','modal') ;
                        src.String = PreviousValue ;
                        return
                    end
                end
    end
    try 
        NewStr ;
    catch
        return
    end
    if isempty(NewStr)
        src.String = '' ;
    else
        src.String = NewStr ;
        jEdit = findjobj(src);
        jEdit.CaretPosition = CursorPos ;
    end    
    
    data.SaveEditUpdate = 0 ;
end

%-------------------------------------------------------------------------%
    function SaveEdit(src,eventdata)
        if isempty(gui.ListBox.String)||isempty(gui.ListBox.String{1})
            return;
        end
        if strcmp(eventdata.EventName,'Action')
            % Trigger the call back to have the value
            try 
                actionsat = data.SaveEditUpdate ;
            catch
                % The variable was not set yet ;
                data.SaveEditUpdate = 0 ;
                actionsat = 1;
            end
            if actionsat == 1
                return;
            end
        end
            % z = eventdata
        SourceControl = src.Tag ;
        SourceStyle = src.Style ;
        switch SourceStyle
            case 'edit'
                VarType = data.varname.(src.Tag).Type ;
                if strcmp(VarType,'double')
                    InputVal = str2double(src.String) ;
                    LowLimit = data.varname.(src.Tag).LowLimit ;
                    HighLimit = data.varname.(src.Tag).HighLimit ;
                    %InputVal % Create exception with NAN value
                    if InputVal < LowLimit                   
                        % The input value is too low
                        err = strcat({'Input value should be greater or equal (>=) than'},{' '},{num2str(LowLimit)}) ;
                        msgbox(err,'Error','modal')
                        src.String = data.varname.(src.Tag).LowLimit ;
                    elseif InputVal > HighLimit
                        % The input value is too high
                        err = strcat({'Input value should be smaller or equal (<=) than'},{' '},{num2str(HighLimit)}) ;
                        msgbox(err,'Error','modal')
                        src.String = data.varname.(src.Tag).HighLimit ;
                    end
                end
                
                Data2Save =  src.String ;
            case 'popupmenu'
                hstring = data.datastructure.(src.Tag).Comparefield{2}                ;
                Data2Search =  src.String{src.Value} ;
                Data2ret = find(strcmp(hstring, Data2Search)) ;
                if isempty(Data2ret)
                    return;
                else
                    Data2Save =  data.datastructure.(src.Tag).Comparefield{1}{Data2ret} ;
                end
        end

        HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        
        for i = 1:numel(HouseSelected)
           HouseTag =  HouseSelected{i} ;
           SaveData(SourceControl,HouseTag,Data2Save)
        end 
    end %SaveEdit
%-------------------------------------------------------------------------%
    function InputErrMessage()
        
    end
%-------------------------------------------------------------------------%
    function [Size]=PanelinnerSize(Panel)
        Header = 23 ;
        found = 0 ;
        ChildOld = Panel ;

        while found == 0
            try
                ChildNew = ChildOld(1).Children(1) ;
            catch
               Size = 0;
               return; 
            end
            found = 1 ;
            pos1 = 0 ;
            
            pos1 = GetHeightContainer(ChildNew,pos1) ;      
        end
        Size = Header + 2*Panel.Padding + pos1 ;
    end %PanelinnerSize
%-------------------------------------------------------------------------%
    function [Heightreturn] = GetHeightContainer(ContainerID, Heightreturn)
        switch class(ContainerID)
            case 'uix.HBox'
                TypeinVBox = ContainerID(1).Children(1).Type ;
                switch TypeinVBox
                    case 'uicontainer'
                        Heightreturn = GetHeightContainer(ContainerID(1).Children(1),Heightreturn) ;
                        Heightreturn = Heightreturn + ContainerID(1).Children(1).Parent.Padding * 2 ;
                    case 'uicontrol'
                        pos = get(ContainerID(1).Children(1),'Extent');
                        Heightreturn = Heightreturn + pos(4) ;
                end
            case 'uix.VBox'
                    for i = 1:numel(ContainerID)
                        for ii = 1:numel(ContainerID(i).Children)
                            TypeinVBox = ContainerID(i).Children(ii).Type ;
                            switch TypeinVBox
                                case 'uicontainer'
                                    Heightreturn = GetHeightContainer(ContainerID(i).Children(ii),Heightreturn) ;
                                    Heightreturn = Heightreturn + ContainerID(i).Children(ii).Spacing * 2 + ContainerID(i).Children(ii).Padding * 2 ;
                                case 'uicontrol'
                                    pos = get(ContainerID(i).Children(ii),'Extent');
                                    style = get(ContainerID(i).Children(ii),'Style') ;
                                    if strcmp(style,'listbox')
                                        NbrInputMax = 6 ;
                                        NbrInput = size(ContainerID(i).Children(ii).String,1) + 1 ;
                                        Heightreturn = Heightreturn + pos(4)*(min(NbrInput,NbrInputMax)) ;
                                    else
                                        Heightreturn = Heightreturn + pos(4) ;
                                    end
                            end
                        end
                    end
        end
    end
%-------------------------------------------------------------------------%
    function createcontextmenu()
        AllObjectswindow = findall(gui.Window) ;
        
        for i = 1:numel(AllObjectswindow)
            n = 1;
            tag=get(AllObjectswindow(i),'tag') ;
            Parent=get(AllObjectswindow(i),'parent') ;
            ParentLevel = get(Parent,'type') ;
            if strcmp(ParentLevel,'root') 
                n = 0;
            else
                ParentTag = get(Parent,'Tag') ;
                if strcmp(ParentTag,'cbutton')
                    makeContextMenuItem(AllObjectswindow(i))
                    n = 0;
                elseif strcmp(ParentTag,'controlLayout')
                    makeContextMenuItem(AllObjectswindow(i))
                    n = 0;
                end
            end
            while n == 1
                Parent = get(Parent,'parent') ;
                ParentLevel = get(Parent,'type') ;
                ParentTag = get(Parent,'Tag') ;
                if strcmp(ParentLevel,'root')
                    n = 0 ;
                elseif strcmp(ParentTag,'cbutton')
                    makeContextMenuItem(AllObjectswindow(i))
                elseif strcmp(ParentTag,'controlLayout')
                    makeContextMenuItem(AllObjectswindow(i))
                end
            end
            
        end
    end %createcontextmenu
%-------------------------------------------------------------------------%
    function makeContextMenuItem(thisObject)
        c = uicontextmenu(gui.Window);
        %b = uicontrol(gui.Window,'UIContextMenu',c);
        % Create a child menu for the uicontextmenu
        if strfind(thisObject.Tag,'cbutt')
%             uimenu('Parent',c,'Label','Disable',...
%             'Callback', {@ContextMenuResponse, thisObject});
        elseif strfind(thisObject.Tag,'House')
            Edit = uimenu('Parent',c,'Label','Delete',...
                   'Callback', {@ContextMenuResponse, thisObject},...
                   'Tag','Delete');
            Create = uimenu('Parent',c,'Label','Create');
                AddApp = uimenu('Parent',Create,'Label','Add Appliances');
                uimenu('Parent',Create,'Label','Add Houses',...
                       'Callback', {@ContextMenuResponse, thisObject},...
                       'Tag','AddHouses');
                Randomcrea = uimenu('Parent',Create,'Label','Generate');
                    uimenu('Parent',AddApp, 'Label', 'Sauna',...
                        'Callback', {@ContextMenuResponse, thisObject},...
                        'Tag','AppSauna');
                    uimenu('Parent',AddApp, 'Label', 'Washing Machine',...
                        'Callback', {@ContextMenuResponse, thisObject},...
                        'Tag','AppWashMach');
                    uimenu('Parent',Randomcrea, 'Label', 'Random generation for this house',...
                        'Callback', {@ContextMenuResponse, thisObject},...
                        'Tag','RandOne');
                    uimenu('Parent',Randomcrea, 'Label', 'Random generation for all houses',...
                        'Callback', {@ContextMenuResponse, thisObject},...
                        'Tag','RandAll');
        elseif strcmp('ListBox',thisObject.Tag)
            gui.MainFilter = uimenu('Parent',c,'Label','Filter...',...
                   'Callback', @onDisplay,...
                   'Tag','Filter',...
                   'Enable','off');
            gui.ResetFilterCM = uimenu('Parent',c,'Label','Reset Filter',...
                   'Callback', @onDisplay,...
                   'Tag','ResetFilter',...
                   'Enable','off'); 
            gui.FilterEnable = uimenu('Parent',c,'Label','Enable',...
                   'Callback', @onDisplay,...
                   'Tag','FilterEnable',...
                   'Enable','off'); 
            gui.MainDeleteList = uimenu('Parent',c,'Label','Delete',...
                   'Callback', @onEdit,...
                   'Tag','MainDeleteList',...
                   'Enable','on');
        else 
%             uimenu('Parent',c,'Label','enable',...
%             'Callback', {@ContextMenuResponse, thisObject});
        end
        set(thisObject,'UIContextMenu',c)
    end %makeContextMenuItem
%-------------------------------------------------------------------------%
    function updateInterface()
        % Update various parts of the interface in response to the demo
        % being changed.
        set(gui.MainFilter,'enable','on')
        if data.Filtermode == 1
            set(gui.FilterEnable,'enable','on')
            set(gui.FilterEnable,'checked','on')
            InputFilter = data.Filter ;
            if size(InputFilter,1) > 1
                set(gui.ResetFilterCM,'enable','on')
            else
                set(gui.ResetFilterCM,'enable','off')
            end
        else
            InputFilter = data.Filter ;
            if size(InputFilter,1) > 1
                set(gui.ResetFilterCM,'enable','on')
                if strcmp(get(gui.FilterEnable,'checked'),'off')
                    set(gui.FilterEnable,'checked','on')
                else
                    set(gui.FilterEnable,'checked','off')
                end
                set(gui.FilterEnable,'enable','on')
            else
                set(gui.FilterEnable,'enable','off')
                set(gui.FilterEnable,'checked','off')
                set(gui.ResetFilterCM,'enable','off')
            end
        end
        % Update the list and menu to show the current demo
        if ~isempty(gui.ListBox.String) && ~isempty(get( gui.ListBox, 'Value'))
            houseselection = get( gui.ListBox, 'Value');
            % Update the help button label
            if numel(houseselection) > 1
                Houseselected = 'Multiple house selected' ;
            else
                Houseselected = gui.ListBox.String{houseselection} ;
            end
            %set( gui.HelpButton, 'String', ['Help for ',demoName] );
            % Update the view panel title
            set( gui.ViewPanel, 'Title', sprintf( 'Viewing: %s', Houseselected ) );
            % Untick all menus
%             menus = get( gui.ViewMenu, 'Children' );
%             set( menus, 'Checked', 'off' );
            %Use the name to work out which menu item should be ticked
%             whichMenu = strcmpi( Houseselected, get( menus, 'Label' ) );
%             set( menus(whichMenu), 'Checked', 'on' );
        end
    end % updateInterface
%-------------------------------------------------------------------------%
    function redrawDemo()
%         fcnName = data.DemoFunctions{data.SelectedDemo};
%         Panelnames = get(gui.ViewContainer,'Children') ;
%         for i = 1:length(Panelnames)
%             if strcmp(get(Panelnames(i),'Tag'),fcnName)
%                 set(Panelnames(i),'Visible','on') ;
%             else
%                 set(Panelnames(i),'Visible','off') ;    
%             end
%         end
    end % redrawDemo
%-------------------------------------------------------------------------%
    function onListSelection( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        %profile on

        if ~isempty(get( src, 'Value' ))
            data.SelectedDemo = src.Value;
            % Hilghlight the correct button
            Houseselected = src.String(src.Value) ;
            
            %updateInterface();
            %redrawDemo();
            k = 0;
            %%%% Small Scale Production
            % Loop through each house in the interface selected
            tech = {'PV'       'Wind'        'FC'
                    'PhotoVol' 'WindTurbine' 'FuelCell'} ;
            Event.EventName = 'NoAction' ;
            HouseTag = Houseselected{1} ;
            selectedhouse = gui.(HouseTag) ;
            Housebutton(selectedhouse,Event) ;
            for ik = 1:size(tech,2)
                
                for ij = 1:numel(Houseselected)
                    HouseTag = Houseselected{ij} ;
                    selectedhouse = gui.(HouseTag) ;
                    if isempty(selectedhouse)
                        selectedhouse = findobj(gui.Housedrawing,'UserData',strcat(Houseselected,'_Black')) ;
                    end
                    % Change the layout of each button house selected
                    Event.EventName = 'NoAction' ;

                    % Go through the different uimulticollist present in the UI
%                     techname = tech{1,ik} ;
                    VarNameTech = tech{2,ik} ;
                    Eventdata.EventName = data.SummaryStructure.(HouseTag).(VarNameTech) ;
                    CurrentHousedata = Eventdata.EventName ;
%                     Spec2List = strcat('Installed',techname);
                    if numel(Houseselected) == 1
                        % In case only 1 house is selected, this is straight
                        % forwards
                        Enabletech(gui.(VarNameTech),Eventdata) ;
                    else
                        if ij > 1
                           if strcmp(CurrentHousedata,PreviousHouseData)
                               if ij == numel(Houseselected)
                                   % If this is the last house and the
                                   % condition is still true
                                   Enabletech(gui.(VarNameTech),Eventdata) ;
                               end
                           else
                               Eventdata.EventName = '0' ;
                               Enabletech(gui.(VarNameTech),Eventdata) ;
                               continue;
                           end
                        end
                    end

                    % If it is more than one, then we need to compare the
                    % values 
                    PreviousHouseData = CurrentHousedata ;
                end 
            end
            % + Repopulate the input data to all the controls
                % Get the house(s) selected
                Housenumber = fieldnames(data.SummaryStructure);
                Eachfield = fieldnames(data.SummaryStructure.(Housenumber{1}));

                    %List the field not too look
                    ToSkip = {'Headers' 'HouseNbr' 'Time_Step' 'Building_Type' 'myiter' 'HighNbHouse' 'HighNbrRoom' 'Appliance_Max'};
                    
                    % There is more than 1 house selected
                    LineNumberApp = 2 ;
                    strfew = uimulticollist(gui.multicolumnApp,'string') ;
                    uimulticollist(gui.multicolumnApp,'value',1) ;
                    str(1,:) = strfew(1,:);
                    for ii = 1:numel(Eachfield)
                        if ~ismember(ToSkip,Eachfield{ii})
                            if sum(ismember(data.AppliancesList(:,3),Eachfield{ii}))
                                % This is to define the appliances
                                Housemax = numel(gui.ListBox.Value);
                                if Housemax == 1
                                    HouseSelected = gui.ListBox.String{gui.ListBox.Value(1)} ;
                                    retainedvalue = data.SummaryStructure.(HouseSelected).(Eachfield{ii}); 
                                elseif Housemax > 1
                                    continue;
                                end
                                CurrentApp      = find(1==strcmp(Eachfield{ii},data.AppliancesList(:,3))) ;
                                AppRanking      = data.AppliancesList{CurrentApp,4} ;
                                AppID           = data.AppliancesList{CurrentApp,3} ;
                                ApplianceName   = data.AppliancesList(CurrentApp,1) ;
                                
                                if ~isempty(AppRanking)
                                    ApplianceRating = data.SummaryStructure.(HouseSelected).(AppRanking) ;
                                    if isa(ApplianceRating,'cell')
                                        uniqueelem = unique(ApplianceRating) ;
                                        for ulem = 1:numel(uniqueelem)
                                            String1 = uniqueelem{ulem} ;
                                            Quantity = sum(strcmp(String1,ApplianceRating)) ;
                                            Quantity2 = data.SummaryStructure.(HouseSelected).(AppID) ;
                                            
                                            if Quantity > 0
                                                if Quantity > 2
                                                    str(LineNumberApp,1) = ApplianceName ;
                                                    str{LineNumberApp,2} = String1 ;
                                                    str{LineNumberApp,3} = num2str(Quantity) ;
                                                    LineNumberApp = LineNumberApp + 1;
                                                elseif ~strcmp(Quantity2,'0')
                                                    str(LineNumberApp,1) = ApplianceName ;
                                                    str{LineNumberApp,2} = String1 ;
                                                    str{LineNumberApp,3} = num2str(Quantity) ;
                                                    LineNumberApp = LineNumberApp + 1;
                                                end
                                            end
                                        end
                                    else
                                        Quantity = str2double(data.SummaryStructure.(HouseSelected).(data.AppliancesList{CurrentApp,3})) ;
                                        Quantity2 = data.SummaryStructure.(HouseSelected).(AppID) ;
                                        if Quantity > 0 && ~strcmp(Quantity2,'0')
                                            str(LineNumberApp,1) = ApplianceName ;
                                            str{LineNumberApp,2} = ApplianceRating ;
                                            str{LineNumberApp,3} = num2str(Quantity) ;
                                            LineNumberApp = LineNumberApp + 1;
                                        end
                                    end
                                else
                                    Quantity = str2double(data.SummaryStructure.(HouseSelected).(data.AppliancesList{CurrentApp,3})) ;
                                    Quantity = sum(Quantity) ;
                                    if Quantity > 0 
                                        str(LineNumberApp,1) = ApplianceName ;
                                        str{LineNumberApp,2} = '-' ;
                                        str{LineNumberApp,3} = num2str(Quantity) ;
                                        LineNumberApp = LineNumberApp + 1;
                                    end
                                end
                            elseif sum(ismember(data.AppliancesList(:,4),Eachfield{ii}))
                                % This is to define the class appliances.
                                % Do nothing because it is already taken
                                % care of before
                            else
                                if strcmp(Eachfield{ii},'Self')
                                   y = 1; 
                                end
                                try
                                    h = gui.(Eachfield{ii}) ;
                                catch
                                    k = k + 1 ;
                                    data.missing{k} = Eachfield{ii} ;
                                    % The varibale has not yet been defined
                                    continue;  % Jump to next iteration of: for i
                                end

                                Housemax = numel(gui.ListBox.Value);
                                if strcmp(Eachfield{ii},'WashMach')
                                    y = 1;
                                end
                                if Housemax == 1
                                    HouseSelected = gui.ListBox.String{gui.ListBox.Value(1)} ;
                                    retainedvalue = data.SummaryStructure.(HouseSelected).(Eachfield{ii}); 
                                elseif Housemax > 1
                                    retainedvalue = 'First Loop';
                                end
                                refill_uicontrol(h,Housemax,retainedvalue,Eachfield{ii})
                            end
                        end
                    end
                % If more than 1 house selected check if each house have
                % the same input
                
                % If they dont have the same input put the value to '-'  or
                % null
                
                % if they have display the common value
                
                % Loop through each panel and each uicontrol to repopulate
                % the data. Tag names should match the structure of
                % data.Summary. Exception will have to be done for the
                % appliances and the uimultilist that will require looping
                % through the cell structure.
                %profile viewer
                updateInterface()
                uimulticollist(gui.multicolumnApp,'string',str) ;
        end
    end % onListSelection
%-------------------------------------------------------------------------%
    function refill_uicontrol(h,Housemax,retainedvalue,field2change)
        i = 1 ;
        while i <= Housemax
        %for i = 1:numel(gui.ListBox.Value)
            HouseSelected = gui.ListBox.String{gui.ListBox.Value(i)} ;
            Value1 = data.SummaryStructure.(HouseSelected).(field2change) ;

            if ~strcmp('First Loop',retainedvalue)
                if isa(Value1,'char')
                    %a = Eachfield{ii}
                    if strcmp(Value1,retainedvalue) && i == Housemax
                        % All houses have the same value
                        %aprime = Eachfield{ii};
                        if ~isempty(h)
                            % Add the original value
                            filltype = h.Type ;
                            switch filltype
                                case 'uicontrol'
                                    fillstyle = h.Style ;
                                    switch fillstyle
                                        case 'edit'
                                            h.String = Value1 ;                                                                                       
                                        case 'popupmenu'
                                             if strcmp(field2change,'Profile')
                                                 if isnan(str2double(Value1))
                                                    h.Value = 1 ;
                                                 else
                                                    h.Value = str2double(Value1) + 1 ;
                                                 end
                                             else
                                                 h.Value = find(strcmp(Value1, h.String)) ;
                                                 if isempty(h.Value)
                                                     if ~isnan(str2double(Value1))
                                                         hstring = data.datastructure.(h.Tag).Comparefield{2}{str2double(Value1)} ;
                                                         h.Value = find(strcmp(hstring, h.String)) ;
                                                     else
                                                         h.Value = 1;
                                                     end
                                                 end
                                             end
                                        case 'checkbox'
                                            if ischar(Value1)
                                                Value1 = str2double(Value1) ;
                                            end
                                            h.Value = Value1 ;
                                    end 
                                case 'uibuttongroup'
                                    switch Value1
                                        case '1'
                                            gui.radiobuttonGreen.Value = 1;
                                        case '2'
                                            gui.radiobuttonOrange.Value = 1;
                                        case '3'
                                            gui.radiobuttonBrown.Value = 1;
                                    end
                            end
                        elseif ismember(field2change,data.AppliancesList(:,3)) || ismember(field2change,data.AppliancesList(:,4))
                            % this is an appliance and
                            % the uimultilist must be
                            % invoked to replace it if
                            % necessary
                        end
                    elseif strcmp(Value1,retainedvalue)
                        % This means that the house n is equal to all the
                        % previous, so we can check the remaining
                        
                    else
                        % This means that the values
                        % are not equal
                        if ~isempty(h)
                            % Set it to the default
                            % value
                            filltype = h.Type ;
                            switch filltype
                                case 'uicontrol'
                                    fillstyle = h.Style ;
                                    switch fillstyle
                                        case 'edit'
                                            h.String = '-' ;                                                                                       
                                        case 'popupmenu'
                                            h.Value = 1 ;                                                                
                                    end 
                                case 'uibuttongroup'

                            end
                        end
                        break;
                    end
                elseif isa(Value1,'double')
                    if strcmp(num2str(Value1), retainedvalue) && i == Housemax
                        % All houses have the same value
                        if ~isempty(h)
                            filltype = h.Type ;
                            switch filltype
                                case 'uicontrol'
                                    fillstyle = h.Style ;
                                    switch fillstyle
                                        case 'edit'
                                            h.String = '-' ;  
                                        case 'checkbox'
                                            h.Value = Value1;
                                        otherwise
                                    end 
                                case 'uibuttongroup'

                            end
                        end
                    else
                        if ~isempty(h)
                            % Set it to the default
                            % value
                            filltype = h.Type ;
                            switch filltype
                                case 'uicontrol'
                                    fillstyle = h.Style ;
                                    switch fillstyle
                                        case 'edit'
                                            h.String = '-' ;                                                                                       
                                        case 'popupmenu'   
                                        case 'checkbox'
                                            h.Value = 1 ;    
                                    end 
                                case 'uibuttongroup'

                            end
                        end
                    end
                elseif isa(Value1,'cell')

                end
            end
            retainedvalue = Value1 ;
            i = i + 1 ;
        end
        
    end %refill_uicontrol
%-------------------------------------------------------------------------%
    function CheckPanel(Panelname)
        if strcmp('uipanel',Panelname.Type)||strcmp('uicontainer',Panelname.Type)
            for i = 1:numel(Panelname.Children)
                CheckPanel(Panelname.Children(i))
            end
        else
            
        end
    end %CheckPanel
%-------------------------------------------------------------------------%
    function onHelp( src, ~ )
        % User has asked for the documentation
        Action = src.Text ;
        switch convertCharsToStrings(Action)
            case 'Contacts'
                open contacts.html
            case 'Feedbacks...'
                web('mailto:jean-nicolas.louis@oulu.fi');
            otherwise
                
        end
    end % onHelp
%-------------------------------------------------------------------------%
    function onDisplay(src,~)
        
        switch src.Text
            case 'User types'
                if strcmp(src.Checked,'on')
                    set(src,'Checked','off')
                else
                    set(src,'Checked','on')
                end
                Displayedhouse() ;
            case 'Filter...'
                FilterHouse()
            case 'Reset Filter'
                data.Filter = {'C1' 'C2' 'C3'};
                set(gui.ListBox,'string',data.Originalarray)
                data.Filtermode = 0;
                updateInterface() ;
                if numel(data.Originalarray) > 0
                    for i = 1:numel(data.Originalarray)
                        HouseSelected = data.Originalarray{i} ;
                        gui.(HouseSelected).Enable = 'on' ;
                    end
                end
            case 'Enable'
                if strcmp(get(src,'checked'),'on')
                    % Disactivating the enable mode
                    data.Filtermode = 0;
                    set(gui.ListBox,'string',data.Originalarray)
                    for i = 1:numel(data.Originalarray)
                        HouseSelected = data.Originalarray{i} ;
                        set(gui.(HouseSelected),'enable','on')
                    end
                    set(gui.ListBox,'value',1)
                else
                    % Activating the enable mode
                    data.Filtermode = 1;
                    
                    set(gui.ListBox,'string',data.Filterarray,'value',1)
                    StartFilter() ;
                    for i = 1:numel(data.Originalarray)
                        HouseSelected = data.Originalarray{i} ;
                        if find(strcmp(HouseSelected,data.Filterarray))
                            set(gui.(HouseSelected),'enable','on')
                        else
                            set(gui.(HouseSelected),'enable','off')
                        end
                    end
                end
                updateInterface() ;
            case 'Use variable long name'
                Var2Change = data.Var2Change ;
                if data.varlongname == 0
                    data.varlongname = 1 ;
                    gui.DisplayVarName.Checked = 'on' ;
        
                    for i = 1:length(Var2Change)
                        Varsource = Var2Change{i,1} ;
                        VarDestination = Var2Change{i,2} ;
                        datasource = data.(Varsource)(:) ;
                        NewList = cell(numel(datasource),1) ;
                        for ij = 1:numel(datasource)
                            Variablename = datasource{ij} ;
                            if ~strcmp(Variablename,'Select...')
                                LongNameVariable = data.varname.(Variablename).LongName ;
                            else
                                LongNameVariable = 'Select...' ;
                            end
                            NewList{ij} = LongNameVariable;
                        end
                        gui.(VarDestination).String = NewList ;
                    end
                else
                    data.varlongname = 0 ;
                    gui.DisplayVarName.Checked = 'off' ;
                    for i = 1:length(Var2Change)
                        gui.(Var2Change{i,2}).String = data.(Var2Change{i,1})(:) ;
                    end
                end
            case 'Report'               
                VarReport = fieldnames(data.VarReport) ;
%                if isempty(gui.ListBox.String)
%                    msgbox('No house to be saved','Information','help');
%                    return;
%                end
                choice = questdlg('Would you like to do?', ...
                                    'Report', ...
                                    'Report all houses','Report selected house(s)','Cancel','Cancel');
                for i = 1:numel(VarReport)
                    try
                        NameUD = data.VarReport.(VarReport{i}).NameUD ;
                    catch
                        NameUD = data.VarReport.(VarReport{i}).NameDefault ;
                    end
                    if isempty(NameUD)
                        NameUD = data.VarReport.(VarReport{i}).NameDefault ;
                    end
                    ToPopulate.(VarReport{i}) = NameUD;
                end
                switch choice
                    case 'Cancel'
                        return;
                    case 'Report all houses'
                        data.House2Report = gui.ListBox.String ;
                    case 'Report selected house(s)'
                        data.House2Report = gui.ListBox.String(gui.ListBox.Value) ;
                end
                
                Reporting_Housesv2(ToPopulate, data);
            case 'Delete all waiting bars'
                figHandles = findall(0, 'Tag', 'TMWWaitbar') ;
                delete(figHandles) ;
            case 'View map'
                gui.ViewPanel1.Selection = 2 ;
                gui.ViewPanel.Title = 'Map view' ;
            case 'View houses list'
                gui.ViewPanel1.Selection = 1 ;
                gui.ViewPanel.Title = 'House list view' ;
            otherwise
        end  
    end %onDisplay
%-------------------------------------------------------------------------%
    function FilterHouse()
        if numel(gui.ListBox.String) > 0 || numel(data.Originalarray) > 0
            Mfigpos = get(gui.Window,'OuterPosition') ;
            buttonwidth = 600 ;
            buttonheight = 200 ;
            gui.Filter = figure('units','pixels',...
                 'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                             Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                             buttonwidth,...
                             buttonheight],...
                 'toolbar','none',...
                 'menu','none',....
                 'name','Filter',....
                 'NumberTitle','off',...
                 'Tag','AddFigure',...
                 'CloseRequestFcn',@closeRequest);
            %set(gui.Filter,'WindowStyle','modal'); 
            % Draw the inside of the filter box
            FilterMain     = uix.HBox('Parent',gui.Filter,'Spacing', 5 ) ;
            FilterCriteria = uix.VBox('Parent',FilterMain,'Spacing', 5 ) ;
                % Add 3 buttons 'Add filter', 'Reset Filter', 'Cancel'
            Buttonfilter    = uix.HButtonBox('Parent',FilterCriteria,'Spacing', 5 ) ;
                gui.ApplyFilter = uicontrol('Parent',Buttonfilter,'Tag','ApplyFilter','String','Apply filter','Callback',@Filterbutton);
                gui.ResetFilter = uicontrol('Parent',Buttonfilter,'Tag','ResetFilter','String','Reset Filter','Callback',@Filterbutton);
                gui.Cancel = uicontrol('Parent',Buttonfilter,'Tag','Cancel','String','Cancel','Callback',@Filterbutton);
            
            FilterArrow    = uix.VButtonBox('Parent',FilterMain,'Spacing', 5 ) ;
            FilterSummary  = uix.VBox('Parent',FilterMain,'Spacing', 5 ) ;
            
            
           data.FilterC2 = Compareinputfields(data) ;
           
           if strcmp(gui.DisplayVarName.Checked,'on')
               AllFields = fieldnames(data.FilterC2) ;
               for i = 1:numel(fieldnames(data.FilterC2))
                    Variablename = AllFields{i} ;
                    if ~strcmp(Variablename,'Select...')
                        LongNameVariable = data.varname.(Variablename).LongName ;
                    else
                        LongNameVariable = 'Select...' ;
                    end
                    Eachfield(i,1) = strcat({LongNameVariable},{': '},{Variablename});
                end
           else
               Eachfield = fieldnames(data.FilterC2);
           end
           
           Eachfield = orderalphacellarray(Eachfield);
           Eachfield = [ { 'Select...' }; Eachfield ]; 
           
            gui.C1 = uicontrol('Parent',FilterCriteria,...
                           'Style','popup',...
                           'String',Eachfield(:),...
                           'Tag','C1',...
                           'Callback',@FilterSelection) ;
            gui.C2 = uicontrol('Parent',FilterCriteria,...
                           'Style','popup',...
                           'String','Select...',...
                           'Tag','C2',...
                           'visible','off',...
                           'Callback',@FilterSelection) ;
            gui.C3 = uicontrol('Parent',FilterCriteria,...
                           'Style','edit',...
                           'String','Select...',...
                           'Tag','C3',...
                           'visible','off',...
                           'KeyPressFcn',@FilterSelection,...
                           'Callback',@FilterSelection) ;
            gui.C4 = uicontrol('Parent',FilterCriteria,...
                           'Style','popup',...
                           'String','Select...',...
                           'Tag','C4',...
                           'visible','off',...
                           'Callback',@FilterSelection) ;
            
                       
            gui.Arrowplusbutton = uicontrol('Parent',FilterArrow,...
                            'string','-->',...
                            'Tag','Arrowplusbutton',...
                            'enable','off',...
                            'Callback',@FilterSelection) ;
            gui.Arrowminusbutton = uicontrol('Parent',FilterArrow,...
                            'string','<--',...
                            'Tag','Arrowminusbutton',...
                            'enable','off',...
                            'Callback',@FilterSelection) ;
            
            if isempty( data.Filter)
                str={'C1' 'C2' 'C3'}   ;
                data.Originalarray = gui.ListBox.String ;
            else
                % Fill the Filter in the uimultiocllist
                str = data.Filter ;
            end
                 
            gui.multicolumnFilter = uimulticollist('Parent',FilterSummary,...
                                  'string', str,...
                                  'tag','multicolumnFilter',...
                                  'Callback',@FilterSelection); 
                                          
            uimulticollist( gui.multicolumnFilter, 'setRow1Header', 'on' )
            uimulticollist( gui.multicolumnFilter, 'applyUIFilter', 'on' )
            
            jScrollPane = findjobj(gui.multicolumnFilter) ;
            jListbox = jScrollPane.getViewport.getComponent(0);
            jListbox = handle(jListbox, 'CallbackProperties');

            % Set the mouse-movement event callback
            set(jListbox, 'MouseMovedCallback', {@mouseMovedCallback,gui.multicolumnFilter});
            
            set(gui.Filter,'visible','on');                  
            set(FilterCriteria,'Heights',[40 30 30 30 30]);
            set(FilterArrow,'VerticalAlignment','middle');
            set(FilterMain,'Widths',[-4 -1 -4])
        end
         
    end %FilterHouse
%-------------------------------------------------------------------------%
    function Filterbutton(src,~)
        nbrrows = uimulticollist( gui.multicolumnFilter, 'nRows' );
        switch src.Tag
            case 'ResetFilter'
                if nbrrows > 1
                    data.Filter = {'C1' 'C2' 'C3'};
                    uimulticollist( gui.multicolumnFilter, 'string', data.Filter ) 
                end
                for i = 1:numel(data.Originalarray)
                    HouseSelected = data.Originalarray{i} ;
                    set(gui.(HouseSelected),'enable','on')
                end
                data.Filtermode = 0;
                updateInterface() ;
            case 'ApplyFilter'
                data.Filter = uimulticollist( gui.multicolumnFilter, 'string' );
                if nbrrows > 1
                    % Find each house that valid all the criteria set
                    % in the filtering box
                    StartFilter() ;
                else
                    data.Filtermode = 0 ;
                end
                updateInterface()
                 delete(gui.Filter);
                 return;
            case 'Cancel'
                delete(gui.Filter);
                data.ValidFilter = 0;
                return;
        end
    end %Filterbutton
%-------------------------------------------------------------------------%
    function StartFilter()
        data.Filterarray = {} ;
        for ii = 1:numel(data.Originalarray)
           % Loop through each house to check the applied filter
           HouseSelected = data.Originalarray{ii} ;
           for i = 2:size(data.Filter,1)
               C1_2check = data.Filter{i,1} ;
               C2_2check = data.Filter{i,2} ;
               C3_2check = data.Filter{i,3} ;

               getcontent = data.FilterC2.(C1_2check);

               if isa(getcontent,'cell')
                    %Input the cell straight to the C2 Filter
                    feedincontent = getcontent{:,2} ;
                    Comparecontent = getcontent{:,1} ;
                    row2extract = find(strcmp(feedincontent,C3_2check )) ;
                    C3_2check = Comparecontent{row2extract} ;
               else
                   C3_2check = data.Filter{i,3} ;
               end

               Housevalue = data.SummaryStructure.(HouseSelected).(C1_2check) ;
               if isnan(str2double(Housevalue))
                   compare = 'string' ;
               else
                   compare = 'double' ;
               end

               switch C2_2check
                   case 'Greater than (>)'
                       if strcmp(compare,'double')
                           if ~(str2double(Housevalue) > str2double(C3_2check))
                              break ; 
                           end
                       else
                           if ~strcmp(Housevalue, C3_2check)
                              break ; 
                           end    
                       end
                   case 'Smaller than (<)'
                       if strcmp(compare,'double')
                           if ~(str2double(Housevalue) < str2double(C3_2check))
                              break ; 
                           end
                       else
                           if ~strcmp(Housevalue, C3_2check)
                              break ; 
                           end    
                       end
                   case 'Equal (=)'
                       if strcmp(compare,'double')
                           if ~(str2double(Housevalue) == str2double(C3_2check))
                              break ; 
                           end
                       else
                           if ~strcmp(Housevalue, C3_2check)
                              break ; 
                           end    
                       end
                   case 'Greater or equal than (>=)'
                       if strcmp(compare,'double')
                           if ~(str2double(Housevalue) >= str2double(C3_2check))
                              break ; 
                           end
                       else
                           if ~strcmp(Housevalue, C3_2check)
                              break ; 
                           end    
                       end
                   case 'Smaller or equal than (<=)'
                       if strcmp(compare,'double')
                           if ~(str2double(Housevalue) <= str2double(C3_2check))
                              break ; 
                           end
                       else
                           if ~strcmp(Housevalue, C3_2check)
                              break ; 
                           end    
                       end
               end
               data.Filterarray{end+1} = HouseSelected; 
               set(gui.(HouseSelected),'enable','on')
           end
        end
        
        Houseoff = ~ismember(data.Originalarray,data.Filterarray') ;
        Houseoff = data.Originalarray(Houseoff) ;
        for i = 1 : numel(Houseoff)
            set(gui.(Houseoff{i}),'enable','off')
        end
        
        set(gui.ListBox,'string',data.Filterarray,'value',1)
        data.Filtermode = 1 ;
    end %StartFilter
%-------------------------------------------------------------------------%
    function FilterSelection(src,~)
        TagPushbutt = src.Tag ;
        switch TagPushbutt
            case 'C1'
                Selectedfilter = gui.C1.String{gui.C1.Value} ;
                if isempty(find(strcmp(data.varname(:,1),strtok(Selectedfilter,':'))))
                    try
                        Selectedfilter = data.varname{find(strcmp(data.varname(:,2),strtok(Selectedfilter,':'))),1} ;
                    catch
                        Selectedfilter = gui.C1.String{gui.C1.Value} ;
                    end
                else
                    Selectedfilter = gui.C1.String{gui.C1.Value} ;
                end
                if ~strcmp(Selectedfilter,'Select...')
                    getcontent = data.FilterC2.(Selectedfilter);
                    if isa(getcontent,'cell')
                        %Input the cell straight to the C2 Filter
                        set(gui.C3,'visible','off') ;
                        feedincontent = getcontent{:,2} ;
                        set(gui.C2,'String',feedincontent,'visible','on','Value',1);
                    else
                        Comparison = {'Select...';...
                                      'Greater than (>)';...
                                      'Smaller than (<)';...
                                      'Equal (=)';...
                                      'Greater or equal than (>=)';...
                                      'Smaller or equal than (<=)'};
                        switch getcontent
                            case 'Compare'        
                                set(gui.C2,'String',Comparison,'visible','on','Value',1);
                                set(gui.Arrowplusbutton,'enable','off')
                            case 'date'
                                set(gui.C2,'visible','off') ;
                                h = uicalendar('InitDate',now(),...
                                               'Weekend', [1 0 0 0 0 0 1], ...  
                                               'SelectionType', 1, ...  
                                               'DestinationUI', gui.C3,...
                                               'OutputDateFormat','dd/mm/yy');
                                uiwait()
                                set(h,'WindowStyle','modal');
                        end
                        set(gui.C3,'visible','on') ;
                        if ~strcmp(gui.C2.String{gui.C2.Value},'Select...')
                            set(gui.Arrowplusbutton,'enable','on')
                        else
                            set(gui.Arrowplusbutton,'enable','off')
                        end
                    end
                else
                    gui.C2.Value = 1;
                    gui.C3.String = 'Select...';
                end
            case 'C2'
                if ~strcmp(gui.C2.String{gui.C2.Value},'Select...')
                    if strcmp(gui.C3.Visible,'on')
                        if ~strcmp(gui.C3.String,'Select...')
                            set(gui.Arrowplusbutton,'enable','on')
                        end
                    else
                        set(gui.Arrowplusbutton,'enable','on')
                    end
                else
                    set(gui.Arrowplusbutton,'enable','off')
                end
            case 'C3'
                try
                    h = str2double(get(gui.C3,'string')) ;
                catch
                    set(gui.Arrowplusbutton,'enable','off')
                    return;
                end
                if isnan(h)
                    set(gui.Arrowplusbutton,'enable','off')
                    Messagein = 'Input must be numeric!' ;
                    uiwait(msgbox(Messagein,'Error','modal'));
                else
                    if ~strcmp(gui.C2.String{gui.C2.Value},'Select...')
                        if ~strcmp(gui.C2.String{gui.C2.Value},'Select...')
                            set(gui.Arrowplusbutton,'enable','on')
                        end
                    else
                        set(gui.Arrowplusbutton,'enable','off')
                    end
                end
            case 'Arrowplusbutton'
                % Check if the filter already exists
                nbrrows = uimulticollist( gui.multicolumnFilter, 'nRows' );
                Inputstr1 = gui.C1.String{gui.C1.Value} ;
                Inputstr2 = gui.C2.String{gui.C2.Value} ;
                Inputstr3 = gui.C3.String      ;
                str = uimulticollist( gui.multicolumnFilter, 'string' ) ;
                
                Selectedfilter = gui.C1.String{gui.C1.Value} ;
                
                if isa(data.varname,'cell')
                    comparray = data.varname(:,1) ;
                    LongName = data.varname(:,2) ;
                elseif isa(data.varname,'struct')
                    comparray = fieldnames(data.varname) ;
                    for ifield = 1:numel(comparray)
                        LongName{ifield} = data.varname.(comparray{ifield}).LongName ;
                    end
                end
                
                if isempty(find(strcmp(comparray,strtok(Inputstr1,':'))))
                    Inputstr1 = data.varname{find(strcmp(LongName,strtok(Inputstr1,':'))),1} ;
                else
                    Inputstr1 = gui.C1.String{gui.C1.Value} ;
                end
                getcontent = data.FilterC2.(Inputstr1);
                
                if isa(getcontent,'cell')
                    Inputstr3 = Inputstr2  ;
                    Inputstr2 = 'Equal (=)';
                end
                rowItems = {Inputstr1  Inputstr2  Inputstr3};
                if sum(strcmp(str(:,1),Inputstr1)) >= 1
                    % The Filter is already listed, check if the
                    % condition 2 is also rated. Create a temporary 
                    % new array to search
                    foundstr = strcmp(str(:,1),Inputstr1) ;
                    arrayapp = str((foundstr==1),:);
                    rowarray = find(foundstr==1);
                    if sum(strcmp(arrayapp(:,2),Inputstr2)) == 1
                        % this particular appliance already exist --> add
                        % the quantity selected to this row
                        row2modify = find(strcmp(arrayapp(:,2),Inputstr2)==1) ;
                        Originalrow = rowarray(row2modify) ;
                        uimulticollist(gui.multicolumnFilter, 'changeItem', Inputstr3, Originalrow, 3 )
                    else
                        % The appliance already exist but not with this
                        % specific rating. Add the appliance with a
                        % different rating as a new line
                        row2modify = find(strcmp(arrayapp(:,1),Inputstr1)==1) ;
                        Originalrow = rowarray(row2modify) ;
                        uimulticollist(gui.multicolumnFilter, 'changeItem', Inputstr2, Originalrow, 2 )
                        uimulticollist(gui.multicolumnFilter, 'changeItem', Inputstr3, Originalrow, 3 )
                    end
                else                    
                    uimulticollist(gui.multicolumnFilter, 'addRow', rowItems , 2 )
                end
            case 'Arrowminusbutton'
                %uimulticollist( gui.multicolumnFilter, 'delRow', RowSelected )
                
                selectedrow = get( gui.multicolumnFilter, 'Value' ) ;
                if selectedrow > 1
                    set(gui.multicolumnFilter, 'Value',1 ) ;
                    uimulticollist( gui.multicolumnFilter, 'delRow', selectedrow )
                    str = uimulticollist( gui.multicolumnFilter, 'string' ) ;
                    [srow,~] = size(str) ;
                    if srow==1
                         set(gui.Arrowminusbutton,'enable','off')
                    end
                end
            case 'multicolumnFilter'
                RowSelected = get( gui.multicolumnFilter, 'Value');
                if RowSelected > 1
                    set(gui.Arrowminusbutton,'enable','on')
                else
                    set(gui.Arrowminusbutton,'enable','off')
                end
        end
    end %FilterSelection

%-------------------------------------------------------------------------%
function mouseMovedCallback(jListbox, jEventData, hListbox)
   % Get the currently-hovered list-item
   mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
   hoverIndex = jListbox.locationToIndex(mousePos) + 1 ;
   listValues = uimulticollist(hListbox,'selectedString') ;
   hoverValue = listValues{hoverIndex};
 
   % Modify the tooltip based on the hovered item
   msgStr = sprintf(hoverValue);
   set(hListbox, 'Tooltip',msgStr);
end  % mouseMovedCallback
%-------------------------------------------------------------------------%
    function Errormessage(Inputstr)
        Mfigpos = get(gui.Window,'OuterPosition') ;
            buttonwidth = 600 ;
            buttonheight = 200 ;
            gui.ErrorMessage = figure('units','pixels',...
                 'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                             Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                             buttonwidth,...
                             buttonheight],...
                 'toolbar','none',...
                 'menu','none',....
                 'name','Filter',....
                 'NumberTitle','off',...
                 'Tag','AddFigure',...
                 'CloseRequestFcn',@closeRequest);
             
         Messagein = str2html(Inputstr,'colour','black') ; 
         
         mainmessage = uix.VBox('Parent',gui.ErrorMessage,'Spacing', 5 ) ;
         OkBox = uix.HButtonBox('Parent',mainmessage,'Spacing', 5 ) ;
         
         uicontrol('Parent',mainmessage,...
                   'Style','text',...
                   'String',Messagein)
         uicontrol('Parent',OkBox,...
                   'Style','pushbutton',...
                   'String','Ok')
         
         uiwait()
            
    end
%-------------------------------------------------------------------------%
    function Displayedhouse()
        for i = 1:numel(gui.ListBox.String)
            HouseSelected = gui.ListBox.String{i} ;
            Newhousepos = get(gui.(HouseSelected),'position') ;
            sizeimage = min(Newhousepos(3),Newhousepos(4)) ;   
            if strfind(gui.(HouseSelected).UserData,'NonSelected')
                GetUserType = data.SummaryStructure.(HouseSelected).User_Type ;
                [FileName] = LogoHouse(GetUserType) ;
            else
                FileName = 'House_Logo_red.png';
            end
            originalimage = imread(FileName);
            a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
            a = im2uint8(a) ;
            set(gui.(HouseSelected), 'cdata',a);
        end
    end %Displayedhouse
%-------------------------------------------------------------------------%
    function onEdit( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        switch src.Label
            case 'Copy'
                
            case 'Add'
                addhousing() ;
            case 'Delete'
                deletehousing();
            case 'Import' 
        end
    end % onEdit
%--------------------------------------------------------------------------%
    function [Nbr_Building,TypeofBuilding] = HouseType
        %h = findobj('Tag','Start');

        h = [];
        % if exists (not empty)
        if ~isempty(h)
            % get handles and other user-defined data associated to Gui1
            g1data = guidata(h);
            Nbr_Building = str2double(get(g1data.Nbr_Building,'String'));
            TypeofBuilding = get(g1data.Elec_ContractEC,'String');
            TypeSelected = get(g1data.Elec_ContractEC,'Value');
            TypeofBuilding = TypeofBuilding{TypeSelected};
            % maybe you want to set the text in Gui2 with that from Gui1
            %set(handles.text1,'String',get(g1data.edit1,'String'));

            % maybe you want to get some data that was saved to the Gui1 app
            %x = getappdata(h,'x');
        else
            %Put here the code if Start doesnot exist
            %fprintf(1,'\n Warning: This section is under development - does not exist yet\n\n');
            Nbr_Building = 1;
            TypeofBuilding = 'Detached House';
        end
    end % HouseType
%--------------------------------------------------------------------------%
    function rightclickbutton(src,~)
      figHandle = ancestor(src, 'figure');

      clickType = get(figHandle, 'SelectionType');
        
      if strcmp(clickType, 'alt')

          %c = uicontextmenu(gui.ViewPanel);

      end
    end %rightclickbutton
%--------------------------------------------------------------------------%
    function Butt1action_Callback( src, ~)
       AllButtons = get(gui.Buttonmenu,'children') ;
       Panel2Look = erase(src.Tag,'cbutt') ;
       cbuttpos = get(src,'position') ;
       sizeimage = min(cbuttpos(3),cbuttpos(4)) ;
       if src.Value == 0
           src.Value = 1;
       end
      
       for i = 1:numel(AllButtons)
            if strcmp(AllButtons(i).Tag,src.Tag)
                %Load the blue logo of the button
                image2loadblue = strcat(Panel2Look,'_icon_blue.png') ;
                try
                    originalimage = imread(image2loadblue);
                catch
                    continue;
                end
                a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                a = im2uint8(a) ;
                set(src, 'cdata',a);
                src.Value = 1;
            else
                image2loadblue = strcat(erase(AllButtons(i).Tag,'cbutt'),'_icon_Black.png') ;
                try
                    originalimage = imread(image2loadblue);
                catch
                    continue;
                end
                a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                a = im2uint8(a) ;
                set(AllButtons(i), 'cdata',a);
                AllButtons(i).Value = 0;
            end
       end
       % Show the correct panel
        for j = 1:numel(gui.p.Children)
            if strcmp(strcat('Panel',Panel2Look),gui.p.Contents(j).Tag)
                gui.p.Selection = j ;
                break
            end
        end      
    end
%--------------------------------------------------------------------------%
    function drawbuttons()
        Butt1action_Callback(gui.cbuttdatesetting);
    end %drawbutton
%--------------------------------------------------------------------------%
    function Date_Callback(src,~)
        UI2feed = erase(src.Tag,'_button') ;

        if contains(src.Tag,'_button')
            % If the date button is pressed then open the calendar, else
            % accept the date as it is.

            user_entry = get(gui.(UI2feed),'string');
            usecase = dateseparator(user_entry) ;
            
            user_entrysplit = strsplit(user_entry,usecase) ;
            
            if numel(user_entrysplit) == 3
                tokenNames.year  = user_entrysplit{3} ;
                tokenNames.month = user_entrysplit{2} ;
                tokenNames.day   = user_entrysplit{1} ;
            else 
                errordlg('Invalid Input Format. Date must include day, month, and year','Error Message','modal')
                uicontrol(gui.(UI2feed))
                Outputdate = datenum(2012,1,1) ;
                Formatout = ['dd',usecase,'mm',usecase,'yyyy'] ;
                Outputdatstr = datestr(Outputdate,Formatout) ;
                gui.(UI2feed).String = Outputdatstr ;
                return
            end
            
            [FormatoutDT,FormatoutDS] = getformatDate(tokenNames,usecase) ;
            
            h = uicalendar('InitDate',datetime(user_entry,'InputFormat',FormatoutDT),...
               'Weekend', [1 0 0 0 0 0 1], ...  
               'SelectionType', 1, ...  
               'DestinationUI', gui.(UI2feed),...
               'OutputDateFormat',FormatoutDS);
            uiwait(h);
        end
        
       [Outputdatstr,OutDateNum] = checkdateentry(gui.(UI2feed)) ;
       
       gui.(UI2feed).String = Outputdatstr ;
        
       Inputdate = OutDateNum ;
       
       if strcmp(UI2feed,'StartingDate')
            SDate = OutDateNum ;
            [~,EDate] = checkdateentry(gui.EndingDate) ;
       elseif  strcmp(UI2feed,'EndingDate')
            EDate = OutDateNum ;
            [~,SDate] = checkdateentry(gui.StartingDate) ;
       end
       
       if SDate > EDate
           set(gui.StartingDate,'ForegroundColor','red') ;
           set(gui.EndingDate,'ForegroundColor','red') ;
       else
           set(gui.StartingDate,'ForegroundColor','black') ;
           set(gui.EndingDate,'ForegroundColor','black') ;
       end
       
       if ~isempty(gui.ListBox.String)
           for i=1:numel(gui.ListBox.Value)
               House2save = gui.ListBox.String{gui.ListBox.Value(i)} ;
               SaveData(UI2feed,House2save,Inputdate)
           end
           UpdateAllTip
       end
    end %uicalendar
%--------------------------------------------------------------------------%
    function checkboxDS_Callback(src,~)
        if src.Value == 1
            set(gui.ListBox,'enable','off') ;
        else
            set(gui.ListBox,'enable','on') ;
        end
    end %checkboxDS_Callback
%--------------------------------------------------------------------------%
    function ContextMenuResponse(src,~,thisObject)
        
%         Tag = thisObject.Tag  ; 
        switch src.Tag
            case 'Delete'
                deletehousing()
            case 'AddHouses'
                addhousing() ;
            case 'AppSauna'
            case 'AppWashMach'
            case 'RandOne'
                Houses2generate = {thisObject.Tag}; % Houses2generate = gui.ListBox.String(gui.ListBox.Value) ; % JARI'S CHANGE
                Generateappliances(Houses2generate)
                MessageIn = 'All appliances were generated successfully' ;
                uiwait(msgbox(MessageIn,'Add','modal'));
                % JARI'S ADDITION
                Value = find(strcmp(gui.ListBox.String,thisObject.Tag)==1);     % JARI
                gui.ListBox.Value = Value;                                      % JARI
                % END OF JARI'S ADDITION
                onListSelection( gui.ListBox) ;
            case 'RandAll'
                Houses2generate = gui.ListBox.String ;
                Generateappliances(Houses2generate)
                MessageIn = 'All appliances were generated successfully' ;
                uiwait(msgbox(MessageIn,'Add','modal'));
                onListSelection( gui.ListBox) ;
        end
    end %ContextMenuResponse
%--------------------------------------------------------------------------%
    function Generateappliances(HouseList)
        for i = 1:numel(HouseList)
            % Get the number of appliances
            Inh = data.SummaryStructure.(HouseList{i}).inhabitants ;
            if strcmp(Inh,'Select...')
                data.SummaryStructure.(HouseList{i}).inhabitants = '1';
                Inh = 1 ;
            else
                Inh = str2double(Inh) ;
            end
            MaxAppQtyReport = 0 ;
            %Loop through each appliance
            for ij = 1:size(data.AppliancesList,1)
                ApplianceSel = data.AppliancesList{ij,1} ;
                Appliancerate = data.AppliancesList{ij,2} ;
                ApplianceCode = data.AppliancesList{ij,3} ;
                AppliancerateCode = data.AppliancesList{ij,4} ;
                
                MaxQty = data.ApplianceMax{find(strcmp(ApplianceSel,data.ApplianceMax(:,1))==1),Inh+1} ;
                MinQty = 0;
                AppQty = fix(((MaxQty - MinQty + 1) * rand()) + MinQty) ;
                
                if AppQty > 0
                    for appqty = 1:AppQty
                        AppQtyReport(appqty) = {'1'}; 
                    end
                    switch Appliancerate
                        case 'Rate'
                            if ~strcmp(ApplianceSel,'Lighting System')
                                MinQty = 2;
                                MaxQty = numel(data.Rating);
                                for apprate = 1:AppQty
                                    AppRatetmp = fix(((MaxQty - MinQty + 1) * rand()) + MinQty) ;
                                    AppRatetmp = data.Rating{AppRatetmp} ;
                                    AppRate(apprate) = {AppRatetmp}; 
                                end
                            else
                                MinQty = 2;
                                MaxQty = numel(data.Lightopt);
                                for apprate = 1:AppQty
                                    AppRatetmp = fix(((MaxQty - MinQty + 1) * rand()) + MinQty) ;
                                    AppRatetmp = data.Lightopt{AppRatetmp} ;
                                    AppRate(apprate) = {AppRatetmp}; 
                                end
                            end
                                
                        case 'None'
                        otherwise
                    end
                else
                    AppQtyReport(1) = {'0'}; 
                    switch Appliancerate
                        case 'Rate'
                            if ~strcmp(ApplianceSel,'Lighting System')
                                AppRate(1) = {'A or B class'}; 
                            else
                                AppRate(1) = {'Low consumption bulbs'};  
                            end
                        case 'None'
                            
                        otherwise
                    end
                end
                if ~isempty(AppliancerateCode)
                    data.SummaryStructure.(HouseList{i}).(AppliancerateCode) = AppRate ;
                end
                if ~isempty(ApplianceCode)
                    data.SummaryStructure.(HouseList{i}).(ApplianceCode) = AppQtyReport ;
                end
                MaxAppQtyReport = MaxAppQtyReport + numel(AppQtyReport) ;
                AppRate = {} ;
                AppQtyReport = {} ;
            end
            SaveData('Appliance_Max',HouseList{i},MaxAppQtyReport) ;
        end
    end %Generateappliances
%--------------------------------------------------------------------------%
    function deletehousing()
        Houses2Delete = gui.ListBox.String(gui.ListBox.Value) ;
        for i = 1:numel(Houses2Delete)
            Tag = Houses2Delete{i} ;
            Housenumber = Tag ;
            data.HouseList(strcmpi(data.HouseList,Housenumber)) = [] ;

            h = gui.(Housenumber) ;
            delete(h);
            data.SummaryStructure = rmfield(data.SummaryStructure,Housenumber) ;
            removefromlist = find(strcmp(data.Originalarray,Housenumber)) ;
            data.Originalarray(removefromlist) = [];
            redrawviewing('rescale') ;
        end

        if isempty(data.HouseList)
            set(gui.SettingOpt,'visible','off') ;
        else
            if isempty(data.HouseList{1})
                set(gui.SettingOpt,'visible','off') ;
            else
                onListSelection( gui.ListBox) ;
            end
        end
        
    end %deletehousing
%--------------------------------------------------------------------------%
    function [FileName] = LogoHouse(UserType)
        if strcmp(gui.DisplayUT.Checked,'on')
            switch UserType
                case '1'
                    FileName = 'House_Logo_Green.png' ;
                case '2' 
                    FileName = 'House_Logo_Orange.png' ;
                case '3' 
                    FileName = 'House_Logo_Brown.png' ;
                otherwise
                    FileName = 'House_Logo_Black.png' ;
            end
        else
            FileName = 'House_Logo_Black.png' ;
        end
    end %LogoHouse
%--------------------------------------------------------------------------%
    function addhousing()
        Mfigpos = get(gui.Window,'OuterPosition') ;
        buttonwidth = 250 ;
        buttonheight = 50 ;
        gui.AddDialog = figure('units','pixels',...
             'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                         Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                         buttonwidth,...
                         buttonheight],...
             'toolbar','none',...
             'menu','none',....
             'name','Add',....
             'NumberTitle','off',...
             'Tag','AddFigure',...
             'CloseRequestFcn',@closeRequest);
         set(gui.AddDialog,'WindowStyle','modal')
         %movegui(gui.AddDialog,'center')
         set(gui.AddDialog, 'Resize', 'off');

         DivideVert = uix.Grid('Parent',gui.AddDialog) ;

         uicontrol('Parent',DivideVert,'Style','popup','String', {'Detached house','Appartment building'})
         gui.NbrBuilding2Add = uicontrol('Parent',DivideVert,...
                                         'Style','edit',...
                                         'String', '1',...
                                         'Tag','NbrBuilding2Add',...
                                         'KeyPressFcn',@ButtonAdd_KeyPress) ;
                                     
         uicontrol('Parent',DivideVert,...
                   'Style','pushbutton',...
                   'String', 'Ok',...
                   'Tag','Ok',...
                   'Callback',@ButtonAdd,...
                   'Value',1,...
                   'KeyPressFcn',@ButtonAdd)
         uicontrol('Parent',DivideVert,...
                   'Style','pushbutton',...
                   'String', 'Cancel',...
                   'Tag','Cancel',...
                   'Callback',@ButtonAdd)
         
         set( DivideVert, 'Widths', [-1 -1], 'Heights', [-1 -1] );        
         
         uiwait(gcf);
         Buttonnumber = numel(gui.Housedrawing.Children)  + 1 ;
         if Buttonnumber > 1
             for i = 1:(Buttonnumber-1)
                Butt2Change = gui.Housedrawing.Children(i) ;
                Newhousepos = get(Butt2Change,'position') ;
                Newhousetag = get(Butt2Change,'UserData') ;
                sizeimage = min(Newhousepos(3),Newhousepos(4)) ; 
                GetUserType = data.SummaryStructure.(Butt2Change.Tag).User_Type ;
                FileName = LogoHouse(GetUserType);
                originalimage = imread(FileName);
                a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                a = im2uint8(a) ;
                set(Butt2Change, 'cdata',a);
                Butt2Change.Value = 0;
                
                newStr = strrep(Newhousetag,'_Selected','_NonSelected') ;
                set(Butt2Change,'UserData',newStr)
             end
         end
         if data.ValidAdd == 1
            if data.Addbuilding > 0
                waitwindow = waitbar(0,'Creating new houses','Name','Creating Houses...',...
                                     'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                setappdata(waitwindow,'canceling',0);
                
                if getappdata(waitwindow,'canceling')
                    delete(waitwindow)
                    return
                end
                
                spacecell = {' '} ;

                AddedNewhouses{data.Addbuilding,1} = {} ;
                for i = 1:data.Addbuilding
                    Message = strcat({'Creating house number'},spacecell,{num2str(i)},{'/'},{num2str(data.Addbuilding)}) ;
                    waitbar(i/(data.Addbuilding),waitwindow,Message)
                    
                    Buttonnumber = numel(gui.Housedrawing.Children)  + 1 ;
                    part = 1 ;
                    if ~isempty(data.HouseList)
                        if ~isempty(data.HouseList{1})
                            while part == 1
                                existinlist = sum(ismember(data.HouseList,strcat('House ',num2str(Buttonnumber)))) ;
                                if existinlist == 0
                                    data.HouseList{end+1} = strcat('House ',num2str(Buttonnumber)) ;
                                    part = 0 ;
                                else
                                    Buttonnumber = Buttonnumber + 1;
                                end 
                            end
                        else
                            data.HouseList{1} = strcat('House ',num2str(Buttonnumber)) ;
                        end
                    else
                        data.HouseList{1} = strcat('House ',num2str(Buttonnumber)) ;
                    end
                     Newstr = strcat('House ',num2str(Buttonnumber)) ;
                     gui.(Newstr) = uicontrol( 'Parent', gui.Housedrawing,...
                                           'callback',@Housebutton,...
                                           'backgroundcolor',[230/255 230/255 230/255],...
                                           'Tag',Newstr,...
                                           data.ToolTipString,Newstr,...
                                           'UserData',strcat(Newstr,'_Selected'));
                     set(gui.SettingOpt,'visible','on') ;
                     [SummaryStructureTemp] = createHouse(Newstr, Buttonnumber, data) ;
                     
                     data.SummaryStructure.(Newstr) = SummaryStructureTemp.(Newstr) ;
                     
                     [~,Tip] = createStrToolTip(data.SummaryStructure.(Newstr),'') ;
                     set(gui.(Newstr),data.ToolTipString,Tip);
                     
                     redrawviewing('')
                     
                     Newhousepos = get(gui.(Newstr),'position') ;
                     sizeimage = min(Newhousepos(3),Newhousepos(4)) ;                  
                        originalimage = imread('House_Logo_Red.png');
                        a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                        a = im2uint8(a) ;
                        set(gui.(Newstr), 'cdata',a);
                        gui.(Newstr).Value = 0;
                     % Create the context menu for all new houses
                     makeContextMenuItem(gui.(Newstr))
                     AddedNewhouses{i} = Newstr ;
                end
                redrawviewing('rescale')
                if data.Addbuilding == 1
                    MessageIn = strcat(num2str(data.Addbuilding), ' house was added succesfully') ;
                else
                    MessageIn = strcat(num2str(data.Addbuilding), ' houses were added succesfully') ;
                end
                uiwait(msgbox(MessageIn,'Add','modal'));
                OrigArray = data.Originalarray ; 
                data.Originalarray = [OrigArray; AddedNewhouses] ;
                delete(waitwindow) ;
            end
         end
    end %addhousing
%--------------------------------------------------------------------------%
    function redrawviewing(Rescale)
        SizeSetting = 30 ;

                     TotalHousing = numel(gui.Housedrawing.Children) ;
        if TotalHousing > 0
                     HouseWidth = ceil(sqrt(TotalHousing));
                     HouseHeight = ceil(TotalHousing / HouseWidth) ;

                     Widtharray(1:HouseWidth) = SizeSetting;
                     Heightarray(1:(HouseHeight)) = SizeSetting;

                     TotalWidth = sum(Widtharray) + (numel(Widtharray)-1)*5 ;
                     TotalHeight = sum(Heightarray) + (numel(Heightarray)-1)*5;
                     
                     set(gui.Housedrawing,'Widths', Widtharray, 'Heights',Heightarray);

                if strcmp(Rescale,'rescale')
                    set( gui.ScrollPanelView, ...
                         'Widths', TotalWidth, ...
                         'Heights', TotalHeight, ...
                         'HorizontalOffsets', 100, ...
                         'VerticalOffsets', 100 );
                end
        end
        set(gui.ListBox,'Value',1:numel(data.HouseList));
        set(gui.ListBox,'String', data.HouseList(:)) ;
    end %redrawviewing
%--------------------------------------------------------------------------%
    function Housebutton(src,Event)
        Buttonnumber = numel(get(src.Parent,'children')) ;
        Buttonframe = src.Parent ;

        if numel( gui.ListBox.Value) == 1 || strcmp(Event.EventName,'Action') 
            for i = 1:Buttonnumber
                Butt2Change = Buttonframe.Children(i) ;
                TagcurrentHouse = get(Butt2Change,'UserData') ;
                if strcmp(src.UserData,TagcurrentHouse)
                    k = strfind(TagcurrentHouse,'_NonSelected') ;
                    if k > 0
                        Newhousepos = get(Butt2Change,'position') ;
                        sizeimage = min(Newhousepos(3),Newhousepos(4)) ;                  
                        originalimage = imread('House_Logo_Red.png');
                        a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                        a = im2uint8(a) ;
                        set(Butt2Change, 'cdata',a);
                        Butt2Change.Value = 0;

                        newStr = strrep(TagcurrentHouse,'_NonSelected','_Selected') ;
                        set(Buttonframe.Children(i),'UserData',newStr)
                    end
                else
                    k = strfind(TagcurrentHouse,'_Selected') ;
                    if k > 0
                        Newhousepos = get(Butt2Change,'position') ;
                        sizeimage = min(Newhousepos(3),Newhousepos(4)) ;   
                        GetUserType = data.SummaryStructure.(Butt2Change.Tag).User_Type ;
                        FileName = LogoHouse(GetUserType);
                        originalimage = imread(FileName);
                        a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                        a = im2uint8(a) ;
                        set(Butt2Change, 'cdata',a);
                        Butt2Change.Value = 0;

                        newStr = strrep(TagcurrentHouse,'_Selected','_NonSelected') ;
                        set(Buttonframe.Children(i),'UserData',newStr)
                    end
                end
            end
            Housenbr = erase(src.UserData,'_NonSelected') ;
            Housenbr = erase(Housenbr,'_Selected') ;
            fd = ismember(data.HouseList,Housenbr) ;
            data.SelectedDemo = find(fd,1) ;
            % JARI'S ADDITIONS
            gui.ListBox.Value = find(strcmp(gui.ListBox.String,Housenbr));
            updateView();
            % END OF ADDITIONS
            updateInterface();
        elseif numel( gui.ListBox.Value) > 1
            RedHouse{numel( gui.ListBox.Value)} = {} ;
            for i = 1:numel( gui.ListBox.Value)
                RedHouse(i) = gui.ListBox.String(gui.ListBox.Value(i)) ;
            end
            for i = 1:Buttonnumber
                Butt2Change = Buttonframe.Children(i) ;
                TagcurrentHouse = get(Butt2Change,'UserData') ;
                if sum(ismember(strcat(RedHouse,'_NonSelected'),TagcurrentHouse))
                    Newhousepos = get(Butt2Change,'position') ;
                    sizeimage = min(Newhousepos(3),Newhousepos(4)) ;                  
                    originalimage = imread('House_Logo_Red.png');
                    a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                    a = im2uint8(a) ;
                    set(Butt2Change, 'cdata',a);
                    Butt2Change.Value = 0;

                    newStr = strrep(TagcurrentHouse,'_NonSelected','_Selected') ;
                    set(Buttonframe.Children(i),'UserData',newStr)
                elseif ~sum(ismember(strcat(RedHouse,'_Selected'),TagcurrentHouse))
                    k = strfind(TagcurrentHouse,'_Selected') ;
                    if k > 0
                        Newhousepos = get(Butt2Change,'position') ;
                        sizeimage = min(Newhousepos(3),Newhousepos(4)) ; 
                        GetUserType = data.SummaryStructure.(Butt2Change.Tag).User_Type ;
                        FileName = LogoHouse(GetUserType);
                        originalimage = imread(FileName);
                        a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                        a = im2uint8(a) ;
                        set(Butt2Change, 'cdata',a);
                        Butt2Change.Value = 0;

                        newStr = strrep(TagcurrentHouse,'_Selected','_NonSelected') ;
                        set(Buttonframe.Children(i),'UserData',newStr)
                    end
                end
                
            end
            % JARI'S ADDITIONS
            if numel(gui.ListBox.Value) == 1
                gui.ListBox.Value = find(strcmp(gui.ListBox.String,Housenbr));
                updateView();
            else
                updateView();
            end
            % END OF ADDITIONS
        end
    end %Housebutton
%--------------------------------------------------------------------------%
    function onMenuSelection(src,~)
        data.SelectedDemo = src.Position ;
        % Hilghlight the correct button
            Houseselected = data.HouseList{data.SelectedDemo} ;
            selectedhouse = gui.(Houseselected) ;
            if isempty(selectedhouse)
                selectedhouse = findobj(gui.Housedrawing,'UserData',strcat(Houseselected,'_Black')) ;
            end
            Housebutton(selectedhouse)
        updateInterface();
    end %onMenuSelection
%--------------------------------------------------------------------------%
    function ButtonAdd_KeyPress(src,eventdata)
        if strcmp(eventdata.Key,'return')
            ButtonAdd(src,'1') ;
        else
            % Get the new value in the edit box
           [DataOut] = ed_kpfcn(src,eventdata) ;
            data.Buttonadd = DataOut ;
            if isnan(str2double(data.Buttonadd))
                % This is a character
                data.Buttonadd = '0' ;
            end
        end
    end %ButtonAdd_KeyPress 
%--------------------------------------------------------------------------%
    function ButtonAdd(src,~)
        
        Buttonpushed = src.Tag ;
        
        switch Buttonpushed
            case 'Cancel'
                delete(gui.AddDialog);
                data.ValidAdd = 0;
                return;
            case {'Ok', 'NbrBuilding2Add'}
                data.ValidAdd = 1;
                try
                    nbrbuilding = data.Buttonadd ;
                catch
                    nbrbuilding = gui.NbrBuilding2Add.String ;
                end
                
                data.Addbuilding = str2double(nbrbuilding);
                delete(gui.AddDialog);
        end
    end %ButtonAdd
%--------------------------------------------------------------------------%
    function closeRequest(src,~)
        ButtonName = questdlg('Close window?', ...
                         'Close Check', ...
                         'Yes', 'No','No');
        switch ButtonName
            case 'Yes'
                data.ValidAdd = 0;
                delete(src);
            case 'No'
                return
        end
    end %closeRequest
%--------------------------------------------------------------------------%
    function ContractSetting(src,~)
        if isempty(gui.ListBox.String)||isempty(gui.ListBox.String{1})
            return;
        end
        
        HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        GetSource = src.Tag; 
        ContractTime = gui.Contract ;
        MinPrice = gui.Low_Price ;
        MaxPrice = gui.High_Price ;
        ContractType = gui.ContElec ;
        
        switch GetSource
            case 'ContElec'
                ContractSelected = src.String(src.Value) ;
                if strcmpi(data.PriceList{2},ContractSelected)
                    %Disable the pricetime options
                    set(ContractTime,'enable','off')
                    set(MinPrice,'enable','on')
                    set(MaxPrice,'enable','on')
                    ContractSetting(MinPrice) ;
                    ContractSetting(MaxPrice) ;
                elseif strcmpi(data.PriceList{1},ContractSelected)
                    set(ContractTime,'enable','off')
                    set(MinPrice,'enable','off')
                    set(MaxPrice,'enable','off')
                    ContractSetting(ContractTime) ;
                else
                    %Enable the pricetime options
                    set(ContractTime,'enable','on')
                    set(MinPrice,'enable','off')
                    set(MaxPrice,'enable','off')
                    ContractSetting(ContractTime) ;
                end
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   SaveData(GetSource,HouseTag,ContractSelected)
                end
            case 'Contract'
                ContractSelected = src.String(src.Value) ;
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   SaveData(GetSource,HouseTag,ContractSelected)
                end
            case 'Low_Price'
                ContractSelected = src.String ;
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   SaveData(GetSource,HouseTag,ContractSelected)
                end
            case 'High_Price'
                ContractSelected = src.String ;
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   SaveData('High_Price',HouseTag,ContractSelected)
                end
        end
        
        UpdateAllTip
        
    end %ContractSetting
%--------------------------------------------------------------------------%
    function radiobutton_Callback(src,~)
       if ~isempty(gui.ListBox.String)
           UserColour = erase(src.String,' User') ;
           switch UserColour
               case 'Green'
                   Usertype = 1;
               case 'Orange'
                   Usertype = 2;
               case 'Brown'
                   Usertype = 3;
           end
           for i=1:numel(gui.ListBox.Value)
               House2save = gui.ListBox.String{gui.ListBox.Value(i)} ;
               SaveData('User_Type',House2save,Usertype)
           end
           UpdateAllTip
       end
    end % radiobutton_Callback
%--------------------------------------------------------------------------%
    function UserProfile(src,~)
        ProfileList = get(src,'String');
        ProfileSelected = get(src,'Value');
        ProfileSelected = ProfileList{ProfileSelected};

        GetPath = mfilename('fullpath');
        ParentFolder = GetPath(1:max(strfind(GetPath,filesep)));

        switch ProfileSelected
            case 'Profile 1'
                filename = 'Profile1.png';
                Prof2Save = 1;
            case 'Profile 2'
                filename = 'Profile2.png';
                Prof2Save = 2;
            otherwise
                filename = 'NoProfile.png';
                Prof2Save = 1;
        end

        var=strcat(ParentFolder,'Images',filesep,filename);
        ORI_IMG=imread(var);
        
        if ishandle( gui.AxesFigure )
            delete( gui.AxesFigure );
        end
        
        fig = figure( 'Visible', 'off' );
        gui.AxesFigure = gca();
        set(gui.AxesFigure,'Units','normalized','position',[0 0 1 1]);
        set(gui.AxesFigure,'Units','pixels');
        
        resizePos = get(gui.AxesFigure,'Position');
        ORI_IMG = imresize(ORI_IMG, [resizePos(4) resizePos(4)]);
        imshow(ORI_IMG);
        
        cmap = colormap( gui.AxesFigure );
        set( gui.AxesFigure, 'Parent', gui.MainPanelUsertypes );
        
        set(gui.AxesFigure,'Units','normalized','position',[0 0 1 1]);
        
        colormap( gui.AxesFigure, cmap );
        
%         axis(gui.AxesFigure);
        close( fig );
        
        if ~isempty(gui.ListBox.String)
            if ~isempty(gui.ListBox.String{1})
                for i=1:numel(gui.ListBox.Value)
                   House2save = gui.ListBox.String{gui.ListBox.Value(i)} ;
                   SaveData('Profile',House2save,Prof2Save)
                end
                UpdateAllTip
            end
        end
        
    end % UserProfile 
%--------------------------------------------------------------------------%
    function UpdateAllTip()
        HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        for i = 1:numel(HouseSelected)
           HouseTag =  HouseSelected{i} ;
           [~,Tip] = createStrToolTip(data.SummaryStructure.(HouseTag),'') ;
           h = gui.(HouseTag);
           set(h,data.ToolTipString,Tip);
        end
    end %UpdateAllTip
%--------------------------------------------------------------------------%
    function SaveData(Field2Save,HouseTag,NewValue)
        %%% Put a * next to the title to say that the new data were input
        TitleName = get(gui.Window,'Name') ;
        if ~contains(TitleName,'*')
            TitleName = [TitleName,'*']        ;
            set(gui.Window,'Name',TitleName)   ;
        end
        %Update the handle
        if iscell(HouseTag)
            for i = 1:size(HouseTag,1)
                HouseNbr = HouseTag{i} ;
                %%%%%HouseNbr = find(contains(handles.SummaryStructure.Headers,HouseNumber{i}));
                %HouseNbr = str2double(replace(HouseNumber{i},'House',''));
                if strcmp(data.varname.(Field2Save).Comparefield,'date')
                    NewValue = datestr(NewValue,'dd/mm/yyyy') ;
                    data.SummaryStructure.(HouseNbr).(Field2Save) = NewValue;
                    data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;
                else
                    if iscell(NewValue)
                        if numel(NewValue) > 1
                            data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;
                            data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue ;
                        else
                            data.SummaryStructure.(HouseTag).(Field2Save) = NewValue{1};
                            data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue{1};
                        end
                    elseif isa(NewValue,'double')
                        data.SummaryStructure.(HouseNbr).(Field2Save) = num2str(NewValue);
                        data.varname.(Field2Save).UserDefValue.(HouseTag) = num2str(NewValue);
                    elseif isempty(NewValue)
                        data.SummaryStructure.(HouseNbr).(Field2Save) = '';
                        data.varname.(Field2Save).UserDefValue.(HouseTag) = '';
                    else
                        data.SummaryStructure.(HouseNbr).(Field2Save) = NewValue;
                        data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;
                    end
                end
            end
        elseif isa(HouseTag,'char')
            %HouseNumber = find(contains(handles.SummaryStructure.Headers,strcat('House',num2str(HouseNumber))));
            
            
            if strcmp(data.varname.(Field2Save).Comparefield,'date')
                    NewValue = datestr(NewValue,'dd/mm/yyyy') ;
                    data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;
                    data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;
            else
                if iscell(NewValue)
                                % JARI'S ADDITION
%                     if any(strcmp(data.AppliancesList(:,3),Field2Save) == 1)            % J % Addition of number of appliances
%                         if numel(NewValue) == 1
%                         ApplianceAddition = 1;                                          % J
%                         data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;       % J
%                         data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;   % J
%                         else                                                                % J
%                             % If the addition should be the sum of the
%                             % values in the cell! Conversely it can be
%                             % numel
%                             data.SummaryStructure.(HouseTag).(Field2Save) = {num2str(sum(str2double(NewValue)))};       % J
%                             data.varname.(Field2Save).UserDefValue.(HouseTag) = {num2str(sum(str2double(NewValue)))};   % J
%                             % If the value is supposed to the be first
%                             % number!
% %                             data.SummaryStructure.(HouseTag).(Field2Save) = NewValue(1);       % J
% %                             data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue(1);   % J
%                         end                                                                     % J
%                     elseif any(strcmp(data.AppliancesList(:,4),Field2Save) == 1)                % J     % Addition of the class of the appliance
%                         if numel(NewValue) == 1                                         % J
%                         ApplianceAddition = 1;                                          % J
%                         data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;       % J
%                         data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;   % J
%                         else                                                            % J
%                             data.SummaryStructure.(HouseTag).(Field2Save) = NewValue(1);       % J
%                             data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue(1);   % J
%                         end                                                             % J
%                     else                                                                % J
                    if numel(NewValue) > 1
                        data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;
                        data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;
                    else
                      if any(strcmp(data.AppliancesList(:,3),Field2Save) == 1) || any(strcmp(data.AppliancesList(:,4),Field2Save) == 1)           % J
                        data.SummaryStructure.(HouseTag).(Field2Save) = NewValue(1);        % J
                        data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue(1);    % J
                      else                                                                  % J
                        data.SummaryStructure.(HouseTag).(Field2Save) = NewValue{1};
                        data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue{1};
                      end                                                                   % J
                    end
%                     end                                                                 % J
                elseif isa(NewValue,'double')
                    data.SummaryStructure.(HouseTag).(Field2Save) = num2str(NewValue);
                    data.varname.(Field2Save).UserDefValue.(HouseTag) = num2str(NewValue);
                elseif isempty(NewValue)
                    data.SummaryStructure.(HouseTag).(Field2Save) = '';
                    data.varname.(Field2Save).UserDefValue.(HouseTag) = '';
                else
                    data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;
                    data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;
                end
            end
        else
            HouseNbr = str2double(erase('House',HouseTag));
            data.SummaryStructure.(Field2Save){HouseNbr+1} = NewValue;
            data.SummaryStructure.(Field2Save){HouseNbr+1} = NewValue;
        end
    end %SaveData
%--------------------------------------------------------------------------%
    function [spintfsplitstr,splitstrhtml] = createStrToolTip(str,header)
        LengthTip = data.TipToolLength ;
        if isa(str,'string')
            nbrofline = ceil(strlength(str) / (LengthTip * 10)) ;
            splitstr = split(str);
            
            possible2reshape = ceil(size(splitstr,1) / nbrofline) ;

            Increasecell = possible2reshape * nbrofline;

            if possible2reshape* nbrofline > size(splitstr,1)
                for i = (size(splitstr,1)+1):Increasecell
                    splitstr{i} = '' ;
                end
            end

            splitstr = reshape(splitstr,possible2reshape,nbrofline)';
            splitstr = string(splitstr) ;
            splitstr = join(splitstr);      

            %Create Sprintf version
             rowToInsert = 1;
             rowVectorToInsert = header ;
             spintfsplitstr = [splitstr(1:rowToInsert-1,:); rowVectorToInsert; splitstr(rowToInsert:end,:)];
             spintfsplitstr = join(spintfsplitstr,'\n');
            %Create html version 
            splitstrhtml = join(splitstr,'<br />');

            splitstrhtml = strcat('<html><b>',header,'</b><br />',splitstrhtml,'</html>');
        elseif isa(str,'char')
            str = convertCharsToStrings(str);
            [spintfsplitstr,splitstrhtml] = createStrToolTip(str,header) ;
        elseif isa(str,'struct')
            fields = fieldnames(str) ;
            splitstrhtml = '<html>' ;
            for i = 1:numel(fields)
                if isa(str.(fields{i}),'double')
                    arg = num2str(str.(fields{i})) ;
                elseif isa(str.(fields{i}),'cell')
                    arg = {''} ;
                    for ii = 1:numel(str.(fields{i}))
                        arg = strcat(arg,{' '},str.(fields{i})(ii)) ;
                    end
                    arg = arg{1} ;
                else
                    arg = str.(fields{i}) ;
                end
                str2input = strcat('<br>',fields{i},': ',arg,'</br>') ;
                splitstrhtml = strcat(splitstrhtml,str2input);
            end
            spintfsplitstr = '' ;
            splitstrhtml = strcat(splitstrhtml,'</html>');
        end
    end %createStrToolTip
%-------------------------------------------------------------------------%
    function AddApplianceCallback(src,~)
        if numel(gui.ListBox.String) > 0 || numel(data.Originalarray) > 0
            buttonpushed = src.Tag ;      
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
            switch buttonpushed
                case 'AddAppliance'
                    Mfigpos = get(gui.Window,'OuterPosition') ;
                    buttonwidth = 250 ;
                    buttonheight = 150 ;
                    gui.AddAppDialog = figure('units','pixels',...
                         'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                     Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                     buttonwidth,...
                                     buttonheight],...
                         'toolbar','none',...
                         'menu','none',....
                         'name','Add appliances',....
                         'NumberTitle','off',...
                         'Tag','AddFigure',...
                         'CloseRequestFcn',@closeRequest);
                     set(gui.AddAppDialog,'WindowStyle','modal')
                     %
                     %movegui(gui.AddDialog,'center')
                     set(gui.AddAppDialog, 'Resize', 'off');

                     DivideVert = uix.VBox('Parent',gui.AddAppDialog) ;

                     AppList = data.AppliancesList(:,1);

                     n = 1 ;
                     ToInsert = 'Select appliance...';
                     AppList(n+1:end+1,:) = AppList(n:end,:);
                     AppList(n,:) = {ToInsert};
                     AppList = orderalphacellarray(AppList,2,numel(AppList));

                     gui.popupApp = uicontrol('Parent',DivideVert,...
                               'Style','popup',...
                               'String', AppList,...
                               'Tag','popupApp',...
                               'Callback',@AddApplianceCall) ;
                     gui.popupRate = uicontrol('Parent',DivideVert,...
                               'Style','popup',...
                               'Tag','popupRate',...
                               'String','Select...',...
                               'Callback',@AddApplianceCall);
                     gui.popupQty = uicontrol('Parent',DivideVert,...
                               'Style','popup',...
                               'Tag','popupQty',...
                               'String',{'1' '2' '3' '4' '5' 'more...' '0'},...
                               'Callback',@AddApplianceCall);
                     uix.Empty('Parent',DivideVert) ;

                     buttonbox =  uix.HBox('Parent',DivideVert) ; 
                     uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Ok','Tag','Ok','Callback',@AddApplianceCall)
                     uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Cancel','Tag','Cancel','Callback',@AddApplianceCall)

                     set( DivideVert,'Heights', [-1 -1 -1 -.5 -1] );        

                     uiwait(gcf);
                     str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                     [srow,~] = size(str) ;
                     if srow>1
                         set(gui.RemoveAppliance,'enable','on')
                     end
                case 'RemoveAppliance'
                    selectedrow = get( gui.multicolumnApp, 'Value' ) ;
                    if selectedrow > 1
                        selectedqty = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,3) ;
                        selectedRank = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,2) ;
                        selectedAppliance = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,1) ;
                        selectedApplianceCode = find(strcmp(data.AppliancesList(:,1), selectedAppliance));
                        Rank = data.AppliancesList{selectedApplianceCode,3} ;
                        Rankclass = data.AppliancesList{selectedApplianceCode,4} ;

                        selectedqty = cellfun(@str2num,selectedqty,'un',0) ;
                        selectedqty = selectedqty{:};
                        if selectedqty > 1
                            selectedqty = selectedqty - 1 ;
                            Newqty = num2str(selectedqty) ; 
                            uimulticollist(gui.multicolumnApp, 'changeItem', Newqty, selectedrow, 3 )
                        else
                            set(gui.multicolumnApp, 'Value',1 ) ;
                            uimulticollist( gui.multicolumnApp, 'delRow', selectedrow )
                            str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                            [srow,~] = size(str) ;
                            if srow==1
                                 set(gui.RemoveAppliance,'enable','off')
                            end
                            Newqty = '0' ;
                        end
                        if str2double(Newqty) >= 1
                            for i = 1:numel(HouseSelected)
                                HouseTag =  HouseSelected{i} ;
                                data.SummaryStructure.(HouseTag).(Rank) = data.SummaryStructure.(HouseTag).(Rank)(1:str2double(Newqty)) ;
                                % Jari's removal!
%                                 RemoveRankRow = find(strcmp(selectedRank,data.SummaryStructure.House3.clOven)==1) ;
%                                 RemoveRankRow = RemoveRankRow(1) ;
                                if isempty(Rankclass)                                   % J
                                    continue                                            % J
                                else                                                    % J
                                    RemoveRankRow = find(strcmp(selectedRank,data.SummaryStructure.(HouseTag).(Rankclass))==1) ;    % J
                                    RemoveRankRow = RemoveRankRow(1) ;                                                              % J
                                    data.SummaryStructure.(HouseTag).(Rankclass)(:,RemoveRankRow) = [] ;                            % J
                                end                                                                                                 % J
                            end
                        else
                            for i = 1:numel(HouseSelected)
                                HouseTag =  HouseSelected{i} ;
%                                 data.SummaryStructure.(HouseTag).(Rank) = str2double(Newqty) ;
                                % Jari's Addition!!
                                data.SummaryStructure.(HouseTag).(Rank) = {Newqty};                     % J
                                if strcmp(Rank,'Elecheat') == 1 || strcmp(Rank,'Sauna') == 1 || strcmp(Rank,'Elec') == 1    % J
                                    continue                                                                    % J
                                else                                                                            % J
                                    data.SummaryStructure.(HouseTag).(Rankclass){1,1} = 'A or B class' ;
                                end                                                                             % J
                            end
                        end
                    end
            end
            str = uimulticollist( gui.multicolumnApp, 'string' ) ;
            AppMax = 0 ;
            for i = 1:size(str,1)
                if ~(i == 1)
                    Appout = str2double(str{i,3}) ;
                    AppMax = AppMax + Appout ;
                end
            end
            for i = 1:numel(HouseSelected)
                HouseTag =  HouseSelected{i} ;
                SaveData('Appliance_Max',HouseTag,AppMax)
            end
        end
    end %AddApplianceCallback
%--------------------------------------------------------------------------%
    function AddApplianceCall(src,~)
        Source = get(src,'Tag') ;
        if numel(gui.ListBox.String) > 0
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
            switch Source
                case 'popupApp'
                    SelectedValue = src.String{src.Value} ;
                    popupRateobj = gui.popupRate ;
                    switch SelectedValue
                        case 'Select appliance...'
                            %Reset the ratings
                            set(popupRateobj,'string','Select...') ;
                            if get(popupRateobj,'value') > 1
                                set(popupRateobj,'value',1);
                            end
                        otherwise
                            PositionApp = find(strcmp(data.AppliancesList(:,1), SelectedValue));
                            Rank = data.AppliancesList{PositionApp,2} ;
                            if strcmp(SelectedValue,'Lighting System')
                                str = data.Lightopt;
                            else
                                switch Rank
                                    case SelectedValue
                                    case 'Rate'
                                        str = data.Rating(:) ;
                                    case 'None'
                                        str = {'Select...','-'};
                                        set(popupRateobj,'value',2);
                                end
                            end
                            set(popupRateobj,'string',str) ;
                            if get(popupRateobj,'value') > 2
                                set(popupRateobj,'value',1);
                            end
                    end
                case 'popupRate'
                case 'popupQty'
                    if strcmp(src.String{src.Value},'more...')
                        Mfigpos = get(gui.AddAppDialog,'OuterPosition') ;
                        buttonwidth = 250 ;
                        buttonheight = 150 ;
                        gui.AddQtyDlg = figure('units','pixels',...
                             'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                         Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                         buttonwidth,...
                                         buttonheight],...
                             'toolbar','none',...
                             'menu','none',....
                             'name','Add appliances',....
                             'NumberTitle','off',...
                             'Tag','AddFigure',...
                             'CloseRequestFcn',@closeRequest);
                         set(gui.AddQtyDlg,'WindowStyle','modal')
                         %
                         %movegui(gui.AddDialog,'center')
                         set(gui.AddQtyDlg, 'Resize', 'off');

                         DivideVert = uix.VBox('Parent',gui.AddQtyDlg) ;
                         uicontrol('Parent',DivideVert,'Style','text','string','Add Quantity') ;
                         gui.NewQty = uicontrol('Parent',DivideVert,'Style','edit','string','Add Quantity','Tag','NewQty') ;

                         buttonbox =  uix.HBox('Parent',DivideVert) ; 
                         uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Ok','Tag','Ok','Callback',@AddNewQtyCall)
                         uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Cancel','Tag','Cancel','Callback',@AddNewQtyCall)
                    end
                case 'Ok'
                    %Check if all inputs are valid
                    Check1 = gui.popupApp ;
                        Inputstr1 = Check1.String(Check1.Value) ;
                        if strcmp(Inputstr1,'Select appliance...') 
                            uiwait(msgbox('Please select an appliance','Error','modal'));
                            return;
                        end
                    Check2 = gui.popupRate ;
                        Inputstr2 = Check2.String(Check2.Value) ;
                        if strcmp(Inputstr2,'Select...') || strcmp(Inputstr2,'S')
                            uiwait(msgbox('Please select category','Error','modal'));
                            return;
                        elseif strcmp(Inputstr2,'-')
                        end
                    Check3 = gui.popupQty ;
                        Inputstr3 = Check3.String(Check3.Value) ;
                    % Get the data from the multi column list to compare them
                    % with thenew input data
                    str = uimulticollist( gui.multicolumnApp, 'string' ) ;

                    if sum(strcmp(str(:,1),Inputstr1)) >= 1
                        % The appliance is already listed, check if the rating
                        % is also rated. Create a temporary new array to search
                        foundstr = strcmp(str(:,1),Inputstr1) ;
                        arrayapp = str((foundstr==1),:);
                        rowarray = find(foundstr==1);
                        if sum(strcmp(arrayapp(:,2),Inputstr2)) == 1
                            % this particular appliance already exist --> add
                            % the quantity selected to this row
                            row2modify = find(strcmp(arrayapp(:,2),Inputstr2)==1) ;
                            Originalrow = rowarray(row2modify) ;
                            Originalqty = arrayapp(row2modify,3) ;
                            Newqty = str2double(Originalqty) + str2double(Inputstr3) ;
                            Newqty = num2str(Newqty) ;
                            uimulticollist(gui.multicolumnApp, 'changeItem', Newqty, Originalrow, 3 )
                        else
                            % The appliance already exist but not with this
                            % specific rating. Add the appliance with a
                            % different rating as a new line
                            rowItems = [Inputstr1, Inputstr2, Inputstr3] ;
                            uimulticollist(gui.multicolumnApp, 'addRow', rowItems , 2 )
                        end
                    else
                        rowItems = [Inputstr1, Inputstr2, Inputstr3] ;
                        uimulticollist(gui.multicolumnApp, 'addRow', rowItems , 2 )
                    end
                    for i = 1:numel(HouseSelected)
                       HouseTag =  HouseSelected{i} ;

                       str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                       [srow,~] = size(str) ;
                        if srow>1
                            % Save only the appliance just recorded

                            Appliance = strcmp(Inputstr1,str(:,1)) ;
                            codeAppliance = data.AppliancesList{find(strcmp(Inputstr1,data.AppliancesList(:,1))==1),3} ;
                            classAppliance = data.AppliancesList{find(strcmp(Inputstr1,data.AppliancesList(:,1))==1),4} ;
                            if sum(Appliance) > 0
                                QtyAppAll = {str{find(Appliance==1),3}} ;
                                ApprateAll = {str{find(Appliance==1),2}} ;
                                NewDataQty = {}; 
                                NewDataRate = {};

                                for AppQty = 1:sum(Appliance)
                                    QtyApp = str2double(QtyAppAll{AppQty}) ;
                                    Apprate = ApprateAll{AppQty} ;
%                                                                     % JARI'S ADDITION!
%                                 if QtyApp == 0                          % J
%                                     NewDataQty = {'0'};                     % J
%                                     NewDataRate = ApprateAll(1);        % J
%                                 else                                    % J
                                    for AppQtyRank = 1:QtyApp
                                        NewDataQty = [NewDataQty {'1'}] ;
                                        NewDataRate = [NewDataRate {Apprate}] ;
                                    end
                                end
%                                 end                                 % J
                                if ~isempty(codeAppliance)
                                    SaveData(codeAppliance,HouseTag,NewDataQty)
                                end
                                if ~isempty(classAppliance)
                                    SaveData(classAppliance,HouseTag,NewDataRate)
                                end
                                MaxApp = maxAppcount(HouseTag) ;
                                SaveData('Appliance_Max',HouseTag,MaxApp)
                            end
                        end

                    end
                    UpdateAllTip

                    delete(gui.AddAppDialog);
                case 'Cancel'
                    delete(gui.AddAppDialog);
                    data.ValidAdd = 0;
                otherwise
            end
        end
    end %AddApplianceCall
%--------------------------------------------------------------------------%
    function MaxApp = maxAppcount(HouseTag)
        MaxApp = 0;
        for I = 1:size(data.AppliancesList,1)
            AppName = data.AppliancesList{I,3} ;
            if isempty(AppName)
                % This ,eams tjat tjos os the lighting system
                continue;
            end
            % JARI'S ADDITION
%             if strcmp(data.SummaryStructure.(HouseTag).(AppName),'0') % J
%                 continue        % J
%             else                % J
%                 MaxApp = MaxApp + str2double(data.SummaryStructure.(HouseTag).(AppName));   % J
%                 % IS THERE A REASON WHY THE APPLIANCES ARE HANDLED BY THE
%                 % NUMBER OF CELLS AND NOT BY THE NUMBER IN THE CELL?
%                 % ORIGINAL STARTS!
            MaxApp = MaxApp + numel(data.SummaryStructure.(HouseTag).(AppName)) ;
                % ORIGINAL ENDS!
%             end                 % J
        end
    end
%--------------------------------------------------------------------------%
    function AddNewQtyCall(src,~)
        Source = get(src,'Tag') ;
        obj2 = gui.popupQty ;
        obj = gui.NewQty ;
        switch Source
            case 'Ok'
                if isnan(str2double(obj.String))
                    uiwait(msgbox('Please enter a numeric value','Error','modal'));
                    return;
                elseif str2double(obj.String) <=0 
                    uiwait(msgbox('Please enter a positive amount of appliances','Error','modal'));
                    return;
                else
                    AppList = obj2.String ;
                    n = 6 ;
                    ToInsert = obj.String;
                    PositionApp = find(strcmp(AppList(:), ToInsert)) ;
                    if isempty(PositionApp)
                        AppList(n+1:end+1,:) = AppList(n:end,:);
                        AppList(n,:) = {ToInsert};
                    end
                    AppListnum = cellfun(@str2num,{AppList{1:(numel(AppList)-1)}},'un',0).' ;
                    AppList(1:(numel(AppList)-1)) = AppListnum ;
                    AppList = orderalphacellarray(AppList);
                    AppList = cellfun(@num2str,AppList ,'un',0) ;
                    set(obj2,'string',AppList) ;
                    PositionApp = find(strcmp(AppList, ToInsert)) ;
                    set(obj2,'value',PositionApp)
                    delete(gui.AddQtyDlg);
                end
            case 'Cancel'
                delete(gui.AddQtyDlg);
                set(obj2,'value',1)
        end
    end %AddNewQtyCall
%--------------------------------------------------------------------------%
    function ControlOpt(src,~)
        if ~isempty(gui.ListBox.String)           
           for i=1:numel(gui.ListBox.Value)
               House2save = gui.ListBox.String{gui.ListBox.Value(i)} ;
               SaveData(src.Tag,House2save,src.Value)
           end
           UpdateAllTip
       end
    end %
%-------------------------------------------------------------------------%
    function nMinimize_HD( src, ~, whichpanel,LimitHeight )
        SelectedCard = gui.p.Contents(gui.p.Selection) ;
        n = 0;
        SelectedBoxes = SelectedCard.Children;
        while n == 0
            if strcmp(SelectedBoxes(1).Type,'uipanel')
                n = 1 ;
               SelectedPanel = SelectedBoxes(1).Parent ;
               NbrPanel = numel(SelectedBoxes) ;
            else
                SelectedBoxes = SelectedBoxes.Children ;
            end
        end
        
        SelectedBox = SelectedBoxes(whichpanel);
        
        if contains(src.(data.ToolTipString),'this panel')
            pheightmin = 23 ;
        elseif isempty(SelectedBox.Children)
            if ~SelectedBox.Minimized
                pheightmin = 23 * 2 ;
            else
                pheightmin = 23 ;
            end
        else
            ActiveComponent = SelectedBox.Children.Children(2).Contents.Value ;
            if ~SelectedBox.Minimized
                if ActiveComponent
                    pheightmin = 150 ;
                else
                    pheightmin = 23 * 2 ;    
                end
            else
                pheightmin = 23 ;
            end
        end
        PanelRealOrder = NbrPanel - whichpanel + 1 ;
        
        switch LimitHeight
            case 'Limit'
                if whichpanel == 1
                    pheightmax = -1 ;
                else
                    [pheightmax] = PanelinnerSizeSSP(SelectedBox) ;
                    pheightmax = max(pheightmax,pheightmin) ;
                end
            case 'NoLimit'
                pheightmax = -1 ;
        end
        s = get( SelectedPanel, 'Heights' );
        pos = get( gui.Window, 'Position' );
        if contains(src.(data.ToolTipString),'this panel')
            pheightmin = 23 ;
            % If we want to minimize or maximise the panel
            panel{whichpanel}.Minimized = SelectedBox.Minimized;
            if panel{whichpanel}.Minimized
                % Expand the Panel
                s(PanelRealOrder) = pheightmax;
                set(SelectedBox,'Minimized',false);
            else
                % Minimize the Panel
                s(PanelRealOrder) = pheightmin; 
                set(SelectedBox,'Minimized',true);
            end 
            set( SelectedPanel, 'Heights', s );
        else
            % If we want just to adjust the size of the panels
            s(PanelRealOrder) = pheightmax;
            set( SelectedPanel, 'Heights', s );
        end
        pos = get( SelectedPanel, 'Position' );
        TotalHeight = 0;
        for i = 1:NbrPanel
            TotalHeight = TotalHeight + max(pheightmin,SelectedBoxes(i).Position(4));
        end
        TotalHeight = TotalHeight + 10 ;
        set( SelectedCard.Children, ...
                         'Heights', TotalHeight);
    end % Minimize 
%-------------------------------------------------------------------------%
    function File(src,~)
       if isa(src,'char')
           textsrc = src;
       elseif isa(src,'matlab.ui.container.Menu')
           textsrc = src.Text ;
       end
       switch textsrc
           case 'Exit'
               try
                  data.SummaryStructure ;
               catch
                  delete(gui.Window) ;
                  close all;
                  delete(findall(0));
                  return;
               end
               % First ask if you want to save the file before closing the
               % app
               answer = questdlg('Do you want to save the file before exiting?',...
                                  'Quit',...
                                  'Yes','No','Cancel','Yes') ;
               switch answer
                   case 'Yes'
                       SaveAll = findobj(src.Parent.Children,'Text','Save all') ;
                       File(SaveAll)
                       switch data.Exit
                           case 'Saved'
                               delete(gui.Window) ;
                               close all;
                               delete(findall(0));
                           case 'Cancel'
                               return;
                       end
                   case 'No'
                       delete(gui.Window) ;
                       close all;
                       delete(findall(0));
                   case 'Cancel'
                       return;
               end
           case 'Save all'
               TitleName = get(gui.Window,'Name') ;
               TitleName = erase(TitleName,'*')   ;
               set(gui.Window,'Name',TitleName)   ;
               try
                  AllData = data.SummaryStructure ;
               catch
                  data.Exit = 'Saved' ; 
                  return; 
               end
               %See if it has already been saved
               if isempty(data.savedname)
                   % It has not been save yet
                   filter = {'*.xml'};
                   [file, path] = uiputfile(filter);
                   %%%                   
                    if isequal(file,0) || isequal(path,0)
                       data.Exit = 'Cancel' ;
                       return;
                    else
                       data.Exit = 'Saved' ;
                    end
                   
                   SaveFullPath = strcat(path,file); 
                   fn = SaveFullPath ;
                   data.savedname = fn ;
               else
                   fn = data.savedname ;
               end
               %Loop through each house
               Housenumber = fieldnames(AllData);
               if isempty(Housenumber)
                   msgbox('No house to be saved','Information','help');
                   return;
               end
               Eachfield = fieldnames(AllData.(Housenumber{1}));
               for i = 1:numel(Eachfield)
                   MaxValue = 1;
                   if strcmp(Eachfield{i},'Oven')
                           x = 1;
                   end
                   for ii = 1:numel(Housenumber)
                       if ~isa(AllData.(Housenumber{ii}).(Eachfield{i}),'char')
                           if isa(AllData.(Housenumber{ii}).(Eachfield{i}),'cell')
                                MaxValue = max(MaxValue,size(AllData.(Housenumber{ii}).(Eachfield{i}),2)) ;
                           end
                       else                 % Jari's addition
                           if any(strcmp(Eachfield{i},data.AppliancesList(:,3)) == 1) || any(strcmp((Eachfield{i}),data.AppliancesList(:,4))==1)    % J
                               if isa(AllData.(Housenumber{ii}).(Eachfield{i}),'char')                                                              % J 
                                   % If value for appliance is a char
                                   % change it to a cell! J
                                   AllData.(Housenumber{ii}).(Eachfield{i}) = {AllData.(Housenumber{ii}).(Eachfield{i})};                           % J
                                   % Assign same char value in to the cell.
                                   MaxValue = max(MaxValue,size(AllData.(Housenumber{ii}).(Eachfield{i}),2)) ;                                      % J
                               end                                                                                                                  % J
                           end                                                                                                                      % J
                       end                                                                                                                          
                   end
                   % Restructure the variable for saving it
                   s.(Eachfield{i}){1,MaxValue} = {};
               end
               for i = 1:numel(Housenumber)
                   data.Simulationdata.(Housenumber{i}) = AllData.(Housenumber{i}) ;
                   % Restructure the variable for saving it
                   for ii = 1:numel(Eachfield)
                       % Restructure the variable for saving it
                       if strcmp(Eachfield{ii},'Charger')
                           x = 1;
                       end
                       if isa(AllData.(Housenumber{i}).(Eachfield{ii}),'cell')
                           MaxApp = 0 ;
                           for jjHouse = 1:numel(Housenumber)
                               MaxApp = max(MaxApp,size(AllData.(Housenumber{jjHouse}).(Eachfield{ii}),2)) ;
                           end
                           for ij = 1:MaxApp
                               if ij <= size(AllData.(Housenumber{i}).(Eachfield{ii}),2)
                                    s.(Eachfield{ii}){i,ij} = AllData.(Housenumber{i}).(Eachfield{ii}){1,ij};
                               else
                                    s.(Eachfield{ii}){i,ij} = '0' ;
                               end
                           end
                       else
                           s.(Eachfield{ii}){i,1} = AllData.(Housenumber{i}).(Eachfield{ii});
                       end
                   end
               end
               data.Simulationdata = AllData ;
               sXML = strcut2XMLStruct(s)    ;
               struct2xml(sXML,fn) ;
               %struct2csv(s,fn)
               % uiwait(msgbox('File saved successfully','Information','modal'));
           case 'Save selected as...'
               HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
               CurrentSavingName = data.savedname ;
               data.savedname = '' ;
               try
                  AllData = data.SummaryStructure ;
               catch
                  return; 
               end
               %See if it has already been saved
               if isempty(data.savedname)
                   % It has not been save yet
                   filter = {'*.xml'};
                   [file, path] = uiputfile(filter);
                   %%%
                   if path == 0; return; end
                   SaveFullPath = strcat(path,filesep,file); 
                   fn = SaveFullPath ;
                   data.savedname = fn ;
               else
                   fn = data.savedname ;
               end
               %Loop through each house
               
               Housenumber = HouseSelected;
               if isempty(Housenumber)
                   msgbox('No house to be saved','Information','help');
                   return;
               end
               Eachfield = fieldnames(AllData.(Housenumber{1}));
               for i = 1:numel(Eachfield)
                   MaxValue = 1;
                   for ii = 1:numel(Housenumber)
                       if ~isa(AllData.(Housenumber{ii}).(Eachfield{i}),'char')
                           if isa(AllData.(Housenumber{ii}).(Eachfield{i}),'cell')
                                MaxValue = max(MaxValue,size(AllData.(Housenumber{ii}).(Eachfield{i}),2)) ;
                           end
                       else                 % Jari's addition
                           if any(strcmp(Eachfield{i},data.AppliancesList(:,3)) == 1) || any(strcmp((Eachfield{i}),data.AppliancesList(:,4))==1)    % J
                               if isa(AllData.(Housenumber{ii}).(Eachfield{i}),'char')                                                              % J 
                                   % If value for appliance is a char
                                   % change it to a cell! J
                                   AllData.(Housenumber{ii}).(Eachfield{i}) = {AllData.(Housenumber{ii}).(Eachfield{i})};                           % J
                                   % Assign same char value in to the cell.
                                   MaxValue = max(MaxValue,size(AllData.(Housenumber{ii}).(Eachfield{i}),2)) ;                                      % J
                               end                                                                                                                  % J
                           end                                                                                                                      % J
                       end
                   end
                   % Restructure the variable for saving it
                   s.(Eachfield{i}){1,MaxValue} = {};
               end
               
                for i = 1:numel(Housenumber)
                   data.Simulationdata.(Housenumber{i}) = AllData.(Housenumber{i}) ;
                   % Restructure the variable for saving it
                   for ii = 1:numel(Eachfield)
                       % Restructure the variable for saving it
                       if strcmp(Eachfield{ii},'Charger')
                           x = 1;
                       end
                       if isa(AllData.(Housenumber{i}).(Eachfield{ii}),'cell')
                           MaxApp = 0 ;
                           for jjHouse = 1:numel(Housenumber)
                               MaxApp = max(MaxApp,size(AllData.(Housenumber{jjHouse}).(Eachfield{ii}),2)) ;
                           end
                           for ij = 1:MaxApp
                               if ij <= size(AllData.(Housenumber{i}).(Eachfield{ii}),2)
                                    s.(Eachfield{ii}){i,ij} = AllData.(Housenumber{i}).(Eachfield{ii}){1,ij};
                               else
                                    s.(Eachfield{ii}){i,ij} = '0' ;
                               end
                           end
                       else
                           s.(Eachfield{ii}){i,1} = AllData.(Housenumber{i}).(Eachfield{ii});
                       end
                   end
               end
               sXML = strcut2XMLStruct(s)    ;
               struct2xml(sXML,fn) ;
%                struct2csv(s,fn)
               data.savedname = CurrentSavingName ;
                uiwait(msgbox('Selected houses saved successfully','Information','modal'));
           case 'Save file as...'
               data.savedname = '' ;
               SaveAll = findobj(src.Parent.Children,'Text','Save all') ;
               File(SaveAll)
           case 'Save each house individually'
               TitleName = get(gui.Window,'Name') ;
               TitleName = erase(TitleName,'*')   ;
               set(gui.Window,'Name',TitleName)   ;
               
               CurrentSavingName = data.savedname ;
               data.savedname = '' ;
               try
                  AllData = data.SummaryStructure ;
               catch
                  return; 
               end
               %See if it has already been saved
               if isempty(data.savedname)
                   % It has not been save yet
                   filter = {'*.xml'};
                   [file, path] = uiputfile(filter);
                   %%%
                   if path == 0; return; end
                   if strcmp(path(end),filesep)
                       SaveFullPath = [path,file] ;
                   else
                       SaveFullPath = [path,filesep,file];
                   end
                   filenocsv = erase(file,'.xml') ;
                   fn = SaveFullPath ;
                   data.savedname = fn ;
               else
                   fn = data.savedname ;
               end
               %Loop through each house
               
               Housenumber = fieldnames(AllData);
               Eachfield = fieldnames(AllData.(Housenumber{1}));
               for i = 1:numel(Eachfield)
                   % Restructure the variable for saving it
                   s.(Eachfield{i}) = {};
               end
               for i = 1:numel(Housenumber)
                   fn = strcat(filenocsv,'_',AllData.(Housenumber{i}).Headers,'.csv') ;
                   if strcmp(path(end),filesep)
                       fn = [path,fn] ;
                   else
                       fn = [path,filesep,fn];
                   end
                   % Restructure the variable for saving it
                   for ii = 1:numel(Eachfield)
                       % Restructure the variable for saving it
                       if isempty(s.(Eachfield{ii}))
                           s.(Eachfield{ii}){1,1} = AllData.(Housenumber{i}).(Eachfield{ii});
                       else
                           s.(Eachfield{ii}){1,1} = AllData.(Housenumber{i}).(Eachfield{ii});
                       end
                   end
                   sXML = strcut2XMLStruct(s)    ;
                   struct2xml(sXML,fn) ; 
%                    struct2csv(s,fn)
               end
               uiwait(msgbox(strcat(num2str(numel(Housenumber)),' houses were saved successfully with the extensions ''_XXXXXX'''),'Information','modal')); 
                data.savedname = CurrentSavingName ;
           case 'New'
               FrontEnd_SB
           case 'Import...'
               % Load the XML file that you want to import
               filter = {'*.xml'};
               [file, path] = uigetfile(filter);
               if path == 0; return; end
               if strcmp(path(end),filesep)
                   LoadFullPath = [path,file] ;
               else
                   LoadFullPath = [path,filesep,file];
               end
               
               % Read the XML file
               tree = xml_read(LoadFullPath);
               % Get the variable format
               VarFormat = data.varname ;
               %Get the last entry of the houses to get its number
               try
                   AllFields = fieldnames(data.SummaryStructure) ;
               catch
                   % This means that this field is non-existent at the
                   % moment and should be created from scratch
                   
               end
               if isempty(AllFields)
                   %This means that there are the GUI is empty
                   LastHouse = 'House0' ;
               else
                   LastHouse = AllFields{end} ;
               end
               HouseNbr = str2double(erase(LastHouse,'House')) ;
               % If there are multiple subElement, data must be stored as
               % indiviudal cell
               AllElements = tree.Element ;
               for ii = 1:numel(AllElements)
                   
                   VarName = AllElements(ii).CONTENT ;
                   
                   Format2save = VarFormat.(VarName).Type ;
                   subElements = AllElements(ii).subElement ;
                   
                   % Each of the subElement is a different house
                   for kk = 1:numel(subElements)
                        GetallInfo = subElements(kk).ATTRIBUTE;
                        GetallFields = fieldnames(GetallInfo) ;
                        HouseNbr2Input = kk + HouseNbr ;
                        
                        VarNameHouse = ['House',num2str(HouseNbr2Input)] ;
                        addedHouses{kk} = VarNameHouse ;
                        for mm = 2:numel(GetallFields)
                            Field2retrieve = GetallFields{mm} ;
                            Value2Input = GetallInfo.(Field2retrieve) ;
                            
                            if numel(GetallFields) > 2 || sum(sum(strcmp(VarName,data.AppliancesList))) >= 1
                                % In this case, store each variable as a
                                % cell
                                if strcmp(VarName,'clCharger')
                                    y=1;
                                end
                                if find(strcmp(VarName,data.AppliancesList(:,4))==1)
                                    % This means that this is a class
                                    % variable
                                    % Get the appliance variable name
                                    AppLoc = find(strcmp(VarName,data.AppliancesList(:,4))==1) ;
                                    AppName  = data.AppliancesList{AppLoc,3} ;
                                    
                                    if isempty(AppName)
                                        % This means that this is the
                                        % lighting system
                                        % In this case, do nothing
                                    else
                                        InfoApp = data.SummaryStructure.(VarNameHouse).(AppName) ;
                                    end
                                    if mm > (1 + numel(InfoApp))
                                        continue
                                    end
                                else
                                    %This means that this is a appliance
                                    %variable name 
                                    if mm > 2 && Value2Input == 0
                                        continue
                                    end
                                end
                                if isnumeric(Value2Input)
                                    Value2Input = num2str(Value2Input) ;
                                end
                                data.SummaryStructure.(VarNameHouse).(VarName)(mm-1) = {Value2Input} ;
                            elseif strcmp(VarName,'HouseNbr')
                                % Only this variable is stroed as a double
                                data.SummaryStructure.(VarNameHouse).(VarName) = HouseNbr2Input ;
                            elseif strcmp(VarName,'Headers')
                                % Only this variable is stroed as a double
                                data.SummaryStructure.(VarNameHouse).(VarName) = VarNameHouse ;
                            else
                                % In this case, store each variable as a
                                % string
                                if isnumeric(Value2Input)
                                    Value2Input = num2str(Value2Input) ;
                                end
                                data.SummaryStructure.(VarNameHouse).(VarName) = Value2Input ;
                            end
                        end
                   end
               end
               
               % Update the list box
               % Retrieve once again the stored data
               
               for i = 1:numel(addedHouses)
                   if size(data.HouseList,1) >= 1 && size(data.HouseList,2) >= 1
                       if isempty(data.HouseList{1})
                            data.HouseList(1) = addedHouses(i) ;
                       else
                            data.HouseList(end+1) = addedHouses(i) ;
                       end
                   else
                      data.HouseList(end+1) = addedHouses(i) ;
                   end
                   HouseNbr = str2double(erase(addedHouses{i},'House')) ;
                   
                   Newstr = strcat('House ',num2str(HouseNbr)) ;
                   
                     gui.(Newstr) = uicontrol( 'Parent', gui.Housedrawing,...
                                           'callback',@Housebutton,...
                                           'backgroundcolor',[230/255 230/255 230/255],...
                                           'Tag',Newstr,...
                                           data.ToolTipString,Newstr,...
                                           'UserData',strcat(Newstr,'_Selected'));
                     set(gui.SettingOpt,'visible','on') ;
                     %[SummaryStructureTemp] = createHouse(Newstr, Buttonnumber, data) ;
                     
                     %data.SummaryStructure.(Newstr) = SummaryStructureTemp.(Newstr) ;
                     
                     [~,Tip] = createStrToolTip(data.SummaryStructure.(Newstr),'') ;
                     set(gui.(Newstr),data.ToolTipString,Tip);
                     
                     redrawviewing('')
                     
                     Newhousepos = get(gui.(Newstr),'position') ;
                     sizeimage = min(Newhousepos(3),Newhousepos(4)) ;                  
                        originalimage = imread('House_Logo_Red.png');
                        a = imresize(originalimage,[sizeimage-10 sizeimage-10]);
                        a = im2uint8(a) ;
                        set(gui.(Newstr), 'cdata',a);
                        gui.(Newstr).Value = 0;
                     % Create the context menu for all new houses
                     makeContextMenuItem(gui.(Newstr))
                     AddedNewhouses{i} = Newstr ;

                
               end
               redrawviewing('rescale')
                if numel(addedHouses) == 1
                    MessageIn = strcat(num2str(numel(addedHouses)), ' house was imported succesfully') ;
                else
                    MessageIn = strcat(num2str(numel(addedHouses)), ' houses were imported succesfully') ;
                end
                uiwait(msgbox(MessageIn,'Add','modal'));
                OrigArray = data.Originalarray ; 
                data.Originalarray = [OrigArray; AddedNewhouses'] ;
                
                updateView();
                
%                currentstring = gui.ListBox.String ;
               
              
       end
    end %File
%-------------------------------------------------------------------------%
    function Enabletech(src,Eventdata)
        n = 0;
        srcOri = src;
        while n == 0
           if strcmp(srcOri.Parent.Type,'uipanel')
               n = 1 ;
               uiPanelOri = srcOri.Parent ;
           else
               srcOri = srcOri.Parent ;
           end
        end
        if strcmp(Eventdata.EventName,'Action')
            if isempty(gui.ListBox.String)
                src.Value = 0 ;
            else
                HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
                for i = 1:numel(HouseSelected)
                    Housetag = HouseSelected{i} ;
                    SaveData(src.Tag,Housetag,src.Value) ;
                end
                UpdateAllTip
            end
        else
            src.Value = str2double(Eventdata.EventName);
        end
        if src.Value == 1
            EnaDis = 'on' ;
        else
            EnaDis = 'off' ;
        end
        DisEnaBoxPanel(uiPanelOri,EnaDis)
    end %Enabletech
%-------------------------------------------------------------------------%
    function onPanelHelp( src, ~ )
        % User wants documentation for the current panel
        switch src.Parent.Parent.Parent.Title
            case 'Photovoltaic panels'
                %Get info
                open Photovoltaic_panels.html
            case 'House Selection'
                %Get info 
            case 'Wind power'
                %Get info 
            case 'Fuel cells'
                %Get info 
            case 'General'
                %Get info 
            case 'Location'
                %Get info 
            case 'Appliances'
                %Get info 
            case 'Options'
                %Get info on the options for simulation
                open OptionSim.html
            case 'Settings'
                %Find the active panel
                SelectedCard = gui.p.Contents(gui.p.Selection) ;
                for i = 1:numel(data.PanelListTitle)
                   if strcmp( SelectedCard.Title,data.PanelListTitle{i})
                      % Get info for the specific panel
                      % Exit the panel loop
                      File2Open = [replace(SelectedCard.Title,' ','_'),'.html'] ;
                      try
                          open(File2Open)
                      catch
                          return;
                      end
                   end
                end
        end
                
    end % onDemoHelp
%-------------------------------------------------------------------------%
    function onRun(src,~)
        switch src.Text
            case 'Run'
                OkSimString = 'Run';
            case 'Run Selected'
                OkSimString = 'Run Selected';
            otherwise
                OkSimString = 'Run';
        end
        x = 0;
        % If the figure already exist and is already opened, bring it in
        % front and disregard the creation of the new window.
        figHandles = findall(0, 'Type', 'figure') ;
        NotOpened = [] ;
        i = 1          ;
        while isempty(NotOpened)
                if find(strcmp(figHandles(i).Name,{'Run' 'Run Selected'})) > 0
                    if strcmp(OkSimString,figHandles(i).Name)
                        % This means that a window is already opened
                        figure(figHandles(i)) ;
                        NotOpened = 0 ;
                    else
                        % This means that the opened windows is for the other
                        % simulation. Close the current window.
                        close(figHandles(i)) ;
                        NotOpened = 1 ;
                    end

                elseif i == numel(figHandles)
                    NotOpened = 1 ;
                end
            i = i + 1 ;  
        end
        if NotOpened == 1
            % This means that we will need to create the window
            CreaterunWindow(OkSimString)
        end
        if x == 1                 
            onLocate(src.Text)
        end
    end %onrun
%-------------------------------------------------------------------------%
    function CreaterunWindow(OkSimString)
        Mfigpos = get(gui.Window,'OuterPosition') ;
        buttonwidth = 500 ;
        buttonheight = 500 ;
        gui.runWindow = figure('units','pixels',...
                             'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                         Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                         buttonwidth,...
                                         buttonheight],...
                             'toolbar','none',...
                             'menu','none',....
                             'name',OkSimString,....
                             'NumberTitle','off',...
                             'Tag','rundialogbox',...
                             'HandleVisibility', 'off');  
                         
        MainPanel = uix.VBox('Parent',gui.runWindow,'Padding', 5 );
            Projectname = uix.HBox('Parent',MainPanel,'spacing', 2 );
            gui.OptionSimulation = uix.BoxPanel('Parent',MainPanel,'Title','Options',...
                                         'MinimizeFcn', {@nMinimize_Sim, 2,'Limit'},...
                                         'Padding',2,'HelpFcn', @onPanelHelp);
            set(gui.OptionSimulation,'Minimized',false);
            gui.SimLogWindow = uicontrol('Parent',MainPanel,'style','listbox') ;
            
            % Set the first box
            gui.startsimbutton = uicontrol('Parent',Projectname,...
                                           'style','pushbutton',...
                                           'string',OkSimString,...
                                           'callback',@Runsim) ;
            gui.startsimbutton = uicontrol('Parent',Projectname,...
                                           'style','pushbutton',...
                                           'string','Cancel',...
                                           'callback',@Runsim) ;
            uix.Empty('Parent',Projectname);
            gui.startsimbutton = uicontrol('Parent',Projectname,...
                                           'style','pushbutton',...
                                           'string','Clear Log file',...
                                           'callback',@Runsim) ; 
            
            % Set the options
            Optionbox = uix.VBox('Parent',gui.OptionSimulation,'spacing', 2 );
            gui.Comparehouses = uicontrol('Parent', Optionbox,...
                                          'Style', 'checkbox',...
                                          'Tag','Comparehouses',...
                                          'String','Compare houses');
            Outputsimutext = uix.HBox('Parent',Optionbox,'spacing', 2 );                          
                textsimoutput = uicontrol('Parent', Outputsimutext,...
                          'Style', 'text',... 
                          'String','Set simulation name');   
                uix.Empty('Parent',Outputsimutext);
            gui.NameSimEdit = uicontrol('Parent',Optionbox,...
                                         'style','edit',...
                                         'HorizontalAlignment','left',...
                                         'string','Simulation',...
                                         'tag','NameSimEdit');
                
                
            Outputfoldertext = uix.HBox('Parent',Optionbox,'spacing', 2 );                          
                textoutput = uicontrol('Parent', Outputfoldertext,...
                          'Style', 'text',... 
                          'String','Set output folder path');   
                set(textoutput,'Position',[textoutput.Position(1) textoutput.Position(2) textoutput.Extent(3) textoutput.Position(4)])     
                uix.Empty('Parent',Outputfoldertext);
            s = strcat(pwd,filesep,'Output');    
            Outputfolder = uix.HBox('Parent',Optionbox,'spacing', 2 );
                gui.OutputFolEdit = uicontrol('Parent',Outputfolder,...
                                         'style','edit',...
                                         'HorizontalAlignment','left',...
                                         'string',s,...
                                         'tag','OutputFolEdit');
                gui.OutputFolSelec = uicontrol('Parent',Outputfolder,...
                                            'style','pushbutton',...
                                            'string','Browse',...
                                            'callback',@Runsim);
                                        
        set(Outputsimutext,'Widths',[textsimoutput.Extent(3) -1])                               
        set(Outputfoldertext,'Widths',[textoutput.Extent(3) -1])
        set(Optionbox,'Heights',[23 15 23 15 23])
        set(Outputfolder,'Widths',[-1 50]); 
        pheightmin = 23;
        [pheightmax] = PanelinnerSize(gui.OptionSimulation) ;
        pheightmax = max(pheightmax + 40,pheightmin) ;
        
        set(MainPanel,'Heights',[23 pheightmax -1]);     
    end
%-------------------------------------------------------------------------%
    function Runsim(src,~)
        switch src.String
            case 'Browse'
                hp_OutputFolEdit = gui.OutputFolEdit ;

                folder_name = uigetdir;
                %%%
                if folder_name == 0; return; end
                set(hp_OutputFolEdit,'string',folder_name)
            case 'Run'
                if ~isempty(gui.ListBox.String) && ~isempty(gui.ListBox.Value)
                    if isempty(data.savedname)
                        File('Save all')
                    else
                        % Option to save the simulation ile somewhere else
                        File('Save all')
                    end
                    % JARI'S ADDITION
%                     AccessDevelopmentMode()
                    % END OF JARI'S ADDITION
                    Simulationdata = data.Simulationdata ;
                    % Check completeness of the information
                    ValidInput = Checkintegrity(Simulationdata, data.datastructure) ;
                    if ~isempty(ValidInput)
                          % display a new figure with an UIMultiList, 3 columns
                          displayerror(ValidInput)
                          uiwait();
                          return;
                    end
                    
                    Launch_Sim(gui.OutputFolEdit.String,gui.NameSimEdit.String,data,gui.SimLogWindow)
                end
            case 'Run Selected'
                File('Save selected as...')
                Housenumber = fieldnames(data.SummaryStructure);
                SelectedHouses = gui.ListBox.String(gui.ListBox.Value) ;
                SelectedHousesnbr = numel(SelectedHouses) ;
                nbrhsel = 0 ;
                i = 1;
                
                    % JARI'S ADDITION
%                     AccessDevelopmentMode()
                    % END OF JARI'S ADDITION
                    
                while nbrhsel < SelectedHousesnbr
                    if sum(strcmp(Housenumber{i},SelectedHouses))
                        % JARI's change and commented line was original
%                         Simulationdata.(Housenumber{i}) = data.SummaryStructure.(Housenumber{i}) ;
                        Simulationdata.(Housenumber{i}) = data.Simulationdata.(Housenumber{i});         % J
                        nbrhsel = nbrhsel + 1 ;
                    end
                    i = i + 1; 
                end
                ValidInput = Checkintegrity(Simulationdata, data.datastructure) ;
                if ~isempty(ValidInput)
                      % display a new figure with an UIMultiList, 3 columns
                      displayerror(ValidInput)
                      uiwait();
                      return;
                end
                data.Simulationdata = Simulationdata ;
                Launch_Sim(gui.OutputFolEdit.String,gui.NameSimEdit.String,data,gui.SimLogWindow)
            case 'Cancel'
                delete(gui.runWindow)
                return;
            case 'Clear Log file'
                gui.SimLogWindow.String = {};
        end
        
    end %Runsim
%-------------------------------------------------------------------------%
    function displayerror(ErrorList)
        Mfigpos = get(gui.Window,'OuterPosition') ;
            buttonwidth = 600 ;
            buttonheight = 200 ;
            gui.ErrorInputs = figure('units','pixels',...
                 'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                             Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                             buttonwidth,...
                             buttonheight],...
                 'toolbar','none',...
                 'menu','none',....
                 'name','Error',....
                 'NumberTitle','off',...
                 'Tag','AddFigure',...
                 'CloseRequestFcn',@closeRequest);
            set(gui.ErrorInputs,'WindowStyle','modal');
            
            MainBox = uix.VBox('Parent',gui.ErrorInputs,'Padding',5);
            uicontrol('parent',MainBox,'style','text','string','Error in input values')
            
            DisplayerrorHeaders = {'House number' 'Variable name' 'Error message'};

            multicolumnApp = uimulticollist('Parent',MainBox,...
                                  'string', ErrorList,...
                                  'columnColour', {'BLACK' 'BLACK' 'BLACK' },...
                                  'tag','multicolumnApp');  
           uimulticollist(multicolumnApp,'addRow', DisplayerrorHeaders , 1)
           uimulticollist( multicolumnApp, 'setRow1Header', 'on' )
           uimulticollist( multicolumnApp, 'applyUIFilter', 'on' )
           set(MainBox,'Heights',[30 -1])
    end
%-------------------------------------------------------------------------%
    function nMinimize_Sim( src, ~, whichpanel,LimitHeight )
        SelectedPanel = src.Parent.Parent.Parent.Parent ;
        pheightmin = 23 ;
        
         PanelRealOrder = whichpanel ;
        SelectedBox = src.Parent.Parent.Parent ;
        
        switch LimitHeight
            case 'Limit'
                if whichpanel == 1
                    pheightmax = -1 ;
                else
                    [pheightmax] = PanelinnerSize(SelectedBox) ;
                    pheightmax = max(pheightmax + 40,pheightmin) ;
                end
            case 'NoLimit'
                pheightmax = -1 ;
        end
        s = get( SelectedPanel, 'Heights' );
        panel{whichpanel}.Minimized = SelectedBox.Minimized;
        if panel{whichpanel}.Minimized
            s(PanelRealOrder) = pheightmax;
            set(SelectedBox,'Minimized',false);
        else
            s(PanelRealOrder) = pheightmin; 
            set(SelectedBox,'Minimized',true);
        end 
        set( SelectedPanel, 'Heights', s );
    end % Minimize 
%-------------------------------------------------------------------------%
    function setIconMenu(jMenuBar, Menu2AddIcon, IconName )
        %jFileMenu = jMenuBar.getComponent(0);
        for ij = 0:(numel(jMenuBar.getComponents)-1)
            jFileMenu = jMenuBar.getComponent(ij);
            pause(.1)
            jFileMenu.doClick; % open the File menu
            jFileMenu.doClick; % close the menu
            MaxMenuCmp = numel(jFileMenu.getMenuComponents) ;
            n = 0;
            i = 0;
            while (n == 0 && i < MaxMenuCmp)
                try
                   jSave = jFileMenu.getMenuComponent(i);
                   get(jSave,'label');
                catch
                    i = i + 1;
                    continue;
                end
                jSaveLabel = get(jSave,'label');
                if strcmp(jSaveLabel,Menu2AddIcon)
                    n = 1;
                else
                    i = i + 1 ;
                end
            end
            %inspect(jSave) 	% just to be sure: label='Save' => good!
            if n == 1 
                jSave.setIcon(javax.swing.ImageIcon(IconName));
            end
        end
    end %setIconMenu
%-------------------------------------------------------------------------%
    function onTools(src,~)
        
        try 
            F = findall(0,'type','figure','tag','Peferences') ;
        catch
            F = '';
        end

        if ~isempty(F)
            uistack(F,'top')
            return
        end

        set(findall(gui.Window,'-property','FontSize'),'FontSize',8)
        
        Add2List = {'Layout'
                    'Report'
                    'Development'
                    };
        
        Mfigpos = get(gui.Window,'OuterPosition') ;
        buttonwidth = 700 ;
        buttonheight = 300 ;
        gui.Peferences = figure('units','pixels',...
                                 'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                             Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                             buttonwidth,...
                                             buttonheight],...
                                 'toolbar','none',...
                                 'menu','none',....
                                 'name','Preferences',....
                                 'NumberTitle','off',...
                                 'Tag','Peferences',...
                                 'CloseRequestFcn',@closeRequest,...
                                 'Visible','off');
%          set(gui.Peferences,'WindowStyle','modal')
         %
         %movegui(gui.AddDialog,'center')
         set(gui.Peferences, 'Resize', 'on');

         Division = uix.HBox('Parent',gui.Peferences) ;

         gui.ListBoxPreference = uicontrol('Style', 'list', ...
                                 'BackgroundColor', 'w', ...
                                 'Parent', Division, ...
                                 'String', Add2List(:), ...
                                 'Value', 1, ...
                                 'Max',2,...
                                 'Tag','ListBoxPreference',...
                                 'Min',0,...
                                 'Callback', @onListSelectionPreference);
         gui.PreferenceWindow = uix.CardPanel('Parent', Division,'Padding', 5 ) ;
         % Create the different subPanels
         for i = 1:numel(Add2List)
            Panelname = strcat('Panel',Add2List{i}) ;
            PanelTitle = Add2List{i} ;
            gui.(Panelname) = uix.Panel('Parent',gui.PreferenceWindow, 'Title', PanelTitle,'Tag',Panelname) ;                
         end
         set(Division,'widths',[-1 -3]) 
         % Fill in the panel with the basic information
            LayoutPanel = uix.VBox('Parent',gui.PanelLayout,'Spacing',5) ;
                % Set the long name variable checkbox
                Pref_Variable_Long_Names = uicontrol('Parent',LayoutPanel,...
                                                'style','checkbox',...
                                                'string','Use variable long name',...
                                                'Tag','Pref_Variable_Long_Names',...
                                                'Value',data.varlongname,...
                                                'callback',@setPreferences);
                Pref_Variable_Long_Names_Ext = get(Pref_Variable_Long_Names,'Extent') ;                                
                
                % Set the font size option
                FontSizeHBox = uix.HBox('Parent',LayoutPanel) ;
                    FontSizeText = uicontrol('Parent',FontSizeHBox,...
                                                    'style','text',...
                                                    'string','Set Font Size');
                    FontSizeTextExt = get(FontSizeText,'Extent') ;
                    fontlist = data.fontlist ;                           
                    gui.Pref_FontSize = uicontrol('Parent',FontSizeHBox,...
                                                    'style','popup',...
                                                    'string',fontlist(:),...
                                                    'callback',@setPreferences,...
                                                    'tag','Pref_FontSize'); 
                    d = listfonts() ;
                    valName = data.FontName ;
                    ValuevalName = find(strcmp(d(:),valName)==1) ;
                    gui.Pref_FontName = uicontrol('Parent',FontSizeHBox,...
                                                    'style','popup',...
                                                    'string',d(:),...
                                                    'Value',ValuevalName,...
                                                    'callback',@setPreferences,...
                                                    'tag','Pref_FontName'); 
                                                
                    Pref_FontSize_Ext = get(gui.Pref_FontSize,'Extent') ;   
                    Min = 0.5 ;
                    Max = 72 ;
                    StepSmall = 0.1/(Max-Min) ;
                    SteppBig = 3/(Max-Min) ;
                    Pref_FontSizeSlider = uicontrol('Parent',FontSizeHBox,...
                                                    'style','slider',...
                                                    'Max',72,...
                                                    'Min',0.5,...
                                                    'Value',8,...                                                    
                                                    'SliderStep',[StepSmall SteppBig],...
                                                    'tag','Pref_FontSizeSlider') ;
                    addlistener(Pref_FontSizeSlider, 'Value', 'PostSet',@myCallBack);
                    set(FontSizeHBox,'Widths',[FontSizeTextExt(3) -1 -1 -3]) ;
                % Set the tooltip length
                ToolTipHBox = uix.HBox('Parent',LayoutPanel) ;
                    ToolTipText = uicontrol('Parent',ToolTipHBox,...
                                                    'style','text',...
                                                    'string','Tip length (cm)');
                    ToolTipTextExt = get(ToolTipText,'Extent') ;       
                    gui.Pref_ToolTipLength = uicontrol('Parent',ToolTipHBox,...
                                                        'style','edit',...
                                                        'string',num2str(data.TipToolLength),...
                                                        'callback',@setPreferences,...
                                                        'tag','Pref_ToolTipLength');
                    set(ToolTipHBox,'Widths',[ToolTipTextExt(3) -1 ]) ;
                % Finishing with an empty block to compress all the VBox    
                uix.Empty('Parent',LayoutPanel) ;
                
                set(LayoutPanel,'heights',[Pref_Variable_Long_Names_Ext(4)...
                                           Pref_FontSize_Ext(4)...
                                           ToolTipTextExt(4)...
                                           -1]) ;
                 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Set the Report Panel
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                VarReport = data.VarReport ;
                AllFields = fieldnames(VarReport) ;
                ReportPanel = uix.VBox('Parent',gui.PanelReport,'Spacing',5) ;
                Height = 19 ;
                HeightTotal = [] ;
                
                for i = 1:numel(fieldnames(VarReport))
                    FieldName = AllFields{i} ;
                    NameLabel = strcat(VarReport.(FieldName).Type,'_',FieldName) ;
                    HBoxName = strcat('HBox',NameLabel) ;
                    TextName = strcat('text',NameLabel) ;
                    editName = strcat('edit',NameLabel) ;
                    ButtName = strcat('pushbutton',NameLabel) ;
                    gui.(HBoxName) = uix.HBox('parent',ReportPanel,'spacing',5) ;
                    
                    % Create the text box
                    gui.(TextName) = uicontrol('parent',gui.(HBoxName),...
                                                'style','text',...
                                                'string',FieldName,...
                                                'tag',NameLabel,...
                                                'HorizontalAlignment','left') ;
                    try
                        ToolTip = VarReport.(FieldName).ToolTip ;
                    catch
                        ToolTip = '' ;
                    end

                    % Create the edit box
                    if strcmp(VarReport.(FieldName).Type,'edit')
                        
                        try
                            NameUD = VarReport.(FieldName).NameUD     ;
                        catch
                            NameUD = VarReport.(FieldName).NameDefault ;
                        end
                        if isempty(NameUD)
                            NameUD = data.VarReport.(FieldName).NameDefault ;
                        end
                        
                        gui.(TextName) = uicontrol('parent',gui.(HBoxName),...
                                                'style',VarReport.(FieldName).Type,...
                                                'string',NameUD,...
                                                'tag',editName,...
                                                'HorizontalAlignment','left',...
                                                data.ToolTipString,ToolTip,...
                                                'KeyPressFcn',@SaveReportdata,...
                                                'callback',@SaveReportdata) ;

                    elseif strcmp(VarReport.(FieldName).Type,'popup')
                        stringin = VarReport.(FieldName).Name ;
                        stringin = orderalphacellarray(stringin(:)') ;
                        stringin = stringin(:) ;
                                                
                        try
                            NameUD = VarReport.(FieldName).NameUD     ;
                        catch
                            NameUD = VarReport.(FieldName).NameDefault ;
                        end
                        if isempty(NameUD)
                            NameUD = data.VarReport.(FieldName).NameDefault ;
                        end
                        
                        if strcmp(FieldName,'Language')
                            valuein = find(strcmp(NameUD,data.LanguagesAll.LanguagesSN)==1) ;
                        elseif strcmp(FieldName,'FileFormat')
                            valuein = find(strcmp(NameUD,stringin)==1) ;
                        end
                        
                        gui.(TextName) = uicontrol('parent',gui.(HBoxName),...
                                                'style',VarReport.(FieldName).Type,...
                                                'string',stringin,...
                                                'value',valuein,...
                                                'tag',editName,...
                                                'HorizontalAlignment','left',...
                                                'KeyPressFcn',@SaveReportdata,...
                                                'callback',@SaveReportdata) ;
                    elseif strcmp(VarReport.(FieldName).Type,'checkbox')
                         
                            NameString = VarReport.(FieldName).ButtonName     ;
                            
                            try
                                NameUD = VarReport.(FieldName).NameUD     ;
                            catch
                                try
                                    NameUD = VarReport.(FieldName).NameDefault     ;
                                catch
                                    NameUD = 0 ;
                                end
                            end
                            if ischar(NameUD)
                                NameUD = str2double(NameUD) ;
                            end
                            gui.(TextName) = uicontrol('parent',gui.(HBoxName),...
                                                    'style',VarReport.(FieldName).Type,...
                                                    'string',NameString,...
                                                    'tag',editName,...
                                                    'HorizontalAlignment','left',...
                                                    'Value',NameUD,...
                                                    data.ToolTipString,ToolTip,...
                                                    'KeyPressFcn',@SaveReportdata,...
                                                    'callback',@SaveReportdata) ;
                    end
                    
                    % Create the pushbutton
                    if strcmp(VarReport.(FieldName).Button,'off')
                        %Create an empty space
                        gui.(ButtName) = uix.Empty('parent',gui.(HBoxName)) ;
                    else
                        % Create a pushbutton
                        gui.(ButtName) = uicontrol('parent',gui.(HBoxName),...
                                                'style','pushbutton',...
                                                'string',VarReport.(FieldName).ButtonName,...
                                                'tag',ButtName,...
                                                'callback',@ReportButton) ;
                    end
                    set(gui.(HBoxName),'Widths',[55 -1 55]) ;
                    HeightTotal(end + 1) = Height ;
                end
                uix.Empty('parent',ReportPanel) ;    
                HeightTotal(end + 1) = -1 ;
                
                set(ReportPanel,'Heights',HeightTotal) ;
                
                % Show the correct Panel
                Panel2Look = Add2List{1} ;
                for j = 1:numel(gui.PreferenceWindow.Children)
                    if strcmp(strcat('Panel',Panel2Look),gui.PreferenceWindow.Contents(j).Tag)
                        gui.PreferenceWindow.Selection = j ;
                        break
                    end
                end 
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Development Tab by JARI                                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                gui.DevelopmentBox = uix.VBox('Parent', gui.PanelDevelopment, ...
                                              'Spacing', 5);

                                          
                    gui.DevelopmentTick = uicontrol('Parent', gui.DevelopmentBox,...
                                                    'Style', 'checkbox', ...
                                                    'String', 'Access Develepmont mode', ...
                                                    'Tag', 'DevelopmentMode', ...
                                                    'callback', @AccessDevelopmentMode);
                                                
                    set(gui.DevelopmentTick, 'Value', 1)
                
        gui.Peferences.Visible = 'on' ;
    end %onTools
%--------------------------------------------------------------------------%
    function ReportButton(src,~)
        %hp_OutputFolEdit = gui.OutputFolEdit ;

        [filename, pathname] = uigetfile(...    
                                {'*.jpg; *.jpeg; *.img; *.tif; *.tiff; *.png','Supported Files (*.jpg,*.img,*.tiff,)'; ...
                                '*.jpg','jpg Files (*.jpg)';...
                                '*.jpeg','jpeg Files (*.jpeg)';...
                                '*.img','img Files (*.img)';...
                                '*.tif','tif Files (*.tif)';...
                                '*.tiff','tiff Files (*.tiff)';...
                                '*.png','png Files (*.png)'},...  
                                'MultiSelect', 'off');
        %%%
        if filename == 0; return; end
        pathnameretrun = strcat(pathname,filename) ;
        set(gui.textedit_Logo,'string',pathnameretrun)
        data.VarReport.Logo.NameUD = pathnameretrun ;
    end %ReportButton
%--------------------------------------------------------------------------%
    function SaveReportdata(src,~)
        Name = src.Tag((strfind(src.Tag,'_')+1):end) ;
        switch src.Style
            case 'edit'
                data.VarReport.(Name).NameUD = src.String ;
            case 'popupmenu'
                if strcmp(Name,'Language')
                    LanguageFullName = src.String{src.Value} ;
                    LangLoc = find(strcmp(LanguageFullName,data.LanguagesAll.LanguagesRegional)==1) ;
                    data.VarReport.(Name).NameUD = data.LanguagesAll.LanguagesSN{LangLoc} ;
                elseif strcmp(Name,'FileFormat')
                    FileFormatFullName = src.String{src.Value} ;
                    data.VarReport.(Name).NameUD = FileFormatFullName ;
                end
            case 'checkbox'
                data.VarReport.(Name).NameUD = src.Value ;
        end
    end %SaveReportdata
%--------------------------------------------------------------------------%
    function setPreferences(Varin,~)
        switch Varin.Tag
            case 'Pref_Variable_Long_Names'
                src.Text = Varin.String ;
                onDisplay(src) ;
            case 'Pref_FontSize'
                valSize = gui.Pref_FontSize.String{gui.Pref_FontSize.Value} ;
                set(findall(gui.Window,'-property','FontSize'),'FontSize',str2double(valSize))
                data.FontSize = valSize ;
            case 'Pref_FontName'
                valName = gui.Pref_FontName.String{gui.Pref_FontName.Value} ;
                set(findall(gui.Window,'-property','FontName'),'FontName',valName)
                data.FontName = valName ;
            case 'Pref_ToolTipLength'
                data.TipToolLength = str2double(gui.Pref_ToolTipLength.String) ;
                ObjTip = findall(gui.Window,'-property',data.ToolTipString,'-not',data.ToolTipString,'') ;
                for i = 1:numel(ObjTip)
                    ObjTipTemp = ObjTip(i) ;
                    try
                        Tip2Catch = data.datastructure.(ObjTipTemp.Tag).(data.ToolTipString) ;
                        Tip2Title = data.datastructure.(ObjTipTemp.Tag).LongName ;
                        [~,TipHTML] = createStrToolTip(Tip2Catch,...
                                                           Tip2Title) ;
                        Tip = TipHTML  ;% ;str2html(TipHTML) ;
                    catch
                        % This is not a regular variable
                        Tip2Catch = ObjTipTemp.(data.ToolTipString) ;
                        Tip2Title = ''    ;
                        [TipString,~] = createStrToolTip(Tip2Catch,...
                                                           Tip2Title) ;
                        Tip = Tip2Catch ;
                    end    
                    
                     set(gui.(ObjTipTemp.Tag),data.ToolTipString, Tip) ;
                     drawnow;
                end
                drawnow ;
                valSize = gui.Pref_FontSize.String{gui.Pref_FontSize.Value} ;
                set(findall(gui.Window,'-property','FontSize'),'FontSize',str2double(valSize))
                data.FontSize = valSize ;
                
        end
        
    end %setPReferences
%--------------------------------------------------------------------------%
    function myCallBack(~,event)
        val = get(event.AffectedObject,'Value') ;
        fontsizelist = data.fontlist ;
         
        if isempty(find([data.fontlist{:}]==val))
            fontsizelist{end + 1} = val ;
        end
        fontsizelist = orderalphacellarray(fontsizelist') ;
        data.fontlistUD = fontsizelist ;
        gui.Pref_FontSize.String = data.fontlistUD ;
        gui.Pref_FontSize.Value = find(strcmp(gui.Pref_FontSize.String,num2str(val))==1) ;
        Varin.Tag = 'Pref_FontSize' ;
        setPreferences(Varin) ;
    end
%--------------------------------------------------------------------------%
    function onListSelectionPreference(src,~)
        ListBoxName = src.String{src.Value} ;
        image2loadblue = strcat('Panel',ListBoxName) ;
        for j = 1:numel(gui.PreferenceWindow.Children)
            if strcmp(image2loadblue,gui.PreferenceWindow.Contents(j).Tag)
                gui.PreferenceWindow.Selection = j ;
                break
            end
        end  
    end %onListSelectionPreference
%--------------------------------------------------------------------------%
 function [Size]=PanelinnerSizeSSP(Panel)
        Header = 23 ;
        found = 0 ;
        ChildOld = Panel ;

        while found == 0
            try
                ChildNew = ChildOld(1).Children(1) ;
            catch
               Size = 0;
               return; 
            end
            found = 1 ;
            pos1 = 0 ;
            
            pos1 = GetHeightContainer(ChildNew,pos1) ;      
        end
        Size = Header + 2*Panel.Parent.Padding + pos1 ;
    end %PanelinnerSize
%--------------------------------------------------------------------------%
    function redrawOptionPanels(Rescale)
        SizeSetting = 30 ;

                     TotalHousing = numel(gui.Housedrawing.Children) ;
        if TotalHousing > 0
                     HouseWidth = ceil(sqrt(TotalHousing));
                     HouseHeight = ceil(TotalHousing / HouseWidth) ;

                     Widtharray(1:HouseWidth) = SizeSetting;
                     Heightarray(1:(HouseHeight)) = SizeSetting;

                     TotalWidth = sum(Widtharray) + (numel(Widtharray)-1)*5 ;
                     TotalHeight = sum(Heightarray) + (numel(Heightarray)-1)*5;
                     
                     set(gui.Housedrawing,'Widths', Widtharray, 'Heights',Heightarray);

                if strcmp(Rescale,'rescale')
                    set( gui.ScrollPanelView, ...
                         'Widths', TotalWidth, ...
                         'Heights', TotalHeight, ...
                         'HorizontalOffsets', 100, ...
                         'VerticalOffsets', 100 );
                end
        end
        set(gui.ListBox,'Value',1:numel(data.HouseList));
        set(gui.ListBox,'String', data.HouseList(:)) ;
    end %redrawviewing
%-------------------------------------------------------------------------%
    function AddSpec(src,~)
        if ~isempty(gui.ListBox.String)
            switch src.Tag
                case {'Spec2AddPV','Spec2RemovePV'}
                    tech = 'PV' ;
                case {'Spec2AddWind','Spec2RemoveWind'}
                    tech = 'Wind' ;
                case {'Spec2AddFC','Spec2RemoveFC'}
                    tech = 'FC' ;
                case {'Spec2AddBDVar','Spec2RemoveBDVar'}
                    tech = 'BDVar' ;
                case {'Spec2AddTPVar','Spec2RemoveTPVar'}
                    tech = 'TPVar' ;
                case {'Spec2AddVentVar','Spec2RemoveVentVar'}
                    tech = 'VentVar' ;
                case {'Spec2AddHeatingVar','Spec2RemoveHeatingVar'} 
                    tech = 'HeatingVar';
            end

            Spec2Define = strcat('Spec2Define',tech);
            Spec2List = strcat('Spec2List',tech);
            Spec2Input = strcat('Spec2Input',tech);
           
            FillSSProdList(Spec2Define,Spec2List,Spec2Input,src)

            
            n = 0;
            Check = src ;
            while n == 0
                Check = Check.Parent ;
                if strcmp(Check.Type,'uipanel')
                    n = 1;
                    whichpanel = erase(Check.Tag,'Panel') ;
                    whichpanel = str2double(whichpanel) ;
                end
            end
            LimitHeight = 'Limit';
            Input.(data.ToolTipString) = 'Rezise' ;
            nMinimize_HD( Input, '', whichpanel,LimitHeight )
        end
    end %AddSpec
%-------------------------------------------------------------------------%
    function FillSSProdList(Spec2Define,Spec2List,Spec2Input,src)
        Var2Input = gui.(Spec2Define).String{gui.(Spec2Define).Value} ;
        try
            data.datastructure.(Var2Input) ;
        catch
            n = 0;
            i = 0;
            AllFields = fieldnames(data.datastructure) ;
            while n == 0
                i = i + 1;
                LN2Check = data.datastructure.(AllFields{i}).LongName ;
                if strcmp(LN2Check,Var2Input)
                    n = 1;
                    Var2Input = data.datastructure.(AllFields{i}).ShortName ;
                end
            end
        end
        
        if strfind(src.Tag,'Spec2Add')
            Records = uimulticollist(gui.(Spec2List),'string');
            if strcmp('Spec2InputFC',Spec2Input)
                Quantity = gui.(Spec2Input).String{gui.(Spec2Input).Value} ;
                if strcmp(Quantity,'Select...')
                    return;
                end
            else
                Quantity = gui.(Spec2Input).String ;
                if isnan(str2double(Quantity))
                    gui.(Spec2Input).String = 'Insert Numeric Value Only';
                    return;                            
                end
            end
            if ~strcmp(Var2Input,Records(:,1))
                rowItems = {Var2Input,Quantity} ;
                %rowIndex = size(Records,1) + 1 ;
                %Add the specific variable
                uimulticollist( gui.(Spec2List), 'addRow', rowItems  )
            else
                rowIndex = find(strcmp(Var2Input,Records(:,1)));
                uimulticollist( gui.(Spec2List), 'changeItem', Quantity , rowIndex, 2 )
            end
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        
            for i = 1:numel(HouseSelected)
               HouseTag =  HouseSelected{i} ;
               SaveData(Var2Input,HouseTag,Quantity)
               data.varname.(Var2Input).UserDefValue.(HouseTag) = Quantity;
            end 
        elseif strfind(src.Tag,'Spec2Remove')
            rowSelected = uimulticollist(  gui.(Spec2List), 'value') ;
            if rowSelected > 1
                varname = uimulticollist( gui.(Spec2List), 'selectedStrCol', 1 ) ;
                varname = varname{1} ;
                % Remove the data from the user specific data
                HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   try
                       data.varname.(varname).UserDefValue.(HouseTag);
                   catch
                       % Does not exist so disregard this variable
                       % We could write a warning in a log file
                   end
                    varnameValue = '';
                    % Set the user defined value to nothing
                    data.varname.(varname).UserDefValue.(HouseTag) = varnameValue;
                    % Replace the value in the Summary to the default value
                    data.SummaryStructure.(HouseTag).(varname) = data.varname.(varname).Defaultvalue ;
                end
               set(gui.(Spec2List), 'value',1)
               uimulticollist( gui.(Spec2List), 'delRow', rowSelected )
            end
        else
            return;
        end
    end
%-------------------------------------------------------------------------%
    function ListSPPSelection(src,~)
        
        persistent chk
        if isempty(chk)
              chk = 1;
              pause(0.2); %Add a delay to distinguish single click from a double click
              if chk == 1
                  % Execute a single click action  
                  fprintf(1,'\nI am doing a single-click.\n\n');
                  chk = [];
              end
        else
              % Execute a double click action   
              fprintf(1,'\nI am doing a double-click.\n\n');
              chk = [];
        end

        if src.Value > 1
            Spec2List = src.Tag;
            tech = erase(Spec2List,'Spec2List') ;
            
            List = uimulticollist( gui.(src.Tag),'selectedString') ;
            
            SelectedVariable = List{1,1};
            Selectedquantity = List{1,2};
            
            Spec2Define = strcat('Spec2Define',tech);
            Spec2Input = strcat('Spec2Input',tech);
            
            RowVariable = find(strcmp(gui.(Spec2Define).String,SelectedVariable));

            if isempty(RowVariable)
                
                if isa(data.varname,'cell')
                    comparray = data.varname(:,1) ;
                    LongName = data.varname(:,2) ;
                elseif isa(data.varname,'struct')
                    comparray = fieldnames(data.varname) ;
                    for ifield = 1:numel(comparray)
                        LongName{ifield} = data.varname.(comparray{ifield}).LongName ;
                    end
                end
                
                RowVariable = find(strcmp(SelectedVariable, comparray)) ;
                if isempty(RowVariable)
                    % THe input value does not exist
                    return;
                else
                    Var2Input = LongName{RowVariable} ;
                end
                RowVariable = find(strcmp(gui.(Spec2Define).String,Var2Input));
            end
            
            SelectInList = RowVariable ;
            if strcmp(gui.(Spec2Define).Style,'popupmenu')
                gui.(Spec2Define).Value = SelectInList ;
            else
                gui.(Spec2Define).String = SelectInList ;
            end
            if strcmp(gui.(Spec2Input).Style,'popupmenu')
                RowVariable = find(strcmp(gui.(Spec2Input).String,Selectedquantity)) ;
                gui.(Spec2Input).Value = RowVariable ;
            else
                gui.(Spec2Input).String = Selectedquantity ;
            end
            
        end
    end %ListSPPSelection
%-------------------------------------------------------------------------%
    function Spec2InputBDVar(src,~)
        n = 0;
        srcOri = src;
        while n == 0
           if strcmp(srcOri.Parent.Type,'uipanel')
               n = 1 ;
               uiPanelOri = srcOri.Parent ;
           else
               srcOri = srcOri.Parent ;
           end
        end
        switch src.String{src.Value}
            case 'Default'
                EnaDis = 'off' ;
                DisEnaBoxPanel(uiPanelOri,EnaDis,{src.Tag})
            case 'Define'
                EnaDis = 'on' ;
                DisEnaBoxPanel(uiPanelOri,EnaDis,{src.Tag})
            otherwise
        end
        if ~isempty(gui.ListBox.String)
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
            BD_Variable = data.BD_Variable ;
            MuliColList = gui.Spec2ListBDVar ;
            for i = 1:numel(HouseSelected)
                Housenumber = (HouseSelected{i}) ;
                HouseVar = uimulticollist( MuliColList, 'string' ) ;
                HouseVarName = HouseVar(2:end,1);
                for ij = 1:numel(BD_Variable)
                    BD_Var = BD_Variable{ij} ;
                    if ~strcmp(BD_Var,'Select...')
                        switch src.String{src.Value}
                            case 'Default'
                                % Check for each variable in the
                                % uimulticollist
                                LocateVar = find(strcmp(HouseVarName,BD_Var)==1) + 1 ;
                                if ~isempty(LocateVar)
                                    newValue = data.varname.(BD_Var).Defaultvalue ;
                                    uimulticollist( MuliColList, 'changeItem', newValue, LocateVar, 2 )
                                end
                            case 'Define'
                                try
                                    % Look for user-defined value    
                                    Var2Get = data.varname.(BD_Var).UserDefValue.(Housenumber) ;
                                catch
                                    % There is no user-defined value
                                    % Go to the next variable
                                    continue;
                                end
                                % Check if the variable already exist in
                                % the summary table
                                LocateVar = find(strcmp(HouseVarName,BD_Var)==1) + 1 ;
                                Variable_Name   = BD_Var;
                                Vairable_Value  = Var2Get;
                                if isempty(LocateVar)
                                % If not add the variable
                                    rowItems = {Variable_Name Vairable_Value};
                                    uimulticollist( MuliColList, 'addRow', rowItems )
                                else
                                % If yes change the related value to the
                                % user defined value
                                    uimulticollist( MuliColList, 'changeItem', Vairable_Value, LocateVar, 2 )
                                end
                            otherwise
                        end
                    end
                end
            end
        end
    end %Spec2InputBDVar
%-------------------------------------------------------------------------%
    function DisEnaBoxPanel(BoxPanelName,EnaDis,Exception,Top)
        switch BoxPanelName.Type
            case 'uipanel'
                for i = 1:numel(BoxPanelName.Contents)
                    NewName = BoxPanelName.Children(i);
                    try
                        Exception      ;
                    catch
                        Exception = {} ;
                    end
                    DisEnaBoxPanel(NewName,EnaDis,Exception,'Top');
                end
            case 'uicontainer'
                try
                    Exception      ;
                catch
                    Exception = {} ;
                end
                for i = 1:numel(BoxPanelName.Contents)
                    if isempty(Exception)
                         if ~(strcmp(Top,'Top') && i == numel(BoxPanelName.Contents))
                            NewName = BoxPanelName.Children(i);
                            DisEnaBoxPanel(NewName,EnaDis,Exception,'NotTop');
                        end
                    else
                        if ( numel(BoxPanelName.Contents))
                            NewName = BoxPanelName.Children(i);
                            if ~strcmp(Exception,NewName.Tag)
                                if ~(strcmp(Top,'Top') && i == numel(BoxPanelName.Contents))
                                    DisEnaBoxPanel(NewName,EnaDis,Exception,'NotTop');
                                end
                            end
                        end
                    end
                end
            case 'uicontrol'
                set(BoxPanelName,'Enable',EnaDis);
                if strcmp(BoxPanelName.Style,'listbox')
                    NbrRows = uimulticollist(BoxPanelName,'nRows') ;
                    if strcmp(EnaDis,'off')
                        % If disable, delete all user defined values
                        uimulticollist( BoxPanelName, 'value', 1 );
                        for ir = 1:NbrRows
                            if ~(ir == NbrRows)
                                uimulticollist( BoxPanelName, 'delRow', 0 )
                            end
                        end
                    else
                        %Get the variables for the current frame
                        Spec2List = BoxPanelName.Tag;
                        tech = erase(Spec2List,'Spec2List') ;
                        Spec2Define = strcat('Spec2Define',tech);
                        Spec2DefineVariable = gui.(Spec2Define).String ;
                        % If enable, reinput the user-defined value
                        % First we must check if multiple houses are
                        % selected
                        if isempty(gui.ListBox.String)
                            return
                        end
                        
                        HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
                        for ivar = 1:numel(Spec2DefineVariable)
                            varname = Spec2DefineVariable{ivar};
                            if numel(HouseSelected) > 1
                                if ~strcmp(varname,'Select...')
                                    for ir = 1:numel(HouseSelected)
                                        Housenumber = (HouseSelected{ir}) ;
                                        try
                                           varnameValue = data.varname.(varname).UserDefValue.(Housenumber);
                                        catch
                                           % Does not exist so disregard this variable
                                           varnameValue = '';
                                        end
                                        CurrentTable = uimulticollist( BoxPanelName,'string') ;
                                        if ~isempty(varnameValue)
                                            if ir > 1
                                                if ~strcmp(VarPrevious,varnameValue)
                                                    break;
                                                else
                                                    if ir == numel(HouseSelected)
                                                        if sum(strcmp(CurrentTable(:,1),varname)) >= 1
                                                             % Variable already listed so just
                                                             % change the quantity
                                                            Row2change = find(strcmp(CurrentTable(:,1),varname) == 1);
                                                            uimulticollist( BoxPanelName, 'changeItem', varnameValue, Row2change, 2 )
                                                        else    
                                                            rowItems = {varname varnameValue};
                                                            uimulticollist( BoxPanelName, 'addRow', rowItems)
                                                        end
                                                        
                                                    end
                                                end
                                            end
                                        else
                                            if ir > 1
                                                if sum(strcmp(CurrentTable(:,1),varname)) >= 1
                                                    Row2change = find(strcmp(CurrentTable(:,1),varname) == 1);
                                                    uimulticollist( BoxPanelName, 'value',1)
                                                    uimulticollist( BoxPanelName, 'delRow', Row2change )
                                                end
                                            end
                                        end
                                        VarPrevious = varnameValue ;
                                    end
                                end
                            else
                                 Housenumber = HouseSelected{1} ;
                                 try
                                    varnameValue = data.varname.(varname).UserDefValue.(Housenumber);
                                 catch
                                    % Does not exist so disregard this variable
                                    varnameValue = '';
                                 end
                                 CurrentTable = uimulticollist( BoxPanelName,'string') ;
                                 if ~isempty(varnameValue)
                                     rowItems = {varname varnameValue};
                                     if sum(strcmp(CurrentTable(:,1),varname)) >= 1
                                         % Variable already listed so just
                                         % change the quantity
                                         Row2change = find(strcmp(CurrentTable(:,1),varname) == 1);
                                         uimulticollist( BoxPanelName, 'changeItem', varnameValue, Row2change, 2 )
                                     else    
                                        uimulticollist( BoxPanelName, 'addRow', rowItems)
                                     end
                                 elseif ~strcmp(varname,'Select...')
                                     if sum(strcmp(CurrentTable(:,1),varname)) >= 1
                                         Row2change = find(strcmp(CurrentTable(:,1),varname) == 1);
                                         uimulticollist( BoxPanelName, 'value',1)
                                         uimulticollist( BoxPanelName, 'delRow', Row2change )
                                     end
                                 end
                            end
                        end
                        % If yes, then we need to compare the value for
                        % each variable, display them if they are the same,
                        % do not show them if they are different.
                        
                        % 
                    end
                end
        end
    end %DisEnaBoxPanel
%--------------------------------------------------------------------------%
    function Checkforupdate(src,~)
        checkupdate ;
    end %Checkforupdate

%--------------------------------------------------------------------------%
function HeatingTechnologySetting(src,~)
if isempty(gui.ListBox.String)|| isempty(gui.ListBox.String{1})
    errordlg('Please add house first!','No houses are created','non-modal')
    return
end

HousingSelected     = gui.ListBox.String(gui.ListBox.Value) ;
GetSource           = src.Tag;
HeatingType         = gui.Heating_Tech  ;
Charging_strategy   = gui.Charging_strategy;

switch GetSource
    case 'Heating_Tech'
        HeatingSelected = src.String(src.Value);
        if strcmp(HeatingSelected,'Underfloor heating') == 1
            set(Charging_strategy,'enable','on')
            HeatingTechnologySetting(Charging_strategy)
        else
            set(Charging_strategy,'enable','off')
            HeatingTechnologySetting(Charging_strategy)
        end
        for i = 1:numel(HousingSelected)
            HouseTag = HousingSelected{i};
            SaveData(GetSource,HouseTag,HeatingSelected)
        end
    case 'Charging_strategy'
        ChargingStrategySelected = src.String(src.Value);
        for i = 1:numel(HousingSelected)
            HouseTag = HousingSelected{i};
            SaveData(GetSource,HouseTag,ChargingStrategySelected)
        end
    case 'ComfortLimit'
        ComfortLimitSelected = src.String(src.Value);
        for i = 1:numel(HousingSelected)
            HouseTag = HousingSelected{i};
            SaveData(GetSource,HouseTag,ComfortLimitSelected)
        end
    case 'Ventil'
        VentilationSelected = src.String(src.Value);
        for i = 1:numel(HousingSelected)
            HouseTag = HousingSelected{i};
            SaveData(GetSource,HouseTag,VentilationSelected)
        end
end
        
end
%--------------------------------------------------------------------------%
%% Test for creating callback function for the database values
function HeatingDatabase(src,~)
n = 0;
srcOriginal = src;
while n == 0
    if strcmp(srcOriginal.Parent.Type,'uipanel') == 1
        n = 1;
        uiPanelOriginal = srcOriginal.Parent;
    else
        srcOriginal = srcOriginal.Parent;
    end
end

switch src.String{src.Value}
    case 'Default'
        EnaDis = 'off';
        DisEnaBoxPanel(uiPanelOriginal,EnaDis,{src.Tag})
    case {'Define', 'Database'}
        EnaDis = 'on';
        DisEnaBoxPanel(uiPanelOriginal,EnaDis,{src.Tag})
    otherwise
        return
end

if isempty(gui.ListBox.String) == 0
    SelectedHouse = gui.ListBox.String(gui.ListBox.Value);
    Thermal_variables = data.TP_Variable;
    Ventilation_variables = data.Ventil_Variable;
    MultiColList = gui.Spec2ListTPVar;
    MultiColList1 = gui.Spec2ListVentVar;
    if strcmp(gui.ListBox.Enable,'off') == 1
        if strcmp(src.String{src.Value},'Database') == 1
            Years = {'1978','1985','2003','2007','2010','2018','Low Energy Building','Passive Building'};
            [indx,tf] = listdlg('ListString',Years,'PromptString','Please select the house type from the database:','Name','Select housetype for the database',...
                                            'OKString','Select','CancelString','No house selected','SelectionMode','Single');
                                        
                                if tf ~=0
                                    msg = {'The' char(Years{indx}) ' building type was selected!'};
                                    msgbox(strcat(msg{1}, {' '}, msg{2:3}),'The reference year selected succesfully!')
                                else
                                    msgbox('No reference building was selected! The action was terminated!','Action terminated!')
                                end
        end
        for i = 1:numel(SelectedHouse)
            Housenumber = (SelectedHouse{i});
            HouseVar = uimulticollist(MultiColList, 'string');
            HouseVar1 = uimulticollist(MultiColList1, 'string');
            HouseVarName = HouseVar(2:end,1);
            HouseVarName1 = HouseVar1(2:end,1);
                                        if tf == 0      % No selection were made
                                            return
                                        else
                                            data.Simulationdata.(Housenumber).house_type = num2str(indx);
                                            data.SummaryStructure.(Housenumber).house_type = num2str(indx);
                                            if exist('U_values','var') == 0
                                                load('U_values.mat','U_values')
                                            end
                                            % Add here the variables
                                            % % Do these need to be changed
                                            % to data.SummaryStructure?
                                            % Why are the values rounded?
%                                                 data.Simulationdata.(Housenumber).uvs        = num2str(U_values{indx+1,1});
%                                                 data.Simulationdata.(Housenumber).uve        = num2str(U_values{indx+1,1});
%                                                 data.Simulationdata.(Housenumber).uvw        = num2str(U_values{indx+1,1});
%                                                 data.Simulationdata.(Housenumber).uvn        = num2str(U_values{indx+1,1});
%     
%                                                 data.Simulationdata.(Housenumber).uvsw       = num2str(U_values{indx+1,4});
%                                                 data.Simulationdata.(Housenumber).uvew       = num2str(U_values{indx+1,4});
%                                                 data.Simulationdata.(Housenumber).uvnw       = num2str(U_values{indx+1,4});
%                                                 data.Simulationdata.(Housenumber).uvww       = num2str(U_values{indx+1,4});
%     
%                                                 data.Simulationdata.(Housenumber).uvd        = num2str(U_values{indx+1,5});
%     
%                                                 data.Simulationdata.(Housenumber).uvf        = num2str(U_values{indx+1,3});
%                                                 data.Simulationdata.(Housenumber).uvr        = num2str(U_values{indx+1,2});
%     
%                                                 data.Simulationdata.(Housenumber).n50        = num2str(U_values{indx+1,6});
%     
%                                                 data.Simulationdata.(Housenumber).Heat_recovery_ventil_annual = num2str(U_values{indx+1,7});
%     
%                                                 data.Simulationdata.(Housenumber).gwindow    = num2str(U_values{indx+1,8});

                                                data.SummaryStructure.(Housenumber).uvs        = num2str(U_values{indx+1,1});
                                                data.SummaryStructure.(Housenumber).uve        = num2str(U_values{indx+1,1});
                                                data.SummaryStructure.(Housenumber).uvw        = num2str(U_values{indx+1,1});
                                                data.SummaryStructure.(Housenumber).uvn        = num2str(U_values{indx+1,1});
    
                                                data.SummaryStructure.(Housenumber).uvsw       = num2str(U_values{indx+1,4});
                                                data.SummaryStructure.(Housenumber).uvew       = num2str(U_values{indx+1,4});
                                                data.SummaryStructure.(Housenumber).uvnw       = num2str(U_values{indx+1,4});
                                                data.SummaryStructure.(Housenumber).uvww       = num2str(U_values{indx+1,4});
    
                                                data.SummaryStructure.(Housenumber).uvd        = num2str(U_values{indx+1,5});
    
                                                data.SummaryStructure.(Housenumber).uvf        = num2str(U_values{indx+1,3});
                                                data.SummaryStructure.(Housenumber).uvr        = num2str(U_values{indx+1,2});
    
                                                data.SummaryStructure.(Housenumber).n50        = num2str(U_values{indx+1,6});
    
                                                data.SummaryStructure.(Housenumber).Heat_recovery_ventil_annual = num2str(U_values{indx+1,7});
    
                                                data.SummaryStructure.(Housenumber).gwindow    = num2str(U_values{indx+1,8});


                                                if indx == 7 || indx == 8
%                                                     data.Simulationdata.(Housenumber).vent_elec  = num2str(U_values{indx+1,9});
                                                    data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9});

                                                else
%                                                         data.Simulationdata.(Housenumber).vent_elec  = U_values{indx+1,9};
                                                        if strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Natural ventilation') == 1
                                                            data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(1));
                                                        elseif strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Mechanical ventilation') == 1
                                                            data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(2));
                                                        elseif strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Air-Air H-EX') == 1
                                                            data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(3));
                                                        end



%                                                         data.SummaryStructure.(Housenumber).vent_elec  = U_values{indx+1,9};

                                                end
                                            % Add here the variables to
                                            % data.Simulationdata.(HouseSelected{i}).Variable
                                        end
                                        
         for j = 1:numel(Thermal_variables)
            Thermal_Var = Thermal_variables{j};
            if strcmp(Thermal_Var,'Select...') == 0
                switch src.String{src.Value}
                    case 'Default'
                    LocateVariable = find(strcmp(HouseVarName,Thermal_Var)==1) +1;
                    if isempty(LocateVariable) == 0
                        newValue = data.varname.(Thermal_Var).Defaultvalue;
                        uimulticollist(MultiColList,'changeItem',newValue,LocateVariable, 2)
                    end
                    case 'Define'
                        try 
                            Var2Get = data.varname.(Thermal_Var).UserDefValue.(Housenumber);
                        catch 
                            continue
                        end
                    LocateVariable = find(strcmp(HouseVarName,Thermal_Var) == 1) +1;
                    Variable_Name = Thermal_Var;
                    Variable_Value = Var2Get;
                    if isempty(LocateVariable) == 0
                        rowItems = {Variable_Name, Variable_Value};
                        uimulticollist(MultiColList,'addRow',rowItems)
                    else
                        uimulticollist(MultiColList,'changeItem',Variable_Value, LocateVariable, 2)
                    end
                    case 'Database'
%                         src.Tag = 'Spec2Add';
%                                     Spec2Define = strcat('Spec2Define','TPVar');
%                                     Spec2List = strcat('Spec2List','TPVar');
%                                     Spec2Input = strcat('Spec2Input','TPVar');
%                         FillSSProdList(Spec2Define,Spec2List,Spec2Input,src)
%                         src.Tag = 'Spec2Define';
                        LocateVariable = find(strcmp(HouseVarName,Thermal_Var) == 1) +1;
                        Variable_Name = Thermal_Var;
%                         Variable_Value = data.Simulationdata.(Housenumber).(Thermal_Var);
                        Variable_Value = data.SummaryStructure.(Housenumber).(Thermal_Var);

                        
                        if isempty(LocateVariable) == 1
                            rowItems = {Variable_Name, Variable_Value};
                            uimulticollist(MultiColList,'addRow',rowItems)
                        else
                            uimulticollist(MultiColList,'changeItem',Variable_Value, LocateVariable, 2)
                        end
                        
                end
            end
        end
        for j = 1:numel(Ventilation_variables)
            Ventil_var = Ventilation_variables{j};
            if strcmp(Ventil_var,'Select...') == 0 && strcmp(Ventil_var,'N0') == 0
                switch src.String{src.Value}
                    case {'Default', 'Define'}
                        continue
                    case 'Database'
                       LocateVariable = find(strcmp(HouseVarName1,Ventil_var) == 1) +1;
                        Variable_Name = Ventil_var;
%                         Variable_Value = data.Simulationdata.(Housenumber).(Ventil_var);
                        Variable_Value = data.SummaryStructure.(Housenumber).(Ventil_var);

                        
                        if isempty(LocateVariable) == 1
                            rowItems = {Variable_Name, Variable_Value};
                            uimulticollist(MultiColList1,'addRow',rowItems)
                        else
                            uimulticollist(MultiColList1,'changeItem',Variable_Value, LocateVariable, 2)
                        end 
                end
            end
        end
                                        
        end
        
    else
        
    for i = 1:numel(SelectedHouse)
        Housenumber = (SelectedHouse{i});
        HouseVar = uimulticollist(MultiColList, 'string');
        HouseVar1 = uimulticollist(MultiColList1, 'string');
        HouseVarName = HouseVar(2:end,1);
        HouseVarName1 = HouseVar1(2:end,1);
                            if strcmp(src.String{src.Value},'Database') == 1
                        Years = {'1978','1985','2003','2007','2010','2018','Low Energy Building','Passive Building'};
                        [indx,tf] = listdlg('ListString',Years,'PromptString','Please select the house type from the database:','Name','Select housetype for the database',...
                                            'OKString','Select','CancelString','No house selected','SelectionMode','Single');
                                        
                                if tf ~=0
                                    msg = {'The' char(Years{indx}) ' building type was selected!'};
                                    msgbox(strcat(msg{1}, {' '}, msg{2:3}),'The reference year selected succesfully!')
                                else
                                    msgbox('No reference building was selected! The action was terminated!','Action terminated!')
                                end
                                        
                                        if tf == 0      % No selection were made
                                            return
                                        else
                                            data.Simulationdata.(Housenumber).house_type = num2str(indx);
                                            data.SummaryStructure.(Housenumber).house_type = num2str(indx);
                                            if exist('U_values','var') == 0
                                                load('U_values.mat','U_values')
                                            end
                                            % Add here the variables
                                            % % Do these need to be changed
                                            % to data.SummaryStructure?
                                            % Why are the values rounded?
%                                                 data.Simulationdata.(Housenumber).uvs        = num2str(U_values{indx+1,1});
%                                                 data.Simulationdata.(Housenumber).uve        = num2str(U_values{indx+1,1});
%                                                 data.Simulationdata.(Housenumber).uvw        = num2str(U_values{indx+1,1});
%                                                 data.Simulationdata.(Housenumber).uvn        = num2str(U_values{indx+1,1});
%     
%                                                 data.Simulationdata.(Housenumber).uvsw       = num2str(U_values{indx+1,4});
%                                                 data.Simulationdata.(Housenumber).uvew       = num2str(U_values{indx+1,4});
%                                                 data.Simulationdata.(Housenumber).uvnw       = num2str(U_values{indx+1,4});
%                                                 data.Simulationdata.(Housenumber).uvww       = num2str(U_values{indx+1,4});
%     
%                                                 data.Simulationdata.(Housenumber).uvd        = num2str(U_values{indx+1,5});
%     
%                                                 data.Simulationdata.(Housenumber).uvf        = num2str(U_values{indx+1,3});
%                                                 data.Simulationdata.(Housenumber).uvr        = num2str(U_values{indx+1,2});
%     
%                                                 data.Simulationdata.(Housenumber).n50        = num2str(U_values{indx+1,6});
%     
%                                                 data.Simulationdata.(Housenumber).Heat_recovery_ventil_annual = num2str(U_values{indx+1,7});
%     
%                                                 data.Simulationdata.(Housenumber).gwindow    = num2str(U_values{indx+1,8});

                                                data.SummaryStructure.(Housenumber).uvs        = num2str(U_values{indx+1,1});
                                                data.SummaryStructure.(Housenumber).uve        = num2str(U_values{indx+1,1});
                                                data.SummaryStructure.(Housenumber).uvw        = num2str(U_values{indx+1,1});
                                                data.SummaryStructure.(Housenumber).uvn        = num2str(U_values{indx+1,1});
    
                                                data.SummaryStructure.(Housenumber).uvsw       = num2str(U_values{indx+1,4});
                                                data.SummaryStructure.(Housenumber).uvew       = num2str(U_values{indx+1,4});
                                                data.SummaryStructure.(Housenumber).uvnw       = num2str(U_values{indx+1,4});
                                                data.SummaryStructure.(Housenumber).uvww       = num2str(U_values{indx+1,4});
    
                                                data.SummaryStructure.(Housenumber).uvd        = num2str(U_values{indx+1,5});
    
                                                data.SummaryStructure.(Housenumber).uvf        = num2str(U_values{indx+1,3});
                                                data.SummaryStructure.(Housenumber).uvr        = num2str(U_values{indx+1,2});
    
                                                data.SummaryStructure.(Housenumber).n50        = num2str(U_values{indx+1,6});
    
                                                data.SummaryStructure.(Housenumber).Heat_recovery_ventil_annual = num2str(U_values{indx+1,7});
    
                                                data.SummaryStructure.(Housenumber).gwindow    = num2str(U_values{indx+1,8});


                                                if indx == 7 || indx == 8
%                                                     data.Simulationdata.(Housenumber).vent_elec  = num2str(U_values{indx+1,9});
                                                    data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9});

                                                else
%                                                         data.Simulationdata.(Housenumber).vent_elec  = U_values{indx+1,9};
                                                        if strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Natural ventilation') == 1
                                                            data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(1));
                                                        elseif strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Mechanical ventilation') == 1
                                                            data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(2));
                                                        elseif strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Air-Air H-EX') == 1
                                                            data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(3));
                                                        end



%                                                         data.SummaryStructure.(Housenumber).vent_elec  = U_values{indx+1,9};

                                                end
                                            % Add here the variables to
                                            % data.Simulationdata.(HouseSelected{i}).Variable
                                        end
                            end
        for j = 1:numel(Thermal_variables)
            Thermal_Var = Thermal_variables{j};
            if strcmp(Thermal_Var,'Select...') == 0
                switch src.String{src.Value}
                    case 'Default'
                    LocateVariable = find(strcmp(HouseVarName,Thermal_Var)==1) +1;
                    if isempty(LocateVariable) == 0
                        newValue = data.varname.(Thermal_Var).Defaultvalue;
                        uimulticollist(MultiColList,'changeItem',newValue,LocateVariable, 2)
                    end
                    case 'Define'
                        try 
                            Var2Get = data.varname.(Thermal_Var).UserDefValue.(Housenumber);
                        catch 
                            continue
                        end
                    LocateVariable = find(strcmp(HouseVarName,Thermal_Var) == 1) +1;
                    Variable_Name = Thermal_Var;
                    Variable_Value = Var2Get;
                    if isempty(LocateVariable) == 0
                        rowItems = {Variable_Name, Variable_Value};
                        uimulticollist(MultiColList,'addRow',rowItems)
                    else
                        uimulticollist(MultiColList,'changeItem',Variable_Value, LocateVariable, 2)
                    end
                    case 'Database'
%                         src.Tag = 'Spec2Add';
%                                     Spec2Define = strcat('Spec2Define','TPVar');
%                                     Spec2List = strcat('Spec2List','TPVar');
%                                     Spec2Input = strcat('Spec2Input','TPVar');
%                         FillSSProdList(Spec2Define,Spec2List,Spec2Input,src)
%                         src.Tag = 'Spec2Define';
                        LocateVariable = find(strcmp(HouseVarName,Thermal_Var) == 1) +1;
                        Variable_Name = Thermal_Var;
%                         Variable_Value = data.Simulationdata.(Housenumber).(Thermal_Var);
                        Variable_Value = data.SummaryStructure.(Housenumber).(Thermal_Var);

                        
                        if isempty(LocateVariable) == 1
                            rowItems = {Variable_Name, Variable_Value};
                            uimulticollist(MultiColList,'addRow',rowItems)
                        else
                            uimulticollist(MultiColList,'changeItem',Variable_Value, LocateVariable, 2)
                        end
                        
                end
            end
        end
        for j = 1:numel(Ventilation_variables)
            Ventil_var = Ventilation_variables{j};
            if strcmp(Ventil_var,'Select...') == 0 && strcmp(Ventil_var,'N0') == 0
                switch src.String{src.Value}
                    case {'Default', 'Define'}
                        continue
                    case 'Database'
                       LocateVariable = find(strcmp(HouseVarName1,Ventil_var) == 1) +1;
                        Variable_Name = Ventil_var;
%                         Variable_Value = data.Simulationdata.(Housenumber).(Ventil_var);
                        Variable_Value = data.SummaryStructure.(Housenumber).(Ventil_var);

                        
                        if isempty(LocateVariable) == 1
                            rowItems = {Variable_Name, Variable_Value};
                            uimulticollist(MultiColList1,'addRow',rowItems)
                        else
                            uimulticollist(MultiColList1,'changeItem',Variable_Value, LocateVariable, 2)
                        end 
                end
            end
        end
            
    end
    end
end
end
%--------------------------------------------------------------------------%
%% This function is used in importing external file to the model to be used as source for the code
% You can import a suitable file for yourself to be used in the simulation

function ImportExternalFile(src, ~)

% Start with defining whether a file is added or removed.
    
if strcmp(src.String,'Add')

        [file, path] = uigetfile('*.mat');

        if file == 0
            return;
        else
            FullFile = strcat(path,file);
        end

% Assign a notice of which file has been changed!
% This is needed in Launch_Sim file to assign the created file into the
% correct slot! Consider also extra selection for the start of the
% databases

switch(src.Tag)
    case 'Temperature'
        data.FileSelection.TemperatureFile      = FullFile;
        data.FileSelection.TemperatureChanged   = 1;
        gui.TemperatureFile.String              = FullFile;
        % Code
    case 'Radiation'
        data.FileSelection.RadiationFile        = FullFile;
        data.FileSelection.RadiationChanged     = 1;
        gui.RadiationFile.String                = FullFile;
        % Code
    case 'Price'
        data.FileSelection.PriceFile            = FullFile;
        data.FileSelection.PriceChanged         = 1;
        gui.PriceFile.String                    = FullFile;
        % Code
    case 'Emission'
        data.FileSelection.EmissionsFile        = FullFile;
        data.FileSelection.EmissionsChanged     = 1;
        gui.EmissionFile.String                 = FullFile;
        % Code
        
end

elseif strcmp(src.String,'Remove')
    % The part where the preselected file is removed and the default file
    % is used!
    
    switch(src.Tag)
        case 'Temperature'
            data.FileSelection.TemperatureFile = [];
            data.FileSelection.TemperatureChanged = 0;
            gui.TemperatureFile.String            = 'Select Temperature file...';
            % Code
        case 'Radiation'
            data.FileSelection.RadiationFile = [];
            data.FileSelection.RadiationChanged = 0;
            gui.RadiationFile.String            = 'Select Radiation file...';
            % Code
        case 'Price'
            data.FileSelection.PriceFile = [];
            data.FileSelection.PriceChanged = 0;
            gui.PriceFile.String            = 'Select Price file...';
            % Code
        case 'Emission'
            data.FileSelection.EmissionsFile = [];
            data.FileSelection.EmissionsChanged = 0;
            gui.EmissionFile.String            = 'Select Emission file...';
            % Code
    end
    
    
else
        return;     % Then neither adding or removing is selected and this should not do anything!
    

end

end

%--------------------------------------------------------------------------%
%% Function for adding the start of the selected database
% This is added to find the offset of the current day and the start of the
% database.
    function DataSetStart(src, ~)
        switch(src.Tag)
            case 'AdditionTemp&Rad'
                data.FileSelection.StartYearTempRad = gui.StartYearTempRad.String;
                msgbox('The start year for temperature and solar radiation databases has been set!', 'Start year added!')
            case 'AdditionPrice&Emission'
                data.FileSelection.StartYearPriceEmissions = gui.StartYearPriceEmissions.String;
                msgbox('The start year for price and emission databases has been set!', 'Start year added!')
        end
    end

%--------------------------------------------------------------------------%
%% Function for adjusting the appliance panel
    function ListApplianceSelection(src, ~)
        
        persistent chk
        
        if strcmp(src.Tag,'Modify') || strcmp(src.Tag,'Remove')     % Assign persistent variable to 1, in case the callback comes from right clicking the appliance list box
            chk = 1;
        end
        
        if isempty(chk)
              chk = 1;
              pause(0.2); %Add a delay to distinguish single click from a double click
              if chk == 1
                  % Execute a single click action  
%                   fprintf(1,'\nI am doing a single-click.\n\n');
                  chk = [];
              end
        else
              % Execute a double click action   
%               fprintf(1,'\nI am doing a double-click.\n\n');
              chk = [];
              
                % In case of double click, open a new message box and allow the user to define the variables themselves
                
                % Determine the values of the selected column
                
                selectedAppliance   = uimulticollist(gui.multicolumnApp, 'selectedStrCol', 1);
                selectedRank        = uimulticollist(gui.multicolumnApp, 'selectedStrCol', 2);
                selectedQuantity    = uimulticollist(gui.multicolumnApp, 'selectedStrCol', 3);
                
%                 matchAppliance  = find(strcmp(data.AppliancesList(:,1),selectedAppliance) == 1);
%                 matchRank       = find(strcmp(data.Rating,selectedRank) == 1);

                % Neglect the selection if the selection is the first row!
                
                if strcmp(selectedAppliance,'Appliance')       % The first row is an exception and should be neglected
                    
                    return;
                    
                end
                
                % Create a window for determining the modifications to the
                % selection
                
                    Mfigpos = get(gui.Window,'OuterPosition') ;
                    buttonwidth = 250 ;
                    buttonheight = 150 ;
                    gui.AddAppDialog = figure('units','pixels',...
                         'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                     Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                     buttonwidth,...
                                     buttonheight],...
                         'toolbar','none',...
                         'menu','none',....
                         'name','Modify the appliance selection',....
                         'NumberTitle','off',...
                         'Tag','AddFigure',...
                         'CloseRequestFcn',@closeRequest);
                     set(gui.AddAppDialog,'WindowStyle','modal')
                     set(gui.AddAppDialog, 'Resize', 'off');

                     DivideVert = uix.VBox('Parent',gui.AddAppDialog) ;

                     AppList = data.AppliancesList(:,1);

                     n = 1 ;
                     ToInsert = 'Select appliance...';
                     AppList(n+1:end+1,:) = AppList(n:end,:);
                     AppList(n,:) = {ToInsert};
                     AppList = orderalphacellarray(AppList,2,numel(AppList));

                     gui.popupApp = uicontrol('Parent',DivideVert,...
                               'Style','popup',...
                               'String', AppList,...
                               'Tag','popupApp',...
                               'Callback',@ModifyApplianceCall) ;
                           set(gui.popupApp, 'Value', find(strcmp(AppList,selectedAppliance)==1));
                           data.TemporaryData.Original = gui.popupApp.String(gui.popupApp.Value);
                     gui.popupRate = uicontrol('Parent',DivideVert,...
                               'Style','popup',...
                               'Tag','popupRate',...
                               'String','Select...',...
                               'Callback',@ModifyApplianceCall);
                           
                           if strcmp(data.TemporaryData.Original,'Lighting System') 
                               set(gui.popupRate, 'String', data.Lightopt(:));
                               OriginalRank = get(gui.popupRate, 'String');
                           elseif strcmp(data.AppliancesList((strcmp(data.AppliancesList(:,1),data.TemporaryData.Original)==1),2),'Rate')
                               set(gui.popupRate, 'String', data.Rating(:));
                               OriginalRank = get(gui.popupRate, 'String');
                           else
                               set(gui.popupRate, 'String', {'Select...', '-'});
                               OriginalRank = get(gui.popupRate, 'String');
                           end
                           
                           if any(strcmp(OriginalRank(:),selectedRank)==1)
                               set(gui.popupRate, 'Value', find(strcmp(OriginalRank,selectedRank)==1));
                           end
                     gui.popupQty = uicontrol('Parent',DivideVert,...
                               'Style','popup',...
                               'Tag','popupQty',...
                               'String',{'1' '2' '3' '4' '5' 'more...' '0'},...
                               'Callback',@ModifyApplianceCall);
                           set(gui.popupQty, 'Value', find(strcmp(gui.popupQty.String, selectedQuantity)==1));
                     uix.Empty('Parent',DivideVert) ;

                     buttonbox =  uix.HBox('Parent',DivideVert) ; 
                     uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Ok','Tag','Ok','Callback',@ModifyApplianceCall)
                     uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Cancel','Tag','Cancel','Callback',@ModifyApplianceCall)

                     set( DivideVert,'Heights', [-1 -1 -1 -.5 -1] );        

                     uiwait(gcf);
                     str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                     [srow,~] = size(str) ;
                     if srow>1
                         set(gui.RemoveAppliance,'enable','on')
                     end
                     
                
        end
        
 end       
%--------------------------------------------------------------------------%
%% Function for modifying the appliance selection
    function ModifyApplianceCall(src,~)
        
        switch(src.Tag)
            case 'popupApp'
                Appliance       = gui.popupApp.String(gui.popupApp.Value);
                indx            = (strcmp(data.AppliancesList(:,1),Appliance)==1);
                markRate        = data.AppliancesList(indx,2);
                
                
%                 if strcmp(data.TemporaryData.Original,Appliance) == 0
%                     
%                     if strcmp(data.AppliancesList((strcmp(data.AppliancesList(:,1),Appliance)==1),2),data.AppliancesList((strcmp(data.AppliancesList(:,1),data.TemporaryData.Original)==1),2)) == 0
                
                        if strcmp(Appliance,'Lighting System')
                            if strcmp(data.TemporaryData.Original,Appliance) == 0
                                set(gui.popupRate,'value',1);
                            end
                            gui.popupRate.String = data.Lightopt(:);
                        elseif strcmp(markRate,'Rate')
                            if strcmp(data.TemporaryData.Original,Appliance) == 0
                                set(gui.popupRate,'value',1);
                            end
                            gui.popupRate.String = data.Rating(:);
                        else
                            if strcmp(data.TemporaryData.Original,Appliance) == 0
                                set(gui.popupRate,'value',1);
                            end
                            gui.popupRate.String = {'Select...','-'};
                            set(gui.popupRate,'value',2);
                        end
                        
%                     end
%                     
%                 end
                            
                
            case 'Ok'
                
                % Start by validating the selections
                
                    Check1 = gui.popupApp ;
                        Inputstr1 = Check1.String(Check1.Value) ;
                        if strcmp(Inputstr1,'Select appliance...') 
                            uiwait(msgbox('Please select an appliance','Error','modal'));
                            return;
                        end
                    Check2 = gui.popupRate ;
                        Inputstr2 = Check2.String(Check2.Value) ;
                        if strcmp(Inputstr2,'Select...') || strcmp(Inputstr2,'S')
                            uiwait(msgbox('Please select category','Error','modal'));
                            return;
                        elseif strcmp(Inputstr2,'-')
                        end
                        
                % Start by assigning the values and updating the
                % multicolumnlist
                
                Housenumber     = gui.ListBox.String(gui.ListBox.Value);
                Appliance       = gui.popupApp.String(gui.popupApp.Value);
                indx            = (strcmp(data.AppliancesList(:,1),Appliance)==1);
                App             = data.AppliancesList(indx,3);
                clRate          = data.AppliancesList(indx,4);
                Rate            = gui.popupRate.String(gui.popupRate.Value);
                Quantity        = gui.popupQty.String(gui.popupQty.Value);
                
                % Assign to the data summary struturuce for using the
                % values in the simulation
                if str2double(Quantity) > 0
                    
                    cellAppliances                                              = cell(1,str2double(Quantity));
                    cellAppliances(1:end)                                       = {'1'};
                    if ~isempty(char(App))                                                        % Check that the appliance is not lighting system
                        data.SummaryStructure.(char(Housenumber)).(char(App))       = cellAppliances;
                    end
                    
                    cellClassAppliances                                         = cell(1,str2double(Quantity));
                    cellClassAppliances(1:end)                                  = Rate;
                    if ~isempty(char(clRate))
                        data.SummaryStructure.(char(Housenumber)).(char(clRate))    = cellClassAppliances;
                    end
                    
                    % Add deletion of the original appliance in case the
                    % new appliance is different than the original one!
                    
                    if strcmp(data.TemporaryData.Original,Appliance) == 0
                        
                        OrgIndx            = (strcmp(data.AppliancesList(:,1),data.TemporaryData.Original)==1);
                        OrgApp             = data.AppliancesList(OrgIndx,3);
                        OrgclRate          = data.AppliancesList(OrgIndx,4);
                        
                        data.SummaryStructure.(char(Housenumber)).(char(OrgApp)) = {'0'};
                        
                        if ~isempty(char(OrgclRate))
                            data.SummaryStructure.(char(Housenumber)).(char(OrgclRate)) = {'A or B class'};
                        end
                        
                    end
                        
                   
                else
                    
                    % The case of wanting to remove the current value
                    data.SummaryStructure.(char(Housenumber)).(char(App))   = {'0'};  % Assigment of the empty cell
                    
                    if ~isempty(char(clRate))
                        data.SummaryStructure.(char(Housenumber)).(char(clRate)) = {'A or B class'}; % Default assignment as it does not matter
                    end
                    
                end
                
                % Calculate the new maximum number of appliances
                                
                                MaxApp = maxAppcount(char(Housenumber)) ;
                                SaveData('Appliance_Max',char(Housenumber),MaxApp)
                
                % Update the multicollist to show the present values 
                
                    current = uimulticollist(gui.multicolumnApp,'string');
                    locate = strcmp(current(:,1),Appliance);
                    
                    if nnz(locate) == 0      % Means that the selected appliance does not exist
                        uimulticollist(gui.multicolumnApp, 'addRow', [Appliance Rate Quantity], size(current,1)+1);     % Add the new item to the multicollist
                        uimulticollist(gui.multicolumnApp, 'delRow', (strcmp(current,data.TemporaryData.Original)==1));  % Remove the original 
                        
                    else
                        % If the selected appliance already exists
                        
                        if strcmp(data.TemporaryData.Original,Appliance) == 0   % Case where the selected appliance exists, but it is different than the originally selected
                        
                            uimulticollist(gui.multicolumnApp, 'changeRow', [Appliance Rate Quantity], find(locate==1));
                            uimulticollist(gui.multicolumnApp, 'delRow', (strcmp(current,data.TemporaryData.Original)==1));
                            
                        elseif str2double(Quantity) == 0    % Case where the selected appliance is deleted
                            
                            uimulticollist(gui.multicolumnApp, 'delRow', (strcmp(current,data.TemporaryData.Original)==1));
                            
                        else    % Selected appliance is the same as original 
                            
                            uimulticollist(gui.multicolumnApp, 'changeRow', [Appliance Rate Quantity], find(locate==1));
                            
                        end
                        
                    end
                        
                
                
                    delete(gui.AddAppDialog)        % Delete the figure property to remove the figure.
                    data = rmfield(data,'TemporaryData');
                
            case('Cancel')
                
                delete(gui.AddAppDialog)
                data = rmfield(data,'TemporaryData');
                data.ValidAdd = 0;

        end
        
        
    end
%--------------------------------------------------------------------------%
%% Function for right-clicking the appliance panel
    function ModificationSelection(src,~)
        % Start by creating context menu!
        
        rightClickInfo = uicontextmenu(ancestor(src,'figure'));
        

        
        % Continue by associating different menus on the contextmenu
        
        menu1 = uimenu('Parent', rightClickInfo, 'Label', 'Filter');
        menu2 = uimenu('Parent', rightClickInfo, 'Label', 'Add', 'Tag', 'AddAppliance', 'callback', @AddApplianceCallback);
        menu3 = uimenu('Parent', rightClickInfo, 'Label', 'Modify', 'Tag', 'Modify', 'callback', @ListApplianceSelection);
        menu4 = uimenu('Parent', rightClickInfo, 'Label', 'Remove', 'Tag', 'RemoveAppliance', 'callback', @AddApplianceCallback);
        menu5 = uimenu('Parent', rightClickInfo, 'Label', 'Remove Filter', 'Tag', 'Remove', 'callback', @DetermineAppliance); %, 'Visible', 'off');
        
        ApplianceFilter = uimenu('Parent', menu1, 'Label', 'Appliances');
        RateFilter      = uimenu('Parent', menu1, 'Label', 'Rate');
        QtyFilter       = uimenu('Parent', menu1, 'Label', 'Quantity');
        
        for nn = 1:size(data.AppliancesList(:,1),1)
            uimenu('Parent', ApplianceFilter, 'Label', char(data.AppliancesList(nn,1)), 'Tag', 'Appliance', 'callback', {@DetermineAppliance, menu5});
        end
        
        for mm = 1:size(data.Rating,1)
            uimenu('Parent', RateFilter, 'Label', char(data.Rating(mm)), 'Tag', 'Rate', 'callback', {@DetermineAppliance, menu5});
        end
        
        QtyList = {'1', '2', '3', '4', '5 or more'};
        for hh = 1:5
            uimenu('Parent', QtyFilter, 'Label', char(QtyList(hh)), 'Tag', 'Qty', 'callback', {@DetermineAppliance, menu5});
        end

        
        set(src,'uicontextmenu',rightClickInfo);
        
    end
%--------------------------------------------------------------------------%
%% A function to save database selections
    function SaveDatabase(src, ~)
        
if strcmp(src.Tag, 'Database')
    
        [file, path] = uigetfile('*.mat');

        if file == 0
            return;
        else
            FullFile = strcat(path,file);
        end
    
        Database                                = load(FullFile);
        data.FileSelection                      = Database.FileSelection;
        
        DatabaseNames                           = {'Temperature', 'Radiation', 'Price', 'Emissions', 'StartYearTempRad', 'StartYearPriceEmissions'};
        
        for i = 1:6
            
            if i <= 4
        
                FileName                            = strcat(DatabaseNames{i},'File');
                
            else
                
                FileName                            = DatabaseNames{i};
                
            end
            
            if isfield(data.FileSelection, FileName)
            
            gui.(FileName).String               = data.FileSelection.(FileName);
            
            end
        
        end
        
else
        
        if isfield(data, 'FileSelection')
        
            [file, path] = uiputfile('*.mat');
            
            if file == 0
                return;
            else
                FullFile = strcat(path,file);
                FileSelection = data.FileSelection;
                save(FullFile,'FileSelection');
            end
        
        else
            
            msgbox({'Currently no database directories are defined!';
                    'Try again after defining the selected files.'}, 'Saving the file failed!', 'warn');
           
                return;
                
        end
        
end
    end
%--------------------------------------------------------------------------%
%% This is the callback function of the heating type selection
% Currently only one technology is available, but when more become
% available their callback should be assigned here.
    function HeatingSelection(src,~)
       
        if strcmp(src.String(src.Value),'Direct Electric Space Heating')
            msg = {'Selection was succesful!';'No other option is currently available, so please wait for their additions!'};
            msgbox(msg, 'Succesful selection');
        else
            msg = {'Please select suitable heating technology.';'Currently only direct electric space heating is available so please wait for the other ones'};
            errordlg(msg, 'Error');
            return;
        end
        
    end
%--------------------------------------------------------------------------%
%% This is a function for updating the interface when importing the houses
    function updateView()
        
        % Define housenumber 
        
        Housenumber             = char(gui.ListBox.String(gui.ListBox.Value));
        
        if size(Housenumber,1) > 1        % In case more than one house is selected just assume that the visible values should be from the first selected building!
            
            Housenumber         = char(gui.ListBox.String(gui.ListBox.Value(1)));
            
        end
       
        % Start the updating with the settings
        
        gui.StartingDate.String = data.SummaryStructure.(Housenumber).StartingDate;
        gui.EndingDate.String   = data.SummaryStructure.(Housenumber).EndingDate;
        
        % Update the Electricity contract
        
        gui.ContElec.Value      = find(strcmp(gui.ContElec.String, data.SummaryStructure.(Housenumber).ContElec)==1) ;
        gui.Contract.Value      = find(strcmp(gui.Contract.String, data.SummaryStructure.(Housenumber).Contract)==1) ;
        gui.Low_Price.String    = data.SummaryStructure.(Housenumber).Low_Price;
        gui.High_Price.String   = data.SummaryStructure.(Housenumber).High_Price;
        
        % Update the user-type & profile
        
        User_Type               = data.SummaryStructure.(Housenumber).User_Type;
        
        switch User_Type
            case '1'
                gui.radiobuttonGreen.Value      = 1;
                gui.radiobuttonOrange.Value     = 0;
                gui.radiobuttonBrown.Value      = 0;
            case '2'
                gui.radiobuttonGreen.Value      = 0;
                gui.radiobuttonOrange.Value     = 1;
                gui.radiobuttonBrown.Value      = 0;
            case '3'
                gui.radiobuttonGreen.Value      = 0;
                gui.radiobuttonOrange.Value     = 0;
                gui.radiobuttonBrown.Value      = 1;
        end
        
        gui.Profile.Value       = find(strcmp(gui.Profile.String, data.SummaryStructure.(Housenumber).Profile) == 1);
        
        % Update house details
        
        gui.inhabitants.Value   = find(strcmp(gui.inhabitants.String, data.SummaryStructure.(Housenumber).inhabitants) == 1);
        gui.nbrRoom.String      = data.SummaryStructure.(Housenumber).nbrRoom;
        
        gui.Latitude.String     = data.SummaryStructure.(Housenumber).Latitude;
        gui.Longitude.String    = data.SummaryStructure.(Housenumber).Longitude;
        
        str                     = {'Appliance', 'Rate', 'Qty'};
        
        % Delete the previous information from the multi column list box,
        % and attach only the string to. Afterwards the rest of the
        % information will be added in the for -loop.
        
        nbrOfItems  = uimulticollist(gui.multicolumnApp, 'nRows');
        
        if nbrOfItems > 1       % If only the first row exists, there are no appliances, and there is no need to delete the rows!
            
            uimulticollist( gui.multicolumnApp, 'delRow', 2:nbrOfItems);
            
        end
        
        for i = 1:size(data.AppliancesList,1)
            
            CurrentApp          = data.AppliancesList{i,3};
            CurrentRate         = data.AppliancesList{i,4};
            
            if ~isempty(CurrentApp)
            
                nbrApp              = size(data.SummaryStructure.(Housenumber).(CurrentApp),2);
                
            else
                
                nbrApp              = 1;      % Only lighting has empty field, and there can only be 1 lighting system
                                
            end
            
            if nbrApp == 1 && ~isempty(CurrentApp)      % Either 1 or 0 appliances
                
                if iscell(data.SummaryStructure.(Housenumber).(CurrentApp))         % Normal case during importing
                
                    nbrApp          = str2double(data.SummaryStructure.(Housenumber).(CurrentApp){1});
                    
                else                                                                % Case when updating view and there are no preselected appliances
                    
                    nbrApp          = str2double(data.SummaryStructure.(Housenumber).(CurrentApp));
                    
                end
                
            end
            
            if nbrApp > 0       % Means that current appliances exist
                
                ApplianceLongName   = data.AppliancesList{i,1};
                
                if isempty(CurrentRate)
                    
                    ApplianceRate = '-';
                    
                else
                    
                    if iscell(data.SummaryStructure.(Housenumber).(CurrentRate))        % Normal case when importing
                     
                        ApplianceRate = data.SummaryStructure.(Housenumber).(CurrentRate){1};
                        
                    else                                                                % Case when there is no appliances created
                        
                        ApplianceRate = data.SummaryStructure.(Housenumber).(CurrentRate);
                        
                    end
                    
                end
                
                Quantity            = num2str(nbrApp);
                
                str                 = [str; {ApplianceLongName, ApplianceRate, Quantity}];
                
                NewStr              = str(end,1:3);                                         % Think if could be done more straightfoward
                
                uimulticollist( gui.multicolumnApp, 'addRow', NewStr, size(str,1) )     ;
                
            end
            
        end
        
        if uimulticollist( gui.multicolumnApp, 'nRows') > 1
           
           gui.RemoveAppliance.Enable = 'on';
            
        end
        
        % Add Control options
        
        gui.Metering.Value          = str2double(data.SummaryStructure.(Housenumber).Metering) + 1; %find(strcmp(gui.Metering.String,data.SummaryStructure.(Housenumber).Metering)==1);
        
        gui.Self.Value              = str2double(data.SummaryStructure.(Housenumber).Self);
        gui.Comp.Value              = str2double(data.SummaryStructure.(Housenumber).Comp);
        gui.Goal.Value              = str2double(data.SummaryStructure.(Housenumber).Goal);
        gui.Bill.Value              = str2double(data.SummaryStructure.(Housenumber).Bill);
        
        % Add small-scale production
        
        for j = 1:size(gui.SSPpanel,2)
             
            Technology = get(gui.SSPpanel{j}.Children.Children(2).Children,'Tag');          % Notice that this needs to be changed in case the interface is changed!
        
        if str2double(data.SummaryStructure.(Housenumber).(Technology)) == 1
            
            gui.(Technology).Value          = str2double(data.SummaryStructure.(Housenumber).(Technology));
            
            Variables                       = get(gui.SSPpanel{1}.Children.Children(1).Children(3),'String');           % Probably a better way of handling this!
            
            ListName                        = get(gui.SSPpanel{1}.Children.Children(1).Children(1),'Tag');            
            
            str                             = {'Criteria', 'Input Value'};
            
            nbrOfItems  = uimulticollist(gui.(ListName), 'nRows');
        
            if nbrOfItems > 1       % If only the first row exists, there are no appliances, and there is no need to delete the rows!
            
                uimulticollist( gui.(ListName), 'delRow', 2:nbrOfItems);
            
            end
                
            for ii = 2:size(Variables(1:end),1)       % First row is Select!
                
                VariableName                = Variables{ii};
                Variablevalue               = data.SummaryStructure.(Housenumber).(VariableName);
                
                if ~strcmp(Variablevalue,data.varname.(VariableName).Defaultcreate)
                    
                    str                     = [str; {VariableName, Variablevalue}];
                    
                    NewStr                  = str(end,1:2);
                    
                    uimulticollist( gui.(ListName), 'addRow', NewStr, size(str,1) )     ;                    
                end
                
            end
            
        end
        
        end
        
        % Add Thermal Characteristics
        
        for n = 1:size(gui.TCpanel,2)         % Check every TCpanel for values
            
            Boxes                           = get(gui.TCpanel{n}.Children.Children, 'Tag');
            Number                          = contains(Boxes,'Spec2Define');
            VariableNames                   = get(gui.TCpanel{n}.Children.Children(Number), 'String');
            Number                          = contains(Boxes,'Spec2List');
            ListNames                       = Boxes{Number};
            
            % Change the values in the popupmenus
            
            Type                            = get(gui.TCpanel{n}.Children.Children, 'Type');
            CorType                         = ~strcmp(Type,'uicontrol');                        % The popups are behind another children
            
            if nnz(CorType) == 1
            
                Style                           = get(gui.TCpanel{n}.Children.Children(CorType).Children, 'Style');
                Popups                          = strcmp(Style, 'popupmenu');                       % The changed values are inside popup
                VariableName                    = get(gui.TCpanel{n}.Children.Children(CorType).Children(Popups), 'Tag');   % The name of the variable which is wanted to be updated
                PossibleVariables               = fieldnames(data.SummaryStructure.(Housenumber));
                WantedVariable                  = PossibleVariables(strcmp(PossibleVariables,VariableName));
                 
                if ~isempty(WantedVariable)                 % Wanted variable is empty if there is no similar variable in the defined data, otherwise the popupmenu is updated!
                    
                    Strings                     = get(gui.TCpanel{n}.Children.Children(CorType).Children(Popups), 'String');
                    
                    gui.(WantedVariable).Value  = find(strcmp(Strings,data.SummaryStructure.(Housenumber).(WantedVariable)));
                    
                end
                
            elseif nnz(CorType) > 1
                
                    NbrCorType                  = find(CorType == 1);                
                    
                for jj = 1:nnz(CorType)
                    
                    Style                       = get(gui.TCpanel{n}.Children.Children(NbrCorType(jj)).Children, 'Style');
                    Popups                      = strcmp(Style, 'popupmenu');
                    VariableName                = get(gui.TCpanel{n}.Children.Children(NbrCorType(jj)).Children(Popups), 'Tag');        % This is the name of the variable, which is wanted to be changed
                    PossibleVariables           = fieldnames(data.varname);
                    WantedVariable              = PossibleVariables(strcmp(PossibleVariables,VariableName));
                 
                    if ~isempty(WantedVariable)                 % Wanted variable is empty if there is no similar variable in the defined data, otherwise the popupmenu is updated!
                        
                        WantedVariable          = char(WantedVariable);         % Convert from cell to char!
                    
                        Strings                 = get(gui.TCpanel{n}.Children.Children(NbrCorType(jj)).Children(Popups), 'String');
                    
                        gui.(WantedVariable).Value  = find(strcmp(Strings,data.SummaryStructure.(Housenumber).(WantedVariable)));
                    
                    end
                    
                end
                
            end         % In case there is only uicontrol panels, the simulation should continue
                
            
            str                             = {'Criteria', 'Input Value'};
            
            nbrOfItems  = uimulticollist(gui.(ListNames), 'nRows');
        
            if nbrOfItems > 1       % If only the first row exists, there are no appliances, and there is no need to delete the rows!
            
                uimulticollist( gui.(ListNames), 'delRow', 2:nbrOfItems);
            
            end
            
            for m = 2:size(VariableNames(1:end),1)
                
                Variable                    = VariableNames{m};
                %%% If long names are used, check for the short name
                %%% equivalent else use the shortname value.
                if data.varlongname == 1
                    VariableList = fieldnames(data.datastructure);
                    varfound = 0 ;
                    varlist = 0 ;
                    while varfound < 1
                        varlist = varlist + 1 ;
                        Variablename = VariableList{varlist} ;
                        LongName = data.datastructure.(Variablename).LongName ;
                        if strcmp(LongName,Variable)
                            varfound = 1 ;
                            Variable = Variablename ;
                        end
                    end
                end
                try 
                    Value = data.SummaryStructure.(Housenumber).(Variable);
                catch
                    Value = data.datastructure.(Variable).Defaultcreate ;
                    AllHouses = char(gui.ListBox.String(gui.ListBox.Value)) ;
                    for ihouse = 1:size(AllHouses,1)
                        HousenumberReplace = char(gui.ListBox.String(gui.ListBox.Value(ihouse))) ;
                        data.SummaryStructure.(HousenumberReplace).(Variable) = Value ;
                    end
                end
                
                if ~strcmp(Value,data.varname.(Variable).Defaultcreate) 
                    str                     = [str; {Variable, Value}];
                    NewStr                  = str(end,1:2);
                    uimulticollist( gui.(ListNames), 'addRow', NewStr, size(str,1) )     ;
                end
            end
        end
    end
%--------------------------------------------------------------------------%
%% This is a function to define the development mode and running mode from each other
% Development mode is used in allowing broader time line of simulation than
% the running mode

    function AccessDevelopmentMode(src,~)
        
        if numel(gui.ListBox.Value) > 1
        
            for n = gui.ListBox.Value(1):gui.ListBox.Value(end)

                Housenumber = gui.ListBox.String{n};

                DefineDates(Housenumber);
                data.DvptMode = 1 ;
            end
        
        else
            
            DefineDates(gui.ListBox.String{gui.ListBox.Value});
    
        end
    
    end
        
%--------------------------------------------------------------------------%
%% Function on changing the Starting and Ending Date values
    function DefineDates(Housenumber)
        
        if gui.DevelopmentTick.Value == 1       % Go on development mode!
            
            % Start testing with Starting Date variable
            
            if datenum(datetime(data.SummaryStructure.(Housenumber).StartingDate, 'InputFormat', 'dd/MM/yyyy')) > datenum(datetime(data.datastructure.StartingDate.HighLimit, 'InputFormat', 'dd/MM/yyyy'))
                data.datastructure.EndingDate.HighLimit = data.SummaryStructure.(Housenumber).EndingDate;
                data.datastructure.StartingDate.HighLimit = data.SummaryStructure.(Housenumber).EndingDate;
            elseif datenum(datetime(data.SummaryStructure.(Housenumber).StartingDate, 'InputFormat', 'dd/MM/yyyy')) < datenum(datetime(data.datastructure.StartingDate.LowLimit, 'InputFormat', 'dd/MM/yyyy'))
                data.datastructure.EndingDate.LowLimit = data.SummaryStructure.(Housenumber).EndingDate;
                data.datastructure.StartingDate.LowLimit = data.SummaryStructure.(Housenumber).EndingDate;
            end
            
            % Next test the Ending Date variable 
            
            if datenum(datetime(data.SummaryStructure.(Housenumber).EndingDate, 'InputFormat', 'dd/MM/yyyy')) > datenum(datetime(data.datastructure.EndingDate.HighLimit, 'InputFormat', 'dd/MM/yyyy'))
                data.datastructure.EndingDate.HighLimit = data.SummaryStructure.(Housenumber).EndingDate;
                data.datastructure.StartingDate.HighLimit = data.SummaryStructure.(Housenumber).EndingDate;
            elseif datenum(datetime(data.SummaryStructure.(Housenumber).EndingDate, 'InputFormat', 'dd/MM/yyyy')) < datenum(datetime(data.datastructure.EndingDate.LowLimit, 'InputFormat', 'dd/MM/yyyy'))
                data.datastructure.EndingDate.LowLimit = data.SummaryStructure.(Housenumber).EndingDate;
                data.datastructure.StartingDate.LowLimit = data.SummaryStructure.(Housenumber).EndingDate;
            end
            
        else
            
            % Keep preset Starting date limits
            
            data.datastructure.StartingDate.HighLimit = '31/12/2013';       % The current default Limit!
            data.datastructure.StartingDate.LowLimit  = '01/01/2012';       % The current default Limit!
            
            % Keep preset Ending Date limits 
            
            data.datastructure.EndingDate.HighLimit = '31/12/2013';       % The current default Limit!
            data.datastructure.EndingDate.LowLimit  = '01/01/2012';       % The current default Limit!
            
        end
    end
%--------------------------------------------------------------------------%
%% Function for the appliance filtering
    function DetermineAppliance(src,~, menu5)
        
        switch(src.Tag)
            
            case 'Appliance'
                
                uimulticollist( gui.multicolumnApp, 'addFilter', 1, {src.Label});
                
                menu5.Visible = 'on';
                
            case 'Rate'
                
                uimulticollist( gui.multicolumnApp, 'addFilter', 2, {src.Label});
                
                menu5.Visible = 'on';
                
            case 'Qty'
                
                uimulticollist( gui.multicolumnApp, 'addFilter', 3, {src.Label});
                
                menu5.Visible = 'on';
                
            case 'Remove'
                
                uimulticollist( gui.multicolumnApp, 'resetFilter');
                
                menu5.Visible = 'off';
                
        end
        
    end
%--------------------------------------------------------------------------% 
%% Function for changing the default value of simulation time frame
% This function is used to change the value of the simulation time frame
% used in the forecasting of global irradiance from TRY data. 
    function SimulationTimeFrameSetting(src,~)
        
        for n = 1:length(gui.ListBox.Value)
            
            j = gui.ListBox.Value(n);
        
        Housenumber             = gui.ListBox.String{j};

            data.SummaryStructure.(Housenumber).SimulationTimeFrame = gui.SimulationTimeFrameSelection.String{gui.SimulationTimeFrameSelection.Value};
            
            if strcmp(data.SummaryStructure.(Housenumber).SimulationTimeFrame, 'Select...')
                data.SummaryStructure.(Housenumber).SimulationTimeFrame = gui.SimulationTimeFrameSelection.String{2}; % TRY2012 is default value
            end
            
        end
    end


%--------------------------------------------------------------------------%
    function clickcallback(obj,evt)
        switch get(obj,'SelectionType')
            case 'normal'
            case 'open'
                disp('double click')
        end
    end
%--------------------------------------------------------------------------%
    function MapSearch(src,~)
        
        switch src.Tag
            case {'MapUpdaterLocation','MapUpdaterAll'}
                Place2Search = gui.MapPlaces.String ;
                coords = downloadCoords_UOulu(Place2Search) ;

                if strcmp(coords,'Unknown place')
                    errordlg('Error');
                    return;
                end 

                coords = [coords.minLon coords.maxLon coords.minLat coords.maxLat] ;
                Res2Set = str2double(gui.MapResolution.String{gui.MapResolution.Value}) ;

                MapLayout = gui.MapLayout.String{gui.MapLayout.Value} ;

                Map(coords, MapLayout, gui.AxesMap, Res2Set);
            case {'MapUpdaterResolution','MapUpdaterLayout'}
                Res2Set = str2double(gui.MapResolution.String{gui.MapResolution.Value}) ;
                MapLayout = gui.MapLayout.String{gui.MapLayout.Value} ;
                Map([], MapLayout, gui.AxesMap, Res2Set);         
        end     
        
    end %MapSearch
end