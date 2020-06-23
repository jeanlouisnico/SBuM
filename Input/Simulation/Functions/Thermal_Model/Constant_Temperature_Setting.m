function [varargout] = Constant_Temperature_Setting(varargin)
%% The function for utilizing direct electric space heating with a constant temperature setting
% This function is for direct electric space heating with constant
% temperature setting. It utilizes heat demand and aims in matching the
% lost heat with the delivered amount of electric space heating.
%% Inputs

Temp_inside                 = varargin{1};
Temp_Set                    = varargin{2};
Heat_Demand                 = varargin{3};
House_Volume                = varargin{4};
Building_Storage            = varargin{5};
Dwelling_env_heat           = varargin{6};
Space_Heating_Efficiency    = varargin{7};
% RTP                         = varargin{8};
Heating_Ventil              = varargin{8};
Temperature                 = varargin{9};

%% The electric heating part
% This part describes the direct electric space heating part with constant
% temperature setting. Temp_Set variable describes the temperature setting
% given to the radiator. It utilizes heat demand variable to estimate the
% amount of heat delivery to the system, and matches the heat delivery with
% the heat demand. The used thermostat is considered to be perfect, with no
% deadband.

if Temp_inside > Temp_Set
            
        Heater_Power = (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set - Temp_inside) + Heat_Demand;
        Heater_Power = max(0, Heater_Power);
            
else

        Heater_Power = max(0,Heat_Demand);
        
%         Heater_Power = (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set - Temp_inside) + Heat_Demand;
%         Heater_Power = max(0, Heater_Power);
        
        if Heater_Power > Dwelling_env_heat
            
            Heater_Power = Dwelling_env_heat;
            
        elseif Temperature > Temp_Set
            
            Heater_Power = 0;
            
        elseif Temp_inside < Temp_Set && Heater_Power < Dwelling_env_heat
            
            Heater_Power = Heater_Power + (1.2 * House_Volume * 1.007 + Building_Storage)/3.6 * (Temp_Set - Temp_inside);
            
            if Heater_Power > Dwelling_env_heat
            
                Heater_Power = Dwelling_env_heat;
            
            end
            
        end
            
end
        
%         if PV_usage == 1 && PowerPV > 0
%             
%             if Heater_Power > 0  && Heating_Ventil > 0
%                 
%                 PhotoVoltaic_Elec_Heat = min(Total_Heating,PowerPV);
%                 
%                 if PhotoVoltaic_Elec_Heat < 0
%                     
%                     PhotoVoltaic_Elec_Heat = 0;
%                     
%                 elseif PhotoVoltaic_Elec_Heat > Max_heating_capacity
%                     
%                     PhotoVoltaic_Elec_Heat = Max_heating_capacity;
%                     
%                 end
%                 
%                 Extra_PV_power = PowerPV - PhotoVoltaic_Elec_Heat;
%                 
%                 if Extra_PV_power < 0
%                     
%                     Extra_PV_power = 0;
%                     
%                 elseif Extra_PV_power > PowerPV
%                         
%                     Extra_PV_power = PowerPV;
%                     
%                 end
%                 
%             elseif Space_Heating > 0
%                 
%                 PhotoVoltaic_Elec_Heat = min(Space_Heating,PowerPV);
%                 
%                 if PhotoVoltaic_Elec_Heat < 0
%                     
%                     PhotoVoltaic_Elec_Heat = 0;
%                     
%                 elseif PhotoVoltaic_Elec_Heat > Dwelling_env_heat
%                     
%                     PhotoVoltaic_Elec_Heat = Dwelling_env_heat;
%                     
%                 end
%                 
%                 Extra_PV_power = PowerPV - PhotoVoltaic_Elec_Heat;
%                 
%                 if Extra_PV_power < 0
%                     
%                     Extra_PV_power = 0;
%                     
%                 elseif Extra_PV_power > PowerPV
%                         
%                     Extra_PV_power = PowerPV;
%                     
%                 end
%                 
%             elseif Heating_Ventil > 0
%                 
%                 PhotoVoltaic_Elec_Heat = min(Heating_Ventil,PowerPV);
%                 
%                 if PhotoVoltaic_Elec_Heat < 0
%                     
%                     PhotoVoltaic_Elec_Heat = 0;
%                     
%                 elseif PhotoVoltaic_Elec_Heat > Ventilation_heater
%                     
%                     PhotoVoltaic_Elec_Heat = Ventilation_heater;
%                     
%                 end
%                 
%                 Extra_PV_power = PowerPV - PhotoVoltaic_Elec_Heat;
%                 
%                 if Extra_PV_power < 0
%                     
%                     Extra_PV_power = 0;
%                     
%                 elseif Extra_PV_power > PowerPV
%                         
%                     Extra_PV_power = PowerPV;
%                     
%                 end
%                 
%             else
%             
%             Extra_PV_power = PowerPV;
%             PhotoVoltaic_Elec_Heat = 0;
%             
%             end
%             
%         else
%             
%             Extra_PV_power = 0;
%             PhotoVoltaic_Elec_Heat = 0;
%             
%         end
%         
%         Gain = Extra_PV_power/1000 * RTP(m)/100;        % The monetary gain from exporting electricity to the grid is assumed to be equal to RTP.
%         Saved_money = PhotoVoltaic_Elec_Heat/1000 * RTP(m)/100;
%         Price = (Total_Heating - PhotoVoltaic_Elec_Heat)/1000 * RTP(m)/100;        % RTP price is in cents/kWh. Consumption is changed to kWh and price to €.
%         


%% The final variables 
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. 

            
        
        Space_Heating   = Heater_Power / Space_Heating_Efficiency ;
        Total_Heating   = Space_Heating + Heating_Ventil;
%         Price           = Total_Heating/1000 * RTP/100;

%% Definition of output variables

varargout{1} = Heater_Power;
% varargout{2} = Space_Heating;
varargout{2} = Total_Heating;
% Price           = varargout{4};
end

