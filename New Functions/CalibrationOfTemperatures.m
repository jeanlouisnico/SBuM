function [Temperatures_nodal] = CalibrationOfTemperatures(varargin)
% Function used for calibrating the indoor temperature values for the 1st time step 
% Calibration period is generally 2 weeks using the temperatures of the
% last 2 weeks of simulation period. Other variables here are considered to
% be equal to the 1st simulation step.
%% Inputs

uvs                         = varargin{1};
uve                         = varargin{2};
uvw                         = varargin{3};
uvn                         = varargin{4};
    
uvsw                        = varargin{5};
uvew                        = varargin{6};
uvnw                        = varargin{7};
uvww                        = varargin{8};
    
uvd                         = varargin{9};
    
uvf                         = varargin{10};
uvr                         = varargin{11};

hgt                         = varargin{12};
lgts                        = varargin{13};
lgte                        = varargin{14};
pitch                       = varargin{15};
aws                         = varargin{16};
awe                         = varargin{17};
awn                         = varargin{18};
aww                         = varargin{19};
ad                          = varargin{20};

A_roof                      = varargin{21};
A_floor                     = varargin{22};

House_Volume                = varargin{23};

Building_Envelope           = varargin{24};

Building_Storage_constant       = varargin{25};

Air_leak                    = varargin{26};
Ventilation_Type            = varargin{27};
Flow_rate                   = varargin{28}; 

Internal_Heat_Gain          = varargin{29};

Solar_Radiation_N           = varargin{30};
Solar_Radiation_E           = varargin{31};
Solar_Radiation_S           = varargin{32};
Solar_Radiation_W           = varargin{33};

Global_Radiation            = varargin{34};

Heater_Power                = varargin{36};

Solar_Heat_Gain             = varargin{35};

Temperature                 = varargin{37};
T_ground                    = varargin{38};
T_inlet                     = varargin{39};

Temperatures_nodal          = varargin{40}; %varargin{35};

CHTCvalue                   = varargin{41};

TimeStep                    = varargin{42};

Dwelling_env_heat           = varargin{43};

WallThermalClass            = varargin{44};
RoofThermalClass            = varargin{45};
FloorThermalClass           = varargin{46};

alfaOpaque                  = varargin{47};

Temp_Set                    = varargin{48};
Temp_cooling                = varargin{49};

WallThermalCapacity         = varargin{50};
RoofThermalCapacity         = varargin{51}; 
FloorThermalCapacity        = varargin{52};

A_swall = (lgts * hgt) - aws - ad;
A_wwall = (lgte * hgt + 0.5 * tand(pitch) * lgte^2) - aww;
A_nwall = (lgts * hgt) - awn;
A_ewall = (lgte * hgt + 0.5 * tand(pitch) * lgte^2) - awe;

%% Loop

for i = 1:length(Temperature)
    
    % Radiative Temperature is weighted average of internal sRrface
    % Temperatures (ISO 52016-1)
    T_radiative = (A_swall * Temperatures_nodal(5) + A_wwall * Temperatures_nodal(10) + A_nwall * Temperatures_nodal(15) + A_ewall * Temperatures_nodal(20) + A_floor * Temperatures_nodal(25) + A_roof * Temperatures_nodal(30) + aws * Temperatures_nodal(32) + aww * Temperatures_nodal(34) + awn * Temperatures_nodal(36) + awe * Temperatures_nodal(38) + ad * Temperatures_nodal(40))/Building_Envelope; %(A_wall * Temperatures1(5) + A_floor * Temperatures1(10) + A_roof * Temperatures1(15) + A_wind * Temperatures1(17) + A_door * Temperatures1(19))/Building_envelope;

    % Inside Temperature is the last calculated Temperature
    T_inside = Temperatures_nodal(41);

    % Operative Temperature is mean of radiative and inside Temperatures
    T_operative = (T_radiative + T_inside)/2;
    
                Heater_Power                    = 0;
                [~, ~, T_operative0, ~] = InsideTemperatureAllWalls(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws,...
                                                                    awe, awn, aww, ad, A_roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant,...
                                                                    Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Radiation_N, Solar_Radiation_E, Solar_Radiation_S, Solar_Radiation_W, Global_Radiation, Solar_Heat_Gain, Heater_Power,...
                                                                    Temperature(i), T_ground, T_inlet, Temperatures_nodal, CHTCvalue, TimeStep, WallThermalClass, RoofThermalClass, FloorThermalClass, alfaOpaque, WallThermalCapacity, RoofThermalCapacity, FloorThermalCapacity);

                HeatingNeed = T_operative0 < Temp_Set ;      % In case free floating temperature is under temperature set, then there is heat demand in the building
                CoolingNeed = T_operative0 > Temp_cooling ;  % If free floating temperature is higher than cooling temperature, then there is need for cooling

                [~, ~, T_operativeMax, ~]  = InsideTemperatureAllWalls(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws,...
                                                                    awe, awn, aww, ad, A_roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant,...
                                                                    Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Radiation_N, Solar_Radiation_E, Solar_Radiation_S, Solar_Radiation_W, Global_Radiation, Solar_Heat_Gain, Dwelling_env_heat,...
                                                                    Temperature(i), T_ground, T_inlet, Temperatures_nodal, CHTCvalue, TimeStep, WallThermalClass, RoofThermalClass, FloorThermalClass, alfaOpaque, WallThermalCapacity, RoofThermalCapacity, FloorThermalCapacity);
                                                                
                if HeatingNeed || CoolingNeed   % If there is heating or cooling need, calculate the heat demand to achieve the heating or cooling set point
                    if HeatingNeed
                        Heat_Demand             = Dwelling_env_heat * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));       % Heat Demand is equal to the heating/cooling need to meet the set-point temperature
%                         Heat_Demand_Temp_Set    = Heat_Demand;
%                         Heat_Demand_Upper_Temp_Limit = Dwelling_env_heat * ((Temp_Set_Heating_Upper_Limit - T_operative0)/(T_operativeMax - T_operative0));
                    else
                        Heat_Demand             = Dwelling_env_heat * ((Temp_cooling - T_operative0)/(T_operativeMax - T_operative0));
%                         Heat_Demand_Temp_Set    = Heat_Demand;
%                         Heat_Demand_Upper_Temp_Limit = 0;
                    end
                else
                    Heat_Demand                 = 0;        % There is no heat demand if the free floating conditions do not shift the temperature outside of the temperature set-points
%                     Heat_Demand_Temp_Set        = Dwelling_env_heat * ((Temp_Set - T_operative0)/(T_operativeMax - T_operative0));
%                     Heat_Demand_Upper_Temp_Limit = Dwelling_env_heat * ((Temp_Set_Heating_Upper_Limit - T_operative0)/(T_operativeMax - T_operative0));   
                end
                
                Heater_Power            = Heat_Demand;
                
                [~, ~, ~, Temperatures1] = InsideTemperatureAllWalls(uvs, uve, uvw, uvn, uvsw, uvew, uvnw, uvww, uvd, uvf, uvr, hgt, lgts, lgte, pitch, aws,...
                                                                    awe, awn, aww, ad, A_roof, A_floor, House_Volume, Building_Envelope, Building_Storage_constant,...
                                                                    Air_leak, Ventilation_Type, Flow_rate, Internal_Heat_Gain, Solar_Radiation_N, Solar_Radiation_E, Solar_Radiation_S, Solar_Radiation_W, Global_Radiation, Solar_Heat_Gain, Heater_Power,...
                                                                    Temperature(i), T_ground, T_inlet, Temperatures_nodal, CHTCvalue, TimeStep, WallThermalClass, RoofThermalClass, FloorThermalClass, alfaOpaque, WallThermalCapacity, RoofThermalCapacity, FloorThermalCapacity);
                                       
    Temperatures1(21)   = T_ground;
    Temperatures1(22)   = T_ground;
    Temperatures_nodal  = Temperatures1;
                
end            
            

%% Outputs

Temperatures_nodal = Temperatures_nodal;

end

