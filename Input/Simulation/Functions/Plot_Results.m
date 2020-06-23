function Plot_Results(Project_ID, varargin)
%close all
dbstop if error
disp('     Loading input variables ...');
if nargin > 1
    Output_Folder = varargin{1};
    Date_Sim = varargin{2};
    Input_Data.Input_Data = varargin{3};
    HouseTitle = varargin{4};
elseif nargin == 1
    folder_name = uigetdir;
    if folder_name == 0; return; end
    Output_Folder = strcat(folder_name);
    load(strcat(Output_Folder,filesep,Project_ID,filesep,'Date_Sim.mat'));
    Input_Data = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Input_Data.mat'));
elseif nargin == 0
    folder_name = uigetdir;
    if folder_name == 0; return; end
    occ = regexp(folder_name,filesep);
    length(folder_name);
    Output_Folder = folder_name(1:(max(occ)-1));
    Project_ID = folder_name((max(occ)+1):length(folder_name));
    load(strcat(Output_Folder,filesep,Project_ID,filesep,'Date_Sim.mat'));
    Input_Data = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Input_Data.mat'));
end
disp('     Checking for existing simulation ...');
listing = dir(strcat(Output_Folder,filesep,Project_ID));
FileName = 'Results';
handle_Folder = '';
MyList = {listing(:,1).name};
AllResultsFile = find(cellfun(@isempty,regexp(MyList, 'Results')) == 0);
if size(AllResultsFile,2)>0 
    choice = questdlg('Would you like to use existing results?',...
                    'Results',...
                    'Yes', ...
                    'No', 'No');
    if isempty(choice);return;end
    switch choice
        case 'Yes'
            MyList = {listing(:,1).name};
            AllResultsFile = find(cellfun(@isempty,regexp(MyList, 'Results')) == 0);
            str = {listing(AllResultsFile).name};
            [s,v] = listdlg('PromptString','Select a file:',...
                            'SelectionMode','single',...
                            'ListString',str);
             if v == 1
                 Current_Folder = str(s);
                 curr = strcat(Output_Folder,filesep,Project_ID,filesep,Current_Folder);
                 Results_File = regexp(Current_Folder,'_');
                 Result_Numb = Current_Folder{1}(1:(max(Results_File{1})-1));
                 matfile = strcat(curr,filesep,Result_Numb,'_','Plot_Results.mat');
                 Old_Results = load(matfile{1});
                 
                 MyInput3 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Variable_File',filesep,'Appliances_One_CodeStrv2.mat'))           ;
                 Exchanged = load('Exchanged.mat');
                 nbr_applinces = Old_Results.nbr_applinces;
                 Action_Resume = Old_Results.Action_Resume;
                 Avg_Week = Old_Results.Avg_Week;
                 Avg_Year = Old_Results.Avg_Year ;
                 time_per_cycle = Old_Results.time_per_cycle;
                 Daily_Profile = Old_Results.Daily_Profile_MeanConsStr;
                 Max_Use = Old_Results.Max_Use ;
                 NewPath = Old_Results.NewPath ;
                 New_Folder = Current_Folder{1};
                 Daily_Profile_Overall = Old_Results.Daily_Profile_MeanConsTotalStr;
                 Daily_Profile_Plot_CO2 = Old_Results.Emission_Profile_MeanCO2Str ;
                 Daily_Profile_Sum_CO2 = Old_Results.Emission_Profile_SumCO2Str;
                 [stopsim]=closePDF(Output_Folder,Project_ID,New_Folder,'Figure');
                 if stopsim == 1;return;end
                 %%% Call the plotting nested function
                 disp('     Plotting ...');
                 Plot_Output(nbr_applinces,Action_Resume,Avg_Week,Max_Use,Avg_Year,time_per_cycle,Daily_Profile_Overall,Daily_Profile,Daily_Profile_Plot_CO2,Daily_Profile_Sum_CO2,Output_Folder,Project_ID,New_Folder,NewPath);
             else
                 return
             end
        case 'No'
             while isempty(handle_Folder)
                if ~isempty(find(cellfun(@isempty,regexp(MyList, 'Results')) == 0))
                    choice = questdlg('Would you like to keep the existing results?',...
                            'Results',...
                            'Yes', ...
                            'No', 'No');
                    switch choice
                        case 'Yes'
                            New_Folder = strcat(datestr(now,'yyyymmdd_HHMMSS'),'_','Results');
                            rehash()
                            mkdir(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder));
                            addpath(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder));
                            display(['New folder created: ',New_Folder])
                            handle_Folder = 1;
                            Results_File = regexp(New_Folder,'_');
                            Result_Numb = New_Folder(1:(max(Results_File)-1));
                            %%% Call the Processing nested function
                            MyInput1 = load('Smart_House_Data_MatLab.mat');
                            MyInput2 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Cons_Tot_Global.mat'))           ;
                            MyInput3 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Variable_File',filesep,'Appliances_One_CodeStrv2.mat'))           ;
                            Exchanged = load('Exchanged.mat');
                            [nbr_applinces, Action_Resume, Avg_Week, time_per_cycle, Daily_Profile, Max_Use, Daily_Profile_Overall,...
                            Daily_Profile_Plot_CO2, Daily_Profile_Sum_CO2,Avg_Year] = Process_Data;                           
                            %%% Call the plotting nested function
                            disp('Plotting ...');
                            NewPath = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder);
                            Plot_Output(nbr_applinces,Action_Resume,Avg_Week,Max_Use,Avg_Year,time_per_cycle,Daily_Profile_Overall,Daily_Profile,Daily_Profile_Plot_CO2,Daily_Profile_Sum_CO2,Output_Folder,Project_ID,New_Folder,NewPath);
                        case 'No'
                            choice2 = questdlg('It will delete all the files in the directory, Are you sure you want to delete these files permanently?',...
                            'Results',...
                            'Yes', ...
                            'No', 'No');
                            switch choice2
                                case 'Yes'
                                    MyList = {listing(:,1).name};
                                    AllResultsFile = find(cellfun(@isempty,regexp(MyList, 'Results')) == 0);
                                    str = {listing(AllResultsFile).name};
                                    [svar,v] = listdlg('PromptString','Select a file:',...
                                                    'SelectionMode','multiple',...
                                                    'ListString',str);
                                    if v == 1
                                        for Filevar = 1:length(svar)
                                            Current_Folder = str(svar(Filevar));
                                            curr = strcat(Output_Folder,filesep,Project_ID,filesep,Current_Folder{1});
                                            currlist = dir(curr);
                                            if max(cellfun('length',{currlist.name})) > 2
                                                [stopsim]=closePDF(Output_Folder,Project_ID,Current_Folder{1});
                                                if stopsim == 1;return;end
                                                rehash()
                                                [SUCCESS,MESSAGE,~] = rmdir(curr,'s');
                                                if SUCCESS == 0;display([MESSAGE,' ','The folder ',Current_Folder{1},' is being used']);end
                                            else
                                                rehash()
                                                [SUCCESS,MESSAGE,~] = rmdir(curr,'s');
                                                if SUCCESS == 0;display([MESSAGE,' ','The folder ',Current_Folder{1},' is being used']);end
                                            end
                                        end
                                        
                                        New_Folder = strcat(datestr(now,'yyyymmdd_HHMMSS'),'_','Results');
                                        rehash()
                                        mkdir(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder));
                                        addpath(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder));
                                        display(['New folder created: ',New_Folder])
                                        handle_Folder = 1;
                                        Results_File = regexp(New_Folder,'_');
                                        Result_Numb = Current_Folder{1}(1:(max(Results_File(2))-2));
                                        %%% Call the Processing nested function
                                        MyInput1 = load('Smart_House_Data_MatLab.mat');
                                        MyInput2 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Cons_Tot_Global.mat'))           ;
                                        MyInput3 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Variable_File',filesep,'Appliances_One_CodeStrv2.mat'))           ;
                                        Exchanged = load('Exchanged.mat');
                                        [nbr_applinces, Action_Resume, Avg_Week, time_per_cycle, Daily_Profile, Max_Use, Daily_Profile_Overall,...
                                        Daily_Profile_Plot_CO2, Daily_Profile_Sum_CO2,Avg_Year] = Process_Data;                            
                                        %%% Call the plotting nested function
                                        disp('     Plotting ...');
                                        NewPath = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder);
                                        Plot_Output(nbr_applinces,Action_Resume,Avg_Week,Max_Use,Avg_Year,time_per_cycle,Daily_Profile_Overall,Daily_Profile,Daily_Profile_Plot_CO2,Daily_Profile_Sum_CO2,Output_Folder,Project_ID,New_Folder,NewPath);
                                    else
                                        handle_Folder = '';
                                    end
                                case 'No'
                                    handle_Folder = '';
                            end
                     end    
                end
            end
    end
else
    New_Folder = strcat(datestr(now,'yyyymmdd_HHMMSS'),'_','Results');
    rehash()
    mkdir(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder));
    addpath(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder));
    display(['     New folder created: ',New_Folder])
    %Results_File = regexp(New_Folder,'_');
    Results_File = regexp(New_Folder,'_');
    Result_Numb = New_Folder(1:(max(Results_File)-1));
    %%% Call the Processing nested function
    MyInput1 = load('Smart_House_Data_MatLab.mat');
    MyInput2 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Cons_Tot_Global.mat'))           ;
    MyInput3 = load(strcat(Output_Folder,filesep,Project_ID,filesep,'Variable_File',filesep,'Appliances_One_CodeStrv2.mat'))           ;
    Exchanged = load('Exchanged.mat');
    disp('     Processing results ...');
    [nbr_applinces, Action_Resume, Avg_Week, time_per_cycle, Daily_Profile, Max_Use, Daily_Profile_Overall,...
    Daily_Profile_Plot_CO2, Daily_Profile_Sum_CO2,Avg_Year] = Process_Data;                            
    %%% Call the plotting nested function
    choice2 = questdlg('Do you want to plot the figures? (This process can take a long time if a large number of house is being processed)',...
                            'Results',...
                            'Yes', ...
                            'No', 'No');
    if isempty(choice2);return;end
    NewPath = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder);
    switch choice2
        case 'Yes'
            disp('     Plotting ...');
            Plot_Output(nbr_applinces,Action_Resume,Avg_Week,Max_Use,Avg_Year,time_per_cycle,Daily_Profile_Overall,Daily_Profile,Daily_Profile_Plot_CO2,Daily_Profile_Sum_CO2,Output_Folder,Project_ID,New_Folder,NewPath);
        case 'No'
            if iscell(NewPath)
                NewPath = NewPath{1};
            end
            addpath(NewPath);
            openFolderwindow(strcat('"',NewPath,'"')) ;
            Win_Expl = ['explorer.exe',' ',NewPath];     
            system(Win_Expl);
            disp('     Figures can be re-processed later on if necessary');
    end
    
end
%% Import Data


%% Data Processing
function [nbr_applinces, Action_Resume, Avg_Week, time_per_cycle, Daily_Profile_MeanConsStr, Max_Use, Daily_Profile_MeanConsTotalStr,...
        Emission_Profile_MeanCO2Str, Emission_Profile_SumCO2Str,Avg_Year] = Process_Data
    % Load the neccesary database
    Emissions_ReCiPev1_12 = load('Emissions_ReCiPev1-12.mat');
    % Allocate Variable Size Appliance_Max
    Houseused = fieldnames(Input_Data.Input_Data) ;
    AppMax = 0;
    for i = 1:numel(Houseused)
        AppMax = max(AppMax,str2double(Input_Data.Input_Data.(Houseused{i}).Appliance_Max)) ;  
    end
    Time_Step = Input_Data.Input_Data.(Houseused{i}).Time_Step  ;  
%     Annual_Energy           = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     Action_Resume           = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     Avg_Week                = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     Avg_Year                = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     Max_Use                 = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     WeekDistrib             = zeros(size(MyInput2.Cons_Tot,2),7,AppMax);
%     time_per_cycle          = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     Weekly_Avg              = zeros(size(MyInput2.Cons_Tot,2),AppMax);
%     Daily_ProfileCO2        = zeros(size(MyInput2.Cons_Tot,2),24,3,12);
%     nbr_applinces           = zeros(1,2,size(MyInput2.Cons_Tot,2));
%     Daily_Profile_MeanCons  = zeros(size(MyInput2.Cons_Tot,2),24,3,12);
    
%    CO2EmissionsAllHouses   = zeros(size(MyInput3.NewVar.Total_Action2,2)-2,size(MyInput3.NewVar.Total_Action2,1));
%   CO2Emission             = zeros(size(MyInput3.NewVar.Total_Action2,1),size(MyInput2.Cons_Tot,2));
    %% Each House Stats
    tn = 0;
    count = 0 ;
    for Housenumber = 1:numel(Houseused)
        tic

        Sartingyear = datetime( Input_Data.Input_Data.(Houseused{Housenumber}).StartingDate,'InputFormat','dd/MM/yyyy') ;
        Endingyear = datetime( Input_Data.Input_Data.(Houseused{Housenumber}).EndingDate,'InputFormat','dd/MM/yyyy') + seconds(3600*24) ;
        
        timeRange = timerange(Sartingyear,Endingyear) ;
        
        numberofday = datenum(Endingyear) - datenum(Sartingyear) ;
        numberofweeks = numberofday / 7 ;
        %% CO2 Emissions
        % The emissions are not calculated before 2004 as there were no data
        % available regarding the power production and consumption at the
        % country level in Finland.
        % Choose the databse (ENVIMAT or EcoInvent)
        Database = 3;
        HouseTag = Houseused{Housenumber} ;
        switch Database
            case 1
                HourlyEmissions = MyInput1.Hourly_CO2_EcoInvent             ;
                xq = (datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1),'ConvertFrom','datenum'):seconds(3600):datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1)+size(HourlyEmissions,1)/24-1/24,'ConvertFrom','datenum'))';
                HourlyEmissions = table(xq,HourlyEmissions,'VariableNames',{'Time','DataOutput'}) ;
            case 2
                HourlyEmissions = MyInput1.Hourly_CO2_ENVIMAT     ;
                xq = (datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1),'ConvertFrom','datenum'):seconds(3600):datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1)+size(HourlyEmissions,1)/24-1/24,'ConvertFrom','datenum'))';
                HourlyEmissions = table(xq,HourlyEmissions,'VariableNames',{'Time','DataOutput'}) ;
            case 3 
%                 HourlyEmissions = MyInput1.Hourly_CO2_ReCiPe     ;
%                 xq = (datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1),'ConvertFrom','datenum'):seconds(3600):datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1)+size(HourlyEmissions,1)/24-1/24,'ConvertFrom','datenum'))';
                 [Headers, Tech, EmissionsVar] = ReCiPe_Headers ;
%                 HourlyEmissions      = array2table(HourlyEmissions,'VariableNames',Headers(2:end));
%                 HourlyEmissions_Time = table(xq,'VariableNames',Headers(1)) ;
                
                
                [HourlyEmissions, HourlyEmissions_Time] = Test_Database_extract_Extrapolate(MyInput1.Hourly_CO2_ReCiPe, ...
                                                          datenum(2000,1,1),...
                                                          'Hourly',...
                                                          Time_Step, ...
                                                          Date_Sim(1,Housenumber), ...
                                                          Date_Sim(2,Housenumber), ...
                                                          'Replicate', ...
                                                          Headers(2:end)) ;
                                                     
                HourlyEmissions      = table2timetable(HourlyEmissions_Time) ;
                
            otherwise
                HourlyEmissions = Input_Data.Hourly_CO2_EcoInvent             ; 
                xq = (datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1),'ConvertFrom','datenum'):seconds(3600):datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1)+size(HourlyEmissions,1)/24-1/24,'ConvertFrom','datenum'))';
                HourlyEmissions = table(xq,HourlyEmissions,'VariableNames',{'Time','DataOutput'}) ;
        end
        % xq = (datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1),'ConvertFrom','datenum'):seconds(3600):datetime(datenum(MyInput3.NewVar.YearStartSimStr,1,1)+size(HourlyEmissions,1)/24,'ConvertFrom','datenum'))';
        Em_Start = Date_Sim(1,Housenumber) - datenum(MyInput3.NewVar.YearStartSimStr,1,1);
        Em_End = Date_Sim(2,Housenumber) - datenum(MyInput3.NewVar.YearStartSimStr,1,1)      + 1;
        Em_Start2 = Date_Sim(1,Housenumber) - datenum(MyInput3.NewVar.YearStartSim2004Str,1,1);
        Em_End2 = Date_Sim(2,Housenumber) - datenum(MyInput3.NewVar.YearStartSim2004Str,1,1) + 1;
        
        if Em_Start == 0
            Em_Start = 1 / 24;
            Em_End = Em_End + 1 ;
            Em_Start2 = 1 / 24 ;
            Em_End2 = Em_End2 + 1;
        end
        if Em_Start2 ==  Em_End2
            Em_End2 = Em_Start2 + 1;
        end
        % JARI'S ADDITION!
        if Em_Start2 == 0
            Em_Start2 = 1/24;
            Em_End2 = Em_End2 + Em_Start2;
        end
        % END OF JARI'S ADDITION  
        [~, Hourly_Fingrid] = Test_Database_extract_Extrapolate(MyInput1.Hourly_Fingrid,datenum(2004,1,1),...
                                                          'Hourly',...
                                                          Time_Step, ...
                                                          Date_Sim(1,Housenumber), ...
                                                          Date_Sim(2,Housenumber), ...
                                                          'Interpolate', ...
                                                          {'TimeStamp','Consumption','Production'}) ;
        Hourly_Fingrid  = table2timetable(Hourly_Fingrid);
        En_Load         = Hourly_Fingrid.Consumption(timeRange,:) ;
        En_Generation   = Hourly_Fingrid.Production(timeRange,:) ;
        
        % Import and interpolate data for statistical purposes.
        [~, Exchanged_Electricity] = Test_Database_extract_Extrapolate(Exchanged.Exchanged_Electricity,...
                                                                                datenum(2004,1,1),...
                                                                                'Hourly',...
                                                                                Time_Step, ...
                                                                                Date_Sim(1,Housenumber), ...
                                                                                Date_Sim(2,Housenumber), ...
                                                                                'Interpolate', ...
                                                                                { 'Export_Sweden','Import_Sweden',...
                                                                                  'Export_Russia','Import_Russia',...
                                                                                  'Export_Estonia','Import_Estonia',...
                                                                                  'Export_Norway','Import_Norway'}) ;
        
        Exchanged_Electricity = table2timetable(Exchanged_Electricity) ;
        
        Traded              = Exchanged_Electricity(timeRange,:) ;
        EmissionsCountry    = Exchanged.Emissions_Country(:,:,Database) ;
        
%         for ii = 1:size(En_Load,2)
%            for jj = 1:(size(Traded,1)/2)
%                perc_trade(ii,jj) = (Traded(jj*2,ii) - Traded(jj*2-1,ii)) / En_Load(1,ii) ;
%            end
%            perc_trade(ii,jj + 1) = En_Generation(1,ii) / En_Load(1,ii) ;
%         end
        
        %Import environmental data
        Nbr_Indic = (size(HourlyEmissions,2)) / 6 ;
%         NetEmissions    = zeros(size(En_Load,2),Nbr_Indic);
%         EmissionFactor  = zeros(size(En_Load,2),Nbr_Indic);
%         Emissions       = zeros(size(En_Load,2),Nbr_Indic);
%         Emission        = zeros(size(En_Load,2),Nbr_Indic);
        EmcountryTotal  = [] ;
        
%         Indic = [IndicatorList EmissionsVar'] ;
        Indic = strrep(EmissionsVar,' ','_') ;
        for Indicator = 1:Nbr_Indic
%             endIndex                = 6 * Indicator;
%             startIndex              = 6 * (Indicator - 1) + 1 ;
            EmissionsTest = zeros(length(En_Load),1) ;
            for iTech = i:length(Tech)
                EmissionsTest = EmissionsTest + HourlyEmissions.([Indic{Indicator,2} '_' Tech{iTech}])(timeRange,:) ;
            end
            NetEmissions.(Indic{Indicator,1})      =  EmissionsTest ; %sum(HourlyEmissions((((Em_Start)*24)):(Em_End*24),startIndex:endIndex),2) ;
            % Get the results in kg/kwh
            EmissionFactor.(Indic{Indicator,1})    = diag(NetEmissions.(Indic{Indicator,1}) ./ En_Load');
            % Convert to g/kWh
            Emissions.(Indic{Indicator,1})         = EmissionFactor.(Indic{Indicator,1}) * 1000   ;
            Emission.(Indic{Indicator,1})          = diag(Emissions.(Indic{Indicator,1}) * MyInput2.Cons_Tot.(HouseTag).DataOutput(1:(end-1))');
            EmissionFix                            = Emissions_ReCiPev1_12.Emissions_fixed(Indicator);  
            
%             endIndex = 6 * Indicator;
%             startIndex    = 6 * (Indicator - 1) + 1 ;
            switch Database
                case 3
                    if and(Indicator >= 13,Indicator<=16) 
                        Multiple = 0.001;
                    else
                        Multiple = 1000 ;
                    end 
                otherwise
                    Multiple = 1000 ;
            end
                Emissions_ReCiPe.(HouseTag).EmissionsfactProduced.(Indic{Indicator,1}) = (NetEmissions.(Indic{Indicator,1}) * Multiple) ./ En_Generation';
                Emissions_ReCiPe.(HouseTag).EmissionHouseProduced.(Indic{Indicator,1}) = diag(Emissions_ReCiPe.(HouseTag).EmissionsfactProduced.(Indic{Indicator,1}) * MyInput2.Cons_Tot.(HouseTag).DataOutput(1:(end-1)));
                NetImportCO2    = []    ;
                NetProducedCO2  = []    ;
                NetCO2          = []    ;
%                 for ww = 1:size(En_Load,2) % ww = number of dates
                    NetImportCO2(:,1) = (Traded.Import_Sweden * EmissionsCountry(Indicator,1) + ...
                                          Traded.Import_Russia * EmissionsCountry(Indicator,2) + ...
                                          Traded.Import_Estonia * EmissionsCountry(Indicator,3) + ...
                                          Traded.Import_Norway * EmissionsCountry(Indicator,4)) ...
                                          / 1000 ;
%                     NetProducedCO2(:,1) = diag(EmissionFactor.(Indic{Indicator,1}) .* En_Generation'); - sum(Traded(1:2:size(Traded,1),ww))) ;
                    
                    NetProducedCO2(:,1) = diag(EmissionFactor.(Indic{Indicator,1}) .* ...
                                                (En_Generation - (Traded.Export_Estonia + Traded.Export_Norway + Traded.Export_Russia + Traded.Export_Sweden))') ;
                    
                    NetCO2(:,1) = NetImportCO2 +  NetProducedCO2 ;
%                 end
                EmcountryTotal.(Indic{Indicator,1}) = NetCO2(:,1);
                EmissionFactor.(Indic{Indicator,1}) = diag(NetCO2(:,1) ./ En_Generation' * Multiple) ;
                Emissions_ReCiPe.(HouseTag).EmissionsfactNetto.(Indic{Indicator,1}) = EmissionFactor.(Indic{Indicator,1}) ;
                Emissions_ReCiPe.(HouseTag).EmissionHouseNetto.(Indic{Indicator,1}) = diag(EmissionFactor.(Indic{Indicator,1}) * MyInput2.Cons_Tot.(HouseTag).DataOutput(1:(end-1))');
                Emissions_ReCiPe.(HouseTag).EmissionHouseFixedFactor.(Indic{Indicator,1}) = (MyInput2.Cons_Tot.(HouseTag).DataOutput(1:(end-1))' * EmissionFix)';
         end
        Series_App = [1:21]';

        AppClass = {'WashMach' 'DishWash' 'Elec' 'Kettle' 'Oven' 'MW' 'Coffee' 'Toas' 'Waff' 'Fridge' 'Radio' 'Laptop' 'Elecheat' 'Shaver' 'Hair' 'Tele' 'Stereo' 'Iron' 'Vacuum' 'Charger' 'Sauna'
                      1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21} ;    
        AppClassName = {'WashMach' 'DishWash' 'Elec' 'Kettle' 'Oven' 'MW' 'Coffee' 'Toas' 'Waff' 'Fridge' 'Radio' 'Laptop' 'Elecheat' 'Shaver' 'Hair' 'Tele' 'Stereo' 'Iron' 'Vacuum' 'Charger' 'Sauna'} ;

        Original_pos = 1;          
        for var_app = 1:21
            var_appn = Series_App(var_app,1); %[43,45,47,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,79,80]
            if ~sum(str2double(Input_Data.Input_Data.(Houseused{Housenumber}).(AppClass{1,var_app}))) == 0
                for var_nbr = 1:sum(str2double(Input_Data.Input_Data.(Houseused{Housenumber}).(AppClass{1,var_app})))
                    nbr_applinces(Original_pos,1, Housenumber) = Original_pos;
                    nbr_applinces(Original_pos,2, Housenumber) = find(Series_App == var_appn);
                    Original_pos = Original_pos + 1 ; 
                end
            end
        end


        if isempty(find(nbr_applinces(:,1,Housenumber)==0,1))
            nbr_appliances = nbr_applinces(:,1:2,Housenumber);
        else
            LastRow = find(nbr_applinces(:,1,Housenumber)==0,1);
            nbr_appliances = nbr_applinces(1:(LastRow(1)-1),1:2,Housenumber);
        end
%         for var = 1:size(Series_App,1)
%             Avg_Year_app(Housenumber,var) = mean(sum(MyInput3.NewVar.Appliances_Cons(Housenumber,:,find(var == nbr_appliances(:,2)))));
%         end
        ArraytoLook = size(Emission(:,1),1) - 1;
%         for var = 1:size(nbr_appliances,1)
%             var2 = nbr_appliances(var,2);
%             if ~(var2 == 10) % Calculate for all except for the Fridge
%                 Action_Resume(Housenumber,var) = sum(MyInput3.NewVar.Total_Action2(Housenumber,:,var));
%                 Avg_Week(Housenumber,var) = MyInput3.NewVar.Vec_Mean_Act_Week(Housenumber,2,var);
%                 Avg_Year(Housenumber,var) = sum(MyInput3.NewVar.Appliances_Cons(Housenumber,:,var));
%                 Max_Use(Housenumber,var) = MyInput3.NewVar.Appliances_Char(str2double(Input_Data.Input_Data.(Houseused{Housenumber}).inhabitants),1,var2);
%             end
%         end
        inhabitants = str2double(Input_Data.Input_Data.(HouseTag).inhabitants) ;
        for AppNum = 1:numel(AppClassName)
            AppName = AppClassName{AppNum} ;
            AppSN = Input_Data.Input_Data.(HouseTag).(AppName) ;
            if ~strcmp(AppSN{1},'0')
                Action_Res  = 0  ;
                AvgWeek     = 0     ;
                AvgYear     = 0 ;
                MaxUse     = 0 ;
                WeekDistribWeekday  = zeros(7,1) ;
                WeekDistribWeek     = zeros(7,1) ;
                if MyInput3.NewVar.TimeoffsetStr == 0
                    startOffset = 1;
                else
                    startOffset = MyInput3.NewVar.TimeoffsetStr ;
                end
                for subapp = 1:numel(AppSN)
                    Action_Res  = Action_Res    +  MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).ActionQty ;
                    AvgWeek     = AvgWeek       +  MyInput3.NewVar.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseTag)(2);
                    AvgYear     = AvgYear       + sum(MyInput3.NewVar.Appliances_ConsStr.(AppName)(subapp).(HouseTag));
                    MaxUse      = MaxUse        + MyInput3.NewVar.Appliances_CharStr.(HouseTag).(AppName)(inhabitants).MaxUse;
                    
                    TimeUseVec  = MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).time_for_recordStr ;
                    TimeUseVec(TimeUseVec==0)=[];
                    time_per_cycle.(AppName)(subapp).(HouseTag) =   mean(TimeUseVec) * 60;
                    Weekly_Avg.(AppName)(subapp).(HouseTag) = sum(MyInput3.NewVar.Appliances_ConsStr.(AppName)(subapp).(HouseTag)) / numberofweeks;
                    
                    average_time = unique(MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).time_for_recordStr);
                    for each_hour_time = 1:size(average_time,2)
                       frequency_app.(AppName)(subapp).(HouseTag)(each_hour_time) = size(find(MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).time_for_recordStr == average_time(each_hour_time)),2) ...
                                                                                   /size(find(MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).time_for_recordStr > 0),2);
                    end      
                    for i = 1:7
                        
                        WeekDistribWeekday(i)   =  WeekDistribWeekday(i) + sum(MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).ActionQtyStep(find(myweekday(Traded.Time)==i))) ;
                        WeekDistribWeek(i)      =  WeekDistribWeek(i)    + sum(MyInput3.NewVar.App.Info.(AppName)(subapp).(HouseTag).ActionQtyStep(find(myweekday(Traded.Time)<=7))) ;
%                         WeekDistribWeekday(i)   = WeekDistribWeekday(i) + sum(MyInput3.NewVar.Total_Action2Str.(AppName)(subapp).(HouseTag)(find(myweekday(Traded.Time)==i))) ; % WeekDistribWeekday(i) + sum(MyInput3.NewVar.Total_Action2Str.(AppName)(subapp).(HouseTag)(find(myweekday(MyInput3.NewVar.TimeVectorStr(startOffset:startOffset + ArraytoLook))==i))) ;
%                         WeekDistribWeek(i)      = WeekDistribWeek(i) +    sum(MyInput3.NewVar.Total_Action2Str.(AppName)(subapp).(HouseTag)(find(myweekday(Traded.Time)<=7))) ; % WeekDistribWeek(i) +    sum(MyInput3.NewVar.Total_Action2Str.(AppName)(subapp).(HouseTag)(find(myweekday(MyInput3.NewVar.TimeVectorStr(startOffset:startOffset + ArraytoLook))<=7))) ;
                    end
                end
                Action_Resume.(HouseTag).(AppName)  = Action_Res ;
                Avg_Week.(HouseTag).(AppName)       = AvgWeek ; 
                Avg_Year.(HouseTag).(AppName)       = AvgYear ;
                Max_Use.(HouseTag).(AppName)        = MaxUse ;
                for i = 1:7
                    WeekDistrib.(HouseTag).(AppName)(i) = WeekDistribWeekday(i) / WeekDistribWeek(i) ;
                end
                
            end
        end

        %% Statistics per appliances
        if isempty(nbr_appliances)
            Appliance_nbr = 0 ;
            frequency_app = 0 ;
        else
            for eachapp = 1:size(nbr_appliances,1)
%                 Appliance_nbr = nbr_appliances(eachapp,2);
%                 Annual_Energy(Housenumber,eachapp) = sum(MyInput3.NewVar.Appliances_Cons(Housenumber,:,eachapp));
                % time_per_cycle(Housenumber,eachapp) =  Annual_Energy(Housenumber,eachapp) / Action_Resume(Housenumber,eachapp) / MyInput3.NewVar.Appliances_Char(1,8,Appliance_nbr) * 60;
%                 aa = MyInput3.NewVar.time_for_record;
%                 aaa = aa(Housenumber,:,eachapp)';
%                 aaa(aaa==0)=[];
%                 time_per_cycle(Housenumber,eachapp) =   mean(aaa) * 60;
%                 Weekly_Avg(Housenumber,eachapp) = sum(MyInput3.NewVar.Appliances_Cons(Housenumber,:,eachapp)) / 52;
%                 average_time = unique(MyInput3.NewVar.time_for_record(Housenumber,:,eachapp));
%                 for each_hour_time = 1:size(average_time,2)
%                    frequency_app(Housenumber,each_hour_time,eachapp) = size(find(MyInput3.NewVar.time_for_record(Housenumber,:,eachapp) == average_time(each_hour_time)),2)/size(find(MyInput3.NewVar.time_for_record(Housenumber,:,eachapp) > 0),2);
%                 end                
            end
        end
        
%         Frequency_app = frequency_app(2:end,:);
        %% Seasonal Plotting
        tic;
        datestart = datenum(Sartingyear)   ;
        DayStrt  = Sartingyear.Day         ;
        MonthStrt = Sartingyear.Month      ;
        MonthEnd = Endingyear.Month        ;
        NumberofMonths = months(datestr(Sartingyear),datestr(Endingyear)) + 1; % Number of months between the 2 dates
        
        for yy = 1:NumberofMonths
            % Increment the number of month
            if yy == 1
                Monthstudied    = MonthStrt ;
                daystart        = DayStrt   ;
            else
                Monthstudied    = Monthstudied + 1 ;
                daystart        = 1;
            end
            studiedTime         = datetime(Sartingyear.Year,Monthstudied,1) ;
            studiedMonth        = studiedTime.Month ;
            studiedMonthName    = GetMonthStr(studiedMonth) ;
            StudiedYear         = studiedTime.Year ;
            studiedMonthName    = [studiedMonthName num2str(StudiedYear)] ;
            % Define the number of month based on the 
%            if mod(Monthstudied,12) > 0
%                Monthstudied = mod(Monthstudied,12) ;
%            else
%                Monthstudied = Monthstudied / 12    ;
%            end
           a = Endingyear.Year ;

           % Note, it does'nt matter the month number, it can be higher
           % than 12 as the datenum function converts the month number into
           % 12 month and interpret the value.
           
           nbrdaysinmonth   = datenum(Sartingyear.Year,Monthstudied + 1,1) - datenum(Sartingyear.Year,Monthstudied,1); 
           nbrdaysincestart = datenum(Sartingyear.Year,Monthstudied,1) - datestart ;
           Daynumber1       = myweekday(datenum(Sartingyear.Year,Monthstudied,daystart)) ;
           arraytolookstart = nbrdaysincestart * 24 + 1 ;
           arraytolookend   = arraytolookstart + nbrdaysinmonth * 24 ;
%            if yy == MonthStrt
%                daystart = DayStrt;
%            else
%                daystart = 1;
%            end
%            if yy == MonthEnd
%                dayend = Endingyear.Day ;
%                monthend = yy ;
%            else
%                dayend = 1 ;
%                monthend = yy + 1 ;
%            end 
           
           
           
           
           
%            nbrdaysinmonth = datenum(Endingyear.Year,monthend,dayend) - datenum(Endingyear.Year,yy,daystart); % to be changed in the future to have multiple years
%            nbrdaysincestart = datenum(a,yy,daystart) - datestart ;
%            Daynumber1 = myweekday(datenum(a,yy,daystart)) ;
           
           for ArraytoLookvar = 1:2
               switch ArraytoLookvar
                   case 1
                            ArrayToAnalyse = MyInput2.Cons_Tot.(HouseTag).DataOutput(1:(end-1))';
                            Lastvariable = min(size(ArrayToAnalyse,2),arraytolookend) ;
                            [Arrayout(:,1,1),Arrayout(:,2,1),Arrayout(:,3,1)] = GetArray(ArrayToAnalyse,Daynumber1,arraytolookstart,Lastvariable,'Mean') ;
                            for arraysz = 1:size(Arrayout,2)
                                switch arraysz
                                    case 1
                                        Periode = 'weekdays' ;
                                    case 2
                                        Periode = 'saturday' ;
                                    case 3
                                        Periode = 'sunday'   ;
                                end
                                    
                                Daily_Profile_MeanConsStr.(Houseused{Housenumber}).(studiedMonthName).(Periode) = Arrayout(:,arraysz) ;
                            end
%                             Daily_Profile_MeanCons(Housenumber,:,:,yy) = Arrayout ;
                   case 2
                       for jj = 1:Nbr_Indic
                            ArrayToAnalyse = Emissions_ReCiPe.(Houseused{Housenumber}).EmissionHouseNetto.(Indic{Indicator,1})';
                            Lastvariable = min(size(ArrayToAnalyse,2),arraytolookend) ;
                            [Arrayout(:,1,1),Arrayout(:,2,1),Arrayout(:,3,1)] = GetArray(ArrayToAnalyse,Daynumber1,arraytolookstart,Lastvariable,'Mean') ;
                            for arraysz = 1:size(Arrayout,2)
                                switch arraysz
                                    case 1
                                        Periode = 'weekdays' ;
                                    case 2
                                        Periode = 'saturday' ;
                                    case 3
                                        Periode = 'sunday'   ;
                                end
                                Emission_ProfileVarStr.(Houseused{Housenumber}).(studiedMonthName).Profile(jj).(Periode) = Arrayout(:,arraysz) ;
                            end
%                             Emission_ProfileVar.Profile{jj}.EmissionsMean(Housenumber,:,:,yy) = Arrayout;
                            
                            [Arrayout(:,1,1),Arrayout(:,2,1),Arrayout(:,3,1)] = GetArray(ArrayToAnalyse,Daynumber1,arraytolookstart,Lastvariable,'Sum') ;
                            for arraysz = 1:size(Arrayout,2)
                                switch arraysz
                                    case 1
                                        Periode = 'weekdays' ;
                                    case 2
                                        Periode = 'saturday' ;
                                    case 3
                                        Periode = 'sunday'   ;
                                end
                                Emission_ProfileVarStr.(Houseused{Housenumber}).(studiedMonthName).Profile(jj).(Periode) = Arrayout(:,arraysz) ;
                            end
%                             Emission_ProfileVar.Profile{jj}.EmissionsSum(Housenumber,:,:,yy) = Arrayout;
                       end
               end
           end
        end
        ArrayToAnalyse = MyInput2.Cons_Tot.(HouseTag).DataOutput(1:(end-1))';
        [Arrayout,~,~] = GetArray(ArrayToAnalyse,8,1,size(ArrayToAnalyse,2),'Mean') ;
        for arraysz = 1:size(Arrayout,2)
            switch arraysz
                case 1
                    Periode = 'weekdays' ;
                case 2
                    Periode = 'saturday' ;
                case 3
                    Periode = 'sunday'   ;
            end
            Daily_Profile_MeanConsTotalStr.(Houseused{Housenumber}) = Arrayout(:,arraysz) ;
        end
%         Daily_Profile_MeanConsTotal(Housenumber,:) = Arrayout ;
        for jj = 1:1
            ArrayToAnalyse = Emissions_ReCiPe.(Houseused{Housenumber}).EmissionHouseNetto.(Indic{Indicator,1})';
            [Arrayout,~,~] = GetArray(ArrayToAnalyse,8,1,size(ArrayToAnalyse,2),'Mean') ;
            for arraysz = 1:size(Arrayout,2)
                switch arraysz
                    case 1
                        Periode = 'weekdays' ;
                    case 2
                        Periode = 'saturday' ;
                    case 3
                        Periode = 'sunday'   ;
                end
                Emission_Profile_MeanCO2Str.(Houseused{Housenumber}) = Arrayout(:,arraysz) ;
            end
%             Emission_Profile_MeanCO2(Housenumber,:) = Arrayout;
            [Arrayout,~,~] = GetArray(ArrayToAnalyse,8,1,size(ArrayToAnalyse,2),'Sum') ;
            for arraysz = 1:size(Arrayout,2)
                switch arraysz
                    case 1
                        Periode = 'weekdays' ;
                    case 2
                        Periode = 'saturday' ;
                    case 3
                        Periode = 'sunday'   ;
                end
                Emission_Profile_SumCO2Str.(Houseused{Housenumber}) = Arrayout(:,arraysz) ;
            end
%             Emission_Profile_SumCO2(Housenumber,:) = Arrayout;
        end
        out = toc;
        TimeRetrieve(out,'The loop 1 took ');       
%% Overall Plotting
        t = toc;
        tn = tn + t ;
        avtime = tn / Housenumber;
        Firstappliance = fieldnames(MyInput3.NewVar.Total_Action2Str) ;
        FirstHouse = fieldnames(MyInput3.NewVar.Total_Action2Str.(Firstappliance{1})) ;
        vector = MyInput3.NewVar.Total_Action2Str.(Firstappliance{1}).(FirstHouse{1}) ;
        exptime = size(vector,2) * avtime;
        remtime = exptime - tn;
        YY = TimeRetrieve(remtime,'     Time remaining: ');
        fprintf(1, repmat('\b',1,count)); %delete line before
        count = fprintf(YY);
        NewPath = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder);
    end
%% Save the variables if Needed
        choicesaving = questdlg('Would you like to save all variables for further use?',...
                        'Let See',...
                        'Yes, And Erase previous variables', ...
                        'Yes, But KEEP previous variables',...
                        'No, Continue without saving','No, Continue without saving');
                    switch choicesaving
                        case 'Yes, And Erase previous variables'
                            MyListloop = {listing(:,1).name};
                                    AllResultsFileloop = find(cellfun(@isempty,regexp(MyListloop, 'Results')) == 0);
                                    strloop = {listing(AllResultsFileloop).name};
                                    [svarloop,~] = listdlg('PromptString','Select a file:',...
                                                    'SelectionMode','multiple',...
                                                    'ListString',strloop);
                                    for Foldervar = 1:length(svarloop)
                                        Current_FolderLoop = strloop(svarloop(Foldervar));
                                        currLoop = strcat(Output_Folder,filesep,Project_ID,filesep,Current_FolderLoop{1});
                                        currlistLoop = dir(currLoop);
                                        if max(cellfun('length',{currlistLoop.name})) > 2
                                            [stopsimLoop]=closePDF(Output_Folder,Project_ID,Current_FolderLoop{1});
                                            if stopsimLoop == 1;return;end
                                            rehash()
                                            [SUCCESSLOOP,MESSAGELOOP,~] = rmdir(currLoop,'s');
                                            if SUCCESSLOOP == 0;display([MESSAGELOOP,' ','The folder ',Current_FolderLoop{1},' is being used']);end
                                        else
                                            rehash()
                                            [SUCCESSLOOP,MESSAGELOOP,~] = rmdir(currLoop,'s');
                                            if SUCCESSLOOP == 0;display([MESSAGELOOP,' ','The folder ',Current_FolderLoop{1},' is being used']);end
                                        end
                                    end
                            FunctionName = dbstack() ;
                            Save_Files = {'nbr_applinces'
                                          'Action_Resume'
                                          'Avg_Week'
                                          'Max_Use'
                                          'Avg_Year'
                                          'time_per_cycle'
                                          'Daily_Profile_MeanConsTotal'
                                          'Daily_Profile_MeanCons'
                                          'Emission_Profile_MeanCO2'
                                          'Emission_Profile_SumCO2'
                                          'Output_Folder'
                                          'Project_ID'
                                          'New_Folder'
                                          'NewPath'} ;
                                      
                            save(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder,filesep,Result_Numb,'_',FunctionName(2).name,'.mat'),Save_Files);
                        case 'Yes, But KEEP previous variables'
                            FunctionName = dbstack() ;
                            save(strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder,filesep,Result_Numb,'_',FunctionName(2).name,'.mat'),'nbr_applinces',...
                                                                                                                                                 'Action_Resume',...
                                                                                                                                                 'Avg_Week',...
                                                                                                                                                 'Max_Use',...
                                                                                                                                                 'Avg_Year',...
                                                                                                                                                 'time_per_cycle',...
                                                                                                                                                 'Daily_Profile_MeanConsStr',...
                                                                                                                                                 'Daily_Profile_MeanConsTotalStr',...
                                                                                                                                                 'Emission_Profile_MeanCO2Str',...
                                                                                                                                                 'Emission_Profile_SumCO2Str',...
                                                                                                                                                 'Output_Folder',...
                                                                                                                                                 'Project_ID',...
                                                                                                                                                 'New_Folder',...
                                                                                                                                                 'NewPath',...
                                                                                                                                                 'HourlyEmissions',...
                                                                                                                                                 'Hourly_Fingrid',...
                                                                                                                                                 'timeRange',...
                                                                                                                                                 'Exchanged_Electricity');
                            save(strcat(Output_Folder,filesep,Project_ID,filesep,'Emissions_ReCiPe.mat'),'Emissions_ReCiPe')         ;
                        case 'No, Continue without saving'
                    end    
end
%% Function dailyCO2
%                 for eachapp = 1:size(nbr_appliances,1)
% %                      Distribution_app(var_hour+1,eachapp,weekday_var,var_month)=  mean(Appliances_Cons(1,find(...
% %                                                                                                        month(TimeVector(Timeoffset:Timeoffset + myiter))==var_month & ...
% %                                                                                                        myweekday(TimeVector(Timeoffset:Timeoffset + myiter))<=5 & ...
% %                                                                                                        hour(TimeVector(Timeoffset:Timeoffset + myiter))==var_hour),eachapp));
%                 for eachapp = 1:size(nbr_appliances,1)
% %                     Distribution_app(var_hour+1,eachapp,weekday_var,var_month)=  mean(Appliances_Cons(1,find(...
% %                                                                                                        month(TimeVector(Timeoffset:Timeoffset + myiter))==var_month & ...
% %                                                                                                        myweekday(TimeVector(Timeoffset:Timeoffset + myiter))==var_day & ...
% %                                                                                                        hour(TimeVector(Timeoffset:Timeoffset + myiter))==var_hour),eachapp));
    function MonthStr = GetMonthStr(MonthNumber)
          months = {'January', 'February', 'March', 'April', 'May', 'June','July', 'August', 'September', 'October', 'November', 'December'};
          if MonthNumber >= 1 && MonthNumber <= length(months)
            MonthStr = months{MonthNumber} ;
          end
    end
%% Function GetArray
    function [weekdays_mean, Satmean, Sunmean] = GetArray(ArrayToAnalyse,Daynumber1,arraytolookstart,arraytolookend,mathfunc)
        switch Daynumber1
            case {1}
                TimeLeftIterOne = 6 - Daynumber1 ;
                Period1Start    = arraytolookstart ;
                Period1End      = Period1Start + TimeLeftIterOne * 24 - 1;
                SatStart        = Period1End + 1 ;
                SatEnd          = SatStart + 23 ;
                SunStart        = SatEnd + 1 ;
                SunEnd          = SunStart + 23 ;
                Period4Start    = [] ;
                Perdio4End      = [];
            case {2,3,4,5}
                TimeLeftIterOne = 6 - Daynumber1 ;
                Period1Start    = arraytolookstart ;
                Period1End      = Period1Start + TimeLeftIterOne * 24 - 1;
                SatStart        = Period1End + 1 ;
                SatEnd          = SatStart + 23 ;
                SunStart        = SatEnd + 1 ;
                SunEnd          = SunStart + 23 ;
                Period4Start    = SunEnd + 1 ;
                Perdio4End      = Period1Start + 168 - 1;
            case 6
                SatStart        = arraytolookstart ;
                SatEnd          = SatStart + 23 ;
                SunStart        = SatEnd + 1 ;
                SunEnd          = SunStart + 23 ;
                Period1Start    = SunEnd + 1  ;
                Period1End      = Period1Start + 5 * 24 - 1;
                Period4Start    = [] ;
                Perdio4End      = [];
            case 7
                SunStart        = arraytolookstart ;
                SunEnd          = SunStart + 23 ;
                Period1Start    = SunEnd + 1  ;
                Period1End      = Period1Start + 5 * 24 - 1;
                Period4Start    = [] ;
                Perdio4End      = [];
                SatStart        = Period1End + 1 ;
                SatEnd          = SatStart + 23 ;
            otherwise
                Period1Start    = arraytolookstart ;
                Period1End      = 168 ;
                SatStart        = [] ;
                SatEnd          = [] ;
                SunStart        = [] ;
                SunEnd          = [] ;
                Period4Start    = [] ;
                Perdio4End      = [];
        end
        MaxWeek = ceil(size(ArrayToAnalyse(arraytolookstart:arraytolookend),2)/168);
        Weekdays1 = zeros(MaxWeek,(Period1End - Period1Start + 1));
        Weekdays2 = zeros(MaxWeek,(Perdio4End - Period4Start + 1));
        Saturday  = zeros(MaxWeek,(SatEnd - SatStart + 1));
        Sunday    = zeros(MaxWeek,(SunEnd - SunStart + 1));

        for iii = Period1Start:Period1End
            a = ArrayToAnalyse(iii:168:arraytolookend)';
            Weekdays1(1:size(a,1),iii-Period1Start + 1)  = a;
        end
        for iii = Period4Start:Perdio4End
            a = ArrayToAnalyse(iii:168:arraytolookend)';
            Weekdays2(1:size(a,1),iii-Period4Start + 1)  = a;
        end
        Weekdays = [Weekdays2,Weekdays1];
        Weekdays(Weekdays == 0) = NaN;
        weekdays_mean = zeros(24,1);
        for iii = 1:24
            if strcmp(mathfunc,'Sum')
                weekdays_mean(iii,1) = nansum(reshape(Weekdays(:,iii:24:end),[],1));
            elseif strcmp(mathfunc,'Mean')
                weekdays_mean(iii,1) = nanmean(reshape(Weekdays(:,iii:24:end),[],1));
            end
        end
        for iii = SatStart:SatEnd
            b = ArrayToAnalyse(iii:168:arraytolookend)';
            Saturday(1:size(b,1),iii-SatStart + 1) = b;
        end
        Saturday(Saturday == 0) = NaN;
        
        if strcmp(mathfunc,'Sum')
            Satmean = nansum(Saturday)';
        elseif strcmp(mathfunc,'Mean')
            Satmean = nanmean(Saturday)';
        end
        
        for iii = SunStart:SunEnd
            b = ArrayToAnalyse(iii:168:arraytolookend)';
            Sunday(1:size(b,1),iii-SunStart + 1) = b;
        end
        Sunday(Sunday == 0) = NaN;
        if strcmp(mathfunc,'Sum')
            Sunmean = nansum(Sunday)';
        elseif strcmp(mathfunc,'Mean')
            Sunmean = nanmean(Sunday)';
        end
    end
%% Figure Plotting
function Plot_Output(nbr_applinces,Action_Resume,Avg_Week,Max_Use,Avg_Year,time_per_cycle,Daily_Profile_Overall,Daily_Profile,Daily_Profile_Plot_CO2,Daily_Profile_Sum_CO2,Output_Folder,Project_ID,New_Folder,NewPath)        

    XAxis_Label = {'WashMach',...
                   'DishWash',...
                   'Elec',...
                   'Kettle',...
                   'Oven',...
                   'MW',...
                   'Coffee',...
                   'Toas',...
                   'Waff',...
                   'Fridge',...
                   'Radio',...
                   'Laptop',...
                   'Elecheat',...
                   'Shaver',...
                   'Hair',...
                   'Tele',...
                   'Stereo',...
                   'Iron',...
                   'Vacuum',...
                   'Charger',...
                   'Sauna'};
               
    disp('          Plotting statistical information ...');
    
    y = 1;
    figureList = {} ;
    newgcf = gcf ;
    if isempty(newgcf.Number)
        startingnumber = 1;
    else
        startingnumber = newgcf.Number ;
    end
    for Housenumbervar = 1:MyInput3.NewVar.Nbr_BuildingStr
        %%% Number of Activity
        HouseNames = fieldnames(Action_Resume)  ;
        HouseName  = HouseNames{Housenumbervar} ;
        hFigures(startingnumber) = figure('Visible','off') ;
        hFigures(startingnumber).Tag = ['Figure',num2str(startingnumber)]  ;
%         figure(newgcf,'Visible','off')
        if y == 0
            close(hFigures(startingnumber-1))
        else
            y = 0;
        end
        AllApp = fieldnames(Action_Resume.(HouseName)) ;
        XAxis_Label = AllApp' ;
        subplot(3,1,1)
        for i = 1:numel(AllApp)
            stem(i,Action_Resume.(HouseName).(AllApp{i}));
            hold on ;
        end
        
        axis_setting(1,numel(AllApp),XAxis_Label)
        title('Number of Activity ["]');
        %%% Weekly Average
        subplot(3,1,2)
        for i = 1:numel(AllApp)
            plot(i,Avg_Week.(HouseName).(AllApp{i}),'Marker','o','MarkerEdgeColor','b');
            hold on ;
            plot(i,Max_Use.(HouseName).(AllApp{i}),'Marker','o','MarkerEdgeColor','r') ;
            hold on ;
        end
%         plot(nbr_applinces(:,2,Housenumbervar),Avg_Week(Housenumbervar,:),'o',nbr_applinces(:,2,Housenumbervar),Max_Use(Housenumbervar,:),'ro');
        axis_setting(1,numel(AllApp),XAxis_Label)
        title('Weekly average use of each appliance ["]');
        suptitle(strcat('House Number "',' ',num2str(Housenumbervar),'", Fig1: Appliances usage and Fig2: the Weekly Average')); 
        %%% Total electricity consumption per appliance
        subplot(3,1,3)
        for i = 1:numel(AllApp)
            plot(i,Avg_Year.(HouseName).(AllApp{i}),'o');
            hold on ;
        end
%         plot(nbr_applinces(:,2,Housenumbervar),Avg_Year(Housenumbervar,:),'o');
        axis_setting(1,numel(AllApp),XAxis_Label)
        title('Weekly average use of each appliance ["]');
        suptitle(strcat('House Number "',' ',num2str(Housenumbervar),'", Fig1: Appliances usage and Fig2: the Weekly Average')); 
        
        print2pdf(hFigures(startingnumber))
        if numel(figureList) == 0
            figureList{1} = strcat('Figure',num2str(startingnumber)) ;
        else
            figureList{end+1} = strcat('Figure',num2str(startingnumber)) ;
        end
        %%% Average Time of Use per Activity
        Graph = gcf;
        startingnumber = startingnumber + 1;
        hFigures(startingnumber) = figure('Visible','off') ;
        hFigures(startingnumber).Tag = ['Figure',num2str(startingnumber)]  ;
%         figure(newgcf,'Visible','off')
        close(hFigures(startingnumber - 1))
        
        for i = 1:numel(AllApp)
            stem(repmat(i,1,size([time_per_cycle.(AllApp{i}).(HouseName)],2)),[time_per_cycle.(AllApp{i}).(HouseName)]);
            hold on ;
        end
        
%         stem(nbr_applinces(:,2,Housenumbervar),time_per_cycle(Housenumbervar,:)');
        axis_setting(1,numel(AllApp),XAxis_Label)
        title('Average time of use of each appliance [min]');
        suptitle(strcat('House Number "',' ',num2str(Housenumbervar),'", Average time of use per activity')); 
        print2pdf(hFigures(startingnumber))
        figureList{end+1} = strcat('Figure',num2str(startingnumber)) ;
        startingnumber = startingnumber + 1;
    end
    disp('          Plotting daily profiles ...');
    %%% Daily Profiles
    for Housenumbervar = 1:MyInput3.NewVar.Nbr_BuildingStr
        varh = 1;
        HouseName  = HouseNames{Housenumbervar} ;
        
        hFigures(startingnumber) = figure('Visible','off') ;
        hFigures(startingnumber).Tag = ['Figure',num2str(startingnumber)]  ;
        close(hFigures(startingnumber-1))
        
        for vari = 1:12
            MonthName = GetMonthStr(vari) ;
            FieldWithMonth = fieldnames(Daily_Profile.(HouseName)) ;
            AllMonth = find(contains(fieldnames(Daily_Profile.(HouseName)),MonthName),1) ;
            if ~isempty(AllMonth)
                AvgMonthlyProf = [] ;
                for varj = 1:3
                    subplot(12,3,varh)
                    for i = 1:numel(AllMonth)
                        MonthTitle = FieldWithMonth{AllMonth(i)} ;
                        switch varj
                            case 1
                                Periode = 'weekdays' ;
                            case 2
                                Periode = 'saturday' ;
                            case 3
                                Periode = 'sunday'   ;
                        end
                        AvgMonthlyProf(:,i) = Daily_Profile.(HouseName).(MonthTitle).(Periode) ;
                    end
                    AvgMonthlyProf = mean(AvgMonthlyProf,2) ;
                    varh = varh + 1;
                    stairs(AvgMonthlyProf)
                    hold on
                end
            end
        end
        suptitle(strcat('House Number "',' ',num2str(Housenumbervar),'", Daily Profiles: Mon-Fri, Sat, Sun'));
        [~,h1]=suplabel('Days of the week, Mon-Fri, Sat, Sun','x'); 
        [~,h2]=suplabel('Month of the Year, Jan-Dec','y'); 
        set(h2,'FontSize',12)
        set(h1,'FontSize',12)
        print2pdf(hFigures(startingnumber)) ;
        figureList{end+1} = strcat('Figure',num2str(startingnumber)) ;
        startingnumber = startingnumber + 1;
    end
    disp('          Plotting yearly load profile ...');
    %%% Mean daily energy consumption Profile for yearly activities
    % All the plots are drawn on the same figure
    hFigures(startingnumber) = figure('Visible','off') ;
    hFigures(startingnumber).Tag = ['Figure',num2str(startingnumber)]  ;
    close(hFigures(startingnumber-1))
%     Graph = gcf;
%     newgcf = Graph.Number + 1;
%     figure(newgcf,'Visible','off')
%     close(figure(newgcf - 1))
    for Housenumbervar = 1 : MyInput3.NewVar.Nbr_BuildingStr
        HouseName  = HouseNames{Housenumbervar} ;
        Daily_Profile_Overall_Built(:,Housenumbervar) = Daily_Profile_Overall.(HouseName) ;
    end
    hplots = stairs(Daily_Profile_Overall_Built);
    clear Leg_Plot
    Leg_Plot = cell(MyInput3.NewVar.Nbr_BuildingStr,1);
    for BuildLeg = 1 : MyInput3.NewVar.Nbr_BuildingStr
       Leg_Plot{BuildLeg} = strcat('House Number',num2str(BuildLeg));
    end
    [~,~,~,~] = legend(Leg_Plot,'location','NorthWest');
    print2pdf(hFigures(startingnumber)) ;
    figureList{end+1} = strcat('Figure',num2str(startingnumber)) ;
    startingnumber = startingnumber + 1;
    disp('          Plotting yearly emission profile ...');
    %%% Mean daily CO2 Emissions Profile for yearly activities
    % All the plots are drawn on the same figure
    hFigures(startingnumber) = figure('Visible','off') ;
    hFigures(startingnumber).Tag = ['Figure',num2str(startingnumber)]  ;
    close(hFigures(startingnumber-1))
    
    for Housenumbervar = 1 : MyInput3.NewVar.Nbr_BuildingStr
        HouseName  = HouseNames{Housenumbervar} ;
        Daily_Profile_Plot_CO2_Built(:,Housenumbervar) = Daily_Profile_Plot_CO2.(HouseName) ;
    end
    hplots = stairs(Daily_Profile_Plot_CO2_Built);
    clear Leg_Plot
    Leg_Plot = cell(MyInput3.NewVar.Nbr_BuildingStr,1);
    for BuildLeg = 1 : MyInput3.NewVar.Nbr_BuildingStr
       Leg_Plot{BuildLeg} = strcat('House Number',num2str(BuildLeg));
    end
    suptitle('CO2 Mean Profile');
    [~,~,~,~] = legend(Leg_Plot,'location','NorthWest');
    print2pdf(hFigures(startingnumber)) ;
    figureList{end+1} = strcat('Figure',num2str(startingnumber)) ;
    startingnumber = startingnumber + 1;

    %%% Mean daily CO2 Cumulated Profile Profile for yearly activities
    % All the plots are drawn on the same figure
    hFigures(startingnumber) = figure('Visible','off') ;
    hFigures(startingnumber).Tag = ['Figure',num2str(startingnumber)]  ;
    close(hFigures(startingnumber-1))
    
    for Housenumbervar = 1 : MyInput3.NewVar.Nbr_BuildingStr
        HouseName  = HouseNames{Housenumbervar} ;
        Daily_Profile_Sum_CO2_Built(:,Housenumbervar) = Daily_Profile_Sum_CO2.(HouseName) ;
    end
    hplots = bar(Daily_Profile_Sum_CO2_Built);
    clear Leg_Plot
    Leg_Plot = cell(MyInput3.NewVar.Nbr_BuildingStr,1);
    for BuildLeg = 1 : MyInput3.NewVar.Nbr_BuildingStr
       Leg_Plot{BuildLeg} = strcat('House Number',num2str(BuildLeg));
    end
    suptitle('CO2 Cumulated Profile');
    [~,~,~,~] = legend(Leg_Plot,'location','NorthWest');
    print2pdf(hFigures(startingnumber)) ;
    figureList{end+1} = strcat('Figure',num2str(startingnumber)) ;
    Total_Fig{numel(figureList),1} = [];
%     Graph = gcf;
    figureorder = 1;
    for figuregcf = 1:numel(figureList)
        figureListName = figureList{figuregcf} ;
        Totfile = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder,filesep,figureListName,'.pdf');
        if iscell(Totfile)
            Totfile = Totfile{1};
        end
        Total_Fig{figureorder} = Totfile;
        figureorder = figureorder + 1 ;
    end
    disp('          Aggregating the figure in a single document...');
    %%% Create the aggregated .pdf
    filesList = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder,filesep,'*.pdf');
    AllPdf = dir(filesList);
    searchpat = regexp({AllPdf(:).name},'Graph Results');
    Graph_Num = sum(cellfun(@sum,searchpat)) + 1;
    PdfFile = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder,filesep,'Graph Results',num2str(Graph_Num),'.pdf');
    if iscell(PdfFile)
        PdfFile = PdfFile{1};
    end
    append_pdfs(PdfFile,Total_Fig{:});
    
    if iscell(NewPath)
        NewPath = NewPath{1};
    end
    addpath(NewPath);
    %%% Delete the Figure PDF
    [stopsim2]=closePDF(Output_Folder,Project_ID,New_Folder,'Figure');
    if stopsim2 == 1;return;end
    disp('     Finishing plotting ...');
    %% Closing the Figures
    choice = questdlg('Would you like to close all the figures?', ...
                    'Yes', ...
                    'No');
                switch choice
                    case 'Yes'
                        close all
                    case 'No'
                end
                openFolderwindow(strcat('"',NewPath,'"')) ;
                
                
    Win_Expl = ['explorer.exe',' ',NewPath];
    system(Win_Expl);
end
%% Open Folder window
    function openFolderwindow(myDir)
       % Just as an example; current dir
        % Windows PC    
        if ispc
            C = evalc(['!explorer ' myDir]);

        % Unix or derivative
        elseif isunix

            % Mac
            if ismac
                C = evalc(['!open ' myDir]);

            % Linux
            else
                fMs = {...
                    'xdg-open'   % most generic one
                    'gvfs-open'  % successor of gnome-open
                    'gnome-open' % older gnome-based systems               
                    'kde-open'   % older KDE systems
                   };
                C = '.';
                ii = 1;
                while ~isempty(C)                
                    C = evalc(['!' fMs{ii} ' ' myDir]);
                    ii = ii +1;
                end

            end
        else
            error('Unrecognized operating system.');
        end

        if ~isempty(C)
            error(['Error while opening directory in default file manager.\n',...
                'The reported error was:\n%s'], C); 
        end 
    end
%% Axis Setting
    function axis_setting(xmin,xmax,XAxis_Label)
        xlim([xmin,xmax]);
        NumTicks = xmax;
        Graph = gca;
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),NumTicks))
        set(gca,'XTickLabel',XAxis_Label)
        Graph.XTickLabelRotation = 45;
        %rotateXLabels(gca,45)
    end
%% PDF Making
    % Print the created figure to pdf
function print2pdf(Figurehandle)
    set(Figurehandle,'PaperOrientation','landscape');
    set(Figurehandle,'PaperPosition', [1 1 28 19]);
    PdfFile = strcat(Output_Folder,filesep,Project_ID,filesep,New_Folder,filesep,Figurehandle.Tag,'.pdf');
    if iscell(PdfFile)
        PdfFile = PdfFile{1};
    end
    print(Figurehandle, '-dpdf', PdfFile);
end
%%
function [stopsim] = closePDF(Output_Folder,Project_ID,Current_Folder,varargin)
    %%% Check if a pdf file is already open
    fileToDelete = {};
    closepdf = ('');
    % Set a couple of warnings to temporarily issue errors (exceptions)
    s = warning('error', 'MATLAB:DELETE:Permission');
    warning('error', 'MATLAB:DELETE:FileNotFound');
    % Run the processing section
    while isempty(closepdf)
        filesList = strcat(Output_Folder,filesep,Project_ID,filesep,Current_Folder,filesep,'*.pdf');
        AllPdf = dir(filesList);
        retryloop = 0;
        if ~length(AllPdf)==0
            for fileIndex = 1 : length(AllPdf)
                if retryloop == 0
                   if isempty(varargin)
                       try
                          % Regular processing part
                          fileToDelete{1} = strcat(Output_Folder,filesep,Project_ID,filesep,Current_Folder,filesep,AllPdf(fileIndex).name);
                          delete(fileToDelete{1});
                          closepdf = 1;
                       catch
                          % Exception-handling part
                          fprintf('Can''t delete %s (reason: %s)\n', fileToDelete{1}, lasterr);
                          choice = questdlg('The file is already open in another session. Close it and click "Continue". If you do not wish to continue, click "Stop"', ...
                                            'Warning',...
                                            'Continue', ...
                                            'Stop','Stop');
                            switch choice
                                case 'Continue'
                                    closepdf = ('');
                                    retryloop = 1;
                                    stopsim = 0;
                                case 'Stop'
                                    stopsim = 1;
                                    return
                            end
                       end
                   else
                       AllPdf(fileIndex).name;
                       searchpat = regexp(AllPdf(fileIndex).name,varargin);
                       if sum(cellfun(@sum,searchpat))>0
                           try
                              % Regular processing part
                              fileToDelete{1} = strcat(Output_Folder,filesep,Project_ID,filesep,Current_Folder,filesep,AllPdf(fileIndex).name);
                              delete(fileToDelete{1});
                              closepdf = 1;
                           catch
                              % Exception-handling part
                              fprintf('Can''t delete %s (reason: %s)\n', fileToDelete{1}, lasterr);
                              choice = questdlg('The file is already open in another session. Close it an click "Continue". If you do not wish to continue, click "Stop"', ...
                                                'Warning',...
                                                'Continue', ...
                                                'Stop','Stop');
                                switch choice
                                    case 'Continue'
                                        closepdf = ('');
                                        retryloop = 1;
                                        stopsim = 0;
                                    case 'Stop'
                                        stopsim = 1;
                                        return
                                end
                           end
                       else
                           closepdf = 1;
                           stopsim = 0 ;
                       end
                   end
                end
            end
            stopsim = 0;
        else
            closepdf = 1;
            stopsim = 0;
        end
    end
    % Restore the warnings back to their previous (non-error) state
    warning(s);
end
    function [Headers, Tech, Indic] = ReCiPe_Headers
        Tech{1} = 'Nuclear' ;
        Tech{2} = 'Wind' ;
        Tech{3} = 'DH' ;
        Tech{4} = 'Ind' ;
        Tech{5} = 'Others' ;
        Tech{6} = 'Hydro' ;
        
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
        
        IndicatorListShort = {'CC'
                              'OD' 
                              'TA' 
                              'FEut' 
                              'MEut' 
                              'HT' 
                              'POF' 
                              'PMF' 
                              'TEco' 
                              'FEco'
                              'MEco'
                              'IR'
                              'ALO'
                              'ULO'
                              'NLT'
                              'WD'
                              'MD'
                              'FD'} ;
                          
        Indic = [IndicatorList IndicatorListShort] ;
        Headers{1} = 'TimeStamp' ;
 
        for ii = 1:size(Indic,1)
            for jj = 1:length(Tech)
                Headers{end+1} = [Indic{ii,2},'_',Tech{jj}] ;
            end
        end
    end
end

