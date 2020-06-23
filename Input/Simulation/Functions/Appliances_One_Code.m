%% Appliances
% In this section, every appliances that has been selected to be run in the
% simulation are oging to be processed. First, all data are going to be
% passed through 
function [Total_Cons,Power_Calc_Light,varargout] = Appliances_One_Code(varargin)

Time_Sim        = varargin{1}              ;
Nbr_Building    = varargin{2}              ;
Input_Data      = varargin{3}              ;
Housenbr        = varargin{4}              ;
All_Var         = varargin{5}              ;
SimDetails      = varargin{6}              ;
SolarLuminancev = varargin{7}       ;
HouseTitle      = varargin{8}       ;
App             = varargin{9}       ;
Housenbr2       = Input_Data.HouseNbr;
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
%TimeVector     = All_Var.TimeVector;
Timeoffset      = Time_Sim.Timeoffset;
Reduce_time     = Time_Sim.Reduce_time;
Fridge          = str2double(Input_Data.Fridge);
clWashMach      = Input_Data.clWashMach ;
clDishWash      = Input_Data.clDishWash ;
clKettle        = Input_Data.clKettle ;
clOven          = Input_Data.clOven ;
clCoffee        = Input_Data.clCoffee ;
clMW            = Input_Data.clMW ;
clToas          = Input_Data.clToas ;
clWaff          = Input_Data.clWaff ;
clFridge        = Input_Data.clFridge ;
clTele          = Input_Data.clTele ;
clLaptop        = Input_Data.clLaptop ;
clShaver        = Input_Data.clShaver ;
clHair          = Input_Data.clHair ;
clStereo        = Input_Data.clStereo ;
clVacuum        = Input_Data.clVacuum ;
clCharger       = Input_Data.clCharger ;
clIron          = Input_Data.clIron ;
clRadio         = Input_Data.clRadio ;
Building_Area   = str2double(Input_Data.Building_Area) ;
clLight         = Input_Data.clLight ;
Time_Step       = Input_Data.Time_Step;
Metering        = str2double(Input_Data.Metering)       ;
ProfileSelected = str2double(Input_Data.Profile)       ;
switch ProfileSelected
    case 1
        Stat4Use        = All_Var.Stat4Use_New;
    case 2
        Stat4Use        = All_Var.Stat4Use_New2;
    otherwise
        Stat4Use        = All_Var.Stat4Use_New;
end

    switch(Time_Step)
        case 'Hourly'
            TimeVector = All_Var.Hourly_Time';
        case 'Half Hourly'
            TimeVector = All_Var.Hourly_Time';
    end
App.class_app = [clWashMach clDishWash 0 clKettle clOven clMW clCoffee clToas ...
                 clWaff clFridge clRadio clLaptop 0 clShaver clHair clTele ...
                 clStereo clIron clVacuum clCharger 0]';
             
nbr_app_max = str2double(Input_Data.Appliance_Max) ;
fds = App_Nbr(HouseTitle,Input_Data);
nbr_appliances = str2double(Input_Data.Appliance_Max) ;
nbr_appliancescheck = size(fds,1) ;

if ~(nbr_appliancescheck == nbr_appliances)
    % There is a mismatch here
end
nbr_appliances = fds ;
if Time_Sim.Series_Sim == 0
    Houseapp.nbr_appliances = nbr_appliances;
else
    App.nbr_appliances(:,:,Housenbr) = nbr_appliances;
end
AppList = All_Var.GuiInfo.AppliancesList ;

%% Enter Iteration for each appliance
if nbr_appliances > 0
    for nbr_appliance = 1:size(nbr_appliances,1)
    %for nbr_appliance = 1:size(nbr_appliances,1)  
        %%%
        % Get the appliance number (from 1 to 21) this will help defining the
        % type of appliance and thus the type of programme it requires
        Appliance_nbr = nbr_appliances(nbr_appliance,2);
        %% Define the random number suite and the change of number
        if App.action(Housenbr,1,nbr_appliance) == 0                                          
            Randhour = App.rand_Appliance(Housenbr, App.refrnd(Housenbr,1,nbr_appliance),nbr_appliance)         ;
            Randday  = App.rand_Appliance(Housenbr, App.refrndday(Housenbr,1,nbr_appliance),nbr_appliance)      ;
        else
            App.refrnd(Housenbr,1,nbr_appliance) = App.refrnd(Housenbr,1,nbr_appliance) + 1               ;
            Randhour = App.rand_Appliance(Housenbr, App.refrnd(Housenbr,1,nbr_appliance),nbr_appliance)         ;
        end
        if or(App.action(Housenbr,1,nbr_appliance) == 1, timehour == 0)
            App.refrndday(Housenbr,1,nbr_appliance) = App.refrndday(Housenbr,1,nbr_appliance) + 1         ;
            Randday    =  App.rand_Appliance(Housenbr, App.refrndday(Housenbr,1,nbr_appliance),nbr_appliance)   ;
        end   
        %% Set the boundaries for everyday
        % Recommendations: make the max_use variable depending on the season
        % *Add the tables for all appliances*
        %%%
        % The maximum daily usage of a certain appliance $A_{d}$ is equal to the 
        % maximum weekly usage of a certain appliance divided by 7, the number of 
        % days per week:
        %%%
        % $$A_{d}=\frac{U_{p}}{7}$$

        Max_use             = Appliances_Char(:,1,Appliance_nbr)                ;
        Time_Usage_Prob     = Appliances_Char(:,2,Appliance_nbr)                ;
        Time_Usage          = Appliances_Char(:,3,Appliance_nbr)                ;
        Daily_Profile       = Appliances_Char(:,4,Appliance_nbr)                ;
        weekday             = Appliances_Char(1,6,Appliance_nbr)                ;
        WeekDayProfileAcc   = Appliances_Char(1,5,Appliance_nbr)                ;
        Long_delay          = Appliances_Char(1,7,Appliance_nbr)                ;
        Short_delay         = Appliances_Char(2,7,Appliance_nbr)                ;
        reduce_time         = Appliances_Char(3,7,Appliance_nbr)                ;
        Power_Level         = Appliances_Char(:,8,Appliance_nbr)                ;

        Daily_acc_day = Max_use(inhabitants) / 7   ;
        ShortDelay= Short_delay * Time_Sim.hour_1_delay(Housenbr, 1);
        %% Define the number of use for the current and previous day, and per week
        %App.wkNbrCNT(Housenbr, myiter + 1,nbr_appliance)       = timeweeknbr;
        App.Nbrusesumtotal(Housenbr, 1,nbr_appliance)       = App.Nbrusesumtotal(Housenbr, 2,nbr_appliance)             ;
        App.Nbrusesumtotal(Housenbr, 2,nbr_appliance)       = App.Nbruse(Housenbr,1,nbr_appliance)                      ; 
        App.Vec_Mean_Act_Week(Housenbr, 1, nbr_appliance)   = App.Vec_Mean_Act_Week(Housenbr, 2, nbr_appliance)         ;
        App.Nbrusesumtotal2(Housenbr, 1,nbr_appliance)      = App.Nbrusesumtotal2(Housenbr, 2,nbr_appliance)            ;
        App.Mem_app_action(Housenbr, 1,nbr_appliance)       = App.Mem_app_action(Housenbr, 2,nbr_appliance)             ;
        App.delay_time_app(Housenbr,1, nbr_appliance)       = App.delay_time_app(Housenbr,2, nbr_appliance)             ;
        App.delaylong_time_app(Housenbr,1,nbr_appliance)    = App.delaylong_time_app(Housenbr,2,nbr_appliance)          ;
        % Sum the number of use
    %     if ~(myiter == 0);
    %         if and(App.Nbrusesumtotal(Housenbr, 2,nbr_appliance) > 0, App.Nbrusesumtotal(Housenbr, 1,nbr_appliance) == 0);
    %             App.Total_Action(Housenbr, myiter + 1,nbr_appliance) = 1      ;
    %         else
    %             App.Total_Action(Housenbr, myiter + 1,nbr_appliance) = 0      ;
    %         end
    %     else
    %         App.Total_Action(Housenbr, myiter + 1,nbr_appliance) = 0          ;
    %     end
        Activity_tot = sum(App.Total_Action2(Housenbr,:,nbr_appliance));
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
        App.Vec_Mean_Act_Week(Housenbr, 2, nbr_appliance) = Mean_Act_Week;

        if nbr_appliance == 7  && Mean_Act_Week < 10
            y = 1;
        end

        % Weekly Acceptance

        if Mean_Act_Week <= Max_use(inhabitants) * 1.1
            if timeweeknbr == 1
                Week_Access = 0;
            else
                Week_Access = 1;
            end
        else
            Week_Access = 0;
        end
        %% Set the new boundaries by incrementation
        % Affine function for daily allowance
    %     WeekEndProfileAcc = 1-WeekDayProfileAcc;
    %     Daily_Perc(1:5) = Daily_Profile(1:5)*WeekDayProfileAcc/sum(Daily_Profile(1:5))';
    %     Daily_Perc(6:7) = Daily_Profile(6:7)*WeekEndProfileAcc/sum(Daily_Profile(6:7))';
    %     DailyAllowance = Daily_Perc(timeweekday);
    %     a_day = (1 - weekday) / (Max_use(6) - Max_use(1));
    %     b_day = weekday - (Max_use(1) * a_day);
    %     wkdaycst_temp = a_day * Max_use(inhabitants) + b_day;
    % %     App.WeekAccess(Housenbr, myiter + 1,nbr_appliance) = Week_Access;
    % %     App.DayAccess(Housenbr, myiter + 1,nbr_appliance) = Day_Access;
    %     Perc_Var = wkdaycst_temp/weekday;
    %     maxValue = max(5,ceil((1 / DailyAllowance) / mean(wkdaycst_temp/weekday)));  
    %     if myiter<=1
    %         Inc_Fac = 1;
    %         Perc_Var = 1;
    %     %elseif size(find(Total_Action2(Housenbr, 1:myiter + 1, nbr_appliance) >= 1 & myweekday(TimeVector(Timeoffset:Timeoffset + myiter))==timeweekday),2)/Activity_tot < DailyAllowance
    %     elseif sum(App.Total_Action2(Housenbr,find(myweekday(TimeVector(Timeoffset:Timeoffset + myiter))==timeweekday),nbr_appliance))/Activity_tot < DailyAllowance
    %         y = 1:maxValue; x = weekday:((((mean(wkdaycst_temp) / weekday)-1))-weekday)/(maxValue-1):(((mean(wkdaycst_temp) / weekday)-1));
    %         Coeff = [reshape(x,length(x),1),ones(length(x),1)] \ reshape(y,length(y),1);
    %         Inc_Fac = polyval(Coeff,Perc_Var-1);
    %     else
    %         Inc_Fac = 1;
    %         Perc_Var = 1;
    %     end
    %     Increase_Potential = Inc_Fac * Perc_Var; 
    %     if myiter == 0;
    %         cmp_Week_Act = App.Vec_Mean_Act_Week(Housenbr, 2,nbr_appliance);
    %         cmp_wkdaycst = wkdaycst_temp    ;
    %     else
    %         cmp_Week_Act = App.Vec_Mean_Act_Week(Housenbr, 1,nbr_appliance)    ;
    %         cmp_wkdaycst = wkdaycst_temp        ;
    %     end
    %     if and(Max_use(inhabitants) * 0.75 > Mean_Act_Week, cmp_Week_Act < Mean_Act_Week);
    %         wkdaycst = max(0, min(2*(a_day * Max_use(inhabitants) + b_day) - cmp_wkdaycst + 0.1,1));
    %     else
    %         wkdaycst = (a_day * Max_use(inhabitants) + b_day);
    %     end
        a_day = (1 - weekday) / (Max_use(6) - Max_use(1));
        b_day = weekday - (Max_use(1) * a_day);
        wkdaycst_temp = a_day * Max_use(inhabitants) + b_day;
        if myiter == 0
            cmp_Week_Act = App.Vec_Mean_Act_Week(Housenbr, 2,nbr_appliance);
            cmp_wkdaycst = wkdaycst_temp    ;
        else
            cmp_Week_Act = App.Vec_Mean_Act_Week(Housenbr, 1,nbr_appliance)    ;
            cmp_wkdaycst = wkdaycst_temp        ;
        end
        if and(Max_use(inhabitants) * 0.75 > Mean_Act_Week, cmp_Week_Act < Mean_Act_Week)
            wkdaycst = max(0, min(2*wkdaycst_temp - cmp_wkdaycst + 0.1,1));
            WeekDayProfileAcc = wkdaycst ;
        end
        WeekEndProfileAcc   = 1-WeekDayProfileAcc                                           ;
        Daily_Perc(1:5)     = Daily_Profile(1:5)*WeekDayProfileAcc/sum(Daily_Profile(1:5))' ;
        Daily_Perc(6:7)     = Daily_Profile(6:7)*WeekEndProfileAcc/sum(Daily_Profile(6:7))' ;
        DailyAllowance      = Daily_Perc(timeweekday)                                       ;
        %% Increase the potential
        if isnan(sum(App.Total_Action2(Housenbr,find(myweekday(TimeVector(Timeoffset + 1:Timeoffset + 1 + myiter))==timeweekday),nbr_appliance))/Activity_tot) == 1
           Compare = 0 ;
        else
            Compare = sum(App.Total_Action2(Housenbr,find(myweekday(TimeVector(Timeoffset + 1:Timeoffset + 1 + myiter))==timeweekday),nbr_appliance))/Activity_tot;
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
        if timeweekday <= 5; weekdayvar = 1; else weekdayvar = timeweekday; end
        switch (timeweekday)
            case 1  || 2 || 3 || 4 || 5
                weekdayvar = 1;
            case 6
                weekdayvar = 2;
            case 7
                weekdayvar = 3;
        end
        App_All = Stat4Use(:, Appliance_nbr, weekdayvar, timemonth); 

        if and(Randhour >= App_All(floor(timehour + 1)), Randhour < App_All(floor(timehour + 2)))
            Hour_Access = 1;
        else
            Hour_Access = 0;
        end
        %%% Weekday vs. weekend access
        if DailyAllowance*Increase_Potential > App.Inc_Pot_Rand(Housenbr, myiter + 1,nbr_appliance)
            Week_Day_End_Access = 1;
        else
            Week_Day_End_Access = 0;
        end
        App.action(Housenbr,1,nbr_appliance) = Week_Access * Week_Day_End_Access * Day_Access * Hour_Access;
        %% Create the action generation
        if myiter > 0
            if and(App.Nbrusesumtotal(Housenbr, 2,nbr_appliance) > 0, App.Nbrusesumtotal(Housenbr, 1,nbr_appliance) == 0)
                %%% 
                % This variable is needed only for retrieving the results
              App.time_for_record(Housenbr, myiter + 1, nbr_appliance) =  App.time(Housenbr,1,nbr_appliance);
            end
        end
        Program = find(App.rand_act(Housenbr, myiter + 1, nbr_appliance) < Time_Usage_Prob);
        Time_Wash = Time_Usage(Program(1) - 1);
        if ~(abs(App.timeactiontot(Housenbr,1,nbr_appliance)) > 0)
            if ~reduce_time == 1
                App.time(Housenbr,1,nbr_appliance) = Time_Wash/stepreal * Reduce_time(Housenbr, 1);
            else
                App.time(Housenbr,1,nbr_appliance) = Time_Wash/stepreal;
            end
        end
        %% Hourly generation
        % This section repeat the action depending on the time step chosen
        if or(App.action(Housenbr,1,nbr_appliance) > 0, abs(App.timeactiontot(Housenbr,1,nbr_appliance)) > 0)
            %%%
            % If it is the first time that the action has been declared, then
            % the total time activity has not been set yet. It will thus be set
            % to the time action that has been defined previously. If this is
            % not the first step at which the appliance is being used, then the
            % time of the action remains the same and the calculation process
            % continues.
            if ~myiter == 0
                if App.Mem_app_action2(Housenbr, myiter, nbr_appliance) == 1 && App.timeactiontot(Housenbr,1,nbr_appliance) > (-stepreal)
                    varcare = 1;
                else
                    varcare = 0;
                end
            else
                varcare = 0;
            end
            if App.timeactiontot(Housenbr,1,nbr_appliance) == 0
                App.timeactiontot(Housenbr,1,nbr_appliance) = App.time(Housenbr,1,nbr_appliance);
            end
            if App.timeactiontot(Housenbr,1,nbr_appliance) > 1
                App.timeaction(Housenbr,1,nbr_appliance)    = 1                    ;  
                App.timeactiontot(Housenbr,1,nbr_appliance) = App.timeactiontot(Housenbr,1,nbr_appliance) - 1;
            elseif App.timeactiontot(Housenbr,1,nbr_appliance) > (-stepreal)
                App.timeaction(Housenbr,1,nbr_appliance) = abs(App.timeactiontot(Housenbr,1,nbr_appliance));
                App.Nbruse(Housenbr,1,nbr_appliance) = 1;
                App.timeactiontot(Housenbr,1,nbr_appliance) = 0;
            end
        else
            App.timeaction(Housenbr,1,nbr_appliance) = 0;
            App.Nbruse(Housenbr,1,nbr_appliance) = App.timeaction(Housenbr,1,nbr_appliance);
            varcare = 0;
        end
        %%% Generate multiple actions
        % If a device that is used for a short time, then we could multiply its
        % usage in order to comply with the average weekly usage of this device
        App.Nbrusesumtotal2(Housenbr, 2,nbr_appliance) = App.Nbruse(Housenbr,1,nbr_appliance); 
        if ~(myiter == 0)
            if (App.Nbrusesumtotal2(Housenbr, 2,nbr_appliance) > 0 && App.Nbrusesumtotal2(Housenbr, 1,nbr_appliance) == 0)
                if App.time(Housenbr,1,nbr_appliance) < 2/7 %&& ~(ismember(Appliance_nbr,[1 5 11 15 19]))
                    multiply_time = floor(RandBetween(1,1/App.time(Housenbr,1,nbr_appliance)*2/7,1,1));
                else
                    multiply_time = 1;
                end
                if App.timeaction(Housenbr,1,nbr_appliance) <= 0.5 && ~varcare == 1
                    App.timeaction(Housenbr,1,nbr_appliance) = App.time(Housenbr,1,nbr_appliance) * multiply_time ;
                end
                App.Total_Action2(Housenbr, myiter + 2,nbr_appliance) = multiply_time          ;
            else
                App.Total_Action2(Housenbr, myiter + 2,nbr_appliance) = 0          ;
            end
        else
            App.Total_Action2(Housenbr, myiter + 2,nbr_appliance) = 0          ;
        end
        % Remember all the actions
        App.Mem_app_action(Housenbr, 2,nbr_appliance) = App.timeaction(Housenbr,1,nbr_appliance) ;
        %% Delay period depending on the controller

        if (Short_delay == 0 && Long_delay == 0) || (varcare == 1)
            timeaction_app2 = App.Mem_app_action(Housenbr, 2, nbr_appliance) ;
            App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
        else
            if ~Short_delay == 0
                delay_time_short = ShortDelay; %1 / stepreal;
                App.delay_time_app(Housenbr,2, nbr_appliance) = delay_time_short;
                if ~myiter == 0
                    if delay_time_short > 0 && App.Mem_app_action(Housenbr, 2, nbr_appliance) > 0
                        if and(delay_time_short > 0, App.Mem_app_action(Housenbr, 1, nbr_appliance) == 0)
                            App.Mem_app_action2(Housenbr, myiter + 1 + delay_time_short,nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
                            timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                        else
                            App.Mem_app_action2(Housenbr, myiter + 1 + App.delay_time_app(Housenbr,1, nbr_appliance),nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
                            timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                        end
                    elseif and(App.delay_time_app(Housenbr,1, nbr_appliance) > 0, App.Mem_app_action(Housenbr, 1, nbr_appliance) > 0)
                        App.Mem_app_action2(Housenbr, myiter + 1 + App.delay_time_app(Housenbr,1, nbr_appliance),nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
                        timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                    else
                        App.Mem_app_action2(Housenbr, myiter + 1 + delay_time_short,nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
                        timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                    end
                else
                    timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                end
            end

            if ~Long_delay == 0
                if Time_Sim.Delay_time(Housenbr,1) > 0
                    delay_time_long = Time_Sim.Delay_time(Housenbr,1) / stepreal;
                else
                    delay_time_long = 0;%(21 - timehour + 3 + 7 - ceil(time(Housenbr,1,nbr_appliance))) / stepreal;
                    % Why Not delay_time = (Delay_time(Housenbr,1) - ceil(wash_time(Housenbr,1))) / stepreal; ?
                end
                if and(sum(App.Mem_app_action2(Housenbr, (myiter + 1:end), nbr_appliance)) == 0, App.timeaction(Housenbr,1,nbr_appliance) > 0 )
                    App.xxx_app(Housenbr,1,nbr_appliance) = myiter + 1 + delay_time_long;
                    App.yyy_app(Housenbr,1,nbr_appliance) = App.time(Housenbr,1,nbr_appliance);
                end
                if App.xxx_app(Housenbr,1,nbr_appliance) < nbrstep
                    zz = sum(App.Mem_app_action2(Housenbr, (App.xxx_app(Housenbr,1,nbr_appliance):App.xxx_app(Housenbr,1,nbr_appliance) + ceil(App.yyy_app(Housenbr,1,nbr_appliance))), nbr_appliance));
                else
                    zz = 0;
                end
                App.delaylong_time_app(Housenbr,2,nbr_appliance) = delay_time_long;
                if ~myiter == 0
                    if ~(zz==App.yyy_app(Housenbr,1, nbr_appliance))
                        if and(delay_time_long > 0, App.Mem_app_action(Housenbr, 2, nbr_appliance) > 0)
                            if and(delay_time_long > 0, App.Mem_app_action(Housenbr, 1, nbr_appliance) == 0)
                                App.Mem_app_action2(Housenbr, myiter + 1 + delay_time_long,nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
                                timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                            else
                                App.Mem_app_action2(Housenbr, myiter + 1 + App.delaylong_time_app(Housenbr,1,nbr_appliance),nbr_appliance) = App.Mem_app_action(Housenbr, 2, nbr_appliance);
                                timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                            end
                        elseif and(App.delaylong_time_app(Housenbr,1, nbr_appliance) > 0, App.Mem_app_action(Housenbr, 1, nbr_appliance) > 0)
                            App.Mem_app_action2(Housenbr, myiter + 1 + App.delaylong_time_app(Housenbr,1, nbr_appliance), nbr_appliance) = App.Mem_app_action(Housenbr, 2,nbr_appliance);
                            timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                        else
                            App.Mem_app_action2(Housenbr, myiter + 1 + delay_time_long, nbr_appliance) = App.Mem_app_action(Housenbr, 2,nbr_appliance);
                            timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                        end
                    elseif App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance)  > 0
                        timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                    else
                        App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance) = 0;
                        timeaction_app2 = 0;
                    end
                else
                    timeaction_app2 = App.Mem_app_action2(Housenbr, myiter + 1, nbr_appliance);
                end 
            end
        end
        % Calculation of the output power
        if ~App.timeaction(Housenbr,1,nbr_appliance) == 0 || ~timeaction_app2 == 0
            if isa(App.class_app{Appliance_nbr,1},'cell')
                AllClasses = App.class_app{Appliance_nbr,1} ;
                Classrateined = AllClasses{1,sum(nbr_appliances(1:nbr_appliance,2) == Appliance_nbr)} ;
            elseif isa(App.class_app{Appliance_nbr,1},'char')
                Classrateined = App.class_app{Appliance_nbr,1};
            end
            switch Classrateined
                case 'A or B class'
                    App_Power = Power_Level(1) * stepreal;
                case 'C or D class'
                    App_Power = Power_Level(2) * stepreal;
                case 'E or F class'
                    App_Power = Power_Level(3) * stepreal;
                otherwise
                    App_Power = Power_Level(1) * stepreal;
            end
            if ~Short_delay == 0 || ~Long_delay == 0
                Timeaction_touse = timeaction_app2;
            else
                Timeaction_touse = App.timeaction(Housenbr,1,nbr_appliance);
            end
            App_Energy = App_Power * Timeaction_touse;
        else
            if ~Power_Level(5)==0
                bed1lap_act = [0,0.147,1]';                                 % Include the stand-by power to the calculation
                %%% Sleeping mode
                if and(App.rand_act(Housenbr, myiter + 1, nbr_appliance) >= bed1lap_act(1), App.rand_act(Housenbr, myiter + 1, nbr_appliance) <= bed1lap_act(2))
                    if isa(App.class_app{Appliance_nbr,1},'cell')
                        AllClasses = App.class_app{Appliance_nbr,1} ;
                        Classrateined = AllClasses{1,sum(nbr_appliances(1:nbr_appliance,2) == Appliance_nbr)} ;
                    elseif isa(App.class_app{Appliance_nbr,1},'char')
                        Classrateined = App.class_app{Appliance_nbr,1};
                    end
                    switch Classrateined
                        case 'A or B class'
                            App_Power = Power_Level(4) * 1.0 * stepreal;
                        case 'C or D class'
                            App_Power = Power_Level(4) * 5/3 * stepreal;
                        case 'E or F class'
                            App_Power = Power_Level(4) * 10/3 * stepreal;
                    end
                %%% Off Mode
                elseif and(App.rand_act(Housenbr, myiter + 1, nbr_appliance) > bed1lap_act(2), App.rand_act(Housenbr, myiter + 1, nbr_appliance) <= bed1lap_act(3))
                    if isa(App.class_app{Appliance_nbr,1},'cell')
                        AllClasses = App.class_app{Appliance_nbr,1} ;
                        Classrateined = AllClasses{1,sum(nbr_appliances(1:nbr_appliance,2) == Appliance_nbr)} ;
                    elseif isa(App.class_app{Appliance_nbr,1},'char')
                        Classrateined = App.class_app{Appliance_nbr,1};
                    end
                    switch Classrateined
                        case 'A or B class'
                            App_Power = Power_Level(5) * 1.0 * stepreal;
                        case 'C or D class'
                            App_Power = Power_Level(5) * 1.5 * stepreal;
                        case 'E or F class'
                            App_Power = Power_Level(5) * 3.0 * stepreal;
                    end
                end
                App_Energy = App_Power;
            elseif ~Power_Level(4)==0
                if isa(App.class_app{Appliance_nbr,1},'cell')
                    AllClasses = App.class_app{Appliance_nbr,1} ;
                    Classrateined = AllClasses{1,sum(nbr_appliances(1:nbr_appliance,2) == Appliance_nbr)} ;
                elseif isa(App.class_app{Appliance_nbr,1},'char')
                    Classrateined = App.class_app{Appliance_nbr,1};
                end
                switch Classrateined
                    case 'A or B class'
                        App_Power = Power_Level(4) * 1.0 * stepreal;
                    case 'C or D class'
                        App_Power = Power_Level(4) * 5/3 * stepreal;
                    case 'E or F class'
                        App_Power = Power_Level(4) * 10/3 * stepreal;
                end
                 App_Energy = App_Power;
            else
                %%% Active Mode
                App_Energy = 0;
            end
        end
        Energy = App_Energy;
        %%%
        % Appliances_Cons data are collected throughout the simulation for
        % collecting information.
        App.Appliances_Cons(Housenbr, myiter + 1, nbr_appliance) = Energy ;
       % Action      = Energy ;
    end
end

%% Fridge
    if Fridge >= 1
        [Power_Fridge] = Fri(timehour);
    else
        Power_Fridge = 0;
    end
    App.Appliances_Cons(Housenbr, myiter + 1, find(nbr_appliances(:,2) == 10)) = Power_Fridge;
%App_Row = zeros(nbr_appliance_max,21);
App_Row = zeros(100,21);
for var_app = 1:21
    if ~isnan(find(nbr_appliances(:,2) == var_app))
        App_Row(1:size(find(nbr_appliances(:,2) == var_app),1),var_app) = find(nbr_appliances(:,2) == var_app);
    else
        App_Row(:,var_app) = 0;
    end
end
Power_Kitchen   = 0 ;
Power_Clean     = 0 ;
Power_Living    = 0 ;
Power_Bath      = 0 ;
Power_Bedrooms  = 0 ;
Power_Calc_Light= 0 ;
Appliance_Number_Kitchen = [1,2,3,4,5,6,7,8,9,10;... % Power Kitchen
                           18,19,0,0,0,0,0,0,0,0;... % Power Cleaning System
                           16,17,0,0,0,0,0,0,0,0;... % Power living room
                           13,14,15,21,0,0,0,0,0,0;...% Power bathroom
                           11,12,20,0,0,0,0,0,0,0;... % Power Bedrooms
                           8,9,7,6,18,19,16,17,15,4]; % Power for light calculations

for BB = 1:21
    for CC = unique(App_Row(:,BB))'
        if ~CC==0
            [Rowapp,~,~] = find(Appliance_Number_Kitchen == BB);
            for DD = unique(Rowapp(:,1))'
                switch DD
                    case 1
                        Power_Kitchen(length(Power_Kitchen) + 1) = App.Appliances_Cons(Housenbr, myiter + 1,CC);
                    case 2
                        Power_Clean(length(Power_Clean) + 1) = App.Appliances_Cons(Housenbr, myiter + 1,CC);
                    case 3
                        Power_Living(length(Power_Living) + 1) = App.Appliances_Cons(Housenbr, myiter + 1,CC);
                    case 4
                        Power_Bath(length(Power_Bath) + 1) = App.Appliances_Cons(Housenbr, myiter + 1,CC);
                    case 5
                        Power_Bedrooms(length(Power_Bedrooms) + 1) = App.Appliances_Cons(Housenbr, myiter + 1,CC);
                    case 6
                        Power_Calc_Light(length(Power_Calc_Light) + 1) = App.Appliances_Cons(Housenbr, myiter + 1,CC);
                end
            end
        end
    end
end
Power_Kitchen = sum(Power_Kitchen);
Power_Clean = sum(Power_Clean) ;
Power_Living = sum(Power_Living) ;
Power_Bath = sum(Power_Bath);
Power_Bedrooms = sum(Power_Bedrooms);
App.Power_Kitchen = Power_Kitchen;
App.Power_Clean = Power_Clean;
App.Power_Living = Power_Living;
App.Power_Bath = Power_Bath;
App.Power_Bedrooms = Power_Bedrooms;
[Power_Light(myiter + 1)] = Lighting(myiter);
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
App.Metering_Cons(Housenbr, myiter + 1) = SP_Cons * nbr_app_max + SM_Cons ;
%% Output Variables
%%%
% The following integrates the electricity consumption from the metering
% system
Total_Cons = sum(App.Appliances_Cons(Housenbr, myiter + 1,:)) + Power_Light(myiter + 1) + App.Metering_Cons(Housenbr, myiter + 1);
Power_Calc_Light = sum(Power_Calc_Light);

if Time_Sim.Series_Sim == 1
    if myiter == nbrstep - 1
        App.NewVar1         = App.NewVar1 + 1      ;
        NewVar1             = App.NewVar1          ;
        FileName            = dbstack()                 ;
        if ~(NewVar1 == 1)
            load(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'));
        else
            % Set the size of each variable
            NewVar.Total_Action2        = zeros(Time_Sim.Nbr_Building,nbrstep + 1,App.NbrAppMax);
            NewVar.Vec_Mean_Act_Week    = zeros(Time_Sim.Nbr_Building, 2,App.NbrAppMax);
            NewVar.Appliances_Cons      = zeros(Time_Sim.Nbr_Building,nbrstep + 1,App.NbrAppMax);
            NewVar.time_for_record      = zeros(Time_Sim.Nbr_Building,nbrstep + 1,App.NbrAppMax);
            NewVar.Nbr_Building         = zeros(Time_Sim.Nbr_Building,nbrstep + 1,App.NbrAppMax);
            NewVar.Metering_Cons        = zeros(Time_Sim.Nbr_Building,nbrstep);
        end
        Nbr_Buildingmax                                                 = Time_Sim.Nbr_Building                   ;
        NewVar.YearStartSim                                             = Time_Sim.YearStartSim                   ;
        NewVar.YearStartSim2004                                         = Time_Sim.YearStartSim2004               ;
        NewVar.Total_Action2(NewVar1,1:end,1:(max(2,nbr_app_max)))           = App.Total_Action2(Housenbr,:,:)         ;
        NewVar.Vec_Mean_Act_Week(NewVar1,1:end,1:(max(2,nbr_app_max)))       = App.Vec_Mean_Act_Week(Housenbr,:,:)     ;
        NewVar.Appliances_Char                                          = Appliances_Char                         ;
        NewVar.Timeoffset                                               = Timeoffset                              ;
        NewVar.TimeVector                                               = TimeVector                              ;
        NewVar.Appliances_Cons(NewVar1,1:end,1:(max(2,nbr_app_max)))         = App.Appliances_Cons(Housenbr,:,:)       ;
        NewVar.time_for_record(NewVar1,1:end,1:(max(2,nbr_app_max)))         = App.time_for_record(Housenbr,:,:)       ;
        NewVar.Nbr_Building(NewVar1,1:end,1:(max(2,nbr_app_max)))            = Nbr_Buildingmax(Housenbr,:,:)           ;
        NewVar.Metering_Cons(NewVar1,1:end)                             = App.Metering_Cons(Housenbr, :)          ;
        %NewVar.AppDetails(:,:,NewVar1)           = App.nbr_appliances(:,:,Housenbr)   ;
        
        save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'),'NewVar');
    end
else
    if myiter == 8807
        y = 1;
    end 
    if myiter == nbrstep - 1
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
    function [Power_Light] = Lighting(myiter)
        Emax    = 100000    ;
        Emin    = 20        ;
        Accmin  = 0.1       ; 
        Percentage = SolarLuminancev(Housenbr, myiter + 1)/(2/3*Emax)+Accmin-Emin/(Emax*2/3);
        %Percentage = 0.015* SolarLuminancev(Housenbr, myiter + 1) / 1000 + 0.0997;
        if (1 - Percentage) >= App.Light_rand(Housenbr, myiter + 1)
            if Power_Calc_Light <= sum(Appliances_Char(4,8,Appliance_Number_Kitchen(6,:)))
                ValOccup   = 0              ;
            else
                ValOccup   = 1              ;
            end
        else
            ValOccup   = 0;
        end
        switch (clLight{1})
            case 'Low consumption bulbs'
                Power_Light = ValOccup * Building_Area * 0.0037 * stepreal;
            case 'Incandescent bulbs'
                Power_Light = ValOccup * Building_Area * 0.012 * stepreal;
        end
    end
%%% Nested function representing the Fridge
    function [Action] = Fri(timehour)
        switch (App.class_app{10})
            case 'A or B class'
                fri_Power = 0.039 * stepreal;
            case 'C or D class'
                fri_Power = 0.100 * stepreal;
            case 'E or F class'
                fri_Power = 0.200 * stepreal;
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