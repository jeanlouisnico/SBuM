function [PMV,PPD] = TestofThermalComfort(varargin)
%% Thermal comfort testing function
% This function is used in testing the thermal comfort values from the
% simulations in order to determine whether they fulfil the thermal comfort
% criteria. The calculations are based on the EN ISO 7730:2005 standard,
% which is used in calculating the PMV and PPD values.
%% Inputs
Met_rate        = varargin{1};
Temperature     = varargin{2};
Temp_inside     = varargin{3};
Temp_radiative  = varargin{4};
n               = varargin{5};



% Limiting Met_rate to values for which the thermal comfort calculations
% can be done.
if Met_rate < 46
    Met_rate = 46;
elseif Met_rate > 232
    Met_rate = 232;
end

% Calculate the water vapor partial pressure. The water vapor saturation
% pressures here are from 10 to 30 degrees celsius by 1 degree steps.

RH = 0.5;   % Relative humidity is considered to be constant 50%
Water_Vapor_Saturation_Pressure = [1.227 1.312 1.402 1.497 1.598 1.705 1.818 1.938 2.065 2.198 2.34 2.489 2.646 2.812 2.986 3.171 3.365 3.569 3.784 4.01 4.248] * 1000; % Saturation Pressures between 1 degree in celsius in Pa.
Water_Vapor_Partial_Pressure    = Water_Vapor_Saturation_Pressure * RH;

% Use inside temperature to define the water vapor partial pressure for the
% inside temperature
if Temp_inside > 30
    Water_Vapor_Partial_Pressure = Water_Vapor_Partial_Pressure(end);   % If temperature raises too high select last value
else
    Water_Vapor_Partial_Pressure    = Water_Vapor_Partial_Pressure(round(Temp_inside-10+1));  % 10 degrees celcius is eqvivalent to the first value.
end

%% Clothing insulation
% The clothing insulation calculations are here. The clothing insulation is
% dependable on the met rate and outside temperature. This is considered to
% be insulation value inside.

if Met_rate == 46
    Clothing_insulation = 0.96 * 0.155;     % Example from ASHRAE Standard for a sleeping person
elseif n <= 24
    if Temperature(n) < 0                   % Morgan & de Dear. Outside temperature has an effect to clothing insulation
        Clothing_insulation = 0.155;        % Wintertime clothing is equal to 1 clo
    elseif Temperature(n) > 0 && Temperature(n) < 10
        Clothing_insulation = 0.8 * 0.155;  % Spring and autumn clothings are estimated to be half from the winter and summer clothing. (John L. Stoops)
    else
        Clothing_insulation = 0.6 * 0.155;  % Summertime clothing is equal to 0.6 clo (Ala-Juusela & Shukuya)
    end
elseif mean(Temperature(n-24:n)) < 0        % Winter from fmi
    Clothing_insulation = 0.155;
elseif mean(Temperature(n-24:n)) > 0 && mean(Temperature(n-24:n)) < 10  % Spring and autumn from fmi
    Clothing_insulation = 0.8 * 0.155;
else
    Clothing_insulation = 0.6 * 0.155;      % Summer
end

% Relative air velocity
Relative_air_velocity = 0.20;       % Guess of the mean air velocity. This is a maximum value from D2. Calculation would require CFD software.

%% Clothing surface area factor

if Clothing_insulation <= 0.078
    fcl = 1.00 + 1.290 * Clothing_insulation;
else
    fcl = 1.05 + 0.645 * Clothing_insulation;
end

%% Clothing surface temperature
% This calculation requires iteration

% First guesses for the answer, and the acceptable difference in iteration
% calculation for the tcl values

tcl1 = 50;
tcl2 = 20;
EPS = 0.00015;

% Loop for the iteration. Equations in the standard, as is the iteration
% mechanism.
while abs(tcl1-tcl2) > EPS
    tcl1 = (tcl1 + tcl2)/2;
        if 2.38 * (abs(tcl1 - Temp_inside)).^0.25 > 12.1 * sqrt(Relative_air_velocity)
            hc = 2.38 * (abs(tcl1 - Temp_inside)).^0.25;
            tcl2 = 35.7 - 0.028 * Met_rate - Clothing_insulation * (3.96 * 10^(-8) * fcl * ((tcl1 + 273).^4 - (Temp_radiative + 273).^4) + fcl * hc .* (tcl1 - Temp_inside));
        else
            tcl2 = 35.7 - 0.028 * Met_rate - Clothing_insulation * (3.96 * 10^(-8) * fcl * ((tcl1 + 273).^4 - (Temp_radiative + 273).^4) + fcl * (12.1 * sqrt(Relative_air_velocity)) * (tcl1 - Temp_inside));
        end
end
tcl = tcl1;     % Assign the final value as tcl

%% PMV calculation
% Here the PMV for the current conditions is calculated

if 2.38 * (abs(tcl - Temp_inside)).^0.25 > 12.1 * sqrt(Relative_air_velocity)
    PMV = (0.303 * exp(-0.036 * Met_rate) + 0.028) * (Met_rate - 3.05 * 10^(-3) * (5733 - 6.99 * Met_rate - Water_Vapor_Partial_Pressure) - 0.42 * (Met_rate - 58.15) - 1.7*10^(-5) * Met_rate * (5867 - Water_Vapor_Partial_Pressure) - 0.0014 * Met_rate * (34 - Temp_inside) - 3.96*10^(-8) * fcl*((tcl + 273).^4 - (Temp_radiative + 273).^4) - fcl * (2.38 * (abs(tcl - Temp_inside)).^0.25) .* (tcl-Temp_inside));
else
    PMV = (0.303 * exp(-0.036 * Met_rate) + 0.028) * (Met_rate - 3.05 * 10^(-3) * (5733 - 6.99 * Met_rate - Water_Vapor_Partial_Pressure) - 0.42 * (Met_rate - 58.15) - 1.7*10^(-5) * Met_rate * (5867 - Water_Vapor_Partial_Pressure) - 0.0014 * Met_rate * (34 - Temp_inside) - 3.96*10^(-8) * fcl*((tcl + 273).^4 - (Temp_radiative + 273).^4) - fcl * (12.1 * sqrt(Relative_air_velocity)) * (tcl-Temp_inside));
end

%% PPD calculation
% Calculation for the percentage of dissatisfied people

PPD = 100 - 95 * exp(-0.03353 * PMV.^4 - 0.2179 * PMV.^2);

end

