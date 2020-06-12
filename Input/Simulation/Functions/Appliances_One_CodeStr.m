%% Appliances
% In this section, every appliances that has been selected to be run in the
% simulation are oging to be processed. First, all data are going to be
% passed through 
function [Total_Cons,Power_Calc_Light,varargout] = Appliances_One_CodeStr(varargin)


Time_Sim        = varargin{1}              ;
Nbr_Building    = varargin{2}              ;
Input_Data      = varargin{3}              ;
% Housenbr        = varargin{4}              ;
All_Var         = varargin{5}              ;
SimDetails      = varargin{6}              ;
SolarLuminancev = varargin{7}       ;
%HouseTitle      = varargin{8}       ;
App             = varargin{9}       ;
timehour        = Time_Sim.timehour        ;
timeweeknbr     = Time_Sim.timeweeknbr  ;
timeweekday     = Time_Sim.timeweekday  ;
timedaynbr      = Time_Sim.timedaynbr    ;
myiter          = Time_Sim.myiter            ;
timemonth       = Time_Sim.timemonth      ;
nbrstep         = Time_Sim.nbrstep          ;
stepreal        = Time_Sim.stepreal        ;
Appliances_Char = All_Var.Detail_Appliance;
inhabitants     = str2double(Input_Data.inhabitants);
Timeoffset      = Time_Sim.Timeoffset;
Reduce_time     = Time_Sim.Reduce_time;
Building_Area   = str2double(Input_Data.Building_Area) ;
clLight         = Input_Data.clLight ;
Time_Step       = Input_Data.Time_Step;
Metering        = str2double(Input_Data.Metering)       ;
ProfileSelected = str2double(Input_Data.Profile)       ;
HouseName       = Input_Data.Headers                    ;
switch ProfileSelected
    case 1
        Stat4Use        = All_Var.Stat4Use_Profile1;
    case 2
        Stat4Use        = All_Var.Stat4Use_Profile2;
    otherwise
        Stat4Use        = All_Var.Stat4Use_Profile1;
end

%     switch(Time_Step)
%         case 'Hourly'
%             TimeVector = All_Var.Hourly_Time';
%         case '30 minutes' % To modify as this is not correct
%             TimeVector = All_Var.Hourly_Time';
%     end
% App.class_app = [clWashMach clDishWash 0 clKettle clOven clMW clCoffee clToas ...
%                  clWaff clFridge clRadio clLaptop 0 clShaver clHair clTele ...
%                  clStereo clIron clVacuum clCharger 0]';
             
nbr_app_max = str2double(Input_Data.Appliance_Max) ;

nbr_appliances = str2double(Input_Data.Appliance_Max) ;

AppList = All_Var.GuiInfo.AppliancesList ;

%% Enter Iteration for each appliance
if nbr_appliances > 0
    for nbr_appliance = 1:size(AppList,1)
        AppName = AppList{nbr_appliance,3}            ;
        LongAppName = AppList(nbr_appliance,1);
        if isempty(AppName)
            % resume to the next applicance
            continue; % This is for the lighting system
        end
        AppSN = Input_Data.(AppName) ;
        if ~strcmp(AppSN{1},'0')
            %% There must be at least 1 appliance to process in this category
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Check for unloading structure variables and run the code only with arrays
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for subapp = 1:numel(AppSN)
                % Loop through each subapp to see if they are running or
                % not.
                %% Set the variables before starting the loop
                
                App.NbrusesumtotalStr.(AppName)(subapp).(HouseName)(1)       = App.NbrusesumtotalStr.(AppName)(subapp).(HouseName)(2)            ;
                App.NbrusesumtotalStr.(AppName)(subapp).(HouseName)(2)       = App.NbruseStr.(AppName)(subapp).(HouseName)(1)                      ; 
                App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(1)    = App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(2)         ;
                App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(1)      = App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(2)            ;
                App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(1)       = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2)             ;
                App.delay_time_appStr.(AppName)(subapp).(HouseName)(1)       = App.delay_time_appStr.(AppName)(subapp).(HouseName)(2)             ;
                App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(1)   = App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(2)          ;
                
                %% Detect if the appliance is already running
                try 
                    App.timeactionStr.(AppName)(subapp).(HouseName)(1) ;
                catch
                    App.timeactionStr.(AppName)(subapp).(HouseName)(1) = 0 ;
                end
                try
                    timeaction_app2;
                catch
                    timeaction_app2 = 0 ;
                end
                if ~App.timeactionStr.(AppName)(subapp).(HouseName)(1) == 0 || ~timeaction_app2 == 0
                    AppInUse = true  ;
                else
                    AppInUse = false ;
                end
                
                % If they are not Running
                %   Evaluate if they should run (all code)
                %   Evaluate if they can be part of some DR programme
                % If they are running, recalculate the power consumption
                % based on the timestep of the simulation, the programme
                % chosen etc...
                % 
                if App.actionStr.(AppName)(subapp).(HouseName) == 0
                    Randhour = App.rand_ApplianceStr.(AppName)(subapp).(HouseName)(App.refrndStr.(AppName)(subapp).(HouseName))    ;
                else
                    App.refrnddayStr.(AppName)(subapp).(HouseName) = App.refrnddayStr.(AppName)(subapp).(HouseName) + 1               ;
                    Randhour = App.rand_ApplianceStr.(AppName)(subapp).(HouseName)(App.refrndStr.(AppName)(subapp).(HouseName))    ;
                end
                if or(App.actionStr.(AppName)(subapp).(HouseName)(1) == 1, timehour == 0)
                    App.refrnddayStr.(AppName)(subapp).(HouseName)(1) = App.refrnddayStr.(AppName)(subapp).(HouseName)(1) + 1         ;
                end   
                Max_use             = All_Var.Detail_Appliance_List.(AppName)(inhabitants).MaxUse ;
                Time_Usage_Prob     = [All_Var.Detail_Appliance_List.(AppName)(:).Temp]                  ;
                Time_Usage          = [All_Var.Detail_Appliance_List.(AppName)(:).TimeUsage]             ;
                Daily_Profile       = [All_Var.Detail_Appliance_List.(AppName)(:).Weekdistr]             ;
                weekday             = All_Var.Detail_Appliance_List.(AppName)(inhabitants).Weekdayweight ;
                WeekDayProfileAcc   = All_Var.Detail_Appliance_List.(AppName)(inhabitants).Weekdayacc ;
                % Need to be re-Written as a washing machine can have any
                % of the 3 options
                Long_delay          = All_Var.Detail_Appliance_List.(AppName)(inhabitants).Delay ;
                Short_delay         = All_Var.Detail_Appliance_List.(AppName)(inhabitants).Delay ;
                reduce_time         = All_Var.Detail_Appliance_List.(AppName)(inhabitants).Delay ;
                
                Power_Level         = [All_Var.Detail_Appliance_List.(AppName)(:).Power] ;
                
                Daily_acc_day       = Max_use / 7   ;
                ShortDelay          = Short_delay * Time_Sim.hour_1_delay.(HouseName)(1);
                
                %% Define the number of use for the current and previous day, and per week
                
                %%% Testing new line
                AllActivity = App.Total_Action2Str.(AppName)(subapp).(HouseName) ;
                Activity_tot = sum(AllActivity);
                
                % Mean activity for the previous day
                if timedaynbr == 1
                    minus_day = 0;
                else
                    minus_day = 1;
                end
                sum_day = timedaynbr - minus_day;
                Mean_Prev_day = Activity_tot / sum_day;

                % Daily Acceptance

                if Mean_Prev_day <= Daily_acc_day * 2
                    Day_Access = 1;
                else
                    Day_Access = 0;
                end

                % Mean Activity per weekday
                if timeweeknbr == 1
                    minus_week = 0;
                else
                    minus_week = 1;
                end
                sum_week = timeweeknbr - minus_week;
                Mean_Act_Week = Activity_tot / sum_week;
                App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(2) = Mean_Act_Week;
                % Weekly Acceptance

                if Mean_Act_Week <= Max_use * 1.1
                    if timeweeknbr == 1
                        Week_Access = 0;
                    else
                        Week_Access = 1;
                    end
                else
                    Week_Access = 0;
                end
                %% Set the new boundaries by incrementation
                MaxUse6Inhabitant = All_Var.Detail_Appliance_List.(AppName)(6).MaxUse ;
                MaxUse1Inhabitant = All_Var.Detail_Appliance_List.(AppName)(1).MaxUse ;
                a_day = (1 - weekday) / (MaxUse6Inhabitant - MaxUse1Inhabitant);
                b_day = weekday - (MaxUse1Inhabitant * a_day);
                wkdaycst_temp = a_day * Max_use + b_day;
                if myiter == 0
                    cmp_Week_Act = App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(2) ;
                    cmp_wkdaycst = wkdaycst_temp    ;
                else
                    cmp_Week_Act = App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(1) ;
                    cmp_wkdaycst = wkdaycst_temp        ;
                end
                if and(Max_use * 0.75 > Mean_Act_Week, cmp_Week_Act < Mean_Act_Week)
                    wkdaycst = max(0, min(2*wkdaycst_temp - cmp_wkdaycst + 0.1,1));
                    WeekDayProfileAcc = wkdaycst ;
                end
                WeekEndProfileAcc   = 1-WeekDayProfileAcc                                           ;
                Daily_Perc(1:5)     = Daily_Profile(1:5)*WeekDayProfileAcc/sum(Daily_Profile(1:5))' ;
                Daily_Perc(6:7)     = Daily_Profile(6:7)*WeekEndProfileAcc/sum(Daily_Profile(6:7))' ;
                DailyAllowance      = Daily_Perc(timeweekday)                                       ;
                %% Increase the potential
                if isnan(App.Total_Action2StrCount.(AppName)(subapp).(HouseName)(timeweekday)/Activity_tot) == 1
                   Compare = 0 ;
                else
                   Compare = App.Total_Action2StrCount.(AppName)(subapp).(HouseName)(timeweekday) / Activity_tot ;
                end
                if myiter<=1
                    Inc_Fac = 1;
                    Perc_Var = 1;
                elseif Compare < DailyAllowance
                    maxValue = max(5,ceil((1 / DailyAllowance) / mean(wkdaycst_temp/weekday)));
                    y = 1:maxValue; x = weekday:((((mean(wkdaycst_temp) / weekday)-1))-weekday)/(maxValue-1):(((mean(wkdaycst_temp) / weekday)-1));
                    Coeff = [reshape(x,length(x),1),ones(length(x),1)] \ reshape(y,length(y),1);
                    Perc_Var = wkdaycst_temp/weekday;
                    Inc_Fac = polyval(Coeff,Perc_Var-1);
                else
                    Inc_Fac = 1;
                    Perc_Var = 1;
                end
                Increase_Potential = Inc_Fac * Perc_Var;
                %% Action decision per day
                if timeweekday <= 5 
                    weekdayvar = 1 ;
                else
                    weekdayvar = timeweekday; 
                end
                switch (timeweekday)
                    case {1 2 3 4 5}
                        weekdayvar = 1;
                    case 6
                        weekdayvar = 2;
                    case 7
                        weekdayvar = 3;
                end
                
                App_All = [Stat4Use(timemonth,weekdayvar,1:size(Stat4Use,3)).(AppName)] ;
                

                if and(Randhour >= App_All(floor(timehour + 1)), Randhour < App_All(floor(timehour + 2)))
                    Hour_Access = 1;
                else
                    Hour_Access = 0;
                end
                %%% Weekday vs. weekend access
                if DailyAllowance*Increase_Potential > App.Inc_Pot_RandStr.(AppName)(subapp).(HouseName)(myiter + 1)
                    Week_Day_End_Access = 1;
                else
                    Week_Day_End_Access = 0;
                end
                App.actionStr.(AppName)(subapp).(HouseName)(1) = Week_Access * Week_Day_End_Access * Day_Access * Hour_Access;
                %% Create the action generation
                if myiter > 0
                    if and(App.NbrusesumtotalStr.(AppName)(subapp).(HouseName)(2) > 0, App.NbrusesumtotalStr.(AppName)(subapp).(HouseName)(1) == 0)
                        %%% 
                        % This variable is needed only for retrieving the results
                        App.time_for_recordStr.(AppName)(subapp).(HouseName)(myiter + 1) =  App.timeStr.(AppName)(subapp).(HouseName)(1) ;
                    end
                end
                Program = find(App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) < Time_Usage_Prob);
                Time_Wash = Time_Usage(Program(1) - 1); % To adapt for the other time step. Now it is in hours
                if ~(abs(App.timeactiontotStr.(AppName)(subapp).(HouseName)(1)) > 0)
                    if ~reduce_time == 1
                        App.timeStr.(AppName)(subapp).(HouseName)(1) = Time_Wash/stepreal * Reduce_time.(HouseName)(1);
                    else
                        App.timeStr.(AppName)(subapp).(HouseName)(1) = Time_Wash/stepreal;
                    end
                end
                %% Hourly generation
                % This section repeat the action depending on the time step chosen
                if or(App.actionStr.(AppName)(subapp).(HouseName)(1) > 0, abs(App.timeactiontotStr.(AppName)(subapp).(HouseName)(1)) > 0)
                    %%%
                    % If it is the first time that the action has been declared, then
                    % the total time activity has not been set yet. It will thus be set
                    % to the time action that has been defined previously. If this is
                    % not the first step at which the appliance is being used, then the
                    % time of the action remains the same and the calculation process
                    % continues.
                    if ~myiter == 0
                        if App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter) == 1 && App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) > (-stepreal)
                            varcare = 1;
                        else
                            varcare = 0;
                        end
                    else
                        varcare = 0;
                    end
                    if App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) == 0
                        App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) = App.timeStr.(AppName)(subapp).(HouseName)(1);
                    end
                    if App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) > 1
                        App.timeactionStr.(AppName)(subapp).(HouseName)(1)    = 1                    ;  
                        App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) = App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) - 1;
                    elseif App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) > (-stepreal)
                        App.timeactionStr.(AppName)(subapp).(HouseName)(1) = abs(App.timeactiontotStr.(AppName)(subapp).(HouseName)(1));
                        App.NbruseStr.(AppName)(subapp).(HouseName)(1) = 1;
                        App.timeactiontotStr.(AppName)(subapp).(HouseName)(1) = 0;
                    end
                else
                    App.timeactionStr.(AppName)(subapp).(HouseName)(1) = 0;
                    App.NbruseStr.(AppName)(subapp).(HouseName)(1) = App.timeactionStr.(AppName)(subapp).(HouseName)(1);
                    varcare = 0;
                end
                %%% Generate multiple actions
                % If a device that is used for a short time, then we could multiply its
                % usage in order to comply with the average weekly usage of this device
                App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(2) = App.NbruseStr.(AppName)(subapp).(HouseName)(1); 
                if ~(myiter == 0)
                    if (App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(2) > 0 && App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(1) == 0)
                        if App.timeStr.(AppName)(subapp).(HouseName)(1) < 2/7 %&& ~(ismember(Appliance_nbr,[1 5 11 15 19]))
                            multiply_time = floor(RandBetween(1,1/App.timeStr.(AppName)(subapp).(HouseName)(1)*2/7,1,1));
                        else
                            multiply_time = 1;
                        end
                        if App.timeactionStr.(AppName)(subapp).(HouseName)(1) <= 0.5 && ~varcare == 1
                            App.timeactionStr.(AppName)(subapp).(HouseName)(1) = App.timeStr.(AppName)(subapp).(HouseName)(1) * multiply_time ;
                        end
                        App.Total_Action2Str.(AppName)(subapp).(HouseName)(myiter + 2) = multiply_time          ;
                    else
                        App.Total_Action2Str.(AppName)(subapp).(HouseName)(myiter + 2) = 0          ;
                    end
                else
                    App.Total_Action2Str.(AppName)(subapp).(HouseName)(myiter + 2) = 0          ;
                end
                
                try
                    App.Total_Action2StrCount.(AppName)(subapp).(HouseName)(timeweekday) = App.Total_Action2StrCount(timeweekday) + App.Total_Action2Str.(AppName)(subapp).(HouseName)(myiter + 2) ;
                catch
                    App.Total_Action2StrCount.(AppName)(subapp).(HouseName)(timeweekday) =  App.Total_Action2Str.(AppName)(subapp).(HouseName)(myiter + 2) ;
                end
                
                % Remember all the actions
                App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2) = App.timeactionStr.(AppName)(subapp).(HouseName)(1) ;
                
                %% Delay period depending on the controller
                if (Short_delay == 0 && Long_delay == 0) || (varcare == 1)
                    timeaction_app2 = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2) ;
                    App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                else
                    if ~Short_delay == 0
                        delay_time_short = ShortDelay; %1 / stepreal;
                        App.delay_time_appStr.(AppName)(subapp).(HouseName)(2) = delay_time_short;
                        if ~myiter == 0
                            if delay_time_short > 0 && App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2) > 0
                                if and(delay_time_short > 0, App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(1) == 0)
                                    App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + delay_time_short) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                    timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                                else
                                    App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + App.delay_time_appStr.(AppName)(subapp).(HouseName)(1)) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                    timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                                end
                            elseif and(App.delay_time_appStr.(AppName)(subapp).(HouseName)(1) > 0, App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(1) > 0)
                                App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + App.delay_time_appStr.(AppName)(subapp).(HouseName)(1)) = ...
                                                                  App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                            else
                                App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + delay_time_short) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                            end
                        else
                            timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                        end
                    end

                    if ~Long_delay == 0
                        if Time_Sim.Delay_time.(HouseName)(1) > 0
                            delay_time_long = Time_Sim.Delay_time.(HouseName)(1) / stepreal;
                        else
                            delay_time_long = 0;%(21 - timehour + 3 + 7 - ceil(time.(HouseName)(1,nbr_appliance))) / stepreal;
                            % Why Not delay_time = (Delay_time.(HouseName)(1) - ceil(wash_time.(HouseName)(1))) / stepreal; ?
                        end
                        if and(sum(App.Mem_app_action2Str.(AppName)(subapp).(HouseName)((myiter + 1:end))) == 0, App.timeactionStr.(AppName)(subapp).(HouseName)(1) > 0 )
                            App.xxx_appStr.(AppName)(subapp).(HouseName)(1) = myiter + 1 + delay_time_long;
                            App.yyy_appStr.(AppName)(subapp).(HouseName)(1) = App.timeStr.(AppName)(subapp).(HouseName)(1);
                        end
                        if App.xxx_appStr.(AppName)(subapp).(HouseName)(1) < nbrstep.(HouseName)
                            zz = sum(App.Mem_app_action2Str.(AppName)(subapp).(HouseName)((App.xxx_appStr.(AppName)(subapp).(HouseName)(1):App.xxx_appStr.(AppName)(subapp).(HouseName)(1) + ceil(App.yyy_appStr.(AppName)(subapp).(HouseName)(1)))));
                        else
                            zz = 0;
                        end
                        App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(2) = delay_time_long;
                        if ~myiter == 0
                            if ~(zz==App.yyy_appStr.(AppName)(subapp).(HouseName)(1))
                                if and(delay_time_long > 0, App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2) > 0)
                                    if and(delay_time_long > 0, App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(1) == 0)
                                        App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + delay_time_long) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                        timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                                    else
                                        App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(1)) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                        timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                                    end
                                elseif and(App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(1) > 0, App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(1) > 0)
                                    App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(1)) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                    timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                                else
                                    App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1 + delay_time_long) = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2);
                                    timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                                end
                            elseif App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1)  > 0
                                timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                            else
                                App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1) = 0;
                                timeaction_app2 = 0;
                            end
                        else
                            timeaction_app2 = App.Mem_app_action2Str.(AppName)(subapp).(HouseName)(myiter + 1);
                        end 
                    end
                end
                % Calculation of the output power
                if ~App.timeactionStr.(AppName)(subapp).(HouseName)(1) == 0 || ~timeaction_app2 == 0
                    ApplianceClass = AppList{nbr_appliance,4}   ;
                    try
                        Classrateined = Input_Data.(ApplianceClass){subapp}    ;
                    catch
                        Classrateined = 'NoClass' ;
                    end
                        
                    switch Classrateined
                        case 'A or B class'
                            App_Power = Power_Level(1) * stepreal;
                        case 'C or D class'
                            App_Power = Power_Level(2) * stepreal;
                        case 'E or F class'
                            App_Power = Power_Level(3) * stepreal;
                        case 'Self-defined'                         % JARI
                            Place = strcmp(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName)(:,1),LongAppName);
                            App_Power = All_Var.GuiInfo.SelfDefinedAppliances.(HouseName){Place,2} * stepreal;
                        otherwise
                            App_Power = Power_Level(1) * stepreal;
                    end
                    if ~Short_delay == 0 || ~Long_delay == 0
                        Timeaction_touse = timeaction_app2;
                    else
                        Timeaction_touse = App.timeactionStr.(AppName)(subapp).(HouseName)(1);
                    end
                    App_Energy = App_Power * Timeaction_touse;
                    AppInUse            = true;         % JARI'S ADDITION
                else
                    if ~Power_Level(5)==0
                        bed1lap_act = [0,0.147,1]';                                 % Include the stand-by power to the calculation
                        %%% Sleeping mode
                        if and(App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) >= bed1lap_act(1), App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) <= bed1lap_act(2))
                            ApplianceClass = AppList{nbr_appliance,4}   ;
                            Classrateined = Input_Data.(ApplianceClass){subapp}    ;
                            switch Classrateined
                                case 'A or B class'
                                    App_Power = Power_Level(4) * 1.0 * stepreal;
                                case 'C or D class'
                                    App_Power = Power_Level(4) * 5/3 * stepreal;
                                case 'E or F class'
                                    App_Power = Power_Level(4) * 10/3 * stepreal;
                                case 'Self-defined'                         % JARI
                                    Place = strcmp(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName)(:,1),LongAppName);
                                    App_Power = All_Var.GuiInfo.SelfDefinedAppliances.(HouseName){Place,3} * stepreal;
                            end
                        %%% Off Mode
                        elseif and(App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) > bed1lap_act(2), App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) <= bed1lap_act(3))
                            ApplianceClass = AppList{nbr_appliance,4}   ;
                            Classrateined = Input_Data.(ApplianceClass){subapp}    ;
                            switch Classrateined
                                case 'A or B class'
                                    App_Power = Power_Level(5) * 1.0 * stepreal;
                                case 'C or D class'
                                    App_Power = Power_Level(5) * 1.5 * stepreal;
                                case 'E or F class'
                                    App_Power = Power_Level(5) * 3.0 * stepreal;
                                case 'Self-defined'                         % JARI
                                Place = strcmp(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName)(:,1),LongAppName);
                                App_Power = All_Var.GuiInfo.SelfDefinedAppliances.(HouseName){Place,4} * stepreal;
                            end
                        end
                        App_Energy = App_Power;
                    elseif ~Power_Level(4)==0
                        ApplianceClass = AppList{nbr_appliance,4}   ;
                        Classrateined = Input_Data.(ApplianceClass){subapp}    ;

                        switch Classrateined
                            case 'A or B class'
                                App_Power = Power_Level(4) * 1.0 * stepreal;
                            case 'C or D class'
                                App_Power = Power_Level(4) * 5/3 * stepreal;
                            case 'E or F class'
                                App_Power = Power_Level(4) * 10/3 * stepreal;
                            case 'Self-defined'                         % JARI
                                Place = strcmp(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName)(:,1),LongAppName);
                                App_Power = All_Var.GuiInfo.SelfDefinedAppliances.(HouseName){Place,3} * stepreal;
                        end
                         App_Energy = App_Power;
                         AppInUse   = false;        % JARI'S ADDITION
                    else
                        %%% Active Mode
                        App_Energy = 0;
                        AppInUse   = false;        % JARI'S ADDITION
                    end
                end
                Energy = App_Energy;
                %%%
                % Appliances_Cons data are collected throughout the simulation for
                % collecting information.
                App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) = Energy ;
                App.AppliancesInUse.(AppName).(HouseName)(subapp)  = AppInUse; %App.AppliancesInUse.(AppName)(subapp).(HouseName)  = AppInUse;                 % JARI'S ADDITION
               % Action      = Energy ;
            end
        end
    end
end

%% Fridge
Power_FridgeTot = 0 ;
for ij = 1:numel(Input_Data.Fridge)
    FridgeExist = str2double(Input_Data.Fridge{ij}) ;
    if FridgeExist >= 1
        [Power_Fridge] = Fri(timehour,Input_Data.clFridge{ij});
    else
        Power_Fridge = 0;
    end
    Power_FridgeTot = Power_FridgeTot + Power_Fridge ;
end

App.Appliances_ConsStr.Fridge.(HouseName)(myiter + 1) = Power_FridgeTot;

Power_Kitchen.(HouseName)   = 0 ;
Power_Clean.(HouseName)     = 0 ;
Power_Living.(HouseName)    = 0 ;
Power_Bath.(HouseName)      = 0 ;
Power_Bedrooms.(HouseName)  = 0 ;
Power_Calc_Light.(HouseName)= 0 ;

Appliance_Kitchen   = {'WashMach' 'DishWash' 'Elec' 'Kettle' 'Oven' 'Coffee' 'MW' 'Toas' 'Waff' 'Fridge'} ;
Appliance_Clean     = {'Iron' 'Vacuum'} ;
Appliance_Living    = {'Stereo' 'Tele'} ;
Appliance_Bath      = {'Shaver' 'Hair' 'Elecheat' 'Sauna'} ;
Appliance_Bedrooms  = {'Radio' 'Laptop' 'Charger'} ;
Appliance_Light     = {'MW' 'Coffee' 'Toas' 'Waff' 'Kettle' 'Hair' 'Tele' 'Stereo' 'Iron' 'Vacuum'} ;

if nbr_appliances > 0
    for nbr_appliance = 1:size(AppList,1)
        AppName = AppList{nbr_appliance,3}            ;
        if isempty(AppName)
            continue; % This is for the lighting system
        end
        AppSN = Input_Data.(AppName) ;
        if ~strcmp(AppSN{1},'0')
            % There is at least 1 appliance to process in this category
            for subapp = 1:numel(AppSN)
                if sum(strcmp(AppName,Appliance_Kitchen)) >= 1
                    Power_Kitchen.(HouseName)(end+1) = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                end
                if sum(strcmp(AppName,Appliance_Clean)) >= 1
                    Power_Clean.(HouseName)(end+1) = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                end
                if sum(strcmp(AppName,Appliance_Living)) >= 1
                    Power_Living.(HouseName)(end+1) = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                end
                if sum(strcmp(AppName,Appliance_Bath)) >= 1
                    Power_Bath.(HouseName)(end+1) = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                end
                if sum(strcmp(AppName,Appliance_Bedrooms)) >= 1
                    Power_Bedrooms.(HouseName)(end+1) = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                end
                if sum(strcmp(AppName,Appliance_Light)) >= 1
                    Power_Calc_Light.(HouseName)(end+1) = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                end
            end
        end
    end
end

Power_Kitchen.(HouseName)              = sum(Power_Kitchen.(HouseName));
Power_Clean.(HouseName)                = sum(Power_Clean.(HouseName)) ;
Power_Living.(HouseName)               = sum(Power_Living.(HouseName)) ;
Power_Bath.(HouseName)                 = sum(Power_Bath.(HouseName));
Power_Bedrooms.(HouseName)             = sum(Power_Bedrooms.(HouseName));
App.Power_Kitchen.(HouseName)          = Power_Kitchen.(HouseName);
App.Power_Clean.(HouseName)            = Power_Clean.(HouseName);
App.Power_Living.(HouseName)           = Power_Living.(HouseName);
App.Power_Bath.(HouseName)             = Power_Bath.(HouseName);
App.Power_Bedrooms.(HouseName)         = Power_Bedrooms.(HouseName);
App.Power_Calc_Light.(HouseName)    = Power_Calc_Light.(HouseName) ;
[Power_Light.(HouseName)(myiter + 1)]  = Lighting(myiter,sum(Power_Calc_Light.(HouseName)),Appliance_Light,Input_Data,App);
%%%
% In this section, we are adding the electrical consumption of the smart
% meter if it exists (Meter + Display = ~20W) + the consumption from the smart
% plugs. A finner study would require to adapt the number of smart plugs (=
% ~4W / Smart plug)depending on the number of appliances.
SP_Power = SmartPlugEnergy(1,4,10,100)    ;
SM_Power = SmartPlugEnergy(1,20,1500,200) ;
switch Metering
    case 1
        SM_Cons = 0  ;
        SP_Cons = 0  ;
    case 2
        SM_Cons = SM_Power ;
        SP_Cons = 0  ;
    case 3
        SM_Cons = SM_Power ;
        SP_Cons = SP_Power  ;
    case 4
        SM_Cons = SM_Power ;
        SP_Cons = SP_Power  ;
end
App.Metering_ConsStr.(HouseName)(myiter + 1) = SP_Cons * nbr_app_max + SM_Cons ;
%% Output Variables
%%%
% The following integrates the electricity consumption from the metering
% system
Total_Cons  = 0 ;
if nbr_appliances > 0
    for nbr_appliance = 1:size(AppList,1)
        AppName = AppList{nbr_appliance,3}            ;
        if isempty(AppName)
            continue; % This is for the lighting system
        end
        AppSN = Input_Data.(AppName) ;
        if ~strcmp(AppSN{1},'0')
            % There is at least 1 appliance to process in this category
            for subapp = 1:numel(AppSN)
                Cons_App  = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                Total_Cons = Total_Cons + Cons_App ;
            end
        end
    end
end
Total_Cons = Total_Cons + Power_Light.(HouseName)(myiter + 1) + App.Metering_ConsStr.(HouseName)(myiter + 1)    ;
           
Power_Calc_Light = sum(Power_Calc_Light.(HouseName)) ;

if Time_Sim.Series_Sim == 1
    if myiter == nbrstep.(HouseName) - 1
        App.NewVar1         = App.NewVar1 + 1      ;
        NewVar1             = App.NewVar1          ;
        FileName            = dbstack()                 ;
        if nbr_appliances > 0
            try
                NewVarImp = load(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'));
                ToBuild = 0;
                NewVar = NewVarImp.NewVar ;
            catch
                % Set the size of each variable
                ToBuild = 1;
            end
            for nbr_appliance = 1:size(AppList,1)
                AppName = AppList{nbr_appliance,3}            ;
                if isempty(AppName)
                    continue; % This is for the lighting system
                end
                AppSN = Input_Data.(AppName) ;
                if ~strcmp(AppSN{1},'0')
                    % There is at least 1 appliance to process in this category
                    for subapp = 1:numel(AppSN)
                        if ToBuild == 1
                            NewVar.Total_Action2Str.(AppName)(subapp).(HouseName)        = zeros(nbrstep.(HouseName) + 1,1);
                            NewVar.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)    = zeros(2,1)          ;
                            NewVar.Appliances_ConsStr.(AppName)(subapp).(HouseName)      = zeros(nbrstep.(HouseName) + 1,1);
                            NewVar.time_for_recordStr.(AppName)(subapp).(HouseName)      = zeros(nbrstep.(HouseName) + 1,1);
                            NewVar.Nbr_BuildingStr.(AppName)(subapp).(HouseName)         = zeros(nbrstep.(HouseName) + 1,1);
                            NewVar.Metering_ConsStr.(AppName)(subapp).(HouseName)        = zeros(Time_Sim.Nbr_Building,nbrstep.(HouseName));
                        end
                        NewVar.Total_Action2Str.(AppName)(subapp).(HouseName)                       = App.Total_Action2Str.(AppName)(subapp).(HouseName)         ;
                        NewVar.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)                   = App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)     ;
                        NewVar.Appliances_CharStr.(HouseName)                                       = All_Var.Detail_Appliance_List                                       ;
                        NewVar.Appliances_ConsStr.(AppName)(subapp).(HouseName)                     = App.Appliances_ConsStr.(AppName)(subapp).(HouseName) ;
                        NewVar.time_for_recordStr.(AppName)(subapp).(HouseName)                     = App.time_for_recordStr.(AppName)(subapp).(HouseName)       ;
                    end
                end
            end
            NewVar.Metering_ConsStr.(HouseName)                       = App.Metering_ConsStr.(HouseName)          ;
        end
        Nbr_Buildingmax             = Time_Sim.Nbr_Building                   ;
        NewVar.YearStartSimStr      = Time_Sim.YearStartSim                   ;
        NewVar.YearStartSim2004Str	= Time_Sim.YearStartSim2004               ;
        NewVar.TimeoffsetStr        = Timeoffset                              ;
        NewVar.Nbr_BuildingStr      = Nbr_Buildingmax ;
%         NewVar.TimeVectorStr        = TimeVector                              ;
        %NewVar.AppDetails(:,:,NewVar1)           = App.nbr_appliances(:,:,Housenbr)   ;
        save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'),'NewVar');
    end
else
    if myiter == 8807
        y = 1;
    end 
    if myiter == nbrstep.(HouseName) - 1
        NewVar.YearStartSim         = Time_Sim.YearStartSim                   ;
        NewVar.YearStartSim2004     = Time_Sim.YearStartSim2004               ;
        NewVar.Total_Action2        = App.Total_Action2         ;
        NewVar.Vec_Mean_Act_Week    = App.Vec_Mean_Act_Week     ;
        NewVar.Appliances_Char      = Appliances_Char           ;
        NewVar.Timeoffset           = Timeoffset                ;
        NewVar.TimeVector           = TimeVector                ;
        NewVar.Appliances_Cons      = App.Appliances_Cons       ;
        NewVar.time_for_record      = App.time_for_record       ;
        NewVar.Nbr_Building         = Nbr_Building              ;
        NewVar.AppDetails           = Houseapp.nbr_appliances   ;
        NewVar.Metering_Cons        = App.Metering_Cons         ;
        FileName = dbstack() ;
        save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'),'NewVar');
    end
end
varargout{1} = App;
%Power_Cook(1,myiter + 1) = Power_Hobs + Power_Oven ;
%% 
%%% Nested function representing the Lighting System
    function [Power_Light] = Lighting(myiter,Power_Calc_Light,Appliance_Light,Input_Data,App)
        Emax    = 100000    ;
        Emin    = 20        ;
        Accmin  = 0.1       ; 
        Percentage = SolarLuminancev(myiter + 1)/(2/3*Emax)+Accmin-Emin/(Emax*2/3);
        StandbyPower = 0 ;
        for i = 1:numel(Appliance_Light)
            AppNamehere = Appliance_Light{i} ;
            StandbyPower = StandbyPower + All_Var.Detail_Appliance_List.(AppNamehere)(4).Power ; % Standbypower
        end
        %Percentage = 0.015* SolarLuminancev(Housenbr, myiter + 1) / 1000 + 0.0997;
        if (1 - Percentage) >= App.Light_randStr.(HouseName)(myiter + 1)
            if Power_Calc_Light <= StandbyPower
                ValOccup   = 0              ;
            else
                ValOccup   = 1              ;
            end
        else
            ValOccup   = 0;
        end
        if isfield(All_Var.GuiInfo.SelfDefinedAppliances,HouseName)
            LightPlace = strcmp(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName)(:,1),'Lighting System');
        end
        switch (clLight{1})
            case 'Low consumption bulbs'
                Power_Light = ValOccup * Building_Area * 0.0037 * stepreal;
            case 'Incandescent bulbs'
                Power_Light = ValOccup * Building_Area * 0.012 * stepreal;
            case 'Self-defined'         % JARI'S ADDITION
                Power_Light = ValOccup * Building_Area * All_Var.GuiInfo.SelfDefinedAppliances.(HouseName){LightPlace,1} * stepreal;   % JARI'S ADDITION
        end
    end
%%% Nested function representing the Fridge
    function [Action] = Fri(timehour,AppClass)
        switch (AppClass)
            case 'A or B class'
                fri_Power = 0.039 * stepreal;
            case 'C or D class'
                fri_Power = 0.100 * stepreal;
            case 'E or F class'
                fri_Power = 0.200 * stepreal;
            case 'Self-Defined'                         % JARI
                [Place1,~] = find(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName),'Fridge');
                fri_Power = All_Var.GuiInfo.SelfDefinedAppliances.(HouseName){Place1,2} * stepreal;
        end
        %timefridge = floor(timehour);
        if and(timehour >=0, timehour < 1)
            Action = fri_Power;
        elseif and(timehour >=3, timehour < 4)
            Action = fri_Power;
        elseif and(timehour >=6, timehour < 7)
            Action = fri_Power;
        elseif and(timehour >=9, timehour < 10)
            Action = fri_Power;
        elseif and(timehour >=12, timehour < 13)
            Action = fri_Power;
        elseif and(timehour >=15, timehour < 16)
            Action = fri_Power;
        elseif and(timehour >=18, timehour < 19)
            Action = fri_Power;
        elseif and(timehour >=21, timehour < 22)
            Action = fri_Power;
        else
            Action = 0;
        end
    end
end