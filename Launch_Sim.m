function Launch_Sim(varargin)
%% Building up the folder trees in the Output file


dbstop if error

profilerboo = false ;

if profilerboo
    profile on;
else
    profile off;
end
%% What would you like to do
NewStart = 0 ;
if NewStart == 1
    choice = questdlg('Would you like to do?', ...
        'Start', ...
        'Create new houses','Use existing houses','Cancel','Cancel');

    switch choice
        case 'Cancel'
            return;
        case 'Create new houses'
            waitfor(GUIModelHEMS)
        case 'Use existing houses'
            ExistingFile_path = uigetdir; % Must be a csv file
    end
end
%% Create the UIwaitbar for the simulation time
% This come on top of the information places in the log file.
SimulationTimeWindow = waitbar(0,'Simulation initialisation...','Name','Running simulation...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(SimulationTimeWindow,'canceling',0);

spacecell = {' '} ;

%% Creating your simulation
% If the function is triggered on its own, you will have to provide the
% different information from the start
if nargin == 0
    set(SimulationTimeWindow, 'Units', 'Normalized')
    set(SimulationTimeWindow, 'Units', 'Pixels', 'Position', [100 100 400 100])
    folder_name = uigetdir;
    %%%
    if folder_name == 0; return; end
    [~,FileName] = fileparts(folder_name);
    if strcmp(FileName,'Output')
        SimDetails.Output_Folder = folder_name ;
    else
        SimDetails.Output_Folder = strcat(folder_name,filesep,'Output'); 
    end
    SimDetails.Project_ID = ('');
    %%%
    
    prompt = {'Project Name or Number: ','Number of Buildings: '};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {'Project Name','1'};
    ValidInput = 0;
    while ValidInput < 2
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if isempty(answer)
            return;
        end
        ValidInput1 = ~isempty(answer{1}) ;
        ValidInput2 = ~isnan(str2double(answer{2})) ;
        ValidInput = ValidInput1 + ValidInput2;
        if ValidInput < 2
            if ValidInput == 0
                promptv2{1} = 'Project must have a name';
                promptv2{2} = 'Number of Buildings must be a number';
            elseif ValidInput1 == 0
                promptv2{1} = 'Project must have a name';
            elseif ValidInput2 == 0
                promptv2{1} = 'Number of Buildings must be a number';
            end
            waitfor(warndlg(promptv2,'Error','modal'));
        end
    end
    while isempty(SimDetails.Project_ID)
    %%%
        SimDetails.Project_ID = answer{1} ; %input('Project Name or Number: ', 's'); 
        listing = dir(SimDetails.Output_Folder);
        for foldername = 1:length(listing)
            if strcmpi(listing(foldername).name, SimDetails.Project_ID)
    %%%
                choice = questdlg('Would you like to replace the current folder?', ...
                    'Yes', ...
                    'No');
                switch choice
                    case 'Yes'
                        rmdir(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID),'s')
                    case 'No'
                        %SimDetails.Project_ID = ('');
                        SimDetails.Project_ID = strcat(SimDetails.Project_ID,'(Copy)') ;
                end
            end
        end
    end
    %%%
    rmpath(genpath(strcat(SimDetails.Output_Folder,SimDetails.Project_ID)));
else
    folder_name = varargin{1};
    data = varargin{3};
    Project_ID = varargin{2};
    hObject = varargin{4};
    %%%
    % Set the waiting window in the middle of the existing SimLogWindow
    movegui(SimulationTimeWindow,'center');
    
    AddText = 'Compiling simulation ...' ;
    addLineSim(hObject,data,AddText)
    AddText = datestr(now) ;
    addLineSim(hObject,data,AddText)
    AddText = '    Initiating folder output creation ...' ;
    addLineSim(hObject,data,AddText)
    HouseLists = fieldnames(data.SummaryStructure) ;
    % '10s' '1 minute' '15 minutes' '30 minutes' 'Hourly'
    switch data.SummaryStructure.(HouseLists{1}).Time_Step
        case 'Hourly'
            timestep            = 24;  %%%%%% To be adatped to the time step definition
            Time_Sim.MinperIter = 60 ;
        case '10s'
            timestep            = 24 * 360 ;
            Time_Sim.MinperIter = 10/60 ;
        case '1 minute'
            timestep            = 24 * 60 ;
            Time_Sim.MinperIter = 1 ;
        case '15 minutes'
            timestep            = 24 * 4 ;
            Time_Sim.MinperIter = 15 ;
        case '30 minutes'
            timestep            = 24 * 2 ;
            Time_Sim.MinperIter = 30 ;
        otherwise
            timestep            = 24;
            Time_Sim.MinperIter = 60 ;
    end
    
    Time_Sim.SecperIter = Time_Sim.MinperIter * 6 ;
    
    if folder_name == 0; return; end
    [~,FileName] = fileparts(folder_name);
    if strcmp(FileName,'Output')
        SimDetails.Output_Folder = folder_name ;
    else
        SimDetails.Output_Folder = strcat(folder_name,filesep,'Output'); 
    end
    SimDetails.Project_ID = Project_ID;
    
    listing = dir(SimDetails.Output_Folder);  
    if sum(strcmp({listing.name},Project_ID)) >= 1
%%%
        choice = questdlg('Would you like to replace the current folder?', ...
            'Yes', ...
            'No');
        switch choice
            case 'Yes'
                % If the file is busy, it cannot be removed, 
                %%%% ADD EXCEPTION AND RETURN THE FUNCTION %%%%%%
                Directory = strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID) ;
                try
                    rmdir(Directory,'s')
                catch
                    
                    A = dir( Directory ) ;
                    for k = 1:length(A)
                        delete([ Directory  '\' A(k).name])
                    end
                    rmdir( Directory  )
                end
                AddText = '    Existing folder has been deleted and replaced by the same folder name ...' ;
                addLineSim(hObject,data,AddText)
            case 'No'
                return;
            case 'Cancel'
                return;
        end
    end
    rmpath(genpath(strcat(SimDetails.Output_Folder,SimDetails.Project_ID)));
end
    %% Import the appliances signature profile
    InfoDisp = '    Importing Appliance Profile ...' ;
    addLineSim(hObject,data,InfoDisp) ;
    
    [App.AppArr] = Appliance10sProfile('AppProf.csv') ;
    
    InfoDisp = '    Appliance Profile Imported...' ;
    addLineSim(hObject,data,InfoDisp) ;
    
    %% Create the Output folder and the tree
    InfoDisp = '    Creating Project folder output ...' ;
    if nargin == 0
        disp(InfoDisp);
    else
        addLineSim(hObject,data,InfoDisp)
    end
    rehash() 
    if isfolder('Output')==0
        mkdir(folder_name, 'Output')
        addfile(SimDetails.Project_ID, SimDetails.Output_Folder);
    else
        addfile(SimDetails.Project_ID, SimDetails.Output_Folder);
    end
    %%%
    if nargin == 0
        Nbr_Building = str2double(answer{2}) ; %input('Number of Buildings: ', 's');
    else
        AllHouses = fieldnames(data.Simulationdata);
        Nbr_Building = size(fieldnames(data.Simulationdata),1);
    end
    SimDetails.IDhouselist = zeros(1, Nbr_Building);
    AddText = '    Output and project folder created ...' ;
    if nargin == 0
        disp(AddText);
    else
        addLineSim(hObject,data,AddText)
    end
    
tic
%% Import the Excel file as input file for the building specifications
if nargin == 0
    InfoDisp = 'Importing the Excel database ...' ;
    disp(InfoDisp);
    %[Input_Data]= Read_Excel_File(Nbr_Building,2);
    formatSpec ='%f%f%f%f%f%f%f%f%f%f%f%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%s%f%f%f%s%f%s%f%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%s%f%f%f%s%s%f%f%f%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%f';
    T = readtable('Variables and Matrix.csv','Delimiter',',','Format',formatSpec);
    c = table2cell(T);
    d = [T.Properties.VariableNames;c];
    S = table2struct(T) ;
    S = struct_string_replace(S,'Vihrevirta','Virhevirta') ;
    [Input_Datav2] = getInputDatav2 ;
    % Modify the Input Data to have the same format than the GUI input.
    for i = 1:size(S,1)
        Fnames = fieldnames(S(i));
        for ix = 1:size(Fnames,1)
            switch Fnames{ix}
                case 'Housenbr'
                    Input_Datav2.Headers{i,1} = strcat('House',num2str(S(i).(Fnames{ix}))) ;
                case 'StartDay'
                    Startingdate = datestr(datenum(S(i).StartYear,S(i).StartMonth,S(i).StartDay),'dd/mm/yyyy') ;
                    Input_Datav2.StartingDate{i,1} = Startingdate ;
                case 'EndDay'
                    Endingdate = datestr(datenum(S(i).EndYear,S(i).EndMonth,S(i).EndDay),'dd/mm/yyyy') ;
                    Input_Datav2.Endingdate{i,1} = Endingdate ;
                otherwise
                    Input_Datav2.(Fnames{ix}){i,1} = S(i).(Fnames{ix});
            end
        end
    end
else
    InfoDisp = '    Importing data ...' ;
    addLineSim(hObject,data,InfoDisp) ;
    
    Input_Datav3 = data.Simulationdata ;
    
    InfoDisp = '    Data imported ...' ;
    addLineSim(hObject,data,InfoDisp) ;
end

%% Time boundaries 
%%%
Allfieldsname = fieldnames(Input_Datav3) ;

    Starting_Days = zeros(1, Nbr_Building)  ;
    Ending_Dates  = zeros(1, Nbr_Building)  ;
    maxnbrstep    = 0                       ;
    TotalStepTime = 0                       ;
    for Buildtime = 1 : (Nbr_Building)
        HouseInfo = Input_Datav3.(Allfieldsname{Buildtime}) ;
        Starting_Days(Buildtime) = datenum(datetime(data.Simulationdata.(AllHouses{Buildtime}).StartingDate,'InputFormat','dd/MM/yyyy'))  ;
        Ending_Dates(Buildtime) = datenum(datetime(data.Simulationdata.(AllHouses{Buildtime}).EndingDate,'InputFormat','dd/MM/yyyy'))  ;
        Time_Sim.nbrstep.(HouseInfo.Headers) = (Ending_Dates(Buildtime) - Starting_Days(Buildtime) + 1) * timestep ;
        maxnbrstep = max(maxnbrstep,Time_Sim.nbrstep.(HouseInfo.Headers)) ;
        TotalStepTime = TotalStepTime + Time_Sim.nbrstep.(HouseInfo.Headers) ;
    end
    
    Date_Sim(1,:) = Starting_Days;
    Date_Sim(2,:) = Ending_Dates;
%% Distribution
% For size reason, in the distributed version, the database is restricted
% to the year 2012.
Public = data.Public ; %1: distributed, 0:working file.
if Public == 1
    AddText = 'Distributed Version' ;
          addLineSim(hObject,data,AddText)

    Time_Sim.YearStartSim = 2012 ;
    Time_Sim.YearStartSim2004 = 2012 ;
     if or(min(Starting_Days) < datenum(2012,1,1), datenum(2012,12,31) < max(Ending_Dates))
          AddText = 'Dates are out of the database. The database is provided for the year 2012 only' ;
          warning(AddText)
          addLineSim(hObject,data,AddText)
          addLineSim(hObject,data,'    Simulation aborted')
          return
     end
     % JARI'S ADDITION
elseif isfield(data, 'FileSelection')
% elseif handles.FileSelection.TemperatureChanged == 1 || handles.FileSelection.RadiationChanged == 1 || handels.FileSelection.PriceChanged == 1 || handles.FileSelection.EmissionChanged == 1
    if isfield(data.FileSelection, 'StartYearTempRad')
        Time_Sim.YearStartSim = str2double(data.FileSelection.StartYearTempRad);
    else
        Time_Sim.YearStartSim = 2000;
    end
    if isfield(data.FileSelection, 'StartYearPriceEmissions')
        Time_Sim.YearStartSim2004 = str2double(data.FileSelection.StartYearPriceEmissions);
    else
        Time_Sim.YearStartSim2004 = 2004;
    end
    % END OF JARI'S ADDITION
else
    Time_Sim.YearStartSim = 2000 ;
    Time_Sim.YearStartSim2004 = 2004 ;
end

SimDate             = datetime(Date_Sim(1,1),'ConvertFrom','datenum') ;
SimDateEnd          = datetime(Date_Sim(2,1),'ConvertFrom','datenum') ;

forc = load('Global_Irradiance_forecast_monthly2050.mat') ;
All_Var.Global_Irradiance_For_Monthly2050 = forc.Global_Irradiance_For_Monthly' ; 

forc = load('Global_Irradiance_forecast_monthly2012.mat') ;
All_Var.Global_Irradiance_For_Monthly2012 = forc.Global_Irradiance_For_Monthly' ; 

if leapyear(SimDate.Year)
    All_Var.Global_Irradiance_For_Monthly2050 = [All_Var.Global_Irradiance_For_Monthly2050(1:1416,:) ;...
                                                 All_Var.Global_Irradiance_For_Monthly2050(1393:1416,:) ;...
                                                 All_Var.Global_Irradiance_For_Monthly2050(1417:end,:)];
    All_Var.Global_Irradiance_For_Monthly2012 = [All_Var.Global_Irradiance_For_Monthly2012(1:1416,:) ;...
                                                 All_Var.Global_Irradiance_For_Monthly2012(1393:1416,:) ;...
                                                 All_Var.Global_Irradiance_For_Monthly2012(1417:end,:)];
end

Array_In         = All_Var.Global_Irradiance_For_Monthly2050 ;
ArrayStartYear   = Date_Sim(1,1) ;
ResIni           = 'Hourly'          ;
FinalYear        = Date_Sim(2,1)   ;
ResFinal         = HouseInfo.Time_Step ;

[ ~ , All_Var.Global_Irradiance_For_Monthly2050,~] = Test_Database_extract_Extrapolate(Array_In, ...
                                                      ArrayStartYear,...
                                                      ResIni ,...
                                                      ResFinal , ...
                                                      ArrayStartYear, ...
                                                      FinalYear , ...
                                                      'Interpolate', ...
                                                      {'Temperature1' 'Temperature2' 'Temperature3' 'Temperature4'}) ;
                                                  
Array_In         = All_Var.Global_Irradiance_For_Monthly2012 ;
ArrayStartYear   = min(Date_Sim(1,:))   ;
ResIni           = 'Hourly'             ;
FinalYear        = max(Date_Sim(2,:))   ;

[ ~ , All_Var.Global_Irradiance_For_Monthly2012,~] = Test_Database_extract_Extrapolate(Array_In, ...
                                                      ArrayStartYear,...
                                                      ResIni ,...
                                                      ResFinal , ...
                                                      ArrayStartYear, ...
                                                      FinalYear , ...
                                                      'Interpolate', ...
                                                      {'Temperature1' 'Temperature2' 'Temperature3' 'Temperature4'}) ;
                                                  
All_Var.Global_Irradiance_For_Monthly2012 = table2timetable(All_Var.Global_Irradiance_For_Monthly2012) ;
All_Var.Global_Irradiance_For_Monthly2050 = table2timetable(All_Var.Global_Irradiance_For_Monthly2050) ;

%%%
    Time_Sim.Time_Resolution = HouseInfo.Time_Step ;
    % JARI'S ADDITION!
%     if strcmp(data.WeatherSelection,'EPW')
%         
%         EPW_Var             = data.EPW ;
%         Default_Var         = load('Smart_House_Data_MatLab.mat');
%         SimDate             = datetime(Date_Sim(1,1),'ConvertFrom','datenum') ;
%         EPWDate             = datetime(EPW_Var.date,'ConvertFrom','datenum') ;
%         
%         Array_InTemp        = EPW_Var.Dry_Bulb_Temperature               ;
%         ResIniTemp          = 'Hourly'                                   ;
%         ArrayStartYearTemp  = datenum(SimDate.Year,EPWDate(1).Month, EPWDate(1).Day)                           ;
%         
%         Array_InSolar       = EPW_Var.Global_Horizontal_Radiation        ;
%         ResIniSolar         = 'Hourly'                                   ;
%         ArrayStartYearSolar = datenum(SimDate.Year,EPWDate(1).Month, EPWDate(1).Day)                           ;
%                 
%         if leapyear(SimDate.Year)
%             Array_InTemp = [Array_InTemp(1:1416,:) ;...
%                                                          Array_InTemp(1393:1416,:) ;...
%                                                          Array_InTemp(1417:end,:)];
%             Array_InSolar = [Array_InSolar(1:1416,:) ;...
%                                                          Array_InSolar(1393:1416,:) ;...
%                                                          Array_InSolar(1417:end,:)];
%         end
%         
%         ResIniPrice         = 'Hourly'                                   ;
%         Array_InPrice       = Default_Var.Hourly_Real_Time_Pricing       ;
%         ArrayStartYearPrice = datenum(2004,1,1)                          ;
%         
%         ResIniEmissions     = 'Hourly'     ;
%         Array_InEmissions       = Default_Var.EmissionFactorNetto ; % This integrates the import and export from the country
%         
%         if Public == 1
%             ArrayStartYearEmissions  = datenum(2012,1,1) ; %2000
%         else
%             ArrayStartYearEmissions  = datenum(2011,1,1) ; %2000
%         end

    if strcmp(data.WeatherSelection,'EPW')
        
        EPW_Var             = data.EPW ;
        Default_Var         = load('Smart_House_Data_MatLab.mat');
        SimDate             = datetime(Date_Sim(1,1),'ConvertFrom','datenum') ;
        EPWDate             = datetime(EPW_Var.date,'ConvertFrom','datenum') ;
        
        Array_InTemp        = EPW_Var.Dry_Bulb_Temperature               ;
        ResIniTemp          = 'Hourly'                                   ;
        ArrayStartYearTemp  = datenum(SimDate.Year,EPWDate(1).Month, EPWDate(1).Day)                           ;
        
        Array_InSolar       = EPW_Var.Global_Horizontal_Radiation        ;
        ResIniSolar         = 'Hourly'                                   ;
        ArrayStartYearSolar = datenum(SimDate.Year,EPWDate(1).Month, EPWDate(1).Day);
        
        Array_InWind        = EPW_Var.Wind_Speed;
        ResIniWind          = 'Hourly';
        ArrayStartYearWind  = datenum(SimDate.Year,EPWDate(1).Month, EPWDate(1).Day);
        
        ResIniWater         = 'Hourly'     ;
        Array_InWater       = Default_Var.T_water ;
        if Public == 1
            ArrayStartYearWater  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearWater  = datenum(2000,1,1) ; %2000
        end
        
%         ResIniPrice         = 'Hourly'     ;
%         Array_InPrice       = Default_Var.Hourly_Real_Time_Pricing ;
%         if Public == 1
%             ArrayStartYearPrice  = datenum(2012,1,1) ; %2000
%         else
%             ArrayStartYearPrice  = datenum(2004,1,1) ; %2000
%         end
        
        ResIniEmissions     = 'Hourly'     ;
        Array_InEmissions   = Default_Var.EmissionFactorNetto ; % This integrates the import and export from the country
        
        if Public == 1
            ArrayStartYearEmissions  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearEmissions  = datenum(2011,1,1) ; %2000
        end
        
        if leapyear(SimDate.Year)
            Array_InTemp = [Array_InTemp(1:1416,:) ;...
                                                         Array_InTemp(1393:1416,:) ;...
                                                         Array_InTemp(1417:end,:)];
            Array_InSolar = [Array_InSolar(1:1416,:) ;...
                                                         Array_InSolar(1393:1416,:) ;...
                                                         Array_InSolar(1417:end,:)];
                                                     
            Array_InWind = [Array_InWind(1:1416,:) ;...
                                                         Array_InWind(1393:1416,:) ;...
                                                         Array_InWind(1417:end,:)];
        end
        
        ResIniPrice         = 'Hourly'                                   ;
        Array_InPrice       = Default_Var.Hourly_Real_Time_Pricing       ;
        if Public == 1
            ArrayStartYearPrice  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearPrice  = datenum(2004,1,1) ; %2000
        end
%         ArrayStartYearPrice = datenum(2004,1,1)                          ;

    elseif strcmp(data.WeatherSelection,'Default')    
        
        Default_Var = load('Smart_House_Data_MatLab.mat');
        %%%% Add the public version that starts at 2012
        
        ResIniTemp          = 'Hourly'     ;
        Array_InTemp        = Default_Var.Hourly_Temperature ;
        if Public == 1
            ArrayStartYearTemp  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearTemp  = datenum(2000,1,1) ; %2000
        end
        ResIniSolar         = 'Hourly'     ;
        Array_InSolar       = Default_Var.Hourly_Solar_Radiation ;
        if Public == 1
            ArrayStartYearSolar  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearSolar  = datenum(2000,1,1) ; %2000
        end
        
        ResIniWind         = 'Hourly'     ;
        Array_InWind       = Default_Var.Hourly_Wind_Speed ;
        if Public == 1
            ArrayStartYearWind  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearWind  = datenum(2000,1,1) ; %2000
        end
        
        ResIniWater         = 'Hourly'     ;
        Array_InWater       = Default_Var.T_water ;
        if Public == 1
            ArrayStartYearWater  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearWater  = datenum(2000,1,1) ; %2000
        end
        
        ResIniPrice         = 'Hourly'     ;
        Array_InPrice       = Default_Var.Hourly_Real_Time_Pricing ;
        if Public == 1
            ArrayStartYearPrice  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearPrice  = datenum(2004,1,1) ; %2000
        end
        
        ResIniEmissions     = 'Hourly'     ;
        Array_InEmissions   = Default_Var.EmissionFactorNetto ; % This integrates the import and export from the country
        
        if Public == 1
            ArrayStartYearEmissions  = datenum(2012,1,1) ; %2000
        else
            ArrayStartYearEmissions  = datenum(2011,1,1) ; %2000
        end
        
    elseif strcmp(data.WeatherSelection,'Individual')
        Default_Var = load('Smart_House_Data_MatLab.mat');
%         All_Var     = load('Smart_House_Data_MatLab.mat');
        
        %%% Import the temperature file
        if isfield(data,'FileSelection')
            if isfield(data.FileSelection,'TemperatureFile')
                if ~isempty(data.FileSelection.TemperatureFile)
                    Temperaturefile      = load(data.FileSelection.TemperatureFile);
                    FieldName            = fieldnames(Temperaturefile);
                    
                    ResIniTemp           = 'Hourly'     ;
                    Array_InTemp         = Temperaturefile.(FieldName{:});
                    
                    if size(Array_InTemp,1)<size(Array_InTemp,2)
                        Array_InTemp = Array_InTemp';
                    end
                    
                    ArrayStartYearTemp   = datenum(SimDate.Year,1,1) ; % This is a random year that has 8760 h as thought for importing files
                end
                if leapyear(SimDate.Year)
                    Array_InTemp = [Array_InTemp(1:1416,:) ;...
                                    Array_InTemp(1393:1416,:) ;...
                                    Array_InTemp(1417:end,:)];
                end
            else
                ResIniTemp          = 'Hourly'     ;
                Array_InTemp        = Default_Var.Hourly_Temperature ;
                ArrayStartYearTemp  = datenum(2000,1,1) ;
            end
            
            if isfield(data.FileSelection,'RadiationFile')
                if ~isempty(data.FileSelection.RadiationFile)
                    Radiationfile   = load(data.FileSelection.RadiationFile);
                    FieldName       = fieldnames(Radiationfile);
                    
                    ResIniSolar         = 'Hourly'     ;
                    Array_InSolar        = Radiationfile.(FieldName{:});
                    
                    if size(Array_InSolar,1)<size(Array_InSolar,2)
                        Array_InSolar = Array_InSolar';
                    end
                    
                    ArrayStartYearSolar  = datenum(SimDate.Year,1,1) ; % This is a random year that has 8760 h as thought for importing files
                end
                if leapyear(SimDate.Year)
                    Array_InSolar = [Array_InSolar(1:1416,:) ;...
                                     Array_InSolar(1393:1416,:) ;...
                                     Array_InSolar(1417:end,:)];
                end
            else
                ResIniSolar         = 'Hourly'     ;
                Array_InSolar            = Default_Var.Hourly_Solar_Radiation ;
                ArrayStartYearSolar      = datenum(2000,1,1) ;
            end
            if isfield(data.FileSelection,'PriceFile')
                if ~isempty(data.FileSelection.PriceFile)
                    Pricefile = load(data.FileSelection.PriceFile);
                    FieldName = fieldnames(Pricefile);
                    
                    Array_InPrice       = Pricefile.(FieldName{:});
                    
                    if size(Array_InPrice,1)<size(Array_InPrice,2)
                        Array_InPrice = Array_InPrice';
                    end
                    
                    ArrayStartYearPrice = datenum(SimDate.Year,1,1) ;
                end
                if leapyear(SimDate.Year)
                    Array_InPrice = [Array_InPrice(1:1416,:) ;...
                                     Array_InPrice(1393:1416,:) ;...
                                     Array_InPrice(1417:end,:)];
                end
            else
                ResIniPrice         = 'Hourly'     ;
                Array_InPrice       = Default_Var.Hourly_Real_Time_Pricing ;
                ArrayStartYearPrice = datenum(2004,1,1) ; 
            end
            if isfield(data.FileSelection,'EmissionsFile')
                if ~isempty(data.FileSelection.EmissionsFile)
                    EmissionFile = load(data.FileSelection.EmissionsFile);
                    FieldName_Emissions = fieldnames(EmissionFile);
    %             All_Var.Hourly_Emissions = Emissionfile.(FieldName{:});        % Check here where the actual emission file is located!
                end
                if leapyear(SimDate.Year)
                    Array_InPrice = [Array_InPrice(1:1416,:) ;...
                                     Array_InPrice(1393:1416,:) ;...
                                     Array_InPrice(1417:end,:)];
                end
            end
        end
    end
    
    ResFinal            = HouseInfo.Time_Step ;
    SimulationStart     = min(Date_Sim(1,:)) ;
    SimulationEnd       = max(Date_Sim(2,:)) ;
    ReplicTemp          = 'Interpolate' ;
    ReplicSolar         = 'Interpolate' ;
    ReplicWind          = 'Interpolate' ;
    ReplicWater         = 'Interpolate' ;
    ReplicPrice         = 'Replicate'  ;
    ReplicEmissions     = 'Replicate'  ;
    
    % Sizing the temperature array for the simulation
    [Hourly_Temperature, Hourly_TemperatureTimed, ~] = Test_Database_extract_Extrapolate(Array_InTemp,...
                                                                                         ArrayStartYearTemp,...
                                                                                         ResIniTemp,...
                                                                                         ResFinal,...
                                                                                         SimulationStart,...
                                                                                         SimulationEnd,...
                                                                                         ReplicTemp,...
                                                                                         'DataOutput') ;
    
    switch ResIniTemp
        case 'Hourly'
            stpIn = 24 ;
        case '30 minutes'
            stpIn = 24 / 0.5 ;
        case '15 minutes'
            stpIn = 24 / 0.25 ;
        case '3 minutes'
            stpIn = 24 / (3 / 60) ;
        case '10s'
            stpIn = 24 / ((1/6) / 60) ;
    end
    
    FinalYear = ArrayStartYearTemp + size(Array_InTemp,1)/stpIn  ;

    [ ~ , All_Var.Hourly_TemperatureOrigTimed,~] = Test_Database_extract_Extrapolate(Array_InTemp, ...
                                                      ArrayStartYearTemp,...
                                                      ResIniTemp ,...
                                                      ResIniTemp , ...
                                                      ArrayStartYearTemp, ...
                                                      FinalYear , ...
                                                      'None', ...
                                                      'Temperature') ;

    All_Var.Hourly_Temperature      = Hourly_Temperature(1:(end-1)) ;
    All_Var.Hourly_TemperatureTimed = Hourly_TemperatureTimed ;
    
    % Sizing the Radiation array for the simulation
    [Hourly_Solar_Radiation, Hourly_Solar_RadiationTimed, ~] = Test_Database_extract_Extrapolate(Array_InSolar,...
                                                                                                 ArrayStartYearSolar,...
                                                                                                 ResIniSolar,...
                                                                                                 ResFinal,...
                                                                                                 SimulationStart,...
                                                                                                 SimulationEnd,...
                                                                                                 ReplicSolar,...
                                                                                                 'DataOutput') ;
    All_Var.Hourly_Solar_Radiation  = Hourly_Solar_Radiation(1:(end-1)) ;
    All_Var.Hourly_Solar_RadiationTimed = Hourly_Solar_RadiationTimed ;
    
    % Sizing the wind speed array for the simulation
    [Hourly_WindSpeed, Hourly_WindSpeedTimed, ~] = Test_Database_extract_Extrapolate(Array_InWind,...
                                                                                                 ArrayStartYearWind,...
                                                                                                 ResIniWind,...
                                                                                                 ResFinal,...
                                                                                                 SimulationStart,...
                                                                                                 SimulationEnd,...
                                                                                                 ReplicWind,...
                                                                                                 'DataOutput') ;
    All_Var.Hourly_WindSpeed  = Hourly_WindSpeed(1:(end-1)) ;
    All_Var.Hourly_WindSpeedTimed = Hourly_WindSpeedTimed ;
    
    % Sizing the wind speed array for the simulation
    [Hourly_Water, Hourly_WaterTimed, ~] = Test_Database_extract_Extrapolate(Array_InWater,...
                                                                                                 ArrayStartYearWater,...
                                                                                                 ResIniWater,...
                                                                                                 ResFinal,...
                                                                                                 SimulationStart,...
                                                                                                 SimulationEnd,...
                                                                                                 ReplicWater,...
                                                                                                 'DataOutput') ;
    All_Var.Hourly_Water  = Hourly_Water(1:(end-1)) ;
    All_Var.Hourly_WaterTimed = Hourly_WaterTimed ;
    
    % Sizing the Price array for the simulation
    [Hourly_Real_Time_Pricing, Hourly_Real_Time_PricingTimed, xq, errormess] = Test_Database_extract_Extrapolate(Array_InPrice,...
                                                                                                      ArrayStartYearPrice,...
                                                                                                      ResIniPrice,...
                                                                                                      ResFinal,...
                                                                                                      SimulationStart,...
                                                                                                      SimulationEnd,...
                                                                                                      ReplicPrice,...
                                                                                                      'DataOutput') ;
    % Sizing the Radiation array for the simulation
    [Hourly_Emissions, Hourly_EmissionsTimed, ~] = Test_Database_extract_Extrapolate(Array_InEmissions,...
                                                                                                 ArrayStartYearEmissions,...
                                                                                                 ResIniEmissions,...
                                                                                                 ResFinal,...
                                                                                                 SimulationStart,...
                                                                                                 SimulationEnd,...
                                                                                                 ReplicEmissions,...
                                                                                                 {'CC' 'OD' 'TA' 'FEut' 'MEut' 'HT' 'POF' 'PMF' 'TEco' 'FEco' 'MEco' 'IR' 'ALO' 'ULO' 'NLT' 'WD' 'MD' 'FD'}) ;
    All_Var.Hourly_Emissions        = Hourly_Emissions(1:(end-1),:) ;
    All_Var.Hourly_EmissionsTimed   = Hourly_EmissionsTimed ;
                                                                                                  

    if errormess.trigger
        AddText = errormess.text ;
        addLineSim(hObject,data,AddText)                                                                                              
    end
    
    All_Var.Hourly_Real_Time_Pricing      = Hourly_Real_Time_Pricing(1:(end-1)) ;
    All_Var.Hourly_Real_Time_PricingTimed = table2timetable(Hourly_Real_Time_PricingTimed) ;
    
    % Create the time array for array calculations such as SolRad3
    Time_Sim.TimeArray           = xq(1:end-1)    ;
    Time_Sim.timeyearArray       = Time_Sim.TimeArray.Year   ;
    Time_Sim.timemonthArray      = Time_Sim.TimeArray.Month  ;
    Time_Sim.timedayArray        = Time_Sim.TimeArray.Day    ;   
    Time_Sim.timeminuteArray     = Time_Sim.TimeArray.Minute ;
    Time_Sim.timesecondArray     = Time_Sim.TimeArray.Second ;
    Time_Sim.HourArray           = Time_Sim.TimeArray.Hour   ;
    startyr                      = datenum(Time_Sim.timeyearArray,1,1)                                        ;
    currtyr                      = datenum(Time_Sim.timeyearArray,Time_Sim.timemonthArray,Time_Sim.timedayArray) + 1    ;
    Time_Sim.timedayyearArray    = currtyr - startyr                                                     ; % Day of the year
    Time_Sim.timedaynbrNArray    = ceil(datenum(Time_Sim.TimeArray - Time_Sim.TimeArray(1))) ;
    
    % END OF ADDITION!
    %%%% TO BE MODIFIED AND ADAPTED TO THE NEW ARRAY
%     if (max(Ending_Dates) - datenum(Time_Sim.YearStartSim,1,1)) * 24 > length(All_Var.Hourly_Temperature')
%         AddText = '     Ending date is out of range. Check out the Temperature and Rediation starting date and/or the Price starting date of the files' ;
% %         warning(AddText)
%         addLineSim(hObject,data,AddText)
%         addLineSim(hObject,data,'Simulation aborted')
%         return; 
%     end
SimulationStart     = min(Date_Sim(1,:)) ;
SimulationEnd       = max(Date_Sim(2,:)) ;
ResFinal = HouseInfo.Time_Step ;
[xq, Time_Sim.stpOut, Time_Sim.ResFinalSecond] = TimeArray(ResFinal, SimulationStart, SimulationEnd) ;

%% Add the DHW distribution 
% The algorithm is based on the DHW_calcl calculation tool but the code was
% entirely written as the code is not freely available. In case of any
% mistake or modifications, please provide some inputs.
% Also define A6 as the difference of time between the 

NumDays         = SimulationEnd - SimulationStart + 1 ;
TimeStr         = datetime(SimulationStart,'ConvertFrom','datenum') ;
daystart        = TimeStr.Day ;

Housenumber = fieldnames(data.Simulationdata) ;
for i = 1:numel(Housenumber)
    All_Var.prob.(Housenumber{i}) = DHW_distribution_LaunchSim('A4', Time_Sim.MinperIter,...
                                                               'A6', NumDays, ...
                                                               'A5', daystart,...
                                                               'plotvar',false) ;
end
%% Extract the array from the database & interpolation (Linear, spline, etc...)
 


%%%
% Pre-Allocate the array for creating the output --> make a separate
% function

%     Emissions_Houses        = zeros(Nbr_Building, maxnbrstep + 1);
%     ExcelImport = 2;
% if ExcelImport == 1    
%     cell2csv2(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Input_House.csv'),Input_Data(2:end,2:end),',');
% else
%     cell2csv2(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Input_House.csv'),Input_Data,',');
% end
%% Set Variables

All_Var.Price_Tax           = Default_Var.Price_Tax ;
All_Var.Detail_Appliance    = Default_Var.Detail_Appliance ;

% Database = 3;
% All_Var.Database = Database;
% 
% switch Database
%     case 1
%         Envi_Database = 'EcoInvent'         ;
%     case 2
%         Envi_Database = 'ENVIMAT' ;
%     case 3
%         Envi_Database = 'ReCiPe' ;
%     otherwise
%         Envi_Database = 'ReCiPe' ;    
% end
% 
% % JARI'S ADDITION
% if isfield(data, 'FileSelection')
%     if isfield(data.FileSelection, 'EmissionsFile')
%         if ~isempty(data.FileSelection.EmissionsFile)
%             switch Database
%                 case 1
%                     All_Var.Hourly_CO2_EcoInvent = EmissionFile.(FieldName_Emissions{:})         ;
%                 case 2
%                     All_Var.Hourly_CO2_ENVIMAT = EmissionFile.(FieldName_Emissions{:})         ;
%                 case 3
%                     All_Var.Hourly_CO2_ReCiPe = EmissionFile.(FieldName_Emissions{:})         ;
%                 otherwise
%                     All_Var.Hourly_CO2_ReCiPe = EmissionFile.(FieldName_Emissions{:})         ;    
%             end
%         end
%     end
% end
% 
% switch Database
%     case 1
%         All_Var.Hourly_Emissions = Default_Var.Hourly_CO2_EcoInvent         ;
%     case 2
%         All_Var.Hourly_Emissions = Default_Var.Hourly_CO2_ENVIMAT         ;
%     case 3
%         All_Var.Hourly_Emissions = Default_Var.Hourly_CO2_ReCiPe         ;
%     otherwise
%         All_Var.Hourly_Emissions = Default_Var.Hourly_CO2_ReCiPe         ;  
% end
% 
%     ResIni   = 'Hourly'       ;
%     Replic   = 'Interpolate'  ;
%     ResFinal = HouseInfo.Time_Step ;
%     Array_In = sum(All_Var.Hourly_Emissions(:,1:6),2) ;
%     
%     %%% Add the public version for the year 2012
%     ArrayStartYear = datenum(2012,1,1) ; %2004
%     SimulationStart = Date_Sim(1,1) ;
%     SimulationEnd   = Date_Sim(2,1) ;
% %     All_Var.Hourly_Temperature = Test_Database_extract_Extrapolate(Array_In,ArrayStartYear,ResIni,ResFinal, SimulationStart, SimulationEnd, Replic) ;
%     [Hourly_Hourly_Emissions, Hourly_Hourly_EmissionsTimed] = Test_Database_extract_Extrapolate(Array_In,ArrayStartYear,ResIni,ResFinal, SimulationStart, SimulationEnd, Replic, 'DataOutput') ;
%     All_Var.Hourly_Hourly_Emissions      = Hourly_Hourly_Emissions(2:end) ;
%     All_Var.Hourly_Hourly_EmissionsTimed = Hourly_Hourly_EmissionsTimed ;

% END OF ADDITION

%%%
% Load the emissions corresponding to the right database. The Emissions
% data starts from 1.1.2004
% All_Var.Emissions = load(strcat('Results_',Envi_Database,'.mat'));
% Emissions_Houses = zeros(Nbr_Building, size(All_Var.Emissions.EmissionFactorNetto,2) , nbrstep + 1);
%%%
% Percentage step given as feedback
Time_Percentage_Indice = 1; % Expressed in "%"
%%%
% Set the type of simulation: 1: Simulation made in series; 0 simulation made in parallel
Time_Sim.Series_Sim = 1 ; 

%% Start the Simulation
%disp('Creating the variables ...');
AddText = '    Creating the variables ...' ;
    addLineSim(hObject,data,AddText)
% ws = workspace;

% for NewVariable = 1:size(Input_Data,2)
%     if ischar(Input_Data{2,NewVariable})
%         ws.(Input_Data{1,NewVariable})= {Input_Data{2:1+Nbr_Building,NewVariable}};
%     else
%         if NewVariable == 18
%            y = 1; 
%         end
%         ws.(Input_Data{1,NewVariable})= [Input_Data{2:1+Nbr_Building,NewVariable}];
%     end
% end
%All_Var.Detail_Appliance_List = CreateAppDetail ;

All_Var.Detail_Appliance_List   = data.Detail_Appliance ;
All_Var.Stat4Use_New            = CreateStat4Use_Profile1 ;
All_Var.Stat4Use_Profile1       = CreateStat4Use_Profile3 ;
All_Var.Stat4Use_Profile2       = CreateStat4Use_Profile2 ;
All_Var.ProfileUserdistri       = data.ProfileUserdistri  ;
All_Var.AppConssignature        = readtable('AppProf.csv');


All_Var.Nuc = load('Emissions_Nuc.mat');
All_Var.DebugMode = data.DebugMode ; % If this is to be distributed, set this value to 0, otherwise 1 (It does not save many variables meant for debugging)
All_Var.Public = Public ;
All_Var.GuiInfo   = data ;


SimStart = now ;
%disp(strcat(num2str(hour(now)),':',num2str(minute(now)),':',num2str(second(now))))

    AddText = strcat({'    Starting at '},{datestr(SimStart)}) ;
    addLineSim(hObject,data,AddText)

% HouseTitle = Input_Data(1,:);
% Import_Data = Input_Data;
Cont.START = 1;
App.START = 1;
SDI.START = 1;
MaxApp = 0 ;
Allfieldsname = fieldnames(Input_Datav3) ;
HouseTitle = fieldnames(Input_Datav3.(Allfieldsname{1})) ;
for i = 1:numel(fieldnames(Input_Datav3))
    App.NbrAppMax = max(MaxApp,str2double(Input_Datav3.(Allfieldsname{i}).Appliance_Max)) ;
end
% App.NbrAppMax = max([Input_Data{2:end,114}]) + 1 ;
EnergyOutput.START = 1;
NewVar1 = 0 ;
App.Calc_Time = zeros(Nbr_Building+1,maxnbrstep);

AddText = ('Simulation started') ;
addLineSim(hObject,data,AddText)

Series_Sim = Time_Sim.Series_Sim;

HouseInfo = Input_Datav3.(Allfieldsname{1}) ;
%% Declare variables
[EnergyOutput, Time_Sim] = DeclareTime(All_Var,Time_Sim,EnergyOutput,HouseInfo) ;
[Cont,App] = declarevariable(Cont,App,Time_Sim,All_Var);

%% Simulation Looping Start
if Time_Sim.Series_Sim == 1
    count = 0;
    tn = 0;
    tic
    Perc_Sim = floor(((TotalStepTime)/(100/Time_Percentage_Indice)) * (1:(100/Time_Percentage_Indice)));
    for BuildSim = 1 : Nbr_Building
%         clear('Time_Sim','Cont','App','EnergyOutput')
        ShowNbr = 0;
        %Public = 0 ; %1: distributed, 0:working file.
        HouseInfo = Input_Datav3.(Allfieldsname{BuildSim}) ;
        
        ProfileSelected = str2double(HouseInfo.Profile)       ;
        
        try
            All_Var.Stat4Use_Profile1 = data.ProfileUserdistri.(HouseInfo.Headers) ;
        catch
            switch ProfileSelected
                case 1
                    All_Var.Stat4Use_Profile1        = CreateStat4Use_Profile3 ;
                case 2
                    All_Var.Stat4Use_Profile1        = CreateStat4Use_Profile2 ;
                otherwise
                    All_Var.Stat4Use_Profile1        = CreateStat4Use_Profile3 ;
            end
        end
        
        nbrstepSum(BuildSim) = Time_Sim.nbrstep.(HouseInfo.Headers) ;
        if Public == 1
            Time_Sim.YearStartSim = 2012 ;
            Time_Sim.YearStartSim2004 = 2012 ;
            
                 % JARI'S ADDITION
        elseif isfield(data, 'FileSelection')
%         elseif handles.FileSelection.TemperatureChanged == 1 || handles.FileSelection.RadiationChanged == 1 || handels.FileSelection.PriceChanged == 1 || handles.FileSelection.EmissionChanged == 1
            
            if isfield(data.FileSelection, 'StartYearTempRad')
                Time_Sim.YearStartSim = str2double(data.FileSelection.StartYearTempRad);
            else
                Time_Sim.YearStartSim = 2000;
            end
            
            if isfield(data.FileSelection, 'StartYearPriceEmissions')
                Time_Sim.YearStartSim2004 = str2double(data.FileSelection.StartYearPriceEmissions);
            else
                Time_Sim.YearStartSim2004 = 2004;
            end
                % END OF JARI'S ADDITION
            
        else
            Time_Sim.YearStartSim = 2000 ;
            Time_Sim.YearStartSim2004 = 2004 ;
        end
        
        % Jari's Addition

        HouseInfo.Terminate = false;

        % End of addition
        
        HouseTitle = fieldnames(Input_Datav3.(Allfieldsname{1})) ;
        App.NbrAppMax = 0;
        for i = 1:numel(fieldnames(Input_Datav3))
            App.NbrAppMax = max(App.NbrAppMax,str2double(Input_Datav3.(Allfieldsname{i}).Appliance_Max)) ;
        end
        Cont.START = 1;
        App.START = 1;
        EnergyOutput.START = 1;
        App.NewVar1 = NewVar1 ;
        Time_Sim.Iteration6(1,1) = 0;
        Time_Sim.Series_Sim = Series_Sim;
        Time_Sim.Nbr_Building = Nbr_Building;
        Start = Starting_Days(BuildSim);
        End   = Ending_Dates(BuildSim);
        Power_prod1 = zeros(1, Time_Sim.nbrstep.(HouseInfo.Headers) + 1);
        Cons_Tot1   = zeros(1, Time_Sim.nbrstep.(HouseInfo.Headers) + 1);
        Occupancy1  = zeros(1, Time_Sim.nbrstep.(HouseInfo.Headers) + 1);
        Price1      = zeros(Time_Sim.nbrstep.(HouseInfo.Headers) + 1, 3);
        
        EnergyOutputLoop = ExtractHouse(EnergyOutput,HouseInfo.Headers) ;
        AppLoop          = ExtractHouse(App,HouseInfo.Headers)          ;
        ContLoop         = ExtractHouse(Cont,HouseInfo.Headers)         ;
        Time_SimLoop     = ExtractHouse(Time_Sim,HouseInfo.Headers)         ;
        
        for myiter = 0:(Time_Sim.nbrstep.(HouseInfo.Headers) - 1)
            Time_SimLoop.myiter = myiter;
            if or(and(min(Starting_Days)+ myiter/timestep >= Start, End >= floor(min(Starting_Days)+ myiter/timestep)),myiter == 0)
                
                [Power_prod1(1,myiter+1), Cons_Tot1(1,myiter+1), Occupancy1(1,myiter+1), Priceout,HouseInfo,All_Var,Time_SimLoop,SimDetails,ContLoop,AppLoop,EnergyOutputLoop,SDI]= ...
                HouseSim(2,1, HouseInfo, All_Var, Time_SimLoop,SimDetails,HouseTitle,ContLoop,AppLoop,EnergyOutputLoop,SDI);
                Price1(myiter+1,:) = Priceout ;
            end
            
            if getappdata(SimulationTimeWindow,'canceling') || HouseInfo.Terminate == true
                delete(SimulationTimeWindow)
                AddText = 'Simulation aborted' ;
                addLineSim(hObject,data,AddText)
                return
            end
            
            if BuildSim > 1
                TotalPreviousStep = sum(nbrstepSum(1:(BuildSim-1))) ;
            else
                TotalPreviousStep = 0;
            end
            
            step = TotalPreviousStep + myiter ;          
            
            if ismember(step,Perc_Sim)
                ShowNbr = ShowNbr + 1 ;
                PercDisplay = find(step == Perc_Sim);
                    t = toc;
                    tn = tn + t ;
                    avtime = tn / (step);
                    exptime = TotalStepTime * avtime;
                    remtime = exptime - tn;
                    YY = TimeRetrieve(remtime,' ');
                    
                    AddText = strcat(num2str(PercDisplay * Time_Percentage_Indice),'%, ',YY);
                tic
                if isempty(AddText)
                    AddText = '0% Completed.';
                end
                Message = strcat({'Step'},spacecell,{num2str(step)},{'/'},{num2str(TotalStepTime)},spacecell,'completed,',spacecell,AddText) ;

                waitbar(step/TotalStepTime,SimulationTimeWindow,Message)
            end
        end
        %% Get the water statistics
        All_Var.water_profile.(HouseInfo.Headers) = Waterstats(All_Var.prob.(HouseInfo.Headers), All_Var.water_profile.(HouseInfo.Headers)) ;
        
        
        %%% Disaggregation
        % At the end of the simulation made on the building, we need to
        % disaggragate the consumption profile of each appliance and the
        % total consumption with the signature profile used for each
        % profile. 
        [EnergyOutput, ~, ~, ~]                         = ReAssignHousev2(EnergyOutput,EnergyOutputLoop,HouseInfo.Headers, xq, data.AppliancesList(:,3)) ;  
        [AppOut.(HouseInfo.Headers), ~, ~, ~]           = ReAssignHousev2(AppLoop,AppLoop,HouseInfo.Headers, xq, data.AppliancesList(:,3))          ;
        
        % Disaggregate appliances into 10 seconds array
        if All_Var.GuiInfo.App10s
            tic
            AppOut.(HouseInfo.Headers) = App10sec(AppOut.(HouseInfo.Headers), Time_Sim) ;
            toc
        end
        
        % Calculate the emissions per appliance and total and 
        
%         [Cont, ~, ~, ~]     = ReAssignHousev2(ContLoop,ContLoop,HouseInfo.Headers, xq, data.AppliancesList(:,3))         ;
%         [Time_Sim, ~, ~, ~] = ReAssignHousev2(Time_SimLoop,Time_SimLoop,HouseInfo.Headers, xq, data.AppliancesList(:,3))         ;
        % WeatherData = table(x,Input.DataSim,'VariableNames',{'Time','DataOutput'}) ;
        
        stime = datetime(Time_Sim.StartDate.(HouseInfo.Headers),'ConvertFrom','datenum')  ;
        
        Power_prod.(HouseInfo.Headers) = array2timetable(Power_prod1','Timestep',seconds(Time_Sim.MinperIter * 60),'VariableNames',{'DataOutput'},'StartTime',stime) ;
        Cons_Tot.(HouseInfo.Headers) = array2timetable(Cons_Tot1','Timestep',seconds(Time_Sim.MinperIter * 60),'VariableNames',{'DataOutput'},'StartTime',stime) ; %table(xq,Cons_Tot1','VariableNames',{'Time','DataOutput'}) ;
%         Emissions_Houses(BuildSim-1,:,:) = SDI.Emissions_Dwel ;
        Occupancy.(HouseInfo.Headers) = array2timetable(Occupancy1','Timestep',seconds(Time_Sim.MinperIter * 60),'VariableNames',{'DataOutput'},'StartTime',stime) ; %table(xq,Occupancy1','VariableNames',{'Time','DataOutput'}) ;
        Price.(HouseInfo.Headers) = array2timetable(Price1,'Timestep',seconds(Time_Sim.MinperIter * 60),'VariableNames',{'Electrical_consumption', 'Heating', 'Total'},'StartTime',stime) ; %table(xq,Price1','VariableNames',{'Time','DataOutput'}) ;
        NewVar1 = AppOut.(HouseInfo.Headers).NewVar1 ;
        
        Emissions_Houses.(HouseInfo.Headers)=emiCalc(AppOut, HouseInfo, All_Var, Cons_Tot) ;
        
        s = {'Building Number',' ', num2str(BuildSim),' out of ',' ',num2str(Nbr_Building),' Completed'};
        AddText = [s{:}];
        addLineSim(hObject,data,AddText)
    end
    %% Rebuild the AppOut into App for post-processing
    App = RestructureAppOut(AppOut) ;
%         [Cont, ~, ~, ~]     = ReAssignHousev2(ContLoop,ContLoop,HouseInfo.Headers, xq, data.AppliancesList(:,3))         ;
%         [Time_Sim, ~, ~, ~] = ReAssignHousev2(Time_SimLoop,Time_SimLoop,HouseInfo.Headers, xq, data.AppliancesList(:,3))         ;
else
    Perc_Sim = floor((nbrstep/(100/Time_Percentage_Indice)) * (1:(100/Time_Percentage_Indice)));
    for myiter = 0:nbrstep
        Time_Sim.myiter = myiter;
        Time_Sim.nbrstep = nbrstep;
        for BuildSim = 2 : (Nbr_Building+1)
            Start = Starting_Days(BuildSim-1);
            End   = Ending_Dates(BuildSim-1);
            if or(and(min(Starting_Days)+ myiter/timestep >= Start, End >= min(Starting_Days)+ myiter/timestep),myiter == 0)
                HouseInfo = Import_Data(BuildSim,:);
                [Power_prod(BuildSim-1,myiter+1), Cons_Tot(BuildSim-1,myiter+1), Occupancy(BuildSim-1,myiter+1), Price(BuildSim-1,myiter+1),HouseInfo,All_Var,Time_Sim,SimDetails,Cont,App,EnergyOutput,SDI(BuildSim-1,myiter+1)]= ...
                HouseSim(BuildSim,Nbr_Building, HouseInfo, All_Var, Time_Sim,SimDetails,HouseTitle,Cont,App,EnergyOutput);
            end
        end
        if ismember(myiter,Perc_Sim)
            PercDisplay = find(myiter == Perc_Sim);
            disp(strcat(num2str(PercDisplay * Time_Percentage_Indice),' %  Completed'));
        end
    end
end
Input_Data = Input_Datav3;
%% Ending the simulation
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Occupancy_Global.mat'),'Occupancy')         ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Cons_Tot_Global.mat'),'Cons_Tot')           ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Power_prod_Global.mat'),'Power_prod')       ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Bill_Global.mat'),'Price')                  ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Time_Sim.mat'),'Time_Sim')                  ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Date_Sim.mat'),'Date_Sim')                  ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Input_Data.mat'),'Input_Data')              ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Cont.mat'),'Cont')              ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Emissions_Houses.mat'),'Emissions_Houses')           ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'SDI.mat'),'SDI')           ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'EnergyOutput.mat'),'EnergyOutput')           ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'App.mat'),'App')           ;
save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'All_Var.mat'),'All_Var')           ;
% save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'data.mat'),'data')           ;
% JARI'S ADDITION
if isfield(data,'FileSelection')
    FileSelection = data.FileSelection;
    save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'FileSelection.mat'),'FileSelection')           ;
end
% END OF ADDITION
%%%
% Display the time elapsed for the simulation

SimEnd = now ;

AddText = strcat({'      Ending at '},{datestr(SimEnd)}) ;
addLineSim(hObject,data,AddText)

timesim = (SimEnd - SimStart) * 86400 ;
YY = TimeRetrieve(timesim,'The simulation took ');

AddText = YY ;
addLineSim(hObject,data,AddText)

AddText = '      Wait......Retrieving the results' ;
addLineSim(hObject,data,AddText)
%%% 
% Delete the *.m files after the simulation
[sub,fls] = subdir(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID));
for CheckCell = 1:length(fls)
   if isempty(fls{CheckCell}) == 0
       delete(strcat(sub{CheckCell},filesep,'*.m'))
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JARI'S ADDITION
% if ~isfield(handles, 'FileSelection') % J
%     Plot_Results(SimDetails.Project_ID, SimDetails.Output_Folder,Date_Sim,Input_Data,HouseTitle) ;
% elseif isfield(handles.FileSelection, 'EmissionsChanged')   % J
%     if handles.FileSelection.EmissionsChanged == 0          % J
%         Plot_Results(SimDetails.Project_ID, SimDetails.Output_Folder,Date_Sim,Input_Data,HouseTitle) ;
%     end                                                     % J
% end                                                                                   % J
% END OF ADDITION

AddText = 'Extracting data by metering system, inhabitants, and contract type ...' ;
addLineSim(hObject,data,AddText)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ExtractMetering(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID));

AddText = 'Simulation Completed' ;
addLineSim(hObject,data,AddText)
delete(SimulationTimeWindow)

if profilerboo
    profile viewer
    profile off
end



function addLineSim(hObject,handles,AddText,varargin)
GetText = get(hObject,'string') ;
if nargin > 3
    
    addLine = 0;
else
    addLine = 1;
end
switch class(AddText)
    case 'char'
        % There is nothing to do, it is already in the right format
        if isempty(GetText)
            GetText{1} = AddText ;
        else
            nbrlines = size(GetText,1) ;
            GetText{nbrlines + addLine} = AddText ;
        end
    case 'cell'
        for i = 1:length(AddText)
            addLineSim(hObject,handles,AddText{i})
            GetText = get(hObject,'string') ;
        end
    case 'double'
       AddText = num2str(AddText) ; 
        if isempty(GetText)
            GetText{1} = AddText ;
        else
            nbrlines = size(GetText,1) ;
            GetText{nbrlines + addLine} = AddText ;
        end
end

set(hObject,'string',GetText) ;
set(hObject,'value', numel(get(hObject,'string'))) ;
pause(0.5);

function [SummaryStructure] = getInputDatav2
SummaryStructure.Headers        = {};
SummaryStructure.StartingDate   = {};
SummaryStructure.EndingDate     = {};
SummaryStructure.Latitude       = {};
SummaryStructure.Longitude      = {};
SummaryStructure.User_Type      = {};
SummaryStructure.Time_Step      = {};
SummaryStructure.Building_Type	= {};
SummaryStructure.WindTurbine	= {};
SummaryStructure.PhotoVol       = {};
SummaryStructure.FuelCell       = {};
SummaryStructure.WTPowertot     = {};
SummaryStructure.WindSpeed      = {};
SummaryStructure.Lambdanom      = {};
SummaryStructure.Cp             = {};
SummaryStructure.MaxPowerWT     = {};
SummaryStructure.Baserotspeed	= {};
SummaryStructure.Pitch          = {};
SummaryStructure.EfficiencyWT	= {};
SummaryStructure.NbrmodTot      = {};
SummaryStructure.Nbrmodser      = {};
SummaryStructure.Nbrmodpar      = {};
SummaryStructure.Aspect         = {};
SummaryStructure.Tilt           = {};
SummaryStructure.Voc            = {};
SummaryStructure.Isc            = {};
SummaryStructure.MaxPowerPV     = {};
SummaryStructure.LengthPV       = {};
SummaryStructure.WidthPV        = {};
SummaryStructure.NOCT           = {};
SummaryStructure.MaxPowerFC     = {};
SummaryStructure.SolarData      = {};
SummaryStructure.ContElec       = {};
SummaryStructure.inhabitants    = {};
SummaryStructure.nbrRoom        = {};
SummaryStructure.WashMach       = {};
SummaryStructure.clWashMach     = {};
SummaryStructure.DishWash       = {};
SummaryStructure.clDishWash     = {};
SummaryStructure.Elec           = {};
SummaryStructure.Kettle         = {};
SummaryStructure.clKettle       = {};
SummaryStructure.Oven           = {};
SummaryStructure.clOven         = {};
SummaryStructure.Coffee         = {};
SummaryStructure.clCoffee       = {};
SummaryStructure.MW             = {};
SummaryStructure.clMW           = {};
SummaryStructure.Toas           = {};
SummaryStructure.clToas         = {};
SummaryStructure.Waff           = {};
SummaryStructure.clWaff         = {};
SummaryStructure.Fridge         = {};
SummaryStructure.clFridge       = {};
SummaryStructure.Tele           = {};
SummaryStructure.clTele         = {};
SummaryStructure.Laptop         = {};
SummaryStructure.clLaptop       = {};
SummaryStructure.Shaver         = {};
SummaryStructure.clShaver       = {};
SummaryStructure.Hair           = {};
SummaryStructure.clHair         = {};
