function [varargout] = Occupancy_detection_thermal_AppProf(varargin)
%% This is a function for occupancy detection in the thermal model
% The aim of this function is to determine the occupancy of the inhabitants
% and determine their actions in the building. This is used in calculating
% the heat gain from inhabitants and the metabolic rate to be used in
% thermal comfort determination.
%% Input variables
% The input variables go here. 

HouseTitle              = varargin{1};
Input_Data              = varargin{2};
All_Var                 = varargin{3};
timehour                = varargin{4};
% EnergyOutput            = varargin{5};
Appliances_consumption  = varargin{5};
Occupancy               = varargin{6};
SimDetails              = varargin{7};
Ventilation_Type        = varargin{8};
T_inlet                 = varargin{9};
myiter                  = varargin{10};
Temp_inside             = varargin{11};
Temperature             = varargin{12};
App                     = varargin{13};
Temp_Cooling            = varargin{14};

DemandVentilation           = strcmp(Input_Data.DemandVentilation,'1');   % Define if Demand-based ventilation is in use (true-false)

Inhabitants = str2double(Input_Data.inhabitants);
N0          = str2double(Input_Data.N0);

%% Predefined variables for the metabolic rate calculation
% These values are based on Ahmed et al. (2017) and SFS-EN ISO 7730:2005.
%%%
% People activities based on met. The calculation is Q = met(action) *
% A(person). A(person) is 1.80 m2 by default. Activities are sleeping (0.8),
% Seating (1.0), Domestic work (2.0) and sedentary activity (1.2). One met
% is considered to be 58 W/m2.

A_Person            = 1.80;

Sleeping            = 46 * A_Person;
Seated              = 58 * A_Person;
Domestic_Work       = 116 * A_Person;
Sedentary_activity  = 70 * A_Person;


%% Variables for occupancy detection
App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers)      = 0;
App.OccupancyDetection.Tele.(Input_Data.Headers)                = 0;
App.OccupancyDetection.Laptop.(Input_Data.Headers)              = 0;
App.OccupancyDetection.WashMach.(Input_Data.Headers)            = 0;
App.OccupancyDetection.DishWash.(Input_Data.Headers)            = 0;
App.OccupancyDetection.HobOven.(Input_Data.Headers)             = 0;
App.OccupancyDetection.Sauna.(Input_Data.Headers)               = 0;
App.OccupancyDetection.Elecheat.(Input_Data.Headers)            = 0;
App.OccupancyDetection.Other.(Input_Data.Headers)               = 0;

AppList = All_Var.GuiInfo.AppliancesList(:,3) ;

for ij = 1:length(AppList)
    if ~isempty(AppList{ij})
        AppName = AppList{ij} ;
        [App] = AppStateExistingProf(AppName, App, Input_Data, myiter) ;
    end
end

%% Determine internal heat gains 

Internal_Heat_Gain_Appl = Appliances_consumption * 1000 - ...
                         ((1-0.8) * App.OccupancyDetection.WashMach.(Input_Data.Headers) * 1000 + ...
                         (1-0.6) * App.OccupancyDetection.DishWash.(Input_Data.Headers) * 1000 + ...
                         (1-0.4) * App.OccupancyDetection.HobOven.(Input_Data.Headers) * 1000 + ...
                         App.OccupancyDetection.Sauna.(Input_Data.Headers) * 1000 + ...
                         App.OccupancyDetection.Elecheat.(Input_Data.Headers) * 1000);
                     
    if timehour > 22 || timehour < 8
        People_Heat_Gain    = Inhabitants * Sleeping;
        Met_rate            = 46; 
    elseif App.AppStatus.(Input_Data.Headers).StandByDomestic == 1 %App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic
        People_Heat_Gain    = Inhabitants * Domestic_Work;
        Met_rate            = 116;
    elseif App.AppStatus.(Input_Data.Headers).StandBySeated == 1 %(App.OccupancyDetection.Tele.(Input_Data.Headers) + App.OccupancyDetection.Laptop.(Input_Data.Headers)) > StandBy_seated 
        People_Heat_Gain    = Inhabitants * Seated;
        Met_rate            = 58;
    elseif App.AppStatus.(Input_Data.Headers).StandBySedentary == 1 
        People_Heat_Gain    = Inhabitants * Sedentary_activity;
        Met_rate            = 70;
    else
        People_Heat_Gain    = 0;
        Met_rate            = 0;
    end
    
    AppStatus.StandBy_Domestic  = App.AppStatus.(Input_Data.Headers).StandByDomestic;
    AppStatus.StandBy_seated    = App.AppStatus.(Input_Data.Headers).StandBySeated;
    AppStatus.StandBy_sedentary = App.AppStatus.(Input_Data.Headers).StandBySedentary;
    
    if AppStatus.StandBy_Domestic == 1 || AppStatus.StandBy_seated == 1 || AppStatus.StandBy_sedentary == 1
        AppStatus.tenancy = 1;
        
    else
        AppStatus.tenancy = 0;
    end
    
%% Define the ventilation flow rate

switch Ventilation_Type
        case{'Mechanical ventilation','Air-Air H-EX'}     
            % These technologies can adjust the ventilation rate of the
            % building. Consider also option to attach the flow rate to the
            % N0.
            if AppStatus.tenancy == 0             % From RIL 249-2009 p. 114
                Flow_rate       = 0.2;
                if strcmp(Ventilation_Type,'Air-Air H-EX') == 1
                    T_inlet         = T_inlet;        
                else
                    T_inlet = Temperature;
                end
            elseif AppStatus.tenancy == 1 && AppStatus.StandBy_Domestic == 1 %App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic    % Increased ventilation air flow when cooking or cleaning
                Flow_rate       = 1.0;
                T_inlet         = T_inlet;
            elseif myiter+1 > 1 && Temp_inside > Temp_Cooling && (timehour > 8 && timehour < 22) % Summer daytime increased ventilation flow
                Flow_rate       = 0.7;
                if Temperature > 10 && Temperature < 18 && strcmp(Ventilation_Type, 'Air-Air H-EX')
                    T_inlet     = Temperature;
%                 elseif Temperature > T_inlet  
                else    
                    T_inlet     = T_inlet;   
                end
            elseif myiter+1 > 1 && Temp_inside > Temp_Cooling && (timehour < 8 || timehour > 22) % Increased ventilation flow for summer nights for cooling
                Flow_rate       = 1.5;
                if Temperature > 10 && Temperature < 18
                    T_inlet     = Temperature;
                else
                    T_inlet     = T_inlet;
                end
            else
                Flow_rate       = N0;
                T_inlet         = T_inlet;
            end
            if ~DemandVentilation
                Flow_rate = N0;
            end
        case('Natural ventilation')
            Flow_rate = N0;
            T_inlet   = T_inlet;
end

%% Output

varargout{1} = People_Heat_Gain;
varargout{2} = Met_rate;
varargout{3} = Internal_Heat_Gain_Appl;
varargout{4} = AppStatus.tenancy;
varargout{5} = Flow_rate;
varargout{6} = T_inlet;
varargout{7} = AppStatus;
end

