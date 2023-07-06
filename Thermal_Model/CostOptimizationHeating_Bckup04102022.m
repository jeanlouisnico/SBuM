function [varargout] = CostOptimizationHeating(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, varargin)
%% Function for optimizing the heating based on real-time price
% This function can be used to create an 'optimal' heating scheme for the
% heater. This fuction is modified from examples from
% https://se.mathworks.com/help/optim/linear-programming-and-mixed-integer-linear-programming.html
% and
% https://se.mathworks.com/help/optim/examples/optimal-dispatch-of-power-generators.html
% It utilizes problem-based optimization setup from optimization toolbox.
% The optimization is linear programming optimization.

% load CostTest

RTP_forecast            = varargin{1};
Weather_forecast        = varargin{2};
% Heat_Demand_estimation  = varargin{3};
Dwelling_env_heat       = varargin{3};
Thermal_time_constant   = varargin{4};
Total_Heat_capacity     = varargin{5};
Total_Loss              = varargin{6};
N0                      = varargin{7};
House_Volume            = varargin{8};
T_inlet                 = varargin{9};
T_ground_hourly         = varargin{10};
Loss_floor              = varargin{11};
Internal_Heat_Gain      = varargin{12};
m                       = varargin{13};
Heat_recovery_ventil_an = varargin{14};
Temp_inside1            = varargin{15}; % The final inside temperature from which to start calculating
lgte                    = varargin{16};
lgts                    = varargin{17};
nPeriods                = varargin{18};                           % Nbr of hours simulated in the optimum solution
LowerTempLimit          = varargin{19};                           % Lower inside temperature limit
UpperTempLimit          = varargin{20};                           % Upper inside temperature limit
solar_heat_gain         = varargin{21};
solar_radiation_vertical = varargin{22};
solar_radiation         = varargin{23};
Temperatures_nodal      = varargin{24};

Temperatures_nodal      = repmat(Temperatures_nodal',1,nPeriods);

Temperature             = Weather_forecast(1:nPeriods)';      % Forecasted weather
                         
T_inlet                 = repelem(T_inlet,nPeriods);          % Simplified estimation by assigning 24 hours to the same value as the current
T_ground_hourly         = repelem(T_ground_hourly,nPeriods);  % Simplified method like above
Temp_inside2            = Temp_inside1;                 % Fixing the loss of last temperature

LowerTempLimit          = 21; % For this simulation time 
UpperTempLimit          = 23; %25; % For this simulation time

dbstop if error
dbclear if naninf
%% Heat Demand Calculation
% First the heat demand estimations for the building needs to be
% calculated. It is done by using weather forecast and variables. The heat
% demand is estimated from last interior temperature and from the weather
% forecast exterior temperatures.

% Internal heat gain is estimated from the Decree on energy efficiency and
% is considered to be equally distributed for the day

lighting_usage_factor           = 0.1;
appliances_and_people_factor    = 0.6;
lighting_heat_gain              = 6 * lgts * lgte;
appliances_heat_gain            = 3 * lgte * lgts;
people_heat_gain                = 2 * lgte * lgts;
internal_heat_gain = lighting_usage_factor * lighting_heat_gain + appliances_and_people_factor * appliances_heat_gain + appliances_and_people_factor * people_heat_gain;

%             Heater_Power0                   = 0;
%             [T_inside0, ~, ~, ~]            = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, internal_heat_gain, solar_heat_gain, Heater_Power, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, solar_radiation_vertical, solar_radiation);
%             [T_insideMax, ~, ~, ~]          = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, Flow_rate, internal_Heat_Gain, solar_heat_gain, Dwelling_env_heat, Temperature, T_ground_hourly, T_inlet, Temperatures_nodal, solar_radiation_vertical, solar_radiation);



% if Heat_recovery_ventil_an == 0
%     Heat_Demand = Total_Loss * (Temp_inside1 - Temperature) + ((1.2 * N0 * House_Volume * 1.007)/3.6) * (Temp_inside1 - T_inlet) + Loss_floor * (Temp_inside1 - T_ground_hourly) - internal_heat_gain; % Loss_Ventil is estimated in normal state & internal_heat_gains are considered as an esimation from Decree on energy efficiency
%     Heating = Dwelling_env_heat * ((Temp_inside - T_inside0)/(T_insideMax - T_inside0));
% else
%     Heat_Demand = Total_Loss * (Temp_inside1 - Temperature) + ((1.2 * N0 * House_Volume * 1.007 * (1 - Heat_recovery_ventil_an))/3.6) * (Temp_inside1 - T_inlet) + Loss_floor * (Temp_inside1 - T_ground_hourly) - internal_heat_gain;
% end

%% Boundaries
% The system includes boundaries to the heating and inside temperature.

Heating     = optimvar('Heating',nPeriods, 1,'LowerBound',0,'UpperBound',Dwelling_env_heat);
% Heating.LowerBound = 0;
% Heating.UpperBound = Dwelling_env_heat;
% Temp_inside = optimvar('Temp_inside', nPeriods, 1, 'LowerBound',LowerTempLimit,'UpperBound',UpperTempLimit);

%% Temperature inside in the estimation
% Inside temperature calculation in the estimations

% Temp_inside1 = repelem(Temp_inside1,24);
% Temp_inside1 = optimexpr(nPeriods);
% Temp_inside1(1) = Temp_inside2;
Temp_inside = optimexpr(nPeriods);

T_inside0       = zeros(1,nPeriods);
T_insideMax     = zeros(1,nPeriods);

for i = 1:nPeriods
%     if i < nPeriods
        
            Heater_Power0                      = 0;
            [T0, ~, To0, ~]               = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, N0, internal_heat_gain, solar_heat_gain(i), Heater_Power0, Temperature(i), T_ground_hourly(i), T_inlet(i), Temperatures_nodal(:,i), solar_radiation_vertical(i), solar_radiation(i));
            T_inside0(i) = T0; 
%             T_operative0(i) = To0;
            [TMax, ~, ToMax, ~]             = InsideTemperature(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, N0, internal_heat_gain, solar_heat_gain(i), Dwelling_env_heat, Temperature(i), T_ground_hourly(i), T_inlet(i), Temperatures_nodal(:,i), solar_radiation_vertical(i), solar_radiation(i));
            T_insideMax(i) = TMax; 
%             T_operativeMax(i) = ToMax;
            
%             Heating(i) = Dwelling_env_heat * ((Temp_inside(i) - T_inside0(i))/(T_insideMax(i) - T_inside0(i)));

            Temp_inside(i) = (1/Dwelling_env_heat) * Heating(i) * (T_insideMax(i) - T_inside0(i)) + T_inside0(i);
%             Temp_inside(i) = (1/Dwelling_env_heat) * Heating(i) * (T_operativeMax(i) - T_operative0(i)) + T_operative0(i);

            
%             [MatrixA, MatrixB] = InsideTemperatureOptim(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws, awe, awn, aww, ad, A_Roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant, Air_leak, Ventilation_Type, N0, internal_heat_gain, solar_heat_gain(i), Heating(i), Temperature(i), T_ground_hourly(i), T_inlet(i), Temperatures_nodal(:,i), solar_radiation_vertical(i), solar_radiation(i));
%             
%             Temp_inside(i) = (MatrixA\MatrixB);
            
%             Temp_inside(i)              = T_inside;
%             Temperatures_nodal(:,i+1)   = Temperatures1;


%         Temp_inside(i) = ((Heating(i) - Heat_Demand(i))*3.6)/(Total_Heat_capacity) + Temp_inside1(i);
%         Temp_inside1(i+1) = Temp_inside(i);
%     else
%         Temp_inside(i) = ((Heating(i) - Heat_Demand(i))*3.6)/(Total_Heat_capacity) + Temp_inside1(i);
%     end
end
TemperatureLowLimit = Temp_inside >= LowerTempLimit;
TemperatureHighLimit = Temp_inside <= UpperTempLimit;
% TemperatureMean     = mean(Temp_inside) == 21;

%% Price of heating
% Price of heating is calculated here

% Price           = Heating/1000 * RTP_forecast/100;
% Whole_day_price = sum(Price);
Cost = optimexpr(nPeriods);
for i = 1:nPeriods
%     Cost(i) = (((Total_Heat_capacity * (Temp_inside(i) - Temp_inside1(i)))/3.6) + Heat_Demand(i))/1000 * RTP_forecast(i)/100;
    Cost(i) = (Dwelling_env_heat * ((Temp_inside(i) - T_inside0(i))/(T_insideMax(i) - T_inside0(i))))/1000 * RTP_forecast(i)/100;
end
    Total_Cost = sum(Cost);

%% Optimization parameter
% The optimization of cost is done here

Heating = optimproblem('ObjectiveSense','minimize');
Heating.Objective = Total_Cost;
Heating.Constraints.TemperatureLowLimit = TemperatureLowLimit;
Heating.Constraints.TemperatureHighLimit = TemperatureHighLimit;
% dispatch.Constraints.TemperatureMean = TemperatureMean;

options = optimoptions('linprog','Display','off','MaxTime',1000);

[dispatchsol] = solve(Heating, 'Options', options);

heating_scheme = dispatchsol.Heating;




% Temperature_reduction   = zeros(71,24);
% Temperature_increase1   = zeros(71,24);


% % 24 hour sorting of RTP based on price estimations
% [RTP_forecast_sorted, idx] = sortrows(RTP_forecast);
% RTP_forecast_sorted = [RTP_forecast_sorted idx];
% 
% Higher_Limit_temp       = 25;
% Lower_Limit_temp        = 18;
% Temp_range              = Lower_Limit_temp:0.1:Higher_Limit_temp;
% 
% % Temperature reductions after an hour from each inside temperature if heating is off
% for n = 1:24
%     Temperature_reduction(:,n) = sort(round((Temp_range' - (Temp_range' - Weather_forecast(n)) * (1 - exp(-1/Thermal_time_constant))),1),'descend');
% end
% 
% % Heat required to heat up 1 degree of the building
% for n = 1:24
%     Heat_Demand_estimation(:,n) = (Total_Loss) * (Temp_range - Weather_forecast(n)) + (1.2 * 1.007 * N0 * House_Volume)/3.6 * (Temp_range - T_inlet) + Loss_floor * (Temp_range - T_ground_hourly) - Internal_Heat_Gain;
%     Temperature_increase1(:,n) = Heat_Demand_estimation(:,n) + Total_Heat_capacity;
% end

varargout{1} = heating_scheme;
end

