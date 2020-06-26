function [Profile, ConvertedArray, varargout] = profileploting(App, Cons_Tot, Time_Sim, SelectedHouse, dataBE, Recalculate10s, Plotstyle)


[Profile, ConvertedArray] = profileplotVar(App, Cons_Tot, Time_Sim, SelectedHouse, dataBE, 'Appliances_ConsStr', 1) ;

plotprofile(App, Cons_Tot, Time_Sim, ConvertedArray, SelectedHouse, Plotstyle) ;

try 
    ProjectList = fieldnames(App)                                   ;
    AppList     = fieldnames(App.(ProjectList{1}).Info)                                ;
    HouseList   = fieldnames(App.(ProjectList{1}).Info.(AppList{1})(1))                ;
    Array       = App.(ProjectList{1}).Info.(AppList{1})(1).(HouseList{1}).App10s      ;
catch
    warndlg('Missing the detailed profile, cannot plot it if it was requested','App10s missing') ;
    Array = [] ;
end

if ~isempty(Array)
    % Draw the load profile of the houses in case the 10s were recorded
    [Profile10s, ConvertedArray10s] = profileplotVar(App, Cons_Tot, Time_Sim, SelectedHouse, dataBE, 'App10s', Recalculate10s) ;
    varargout{1} = Profile10s ;
    varargout{2} = ConvertedArray10s ;
    plotprofile(App, Cons_Tot, Time_Sim, ConvertedArray10s, SelectedHouse, Plotstyle)
else
    varargout{1} = [] ;
    varargout{2} = [] ;
end

%% Function draw the load profile for variable timestep
   function [Profile, ConvertedArray] = profileplotVar(App, Cons_Tot, Time_Sim, SelectedHouse, dataBE, Variableinput, Recalculate)
        AllProjects = fieldnames(App) ;

        for iProject = 1:length(AllProjects)
            ProjectName = AllProjects{iProject} ;

            AllApps     = fieldnames(App.(ProjectName).Appliances_ConsStr) ;

            if nargin > 4
                AllHouses   = SelectedHouse ;
                VarDraw     = Variableinput ;
                
                switch VarDraw
                    case 'Appliances_ConsStr'
                       AppCons     = App.(ProjectName).Appliances_ConsStr  ;
                        try 
                            data                = dataBE ;
                            dataProfile         = data.Profile ;
                            dataConvertedArray  = data.ConvertedArray  ;
                        catch
                            data = false ;
                        end
                    case 'App10s'
                        %App.Info.(AllApps{i})(io).(HouseList{ij}).App10s
                       AppCons     = App.(ProjectName).Info  ;
                       if Recalculate
                           data = false ;
                       else
                           try 
                                data                 = dataBE                   ;
                                dataProfile          = data.Profile10s          ;
                                dataConvertedArray   = data.ConvertedArray10s   ;
                           catch
                                data = false ;
                           end
                       end
                end
            elseif nargin > 3
                AllHouses   = SelectedHouse ;
            else
                AllHouses   = fieldnames(Cons_Tot) ;
            end
            
            if ~isa(data,'struct')
                Time_Sim2Pass   = Time_Sim.(ProjectName)                ;
                App2Pass        = App.(ProjectName)                     ;
                [Profile.(ProjectName), ConvertedArray.(ProjectName)] = Profilehouse(AllHouses, AllApps, Time_Sim2Pass, App2Pass, AppCons, VarDraw) ;
            else
                Profile         = dataProfile        ;
                ConvertedArray  = dataConvertedArray ;
            end
        end
   end
%% Loop through the houses
    function [Profile, ConvertedArray] = Profilehouse(AllHouses, AllApps, Time_Sim, App, Cons_Input, VarDraw)
        TimeStep    = Time_Sim.MinperIter * 60 ;
        for iHouse = 1:length(AllHouses)
            HouseTag = AllHouses{iHouse} ;
            stime    = datetime(Time_Sim.StartDate.(HouseTag),'ConvertFrom','datenum')  ;
            for iApp = 1:length(AllApps)
                AppName = AllApps{iApp} ;
                subapp = size(App.Info.(AppName),2) ;
                for isubapp = 1:subapp
                     % Gather all variables under 1 timetable
                     AppCons = extractVar(VarDraw, Cons_Input, AppName, isubapp, HouseTag) ;
                     if isempty(AppCons)
                         continue;
                     end

                     AppNameSingle  = [AppName num2str(isubapp)] ;
                     if ~isempty(AppCons)
                         ProfileApp = ConvertTimeTable(AppCons, TimeStep, stime, AppNameSingle)           ;
                         try
                             Profile.(HouseTag) = synchronize(Profile.(HouseTag), ProfileApp) ;
                         catch
                             % Profile does not exist so we create it
                             Profile.(HouseTag) = ProfileApp;
                         end
                     end
                end
            end
            hourOfDay = Profile.(HouseTag).Time.Hour + Profile.(HouseTag).Time.Minute / 60 + Profile.(HouseTag).Time.Second / 3600 ;
            % Loop through each time step of a day 
            switch VarDraw
                case 'Appliances_ConsStr'
                   StepDraw = TimeStep / 3600 ;
                case 'App10s'
                    %App.Info.(AllApps{i})(io).(HouseList{ij}).App10s
                   TimeStep = 10 ;
                   StepDraw = 10 / 3600 ;
            end
            
            if StepDraw > 1/360
                for b = 0:StepDraw:24
                    selectedTimes = hourOfDay >= b & hourOfDay < (b + StepDraw); 
                    StatHour = Profile.(HouseTag)(selectedTimes,:) ;
                    ProfileHourTemp = retime(StatHour,'yearly','mean');
                    try
                            ProfileHour.(HouseTag) = [ProfileHour.(HouseTag); ProfileHourTemp(1,:)] ;
                    catch
                         % Profile does not exist so we create it
                        if ~isempty(ProfileHourTemp)
                            ProfileHour.(HouseTag) = ProfileHourTemp(1,:);
                        end
                    end
                end
            else
                Profile2Investigate = Profile.(HouseTag) ;
                parfor b = 0:(24/StepDraw)
                    bLook = b * StepDraw ;
                    selectedTimes = (round(hourOfDay,6) == round(bLook,6)) ; %hourOfDay == bLook ; 
                    StatHour = Profile2Investigate(selectedTimes,:) ;
                    ProfileHourTemp = retime(StatHour,'yearly','mean');
                    try
                            ProfileHour(b + 1).(HouseTag) = ProfileHourTemp(1,:) ;
                    catch
                         % Profile does not exist so we create it
                        if ~isempty(ProfileHourTemp)
                            ProfileHour(b + 1).(HouseTag) = ProfileHourTemp(1,:);
                        end
                    end
                end
                ProfileHourv2 = [] ;
                for iprofile = 1:length(ProfileHour)
                    try
                        ProfileHourv2 = [ProfileHourv2 ; ProfileHour(iprofile).(HouseTag) ] ;
                    catch
                        % Profile does not exist so we create it
                        if ~isempty(ProfileHour(iprofile).(HouseTag))
                            ProfileHourv2 = ProfileHour(iprofile).(HouseTag) ;
                        end
                    end
                end
                ProfileHour = [] ;
                ProfileHour.(HouseTag) = ProfileHourv2 ;
            end  
            ProfileHour.(HouseTag)      = timetable2table(ProfileHour.(HouseTag),'ConvertRowTimes',false) ;
            ConvertedArray.(HouseTag)   = ConvertTimeTableProfile(ProfileHour.(HouseTag), TimeStep) ;

            % sort the output file to classify the appliances from the one that
            % varies the least to the one that varies the most
            stddev=std(ConvertedArray.(HouseTag).Variables)';
            Sortstddev = table(stddev,'RowNames',ConvertedArray.(HouseTag).Properties.VariableNames') ;
            tblB = sortrows(Sortstddev) ;
            SortedApp = tblB.Properties.RowNames ;
            ConvertedArray.(HouseTag) = movevars(ConvertedArray.(HouseTag),SortedApp,'Before',1);
        end
    end
%% Function extract the correct output variable
    function AppCons = extractVar(VarDraw, Cons_Input, AppName, isubapp, HouseTag)
        try
            switch VarDraw
                case 'Appliances_ConsStr'
                   AppCons     = Cons_Input.(AppName)(isubapp).(HouseTag)  ;
                case 'App10s'
                    %App.Info.(AllApps{i})(io).(HouseList{ij}).App10s
                   AppCons     = Cons_Input.(AppName)(isubapp).(HouseTag).App10s  ;
            end
        catch
            AppCons = [] ;
        end
    end
%% Plot the profiles
    function plotprofile(App, Cons_Tot, Time_Sim, ConvertedArray, HouseSelected, Plotstyle)
        AllProjects = fieldnames(App) ;
        for iProject = 1:length(AllProjects)
            newgcf = gcf ;
            if isempty(newgcf.Number)
                startingnumber = 1;
            else
                startingnumber = newgcf.Number ;
            end
            hFigures(startingnumber) = figure('Visible','off') ;

            ProjectName = AllProjects{iProject} ;

%             AllApps     = fieldnames(App.(ProjectName).Appliances_ConsStr) ;

            if nargin > 3
                AllHouses   = HouseSelected ;
            else
                AllHouses   = fieldnames(Cons_Tot) ;
            end
%             TimeStep    = Time_Sim.(ProjectName).MinperIter * 60 ;
%             StepDraw    = 24 / size(ConvertedArray.(ProjectName).(HouseTag).Variables, 1) ; % TimeStep / 3600 ;
            nrow        = ceil(sqrt(length(AllHouses))) ;
            ncol        = ceil(length(AllHouses)/nrow)  ;

            for iHouse = 1:length(AllHouses)
                HouseTag = AllHouses{iHouse} ;
                StepDraw = 24 / size(ConvertedArray.(ProjectName).(HouseTag).Variables, 1) ;
                subplot(nrow,ncol,iHouse)
                switch Plotstyle
                    case 'area'
                        area(0:StepDraw:(24-StepDraw), ConvertedArray.(ProjectName).(HouseTag).Variables)
                        legend('Original Distribution',ConvertedArray.(ProjectName).(HouseTag).Properties.VariableNames) ;
                    case 'line'
                        line(0:StepDraw:(24-StepDraw), ConvertedArray.(ProjectName).(HouseTag).Variables)
                        clickableLegend('Original Distribution',ConvertedArray.(ProjectName).(HouseTag).Properties.VariableNames) ;
                end
                
                grid on
                grid minor
                ProjectNameTitle = strrep(ProjectName,'_','-') ;
                title([ProjectNameTitle ' - ' HouseTag])
                
            end
            hFigures(startingnumber).Visible = 'on' ;
        end
    end
%% Function to convert array
    function ConvertedArray = ConvertTimeTable(Input, TimeStep, stime, AppName)
        if isa(Input,'table')
            ConvertedArray = table2timetable(Input.DataOutput,'Timestep',seconds(TimeStep),'VariableNames',{AppName},'StartTime',stime) ;
        elseif isa(Input,'double')
            ConvertedArray = array2timetable(Input,'Timestep',seconds(TimeStep),'VariableNames',{AppName},'StartTime',stime) ;
        elseif isa(Input,'timetable')
            try
                Input.Properties.VariableNames{'DataOutput'} = AppName ;
            catch
                %Name is already good
            end
            ConvertedArray = Input ;
        end
    end
%% Function to convert array
    function ConvertedArray = ConvertTimeTableProfile(Input, TimeStep)
        if isa(Input,'table')
            ConvertedArray = table2timetable(Input,'Timestep',seconds(TimeStep)) ;
        elseif isa(Input,'double')
            ConvertedArray = array2timetable(Input,'Timestep',seconds(TimeStep)) ;
        elseif isa(Input,'timetable')
            ConvertedArray = Input ;
        end
    end

end