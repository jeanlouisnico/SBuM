%% Appliances
% In this section, every appliances that has been selected to be run in the
% simulation are oging to be processed. First, all data are going to be
% passed through 
function [Total_Cons,Power_Calc_Light,varargout] = Appliances_One_CodeStrv2(varargin)


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
nbrstep         = Time_Sim.nbrstep.(Input_Data.Headers)          ;
stepreal        = Time_Sim.stepreal        ;
Appliances_Char = All_Var.Detail_Appliance;
inhabitants     = str2double(Input_Data.inhabitants);
Timeoffset      = Time_Sim.Timeoffset;
Reduce_time     = Time_Sim.Reduce_time;
MinperIter      = Time_Sim.MinperIter ;
SecperIter      = Time_Sim.SecperIter ;
Building_Area   = str2double(Input_Data.Building_Area) ;
clLight         = Input_Data.clLight ;
Time_Step       = Input_Data.Time_Step;
Metering        = str2double(Input_Data.Metering)       ;
% ProfileSelected = str2double(Input_Data.Profile)       ;
HouseName       = Input_Data.Headers                    ;

Stat4Use        = All_Var.ProfileUserdistri.(HouseName) ;

% switch ProfileSelected
%     case 1
%         Stat4Use        = All_Var.Stat4Use_Profile1;
%     case 2
%         Stat4Use        = All_Var.Stat4Use_Profile2;
%     otherwise
%         Stat4Use        = All_Var.Stat4Use_Profile1;
% end

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

AppList     = All_Var.GuiInfo.AppliancesList ;
AppSimu     = fieldnames(All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances) ;
App10s      = All_Var.GuiInfo.App10s ;
CurrentTime = Time_Sim.TimeStr ;
AppHistory  = cell(1,2) ;
%% Enter Iteration for each appliance
if nbr_appliances > 0
    for nbr_appliance = 1:size(AppSimu,1)
        AppName     = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).SN    ; % AppList{nbr_appliance,3}  ;
        AppQty      = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).Qty   ;
        AppClass    = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).Class ;
        AppDB       = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).DB    ;
        Appnumber   = find(strcmp(AppList(:,3), AppName)) ;
        % ApplianceClass = AppList{nbr_appliance,4}   ;
        
        if isa(AppQty,'char')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'string')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'cell')
            AppQty = str2double(AppQty) ;
        end
        
        if any(strcmp(AppHistory(:,1), AppName))
            GetAllApp   = strcmp(AppHistory(:,1), AppName) ;
            Qty         = AppHistory(GetAllApp,2) ;
            if size(Qty, 1) > 1 
                startApp    = plus(Qty{:}) + 1 ;
            else
                startApp    = Qty{1} + 1 ;
            end
        else
            startApp    = 1 ;
        end
        
        % This is only for classifying the appliances.
        AppHistory{nbr_appliance,1} = AppName ;
        AppHistory{nbr_appliance,2} = AppQty ;
        
        LongAppName = All_Var.GuiInfo.datastructure.(AppName).LongName ; %AppList(nbr_appliance,1)  ;
        ShortAppName = All_Var.GuiInfo.datastructure.(AppName).ShortName ; %AppList(nbr_appliance,1)  ;
        if isempty(AppName)
            % resume to the next applicance
            continue; % This is for the lighting system
        end
%         AppSN = Input_Data.(AppName) ;
%         if ~strcmp(AppSN{1},'0')
            %% There must be at least 1 appliance to process in this category
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Check for unloading structure variables and run the code only with arrays
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for subapp = startApp:(startApp - 1 + AppQty)
                % Loop through each subapp to see if they are running or
                % not.
                %% Set the variables before starting the loop
                
                App = SetApp(App,AppName,subapp,HouseName, CurrentTime) ;
                % These are examples to be implemented
                
                Max_use             = All_Var.Detail_Appliance_List.(AppName).MaxUse(inhabitants) ;
                Time_Usage_Prob     = All_Var.Detail_Appliance_List.(AppName).Temp(:)                  ;
                Time_Usage          = All_Var.Detail_Appliance_List.(AppName).TimeUsage(:)             ;
                Daily_Profile       = All_Var.Detail_Appliance_List.(AppName).Weekdistr(:)            ;
                weekday             = All_Var.Detail_Appliance_List.(AppName).Weekdayweight(inhabitants) ;
                WeekDayProfileAcc   = All_Var.Detail_Appliance_List.(AppName).Weekdayacc(inhabitants) ;
                % Need to be re-Written as a washing machine can have any
                % of the 3 options
                Long_delay          = All_Var.Detail_Appliance_List.(AppName).Delay(1) ;
                Short_delay         = All_Var.Detail_Appliance_List.(AppName).Delay(2) ;
                    ShortDelay      = Short_delay * Time_Sim.hour_1_delay.(HouseName)(1);
                reduce_time         = All_Var.Detail_Appliance_List.(AppName).Delay(3) ;
                
                Power_Level         = All_Var.Detail_Appliance_List.(AppName).Power(:) ;
                %% Detect if the appliance is already running
                % Check if the action timer is true or false meaning that
                % the appliance is currently running

                % Set some variables in case they were not set before
                try 
                    App.timeactionStr.(AppName)(subapp).(HouseName)(1) ;
                catch
                    App.timeactionStr.(AppName)(subapp).(HouseName)(1) = 0 ;
                end
                try
                    App.Info.(AppName)(subapp).(HouseName).ActionQty ;
                catch
                    App.Info.(AppName)(subapp).(HouseName).ActionQty = 0;
                end
                try
                    App.Info.(AppName)(subapp).(HouseName).LeftCycle ;
                catch
                    App.Info.(AppName)(subapp).(HouseName).LeftCycle = 1 ;
                end
%                 if ~App.timeactionStr.(AppName)(subapp).(HouseName)(1) == 0
%                     AppInUse = true  ;
%                 else
%                     AppInUse = false ;
%                 end
                if myiter == 1000
                    x = 1;
                end
                if strcmp(AppName,'Elec')
                    % Make a stop to debug
                    ystop = 1;
                end
                if App.Info.(AppName)(subapp).(HouseName).InUse
                    % 1. Check how much time there is left
                    [App_Energy, App] = PowerConsumption(App, AppName, subapp, HouseName, Time_Sim, App.PowerConsProfile, AppList, ...
                                                         Appnumber,  Input_Data, Power_Level, All_Var, ShortAppName,SecperIter, App10s, AppClass, AppDB) ;
                    % 2. Process the time left
                    % 3. Get the power/energy demand
                    % 4. Go to next app
                else % The appliance is not running at the moment
                    % 1. Get the statistical values from the appliance
                    
                    [Mean_Prev_day, Mean_Act_Week, Activity_tot] = AppStats(App, AppName, subapp, HouseName, timedaynbr, timeweeknbr) ;
                        App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(2) = Mean_Act_Week;
                    % 2. Define if the appliance is allowed to run based on
                    % the statistical distribution
                    if strcmp(AppName,'Fridge')
                        % Fridge is always on, so its value is always equa
                        % to 1. Option to make scenario could be developed
                        % further.
                         App.actionStr.(AppName)(subapp).(HouseName)(1) = 1;
                    else
                        [Day_Access]            = DayAccess(Max_use, Mean_Prev_day) ;
                        if Day_Access
                            [Week_Access]           = WeekAccess(Mean_Act_Week,Max_use,timeweeknbr) ;
                            if Week_Access
                                [Week_Day_End_Access]   = WeekDayAccess(Activity_tot,All_Var,AppName,weekday,Max_use,subapp,HouseName,myiter,App,Mean_Act_Week,WeekDayProfileAcc,Daily_Profile,timeweekday) ;
                                if Week_Day_End_Access
                                    [App, Hour_Access]      = HourlyAccess(timeweekday,Stat4Use,timemonth,AppName,subapp,HouseName,App,timehour, AppDB) ;
                                    if Hour_Access
                                        App.actionStr.(AppName)(subapp).(HouseName)(1) = 1;
                                    else
                                        App.actionStr.(AppName)(subapp).(HouseName)(1) = 0;
                                    end
                                else
                                    App.actionStr.(AppName)(subapp).(HouseName)(1) = 0;
                                end
                            else
                                App.actionStr.(AppName)(subapp).(HouseName)(1) = 0 ;
                            end
                        else
                            App.actionStr.(AppName)(subapp).(HouseName)(1) = 0;
                        end
%                         App.actionStr.(AppName)(subapp).(HouseName)(1) = Week_Access * Week_Day_End_Access * Day_Access * Hour_Access;
                    end
                    
                    % 3. if the appliance can generate, then proceed with
                    % the generation steps
                    if App.actionStr.(AppName)(subapp).(HouseName)(1)
                        if strcmp(AppName,'Elec')
                            % Make a stop to debug
                            ystop = 1;
                        end
                        App.activeApp.(AppName)(subapp).(HouseName)     = true ;
                        App.Info.(AppName)(subapp).(HouseName).InUse    = true ;
                        App.Info.(AppName)(subapp).(HouseName).InUse10s = true ;
                        App.Info.(AppName)(subapp).(HouseName).StepUse  = 1  ; 
                        
                        % 4. Increase the action numbers. The action
                        % distribution is given on an hourly basis, thus this
                        % should be increased especially if the cycle time is
                        % small.  
                        
                        % CycleTime is the time of 1 cycle in the app
                        % signature (expressed in number of steps that is
                        % dependent on the time resolution of the
                        % simulation). Expressed in steps.
                        % Time_Cycle is the time the applicance is going to
                        % be running. This will be used for creating the
                        % appliance signature and the amount of electricity
                        % used for this cycle. Expressed in steps
                        
                        [AppSign, CycleTime, Time_Cycle, MinperIter, App] = CreateTime(AppName, All_Var, App, subapp, HouseName, myiter, Time_Usage_Prob, Time_Usage, Time_Step, Reduce_time, reduce_time, MinperIter) ;
                        
                        % Increase the amount of appliance cycles,
                        % especially when the time resolution is set to
                        % hourly values.
                        Mintime = 2 / 7;
                        if strcmp(AppName,'Fridge')
                            % Make a stop to debug
                            Time_Cycle = 1;
                        end
                        if Time_Cycle < Mintime
                            % If the time cycle for the appliance is less
                            % than 2/7 of 1 step, then we can multiply its
                            % usage
                            % for example, if 1 step = 1 hour, 2/7 is 17
                            % minutes, if 1 step = 30 minutes, then it is
                            % equal to 8.5 minutes
                            multiply_time = floor(RandBetween(1,1/Time_Cycle * Mintime,1,1));
                            Time_Cycle = Time_Cycle * multiply_time ;
                        else
                            multiply_time = 1 ;
                        end
                        % Record the amound of actions performed within
                        % this section. This is used for statistical
                        % purposes to make sure the app is used according
                        % to the weekly distribution within days, Month,
                        % and hours
                        try
                            App.Info.(AppName)(subapp).(HouseName).time_for_recordStr(end + 1)    = Time_Cycle ;
                        catch
                            App.Info.(AppName)(subapp).(HouseName).time_for_recordStr(1)          = Time_Cycle ;
                        end
                        App.Info.(AppName)(subapp).(HouseName).ActionQty                      = App.Info.(AppName)(subapp).(HouseName).ActionQty + multiply_time ;
                        App.Info.(AppName)(subapp).(HouseName).ActionQtyStep(myiter + 1)      = multiply_time ;
                        App.Info.(AppName)(subapp).(HouseName).Time_Cycle(myiter + 1)         = Time_Cycle    ;
                        % Resample depending on the size of the cycle
                        if strcmp(AppName,'Fridge')
                           [App.PowerConsProfile.(AppName)(subapp).(HouseName), App.OutputSignal10s.(AppName)(subapp).(HouseName), App.Info.(AppName)(subapp).(HouseName).LeftCycle] = ...
                                                    ReSampling(AppSign.(AppName).Sign, Time_Cycle, AppName, CycleTime, MinperIter, App.Info.(AppName)(subapp).(HouseName).LeftCycle) ; 
                        else
                            [App.PowerConsProfile.(AppName)(subapp).(HouseName), App.OutputSignal10s.(AppName)(subapp).(HouseName)] = ...
                                                    ReSampling(AppSign.(AppName).Sign, Time_Cycle, AppName, CycleTime, MinperIter) ; 
                        end
                        
                        % This has the entire profile to be used for calculating the active power of the appliance. 
                        % This is expressed in [%] of the maximum power capacity of the applicance and therefore should be 
                        % multiplied by the power rating of the appliance
                        
                    % 5. Look if the appliance can or should be delayed
                    %    If yes, delay to the indicated time
                    %    If no, create the action now
                        if (Short_delay == 0 && Long_delay == 0)
                            App.ActionStart.(AppName)(subapp).(HouseName) = Time_Sim.TimeStr ;
                        else
                            if Short_delay == 1
                                % ShortDelay is the short delaying time
                                % expressed in hours
                                % This defines when the appliance have to
                                % start its delay in case 
                                App.ActionStart.(AppName)(subapp).(HouseName) = Time_Sim.TimeStr + seconds(3600 * ShortDelay) ;
                            elseif Long_delay  == 1
                                delay_time_long = Time_Sim.Delay_time.(HouseName)(1) ;
                                App.ActionStart.(AppName)(subapp).(HouseName) = Time_Sim.TimeStr + seconds(3600 * delay_time_long) ;
                            end
                        end
                    
                    % 6. Calculate the power output from the appliance
                        [App_Energy, App] = PowerConsumption(App, AppName, subapp, HouseName, Time_Sim, App.PowerConsProfile, AppList, ...
                                                             Appnumber,  Input_Data, Power_Level, All_Var, ShortAppName,SecperIter, App10s, AppClass, AppDB) ;
                        
                    else
                    %    If the appliance cannot generate, look for residual power and continue to the next appliance   
                        App.Info.(AppName)(subapp).(HouseName).ActionQtyStep(myiter + 1) = 0 ;
                        [App, App_Energy,AppInUse]  = ResidualPower(Power_Level,App,AppName,subapp, HouseName, myiter, AppList, Appnumber, Input_Data, All_Var, stepreal, ShortAppName, AppClass, AppDB) ;
                        [App]                       = Allocate_Energy(App_Energy,App,AppName,subapp,HouseName,myiter, AppInUse) ;
                        continue ;
                    end
                    
                end
                App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) = App_Energy ;
                
                % If they are not Running
                %   Evaluate if they should run (all code)
                %   Evaluate if they can be part of some DR programme
                % If they are running, recalculate the power consumption
                % based on the timestep of the simulation, the programme
                % chosen etc...
                % 
                % actionStr - Define if an action has been granted based on
                % the statistical distribution. This does not mean that the
                % action actually took place               
            end
%         end
    end
end

%% Fridge
% Power_FridgeTot = 0 ;
% for ij = 1:numel(Input_Data.Fridge)
%     FridgeExist = str2double(Input_Data.Fridge{ij}) ;
%     if FridgeExist >= 1
%         [Power_Fridge] = Fri(timehour,Input_Data.clFridge{ij}, HouseName, All_Var,stepreal);
%     else
%         Power_Fridge = 0;
%     end
%     App.Appliances_ConsStr.Fridge(ij).(HouseName)(myiter + 1) = Power_Fridge ;
% end

% App.Appliances_ConsStr.Fridge.(HouseName)(myiter + 1) = Power_FridgeTot;

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
    for nbr_appliance = 1:size(AppSimu,1)
%         AppName = AppList{nbr_appliance,3}            ;
        AppName     = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).SN    ; % AppList{nbr_appliance,3}  ;
        AppQty      = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).Qty   ;
        
        if isa(AppQty,'char')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'string')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'cell')
            AppQty = str2double(AppQty) ;
        end
%         LongAppName = All_Var.GuiInfo.datastructure.(AppName).LongName ;
        if isempty(AppName)
            continue; % This is for the lighting system
        end
%         AppSN = Input_Data.(AppName) ;
%         if ~strcmp(AppSN{1},'0')
            % There is at least 1 appliance to process in this category
            for subapp = 1:AppQty
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
%         end
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
[App.Power_Light.(HouseName)(myiter + 1)]  = Lighting(myiter,sum(Power_Calc_Light.(HouseName)),Appliance_Light,Input_Data,App, HouseName, All_Var,stepreal,Building_Area,SolarLuminancev,clLight);
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
    for nbr_appliance = 1:size(AppSimu,1)
%         AppName = AppList{nbr_appliance,3}            ;
        AppName     = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).SN    ; % AppList{nbr_appliance,3}  ;
        AppQty      = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).Qty   ;
        
        if isa(AppQty,'char')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'string')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'cell')
            AppQty = str2double(AppQty) ;
        end
        
        if isempty(AppName)
            continue; % This is for the lighting system
        end
%         AppSN = Input_Data.(AppName) ;
%         if ~strcmp(AppSN{1},'0')
            % There is at least 1 appliance to process in this category
            for subapp = 1:AppQty
                Cons_App  = App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1) ;
                Total_Cons = Total_Cons + Cons_App ;
            end
%         end
    end
    App.Total_Cons(myiter + 1) = Total_Cons ;
end
Total_Cons = Total_Cons + App.Power_Light.(HouseName)(myiter + 1) + App.Metering_ConsStr.(HouseName)(myiter + 1)    ;
           
Power_Calc_Light = sum(Power_Calc_Light.(HouseName)) ;

if Time_Sim.Series_Sim == 1
    if myiter == nbrstep - 1
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
            for nbr_appliance = 1:size(AppSimu,1)
%                 AppName = AppList{nbr_appliance,3}            ;
                AppName     = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).SN    ; % AppList{nbr_appliance,3}  ;
                AppQty      = All_Var.GuiInfo.SummaryStructure.(HouseName).Appliances.(AppSimu{nbr_appliance}).Qty   ;
                if isempty(AppName)
                    continue; % This is for the lighting system
                end
                if isa(AppQty,'char')
                    AppQty = str2double(AppQty) ;
                elseif isa(AppQty,'string')
                    AppQty = str2double(AppQty) ;
                elseif isa(AppQty,'cell')
                    AppQty = str2double(AppQty) ;
                end
%                 AppSN = Input_Data.(AppName) ;
%                 if ~strcmp(AppSN{1},'0')
                    % There is at least 1 appliance to process in this category
                    for subapp = 1:AppQty
                        if ToBuild == 1
                            NewVar.Total_Action2Str.(AppName)(subapp).(HouseName)        = zeros(nbrstep + 1,1);
                            NewVar.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)    = zeros(2,1)          ;
                            NewVar.Appliances_ConsStr.(AppName)(subapp).(HouseName)      = zeros(nbrstep + 1,1);
                            NewVar.time_for_recordStr.(AppName)(subapp).(HouseName)      = zeros(nbrstep + 1,1);
                            NewVar.Nbr_BuildingStr.(AppName)(subapp).(HouseName)         = zeros(nbrstep + 1,1);
                            NewVar.Metering_ConsStr.(AppName)(subapp).(HouseName)        = zeros(Time_Sim.Nbr_Building,nbrstep);
                        end
                        NewVar.Total_Action2Str.(AppName)(subapp).(HouseName)                       = App.Total_Action2Str.(AppName)(subapp).(HouseName)         ;
                        NewVar.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)                   = App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)     ;
                        NewVar.Appliances_CharStr.(HouseName)                                       = All_Var.Detail_Appliance_List                                       ;
                        NewVar.Appliances_ConsStr.(AppName)(subapp).(HouseName)                     = App.Appliances_ConsStr.(AppName)(subapp).(HouseName) ;
                        NewVar.time_for_recordStr.(AppName)(subapp).(HouseName)                     = App.time_for_recordStr.(AppName)(subapp).(HouseName)       ;
                    end
%                 end
            end
            NewVar.Metering_ConsStr.(HouseName)                       = App.Metering_ConsStr.(HouseName)          ;
        end
        Nbr_Buildingmax             = Time_Sim.Nbr_Building                   ;
        NewVar.YearStartSimStr      = Time_Sim.YearStartSim                   ;
        NewVar.YearStartSim2004Str	= Time_Sim.YearStartSim2004               ;
        NewVar.TimeoffsetStr        = Timeoffset                              ;
        NewVar.Nbr_BuildingStr      = Nbr_Buildingmax ;
%         NewVar.App                  = App ;
%          NewVar.TimeVectorStr        = TimeVector                              ;
        %NewVar.AppDetails(:,:,NewVar1)           = App.nbr_appliances(:,:,Housenbr)   ;
        save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'),'NewVar');
    end
else
    if myiter == 8807
        yyyyy = 1;
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
%% Nested Functions
%--------------------------------------------------------------------------%
%%% Nested function representing the Lighting System
    function [Power_Light] = Lighting(myiter,Power_Calc_Light,Appliance_Light,Input_Data,App, HouseName, All_Var,stepreal,Building_Area,SolarLuminancev, clLight)
        Emax    = 100000    ;
        Emin    = 20        ;
        Accmin  = 0.1       ; 
        Percentage = SolarLuminancev(myiter + 1)/(2/3*Emax)+Accmin-Emin/(Emax*2/3);
        StandbyPower = 0 ;
        for i = 1:numel(Appliance_Light)
            AppNamehere = Appliance_Light{i} ;
            StandbyPower = StandbyPower + All_Var.Detail_Appliance_List.(AppNamehere).Power(4) ; % Standbypower
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
            if isfield(All_Var.GuiInfo.SelfDefinedAppliances.(HouseName),'Lights')
                LightPlace = All_Var.GuiInfo.SelfDefinedAppliances.(HouseName).Lights.Rate ;
                LightPlace = convert2double(LightPlace) ;    
            else
                LightPlace = 0 ;
            end
        else
            LightPlace = 0 ;
        end
        if isa(clLight,'cell')
            clLight = clLight{1} ;
        end
        switch (clLight)
            case 'Low consumption bulbs'
                Power_Light = ValOccup * Building_Area * 0.0037;
            case 'Incandescent bulbs'
                Power_Light = ValOccup * Building_Area * 0.012;
            case 'Self-defined'         % JARI'S ADDITION
                Power_Light = ValOccup * Building_Area * LightPlace ;   % JARI'S ADDITION
        end
    end % Lighting
%--------------------------------------------------------------------------%
%%% Fridge
    function [Action] = Fri(timehour,AppClass, HouseName, All_Var,stepreal)
        switch (AppClass)
            case 'A or B class'
                fri_Power = 0.039 ;
            case 'C or D class'
                fri_Power = 0.100 ;
            case 'E or F class'
                fri_Power = 0.200 ;
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
    end % Fridge
%--------------------------------------------------------------------------%
    function [App] = SetApp(App,AppName,subapp,HouseName, CurrentTime)
        App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(1)    = App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(HouseName)(2)         ;
        App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(1)      = App.Nbrusesumtotal2Str.(AppName)(subapp).(HouseName)(2)            ;
        App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(1)       = App.Mem_app_actionStr.(AppName)(subapp).(HouseName)(2)             ;
        App.delay_time_appStr.(AppName)(subapp).(HouseName)(1)       = App.delay_time_appStr.(AppName)(subapp).(HouseName)(2)             ;
        App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(1)   = App.delaylong_time_appStr.(AppName)(subapp).(HouseName)(2)          ;
    end % Set appliance values from the previous step
%--------------------------------------------------------------------------%
    function [Mean_Prev_day, Mean_Act_Week, Activity_tot] = AppStats(App, AppName, subapp, HouseName, timedaynbr, timeweeknbr)
        %% Define the number of use for the current and previous day, and per week
                AllActivity = App.Info.(AppName)(subapp).(HouseName).ActionQty ;
                Activity_tot = sum(AllActivity);
                
                % Mean activity for the previous day
                if timedaynbr == 1
                    minus_day = 0;
                else
                    minus_day = 1;
                end
                sum_day = timedaynbr - minus_day;
                Mean_Prev_day = Activity_tot / sum_day;

                % Mean Activity per weekday
                if timeweeknbr == 1
                    minus_week = 0;
                else
                    minus_week = 1;
                end
                sum_week = timeweeknbr - minus_week;
                Mean_Act_Week = Activity_tot / sum_week;
    end % Get the appliance usage statistics
%--------------------------------------------------------------------------%
    function [Day_Access] = DayAccess(Max_use, Mean_Prev_day)
        %% Daily Acceptance
        Daily_acc_day       = Max_use / 7   ;
        if Mean_Prev_day <= Daily_acc_day * 2
            Day_Access = true ;
        else
            Day_Access = false ;
        end
    end
%--------------------------------------------------------------------------%
    function [Week_Access] = WeekAccess(Mean_Act_Week,Max_use,timeweeknbr)
        % Weekly Acceptance
        if Mean_Act_Week <= Max_use * 1.1
            if timeweeknbr == 1
                Week_Access = false ;
            else
                Week_Access = true ;
            end
        else
            Week_Access = false ;
        end
    end
%--------------------------------------------------------------------------%
    function [Week_Day_End_Access] = WeekDayAccess(Activity_tot,All_Var,AppName,weekday,Max_use,subapp,HouseName,myiter,App,Mean_Act_Week,WeekDayProfileAcc,Daily_Profile,timeweekday)
        %% Set the new boundaries by incrementation
        MaxUse6Inhabitant = All_Var.Detail_Appliance_List.(AppName).MaxUse(6) ;
        MaxUse1Inhabitant = All_Var.Detail_Appliance_List.(AppName).MaxUse(1) ;
        if MaxUse6Inhabitant == MaxUse1Inhabitant
            a_day = (1 - weekday) ;
        else
            a_day = (1 - weekday) / (MaxUse6Inhabitant - MaxUse1Inhabitant);
        end
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
        Daily_Perc          = zeros(1,7)                                                    ;
        WeekEndProfileAcc   = 1-WeekDayProfileAcc                                           ;
        Daily_Perc(1:5)     = Daily_Profile(1:5)*WeekDayProfileAcc/sum(Daily_Profile(1:5))  ;
        Daily_Perc(6:7)     = Daily_Profile(6:7)*WeekEndProfileAcc/sum(Daily_Profile(6:7))  ;
        DailyAllowance      = Daily_Perc(timeweekday)                                       ;
        
        %% Increase the potential
        if isnan(App.Total_Action2StrCount.(AppName)(subapp).(HouseName)(timeweekday)/Activity_tot)
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
        %%% Weekday vs. weekend access
        if DailyAllowance * Increase_Potential > App.Inc_Pot_RandStr.(AppName)(subapp).(HouseName)(myiter + 1)
            Week_Day_End_Access = true  ;
        else
            Week_Day_End_Access = false ;
        end
    end
%--------------------------------------------------------------------------%
    function [App,Hour_Access] = HourlyAccess(timeweekday,Stat4Use,timemonth,AppName,subapp,HouseName,App,timehour, AppDB)
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

        App_All = [Stat4Use(timemonth,weekdayvar).(AppName).(AppDB)] ;

        if App.actionStr.(AppName)(subapp).(HouseName) == 0
            Randhour = App.rand_ApplianceStr.(AppName)(subapp).(HouseName)(App.refrnddayStr.(AppName)(subapp).(HouseName))    ;
        else
            App.refrnddayStr.(AppName)(subapp).(HouseName) = App.refrnddayStr.(AppName)(subapp).(HouseName) + 1               ;
            Randhour = App.rand_ApplianceStr.(AppName)(subapp).(HouseName)(App.refrnddayStr.(AppName)(subapp).(HouseName))    ;
        end
        if or(App.actionStr.(AppName)(subapp).(HouseName)(1) == 1, timehour == 0)
            App.refrnddayStr.(AppName)(subapp).(HouseName)(1) = App.refrnddayStr.(AppName)(subapp).(HouseName)(1) + 1         ;
        end 

        if and(Randhour >= App_All(floor(timehour + 1)), Randhour < App_All(floor(timehour + 2)))
            Hour_Access = true ;
        else
            Hour_Access = false ;
        end
    end
%--------------------------------------------------------------------------%
    function [App, App_Energy,AppInUse] = ResidualPower(Power_Level,App,AppName,subapp, HouseName, myiter, AppList, nbr_appliance, Input_Data, All_Var, stepreal, ShortAppName, AppClass, AppDB)
        if ~Power_Level(5)==0
            bed1lap_actfun = [0,0.147,1]';                                 % Include the stand-by power to the calculation
            %%% Sleeping mode
            if and(App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) >= bed1lap_actfun(1), App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) <= bed1lap_actfun(2))
%                 ApplianceClassfun = AppList{nbr_appliance,4}   ;
%                 Classrateinedfun = Input_Data.(ApplianceClassfun){subapp}    ;
                switch AppClass
                    case 'A or B class'
                        App_Powerfun = Power_Level(4) * 1.0 ;%* stepreal;
                    case 'C or D class'
                        App_Powerfun = Power_Level(4) * 5/3 ;%* stepreal;
                    case 'E or F class'
                        App_Powerfun = Power_Level(4) * 10/3 ;%* stepreal;
                    case 'Self-defined'                         % JARI
                        Placefun = All_Var.GuiInfo.Simulationdata.(HouseName).SelfDefinedAppliances.(ShortAppName).(AppDB).StandBy ;
                        App_Powerfun = Placefun ;%* stepreal;
                end
            %%% Off Mode
            elseif and(App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) > bed1lap_actfun(2), App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) <= bed1lap_actfun(3))
%                 ApplianceClassfun = AppList{nbr_appliance,4}   ;
%                 Classrateinedfun = Input_Data.(ApplianceClassfun){subapp}    ;
                switch AppClass
                    case 'A or B class'
                        App_Powerfun = Power_Level(5) * 1.0 ;%* stepreal;
                    case 'C or D class'
                        App_Powerfun = Power_Level(5) * 1.5 ;%* stepreal;
                    case 'E or F class'
                        App_Powerfun = Power_Level(5) * 3.0 ;%* stepreal;
                    case 'Self-defined'                         % JARI
                        Placefun = All_Var.GuiInfo.Simulationdata.(HouseName).SelfDefinedAppliances.(ShortAppName).(AppDB).Sleep ;
                        App_Powerfun = Placefun ;%* stepreal;
                end
            end
            App_Energy = App_Powerfun;
            AppInUse   = false;
        elseif ~Power_Level(4)==0
%             ApplianceClassfun = AppList{nbr_appliance,4}   ;
%             Classrateinedfun = Input_Data.(ApplianceClassfun){subapp}    ;

            switch AppClass
                case 'A or B class'
                    App_Powerfun = Power_Level(4) * 1.0 ;%* stepreal;
                case 'C or D class'
                    App_Powerfun = Power_Level(4) * 5/3 ;%* stepreal;
                case 'E or F class'
                    App_Powerfun = Power_Level(4) * 10/3 ;%* stepreal;
                case 'Self-defined'                         % JARI
                    App_Powerfun = All_Var.GuiInfo.Simulationdata.(HouseName).SelfDefinedAppliances.(ShortAppName).(AppDB).Sleep ;%* stepreal;
            end
             App_Energy = App_Powerfun;
             AppInUse   = false;        % JARI'S ADDITION
        else
            %%% Active Mode
            App_Energy = 0;
            AppInUse   = false;        % JARI'S ADDITION
        end
    end % Calculate the residual power (stand-by or off-mode consumption)
%--------------------------------------------------------------------------%    
    function [App] = Allocate_Energy(App_Energy,App,AppName,subapp,HouseName,myiter, AppInUse)
        Energyfun = App_Energy;
        %%%
        % Appliances_Cons data are collected throughout the simulation for
        % collecting information.
%         App.Appliances_ConsStr.(AppName)(subapp).(HouseName)(myiter + 1)    = Energyfun ;
        App.Info.(AppName)(subapp).(HouseName).InUse                        = AppInUse;
    end
%--------------------------------------------------------------------------%    
    function [AppSign,CycleTime, Time_Cycle, MinperIter, App] = CreateTime(AppName, All_Var, App, subapp, HouseName, ...
                                                                           myiter, Time_Usage_Prob, Time_Usage, ...
                                                                           Time_Step,Reduce_time, reduce_time, MinperIter)
        % Get the amount of time the cycle lasts.
        switch AppName
            case {'Fridge'}
                Randomapplicance = round(RandBetween(1,2)) ;
            case {'MW','Coffee'}    
                Randomapplicance = round(RandBetween(1,2)) ;
            case  'Tele'
                Randomapplicance = round(RandBetween(1,20)) ;
            case 'Laptop'
                Randomapplicance = round(RandBetween(1,3)) ;
            otherwise
                Randomapplicance = '' ;
        end
        if strcmp('Elec',AppName)
            stop=1;
        end
        % If the appliance is any of these two appliance, then the
        % signature can be taken randomly. if it is one of these appliance,
        % then we re-use always the same signature (a fridge cannot have
        % multiple signature
        if ~any(strcmp(AppName,{'Fridge'}))
            dbAppName = [AppName num2str(Randomapplicance)] ;
        else
            if myiter == 0
                dbAppName             = [AppName num2str(Randomapplicance)] ;
                App.AppSign.(AppName) = dbAppName                           ;
            elseif sum(App.Info.(AppName)(subapp).(HouseName).ActionQtyStep) > 0
                dbAppName = App.AppSign.(AppName)          ;
            else
                dbAppName             = [AppName num2str(Randomapplicance)] ;
                App.AppSign.(AppName) = dbAppName                           ;
            end
        end
        
        AppSign.(AppName).original = All_Var.AppConssignature.(dbAppName) ;
        NonNaNValue = sum(sum(~isnan(AppSign.(AppName).original),2)) ;

        AppSign.(AppName).Sign    = AppSign.(AppName).original(1:NonNaNValue) ;
        AppSign.(AppName).Profile = dbAppName                        ;
        % Get the time of the appliance running time
        Program = find(App.rand_actStr.(AppName)(subapp).(HouseName)(myiter + 1) < Time_Usage_Prob);
        Time_Cycle = Time_Usage(max(1,Program(1) - 1)); % To adapt for the other time step. Now it is in hours
        
        CycleTime  = NonNaNValue / (6 * MinperIter); % Expressed in number of steps as the Time_Cycle is also a defined in hour
        Time_Cycle = Time_Cycle * (60 / MinperIter)  ; % Express Time cycle in terms of steps       
        
        % Reduce the time of the applicance use in case 
                
        if ~(abs(App.timeactiontotStr.(AppName)(subapp).(HouseName)(1)) > 0)
            if ~reduce_time == 1
                Time_Cycle = Time_Cycle * Reduce_time.(HouseName)(1);
            end
        end
    end
%--------------------------------------------------------------------------%    
    function [App_Energy, App] = PowerConsumption(App, AppName, subapp, HouseName, Time_Sim, PowerConsProfile, AppList, ...
                                           nbr_appliance,  Input_Data, Power_Level, All_Var, ShortAppName, SecperIter, App10s, AppClass, AppDB)
                                       
        if App.ActionStart.(AppName)(subapp).(HouseName) <= Time_Sim.TimeStr
            Powerprofile10s = App.OutputSignal10s.(AppName)(subapp).(HouseName) ;
            Powerprofile    = PowerConsProfile.(AppName)(subapp).(HouseName)(1) ;
            
            % re-write the rest of the appliance signature
            if length(PowerConsProfile.(AppName)(subapp).(HouseName)) > 1
                App.PowerConsProfile.(AppName)(subapp).(HouseName) = PowerConsProfile.(AppName)(subapp).(HouseName)(2:end) ;
            else
                % If this is the last step, we can set it
                % up to null and set the appliance to not
                % in use at the end of this condition
                App.PowerConsProfile.(AppName)(subapp).(HouseName)  = '';
                App.Info.(AppName)(subapp).(HouseName).InUse        = false ;
            end
            ApplianceClass = AppList{nbr_appliance,4}   ;
            try
                Classrateined = Input_Data.(ApplianceClass){subapp}    ;
            catch
                Classrateined = 'NoClass' ;
            end
            
            if App.Info.(AppName)(subapp).(HouseName).InUse10s
                if App10s && (App.Info.(AppName)(subapp).(HouseName).StepUse == 1)
                    App_EnergyArray10s                                      = ClassPower(AppClass,Power_Level, Powerprofile10s, Time_Sim, All_Var, HouseName, ShortAppName, AppDB) ;                
%                     StartLine                                               = Time_Sim.myiter * SecperIter + 1  ;
%                     EndLine                                                 = StartLine + length(App_EnergyArray10s) - 1 ;
%                     ReAllocate                                              = App.Info.(AppName)(subapp).(HouseName).App_Energy10s ;
%                     ReAllocate(StartLine:EndLine)                           = App_EnergyArray10s ;
                    try
                        App.Info.(AppName)(subapp).(HouseName).App_Energy10scell{end+1} = App_EnergyArray10s ;
                    catch
                        App.Info.(AppName)(subapp).(HouseName).App_Energy10scell{1} = App_EnergyArray10s ;
                    end
%                     App.Info.(AppName)(subapp).(HouseName).App_Energy10s    = ReAllocate ;
                end
                App.Info.(AppName)(subapp).(HouseName).InUse10s             = false ;
            end
            
            App_Energy = ClassPower(AppClass,Power_Level, Powerprofile, Time_Sim, All_Var, HouseName, ShortAppName, AppDB);
        else
            App_Energy = 0 ;
        end
        %% Function to retrieve the Profile of 10s
        function App_Energy = ClassPower(Classrateined,Power_Level, Powerprofile, Time_Sim, All_Var, HouseName, ShortAppName, AppDB)
            switch Classrateined
                case 'A or B class'
                    App_Energy = Power_Level(1) * Powerprofile ;%* Time_Sim.stepreal ;
                case 'C or D class'
                    App_Energy = Power_Level(2) * Powerprofile ;%* Time_Sim.stepreal ;
                case 'E or F class'
                    App_Energy = Power_Level(3) * Powerprofile ;%* Time_Sim.stepreal ;
                case 'Self-defined'                         % JARI
                    Place = All_Var.GuiInfo.Simulationdata.(HouseName).SelfDefinedAppliances.(ShortAppName).(AppDB).Rate ;
                    App_Energy = Place * Powerprofile ;%* Time_Sim.stepreal ;
                otherwise
                    App_Energy = Power_Level(1)  * Powerprofile ;%* Time_Sim.stepreal ;
            end
        end
    end
end
