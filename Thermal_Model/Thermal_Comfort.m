function [Acceptable_inside_Temperature] = Thermal_Comfort(varargin)
%% Thermal comfort calculation function
% This function is used to calculate the predicted mean vote and percentage
% of people dissatisfied of the thermal comfort and this is used to predict
% the state of the indoor climate and its suitability for the residents.
% This is used to keep the indoor climate conditions acceptable in the
% varying temperature.
% The calculations here are based on British Standard BS EN 7730:2005, that
% describes the PMV and PPD values. Here the radiative temperature is
% assumed to be same than inside air temperature for the sake of
% simplicity.
%%%
%% Inputs
% The inputs to the system are presented here.
% load Met_rate
% load Temperature

All_Var         = varargin{1};
Time_Sim        = varargin{2};
Met_rate        = varargin{3};
Temperature     = varargin{4};
n               = varargin{5};
ComfortLimit    = varargin{6};

% Limiting Met_rate to values for which the thermal comfort calculations
% can be done.
if Met_rate < 46
    Met_rate = 46;
elseif Met_rate > 232
    Met_rate = 232;
end

% Define RH value
RH = 0.5;       % Relative humidity is considered to be constant 50 % inside

% dbstop if naninf
%% PMV & PPD
% The calculation for the PMV and PPD are presented here. Based on the
% variation of the acceptable temperature range and discomfort the values
% of PMV and PPD can vary. The clothing insulation values also affect the
% feeling of discomfort.
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
% Clothing_insulation = 0.155 ; % Example for now, suitable summertime clothes
Relative_air_velocity = 0.20; % Example from D2 for now until a calculation procedure is found. Ala-Juusela and Shukuya uses 0.1 m/s.
if Clothing_insulation <= 0.078
    fcl = 1.00 + 1.290 * Clothing_insulation;
else
    fcl = 1.05 + 0.645 * Clothing_insulation;
end
tcl = zeros(1,21); % Pre-allocation of the tcl values for the 20 preset temperatures
for Temp_inside = 10:30
    tcl1 = 50;
    tcl2 = 20;
%     tcl1 = ((Temp_inside+273) + (35.5-Temp_inside)/(3.5*Clothing_insulation+0.1))/100;
%     tcl2 = tcl1; 
%     Water_Vapor_Saturation_Pressure = exp(16.6536-4030.183/(Temp_inside+235));
%     Water_Vapor_Partial_Pressure(Temp_inside-9) = RH * 10 * Water_Vapor_Saturation_Pressure;
%     P1 = Clothing_insulation * fcl;
%     P2 = P1 * 3.96;
%     P3 = P1 * 100;
%     P4 = P1 * (Temp_inside + 273);
%     P5 = 308.7 - 0.028 * Met_rate + P2 * ((Temp_inside + 273)/100) * 4;
%     Water_Vapor_Saturation_Pressure = [1.227 1.312 1.402 1.497 1.598 1.705 1.818 1.938 2.065 2.198 2.34 2.489 2.646 2.812 2.986 3.171 3.365 3.569 3.784 4.01 4.248] * 1000; % Saturation Pressures between 1 degree in celsius in Pa.
%     Water_Vapor_Partial_Pressure    = Water_Vapor_Saturation_Pressure * RH;
%     Theta = 1 - (Temp_inside + 235.15/647.096); % From Vaisala; Latter number is Critical temperature
%     Water_Vapor_Saturation_Pressure = 220640 * exp((647.096/220640) * (-7.85951783 * Theta + 1.84408259 * (Theta)^1.5 - 11.7866497 * (Theta)^3 + 22.6807411 * (Theta)^3.5 - 15.9618719 * (Theta)^4 + 1.80122502 * (Theta)^7.5)); % From Vaisala p. 4
%     Water_Vapor_Saturation_Pressure = Water_Vapor_Saturation_Pressure/100;
%     Water_Vapor_Partial_Pressure = Water_Vapor_Saturation_Pressure * 0.50; % Assuming constant 50 % RH; From Vaisala
    EPS = 0.00015;
    while abs(tcl1-tcl2) > EPS
    tcl1 = (tcl1 + tcl2)/2;
        if 2.38 * (abs(tcl1 - Temp_inside)).^0.25 > 12.1 * sqrt(Relative_air_velocity)
            hc = 2.38 * (abs(tcl1 - Temp_inside)).^0.25;
%             tcl2 = (P5 + P4 * hc - P2 * tcl1^4)/(100 + P3 * hc);
            tcl2 = 35.7 - 0.028 * Met_rate - Clothing_insulation * (3.96 * 10^(-8) * fcl * ((tcl1 + 273).^4 - (Temp_inside + 273).^4) + fcl * hc .* (tcl1 - Temp_inside));
        else
%             hc = 12.1 * sqrt(Relative_air_velocity);
%             tcl2 = (P5 + P4 * hc - P2 * tcl1^4)/(100 + P3 * hc);
            tcl2 = 35.7 - 0.028 * Met_rate - Clothing_insulation * (3.96 * 10^(-8) * fcl * ((tcl1 + 273).^4 - (Temp_inside + 273).^4) + fcl * (12.1 * sqrt(Relative_air_velocity)) * (tcl1 - Temp_inside));
        end
    end
    tcl(Temp_inside - 9) = tcl1;
end
% Calculate water vapor partial pressure. Use saturation pressures of the
% predefined temperatures
    Water_Vapor_Saturation_Pressure = [1.227 1.312 1.402 1.497 1.598 1.705 1.818 1.938 2.065 2.198 2.34 2.489 2.646 2.812 2.986 3.171 3.365 3.569 3.784 4.01 4.248] * 1000; % Saturation Pressures between 1 degree in celsius in Pa.
    Water_Vapor_Partial_Pressure    = Water_Vapor_Saturation_Pressure * RH;
% Inside temperature range definition
Temp_inside = 10:30;
if 2.38 * (abs(tcl - Temp_inside)).^0.25 > 12.1 * sqrt(Relative_air_velocity)
    PMV = (0.303 * exp(-0.036 * Met_rate) + 0.028) * (Met_rate - 3.05 * 10^(-3) * (5733 - 6.99 * Met_rate - Water_Vapor_Partial_Pressure) - 0.42 * (Met_rate - 58.15) - 1.7*10^(-5) * Met_rate * (5867 - Water_Vapor_Partial_Pressure) - 0.0014 * Met_rate * (34 - Temp_inside) - 3.96*10^(-8) * fcl*((tcl + 273).^4 - (Temp_inside + 273).^4) - fcl * (2.38 * (abs(tcl - Temp_inside)).^0.25) .* (tcl-Temp_inside));
else
    PMV = (0.303 * exp(-0.036 * Met_rate) + 0.028) * (Met_rate - 3.05 * 10^(-3) * (5733 - 6.99 * Met_rate - Water_Vapor_Partial_Pressure) - 0.42 * (Met_rate - 58.15) - 1.7*10^(-5) * Met_rate * (5867 - Water_Vapor_Partial_Pressure) - 0.0014 * Met_rate * (34 - Temp_inside) - 3.96*10^(-8) * fcl*((tcl + 273).^4 - (Temp_inside + 273).^4) - fcl * (12.1 * sqrt(Relative_air_velocity)) * (tcl-Temp_inside));
end
%     HL1 = 3.05 * 0.001 * (5733 - 6.99 * Met_rate - Water_Vapor_Partial_Pressure(Temp_inside-9));
%     HL2 = 0.42 * (Met_rate - 58.15);
%     if HL2 < 0
%         HL2 = 0;
%     end
%     HL3 = 1.7 * 0.00001 * Met_rate *(5867 - Water_Vapor_Partial_Pressure(Temp_inside-9));
%     HL4 = 0.0014 * Met_rate * (34 - Temp_inside);
%     HL5 = 3.96 * fcl * ((tcl(Temp_inside-9) + 273) ^ 4 - ((Temp_inside + 273)/100^4));
%     if 2.38 * (abs(tcl(Temp_inside-9) - Temp_inside)).^0.25 > 12.1 * sqrt(Relative_air_velocity)
%         hc = 2.38 * (abs(tcl(Temp_inside-9) - Temp_inside)).^0.25;
%     else
%         hc = 12.1 * sqrt(Relative_air_velocity);
%     end
%     HL6 = fcl * hc * (tcl(Temp_inside-9) - Temp_inside);
%     TS = 0.303 * exp(-0.036 * Met_rate) + 0.028;
%     PMV = TS * (Met_rate - HL1 - HL2 - HL3 - HL4 - HL5 - HL6);
%     PMV1(Temp_inside - 9) = PMV;
PPD = 100 - 95 * exp(-0.03353 * PMV.^4 - 0.2179 * PMV.^2);
Logical = (PMV >= -ComfortLimit & PMV <= ComfortLimit);
Acceptable_inside_Temperature = Temp_inside(Logical); 
end

