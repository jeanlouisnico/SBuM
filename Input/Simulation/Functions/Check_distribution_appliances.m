
function [Stat4Use_Profileextract,Distri_Cumsum, Info] = Check_distribution_appliances(varargin)

if nargin > 0
    App = varargin{1} ;
    Appliance = varargin{2} ;
    HouseTag  = varargin{3}   ;
    Time_Sim  = varargin{4}   ;
    All_Var   = varargin{5}   ;
else
    App = load('C:\Users\jlouis\MATLAB Drive V2\MatLab model Beta\Output\Simulation_15min_10s\App.mat') ;
    Appliance = 'Oven' ;
    HouseTag  = {'House1'}   ;
end
[varname] = variable_names;
% Extract the original data from the app variable

% Loop through each project
AllProjects = fieldnames(App) ;
for iProject = 1:length(AllProjects)
% Loop through each houses in the project
    for iHouse = 1:length(HouseTag)
        ProjectHouse= HouseTag{iHouse}     ;
        ProjectName = AllProjects{iProject} ;
        AppProject  = App.(ProjectName)     ;
        Time_SimProject = Time_Sim.(ProjectName)     ;
        if isa(All_Var, 'struct')
            All_VarProject  = All_Var.(ProjectName).ProfileUserdistri.(ProjectHouse)     ; % All_Var.ProfileUserdistri.(HouseName)
        else
            All_VarProject  = 0 ;
        end
        stime = datetime(Time_SimProject.StartDate.(ProjectHouse),'ConvertFrom','datenum')  ;
        if strcmp(Appliance,'All')
            AllApp = fieldnames(App.(ProjectName).Info) ;
            for iApp = 1:length(AllApp)
                App2extract = AllApp{iApp} ;
                [Stat4Use_Profileextract,Distri_Cumsum]                                  = getdistribution(AppProject, App2extract, ProjectHouse, Time_SimProject, stime, All_VarProject) ;
                Info.(App2extract).(ProjectName).(ProjectHouse).Stat4Use_Profileextract  = Stat4Use_Profileextract ;
                Info.(App2extract).(ProjectName).(ProjectHouse).Distri_Cumsum            = Distri_Cumsum ;
            end
        else
            [Stat4Use_Profileextract,Distri_Cumsum]                                = getdistribution(AppProject, Appliance, ProjectHouse, Time_SimProject, stime, All_VarProject) ;
            Info.(Appliance).(ProjectName).(ProjectHouse).Stat4Use_Profileextract  = Stat4Use_Profileextract ;
            Info.(Appliance).(ProjectName).(ProjectHouse).Distri_Cumsum            = Distri_Cumsum ;
        end
    end
end
% Plot all the data, differentiate if multiple sources
ToTrace = fieldnames(Info) ;
newgcf = gcf ;
if isempty(newgcf.Number)
    startingnumber = 1;
else
    startingnumber = newgcf.Number ;
end
hFigures(startingnumber) = figure('Visible','off') ;
if length(ToTrace) > 1
    % Plot a single plot
    nrow = floor(sqrt(length(ToTrace))) ;
    ncol = ceil(length(ToTrace)/nrow)  ;
    if isa(All_Var.(ProjectName).Stat4Use_Profile1(1).WashMach, 'struct') 
        Legend       = All_Var.(ProjectName).GuiInfo.DatabaseApp ;
    else
        Legend       = {'Original Distribution'} ;
    end
    for kplot = 1:length(ToTrace)
        iplot        = 1 ;
        iProjectName = 1 ;
        dataStat4Use = [];
        dataDistri_Cumsum = [] ;
        for iProject = 1:length(AllProjects)
            iHouseName = 1 ;
            ProjectName = AllProjects{iProject} ;
            for iHouse = 1:length(HouseTag)
                ProjectHouse      = HouseTag{iHouse} ; 
                try 
                    dataStat4Use               = Info.(ToTrace{kplot}).(ProjectName).(ProjectHouse).Stat4Use_Profileextract ;
                    dataDistri_Cumsum(:,iplot) = Info.(ToTrace{kplot}).(ProjectName).(ProjectHouse).Distri_Cumsum           ;
                    plotvar = true ;
                catch
                    % Appliance is not present in this project
                    try 
                        dataDistri_Cumsum ;
                        if isempty(dataDistri_Cumsum)
                            plotvar = false ;
                        end
                    catch
                        plotvar = false ;
                    end
                    
                    continue;
                end
                Legendname = ['Simulation Distribution-' ProjectName '-' ProjectHouse ] ;
                Legendname = strrep(Legendname,'_','-') ;
                if ~(any(strcmp(Legend,Legendname)))
                    Legend{length(Legend) + 1} = Legendname     ; 
                end
                iplot = iplot + 1 ;
                iHouseName = iHouseName + 1 ;
            end
            iProjectName = iProjectName + 1 ;
        end
        if isa(dataStat4Use, 'struct')
            allDB = fieldnames(dataStat4Use) ;
            for jDB = 1:length(allDB)
                dataStat4UseTemp(:,jDB) = dataStat4Use.(allDB{jDB}) ;
            end
            dataStat4Use = dataStat4UseTemp ;
        end
        if plotvar
            subplot(nrow,ncol,kplot)
            plot(0:24,dataStat4Use,1:24,dataDistri_Cumsum)
            grid on
            grid minor
            title(varname.(ToTrace{kplot}).LongName)
        end
    end
    clickableLegend('Original Distribution',Legend) ;
else
    Legend       = {'Original Distribution'} ;
    iplot        = 1 ;
    iProjectName = 1 ;
    dataStat4Use = [];
    dataDistri_Cumsum = [] ;
    for iProject = 1:length(AllProjects)
        iHouseName = 1 ;
        ProjectName = AllProjects{iProject} ;
        for iHouse = 1:length(HouseTag)
            ProjectHouse      = HouseTag{iHouse} ;
            try 
                dataStat4Use               = Info.(Appliance).(ProjectName).(ProjectHouse).Stat4Use_Profileextract ;
                dataDistri_Cumsum(:,iplot) = Info.(Appliance).(ProjectName).(ProjectHouse).Distri_Cumsum           ;
            catch
                % Appliance is not present in this project
                x = 1;
            end
            Legendname = ['Simulation Distribution-' ProjectName '-' ProjectHouse ] ;
            Legendname = strrep(Legendname,'_','-') ;
            if ~(any(strcmp(Legend,Legendname)))
                Legend{length(Legend) + 1} = Legendname     ; 
            end
            iplot = iplot + 1 ;
            iHouseName = iHouseName + 1 ;
        end
        iProjectName = iProjectName + 1 ;
    end
    if isa(dataStat4Use, 'struct')
        allDB = fieldnames(dataStat4Use) ;
        for jDB = 1:length(allDB)
            dataStat4UseTemp(:,jDB) = dataStat4Use.(allDB{jDB}) ;
        end
        dataStat4Use = dataStat4UseTemp ;
    end
    % Plot all as subplots and re-arrange them
    plot(0:24,dataStat4Use,1:24,dataDistri_Cumsum)     ;
    grid on
    grid minor
    title(varname.(Appliance).LongName)
    clickableLegend('Original Distribution',Legend) ;
end
hFigures(startingnumber).Visible = 'on' ;   
    
%-------------------------------------------------------------------------%
    function [Stat4Use_Profileextract,Distri_Cumsum] = getdistribution(App, Appliance, HouseTag, Time_Sim, stime, All_VarProject)
        try
            Data2Check          = App.Info.(Appliance)(1).(HouseTag).ActionQtyStep ;
        catch
            % The appliance does not exist for the house selected
            Stat4Use_Profileextract = zeros(25,1);
            Distri_Cumsum           = [] ;
            return;
        end
        TimeStep    = Time_Sim.MinperIter * 60 ;
        Data2Check = ConvertTimeTableProfile(Data2Check, TimeStep, stime) ;
        
        if isa(All_VarProject, 'double')
            Stat4Use_Profile1   = CreateStat4Use_Profile3 ;
        else
            Stat4Use_Profile1   = All_VarProject ;
        end

        for i_month = 1:size(Stat4Use_Profile1,1)
            for k_day = 1:size(Stat4Use_Profile1,2)
                if ndims(Stat4Use_Profile1) == 3    
                    for m_Hour = 1:size(Stat4Use_Profile1,3)
                        Stat4Use_Profile1v2(i_month).(Appliance)(m_Hour,k_day) = Stat4Use_Profile1(i_month,k_day,m_Hour).(Appliance) ;
                    end
                else
                    Stat4Use_Profile1v2(i_month).(Appliance)(k_day) = Stat4Use_Profile1(i_month,k_day).(Appliance) ;
                end
            end
        end

        Month2Check      = 'All' ; % 1 to 12
        TimePEriod2Check = 'All' ; % 1 to 3

        % Extract the database from the distribution file

        Stat4Use_Month = [] ;
            if strcmp(Month2Check,'All') && strcmp(TimePEriod2Check,'All')
                icol = 1 ;
                for ij = 1:12
                    for ik = 1:3
                        if isa(Stat4Use_Profile1v2(ij).(Appliance),'struct')
                            AppDB = fieldnames(Stat4Use_Profile1v2(ij).(Appliance)) ;
                            for iDB = 1:length(AppDB)
                                Stat4Use_Month(icol).(AppDB{iDB}) = Stat4Use_Profile1v2(ij).(Appliance)(ik).(AppDB{iDB}) ;
                            end
                        else
                            Stat4Use_Month(icol) = Stat4Use_Profile1v2(ij).(Appliance)(ik) ;
                        end
                        icol = icol + 1 ;
                    end
                end
                if isa(Stat4Use_Profile1v2(ij).(Appliance),'struct')
                    AppDB = fieldnames(Stat4Use_Profile1v2(ij).(Appliance)) ;
                    for iDB = 1:length(AppDB)
                        Stat4Use_Profileextract.(AppDB{iDB}) = mean([Stat4Use_Month.(AppDB{iDB})],2) ;
                    end
                else
                    Stat4Use_Profileextract = mean(Stat4Use_Month,2) ;
                end
                
            elseif strcmp(TimePEriod2Check,'All')
                if isa(Stat4Use_Profile1v2(Month2Check).(Appliance),'struct')
                    AppDB = fieldnames(Stat4Use_Profile1v2(Month2Check).(Appliance)) ;
                    for iDB = 1:length(AppDB)
                        Stat4Use_Profileextract.(AppDB{iDB}) = mean(Stat4Use_Profile1v2(Month2Check).(Appliance)(:).(AppDB{iDB}),2) ;
                    end
                else
                    Stat4Use_Profileextract = mean(Stat4Use_Profile1v2(Month2Check).(Appliance)(:,:),2) ;
                end
                
%                 Stat4Use_Profileextract = mean(Stat4Use_Profile1v2(Month2Check).(Appliance)(:,:),2) ;
            elseif strcmp(Month2Check,'All')
                if isa(Stat4Use_Profile1v2(Month2Check).(Appliance),'struct')
                    AppDB = fieldnames(Stat4Use_Profile1v2(Month2Check).(Appliance)) ;
                    for iDB = 1:length(AppDB)
                        for ij = 1:12
                            Stat4Use_Month(ij) = Stat4Use_Profile1v2(ij).(Appliance)(TimePEriod2Check).(AppDB{iDB}) ;
                        end
                        Stat4Use_Profileextract.(AppDB{iDB}) = mean(Stat4Use_Month,2) ;
                    end
                else
                    for ij = 1:12
                        Stat4Use_Month(:,ij) = Stat4Use_Profile1v2().(Appliance)(TimePEriod2Check) ;
                    end
                    Stat4Use_Profileextract = mean(Stat4Use_Month,2) ;
                end
            else
                if isa(Stat4Use_Profile1v2(Month2Check).(Appliance),'struct')
                    AppDB = fieldnames(Stat4Use_Profile1v2(Month2Check).(Appliance)) ;
                    for iDB = 1:length(AppDB)
                        Stat4Use_Profileextract.(AppDB{iDB}) = Stat4Use_Profile1v2(Month2Check).(Appliance)(TimePEriod2Check).(AppDB{iDB}) ;
                    end
                else
                    Stat4Use_Profileextract = Stat4Use_Profile1v2(Month2Check).(Appliance)(TimePEriod2Check) ;
                end
                
            end  


        % Extract the information from the simulation file
        for i_hour = 0:23
            if strcmp(Month2Check,'All') && strcmp(TimePEriod2Check,'All')
                outputdatatemp = Data2Check.DataOutput(Data2Check.Time.Hour == i_hour) ;
            elseif strcmp(Month2Check,'All')
                switch TimePEriod2Check
                    case 1
                        outputdatatemp = Data2Check.DataOutput(myweekday(Data2Check.Time) < 6 & ...
                                          Data2Check.Time.Hour == i_hour) ;
                    case 2
                        outputdatatemp = Data2Check.DataOutput(myweekday(Data2Check.Time) == 6 & ...
                                          Data2Check.Time.Hour == i_hour) ;
                    case 3
                        outputdatatemp = Data2Check.DataOutput(myweekday(Data2Check.Time) == 7 & ...
                                          Data2Check.Time.Hour == i_hour) ;
                end
        %         Stat4Use_Profileextract(i) = mean(Stat4Use_Month)
            elseif strcmp(TimePEriod2Check,'All')
                outputdatatemp = Data2Check.DataOutput(Data2Check.Time.Month == Month2Check     & ...
                                                      Data2Check.Time.Hour == i_hour) ;
            end  

            outputdata(i_hour + 1) =  sum(outputdatatemp)    ;
        end
        Total_Occurance = sum(outputdata) ;

        Distribution = outputdata / Total_Occurance ;
        Distri_Cumsum = cumsum(Distribution)        ;
        Distri_Cumsum = Distri_Cumsum';
    end
%%
    function ConvertedArray = ConvertTimeTableProfile(Input, TimeStep,stime)
        if isa(Input,'table')
            ConvertedArray = array2timetable(Input.DataOutput,'Timestep',seconds(TimeStep),'StartTime',stime, 'VariableNames',{'DataOutput'}) ;
        elseif isa(Input,'double')
            ConvertedArray = array2timetable(Input,'Timestep',seconds(TimeStep),'StartTime',stime,'VariableNames',{'DataOutput'}) ;
        elseif isa(Input,'timetable')
            ConvertedArray = Input ;
        end
    end
end
