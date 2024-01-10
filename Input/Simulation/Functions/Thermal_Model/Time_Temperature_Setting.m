function [varargout] = Time_Temperature_Setting(varargin)
%% This is a function for Time based temperature settings on for the thermostat
% This function is similar to constant temperature setting function, with
% the exception of the temperature setting varying in time. The heat
% delivered is based on the heat demand, and the reduction or increase in
% heat delivery for changing the indoor temperature is based on thermal
% storage consideration of the building, where building is treated as
% thermal storage, and the heat capacity is a combination of indoor air and
% building sturctures' heat capacities.
%% Inputs 

Temp_inside                 = varargin{1};
Temp_Set                    = varargin{2};
timehour                    = varargin{3};
Heat_Demand                 = varargin{4};
House_Volume                = varargin{5};
Building_Storage            = varargin{6};
Dwelling_env_heat           = varargin{7};
Space_Heating_Efficiency    = varargin{8};
Heating_Ventil              = varargin{9};
Temperature                 = varargin{10};

%% Electric space heating part
% This part is used in the direct electric space heating with varying
% temperature settings according to the time. In nighthours (23-6) and 
% daytime (10-16), the temperature is lower than in other times. The heat 
% demand for increasing the indoor temperature is estimated with equation: 
% Q = mc delta T, where delta T is the temperature difference between 
% current temperature and the wanted one. Similarly, the heating is 
% discontinued until the lower temperature is achieved. In other times, the
% heat delivery is equal to the heat demand. 

% First check the time and adjust the Temperature setting accordingly.

% if timehour < 6 || timehour >= 23 || (timehour > 9 && timehour < 17)
%     Temp_Set1 = Temp_Set(2);
% else
%     Temp_Set1 = Temp_Set(1);
% end

% Next calculate the heater power from the direct electric space heater.
% Here the heat demand and the change in the energy content in the system
% is considered togther and the heat is supplied accordingly. In case,
% there is no heating need (either no heat demand, or temperature does not
% drop to temperature setting yet), there won't be any heat supplied to the
% system. 

Heater_Power = (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set - Temp_inside) + Heat_Demand;
Heater_Power = max(0, Heater_Power);

% Check the capacity limits and outdoor temperature effect.

if Heater_Power > Dwelling_env_heat
    
    Heater_Power = Dwelling_env_heat;
    
elseif Temperature > Temp_Set
    
    Heater_Power = 0;
    
end


%% The final variables
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. 

Space_Heating = Heater_Power / Space_Heating_Efficiency ;
Total_Heating = Space_Heating + Heating_Ventil;
% Price = Total_Heating/1000 * RTP(m)/100;        % RTP price is in cents/kWh. Consumption is changed to kWh and price to €.

%% Outputs

varargout{1}    = Heater_Power;
varargout{2}    = Space_Heating;
varargout{3}    = Total_Heating;
% varargout{4}    = Price;

end

