function Reporting_Housesv2(varargin)

import mlreportgen.report.*
import mlreportgen.dom.*

FullPath  = mfilename('fullpath')       ;

PathSmartHome = getfolder(FullPath,'MatLab model Beta') ;

PathExtrFunc = [PathSmartHome,filesep,'Input',filesep,'Extra Functions'] ;

waitwindow = waitbar(0,'Creating report','Name','Creating report...',...
   'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(waitwindow,'canceling',0);

if ismac
    MachineInfo.name = java.lang.System.getProperty('user.name') ; %getenv('USER')
    MachineInfo.MLver = version ;
    MachineInfo.domain = 'unknown' ;
    MachineInfo.host   = 'unknown' ;
    try
        getip
    catch
       if ismac
           try
               mex -O getip.c
           catch
               MachineInfo.ip = 'unknown' ;
           end
           if isempty(MachineInfo.ip)
               MachineInfo.ip = getip ;
           end
       elseif ispc
           %This could work for windows computer but it needs some twick to
           %install a compiler that is not by default (compiler is already
           %on unix machine though). Then it requires to set the path for
           %the ws2_32.lib which is in the matlab path e.g. C:\Program
           %Files\MATLAB\R2018b\sys\lcc64\lcc64\lib64 
           
           getipPath = [PathExtrFunc,filesep,getip.c] ;
           mex -O getip.c ws2_32.lib -DWIN32
       end
    end
    
    osname = strcat({char(java.lang.System.getProperty('os.name'))},{' '},...
                                {char(java.lang.System.getProperty('os.version'))},{' '},...
                                {char(java.lang.System.getProperty('os.arch'))});
    MachineInfo.osname = osname{1} ;
else
    MachineInfo = whoami;
end
Headers = {'Title' 'Subtitle' 'Logo' 'Author' 'Publisher' 'PubDate'} ;

if getappdata(waitwindow,'canceling')
    delete(waitwindow)
    return
end

if nargin > 1
    ToPopulate = varargin{1} ;
    HousesData = varargin{2} ;
    VarReport.ReportName = strrep(ToPopulate.Title,' ','_') ; 
    VarReport.Locale = ToPopulate.Language ;
    VarReport.FileFormat = ToPopulate.FileFormat ;
    VarReport.DisplayDefault = ToPopulate.DisplayDef ;
    for i = 1:numel(Headers)
        Header2Define = Headers{i} ;
        try
            output = ToPopulate.(Header2Define) ;
        catch
            output = defaultinput(Header2Define,MachineInfo) ;
        end
        ReportData.(Header2Define) = output ;
    end
else
    for i = 1:numel(Headers)
        Header2Define = Headers{i} ;
        output = defaultinput(Header2Define,MachineInfo) ;
        ReportData.(Header2Define) = output ;
    end
    HouseNbr = 3 ;
    varnamecell.datastructure = variable_names ;
    HousesData.varname = variable_names ;
    HousesData.AppliancesList = AppList ;
    
    for i = 1:HouseNbr
        HouName = strcat('House',num2str(i)) ;
        [SummaryStructure] = createHouse(HouName, i, varnamecell) ;
        HousesData.SummaryStructure.(HouName) = SummaryStructure.(HouName) ;
    end
    VarReport.FileFormat = 'pdf' ;
    VarReport.ReportName = strrep(ReportData.Title,' ','_') ;
    VarReport.Locale = 'eng' ;
    VarReport.DisplayDefault = 0 ;
end
HousesData.FileFormat = VarReport.FileFormat;
R = Report(VarReport.ReportName,VarReport.FileFormat) ;
R.Locale = VarReport.Locale ;
open(R)

%% Set the Front page
if getappdata(waitwindow,'canceling')
    delete(waitwindow)
    return
end

tp = TitlePage() ;
tp.Title = ReportData.Title ;
tp.Subtitle = ReportData.Subtitle ;
if ~isempty(ReportData.Logo)
    tp.Image = ReportData.Logo; 
end
tp.Author = ReportData.Author ;
tp.Publisher = ReportData.Publisher;
tp.PubDate = ReportData.PubDate ;

%% Create Table of contents
toc = TableOfContents();

add(R,tp);

br = {PageBreakBefore(true)};

Text1 = Text(MachineInfo.MLver) ; %Matlab Version
Text1.Bold = 'true' ;
Text1.Style = br ;

add(R,Text1);
add(R,MachineInfo.domain);
add(R,MachineInfo.host);
add(R,MachineInfo.ip);
add(R,MachineInfo.osname);
%% Add Table of contents
% Create and append the page break object
br = PageBreak();
add(R,br);

add(R,toc);

%% Create the report
% Here we are strucutring the report to know what are the variables we need
% to retrieve from each house and how to classifiy them
% ch = BuildChapter(Title,Figure,Table,Text,Content)
% ch = BuildSection(Title,VarName,Figure,Table,Text,Content)

%% Create the summary of all simulation
if getappdata(waitwindow,'canceling')
    delete(waitwindow)
    return
end

try
    HousesTag = fieldnames(HousesData.SummaryStructure) ;
catch
    HousesTag = 'No Houses to report' ;
end     
if isempty(HousesTag)
    HousesTag = 'No Houses to report' ;
end
if isa(HousesTag,'char')
    Text2Add = Text(HousesTag) ;
    add(R,Text2Add) ;
else
    try 
        HousesTag = HousesData.House2Report ;
    catch
        HousesTag = fieldnames(HousesData.SummaryStructure) ;
    end
    % The first chapter must be a summary of all houses in form of a table
    LanguagesAll = Languages ;
    Content = LanguagesAll.LanguagesRegional ;

    T = cell2table(Content') ;
    T.Properties.VariableNames = {'Available_Languages'} ;
    Table = AddTable(T,'Regional Languages',VarReport) ;
    br = PageBreak();
    add(R,br);
    add(R,Table);

    sz = [numel(HousesTag) 3];
    varTypes = {'string','string','string'};
    varNames = {'HouseID','Appliance','Size'};
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames) ;


    for i = 1:numel(HousesTag)
        HousesTagName = HousesTag{i} ;
        DataHouse = HousesData.SummaryStructure.(HousesTagName) ;
        HouseName = DataHouse.Headers ;
        HouseName = insertAfter(HouseName,'House', ' ') ;
        T(i,:) = {DataHouse.Headers, ...
                  DataHouse.Appliance_Max, ...
                  DataHouse.Building_Area};
    end
    chap.Title = 'Summary' ;
        section1.Title   = 'House Description';
        section1.Table   = T ;
        section1.Figure  = [] ;
        section1.Content = [] ;
        section1.Text    = {'This is a table'} ;
    chap.Content.Section1 = section1 ;

    ch = AddChapter(chap,'',HousesData,VarReport) ;

    add(R,ch);
    %% Create details for each house
    % Add the detailed information per house
    
    for i = 1:numel(HousesTag)
        spacecell = {' '} ;
        Message = strcat({'Reviewing house number'},spacecell,{num2str(i)},{'/'},{num2str(numel(HousesTag))}) ;

        waitbar(i/(numel(HousesTag) + 1),waitwindow,Message)

        chap = [] ;
        HousesTagName = HousesTag{i} ;
    %     HousesData.SummaryStructure.(HousesTagName).WindTurbine = num2str(round(RandBetween(0,1))) ;
        DataHouse = HousesData.SummaryStructure.(HousesTagName) ;
        HouseName = DataHouse.Headers ;
        HouseName = insertAfter(HouseName,'House', ' ') ;
        chapTitle = HouseName ;

        chap.Title = chapTitle ;
        HousesData.HouseTag = HousesTagName ;
        Section1 = BuildChapters(chap,HousesData,VarReport) ;

        if getappdata(waitwindow,'canceling')
            delete(waitwindow)
            close(R)
            return
        end

        ch = AddChapter(Section1,DataHouse,HousesData,VarReport) ;
    %     p2 = Paragraph('Here are some paragraphs after the forced page break.');
    %     add(ch,p2);
        add(R,ch);
    end
end
waitbar(1,waitwindow,'Opening report...')
close(R)
rptview(R.OutputPath);

delete(waitwindow)
end
%% Add variables into chapters
function chap = BuildChapters(chap,HousesData,VarReport)
    HousesData.VarReport = VarReport ;
%     BuildSection(HEADER TITLE,'VarName',ALL VARIABLE NAMES,VARIABLES TO
%     LINK) 
%     HEADER TITLE: Can be any title that will show in the section or
%     subsection of a chapter
%     'VarName': This is invariable
%     The first set of variables describe the long name of the variable,
%     the second part refers to the variable you want to attach to it.

    ChapterSSP = BuildSection('Small Scale Production') ;
        section1 = BuildSection('Wind Turbine','VarName','WindTurbine',...
                                'Text','Wind turbine characteristics',...
                                'CheckVariables',{'WTPowertot' 'WindSpeed' 'Lambdanom' 'Cp' 'MaxPowerWT' 'Baserotspeed' 'Pitch' 'EfficiencyWT'},...
                                HousesData) ;
        section2 = BuildSection('Photovoltaic panels','VarName','PhotoVol',...
                                'Text','Photovoltaic panels characteristics',...
                                'CheckVariables',{'NbrmodTot' 'Nbrmodser' 'Nbrmodpar' 'Aspect' 'Tilt' 'Voc' 'Isc' 'MaxPowerPV' 'LengthPV' 'WidthPV' 'NOCT' 'VTempCoff'},...
                                HousesData) ;
        section3 = BuildSection('Fuel Cells','VarName','FuelCell',...
                                'CheckVariables',{'MaxPowerFC'},...
                                HousesData) ;
    ChapterSSP = CompileChapter(ChapterSSP,section1,section2,section3) ; 
    
    ChapterUser = BuildSection('End users',...
                               'CheckVariables',{'inhabitants' 'Profile' 'User_Type'},...
                                HousesData) ;
        section1 = BuildSection('User Type','VarName','User_Type',...
                                'Text','This is the user type for this house. This determine how invested is the end user in the decision making of the house',...
                                'CheckVariables',{'User_Type'},...
                                 HousesData) ;
        section2 = BuildSection('User Profile','VarName','Profile',...
                                'Text','The user profile is the way people consumer electricity',...
                                'CheckVariables',{'Profile'},...
                                HousesData) ;
        section3 = BuildSection('Number of inhabitants','VarName','inhabitants',...
                                'CheckVariables',{'inhabitants'},...
                                 HousesData) ;
                      
    ChapterUser = CompileChapter(ChapterUser,section1,section2,section3) ; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ChapterTime = BuildSection('Simulation Time',...
                               'CheckVariables',{'StartingDate' 'EndingDate'},...
                                HousesData) ;
        section1 = BuildSection('Starting Date','VarName','StartingDate',...
                                'CheckVariables',{'StartingDate'},...
                                 HousesData) ;
        section2 = BuildSection('Ending Date','VarName','EndingDate',...
                                'CheckVariables',{'EndingDate'},...
                                HousesData) ;
        ChapterTime = CompileChapter(ChapterTime,section1,section2) ; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    ChapterContract = BuildSection('Electricity Contract');
        section1 = BuildSection('Electricity Contract','VarName','ContElec',...
                                'CheckVariables',{'ContElec' 'Contract' 'Low_Price' 'High_Price'},...
                                 HousesData) ;
        ChapterContract = CompileChapter(ChapterContract,section1) ; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    Chapterlocation = BuildSection('Building Characteristics');
        section1 = BuildSection('Geolocation of the building','VarName','Latitude',...
                                'CheckVariables',{'Latitude' 'Longitude'},...
                                 HousesData) ;
        section2 = BuildSection('Building size','VarName','Building_Area',...
                                'CheckVariables',{'Building_Area' 'hgt' 'lgts' 'lgte' 'pitchangle' 'aws'  'awe' 'awn' 'aww' 'ad' ...
                                                  'gwindow' 'n50'},...
                                 HousesData) ;
        Chapterlocation = CompileChapter(Chapterlocation,section1,section2) ; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    ChapterTher = BuildSection('Thermal characteristics') ;
        section1 = BuildSection('Geolocation of the building','VarName','uvs',...
                                'CheckVariables',{'uvs' 'uve' 'uvn' 'uvw' 'uvsw' 'uvew' 'uvnw' 'uvww' 'uvd' 'uvr' 'uvf'},...
                                 HousesData) ;
        section2 = BuildSection('Ventilation system','VarName','Ventil',...
                                'CheckVariables',{'Ventil' 'N0' 'Heat_recovery_ventil_annual' 'vent_elec'},...
                                 HousesData) ;
        section3 = BuildSection('Heating system','VarName','HeatingTechnology',...
                                'CheckVariables',{'HeatingTechnology' 'Heating_Tech' 'Charging_strategy' 'ComfortLimit' 'Temp_Set' ...
                                                  'NbrBatteries' 'prcntage' 'Building_storage_constant' 'Temp_cooling' 'PVprice' ...
                                                  'BatteryPrice' 'BatteryCapacity' 'ProfitBattery' 'RoundTripEfficiency' 'BatteryEmissions' ... 
                                                  'PVEmissions' 'ChargingHours' 'T_inlet'},...
                                 HousesData) ;
        ChapterTher = CompileChapter(ChapterTher,section1,section2,section3) ; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    ChapterMetering = BuildSection('Smart Metering') ;
        section1 = BuildSection('Metering system selected','VarName','Metering',...
                                'CheckVariables',{'Metering' 'Self' 'Comp' 'Goal' 'Bill'},...
                                 HousesData) ;
        ChapterMetering = CompileChapter(ChapterMetering,section1) ; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   
    ChapterAppliances = BuildSection('Appliances') ;
        section1 = BuildSection('Kitchen',...
                                'CheckVariables',{'WashMach' 'clWashMach' 
                                                  'DishWash' 'clDishWash'    
                                                  'Elec'     ''
                                                  'Kettle'   'clKettle'
                                                  'Oven'     'clOven'
                                                  'Coffee'   'clCoffee'
                                                  'MW'       'clMW'     
                                                  'Toas'     'clToas'
                                                  'Waff'     'clWaff'
                                                  'Fridge'   'clFridge'
                                                  'Tele'     'clTele'
                                                  'Laptop'   'clLaptop'
                                                  'Shaver'   'clShaver'
                                                  'Hair'     'clHair'
                                                  'Stereo'   'clStereo'
                                                  'Vacuum'   'clVacuum'
                                                  'Charger'  'clCharger'
                                                  'Iron'     'clIron'
                                                  'Elecheat' ''
                                                  'Sauna'    ''
                                                  'Radio'    'clRadio'  
                                                  ''         'clLight'  
                                                  },...
                                 HousesData) ;
        ChapterAppliances = CompileChapter(ChapterAppliances,section1) ; 
    
    
    
    
    chap = CompileChapter(chap,ChapterTime,ChapterContract,ChapterSSP,Chapterlocation,ChapterUser,ChapterMetering,ChapterTher,ChapterAppliances) ;
end
%-----------------------------------------------------------------------------%
function ch = BuildsubChapter(varargin)
    import mlreportgen.report.*
    import mlreportgen.dom.*
        
    if nargin <= 1
        if nargin
            Title = varargin{1} ;
            Figure = [] ;
            Table = [] ;
            Text = {} ;
            Content = [] ;
        else
            Title = 'Dummy chapter title' ;
            Figure = [] ;
            Table = [] ;
            Text = {} ;
            Content = [] ;
        end
        if isempty(Title)
            ch.Title = 'Dummy chapter title' ;
        else
            ch.Title = Title ;
        end
        if isempty(Figure)
            ch.Figure = [] ;
        else
            ch.Figure = Figure ;
        end
        if isempty(Table)
            ch.Table = [] ;
        else
            ch.Table = Table ;
        end
        if isempty(Text)
            ch.Text = {} ;
        else
            ch.Text = Text ;
        end
        if isempty(Content)
            ch.Content = [] ;
        else
            ch.Content = Content ;
        end
    else
        if ~mod(nargin,2)
            error('wrong number of pairs associated')
            %return;
        end
        ch.Title = varargin{1} ;
        for i = 2:2:nargin
            Var2Def       = varargin{i} ;
            Var2Def_Value = varargin{i + 1} ;
            ch.(Var2Def)  = Var2Def_Value ;
        end
        try
            ch.Figure      ;
        catch
            ch.Figure = [] ;
        end
        try
            ch.Text      ;
        catch
            ch.Text = {} ;
        end
        try
            ch.Table      ;
        catch
            ch.Table = [] ;
        end
        try
            ch.Content      ;
        catch
            ch.Content = [] ;
        end
    end
    
end %BuildChapter
%-----------------------------------------------------------------------------%
function ch = BuildSection(varargin)
    import mlreportgen.report.*
    import mlreportgen.dom.*
    
    if nargin <= 1
        if nargin
            Title    = varargin{1} ;
            VarName  = [] ;
            VarValue = [] ;
            Figure   = [] ;
            Table    = [] ;
            Text     = {} ;
            Content  = [] ;
        else
            Title    = 'Dummy chapter title' ;
            VarName  = [] ;
            VarValue = [] ;
            Figure   = [] ;
            Table    = [] ;
            Text     = {} ;
            Content  = [] ;
        end
        ch.Title    = Title ;
        ch.Figure   = Figure ;
        ch.Table    = Table ;
        ch.Text     = Text ;
        ch.Content  = Content ;
        ch.VarValue = VarValue ;
        
        if isempty(VarName)
            GenNbr = round(RandBetween(0,1000)) ;
            ch.VarName = strcat('DummyName',num2str(GenNbr)) ;
        else
            ch.VarName = Content ;
        end
    else
        if mod(nargin,2)
            error('wrong number of pairs associated')
        end
        ch.Title = varargin{1} ;
        for i = 2:2:nargin
            Var2Def       = varargin{i} ;
            if isa(Var2Def,'struct')
                try 
                    ch.VarValue = Var2Def.SummaryStructure.(Var2Def.HouseTag).(ch.VarName) ;
                catch
                    GenNbr = round(RandBetween(0,1000)) ;
                    ch.VarName = strcat('DummyName',num2str(GenNbr)) ;
                    ch.VarValue = '1' ;
                end
                VarReport = Var2Def.VarReport ;
                AllData = Var2Def;
            else
                Var2Def_Value = varargin{i + 1} ;
                if strcmp(Var2Def,'Text')
                    ch.(Var2Def)  = {Var2Def_Value} ;
                else
                    ch.(Var2Def)  = Var2Def_Value ;
                end
            end
        end
        try
            ch.Figure ;
        catch
            if sum(strcmp(ch.VarName,{'Profile','Flat'}))
                % Write the exception to add predefined Figures
                ch.Figure = ExceptionFigure(ch.VarName,AllData) ;
            else
                ch.Figure = [] ;
            end
        end
        try
            ch.Text ;
        catch
            ch.Text = {} ;
        end
        try
            ch.CheckVariables ;
        catch
            ch.CheckVariables = [] ;
        end
        try
            ch.Table ;
        catch
            if ~isempty(ch.CheckVariables)
                if ~isempty(ch.CheckVariables) %&& isempty(subContent)
                    [Tablev,Textv] = TableVar(ch.CheckVariables,Var2Def,VarReport) ;
                    ch.Text = Textv ;
                    ch.Table = Tablev ;
                end
            else
                ch.Table = [] ;
            end
        end
        try
            ch.Content ;
        catch
            ch.Content = [] ;
        end
        try
            ch.VarName ;
        catch
            GenNbr = round(RandBetween(0,1000)) ;
            ch.VarName = strcat('DummyName',num2str(GenNbr)) ;
        end
    end
end %BuildChapter
%-----------------------------------------------------------------------------%
function MainChap = CompileChapter(MainChap,varargin)
    import mlreportgen.report.*
    import mlreportgen.dom.*
    
    if nargin <= 1
        error('Not enough input arguments')
    end
    
    for i = 1:(nargin - 1)
        if isempty(varargin{i}.Content)
            if ~strcmp(varargin{i}.VarValue,'0') && ~isempty(varargin{i}.VarValue)
                Text = strcat({'The Table below looks at all variables that defines the'},{' '},{varargin{i}.Title}) ; 
                if isempty(varargin{i}.Text)
                    varargin{i}.Text = Text(1)                          ;
                else
                    varargin{i}.Text(end + 1) = Text ;
                end
            else
                varargin{i}.VarValue = '0' ;    
            end
        else
            varargin{i}.VarValue = '1'                               ;
        end
        
        if ~strcmp(varargin{i}.VarValue,'0')
            MainChap.Content.(varargin{i}.VarName) = varargin{i} ;
        end
    end
    
end
%-----------------------------------------------------------------------------%
%% Add your Chapter Here
function ch = AddChapter(chap, DataHouse,HousesData,VarReport)
    import mlreportgen.report.*
    import mlreportgen.dom.*
%     br = {PageBreakBefore(true)};
    
    
    ch = Chapter(chap.Title);
    ContentName = fieldnames(chap.Content) ;
    for i = 1:numel(ContentName)
        Title = chap.Content.(ContentName{i}).Title ;
        Figure = chap.Content.(ContentName{i}).Figure ;
        Table = chap.Content.(ContentName{i}).Table ;
        Text1 = chap.Content.(ContentName{i}).Text ;
        subContent = chap.Content.(ContentName{i}).Content ;
        Sec = AddSection(Title,Figure,Table,Text1,subContent,DataHouse,HousesData,VarReport) ;
        add(ch,Sec);
    end
end %AddChapter
%-----------------------------------------------------------------------------%
function Sec = AddSection(SectionTitle, Figure, Table,Text, Content,DataHouse,HousesData,VarReport)
    import mlreportgen.report.*
    import mlreportgen.dom.*
    Sec = Section(SectionTitle) ;
    
    if ~isempty(Text)
        for i = 1:numel(Text)
            add(Sec,Text{i});
        end
    end
    if ~isempty(Figure)
        test = Image(Figure) ;
        test.Style = {ScaleToFit};
        add(Sec,test);
    end
    if ~isempty(Table)
        add(Sec,Table);
    end
    
    if ~isempty(Content) 
        ContentName = fieldnames(Content) ;
        for i = 1:numel(ContentName)
            Title = Content.(ContentName{i}).Title ;
            try 
                Figure = Content.(ContentName{i}).Figure ;
            catch
                Figure = '';
            end
            try 
                Table = Content.(ContentName{i}).Table ;
            catch
                Table = '';
            end
            try 
                Text = Content.(ContentName{i}).Text ;
            catch
                Text = {};
            end
            try
                subContent = Content.(ContentName{i}).Content ;
            catch
                subContent = '' ;
            end
            try
                LoopVariable = Content.(ContentName{i}).CheckVariables ;
            catch
                LoopVariable = '' ;
            end
            if ~isempty(LoopVariable) %&& isempty(subContent)
                [Table,Text] = TableVar(LoopVariable,HousesData,VarReport) ;
            end
            Subsection = AddSection(Title,Figure,Table,Text,subContent,DataHouse,HousesData,VarReport) ;
            add(Sec,Subsection);
        end
    end
    
end %Sec
%-----------------------------------------------------------------------------%
function [Table,Text] = TableVar(LoopVariable,HousesData,VarReport)

    DisplayDefault = VarReport.DisplayDefault ;
    if ischar(DisplayDefault)
        DisplayDefault = str2double(DisplayDefault) ;
    end
    if ~isempty(LoopVariable) %&& isempty(subContent)
        % This is when we loop through the variables
        ID          = {} ; 
        Defined     = {} ;
        Name        = {} ;
        Value       = {} ;
        Class       = {} ;
        VarDefault  = 0 ;
        VarUD       = 0 ;
        VarUD_Display = 0 ;
        DataHouse = HousesData.SummaryStructure.(HousesData.HouseTag) ;
        DisplayUD = DisplayDefault ;
        % Loop through each variable. If there is only 1, then it
        % is a character. If there are multiple, then it is a cell
        % array
        AppliancesList = HousesData.AppliancesList(:,3) ;
        AppliancesListCat = HousesData.AppliancesList(:,4) ;
        for VarVal = 1:(max(size(LoopVariable,1),size(LoopVariable,2)))
            App = 0 ;
            if numel(LoopVariable) == 1
                Var2Look = LoopVariable{VarVal} ;
            else
                Var2Look = LoopVariable{VarVal} ;
            end
            if isempty(Var2Look) && size(LoopVariable,2) > 1
                if numel(LoopVariable) == 1
                    Var2Look = LoopVariable{VarVal,2} ;
                else
                    Var2Look = LoopVariable{VarVal,2} ;
                end
            end
            if sum(strcmp(AppliancesList,Var2Look))
                % This means that this is an appliance. 1 Exception has to be made for the lighting system                
                Apprun = find(strcmp(AppliancesList,Var2Look)==1) ;
                ApprunCat = AppliancesListCat{Apprun} ; 
                if ~isempty(ApprunCat)
                    AllCategories = DataHouse.(ApprunCat) ;
                else
                    AllCategories = '' ;
                end
                App = 1 ;
            elseif sum(strcmp(AppliancesListCat,Var2Look))
                if strcmp(Var2Look,'clLight')
                    App = 1 ;
                else
                    continue;
                end
            end
            
        % Look for the default value in the varname
            VariableSize = size(DataHouse.(Var2Look),1) ;
            defVal = HousesData.varname.(Var2Look).Defaultvalue;
            %%%%% Compare the default value with the input value
            if strcmp(DataHouse.(Var2Look),defVal)
                % If the input value is the same than default
                    % Add a row to the table and set it as default value
                VarDefault = VarDefault + 1;
                if DisplayUD == 1
                    continue;
                end
                VarUD = VarUD + 1;
            else
                % If not
                    % Add a row to the table and set it as user defined
                    % value
                VarUD = VarUD + 1;
                VarUD_Display = VarUD_Display + 1;
            end
            
            % If it is an appliance, create a different table
            if App == 1
                if isa(AllCategories,'char')
                    AllCategories = {AllCategories} ;
                end
               uniqueelem = unique(AllCategories) ;
               VariableSize2 = numel(uniqueelem) ;
               for icell = 1:VariableSize2
                   String1 = uniqueelem{icell} ;
                   Quantity = sum(strcmp(String1,AllCategories)) ;
                   Quantity2 = DataHouse.(Var2Look) ;
                   if Quantity > 0
                        if icell > 1
                           ID{end + 1}      = '';
                           Name{end + 1}    = '';
                           Class{end + 1}   = String1 ;
                           Value{end + 1}   = Quantity ;
                           Defined{end + 1} = 'User defined' ;
                        elseif ~strcmp(Quantity2,'0')
                           ID{end + 1}      = Var2Look ;
                           Name{end + 1}    = HousesData.varname.(Var2Look).LongName;
                           Class{end + 1}   = String1 ;
                           Value{end + 1}   = Quantity ;
                           Defined{end + 1} = 'User defined' ;
                        else
                           ID{end + 1} = Var2Look;
                           Name{end + 1} = HousesData.varname.(Var2Look).LongName ;
                           Class{end + 1} = '' ;
                           Value{end + 1}   = Quantity ;
                           Defined{end + 1} = 'Default Value' ;
                        end
                   end
               end
            else
                ID{VarUD} = Var2Look ;
                Name{VarUD} = HousesData.varname.(Var2Look).LongName;
                if strcmp(DataHouse.(Var2Look),defVal) 
                    Defined{end + 1} = 'Default Value' ;
                else
                    Defined{end + 1} = 'User defined' ;
                end
                if isa(DataHouse.(Var2Look),'cell')
                    ValueTemp = DataHouse.(Var2Look) ;
                    for icell = 1:VariableSize
                        Value{end + icell} = ValueTemp{icell} ;
                    end
                else
                    Value{VarUD} = DataHouse.(Var2Look) ;
                end
            end
            
        end

        Text1 = strcat({'There are'},{' '},{num2str(VarDefault)},{' '},'variable with the default setting') ; 
        Text2 = strcat({'There are'},{' '},{num2str(VarUD_Display)},{' '},'variable with user defined settings') ; 

        Text = {Text1{1} Text2{1}} ;
        
        if ~isempty(ID)
%             Var2Look
            if isequal(size(ID), size(Name), size(Defined), size(Value))
                if App == 1
                    T = table(ID',Name',Defined',Class',Value') ;
                    T.Properties.VariableNames = {'ID','Name','Defined','Class','Value'} ;
                else
                    T = table(ID',Name',Defined',Value') ;
                    T.Properties.VariableNames = {'ID','Name','Defined','Value'} ;
                end
                Table = AddTable(T, 'Customise caption',VarReport) ;
            else
                % There is a problem in size ector
                y= 1;
                Table = [] ;
            end
        else
            Table = [] ;
        end
    end
end
%-----------------------------------------------------------------------------%
function [filename] = ExceptionFigure(VarName, Housedata)
    Path = mfilename('fullpath') ;
    folder = dbstack ;
    filename = folder.file ;
    filename_noext = erase(filename,'.m') ;
    filePath = erase(Path,filename_noext) ;
    switch VarName
        case 'Profile'
            ProfileSelected = Housedata.SummaryStructure.(Housedata.HouseTag).Profile ;
            
            switch ProfileSelected
                case '1'
                    filename = strcat(filePath,'Images',filesep,'Profile1.png');
                case '2'
                    filename = strcat(filePath,'Images',filesep,'Profile2.png');
                otherwise
                    filename = strcat(filePath,'Images',filesep,'NoProfile.png');
            end
    end
end % ExceptionFigure
%-----------------------------------------------------------------------------%
function Tableout = AddTable(Content, Caption,VarReport)
    import mlreportgen.report.*
    import mlreportgen.dom.*
    
    FileFormat = VarReport.FileFormat ;
    doc = Document('test');
    % First create the table as a dom class object
    % Full spec here https://se.mathworks.com/help/rptgen/ug/mlreportgen.dom.table-class.html
    
    table1 = append(doc,Content);
    
    % Format the table from the dome object (line colours etc...)
    if sum(strcmp(FileFormat,{'pdf','html'})) 
        table1.HeaderRule.Border = 'solid';
    else
        table1.HeaderRule.Border = 'single';
    end
    table1.ColSep = 'solid';
    table1.HeaderRule.BorderColor  = 'black';
    table1.TableEntriesHAlign = 'left' ;
    table1.TableEntriesVAlign = 'top';
    
%     table1.Style = {Border('inset','crimson','6pt'), ...
%                ColSep('double','DarkGreen','3pt'), ...
%                RowSep('double','Gold','3pt'), ...
%                Width('50%')};
    
     % format the table as a report class object for caption and other
     % reporting elements
     
     Tableout = BaseTable(table1);
     Tableout.Title = Caption; 
end %Sec
%-------------------------------------------------------------------------% 
function AppliancesList = AppList
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
end