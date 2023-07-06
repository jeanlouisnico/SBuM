%% Sandboxed thermal house model
% This is a model for the thermal demand in the house and its temperature
% with several heating and DSM technologies. This is a sandboxed version
% for testing the function and it will later on be added to the original
% version.
%%%
% The inputs for the system are presented here. Variables are loaded to the
% system for the testing's sake. Later on it is expected for them to added
% to the function as inputs from the Launch.m
function [Thermal_Model, Input_Data] = Thermal_House1(Input_Data, Time_Sim, All_Var, Thermal_Model, HouseTitle, BuildSim, SimDetails, App, PowerPV, varargin)

Appliances_consumption  = varargin{1};
Occupancy               = varargin{2};

%%%%%%%%%%%%%%%%%%% Jean Addition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to use the default value in case the simulation stops. This is to
% avoid that the simulation stops in he middle while we are away.
UseDefault = true ;
%%%%%%%%%%%%%%%%%%% Jean Addition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Timeoffset = (Time_Sim.StartDate.(Input_Data.Headers) - datenum(2000,1,1)) * 24; % Weather data starts from January 1st 2000.
Timeoffset      = Time_Sim.Timeoffset;
myiter          = Time_Sim.myiter;
RTP_offset      = (Time_Sim.StartDate.(Input_Data.Headers) - datenum(Time_Sim.YearStartSim2004,1,1)) * 24;    % Real Time pricing starts from the beginning of 2004.

if myiter == 0
    Rounded_Hourly_temp_forecast_random = normrnd(All_Var.Hourly_Temperature,1.5);
    Rounded_Hourly_temp_forecast_random = round(Rounded_Hourly_temp_forecast_random);
    Thermal_Model.Forecast.Weather      = Rounded_Hourly_temp_forecast_random;
else
    Rounded_Hourly_temp_forecast_random = Thermal_Model.Forecast.Weather;       % Consider restricting the creation and assigning to the simulation time
end

% SimDetails                  = 1;
Building_Storage_constant   = str2double(Input_Data.Building_storage_constant);     % Building Storage amount in Wh/m2K

hgt                         = str2double(Input_Data.hgt);
lgts                        = str2double(Input_Data.lgts);
lgte                        = str2double(Input_Data.lgte);
pitch                       = str2double(Input_Data.pitchangle);
aws                         = str2double(Input_Data.aws);
awe                         = str2double(Input_Data.awe);
awn                         = str2double(Input_Data.awn);
aww                         = str2double(Input_Data.aww);
ad                          = str2double(Input_Data.ad);

Ventilation_Type                    = char(Input_Data.Ventil);
    
uvs     = str2double(Input_Data.uvs);
uve     = str2double(Input_Data.uve);
uvn     = str2double(Input_Data.uvn);
uvw     = str2double(Input_Data.uvw);

uvsw    = str2double(Input_Data.uvsw);
uvew    = str2double(Input_Data.uvew);
uvnw    = str2double(Input_Data.uvnw);
uvww    = str2double(Input_Data.uvww);

uvd     = str2double(Input_Data.uvd);

uvf     = str2double(Input_Data.uvf);
uvr     = str2double(Input_Data.uvr);

n50     = str2double(Input_Data.n50);

Heat_recovery_ventil_annual     = str2double(Input_Data.Heat_recovery_ventil_annual); 
gwindow                         = str2double(Input_Data.gwindow);    
house_type                      = 1;
    
%     vent_elec                       = str2double(Input_Data.vent_elec);
    
    if n50 == -1    % Default value
        n50     = 4.0; 
    end
    
    if Heat_recovery_ventil_annual == -1 % Default value
        Heat_recovery_ventil_annual = 0.0;
    end
    
    if gwindow <= 0         % Default value
        gwindow = 0.6;      % From perustelumuistio
    end
    
    vent_elec = Input_Data.vent_elec;
    
    % TEST IF THE INPUT VALUES ARE VALID. E.G. DOES MECHANICAL VENTILATION
    % HAVE HEAT RECOVERY!
    
    switch(Ventilation_Type)  
        case{'Mechanical ventilation','Natural ventilation'}
            % Heat losses through ventilation are calculated according to
            % the National Building Code of Finland D5. The equation is 
            % Q = cp * roo * flow rate * Vhouse * deltaT.
            if Heat_recovery_ventil_annual > 0 && myiter == 0  
                warning('Adjust the ventilation! Mechanical and natural ventilations cannot have heat recovery!')             
                if UseDefault == true
                    Input_Data.Ventil                   = 'Air-Air H-EX';
                    Ventilation_Type                    = char(Input_Data.Ventil);
                    T_inlet                             = str2double(Input_Data.T_inlet);
                else
                    Mod = questdlg({'Adjust the ventilation! Mechnanical and natural ventilations cannot have heat recovery!', 'Please select either Air-Air H-EX, no heat recovery', 'or terminate the simulation'}, ...
                                'Warning on unsuitable heat recovery', 'Air-Air H-EX', 'No heat recovery', 'Terminate', 'Air-Air H-EX');       
                    switch Mod
                        case 'Air-Air H-EX'
                            Input_Data.Ventil = 'Air-Air H-EX';
                            Ventilation_Type                    = char(Input_Data.Ventil);
                            T_inlet                             = str2double(Input_Data.T_inlet);
                        case 'No heat recovery'
                            Input_Data.Heat_recovery_ventil_annual = '0';
                            Heat_recovery_ventil_annual     = str2double(Input_Data.Heat_recovery_ventil_annual);
                        otherwise
%                                 delete(gui.runWindow)
                            Input_Data.Terminate = true;
                        return;
%                                 error('The execution was terminated!')
                    end
                end
            end
    end

    if iscell(vent_elec)
        switch Ventilation_Type
            case 'Natural ventilation'
                vent_elec = 0;          % This is always 0.           
            case 'Mechanical ventilation'
                if vent_elec == -1
                    vent_elec = 1.0;    % Use default value
                else
                    vent_elec = vent_elec{2};
                end
            case 'Air-Air H-EX'
                if vent_elec == -1 
                    vent_elec = 2.0;    % Use default value
                else
                    vent_elec = vent_elec{3};
                end
        end 
    else
        vent_elec = str2double(Input_Data.vent_elec);    
        switch Ventilation_Type
            case 'Natural ventilation'
                vent_elec = 0;          % This is always 0.
            case 'Mechanical ventilation'
                if vent_elec == -1
                    vent_elec = 1.0;    % Use default value
                end
            case 'Air-Air H-EX'
                if vent_elec == -1 
                    vent_elec = 2.0;    % Use default value
                end
        end 
    end
%     house_type = 6;     % Required for the simulation to go through!
    
% end

N0                                  = str2double(Input_Data.N0);
Inhabitants                         = str2double(Input_Data.inhabitants);

Nbr_batteries                       = str2double(Input_Data.NbrBatteries);
prcntage                            = str2double(Input_Data.prcntage);

Heating_Tech                        = char(Input_Data.Heating_Tech);
Charging_strategy                   = char(Input_Data.Charging_strategy);
% Charging_Time                       = char(Input_Data.Charging_Time);

if strcmp(Heating_Tech,'Time Set Temp') == 1     % For time set temperature scenario the temperature set from the input is the higher temperature set and the other is 2 degrees less.
    Temp_Set                        = [str2double(Input_Data.Temp_Set) str2double(Input_Data.Temp_Set)-2];
else
    Temp_Set                        = str2double(Input_Data.Temp_Set);
end

Temp_Set_Heating_Upper_Limit        = 25;       % Add as a variable later on!
Temp_cooling                        = str2double(Input_Data.Temp_cooling);

if Temp_cooling == -1       % Consired exception and assign it to default value.
    Temp_cooling = 27;
end

% Heating_Tech                        = 'Constant';
% Charging_strategy                   = 'PV charging'; % Only needed if heating technology is underfloor heating.

PV_usage                            = str2double(Input_Data.PhotoVol);

if strcmp(Heating_Tech,'PV battery') == 1 || strcmp(Heating_Tech, 'Battery from grid') == 1
    Battery_Usage = 1;
else
    Battery_Usage = 0;
    Battery_PV_CO2_emissions = 0;
end

timehour                            = Time_Sim.timehour;
% myiter                              = Time_Sim.myiter;

%%% JEAN
% currenthouryear must consider the timehour and the time resolution of the
% model. Therefore, currenthouryear has been recalculated to match this.

% currenthouryear = floor((datenum(Time_Sim.timeyear,Time_Sim.timemonth,Time_Sim.timeday,Time_Sim.timehour,Time_Sim.timeminute,Time_Sim.timesecond)-datenum(Time_Sim.timeyear,1,1,0,0,0))*24) + 1;

currenthouryear = floor((datenum(Time_Sim.TimeStr)-datenum(Time_Sim.timeyear,1,1,0,0,0))*24) + 1;

% if myiter == 0 && Time_Sim.timeday == 1 && Time_Sim.timemonth == 1
%     currenthouryear                     = 1;
%     Thermal_Model.currenthouryear       = currenthouryear;
% elseif myiter == 0 && Time_Sim.timeday ~= 1 && Time_Sim.timemonth ~= 1
%     currenthouryear                     = daysact(datenum(Time_Sim.YearStartSim,1,1),Time_Sim.StartDate.(Input_Data.Headers)) * 24;    % The simulation is assumed to start at midnight all the time. If timestep something else than an hour consider changing this
%     Thermal_Model.currenthouryear       = currenthouryear;
% elseif Time_Sim.timeday == 31 && Time_Sim.timemonth == 12 && Time_Sim.timehour == 23 && Time_Sim.myiter+1 ~= Time_Sim.nbrstep.(Input_Data.Headers)
%     currenthouryear                     = 1;            % Attach to one for allowing calculation for the next year
% elseif Time_Sim.timeday == 1 && Time_Sim.timemonth == 1 && Time_Sim.timehour == 0 && (Time_Sim.myiter + 1) ~= Time_Sim.nbrstep.(Input_Data.Headers)
%     currenthouryear                     = 1;            % Start the calculation again
%     Thermal_Model.currenthouryear       = currenthouryear;
% elseif BuildSim == 1                    % Current hour stays the same for all the buildings and only changes with the first building
%     currenthouryear                     = Thermal_Model.currenthouryear + 1;
%     Thermal_Model.currenthouryear       = currenthouryear;
% end

RTP                                 = All_Var.Hourly_Real_Time_Pricing;
RTP_forecast                        = RTP;  %RTP forecast is assumed to be the next 24 hours % All_Var.Hourly_Real_Time_Price_Forecasting;

%%% JEAN COMMENTS %%%
% Consider using the EnergyOutput.Price_Foreca for the RTP_forecast it is
% recalculated automatically for the next day. The update time can be set
% up.

% Distribution_Cost                   = 0.028387; % Oulun Energia siirto ja jakelu, VAT is deducted from the price. Fixed contract. No annual price is added as it will be paid anyway. Price is in €/kWh.     % Add the distribution cost here. If ToU tariff is wanted, add a vector for the whole simulation time.
% Elec_Tax                            = 0.0279;   % Add the electricity taxes as €/kWh.
% VAT                                 = 1.24;     % VAT for electricity and distribution is nowadays 24%, thus multiplying by 1.24
% Generation_distribution             = 0.0007;   % Distribution cost for the generated electricity which is sold to the grid. €/kWh

Time_Step                           = Input_Data.Time_Step;
% StartDate                           = datetime([Input_Data{7}],[Input_Data{6}],[Input_Data{5}]);
% EndDate                             = datetime([Input_Data{10}],[Input_Data{9}],[Input_Data{8}]);
% Simulation_Time                     = datetime(StartDate): hours(1): datetime(EndDate);
% Simulation_Time                     = Simulation_Time(1:end-1);

% DataSetStartTime                    = datetime(2000,1,1,0,0,0);
% Offset                              = hours(Simulation_Time(1) - DataSetStartTime);         % This is used to define the offset of the time from the beginning of the dataset. It matches hourly values.

% PowerPV = EnergyOutput.PVPower.(Input_Data.Headers)(Time_Sim.myiter+1);

if myiter == 0
    F_permeability                      = 0;    % Used as an input, will be changed according to the simulation rules.
else
    F_permeability                      = Thermal_Model.Heat_Demand.F_permeability;
end

BatteryCapacity                     = str2double(Input_Data.BatteryCapacity);

PV_Price                            = str2double(Input_Data.PVprice)/(str2double(Input_Data.MaxPowerPV)/1000) * str2double(Input_Data.NbrmodTot); %1350/(str2double(Input_Data.MaxPowerPV)/1000) * str2double(Input_Data.NbrmodTot);       % PV price per kWh. division due to max power in Wh.
Battery_Price                       = str2double(Input_Data.BatteryPrice) * BatteryCapacity * Nbr_batteries; % 725 * 13.5 * Nbr_batteries;      % Add the Battery Price to this
Profit_battery                      = str2double(Input_Data.ProfitBattery);

Number_of_battery_cycles            = 6000;         % Define the number of the battery charge/discharge cycles. This is needed in the economic calculations.
Min_discharge_cycle                 = Nbr_batteries * BatteryCapacity * (0.8 - 0.3); % Calculate the minimum electricity amount discharged from the battery on every cycle. 13500 is the battery capacity.
Round_trip_efficiency               = str2double(Input_Data.RoundTripEfficiency);          % Round trip efficiency of the battery system. Is taken from the TESLA POWERWALL 2.
% Nbr_of_cycles                       = 0;            % Default value, will change if battery in use

% switch Simulation_Scenario
%     
%     case '2050'
%         
%         PV_CO2                              = 833 * 0.2 * Input_Data{27};
%         
%     case 'Today'
%         
        PV_CO2                              = str2double(Input_Data.PVEmissions) * (str2double(Input_Data.MaxPowerPV)/1000) * str2double(Input_Data.NbrmodTot); %1850 * 0.2 * Input_Data{27};            % CO2 emissions from the PV production (LCA). This value is by kgCO2eq./kWp. This is later trasferred to gCO2eq./kWh. Value is an estimation from (Laleman et al. 2011), and one panel is considered to be 200Wp, which is multiplied by the number of panels.
%         
% end

Battery_CO2                         = (str2double(Input_Data.BatteryEmissions) * BatteryCapacity * Nbr_batteries)/1000; % (18.3 * 14 * Nbr_batteries)/1000;            % CO2 emissions from the battery related electricity (LCA) in g of CO2 eq. per cycle (one battery has capacity of 14 kWh (Tesla 2018), average cycle life of 6000 with 80% Depth of Discharge and has 110 kg of CO2 eq. emissions per kWh of storage capacity) (Peters et al. 2017; Rydh and Sandén 2005)

% CHECK THE VALUE OF THE CO2 EMISSIONS ARE THEY IN kg OR g ????????????????????????????

Space_Heating_Efficiency            = 0.95;        % From Ministry of the Environment
Underfloor_heating_efficiency       = 0.85;         % From National building code D5

nPeriods                            = 24;

switch Input_Data.ComfortLimit
    case 'High' 
        ComfortLimit                = 0.2;
    case 'Medium' 
        ComfortLimit                = 0.5;
    case 'Low' 
        ComfortLimit                = 0.7;
end

SimulationTimeFrame                 = Input_Data.SimulationTimeFrame;

% LowerTempLimit                      = 21;
% UpperTempLimit                      = 25;
if myiter == 0
    LowerTempLimit1                             = Temp_Set;   % Use the default values for the optimal heating scheme which will then adjust itself
    UpperTempLimit1                             = Temp_cooling;   % Use the default values.
    Thermal_Model.Temperature.LowerTempLimit    = LowerTempLimit1;
    Thermal_Model.Temperature.UpperTempLimit    = UpperTempLimit1;
else
    LowerTempLimit1                             = Thermal_Model.Temperature.LowerTempLimit;
    UpperTempLimit1                             = Thermal_Model.Temperature.UpperTempLimit;
end
% Temp_Set                            = 21;               % Assign this as in input value to the GUI

BiggerHeaterNeedCalc                = 0;

% if Charging_Time <= 0    % Assigns default value
    
Charging_Time                        = str2double(Input_Data.ChargingHours);        % Heating hour amount for storage heaters
    
% end

% if Heat_recovery_ventil_annual == 0
% 
%     Ventil_type                         = 0;        % Ventilation type. 0 for natural and exhaust ventilations, 1 for mechanical ventilation
%     
% else
%     
%     Ventil_type = 1;
%     
% end
% 
% if Ventil_type == 0
%     Ventil_type1 = 1;       % Ventilation type. 0 for natural ventilation, 1 for exhaust ventilation. Used to determine the electricity consumption.
% elseif Ventil_type == 1
%     Ventil_type1 = 2;
% end

% All_Var.Hourly_Solar_Radiation = Solar_Radiation;
% All_Var.Hourly_Temperature = Temperature;
% All_Var.DebugMode = 0;
% All_Var.Hourly_Real_Time_Pricing = RTP;
% Solar_radiation = Solar_Radiation;

Temp_outlet1 = 5;    % Maximum outlet temperature from the heat recovery to prevent frost

DatabaseRes  = 'Hourly' ;
switch DatabaseRes
    case 'Hourly'
        Timeoffset = round(Timeoffset * Time_Sim.stepreal) ;
    case '15 minutes'
        Timeoffset = Timeoffset * (Time_Sim.stepreal / 4) ;
    otherwise

end

Temperature     = All_Var.Hourly_Temperature(myiter + 1) ;
Solar_radiation = All_Var.Hourly_Solar_Radiation(myiter + 1) ;

%     switch(Time_Step)
%         case 'Hourly'
%             Temperature = All_Var.Hourly_Temperature(Timeoffset+ floor(myiter * Time_Sim.stepreal) +1);
%             Solar_radiation = All_Var.Hourly_Solar_Radiation(Timeoffset+ floor(myiter * Time_Sim.stepreal) +1); % TRY2050A1B;
% %             Temperature = [Temperature(1:1391) Temperature(1392:1416) Temperature(1392:8760)];
%         case 'test_Half_Hourly'
%             Temperature = All_Var.Half_Hourly_Temperature';
%         otherwise
%             Temperature = All_Var.Hourly_Temperature(Timeoffset+ floor(myiter * Time_Sim.stepreal) +1);
%             Solar_radiation = All_Var.Hourly_Solar_Radiation(Timeoffset+ floor(myiter * Time_Sim.stepreal) +1); % TRY2050A1B;
%     end

%     Temperature = Temperature(OffSet_weather+myiter+1);
%     Solar_radiation = Solar_radiation(OffSet_weather+myiter+1);
    
    if myiter == 0 && strcmp(Heating_Tech,'Time Set Temp') == 1
        Temp_inside = Temp_Set(1);
        
        if strcmp(Ventilation_Type, 'Air-Air H-EX')
            T_inlet     = str2double(Input_Data.T_inlet);
        else
            T_inlet     = Temperature;
        end
        
    elseif myiter == 0
        Temp_inside = Temp_Set;
        
        if strcmp(Ventilation_Type, 'Air-Air H-EX')
            T_inlet     = str2double(Input_Data.T_inlet);
        else
            T_inlet     = Temperature;
        end
        
    else
        Temp_inside = Thermal_Model.Temperature.IndoorTemperature(myiter);

        if strcmp(Ventilation_Type, 'Air-Air H-EX')
            T_inlet     = str2double(Input_Data.T_inlet);
        else
            T_inlet     = Temperature;
        end
        
    end
    
dbstop if error
%% Thermal losses
%%% Walls
% For calculating the losses through the walls, a general formula is used
% Eq.... The entrance door is placed on the south wall, consequently, the
% door surface is set to 0 for the other surfaces.
%%%
% $$Q_{wall}=UV_{surf}((h\cdot L_{surf})-A_{door}-A_{window-surf})$$
%%%
% Where QSurf is the heat loss through the wall [W/K], UV_{surf} is the
% U-Value of the studied surface [W/m2.K-1], h is the height of the wall
% [m], Lsurf is the lenght of the wall [m], Adoor is the surface area of
% the door [m2], Awindow-surf is total the surface area of windows on the
% studied surface [m2]. The extra areas in east and west walls from the
% declination of the roof need to be added to the values.

Wall_Loss = @(Length, height, door, window, UVwall) UVwall.*((height.*Length)-door-window); 

Specific_Loss_North = Wall_Loss(lgts, hgt, 0, awn, uvn);
Specific_Loss_South = Wall_Loss(lgts, hgt, ad, aws, uvs);
Specific_Loss_West  = Wall_Loss(lgte, hgt, 0, aww, uvw) + uvw * (0.5 * tand(pitch) * lgte^2);
Specific_Loss_East  = Wall_Loss(lgte, hgt, 0, awe, uve) + uvw * (0.5 * tand(pitch) * lgte^2);

%%% Windows and door
% The calculation of the heat loss through the window is pretty straight 
% forward as it is the product of the total surface area of the window on a
% particular surface times the U-Value of the windows. It is assumed that
% the U-Value for a given surface is similar to all windows.
%%%
% $$Q_{surface}=UV_{window}\, \cdot \, A_{window}$$
%%%
% Where Qwindow is the heat loss through the window [W/K], UVwindow is the
% U-Value of the windoes on the studied surface [W/m2.K-1], and Awindow is
% the total surface area of window on w given surface [m2].

Surface_Loss = @(UV, A) UV.*A;

Loss_Wind_South = Surface_Loss(uvsw, aws);
Loss_Wind_North = Surface_Loss(uvnw, awn);
Loss_Wind_West  = Surface_Loss(uvww, aww);
Loss_Wind_East  = Surface_Loss(uvew, awe);
Loss_Door       = Surface_Loss(uvd, ad)  ;

%%% Losses through the floor and roof
% As the floor area is not given as an input, it has to be calculated from
% the lenghts of the walls on the different surface. Afterwards, the heat
% loss through the floor is calculated using Eq...
% . The heat loss through the roof is calculated also with Eq... but the
% surface area of the roof needs to be evaluated first using Eq...
%%%
% $$A_{roof}=\frac{L_{East} \cdot L_{South}}{cos\left (\frac{2\pi \beta
% }{360}  \right )}$$
%%%
% Where Aroof is the roof surface are [m2], Least is the lenght of the
% Eastern wall [m], Lsouth is the lenght of the Southern wall [m], and beta is
% the pitch angle of the roof [o].

A_Roof      = ((lgte * lgts)/cos(pitch * 2 * pi() / 360))   ;
Loss_floor  = (lgte * lgts) * uvf                           ;
Loss_roof   = Surface_Loss(uvr, A_Roof)                     ;
A_floor     = lgte * lgts                                   ;

%%% Ground temperature 
% The calculation for the monthly temperature of the ground is presented in
% the Building Code of Conduct Finland D5. As the annual monthly
% variation for the ground temperature is 6 degrees, is does not seem
% necessary to calculate the temperature more precisely. The annual average
% ground temperature can be calculated by considering the differences
% between the outdoor annual temperature and adding 5 degrees to it. Then
% the monthly values are calculated by using values from the Ministry of
% the Environment's guide on the monthly variations. This is then
% designated as the heat transfer temperature through the floor.

% Calculate the average temperature for the on-going year for the ground
% temperature calculation

if myiter == 0 || Time_Sim.timeyear > Thermal_Model.RecalcYear
    Sartingyear = datetime(datenum(Time_Sim.timeyear,1,1),'ConvertFrom','datenum')         ;
    Endingyear  = datetime(datenum(Time_Sim.timeyear + 1,1,1),'ConvertFrom','datenum')       ;

    timeRange                            = timerange(Sartingyear,Endingyear)               ;
    All_Var.Hourly_TemperatureTimedTable = table2timetable(All_Var.Hourly_TemperatureOrigTimed);
    Thermal_Model.RecalcYear             = Time_Sim.timeyear        ;   
    Thermal_Model.T_mean_outside         = mean(All_Var.Hourly_TemperatureTimedTable.Temperature(timeRange,:))         ;
end

T_mean_outside = Thermal_Model.T_mean_outside ;

%%% !!!!!! This should be done only once per year and not at every
%%% iteration !!!! %%%%%%%

% if leapyear(Time_Sim.timeyear) == 1
%     T_mean_outside = mean(All_Var.Hourly_Temperature(((datenum(Time_Sim.timeyear,1,1)-datenum(Time_Sim.YearStartSim,1,1))*24+1):((datenum(Time_Sim.timeyear,1,1)-datenum(Time_Sim.YearStartSim,1,1))*24+1+8784-1)));
% else
%     T_mean_outside = mean(All_Var.Hourly_Temperature(((datenum(Time_Sim.timeyear,1,1)-datenum(Time_Sim.YearStartSim,1,1))*24+1):((datenum(Time_Sim.timeyear,1,1)-datenum(Time_Sim.YearStartSim,1,1))*24+1+8760-1)));
% end

% T_mean_outside                  = 2.7; % Check the locations mean outside temperature
T_monthly_variations            = [0 -1 -2 -3 -3 -2 0 1 2 3 3 2];
T_ground_monthly                = (T_mean_outside + 5) + T_monthly_variations;
% [~,Simulation_month,~,~,~,~]    = datevec(Simulation_Time);
if leapyear(Time_Sim.timeyear) == 1
    T_ground_hourly1                 = [repelem(T_ground_monthly(1),744) repelem(T_ground_monthly(2),696) repelem(T_ground_monthly(3),744) repelem(T_ground_monthly(4),720) repelem(T_ground_monthly(5),744) repelem(T_ground_monthly(6),720) repelem(T_ground_monthly(7),744) repelem(T_ground_monthly(8),744) repelem(T_ground_monthly(9),720) repelem(T_ground_monthly(10),744) repelem(T_ground_monthly(11),720) repelem(T_ground_monthly(12),744)];
else
    T_ground_hourly1                 = [repelem(T_ground_monthly(1),744) repelem(T_ground_monthly(2),672) repelem(T_ground_monthly(3),744) repelem(T_ground_monthly(4),720) repelem(T_ground_monthly(5),744) repelem(T_ground_monthly(6),720) repelem(T_ground_monthly(7),744) repelem(T_ground_monthly(8),744) repelem(T_ground_monthly(9),720) repelem(T_ground_monthly(10),744) repelem(T_ground_monthly(11),720) repelem(T_ground_monthly(12),744)];
end
T_ground_hourly = T_ground_hourly1(currenthouryear);

%%% Ventilation losses
% The heat loss through natural ventilation consider the number of air
% change per hour. Thus, the general formula is given in Eq.
%%%
% $$Q_{Ventil} = N_{0} V_{House} \rho_{air} \frac{C_{p-air}}{3.6}$$
%%%
% Where Qventil is the heat loss through natural ventilation [W/K], Vhouse
% is the total volume of the house and is evaluated from Eq... [m3], Rhoair
% is the air density [kg/m3], and Cpair is the heat capacity of air
% [kJ/kg.K-1] usually taken at 1.007.
%%%
% $$V_{house}=h\cdot L_{South}L_{East} + \left ( tan\left ( \frac{2\pi
% \beta}{360} \right )\cdot \left ( \frac{L_{East}}{2} \right )^2 \cdot
% L_{South} \right )$$

House_Volume = hgt*lgts*lgte + (tan(pitch * 2 * pi() / 360) * (lgte/2)^2 * lgts);


%%% Air-leakage through the building envelope
% The thermal insulation leaks a bit of air through its structure and the
% amount of air can be calculated by using equation 
% q(v,air) = (q(50)/3600*x)*A(building envelope)
%
% If q50 is unknown but n50 is known the calculation is
% q50 = (n50/A(building envelope)) * Volume(house)
%
% The heat loss on the other hand can be calculated by
% Q(airleak) = density * heat capacity * q(v,airleak) * (T(i) - T(e))
%
% Building envelope means the total surface area of the building envelope
% (as the building is symmetrical the north and south areas are the same as
% well as the east and west
% x_building is a factor which depends on the floor amount and height
% q50 is air-leak value which can be measured in (m3/(h m2))
% Calculating the air-leak amount

Building_Envelope = 2 * lgts * hgt + 2 * lgte * hgt + lgts * lgte + 2 * 0.5 * tand(pitch) * lgte^2 + A_Roof;

% if house_type == 6
%     q50 = n50;
% else
    q50 = (n50/Building_Envelope) * House_Volume;
% end

x_building  = 35;           % For one-storey house. NUMBER OF STORES SHOULD BE ADDED IN THE FUTURE AS INPUT.
Air_leak    = 1.2 * 1007 * ((q50 / (3600 * x_building)) * Building_Envelope);

%%% Heat load
% The total heat load of the house is calculated as the summ of the
% different heat loss on surfaces, walls and ventilation.
%%%
% $$Q_{total} = \sum Q_{wall} + \sum Q_{surface} + Q_{Ventil} + Q_{Air-leak}$$
%%%
% Where Qtotal is the total heat loss [W/K]. The total loss does not
% include Loss_Ventil if the ventilation heating is considered, but needs
% to include it if the Loss_Ventil is done without considering the
% ventilation heating. The Loss_floor is not included either as the
% temperature difference in calculations is not the same.

Total_Loss = Specific_Loss_East + Specific_Loss_North + Specific_Loss_South + Specific_Loss_West + Loss_Wind_East + Loss_Wind_North + Loss_Wind_South + Loss_Wind_West + Loss_Door  + Loss_roof  + Air_leak;

%%%
% Take a test by including the building storage capacity to the system in
% kJ/m2. Building Storage values can be found from Building Code of Conduct

Building_Storage    = Building_Storage_constant * 3.6 * lgts * lgte;
Total_Heat_capacity = (Building_Storage + (1.2 * House_Volume * 1.007 * N0))/3.6;

% Next the thermal time constant is calculated by basing it to a very rough
% estimation for the heat losses on a normal case.

Thermal_time_constant = (Total_Heat_capacity) / (Total_Loss + Loss_floor + ((1.2 * 1.007 * N0 * House_Volume)/3.6));

%% Internal heat gains
% The internal heat gains include heat from appliances, people and from
% solar radiation. The heat gain from appliances is estimated to be the
% same as their electricity consumption except for dishwasher and washing
% machine for which the heat gains are 25 % from the over-all electricity
% consumption. The heat gain from people is 85 W per person and is in use
% when there are people occupant. Solar radiation heat gain is calculated
% by using Sol_rad_windows.m function.
%%% Appliances heat gains
% Appliances consumptions are in kWh hence the multiplying


%%% Heat gain from people
% First it is needed to determine if there are people inside the dwelling.
% This can be assumed so that there are people in the dwelling from 0-8 and
% from 22-24. The other times the occupancy is estimated based on the 
% occupancy variable. Next the task of the occupant is estimated by the
% appliance usage and the heat gain is then finally estimated from it based
% on the metabolic rate.
%%%
% People activities based on met. The calculation is Q = met(action) *
% A(person). A(person) is 1.80 m2 by default. Activities are sleeping (0.8),
% Seating (1.0), Domestic work (2.0) and sedentary activity (1.2). One met
% is considered to be 58 W/m2.


[People_Heat_Gain, Met_rate, Internal_Heat_Gain_Appl, tenancy, Flow_rate, T_inlet] = Occupancy_detection_thermal(HouseTitle, Input_Data, All_Var, timehour, Appliances_consumption, Occupancy, SimDetails, Ventilation_Type, T_inlet, myiter, Temp_inside, Temperature,App, Temp_cooling);


%% The simulation for heating
% Work to do: 
% Temperature setting in the building
% --> look the possibility to couple the set temperature with the occupancy
% Loop the room temperature with the activity in the home, depending on how
% many people are living the house
% Let's consider the temperature set as the building's temperature in the
% first calculations


Temperature_to_heat_exchanger = Temperature;

LowerPriceLimit     = 0;    % Needs value for the simulation. If needed defined again in the loop
UpperPriceLimit     = 0;    % Needs value for the simulation. If needed defined again in the loop

% Define nodal temperatures for the simulation. Assign inside surfaces to
% set temperature and outside surfaces to outdoor temperature. Nodal
% temperatures inbetween are just interpolated from the two. Consider
% making a prerun in the future to adjust the values. Definitions are in
% InsideTemperature function and ISO 52016-1:2017. This is assumed to give
% high enough estimation of the starting conditions.

if myiter == 0          % In the beginning the nodal temperatures are calculated
    
    Temperatures_nodal(1)     = Temperature(1);                                         % Outside surface of walls
    Temperatures_nodal(5)     = Temp_Set(1);                                            % Inside surface of walls
    Temperatures_nodal(3)     = (Temperatures_nodal(1) + Temperatures_nodal(5))/2;      % Mean temperature change in construction surface
    Temperatures_nodal(4)     = (Temperatures_nodal(3) + Temperatures_nodal(5))/2;      % Mean between outside and middle
    Temperatures_nodal(2)     = (Temperatures_nodal(1) + Temperatures_nodal(3))/2;      % Mean between inside and middle
    Temperatures_nodal(6)     = T_ground_hourly;                                        % Virtual ground temperature is equal to ground temperature
    Temperatures_nodal(10)    = Temp_Set(1);                                            % Inside surface equal to inside temperature
    Temperatures_nodal(8)     = (Temperatures_nodal(6) + Temperatures_nodal(10))/2;     % Mean temperature change in construction surface
    Temperatures_nodal(7)     = (Temperatures_nodal(6) + Temperatures_nodal(8))/2;      % Mean between ground and middle
    Temperatures_nodal(9)     = (Temperatures_nodal(10) + Temperatures_nodal(8))/2;     % Mean between inside and middle
    Temperatures_nodal(11)    = Temperature(1);                                         % Outside surface of roof
    Temperatures_nodal(15)    = Temp_Set(1);                                            % Inside surface of roof
    Temperatures_nodal(13)    = (Temperatures_nodal(11) + Temperatures_nodal(15))/2;    % Mean temperature change in construction surface
    Temperatures_nodal(14)    = (Temperatures_nodal(13) + Temperatures_nodal(15))/2;    % Mean between outside and middle
    Temperatures_nodal(12)    = (Temperatures_nodal(11) + Temperatures_nodal(13))/2;    % Mean between inside and middle
    Temperatures_nodal(16)    = Temperature(1);                                         % Outside surface of window
    Temperatures_nodal(17)    = Temp_Set(1);                                            % Inside surface of window
    Temperatures_nodal(18)    = Temperature(1);                                         % Outside surface of door
    Temperatures_nodal(19)    = Temp_Set(1);                                            % Inside surface of door
    Temperatures_nodal(20)    = Temp_Set(1);                                            % Air Temperature
    
    T_design_outside        = -32;   % input the outside design temperature
    T_design_ground         = 5.2;
    T_desing_inside         = 21; 
    
    Temperatures_nodal0(1)     = T_design_outside;                                         % Outside surface of walls
    Temperatures_nodal0(5)     = T_desing_inside;                                            % Inside surface of walls
    Temperatures_nodal0(3)     = (Temperatures_nodal0(1) + Temperatures_nodal0(5))/2;      % Mean temperature change in construction surface
    Temperatures_nodal0(4)     = (Temperatures_nodal0(3) + Temperatures_nodal0(5))/2;      % Mean between outside and middle
    Temperatures_nodal0(2)     = (Temperatures_nodal0(1) + Temperatures_nodal0(3))/2;      % Mean between inside and middle
    Temperatures_nodal0(6)     = T_design_ground;                                        % Virtual ground temperature is equal to ground temperature
    Temperatures_nodal0(10)    = T_desing_inside;                                            % Inside surface equal to inside temperature
    Temperatures_nodal0(8)     = (Temperatures_nodal0(6) + Temperatures_nodal0(10))/2;     % Mean temperature change in construction surface
    Temperatures_nodal0(7)     = (Temperatures_nodal0(6) + Temperatures_nodal0(8))/2;      % Mean between ground and middle
    Temperatures_nodal0(9)     = (Temperatures_nodal0(10) + Temperatures_nodal0(8))/2;     % Mean between inside and middle
    Temperatures_nodal0(11)    = T_design_outside;                                         % Outside surface of roof
    Temperatures_nodal0(15)    = T_desing_inside;                                            % Inside surface of roof
    Temperatures_nodal0(13)    = (Temperatures_nodal0(11) + Temperatures_nodal0(15))/2;    % Mean temperature change in construction surface
    Temperatures_nodal0(14)    = (Temperatures_nodal0(13) + Temperatures_nodal0(15))/2;    % Mean between outside and middle
    Temperatures_nodal0(12)    = (Temperatures_nodal0(11) + Temperatures_nodal0(13))/2;    % Mean between inside and middle
    Temperatures_nodal0(16)    = T_design_outside;                                         % Outside surface of window
    Temperatures_nodal0(17)    = T_desing_inside;                                            % Inside surface of window
    Temperatures_nodal0(18)    = T_design_outside;                                         % Outside surface of door
    Temperatures_nodal0(19)    = T_desing_inside;                                            % Inside surface of door
    Temperatures_nodal0(20)    = T_desing_inside;                                            % Air Temperature
    
    
%     Temperatures_nodal0       = Temperatures_nodal;                                     % To be used in the design heating power calculations
    Thermal_Model.Temperature.Nodal_Temperatures_Original   = Temperatures_nodal0;
    
else                    % After the first one, the previous values are assigned as nodal temperatures
    
    Temperatures_nodal(1)     = Thermal_Model.Temperature.Nodal_Temperatures(1,myiter);     % Outside surface of walls
    Temperatures_nodal(5)     = Thermal_Model.Temperature.Nodal_Temperatures(5,myiter);     % Inside surface of walls
    Temperatures_nodal(3)     = Thermal_Model.Temperature.Nodal_Temperatures(3,myiter);     % Mean temperature change in construction surface
    Temperatures_nodal(4)     = Thermal_Model.Temperature.Nodal_Temperatures(4,myiter);     % Mean between outside and middle
    Temperatures_nodal(2)     = Thermal_Model.Temperature.Nodal_Temperatures(2,myiter);     % Mean between inside and middle
    Temperatures_nodal(6)     = T_ground_hourly;                                            % Virtual ground temperature is equal to ground temperature
    Temperatures_nodal(10)    = Thermal_Model.Temperature.Nodal_Temperatures(10,myiter);    % Inside surface equal to inside temperature
    Temperatures_nodal(8)     = Thermal_Model.Temperature.Nodal_Temperatures(8,myiter);     % Mean temperature change in construction surface
    Temperatures_nodal(7)     = Thermal_Model.Temperature.Nodal_Temperatures(7,myiter);     % Mean between ground and middle
    Temperatures_nodal(9)     = Thermal_Model.Temperature.Nodal_Temperatures(9,myiter);     % Mean between inside and middle
    Temperatures_nodal(11)    = Thermal_Model.Temperature.Nodal_Temperatures(11,myiter);    % Outside surface of roof
    Temperatures_nodal(15)    = Thermal_Model.Temperature.Nodal_Temperatures(15,myiter);    % Inside surface of roof
    Temperatures_nodal(13)    = Thermal_Model.Temperature.Nodal_Temperatures(13,myiter);    % Mean temperature change in construction surface
    Temperatures_nodal(14)    = Thermal_Model.Temperature.Nodal_Temperatures(14,myiter);    % Mean between outside and middle
    Temperatures_nodal(12)    = Thermal_Model.Temperature.Nodal_Temperatures(12,myiter);    % Mean between inside and middle
    Temperatures_nodal(16)    = Thermal_Model.Temperature.Nodal_Temperatures(16,myiter);    % Outside surface of window
    Temperatures_nodal(17)    = Thermal_Model.Temperature.Nodal_Temperatures(17,myiter);    % Inside surface of window
    Temperatures_nodal(18)    = Thermal_Model.Temperature.Nodal_Temperatures(18,myiter);    % Outside surface of door
    Temperatures_nodal(19)    = Thermal_Model.Temperature.Nodal_Temperatures(19,myiter);    % Inside surface of door
    Temperatures_nodal(20)    = Thermal_Model.Temperature.Nodal_Temperatures(20,myiter); 
    
    Temperatures_nodal0       = Thermal_Model.Temperature.Nodal_Temperatures_Original;          % The starting temperatures to be used in the design temperature calculation
end

%%%
% Calling the global radiation function to define the solar heat gain

if myiter == 0 || (Time_Sim.timeday == 1 && Time_Sim.timemonth == 1 && Time_Sim.timehour == 0)       % PV generation estimation for the year. Start either at the beginning of the simulation and for all the new years!
    
    [Global_Irradiance_North, Global_Irradiance_East, Global_Irradiance_South, Global_Irradiance_West] = verticalrad1(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails);
    
    [PV_production_estimation, GINARRAY, GIEARRAY, GISARRAY, GIWARRAY] = PV_production_estimation_function(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails);
    Thermal_Model.Forecast.PV_production_estimation = PV_production_estimation;
%     
%     % Consider including solar radiation data from TRY2012, since there is
%     % currently no way to forecast the solar radiation
%     
else
    [Global_Irradiance_North, Global_Irradiance_East, Global_Irradiance_South, Global_Irradiance_West] = verticalrad1(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails);
    PV_production_estimation = Thermal_Model.Forecast.PV_production_estimation;
end

% Consider the possibility of a leap year
if myiter == 0 || (Time_Sim.timeday == 1 && Time_Sim.timemonth == 1 && Time_Sim.timehour == 0) 
    if PV_usage == 0
        PV_production_estimation = 0;
    else
        if leapyear(Time_Sim.timeyear) == 1
            PV_production_estimation = [PV_production_estimation(1:1416)' PV_production_estimation(1393:1416)' PV_production_estimation(1416:end)'];
        end
    end
end

% Consider daily production estimation from PV 

if myiter == 0 || (Time_Sim.timeday == 1 && Time_Sim.timemonth == 1 && Time_Sim.timehour == 0) 
    PV_daily_production_estimation = zeros(1,365);
%     Global_Irradiance_For           = zeros(4,24,12);
    if leapyear(Time_Sim.timeyear) == 1
%         GIrrN           = [GIrrN(1:1416)' GIrrN(1392:1416)' GIrrN(1416:end)'];
%         GIrrE           = [GIrrE(1:1416)' GIrrE(1392:1416)' GIrrE(1416:end)'];
%         GIrrS           = [GIrrS(1:1416)' GIrrS(1392:1416)' GIrrS(1416:end)'];
%         GIrrW           = [GIrrW(1:1416)' GIrrW(1392:1416)' GIrrW(1416:end)'];
%         
%         simRange        = repelem(month(datenum(2000,1,1:366)),24);
% %         simHour         = hour(datenum(2000,1,1):hours(1):datenum(2000,1,367));
% %         simHour         = simHour(1:end-1);
%         simHour         = 0:1:23;
%         simHour         = repmat(simHour,1,366);
        
        for k = 1:366
            if PV_usage == 0
                PV_daily_production_estimation(k) = 0;
            else
                PV_daily_production_estimation(k) = sum(PV_production_estimation((k-1)*24+1:k*24));
            end
%             Global_Irradiance_For(:,k)            = [mean(GIrrN((k-1)*24+1:k*24)); mean(GIrrE((k-1)*24+1:k*24)); mean(GIrrS((k-1)*24+1:k*24)); mean(GIrrW((k-1)*24+1:k*24))];
        end
    else
%         
%         simRange    = repelem(month(datenum(2001,1,1:365)),24);
% %         simHour     = hour(datenum(2001,1,1):hours(1):datenum(2001,1,365));
%         simHour         = 0:1:23;
%         simHour         = repmat(simHour,1,365);

       for k = 1:365
            if PV_usage == 0
                PV_daily_production_estimation(k) = 0;
            else
                PV_daily_production_estimation(k) = sum(PV_production_estimation((k-1)*24+1:k*24));
            end
%             Global_Irradiance_For(:,k)            = [mean(GIrrN((k-1)*24+1:k*24)); mean(GIrrE((k-1)*24+1:k*24)); mean(GIrrS((k-1)*24+1:k*24)); mean(GIrrW((k-1)*24+1:k*24))];
       end
    end

    % Hourly forecast per month for global irradiance
    
%     for g = 1:12        % Loop over each month
%     
%         for h = 1:24    % Loop over the hours of the day
%         
%             Global_Irradiance_For(:,h,g) = [mean(GIrrN(simRange == g & simHour == h-1)); mean(GIrrE(simRange == g & simHour == h-1)); mean(GIrrS(simRange == g & simHour == h-1)); mean(GIrrW(simRange == g & simHour == h-1))];
%             
%         end
%         
%     end

% Consider some monthly average value for estimating PV generation in
% during the months.

    if PV_usage == 1
        if leapyear(Time_Sim.timeyear) == 1         
            Daily_estimated_production_by_month = [mean(PV_daily_production_estimation(1:31)); mean(PV_daily_production_estimation(32:60)); mean(PV_daily_production_estimation(61:92)); mean(PV_daily_production_estimation(93:123)); mean(PV_daily_production_estimation(124:155)); mean(PV_daily_production_estimation(156:186)); mean(PV_daily_production_estimation(187:218)); mean(PV_daily_production_estimation(219:240)); mean(PV_daily_production_estimation(241:271)); mean(PV_daily_production_estimation(272:303)); mean(PV_daily_production_estimation(304:334)); mean(PV_daily_production_estimation(335:366))];
%             Global_Irradiance_For_Monthly = [mean(Global_Irradiance_For(1:31),2); mean(Global_Irradiance_For(32:60),2); mean(Global_Irradiance_For(61:92),2); mean(Global_Irradiance_For(93:123),2); mean(Global_Irradiance_For(124:155),2); mean(Global_Irradiance_For(156:186),2); mean(Global_Irradiance_For(187:218),2); mean(Global_Irradiance_For(219:240),2); mean(Global_Irradiance_For(241:271),2); mean(Global_Irradiance_For(272:303),2); mean(Global_Irradiance_For(304:334),2); mean(Global_Irradiance_For(335:366),2)];               
        else
            Daily_estimated_production_by_month = [mean(PV_daily_production_estimation(1:31)); mean(PV_daily_production_estimation(32:59)); mean(PV_daily_production_estimation(60:91)); mean(PV_daily_production_estimation(92:122)); mean(PV_daily_production_estimation(123:154)); mean(PV_daily_production_estimation(154:185)); mean(PV_daily_production_estimation(186:217)); mean(PV_daily_production_estimation(218:239)); mean(PV_daily_production_estimation(240:270)); mean(PV_daily_production_estimation(271:302)); mean(PV_daily_production_estimation(303:333)); mean(PV_daily_production_estimation(334:365))];  
%             Global_Irradiance_For_Monthly = [mean(Global_Irradiance_For(1:31),2); mean(Global_Irradiance_For(32:59),2); mean(Global_Irradiance_For(60:91),2); mean(Global_Irradiance_For(92:122),2); mean(Global_Irradiance_For(123:154),2); mean(Global_Irradiance_For(155:185),2); mean(Global_Irradiance_For(186:217),2); mean(Global_Irradiance_For(218:239),2); mean(Global_Irradiance_For(240:270),2); mean(Global_Irradiance_For(271:302),2); mean(Global_Irradiance_For(303:333),2); mean(Global_Irradiance_For(334:365),2)];
        end

        if leapyear(Time_Sim.timeyear) == 1
            Daily_estimated_production_by_month = [repelem(Daily_estimated_production_by_month(1),31*24) repelem(Daily_estimated_production_by_month(2),29*24) repelem(Daily_estimated_production_by_month(3),31*24) repelem(Daily_estimated_production_by_month(4),30*24) repelem(Daily_estimated_production_by_month(5),31*24) repelem(Daily_estimated_production_by_month(6),30*24) repelem(Daily_estimated_production_by_month(7),31*24) repelem(Daily_estimated_production_by_month(8),31*24) repelem(Daily_estimated_production_by_month(9),30*24) repelem(Daily_estimated_production_by_month(10),31*24) repelem(Daily_estimated_production_by_month(11),30*24) repelem(Daily_estimated_production_by_month(12),31*24)];
            
%             Global_Irradiance_For_Monthly       = [repelem(Global_Irradiance_For(:,1:24,1),31) repelem(Global_Irradiance_For(:,1:24,2),29) repelem(Global_Irradiance_For(:,1:24,3),31) repelem(Global_Irradiance_For(:,1:24,4),30) repelem(Global_Irradiance_For(:,1:24,5),31) repelem(Global_Irradiance_For(:,1:24,6),30) repelem(Global_Irradiance_For(:,1:24,7),31) repelem(Global_Irradiance_For(:,1:24,8),31) repelem(Global_Irradiance_For(:,1:24,9),30) repelem(Global_Irradiance_For(:,1:24,10),31) repelem(Global_Irradiance_For(:,1:24,11),30) repelem(Global_Irradiance_For(:,1:24,12),31)];

%             for i = 1:4     % 4 orientations
%             
%             Global_Irradiance_For_Monthly(i,:)       = [repmat(Global_Irradiance_For(i,1:24,1),1,31) repmat(Global_Irradiance_For(i,1:24,2),1,29) repmat(Global_Irradiance_For(i,1:24,3),1,31) repmat(Global_Irradiance_For(i,1:24,4),1,30) repmat(Global_Irradiance_For(i,1:24,5),1,31) repmat(Global_Irradiance_For(i,1:24,6),1,30) repmat(Global_Irradiance_For(i,1:24,7),1,31) repmat(Global_Irradiance_For(i,1:24,8),1,31) repmat(Global_Irradiance_For(i,1:24,9),1,30) repmat(Global_Irradiance_For(i,1:24,10),1,31) repmat(Global_Irradiance_For(i,1:24,11),1,30) repmat(Global_Irradiance_For(i,1:24,12),1,31)];
% 
%             end
        else
            Daily_estimated_production_by_month = [repelem(Daily_estimated_production_by_month(1),31*24) repelem(Daily_estimated_production_by_month(2),28*24) repelem(Daily_estimated_production_by_month(3),31*24) repelem(Daily_estimated_production_by_month(4),30*24) repelem(Daily_estimated_production_by_month(5),31*24) repelem(Daily_estimated_production_by_month(6),30*24) repelem(Daily_estimated_production_by_month(7),31*24) repelem(Daily_estimated_production_by_month(8),31*24) repelem(Daily_estimated_production_by_month(9),30*24) repelem(Daily_estimated_production_by_month(10),31*24) repelem(Daily_estimated_production_by_month(11),30*24) repelem(Daily_estimated_production_by_month(12),31*24)];
            
%             Global_Irradiance_For_Monthly       = [repelem(Global_Irradiance_For(:,1:24,1),31) repelem(Global_Irradiance_For(:,1:24,2),28) repelem(Global_Irradiance_For(:,1:24,3),31) repelem(Global_Irradiance_For(:,1:24,4),30) repelem(Global_Irradiance_For(:,1:24,5),31) repelem(Global_Irradiance_For(:,1:24,6),30) repelem(Global_Irradiance_For(:,1:24,7),31) repelem(Global_Irradiance_For(:,1:24,8),31) repelem(Global_Irradiance_For(:,1:24,9),30) repelem(Global_Irradiance_For(:,1:24,10),31) repelem(Global_Irradiance_For(:,1:24,11),30) repelem(Global_Irradiance_For(:,1:24,12),31)];

%             for i = 1:4     % 4 orientations
%             
%             Global_Irradiance_For_Monthly(i,:)       = [repmat(Global_Irradiance_For(i,1:24,1),1,31) repmat(Global_Irradiance_For(i,1:24,2),1,29) repmat(Global_Irradiance_For(i,1:24,3),1,31) repmat(Global_Irradiance_For(i,1:24,4),1,30) repmat(Global_Irradiance_For(i,1:24,5),1,31) repmat(Global_Irradiance_For(i,1:24,6),1,30) repmat(Global_Irradiance_For(i,1:24,7),1,31) repmat(Global_Irradiance_For(i,1:24,8),1,31) repmat(Global_Irradiance_For(i,1:24,9),1,30) repmat(Global_Irradiance_For(i,1:24,10),1,31) repmat(Global_Irradiance_For(i,1:24,11),1,30) repmat(Global_Irradiance_For(i,1:24,12),1,31)];
% 
%             end

%             Global_Irradiance_For_Monthly = [repelem(Global_Irradiance_For(:,1),31*24) repelem(Global_Irradiance_For(:,2),28*24) repelem(Global_Irradiance_For(:,3),31*24) repelem(Global_Irradiance_For(:,4),30*24) repelem(Global_Irradiance_For(:,5),31*24) repelem(Global_Irradiance_For(:,6),30*24) repelem(Global_Irradiance_For(:,7),31*24) repelem(Global_Irradiance_For(:,8),31*24) repelem(Global_Irradiance_For(:,9),30*24) repelem(Global_Irradiance_For(:,10),31*24) repelem(Global_Irradiance_For(:,11),30*24) repelem(Global_Irradiance_For(:,12),31*24)];
        end
    else
        if leapyear(Time_Sim.timeyear) == 1
            Daily_estimated_production_by_month = zeros(1, 8784);
%             for i = 1:4     % 4 orientations
%             
%             Global_Irradiance_For_Monthly(i,:)       = [repmat(Global_Irradiance_For(i,1:24,1),1,31) repmat(Global_Irradiance_For(i,1:24,2),1,29) repmat(Global_Irradiance_For(i,1:24,3),1,31) repmat(Global_Irradiance_For(i,1:24,4),1,30) repmat(Global_Irradiance_For(i,1:24,5),1,31) repmat(Global_Irradiance_For(i,1:24,6),1,30) repmat(Global_Irradiance_For(i,1:24,7),1,31) repmat(Global_Irradiance_For(i,1:24,8),1,31) repmat(Global_Irradiance_For(i,1:24,9),1,30) repmat(Global_Irradiance_For(i,1:24,10),1,31) repmat(Global_Irradiance_For(i,1:24,11),1,30) repmat(Global_Irradiance_For(i,1:24,12),1,31)];
% 
%             end
            
%             Global_Irradiance_For_Monthly       = [mean(Global_Irradiance_For(1:31),2); mean(Global_Irradiance_For(32:60),2); mean(Global_Irradiance_For(61:92),2); mean(Global_Irradiance_For(93:123),2); mean(Global_Irradiance_For(124:155),2); mean(Global_Irradiance_For(156:186),2); mean(Global_Irradiance_For(187:218),2); mean(Global_Irradiance_For(219:240),2); mean(Global_Irradiance_For(241:271),2); mean(Global_Irradiance_For(272:303),2); mean(Global_Irradiance_For(304:334),2); mean(Global_Irradiance_For(335:366),2)];
            
%             Global_Irradiance_For_Monthly       = [repelem(Global_Irradiance_For(:,1),31*24) repelem(Global_Irradiance_For(:,2),29*24) repelem(Global_Irradiance_For(:,3),31*24) repelem(Global_Irradiance_For(:,4),30*24) repelem(Global_Irradiance_For(:,5),31*24) repelem(Global_Irradiance_For(:,6),30*24) repelem(Global_Irradiance_For(:,7),31*24) repelem(Global_Irradiance_For(:,8),31*24) repelem(Global_Irradiance_For(:,9),30*24) repelem(Global_Irradiance_For(:,10),31*24) repelem(Global_Irradiance_For(:,11),30*24) repelem(Global_Irradiance_For(:,12),31*24)];
            
        else
            Daily_estimated_production_by_month = zeros(1, 8760);
%             Global_Irradiance_For_Monthly       = [repelem(Global_Irradiance_For(:,1:24,1),31) repelem(Global_Irradiance_For(:,1:24,2),28) repelem(Global_Irradiance_For(:,1:24,3),31) repelem(Global_Irradiance_For(:,1:24,4),30) repelem(Global_Irradiance_For(:,1:24,5),31) repelem(Global_Irradiance_For(:,1:24,6),30) repelem(Global_Irradiance_For(:,1:24,7),31) repelem(Global_Irradiance_For(:,1:24,8),31) repelem(Global_Irradiance_For(:,1:24,9),30) repelem(Global_Irradiance_For(:,1:24,10),31) repelem(Global_Irradiance_For(:,1:24,11),30) repelem(Global_Irradiance_For(:,1:24,12),31)];

%             for i = 1:4     % 4 orientations
%             
%             Global_Irradiance_For_Monthly(i,:)       = [repmat(Global_Irradiance_For(i,1:24,1),1,31) repmat(Global_Irradiance_For(i,1:24,2),1,28) repmat(Global_Irradiance_For(i,1:24,3),1,31) repmat(Global_Irradiance_For(i,1:24,4),1,30) repmat(Global_Irradiance_For(i,1:24,5),1,31) repmat(Global_Irradiance_For(i,1:24,6),1,30) repmat(Global_Irradiance_For(i,1:24,7),1,31) repmat(Global_Irradiance_For(i,1:24,8),1,31) repmat(Global_Irradiance_For(i,1:24,9),1,30) repmat(Global_Irradiance_For(i,1:24,10),1,31) repmat(Global_Irradiance_For(i,1:24,11),1,30) repmat(Global_Irradiance_For(i,1:24,12),1,31)];
% 
%             end

            
%             Global_Irradiance_For_Monthly = [mean(Global_Irradiance_For(1:31),2); mean(Global_Irradiance_For(32:59),2); mean(Global_Irradiance_For(60:91),2); mean(Global_Irradiance_For(92:122),2); mean(Global_Irradiance_For(123:154),2); mean(Global_Irradiance_For(155:185),2); mean(Global_Irradiance_For(186:217),2); mean(Global_Irradiance_For(218:239),2); mean(Global_Irradiance_For(240:270),2); mean(Global_Irradiance_For(271:302),2); mean(Global_Irradiance_For(303:333),2); mean(Global_Irradiance_For(334:365),2)];

%             Global_Irradiance_For_Monthly = [repelem(Global_Irradiance_For(:,1),31*24) repelem(Global_Irradiance_For(:,2),28*24) repelem(Global_Irradiance_For(:,3),31*24) repelem(Global_Irradiance_For(:,4),30*24) repelem(Global_Irradiance_For(:,5),31*24) repelem(Global_Irradiance_For(:,6),30*24) repelem(Global_Irradiance_For(:,7),31*24) repelem(Global_Irradiance_For(:,8),31*24) repelem(Global_Irradiance_For(:,9),30*24) repelem(Global_Irradiance_For(:,10),31*24) repelem(Global_Irradiance_For(:,11),30*24) repelem(Global_Irradiance_For(:,12),31*24)];

        end
    end
    
    Thermal_Model.Forecast.PV_forecast_TRY = Daily_estimated_production_by_month;
    
%     Thermal_Model.Forecast.GlobalIrradiance = Global_Irradiance_For_Monthly;
    
else
    Daily_estimated_production_by_month = Thermal_Model.Forecast.PV_forecast_TRY;
end
     if strcmp(Input_Data.SimulationTimeFrame,'TRY2050')
        Global_Irradiance_For_Monthly       = All_Var.Global_Irradiance_For_Monthly2050;
        
        if leapyear(Time_Sim.timeyear)
            Global_Irradiance_For_Monthly = [Global_Irradiance_For_Monthly(:,1:1416) Global_Irradiance_For_Monthly(:,1393:1416) Global_Irradiance_For_Monthly(:,1417:end)];
        end
    else
        Global_Irradiance_For_Monthly       = All_Var.Global_Irradiance_For_Monthly2012;
        if leapyear(Time_Sim.timeyear)
            Global_Irradiance_For_Monthly = [Global_Irradiance_For_Monthly(:,1:1416) Global_Irradiance_For_Monthly(:,1393:1416) Global_Irradiance_For_Monthly(:,1417:end)];
        end
    end  

% Solar radiation variable to describe the overall radiation to the
% vertical opaque surfaces of the building. Needed for the inside
% temperature calculations

Solar_Radiation_vertical = ((lgts * hgt - aws - ad) * Global_Irradiance_South + (lgts * hgt - awn) * Global_Irradiance_North + (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe) * Global_Irradiance_East + (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww) * Global_Irradiance_West)/(lgts * hgt - aws - ad + lgts * hgt - awn + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww);

% Calculating the maximum heating capacities for design conditions

if myiter == 983
    v = 3;
end

[Max_heating_capacity, Dwelling_env_heat, Ventilation_heater] = Max_heating(N0, House_Volume, Heat_recovery_ventil_annual, Total_Loss, Loss_floor, Ventilation_Type, Temperatures_nodal0, uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, Building_Envelope, Building_Storage_constant, Air_leak);

% Calculate max input for underfloor heater
switch(Heating_Tech)
    
    case 'Underfloor heating'
        
        Max_Input = (Underfloor_heating_efficiency * 24 * 1.3 * Dwelling_env_heat)/Charging_Time;
        
end

        

%%%
% Looping the ventilation and heating functions
%%%
% Ventilation losses can be calculated by the heating
% requirements of the ventilated air when the suplly air from the
% ventilation shaft is 18 degrees. The calculations are presented in the 
% National Building Code of Finland pp. 22 - 26. Loss_Ventil depicts the 
% amount of heating need in the building after the ventilation, and is thus
% the need of dwelling's heating. This way the radiatior heating amount 
% is smaller as the ventilation heats some of the air.
%%%
% The ventilation type influenceses the heat demand and direct electric
% space heating requirements. Three choices can be made here: Natural
% Ventilation, Mechanical Ventilation or Balanced Ventilation with A/A Heat
% exhancer. A/A heat exchangers can be further divided to plate and rotary
% types, which both influence the heat recovery rate, and rotary heat
% exchangers needs motors to operate, which adds some electricity
% consumption in them. 

%     switch Ventilation_Type
%         
%         case{'Mechanical Ventilation','Air-Air H-EX'}     
%             % These technologies can adjust the ventilation rate of the building.
% 
%             if tenancy == 0             % From RIL 249-2009 p. 114
%                 
%                 Flow_rate       = 0.2;
%                 
%             elseif tenancy == 1 && (NewVar.Appliances_Cons(:,myiter+1,18) > 0 || NewVar.Appliances_Cons(:,myiter+1,19) > 0)    % Increased ventilation air flow when cooking or cleaning
%                 
%                 Flow_rate       = 1.0;
%                 
%             elseif m > 1 && Temp_inside > 25 && (timehour > 8 && timehour < 22) % Summer daytime increased ventilation flow
%                 
%                 Flow_rate       = 0.7;
%                 
%                 if Temperature > 10 && Temperature < 18
%                     
%                     T_inlet     = Temperature;
%                     
%                 end
%                 
%             elseif myiter+1 > 1 && Temp_inside > 25 && (timehour < 8 || timehour > 22) % Increased ventilation flow for summer nights for cooling
%                 
%                 Flow_rate       = 1.5;
%                 
%                 if Temperature > 10 && Temperature < 18
%                     
%                     T_inlet     = Temperature;
%                     
%                 end
%                 
%             else
%                 
%                 Flow_rate       = N0;
%                 
%             end
%     
%         case('Natural Ventilation')
%             
%             Flow_rate = N0;
%             
%     end


    

    switch(Ventilation_Type)
        
            
        case{'Mechanical ventilation','Natural ventilation'}
            
            % Heat losses through ventilation are calculated according to
            % the National Building Code of Finland D5. The equation is 
            % Q = cp * roo * flow rate * Vhouse * deltaT.
            
            if Heat_recovery_ventil_annual > 0 && myiter == 0
                
                warning('Adjust the ventilation! Mechnanical and natural ventilations cannot have heat recovery!')
                
                %UseDefault = true ;
                
                if UseDefault == true
                    Input_Data.Ventil = 'Air-Air H-EX';
                    Ventilation_Type  = char(Input_Data.Ventil);
                else
                 Mod = questdlg({'Adjust the ventilation! Mechnanical and natural ventilations cannot have heat recovery!', 'Please select either Air-Air H-EX, no heat recovery', 'or terminate the simulation'}, ...
                                    'Warning on unsuitable heat recovery', 'Air-Air H-EX', 'No heat recovery', 'Terminate', 'Air-Air H-EX');
                                
                        switch Mod
                            case 'Air-Air H-EX'
                                Input_Data.Ventil = 'Air-Air H-EX';
                                Ventilation_Type                    = char(Input_Data.Ventil);
                            case 'No heat recovery'
                                Input_Data.Heat_recovery_ventil_annual = '0';
                                Heat_recovery_ventil_annual     = str2double(Input_Data.Heat_recovery_ventil_annual);
                            otherwise
%                                 delete(gui.runWindow)
                                Input_Data.Terminate = true;
                            return;
%                                 error('The execution was terminated!')
                        end
                end
                
            end
            
                Loss_Ventil = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temp_inside - Temperature);
                
                Heating_Ventil = 0;
                
                T_inlet = Temperature;      % No heat exchanger nor ventilation heater
                
                
            
%             if house_type <= 6

                if strcmp(Ventilation_Type,'Mechanical ventilation') == 1
%                 
                % Mechanical ventilation uses electricity to extract air
                % and this electricity consumption has an effect to the
                % electricity consumption from the ventilation system. The
                % electricity consumption is calculated in accordance with
                % the National Building Code of Finland D5. As the
                % electricity consumption is as kWh/m3/s the consumption is
                % related to the air flow in the ventilation.
                
                    if vent_elec == 0
                        
                        msg = 'Mechanical ventilation consumes electricity!';
                        warning(msg)
                        
                        %UseDefault = true ;
                        
                        if UseDefault == true
                            El{1} = 1.5 ;
                        else
                            El = inputdlg('Currently the electricity consumption for mechanical ventilation is 0. Please assign the electricity consumption for the ventilation in kWh/m3/s. Default option is 1.5 kWh/m3/s.', 'Electricity consumption for ventilation error!');
                        end
                        
                        vent_elec               = str2double(El{1});
                        Input_Data.vent_elec    = El{1};
                        
                        
                    end
                
                    Ventil_Consumption      = vent_elec * 1000 * (Flow_rate * House_Volume / 3600);
                    
                else
                    
                    Ventil_Consumption      = 0;
                    
                end
                
                Motor_consumption           = 0;
                
                    if Temp_inside > Temp_cooling && Flow_rate > N0 && strcmp(Ventilation_Type,'Mechanical ventilation') == 1
            
                        Cooling_Impact = (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside - T_inlet) - Loss_Ventil;
                        
                    else
                        
                        Cooling_Impact = 0;
            
                    end
% 
%             else    % Low energy and passive houses must have mechanical ventilation. This is also why in user defined inputs the house type needs to be 6.
%                 
%                 msg = 'Low-energy and passive houses must have mechanical ventilation!';
%                 error(msg);
%                 
%             end
            
            % Air-to-air heat recovery
        
        % case('A/A HEX')
        
        case('Air-Air H-EX')     % Air-to-air heat recovery system
            
            if Heat_recovery_ventil_annual == 0     % A case where there is balanced ventilation without actual heat recovery
                
                % In both with and without heat recoveries balanced
                % ventilation has heating system for the indoor air.
                % Without heat recovery it is purely the difference between
                % outdoor and supply air. The heating power is calculated
                % in accordance with the National Building Code of Finland
                % D5. 
                
                Heating_Ventil      = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (T_inlet - Temperature);
                
                if Heating_Ventil <= 0                       % Ventilation heating cannot be negative!
                    
                    Heating_Ventil = 0;
                    
                    T_inlet = Temperature;                % Then inlet temperature is equal to outside temperature as well since it is higher than the default inlet temperature
                    
                elseif Heating_Ventil > Ventilation_heater   % Design ventilation heating capacity cannot be crossed
                    
                    Heating_Ventil = Ventilation_heater;
                    
                    T_inlet = Temperature + Heating_Ventil/((1.2 * 1.007 * Flow_rate * House_Volume)/3.6); % This is the temperature to which the design heating capacity is able to heat the inlet air
                    
                end
               
                % Heat losses through ventilation are calculated equal to
                % mechanical and natural ventilations, but here the heat
                % loss is considered as amount of energy the space heating
                % system needs to deliver to keep the indoor temperature
                % steady. Thus, the temperature difference is between the
                % indoor and supply temperatures.
               
                    Loss_Ventil = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temp_inside - T_inlet);
                 
                    % Balanced ventilation requires electricity to run and
                    % this is calculated equally to mechanical ventilation.
                    
                    if vent_elec == 0
                        
                        msg = 'Air-Air H-EX ventilation consumes electricity!';
                        warning(msg)
                        
                        %UseDefault = true ;
                        
                        if UseDefault == true
                            El{1} = 2 ;
                        else
                            El = inputdlg('Currently the electricity consumption for Air-Air H-EX ventilation is 0. Please assign the electricity consumption for the ventilation in kWh/m3/s. Default option is 2 kWh/m3/s.', 'Electricity consumption for ventilation error!');
                        end
                        
                        vent_elec               = str2double(El{1});
                        Input_Data.vent_elec    = El{1};
                        
                    end
                    
                    Ventil_Consumption = vent_elec * 1000 * (Flow_rate * House_Volume / 3600); % Ventilation electricity consumption is on kW/m3/s on database.
                    
                    Recovery_Power      = 0;
                    
                    if Temp_inside > Temp_cooling && Flow_rate > N0
            
                        Cooling_Impact = (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside - T_inlet) - Loss_Ventil;
                        
                    else
                        
                        Cooling_Impact = 0;
            
                    end
                 
                
            else
                
                if myiter +1 == 2
                    a = 0;
                end
        
                if (strcmp(Ventilation_Type,'Natural Ventilation') == 1 || strcmp(Ventilation_Type,'Mechanical Ventilation') == 1) && myiter == 0
            
                    msg = 'With heat recovery only Air-Air H-EX is allowed!';
                    warning(msg)
                    
                    %UseDefault = true ;
                    
                    if UseDefault == true
                        Input_Data.Ventil = 'Air-Air H-EX';
                    else
                        Mod = questdlg({'With heat recovery only Air-Air H-EX is allowed!','Please select either Air-Air H-EX, no heat recovery', 'or terminate the simulation'}, ...
                                        'Warning on unsuitable heat recovery', 'Air-Air H-EX', 'No heat recovery', 'Terminate');

                            switch Mod
                                case 'Air-Air H-EX'
                                    Input_Data.Ventil = 'Air-Air H-EX';
                                case 'No heat recovery'
                                    Input_Data.Heat_recovery_ventil_annual = '0';
                                otherwise
    %                                 delete(gui.runWindow)
                                    Input_Data.Terminate = true;
                                return;
    %                                 error('The execution was terminated');
                            end
                    end
                end

            
            % First calculate the recovery efficiency when taking outlet
            % air temperature restriction into account to prevent
            % defrosting. In case of low energy or passive house, rotary
            % wheel heat exchanger is used, and there is need for
            % preheating the air coming to the heat exchanger in order to
            % reduce the defrosting. Similarly, preheating can be used to
            % increase the efficiency of the heat exchanger as the total
            % efficiency cycle can be utilized. Temp_outlet1 is the defrost
            % temperture limit.
                 
                
                if Temperature > Temp_outlet1        % if outdoor temperature is higher than the defrost limit temperature, then the outdoor temperature is used.
                
                % The outlet temperture in case of higher
                
                    Temp_outlet = Temp_inside - Heat_recovery_ventil_annual*(Temp_inside - Temperature);
                    Preheat_Ventil = 0;
                    
                else
                    
                    Temp_outlet = Temp_outlet1;     % Exhaus air temperature(outlet air temperature) from the heat recovery system needs to be higher than the minimum defrost outlet temperature
                    Preheat_Ventil = 0;
                    
                    Outdoor_Air_Defrost_Temp_Limit  = (1/Heat_recovery_ventil_annual)*(Temp_outlet + (Heat_recovery_ventil_annual-1)*Temp_inside);  % Temperature to which outdoor air needs to be preheated for the heat recovery system to achieve its maximum heat recovery efficiency
                
                    if Temperature < Outdoor_Air_Defrost_Temp_Limit && (Time_Sim.timemonth <=4 || Time_Sim.timemonth >=9)   % If the outdoor temperature is lower than the threshold value for the maximum efficiency supply temperature for the heat recovery system during the heating period, then there is a need for preheating the outdoor air before its supply to the heat recovery system
                
                % If outside temperature is less than the limit for the
                % maximum annual heat recovery, then it needs to be
                % preheated to the threshold temperature for maximizing the
                % heat recovery efficiency.
                
                    Temperature_to_heat_exchanger   = (1/Heat_recovery_ventil_annual) * (Temp_outlet + (Heat_recovery_ventil_annual-1)*Temp_inside);
                    
                    if Temperature_to_heat_exchanger < Temperature
                        
                        Temperature_to_heat_exchanger = Temperature; 
                        
                    end
                    
                    Preheat_Ventil                  = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temperature_to_heat_exchanger - Temperature);
                    
                    if Preheat_Ventil > Ventilation_heater
                        
                        Preheat_Ventil                      = Ventilation_heater;
                        Temperature_to_heat_exchanger       = Temperature + Preheat_Ventil / ((1.2 * 1.007 * Flow_rate * House_Volume)/3.6);
                        
                    end
                
                    else
                    
                    Temperature_to_heat_exchanger   = Temperature;
                
                    end
                
                end
            
            
                Heat_Recovery_efficiency            = (Temp_inside - Temp_outlet)/(Temp_inside - Temperature_to_heat_exchanger);

                if Heat_Recovery_efficiency > Heat_recovery_ventil_annual   % Heat recovery cannot be more than annual efficiency
                    
                    Heat_Recovery_efficiency        = Heat_recovery_ventil_annual;
                    Temperature_to_heat_exchanger   = (1/Heat_Recovery_efficiency)*(Temp_outlet + (Heat_Recovery_efficiency-1)*Temp_inside);
                    
                    if Temperature > Temperature_to_heat_exchanger
                        
                        Temperature_to_heat_exchanger = Temperature;
                        
                    end
                    
                    Preheat_Ventil                  = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temperature_to_heat_exchanger - Temperature);
                    
                    if Preheat_Ventil > Ventilation_heater
                        
                        Preheat_Ventil                      = Ventilation_heater;
                        Temperature_to_heat_exchanger       = Temperature + Preheat_Ventil / ((1.2 * 1.007 * Flow_rate * House_Volume)/3.6);
                        Heat_Recovery_efficiency            = (Temp_inside - Temp_outlet)/(Temp_inside - Temperature_to_heat_exchanger);

                        
                    end
                    
                end
            
            % Calculate heat recovery from the heat recovery system and the
            % heating in the ventilation.
            
                Recovery_Power          = Heat_Recovery_efficiency * (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temp_inside - Temperature_to_heat_exchanger); 
                Heat_Recovery_Temp      = Temperature_to_heat_exchanger + (Recovery_Power/((1.2 * 1.007 * Flow_rate * House_Volume)/3.6));
                
                if Heat_Recovery_Temp > T_inlet
                    
                    Heat_Recovery_Temp = T_inlet;
                    
                    Heat_Recovery_efficiency    = (Heat_Recovery_Temp - Temperature_to_heat_exchanger)/(Temp_inside - Temperature_to_heat_exchanger);
                    Recovery_Power              = Heat_Recovery_efficiency * (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temp_inside - Temperature_to_heat_exchanger); 
                    
                end
                
                Heating_Ventil          = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (T_inlet - Heat_Recovery_Temp);
            
                    if Heating_Ventil <= 0       % Heating ventilation cannot be under 0
                        
                        Heating_Ventil  = 0;
                    
                        if Temperature > T_inlet && Temperature < UpperTempLimit1
                            
                            T_inlet             = Temperature;                 % If temperature is higher outside than the preset inlet temperature the inlet temperature is equal to the outside temperature
                            
                            Recovery_Power      = 0;
                            
                        elseif Temperature > Temp_inside && Temperature > UpperTempLimit1
                            
                            T_inlet             = Heat_Recovery_Temp;
                            

                        elseif Temperature < T_inlet && Temp_inside > UpperTempLimit1 && (Time_Sim.timemonth == 5 || Time_Sim.timemonth == 6 || Time_Sim.timemonth == 7 || Time_Sim.timemonth == 8)
                            
                            T_inlet             = Temperature;
                            
                            Recovery_Power      = 0;
                            
                        elseif Heat_Recovery_Temp > T_inlet
                            
                            Heat_Recovery_Temp  = T_inlet;         % The automation is considered to set the recovery temperature at most to the inlet temperature
                            
                            Recovery_Power      = ((1.2 * 1.007 * Flow_rate * House_Volume)/3.6) * (Heat_Recovery_Temp - Temperature_to_heat_exchanger);
                            
                        end
                    
                    elseif Heating_Ventil + Preheat_Ventil > Ventilation_heater       % Ventilation heating cannot be higher than the design value
                        
                        Heating_Ventil          = Ventilation_heater - Preheat_Ventil;
                        
                        T_inlet                 = Heat_Recovery_Temp + Heating_Ventil/((1.2 * 1.007 * Flow_rate * House_Volume)/3.6);     % Inlet air temperature when design ventilation heating is in action
                        
                    end
            

                 

        
        % Heat losses through ventilation.
        
                
                    Loss_Ventil = (1.2 * 1.007 * Flow_rate * House_Volume)/3.6 * (Temp_inside - T_inlet);
                    
                            
                    if Temp_inside > Temp_cooling && Flow_rate > N0
            
                        Cooling_Impact = (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside - T_inlet) - Loss_Ventil;
                        
                    else
                        
                        Cooling_Impact = 0;
            
                    end
                
        
        % Calculate electricity consumption from the ventilation.
        
                    % Balanced ventilation requires electricity to run and
                    % this is calculated equally to mechanical ventilation.
                    
                    if vent_elec == 0
                        
                        msg = 'Balanced ventilation consumes electricity!';
                        warning(msg)
                        
                        %UseDefault = true ;
                        
                        if UseDefault == true
                            El{1} = 2 ;
                        else
                            El = inputdlg('Currently the electricity consumption for balanced ventilation is 0. Please assign the electricity consumption for the ventilation in kWh/m3/s. Default option is 2 kWh/m3/s.', 'Electricity consumption for ventilation error!');
                        end
                        
                        vent_elec               = str2double(El{1});
                        Input_Data.vent_elec    = El{1};
                        
                    end
                    
%                     Ventil_Consumption = vent_elec * 1000 * (Flow_rate * House_Volume / 3600); % Ventilation electricity consumption is on kW/m3/s on database.
        
                
                    Ventil_Consumption = vent_elec * 1000 * (Flow_rate * House_Volume / 3600);
                
        
        % Total ventilation heating is equal to preheat and heating after
        % the heat recovery
        
                Heating_Ventil = Heating_Ventil + Preheat_Ventil;
        
            end
    
    % Calculate the energy amount through the ventilation system to define
    % the actual heat recovery.
    
            if Loss_Ventil <= 0
                
                Total_Loss_from_ventil = abs(Recovery_Power) + Heating_Ventil;
                
            else
                
                Total_Loss_from_ventil = abs(Recovery_Power) + Heating_Ventil + Loss_Ventil;
                
            end
    
    % Low energy and passive buildings have rotary heat exchanger which
    % consumes electricity
    
            if house_type == 7 || house_type == 8
                
                Motor_power = 60;
                
                if Recovery_Power > 0
                    
                    Motor_consumption = Motor_power;
                    
                end
                
            else
                
                Motor_consumption = 0;
                
            end
            
    end
    
    %%% Next the heat gain from the solar radiation through windows in determined
    
    [Solar_Heat_Gain, F_permeability] = Sol_rad_windows1(Input_Data, Time_Sim, All_Var, BuildSim, Temp_inside, Global_Irradiance_North, Global_Irradiance_East, Global_Irradiance_South, Global_Irradiance_West, tenancy, F_permeability, gwindow, Temperature);
%     F_permeability = F_permeability;
    
    % Now the total heat gains are:
    Internal_Heat_Gain = Solar_Heat_Gain + Internal_Heat_Gain_Appl + People_Heat_Gain;
    
    % Heat gain for the estimation calculation from the decree of the
    % ministry of the environment
    Internal_Heat_Gain_Leg      = lgte * lgts * (0.1 * 6 + 0.6 * 3 + 0.6 * 2);      % From Decree of the Ministry of the Environment


% Thermal comfort calculation
if tenancy == 0
    
    LowerTempLimit = Temp_Set;
    UpperTempLimit = Temp_cooling;
    
else
    
    Acceptable_inside_temperature = Thermal_Comfort(All_Var, Time_Sim, Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), myiter+1, ComfortLimit);
    LowerTempLimit = Acceptable_inside_temperature(1);
    UpperTempLimit = Acceptable_inside_temperature(end);
    
end

% Time set temperature limits need different comfort limit values. Save the
% temperature limit for checking in the future.

if strcmp(Heating_Tech, 'Time Set Temp') == 1
    LowerTempLimit2 = LowerTempLimit(1);
else    
    LowerTempLimit2 = LowerTempLimit;
end
UpperTempLimit2 = UpperTempLimit;

% Consider generating a weather forecast model to be used 

% Heat demand estimation is required for underfloor heating. It is
% estimated from the temperature forecast, and expected indoor temperatures
% from the latest thermal comfort lower temperature limit. 

Time_ahead           = 24;        % This is the time the model considers and calculates the heat demand beforehand

% Temp_inside_forecast = ones(1,Time_ahead) * LowerTempLimit(1); %* Temp_Set(1); %LowerTempLimit(1); 
Temp_inside_forecast = ones(1,Time_ahead) * Temp_Set;
Temp_inside_forecast_corrected = ones(1,Time_ahead) * Temp_inside;

if myiter == 8600
    x = 1;
end

if rem(myiter+1,Time_ahead / Time_Sim.stepreal) == 0 || myiter == 0
    
        F_permeability_For                      = 0.75;
        
        if strcmp(Input_Data.SimulationTimeFrame,'TRY2050')
            load('2050_global_radiation.mat', 'Hourly_Global_Radiation_2050')
            Solar_Radiation_For     = Hourly_Global_Radiation_2050';
            
            if leapyear(Time_Sim.timeyear) == 0
                
                Solar_Radiation_For     = [Solar_Radiation_For(1:1392) Solar_Radiation_For(1417:end)];
                
            end
            
        else
            load TRY2012
            Solar_Radiation_For     = TRY2012_Global_Radiation;
            
            if leapyear(Time_Sim.timeyear)
                
                Solar_Radiation_For     = [Solar_Radiation_For(1:1392) Solar_Radiation_For(1367:1392) Solar_Radiation_For(1393:end)];
                
            end
            
        end
        
        Solar_Heat_Gain_For1            = zeros(1,Time_ahead);
        Solar_Radiation_vertical_For1   = zeros(1,Time_ahead);

        if Time_Sim.myiter + 1 ~= Time_Sim.nbrstep.(Input_Data.Headers) 

            for ii = 1:Time_ahead   % Loop the heat demand calculation for the next day

                Solar_Radiation_vertical_For = ((lgts * hgt - aws - ad)                             * Global_Irradiance_For_Monthly(3,currenthouryear+ii-1) + ...
                                               (lgts * hgt - awn)                                   * Global_Irradiance_For_Monthly(1,currenthouryear+ii-1) + ...
                                               (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe)    * Global_Irradiance_For_Monthly(2,currenthouryear+ii-1) + ...
                                               (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww)    * Global_Irradiance_For_Monthly(4,currenthouryear+ii-1)) / (lgts * hgt - aws - ad + lgts * hgt - awn + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww);

                Solar_Heat_Gain_For = (Global_Irradiance_For_Monthly(2,currenthouryear+ii-1) * F_permeability_For * awe * gwindow + Global_Irradiance_For_Monthly(1,currenthouryear+ii-1) * F_permeability_For * awn * gwindow + ...
                                       Global_Irradiance_For_Monthly(4,currenthouryear+ii-1) * F_permeability_For * aww * gwindow + Global_Irradiance_For_Monthly(3,currenthouryear+ii-1) * F_permeability_For * aws * gwindow);

                Solar_Heat_Gain_For1(ii)            = Solar_Heat_Gain_For;
                Solar_Radiation_vertical_For1(ii)    = Solar_Radiation_vertical_For;

            end
        
        end
    
    if myiter+1 < 24
        
%         Day_forecasted_heat_demand(1:24)    = zeros(1,24);

% %         Temp_nodal                              = zeros(20,Time_ahead+1);
% %         Temp_nodal(:,1)                         = Thermal_Model.Temperature.Nodal_Temperatures(:,myiter+1);
% %         Heat_Demand_Forc                        = zeros(1,Time_ahead);
% %         
% %         F_permeability_For                      = 0.75;
% %         
% %         if strcmp(Input_Data.SimulationTimeFrame,'TRY2050')
% %             load 2050_global_radiation
% %             Solar_Radiation_For     = Hourly_Global_Radiation_2050;
% %             
% %             if leapyear(Time_Sim.timeyear)
% %                 
% %                 Solar_Radiation_For     = [Solar_Radiation_For(1:1416) Solar_Radiation_For(1393:1416) Solar_Radiation_For(1417:end)];
% %                 
% %             end
% %             
% %         else
% %             load TRY2012
% %             Solar_Radiation_For     = TRY2012_Global_Radiation;
% %             
% %             if leapyear(Time_Sim.timeyear)
% %                 
% %                 Solar_Radiation_For     = [Solar_Radiation_For(1:1416) Solar_Radiation_For(1393:1416) Solar_Radiation_For(1417:end)];
% %                 
% %             end
% %             
% %         end
% %         
% %         Solar_Heat_Gain_For1            = zeros(1,Time_ahead);
% %         Solar_Radiation_vertical_For1   = zeros(1,Time_ahead);
% % 
% %         for ii = 1:Time_ahead   % Loop the heat demand calculation for the next day
% %             
% %             Heater_Power_Forc                    = 0;
% %             
% %             Solar_Radiation_vertical_For = ((lgts * hgt - aws - ad) * Global_Irradiance_For_Monthly(3,currenthouryear+ii-1) + (lgts * hgt - awn) * Global_Irradiance_For_Monthly(1,currenthouryear+ii-1) + (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe) * Global_Irradiance_For_Monthly(2,currenthouryear+ii-1) + (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww) * Global_Irradiance_For_Monthly(4,currenthouryear+ii-1))/(lgts * hgt - aws - ad + lgts * hgt - awn + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww);
% % 
% %             Solar_Heat_Gain_For = (Global_Irradiance_For_Monthly(2,currenthouryear+ii-1) * F_permeability_For * awe * gwindow + Global_Irradiance_For_Monthly(1,currenthouryear+ii-1) * F_permeability_For * awn * gwindow + ...
% %                 Global_Irradiance_For_Monthly(4,currenthouryear+ii-1) * F_permeability_For * aww * gwindow + Global_Irradiance_For_Monthly(3,currenthouryear+ii-1) * F_permeability_For * aws * gwindow);
% %             
% %             Solar_Heat_Gain_For1(ii)            = Solar_Heat_Gain_For;
% %             Solar_Radiation_vertical_For1(ii)    = Solar_Radiation_vertical_For;
% %             
% %             if strcmp(Heating_Tech, 'Underfloor_heating')
% %                 
% %                 [T_insideForc0, ~, T_operativeForc0, T_nodal] = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heater_Power_Forc, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% % 
% %                 HeatingNeed = T_insideForc0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
% %                 CoolingNeed = T_insideForc0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
% %             
% %                 Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
% %                 
% %             else
% %             
% %                 [T_insideForc0, ~, T_operativeForc0, T_nodal] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heater_Power_Forc, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %             
% %                 HeatingNeed = T_insideForc0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
% %                 CoolingNeed = T_insideForc0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
% %             
% %                 Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
% %             
% %             end
% %             
% %             if HeatingNeed || CoolingNeed   % If there is heating or cooling need, calculate the heat demand to achieve the heating or cooling set point
% %                 
% %                 if strcmp(Heating_Tech, 'Underfloor heating')
% %                     
% %                     [T_insideForcMax, ~, T_operativeForcMax, ~]  = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Dwelling_env_heat, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                 else
% % 
% %                 
% %                     [T_insideForcMax, ~, T_operativeForcMax, ~]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Dwelling_env_heat, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                 end
% %                 
% %                 if HeatingNeed
% %                 
% %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_Set - T_insideForc0)/(T_insideForcMax - T_insideForc0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature
% % %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_Set - T_operativeForc0)/(T_operativeForcMax - T_operativeForc0));
% %                 
% %                 else
% %                     
% %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_cooling - T_insideForc0)/(T_insideForcMax - T_insideForc0));
% % %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_cooling - T_operativeForc0)/(T_operativeForcMax - T_operativeForc0));
% %                     
% %                 end
% %                 
% %             else
% %                 
% %                 Heat_Demand_Forc(ii)                 = 0;        % There is no heat demand if the free floating conditions do not shift the temperature outside of the temperature set-points
% %                 
% %             end
% %             
% %         end

        if isrow(Rounded_Hourly_temp_forecast_random)

            Day_forecasted_heat_demand             = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)) + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet) + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1)) - Internal_Heat_Gain_Leg - Solar_Heat_Gain_For1; % (mean(Thermal_Model.Internal_Heat_Gain(myiter-Time_ahead+1:myiter))); % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
         
        else
            
            Day_forecasted_heat_demand             = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet) + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1)) - Internal_Heat_Gain_Leg - Solar_Heat_Gain_For1; % (mean(Thermal_Model.Internal_Heat_Gain(myiter-Time_ahead+1:myiter))); % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
            
        end

%         Day_forecasted_heat_demand          = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet) + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1)) - Internal_Heat_Gain_Leg - Solar_Heat_Gain_For1; % (mean(Thermal_Model.Internal_Heat_Gain((1:myiter)))); % Daily mean value for the first 24 hours needs to be taken from less than 24 values % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
%         Day_forecasted_heat_demand_corrected = (Total_Loss) * (Temp_inside_forecast_corrected - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet) + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1)) - Internal_Heat_Gain_Leg - Solar_Heat_Gain_For1;
        
%         if Day_forecasted_heat_demand < Day_forecasted_heat_demand_corrected
        
%             Heat_Demand_forecast_corrected      = Day_forecasted_heat_demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_inside_forecast - Temp_inside_forecast_corrected);
%             Day_forecasted_heat_demand          = Day_forecasted_heat_demand - (Day_forecasted_heat_demand - Day_forecasted_heat_demand_corrected);
            Sum_day_heat_demand_forecast        = sum(Day_forecasted_heat_demand);
% %         Sum_day_heat_demand_forecast        = sum(Heat_Demand_Forc);

%         else
%             
%             Day_forecasted_heat_demand          = Day_forecasted_heat_demand + (Day_forecasted_heat_demand_corrected - Day_forecasted_heat_demand);
%             Sum_day_heat_demand_forecast        = sum(Day_forecasted_heat_demand);
%             
%         end

%         Sum_day_heat_demand_forecast        = sum(Heat_Demand_forecast_corrected);
        
        Thermal_Model.Forecast.Day_ahead_heat_demand_forecast = repelem(Sum_day_heat_demand_forecast,Time_ahead);
        
%         Day_forecasted_heat_demand(1:24) = zeros(1,24);
%         Day_forecasted_heat_demand(myiter + 1 : myiter + 1 + Time_ahead - 1) = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1))) - (mean(Thermal_Model.Internal_Heat_Gain((1:myiter)))); % Daily mean value for the first 24 hours needs to be taken from less than 24 values % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
%         Sum_day_heat_demand_forecast(myiter+1:myiter+Time_ahead) = sum(Day_forecasted_heat_demand(myiter+1:myiter+Time_ahead));
%         
%         Thermal_Model.Forecast.Day_ahead_heat_demand_forecast(myiter+1:myiter+Time_ahead) = Sum_day_heat_demand_forecast(myiter+1:myiter+Time_ahead);

        
    
    elseif myiter + 1 ~= Time_Sim.nbrstep.(Input_Data.Headers)
        
% %         Temp_nodal                              = zeros(20,Time_ahead+1);
% %         Temp_nodal(:,1)                         = Thermal_Model.Temperature.Nodal_Temperatures(:,myiter);
% %         Heat_Demand_Forc                        = zeros(1,Time_ahead);
% %         
% %         F_permeability_For                      = 0.75;
% % 
% %         
% %         if strcmp(Input_Data.SimulationTimeFrame,'TRY2050')
% %             load 2050_global_radiation
% %             Solar_Radiation_For     = Hourly_Global_Radiation_2050;
% %             
% %             if leapyear(Time_Sim.timeyear)
% %                 
% %                 Solar_Radiation_For     = [Solar_Radiation_For(1:1416) Solar_Radiation_For(1393:1416) Solar_Radiation_For(1416:end)];
% %                 
% %             end
% %             
% %         else
% %             load TRY2012
% %             Solar_Radiation_For     = TRY2012_Global_Radiation;
% %             
% %             if leapyear(Time_Sim.timeyear)
% %                 
% %                 Solar_Radiation_For     = [Solar_Radiation_For(1:1416) Solar_Radiation_For(1393:1416) Solar_Radiation_For(1416:end)];
% %                 
% %             end
% %             
% %         end
% %         
% %         Solar_Heat_Gain_For1            = zeros(1,Time_ahead);
% %         Solar_Radiation_vertical_For1   = zeros(1,Time_ahead);
% % 
% %         for ii = 1:Time_ahead   % Loop the heat demand calculation for the next day
% %             
% %             Heater_Power_Forc                    = 0;
% %             
% %             Solar_Radiation_vertical_For = ((lgts * hgt - aws - ad) * Global_Irradiance_For_Monthly(3,currenthouryear+ii-1) + (lgts * hgt - awn) * Global_Irradiance_For_Monthly(1,currenthouryear+ii-1) + (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe) * Global_Irradiance_For_Monthly(2,currenthouryear+ii-1) + (lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww) * Global_Irradiance_For_Monthly(4,currenthouryear+ii-1))/(lgts * hgt - aws - ad + lgts * hgt - awn + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe + lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww);
% % 
% %             Solar_Heat_Gain_For = (Global_Irradiance_For_Monthly(2,currenthouryear+ii-1) * F_permeability_For * awe * gwindow + Global_Irradiance_For_Monthly(1,currenthouryear+ii-1) * F_permeability_For * awn * gwindow + ...
% %                 Global_Irradiance_For_Monthly(4,currenthouryear+ii-1) * F_permeability_For * aww * gwindow + Global_Irradiance_For_Monthly(3,currenthouryear+ii-1) * F_permeability_For * aws * gwindow);
% %             
% %             Solar_Heat_Gain_For1(ii)            = Solar_Heat_Gain_For;
% %             Solar_Radiation_vertical_For1(ii)    = Solar_Radiation_vertical_For;
            
%             [T_insideForc0, ~, T_operativeForc0, T_nodal] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heater_Power_Forc, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
%             
%             HeatingNeed = T_insideForc0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
%             CoolingNeed = T_insideForc0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
%             
%             Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
            
%             if HeatingNeed || CoolingNeed   % If there is heating or cooling need, calculate the heat demand to achieve the heating or cooling set point
%                 
%                 [T_insideForcMax, ~, T_operativeForcMax, ~]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Dwelling_env_heat, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));

% %             if strcmp(Heating_Tech, 'Underfloor heating')
% %                 
% %                 [T_insideForc0, ~, T_operativeForc0, T_nodal] = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heater_Power_Forc, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% % 
% %                 HeatingNeed = T_insideForc0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
% %                 CoolingNeed = T_insideForc0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
% %             
% %                 Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
% %                 
% %             else
% %             
% %                 [T_insideForc0, ~, T_operativeForc0, T_nodal] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heater_Power_Forc, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %             
% %                 HeatingNeed = T_insideForc0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
% %                 CoolingNeed = T_insideForc0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
% %             
% %                 Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
% %             
% %             end
% %             
% %             if HeatingNeed || CoolingNeed   % If there is heating or cooling need, calculate the heat demand to achieve the heating or cooling set point
% %                 
% %                 if strcmp(Heating_Tech, 'Underfloor heating')
% %                     
% %                     [T_insideForcMax, ~, T_operativeForcMax, ~]  = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Dwelling_env_heat, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                 else
% % 
% %                 
% %                     [T_insideForcMax, ~, T_operativeForcMax, ~]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Dwelling_env_heat, Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                 end
% % 
% %                 if HeatingNeed
% %                 
% %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_Set - T_insideForc0)/(T_insideForcMax - T_insideForc0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature
% %                     
% %                     if strcmp(Heating_Tech, 'Underfloor heating')
% %                     
% %                         [~, ~, ~, T_nodal]  = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heat_Demand_Forc(ii), Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                     else
% %                 
% %                         [~, ~, ~, T_nodal]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heat_Demand_Forc(ii), Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                     end
% %                     
% %                 Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
% %                     
% % %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_Set - T_operativeForc0)/(T_operativeForcMax - T_operativeForc0));
% %                 
% %                 else
% %                     
% %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_cooling - T_insideForc0)/(T_insideForcMax - T_insideForc0));
% % %                     Heat_Demand_Forc(ii)             = Dwelling_env_heat * ((Temp_cooling - T_operativeForc0)/(T_operativeForcMax - T_operativeForc0));
% % 
% %                     if strcmp(Heating_Tech, 'Underfloor heating')
% %                     
% %                         [~, ~, ~, T_nodal]  = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heat_Demand_Forc(ii), Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                     else
% %                 
% %                         [~, ~, ~, T_nodal]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain_Leg, Solar_Heat_Gain_For, Heat_Demand_Forc(ii), Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+ii), T_ground_hourly1(currenthouryear+ii-1), T_inlet, Temp_nodal(:,ii), Solar_Radiation_vertical_For, Solar_Radiation_For(currenthouryear+ii-1));
% %                     
% %                     end
% %                     
% %                 Temp_nodal(:,ii+1) = T_nodal;   % Needs to be saved for the forecast calculation
% % 
% %                 end
% %                 
% %             else
% %                 
% % %                 Heat_Demand_Forc(ii)                 = 0;        % There is no heat demand if the free floating conditions do not shift the temperature outside of the temperature set-points
% %                 Heat_Demand_Forc(ii)             = 0;
% %                 
% %             end
% %             
% %         end

        if isrow(Rounded_Hourly_temp_forecast_random)

            Day_forecasted_heat_demand             = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)) + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet) + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1)) - Internal_Heat_Gain_Leg - Solar_Heat_Gain_For1; % (mean(Thermal_Model.Internal_Heat_Gain(myiter-Time_ahead+1:myiter))); % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
         
        else
            
            Day_forecasted_heat_demand             = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet) + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1)) - Internal_Heat_Gain_Leg - Solar_Heat_Gain_For1; % (mean(Thermal_Model.Internal_Heat_Gain(myiter-Time_ahead+1:myiter))); % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
            
        end

%          Heat_Demand_forecast_corrected         = Day_forecasted_heat_demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_inside_forecast - Temp_inside_forecast_corrected);
% 
%          Sum_day_heat_demand_forecast           = sum(Heat_Demand_forecast_corrected);
         
         Sum_day_heat_demand_forecast   = sum(Day_forecasted_heat_demand);
% %             Sum_day_heat_demand_forecast   = sum(Heat_Demand_Forc);

         Thermal_Model.Forecast.Day_ahead_heat_demand_forecast = repelem(Sum_day_heat_demand_forecast,Time_ahead);


        
%         Day_forecasted_heat_demand(myiter+1:myiter+Time_ahead) = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet + Loss_floor * (Temp_inside_forecast - T_ground_hourly1(currenthouryear:currenthouryear+Time_ahead-1))) - (mean(Thermal_Model.Internal_Heat_Gain((myiter-Time_ahead+1:myiter)))); % - mean(Solar_Heat_Gain(m-Time_ahead+1:m)); % Consider some average estimation for the internal heat gain
%         Sum_day_heat_demand_forecast(myiter+1:myiter+Time_ahead) = sum(Day_forecasted_heat_demand(myiter+1:myiter+Time_ahead));
%         
%         Thermal_Model.Forecast.Day_ahead_heat_demand_forecast(myiter+1:myiter+Time_ahead) = Sum_day_heat_demand_forecast(myiter+1:myiter+Time_ahead);
        
    end
        
end

% Calculate mean temperatures to be used in the underfloor heating rules.

oneday  = 24;        % hours on one day
twodays = 48;        % hours on two days

if rem(myiter+1,oneday) == 0 && myiter+1 > 48
    
    Mean_yesterday      = mean(All_Var.Hourly_Temperature(Timeoffset + myiter+1-23:Timeoffset + myiter+1));
    Mean_2days          = mean(All_Var.Hourly_Temperature(Timeoffset + myiter + 1 - twodays+1:Timeoffset + myiter + 1));
    
    Thermal_Model.Temperature.Mean_yesterday    = Mean_yesterday;
    Thermal_Model.Temperature.Mean_2days        = Mean_2days;

    
elseif rem(myiter+1,oneday) == 0
    
    Mean_yesterday      = mean(All_Var.Hourly_Temperature(Timeoffset + myiter + 1 - 23:Timeoffset + myiter + 1));
    Mean_2days          = 0;
    
    Thermal_Model.Temperature.Mean_yesterday    = Mean_yesterday;
    Thermal_Model.Temperature.Mean_2days        = Mean_2days;

elseif myiter == 0
    
    Mean_yesterday  = 0;
    Mean_2days      = 0;
    
    Thermal_Model.Temperature.Mean_yesterday    = Mean_yesterday;
    Thermal_Model.Temperature.Mean_2days        = Mean_2days;

    
% end
% 
% if myiter + 1 < Time_Sim.nbrstep.(Input_Data.Headers) && myiter + 1 > 48 && rem(myiter+1,24) == 0
%     
% Mean_yesterday              = repelem(Mean_yesterday,24);
% Mean_2days                  = repelem(Mean_2days,24);

else
    
    Mean_yesterday  = Thermal_Model.Temperature.Mean_yesterday;
    Mean_2days      = Thermal_Model.Temperature.Mean_2days;

end

%% Start the heating model!

if myiter+1 == 3500
    a = 0;
end

% Start by calculating the heat demand as a function to temperature setting:

%             Heat_Demand         = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            if strcmp(Heating_Tech,'Time Set Temp') == 1 && (timehour < 6 || timehour >= 23 || (timehour > 9 && timehour < 17))
                Temp_Set                        = Temp_Set(2);  % ADDED LATER
%                 Heat_Demand                 = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
%                 Heat_Demand_Temp_Set        = Heat_Demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set(2) - Temp_inside);
            elseif strcmp(Heating_Tech,'Time Set Temp') == 1 
                Temp_Set                        = Temp_Set(1);  % ADDED LATER
%                 Heat_Demand                 = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
%                 Heat_Demand_Temp_Set        = Heat_Demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set(1) - Temp_inside);
%             else
%                 Heat_Demand                 = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
%                 Heat_Demand_Temp_Set        = Heat_Demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set - Temp_inside);
            end
            
            % Test of hourly heat demand calculation with dynamic simulatin
            % from the standard ISO 52016-1
            
            if strcmp(Heating_Tech, 'Underfloor heating')
                
                Heater_Power                    = 0;
            [T_inside0, ~, T_operative0, ~] = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            HeatingNeed = T_inside0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
            CoolingNeed = T_inside0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
                                        
            [T_insideMax, ~, T_operativeMax, ~]  = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Max_Input, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);

            
            if HeatingNeed || CoolingNeed   % If there is heating or cooling need, calculate the heat demand to achieve the heating or cooling set point
                                
                if HeatingNeed
                
                    Heat_Demand             = Max_Input * ((Temp_Set - T_inside0)/(T_insideMax - T_inside0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature
%                     Heat_Demand             = Dwelling_env_heat * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature

                    Heat_Demand_Temp_Set    = Heat_Demand;
                    Heat_Demand_Upper_Temp_Limit = Max_Input * ((Temp_Set_Heating_Upper_Limit - T_inside0)/(T_insideMax - T_inside0));
                
                else
                    
                    Heat_Demand             = Max_Input * ((Temp_cooling - T_inside0)/(T_insideMax - T_inside0));
%                     Heat_Demand             = Dwelling_env_heat * ((Temp_cooling - T_operative0)/(T_operativeMax - T_operative0));
                    Heat_Demand_Temp_Set    = Heat_Demand;
                    Heat_Demand_Upper_Temp_Limit = 0;
                    
                end
                
            else
                
                Heat_Demand                 = 0;        % There is no heat demand if the free floating conditions do not shift the temperature outside of the temperature set-points
                Heat_Demand_Temp_Set        = Max_Input * ((Temp_Set - T_inside0)/(T_insideMax - T_inside0));
%                 Heat_Demand_Temp_Set        = Dwelling_env_heat * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature

                Heat_Demand_Upper_Temp_Limit = Max_Input * ((Temp_Set_Heating_Upper_Limit - T_inside0)/(T_insideMax - T_inside0));

                
            end
            
            
            else
            
            Heater_Power                    = 0;
            [T_inside0, ~, T_operative0, ~] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            HeatingNeed = T_inside0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
            CoolingNeed = T_inside0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling
                                        
            [T_insideMax, ~, T_operativeMax, ~]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Dwelling_env_heat, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);

            
            if HeatingNeed || CoolingNeed   % If there is heating or cooling need, calculate the heat demand to achieve the heating or cooling set point
                                
                if HeatingNeed
                
                    Heat_Demand             = Dwelling_env_heat * ((Temp_Set - T_inside0)/(T_insideMax - T_inside0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature
%                     Heat_Demand             = Dwelling_env_heat * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature

                    Heat_Demand_Temp_Set    = Heat_Demand;
                    
                    Heat_Demand_Upper_Temp_Limit = Dwelling_env_heat * ((Temp_Set_Heating_Upper_Limit - T_inside0)/(T_insideMax - T_inside0));
                
                else
                    
                    Heat_Demand             = Dwelling_env_heat * ((Temp_cooling - T_inside0)/(T_insideMax - T_inside0));
%                     Heat_Demand             = Dwelling_env_heat * ((Temp_cooling - T_operative0)/(T_operativeMax - T_operative0));
                    Heat_Demand_Temp_Set    = Heat_Demand;
                    
                    Heat_Demand_Upper_Temp_Limit = 0;
                    
                end
                
            else
                
                Heat_Demand                 = 0;        % There is no heat demand if the free floating conditions do not shift the temperature outside of the temperature set-points
                Heat_Demand_Temp_Set        = Dwelling_env_heat * ((Temp_Set - T_inside0)/(T_insideMax - T_inside0));
%                 Heat_Demand_Temp_Set        = Dwelling_env_heat * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature

                Heat_Demand_Upper_Temp_Limit = Dwelling_env_heat * ((Temp_Set_Heating_Upper_Limit - T_inside0)/(T_insideMax - T_inside0));

                
            end
            
            end
            
            Heat_Demand_Manual             = Dwelling_env_heat * ((Temp_inside - T_inside0)/(T_insideMax - T_inside0));



%             Heat_Demand_Temp_Set        = Heat_Demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set - Temp_inside);
            
%             Heat_Demand_ComfortLimit    = Heat_Demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (LowerTempLimit - Temp_inside);
%             
%             Heat_Demand_Cooling         = Heat_Demand + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_cooling - Temp_inside);
            
%             Internal_Heat_Gain_Leg      = lgte * lgts * (0.1 * 6 + 0.6 * 3 + 0.6 * 2);      % From Decree of the Ministry of the Environment




            % If heat demand is negative the indoor temperature starts to
            % rise without cooling. The cooling system is assigned when
            % indoor temperature increases over a threshold value and the
            % heat demand is negative. Otherwise the heating system is
            % operated, which has its own rules.
            
            if Temp_inside > Temp_cooling && Heat_Demand <= 0
                
                % Cooling system is operated!
                Heater_Power            = 0;
                Space_Heating           = 0;
                Total_Heating           = 0;
                PhotoVoltaic_Elec_Heat  = 0;
                
                % The amount of cooling needed in the system to achieve the
                % cooling temperature limit
                
                Cooling_Power = Heat_Demand;  %Heat_Demand_Cooling;
                
%                 Cooling_Power   = 0; % For the simulation of DSM.
                
                Cooling_Heat_Demand = Heat_Demand + Cooling_Impact; %Heat_Demand_Cooling + Cooling_Impact;
                
                % Calculate inside temperature using indoor temperature function.
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Cooling_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;

            
            % Test the state of the thermal comfort with the current values
            % as the difference with radiative temperature may change the
            % feeling
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved = 1;
                    Thermal_comfort_wasnt_achieved = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved = 1;
                    Thermal_comfort_achieved = 0;
                    
            else 
                
                Thermal_comfort_wasnt_achieved  = 0;
                Thermal_comfort_achieved        = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)    = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1) = Thermal_comfort_wasnt_achieved;
            
            
            if isfield(Thermal_Model.Heating, 'CurrentCapacity')
                if size(Thermal_Model.Heating.CurrentCapacity,2) == myiter
                    Thermal_Model.Heating.CurrentCapacity(myiter+1) = Thermal_Model.Heating.CurrentCapacity(myiter);
                end
            end
                
            else
            
switch(Heating_Tech)
    
    case 'Constant'
        % Constant heating technology considers to keep the inside
        % temperature in a constant set temperature unless the internal
        % heat gains or heat from outdoors is increasing it.
       
            
            % Calculate the heat demand of the house. This is the amount of
            % energy the building loses through conduction and convection
            % with the addition of heat from internal heat sources.
            
%             Heat_Demand         = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            % After heat demand call the electric heating function in order
            % to decide the amount of heating.
            
            [Heater_Power, Total_Heating]    = Constant_Temperature_Setting(Temp_inside, Temp_Set, Heat_Demand, House_Volume, Building_Storage, Dwelling_env_heat, Space_Heating_Efficiency, Heating_Ventil, Temperature);
            
            PhotoVoltaic_Elec_Heat           = 0;    % Assumed that no PV generation is used in heating
            
            
            % Calculate inside temperature using indoor temperature function.
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;

            
            % Test the state of the thermal comfort with the current values
            % as the difference with radiative temperature may change the
            % feeling
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved = 1;
                    Thermal_comfort_wasnt_achieved = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved = 1;
                    Thermal_comfort_achieved = 0;
                    
            else 
                
                Thermal_comfort_wasnt_achieved  = 0;
                Thermal_comfort_achieved        = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)    = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1) = Thermal_comfort_wasnt_achieved;
            
            Thermal_Model.Heating.HeaterPower(myiter+1)                         = Heater_Power;


    
    case 'Time Set Temp'
        
        % The heating is done based on time set temperatures. Thus the
        % thermostat varies the temperature based on the temperature
        % setting.
        
                        
%             Heat_Demand      = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            % Call the time setting function
            
            [Heater_Power, ~, Total_Heating] = Time_Temperature_Setting(Temp_inside, Temp_Set, timehour, Heat_Demand, House_Volume, Building_Storage, Dwelling_env_heat, Space_Heating_Efficiency, Heating_Ventil, Temperature);
            
            PhotoVoltaic_Elec_Heat = 0;     % Assume the PV generation is not used in heating
            
            
            % Temperature indoor

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;

            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. Comfort limits can be
                % changed
                
                    Thermal_comfort_achieved        = 1;
                    Thermal_comfort_wasnt_achieved  = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved  = 1;
                    Thermal_comfort_achieved        = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved  = 0;
                    Thermal_comfort_achieved        = 0;          
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;

  
        
    case 'Manual'
        
        % The heating is defined through having manual heater, that the
        % user manually adjusts. The heater has six possible settings.
        
        if Thermal_Model.Heating.Set_Up > 0
            a = 1;
        end

%         if Temp_inside < 16
%             Heat_Demand      = (Total_Loss) * (Temp_Set - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
%         end

            [Heater_Power, ~, Total_Heating, Set_Up] = Manually_controlled_heating(Max_heating_capacity, Dwelling_env_heat, tenancy, Heat_Demand, UpperTempLimit, Space_Heating_Efficiency, Heating_Ventil, Temp_inside, myiter, Thermal_Model.Heating.Set_Up, LowerTempLimit, Heat_Demand_Temp_Set, Temperature, Heat_Demand_Manual);
            
            PhotoVoltaic_Elec_Heat = 0;     % Assumed no PV is used in heating
            
            % Save the set-up for future use, if building is unoccupied.

            Thermal_Model.Heating.Set_Up       = Set_Up;

            % Temperature indoor
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;

            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
                        
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)        = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)     = Thermal_comfort_wasnt_achieved;

 
         
    case 'PV with heating load shifting'
        
        % The heating of the building is done partially by using
        % electricity generation from PV panels. The system does not
        % include batteries nor considers net metering.
        
        % First, start by checking the PV utilization and give error in
        % case they are not in use.
            
            if PV_usage == 0
                error('PV panels are not considered to be on! Choose "Install PV", add wanted values and try again.')
            end
        
                        
            % Heat demand calculation. First step uses the default values
            % as inside temperature, while the next steps use the
            % differences in the previous temperatures to the current
            % outside temperature.
            
%             Heat_Demand      = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            % Call for the electric heating function.
            
            [Heater_Power, ~, Total_Heating, Gain1, Saved_money1, PhotoVoltaic_Elec_Heat] = PV_load_shifting(Temp_inside, PV_usage, PowerPV, Heat_Demand, LowerTempLimit, UpperTempLimit, Dwelling_env_heat, Space_Heating_Efficiency, RTP(RTP_offset+myiter+1), Heating_Ventil, Max_heating_capacity, Temp_Set, Heat_Demand_Temp_Set, Heat_Demand_Upper_Temp_Limit);

            % Save Gain and saved money

            Thermal_Model.Economics.Gain(myiter+1)                  = Gain1;
            Thermal_Model.Economics.SavedMoneyModel(myiter+1)       = Saved_money1;
            
            % Calculate the indoor temperature.
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            

            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), T_inside, T_radiative, myiter+1);            
                        
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0; 
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)= Thermal_comfort_wasnt_achieved;
            
            if T_inside < LowerTempLimit && PMV < -ComfortLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
                
                [T_insideMaxNew, ~, ~, ~]  = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, (Dwelling_env_heat-Heater_Power), Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);

                Extra_heater    = (Dwelling_env_heat - Heater_Power) * ((Temp_Set - T_inside)/(T_insideMaxNew - T_inside));
                
%                 Extra_heater        = ((1.2 * House_Volume * 1.007 + Building_Storage) * (LowerTempLimit - (T_inside)))/3.6;    % Extra Heater may have some difficulties on having too big values in the beginning
                
                if Extra_heater + Heater_Power > Dwelling_env_heat          % Cannot be more than the maximum capacity
                    
                    Extra_heater    = Dwelling_env_heat - Heater_Power;
                    
                elseif Extra_heater < 0
                    
                    Extra_heater    = 0;
                    
                end
                
            
                
                % Inside temperature calculation with the extra heater.
                
%                 Heater_Power        = Heater_Power + Extra_heater;
                Total_Heating       = Total_Heating + Extra_heater/Space_Heating_Efficiency; 
                
                
                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, (Heater_Power + Extra_heater), Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                

                
                % Check of thermal comfort
            
                [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
                if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                = 1;
                    Thermal_comfort_wasnt_achieved          = 0;
                    
                elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                    % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved          = 1;
                    Thermal_comfort_achieved                = 0;
                    
                end
            
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;

            else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
            
            end

        
    case 'PV_net_metering'
        
        % Heating is done partially by using electricity from PV panels
        % when they have electricity generation. The excess electricity is
        % considered to be supplied to the grid with net metering scheme,
        % so that the supplied electricity can be used later on from grid. 
        
        if m == 1
            
            State = 0;          % State of the battery is 0, as there is no battery. Need to be zero for the simulation.
            
            % Heat demand calculation.
            
            Heat_Demand(m)      = (Total_Loss) * (Temp_inside(m) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
            
            % Call the electricity heating function. 
            
            [Space_Heating(m), ~, Price, Total_Heating(m), Heater_Power(m), ~, Current_capacity(m), Extra_PV_power(m), Gain, Saved_money, State, PhotoVoltaic_Elec_Heat(m), Elec_value_battery] = Electric_heating1(Input_Data, Time_Sim, All_Var, Total_Loss, Loss_floor, Heat_recovery_ventil_annual, Temp_Set, House_Volume, Heat_Demand(m), Internal_Heat_Gain(m), T_ground_hourly(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m), Occupancy, m, Set_Up, Heating_Tech, Ventil_type, Met_rate(m), Heating_Ventil(m), Current_capacity(m), Temperature_core(m), Dwelling_env_heat, PowerPV(m), LowerTempLimit, UpperTempLimit, Max_heating_capacity, Ventilation_heater, State, LowerPriceLimit, UpperPriceLimit, Elec_value_battery(m), Nbr_batteries, RTP);
            
            % Assign variables from the outputs.
            
            Space_Heating(m)    = Space_Heating(m);
            Total_Heating(m)    = Total_Heating(m);
            Heater_Power(m)     = Heater_Power(m);
            PhotoVoltaic_Elec_Heat(m)= PhotoVoltaic_Elec_Heat(m);
            Extra_PV_power(m)   = Extra_PV_power(m);
            Current_capacity(m) = Current_capacity(m);
            Price1(m)           = Price;
            Gain1(m)            = Gain;
            Saved_money1(m)     = Saved_money;
            
            % Inside temperature calculation.
            
%             Temp_inside(m)      = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m));
 
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside(m)      = T_inside;
            Temp_radiative(m)   = T_radiative;
            Temp_operative(m)   = T_operative;
            Temperatures_nodal(:,m) = Temperatures1;

            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
                        
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy(m) == 1
                % Thermal comfort has been achieved. These values can be
                % changed
                    Thermal_comfort_achieved(m) = 1;
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy(m) == 1
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved(m) = 1;
            end

        else
            
            Heat_Demand(m)      = (Total_Loss) * (Temp_inside(m-1) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m-1) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
            
            [Space_Heating(m), ~, Price, Total_Heating(m), Heater_Power(m), ~, Current_capacity(m), Extra_PV_power(m), Gain, Saved_money, State, PhotoVoltaic_Elec_Heat(m), Elec_value_battery] = Electric_heating1(Input_Data, Time_Sim, All_Var, Total_Loss, Loss_floor, Heat_recovery_ventil_annual, Temp_Set, House_Volume, Heat_Demand(m), Internal_Heat_Gain(m), T_ground_hourly(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m-1), Occupancy, m, Set_Up(m-1), Heating_Tech, Ventil_type, Met_rate(m), Heating_Ventil(m), Current_capacity(m-1), Temperature_core(m-1), Dwelling_env_heat, PowerPV(m), LowerTempLimit, UpperTempLimit, Max_heating_capacity, Ventilation_heater, State, LowerPriceLimit, UpperPriceLimit, Elec_value_battery, Nbr_batteries, RTP);
            
            Space_Heating(m)    = Space_Heating(m);
            Total_Heating(m)    = Total_Heating(m);
            Heater_Power(m)     = Heater_Power(m);
            PhotoVoltaic_Elec_Heat(m)= PhotoVoltaic_Elec_Heat(m);
            Extra_PV_power(m)   = Extra_PV_power(m);
            Current_capacity(m) = Current_capacity(m);
            Price1(m)           = Price;
            Gain1(m)            = Gain;
            Saved_money1(m)     = Saved_money;
            
%             Temp_inside(m)      = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));  
 
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Loss_Ventil(m), Flow_rate(m), Internal_Heat_Gain(m), Solar_Heat_Gain(m), Heater_Power(m), Temperature(m), T_ground_hourly(m), T_inlet(m), Temperatures_nodal(:,m-1), Solar_Radiation_vertical(m), Solar_radiation(m));
            
            Temp_inside(m)      = T_inside;
            Temp_radiative(m)   = T_radiative;
            Temp_operative(m)   = T_operative;
            Temperatures_nodal(:,m) = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
                        
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy(m) == 1
                % Thermal comfort has been achieved. These values can be
                % changed
                    Thermal_comfort_achieved(m) = 1;
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy(m) == 1
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved(m) = 1;
            end


            % If heating does not increase the temperature over the lower
            % temperature limit, an extra heater is used to increase the
            % temperature to the lower limit. At the same time the total
            % heating capacity needs to be lower than the maximum heating
            % capacity.
            
            if Temp_inside(m) < LowerTempLimit && Heater_Power(m) < Dwelling_env_heat && PMV < -0.7
                
                % Calculate the extra heating need to the lower temperature
                % limit.
                
                Extra_heater(m)             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside(m))))/3.6;
                
                % Total heating capacity cannot be over maximum heating
                % capacity. If it goes over the maximum heating capacity,
                % the extra heating is adjusted so that total heating
                % capacity is equal to the maximum capacity. At the same
                % time if the heating need is not met, cumulative bigger
                % heater calculator is run in order to see how many times
                % there is need to have bigger heater to meet the thermal
                % comfort temperatures. 
                
                if Extra_heater(m) + Heater_Power(m) > Dwelling_env_heat
                    Extra_heater(m)         = Dwelling_env_heat - Heater_Power(m);
                    Heater_Power(m)         = Heater_Power(m) + Extra_heater(m);
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                end
                
                % Assign total heating, new inside temperature and cost
                % from the extra heater.
                
                Total_Heating(m)            = Total_Heating(m) + Extra_heater(m);
                
                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Loss_Ventil(m), Flow_rate(m), Internal_Heat_Gain(m), Solar_Heat_Gain(m), Heater_Power(m), Temperature(m), T_ground_hourly(m), T_inlet(m), Temperatures_nodal(:,m-1), Solar_Radiation_vertical(m), Solar_radiation(m));
            
                Temp_inside(m)      = T_inside;
                Temp_radiative(m)   = T_radiative;
                Temp_operative(m)   = T_operative;
                Temperatures_nodal(:,m) = Temperatures1;

                % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
                        
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy(m) == 1
                % Thermal comfort has been achieved. These values can be
                % changed
                    Thermal_comfort_achieved(m) = 1;
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy(m) == 1
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved(m) = 1;
            end
                
%                 Temp_inside(m)              = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
                Price1(m)                   = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
                
            end
            
        end
        
        case 'Underfloor heating'
            
            % Main heating technology is underfloor heating with different
            % possible loading possibilities. 
            
            if myiter == 11
                a = 4;
            end
            
            switch(Charging_strategy)
                
                case 'Set Time'
                    
                    % Input to the underfloor heating is based on set
                    % times. Used hours and input matrix are set as zeros
                    % for the simulation to go through.
                    
                    Used_Hours = 0;
                    Input_Matrix = [0 0];
                    
                case 'Cheapest Hours'
                    
                    % Consider Cheapest Hours to load the underfloor
                    % heater. The heating hours are firstly based on real
                    % time price forecasts for the day. The cheapest hours
                    % are adjusted so that if the actual price is lower
                    % than what the system originally considered to be for
                    % the heating time from the real time price forecast, 
                    % the new time is added to heating hour and the most 
                    % expensive not used hour is removed from the list. The
                    % list is renewed at the change of day.
                    
                    Used_Hours      = Thermal_Model.Heating.Used_hours_underfloor;
                    
                    if myiter == 0
                        Input_Matrix = zeros(Charging_Time,2);
                    else
                        Input_Matrix    = Thermal_Model.Heating.Input_Matrix;
                    end
                
                if (mod(myiter+1,24) == 0 || myiter == 0) && myiter + 1 ~= Time_Sim.nbrstep.(Input_Data.Headers)                % Only consider full days 
                    
                    RTP_forecast1   = RTP_forecast(RTP_offset+myiter+1:RTP_offset+myiter+24); % Assign the forecasted RTP for the next 24 hours to a vector.
                    Used_Hours      = 0;                    % Used hours starts from zero and everytime there is input to system it is considered to be one used hour. Consideration is that there is limit amount of input hours.
                    
                    % Re-arrange the hours and prices so that the cheapest
                    % period hours are the only ones left.
                    
                    [~,Cheapest_Hours]              = sort(RTP_forecast1);
                    Cheapest_Hours                  = Cheapest_Hours(1:Charging_Time);
                    Cheapest_Hours                  = sort(Cheapest_Hours);
                    Input_Matrix                    = [Cheapest_Hours RTP_forecast1(Cheapest_Hours)];
                    
                    Thermal_Model.Heating.Input_Matrix  = Input_Matrix;

                end


                % Check if the actual RTP price is lower than the unused
                % heating hours in the prediction
                
%                 if Used_Hours < Charging_Time
%                     
%                     Input_Matrix                                    = Thermal_Model.Heating.Input_Matrix;
%                     
%                     if any(RTP(RTP_offset+myiter+1) < Input_Matrix(Used_Hours+1:end,2)) == 1 && any(timehour + 1 < Input_Matrix(Used_Hours+1,1)) == 1
%                         
%                         
%                         [~, Priciest_Hour]                          = max(Input_Matrix(Used_Hours+1:end,2));
%                         Input_Matrix(Priciest_Hour+Used_Hours,:)    = [timehour+1 RTP(RTP_offset+myiter+1)];
%                         [Cheapest_Hours, location]                  = sort(Input_Matrix(:,1));
%                         Input_Matrix                                = [Cheapest_Hours Input_Matrix(location,2)];
%                         
%                         Thermal_Model.Heating.Input_Matrix          = Input_Matrix;
%                         
%                     end
%                     
%                 end
                
                case 'PV charging'
                    
                    % Third scenario is that PV panels are used to charge
                    % the underfloor heating, when available.
                    
                    Used_Hours = 0; % Consider adding monetary gains from the extra PV!
                    Input_Matrix = [0 0];
                
            end
                        
            % Heat Demand estimation calculations for the next day
            
            if myiter+1 == 1
%             if rem(myiter+1,Time_ahead) == 0
                
                Heat_Demand_estimation_hourly                           = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+Time_ahead)') + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - repelem(T_inlet,Time_ahead)) + Loss_floor * (Temp_inside_forecast - repelem(T_ground_hourly,Time_ahead)) - repelem(Internal_Heat_Gain_Leg,Time_ahead); % repelem(Internal_Heat_Gain,Time_ahead);
                Heat_Demand_estimation                                  = sum(Heat_Demand_estimation_hourly);
                Heat_Demand_estimation                                  = repelem(Heat_Demand_estimation,Time_ahead);
                
                Thermal_Model.Forecast.Heat_Demand_forecast = Heat_Demand_estimation;

            elseif rem(myiter+1,Time_ahead) == 0
                
                if myiter + 1 == Time_Sim.nbrstep.(Input_Data.Headers)        % Last hour is assigned to the previous one for the simulation to go through.
                    
                    Heat_Demand_estimation = repelem(Thermal_Model.Forecast.Heat_Demand_forecast(end),Time_ahead);
                    
                else
                    
                    Heat_Demand_estimation = repelem(Sum_day_heat_demand_forecast,Time_ahead);
                    
                end
                
                Thermal_Model.Forecast.Heat_Demand_forecast = Heat_Demand_estimation;
                
            else
                
                Heat_Demand_estimation = Thermal_Model.Forecast.Heat_Demand_forecast;
                
            end
            
%             Temperatures_nodal(1,10) = Temp_inside_forecast(1);
            
            % Assign cumulative input to zero in the beginning.
            
            if myiter == 0
                
                Current_capacity            = 0;
                Cumulative_input            = 0;
                Previous_Temperature_core   = 0;
                Cumulative_input_PV         = 0;
                
            elseif rem(myiter+1,Time_ahead) == 0
                
                Cumulative_input            = 0;
                Current_capacity            = Thermal_Model.Heating.CurrentCapacity(myiter);
                Previous_Temperature_core   = Thermal_Model.Heating.Previous_Temperature_core;
                Cumulative_input_PV         = 0;
                
            else
                
                Cumulative_input            = Thermal_Model.Heating.CumInput;
                Current_capacity            = Thermal_Model.Heating.CurrentCapacity(myiter);
                Previous_Temperature_core   = Thermal_Model.Heating.Previous_Temperature_core;
                Cumulative_input_PV         = Thermal_Model.Heating.Cumulative_input_PV; 
                
            end
            
            
            % Calculate the actual heat demand for the hour.
            
%             Heat_Demand          = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            % Call for thermal storage function which is used to calculate
            % the heat output to be delivered to indoor.
            
            if myiter == 700
                x = 0;
            end
            
            [Input, Current_capacity, PhotoVoltaic_Elec_Heat, Extra_PV, Used_Hours, Cumulative_input, Previous_Temperature_core, Cumulative_input_PV] = Underfloor_heating(Charging_Time, Dwelling_env_heat, Underfloor_heating_efficiency, RTP(RTP_offset+myiter+1), timehour, Temperature, Mean_yesterday, Heat_Demand, Current_capacity, Heat_Demand_estimation(rem(myiter,Time_ahead)+1), Used_Hours, PV_usage, PowerPV, Daily_estimated_production_by_month(Thermal_Model.currenthouryear), Cumulative_input, Temp_inside, LowerTempLimit, Charging_strategy, lgts, lgte, myiter, Charging_Time, Previous_Temperature_core, Heating_Ventil, Ventilation_heater, Temp_Set, Cumulative_input_PV, Input_Matrix, UpperTempLimit);
            
            
            % Outputs to variables.
            

            Gain1                   = Extra_PV/1000 * RTP(RTP_offset+myiter+1)/100;
            Saved_money1            = (PowerPV * 1000 - Extra_PV * 1000)/1000 * RTP(RTP_offset+myiter+1)/100;
            Cumulative_input        = Cumulative_input + Input;
            

            Thermal_Model.Heating.Used_hours_underfloor       = Used_Hours;
            Thermal_Model.Economics.Gain(myiter+1)            = Gain1;
            Thermal_Model.Economics.SavedMoney(myiter+1)      = Saved_money1;
            Thermal_Model.Heating.CumInput                    = Cumulative_input;
            Thermal_Model.Heating.CurrentCapacity(myiter+1)   = Current_capacity;
            Thermal_Model.Heating.Previous_Temperature_core   = Previous_Temperature_core;
            Thermal_Model.Heating.Input(myiter+1)             = Input;
            Thermal_Model.Heating.Cumulative_input_PV         = Cumulative_input_PV;
            
            
            % Assign cumulative input and renew it every 24 hours.
            
%             if rem(myiter+1,Time_ahead) == 0
%                 Cumulative_input = 0;
%             else

%                 Cumulative_input = Cumulative_input + Input;
                
%             end
            
            % Extra heater cannot be under zero.
            
%             if Extra_heater(m) < 0
%                 Extra_heater(m) = 0;
%             end
            
%             Heater_Power(m) = Heater_Power(m) + Extra_heater(m);
%             Total_Heating(m) = Input(m) + Extra_heater(m) + Heating_Ventil(m); 
            
            % Inside temperature and cost calculations for extra heater.
            
%             Temp_inside(m)          = (((Heater_Power(m) + Extra_heater(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007)) + (Temp_inside(m));

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature_underfloor(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Input, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);

            
%                 Temp_inside         = T_inside;
%                 Temp_radiative      = T_radiative;
%                 Temp_operative      = T_operative;
%                 Temperatures_nodal  = Temperatures1;
                
                % Assign input again considering the efficiency losses
%                 Input(m) = Input(m)/Underfloor_heating_efficiency;          % Efficiency from the National building code of Finland D5
            
                % Total Heating is electricity used at time step
%                 Total_Heating        = Input + Extra_heater + Heating_Ventil;
                
           % Check of thermal comfort
                        
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), T_inside, T_radiative, myiter+1);            
                        
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                % Thermal comfort has been achieved. These values can be
                % changed
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)    = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1) = Thermal_comfort_wasnt_achieved;

%             if T_inside < LowerTempLimit && PMV < -ComfortLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
% %             if T_inside < Temp_Set && PMV < -ComfortLimit
%                 
%                 Extra_heater        = ((1.2 * House_Volume * 1.007 + Building_Storage) * (LowerTempLimit - T_inside))/3.6;    % Extra Heater may have some difficulties on having too big values in the beginning
% %                 Extra_heater        = ((1.2 * House_Volume * 1.007 + Building_Storage) * (Temp_Set - T_inside))/3.6;
%                 
%                 if Extra_heater > Dwelling_env_heat          % Cannot be more than the maximum capacity
%                     
%                     Extra_heater    = Dwelling_env_heat;
%                     
%                 elseif Extra_heater < 0
%                     
%                     Extra_heater    = 0;
%                     
%                 end
%                 
%             
%                 
%                 % Inside temperature calculation with the extra heater.
%                 
% %                 Heater_Power        = Heater_Power + Extra_heater;
% %                 Total_Heating       = Input + Extra_heater/Space_Heating_Efficiency + Heating_Ventil; 
%                 
% %                 Temp_inside(m)      = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
%                 
%                 [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature_underfloor_extraheater1(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Extra_heater, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation, Input);
%             
%                 Temp_inside         = T_inside;
%                 Temp_radiative      = T_radiative;
%                 Temp_operative      = T_operative;
%                 Temperatures_nodal  = Temperatures1;
%                 
% 
%                 
%                 % Check of thermal comfort
%             
%                 [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
%             
%                 if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
%                 % Thermal comfort has been achieved. These values can be
%                 % changed
%                 
%                     Thermal_comfort_achieved                = 1;
%                     Thermal_comfort_wasnt_achieved          = 0;
%                     
%                 elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
%                 
%                 % Thermal comfort wasn't achieved with tenancy
%                     Thermal_comfort_wasnt_achieved          = 1;
%                     Thermal_comfort_achieved                = 0;
%                     
%                 end
%             
%                 Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)            = Thermal_comfort_achieved;
%                 Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)         = Thermal_comfort_wasnt_achieved;
% 
%             else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                Extra_heater        = 0;
                
%             end
            
%             Total_Heating = Input + Extra_heater/Space_Heating_Efficiency + Heating_Ventil;
              Total_Heating = Input/Underfloor_heating_efficiency + Heating_Ventil;


%     case 'Simple_Radiating_Storage_Heater'
%         
%         if m == 1
%             
%             Heat_Demand(m)          = (Total_Loss) * (Temp_inside(m) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
%             
%             [Heater_Power(m), Space_Heating(m), Total_Heating(m), Price, Current_capacity(m), Temperature_core(m), Input(m)] = Thermal_Storage_Building(Input_Data, Time_Sim, All_Var, Temp_Set, House_Volume, Heat_Demand(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m), Occupancy(m), m, Heating_Tech, Current_capacity(m), Temperature_core(m), Heating_Ventil(m));            
%             
%             Space_Heating(m)        = Space_Heating(m);
%             Total_Heating(m)        = Total_Heating(m);
%             Heater_Power(m)         = Heater_Power(m);
%             Price1(m)               = Price;
%             Current_capacity(m)     = Current_capacity(m);
%             Temperature_core(m)     = Temperature_core(m);
%             Input(m)                = Input(m);
%             Extra_heater(m)         = Heat_Demand(m) - Heater_Power(m);
%             
%             if Extra_heater(m) < 0
%                 Extra_heater(m) = 0;
%             end
%             
%             Temp_inside(m)          = (((Heater_Power(m) + Extra_heater(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007)) + (Temp_inside(m));
%             Price1(m)               = Price1(m) + Extra_heater(m)/1000 * RTP(m);
%             
%         else
%             
%             Heat_Demand(m)          = (Total_Loss) * (Temp_inside(m-1) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m-1) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
%             
%             [Heater_Power(m), Space_Heating(m), Total_Heating(m), Price, Current_capacity(m), Temperature_core(m), Input(m)] = Thermal_Storage_Building(Input_Data, Time_Sim, All_Var, Temp_Set, House_Volume, Heat_Demand(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m-1), Occupancy(m), m, Heating_Tech, Current_capacity(m-1), Temperature_core(m-1), Heating_Ventil(m));            
%             
%             Space_Heating(m)        = Space_Heating(m);
%             Total_Heating(m)        = Total_Heating(m);
%             Heater_Power(m)         = Heater_Power(m);
%             Price1(m)               = Price;
%             Current_capacity(m)     = Current_capacity(m);
%             Temperature_core(m)     = Temperature_core(m);
%             Input(m)                = Input(m);
%             Temp_inside(m)          = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));  
%             
%             if Temp_inside(m) < LowerTempLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
%                 Extra_heater(m)     = ((1.2 * House_Volume * 1.007 + Building_Storage) * (LowerTempLimit - (Temp_inside(m))))/3.6;
%                 Temp_inside(m)      = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
%                 Price1(m)           = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
%             end
%         end
%         
%     case 'Smart_Radiating_Storage_Heater'
%         
%         if m == 1
%             
%             Heat_Demand(m)          = (Total_Loss) * (Temp_inside(m) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
%             
%             [Dwelling_env_heat, Space_Heating(m), ~, Price, Total_Heating(m), Heater_Power(m), ~, Current_capacity(m), Temperature_core(m)] = Electric_heating(Input_Data, Time_Sim, All_Var, Total_Loss, Loss_floor, Heat_recovery_ventil_annual, Temp_Set, House_Volume, Heat_Demand(m), Internal_Heat_Gain(m), T_ground_hourly(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m), Occupancy, m, Set_Up, Heating_Tech, Ventil_type, Met_rate(m), Heating_Ventil(m), Current_capacity(m), Temperature_core(m), RTP);
%             
%             Space_Heating(m)        = Space_Heating(m);
%             Total_Heating(m)        = Total_Heating(m);
%             Heater_Power(m)         = Heater_Power(m);
%             Price1(m)               = Price;
%             Current_capacity(m)     = Current_capacity(m);
%             Temp_inside(m)          = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007)) + (Temp_inside(m));
%             
%             if Temp_inside(m) < LowerTempLimit    % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
%                 Extra_heater(m)     = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside(m))))/3.6;
%                 Temp_inside(m)      = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
%                 Price1(m)           = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
%             end
%             
%         else
%             
%             Heat_Demand(m)          = (Total_Loss) * (Temp_inside(m-1) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m-1) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
%             
%             if m < 24
%                 
%                 [Dwelling_env_heat, Space_Heating(m), ~, Price, Total_Heating(m), Heater_Power(m), ~, Current_capacity(m), Temperature_core(m)] = Electric_heating(Input_Data, Time_Sim, All_Var, Total_Loss, Loss_floor, Heat_recovery_ventil_annual, Temp_Set, House_Volume, Heat_Demand(m), Internal_Heat_Gain(m), T_ground_hourly(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m-1), Occupancy, m, Set_Up(m-1), Heating_Tech, Ventil_type, Met_rate(m), Heating_Ventil(m), Current_capacity(m-1), Temperature_core(m-1), RTP);
%                 
%                 Space_Heating(m)    = Space_Heating(m);
%                 Total_Heating(m)    = Total_Heating(m);
%                 Heater_Power(m)     = Heater_Power(m);
%                 Price1(m)           = Price;
%                 Current_capacity(m) = Current_capacity(m);
%                 Temperature_core(m) = Temperature_core(m);
%                 Temp_inside(m)      = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));  
%                 
%                 if Temp_inside(m) < LowerTempLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
%                     Extra_heater(m) = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside(m))))/3.6;
%                     Temp_inside(m)  = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
%                     Price1(m)       = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
%                 end
%                 
%             else 
%                 
%                 [Dwelling_env_heat, Space_Heating(m), ~, Price, Total_Heating(m), Heater_Power(m), ~, Current_capacity(m), Temperature_core(m)] = Electric_heating(Input_Data, Time_Sim, All_Var, Total_Loss, Loss_floor, Heat_recovery_ventil_annual, Temp_Set, House_Volume, Heat_Demand(m-24:m), Internal_Heat_Gain(m), T_ground_hourly(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m-1), Occupancy, m, Set_Up(m-1), Heating_Tech, Ventil_type, Met_rate(m), Heating_Ventil(m), Current_capacity(m-1), Temperature_core(m-1), RTP);
%                 
%                 Space_Heating(m)    = Space_Heating(m);
%                 Total_Heating(m)    = Total_Heating(m);
%                 Heater_Power(m)     = Heater_Power(m);
%                 Price1(m)           = Price;
%                 Current_capacity(m) = Current_capacity(m);
%                 Temperature_core(m) = Temperature_core(m);
%                 Temp_inside(m)      = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));  
%                 
%                 if Temp_inside(m) < LowerTempLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
%                     Extra_heater(m) = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside(m))))/3.6;
%                     Temp_inside(m)  = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
%                     Price1(m)       = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
%                 end
%             end
%         end
        
    case 'Convective Storage Heater'
        
        % Calculations for convective storage heater. Convective storage
        % heater can apply convective heat and not only radiative heat.
        
        if m == 1
            
            Used_Hours = 0;
            Input_Matrix = 0;
            Cumulative_input = 0;
            
            Heat_Demand_estimation_hourly(m:m+23)   = (Total_Loss) * (Temp_inside_forecast - Rounded_Hourly_temp_forecast_random(m:m+23)) + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_inside_forecast - T_inlet(m:m+23)) + Loss_floor * (Temp_inside_forecast - T_ground_hourly(m:m+23)) - Internal_Heat_Gain(m:m+23);
            Heat_Demand_estimation(m)               = sum(Heat_Demand_estimation_hourly(m:m+23));
            Heat_Demand_estimation(m:m+23)          = repelem(Heat_Demand_estimation(m),24);
            
            Heat_Demand(m)                          = (Total_Loss) * (Temp_inside(m) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
            
            [Heater_Power(m), Space_Heating(m), Total_Heating(m), Price, Current_capacity(m), Temperature_core(m), Input(m), ~, Extra_PV] = Thermal_Storage_Building(Input_Data, Time_Sim, All_Var, Temp_Set, House_Volume, Heat_Demand(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m), Occupancy(m), m, Heating_Tech, Current_capacity(m), Temperature_core(m), Heating_Ventil(m), Dwelling_env_heat, Heat_Demand_estimation(m), Mean_yesterday(rem(myiter+1,Time_ahead+1)), Heating_Time_and_technology, Used_Hours, Input_Matrix, Daily_estimated_production_by_month(m), Cumulative_input, PowerPV(m), Ventilation_heater, LowerTempLimit);            
            
            Space_Heating(m)                        = Space_Heating(m);
            Total_Heating(m)                        = Total_Heating(m);
            Heater_Power(m)                         = Heater_Power(m);
            PhotoVoltaic_Elec_Heat(m)               = PhotoVoltaic_Elec_Heat(m);
            Price1(m)                               = Price;
            Gain1(m)                                = Extra_PV/1000 * RTP(m)/100;
            Saved_money1(m)                         = (PowerPV(m) - Extra_PV)/1000 * RTP(m)/100;
            Current_capacity(m)                     = Current_capacity(m);
            Temperature_core(m)                     = Temperature_core(m);
            Input(m)                                = Input(m);
            Extra_heater(m)                         = Heat_Demand(m) - Heater_Power(m);
            
            if Extra_heater(m) < 0
                Extra_heater(m) = 0;
            end
            
%             Temp_inside(m)                          = (((Heater_Power(m) + Extra_heater(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007)) + (Temp_inside(m));
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside(m)      = T_inside;
            Temp_radiative(m)   = T_radiative;
            Temp_operative(m)   = T_operative;
            Temperatures_nodal(:,m) = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;


            Total_Heating(m)                        = Total_Heating(m) + Extra_heater(m);
            Price1(m)                               = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
            
        else
            
            % Other hours
            
            % Recalculate the heat demand estimation every 24 hours.
            if rem(m,Time_ahead) == 0
                if m == Time_Sim.nbrstep+24
                    Heat_Demand_estimation(m)      = Heat_Demand_estimation(m-1);
                else
                    Heat_Demand_estimation(m:m+23) = Sum_day_heat_demand_forecast(m:m+23);
                end
            end
            
            Heat_Demand(m)                          = (Total_Loss) * (Temp_inside(m-1) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m-1) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
            
            [Heater_Power(m), Space_Heating(m), Total_Heating(m), Price, Current_capacity(m), Temperature_core(m), Input(m), ~, Extra_PV] = Thermal_Storage_Building(Input_Data, Time_Sim, All_Var, Temp_Set, House_Volume, Heat_Demand(m), Temperature(m), timehour(m), Building_Storage, Temp_inside(m-1), Occupancy(m), m, Heating_Tech, Current_capacity(m-1), Temperature_core(m-1), Heating_Ventil(m), Dwelling_env_heat, Heat_Demand_estimation(m), Mean_yesterday(rem(myiter+1,Time_ahead+1)), Heating_Time_and_technology, Used_Hours, Input_Matrix, Daily_estimated_production_by_month(m), Cumulative_input, PowerPV(m), Ventilation_heater, LowerTempLimit);            
            
            Space_Heating(m)                        = Space_Heating(m);
            Total_Heating(m)                        = Total_Heating(m);
            Heater_Power(m)                         = Heater_Power(m);
            PhotoVoltaic_Elec_Heat(m)               = PhotoVoltaic_Elec_Heat(m);
            Price1(m)                               = Price;
            Gain1(m)                                = Extra_PV/1000 * RTP(m)/100;
            Saved_money1(m)                         = (PowerPV(m) - Extra_PV)/1000 * RTP(m)/100;
            Current_capacity(m)                     = Current_capacity(m);
            Temperature_core(m)                     = Temperature_core(m);
            Input(m)                                = Input(m);
            
            
%             Temp_inside(m)                          = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));  

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside(m)      = T_inside;
            Temp_radiative(m)   = T_radiative;
            Temp_operative(m)   = T_operative;
            Temperatures_nodal(:,m) = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                % Thermal comfort has been achieved. These values can be
                % changed
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;

            
            if Temp_inside(m) < LowerTempLimit && PMV < -ComfortLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
                Extra_heater(m)                     = ((1.2 * House_Volume * 1.007 + Building_Storage) * (LowerTempLimit - (Temp_inside(m))))/3.6;
%                 Temp_inside(m)                      = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);

                Heater_Power(m) = Heater_Power(m) + Extra_heater(m);

                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Loss_Ventil(m), Flow_rate(m), Internal_Heat_Gain(m), Solar_Heat_Gain(m), Heater_Power(m), Temperature(m), T_ground_hourly(m), T_inlet(m), Temperatures_nodal(:,m-1), Solar_Radiation_vertical(m), Solar_radiation(m));
            
                Temp_inside(m)      = T_inside;
                Temp_radiative(m)   = T_radiative;
                Temp_operative(m)   = T_operative;
                Temperatures_nodal(:,m) = Temperatures1;
                
                % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy(m) == 1
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;


                
                if Extra_heater > 0
                    Total_Heating(m) = Total_Heating(m) + Extra_heater(m);
                end
                
                Price1(m)                           = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
            end
        end
        
        case 'PV with battery'
            
            % This case presents a heating scheme including own generation
            % from the photovoltaics and including battery storage system
            % in. The PV generation is emphasized in the system so that the
            % electricity generated there will firstly be used in to heat
            % the building and in the case of excess electricity generation
            % will charge the battery. The battery is then discharged when
            % there is heating need but no PV generation present. In other
            % cases the electricity is taken from the grid to heat up the
            % building.
            
            
            Battery_Usage = 1;
            
            if myiter == 0
                
                State               = 0;
                Nbr_of_cycles       = 0;
                Current_capacity    = 0;
                
                Thermal_Model.Heating.State = State;
                Thermal_Model.Battery.NbrCycles = Nbr_of_cycles;
                Thermal_Model.Battery.CurrentCapacity(myiter+1) = Current_capacity;
                
            else
                
                State               = Thermal_Model.Heating.State;
                Nbr_of_cycles       = Thermal_Model.Battery.NbrCycles;
                Current_capacity    = Thermal_Model.Battery.CurrentCapacity(myiter);
                
            end
            
            
%             Heat_Demand          = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            [Heater_Power, ~, Total_Heating, ~, Gain1, Saved_money1, PhotoVoltaic_Elec_Heat, Current_capacity, State] = PV_battery(Temp_inside, PV_usage, PowerPV, Heat_Demand, LowerTempLimit, UpperTempLimit, Dwelling_env_heat, Space_Heating_Efficiency, RTP(RTP_offset+myiter+1), Heating_Ventil, Max_heating_capacity, Nbr_batteries, State, Current_capacity, Temp_Set, Heat_Demand_Temp_Set, BatteryCapacity, Round_trip_efficiency);
            
            
            if Thermal_Model.Heating.State == 1 && State == 0 && Thermal_Model.Heating.State ~=State
                
                Nbr_of_cycles = Nbr_of_cycles + 1;          % If the battery has finished both charging and discharging cycles, one full cycle has happened.
                
            end
            
            Thermal_Model.Heating.State                       = State;
            Thermal_Model.Battery.NbrCycles                   = Nbr_of_cycles;
            Thermal_Model.Battery.CurrentCapacity(myiter+1)   = Current_capacity;
            Thermal_Model.Economics.Gain(myiter+1)            = Gain1;
            Thermal_Model.Economics.SavedMoney(myiter+1)      = Saved_money1;
            
%             Temp_inside(m)          = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007)) + (Temp_inside(m));

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
%             Temp_inside         = T_inside;
%             Temp_radiative      = T_radiative;
%             Temp_operative      = T_operative;
%             Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), T_inside, T_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else 
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;
            
            if T_inside < Temp_Set && PMV < -ComfortLimit %LowerTempLimit && PMV < -ComfortLimit       % If minimum temperature is not achieved with storage heater, there need to be extra heater to provide heat to the system
                
                Extra_heater        = ((1.2 * House_Volume * 1.007 + Building_Storage) * (LowerTempLimit - (T_inside)))/3.6;    % Extra Heater may have some difficulties on having too big values in the beginning
                
                if Extra_heater + Heater_Power > Dwelling_env_heat          % Cannot be more than the maximum capacity
                    
                    Extra_heater    = Dwelling_env_heat - Heater_Power;
                    
                elseif Extra_heater < 0
                    
                    Extra_heater    = 0;
                    
                end
                
            
                
                % Inside temperature calculation with the extra heater.
                
%                 Heater_Power        = Heater_Power + Extra_heater;
                Total_Heating       = Total_Heating + Extra_heater/Space_Heating_Efficiency; 
                
                
                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, (Heater_Power + Extra_heater), Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                

                
                % Check of thermal comfort
            
                [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
                if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                = 1;
                    Thermal_comfort_wasnt_achieved          = 0;
                    
                elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                    % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved          = 1;
                    Thermal_comfort_achieved                = 0;
                    
                end
            
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;

            else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
            
            end
            
        
    case 'Battery from grid'
        
        % This case is used to present a system with the possibility to
        % charge battery from the grid and use the battery to heat up the
        % building in the case of the purchased electricity price being 
        % higher than the value of the electricity in the battery. Thus,
        % battery would provide cheaper electricity than the grid. 
        
        if RTP_offset ~= 0
            Offset_to_previous_year = (datenum(Time_Sim.timeyear-1,1,1)-datenum(Time_Sim.YearStartSim2004,1,1)) * 24;
            Offset_to_current_year  = (datenum(Time_Sim.timeyear,1,1)-datenum(Time_Sim.YearStartSim2004,1,1)) * 24;
            LowerPriceLimit = prctile(All_Var.Hourly_Real_Time_Pricing(Offset_to_previous_year:Offset_to_current_year),prcntage);    % Consider the real time price from earlier years if the simulation year is not the beginning of the database.
        else
            LowerPriceLimit = prctile(All_Var.Hourly_Real_Time_Pricing(1:8784),prcntage);    % When simulation begins at the beginning of the database, the first year is used in the price limit creation.
        end

        
            
            Battery_Usage = 1;
            
            if myiter == 0
                
                State               = 0;
                Nbr_of_cycles       = 0;
                Current_capacity    = 0;
                Elec_value_battery  = 0;
                State               = 0;
                
                Thermal_Model.Battery.State                         = State;
                Thermal_Model.Battery.NbrCycles                     = Nbr_of_cycles;
                Thermal_Model.Battery.CurrentCapacity(myiter+1)     = Current_capacity;
                Thermal_Model.Battery.ElectricityValue(myiter+1)    = Elec_value_battery;
                
            else
                
                State               = Thermal_Model.Battery.State;
                Nbr_of_cycles       = Thermal_Model.Battery.NbrCycles;
                Current_capacity    = Thermal_Model.Battery.CurrentCapacity(myiter);
                Elec_value_battery  = Thermal_Model.Battery.ElectricityValue(myiter);
                
            end
            

            
            UpperPriceLimit         = LowerPriceLimit + ((Battery_Price/Number_of_battery_cycles)/Min_discharge_cycle) + Profit_battery; % The upper price limit is the value of the electricity in the battery added by the costs associated to the investment and by the profit wanted per cycle. This price is used to determine the price limit to use the electricity from the battery.
            
            % Calculate the price used as the threshold value for the
            % battery charge. The lower price limit for charging is 
            % considered to be the 5th percentile from the real time price
            % from the year before.
            
%             Elec_value_battery(1) = 0;     % There is no electricity in the battery at time = 0
            
            % Calculate heat demand
            
%             Heat_Demand          = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            % Call electric heating function
            
            [Heater_Power, ~, Total_Heating, Gain1, Saved_money1, PhotoVoltaic_Elec_Heat, Current_capacity, State, Input] = Battery_from_the_grid(Temp_inside, LowerPriceLimit, UpperPriceLimit, Heat_Demand, LowerTempLimit, UpperTempLimit, Dwelling_env_heat, Space_Heating_Efficiency, RTP(RTP_offset+myiter+1), Heating_Ventil, Max_heating_capacity, Nbr_batteries, State, Current_capacity, Elec_value_battery, myiter, Temp_Set, Heat_Demand_Temp_Set, BatteryCapacity, Round_trip_efficiency);
            
            % Calculate the number of operating cycles. One cycles is
            % considered to have happened when the battery turns from
            % discharge state to charging state.

            if Thermal_Model.Battery.State == 1 && State == 0 && Thermal_Model.Battery.State ~=State
                
                Nbr_of_cycles = Nbr_of_cycles + 1;          % If the battery has finished both charging and discharging cycles, one full cycle has happened.
                
            end

            
            Thermal_Model.Battery.ElectricityValue(myiter+1)      = Elec_value_battery;
            Thermal_Model.Battery.CurrentCapacity(myiter+1)       = Current_capacity;
            Thermal_Model.Economics.Gain(myiter+1)                = Gain1;
            Thermal_Model.Economics.SavedMoney(myiter+1)          = Saved_money1;
            Thermal_Model.Battery.State                           = State;
            Thermal_Model.Battery.NbrCycles                       = Nbr_of_cycles;
        
            % Check that the temperature is within the limits and calculate
            % it 

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
%             Temp_inside         = T_inside;
%             Temp_radiative      = T_radiative;
%             Temp_operative      = T_operative;
%             Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), T_inside, T_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)    = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1) = Thermal_comfort_wasnt_achieved;

            
            % Apply extra heater if inside temperature drops too low
            
            if T_inside < Temp_Set && (Heater_Power + Input) < Dwelling_env_heat && PMV < -ComfortLimit %LowerTempLimit 
                
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (T_inside)))/3.6;
                
                if Extra_heater + Heater_Power + Input > Dwelling_env_heat
                    
                    Extra_heater            = Dwelling_env_heat - Heater_Power - Input;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                    
                end
                
                if Extra_heater < 0
                    
                    Extra_heater = 0;
                    
                end
                
                Total_Heating            = Total_Heating + Extra_heater/Space_Heating_Efficiency;
                Heater_Power             = Heater_Power + Extra_heater/Space_Heating_Efficiency;
                
                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                
                % Check of thermal comfort
            
                [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
                if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
                elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
                end
            
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;

            else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                
               
            end
            

            
    case 'Cost Optimized Heating'
        
        % This is a scheme were the heating is optimized based on the cost.
        % Linear Optimization is used to minimize costs so that the
        % temperature is within the limit values, and heating capacities
        % are considered. Outside temperature is from artificial weather
        % forecast, and forecasted real time price is used in the cost
        % minimization. This is used to consider if forecasted real time
        % price can be used as an indicator for the actual real time price.
        
        if myiter == 0
            
            % Calculate the heating scheme.
            
%             Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            [Heating_scheme]                = CostOptimizationHeating(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, RTP_forecast(RTP_offset+myiter+1:RTP_offset + myiter + nPeriods), Rounded_Hourly_temp_forecast_random(Timeoffset + myiter + 1 : Timeoffset + myiter + nPeriods), Dwelling_env_heat, Thermal_time_constant, Total_Heat_capacity, Total_Loss, N0, House_Volume, T_inlet, T_ground_hourly, Loss_floor, Internal_Heat_Gain, myiter+1, Heat_recovery_ventil_annual, Temp_inside, lgte, lgts, nPeriods, LowerTempLimit1, UpperTempLimit1, Solar_Heat_Gain_For1, Solar_Radiation_vertical_For1, Solar_Radiation_For, Temperatures_nodal);            
            
            Heating_scheme1(1:nPeriods)     = Heating_scheme;
            Heater_Power                    = Heating_scheme(1);
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
            PhotoVoltaic_Elec_Heat          = 0;                                        % Assumed no PV used in heating
 

            Thermal_Model.Heating.Heating_Scheme = Heating_scheme1;
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
%             Temp_inside         = T_inside;
%             Temp_radiative      = T_radiative;
%             Temp_operative      = T_operative;
%             Temperatures_nodal  = Temperatures1;
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), T_inside, T_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)          = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)       = Thermal_comfort_wasnt_achieved;

            if T_inside < LowerTempLimit && Heater_Power < Dwelling_env_heat && PMV < -ComfortLimit
                
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (T_inside)))/3.6;
                
                if Extra_heater + Heater_Power > Dwelling_env_heat
                    
                    Extra_heater            = Dwelling_env_heat - Heater_Power;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                    
                end
                
                Total_Heating               = Total_Heating + Extra_heater/Space_Heating_Efficiency;

                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, (Heater_Power + Extra_heater), Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside             = T_inside;
                Temp_radiative          = T_radiative;
                Temp_operative          = T_operative;
                Temperatures_nodal      = Temperatures1;
                
                % Check of thermal comfort
            
                [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
                if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
                elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
                else
                    
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;
                    
                end

                Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;
                
            else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;

            end
            
        elseif ~mod(myiter+1,nPeriods) == 0 
            
            % The heating scheme is only calculated every 24 hours, and in
            % other hours the optimized scheme is used. 
            
            Heating_scheme1                 = Thermal_Model.Heating.Heating_Scheme;
            
            Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            Heater_Power                    = Heating_scheme1(mod(myiter+1,nPeriods));
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
            PhotoVoltaic_Elec_Heat          = 0;
   
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
%             Temp_inside             = T_inside;
%             Temp_radiative          = T_radiative;
%             Temp_operative          = T_operative;
%             Temperatures_nodal      = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), T_inside, T_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;



            % If the optimized scheme cannot provide enough heat to keep
            % the temperature over lower temperature limit, an extra heat
            % is needed. This may come from scenario where the weather
            % forecast is wrong, making the heat demand higher than
            % expected. Heater Power cannot be higher than maximum heating
            % capacity.
            
            if T_inside < LowerTempLimit && Heater_Power < Dwelling_env_heat && PMV < -ComfortLimit
                
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (T_inside)))/3.6;
                
                if Extra_heater + Heater_Power > Dwelling_env_heat
                    
                    Extra_heater            = Dwelling_env_heat - Heater_Power;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                    
                end
                
                Total_Heating               = Total_Heating + Extra_heater/Space_Heating_Efficiency;
%                 Heater_Power                = Heater_Power + Extra_heater;
%                 Temp_inside(m)              = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);

                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, (Heater_Power + Extra_heater), Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside             = T_inside;
                Temp_radiative          = T_radiative;
                Temp_operative          = T_operative;
                Temperatures_nodal      = Temperatures1;
                
                % Check of thermal comfort
            
                [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
                if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
                elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                else
                    
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;                    
                    
                end

                Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)    = Thermal_comfort_achieved;
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1) = Thermal_comfort_wasnt_achieved;
                
            else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;

            
            end
            
            
        elseif myiter+1 ~= Time_Sim.nbrstep.(Input_Data.Headers)           % Other than the last hour that do not include optimizing
            
            Heating_scheme1                 = Thermal_Model.Heating.Heating_Scheme;
            
%             Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            [Heating_scheme]                = CostOptimizationHeating(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, RTP_forecast(RTP_offset+myiter+1:RTP_offset + myiter + nPeriods), Rounded_Hourly_temp_forecast_random(Timeoffset + myiter + 1 : Timeoffset + myiter + nPeriods), Dwelling_env_heat, Thermal_time_constant, Total_Heat_capacity, Total_Loss, N0, House_Volume, T_inlet, T_ground_hourly, Loss_floor, Internal_Heat_Gain, myiter+1, Heat_recovery_ventil_annual, Temp_inside, lgte, lgts, nPeriods, LowerTempLimit1, UpperTempLimit1, Solar_Heat_Gain_For1, Solar_Radiation_vertical_For1, Solar_Radiation_For, Temperatures_nodal);            
            
            if isempty(Heating_scheme) == 1 && mean(All_Var.Hourly_Temperature(Timeoffset+myiter-nPeriods+1:Timeoffset+myiter+1)) > 15
                Heating_scheme              = zeros(1,nPeriods);
                
            elseif mean(All_Var.Hourly_Temperature(Timeoffset+1+myiter-nPeriods+1:Timeoffset+myiter+1)) > 15
                Heating_scheme              = zeros(1,nPeriods);
                
            elseif isempty(Heating_scheme) == 1
                Heating_scheme              = Heating_scheme1;
                
            end
            
            Heating_scheme1(1:nPeriods)     = Heating_scheme;
            Heater_Power                    = Heating_scheme1(1);
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
            PhotoVoltaic_Elec_Heat          = 0;

            Thermal_Model.Heating.Heating_Scheme  = Heating_scheme1;


            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;
            
            if T_inside < LowerTempLimit && Heater_Power < Dwelling_env_heat && PMV < -ComfortLimit
                
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (T_inside)))/3.6;
                
                if Extra_heater + Heater_Power > Dwelling_env_heat
                    
                    Extra_heater            = Dwelling_env_heat - Heater_Power;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                    
                end
                
                Total_Heating               = Total_Heating + Extra_heater/Space_Heating_Efficiency;

                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, (Heater_Power + Extra_heater), Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside             = T_inside;
                Temp_radiative          = T_radiative;
                Temp_operative          = T_operative;
                Temperatures_nodal      = Temperatures1;
                
                % Check of thermal comfort
            
                [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
                if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
                elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
                else
                    
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;
                    
                end

                Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)      = Thermal_comfort_achieved;
                Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1)   = Thermal_comfort_wasnt_achieved;
                
            else
                
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;

            end
            
        else        % Describes the last hour of the simulation
            
            Heating_scheme1                 = Thermal_Model.Heating.Heating_Scheme;

%             Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            Heater_Power                    = Heating_scheme1(end);
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
            PhotoVoltaic_Elec_Heat          = 0;

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            else
                
                    Thermal_comfort_wasnt_achieved      = 0;
                    Thermal_comfort_achieved            = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(myiter+1)    = Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(myiter+1) = Thermal_comfort_wasnt_achieved;


        end
        
        case 'Cost Optimized Heating_lower_limit'
            
            % Similar scenario than cost optimized, but including
            % considerations of lower capacity when outside temperature is
            % high enough. This could consider that the capacity could be
            % lowered from the utility when there is no need for it. At the
            % same time this would allow maximum peak shaving.
        
        if myiter+1 == 1
            
%             Heat_Demand                  = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            if Temperature > -10
                
                Dwelling_env_heat1 = Dwelling_env_heat * 0.75;
                
            else
                
                Dwelling_env_heat1 = Dwelling_env_heat;
                
            end
            
            [Heating_scheme] = CostOptimizationHeating(RTP_forecast(RTP_offset+myiter+1:RTP_offset+myiter+nPeriods), Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+nPeriods), Dwelling_env_heat1, Thermal_time_constant, Total_Heat_capacity, Total_Loss, N0, House_Volume, T_inlet, T_ground_hourly, Loss_floor, Internal_Heat_Gain, myiter+1, Heat_recovery_ventil_annual, Temp_inside, lgte, lgts, nPeriods, LowerTempLimit1, UpperTempLimit1);            
            
            Heating_scheme1(1:nPeriods)     = Heating_scheme;
            Heater_Power                    = Heating_scheme(mod(myiter+1/nPeriods));
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;
            
            Thermal_Model.Heating.Heating_Scheme(BuildSim,:) = Heating_scheme1;

            
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m));
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;


        elseif ~mod(myiter+1,nPeriods) == 0 
            
            Heating_scheme1                 = Thermal_Model.Heating.Heating_Scheme(BuildSim,:);
            
%             Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            Heater_Power                    = Heating_scheme1(mod(myiter+1,nPeriods));
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;

            if Temp_inside < LowerTempLimit && Heater_Power < Dwelling_env_heat
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside)))/3.6;
                
                if Extra_heater + Heater_Power > Dwelling_env_heat
                    Extra_heater            = Dwelling_env_heat - Heater_Power;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                end
                
                Total_Heating               = Total_Heating + Extra_heater;
                Heater_Power                = Heater_Power + Extra_heater;
%                 Temp_inside(m)              = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                
                % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;


%                 Price1(m)                   = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
            end
            
        elseif myiter ~= Time_Sim.nbrstep
            
            Heating_scheme1             = Thermal_Model.Heating.Heating_Scheme(BuildSim,:);

            
%             Heat_Demand                  = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            if Temperature > -10
                
                Dwelling_env_heat1 = Dwelling_env_heat * 0.75;
                
            else
                
                Dwelling_env_heat1 = Dwelling_env_heat;
                
            end
            
            [Heating_scheme] = CostOptimizationHeating(RTP_forecast(RTP_offset+myiter+1:RTP_offset+myiter+nPeriods), Rounded_Hourly_temp_forecast_random(Timeoffset+myiter+1:Timeoffset+myiter+nPeriods), Dwelling_env_heat1, Thermal_time_constant, Total_Heat_capacity, Total_Loss, N0, House_Volume, T_inlet, T_ground_hourly, Loss_floor, Internal_Heat_Gain, myiter+1, Heat_recovery_ventil_annual, Temp_inside, lgte, lgts, nPeriods, LowerTempLimit1, UpperTempLimit1);            
            
            if isempty(Heating_scheme) == 1 && mean(All_Var.Hourly_Temperature(Timeoffset+myiter-nPeriods+1:Timeoffset+myiter+1)) > 15
                Heating_scheme              = zeros(1,nPeriods);
                
            elseif mean(All_Var.Hourly_Temperature(Timeoffset+myiter-nPeriods+1:Timeoffset+myiter+1)) > 15
                Heating_scheme              = zeros(1,nPeriods);
                
            elseif isempty(Heating_scheme) == 1
                Heating_scheme              = Heating_scheme1;
                
            end
            
            Heating_scheme1(1:nPeriods)     = Heating_scheme;
            Heater_Power                    = Heating_scheme1(mod(myiter+1,nPeriods));
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;

            Thermal_Model.Heating.Heating_Scheme(BuildSim,:) = Heating_scheme1;


%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1)); 

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;

        else        % Describes the last step!
            
%             Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            Heater_Power                    = Heating_scheme1(end);
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;
%             Extra_PV_power(m)               = PowerPV(m);
            
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1)); 

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy(m) == 1
                
                % Thermal comfort wasn't achieved with tenancy
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;

            

        end
        
    case 'Adaptive optimum heating scheme'
        
        % This scheme considers adaptive heating scheme, where linear
        % optimization is used everytime the real time price is lower than
        % the forecasted.
        
        if myiter+1 == 1
            
            % Calculate the heating scheme.
            
%             Heat_Demand                  = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            [Heating_scheme] = CostOptimizationHeating(RTP_forecast(RTP_offset+myiter+1:RTP_offset + myiter + nPeriods), Rounded_Hourly_temp_forecast_random(Timeoffset + myiter + 1 : Timeoffset + myiter + nPeriods), Dwelling_env_heat, Thermal_time_constant, Total_Heat_capacity, Total_Loss, N0, House_Volume, T_inlet, T_ground_hourly, Loss_floor, Internal_Heat_Gain, m, Heat_recovery_ventil_annual, Temp_inside, lgte, lgts, nPeriods, LowerTempLimit1, UpperTempLimit1);            
            
            Heating_scheme1(1:nPeriods)     = Heating_scheme;
            Heater_Power                    = Heating_scheme(1);
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV/1000 * RTP/100;
%             Extra_PV_power(m)               = PowerPV;

            Thermal_Model.Heating.Heating_Scheme(BuildSim,:) = Heating_scheme1;


            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved            = 1;
                    Thermal_comfort_wasnt_achieved      = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved      = 1;
                    Thermal_comfort_achieved            = 0;
                    
            end
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;



            % Defining the nonzero time slots and amount of them
            Heating_on_hours                = nnz(Heating_scheme(1:nPeriods));
            Heating_on_times                = Heating_scheme(1:nPeriods) ~= 0;
            
            % Defining the day ahead prices of electricity for the heating
            % hours
            RTP_forecast_running            = RTP_forecast(RTP_offset+myiter+1:RTP_offset+myiter+24);
            
            Thermal_Model.Heating.Heating_hours(BuildSim)              = Heating_on_hours;
            Thermal_Model.Heating.Heating_times(BuildSim,:)            = Heating_on_times;
            Thermal_Model.Heating.RTP_forecast(BuildSim,1:nPeriods)    = RTP_forecast_running;

            
        elseif ~mod(myiter+1,nPeriods) == 0 && all(RTP(RTP_offset+myiter+1) > Thermal_Model.Heating.RTP_forecast(BuildSim,Thermal_Model.Heating.Heating_times)) %RTP_forecast_running(Heating_on_times))
            
            Heating_scheme1                 = Thermal_Model.Heating.Heating_Scheme(BuildSim,:);

            
            Heat_Demand                  = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            Heater_Power                 = Heating_scheme1(mod(myiter+1,nPeriods));
            Space_Heating                = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                = Space_Heating + Heating_Ventil(m);
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));
            
            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;

            Heating_on_hours                    = Thermal_Model.Heating.Heating_hours(BuildSim);
            Heating_on_times                    = Thermal_Model.Heating.Heating_times(BuildSim,:);

            if Heater_Power > 0
                Heating_on_hours               = Heating_on_hours -1;
                Heating_on_times(find(Heating_on_times,1)) = 0;
            end
            
            Thermal_Model.Heating.Heating_hours(BuildSim) = Heating_on_hours;
            Thermal_Model.Heating.Heating_times(BuildSim,:) = Heating_on_times;
            
            
            if Temp_inside < LowerTempLimit && Heater_Power < Dwelling_env_heat && PMV < -ComfortLimit
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside)))/3.6;
                
                if Extra_heater + Heater_Power > Dwelling_env_heat
                    Extra_heater         = Dwelling_env_heat - Heater_Power;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                end
                
                Total_Heating            = Total_Heating + Extra_heater;
                Heater_Power            = Heater_Power + Extra_heater;
%                 Temp_inside(m)              = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);

                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                
                % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate(m), Temperature, Temp_inside(m), Temp_radiative(m), m);
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;



%                 Gain1(m)                    = PowerPV(m)/1000 * RTP(m)/100;
            end
            
            
            
%             if any(RTP(m) < RTP_forecast_running(Heating_on_times))
%                 if any(timehour(m) < timehour(Heating_on_times)) && any(Heater_Power(m) < Heating_scheme1(Heating_on_times))
%                     [highest_cost_to_be, hour_of_highest_cost] = max(RTP_forecast_running(Heating_on_times));
%                     Highest_actual_hour     = find(Heating_on_times);
%                     Location_of_the_hour    = Highest_actual_hour(hour_of_highest_cost);
%                     
%             Heat_Demand(m)                  = (Total_Loss) * (Temp_inside(m-1) - Temperature(m)) + Loss_Ventil(m) + Loss_floor * (Temp_inside(m-1) - T_ground_hourly(m)) - Internal_Heat_Gain(m);
%             Heater_Power(m)                 = Heating_scheme1(m);
%             Space_Heating(m)                = Heater_Power(m)/Space_heating_efficiency;
%             Total_Heating(m)                = Space_Heating(m) + Heating_Ventil(m);
%             Price1(m)                       = Total_Heating(m)/1000 * RTP(m)/100;
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));
%             
%             if Heater_Power(m) > 0
%                 Heating_on_hours               = Heating_on_hours -1;
%                 Heating_on_times               = 
%             end
%             
%             
%             if Temp_inside(m) < LowerTempLimit && Heater_Power(m) < Dwelling_env_heat
%                 Extra_heater(m)             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside(m))))/3.6;
%                 
%                 if Extra_heater(m) + Heater_Power(m) > Dwelling_env_heat
%                     Extra_heater(m)         = Dwelling_env_heat - Heater_Power(m);
%                     BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
%                 end
%                 
%                 Total_Heating(m)            = Total_Heating(m) + Extra_heater(m);
%                 Temp_inside(m)              = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);
%                 Price1(m)                   = Price1(m) + Extra_heater(m)/1000 * RTP(m)/100;
%             end

        elseif myiter +1 < nPeriods             % Recalculation cannot be done in the first 24 hours
            
            Heating_scheme1             = Thermal_Model.Heating.Heating_Scheme(BuildSim,:);
            
            Heat_Demand                  = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            Heater_Power                 = Heating_scheme1(mod(myiter+1,nPeriods));
            Space_Heating                = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1));

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside         = T_inside;
            Temp_radiative      = T_radiative;
            Temp_operative      = T_operative;
            Temperatures_nodal  = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;

            Heating_on_hours                    = Thermal_Model.Heating.Heating_hours(BuildSim);
            Heating_on_times                    = Thermal_Model.Heating.Heating_times(BuildSim,:);

            

            if Heater_Power > 0
                Heating_on_hours               = Heating_on_hours -1;
                Heating_on_times(find(Heating_on_times,1)) = 0;
            end
            
            Thermal_Model.Heating.Heating_hours(BuildSim) = Heating_on_hours;
            Thermal_Model.Heating.Heating_times(BuildSim,:) = Heating_on_times;
            
            
            
            if Temp_inside < LowerTempLimit && Heater_Power < Dwelling_env_heat && PMV < -ComfortLimit
                Extra_heater             = ((1.2 * House_Volume * 1.007 + Building_Storage) + (LowerTempLimit - (Temp_inside)))/3.6;
                
                if Extra_heater + Heater_Power > Dwelling_env_heat
                    Extra_heater         = Dwelling_env_heat - Heater_Power;
                    BiggerHeaterNeedCalc    = BiggerHeaterNeedCalc + 1;
                end
                
                Total_Heating            = Total_Heating + Extra_heater;
                Heater_Power             = Heater_Power + Extra_heater;
%                 Temp_inside(m)              = (Extra_heater(m) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage) + Temp_inside(m);

                [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
                Temp_inside         = T_inside;
                Temp_radiative      = T_radiative;
                Temp_operative      = T_operative;
                Temperatures_nodal  = Temperatures1;
                
                % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;



            end
            
        else                % If the current RTP price is lower than estimated or the optimization time has run over 24 hours, then the optimization needs to be done again
            
            Heating_scheme1                 = Thermal_Model.Heating.Heating_Scheme(BuildSim,:);
            
            Heat_Demand                     = (Total_Loss) * (Temp_inside - Temperature) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly) - Internal_Heat_Gain;
            
            RTP_forecast                    = RTP;
            
            [Heating_scheme]                = CostOptimizationHeating(RTP_forecast(RTP_offset+myiter+1:RTP_offset + myiter + nPeriods), Rounded_Hourly_temp_forecast_random(Timeoffset + myiter + 1 : Timeoffset + myiter + nPeriods), Dwelling_env_heat, Thermal_time_constant, Total_Heat_capacity, Total_Loss, N0, House_Volume, T_inlet, T_ground_hourly, Loss_floor, Internal_Heat_Gain, m, Heat_recovery_ventil_annual, Temp_inside, lgte, lgts, nPeriods, LowerTempLimit1, UpperTempLimit1);            
            
            if isempty(Heating_scheme) == 1 && mean(All_Var.Hourly_Temperature(Timeoffset+myiter-nPeriods+1:Timeoffset+myiter+1)) > 15
                Heating_scheme              = zeros(1,nPeriods);
                
            elseif mean(All_Var.Hourly_Temperature(Timeoffset+myiter-nPeriods+1:Timeoffset+myiter+1)) > 15
                Heating_scheme              = zeros(1,nPeriods);
                
            elseif isempty(Heating_scheme) == 1
                Heating_scheme              = Heating_scheme1;
                
            end
            
            % Defining the nonzero time slots and amount of them
            if myiter +1 < Time_Sim.nbrstep - nPeriods
                Heating_on_hours                = nnz(Heater_Power(1:nPeriods));
                Heating_on_times                = Heater_Power(1:nPeriods) ~= 0;
            else
                Heating_on_hours                = nnz(Heater_Power(1:mod(Time_Sim.nbrstep,nPeriods)));
                Heating_on_times                = Heater_Power(1:mod(Time_Sim.nbrstep,nPeriods)) ~= 0;
            end
            
            % Defining the day ahead prices of electricity for the heating
            % hours
            RTP_forecast_running            = RTP_forecast(RTP_offset+myiter+1:RTP_offset+myiter+nPeriods);
            
            Thermal_Model.Heating.Heating_hours(BuildSim)              = Heating_on_hours;
            Thermal_Model.Heating.Heating_times(BuildSim,:)            = Heating_on_times;
            Thermal_Model.Heating.RTP_forecast(BuildSim,1:nPeriods)    = RTP_forecast_running;
            
            
            Heating_scheme1(1:nPeriods)     = Heating_scheme;
            Heater_Power                    = Heating_scheme1(mod(myiter+1,nPeriods));
            Space_Heating                   = Heater_Power/Space_Heating_Efficiency;
            Total_Heating                   = Space_Heating + Heating_Ventil;
%             Gain1(m)                        = PowerPV(m)/1000 * RTP(m)/100;
            
%             Temp_inside(m)                  = (((Heater_Power(m) - Heat_Demand(m)) * 3.600) / (1.2 * House_Volume * 1.007 + Building_Storage)) + (Temp_inside(m-1)); 

            [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Heat_Gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, Solar_Radiation_vertical, Solar_radiation);
            
            Temp_inside      = T_inside;
            Temp_radiative   = T_radiative;
            Temp_operative   = T_operative;
            Temperatures_nodal = Temperatures1;
            
            % Check of thermal comfort
            
            [PMV, PPD] = TestofThermalComfort(Met_rate, All_Var.Hourly_Temperature(Timeoffset+1:Timeoffset+Time_Sim.nbrstep.(Input_Data.Headers)), Temp_inside, Temp_radiative, myiter+1);            
            
            if PMV < ComfortLimit && PMV > -ComfortLimit && tenancy == 1
                
                % Thermal comfort has been achieved. These values can be
                % changed
                
                    Thermal_comfort_achieved                    = 1;
                    Thermal_comfort_wasnt_achieved              = 0;
                    
            elseif (PMV > ComfortLimit || PMV < -ComfortLimit) && tenancy == 1
                
                % Thermal comfort wasn't achieved with tenancy
                
                    Thermal_comfort_wasnt_achieved              = 1;
                    Thermal_comfort_achieved                    = 0;
                    
            end

            Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(BuildSim,myiter+1)= Thermal_comfort_achieved;
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(BuildSim,myiter+1)= Thermal_comfort_wasnt_achieved;



        end
        
        
    % Temperature after heating
    % Temp_w_heating(n+1) = ((Heater_Power(n) * 3.600) / (1.2 * House_Volume * 1.007)) + Temp_wo_heating(n); 
    % Temp_w_heating(n+1) = Temp_w_heating(n) - 273.15;
    % Temp_inside(n) = Temp_w_heating(n+1);
end
% end

        Cooling_Power = 0;  % When heating is on, no cooling power is used!
        Cooling_Heat_Demand = Cooling_Power + Cooling_Impact;
        
            end

%% Environmental emissions are calculated here!
% Start with calculating the CO2 emissions together as they are now based
% on generation method. The CO2 emissions are kg/kWh.

% Hourly_CO2 = sum(All_Var.Hourly_CO2_ReCiPe(:,1:6),2);       % As the CO2 emissions are by the generation technology, their sum is needed to have the overall emissions

% Start by defining the electricity from the grid used in heating or
% charging. Cooling power should be negative when used

if strcmp(Heating_Tech, 'Underfloor heating') == 1 || strcmp(Heating_Tech, 'Convective Storage Heater') == 1    % Storage Heaters need to have different consideration, as their inputs are taken from the grid, not the heating power from them
    %Heating_Power_from_Grid = (Input + Heating_Ventil + Extra_heater) - PhotoVoltaic_Elec_Heat;        % Grid based electricity is the difference in inputs and ventilation heating and PV based supply
    Heating_Power_from_Grid = Total_Heating - PhotoVoltaic_Elec_Heat - Cooling_Power;
    Heating_Power_from_Grid = Heating_Power_from_Grid/1000;                             % Assign it in kWh
elseif strcmp(Heating_Tech, 'Battery from grid') == 1
    Heating_Power_from_Grid = Total_Heating + Input - PhotoVoltaic_Elec_Heat - Cooling_Power;           % Battery from the grid uses direct space heating, input to the battery and photovoltaic elec heat is electricity discharged from the battery
    Heating_Power_from_Grid = Heating_Power_from_Grid/1000;
else
    Heating_Power_from_Grid = Total_Heating - PhotoVoltaic_Elec_Heat - Cooling_Power;         % Calculate the amount of power taken from the grid. It is needed for emissions calculations. This is also used to determine the electricity costs.
    Heating_Power_from_Grid = Heating_Power_from_Grid/1000;                   % Assign heating power to kWh.
end

if Heating_Power_from_Grid < 0
    Heating_Power_from_Grid = 0;
end

Total_Electricity_Consumption   = Heating_Power_from_Grid * 1000 + Ventil_Consumption + Motor_consumption;

if Heat_Demand > 0
    
    Total_EnergyDemand              = Heat_Demand + Heating_Ventil;
    Total_HeatDemand                = Heat_Demand + Heating_Ventil;
    
elseif Heat_Demand == 0
    
    Total_EnergyDemand              = Heating_Ventil;
    Total_HeatDemand                = Heating_Ventil;
    
else
    
    Total_EnergyDemand              = abs(Cooling_Heat_Demand);
    Total_HeatDemand                = 0;
    
end

% Clear extra variables and calculate total variables when the total
% simulation has run.

if myiter+1 == Time_Sim.nbrstep.(Input_Data.Headers)
    
    for i = 1:Time_Sim.nbrstep.(Input_Data.Headers)
        
        if Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved(i) == 1 && Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(i) == 1
            
            Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved(i) = 0;
            
        end
        
    end

Thermal_comfort_achieved                = cumsum(Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved);
Thermal_comfort_wasnt_achieved          = cumsum(Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved);
Thermal_comfort_achievement_total       = (Thermal_comfort_achieved(end)/(Thermal_comfort_achieved(end) + Thermal_comfort_wasnt_achieved(end))) * 100;

% Clear extra thermal comfort variables
% Thermal_Model.Thermal_Comfort = rmfield(Thermal_Model.Thermal_Comfort,Thermal_Comfort_Achieved);
% Thermal_Model.Thermal_Comfort = rmfield(Thermal_Model.Thermal_Comfort,Thermal_Comfort_notAchieved);

Thermal_Model.Thermal_Comfort_achievement = Thermal_comfort_achievement_total;

end

% Calculate the CO2 emission from the consumption.

% CO2_emissions           = Hourly_CO2.*Heating_Power_from_Grid'; %Hourly_CO2(Offset+1:Offset+Time_Sim.nbrstep+24).*Heating_Power_from_Grid';    % Consider the power from the grid.
% if PowerPV == 0
%     Hourly_PV_CO2_emissions = zeros(1,Time_Sim.nbrstep + 24)';
%     Heating_PV_CO2_emissions = zeros(1,Time_Sim.nbrstep + 24);
% else
%     Hourly_PV_CO2_emissions = PowerPV .* (PV_CO2/(sum(PowerPV)*30));         % Emissions in (k)g?. PV generation emission by kgCO2eq./kWh. This is done by calculating yearly production, multiplying it by the expected lifetime of PV panel of 30 years (Jungbluth & Tuchschmid 2007), and dividing total emissions by that value. Then hourly emissions are by the actual production.
%     Heating_PV_CO2_emissions = PhotoVoltaic_Elec_Heat .* (PV_CO2/(sum(PowerPV)*30)); % PV generation emissions by the PV generation used in heating.
% end
% % PV_CO2_emissions        = PowerPV * PV_CO2;                             % PV generation based emissions from LCA estimations (kgCO2eq./kWh)
% % Battery_CO2_emissions   = Nbr_of_cycles * Battery_CO2;                  % Add here battery related emissions. 
% % Total_hourly_emissions  = CO2_emissions + Hourly_PV_CO2_emissions;      % The total hourly emissions are a combination of grid and PV
% % Total_heating_hourly_emissions = CO2_emissions + Heating_PV_CO2_emissions';
% % Total_CO2               = sum(Total_hourly_emissions) + Battery_CO2_emissions; % Total emissions from the simulation time
% Total_CO2               = sum(CO2_emissions);
% Total_electricity_CO2   = Total_CO2 + sum((Hourly_CO2.*((Ventil_Consumption + Motor_consumption)'/1000)));
% Total_electricity_CO2_with_PV_consideration = sum(((Heating_Power_from_Grid + Ventil_Consumption/1000 + Motor_consumption/1000)).* Hourly_CO2');
% Total_electricity_CO2_with_PV_consideration_and_PV_heating = Total_electricity_CO2_with_PV_consideration + sum(Heating_PV_CO2_emissions);
% Total_electricity_CO2_with_PV_consideration_and_PV_emissions = Total_electricity_CO2_with_PV_consideration + sum(Hourly_PV_CO2_emissions);
% 
% fprintf('Need of bigger heater occurred %d times! \n', BiggerHeaterNeedCalc);
% 
% % Space_Heating_Efficiency = 0.95; % Annual value from the Ministry of the Environment
% % Space_Heating = Heater_Power / Space_Heating_Efficiency ;
% 
% Temp_inside         = Temp_inside(1:end-1);
% Total_Cost_Elec     = sum(Price1);
% Total_Cost_Elec_ventil = sum(Price1) + sum(((Ventil_Consumption + Motor_consumption)/1000)*RTP/100);
% Total_Cost          = Total_Cost_Elec * VAT + sum((Heating_Power_from_Grid * (Distribution_Cost + Elec_Tax))); % VAT for distribution is already included in the Electricity TAX!
% Total_Gain          = sum(Gain1);
% Total_Electricity_cost = Total_Cost + sum(((Ventil_Consumption + Motor_consumption)/1000)*RTP/100) * VAT + sum(((Ventil_Consumption + Motor_consumption)/1000) * (Distribution_Cost + Elec_Tax));
% 
% % For money saving consideration, with battery from the grid, VAT,
% % distribution costs and Electricity Taxes are paid from the bought
% % electricity as well. On the other hand, with own generation the savings
% % come from prevention of VAT, distribution costs and electricity taxes
% % that would have been paid if bought the same amount of electricity from
% % the grid.
% 
% if strcmp(Heating_Tech, 'Battery from grid') == 1
%     Total_Money_Saved   = sum(Saved_money1);
% else
%     Total_Money_Saved   = sum(Saved_money1) * VAT + sum((PhotoVoltaic_Elec_Heat/1000) * (Distribution_Cost + Elec_Tax)); % VAT for distribution is already included in the Electricity TAX!
% end
% 
% Annual_finance      = Total_Cost - Total_Gain;      % Negative values are for profit and positive for annual costs
% 
% % if strcmp(Heating_Tech, 'PV_net_metering') == 1
% %     PV_heating = cumsum(abs(PhotoVoltaic_Elec_Heat));
% %     Sum_PV_heating = PV_heating(end);
% %     Total_Money_Saved = sum(Saved_money1) * VAT + Sum_PV_heating/1000 * (Distribution_Cost + Elec_Tax);
% % end
% 
% % The payback-time of the PV and battery systems without taking the
% % technical constrains into notion.
% if PV_usage == 1 && sum(PowerPV) > 0 && Battery_Usage == 1
%     
%     Paybacktime_estimation = (PV_Price + Battery_Price)/(Total_Money_Saved + Total_Gain);
%     
% elseif PV_usage == 1
%     
%     Paybacktime_estimation = PV_Price/(Total_Money_Saved + Total_Gain);
%     
% elseif Battery_Usage == 1
%     
%     Paybacktime_estimation = Battery_Price/(Total_Money_Saved + Total_Gain);
%     
% else
%     
%     Paybacktime_estimation = 0;
%     
% end
% 
% % Calculate the utilization rate of internal heat gains divided to solar
% % radiation and to heat gain from appliances.
% 
% Appliances_utilization_rate     = zeros(1,Time_Sim.nbrstep + 24);
% Solar_utilization_rate          = zeros(1,Time_Sim.nbrstep + 24);
% % Heat_demand_wo_solar            = (Total_Loss) * (Temp_inside - Temperature(1:Time_Sim.nbrstep+24)') + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly(1:Time_Sim.nbrstep + 24)) - Solar_Heat_Gain;
% % Heat_demand_wo_appliances       = (Total_Loss) * (Temp_inside - Temperature(1:Time_Sim.nbrstep+24)') + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly(1:Time_Sim.nbrstep + 24)) - (Solar_Heat_Gain + Internal_Heat_Gain_Appl);
% 
% % Heat_demand_wo_solar            = (Total_Loss) * (Temp_inside - Temperature(1:Time_Sim.nbrstep+24)') + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly(1:Time_Sim.nbrstep + 24)) - Solar_Heat_Gain;
% % Heat_demand_wo_appliances       = (Total_Loss) * (Temp_inside - Temperature(1:Time_Sim.nbrstep+24)') + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly(1:Time_Sim.nbrstep + 24)) - (Solar_Heat_Gain + Internal_Heat_Gain_Appl);
% 
% Heat_demand_wo_solar            = (Total_Loss) * (Temp_inside - Temperature(1:Time_Sim.nbrstep+24)) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly(1:Time_Sim.nbrstep + 24)) - Solar_Heat_Gain;
% Heat_demand_wo_appliances       = (Total_Loss) * (Temp_inside - Temperature(1:Time_Sim.nbrstep+24)) + Loss_Ventil + Loss_floor * (Temp_inside - T_ground_hourly(1:Time_Sim.nbrstep + 24)) - (Solar_Heat_Gain + Internal_Heat_Gain_Appl);
% 
% 
% % Calculations for the hourly utilization rates. Passive solar gains are
% % emphasized over appliances.
% 
% for i = 1:Time_Sim.nbrstep + 24
%     if Heat_Demand(i) > 0
%         Appliances_utilization_rate(i)  = 1;
%         Solar_utilization_rate(i)       = 1;
%     elseif Heat_demand_wo_appliances(i) < 0
%         Appliances_utilization_rate(i)  = 0;
%         Solar_utilization_rate(i)       = 0;
%     elseif Heat_demand_wo_solar < 0
%         Appliances_utilization_rate(i)  = 0;
%         Solar_utilization_rate(i)       = (1 - ((Solar_Heat_Gain(i) - ((Total_Loss) * (Temp_inside(i-1) - Temperature(i)) + Loss_Ventil(i) + Loss_floor * (Temp_inside(i-1) - T_ground_hourly(i))))/Solar_Heat_Gain(i)));
%     else
%         Appliances_utilization_rate(i)  = (1 - ((Internal_Heat_Gain_Appl(i) - Heat_demand_wo_solar(i))/Internal_Heat_Gain_Appl(i)));
%         Solar_utilization_rate(i)       = 1;
%     end
% end
% 
% Appliances_utilization_rate_annual  = (mean(Appliances_utilization_rate) * 100);
% Solar_utilization_rate_annual       = (mean(Solar_utilization_rate) * 100);
% 
% % Monthly heater values
% % [Monthly_values, Daily_average_per_month] = Monthly_heating_values(Time_Sim, Heater_Power, Space_Heating, Heating_Ventil, Total_Heating);
% 
% % Heating hours of the day per month
% Hourlypercentage = Heating_time_of_day(Time_Sim, Heater_Power, Space_Heating, Heating_Ventil, Total_Heating);
% 
% fprintf('The annual utilization rates are %.2f for Appliances and %.2f for Solar Radiation! \n', Appliances_utilization_rate_annual, Solar_utilization_rate_annual);
% 
% % Estimation for the amount of times the thermal comfort of the system has
% % been achieved!
% 
% % Thermal_comfort_achievement = zeros(1,Time_Sim.nbrstep+24);
% % 
% % for i = 1:Time_Sim.nbrstep+24
% %     if Temp_inside(i) > LowerTempLimit2(i) && Temp_inside(i) < UpperTempLimit2(i)
% %         Thermal_comfort_achievement(i) = 1;
% %     else
% %         Thermal_comfort_achievement(i) = 0;
% %     end
% % end
% 
% % Thermal_comfort_achieved    = 0;
% % Times_occupant              = 0;
% % 
% % for i = 1:Time_Sim.nbrstep + 24
% %     if tenancy(i) == 1 && Temp_inside(i) > LowerTempLimit2(i) && Temp_inside(i) < UpperTempLimit2(i)
% %         Thermal_comfort_achieved = Thermal_comfort_achieved + 1;
% %         Times_occupant = Times_occupant + 1;
% %     elseif tenancy(i) == 1
% %         Times_occupant = Times_occupant + 1;
% %     end
% % end
% % 
% % Thermal_comfort_achievement_total = (Thermal_comfort_achieved/Times_occupant) * 100;
% 
% % Thermal comfort achievement is the proportion of occupant times when the
% % PMV was within the limits.
% 
% % First check duplicate values. In those cases the thermal comfort has been
% % achieved as the duplication comes from first not meeting the requirement
% % and then fulfilling it.
% 
% for i = 1:Time_Sim.nbrstep + 24
%     if Thermal_comfort_achieved(i) == 1 && Thermal_comfort_wasnt_achieved(i) == 1
%         Thermal_comfort_wasnt_achieved(i) = 0;
%     end
% end
% 
% Thermal_comfort_achieved                = cumsum(Thermal_comfort_achieved);
% Thermal_comfort_wasnt_achieved          = cumsum(Thermal_comfort_wasnt_achieved);
% Thermal_comfort_achievement_total       = (Thermal_comfort_achieved(end)/(Thermal_comfort_achieved(end) + Thermal_comfort_wasnt_achieved(end))) * 100;
% 
% % Thermal_comfort_achievement_total = mean(Thermal_comfort_achievement) * 100;
% 
% fprintf('The thermal comfort of the occupants was achieved %.2f percent of the time! \n', Thermal_comfort_achievement_total);
% 
% % Estimation for the PV self-consumption!
% if PowerPV == 0
%     PV_self_consumption = 0;
% else
%     PV_self_consumption = (sum(PowerPV) - sum(Extra_PV_power))/sum(PowerPV);
% end
% 
% if strcmp(Heating_Tech, 'PV_net_metering') == 1
%     PV_self_consumption = 1; %(sum(PhotoVoltaic_Elec_Heat) + sum(Extra_PV_power))/sum(PowerPV);
% end
% 
% fprintf('PV Self-consumption rate is %.2f \n', PV_self_consumption * 100);
% 
% Annual_recovery_efficiency = sum(Recovery_Power)/(sum(Total_Loss_from_ventil)-sum(Loss_Ventil));
% 
% fprintf('Annual heat recovery efficiency is %.2f \n', Annual_recovery_efficiency * 100);

if myiter == 720
    b = 0;
end

Thermal_Model.Temperature.Nodal_Temperatures(:,myiter+1)          = Temperatures_nodal; 
Thermal_Model.Temperature.IndoorTemperature(myiter+1)             = Temp_inside;
Thermal_Model.Temperature.OperativeTemperature(myiter+1)          = Temp_operative;
Thermal_Model.Heat_Demand.F_permeability                          = F_permeability;
Thermal_Model.Heat_Demand.Heat_Demand(myiter+1)                   = Heat_Demand;
Thermal_Model.Heat_Demand.Cooling_Demand(myiter+1)                = Cooling_Heat_Demand;
Thermal_Model.Heat_Demand.Active_Cooling_Demand(myiter+1)         = Cooling_Power;
Thermal_Model.Heat_Demand.Passive_Cooling_Demand(myiter+1)        = Cooling_Impact;
Thermal_Model.Internal_Heat_Gain(myiter+1)                        = Internal_Heat_Gain;
Thermal_Model.Total_Electricity_Consumption(myiter+1)             = Total_Electricity_Consumption;
Thermal_Model.PhotoVoltaic_Elec_Heat(myiter + 1)                  = PhotoVoltaic_Elec_Heat;
% Thermal_Model.Extra_Heater(myiter + 1)                            = Extra_heater;
Thermal_Model.Heating_Ventil(myiter + 1)                          = Heating_Ventil;
Thermal_Model.tenancy(myiter +1)                                  = tenancy;
Thermal_Model.Heat_Demand.Total_EnergyDemand(myiter+1)            = Total_EnergyDemand;
Thermal_Model.Heat_Demand.Total_HeatDemand(myiter+1)              = Total_HeatDemand;

Thermal_Model.Heat_Demand.Solar_Heat_Gain(myiter+1)               = Solar_Heat_Gain;

Thermal_Model.Temperature.T_inlet(myiter+1)                       = T_inlet;

Thermal_Model.FlowRate(myiter+1)                                  = Flow_rate;


if myiter + 1 == Time_Sim.nbrstep.(Input_Data.Headers) && Time_Sim.nbrstep.(Input_Data.Headers) <= 8784
    SimulationTime                                                  = datetime(Time_Sim.StartDate.(Input_Data.Headers),'ConvertFrom','datenum'):hours(1):datetime(Time_Sim.EndDate.(Input_Data.Headers),'ConvertFrom','datenum');
    Thermal_Model.Total.Total_Electricity_Consumption               = sum(Thermal_Model.Total_Electricity_Consumption);
    Thermal_Model.Total.Average_Indoor_Temperature                  = mean(Thermal_Model.Temperature.IndoorTemperature);
    
    [HourlyProfile]                                                 = HourlyHeatingPower(Thermal_Model.Total_Electricity_Consumption, Time_Sim, (Input_Data.Headers));
    Thermal_Model.Total.HourlyProfile                               = HourlyProfile;
    
    [Monthly_values, Daily_average_per_month]                       = Monthly_heating_values(SimulationTime, Thermal_Model.Total_Electricity_Consumption, (Input_Data.Headers));
    Thermal_Model.Total.Monthly_values                              = Monthly_values;
    Thermal_Model.Total.Daily_average_per_month                     = Daily_average_per_month;
    
    Thermal_Model.Total.EnergyDemand                                = sum(Thermal_Model.Heat_Demand.Total_EnergyDemand);
    Thermal_Model.Total.HeatDemand                                  = sum(Thermal_Model.Heat_Demand.Heat_Demand(Thermal_Model.Heat_Demand.Heat_Demand > 0)) + sum(Thermal_Model.Heating_Ventil);
    Thermal_Model.Total.CoolingDemand                               = sum(abs(Thermal_Model.Heat_Demand.Cooling_Demand));
    Thermal_Model.Total.ActiveCoolingDemand                         = sum(abs(Thermal_Model.Heat_Demand.Active_Cooling_Demand));
    Thermal_Model.Total.PassiveCoolingDemand                        = sum(abs(Thermal_Model.Heat_Demand.Passive_Cooling_Demand));
    
    Thermal_Model.Total.PeakHeat                                    = max(Thermal_Model.Heat_Demand.Total_EnergyDemand(Thermal_Model.Heat_Demand.Heat_Demand > 0));
    
    if any(Thermal_Model.Heat_Demand.Cooling_Demand < 0)
    
        Thermal_Model.Total.PeakCooling                                 = max(abs(Thermal_Model.Heat_Demand.Cooling_Demand));
    
    else
        
        Thermal_Model.Total.PeakCooling                                 = 0;
        
    end
    
elseif myiter + 1 == Time_Sim.nbrstep.(Input_Data.Headers) && Time_Sim.nbrstep.(Input_Data.Headers) >= 8784
    SimulationTime = datetime(Time_Sim.StartDate.(Input_Data.Headers),'ConvertFrom','datenum'):hours(1):datetime(Time_Sim.EndDate.(Input_Data.Headers)+23/24,'ConvertFrom','datenum');
%     SimulationTime = Time_Sim.StartDate.(Input_Data.Headers):hours(1):Time_Sim.EndDate.(Input_Data.Headers);
    SimulationYears = SimulationTime.Year;  
    SimulationYears = unique(SimulationYears);
%     Annual  = zeros(length(SimulationYears),length(SimulationTime));
    for m = 1:length(SimulationYears)
        Annual = SimulationTime.Year == SimulationYears(m);
        Thermal_Model.Yearly.Total_Electricity_Consumption(m)           = sum(Thermal_Model.Total_Electricity_Consumption(Annual));
        Thermal_Model.Yearly.AverageIndoorTemperature(m)                = mean(Thermal_Model.Temperature.IndoorTemperature(Annual));
        
        YearlyName                                                      = ['Year' num2str(SimulationYears(m))];
        
        [Monthly_values, Daily_average_per_month]                       = Monthly_heating_values(SimulationTime(Annual), Thermal_Model.Total_Electricity_Consumption(Annual), (Input_Data.Headers));
        Thermal_Model.Yearly.Monthly_values.SimulationYears.(YearlyName)        = Monthly_values;
        Thermal_Model.Total.Daily_average_per_month.SimulationYears.(YearlyName)= Daily_average_per_month;
        
            Thermal_Model.Yearly.EnergyDemand(m)                                = sum(Thermal_Model.Heat_Demand.Total_EnergyDemand(Annual));
            Thermal_Model.Yearly.HeatDemand(m)                                  = sum(Thermal_Model.Heat_Demand.Heat_Demand > 0 & Annual) + sum(Thermal_Model.Heating_Ventil(Annual));
            Thermal_Model.Yearly.CoolingDemand(m)                               = sum(abs(Thermal_Model.Heat_Demand.Cooling_Demand(Annual)));
            Thermal_Model.Yearly.ActiveCoolingDemand(m)                         = sum(abs(Thermal_Model.Heat_Demand.Active_Cooling_Demand(Annual)));
            Thermal_Model.Yearly.PassiveCoolingDemand(m)                        = sum(abs(Thermal_Model.Heat_Demand.Passive_Cooling_Demand(Annual)));
    
            Thermal_Model.Yearly.PeakHeat(m)                                    = max(Thermal_Model.Heat_Demand.Total_EnergyDemand > 0 & Annual);
    
            if any(Thermal_Model.Heat_Demand.Cooling_Demand(Annual) < 0)
    
                Thermal_Model.Yearly.PeakCooling(m)                                 = max(abs(Thermal_Model.Heat_Demand.Cooling_Demand(Annual)));
    
            else
        
                Thermal_Model.Yearly.PeakCooling(m)                                 = 0;
        
            end
        
    end
    
    Thermal_Model.Total.Total_Electricity_Consumption               = sum(Thermal_Model.Total_Electricity_Consumption);
    Thermal_Model.Total.Average_Indoor_Temperature                  = mean(Thermal_Model.Temperature.IndoorTemperature);
    
    Thermal_Model.Total.EnergyDemand                                = sum(Thermal_Model.Heat_Demand.Total_EnergyDemand);
    Thermal_Model.Total.HeatDemand                                  = sum(Thermal_Model.Heat_Demand.Heat_Demand(Thermal_Model.Heat_Demand.Heat_Demand > 0)) + sum(Thermal_Model.Heating_Ventil);
    Thermal_Model.Total.CoolingDemand                               = sum(abs(Thermal_Model.Heat_Demand.Cooling_Demand));
    Thermal_Model.Total.ActiveCoolingDemand                         = sum(abs(Thermal_Model.Heat_Demand.Active_Cooling_Demand));
    Thermal_Model.Total.PassiveCoolingDemand                        = sum(abs(Thermal_Model.Heat_Demand.Passive_Cooling_Demand));
    
    Thermal_Model.Total.PeakHeat                                    = max(Thermal_Model.Heat_Demand.Total_EnergyDemand(Thermal_Model.Heat_Demand.Heat_Demand > 0));
    
    if any(Thermal_Model.Heat_Demand.Cooling_Demand < 0)
    
        Thermal_Model.Total.PeakCooling                                 = max(abs(Thermal_Model.Heat_Demand.Cooling_Demand));
    
    else
        
        Thermal_Model.Total.PeakCooling                                 = 0;
        
    end
    
end
end


% Thermal_Model.Thermal_Comfort.Thermal_Comfort_Achieved.(Input_Data.Heading)(myiter+1)= Thermal_comfort_achieved;
% Thermal_Model.Thermal_Comfort.Thermal_Comfort_notAchieved.(Input_Data.Heading)(myiter+1)= Thermal_comfort_wasnt_achieved;


% Simulation_results.Heating.Total_Heating = Total_Heating;
% Simulation_results.Heating.Space_Heating = Space_Heating;
% Simulation_results.Heating.Heating_Ventil = Heating_Ventil;
% Simulation_results.Heating.Preheat_Ventil = Preheat_Ventil;
% Simulation_results.Heating.Heating_Power = Heater_Power;
% Simulation_results.Input_Data = Input_Data;
% Simulation_results.Time_Sim = Time_Sim;
% Simulation_results.Heating.Heating_Tech = Heating_Tech;
% Simulation_results.Heating.Heating_Time_and_technology = Heating_Time_and_technology;
% Simulation_results.Total_Cost = Total_Cost;
% Simulation_results.Emissions.Total_CO2 = Total_CO2;
% Simulation_results.Information.Building_Storage_constant = Building_Storage_constant;
% Simulation_results.Information.house_type = house_type;
% Simulation_results.Battery.Nbr_of_batteries = Nbr_batteries;
% Simulation_results.Emissions.PV_CO2 = PV_CO2;
% Simulation_results.Emissions.Battery_CO2 = Battery_CO2;
% Simulation_results.Information.LowerTempLimit = LowerTempLimit;
% Simulation_results.Information.Ventil_type = Ventil_type;
% Simulation_results.Information.Ventil_type1 = Ventil_type1;
% Simulation_results.Temperatures.T_inlet = T_inlet;
% Simulation_results.Temperatures.Temp_inside = Temp_inside;
% Simulation_results.Temperatures.Temp_radiative = Temp_radiative;
% Simulation_results.Temperatures.Temp_operative = Temp_operative;
% Simulation_results.Ventilation.Ventil_Consumption = Ventil_Consumption;
% Simulation_results.Ventilation.Motor_consumption = Motor_consumption;
% Simulation_results.Ventilation.Annual_Recovery_assumed = Heat_recovery_ventil_annual;
% Simulation_results.Ventilation.Annual_Recovery = Annual_recovery_efficiency;
% Simulation_results.Ventilation.Recovery_Power = Recovery_Power;
% Simulation_results.Ventilation.Heat_recovery_efficiency = Heat_Recovery_efficiency;
% Simulation_results.Heat_Losses.Loss_Ventil = Loss_Ventil;
% Simulation_results.Heat_Gains.Internal_Heat_Gain = Internal_Heat_Gain;
% Simulation_results.Heat_Demand = Heat_Demand;
% Simulation_results.Heating.PhotoVoltaic_Elec_Heat = PhotoVoltaic_Elec_Heat;
% Simulation_results.PV.Extra_PV_power = Extra_PV_power;
% Simulation_results.Economics.Cost_of_electricity = Price1;
% Simulation_results.Economics.Sold_electricity = Gain1;
% Simulation_results.Economics.Saved_Costs = Saved_money1;
% Simulation_results.Economics.Cost_of_electricity = Price1;
% Simulation_results.Economics.Total_Costs = Total_Cost_Elec;
% Simulation_results.Economics.Total_Sell = Total_Gain;
% Simulation_results.Economics.Total_Money_Saved = Total_Money_Saved;
% Simulation_results.Economics.Annual_Finance = Annual_finance;
% Simulation_results.Economics.Paybacktime = Paybacktime_estimation;
% Simulation_results.Temperatures.Nodal_Temperatures = Temperatures_nodal;
% Simulation_results.PV.PowerPV = PowerPV;
% Simulation_results.PV.SelfConsumption = PV_self_consumption;
% Simulation_results.Heating.Radiatior_maximum_capacity = Dwelling_env_heat;
% Simulation_results.Heating.Extra_heater = Extra_heater;
% Simulation_results.Heating.BiggerHeaterNeedCalc = BiggerHeaterNeedCalc;
% Simulation_results.Heating.Charging_of_thermal_Storage = Input;
% if strcmp(Heating_Tech, 'Cost Optimized Heating') == 1
% Simulation_results.Heating.Optimized_heating.Heating_scheme = Heating_scheme;
% end
% Simulation_results.Heating.Heating_Power_from_Grid = Heating_Power_from_Grid;
% Simulation_results.Heating.Hourlypercentages = Hourlypercentage;
% Simulation_results.Heating.Heating_maximum_capacity = Max_heating_capacity;
% Simulation_results.Heating.Ventilation_heater_maximum_capacity = Ventilation_heater;
% Simulation_results.Battery.Current_capacity = Current_capacity;
% Simulation_results.Battery.Nbr_of_cycles = Nbr_of_cycles;
% Simulation_results.Battery.LowerPriceLimit = LowerPriceLimit;
% Simulation_results.Battery.Value_of_electricity_in_battery = Elec_value_battery;
% Simulation_results.Emissions.Hourly_PV_CO2_emissions = Hourly_PV_CO2_emissions;
% Simulation_results.Emissions.Heating_PV_CO2_emissions = Heating_PV_CO2_emissions;
% % Simulation_results.Emissions.Battery_CO2_emissions = Battery_CO2_emissions;
% % Simulation_results.Emissions.Total_hourly_emissions = Total_hourly_emissions;
% % Simulation_results.Emissions.Total_heating_hourly_emissions = Total_heating_hourly_emissions;
% Simulation_results.Emissions.Total_CO2 = Total_CO2;
% Simulation_results.Utilization_rates.Appliances_utilization_rate = Appliances_utilization_rate;
% Simulation_results.Utilization_rates.Solar_utilization_rate = Solar_utilization_rate;
% Simulation_results.Thermal_Comfort.Thermal_Comfort_Achieved = Thermal_comfort_achieved;
% Simulation_results.Thermal_Comfort.Thermal_Comfort_wasnt_Achieved = Thermal_comfort_wasnt_achieved;
% Simulation_results.Thermal_Comfort.Thermal_Comfort_Achievement_Total = Thermal_comfort_achievement_total;
% Simulation_results.Thermal_Comfort.Hourly_LowerTempLimits = LowerTempLimit2;
% Simulation_results.Thermal_Comfort.Hourly_UpperTempLimits = UpperTempLimit2;
% Simulation_results.Heat_Gains.Solar_Heat_Gain = Solar_Heat_Gain;
% Simulation_results.Heat_Gains.Internal_Heat_Gain_Appl = Internal_Heat_Gain_Appl;
% Simulation_results.Heat_Gains.People_Heat_Gain = People_Heat_Gain;
% Simulation_results.Emissions.CO2_emissions = CO2_emissions;
% Simulation_results.Emissions.Total_electricity_CO2 = Total_electricity_CO2;
% Simulation_results.Economics.Total_electricity_cost = Total_Electricity_cost;
% Simulation_results.Economics.Total_electricity_cost_ventil_and_motor_added = Total_Cost_Elec_ventil;
% Simulation_results.Emissions.Total_electricity_CO2with_PV_consideration = Total_electricity_CO2_with_PV_consideration;
% Simulation_results.Emissions.Total_electricity_with_PV_consideration_and_PV_heating = Total_electricity_CO2_with_PV_consideration_and_PV_heating;
% Simulation_results.Emissions.Total_electricity_CO2_with_PV_consideration_and_PV_emissions = Total_electricity_CO2_with_PV_consideration_and_PV_emissions;
