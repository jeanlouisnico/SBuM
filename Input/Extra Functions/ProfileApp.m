function [ConvertedArray] = ProfileApp
        
    [file,path,~] = uigetfile('MultiSelect','on') ;
    
    parfor ifile = 1:length(file)
        Input_Profile = readtable([path file{ifile}]) ;
        Input_Profile.Time = datetime(datevec(Input_Profile.Time),'Format','yyyy-MM-dd HH:mm:ss');
        Input_Profile = table2timetable(Input_Profile) ;

        AppNameList = fieldnames(Input_Profile) ;
        n = 0 ;
        iAppName = 1 ;
        tic
        while n == 0
            AppName     = AppNameList{iAppName} ;
            if ~any(strcmp(AppName,{'Time' 'Variables' 'Unix' 'Properties'}))
                n = 1 ;
                 AppCons = Input_Profile.(AppName) ;
                 if isempty(AppCons)
                     continue;
                 end

              hourOfDay = Input_Profile.Time.Hour + Input_Profile.Time.Minute / 60 + Input_Profile.Time.Second / 3600 ;
                % Loop through each time step of a day 
                TimeStep = 3600 ; % We want the load profile on an hourly basis

                StepDraw = TimeStep / 3600 ;

                for b = 0:StepDraw:23
                    selectedTimes = hourOfDay >= b & hourOfDay < (b + StepDraw); 
                    StatHour = Input_Profile(selectedTimes,:)  ;
                    ProfileHourTemp = mean(StatHour.Variables) ;
                    try
                        ProfileHour = [ProfileHour; ProfileHourTemp ] ;
                    catch
                         % Profile does not exist so we create it
                        if ~isempty(ProfileHourTemp)
                            ProfileHour = ProfileHourTemp ;
                        end
                    end
                end
                ProfileHour                            = array2table(ProfileHour,'VariableNames',StatHour.Properties.VariableNames) ;
                ConvertedArray(ifile).OverallHourly    = ConvertTimeTableProfilePar(ProfileHour, TimeStep) ; 

                MonthofYear = Input_Profile.Time.Month ;

                for b = 1:12
                    selectedTimes = MonthofYear == b ; 
                    StatHour = Input_Profile(selectedTimes,:)  ;
                    ProfileHourTemp = sum(StatHour.Variables) ;
                    try
                        ProfileHourMonth = [ProfileHourMonth; ProfileHourTemp ] ;
                    catch
                         % Profile does not exist so we create it
                        if ~isempty(ProfileHourTemp)
                            ProfileHourMonth = ProfileHourTemp ;
                        end
                    end
                end
                ProfileHourMonth       = array2table(ProfileHourMonth,'VariableNames',StatHour.Properties.VariableNames) ;
                ConvertedArray(ifile).OverallMonthly    = ConvertTimeTableProfilePar(ProfileHourMonth, TimeStep) ; 

    %             for jmonth = 1:12
                    for i = 1:3
                        hourOfDay = Input_Profile.Time.Hour + Input_Profile.Time.Minute / 60 + Input_Profile.Time.Second / 3600 ;
                        WeekdayList = myweekday(Input_Profile.Time) ;
                        for b = 0:StepDraw:23
                            selectedTimesWeekDays = WeekdayList < 6 & hourOfDay >= b & hourOfDay < (b + StepDraw); 
                            selectedTimesSaturday = WeekdayList == 6 & hourOfDay >= b & hourOfDay < (b + StepDraw);
                            selectedTimesSunday = WeekdayList == 7 & hourOfDay >= b & hourOfDay < (b + StepDraw);

                            StatHourWeekDays = Input_Profile(selectedTimesWeekDays,:)  ;
                            StatHourSaturday = Input_Profile(selectedTimesSaturday,:)  ;
                            StatHourSunday = Input_Profile(selectedTimesSunday,:)  ;

                            ProfileHourTempWeekDays = mean(StatHourWeekDays.Variables) ;
                            ProfileHourTempSaturday = mean(StatHourSaturday.Variables) ;
                            ProfileHourTempSunday   = mean(StatHourSunday.Variables) ;

                            try
                                ProfileHourWeekDays = [ProfileHourWeekDays; ProfileHourTempWeekDays ] ;
                            catch
                                 % Profile does not exist so we create it
                                if ~isempty(ProfileHourTempWeekDays)
                                    ProfileHourWeekDays = ProfileHourTempWeekDays ;
                                end
                            end

                            try
                                ProfileHourSaturday = [ProfileHourSaturday; ProfileHourTempSaturday ] ;
                            catch
                                 % Profile does not exist so we create it
                                if ~isempty(ProfileHourTempSaturday)
                                    ProfileHourSaturday = ProfileHourTempSaturday ;
                                end
                            end

                            try
                                ProfileHourSunday = [ProfileHourSunday; ProfileHourTempSunday ] ;
                            catch
                                 % Profile does not exist so we create it
                                if ~isempty(ProfileHourTempSunday)
                                    ProfileHourSunday = ProfileHourTempSunday ;
                                end
                            end
                        end
                        ProfileHourWeekDays                     = array2table(ProfileHourWeekDays,'VariableNames',StatHour.Properties.VariableNames) ;
                        ProfileHourSaturday                     = array2table(ProfileHourSaturday,'VariableNames',StatHour.Properties.VariableNames) ;
                        ProfileHourSunday                       = array2table(ProfileHourSunday,'VariableNames',StatHour.Properties.VariableNames) ;

                        ConvertedArray(ifile).ProfileHourWeekDays    = ConvertTimeTableProfilePar(ProfileHourWeekDays, TimeStep) ; 
                        ConvertedArray(ifile).ProfileHourSaturday    = ConvertTimeTableProfilePar(ProfileHourSaturday, TimeStep) ; 
                        ConvertedArray(ifile).ProfileHourSunday      = ConvertTimeTableProfilePar(ProfileHourSunday, TimeStep) ; 
                    end
    %             end
            end
            iAppName          = iAppName + 1 ;
        end
    end
    toc
end