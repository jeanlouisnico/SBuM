function [varargout] = PV_load_shifting(varargin)
%% This is a function for direct electric space heating with PV generation and load shifting
% This function aims in utilizing direct electric space heating with PV
% generation and shift the heating load according to the local generation.
% It utilizes also heat demand, and thermal comfort temperature limits.

%% Inputs 

Temp_inside                 = varargin{1};
PV_usage                    = varargin{2};
PowerPV                     = varargin{3};
Heat_Demand                 = varargin{4};
LowerTempLimit              = varargin{5};
UpperTempLimit              = varargin{6};
Dwelling_env_heat           = varargin{7};
Space_Heating_Efficiency    = varargin{8};
RTP                         = varargin{9};
Heating_Ventil              = varargin{10};
Max_heating_capacity        = varargin{11};
Temp_Set                    = varargin{12};
Heat_Demand_Temp_Set        = varargin{13};
Heat_Demand_Upper_Temp_Limit = varargin{14};

LowerTempLimit = Temp_Set;

PowerPV = PowerPV * 1000;

%% Electric space heating part
% This part is used in the direct electric space heating with PV generation
% and heating load shifting. Aim is to utilize local generation immediately
% if there is generation, heat demand and the indoor temperature is under
% the threshold value. Heating limitations come from the local generation
% amount, radiator power capacity and indoor temperature. PV generation
% utilization is emphasized and it can be used in direct electric space
% heating or in ventilation heating. If the local generation cannot be used
% then it is fed in to the grid. 


        if PV_usage == 1
            
            % Test if PV cells produce electricity, that there is heat
            % demand that needs to be fullfilled and that the inside
            % temperature does not rise too high.
            
            if PowerPV > 0 && (Heat_Demand_Upper_Temp_Limit + Heating_Ventil) > 0 && Temp_inside < UpperTempLimit - 0.5 % (Heat_Demand + Heating_Ventil) > 0 && Temp_inside < UpperTempLimit - 0.5
                
                % Take space heating inefficiencies into account.
                
                Space_Heating_Demand = Heat_Demand / Space_Heating_Efficiency;
                
                % Add ventilation heating to the total heating demand as it
                % also requires eletricity.
                
                Total_Heating_Demand = Space_Heating_Demand + Heating_Ventil;
                
%                 if Space_Heating_Demand > Dwelling_env_heat
%                     Space_Heating_Demand = Dwelling_env_heat;
%                 elseif Space_Heating_Demand < 0
%                     Space_Heating_Demand = 0;
%                 end

                % The power delivered to the heater from photovoltaic
                % generation is either the produced amount or the total
                % heat demand based on by the one which is smaller. This is
                % due to either using all the generation to match as much
                % of the heat demand as possible, or to use PV generation
                % all the way to match as much from the heat demand as
                % possible.

                PhotoVoltaic_Elec_Heat = min(PowerPV, Total_Heating_Demand);
                
                % Check that the electric heating taken from the PV is not
                % bigger than the total heating capacity, and that the
                % heating is not negative.
                
                if PhotoVoltaic_Elec_Heat > Max_heating_capacity
                    
                    PhotoVoltaic_Elec_Heat = Max_heating_capacity;
                    
                elseif PhotoVoltaic_Elec_Heat < 0
                    
                    PhotoVoltaic_Elec_Heat = 0;
                    
                end
                
                % Differentiate ventilation heating from the direct space
                % heating. If there is no need for ventilation heating,
                % then all the electricity goes to direct space heating.
                
                if Heating_Ventil > 0
                
                    PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat - Heating_Ventil;
                    
                elseif Heating_Ventil <= 0
                    
                    PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat;
                    
                end
                
                if PhotoVoltaic_Space_Heat < 0
                    
                    PhotoVoltaic_Space_Heat = 0;
                    
                end
                
                % Now calculate the heating electricity consumption that is
                % not taken from PV cells generation.
                
                if Temp_inside > UpperTempLimit - 1.5
                    
                    Tot_Heater_Power_wo_PV = 0;
                    
                else
                
                    Tot_Heater_Power_wo_PV = Total_Heating_Demand - PowerPV;
                    
                end
                
                % Check that the electricity consumption from the grid is
                % within the threshold values. This means that the heating
                % cannot be negative and that the overall heating cannot be
                % higher than the radiator capacity. In the case of higher
                % heating calculated, the value is corrected to match the
                % overall heater capacity.
                
                if Tot_Heater_Power_wo_PV < 0
                    
                    Tot_Heater_Power_wo_PV = 0;
                    
                elseif Tot_Heater_Power_wo_PV > (Max_heating_capacity - PhotoVoltaic_Elec_Heat)
                    
                    Tot_Heater_Power_wo_PV = Max_heating_capacity - PhotoVoltaic_Elec_Heat;
                    
                end
                
                % Now the same check up is made with the ventilation
                % heating, and the electricity used in it, is calculated.
                % At the same time the radiator heater power from the grid
                % is being calculated.
                
                if Heating_Ventil > 0
                
                    Heater_Power_wo_PV = Tot_Heater_Power_wo_PV - Heating_Ventil;
                    
                elseif Heating_Ventil <= 0
                    
                    Heater_Power_wo_PV = Tot_Heater_Power_wo_PV;
                    
                end
                
                % Same check up is done once again in order to check that
                % the radiator heating is within the threshold values and
                % corrected accordingly if not. 
                
                if Heater_Power_wo_PV < 0
                    
                    Heater_Power_wo_PV = 0;
                    
                elseif Heater_Power_wo_PV > Dwelling_env_heat
                    
                    Heater_Power_wo_PV = Dwelling_env_heat;
                    
                end
                
            % In the case that there is no PV power generated at the moment
            % the system still needs to be kept within the temperature
            % limit in order to provide comfort to the occupants. Thus, the
            % system keeps heating the house if the temperature drops under
            % the a deadband value given for the lower temperature limit.
            % The chosen value is 1.5 degrees higher than the lower
            % temperature limit.
                
            elseif Temp_inside < Temp_Set % LowerTempLimit %Temp_inside < LowerTempLimit + 1.5
                
                % Yet again, calculate the heating demand, and take the
                % space heating efficiency in to consideration. 
                
                Heater_Power_wo_PV = Heat_Demand_Temp_Set; % / Space_Heating_Efficiency; 
                
                % Confirm that the heating is not negative nor goes over
                % the heating capacity.
                
                if Heater_Power_wo_PV < 0
                    
                    Heater_Power_wo_PV = 0;
                    
                elseif Heater_Power_wo_PV > Dwelling_env_heat
                    
                    Heater_Power_wo_PV = Dwelling_env_heat;
                    
                end
                
                % In this case there is no heating coming from the PV
                % generation so the values need to be addressed as zeros.
                
                PhotoVoltaic_Elec_Heat = 0;
                PhotoVoltaic_Space_Heat = 0;
                
            % If there is no PV generation and the temperature is within
            % its given limits while taking the deadband value in to notice
            % there is no direct space heating as a first guess. If the
            % temperature drops under the limit, it will be corrected later
            % on.
                
            else
                
                % As there is no heating nor generation as a first guess,
                % address the according values to zeros.
                
                Heater_Power_wo_PV = 0;
                PhotoVoltaic_Elec_Heat = 0;
                PhotoVoltaic_Space_Heat = 0;
                
            end
            
        % A scenario where the heating is chosen to be from the PV
        % generation, but the PV panels have not been chosen for the
        % heating as an input value. As load shifting from local generation
        % cannot be utilized if there is no local generation, an error is
        % given in this situation!
            
        else
            
            msg = 'PV generation is not on! PV with load shifting can only be applied when PV system is on!';
            error(msg)
            
        end


%% The final variables
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. 

        Heater_Power = Heater_Power_wo_PV + PhotoVoltaic_Space_Heat * Space_Heating_Efficiency;
        Space_Heating = Heater_Power / Space_Heating_Efficiency;
        Total_Heating = Space_Heating + Heating_Ventil + (PhotoVoltaic_Elec_Heat - PhotoVoltaic_Space_Heat);    % Their difference is used in ventilation heating!
        Extra_PV_power = PowerPV - PhotoVoltaic_Elec_Heat;
%         Price = (Total_Heating - PhotoVoltaic_Elec_Heat)/1000 * RTP/100;
        Gain = Extra_PV_power/1000 * RTP/100;
        Saved_money = PhotoVoltaic_Elec_Heat/1000 * RTP/100;         % The utilized own generation can be considered to be "saved money" from preventing electricity purchase from the grid.

%% Outputs

varargout{1} = Heater_Power            ;
varargout{2} = Space_Heating           ;
varargout{3} = Total_Heating           ;
varargout{4} = Gain                    ;
varargout{5} = Saved_money             ;
varargout{6} = PhotoVoltaic_Elec_Heat  ;
% varargout{7} = Extra_PV_power          ;

end

