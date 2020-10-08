function SBuM()

% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all GUI stuff in one structure and all data stuff in another. As the app
% grows, we might consider making these objects rather than structures.

% built with the toolbox 'GUI Layout Toolbox' version 2.3.3.0 (10/2018).
% Newer version (2.3.4.) is available (02/2019)!

% Use of the uimulticollistbox function available here: https://se.mathworks.com/matlabcentral/fileexchange/42670-multi-column-listbox
% It has been modified to comply to MatLab2018a.

dbstop if error
guiwait.Figure = figure( ...
                                'Name', 'Smart house model - University of Oulu', ...
                                'NumberTitle', 'off', ...
                                'MenuBar', 'none', ...
                                'Toolbar', 'none', ...
                                'HandleVisibility', 'on',...
                                'Visible','off');
open_Waiting_Window ;
builtversion =  '2.3.4' ;
x=1;
IsExeFile = 0 ;
if ~IsExeFile
    CheckToolBox(builtversion) ;
end
%Check the internet connection
if ~isnetavl
    NoInternetConnection = 1;
end

data = createData();
% If the process has been aborted, abort also the main function
if isempty(data)
    msgbox('The model could not be opened', 'Warning','warn');
    delete(guiwait.Figure) ;
    return;
end

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
        
        filename = 'Oulun_Yliopisto_1_50percent.png';
        
        GetPath = mfilename('fullpath');
        ParentFolder = GetPath(1:max(strfind(GetPath,filesep)));
        
        var=strcat(ParentFolder,'Input',filesep,'GUI',filesep,'Images',filesep,filename);
        ORI_IMG=imread(var);
        
        if ishandle( AxesFigure )
            delete( AxesFigure );
        end
        
        fig = figure( 'Visible', 'off' );
        AxesFigure = gca();
        set(AxesFigure,'Units','pixels','position', [0 0 4444 5876]);
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
        
        str = [char(169),' University of Oulu, 2019 - ', num2str(datetime(now,"ConvertFrom","datenum").Year)] ;
        
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
        
        set(guiwait.Figure,'Position',[WLeft WHeight 1.2*Pos(3) Pos(4)]); % JARI'S MODIFICATION % Pos(3) Pos(4)]) ;
        pause(1);
        set(guiwait.Figure,'Visible', 'on') ;
        %undecorateFig(guiwait.Figure)
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
        
        
        GetPath = mfilename('fullpath');
        ParentFolder = GetPath(1:max(strfind(GetPath,filesep)));
        
        ImageFolder = strcat(ParentFolder,'Input',filesep,'GUI',filesep,'Images',filesep);
        
        filepathini = [ParentFolder 'Input' filesep 'ini' filesep] ;

        if exist(filepathini, 'dir')
            listing = dir ([filepathini '*xml']) ;
            if ~isempty(listing)
                answer = questdlg('Would you like to load self-defined profiles?', ...
                             'Load user defined profiles', ...
                             'Yes','No','Cancel','Cancel');
                         switch answer
                             case 'Yes'
                                 % List all the xml files
                                 fileaccept = 0 ;
                                 Chckfiles = dir([filepathini '*xml']) ;
                                 if size(Chckfiles, 1) > 1
                                     while fileaccept == 0   
                                     [file,path] = uigetfile([filepathini '*xml'],'Select an user File') ;
                                        if file == 0
                                            data = [] ;
                                            return;
                                        elseif (contains(file,'.xml'))
                                            fileaccept          = 1;
                                            [varname]           = variable_names;
                                            userdata            = importXMLini([path file])             ;
                                            Detail_Appliance    = userdata.Detail_Appliance             ;
                                            DatabaseApp         = userdata.DatabaseApp                  ;
                                            AppliancesList      = userdata.AppliancesList               ;
                                            ApplianceMax        = userdata.ApplianceMax                 ;
                                            AppProfile          = userdata.ApplianceSpec.AppProfile     ;
                                            datastructure       = fieldnames(userdata.datastructure)    ;
                                            for i = 1:length(datastructure)
                                                varname.(datastructure{i}) = userdata.datastructure.(datastructure{i})  ;
                                            end
                                        else
                                            data = [] ;
                                            return;
                                        end
                                     end
                                 else
                                     path           = Chckfiles.folder ;
                                     file           = Chckfiles.name   ;
                                     userdata       = importXMLini([path filesep file])             ;
                                     fileaccept          = 1;
                                     [varname]           = variable_names;
                                     Detail_Appliance    = userdata.Detail_Appliance             ;
                                     DatabaseApp         = userdata.DatabaseApp                  ;
                                     AppliancesList      = userdata.AppliancesList               ;
                                     ApplianceMax        = userdata.ApplianceMax                 ;
                                     AppProfile          = userdata.ApplianceSpec.AppProfile     ;
                                     datastructure       = fieldnames(userdata.datastructure)    ;
                                     for i = 1:length(datastructure)
                                         varname.(datastructure{i}) = userdata.datastructure.(datastructure{i})  ;
                                     end
                                 end
                             case 'No'
                                 % Load the variable as the should be in
                                 % the standard loading
                                 [varname]           = variable_names;
                                 [Detail_Appliance]  = ApplianceSpec ;
                                 KrRemodece          = RemodeceDistriv2('Remodece_Distribution.xlsx')  ;
                                 % Save all the profiles as Appliance/Database/Array value
                                 AppProfile          = reclassProfile(KrRemodece, 'Remodece') ;
                                 DatabaseApp{1}      = 'Remodece' ;
                                 AppliancesList      = ApplianceListfunc ;
                                 ApplianceMax        = appMaxfunc        ;
                             case 'Cancel'
                                 data = [] ;
                                 return ;
                             otherwise
                                 data = [] ;
                                 return ;
                         end
            end
        else
            [varname]           = variable_names;
            [Detail_Appliance]  = ApplianceSpec ;
            KrRemodece          = RemodeceDistriv2('Remodece_Distribution.xlsx')  ;
            % Save all the profiles as Appliance/Database/Array value
            AppProfile          = reclassProfile(KrRemodece, 'Remodece') ;
            DatabaseApp{1}      = 'Remodece'        ;
            AppliancesList      = ApplianceListfunc ;
            ApplianceMax        = appMaxfunc        ;
        end
        
        % Set the Appliances rate when opening
        a = fieldnames(Detail_Appliance) ;
            for i = 1:length(a)
                if i == 1
                    Appliance = {varname.(a{i}).LongName} ;
                    AOrB      = Detail_Appliance.(a{i}).Power(1) ;
                    COrD      = Detail_Appliance.(a{i}).Power(2) ;
                    EOrF      = Detail_Appliance.(a{i}).Power(3) ;
                    StbPower  = Detail_Appliance.(a{i}).Power(4) ;
                    OffMode   = Detail_Appliance.(a{i}).Power(5) ;
                else
                    Appliance = [Appliance  ; {varname.(a{i}).LongName}] ;
                    AOrB      = [AOrB       ; Detail_Appliance.(a{i}).Power(1)] ;
                    COrD      = [COrD       ; Detail_Appliance.(a{i}).Power(2)] ;
                    EOrF      = [EOrF       ; Detail_Appliance.(a{i}).Power(3)] ;
                    StbPower  = [StbPower   ; Detail_Appliance.(a{i}).Power(4)] ;
                    OffMode   = [OffMode    ; Detail_Appliance.(a{i}).Power(5)] ;
                end
            end
            
            ApplianceRates = table(Appliance,AOrB,COrD,EOrF,StbPower,OffMode) ;
        
        % Add an empty structure to the varname if it does not exist
        if ~isfield(varname,'Appliances')
            varname.Appliances = struct ;
        end
        
        Profile1distri = CreateStat4Use_Profile3 ;
        Profile2distri = CreateStat4Use_Profile2 ;
        
        if verLessThan('matlab','9.5')
            % -- Code to run in MATLAB R2018a and earlier here --
            ToolTipString = 'TooltipString' ;
        else
            % -- Code to run in MATLAB R2018b and later here --
            ToolTipString = 'TooltipString' ; % Normally 'Tooltip' but it does not seem to work
        end
        
        Time_Step = {'10s' '1 minute' '15 minutes' '30 minutes' 'Hourly'} ;
        
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
%         Rating(end+1,:) = {'Self-defined'};
        
        SimulationTimeFrame_Var = {'Select...'
                                   'TRY2012'
                                   'TRY2050'};
                               
        coordsDefault = [25.456 25.480 65.051 65.064];
        
        WeatherSelection = 'Default' ;
        
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
        Lightopt(end+1,:) = {'Self-defined'};
        
        nbrInhabitant = varname.inhabitants.Comparefield{2};
        nbrInhabitant(2:end+1,:) = nbrInhabitant(1:end,:);
        nbrInhabitant(1,:) = {'Select...'};
               
    
        WeatherFileList = {'Default weather' 
                           'Load EPW file' 
                           'Load Individual files'} ;
    
        LanguagesAll = Languages ;
        if ismac
            MachineInfo.name = getenv('USER') ;
        else
            MachineInfo = whoami;
        end
        
        if strcmp(MachineInfo.name,'jlouis')
            DebugMode = 1 ;
            DvptMode  = 1 ;
        else
            DebugMode = 0 ;
            DvptMode  = 0 ;
        end
        
        App10s = 0 ;
        
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
        SelfDefinedAppliances = struct ;    % JARI
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
        
        
        selectedDemo    = 1;
        
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
            'coordsDefault',{coordsDefault},...
            'SelfDefinedAppliances',SelfDefinedAppliances,...
            'WeatherFileList',{WeatherFileList},...
            'Time_Step',{Time_Step},...
            'WeatherSelection',WeatherSelection,...
            'DebugMode',DebugMode,...
            'DvptMode',DvptMode,...
            'App10s',App10s,...
            'Profile1distri',{Profile1distri},...
            'Profile2distri',{Profile2distri},...
            'DatabaseApp',{DatabaseApp},...
            'AppProfile',AppProfile,...
            'ApplianceRates',ApplianceRates,...
            'Detail_Appliance',Detail_Appliance,...
            'ImageFolder',ImageFolder); % JARI'S ADDITION
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
        %% Set the menu
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
        uimenu( helpMenu, 'Label', 'Analyse results...', 'Callback', @RunStatistics )
        
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
        
        % The Javaframe is meant to pre-load the element before it is being
        % built.
        jFrame = get(gui.Window,'JavaFrame');
        jMenuBar = jFrame.(gui.Handle_Graphics).getMenuBar;
        pause(.1)
        
        N = 100 ;
        i = 0   ;   
        JavaFrameErrorPass = true ;
        while (i < N) 
            try
                jFileMenu = jMenuBar.getComponent(0);
            catch
                JavaFrameErrorPass = false ;
            end
            if JavaFrameErrorPass
                break
            end
            i = i + 1 ;
        end
        
        if JavaFrameErrorPass
            % We manage to make it work
            jFileMenu.doClick; % open the File menu
            jFileMenu.doClick; % close the menu
            pause(.1)
        else
            % We did no manage to make it work
            warning('We did not manage to pass the javaframe. Some error may appear.') ;
        end
            
        %         y = getjframe(gui.Window) ; % Does not work from MatLab 2018b....

        Path = mfilename('fullpath') ;
        folder = dbstack ;
        filename = folder.file ;
        filename_noext = erase(filename,'.m') ;
        filePath = erase(Path,filename_noext) ;
        
        s = [data.ImageFolder 'LogosSaveAll.png'] ;
        if exist(s, 'file') == 2
            % The file exist at that location
            setIconMenu(jMenuBar, 'Save all' ,s);
            % If not then do not put any logo
        else
            warning('Logo Save All not located under ...\Images\') ;
        end
        
        s = [data.ImageFolder 'LogosPreferences.png'];
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

        % Add the edit panel for the appliance usage distribution
        gui.AppDistri = uix.VBox('Parent',gui.ViewPanel1,'Tag','AppDistri') ;
            HBox1 = uix.HBox('Parent',gui.AppDistri, 'Spacing', 5) ;
            % There will be 3 boxes under, one large for the tables an
            % button and one for the graphics
                % First one is for the graphics and is divided into 4
                % columns
                uix.Empty('parent',HBox1) ;  
                
                gui.VarListDistri = uicontrol(HBox1,'style','popup',...
                                                        'string',data.AppliancesList(:,1), ...
                                                        'tag','VarListDistri',...
                                                        'Callback', @HourDistri_Callback) ;
                
                gui.VarPorjectDistri = uicontrol(HBox1,'style','popup',...
                                                        'string',data.DatabaseApp(:), ...
                                                        'tag','VarPorjectDistri',...
                                                        'Callback', @HourDistri_Callback) ;                                    
                                                    
                gui.VarImportDistri = uicontrol(HBox1,'style','pushbutton',...
                                                    'string','Import...', ...
                                                    'tag','VarImportDistri',...
                                                    'Callback', @HourDistri_Callback) ;
                                                
                gui.VarSaveDistri = uicontrol(HBox1,'style','pushbutton',...
                                                    'string','Save...', ...
                                                    'tag','VarSaveDistri',...
                                                    'Callback', @HourDistri_Callback) ;
                                                
                gui.VarCloseDistri = uicontrol(HBox1,'style','pushbutton',...
                                                        'string','Close', ...
                                                        'tag','VarCloseDistri',...
                                                        'Callback', @HourDistri_Callback) ;
                                                    
                gui.VarGraphDistri = uicontrol(HBox1,'style','pushbutton',...
                                                        'string','Update', ...
                                                        'tag','VarGraphDistri',...
                                                        'Callback', @HourDistri_Callback) ;
                                                    
                uix.Empty('parent',HBox1) ;  
                % Profile1distri
             HBox2 = uix.HBox('Parent',gui.AppDistri, 'Spacing', 5) ;                                   
                VBox1 = uix.VBox('Parent',HBox2,'Tag','AppDistri') ;
                    % In the first column, there are 25 boxes 
                    for i = 0:12
                        if i == 0
                            HourName    = 'HourTextini' ;
                            hourString  = 'Initial' ;
                        else
                            HourName    = ['HourText' num2str(i)] ;
                            hourString  = ['[' num2str(i - 1) ' - ' num2str(i) ']'] ;
                        end
                        
                        gui.(HourName) = uicontrol(VBox1,'Style', 'text',...
                                                  'Tag',HourName, ...
                                                  'String',hourString) ;       
                    end
                    
                    VBox1_2 = uix.VBox('Parent',HBox2,'Tag','AppDistri') ;
                    % In the second column, there are also 25 boxes wit
                    % hthe editable values of the appliance distribution. They should
                    % be pre-filled with the value of the appliance later
                    % on
                    WashMachProfile = data.AppProfile.(data.AppliancesList{1,3}).(data.DatabaseApp{1}) ;
                    WashMachProfile = ceil(WashMachProfile * data.Detail_Appliance.(data.AppliancesList{1,3}).Power(1) * 1000) ;
%                     WashMachProfile = cumsum(WashMachProfile)  ;
                    for i = 0:12
                        if i == 0
                            enable      = 'off' ;
                            ValueCumsum = 0     ;
                        else
                            enable = 'on' ;
                            ValueCumsum = WashMachProfile(i) ;
                        end
                        HourName    = ['Hour' num2str(i)] ;
                        
                        gui.(HourName) = uicontrol(VBox1_2,'Style', 'edit',...
                                                'Callback', @HourDistri_Callback, ...
                                                'String',ValueCumsum,...
                                                  'Tag',HourName,...
                                                  'enable',enable) ;       
                    end
                
                    VBox1_3 = uix.VBox('Parent',HBox2,'Tag','AppDistri') ;
                    % Those are greyed out text box that retains the
                    % original value that could be used to reset the
                    % appliance distribution
                    for i = 0:12
                        if i == 0
                            HourName    = 'HourTextResetini' ;
                            ValueCumsum = 0     ;
                        else
                            HourName    = ['HourTextReset' num2str(i)] ;
                            ValueCumsum = WashMachProfile(i) ;
                        end
                        
                        gui.(HourName) = uicontrol(VBox1_3,'Style', 'text',...
                                                  'Tag',HourName,...
                                                  'String',ValueCumsum) ;       
                    end                         
                    
                    VBox1_4 = uix.VBox('Parent',HBox2,'Tag','AppDistri') ;
                    % In the first column, there are 25 boxes 
                    for i = 13:24
                        HourName    = ['HourText' num2str(i)] ;
                        hourString  = ['[' num2str(i - 1) ' - ' num2str(i) ']'] ;                        
                        gui.(HourName) = uicontrol(VBox1_4,'Style', 'text',...
                                                  'Tag',HourName, ...
                                                  'String',hourString) ;       
                    end
                    
                    VBox1_5 = uix.VBox('Parent',HBox2,'Tag','AppDistri') ;
                    % In the second column, there are also 25 boxes wit
                    % hthe editable values of the appliance distribution. They should
                    % be pre-filled with the value of the appliance later
                    % on
                    for i = 13:24
                        if i == 24
                            enable = 'on';
                        else
                            enable = 'on' ;
                        end
                        ValueCumsum = WashMachProfile(i) ;
                        HourName    = ['Hour' num2str(i)] ;
                        gui.(HourName) = uicontrol(VBox1_5,'Style', 'edit',...
                                                'Callback', @HourDistri_Callback, ...
                                                  'Tag',HourName,...
                                                  'String',ValueCumsum,...
                                                  'enable',enable) ;       
                    end
                
                    VBox1_6 = uix.VBox('Parent',HBox2,'Tag','AppDistri') ;
                    % Those are greyed out text box that retains the
                    % original value that could be used to reset the
                    % appliance distribution
                    for i = 13:24
                        HourName    = ['HourTextReset' num2str(i)] ;  
                        ValueCumsum = WashMachProfile(i) ;
                        gui.(HourName) = uicontrol(VBox1_6,'Style', 'text',...
                                                  'Tag',HourName,...
                                                  'String',ValueCumsum) ;       
                    end

                    
               % This is the second line in the vbox and contains the graphing button to update if necessarry                                 
%                HBox3 = uix.HBox('Parent',gui.AppDistri,'Tag','AppDistri') ;  
%                     uix.Empty('parent',HBox3) ;
%                     
%                     set(HBox3,'Widths',[-1 50]) ;                                
                % The last box includes the graph for the distribution. 2
                % plots should be made available: the original dataset
                % based on the profile chosen in the user definition and
                % the one that has been redifeined by the user
                
               gui.Figuredistri     = axes('Parent',gui.AppDistri) ;
               
               ArrayOut             = edit2array(gui) ; 
               plot(ArrayOut,'Parent',gui.Figuredistri) ;
               xlabel(gui.Figuredistri,'Time [h]') 
               ylabel(gui.Figuredistri,'Power consumption profile [Wh/h]') 
               
               yyaxis(gui.Figuredistri,'right')
               
               ArrayOutCumSum = cumsum(ArrayOut/sum(ArrayOut)) ;
               plot(ArrayOutCumSum,'Parent',gui.Figuredistri) ;
               ylabel(gui.Figuredistri,'Distribution used [%]') 
               
               set(gui.AppDistri,'Heights',[23 -1  -2]) ;
               
        % + Adjust the main layout
        set( gui.MapPanel,'Heights',[23 23 -1])    ;
        set( mainLayout, 'Widths', [-1,-2,-1]  );
        set( ViewingPanel, 'Heights', -1  ); %50 , -1
        set( EditPanel, 'Heights', [45,-1]  );
        
        % Set the view of the card panel to the map layer when starting the
        % interface. 
        gui.ViewPanel1.Selection = 2 ;
        
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
        
        TimeDefBox = uix.VBox('parent', Maindate, 'Spacing', 3);
            uicontrol('Parent', TimeDefBox,...
                      'style','text',...
                      'HorizontalAlignment','Left',...  
                      'string','Time resolution') ;
        
        gui.ListTimeStep = uicontrol('Parent', TimeDefBox,...
                                 'style','popup',...
                                 'string',data.Time_Step,...
                                 'value',5,...
                                 'callback',@Time_StepDef) ;    

              % JARI'S ADDITION
              
        gui.FileAdditionMain = uix.VBox('Parent', Maindate, 'Spacing', 3);
        gui.FileAdditionPanelMain = uipanel('Parent', gui.FileAdditionMain, 'Title', 'Weather Files'); %, 'Spacing', 5);
        
        gui.FileSelectionBox = uix.VBox('Parent', gui.FileAdditionPanelMain, 'Spacing', 3);
        
        gui.ListFile = uicontrol('Parent', gui.FileSelectionBox,...
                                 'style','popup',...
                                 'string',data.WeatherFileList,...
                                 'callback',@WeatherSel) ;
        
        gui.FileAdditionScrollPanel     = uix.ScrollingPanel('Parent', gui.FileSelectionBox)   ;        
        gui.FileAdditionPanel           = uix.CardPanel('Parent', gui.FileAdditionScrollPanel)   ;                   
        
        % Set up the card panels 
        gui.FileAdditionDefFile = uix.VBox('Parent', gui.FileAdditionPanel);
        gui.FileAdditionEPWFile = uix.VBox('Parent', gui.FileAdditionPanel);
        gui.FileAdditionIndFile = uix.VBox('Parent', gui.FileAdditionPanel); %, 'Title', 'File Addition'); % Maindate); %, 'Title', 'Add your own files');
        %%%%% Panel EPW load
        
        gui.EPWBrowseBox = uix.VBox('Parent', gui.FileAdditionEPWFile);
            gui.EPWBrowse = uicontrol('Parent', gui.EPWBrowseBox,...
                                      'style','pushbutton',...
                                      'string','Browse...',...
                                      'callback',@BrowseEWP) ;
        str = {'File' 'Address'} ;                     
        gui.multiEPWfiles = uimulticollist('Parent',gui.EPWBrowseBox,...
                                                      'string', str,...
                                                      'columnColour', {'BLACK' 'BLACK' });
            uix.Empty('Parent', gui.EPWBrowseBox);                                      
            gui.EPWLoad = uicontrol('Parent', gui.EPWBrowseBox,...
                                      'style','pushbutton',...
                                      'string','Load...',...
                                      'callback',@LoadEWP) ;
            uix.Empty('Parent', gui.EPWBrowseBox);
            gui.EPWLoadText = uicontrol('Parent', gui.EPWBrowseBox,...
                                      'style','text') ;
                                                  
        %%%%% Panel defined file
        gui.TemperatureBox = uix.VBox('Parent', gui.FileAdditionIndFile);
        gui.ChangeTemperature = uicontrol('Parent', gui.TemperatureBox, ...
                                            'Style', 'text', ...
                                            'HorizontalAlignment','Left',...
                                            'String', 'Load weather file(s)...', ...
                                            'Tag', 'ChangeTemperature');
        
        File2Load = {'Temperature' 'Radiation' 'Price' 'Emissions'};
                                        
        gui.ListFileInd = uicontrol('Parent', gui.TemperatureBox,...
                                 'style','popup',...
                                 'string',File2Load) ;
                                        
            gui.TemperatureButtons      = uix.HBox('Parent', gui.TemperatureBox);
                gui.WeatherAddition = uicontrol('Parent', gui.TemperatureButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Add', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'WeatherAddition');
                gui.WeatherRemoval = uicontrol('Parent', gui.TemperatureButtons, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Remove', ...
                                            'callback', @ImportExternalFile, ...
                                            'Tag', 'WeatherRemoval');
            str = {'File' 'Address'} ;                     
            gui.multiweatherfiles = uimulticollist('Parent',gui.TemperatureBox,...
                                                      'string', str,...
                                                      'columnColour', {'BLACK' 'BLACK' },...
                                                      'tag','multicolumnApp', ...
                                                      'callback', @WeatherSelection, ...
                                                      'ButtonDownFcn', @ModificationWeatherSel);                              
                                        
        gui.DataSetStartsMain = uix.VBox('Parent', gui.FileAdditionIndFile, 'Spacing', 3);
                                        
        gui.DataSetStartsPanel = uix.Panel('Parent', gui.DataSetStartsMain, 'Title', 'Database Start Years'); %, 'Spacing', 5);
                                        
        gui.DataSetStarts = uix.VBox('Parent', gui.DataSetStartsPanel, 'Spacing', 5); % Maindate, 'Spacing', 2);  
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
%                                                     
%                                         
%         % END OF JARI'S ADDITION
%         
%         
%   
        
        set(Maindate, 'Heights', [50 45 460]);  % JArI % 50 300 122
        set(TimeDefBox, 'Heights', [20 25]) ;
        set(gui.TemperatureBox, 'Heights', [20 25 25 -1]);    % J
        set(gui.EPWBrowseBox, 'Heights', [25 75 25 25 25 25]);
%         set(gui.TemperatureMain, 'Height', [25 25]);    % J
%         set(gui.RadiationBox, 'Heights', [15 50]);      % J
%         set(gui.RadiationMain, 'Height', [25 25]);      % J
%         set(gui.PriceBox, 'Heights', [15 50]);          % J
%         set(gui.PriceMain, 'Height', [25 25]);          % J
%         set(gui.EmissionBox, 'Heights', [15 50]);       % J
%         set(gui.EmissionMain, 'Height', [25 25]);       % J
        set(gui.DataSetStarts, 'Height', [15 25 15 25 50]); %[15 15 25 15 25 45]); % J % 30 25 30 25
        set(gui.SimulationTimeFrame, 'Height', [15 30]); % J
%         set(gui.SimulationTimeFrame, 'Height', [-1 -1]);    % J
        set(gui.StartOfDataSetTemp, 'Widths', [-4 -1]);     % J
        set(gui.StartOfDataSetPrice, 'Widths', [-4 -1]);    % J
%         set(Maindate, 'Widths', [-1 -1]); %set(Maindate, 'Widths', -1);
        set(gui.FileSelectionBox,'Heights',[25 -1]);
        set(selectionbox,'Heights',[25 25]) ;
        set(Startdatebox,'Widths',[-1 73 73]);
        set(EndDatebox,'Widths',[-1 73 73]);
        gui.FileAdditionPanel.Selection = 1 ;
        
        
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
        LowPriceLimit = uix.HBox('Parent',Maincontract, 'Spacing', 5 ) ;    
        [~,Tip] = createStrToolTip(data.datastructure.Low_Price.Tooltip,...
                                   data.datastructure.Low_Price.LongName) ;
                                uicontrol('Parent', LowPriceLimit,...
                                            'Style','text',...
                                            'String','Low Price',...
                                            data.ToolTipString,Tip);   
                                        
                gui.Low_Price = uicontrol('Parent', LowPriceLimit,...
                                            'Style','edit',...
                                            'String',data.datastructure.Low_Price.Defaultcreate,...
                                            'Tag','Low_Price',...
                                            'Callback',@ContractSetting,...
                                            data.ToolTipString,Tip);
                                        
                                uicontrol('Parent', LowPriceLimit,...
                                            'Style','text',...
                                            'String',['[cts' char(8364)  ']'],...
                                            data.ToolTipString,Tip);
                                        
        [~,Tip] = createStrToolTip(data.datastructure.High_Price.Tooltip,...
                                   data.datastructure.High_Price.LongName) ;
                               
        HighPriceLimit = uix.HBox('Parent',Maincontract, 'Spacing', 5 ) ; 
                        
                         uicontrol('Parent', HighPriceLimit,...
                                            'Style','text',...
                                            'String','High Price',...
                                            data.ToolTipString,Tip); 
                                        
        gui.High_Price = uicontrol('Parent', HighPriceLimit,...
                                    'Style','edit',...
                                    'String',data.datastructure.High_Price.Defaultcreate,...
                                    'Tag','High_Price',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
                         uicontrol('Parent', HighPriceLimit,...
                                            'Style','text',...
                                            'String',['[cts' char(8364)  ']'],...
                                            data.ToolTipString,Tip);
                                        
       [~,Tip] = createStrToolTip(data.datastructure.RTP_Update.Tooltip,...
                                   data.datastructure.RTP_Update.LongName) ;
       SetRTP_Update = uix.HBox('Parent',Maincontract, 'Spacing', 5 ) ; 
                        
                         uicontrol('Parent', SetRTP_Update,...
                                            'Style','text',...
                                            'String','Time update',...
                                            data.ToolTipString,Tip);
                                        
       gui.RTP_Update = uicontrol('Parent', SetRTP_Update,...
                                    'Style','edit',...
                                    'String',data.datastructure.RTP_Update.Defaultcreate,...
                                    'Tag','RTP_Update',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
                
                         uicontrol('Parent', SetRTP_Update,...
                                            'Style','text',...
                                            'String','[h]',...
                                            data.ToolTipString,Tip);
                                        
       [~,Tip] = createStrToolTip(data.datastructure.RTP_EndTime.Tooltip,...
                                   data.datastructure.RTP_EndTime.LongName) ;                         
       
       SetRTP_EndTime = uix.HBox('Parent',Maincontract, 'Spacing', 5 ) ; 
                        
                         uicontrol('Parent', SetRTP_EndTime,...
                                            'Style','text',...
                                            'String','Day-ahead ends',...
                                            data.ToolTipString,Tip);
                                        
       gui.RTP_EndTime = uicontrol('Parent', SetRTP_EndTime,...
                                    'Style','edit',...
                                    'String',data.datastructure.RTP_EndTime.Defaultcreate,...
                                    'Tag','RTP_EndTime',...
                                    'Callback',@ContractSetting,...
                                    data.ToolTipString,Tip);
                                
                         uicontrol('Parent', SetRTP_EndTime,...
                                            'Style','text',...
                                            'String','[h]',...
                                            data.ToolTipString,Tip);
                                        
       set(LowPriceLimit ,'Widths',[90 -1 40]) ;        
       set(HighPriceLimit,'Widths',[90 -1 40]) ;    
       set(SetRTP_Update ,'Widths',[90 -1 40]) ;        
       set(SetRTP_EndTime,'Widths',[90 -1 40]) ;  
       
       set(MainPanelContracts,'Widths',-1)                    ;   
       set(Maincontract,'Heights',[20 20 20 20 20 20])              ; 
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % + Create the interface for the *User types*
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
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
                 gui.Changedistri = uicontrol('Parent',AppAdd,'Style','pushbutton',...
                           data.ToolTipString,'Change distribution',...
                           'Tag','ChangeDistri',...
                           'Callback',@AddApplianceCallback) ;
                       if gui.Changedistri.Value == 0
                           gui.Changedistri.Value = 1;
                       end
                       image2loadblue = 'Graph_Distri.png' ;
                        try
                            originalimage = imread(image2loadblue);
                        catch
                            %
                        end
                        a = imresize(originalimage,[25 25]);
                        a = im2uint8(a) ;
                        set(gui.Changedistri, 'cdata',a);
                        gui.Changedistri.Value = 1;
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
                       
                 str={'Appl.' 'Rate' 'Qty' 'Database'}   ;   
                 
                 gui.multicolumnApp = uimulticollist('Parent',gui.SplitApp,...
                                  'string', str,...
                                  'columnColour', {'BLACK' 'BLACK' 'BLACK' 'BLACK' },...
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
        
        set(AppAdd,'Widths',[-1 25 25 25]);
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
                                                                    
                    gui.DemandVentilation = uicontrol('Parent', gui.SplitVent, ...
                                                      'Style', 'checkbox',...
                                                      'String','Demand Controlled Ventilation',...
                                                      'Tag','DemandVentilation',...
                                                      'enable','off',...
                                                      'Value',0,...
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
       set(gui.SplitVent,'Heights',[23 15 23 15 23 23 -1] );  
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
            gui.MainFilter = uimenu('Parent',c,'Label','Rename',...
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
%         profile on

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
                    
                    idx = cellfun(@isempty,data.AppliancesList(:,4)) ;
                    data.AppliancesList(idx,4) = {''};
                    
                    for ii = 1:numel(Eachfield)
                        if ~ismember(ToSkip,Eachfield{ii})
                            if isfield(data.SummaryStructure.(HouseTag), 'Appliances')
                                if strcmp(Eachfield{ii}, 'Appliances')
                                    AllApp      = fieldnames(data.SummaryStructure.(HouseTag).Appliances) ;
                                    AllAppData  = data.SummaryStructure.(HouseTag).Appliances ;
                                    if isempty(AllApp)
                                        % The str variable must be set empty
                                        % with a header
                                    else
                                        % Loop through each of the Appliance in
                                        % the summarystructure to rebuild the
                                        % str cell array
                                        for iappLoop = 1:length(AllApp)
                                            LongName     = data.varname.(AllAppData.(AllApp{iappLoop}).SN).LongName ;
                                            str{end+1,1} = LongName ;
                                            if isa(AllAppData.(AllApp{iappLoop}).Qty,'double')
                                                Qty = num2str(AllAppData.(AllApp{iappLoop}).Qty) ;
                                            else
                                                Qty = AllAppData.(AllApp{iappLoop}).Qty ;
                                            end
                                            str{end,3}   = Qty ;
                                            str{end,4}   = AllAppData.(AllApp{iappLoop}).DB ;
                                            str{end,2}   = AllAppData.(AllApp{iappLoop}).Class ;
                                        end
                                    end
                                    [~, ix] = sort(str(2:end,1)) ;
                                    str(2:end,:) = str(ix+1,:)   ;
                                else
                                    try
                                        h = gui.(Eachfield{ii}) ;
                                    catch
                                        k = k + 1 ;
                                        data.missing{k} = Eachfield{ii} ;
                                        % The varibale has not yet been defined
                                        continue;  % Jump to next iteration of: for i
                                    end

                                    Housemax = numel(gui.ListBox.Value);
                                    if Housemax == 1
                                        HouseSelected = gui.ListBox.String{gui.ListBox.Value(1)} ;
                                        retainedvalue = data.SummaryStructure.(HouseSelected).(Eachfield{ii}); 
                                    elseif Housemax > 1
                                        retainedvalue = 'First Loop';
                                    end
                                    refill_uicontrol(h,Housemax,retainedvalue,Eachfield{ii})
                                end
                            else  
                                if sum(ismember(data.AppliancesList(:,3),Eachfield{ii}))
%                                     % This is to define the appliances
%                                     Housemax = numel(gui.ListBox.Value);
%                                     if Housemax == 1
%                                         HouseSelected = gui.ListBox.String{gui.ListBox.Value(1)} ;
%                                         retainedvalue = data.SummaryStructure.(HouseSelected).(Eachfield{ii}); 
%                                     elseif Housemax > 1
%                                         continue;
%                                     end
%                                     CurrentApp      = find(1==strcmp(Eachfield{ii},data.AppliancesList(:,3))) ;
%                                     AppRanking      = data.AppliancesList{CurrentApp,4} ;
%                                     AppID           = data.AppliancesList{CurrentApp,3} ;
%                                     ApplianceName   = data.AppliancesList(CurrentApp,1) ;
% 
%                                     if ~isempty(AppRanking)
%                                         ApplianceRating = data.SummaryStructure.(HouseSelected).(AppRanking) ;
%                                         if isa(ApplianceRating,'cell')
%                                             uniqueelem = unique(ApplianceRating) ;
%                                             for ulem = 1:numel(uniqueelem)
%                                                 String1 = uniqueelem{ulem} ;
%                                                 Quantity = sum(strcmp(String1,ApplianceRating)) ;
%                                                 Quantity2 = data.SummaryStructure.(HouseSelected).(AppID) ;
% 
%                                                 if Quantity > 0
%                                                     if Quantity > 2
%                                                         str(LineNumberApp,1) = ApplianceName ;
%                                                         str{LineNumberApp,2} = String1 ;
%                                                         str{LineNumberApp,3} = num2str(Quantity) ;
%                                                         LineNumberApp = LineNumberApp + 1;
%                                                     elseif ~strcmp(Quantity2,'0')
%                                                         str(LineNumberApp,1) = ApplianceName ;
%                                                         str{LineNumberApp,2} = String1 ;
%                                                         str{LineNumberApp,3} = num2str(Quantity) ;
%                                                         LineNumberApp = LineNumberApp + 1;
%                                                     end
%                                                 end
%                                             end
%                                         else
%                                             Quantity = str2double(data.SummaryStructure.(HouseSelected).(data.AppliancesList{CurrentApp,3})) ;
%                                             Quantity2 = data.SummaryStructure.(HouseSelected).(AppID) ;
%                                             if Quantity > 0 && ~strcmp(Quantity2,'0')
%                                                 str(LineNumberApp,1) = ApplianceName ;
%                                                 str{LineNumberApp,2} = ApplianceRating ;
%                                                 str{LineNumberApp,3} = num2str(Quantity) ;
%                                                 LineNumberApp = LineNumberApp + 1;
%                                             end
%                                         end
%                                     else
%                                         Quantity = str2double(data.SummaryStructure.(HouseSelected).(data.AppliancesList{CurrentApp,3})) ;
%                                         Quantity = sum(Quantity) ;
%                                         if Quantity > 0 
%                                             str(LineNumberApp,1) = ApplianceName ;
%                                             str{LineNumberApp,2} = '-' ;
%                                             str{LineNumberApp,3} = num2str(Quantity) ;
%                                             LineNumberApp = LineNumberApp + 1;
%                                         end
%                                     end
%                                 elseif sum(ismember(data.AppliancesList(:,4),Eachfield(ii)))
%                                     % This is to define the class appliances.
%                                     % Do nothing because it is already taken
%                                     % care of before
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
                    end
                    if gui.ViewPanel1.Selection == 3
                        AppName         = gui.VarListDistri.String{gui.VarListDistri.Value} ;
                        AppShortName    = data.AppliancesList{...
                                            find(strcmp(AppName,data.AppliancesList(:,1))==1),...
                                            3};
                        gui.ListBox.Value   = gui.ListBox.Value(1) ;
                        HouseSelected       = gui.ListBox.String{gui.ListBox.Value} ;
                        try 
                            ArrayOut = data.userdefined.(AppShortName).(HouseSelected).appdistri ;
                        catch
                            % There is no user-defined distribution
                            if isa(gui.VarPorjectDistri.String,'char')
                                DataBaseApp = gui.VarPorjectDistri.String ;
                            elseif isa(gui.VarPorjectDistri.String,'cell')
                                DataBaseApp = gui.VarPorjectDistri.String{gui.VarPorjectDistri.Value} ;
                            end
                            ArrayOut = data.AppProfile.(AppShortName).(DataBaseApp) ;
                            ArrayOut = ceil(ArrayOut * data.Detail_Appliance.(AppShortName).Power(1) * 1000) ;
                            ArrayOut = insertrows(ArrayOut,0,0) ;
                        end

                        array2edit(ArrayOut)        ;
                        GraphAppDistri(ArrayOut)    ;
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
%% refill_uicontrol
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
%% CheckPanel
    function CheckPanel(Panelname)
        if strcmp('uipanel',Panelname.Type)||strcmp('uicontainer',Panelname.Type)
            for i = 1:numel(Panelname.Children)
                CheckPanel(Panelname.Children(i))
            end
        else
            
        end
    end %CheckPanel
%-------------------------------------------------------------------------%
%% onHelp
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
%% onDisplay
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
            case 'Rename'
                % Rename the selected house
                
                % change the data.Summary
                
                % add a random number that is fixed.
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
%% FilterHouse
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
%% Filterbutton
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
%% StartFilter
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
%% FilterSelection
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
                [FileName] = LogoHouse(GetUserType, gui.DisplayUT.Checked) ;
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
%% onEdit
    function onEdit( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        switch src.Label
            case 'Copy'
                % set up the dialog window for setting up the copy of the
                % values from 1 house to any other ones
                Mfigpos = get(gui.Window,'OuterPosition') ;
                buttonwidth = 500 ;
                buttonheight = 500 ;
                gui.CopyDialog = figure('units','pixels',...
                         'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                     Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                     buttonwidth,...
                                     buttonheight],...
                         'toolbar','none',...
                         'menu','none',....
                         'name','Copy',....
                         'NumberTitle','off',...
                         'Visible','off',...
                         'Tag','AddFigure') ;%,...
                         %'CloseRequestFcn',@closeRequest);
                    %set(gui.CopyDialog,'WindowStyle','modal')

                    setupVer = uix.VBox('Parent', gui.CopyDialog) ;
                        setupHor1 = uix.HBox('Parent', setupVer) ;
                        setupHor2 = uix.HBox('Parent', setupVer) ;
                        setupHor3 = uix.HBox('Parent', setupVer) ;
                        setupHor4 = uix.HBox('Parent', setupVer) ;
                        setupHor5 = uix.HBox('Parent', setupVer) ;
                        setupHor6 = uix.HBox('Parent', setupVer) ;
                    if ~isempty(data.HouseList)
                        Houselist = data.HouseList ;
                    else
                        Houselist = {} ;
                    end
                    % Setup the house source and destination text
                    uicontrol('Parent',setupHor1,...
                               'Style','text',...
                               'String', 'Source',...
                               'Tag','HouseSourcetext') ;
                    uicontrol('Parent',setupHor1,...
                               'Style','text',...
                               'String', 'Destination(s)',...
                               'Tag','HouseSourcetext') ;

                    % Setup the house source and destination uicontrol
                    gui.CopyHouseSource = uicontrol('Parent',setupHor2,...
                               'Style','popup',...
                               'String', Houselist,...
                               'Tag','HouseSource',...
                               'Value',1) ;

                    gui.CopyHouseDes = uicontrol('Parent',setupHor2,...
                               'Style','list',...
                               'String', Houselist,...
                               'Tag','HouseDestination',...
                               'Max',2,...
                               'Min',0,...
                               'Value',1) ;

                     % Setup the variable to copy text and buttons
                     uicontrol('Parent',setupHor3,...
                               'Style','text',...
                               'String', 'Variable(s) to copy',...
                               'HorizontalAlignment','left',...
                               'Tag','Variabletext') ;
                     Var2List = fieldnames(data.varname) ;
                     Var2List(end + 1) = {'All_Appliances'} ;
                     Var2List(end + 1) = {'All_Variables'} ;
                     gui.varlist = uicontrol('Parent',setupHor3,...
                               'Style','popup',...
                               'String',  [{'-'}; sort(Var2List)],...
                               'Tag','HouseSource',...
                               'callback', @InfoVar, ...
                               'Value',1) ;
                     uicontrol('Parent',setupHor3,...
                               'Style','pushbutton',...
                               'String', '+',...
                               'callback',@AddRemVar,...
                               'Tag','PlusButton') ;
                     uicontrol('Parent',setupHor3,...
                               'Style','pushbutton',...
                               'String', '-',...
                               'callback',@AddRemVar,...
                               'Tag','MinusButton') ;
                           
                     % Setup the info text box for each variable
                     gui.InfoVarCopy = uicontrol('Parent',setupHor4,...
                               'Style','text',...
                               'HorizontalAlignment','left',...
                               'String', 'Information on the selected variable',...
                               'Tag','VariableInfotext') ;                    
                     
                      % Setup the multi-list box
                    str={'Short Name' 'Long Name' 'Unit' 'Value' 'Description'}   ;   
                    gui.Variablelist = uimulticollist('Parent',setupHor5,...
                                   'string', str,...
                                   'Max', 2,...
                                   'columnColour', {'BLACK' 'BLACK' 'BLACK' 'BLACK' 'BLACK' }) ;
                    uimulticollist( gui.Variablelist, 'setRow1Header', 'on' )     ;

                      % Setup the Cancel and Copy buttons

                      uix.Empty('Parent',setupHor6) ;
                      uicontrol('Parent',setupHor6,...
                               'Style','pushbutton',...
                               'String', 'Cancel',...
                               'Tag','CancelButton',...
                               'callback',@CopyData) ;
                     uicontrol('Parent',setupHor6,...
                               'Style','pushbutton',...
                               'String', 'Copy',...
                               'Tag','CopyButton',...
                               'callback',@CopyData) ;
                           
                
                set(setupVer,'Heights',[23 75 23 -1 -1 23]);
                set(setupHor3,'Widths',[-3 -2 -1 -1]);
                set(setupHor6,'Widths',[-1 100 100]);
                
                set(gui.CopyDialog,'Visible','on') ;
                
            case 'Add'
                addhousing() ;
            case 'Delete'
                deletehousing();
            case 'Import' 
        end
    end % onEdit
%--------------------------------------------------------------------------%
%% CopyData
    function CopyData(src,~)
        switch src.String
            case 'Copy'
                ExistingVar = uimulticollist(gui.Variablelist,'string') ;
                ExistingVar = ExistingVar(2:end,1) ;
                for i = 1:length(ExistingVar)
                    Var2Copy = ExistingVar{i} ;
                    SourceHouse = gui.CopyHouseSource.String{gui.CopyHouseSource.Value} ;
                    DestHouses  = gui.CopyHouseDes.Value ;
                    for ij = 1:length(DestHouses)
                        HouseDes = gui.CopyHouseSource.String{DestHouses(ij)} ;
                        if ~any(strcmp(Var2Copy,{'HouseNbr','Headers'}))
                            data.SummaryStructure.(HouseDes).(Var2Copy) = data.SummaryStructure.(SourceHouse).(Var2Copy) ;
                        end
                    end
                end
                msgbox('All variable were copied successfully!!','Successfull copy')
            case 'Cancel'
                delete(gui.CopyDialog) ;
        end
    end %CopyData
%--------------------------------------------------------------------------%
    function InfoVar(src,~)
        varSel = src.String{src.Value} ;
        
        if ~strcmp('-',varSel)
            
            try            
                str = data.varname.(varSel) ;
                IsVariable = true ;
            catch
                str = varSel ;
                IsVariable = false ;
            end
            
            if IsVariable
                fields = fieldnames(str) ;
                spintfsplitstr = {''};
                for i = 1:numel(fields)
                    arg = str.(fields{i}) ;
                    if iscell(arg) && (size(arg,2) > 1 || size(arg,1) > 1)
                        arg = 'multiple value possible' ;
                    elseif isa(arg,'double')
                        arg = num2str(arg) ;
                    end
                    spintfsplitstr = [spintfsplitstr strcat(fields{i}, ':',{' '}, arg)] ;
                end  
                set(gui.InfoVarCopy,'String',spintfsplitstr) 
            else
                switch str
                    case 'All_Appliances'
                        AppliancesList = data.AppliancesList(:,1);
                    case 'All_Variables'
                    
                    case 'All_PVGen'
                      
                    case 'All_WindGen'
                end
            end
        end
        
    end %InfoVar
%--------------------------------------------------------------------------%
    function AddRemVar(src,~)
        %str={'Short Name' 'Long Name' 'Unit' 'Value' 'Description'}
        profile on
        waitwindow = waitbar(0,'Add/Delete new variables','Name','Variables',...
                                     'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(waitwindow,'canceling',0);
        if getappdata(waitwindow,'canceling')
            delete(waitwindow)
            return
        end
        spacecell = {' '} ;
        if strcmp(src.Tag,'PlusButton')
            % { 'A' ... 'B' 
            
            houseSel = gui.CopyHouseSource.String{gui.CopyHouseSource.Value} ;
            varSel = gui.varlist.String{gui.varlist.Value} ;
            
            try            
                varDetail = data.varname.(varSel) ;
                IsVariable = true ;
            catch
                varDetail = varSel ;
                IsVariable = false ;
            end
            
            if IsVariable
                value2copy = data.SummaryStructure.(houseSel).(varSel) ;
                addVar(varSel,varDetail,value2copy, gui.Variablelist) ;
            else
                switch varDetail
                    case 'All_Appliances'
                        AppliancesList = data.AppliancesList(:,3);
                        for i = 1:length(AppliancesList)
                            varSel = AppliancesList{i} ;
%                             Message = strcat({'Adding:'},spacecell,{varSel}) ;
%                             waitbar(i/(length(AppliancesList)),waitwindow,Message)
                            if ~isempty(varSel)
                                value2copy = data.SummaryStructure.(houseSel).(varSel) ;
                                NewvarDetail = data.varname.(varSel) ;
                                addVar(varSel,NewvarDetail,value2copy, gui.Variablelist) ;
                            end
                        end
                        
                        AppliancesList = data.AppliancesList(:,4);
                        for i = 1:length(AppliancesList)
                            varSel = AppliancesList{i} ;
%                             Message = strcat({'Adding:'},spacecell,{varSel}) ;
%                             waitbar(i/(length(AppliancesList)),waitwindow,Message)
                            if ~isempty(varSel)
                                value2copy = data.SummaryStructure.(houseSel).(varSel) ;
                                NewvarDetail = data.varname.(varSel) ;
                                addVar(varSel,NewvarDetail,value2copy, gui.Variablelist) ;
                            end
                        end
                    case 'All_Variables'
                        
                        AllVar = fieldnames(data.varname);
                        for i = 1:length(AllVar)
                            varSel = AllVar{i} ;
                            %Message = strcat({'Adding:'},spacecell,{varSel}) ;
                            %waitbar(i/(length(AllVar)),waitwindow) ;
                            if ~isempty(varSel)
                                try
                                    value2copy = data.SummaryStructure.(houseSel).(varSel) ;
                                catch
                                    continue;
                                end
                                NewvarDetail = data.varname.(varSel) ;
                                addVar(varSel,NewvarDetail,value2copy, gui.Variablelist) ;
                            end
                        end
                    case 'All_PVGen'
                      
                    case 'All_WindGen'
                end
            end 
            msgbox('All variable were added successfully!!','Successfull addition')
        elseif strcmp(src.Tag,'MinusButton')
            SelVar = uimulticollist( gui.Variablelist, 'selectedStrCol', 1 ) ;
            
                uimulticollist( gui.Variablelist,'value',1);
                for i = 1:length(SelVar)
                    ExistingVar = uimulticollist(gui.Variablelist,'string') ;

                    % Message = strcat({'Deleting:'},spacecell,{SelVar{i}}) ;
                    % waitbar(i/(length(SelVar)),waitwindow) ;
                    if ~strcmp(SelVar{i},'Short Name')
                        rowIndex = find(strcmp(SelVar{i},ExistingVar(:,1))) ;
                        uimulticollist( gui.Variablelist, 'delRow', rowIndex );
                    end
                end
        end
        delete(waitwindow) ;
        profile viewer
    end %AddRemVar
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
                SavaData('inhabitants',HouseList{i},'1')   ;
%                 data.SummaryStructure.(HouseList{i}).inhabitants = '1';
                Inh = 1 ;
            else
                Inh = str2double(Inh) ;
            end
            MaxAppQtyReport = 0 ;
            %Loop through each appliance
            for ij = 1:size(data.AppliancesList,1)
                ApplianceSel        = data.AppliancesList{ij,1} ;
                Appliancerate       = data.AppliancesList{ij,2} ;
                ApplianceCode       = data.AppliancesList{ij,3} ;
                AppliancerateCode   = data.AppliancesList{ij,4} ;
                
                % MaxQty = data.ApplianceMax{find(strcmp(ApplianceCode,data.ApplianceMax(:,1))==1),Inh+1} ;
                MaxQty = data.ApplianceMax{find(strcmp(ApplianceCode,data.ApplianceMax(:,1))==1),Inh+1} ;

                MinQty = 0;
                AppQty = round(RandBetween(MinQty,MaxQty)) ; %fix(((MaxQty - MinQty + 1) * rand()) + MinQty) ;
                
                if AppQty > 0
                    for appqty = 1:AppQty
                        AppQtyReport(appqty) = {'1'}; 
                    end
                    switch Appliancerate
                        case 'Rate'
                            if ~strcmp(ApplianceSel,'Lighting System')
                                LastApp = ApplianceCode ;
                                MinQty = 2;
                                MaxQty = numel(data.Rating)-1;              % JARI'S MODIFICATION (ADDED -1 TO THE END SINCE RATING NOW HAS 5TH OPTION OF SELF DEFINING!)
                                for apprate = 1:AppQty
                                    % Randomise the Rate of the appliance
                                    AppRatetmp = round(RandBetween(MinQty,MaxQty)) ; %fix(((MaxQty - MinQty + 1) * rand()) + MinQty) ;
                                    AppRatetmp = data.Rating{AppRatetmp} ;
                                    AppRate(apprate) = {AppRatetmp}; 
                                    
                                    % Randomise the database
                                    DBList = fieldnames(data.AppProfile.(ApplianceCode)) ;
                                    AppDBtmp = round(RandBetween(1,length(DBList))) ; %fix(((length(DBList) - 1 + 1) * rand()) + 1) ;
                                    AppDB(apprate) = DBList(AppDBtmp) ;
                                    
                                    % This step is necessary to save the
                                    % variable. The list will be sorted out
                                    % alphabetically later in the
                                    % onListselection function
                                    updateuimulticollist(ApplianceSel, AppRate(apprate), AppQty, AppDB(apprate)) ;
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
                    LastApp = [] ;
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
                if ~isempty(LastApp)
                    SaveData('Appliances', HouseList{i}, ApplianceCode) ;
                end
%                 if ~isempty(AppliancerateCode)
%                     data.SummaryStructure.(HouseList{i}).(AppliancerateCode) = AppRate ;
%                 end
%                 if ~isempty(ApplianceCode)
%                      data.SummaryStructure.(HouseList{i}).(ApplianceCode) = AppQtyReport ;
%                 end
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
            if isfield(data.SelfDefinedAppliances,Housenumber)              % JARI BEGINS
                data.SelfDefinedAppliances = rmfield(data.SelfDefinedAppliances,Housenumber);
            end                                                             % JARI ENDS
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
%% addhousing
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
                FileName = LogoHouse(GetUserType, gui.DisplayUT.Checked);
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
                        FileName = LogoHouse(GetUserType,gui.DisplayUT.Checked);
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
                        FileName = LogoHouse(GetUserType, gui.DisplayUT.Checked);
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
        MinPrice = gui.Low_Price    ;
        MaxPrice = gui.High_Price   ;
        RTPupdate = gui.RTP_Update  ;
        RTPEndArr = gui.RTP_EndTime ;
        ContractType = gui.ContElec ;
        
        switch GetSource
            case 'ContElec'
                ContractSelected = src.String(src.Value) ;
                if strcmpi(data.PriceList{2},ContractSelected)
                    %Disable the pricetime options
                    set(ContractTime,'enable','off')
                    set(MinPrice,'enable','on')
                    set(MaxPrice,'enable','on')
                    set(RTPupdate,'enable','on')
                    set(RTPEndArr,'enable','on')
                    ContractSetting(MinPrice) ;
                    ContractSetting(MaxPrice) ;
                elseif strcmpi(data.PriceList{1},ContractSelected)
                    set(ContractTime,'enable','off')
                    set(MinPrice,'enable','off')
                    set(MaxPrice,'enable','off')
                    set(RTPupdate,'enable','off')
                    set(RTPEndArr,'enable','off')
                    ContractSetting(ContractTime) ;
                else
                    %Enable the pricetime options
                    set(ContractTime,'enable','on')
                    set(MinPrice,'enable','off')
                    set(MaxPrice,'enable','off')
                    set(RTPupdate,'enable','off')
                    set(RTPEndArr,'enable','off')
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
            case 'RTP_Update'
                ContractSelected = src.String ;
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   SaveData('RTP_Update',HouseTag,ContractSelected)
                end
            case 'RTP_EndTime'
                ContractSelected = src.String ;
                for i = 1:numel(HouseSelected)
                   HouseTag =  HouseSelected{i} ;
                   SaveData('RTP_EndTime',HouseTag,ContractSelected)
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

        var = [data.ImageFolder filename];
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
        %%% Check if the field2save is already registered as a field, if
        %%% not then register it
        if ~isfield(data.varname,Field2Save)
            registervar(Field2Save) ;
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
                if strcmp(Field2Save, data.AppliancesList(:,3))
                    str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                    apparray = strcmp(str(:,1),Field2Save) ;
                    if sum(apparray) >= 1
                        foundstr =  str(apparray,:) ;
                    end
                end
            end
        elseif isa(HouseTag,'char')
            if strcmp(Field2Save,'Appliances')
%                 if any(strcmp(Field2Save, data.AppliancesList(:,3)))
                str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                AppName = NewValue ;
                AppLN   = data.datastructure.(AppName).LongName      ;
                apparray = strcmp(str(:,1), AppLN) ;
                if sum(apparray) >= 1
                    foundstr =  str(apparray,:) ;
                    for ij = 1:size(foundstr,1)
                        if isfield(data.SummaryStructure.(HouseTag), 'Appliances')
                            %  Loop through each existing appliance and look if
                            % this particular appliance has already been
                            % defined
                            AppCodeLine = find(strcmp(data.AppliancesList(:,1),foundstr{ij,1}) == 1) ;
                            AppCodeVal  = data.AppliancesList{AppCodeLine,3} ;
                            AllAppData  = data.SummaryStructure.(HouseTag).Appliances ;
                            [Appfound, AppCode] = Getappref(HouseTag, AppCodeVal, foundstr{ij,4}, foundstr{ij,2}) ;
                            
                            if Appfound
                                % We found the app, now we can modifiy the
                                % data
                                if str2double(foundstr{ij,3}) >= 1
                                    % Update with the new number of
                                    % appliances within the frame
                                    data.SummaryStructure.(HouseTag).Appliances.(AppCode).Qty = foundstr{ij,3} ;
                                else
                                    % This means that there is no
                                    % more app anymore with this
                                    % feature, remove the field
                                    % from the structure
                                    data.SummaryStructure.(HouseTag).Appliances = ...
                                        rmfield(data.SummaryStructure.(HouseTag).Appliances,AppCode) ;
                                end
                            else
                                % We did not find the app, Then add the app
                                % into the list
                                n = 0 ;
                                iapp = 1 ;
                                while n == 0
                                    if isfield(AllAppData,['App' num2str(iapp)])
                                        iapp = iapp + 1 ;
                                    else
                                        n = 1 ;
                                        AppTag = ['App' num2str(iapp)] ;
                                    end
                                end
                                data.SummaryStructure.(HouseTag).Appliances.(AppTag).SN     = AppCodeVal ;
                                data.SummaryStructure.(HouseTag).Appliances.(AppTag).Qty    = foundstr{ij,3} ;
                                data.SummaryStructure.(HouseTag).Appliances.(AppTag).DB     = foundstr{ij,4} ;
                                data.SummaryStructure.(HouseTag).Appliances.(AppTag).Class  = foundstr{ij,2} ;
                            end
                        else
                            data.SummaryStructure.(HouseTag).Appliances.App1.SN     = AppCodeVal ;
                            data.SummaryStructure.(HouseTag).Appliances.App1.Qty    = foundstr{ij,3} ;
                            data.SummaryStructure.(HouseTag).Appliances.App1.DB     = foundstr{ij,4} ;
                            data.SummaryStructure.(HouseTag).Appliances.App1.Class  = foundstr{ij,2} ;
                        end
                    end
                end
                % Check if all the App field are listed in the multicollist
                % as this is the updated version. If not, remove the field
                % from the saved information
                AllApp      = fieldnames(data.SummaryStructure.(HouseTag).Appliances) ;
                AllAppData  = data.SummaryStructure.(HouseTag).Appliances ;
                for iapp = 1:length(AllApp)
                    AppTag = AllApp{iapp} ;
                    
                    ArrayApp = strcmp(str(:,2),AllAppData.(AppTag).Class) .* ...
                               strcmp(str(:,1),data.varname.(AllAppData.(AppTag).SN).LongName)    .* ...
                               strcmp(str(:,4),AllAppData.(AppTag).DB) ;
                    if sum(ArrayApp) == 1
                        % This is the normal case, There is nothing to do
                        % as it checks out fine
                    elseif sum(ArrayApp) > 1
                        % This is the not a normal case as there should be
                        % only one of these, give a warning for debug
                        uiwait(msgbox('Issue with the number of apps in the database','Error','modal'));
                    else
                        % This is the case where the appliance does not
                        % exist in the database
                        data.SummaryStructure.(HouseTag).Appliances = rmfield(data.SummaryStructure.(HouseTag).Appliances, AppTag) ;  
                    end
                end
            elseif strcmp(data.varname.(Field2Save).Comparefield,'date')
                    NewValue = datestr(NewValue,'dd/mm/yyyy') ;
                    data.SummaryStructure.(HouseTag).(Field2Save) = NewValue;
                    data.varname.(Field2Save).UserDefValue.(HouseTag) = NewValue;    
            else
                if iscell(NewValue)
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
            spintfsplitstr = {''};
            for i = 1:numel(fields)
                if isa(str.(fields{i}),'double')
                    arg = num2str(str.(fields{i})) ;
                elseif isa(str.(fields{i}),'cell')
                    arg = {''} ;
                    for ii = 1:numel(str.(fields{i}))
                        arg = strcat(arg,{' '},str.(fields{i})(ii)) ;
                    end
                    arg = arg{1} ;
                elseif isa(str.(fields{i}),'struct')
                    
                else
                    arg = str.(fields{i}) ;
                end
                str2input = strcat('<br>',fields{i},': ',arg,'</br>') ;
                spintfsplitstr = [spintfsplitstr strcat(fields{i}, ':',{' '}, arg)] ;
                splitstrhtml = strcat(splitstrhtml,str2input);
            end
            spintfsplitstr = spintfsplitstr ;
            splitstrhtml = strcat(splitstrhtml,'</html>');
        end
    end %createStrToolTip
%-------------------------------------------------------------------------%
    function AddApplianceCallback(src,~)
        if numel(gui.ListBox.String) > 0 || numel(data.Originalarray) > 0
            buttonpushed = src.Tag ;      
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
            
            a = fieldnames(data.Detail_Appliance) ;
            for i = 1:length(a)
                if i == 1
                    Appliance = {data.varname.(a{i}).LongName} ;
                    AOrB      = data.Detail_Appliance.(a{i}).Power(1) ;
                    COrD      = data.Detail_Appliance.(a{i}).Power(2) ;
                    EOrF      = data.Detail_Appliance.(a{i}).Power(3) ;
                    StbPower  = data.Detail_Appliance.(a{i}).Power(4) ;
                    OffMode   = data.Detail_Appliance.(a{i}).Power(5) ;
                else
                    Appliance = [Appliance  ; {data.varname.(a{i}).LongName}] ;
                    AOrB      = [AOrB       ; data.Detail_Appliance.(a{i}).Power(1)] ;
                    COrD      = [COrD       ; data.Detail_Appliance.(a{i}).Power(2)] ;
                    EOrF      = [EOrF       ; data.Detail_Appliance.(a{i}).Power(3)] ;
                    StbPower  = [StbPower   ; data.Detail_Appliance.(a{i}).Power(4)] ;
                    OffMode   = [OffMode    ; data.Detail_Appliance.(a{i}).Power(5)] ;
                end
            end
            
            data.ApplianceRates = table(Appliance,AOrB,COrD,EOrF,StbPower,OffMode) ;
        
            switch buttonpushed
                case 'AddAppliance'
                    AddModAppliances ;
                case 'RemoveAppliance'
                    selectedrow = get( gui.multicolumnApp, 'Value' ) ;
                    if selectedrow > 1
                        selectedQty             = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,3) ;
                        selectedClass           = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,2) ;
                        selectedApp             = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,1) ;
                        selectedDB              = uimulticollist( gui.multicolumnApp, 'selectedStrCol' ,4) ;
                        
                        % JARI'S ADDITION
                        if strcmp(selectedClass,'Self-defined')
                            HouseSelected = gui.ListBox.String(gui.ListBox.Value);
                            if size(HouseSelected,1) > 1
                                for n = 1:size(HouseSelected,1)
                                    Place = strcmp(data.SelfDefinedAppliances.(HouseSelected{n}),selectedApp);
                                    data.SelfDefinedAppliances.(HouseSelected{n})(Place,:) = [];
                                end
                            else
                                Place = strcmp(data.SelfDefinedAppliances.(HouseSelected{1})(:,1),selectedApp);
                                    data.SelfDefinedAppliances.(HouseSelected{1})(Place,:) = [];
                            end  
                            % [locate,~] = find(data.SelfDefinedAppliances,selectedAppliance);
%                             data.SelfDefinedAppliances(locate,:) = [];
                        end

                        % END OF EDITION
                        
                        selectedQty = selectedQty{1} ; %cellfun(@str2num,selectedQty,'un',0) ;
                        if isa(selectedQty,'char')
                            selectedQty = str2double(selectedQty) ;
                        elseif isa(selectedQty,'string')
                            selectedQty = str2double(selectedQty) ;
                        elseif isa(selectedQty,'cell')
                            selectedQty = str2double(selectedQty) ;
                        end
%                         selectedQty = selectedQty{:};
                        if selectedQty > 1
                            selectedQty = selectedQty - 1 ;
                            Newqty = num2str(selectedQty) ; 
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
                        
                        for i = 1:numel(HouseSelected)
                            HouseTag =  HouseSelected{i} ;
                            if isfield(data.SummaryStructure.(HouseTag), 'Appliances')
                                [Appfound, AppCode] = Getappref(HouseTag, selectedApp, selectedDB, selectedClass) ;
                                if Appfound
                                    % We found the app, now we can modifiy the
                                    % data
                                    if str2double(Newqty) >= 1
                                        % Update with the new number of
                                        % appliances within the frame
                                        data.SummaryStructure.(HouseTag).Appliances.(AppCode).Qty = Newqty ;
                                    else
                                        % This means that there is no
                                        % more app anymore with this
                                        % feature, remove the field
                                        % from the structure
                                        data.SummaryStructure.(HouseTag).Appliances = ...
                                            rmfield(data.SummaryStructure.(HouseTag).Appliances,AppCode) ;
                                    end
                                else
                                    % We did not find the app, this is an error

                                end
                                AllApps = fieldnames(data.SummaryStructure.(HouseTag).Appliances) ;
                                AppMax = 0 ;
                                for iapp = 1:length(AllApps)
                                    Qty = data.SummaryStructure.(HouseTag).Appliances.(AllApps{iapp}).Qty ;
                                    if isa(Qty,'char')
                                        Qty = str2double(Qty) ;
                                    elseif isa(Qty,'string')    
                                        Qty = str2double(Qty) ;
                                    elseif isa(Qty,'cell')    
                                        Qty = str2double(Qty) ;
                                    elseif isa(Qty,'double')    
                                        %Nothing to do
                                    end
                                    AppMax = AppMax + Qty ;
                                end
                                SaveData('Appliance_Max',HouseTag,AppMax)
                            end
                        end
                    end
                case 'ChangeDistri'
                    if gui.ViewPanel1.Selection == 3
                        gui.ViewPanel1.Selection = 2 ; 
                    else
                        gui.ViewPanel1.Selection = 3 ; 
                    end
            end
        else
            msgbox('Add a building before adding an appliance', 'Error','warn')
        end
    end %AddApplianceCallback
%--------------------------------------------------------------------------%
    function AddApplianceCall(src,~)
        Source = get(src,'Tag') ;
        if numel(gui.ListBox.String) > 0
            HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
            
            ApplianceRates = data.ApplianceRates;

            switch Source
                case 'popupApp'
                    SelectedValue = src.String{src.Value} ;
                    popupRateobj  = gui.popupRate   ;
                    popupDBobj    = gui.popupDB     ;
                    switch SelectedValue
                        case 'Select appliance...'
                            %Reset the ratings
                            set(popupRateobj,'string','Select...') ;
                            AppList = data.AppliancesList(:,1);
                                 n = 1 ;
                                 ToInsert = 'Select appliance...';
                                 AppList(n+1:end+1,:) = AppList(n:end,:);
                                 AppList(n,:) = {ToInsert};
                                 AppList = orderalphacellarray(AppList,2,numel(AppList));
                            set(gui.popupApp,'String',AppList) ;
                             
                            if get(popupRateobj,'value') > 1
                                set(popupRateobj,'value',1);
                            end
                            if get(popupDBobj,'value') > 1
                                set(popupDBobj,'value',1);
                            end
                        otherwise
                            PositionApp = find(strcmp(data.AppliancesList(:,1), SelectedValue));
                            Rank = data.AppliancesList{PositionApp,2} ;
                            if strcmp(SelectedValue,'Lighting System')
                                str = data.Lightopt;
                                set(gui.ApplianceRateText,'String','Add the Appliance Power [kW/m2]');
                                set(gui.popupQty,'enable','off','String','1');
                            else
                                set(gui.ApplianceRateText,'String','Add the Appliance Power [kW]');
                                set(gui.popupQty,'enable','on');
                                switch Rank
                                    case SelectedValue
                                    case 'Rate'
                                        str = data.Rating(:) ;
                                    case 'None'
                                        str = {'Select...','-','Self-defined'};
                                        set(popupRateobj,'value',2);
                                end
                            end
                            set(popupRateobj,'string',str) ;
                            if get(popupRateobj,'value') > 2 && popupRateobj.Value ~= 5 % Second on JARI
                                    set(popupRateobj,'value',1);    % ORIGINAL!!
                            end
                            DbList = fieldnames(data.AppProfile.(data.AppliancesList{PositionApp,3})) ;
                                ToInsert = 'Select database...';
                                DbList(2:end+1,:) = DbList(1:end,:);
                                DbList(1,:) = {ToInsert};
                                DbList = orderalphacellarray(DbList,2,numel(DbList));
                            set(gui.popupDB,'String', DbList) ;
                            if get(gui.popupDB,'Value') > length(DbList)
                                set(gui.popupDB,'Value',1)
                            end
                            if gui.ownSelection == 1            % JARI
                                if strcmp(SelectedValue, 'Rate') % JARI
                                    set(popupRateobj,'value',5)     % JARI
                                elseif strcmp(SelectedValue,'None')                            % JARI
                                    set(popupRateobj,'value',3)     % JARI
                                else
                                    set(popupRateobj,'value',4)     % JARI (LIGHTING)
                                end                             % JARI
                            end                                 % JARI

                            if gui.ownSelection.Value == 1      % JARI BEGNS
                                StandByAppliances = {'Microwave' 'Coffee maker' 'Toaster' 'Waffle' 'Kettle' 'Hair dryer' 'Television' 'Stereo' 'Iron' 'Vacuum cleaner'} ;
                                if any(strcmp(gui.popupApp.String{gui.popupApp.Value},StandByAppliances))
                                    set(gui.ApplianceStandBy,'visible','on','enable','on')
                                    if any(strcmp(gui.popupApp.String(gui.popupApp.Value),'Laptop'))
                                        set(gui.ApplianceSleep,'visible','on','enable','on')
                                    else
                                        set(gui.AppliacneSleep,'visible','on','enable','off')
                                    end
                                else
                                    set(gui.ApplianceStandBy,'visible','on','enable','off')
                                    set(gui.ApplianceSleep,'visible','on','enable','off')
                                    set(gui.ApplianceStandBy, 'String', '0')
                                    set(gui.ApplianceSleep, 'String', '0')
                                end
                            end
                            % Reset the rating in the boxes
                            setratingapp(ApplianceRates) ;       
                    end                             % JARI ENDS          
                case 'popupRate'
                    if strcmp(gui.popupRate.String(gui.popupRate.Value),'Self-defined')
                        gui.ownSelection.Value = 1;
                        src = gui.ownSelection;
                        AddApplianceCall(src)
                    elseif strcmp(gui.popupRate.String(gui.popupRate.Value),'-')
                        set(gui.ApplianceRate,'visible','on','enable','off')
                        set(gui.ApplianceRateText,'visible','on')
                        set(gui.ApplianceSleepText,'visible','on')
                        set(gui.ApplianceStandByText,'visible','on')
                        set(gui.ApplianceStandBy,'visible','on','enable','off')
                        set(gui.ApplianceSleep,'visible','on','enable','off')
                        % Reset the rating in the boxes
                        setratingapp(ApplianceRates) ;
                    else
                        % Reset the rating in the boxes
                        setratingapp(ApplianceRates) ;
                    end
                    
                    
                case 'popupDB' 
                    % Check all the appliances that uses the database
                    SelectedValue = src.String{src.Value} ;
                    
                    switch SelectedValue
                        case 'Select database...'
                            % Reinstate all the appliances in the gui.popupApp
                             AppList = data.AppliancesList(:,1);
                             n = 1 ;
                             ToInsert = 'Select appliance...';
                             AppList(n+1:end+1,:) = AppList(n:end,:);
                             AppList(n,:) = {ToInsert};
                             AppList = orderalphacellarray(AppList,2,numel(AppList));
                             set(gui.popupApp,'String',AppList) ;
                             
                             % Reset the rating in the boxes
                             setratingapp(ApplianceRates) ;
                        otherwise
                            % Loop through all the data.AppProfile
                            SelectedApp = gui.popupApp.String{gui.popupApp.Value} ;
                            AllApps     = fieldnames(data.AppProfile) ;
                            AppList     = {} ;
                            for i = 1:length(AllApps)
                                if any(strcmp(SelectedValue,fieldnames(data.AppProfile.(AllApps{i}))))
                                    AppList{end + 1, 1} = data.datastructure.(AllApps{i}).LongName ;
                                end
                            end
                            ToInsert = 'Select appliance...';
                             n = 1 ;
                             AppList(n+1:end+1,:) = AppList(n:end,:);
                             AppList(n,:) = {ToInsert};
                             AppList = orderalphacellarray(AppList,2,numel(AppList));
                             if get(gui.popupApp,'Value') > length(AppList)
                                 if any(strcmp(SelectedApp,AppList))
                                     set(gui.popupApp,'Value',find(strcmp(SelectedApp,AppList)==1)) ;
                                 else
                                     set(gui.popupApp,'Value',1)
                                 end
                             elseif get(gui.popupApp,'Value') > 1
                                 if any(strcmp(SelectedApp,AppList))
                                     set(gui.popupApp,'Value',find(strcmp(SelectedApp,AppList)==1)) ;
                                 else
                                     set(gui.popupApp,'Value',1)
                                 end
                             end
                             set(gui.popupApp,'String',AppList) ;
                    end
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
                    %%% Check if all inputs are valid
                    Check1 = gui.popupApp ;
                        Inputstr1 = Check1.String(Check1.Value) ;
                        if strcmp(Inputstr1,'Select appliance...') 
                            uiwait(msgbox('Please select an appliance','Error','modal'));
                            return;
                        end
                        AppName = data.AppliancesList{find(strcmp(Inputstr1{1},data.AppliancesList(:,1)) == 1),3} ;
                        
                    Check4 = gui.popupDB ;
                        Inputstr4 = Check4.String(Check4.Value) ;    
                        if strcmp(Inputstr4,'Select database...') 
                            uiwait(msgbox('Please select a database','Error','modal'));
                            return;
                        end
                        
                    Check2 = gui.popupRate ;
                        Inputstr2 = Check2.String(Check2.Value) ;
                        if strcmp(Inputstr2,'Select...') || strcmp(Inputstr2,'S')
                            uiwait(msgbox('Please select category','Error','modal'));
                            return;
                        elseif strcmp(Inputstr2,'-')
                        elseif strcmp(Inputstr2,'Self-defined')
                            for hh = 1:size(HouseSelected,1)
                               data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(Inputstr4{1}).Rate = str2double(gui.ApplianceRate.String)    ;
                               data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(Inputstr4{1}).Sleep = str2double(gui.ApplianceSleep.String)   ;
                               data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(Inputstr4{1}).StandBy = str2double(gui.ApplianceStandBy.String) ;
                            end
                        end
                    Check3 = gui.popupQty ;
                        Inputstr3 = Check3.String(Check3.Value) ;
                    
                    %%% UPDATE THE UIMULTICOLLIST     
                    % Get the data from the multi column list to compare them
                    % with thenew input data
                    updateuimulticollist(Inputstr1, Inputstr2, Inputstr3, Inputstr4) ;
                    
                    %%% SAVE THE APPLIANCES AND FIELDS FROM THE
                    %%% UIMULTICOLLIST
                    for i = 1:numel(HouseSelected)
                       HouseTag =  HouseSelected{i} ;

                       str = uimulticollist( gui.multicolumnApp, 'string' ) ;
                       [srow,~] = size(str) ;
                        if srow>1
                            % Save only the appliance just recorded
                            Appliance       = strcmp(Inputstr1,str(:,1)) ;
                            codeAppliance   = data.AppliancesList{find(strcmp(Inputstr1,data.AppliancesList(:,1))==1),3} ;
                            classAppliance  = data.AppliancesList{find(strcmp(Inputstr1,data.AppliancesList(:,1))==1),4} ;
                            codedatabase    = [codeAppliance 'database'] ;
                            if sum(Appliance) > 0
                                QtyAppAll   = {str{find(Appliance==1),3}} ;
                                ApprateAll  = {str{find(Appliance==1),2}} ;
                                DBAll       = {str{find(Appliance==1),4}} ;
                                NewDataQty  = {}; 
                                NewDataRate = {};
                                NewDataDB   = {}; 
                                
                                for AppQty = 1:sum(Appliance)
                                    QtyApp  = str2double(QtyAppAll{AppQty}) ;
                                    Apprate = ApprateAll{AppQty}            ;
                                    DB      = DBAll{AppQty}                 ;
                                    for AppQtyRank = 1:QtyApp
                                        NewDataQty  = [NewDataQty {'1'}] ;
                                        NewDataRate = [NewDataRate  {Apprate}]  ;
                                        NewDataDB   = [NewDataDB    {DB}]       ;
                                    end
                                end
                                if ~isempty(codeAppliance)
                                    SaveData(codeAppliance,HouseTag,NewDataQty)
                                end
                                if ~isempty(classAppliance)
                                    SaveData(classAppliance,HouseTag,NewDataRate)
                                end
                                if ~isempty(codedatabase)
                                    SaveData(codedatabase,HouseTag,NewDataDB)
                                end
                                SaveData('Appliances', HouseTag, codeAppliance) ;
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
                case 'ownSelection'                 % ALL JARI'S UNDER HERE!
                    if gui.ownSelection.Value == 1
                        set(gui.ApplianceRate,'visible','on','enable','on')
                        set(gui.ApplianceRateText,'visible','on')
                        set(gui.ApplianceSleepText,'visible','on')
                        set(gui.ApplianceStandByText,'visible','on')
                        set(gui.ApplianceStandBy,'visible','on','enable','on')
                        set(gui.ApplianceSleep,'visible','on','enable','on')                            

                        ValueRate = find(strcmp(gui.popupRate.String, 'Self-defined') == 1) ;
                        set(gui.popupRate, 'Value', ValueRate) ;
                        
                        Housenumber     = gui.ListBox.String(gui.ListBox.Value);
                        AppName         = data.AppliancesList{find(strcmp(data.AppliancesList(:,1), gui.popupApp.String{gui.popupApp.Value})),3} ;
                        DBsel           = gui.popupDB.String{gui.popupDB.Value} ;
                        
                        if strcmp(DBsel,'Select database ...')
                             set(gui.ApplianceRate   ,'String','0')
                             set(gui.ApplianceSleep  ,'String','0') 
                             set(gui.ApplianceStandBy,'String','0')
                        else
                            if strcmp(gui.popupRate.String(gui.popupRate.Value),'Self-defined') && isfield(data.SelfDefinedAppliances,Housenumber(1))
                                if isfield(data.SelfDefinedAppliances.(Housenumber{1}), AppName)
                                    if isfield(data.SelfDefinedAppliances.(Housenumber{1}).(AppName), DBsel)
                                        set(gui.ApplianceRate   ,'String',num2str(data.SelfDefinedAppliances.(Housenumber{1}).(AppName).(DBsel).Rate))
                                        set(gui.ApplianceSleep  ,'String',num2str(data.SelfDefinedAppliances.(Housenumber{1}).(AppName).(DBsel).Sleep))
                                        set(gui.ApplianceStandBy,'String',num2str(data.SelfDefinedAppliances.(Housenumber{1}).(AppName).(DBsel).StandBy))
                                    else
                                        set(gui.ApplianceRate   ,'String','0')
                                        set(gui.ApplianceSleep  ,'String','0') 
                                        set(gui.ApplianceStandBy,'String','0')
                                    end
                                else
                                     set(gui.ApplianceRate   ,'String','0')
                                     set(gui.ApplianceSleep  ,'String','0') 
                                     set(gui.ApplianceStandBy,'String','0')
                                end
                            end
                        end

                    else
                        set(gui.ApplianceRate,'visible','on','enable','off')
                        set(gui.ApplianceRateText,'visible','on')
                        set(gui.ApplianceSleep,'visible','on','enable','off')
                        set(gui.ApplianceSleepText,'visible','on')
                        set(gui.ApplianceStandBy,'visible','on','enable','off')
                        set(gui.ApplianceStandByText,'visible','on')
                        set(gui.popupRate, 'enable','on')
                        
                        SelectedValue   = gui.popupApp.String{gui.popupApp.Value} ;
                        PositionApp     = find(strcmp(data.AppliancesList(:,1), SelectedValue));
                        popupRateobj    = gui.popupRate ;
                        if isempty(PositionApp)
                            set(gui.popupRate,'string','Select...')
                        else
                            Rank = data.AppliancesList{PositionApp,2} ;
                            if strcmp(SelectedValue,'Lighting System')
                                str = data.Lightopt;
                            else
                                switch Rank
                                    case SelectedValue
                                    case 'Rate'
                                        str = data.Rating(:) ;
                                    case 'None'
                                        str = {'Select...','-','Self-defined'};
                                        set(popupRateobj,'value',2);
                                end
                            end
                            set(popupRateobj,'string',str) ;
                            if get(popupRateobj,'value') > 2
                                set(popupRateobj,'value',1);
                            end
                        end                        
                        % Reset the rating in the boxes
                        setratingapp(ApplianceRates) ;                                    
                    end
                case {'ApplianceStandBy', 'ApplianceRate', 'ApplianceSleep' } 
                    Housenumber     = gui.ListBox.String(gui.ListBox.Value);
                    AppName         = data.AppliancesList{find(strcmp(data.AppliancesList(:,1), gui.popupApp.String{gui.popupApp.Value})),3} ;
                    DBsel           = gui.popupDB.String{gui.popupDB.Value} ;
                    
                    %%% Check for errors before proceeding
                    Inputstr1 = gui.popupApp.String(gui.popupApp.Value) ;
                    if strcmp(Inputstr1,'Select appliance...') 
                        uiwait(msgbox('Please select an appliance','Error','modal'));
                        return;
                    end
                    
                    if strcmp(DBsel,'Select database...') 
                        uiwait(msgbox('Please select a database','Error','modal'));
                        return;
                    end
                    
                    %%% Retrieve the value and store it in the self defined
                    %%% variable
                    
                    for hh = 1:size(Housenumber,1)
                        switch Source
                            case 'ApplianceStandBy'
                                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).StandBy    = str2double(gui.(Source).String)   ;
                            case 'ApplianceRate' 
                                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Rate       = str2double(gui.(Source).String)   ;
                            case 'ApplianceSleep'
                                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Sleep      = str2double(gui.(Source).String)   ;
                        end
                        % Fill in the missing fields if they have never
                        % been declared before
                        if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel),'Rate')
                            data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Rate   = 0 ;
                        end
                        if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel),'StandBy')
                            data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).StandBy   = 0 ;
                        end
                        if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel),'Sleep')
                            data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Sleep   = 0 ;
                        end
                    end  
                otherwise
            end
        end
    end %AddApplianceCall
%--------------------------------------------------------------------------%
%% Calculate the amount of appliances per house
    function MaxApp = maxAppcount(HouseTag)
        AllApps = fieldnames(data.SummaryStructure.(HouseTag).Appliances) ;
        MaxApp = 0 ;
        for iapp = 1:length(AllApps)
            Qty = data.SummaryStructure.(HouseTag).Appliances.(AllApps{iapp}).Qty ;
            if isa(Qty,'char')
                Qty = str2double(Qty) ;
            elseif isa(Qty,'string')    
                Qty = str2double(Qty) ;
            elseif isa(Qty,'cell')    
                Qty = str2double(Qty) ;
            elseif isa(Qty,'double')    
                %Nothing to do
            end
            MaxApp = MaxApp + Qty ;
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
                    ToInsert = num2str(str2double(obj.String));
                    PositionApp = find(strcmp(AppList(:), ToInsert), 1) ;
                    if isempty(PositionApp)
                        AppList(n+1:end+1,:) = AppList(n:end,:);
                        AppList(n,:) = {ToInsert};
                    end
                    AppListnum = cellfun(@str2num,{AppList{1:(numel(AppList)-1)}},'un',0).' ;
                    AppList(1:(numel(AppList)-1)) = AppListnum ;
                    
                    AppList(cellfun(@isempty,AppList)) = {'more...'} ;
                    
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

%% Menu File
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
%                HouseNames = gui.ListBox.String    ;     % JARI'S ADDITION, LOOP THROUGH HOUSES THAT HAVE SELF-DEFINED APPLIANCES AND SAVE THEIR VALUES
               for i = 1:length(Housenumber)
                   if isfield(data.SelfDefinedAppliances, Housenumber{i})
                       data.SummaryStructure.(Housenumber{i}).SelfDefinedAppliances = data.SelfDefinedAppliances.(Housenumber{i});
                   else
                       data.SummaryStructure.(Housenumber{i}).SelfDefinedAppliances = 0;
                   end
               end                                      % JARI'S ADDITION ENDS
               AllData = data.SummaryStructure ;
               
               
               for ii = 1:numel(Housenumber)
                   Eachfield = fieldnames(AllData.(Housenumber{ii}));
                   for i = 1:numel(Eachfield)
                       MaxValue = 1;
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
                   Eachfield = fieldnames(AllData.(Housenumber{i}));
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
                               try
                                   MaxApp = max(MaxApp,size(AllData.(Housenumber{jjHouse}).(Eachfield{ii}),2)) ;
                               catch
                                   continue;
                               end
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
               data.Simulationdata  = AllData ;
               %%% Prepare the s structure to be converted accordingly
               sXML                 = strcut2XMLStruct(s,'XMLSmartHouse')    ;
               %%% Convert the s structure to xml
               struct2xml(sXML,fn) ;
               %struct2csv(s,fn)
               % uiwait(msgbox('File saved successfully','Information','modal'));
           case 'Save selected as...'
               HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
               CurrentSavingName = data.savedname ;
               data.savedname = '' ;
               for i = 1:size(HouseSelected,1)              % JARI'S ADDITION FOR LOOPING THROUGH THE HOUSES AND SAVE THEIR SELF-DEFINED APPLIANCES
                   if isfield(data.SelfDefinedAppliances, HouseSelected{i})
                        data.SummaryStructure.(HouseSelected{i}).SelfDefinedAppliances = data.SelfDefinedAppliances.(HouseSelected{i});
                   else
                       data.SummaryStructure.(HouseSelected{i}).SelfDefinedAppliances = 0;
                   end
               end                                          % JARI'S ADDITION ENDS
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
               sXML = strcut2XMLStruct(s, 'XMLSmartHouse')    ;
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
               HouseNames = gui.ListBox.String    ;     % JARI'S ADDITION, LOOP THROUGH HOUSES THAT HAVE SELF-DEFINED APPLIANCES AND SAVE THEIR VALUES
               for i = 1:size(HouseNames,1)
                   if isfield(data.SelfDefinedAppliances, HouseNames{i})
                        data.SummaryStructure.(HouseNames{i}).SelfDefinedAppliances = data.SelfDefinedAppliances.(HouseNames{i});
                   else
                       data.SummaryStructure.(HouseNames{i}).SelfDefinedAppliances = 0;
                   end
               end                                      % JARI'S ADDITION ENDS
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
                   sXML = strcut2XMLStruct(s,'XMLSmartHouse')    ;
                   struct2xml(sXML,fn) ; 
%                    struct2csv(s,fn)
               end
               uiwait(msgbox(strcat(num2str(numel(Housenumber)),' houses were saved successfully with the extensions ''_XXXXXX'''),'Information','modal')); 
                data.savedname = CurrentSavingName ;
           case 'New'
               SBuM
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
               
               VarFormat.SelfDefinedAppliances.Type = 'cell';   % JARI'S ADDITION FOR TESTING
               
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
               
               [dataout, addedHouses] = importXMLSavedHouse(LoadFullPath,data.AppliancesList,HouseNbr) ;
               
               for ihouse = 1:length(addedHouses)
                   % for each house, check if the Appliances field is
                   % present. If not, add it based on the appliances
                   % present in the description
                   if ~isfield(dataout.SummaryStructure.(addedHouses{ihouse}),'Appliances')
                       AppList  = find(ismember(fieldnames(dataout.SummaryStructure.(addedHouses{ihouse})),data.AppliancesList(:,3))==1) ;
                       nbrApp   = length(AppList) ;
                       Allfields = fieldnames(dataout.SummaryStructure.(addedHouses{ihouse})) ;
                       for ifield = 1:nbrApp
                           Appnumber = AppList(ifield)      ;
                           AppName   = Allfields{Appnumber} ;
                           % Parse the appliance into the new structure
                           % variable
                           dataout = AddAppliancesfieldImport(AppName, dataout, addedHouses{ihouse}) ;
                       end
                   end
               end
               data.SummaryStructure = catstruct(data.SummaryStructure, dataout.SummaryStructure) ;
               
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
%                 HouseNames = fieldnames(data.SummaryStructure);
                for i = 1:size(addedHouses,2) %fieldnames(data.SummaryStructure))
                    data.SelfDefinedAppliances.(addedHouses{i}) = data.SummaryStructure.(addedHouses{i}).SelfDefinedAppliances;
%                     if isnumeric(data.SelfDefinedAppliances.(addedHouses{i})(1))
                    if strcmp(data.SelfDefinedAppliances.(addedHouses{i})(1),'0')
                        data.SelfDefinedAppliances = rmfield(data.SelfDefinedAppliances,addedHouses{i});
                    else
                        for m = 1:size(data.SelfDefinedAppliances.(addedHouses{i}),1)
                            for n = 2:4
                                data.SelfDefinedAppliances.(addedHouses{i}){m,n} = str2double(data.SelfDefinedAppliances.(addedHouses{i})(m,n));
                            end
                        end
                    end
                    data.SummaryStructure.(addedHouses{i}) = rmfield(data.SummaryStructure.(addedHouses{i}),'SelfDefinedAppliances');

                end
                profileupdate('Load') ;
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
                figHandles = findall(0, 'Tag', 'TMWWaitbar') ;
                delete(figHandles) ;
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
                    if ~isfield(data,'ProfileUserdistri')
                        profileupdate('Update Sim') ;
                    end
                    Launch_Sim(gui.OutputFolEdit.String,gui.NameSimEdit.String,data,gui.SimLogWindow)
                end
            case 'Run Selected'
                figHandles = findall(0, 'Tag', 'TMWWaitbar') ;
                delete(figHandles) ;
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
                    'Simulation'
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
                
                gui.DevelopmentBox = uix.VBox('Parent', gui.PanelSimulation, ...
                                              'Spacing', 5);                     
                    gui.DevelopmentTick = uicontrol('Parent', gui.DevelopmentBox,...
                                                    'Style', 'checkbox', ...
                                                    'String', 'Access Development mode', ...
                                                    'Tag', 'DevelopmentMode', ...
                                                    'callback', @AccessDevelopmentMode);
                    gui.App10s = uicontrol('Parent', gui.DevelopmentBox,...
                                                    'Style', 'checkbox', ...
                                                    'String', 'Record detailed appliance signature - 10s', ...
                                                    'Tag', 'App10s', ...
                                                    'Value', data.App10s, ...
                                                    'callback', @AccessDevelopmentMode);
                   uix.Empty('Parent', gui.DevelopmentBox);                             
                   set(gui.DevelopmentTick, 'Value', data.DebugMode)
                    
                    set(gui.DevelopmentBox,'Heights',[23 23 -1]);
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
        if strcmp(VentilationSelected, 'Natural ventilation')
            gui.DemandVentilation.Enable = 'off';
        else
            gui.DemandVentilation.Enable = 'on';
        end
        for i = 1:numel(HousingSelected)
            HouseTag = HousingSelected{i};
            SaveData(GetSource,HouseTag,VentilationSelected)
        end
    case 'DemandVentilation'
        DemandVentilationSelected = src.Value;
        for i = 1:numel(HousingSelected)
            HouseTag = HousingSelected{i};
            SaveData(GetSource,HouseTag,DemandVentilationSelected)
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
                                                SaveData('uvs',Housenumber,num2str(U_values{indx+1,1})) ;
                                                SaveData('uve',Housenumber,num2str(U_values{indx+1,1})) ;
                                                SaveData('uvw',Housenumber,num2str(U_values{indx+1,1})) ;
                                                SaveData('uvn',Housenumber,num2str(U_values{indx+1,1})) ;
                                                
                                                SaveData('uvr',Housenumber,num2str(U_values{indx+1,2})) ;
                                                
                                                SaveData('uvf',Housenumber,num2str(U_values{indx+1,3})) ;
%                                                 data.SummaryStructure.(Housenumber).uvs        = num2str(U_values{indx+1,1});
%                                                 data.SummaryStructure.(Housenumber).uve        = num2str(U_values{indx+1,1});
%                                                 data.SummaryStructure.(Housenumber).uvw        = num2str(U_values{indx+1,1});
%                                                 data.SummaryStructure.(Housenumber).uvn        = num2str(U_values{indx+1,1});

                                                SaveData('uvsw',Housenumber,num2str(U_values{indx+1,4})) ;
                                                SaveData('uvew',Housenumber,num2str(U_values{indx+1,4})) ;
                                                SaveData('uvnw',Housenumber,num2str(U_values{indx+1,4})) ;
                                                SaveData('uvww',Housenumber,num2str(U_values{indx+1,4})) ;
                                                
                                                SaveData('uvd',Housenumber,num2str(U_values{indx+1,5})) ;
                                                
                                                SaveData('n50',Housenumber,num2str(U_values{indx+1,6})) ;
                                                
                                                SaveData('Heat_recovery_ventil_annual',Housenumber,num2str(U_values{indx+1,7})) ;
                                                
                                                SaveData('gwindow',Housenumber,num2str(U_values{indx+1,8})) ;
%                                                 data.SummaryStructure.(Housenumber).uvsw       = num2str(U_values{indx+1,4});
%                                                 data.SummaryStructure.(Housenumber).uvew       = num2str(U_values{indx+1,4});
%                                                 data.SummaryStructure.(Housenumber).uvnw       = num2str(U_values{indx+1,4});
%                                                 data.SummaryStructure.(Housenumber).uvww       = num2str(U_values{indx+1,4});
%                                                 data.SummaryStructure.(Housenumber).uvd        = num2str(U_values{indx+1,5});
%                                                 data.SummaryStructure.(Housenumber).uvf        = num2str(U_values{indx+1,3});
%                                                 data.SummaryStructure.(Housenumber).uvr        = num2str(U_values{indx+1,2});    
%                                                 data.SummaryStructure.(Housenumber).n50        = num2str(U_values{indx+1,6});    
%                                                 data.SummaryStructure.(Housenumber).Heat_recovery_ventil_annual = num2str(U_values{indx+1,7});    
%                                                 data.SummaryStructure.(Housenumber).gwindow    = num2str(U_values{indx+1,8});


                                                if indx == 7 || indx == 8
%                                                     data.Simulationdata.(Housenumber).vent_elec  = num2str(U_values{indx+1,9});
%                                                     data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9});
                                                    SaveData('vent_elec',Housenumber,num2str(U_values{indx+1,9})) ;
                                                else
%                                                         data.Simulationdata.(Housenumber).vent_elec  = U_values{indx+1,9};
                                                        if strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Natural ventilation') == 1
                                                            SaveData('vent_elec',Housenumber,num2str(U_values{indx+1,9}(1))) ;
%                                                             data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(1));
                                                        elseif strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Mechanical ventilation') == 1
                                                            SaveData('vent_elec',Housenumber,num2str(U_values{indx+1,9}(2))) ;
%                                                             data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(2));
                                                        elseif strcmp(data.SummaryStructure.(Housenumber).Ventil, 'Air-Air H-EX') == 1
                                                            SaveData('vent_elec',Housenumber,num2str(U_values{indx+1,9}(3))) ;
%                                                             data.SummaryStructure.(Housenumber).vent_elec  = num2str(U_values{indx+1,9}(3));
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
%% Import the EPW file
    function BrowseEWP(src,~)
        [file, path] = uigetfile('*.epw');

        if file == 0
            return;
%         else
%             FullFile = strcat(path,file);
        end
        
        str = uimulticollist( gui.multiEPWfiles, 'string' );
        
        if size(str,1) > 1
            uimulticollist(gui.multiEPWfiles, 'changeItem', file, 2, 1 )
            uimulticollist(gui.multiEPWfiles, 'changeItem', path, 2, 2 )
        else
            rowItems = {file path} ;
            uimulticollist( gui.multiEPWfiles, 'addRow', rowItems )
        end
        
        %%% Load the EPW into variables
        
    end
%% Load EPW file
    function LoadEWP(src,~)
        gui.EPWLoadText.String = 'Loading...' ;
        str = uimulticollist(gui.multiEPWfiles, 'string') ;
        path = str{2,2} ;
        file = str{2,1} ;
        
        FullPath = [path file] ;
        
        [data.EPW] = EPWreader(FullPath) ;
        gui.EPWLoadText.String = 'Successfully loaded!!' ;
    end
%--------------------------------------------------------------------------%
%% This function is used in importing external file to the model to be used as source for the code
% You can import a suitable file for yourself to be used in the simulation

function ImportExternalFile(src, ~)

% Start with defining whether a file is added or removed.
Input_Var = gui.ListFileInd.String{gui.ListFileInd.Value} ;    
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
switch(Input_Var)
    case 'Temperature'
        data.FileSelection.TemperatureFile      = FullFile;
        data.FileSelection.TemperatureChanged   = 1;
%         gui.TemperatureFile.String              = FullFile;
        % Code
    case 'Radiation'
        data.FileSelection.RadiationFile        = FullFile;
        data.FileSelection.RadiationChanged     = 1;
%         gui.RadiationFile.String                = FullFile;
        % Code
    case 'Price'
        data.FileSelection.PriceFile            = FullFile;
        data.FileSelection.PriceChanged         = 1;
%         gui.PriceFile.String                    = FullFile;
        % Code
    case 'Emission'
        data.FileSelection.EmissionsFile        = FullFile;
        data.FileSelection.EmissionsChanged     = 1;
%         gui.EmissionFile.String                 = FullFile;
        % Code
        
end
str = uimulticollist( gui.multiweatherfiles, 'string' );
if any(strcmp(str(:,1),Input_Var))
    Row2Change = find(strcmp(str(:,1),src.Tag)==1) ;
    uimulticollist(gui.multiweatherfiles, 'changeItem', FullFile, Row2Change, 2 )
else
    rowItems = {Input_Var FullFile} ;
    uimulticollist( gui.multiweatherfiles, 'addRow', rowItems )
end

elseif strcmp(src.String,'Remove')
    % The part where the preselected file is removed and the default file
    % is used!
    selectedrow = get( gui.multiweatherfiles, 'Value' ) ;
    if selectedrow > 1
        Input_Var = uimulticollist( gui.multiweatherfiles, 'selectedStrCol',1);
            uimulticollist( gui.multiweatherfiles, 'delRow', selectedrow )

            switch(Input_Var{1})
                case 'Temperature'
                    data.FileSelection.TemperatureFile = [];
                    data.FileSelection.TemperatureChanged = 0;
        %             gui.TemperatureFile.String            = 'Select Temperature file...';
                    % Code
                case 'Radiation'
                    data.FileSelection.RadiationFile = [];
                    data.FileSelection.RadiationChanged = 0;
        %             gui.RadiationFile.String            = 'Select Radiation file...';
                    % Code
                case 'Price'
                    data.FileSelection.PriceFile = [];
                    data.FileSelection.PriceChanged = 0;
        %             gui.PriceFile.String            = 'Select Price file...';
                    % Code
                case 'Emission'
                    data.FileSelection.EmissionsFile = [];
                    data.FileSelection.EmissionsChanged = 0;
        %             gui.EmissionFile.String            = 'Select Emission file...';
                    % Code
            end
        set(gui.multiweatherfiles, 'Value',1 ) ;
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
                selectedDB          = uimulticollist(gui.multicolumnApp, 'selectedStrCol', 4);

                % Neglect the selection if the selection is the first row!
                
                if strcmp(selectedAppliance,'Appliance')       % The first row is an exception and should be neglected
                    return;  
                end
                
                % Create a window for determining the modifications to the
                % selection
                
                AddModAppliances(selectedAppliance, selectedRank, selectedQuantity, selectedDB)           
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
        

        idx                     = find(strcmp(data.Time_Step,data.SummaryStructure.(Housenumber).Time_Step )) ;
        gui.ListTimeStep.Value  = idx ;
        
        gui.Profile.Value       = find(strcmp(gui.Profile.String, data.SummaryStructure.(Housenumber).Profile) == 1);
        
        % Update house details
        
        gui.inhabitants.Value   = find(strcmp(gui.inhabitants.String, data.SummaryStructure.(Housenumber).inhabitants) == 1);
        gui.nbrRoom.String      = data.SummaryStructure.(Housenumber).nbrRoom;
        
        gui.Latitude.String     = data.SummaryStructure.(Housenumber).Latitude;
        gui.Longitude.String    = data.SummaryStructure.(Housenumber).Longitude;
        
        str                     = {'Appl.' 'Rate' 'Qty' 'Database'} ;
        
        % Delete the previous information from the multi column list box,
        % and attach only the string to. Afterwards the rest of the
        % information will be added in the for -loop.
        
        nbrOfItems  = uimulticollist(gui.multicolumnApp, 'nRows');
        
        if nbrOfItems > 1       % If only the first row exists, there are no appliances, and there is no need to delete the rows!            
            uimulticollist( gui.multicolumnApp, 'delRow', 2:nbrOfItems);            
        end
        
        if isfield(data.SummaryStructure.(Housenumber),'Appliances')
            AllApp = fieldnames(data.SummaryStructure.(Housenumber).Appliances) ;
            for i = 1:size(AllApp,1)
                AppNumber = AllApp{i} ;
                ApplianceLongName   = data.varname.(data.SummaryStructure.(Housenumber).Appliances.(AppNumber).SN).LongName ; 
                                      %data.SummaryStructure.(Housenumber).Appliances.(AppNumber).SN     ;
                ApplianceRate       = data.SummaryStructure.(Housenumber).Appliances.(AppNumber).Class  ;
                Quantity            = data.SummaryStructure.(Housenumber).Appliances.(AppNumber).Qty    ;
                DBupdate            = data.SummaryStructure.(Housenumber).Appliances.(AppNumber).DB     ;
                
                str                 = [str; {ApplianceLongName, ApplianceRate, Quantity, DBupdate}];
                
            end
            uimulticollist( gui.multicolumnApp, 'string', str)     ; 
        else
            for i = 1:size(data.AppliancesList,1)

                CurrentApp          = data.AppliancesList{i,3};
                CurrentRate         = data.AppliancesList{i,4};
                CurrentDB           = [CurrentApp 'database'] ;
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
                        if iscell(data.SummaryStructure.(Housenumber).(CurrentDB))        % Normal case when importing                     
                            DBupdate = data.SummaryStructure.(Housenumber).(CurrentDB){1};                        
                        else                                                                % Case when there is no appliances created                        
                            DBupdate = data.SummaryStructure.(Housenumber).(CurrentDB);                        
                        end
                    end
                    Quantity            = num2str(nbrApp);
                    str                 = [str; {ApplianceLongName, ApplianceRate, Quantity, DBupdate}];
                    NewStr              = str(end,1:4);                                         % Think if could be done more straightfoward
                    uimulticollist( gui.multicolumnApp, 'addRow', NewStr, size(str,1) )     ;                
                end            
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
        switch src.Tag
            case 'App10s'
                data.App10s  = abs(data.App10s-1) ;
            case 'DevelopmentMode'
                data.DvptMode  = abs(data.DvptMode-1) ;
                data.DebugMode = abs(data.DebugMode-1) ;

                if numel(gui.ListBox.Value) > 1
                    for n = gui.ListBox.Value(1):gui.ListBox.Value(end)
                        Housenumber = gui.ListBox.String{n};
                        DefineDates(Housenumber);
                    end
                else
                    DefineDates(gui.ListBox.String{gui.ListBox.Value});
                end
        end
    end
%--------------------------------------------------------------------------%
%% Function on changing the Starting and Ending Date values
    function DefineDates(Housenumber)
        
        if data.DvptMode == 1       % Go on development mode!
            
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
%% MapSearch
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
%--------------------------------------------------------------------------%
%% WeatherSel
    function WeatherSel(src,~)
        switch src.String{src.Value}
            case 'Default weather' 
                gui.FileAdditionPanel.Selection = 1 ;
                data.WeatherSelection = 'Default' ;
            case 'Load EPW file' 
                gui.FileAdditionPanel.Selection = 2 ;
                data.WeatherSelection = 'EPW' ;
            case 'Load Individual files'
                gui.FileAdditionPanel.Selection = 3 ;
                data.WeatherSelection = 'Individual' ;
        end
        
    end %WeatherSel
%--------------------------------------------------------------------------%
%% WeatherSelection
    function WeatherSelection(src,~)
        
    end %WeatherSelection
%--------------------------------------------------------------------------%
%% ModificationWeatherSel
    function ModificationWeatherSel(src,~)
        
    end %ModificationWeatherSel
%--------------------------------------------------------------------------%
%% Time_Step
    function Time_StepDef(src,~)
        data.datastructure.Time_Step.Defaultcreate = gui.ListTimeStep.String{gui.ListTimeStep.Value} ;
        if ~isempty(gui.ListBox.String) 
            for i = 1:numel(gui.ListBox.String)
                Housename = gui.ListBox.String{i} ;
                data.SummaryStructure.(Housename).Time_Step = gui.ListTimeStep.String{gui.ListTimeStep.Value} ;
            end
        end
    end
%
%% Run Statistics BackEnd
    function RunStatistics(src,~)
        BackEnd_SB;
    end
%% Modify the hourly distribution of appliances
    function HourDistri_Callback(src,~)
        for i = 1:24
            HourName{i}    = ['Hour' num2str(i)] ;       
        end
        switch src.Tag
            case 'VarCloseDistri'
                if strcmp(gui.VarGraphDistri.String,'Update*')
                    profileupdate('Update') ;
                    gui.VarGraphDistri.String = 'Update' ;
                end

                gui.ViewPanel1.Selection = 2 ; 
            case 'VarGraphDistri'
                % This is the update button
                % do something here
                ProceedUpdate = questdlg('This will update the distribution file using the profile chosen for this house. It will update all the appliances profile. Would you like to continue?', ...
                            'Create Distribution file', ...
                            'Yes','Cancel','Cancel') ;
                switch ProceedUpdate
                    case 'Yes'
                        profileupdate('Update') ;
                    case 'Cancel'
                        
                end                               
                
                % At the end, return to the map layer
            case 'VarResetDistri'
                % When click, open a new window to confirm and then reset
                % all values to the original one.
                AppName         = gui.VarListDistri.String{gui.VarListDistri.Value} ;
                resetdistrib(AppName) ;
                
                ArrayOut                = edit2array(gui) ; 
                GraphAppDistri(ArrayOut) ;
            case 'VarListDistri'
                % When change of the appliance, gather information and
                % retrieve them in the edit boxes as well as in the default
                % boxes
                AppName         = gui.VarListDistri.String{gui.VarListDistri.Value} ;
                AppShortName    = data.AppliancesList{...
                                    find(strcmp(AppName,data.AppliancesList(:,1))==1),...
                                    3};
                gui.ListBox.Value           = gui.ListBox.Value(1) ;
                HouseSelected               = gui.ListBox.String{gui.ListBox.Value} ;
                gui.VarPorjectDistri.String = fieldnames(data.AppProfile.(AppShortName)) ;
                gui.VarPorjectDistri.Value  = 1 ;
                try 
                    ArrayOut = data.userdefined.(AppShortName).(HouseSelected).appdistri ;
                catch
                    % There is no user-defined distribution
                    DataBaseApp = gui.VarPorjectDistri.String{gui.VarPorjectDistri.Value} ;
                    ArrayOut = data.AppProfile.(AppShortName).(DataBaseApp) ;
                    ArrayOut = ceil(ArrayOut * data.Detail_Appliance.(AppShortName).Power(1) * 1000) ;
                    ArrayOut = insertrows(ArrayOut,0,0) ;
                end
                
                array2edit(ArrayOut)        ;
                GraphAppDistri(ArrayOut)    ;
            case HourName
                % If this is one of the editable hour, regraph the
                % distribution graph with the new value
                ArrayOut                = edit2array(gui) ; 
                
                AppName         = gui.VarListDistri.String{gui.VarListDistri.Value} ;
                AppShortName    = data.AppliancesList{...
                                    find(strcmp(AppName,data.AppliancesList(:,1))==1),...
                                    3};
                HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
                
                gui.VarGraphDistri.String = 'Update*' ;
                
                for i = 1:numel(HouseSelected)
                    HouseTag    =  HouseSelected{i} ;
                    data.userdefined.(AppShortName).(HouseTag).appdistri = ArrayOut ;
                end
                
                GraphAppDistri(ArrayOut) ;
            case 'VarImportDistri'
                [file,path,~] = uigetfile({'*.xlsx';'*.csv';'*.xls'},...
                                          'File Selector') ;
                                      
                     
                if ~isempty(file)
                    [folder, baseFileNameNoExt, extension] = fileparts([path file]);
                % Create a new field for the type of database we can use 
                    % Name after the file name
                    Databasename = regexprep(baseFileNameNoExt, ' ', '_'); 
                    data.DatabaseApp{end + 1} = Databasename ;
                    % Add it to the gui popup list
                    gui.VarPorjectDistri.String = data.DatabaseApp{:} ;
                % Import each appliance 
                       InputProfile	= RemodeceDistriv2([path file])  ;
                       AppProfile   = reclassProfile(InputProfile, Databasename) ; 
                       
                       AllAppImport = fieldnames(AppProfile) ;
                       for i = 1:length(AllAppImport)
                        % Check if the appliance already exist in the data.AppProfile.(AppName)
                            if any(strcmp(AllAppImport{i},fieldnames(data.AppProfile)))
                                % If it exist, just add the profile to the list
                                data.AppProfile.(AllAppImport{i}).(Databasename) = AppProfile.(AllAppImport{i}).(Databasename) ;
                            else
                                % If it does not exist, add the appliance
                                % to the list
                                SetUpAppliance(AllAppImport{i}) ;
                                % Create a new profile of appliance to be
                                % added to the data.AppliancesList
                                if ~isvalid(gui.SetUpAppliance)
                                    try
                                        s = data.SetUpAppliance ;
                                    catch
                                        return ;
                                    end
                                    if ~strcmp(s,'Add')
                                        return;
                                    end
                                end
                                data.AppProfile.(AllAppImport{i}).(Databasename) = AppProfile.(AllAppImport{i}).(Databasename) ;
                            end
                       end
                       % Reset the Applist for the distribution
                       gui.VarListDistri.String = data.AppliancesList(:,1) ;
                end
            case 'VarPorjectDistri'
                AppName         = gui.VarListDistri.String{gui.VarListDistri.Value} ;
                AppShortName    = data.AppliancesList{...
                                    find(strcmp(AppName,data.AppliancesList(:,1))==1),...
                                    3};
                HouseSelected   = gui.ListBox.String{gui.ListBox.Value} ;
                try 
                    ArrayOut = data.userdefined.(AppShortName).(HouseSelected).appdistri ;
                catch
                    % There is no user-defined distribution
                    DataBaseApp = gui.VarPorjectDistri.String{gui.VarPorjectDistri.Value} ;
                    ArrayOut = data.AppProfile.(AppShortName).(DataBaseApp) ;
                    ArrayOut = ceil(ArrayOut * data.Detail_Appliance.(AppShortName).Power(1) * 1000) ;
                    ArrayOut = insertrows(ArrayOut,0,0) ;
                end                
                array2edit(ArrayOut)        ;
                GraphAppDistri(ArrayOut)    ;
            case 'VarSaveDistri'
                % Get the source folder to save it into the ini file.
                [filepath,~,~] = fileparts(which('FrontEnd_SB.m')) ;
                filepathini = [erase(filepath,'GUI') 'ini' filesep] ;
                if ~exist(filepathini, 'dir')
                   mkdir(filepathini) ;
                end
                
                try
                    fn = data.savedininame ;
                catch
                    fn = [filepathini 'user'];
                    data.savedininame = fn   ;
                end
                
                % Save the appliances to be reloaded in the next time that
                % we open the window in case it exists
                % The file should contain all the appliance specifications
                % as well as the source of the project. Everything will be
                % saved as an xml file as it is easier to retrieve.
                
                structuredata = data.AppliancesList(:,3) ;
                for i = 1:length(structuredata)
                    if ~isempty(structuredata{i})
                        s.ApplianceSpec.(structuredata{i}).LongName = data.datastructure.(structuredata{i}).LongName ;
                        s.ApplianceSpec.(structuredata{i}).ShortName = data.datastructure.(structuredata{i}).ShortName ;
                        s.ApplianceSpec.(structuredata{i}).Tooltip = data.datastructure.(structuredata{i}).Tooltip ;
                        Project = fieldnames(data.AppProfile.(structuredata{i})) ;
                        for ij = 1:length(Project)
                            ProjectName = Project{ij} ;
                            s.ApplianceSpec.(structuredata{i}).AppProfile.(ProjectName) = data.AppProfile.(structuredata{i}).(ProjectName)  ;
                        end
                        s.ApplianceSpec.(structuredata{i}).Defaultvalue     = data.datastructure.(structuredata{i}).Defaultvalue ;
                        s.ApplianceSpec.(structuredata{i}).Unit             = data.datastructure.(structuredata{i}).Unit ;
                        s.ApplianceSpec.(structuredata{i}).Comparefield     = data.datastructure.(structuredata{i}).Comparefield ;
                        s.ApplianceSpec.(structuredata{i}).Defaultcreate    = data.datastructure.(structuredata{i}).Defaultcreate ;
                        s.ApplianceSpec.(structuredata{i}).Type             = data.datastructure.(structuredata{i}).Type ;
                        s.ApplianceSpec.(structuredata{i}).LowLimit         = data.datastructure.(structuredata{i}).LowLimit ;
                        s.ApplianceSpec.(structuredata{i}).HighLimit        = data.datastructure.(structuredata{i}).HighLimit ;
                        s.ApplianceSpec.(structuredata{i}).Exception        = data.datastructure.(structuredata{i}).Exception ;
                        s.ApplianceSpec.(structuredata{i}).ClassName        = data.AppliancesList{i,4} ;
                        s.ApplianceSpec.(structuredata{i}).Rate             = data.AppliancesList{i,2} ;
                        s.ApplianceSpec.(structuredata{i}).MaxUse           = data.Detail_Appliance.(structuredata{i}).MaxUse ;
                        s.ApplianceSpec.(structuredata{i}).Temp             = data.Detail_Appliance.(structuredata{i}).Temp ;
                        s.ApplianceSpec.(structuredata{i}).TimeUsage        = data.Detail_Appliance.(structuredata{i}).TimeUsage ;
                        s.ApplianceSpec.(structuredata{i}).Weekdistr        = data.Detail_Appliance.(structuredata{i}).Weekdistr ;
                        s.ApplianceSpec.(structuredata{i}).Weekdayweight    = data.Detail_Appliance.(structuredata{i}).Weekdayweight ;
                        s.ApplianceSpec.(structuredata{i}).Weekdayacc       = data.Detail_Appliance.(structuredata{i}).Weekdayacc ;
                        s.ApplianceSpec.(structuredata{i}).Delay            = data.Detail_Appliance.(structuredata{i}).Delay ;
                        s.ApplianceSpec.(structuredata{i}).Power            = data.Detail_Appliance.(structuredata{i}).Power ;
                        ApplianceMaxRow                                     = find(strcmp(data.ApplianceMax(:,1),data.AppliancesList{i,1})==1) ;
                        s.ApplianceSpec.(structuredata{i}).ApplianceMax     = cell2mat(data.ApplianceMax(ApplianceMaxRow,2:end))' ;
                        ClassName = s.ApplianceSpec.(structuredata{i}).ClassName ;
                        if ~isempty(ClassName)
                            s.ApplianceSpec.(ClassName).LongName         = data.datastructure.(ClassName).LongName ;
                            s.ApplianceSpec.(ClassName).ShortName        = data.datastructure.(ClassName).ShortName ;
                            s.ApplianceSpec.(ClassName).Tooltip          = data.datastructure.(ClassName).Tooltip ;
                            s.ApplianceSpec.(ClassName).Defaultvalue     = data.datastructure.(ClassName).Defaultvalue ;
                            s.ApplianceSpec.(ClassName).Unit             = data.datastructure.(ClassName).Unit ;
                            s.ApplianceSpec.(ClassName).Comparefield     = cell2mat(data.datastructure.(ClassName).Comparefield{1}) ;
                            s.ApplianceSpec.(ClassName).Defaultcreate    = data.datastructure.(ClassName).Defaultcreate ;
                            s.ApplianceSpec.(ClassName).Type             = data.datastructure.(ClassName).Type ;
                            s.ApplianceSpec.(ClassName).LowLimit         = data.datastructure.(ClassName).LowLimit ;
                            s.ApplianceSpec.(ClassName).HighLimit        = data.datastructure.(ClassName).HighLimit ;
                            s.ApplianceSpec.(ClassName).Exception        = cell2mat(data.datastructure.(ClassName).Exception) ;
                        end
                    end
                end
                struct2xml(s,fn) ;
                msgbox(['File saved in ' filepathini])
            otherwise 
                msgbox('Not yet implemented')
        end
    end
%% Gather the edit box into 1 array
    function ArrayOut = edit2array(gui)
        ArrayOut = zeros(25,1) ;
        for i = 0:24
           HourName    = ['Hour' num2str(i)]   ;
           ArrayOut(i + 1)    = str2double(gui.(HourName).String) ;
        end
    end
%% Repopulate the data to the edit box
    function array2edit(Arrayout)
        for i = 0:24
           HourName    = ['Hour' num2str(i)]   ;
           gui.(HourName).String = num2str(Arrayout(i + 1)) ;
        end
    end
%% Graph the appliance distribution
    function GraphAppDistri(RawArray)
        AppName         = gui.VarListDistri.String{gui.VarListDistri.Value} ;
        AppShortName    = data.AppliancesList{...
                            find(strcmp(AppName,data.AppliancesList(:,1))==1),...
                            3};
        if isa(gui.VarPorjectDistri.String, 'char')
            DataBaseApp = gui.VarPorjectDistri.String ;
        else
            DataBaseApp = gui.VarPorjectDistri.String{gui.VarPorjectDistri.Value} ;  
        end
        legendlist = {} ;
        DataBaseApp = regexprep(DataBaseApp, '_', ' ');
        
        yyaxis(gui.Figuredistri,'left')
        plot(RawArray,'Parent',gui.Figuredistri) ;
        legendlist{end + 1} = 'Normal distribution' ;
        
        ylabel(gui.Figuredistri,'Power consumption profile [Wh/h]') 
                
        gui.ListBox.Value   = gui.ListBox.Value(1) ;
        HouseTag       = gui.ListBox.String{gui.ListBox.Value} ;
        
        try
            ApplianceLD = data.ProfileUserdistri.(HouseTag)  ;
        catch
            ApplianceLD = [] ;
        end
        for i = 1:length(data.DatabaseApp)
            DataBaseApp = regexprep(data.DatabaseApp{i}, '_', ' ');
            try
                if ~isempty(ApplianceLD)
                    % If not empty, draw the other variables as well
                    Stat4Use_Profileextract(:,i) = ApplianceDistri(ApplianceLD, AppShortName, data.DatabaseApp{i}) ;
                else
                    Stat4Use_Profileextract(:,i) = zeros(25,1) ;
                end
                legendlist{end + 1} = [DataBaseApp ' Distribution'] ;
            catch
                continue;
            end
        end
        yyaxis(gui.Figuredistri,'right')
        ArrayOutCumSum = cumsum(RawArray/sum(RawArray)) ;
        legendlist{end + 1} = 'cumulative sum Normal distribution' ;
        h = plot(0:24,Stat4Use_Profileextract,0:24,ArrayOutCumSum, 'Parent',gui.Figuredistri) ;
        ylabel(gui.Figuredistri,'Distribution used [%]') 
        PreviousPos = get(gui.Figuredistri,'Position') ;
%         legend('off')
        legend(gui.Figuredistri,legendlist,'Location','northwest') ;
        set(gui.Figuredistri,'Position',PreviousPos) ;
    end
%% Reset the appliance to its original distribution 
    function resetdistrib(AppName)
        AppShortName    = data.AppliancesList{...
                                    find(strcmp(AppName,data.AppliancesList(:,1))==1),...
                                    3};
        DataBaseApp = gui.VarPorjectDistri.String{gui.VarPorjectDistri.Value} ;                        
        Profile = data.AppProfile.(AppShortName).(DataBaseApp) ;
        Profile = ceil(Profile * data.Detail_Appliance.(AppShortName).Power(1) * 1000) ;
        for i = 1:24
           HourName                 = ['Hour' num2str(i)]   ;
           gui.(HourName).String    = Profile(i) ; 
        end
        data.userdefined = fRMField(data.userdefined, AppShortName) ;
    end
%% Get the global distribution for all year round
    function Stat4Use_Profileextract = ApplianceDistri(Stat4Use_Profile1, Appliance, databasename)
        icol = 1 ;
        for ij = 1:12
            for ik = 1:3
                Stat4Use_Month(:,icol) = Stat4Use_Profile1(ij,ik).(Appliance).(databasename) ;
                icol = icol + 1 ;
            end
        end
        Stat4Use_Profileextract = mean(Stat4Use_Month,2) ;
    end
%% Update the profile
    function profileupdate(trigger)
        AppList = data.AppliancesList(:,3) ;
        
        switch trigger
            case {'Update', 'Load', 'Update Sim'}
                HouseSelected = gui.ListBox.String ;
            case 'Change List'
                HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
            otherwise
                HouseSelected = gui.ListBox.String(gui.ListBox.Value) ;
        end
        
        
        for i = 1:numel(HouseSelected)
            HouseTag    =  HouseSelected{i} ;
            for ik = 1:(length(AppList))
                AppName = AppList{ik} ;
                for im = 1:length(data.DatabaseApp)
                    DatabaseName = data.DatabaseApp{im} ;
                    try 
                        ArrayOut = data.userdefined.(AppName).(HouseTag).appdistri ;
                    catch
                        try 
                            ArrayOut = data.AppProfile.(AppName).(DatabaseName) ;
                            ArrayOut = ceil(ArrayOut * data.Detail_Appliance.(AppName).Power(1) * 1000) ;
                        catch
                            continue ;
                        end
                    end
                    if length(ArrayOut) == 25
                        ArrayOut = ArrayOut(2:end) ;
                    end
                    ArrayOutCumSum.(AppName).(DatabaseName) = cumsum(ArrayOut/sum(ArrayOut)) ;
                end
            end

            inhabitant  = str2double(data.SummaryStructure.(HouseTag).inhabitants) ;
            [ApplianceLD, ~] = Profile_Distribution(inhabitant,ArrayOutCumSum, data.Detail_Appliance, data.AppProfile, data.DatabaseApp) ;
            data.ProfileUserdistri.(HouseTag) = ApplianceLD ;
        end
        switch trigger
            case {'Update'}
                msgbox('The distribution file has been updated to match the Finnish decree','Appliances dDistribution') ;
            otherwise
        end
        
        gui.VarGraphDistri.String = 'Update' ;
    end
%% Setup a new appliance, this will require to fill many fields but some can be put as default values as well
    function SetUpAppliance(AppName)
        % Create a new window that will ask
        Mfigpos = get(gui.Window,'OuterPosition') ;
        gui.SetUpAppliance = figure('units','pixels',...
                                         'position',[Mfigpos(1)+Mfigpos(3)/2,...
                                                     Mfigpos(2)+Mfigpos(4)/2,...
                                                     700,...
                                                     250],...
                                         'toolbar','none',...
                                         'menu','none',....
                                         'name',['Setup new appliance: ' AppName],....
                                         'NumberTitle','off',...
                                         'Tag','SetUpAppliance') ;
                                     
%         set(gui.SetUpAppliance,'WindowStyle','modal')
        gui.DivideCar = uix.VBox('Parent', gui.SetUpAppliance) ;
        gui.MainFrameCard = uix.CardPanel('Parent',gui.DivideCar) ;
            MainFrame1 = uix.VBoxFlex('Parent', gui.MainFrameCard) ;
        
        % Add a text box on the top to explain the different things to do.    
            Text2Add = '';
%1            
            uicontrol('Parent', MainFrame1, ...
                      'Style','text',...
                      'String',Text2Add) ;
              % to input
              % Use 5 tables to define each of the input, it will be easier and more readable for the user 
              % data.Detail_Appliance.(AppName).(...)
                  %%% Table 1      
                  cnames = {'Maximum number of use [/week]', 'Maximum number of appliances (use for automatic generation)'} ;
                        
                  rnames = {'1 inhabitant','2 inhabitants','3 inhabitants','4 inhabitants','5 inhabitants','6 inhabitants'};
                  d      = {1 , 1  ;...
                            1 , 1 ;...
                            1 , 1 ;...
                            1 , 1 ;...
                            1 , 1 ;...
                            1 , 1 };
%2                        
                 gui.uit_Detail_Appliance = uitable('Parent', MainFrame1, ...
                                               'RowName',rnames,...
                                               'ColumnName',cnames,...
                                               'Data', d,...
                                                   'ColumnEditable',true);
                                               
                gui.uit_Detail_Appliance.Position(3) = gui.SetUpAppliance.Position(3) ;
                
        % Add a text box on the top to explain the different things to do.    
            Text2Add = '';
%3            
            MainFrame2 = uix.VBoxFlex('Parent', gui.MainFrameCard) ;
            uicontrol('Parent', MainFrame2, ...
                      'Style','text',...
                      'String',Text2Add) ;
                                           
                %%% Table 2
                    % Add a button to add one more field in the table and
                    % add a delele button for the selected row. 
                    % regexprep('Option 1', 'Option', '')
                    
                cnames = {'Name of the programme',...
                          'Maximum number of use',...
                          'Time usage [h]'} ;
                        
                rnames = {'Option 1'};
                
                d      = {'Programme 1' , 1, 1 };
%4                
                gui.uit_Time_Programme = uitable('Parent', MainFrame2, ...
                                               'RowName',rnames,...
                                               'ColumnName',cnames,...
                                               'Data', d,...
                                               'ColumnEditable',true);
                                               
                gui.uit_Time_Programme.Position(3) = gui.SetUpAppliance.Position(3) ;                               
                %%% Table 3
                % This includes the different weekdays
        % Add a text box on the top to explain the different things to do.    
            Text2Add = '';
%5            
            MainFrame3 = uix.VBoxFlex('Parent', gui.MainFrameCard) ;
            uicontrol('Parent', MainFrame3, ...
                      'Style','text',...
                      'String',Text2Add) ;                
                cnames = {'Weekly distribution',...
                          'Weight of the weekdays over the weekend',...
                          'Weekday Acceptance'} ;
                
                [~,S] = myweekday(4:10,'long') ;
                rnames = cellstr(S)' ;
                
                d      = {1/7 , 5/7, .5  ;...
                          1/7 , 5/7, .5 ;...
                          1/7 , 5/7, .5 ;...
                          1/7 , 5/7, .5 ;...
                          1/7 , 5/7, .5 ;...
                          1/7 , 5/7, .5 ;...
                          1/7 , 5/7, .5 };
%6                     
                gui.uit_Week_Distribution = uitable('Parent', MainFrame3, ...
                                               'RowName',rnames,...
                                               'ColumnName',cnames,...
                                               'Data', d,...
                                                   'ColumnEditable',true);
                gui.uit_Week_Distribution.Position(3) = gui.SetUpAppliance.Position(3) ;    
                
                %%% Table 4 Delay options
            % Add a text box on the top to explain the different things to do.    
            Text2Add = '';
%7            
            MainFrame4 = uix.VBoxFlex('Parent', gui.MainFrameCard) ;
            uicontrol('Parent', MainFrame4, ...
                      'Style','text',...
                      'String',Text2Add) ;                

                    cnames = {'Delay Option, boolean'} ;

                    rnames = {'Long Delay',...
                              'Short Delay',...
                              'Reduce Time'} ;

                    d      = {0;...
                              0;...
                              0 };
%8
                    gui.uit_Delay = uitable('Parent', MainFrame4, ...
                                                   'RowName',rnames,...
                                                   'ColumnName',cnames,...
                                                   'Data', d,...
                                                   'ColumnEditable',true);
                                               
                    gui.uit_Delay.Position(3) = gui.SetUpAppliance.Position(3) ;  
                                                             
                %%% Table 5 Power option
            % Add a text box on the top to explain the different things to do.    
            Text2Add = '';
%9            
            MainFrame5 = uix.VBoxFlex('Parent', gui.MainFrameCard) ;
            uicontrol('Parent', MainFrame5, ...
                      'Style','text',...
                      'String',Text2Add) ;
                    cnames = {'Power Input [kW]'} ;

                    rnames = {'A or B',...
                              'C or D',...
                              'E or F',...
                              'Stand-by',...
                              'Off-mode'} ;

                    d      = {0.2   ;...
                              0.5   ;...
                              0.7   ;...
                              0     ;...
                              0     };
%10
                    gui.uit_Demand_Response = uitable('Parent', MainFrame5, ...
                                                   'RowName',rnames,...
                                                   'ColumnName',cnames,...
                                                   'Data', d,...
                                                   'ColumnEditable',true);
                
                    gui.uit_Demand_Response.Position(3) = gui.SetUpAppliance.Position(3) ;  
              % Set up the VarName of the
              % appliance, this is another
              % table to be edited
            % Add a text box on the top to explain the different things to do.    
            Text2Add = '';
%11            
            MainFrame6 = uix.VBoxFlex('Parent', gui.MainFrameCard) ;
            uicontrol('Parent', MainFrame6, ...
                      'Style','text',...
                      'String',Text2Add) ;
                    cnames = {'Appliance to add'} ;

                    rnames = {'Short Name',...
                              'Long Name',...
                              'Unit',...
                              'Defaultvalue',...
                              'Tooltip',...
                              'Compare field',...
                              'Default create',...
                              'Variable Type',...
                              'Low Limit',...
                              'High Limit',...
                              'Exception'} ;

                    d      = {AppName   ;...
                              AppName   ;...
                              '[-]'   ;...
                              '0'     ;...
                              'Write some tips that you would like to appear'     ;...
                              'Compare'  ;...
                              0;...
                              'double';...
                              0;...
                              Inf;...
                              -1};
%12
                    gui.uit_App_names = uitable( 'Parent', MainFrame6, ...
                                                       'RowName',rnames,...
                                                       'ColumnName',cnames,...
                                                       'Data', d,...
                                                   'ColumnEditable',true);
                
                    gui.uit_App_names.Position(3) = gui.SetUpAppliance.Position(3) ;  
             

%13            
             % Add buttons cancel and input
             lastrow = uix.HBox('Parent', gui.DivideCar) ;
             uix.Empty('Parent', lastrow) ;
             uicontrol('Parent', lastrow,...
                       'Style','pushbutton',...
                       'String','<- Previous',...
                       'Tag','Previous',...
                       'Visible','off',...
                       'CallBack',@AddAppliance) ;
             uix.Empty('Parent', lastrow) ;      
             uicontrol('Parent', lastrow,...
                       'Style','pushbutton',...
                       'String','Cancel',...
                       'Tag','Cancel',...
                       'CallBack',@AddAppliance) ;
             uix.Empty('Parent', lastrow) ;      
             uicontrol('Parent', lastrow,...
                       'Style','pushbutton',...
                       'String','Next ->',...
                       'Tag','Next',...
                       'CallBack',@AddAppliance) ;
             uix.Empty('Parent', lastrow) ;
             
            set(MainFrame1,'Heights',[19 -1]);       
            set(MainFrame2,'Heights',[19 -1]); 
            set(MainFrame3,'Heights',[19 -1]); 
            set(MainFrame4,'Heights',[19 -1]); 
            set(MainFrame5,'Heights',[19 -1]); 
            set(MainFrame6,'Heights',[19 -1]); 
            set(gui.DivideCar,'Heights',[-1 19]);
            
            gui.MainFrameCard.Selection = 1  ;       
                   
            waitfor(gui.SetUpAppliance) ;
                   
              % data.AppliancesList
                % 'LongName' 'ShortName' clDishWash.ShortName
    end
%% Add appliance return function 
    function AddAppliance(src,~)
        switch src.Tag
            case 'Cancel'
                data.SetUpAppliance = 'Cancel' ;
                close(gui.SetUpAppliance) ; 
            case 'Next'
            % data.AppliancesList
                gui.MainFrameCard.Selection = gui.MainFrameCard.Selection + 1 ; 
                if gui.MainFrameCard.Selection == size(gui.MainFrameCard.Contents,1)
                    src.Tag     = 'Add' ;
                    src.String  = 'Add' ;
                end
                h = findobj('Tag','Previous') ;
                h.Visible = 'on' ;
                h.Enable  = 'on' ;
            % data.varname
            case 'Previous'
                if gui.MainFrameCard.Selection == size(gui.MainFrameCard.Contents,1)
                    h         = findobj('Tag','Add') ;
                    h.Tag     = 'Next' ;
                    h.String  = 'Next' ; 
                end
                
                gui.MainFrameCard.Selection = gui.MainFrameCard.Selection - 1 ; 
                
                if gui.MainFrameCard.Selection == 1
                    src.Visible     = 'off' ;
                    src.Enable      = 'off' ;
                end
            case 'Add'
                % Parse the data
                ShortName = gui.uit_App_names.Data{1} ;
                % uit_Detail_Appliance
                % MaxUse    Temp    TimeUsage    Weekdistr    Weekdayweight    Weekdayacc    Delay    Power
                MaxUse          = gui.uit_Detail_Appliance.Data(:,1)    ;
                MaxUse(end+1)   = MaxUse(end)                           ;
                if size(gui.uit_Time_Programme.Data(:,2),1) < size(MaxUse,1)
                    InputRow = size(gui.uit_Time_Programme.Data(:,2),1) ;
                    gui.uit_Time_Programme.Data(InputRow+1:7,2) = {0}      ;
                    gui.uit_Time_Programme.Data(InputRow+1:7,3) = {0}      ;
                end
                Temp            = gui.uit_Time_Programme.Data(:,2)      ;
                TimeUsage       = gui.uit_Time_Programme.Data(:,3)      ;
                Weekdistr       = gui.uit_Week_Distribution.Data(:,1)   ;
                Weekdayweight   = gui.uit_Week_Distribution.Data(:,2)   ;
                Weekdayacc      = gui.uit_Week_Distribution.Data(:,3)   ;
                Delay           = gui.uit_Delay.Data(:,1)               ;
                Delay(4:7)      = {0}                                   ;
                Power           = gui.uit_Demand_Response.Data(:,1)     ;
                Power(6:7)      = {0}                                   ;
                C = [MaxUse   Temp     TimeUsage    Weekdistr     Weekdayweight    Weekdayacc     Delay     Power];
                data.Detail_Appliance.(ShortName) = cell2table(C,'VariableNames',{'MaxUse'    'Temp'    'TimeUsage'   'Weekdistr'    'Weekdayweight'    'Weekdayacc'    'Delay'    'Power'}) ;
                data.ApplianceMax(end+1,:) = [gui.uit_App_names.Data{2} gui.uit_Detail_Appliance.Data(:,2)'] ;
                
                % Save the variable and its data datastructure
                AllFields = fieldnames(data.varname.WashMach) ;
                for i = 1:length(AllFields)
                    data.varname.(ShortName).(AllFields{i}) = gui.uit_App_names.Data{i} ;
                    data.datastructure.(ShortName).(AllFields{i}) = gui.uit_App_names.Data{i} ;
                end
                ClassName = ['cl' ShortName] ;
                data.varname.(ClassName).ShortName      = ClassName ;
                data.datastructure.(ClassName).ShortName      = ClassName ;
                data.varname.(ClassName).LongName       = [data.varname.(ShortName).LongName ' Class'] ;
                data.datastructure.(ClassName).LongName       = [data.varname.(ShortName).LongName ' Class'] ;
                data.varname.(ClassName).Unit           = '[]' ;
                data.datastructure.(ClassName).Unit           = '[]' ;
                data.varname.(ClassName).Defaultvalue   = 'A or B class' ;
                data.datastructure.(ClassName).Defaultvalue   = 'A or B class' ;
                
                Text = ['In case there would be a ' ShortName ', the class of the ' ShortName ' has to be selected.'...
                        ' The classes follow the labels given by the Energy-using Product directive of the EU. Classes have been divided'...
                        ' into three categories in order to simplify the choice. A or B class, C or D class, E or F class'] ;
                
                data.varname.(ClassName).Tooltip        = Text      ;
                data.datastructure.(ClassName).Tooltip        = Text      ;
                data.varname.(ClassName).Comparefield   = {{'A or B class';'C or D class';'E or F class';'Self-defined'} {'A or B class';'C or D class';'E or F class';'Self-defined'}} ;
                data.datastructure.(ClassName).Comparefield   = {{'A or B class';'C or D class';'E or F class';'Self-defined'} {'A or B class';'C or D class';'E or F class';'Self-defined'}} ;
                data.varname.(ClassName).Defaultcreate  = 'A or B class';
                data.datastructure.(ClassName).Defaultcreate  = 'A or B class';
                data.varname.(ClassName).Type           = 'cell' ;
                data.datastructure.(ClassName).Type           = 'cell' ;
                data.varname.(ClassName).LowLimit       = '' ;
                data.datastructure.(ClassName).LowLimit       = '' ;
                data.varname.(ClassName).HighLimit      = '' ;
                data.datastructure.(ClassName).HighLimit      = '' ;
                data.varname.(ClassName).Exception      = {'A or B class';'C or D class';'E or F class';'Self-defined'} ;
                data.datastructure.(ClassName).Exception      = {'A or B class';'C or D class';'E or F class';'Self-defined'} ; 
                data.SetUpAppliance = 'Add' ;
                
                data.AppliancesList{end + 1, 1} = data.varname.(ShortName).LongName ;
                data.AppliancesList{end, 2} = 'Rate' ;
                data.AppliancesList{end, 3} = data.varname.(ShortName).ShortName    ;
                data.AppliancesList{end, 4} = ClassName                             ;
                
                HouseList = gui.ListBox.String ;
                for i = 1:length(HouseList)
                    data.SummaryStructure.(HouseList{i}).(ShortName) = {num2str(data.varname.(ShortName).Defaultcreate)} ;
                    data.SummaryStructure.(HouseList{i}).(ClassName) = {data.varname.(ClassName).Defaultcreate}    ;
                end
                % Add the appliance profile where possible 
                
                close(gui.SetUpAppliance) ; 
        end
    end
%% Register variable if they do not exist
    function registervar(Field2Save)
        data.varname.(Field2Save).ShortName      = Field2Save     ;
        data.varname.(Field2Save).LongName       = Field2Save     ;
        data.varname.(Field2Save).Unit           = '[]' ;
        data.varname.(Field2Save).Defaultvalue   = '' ;
        data.varname.(Field2Save).UserDefvalue   = '' ;
        data.varname.(Field2Save).Tooltip        = 'This variable was set automatically' ;
        data.varname.(Field2Save).Comparefield   = 'Compare';
        data.varname.(Field2Save).Defaultcreate  = 'Remodece' ;
        data.varname.(Field2Save).Type           = 'string' ;
        data.varname.(Field2Save).LowLimit       = '' ;
        data.varname.(Field2Save).HighLimit      = '' ;
        data.varname.(Field2Save).Exception      = '' ;
    end
%% Set the appliance rating when changing or adding a new appliance
    function setratingapp(ApplianceRates)
        matchAppliance = find(strcmp(ApplianceRates.Appliance,gui.popupApp.String{gui.popupApp.Value}));                        
        if ~strcmp(gui.popupRate.String(gui.popupRate.Value),'Select...')   
            if isa(gui.popupRate.String,'char')
                CheckValue = gui.popupRate.String ;
            elseif isa(gui.popupRate.String,'cell')
                CheckValue =  gui.popupRate.String{gui.popupRate.Value} ;
            end
            switch CheckValue
                case 'A or B class'
                    set(gui.ApplianceRate   ,'String',num2str(ApplianceRates.AOrB(matchAppliance)))
                    set(gui.ApplianceSleep  ,'String',num2str(ApplianceRates.StbPower(matchAppliance))) 
                    set(gui.ApplianceStandBy,'String',num2str(ApplianceRates.OffMode(matchAppliance)))
                case 'C or D class'
                    set(gui.ApplianceRate   ,'String',num2str(ApplianceRates.COrD(matchAppliance)))
                    set(gui.ApplianceSleep  ,'String',num2str(ApplianceRates.StbPower(matchAppliance))) 
                    set(gui.ApplianceStandBy,'String',num2str(ApplianceRates.OffMode(matchAppliance)))
                case 'E or F class'
                    set(gui.ApplianceRate   ,'String',num2str(ApplianceRates.EOrF(matchAppliance)))
                    set(gui.ApplianceSleep  ,'String',num2str(ApplianceRates.StbPower(matchAppliance))) 
                    set(gui.ApplianceStandBy,'String',num2str(ApplianceRates.OffMode(matchAppliance)))
                case 'Self-defined'
                    % Nothing to do because it was already
                    % taken care of earlier in the previous
                    % lines of the code
                case '-'
                    set(gui.ApplianceRate   ,'String',num2str(ApplianceRates.AOrB(matchAppliance)))
                    set(gui.ApplianceSleep  ,'String',num2str(ApplianceRates.StbPower(matchAppliance))) 
                    set(gui.ApplianceStandBy,'String',num2str(ApplianceRates.OffMode(matchAppliance)))
                otherwise
                    % This is an unknown format and
                    % cannot be reported here
                    set(gui.ApplianceRate   ,'String','0', 'Enable', 'off')
                    set(gui.ApplianceSleep  ,'String','0', 'Enable', 'off') 
                    set(gui.ApplianceStandBy,'String','0', 'Enable', 'off')
            end                                                                          
        else                                        
            set(gui.ApplianceRate,'String','0')
            set(gui.ApplianceSleep,'String','0')
            set(gui.ApplianceStandBy,'String','0')                                        
        end 
    end
%% Create figure to input the appliances or change them 
    function AddModAppliances(varargin)
        if nargin > 0
            selectedAppliance   = varargin{1} ;
            selectedRank        = varargin{2};
            selectedQuantity    = varargin{3};
            selectedDB          = varargin{4};
            AppCodeLine = find(strcmp(data.AppliancesList(:,1),selectedAppliance) == 1) ;
            AppCodeVal  = data.AppliancesList{AppCodeLine,3} ;
        end
        
        Mfigpos = get(gui.Window,'OuterPosition') ;
        buttonwidth = 250 ;
        buttonheight = 2 * 150; %12/5 * 150; %150 ;
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
%          set(gui.AddAppDialog,'WindowStyle','modal')
         %
         %movegui(gui.AddDialog,'center')
         set(gui.AddAppDialog, 'Resize', 'off');

         gui.DivideVert = uix.VBox('Parent',gui.AddAppDialog) ;

         AppList = data.AppliancesList(:,1);
        
         n = 1 ;
         ToInsert = 'Select appliance...';
         AppList(n+1:end+1,:) = AppList(n:end,:);
         AppList(n,:) = {ToInsert};
         AppList = orderalphacellarray(AppList,2,numel(AppList));

         DbList = data.DatabaseApp' ;
         ToInsert = 'Select database...';
         DbList(n+1:end+1,:) = DbList(n:end,:);
         DbList(n,:) = {ToInsert};
         DbList = orderalphacellarray(DbList,2,numel(DbList));

         gui.popupApp = uicontrol('Parent',gui.DivideVert,...
                   'Style','popup',...
                   'String', AppList,...
                   'Tag','popupApp',...
                   'Callback',@AddApplianceCall) ;
         if nargin > 0
             set(gui.popupApp, 'Value', find(strcmp(AppList,selectedAppliance)==1));
             set(gui.popupApp, 'Enable', 'off');
         end
         gui.popupDB = uicontrol('Parent',gui.DivideVert,...
                   'Style','popup',...
                   'String', DbList,...
                   'Tag','popupDB',...
                   'Callback',@AddApplianceCall) ;
         if nargin > 0
             set(gui.popupDB, 'Value', find(strcmp(DbList,selectedDB)==1));
             set(gui.popupDB, 'Enable', 'off');
         end
         gui.popupRate = uicontrol('Parent',gui.DivideVert,...
                   'Style','popup',...
                   'Tag','popupRate',...
                   'String','Select...',...
                   'Callback',@AddApplianceCall);
         if nargin > 0
               if strcmp(selectedAppliance,'Lighting System') 
                   set(gui.popupRate, 'String', data.Lightopt(:));
                   OriginalRank = get(gui.popupRate, 'String');
               elseif strcmp(data.AppliancesList((strcmp(data.AppliancesList(:,1),selectedAppliance)==1),2),'Rate')
                   set(gui.popupRate, 'String', data.Rating(:));
                   OriginalRank = get(gui.popupRate, 'String');
               else
                   set(gui.popupRate, 'String', {'Select...', '-','Self-defined'});
                   OriginalRank = get(gui.popupRate, 'String');
               end

               if any(strcmp(OriginalRank(:),selectedRank)==1)
                   set(gui.popupRate, 'Value', find(strcmp(OriginalRank,selectedRank)==1));
               end
         end
         gui.popupQty = uicontrol('Parent',gui.DivideVert,...
                   'Style','popup',...
                   'Tag','popupQty',...
                   'String',{'1' '2' '3' '4' '5' 'more...' '0'},...
                   'Callback',@AddApplianceCall);
        if nargin > 0
            originalarray = {'1' '2' '3' '4' '5' 'more...' '0'} ;
            if isa(selectedQuantity{1},'double')
                selectedQuantity = num2str(selectedQuantity{1}) ;
            end
            if ismember(originalarray,selectedQuantity)
                Value = find(ismember(originalarray,selectedQuantity)==1) ;
                set(gui.popupQty,'Value',Value) ;
            else
                AppList = gui.popupQty.String ;
                n = length(gui.popupQty) ;
                ToInsert = selectedQuantity ;
                PositionApp = find(strcmp(AppList(:), ToInsert), 1) ;
                if isempty(PositionApp)
                    AppList(n+1:end+1,:) = AppList(n:end,:);
                    AppList(n,:) = ToInsert;
                end
                AppListnum = cellfun(@str2num,{AppList{1:(numel(AppList)-1)}},'un',0).' ;
                AppList(1:(numel(AppList)-1)) = AppListnum ;

                AppList(cellfun(@isempty,AppList)) = {'more...'} ;

                AppList = orderalphacellarray(AppList);
                AppList = cellfun(@num2str,AppList ,'un',0) ;
                set(gui.popupQty,'string',AppList) ;
                PositionApp = find(strcmp(AppList, ToInsert)) ;
                set(gui.popupQty,'value',PositionApp)
            end
        end
        gui.ownSelection = uicontrol('Parent',gui.DivideVert,...        %Jari mod starts!
                    'Style','checkbox',...
                    'String','Define the rates yourselves',...
                    'Tag','ownSelection',...
                    'Callback',@AddApplianceCall);
        gui.ApplianceRateText = uicontrol('Parent', gui.DivideVert,...
                    'Style','text',...
                    'Tag', 'ApplianceRateText',...
                    'String','Operational Appliance Power [kW]',...
                    'Visible','on');
        if nargin > 0
            HouseTag = gui.ListBox.String{gui.ListBox.Value(1)} ;
            if strcmp(selectedRank,'Self-defined')
                Power = data.SelfDefinedAppliances.(HouseTag).(AppCodeVal).(selectedDB{1})       ;
                NominalPower    = Power.Rate ;
                Stdby           = Power.StandBy ;
                Offpower        = Power.Sleep ;
            else
                NominalPower    = '0' ;
                Stdby           = '0' ;
                Offpower        = '0' ;
            end
        else
            NominalPower    = '0' ;
            Stdby           = '0' ;
            Offpower        = '0' ;
        end
        gui.ApplianceRate = uicontrol('Parent', gui.DivideVert,...
                    'Style', 'edit',...
                    'String', NominalPower,...
                    'Tag', 'ApplianceRate',...
                    'Callback',@AddApplianceCall,...
                    'Visible','on',...
                    'Enable','off');
        gui.ApplianceSleepText = uicontrol('Parent',gui.DivideVert,...
                    'Style','text',...
                    'String','Stand-By Power [kW]',...
                    'Tag','ApplianceSleepText',...
                    'Visible','on');
        gui.ApplianceSleep = uicontrol('Parent',gui.DivideVert,...
                    'Style','edit',...
                    'Tag','ApplianceSleep',...
                    'String',Stdby,...
                    'Callback',@AddApplianceCall,...
                    'Visible','on',...
                    'Enable','off');
        gui.ApplianceStandByText = uicontrol('Parent',gui.DivideVert,...
                    'Style','text',...
                    'String','Off-Mode power [kW]',...
                    'Tag','ApplianceStandByText',...
                    'Visible','on');
        gui.ApplianceStandBy = uicontrol('Parent',gui.DivideVert,...
                    'Style','edit',...
                    'Tag','ApplianceStandBy',...
                    'String',Offpower,...
                    'Callback',@AddApplianceCall,...
                    'Visible','on',...
                    'Enable','off');                            % Jari Mod ends!
        
         setratingapp(data.ApplianceRates) ;
        
         uix.Empty('Parent',gui.DivideVert) ;

         buttonbox =  uix.HBox('Parent',gui.DivideVert) ; 
         uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Ok','Tag','Ok','Callback',@AddApplianceCall)
         uicontrol('Parent',buttonbox,'Style','pushbutton','String', 'Cancel','Tag','Cancel','Callback',@AddApplianceCall)

         set( gui.DivideVert,'Heights', [-1 -1 -1 -1 -1 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -.5 -1] );         % some mods are here as well


         uiwait(gcf);
         str = uimulticollist( gui.multicolumnApp, 'string' ) ;
         [srow,~] = size(str) ;
         if srow>1
             set(gui.RemoveAppliance,'enable','on')
         end
    end
%% Update the UImulticolllist anytime there is a modification in the appliance list
    function updateuimulticollist(AppName, Rate, Qty, DB)
        %%% UPDATE THE UIMULTICOLLIST     
        % Get the data from the multi column list to compare them
        % with thenew input data
        str = uimulticollist( gui.multicolumnApp, 'string' ) ;
        ArrayApp = strcmp(str(:,2), Rate) .* strcmp(str(:,1), AppName) .* strcmp(str(:,4), DB) ;
        if sum(ArrayApp) >= 1
            % The appliance is already listed, check if the rating
            % is also rated. Create a temporary new array to search
            row2modify  = find(ArrayApp == 1) ;
            if isfield(gui, 'popupApp')
                if strcmp(get(gui.popupApp,'enable'),'off')
                    % This means we do not add up but we
                    % modifiy the quantity of appliances as well as
                    % the rate if necessary
                    if isa(Qty,'cell')
                        Newqty = str2double(Qty) ;
                    elseif isa(Qty,'double')
                        Newqty = Qty ;
                    end
                    Newqty = num2str(Newqty) ;
                    uimulticollist(gui.multicolumnApp, 'changeItem', Newqty, row2modify, 3 )
                else                            
                    % this particular appliance already exist --> add
                    % the quantity selected to this row
                    Originalqty = str(row2modify,3) ;
                    if isa(Qty,'cell')
                        Newqty = str2double(Originalqty) + str2double(Qty) ;    
                    elseif isa(Qty,'double')
                        Newqty = str2double(Originalqty) + Qty ;    
                    end
                    
                    Newqty = num2str(Newqty) ;
                    uimulticollist(gui.multicolumnApp, 'changeItem', Newqty, row2modify, 3 )                            
                end  
            else
                % this particular appliance already exist --> add
                % the quantity selected to this row
                Originalqty = str(row2modify,3) ;
                if isa(Qty,'cell')
                    Newqty = str2double(Originalqty) + str2double(Qty) ;    
                elseif isa(Qty,'double')
                    Newqty = str2double(Originalqty) + Qty ;    
                end  
                Newqty = num2str(Newqty) ;
                uimulticollist(gui.multicolumnApp, 'changeItem', Newqty, row2modify, 3 )  
            end
        else
            rowItems = [AppName, Rate, Qty, DB] ;
            uimulticollist(gui.multicolumnApp, 'addRow', rowItems , 2 )
        end
    end
%% Get the appliance Ref from the summarystructure
    function [Appfound, AppCode] = Getappref(HouseTag, selectedApp, selectedDB, selectedClass)
        %  Loop through each existing appliance and look if
        % this particular appliance has already been
        % defined
        n = 0 ;
        iapp = 1 ;
        AllApp      = fieldnames(data.SummaryStructure.(HouseTag).Appliances) ;
        AllAppData  = data.SummaryStructure.(HouseTag).Appliances ;
        AppCode     = [] ;
        while n == 0
            if isempty(AllApp)
                n = 1 ;
                Appfound = false ;
            else
                AppRef = AllApp{iapp} ;
                if strcmp(AllAppData.(AppRef).SN, selectedApp)
                    if strcmp(AllAppData.(AppRef).DB, selectedDB)
                        if strcmp(AllAppData.(AppRef).Class, selectedClass)
                            Appfound = true ;
                            n = 1 ;
                            % In this case, there is only
                            % the quantity of appliances to
                            % change
                            AppCode = AppRef ;
                        else
                            Appfound = false ;
                        end
                    else
                        Appfound = false ;
                    end
                else
                    Appfound = false ;
                end
                if iapp == length(AllApp)
                    n = 1 ;
                end
                iapp= iapp + 1 ;
            end
        end
    end
%% Add the Apliances field when importing houses from old database
    function dataout = AddAppliancesfieldImport(AppName, dataout, housenbr)
        % Check if the appliance exist in the database for appliances
        if isfield(data.AppProfile, AppName)
            % Get the quantity of appliances for each appliance
            % Get the App class
            AppPos      = find(strcmp(data.AppliancesList(:,3),AppName)==1) ;
            AppClass    = data.AppliancesList{AppPos,4} ;
            if isempty(AppClass)
                % this happens when the app class does not exist, then
                % count the number of appliances in the appliance
                AppQty      = sum(str2double(dataout.SummaryStructure.(housenbr).(AppName))) ;
                fieldllokup = '-' ;
                
                dataout = setupAppImp(dataout, housenbr, AppName, AppQty, fieldllokup) ;
                
            else
                % Loop through the fields to be compared to find the number
                % of qantities for each
                Cmpfield = data.datastructure.(AppClass).Comparefield{1} ;
                for i = 1:length(Cmpfield)
                    fieldllokup = Cmpfield{i} ;
                    AppQty = sum(strcmp(dataout.SummaryStructure.(housenbr).(AppClass), fieldllokup)) ;
                    if AppQty > 0
                        dataout = setupAppImp(dataout, housenbr, AppName, AppQty, fieldllokup) ;
                    end
                end
            end
        else
            % The appliance has not been declared, for now it should not be
            % a problem
        end
    end
%% Function to set up the appliances field
    function dataout = setupAppImp(dataout, housenbr, AppName, AppQty, AppClass)
        DB_Avail = fieldnames(data.AppProfile.(AppName)) ;
        AppDB    = round(RandBetween(1,length(DB_Avail))) ;
        DB       = DB_Avail{AppDB} ;
        try
            GetApps = fieldnames(dataout.SummaryStructure.(housenbr).Appliances) ;
            Appnumber = length(GetApps) + 1 ;
        catch
            % No app has been declared yet
            Appnumber = 1 ;
        end

        AppFields = ['App' num2str(Appnumber)] ;

        dataout.SummaryStructure.(housenbr).Appliances.(AppFields).DB       = DB        ;
        dataout.SummaryStructure.(housenbr).Appliances.(AppFields).SN       = AppName   ;
        dataout.SummaryStructure.(housenbr).Appliances.(AppFields).Qty      = AppQty    ;
        dataout.SummaryStructure.(housenbr).Appliances.(AppFields).Class    = AppClass  ;
    end
end