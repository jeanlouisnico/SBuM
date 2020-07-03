function BackEnd_SB(varargin)

dbstop if error

builtversion =  '2.3.4' ;

CheckToolBox(builtversion) ;
dataBE = createData(varargin);
if isempty(dataBE)
    return
end
guiBackEnd = createInterface(varargin);
set(guiBackEnd.Graphing,'Visible','on');
%-------------------------------------------------------------------------%
    function dataBE = createData(datavariable)
        AppClassName = {'WashMach' 'DishWash' 'Elec' 'Kettle' 'Oven' 'MW' 'Coffee' 'Toas' 'Waff' 'Fridge' 'Radio' 'Laptop' 'Elecheat' 'Shaver' 'Hair' 'Tele' 'Stereo' 'Iron' 'Vacuum' 'Charger' 'Sauna'} ;
        % Create all data needed to run the backend user interface
        folder_name = uigetdir;
        if isempty(datavariable)
            % This means that the function was triggered outside the smart
            % building model --> create all the variables by importing them
            % from simulated data
            % Data Needed :
            % Energy consumption, house information, Price, Emissions, power
            % production, SDI, Appliance_One_Code

            if folder_name == 0 
                dataBE = [] ;
                return
            end
        else
            dataBE = datavariable ;
            if folder_name == 0 
                return
            end
        end
        
        if verLessThan('matlab','9.5')
            % -- Code to run in MATLAB R2018a and earlier here --
            ToolTipString = 'TooltipString' ;
        else
            % -- Code to run in MATLAB R2018b and later here --
            ToolTipString = 'TooltipString' ; % Normally 'Tooltip' but it does not seem to work
        end
        occ = regexp(folder_name,filesep);
        length(folder_name);
        Output_Folder = folder_name(1:(max(occ)-1));
        Project_ID = folder_name((max(occ)+1):length(folder_name));

        EnerCon     = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Cons_Tot_Global.mat'));
        Controller  = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Cont.mat'));
            Controller  = Controller.Cont   ;
        try    
            Emissions   = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Emissions_ReCiPe.mat'));
                Emissions = Emissions.Emissions_ReCiPe ;
        catch
            warning('Missing Emissions files in the output') ;
            Emissions = 0 ;
        end
        try 
            All_Var = load(strcat(Output_Folder,filesep,Project_ID,filesep,'All_Var.mat'));
                All_Var = All_Var.All_Var ;
                AppClassName = All_Var.GuiInfo.AppliancesList(:,3)' ;
        catch
            warning('Missing Variables files in the output, it may be an old simulation that did not save this file') ;
            All_Var = 0 ;
        end
        Input_Data  = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Input_Data.mat'));
            Input_Data  = Input_Data.Input_Data ;
        SDI         = load(strcat(Output_Folder,filesep,Project_ID,filesep,'SDI.mat'));
            SDI = SDI.SDI ;
        ApplianceOneCode  = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Variable_File',filesep,'Appliances_One_CodeStrv2.mat'));
            ApplianceOneCode  = ApplianceOneCode.NewVar ;
        EnergyOutput  = load(strcat(Output_Folder,filesep,Project_ID,filesep,'EnergyOutput.mat'));
            EnergyOutput  = EnergyOutput.EnergyOutput ;
        App  = load(strcat(Output_Folder,filesep,Project_ID,filesep,'App.mat'));
            App  = App.App ;
        Time_Sim  = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Time_Sim.mat'));
            Time_Sim  = Time_Sim.Time_Sim ;
    IndicatorList = {'Climate Change'
                         'Ozone Depletion'
                         'Terrestrial acidification'
                         'Freshwater eutrophication'
                         'Marine eutrophication'
                         'Human toxicity'
                         'Photochemical oxidant formation'
                         'Particulate matter formation'
                         'Terrestrial ecotoxicity'
                         'Freshwater ecotoxicity'
                         'Marine ecotoxicity'
                         'Ionising radiation'
                         'Agricultural land occupation'
                         'Urban land occupation'
                         'Natural land transformation'
                         'Water depletion'
                         'Metal depletion'
                         'Fossil depletion'
                         };
    
    VariablesList = struct() ;
    AllFields = fieldnames(EnerCon) ;
    % CreateSubLayers is a function that create the structure of each
    % variable --> it finds in each variable what it the type of variable
    % in the first layer, second layer and third layer if necessary. This
    % is to be able to retrieve the right information from each of the
    % variable when necessary.
    for i = 1:numel(fieldnames(EnerCon))
        Fieldname = AllFields{i} ;
        VariablesList.(Fieldname).Name = Fieldname ;
        VariablesList.(Fieldname).Variable = 'EnerCon' ;
        
        MainVar = EnerCon.(Fieldname)                 ;
        VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname) ;
    end
    AllFields = fieldnames(Controller) ;
    for i = 1:numel(fieldnames(Controller))
        Fieldname = AllFields{i} ;
        VariablesList.(Fieldname).Name = Fieldname ;
        VariablesList.(Fieldname).Variable = 'Controller' ;

        MainVar = Controller.(Fieldname)                 ;
        VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname) ;
    end
    AllFields = fieldnames(SDI) ;
    for i = 1:numel(fieldnames(SDI))
        Fieldname = AllFields{i} ;
        VariablesList.(Fieldname).Name = Fieldname ;
        VariablesList.(Fieldname).Variable = 'SDI' ;
        
        MainVar = SDI.(Fieldname) ;
        VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname) ;
    end
    AllFields = fieldnames(ApplianceOneCode) ;
    for i = 1:numel(fieldnames(ApplianceOneCode))
        Fieldname = AllFields{i} ;
        VariablesList.(Fieldname).Name = Fieldname ;
        VariablesList.(Fieldname).Variable = 'ApplianceOneCode' ;
        
        MainVar = ApplianceOneCode.(Fieldname)                 ;
        VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname) ;
    end
    AllFields = fieldnames(EnergyOutput) ;
    for i = 1:numel(fieldnames(EnergyOutput))
        Fieldname = AllFields{i} ;
        VariablesList.(Fieldname).Name = Fieldname ;
        VariablesList.(Fieldname).Variable = 'EnergyOutput' ;
        
        MainVar = EnergyOutput.(Fieldname)                 ;
        VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname) ;
    end
    AllFields = fieldnames(App) ;
    for i = 1:numel(fieldnames(App))
        Fieldname = AllFields{i} ;
        VariablesList.(Fieldname).Name = Fieldname ;
        VariablesList.(Fieldname).Variable = 'App' ;
        
        MainVar = App.(Fieldname)                 ;
        VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname) ;
    end
    
    
    
    TimeFrame = {'Hourly'
                 'Daily'
                 'Monthly'
                 'Yearly'} ;
    Aggregationmode = {'Sum'
                       'Average'
                       'Median'} ;
                   
    SavedVar = cell2table(cell(0,5)) ;               
    dataBE.(Project_ID) = struct( ...
                                'SDI', {SDI},...
                                'EnerCon',{EnerCon},...
                                'ApplianceOneCode',{ApplianceOneCode},...
                                'Controller',{Controller},...
                                'Emissions',{Emissions},...
                                'Input_Data',{Input_Data},...
                                'VariablesList',{VariablesList},...
                                'TimeFrame',{TimeFrame},...
                                'Aggregationmode',{Aggregationmode},...
                                'ToolTipString',{ToolTipString},...
                                'IndicatorList',{IndicatorList},...
                                'AppClassName',{AppClassName},...
                                'EnergyOutput',{EnergyOutput},...
                                'App',{App},...
                                'Time_Sim',{Time_Sim},...
                                'SavedVar',{SavedVar},...
                                'All_Var',{All_Var},...
                                'Project_ID',{Project_ID}) ;
end %createData
%-------------------------------------------------------------------------%
function guiBackEnd = createInterface(datavariable)
    % Creating the interface with the different components that will be
    % used for making it usable
    guiBackEnd = struct();
        % Open a window and add some menus
    if isempty(datavariable)
        guiBackEnd.Graphing = figure( ...
            'Name', 'Smart house model - Graphing - University of Oulu', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off',...
            'Visible','off');
        set(guiBackEnd.Graphing,'Position',[guiBackEnd.Graphing.Position(1) guiBackEnd.Graphing.Position(2) 950 600]);

        movegui(guiBackEnd.Graphing,'center')
    else
        
    end

    % + File menu
        guiBackEnd.FileMenu = uimenu( guiBackEnd.Graphing, 'Label', 'File' );
        uimenu( guiBackEnd.FileMenu, 'Label', 'Open', 'Callback', @File);
        uimenu( guiBackEnd.FileMenu, 'Label', 'Open Recent','Callback', @File );
        uimenu( guiBackEnd.FileMenu, 'Label', 'Export', 'Callback', @File,'Separator','on');
        uimenu( guiBackEnd.FileMenu, 'Label', 'Exit', 'Callback', @File,'Separator','on', 'Accelerator','Q' );
    % + Edit menu
        guiBackEnd.FileMenu = uimenu( guiBackEnd.Graphing, 'Label', 'Edit' );
        uimenu( guiBackEnd.FileMenu, 'Label', 'Edit in external figure', 'Callback', @Edit);
        uimenu( guiBackEnd.FileMenu, 'Label', 'Access Database', 'Callback', @Edit);
    % + Graph menu
        guiBackEnd.FileMenu = uimenu( guiBackEnd.Graphing, 'Label', 'Graph' );
        uimenu( guiBackEnd.FileMenu, 'Label', 'Reset Graph', 'Callback', @Graph);
        uimenu( guiBackEnd.FileMenu, 'Label', 'Add Elements', 'Callback', @Graph);
    % + Statistics menu
        guiBackEnd.FileMenu = uimenu( guiBackEnd.Graphing, 'Label', 'Statistics' );
        uimenu( guiBackEnd.FileMenu, 'Label', 'Appliance Distribution', 'Callback', @StatisticsBE);
        uimenu( guiBackEnd.FileMenu, 'Label', 'Appliance signatures', 'Callback', @StatisticsBE); %Load Profile
        uimenu( guiBackEnd.FileMenu, 'Label', 'Load Profile', 'Callback', @StatisticsBE);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', guiBackEnd.Graphing, 'Spacing', 3 );

        guiBackEnd.controlPanel = uix.BoxPanel('Parent', mainLayout, ...
                                    'Title', 'Variables:' );
        graphingPanel = uix.BoxPanel('Parent', mainLayout, ...
                                    'Title', 'Graphing' );

        guiBackEnd.ScrollVarpanel = uix.ScrollingPanel('Parent', guiBackEnd.controlPanel);
        guiBackEnd.MainPanel_Var = uix.VBox('Parent',guiBackEnd.ScrollVarpanel,'Spacing', 5 ) ;
        
        guiBackEnd.Varpanel{1} = uix.BoxPanel('Parent',guiBackEnd.MainPanel_Var,'Title','Source',...
                                       'Padding',2,'HelpFcn', @onPanelHelp);
                                   
        guiBackEnd.SplitSource = uix.VBox('Parent',guiBackEnd.Varpanel{1},'Spacing', 5 ) ;
                uicontrol('Parent',guiBackEnd.SplitSource,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Selected Building');

                Project_ID = char(fieldnames(dataBE)) ;
                HouseData = fieldnames(dataBE.(Project_ID).Input_Data) ;
                
                guiBackEnd.ProjectID = uicontrol('Parent',guiBackEnd.SplitSource,...
                                                    'Style','popup',...
                                                    'Tag','ProjectID',...
                                                    'string',{Project_ID},...
                                                    'callback',@Var2Plot);
                
                guiBackEnd.DefineBDVar = uicontrol('Parent',guiBackEnd.SplitSource,...
                                                    'Style','popup',...
                                                    'Tag','DefineBDVar',...
                                                    'string',HouseData(:),...
                                                    'callback',@Var2Plot);
                                                
                guiBackEnd.CheckHouses = uicontrol('Parent',guiBackEnd.SplitSource,...
                                                    'Style','checkbox',...
                                                    'Tag','CheckHouses',...
                                                    'value',0,...
                                                    'callback',@CheckAllHouses);                                
        guiBackEnd.Varpanel{2} = uix.BoxPanel('Parent',guiBackEnd.MainPanel_Var,'Title','Variables',...
                                            'Padding',2,'HelpFcn', @onPanelHelp);
        guiBackEnd.SplitVariable = uix.VBox('Parent',guiBackEnd.Varpanel{2},'Spacing', 5 ) ;
                uicontrol('Parent',guiBackEnd.SplitVariable,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Selected variables');
                % List the building simulated      
                VariablesList = fieldnames(dataBE.(Project_ID).VariablesList) ;     
                VariablesList = orderalphacellarray(VariablesList) ;
                guiBackEnd.VarList = uicontrol('Parent',guiBackEnd.SplitVariable,...
                                            'Style','popup',...
                                            'Tag','VarList',...
                                            'string',VariablesList(:),...
                                            'callback',@Var2Plot);
                DefVar = VariablesList{1} ;
                VarName = dataBE.(Project_ID).VariablesList.(DefVar).Variable ;
                
                RetrieveVarName = retrievesublayer(dataBE.(Project_ID).(VarName).(DefVar),HouseData,dataBE.(Project_ID).VariablesList.(DefVar),1) ;
                % List the appliances available for this building only
                guiBackEnd.SplitVariableSubLayer1 = uix.HBox('Parent',guiBackEnd.SplitVariable,'Spacing', 5 ) ;
                
                    guiBackEnd.SubLayCombo1 = uicontrol('Parent',guiBackEnd.SplitVariableSubLayer1,...
                                                'Style','popup',...
                                                'Tag','SubLayCombo1',...
                                                'string',RetrieveVarName(:),...
                                                'callback',@Var2Plot);
                    guiBackEnd.SubLayCombo1_Quantity = uicontrol('Parent',guiBackEnd.SplitVariableSubLayer1,...
                                                'Style','popup',...
                                                'Tag','SubLayCombo1_Quantity',...
                                                'string','1',...
                                                'enable','off',...
                                                'callback',@Var2Plot);
                                            
                guiBackEnd.SplitVariableSubLayer2 = uix.HBox('Parent',guiBackEnd.SplitVariable,'Spacing', 5 ) ;
                    RetrieveVarName = retrievesublayer(dataBE.(Project_ID).(VarName).(DefVar),HouseData,dataBE.(Project_ID).VariablesList.(DefVar),2) ;                        
                    guiBackEnd.SubLayCombo2 = uicontrol('Parent',guiBackEnd.SplitVariableSubLayer2,...
                                                'Style','popup',...
                                                'Tag','SubLayCombo2',...
                                                'string',RetrieveVarName(:),...
                                                'callback',@Var2Plot);
                    guiBackEnd.SubLayCombo2_Quantity = uicontrol('Parent',guiBackEnd.SplitVariableSubLayer2,...
                                                'Style','popup',...
                                                'Tag','SubLayCombo2_Quantity',...
                                                'string','1',...
                                                'enable','off',...
                                                'callback',@Var2Plot);
                                            
                guiBackEnd.SplitVariableSubLayer3 = uix.HBox('Parent',guiBackEnd.SplitVariable,'Spacing', 5 ) ;
                    RetrieveVarName = retrievesublayer(dataBE.(Project_ID).(VarName).(DefVar),HouseData,dataBE.(Project_ID).VariablesList.(DefVar),3) ;                        
                    guiBackEnd.SubLayCombo3 = uicontrol('Parent',guiBackEnd.SplitVariableSubLayer3,...
                                                'Style','popup',...
                                                'Tag','SubLayCombo3',...
                                                'string',RetrieveVarName(:),...
                                                'callback',@Var2Plot);     
                    guiBackEnd.SubLayCombo3_Quantity = uicontrol('Parent',guiBackEnd.SplitVariableSubLayer3,...
                                                'Style','popup',...
                                                'Tag','SubLayCombo3_Quantity',...
                                                'string','1',...
                                                'enable','off',...
                                                'callback',@Var2Plot);
                                            
               set(guiBackEnd.SplitVariableSubLayer1,'Widths',[-1 30])
               set(guiBackEnd.SplitVariableSubLayer2,'Widths',[-1 30])
               set(guiBackEnd.SplitVariableSubLayer3,'Widths',[-1 30])
        %%%%%%%%%%%%%%%%%%% AGGREGATION MODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        guiBackEnd.Varpanel{3} = uix.BoxPanel('Parent',guiBackEnd.MainPanel_Var,'Title','What to plot',...
                                            'Padding',2,'HelpFcn', @onPanelHelp);
                                        
        guiBackEnd.SplitTypePlot = uix.VBox('Parent',guiBackEnd.Varpanel{3},'Spacing', 5 ) ;
                uicontrol('Parent',guiBackEnd.SplitTypePlot,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Time frame');
                guiBackEnd.TimeFrame = uicontrol('Parent',guiBackEnd.SplitTypePlot,...
                                            'Style','popup',...
                                            'Tag','TimeFrame',...
                                            'string',dataBE.(Project_ID).TimeFrame(:),...
                                            'callback',@SplitTypePlot);
                uicontrol('Parent',guiBackEnd.SplitTypePlot,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Aggregation mode');
                guiBackEnd.AggregMode = uicontrol('Parent',guiBackEnd.SplitTypePlot,...
                                            'Style','popup',...
                                            'Tag','AggregMode',...
                                            'string',dataBE.(Project_ID).Aggregationmode(:),...
                                            'callback',@SplitTypePlot);
        
        %%%%%%%%%%%%%%%%%%% EDIT PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        guiBackEnd.Varpanel{4} = uix.BoxPanel('Parent',guiBackEnd.MainPanel_Var,'Title','Edit Plot',...
                                            'Padding',2,'HelpFcn', @onPanelHelp);
        guiBackEnd.SplitEditPlot = uix.VBox('Parent',guiBackEnd.Varpanel{4},'Spacing', 5 ) ;
                uicontrol('Parent',guiBackEnd.SplitEditPlot,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Title');
               guiBackEnd.Title = uicontrol('Parent',guiBackEnd.SplitEditPlot,...
                                      'HorizontalAlignment','left',...
                                      'Style','edit',...
                                      'callback',@EditPlot,...
                                      'tag','title');
               uicontrol('Parent',guiBackEnd.SplitEditPlot,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','X-axis');
               guiBackEnd.Xaxis = uicontrol('Parent',guiBackEnd.SplitEditPlot,...
                                      'HorizontalAlignment','left',...
                                      'Style','edit',...
                                      'callback',@EditPlot,...
                                      'tag','Xaxis');
               uicontrol('Parent',guiBackEnd.SplitEditPlot,...
                          'HorizontalAlignment','left',...
                          'Style','text',...
                          'String','Y-axis');
               guiBackEnd.Yaxis = uicontrol('Parent',guiBackEnd.SplitEditPlot,...
                                      'HorizontalAlignment','left',...
                                      'Style','edit',...
                                      'callback',@EditPlot,...
                                      'tag','Yaxis'); 
               uix.Empty('Parent',guiBackEnd.SplitEditPlot) ;
               set(guiBackEnd.SplitEditPlot,'Heights',[19 23 19 23 19 23 -1]) ;
    % Set the panel names and number automatically based on the number of
    % sub panels that were defined earlier.
    for i = 1:numel(guiBackEnd.Varpanel)
        PanelNumber = numel(guiBackEnd.Varpanel) - (i - 1) ;
        switch i
            case {1 2 3}
                Limitation = 'Limit' ;
            case {4}    
                Limitation = 'Limit' ;
            otherwise
                Limitation = 'NoLimit' ;
        end
            
        set(guiBackEnd.Varpanel{i},'MinimizeFcn', {@nMinimize_HD, PanelNumber,Limitation})
        set(guiBackEnd.Varpanel{i},'Tag', ['Panel',num2str(PanelNumber)])
    end
    %%%
    guiBackEnd.SplitGraphingArea = uix.HBox('Parent',guiBackEnd.MainPanel_Var,'Spacing', 5 ) ;
    
    guiBackEnd.AddReplace = uicontrol('Parent',guiBackEnd.SplitGraphingArea,...
                                'Style','checkbox',...
                                dataBE.(Project_ID).ToolTipString,'When checked, it adds plot, when unchecked it replaces existing plot') ;
    guiBackEnd.GraphButton = uicontrol('Parent',guiBackEnd.SplitGraphingArea,...
                                'Style','pushbutton',...
                                'string','Graph',...
                                'callback',@Graph) ;
    set(guiBackEnd.SplitGraphingArea,'Widths', [15,-1]  );
    set( mainLayout, 'Widths', [-1,-5]  );
    
    StandardHeight = 23 ;
    HeightPanel = [] ;
    for i = 1:numel(guiBackEnd.MainPanel_Var.Contents)
        if i == numel(guiBackEnd.MainPanel_Var.Contents) - 1
            nbrofChildren = -1 ;
        elseif i == numel(guiBackEnd.MainPanel_Var.Contents)
            nbrofChildren = 23 ;
        else
            nbrofChildren = (numel(guiBackEnd.MainPanel_Var.Contents(i).Children.Children) + 1) * StandardHeight   ;
        end
        HeightPanel = [HeightPanel nbrofChildren] ;
    end
        set(guiBackEnd.MainPanel_Var,'Heights',HeightPanel ) ;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    guiBackEnd.MainFigure = axes('Parent',graphingPanel) ;
end %createInterface
%-------------------------------------------------------------------------%
    function nMinimize_HD( src, ~, whichpanel,LimitHeight )
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        SelectedBox     = src.Parent.Parent.Parent ;
        SelectedPanel   = SelectedBox.Parent ;
        SelectedCard    = SelectedPanel.Parent ;
        NbrPanel        = numel(SelectedBox.Parent.Contents) - 1 ;
%         SelectedBox = SelectedBoxes(whichpanel);
        
        if contains(src.(dataBE.(Project_ID).ToolTipString),'this panel')
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
        StandardHeight = 23; 
        switch LimitHeight
            case 'Limit'
                if whichpanel == 1
                    pheightmax = -1 ;
                    pheightmaxcm = (numel(guiBackEnd.MainPanel_Var.Contents(PanelRealOrder).Children.Children) + 1) * StandardHeight ;
                else
                    pheightmax = (numel(guiBackEnd.MainPanel_Var.Contents(PanelRealOrder).Children.Children) + 1) * StandardHeight ;
                    pheightmax = max(pheightmax,pheightmin) ;
                end
            case 'NoLimit'
                pheightmax = -1 ;
        end
        s = get( SelectedPanel, 'Heights' );
        pos = get( guiBackEnd.Graphing, 'Position' );
        if contains(src.(dataBE.(Project_ID).ToolTipString),'this panel')
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
            if PanelRealOrder == NbrPanel && i == NbrPanel
                TotalHeight = TotalHeight + max([pheightmin,SelectedPanel.Contents(i).Position(4),pheightmaxcm]) ;
            else
                TotalHeight = TotalHeight + max(pheightmin,SelectedPanel.Contents(i).Position(4));
            end
        end
        TotalHeight = TotalHeight + 10 + 23 ;
        TotalHeight = max(TotalHeight,SelectedCard.Parent.Position(4)-23) ;
        set( SelectedCard, 'Heights', TotalHeight);
end % Minimize 
%-------------------------------------------------------------------------%
    function EditPlot(src,~)
        switch src.Tag
            case 'Yaxis'
                if isempty(src.String)
                    %Remove the YAxis title
                    ylabel(guiBackEnd.MainFigure,'')
                else
                    ylabel(guiBackEnd.MainFigure,src.String) 
                end
            case 'Xaxis'
                if isempty(src.String)
                    %Remove the YAxis title
                    xlabel(guiBackEnd.MainFigure,'')
                else
                    xlabel(guiBackEnd.MainFigure,src.String) 
                end
            case 'title'
                if isempty(src.String)
                    %Remove the YAxis title
                    title(guiBackEnd.MainFigure,'')
                else
                    title(guiBackEnd.MainFigure,src.String) 
                end
            otherwise
                
        end
    end % EditPlot
%-------------------------------------------------------------------------%
    function CheckAllHouses(src,~)
        if src.Value == 1 
            guiBackEnd.DefineBDVar.Enable = 'off' ;
        else
            guiBackEnd.DefineBDVar.Enable = 'on' ;
        end
    end %CheckAllHouses
%-------------------------------------------------------------------------%
    function Var2Plot(src,~)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        try
            sourcetag = src.Tag;
        catch
            sourcetag = '';
        end
        
        if strcmp(sourcetag,'DefineBDVar')    
            AppList = ListAppliances(src.String{src.Value}) ;
            guiBackEnd.AppList.String = AppList(:) ;
        end
        
        if guiBackEnd.CheckHouses.Value == 1
            HouseTag = guiBackEnd.DefineBDVar.String                                    ;
        else
            HouseTag = guiBackEnd.DefineBDVar.String{guiBackEnd.DefineBDVar.Value}      ;
        end
        
        SelectedMainVar = guiBackEnd.VarList.String{guiBackEnd.VarList.Value} ;
        HouseData = fieldnames(dataBE.(Project_ID).Input_Data) ;
        switch src.Tag
            case {'DefineBDVar','ProjectID'}
                % Retrieve the new variable and each of the variable
                MainVar = dataBE.(Project_ID).VariablesList.(SelectedMainVar).Variable ;
                SelVar = SelectedMainVar ;
                VariableInfo = dataBE.(Project_ID).VariablesList.(SelVar) ;
                VariableDisplay = dataBE.(Project_ID).(MainVar).(SelVar) ;
                
                [VarRoot,VariableDisplay, VariableNameOut] = Var2Display(VariableDisplay,VariableInfo,HouseTag) ;                 
            case 'VarList'
                % Retrieve the new variable and each of the variable
                MainVar = dataBE.(Project_ID).VariablesList.(SelectedMainVar).Variable ;
                SubLayer = 1;
                i = 0 ;
                % Loop through each of the combobox afterwards to set them
                % up using the first variable.
                while SubLayer <= 3
                    i = i + 1 ;
                    
                    RetrieveVarName = retrievesublayer(dataBE.(Project_ID).(MainVar).(SelectedMainVar),HouseData,dataBE.(Project_ID).VariablesList.(SelectedMainVar),i) ;
                    SubLayerName = ['SubLayCombo',num2str(SubLayer)] ;
                    
                    if isempty(RetrieveVarName)
                        guiBackEnd.(SubLayerName).Enable = 'off' ;
                        guiBackEnd.(SubLayerName).Value = 1   ;
                        guiBackEnd.(SubLayerName).String = {' '}    ;
                        SubLayer = SubLayer + 1 ;
                    else
                        if isa(RetrieveVarName,'double')
                            SubLayer = SubLayer - 1 ;
                            if RetrieveVarName == 1
                                SubLayerName = ['SubLayCombo',num2str(SubLayer),'_Quantity'] ;
                                guiBackEnd.(SubLayerName).Visible = 'on' ;
                                guiBackEnd.(SubLayerName).Enable = 'off'  ;
                                guiBackEnd.(SubLayerName).String = {' '}  ;
                            else
                                SubLayerName = ['SubLayCombo',num2str(SubLayer),'_Quantity'] ;
                                guiBackEnd.(SubLayerName).Visible = 'on' ;
                                guiBackEnd.(SubLayerName).Enable = 'on'  ;
                                guiBackEnd.(SubLayerName).String = RetrieveVarName(:) ;
                            end
                            SubLayer = SubLayer + 1 ;
                        else
                            guiBackEnd.(SubLayerName).Enable = 'on' ;
                            guiBackEnd.(SubLayerName).String = RetrieveVarName(:) ;
                            guiBackEnd.(SubLayerName).Value = 1   ;
                            SubLayer = SubLayer + 1 ;
                        end
                        
                    end
                    % If all the sublayers are off, then we must allocate
                    % the data.Var2Draw here, otherwise there is nothing to
                    % draw until it is decided what to draw
                end
                SelVar = SelectedMainVar ;
                VariableInfo = dataBE.(Project_ID).VariablesList.(SelVar) ;
                VariableDisplay = dataBE.(Project_ID).(MainVar).(SelVar) ;
                [VarRoot,VariableDisplay, VariableNameOut] = Var2Display(VariableDisplay,VariableInfo,HouseTag) ;  
            case {'SubLayCombo1','SubLayCombo2','SubLayCombo3','SubLayCombo1_Quantity', 'SubLayCombo2_Quantity'}
                SelVar = guiBackEnd.VarList.String{guiBackEnd.VarList.Value} ;
                VariableInfo = dataBE.(Project_ID).VariablesList.(SelVar) ;
                MainVar = dataBE.(Project_ID).VariablesList.(SelVar).Variable  ;
                SubLayer = str2double(erase(src.Tag,'SubLayCombo')) ;
                if sum(strcmp(src.Tag,{'SubLayCombo1','SubLayCombo2','SubLayCombo3'})) >= 1
                    ReconstructCombo(VariableInfo,SubLayer)
                end
                VariableDisplay = dataBE.(Project_ID).(MainVar).(SelVar) ;
                [VarRoot,VariableDisplay, VariableNameOut] = Var2Display(VariableDisplay,VariableInfo,HouseTag) ;
                % Get the SubLayer with the appliance and then perform the
                % test of how many appliances is there under
                    n = 0 ;
                    i = 0 ;
                    AllFields = fieldnames(VariableInfo) ;
                    while n == 0
                        i = i + 1;
                        try 
                           FieldTag = AllFields{i} ;
                        catch
                           % If field does not exist, then we have to exit the loop
                           n = 1 ;
                        end
                        if contains(FieldTag,'SubLayer')
                            FieldTagSubLayer = str2double(erase(FieldTag,'SubLayer')) ;
                            if FieldTagSubLayer < SubLayer
                                continue
                            else
                                if strcmp(VariableInfo.(FieldTag),'App')
%                                     NbrApp = VariableInfo.(Variable
                                end
                            end
                        end
                    end
                    
            otherwise
                
        end
        dataBE.(Project_ID).VarRoot  = VarRoot                ;
        dataBE.(Project_ID).Var2Draw = VariableDisplay        ; 
        dataBE.(Project_ID).VarName  = VariableNameOut        ;
    end %Var2Plot
%-------------------------------------------------------------------------%
    function ReconstructCombo(VariableInfo,SubLayerCombo)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        FileName = VariableInfo.Variable ;
        Variable = VariableInfo.Name     ;
        AllVariables = dataBE.(Project_ID).(FileName).(Variable) ;  
        n = 1 ;
        i = 1 ;
        Sublayer = ['SubLayer',num2str(i)] ;
        try 
            FieldTag = VariableInfo.(Sublayer) ;
        catch
           % If it does not work, then we have to exist the loop
           %AllFieldsunder = [] ;
            FieldTag = '' ;
        end
        if strcmp(FieldTag,'HouseTag')
               AllHouseString = guiBackEnd.DefineBDVar.String;
               SelectedHouse    = AllHouseString{guiBackEnd.DefineBDVar.Value} ;
               AllVariables = AllVariables.(SelectedHouse) ;
               i = i + 1 ;
        end
        while n < SubLayerCombo
           Sublayer = ['SubLayer',num2str(i)] ;
           SublayerComboBox = ['SubLayCombo',num2str(n)] ;
           SubLayerComboBox_Qty = ['SubLayCombo',num2str(n),'_Quantity'] ;
           try 
               FieldTag = VariableInfo.(Sublayer) ;
           catch
               % If it does not work, then we have to exist the loop
               %AllFieldsunder = [] ;
               break
           end
           if strcmp(FieldTag,'HouseTag')
               AllHouseString = guiBackEnd.DefineBDVar.String;
               SelectedHouse    = AllHouseString{guiBackEnd.DefineBDVar.Value} ;
               AllVariables = AllVariables.(SelectedHouse) ;
           else
               ComboBoxContent = guiBackEnd.(SublayerComboBox).String{guiBackEnd.(SublayerComboBox).Value} ;
               if strcmp(guiBackEnd.(SubLayerComboBox_Qty).String(guiBackEnd.(SubLayerComboBox_Qty).Value),' ')
                   SubLayerComboBox_QtyVal = 1 ;
               else
                   SubLayerComboBox_QtyVal = guiBackEnd.(SubLayerComboBox_Qty).String(guiBackEnd.(SubLayerComboBox_Qty).Value) ;
               end
               if isa(SubLayerComboBox_QtyVal,'char')
                   SubLayerComboBox_QtyVal = str2double(SubLayerComboBox_QtyVal) ;
               elseif isa(SubLayerComboBox_QtyVal,'cell')
                   SubLayerComboBox_QtyVal = SubLayerComboBox_QtyVal{1} ;
                   if isa(SubLayerComboBox_QtyVal,'char')
                        SubLayerComboBox_QtyVal = str2double(SubLayerComboBox_QtyVal) ;
                   end
               end
               % Extract the specific dimension
               AllVariables = AllVariables.(ComboBoxContent)(SubLayerComboBox_QtyVal) ;
               n = n + 1 ;
           end
           i = i + 1 ;
        end
        
        % We now have the top layer of the data structure
        % Now we can extract the sublayers
        %ReconstructCombo(VariableInfo,3,AllVariables,SubLayerCombo+1)

        SubLayerComboMax = 3 ;

        while n < SubLayerComboMax
           Sublayer = ['SubLayer',num2str(i)] ;
           SublayerComboBox = ['SubLayCombo',num2str(n)] ;
           SubLayerComboBox_Qty = ['SubLayCombo',num2str(n),'_Quantity'] ;
           try 
               FieldTag = VariableInfo.(Sublayer) ;
           catch
               % If it does not work, then we have to exist the loop
               %AllFieldsunder = [] ;
               break
           end
           if strcmp(FieldTag,'HouseTag')
               AllHouseString = guiBackEnd.DefineBDVar.String;
               SelectedHouse    = AllHouseString{guiBackEnd.DefineBDVar.Value} ;
               AllVariables = AllVariables.(SelectedHouse) ;
           else
               ComboBoxContent = guiBackEnd.(SublayerComboBox).String{guiBackEnd.(SublayerComboBox).Value} ;
               % Update the Combobox quantity visibility first
               AllVariablesTemp = AllVariables.(ComboBoxContent) ;
               
               if isa(AllVariablesTemp,'struct')
                    % Find out if there are any variables under it by looking at
                    % the size of the structure
                    Dim = size(AllVariablesTemp,2) ;
                    for qty = 1:Dim
                        a{qty} = qty ;
                    end
                    if numel(a) > 1
                        set(guiBackEnd.(SubLayerComboBox_Qty),'Enable','on',...
                                                          'String', a,...
                                                          'Value',1) ;
                    else
                        set(guiBackEnd.(SubLayerComboBox_Qty),'Enable','off',...
                                                              'String', a,...
                                                              'Value',1) ;
                    end
                elseif isa(AllVariablesTemp,'double')
                    % Then there is nothing to do but to plot the data
                    for i_n = n+1:SubLayerComboMax
                        SublayerComboBox = ['SubLayCombo',num2str(i_n)] ;
                        SubLayerComboBox_Qty = ['SubLayCombo',num2str(i_n),'_Quantity'] ;
                        set(guiBackEnd.(SublayerComboBox),'string',' ',...
                                                          'value',1,...
                                                          'enable','off','string',' ')
                        set(guiBackEnd.(SubLayerComboBox_Qty),'string',' ',...
                                                              'value',1,...
                                                              'enable','off','string',' ')
                    end
                    break
                end
                
               if strcmp(guiBackEnd.(SubLayerComboBox_Qty).String(guiBackEnd.(SubLayerComboBox_Qty).Value),' ')
                   SubLayerComboBox_QtyVal = 1 ;
               else
                   SubLayerComboBox_QtyVal = guiBackEnd.(SubLayerComboBox_Qty).String(guiBackEnd.(SubLayerComboBox_Qty).Value) ;
               end
               if isa(SubLayerComboBox_QtyVal,'cell')
                   SubLayerComboBox_QtyVal = SubLayerComboBox_QtyVal{1} ;
                   SubLayerComboBox_QtyVal = str2double(SubLayerComboBox_QtyVal) ;
               elseif isa(SubLayerComboBox_QtyVal,'char')
                   SubLayerComboBox_QtyVal = str2double(SubLayerComboBox_QtyVal) ;
               end
               % Extract the specific dimension
               if isa(AllVariables.(ComboBoxContent),'table')
                   AllVariables = AllVariables.(ComboBoxContent).DataOutput(SubLayerComboBox_QtyVal) ;
               else
                   AllVariables = AllVariables.(ComboBoxContent)(SubLayerComboBox_QtyVal) ;
               end
                if isa(AllVariables,'struct')
                    % Then setup the next Variable Combobox with Value = 1
                    NextComboBox = fieldnames(AllVariables) ;
                    Temp_i = i + 1 ;
                    Sublayer = ['SubLayer',num2str(Temp_i)] ;
                    try 
                        FieldTag = VariableInfo.(Sublayer) ;
                    catch
                        % If it does not work, then we have to exist the loop
                        %AllFieldsunder = [] ;
                        FieldTag = 'HouseTag' ;
                    end
                    if ~strcmp(FieldTag,'HouseTag')
                        SublayerComboBox = ['SubLayCombo',num2str(SubLayerCombo + 1)] ;
                        SubLayerComboBox_Qty = ['SubLayCombo',num2str(SubLayerCombo),'_Quantity'] ;
                        set(guiBackEnd.(SublayerComboBox),'String',NextComboBox,...
                                                          'Value',1,...
                                                          'Enable','on');
                    end
                elseif isa(AllVariables,'double')
                    % Then Exit the loop by setting all the remaining
                    % ComboBox to off
                    for i_n = n+1:SubLayerComboMax
                        SublayerComboBox = ['SubLayCombo',num2str(i_n)] ;
                        SubLayerComboBox_Qty = ['SubLayCombo',num2str(i_n),'_Quantity'] ;
                        set(guiBackEnd.(SublayerComboBox),'enable','off','string',' ')
                        set(guiBackEnd.(SubLayerComboBox_Qty),'enable','off','string',' ')
                    end
                    break
                end
               n = n + 1 ;
           end
           i = i + 1 ;
        end
            
    end %ExtractData
%-------------------------------------------------------------------------%
    function [VarRootOut,VariableDisplayOut, VariableNameOut] = Var2Display(VariableDisplay,VariableInfo,HouseTag)
        
        if isa(HouseTag,'char')
            HouseTagList = {HouseTag} ;
        else
            HouseTagList = HouseTag ;
        end
        VariableDisplayOriginal = VariableDisplay ;
        for iHouse = 1:length(HouseTagList)
            
            HouseTagLoop = HouseTagList{iHouse} ;
            SubLayerretrieve = 0 ;
            VarRoot = [VariableInfo.Variable,'\',VariableInfo.Name] ;
            n = 0;
            i = 0;
            VariableDisplay = VariableDisplayOriginal ;
            while n == 0
                i = i + 1 ;
                SubLayerTag = ['SubLayer',num2str(i)] ;
                try
                    VarLayer = VariableInfo.(SubLayerTag) ;
                catch
                    n = 1 ;
                end
                if isa(VariableDisplay,'double')
                    n = 1 ;
                end
                % look in which sublayer combobox we have already looked into
                if ~n
                    if strcmp(VarLayer,'HouseTag')
                        try 
                            Value2Retrieve = VariableDisplay.(HouseTagLoop) ;
                        catch
                            VariableDisplay = 0 ;
                            continue
                        end
%                         SubLayerretrieve = max(0,SubLayerretrieve - 1) ;
                        VariableDisplay = Value2Retrieve ;
                        VarRoot = [VarRoot,'\',HouseTagLoop];
                        try 
                            Var2Name ;
                        catch
                            Var2Name = VariableInfo.Name ;
                        end
                    else
                        SubLayerretrieve = SubLayerretrieve + 1 ;
                        SubLayerTag = ['SubLayCombo',num2str(SubLayerretrieve)] ;
                        SubLayerQty = ['SubLayCombo',num2str(SubLayerretrieve),'_Quantity'] ;

                        Value = guiBackEnd.(SubLayerTag).Value ;

                        if isa(Value,'char')
                            Value = str2double(Value) ;
                        end
                        
                        try
                            Value2Retrieve = guiBackEnd.(SubLayerTag).String(Value) ;
                        catch
                            Value2Retrieve = ' ' ;
                        end
                        if isa(Value2Retrieve,'cell')
                            Value2Retrieve = Value2Retrieve{1} ;
                        end
                        if strcmp(Value2Retrieve,' ')
                            Value2Retrieve = 1;
                        end
                        
                        Var2Name       = Value2Retrieve ;
                        
                        ValueQty = guiBackEnd.(SubLayerQty).String(guiBackEnd.(SubLayerQty).Value) ;
                        if isa(ValueQty,'cell')
                            ValueQty = ValueQty{1} ;
                        end
                        if strcmp(ValueQty,' ')
                            ValueQty = '1';
                        end
                        ValueQty_double = str2double(ValueQty) ;
                        switch VarLayer
                            case {'App','VarSpecific'}
                                VariableDisplay = VariableDisplay.(Value2Retrieve) ;
                                if ~isa(VariableDisplay,'double')
                                    if isa(VariableDisplay,'table')
                                        VariableDisplay = VariableDisplay ;
                                    elseif isa(VariableDisplay,'timetable')
                                        VariableDisplay = VariableDisplay ;
                                    else
                                        VariableDisplay = VariableDisplay(ValueQty_double) ;
                                    end
                                end
                                VarRoot = [VarRoot,'\',Value2Retrieve,'[',ValueQty,']'];
                            case 'NbrApp'
    %                             if strcmp(Value2Retrieve,' ')
    %                                 Value2Retrieve = '1' ;
    %                             end
    %                             VariableDisplay = VariableDisplay(str2double(Value2Retrieve))  ;
    %                             VarRoot = [VarRoot,'[',Value2Retrieve,']'];
                        end
                    end
                end %Exit Condition
            end %While Loop
            VarRootOut{iHouse}          = VarRoot ;
            VariableDisplayOut{iHouse}  = VariableDisplay ;
            VariableNameOut{iHouse}     = Var2Name ;
        end %For Loop
    end
%-------------------------------------------------------------------------%
    function DrawVar
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        try
            dataBE.(Project_ID).Var2Draw ;
        catch
            % This can happen if the popup has not been selected
            Var2Draw = guiBackEnd.VarList.String{guiBackEnd.VarList.Value} ;
            dataBE.(Project_ID).Var2Draw = Var2Draw ;
        end
        try
            dataBE.(Project_ID).VarName ;
        catch
            % This can happen if the popup has not been selected
            VarName = guiBackEnd.VarList.String{guiBackEnd.VarList.Value} ;
            dataBE.(Project_ID).VarName = VarName ;
        end
    
        try
            dataBE.(Project_ID).TF2Draw ;
        catch
            % This can happen if the popup has not been selected
            TF2Draw = guiBackEnd.TimeFrame.String{guiBackEnd.TimeFrame.Value} ;
            dataBE.(Project_ID).TF2Draw = TF2Draw ;
        end
        
        try
            dataBE.(Project_ID).Agg2Draw ;
        catch
            % This can happen if the popup has not been selected
            Agg2Draw = guiBackEnd.AggregMode.String{guiBackEnd.AggregMode.Value} ;
            dataBE.(Project_ID).Agg2Draw = Agg2Draw ;
        end
        
        replacevar = guiBackEnd.AddReplace.Value ;
        
        for iDraw = 1:length(dataBE.(Project_ID).Var2Draw)
            
            VarRoot = dataBE.(Project_ID).VarRoot{iDraw} ;
            Var2Draw = dataBE.(Project_ID).Var2Draw{iDraw} ;
            VarName = dataBE.(Project_ID).VarName{iDraw} ;
            
            if 	isa(Var2Draw,'struct')
                Var2Draw = Var2Draw.(guiBackEnd.DefineBDVar.String{guiBackEnd.DefineBDVar.Value}) ;
            end
            
            if isempty(guiBackEnd.MainFigure.UserData)
                guiBackEnd.MainFigure.UserData.Variable1.Root = VarRoot ;
            else
                % Create the option to add more variable if necessary
                if replacevar
                    % Replace the current drawn variable
                    % Delete the exisiting data
                    guiBackEnd.MainFigure.UserData = [] ;
                    %Write the first variable name
                    guiBackEnd.MainFigure.UserData.Variable1.Root = VarRoot ;
                else
                    % Add one more variable to the Graph
                    NbrVar = length(guiBackEnd.MainFigure.UserData) ;
                    NewVarNbr = NbrVar + 1 ;
                    NewVarName = ['Variable',num2str(NewVarNbr)] ;
                    guiBackEnd.MainFigure.UserData.(NewVarName).Root = VarRoot ;
                end
            end
            if replacevar
                hold(guiBackEnd.MainFigure,'off')
                if size(Var2Draw,1) == 1 && size(Var2Draw,2) == 1
                    stem(Var2Draw,'Parent',guiBackEnd.MainFigure,'DisplayName',VarName) ;
                else
                    plot(Var2Draw,'Parent',guiBackEnd.MainFigure,'DisplayName',VarName) ;
                end
            else
                fig = guiBackEnd.MainFigure ;
                hold(fig,'on')
                if size(Var2Draw,1) == 1 && size(Var2Draw,2) == 1
                    stem(Var2Draw,'Parent',fig) ;
                else
                    if isa(Var2Draw,'table')
                        plot(Var2Draw.Time,Var2Draw.DataOutput,'Parent',fig, 'DisplayName',VarName) ;
                    elseif isa(Var2Draw,'timetable')
                        plot(Var2Draw.Time,Var2Draw.DataOutput,'Parent',fig, 'DisplayName',VarName) ;
                    else
                        plot(Var2Draw,'Parent',fig,'DisplayName',VarName) ;
                    end
                end            
            end
            legend ;
        end
    end % DrawVar
%-------------------------------------------------------------------------%
    function HouseVar(src,~)
        AppList = ListAppliances(src.String{src.Value}) ;
        guiBackEnd.AppList.String = AppList(:) ;
    end %HouseVar
%-------------------------------------------------------------------------%
    function AppListRetrieve = ListAppliances(HouseTag)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        AppList = fieldnames(dataBE.(Project_ID).ApplianceOneCode.Appliances_ConsStr) ;
        AppListRetrieve = {} ;
        for i = 1:numel(AppList)
            try 
                dataBE.(Project_ID).ApplianceOneCode.Appliances_ConsStr.(AppList{i}).(HouseTag) ;
            catch
                % The Building does not have this appliance
                continue
            end
            AppListRetrieve{end+1} = AppList{i} ;
        end
        AppListRetrieve = orderalphacellarray(AppListRetrieve') ;
    end % ListAppliances
%-------------------------------------------------------------------------%
    function VariablesList = CreateSubLayers(MainVar,VariablesList,Fieldname)
        % Check for all the structures under the Variable
        SubLayerNum = 1 ;
        n = 0 ;
        while n==0
            if isstruct(MainVar)
                FieldMainVar = fieldnames(MainVar) ;
                SubLayerName = ['SubLayer',num2str(SubLayerNum)] ;
                if contains(FieldMainVar{1},'House')
                    % This means that the first layer is the house
                    % definition
                    VariablesList.(Fieldname).(SubLayerName) = 'HouseTag' ;
                    MainVar = MainVar.(FieldMainVar{1}) ;
%                 elseif sum(contains(AppClassName,FieldMainVar{1})) > 0
%                     % This means that the sublayer is an appliance
%                     VariablesList.(Fieldname).(SubLayerName) = 'App' ;
%                     SubLayerNum = SubLayerNum + 1 ;
%                     SubLayerName = ['SubLayer',num2str(SubLayerNum)] ;
%                     VariablesList.(Fieldname).(SubLayerName) = 'NbrApp' ;
%                     MainVar = MainVar.(FieldMainVar{1}) ;
                else
                    VariablesList.(Fieldname).(SubLayerName) = 'VarSpecific' ;
                    MainVar = MainVar.(FieldMainVar{1}) ;
                end
                SubLayerNum = SubLayerNum + 1 ;
            elseif isa(MainVar,'double')
                [row,col] = size(MainVar) ;
                if row > 1 && col > 1
                    NbrSubDouble = min(row,col) ;
                    SubLayerNum = SubLayerNum + 1 ;
                    SubLayerName = ['SubLayer',num2str(SubLayerNum)] ;
                    VariablesList.(Fieldname).(SubLayerName) = num2str(NbrSubDouble) ;
                else
                    NbrSubDouble = 1 ;
                end
                
                n = 1 ;
            else
                n = 1 ;
            end
        end
    end % CreateSubLayers
%-------------------------------------------------------------------------%
    function AllFieldsunder = retrievesublayer(VariableData,HouseData,VariableInfo,level2retrieve)
       AllFields = fieldnames(VariableInfo) ;
       Level = 0 ;
       n = 0 ;
       i = 0 ;
       VariableDataTemp = VariableData ;
       % Get the mapping of the variable that we want to retrieve
       AllFieldsunder = [] ;
       while n == 0
           i = i + 1;
           try 
               FieldTag = AllFields{i} ;
           catch
               % If it does not work, then we have to exist the loop
               AllFieldsunder = [] ;
               break
           end
           if contains(FieldTag,'SubLayer')
               % Builb sublayer i
               if ~strcmp(VariableInfo.(FieldTag),'HouseTag')
                   Level = Level + 1 ;
                   if Level == level2retrieve
%                        RetrieveVarName = VariableInfo.(FieldTag) ;
                       n = 1 ;
                       if strcmp(VariableInfo.(FieldTag),'NbrApp')
                           % Need to count how many app are defined under
                           % this variable
                           % Get the first app for definition
                           First_App = fieldnames(VariableDataPrev) ;
                           First_App = First_App{1} ;
                           AllFieldsunder = numel(VariableDataPrev.(First_App)) ;
                       else
                           AllFieldsunder = fieldnames(VariableDataTemp) ;
                       end
                   else
                       if strcmp(VariableInfo.(FieldTag),'NbrApp')
                           % Need to retrieve the first app and what is
                           % under it
                            VariableDataTemp = VariableDataTemp(1)                 ;
                       else
                           AllFieldsunder = fieldnames(VariableDataTemp) ;
                           VariableDataPrev = VariableDataTemp ;
                           VariableDataTemp = VariableDataTemp.(AllFieldsunder{1}) ;
                       end
                   end
               else
                   try 
                       AllHouseString = guiBackEnd.DefineBDVar.String;
                       SelHouseTag    = AllHouseString{guiBackEnd.DefineBDVar.Value};
                   catch
                       % This means the interface was not declared yet
                       SelHouseTag    = HouseData{1} ;
                   end
                   SubLayerHouseTag = SelHouseTag ;
                   VariableDataPrev = VariableDataTemp ;
                   try
                       VariableDataTemp = VariableDataTemp.(SubLayerHouseTag) ;
                   catch
                       continue
                   end
                   AllFieldsunder =  [] ;
               end
           end
       end
    end % retrievesublayer
%-------------------------------------------------------------------------%
    function File(src,~)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        switch src.Text
            case 'Export'    
                fig = guiBackEnd.MainFigure ;
                axObjs = fig.Children ;
                if isempty(axObjs)
                    msgbox('No data to be exported','Export failed','help')
                    return;
                end
                for i = 1:numel(axObjs)
                    Data1 = ['X',num2str(i)] ;
                    x_data.(Data1) = axObjs(i).XData' ;
                    Data2 = ['Y',num2str(i)] ;
                    y_data.(Data2) = axObjs(i).YData' ; 
                end
                
                % If Excel is chosen then perform this
                for i = 1:numel(axObjs)
                    sheet = i;
                    Data1 = ['X',num2str(i)] ;
                    Data2 = ['Y',num2str(i)] ;
                    
                    writetable(table(x_data.(Data1), y_data.(Data2)),'Results.xlsx','sheet',sheet,'Range','A1','WriteVariableNames', true)
                end
%                 writetable(dataBE.(Project_ID).SavedVar,'tabledata.csv','Delimiter',',');
                msgbox('File exported as tabledata.csv in the root file successfully!!')
                
            case 'Open'
                dataBE = createData(dataBE) ;
                NewString = fieldnames(dataBE) ;
                guiBackEnd.ProjectID.String = NewString ;
            case 'Open Recent'
                
            case 'Exit'
                close(guiBackEnd.Graphing)
                
        end
    end %File
%-------------------------------------------------------------------------%
    function SplitTypePlot(src,~)
        fig = guiBackEnd.MainFigure ;
        axObjs = fig.Children ;
        x_data = axObjs(1).XData ;
        y_data = axObjs(1).YData ;
        
        
        
    end %SplitTypePlot
%-------------------------------------------------------------------------%
    function Edit(src,~)
        switch src.Text
            case 'Edit in external figure'
                fig = guiBackEnd.MainFigure ;
                newgcf = gcf ;
                if isempty(newgcf.Number)
                    startingnumber = 1;
                else
                    startingnumber = newgcf.Number ;
                end
                hFigures(startingnumber) = figure('Visible','on') ;
                a2 = copyobj(fig,hFigures(startingnumber)) ;
            case 'Access Database'
                opendata = dataBE ;
                assignin('base','opendata',opendata) ;
                open opendata;
        end
        
    end
%-------------------------------------------------------------------------%
    function Graph(src,~)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        try 
            text2read = src.Text ;
        catch
            text2read = src.String ;
        end
        switch text2read
            case 'Reset Graph' 
                delete(guiBackEnd.MainFigure.Children); % Make averSpec the current axes.
                dataBE.(Project_ID).SavedVar = cell2table(cell(0,5)) ;
            case 'Graph'
                DrawVar ;
                if guiBackEnd.CheckHouses.Value == 1
                    HouseTag = guiBackEnd.DefineBDVar.String                                    ;
                else
                    HouseTag = guiBackEnd.DefineBDVar.String(guiBackEnd.DefineBDVar.Value)      ;
                end
                for iDraw = 1:length(dataBE.(Project_ID).Var2Draw)
            
                    VarRoot = dataBE.(Project_ID).VarRoot{iDraw} ;
                    Var2Draw = dataBE.(Project_ID).Var2Draw{iDraw} ;
                
                    varname = split(VarRoot,'\') ;
                    %HouseTag = guiBackEnd.DefineBDVar.String{guiBackEnd.DefineBDVar.Value} ;

                    if strcmp(HouseTag{iDraw},varname{end})
                        varname = varname{end-1} ;
                    else
                        varname = varname{end}   ;
                    end

                    varname = [varname '_' HouseTag{iDraw}] ;

                    CheckVarName = any(strcmp(dataBE.(Project_ID).SavedVar.Properties.VariableNames,varname)) ;

                    if ~(length(varname) < namelengthmax)
                        % the variable name is too long, change it to fit the
                        % variable name size of 63 characters (as of 2019b)
                    end

                    if CheckVarName
                        %This varname already exists
                        return;
                    end

                    if size(dataBE.(Project_ID).SavedVar,1) == 0 || size(dataBE.(Project_ID).SavedVar,2) == 0
                        if isa(Var2Draw,'table')
                            Var2Draw = Var2Draw.DataOutput ;
                        elseif isa(Var2Draw,'timetable')
                            Var2Draw = Var2Draw.DataOutput ;
                        end
                        dataBE.(Project_ID).SavedVar =  table(Var2Draw', 'VariableNames', {varname})                     ;
                    else
                        % TableCurRowLength = size(dataBE.(Project_ID).SavedVar,1) ;
                        if isa(Var2Draw,'table')
                            Var2Draw = Var2Draw.DataOutput ;
                        end
                        dataBE.(Project_ID).SavedVar = [table(Var2Draw', 'VariableNames', {varname})  dataBE.(Project_ID).SavedVar] ;
                    end
                    %dataBE.(Project_ID).SavedVar 
                end
        end
    end
%% Statistics on appliances
    function StatisticsBE(src,~)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        
        Mfigpos = get(guiBackEnd.Graphing,'OuterPosition') ;
                buttonwidth = 500 ;
                buttonheight = 500 ;
        guiBackEnd.StatisticsApp = figure('units','pixels',...
                         'position',[Mfigpos(1)+Mfigpos(3)/2-buttonwidth/2,...
                                     Mfigpos(2)+Mfigpos(4)/2-buttonheight/2,...
                                     buttonwidth / 3,...
                                     buttonheight/3],...
                         'toolbar','none',...
                         'menu','none',....
                         'name','Statistics',....
                         'NumberTitle','off',...
                         'Visible','off',...
                         'Tag','AddFigure') ;%,...
                         %'CloseRequestFcn',@closeRequest);
                    %set(gui.CopyDialog,'WindowStyle','modal')

        setupVer = uix.VBox('Parent', guiBackEnd.StatisticsApp) ;
        
        guiBackEnd.checkboxDS = uicontrol('Parent', setupVer,...
                                          'Style', 'checkbox',...
                                          'Tag','checkboxDS',...
                                          'String','Use all loaded projects'); 
                                      
        guiBackEnd.checkboxAllHouses = uicontrol('Parent', setupVer,...
                                          'Style', 'checkbox',...
                                          'Tag','checkboxAllHouses',...
                                          'String','Use all houses'); 
                                      
        % Tick box to integrate all the projects or just the one displayed
        
        % Combobox menu with al the appliances
        AllApps = [{'All'};fieldnames(dataBE.(Project_ID).App.Info)] ;
        MonthStudied = [{'All'} num2cell(1:12)] ;    
        TimeStudied  = [{'All'} num2cell(1:3)] ;
        
                                      
        dataBE.(Project_ID).StatApp = src.Text ;
        switch src.Text
            case 'Appliance Distribution'
                % Appliances to check from All to single
                guiBackEnd.Appstudied = uicontrol('Parent', setupVer,...
                                          'Style', 'popupmenu',...
                                          'Tag','Appstudied',...
                                          'String',AllApps);
                % Month to check from All to 1:12
                guiBackEnd.Monthstudied = uicontrol('Parent', setupVer,...
                                          'Style', 'popupmenu',...
                                          'Tag','Monthstudied',...
                                          'String',MonthStudied);
                % Period of the week to check from Weekday to weekends
                guiBackEnd.Timeperiodtudied = uicontrol('Parent', setupVer,...
                                          'Style', 'popupmenu',...
                                          'Tag','Timeperiodtudied',...
                                          'String',TimeStudied);
            case 'Appliance signatures'
                guiBackEnd.Appstudied = uicontrol('Parent', setupVer,...
                                          'Style', 'popupmenu',...
                                          'Tag','Appstudied',...
                                          'String',AllApps);
                uix.Empty('Parent', setupVer)
                uix.Empty('Parent', setupVer)
                
            case 'Load Profile'
                guiBackEnd.Recalculate10s = uicontrol('Parent', setupVer,...
                                          'Style', 'checkbox',...
                                          'Tag','Recalculate10s',...
                                          'String','Recalculate 10s profiles');
                guiBackEnd.Plotstyle = uicontrol('Parent', setupVer,...
                                          'Style', 'popupmenu',...
                                          'Tag','Appstudied',...
                                          'String',{'area', 'line'});
                uix.Empty('Parent', setupVer)
        end
        guiBackEnd.Butt_trace = uicontrol('Parent', setupVer,...
                                          'Style', 'pushbutton',...
                                          'Tag','Appstudied',...
                                          'String','Graphs',...
                                          'Callback', @GraphStatistics);
                                      
        set(guiBackEnd.StatisticsApp,'Visible','on') ;
        
    end
%% Graph the appliance statistics
    function GraphStatistics(varargin)
        Project_ID = guiBackEnd.ProjectID.String{guiBackEnd.ProjectID.Value} ;
        if guiBackEnd.checkboxDS.Value == 1
             AllProjects = fieldnames(dataBE) ;
             for i = 1:length(AllProjects)
                 Project_IDv2 = AllProjects{i} ;
                 App.(Project_IDv2) = dataBE.(Project_IDv2).App ;
                 Time_Sim.(Project_IDv2) = dataBE.(Project_IDv2).Time_Sim ;
                 Cons_Tot.(Project_IDv2) = dataBE.(Project_IDv2).EnerCon.Cons_Tot ;
                 All_Var.(Project_IDv2)  = dataBE.(Project_IDv2).All_Var  ;
             end
        else
             App.(Project_ID)           = dataBE.(Project_ID).App ;
             Time_Sim.(Project_ID)      = dataBE.(Project_ID).Time_Sim ;
             Cons_Tot.(Project_ID)      = dataBE.(Project_ID).EnerCon.Cons_Tot ;
             All_Var.(Project_ID)       = dataBE.(Project_ID).All_Var  ;
        end
        AllHouseString = guiBackEnd.DefineBDVar.String;
        
        if guiBackEnd.checkboxAllHouses.Value == 1
            SelectedHouse    = AllHouseString  ;
        else
            SelectedHouse    = AllHouseString(guiBackEnd.DefineBDVar.Value) ;
        end
        
        switch dataBE.(Project_ID).StatApp
            case 'Appliance Distribution'
                Appliancestudied = guiBackEnd.Appstudied.String{guiBackEnd.Appstudied.Value} ;
                [dataBE.(Project_ID).Distribution.Stat4Use_Profileextract,dataBE.(Project_ID).Distribution.Distri_Cumsum, dataBE.(Project_ID).Distribution.Info] = Check_distribution_appliances(App,Appliancestudied,SelectedHouse, Time_Sim, All_Var) ;
                % Plot all the data, differentiate if multiple sources
            case 'Appliance signatures'
                Appliancestudied = guiBackEnd.Appstudied.String{guiBackEnd.Appstudied.Value} ;
                [a] = Check_signature_appliances(App,Appliancestudied,SelectedHouse) ;
            case 'Load Profile'
                Recalculate10s = guiBackEnd.Recalculate10s.Value ; 
                Plotstyle = guiBackEnd.Plotstyle.String{guiBackEnd.Plotstyle.Value} ;
                [dataBE.(Project_ID).Profile, dataBE.(Project_ID).ConvertedArray, dataBE.(Project_ID).Profile10s, dataBE.(Project_ID).ConvertedArray10s] = profileploting(App, Cons_Tot, Time_Sim, ...
                                                                                                                      SelectedHouse, dataBE, ...
                                                                                                                      Recalculate10s, Plotstyle) ;
        end
    end
end