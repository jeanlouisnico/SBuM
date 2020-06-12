function [varargout] = PV_battery(varargin)
%% This is a function for direct electric space heating with PV generation and attached battery system
% This function describes a local generation, which is used in direct
% electric space heating, or stored for later use in the same matter.
% Heating load shifting is emphasized, and only after not being able to
% shift the heating load, the battery is charged with local generation. 
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
Nbr_batteries               = varargin{12};
State                       = varargin{13};
Current_capacity            = varargin{14};
Temp_Set                    = varargin{15};
Heat_Demand_Temp_Set        = varargin{16};
BatteryCapacity             = varargin{17};
RoundTripEfficiency         = varargin{18};
Appliances_Consumption      = varargin{19};

PowerPV = PowerPV * 1000;

%% Electric space heating part
% This part is used in the direct electric space heating with PV
% generation, heating load shifting and battery system. Load shifting is
% used first, and all the extra generation after that is used in charging
% the battery. In case the battery is charged and the heating is
% unavailable in the presence of local generation, the extra generation is
% fed to the grid. The battery system is opearated with charging and
% discharging cycles to keep the charge of the battery between 30-80 % all
% the time to prevent waring down the battery. Electricity from the battery
% is used in heating when there is need for it and when the battery is in 
% discharge cycle.

        if PV_usage == 1 && Nbr_batteries > 0
            
            % Direct usage from the generation is prioritized first, so if
            % there is generation, heat demand and temperature within the
            % limits, the generation is is used directly to heating.
            % Otherwise, it is checked if excess generation can be charged
            % to the battery.
            
            if PowerPV > 0 && (Heat_Demand + Heating_Ventil) > 0 && Temp_inside < UpperTempLimit - 0.5               % The self-consumption is prioritized over charging of battery
                
                % Take notion of the space heating efficiency and add space
                % heating to ventilation heating to check total electricity
                % consumption from heating.
                
                Input               = 0;
                Output              = 0;
                
                Space_Heating_Demand = Heat_Demand / Space_Heating_Efficiency;
                Total_Heating_Demand = Space_Heating_Demand + Heating_Ventil;
                
%                 if Space_Heating_Demand > Dwelling_env_heat
%                     Space_Heating_Demand = Dwelling_env_heat;
%                 end

                % Use either total amount of the generation to heat up the
                % building or use generation up to the heat demand.

                PhotoVoltaic_Elec_Heat = min(PowerPV, Total_Heating_Demand);
                
                % Check the values and that they are in between the
                % threshold values.
                
                if PhotoVoltaic_Elec_Heat > Max_heating_capacity
                    
                    PhotoVoltaic_Elec_Heat = Max_heating_capacity;
                    
                elseif PhotoVoltaic_Elec_Heat < 0
                    
                    PhotoVoltaic_Elec_Heat = 0;
                    
                end
                
                % Assess the extra generation in case that there is more
                % generation than consumption. 
                
                Extra_PV_power = PowerPV - PhotoVoltaic_Elec_Heat - Appliances_Consumption;            % Extra power from PV panels to be used somewhere else
                
                % Calculate space heating from the PV panels. It is
                % considered that the ventilation heating uses as much of
                % the generation as possible and rest goes to direct space
                % heating. If no ventilation heating is needed, consumed
                % generation goes fully to direct space heating.
                
% %                 if Heating_Ventil > 0
% %                 
% %                     PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat - Heating_Ventil;
% %                     
% %                 elseif Heating_Ventil <= 0
% %                     
% %                     PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat;
% %                     
% %                 end
                
                % The grid supplied electricity is calculated in case the
                % heating demand is higher than the generation.
                
% %                 Tot_Heater_Power_wo_PV = Total_Heating_Demand - PowerPV;
                
                % Check the threshold values for the grid supplied
                % electricity consumption. This means that there should not
                % be negative values nor should the consumption be more
                % than the maximum capacity. In that case, the grid
                % electricity consumption is recalculated, so the total
                % heating capacity matches.
                
% %                 if Tot_Heater_Power_wo_PV < 0
% %                     
% %                     Tot_Heater_Power_wo_PV = 0;
% %                     
% %                 elseif Tot_Heater_Power_wo_PV > (Max_heating_capacity - PhotoVoltaic_Elec_Heat)
% %                     
% %                     Tot_Heater_Power_wo_PV = Max_heating_capacity - PhotoVoltaic_Elec_Heat;     % Re-adjust the heating to match the maximum capacity. Hence, it is maximum heating capacity reduced by the PV used in heating.
% %                     
% %                 end
                
                % Check the ventilation heating, and calculate values for
                % it to be supplied from the grid.
                
% %                 if Heating_Ventil > 0
% %                 
% %                     Heater_Power_wo_PV = Tot_Heater_Power_wo_PV - Heating_Ventil;
% %                     
% %                 elseif Heating_Ventil <= 0
% %                     
% %                     Heater_Power_wo_PV = Tot_Heater_Power_wo_PV;
% %                     
% %                 end
                
                % Check that the values do not go over the limits.
                
% %                 if Heater_Power_wo_PV < 0
% %                     
% %                     Heater_Power_wo_PV = 0;
% %                     
% %                 elseif Heater_Power_wo_PV > Dwelling_env_heat
% %                     
% %                     Heater_Power_wo_PV = Dwelling_env_heat;
% %                     
% %                 end
                
                % Check the extra PV values. If there is no extra PV assing
                % it to zero. Otherwise check that it does not go negative.
                % If there is extra PV, check whether there is capacity in
                % the battery and use it to charge it.
                
                if Extra_PV_power < 0
                    
                    Extra_PV_power = 0;
                    
                elseif Extra_PV_power > 0 && State == 0
                    
                    Input = Extra_PV_power;     % Assume extra PV is equal to the input to the battery
                    Output = 0;                 % Output is zero in case of charging the battery as it cannot charge and discharge simultaneously.
                    Battery_action = 1;         % Battery action used to describe charging.
                    
                    [Battery_charge, ~, ~, Extra_input, State] = Electric_battery(Nbr_batteries, Battery_action, Input, Current_capacity, Output, State, BatteryCapacity, RoundTripEfficiency);
                
                    Current_capacity        = Battery_charge;   % Make battery charge output from the function as the current charge of the battery,
                    Extra_PV_power          = Extra_input + Appliances_Consumption;      % Add extra input to be supplied to the grid. This happens in case the battery becomes fully charged or the extra generation is higher than what can be used to charge the battery.
                    
                end
                


            % Next scenario is that there is PV generation, but no need for
            % heating. The battery is charged if the battery is considered
            % to be chargeable. 
                
            elseif PowerPV > 0 && State == 0
                
                Total_Heating_Demand = (Heat_Demand/Space_Heating_Efficiency) + Heating_Ventil;
                
                Input = PowerPV - Appliances_Consumption;        % Total generation is considered to be the standard input to the battery.
                
                if Input < 0
                    Input = 0;
                end
                
                Output = 0;             % There is no output as the battery cannot charge and discharge simultaneously.
                Battery_action = 1;     % Action 1 is for charging the battery
                
                [Battery_charge, ~, ~, Extra_input, State] = Electric_battery(Nbr_batteries, Battery_action, Input, Current_capacity, Output, State, BatteryCapacity, RoundTripEfficiency);
                
                Current_capacity        = Battery_charge;   % Use battery charge output to define the current charge of the battery.
                Extra_PV_power          = Extra_input;      % The generation that is not used to charge the battery in case it has become either fully charged or the generation is higher than the possible input to the battery. This is supplied to the grid.
                Heater_Power_wo_PV      = 0;                % No heating is occuring as the PV generation would otherwise be firstly used to that.
                PhotoVoltaic_Elec_Heat  = 0;                % No heating from the PV panels.
                PhotoVoltaic_Space_Heat = 0;                % No heating from the PV panels.
                
            % Next scenario is that there is no PV generation, but that the
            % battery is charged enough to supply electricity to match the
            % heating demand. Temperature needs to be under the deadband
            % value.
                
            elseif Current_capacity > 0 && (Heat_Demand + Heating_Ventil) > 0 && State == 1 % Temp_inside < LowerTempLimit + 1.5 && State == 1
                
                % Take space heating efficiency in to notion and add
                % ventilation heating to the space heating in order to
                % create total heating demand.
                
                Space_Heating_Demand = Heat_Demand / Space_Heating_Efficiency;
                Total_Heating_Demand = Space_Heating_Demand + Heating_Ventil;
                
                % As battery cannot charge and discharge simultanously, the
                % input to the battery is zero. 
                
                Input = 0;
                
                % Standard input for the electric battery function is the
                % smaller value from total heating demand or from current
                % capacity. This the maximum value that could be used from
                % the battery to match heat demand when the restrictions
                % are not considered. 
                
                Output = min(Total_Heating_Demand, Current_capacity);
                
                % Output cannot be negative.
                
                if Output < 0
                    
                    Output = 0;
                    
                end
                
                Battery_action = 2;     % Action 2 is for discharging the battery
                
                [Battery_charge, Input, Output, ~, State] = Electric_battery(Nbr_batteries, Battery_action, Input, Current_capacity, Output, State, BatteryCapacity, RoundTripEfficiency);
                
%                 PhotoVoltaic_Elec_Heat = min(Output, Space_Heating_Demand);

                % Output from the function is considered to be equal to PV
                % generated electricity consumption, since the battery has
                % been charged with PV generated electricity.
               
                PhotoVoltaic_Elec_Heat = Output;
                
                % Check that the values are within the capacity values.
                
                if PhotoVoltaic_Elec_Heat > Max_heating_capacity
                    
                    PhotoVoltaic_Elec_Heat = Max_heating_capacity;
                    
                elseif PhotoVoltaic_Elec_Heat < 0
                    
                    PhotoVoltaic_Elec_Heat = 0;
                    
                end
                
                % Assign the current battery charge output as the current
                % charge of the battery.
                
                Current_capacity = Battery_charge;
                
                % Calculate the PV based space heating from the battery.
                % It is considered that the electricity is first supplied
                % to ventilation heating. If there is no requirements for
                % heating the ventilation air, all is used in space
                % heating.
                
% %                 if Heating_Ventil > 0
% %                 
% %                     PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat - Heating_Ventil;
% %                     
% %                 elseif Heating_Ventil <= 0
% %                     
% %                     PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat;
% %                     
% %                 end
                
                % Calculate the heating supplied by the grid.
                
% %                 Tot_Heater_Power_wo_PV = Total_Heating_Demand - PhotoVoltaic_Elec_Heat;
                
                % Check that the values are within the capacity ranges. If
                % not calculate heating from maximum heating capacity and
                % electricity supplied from battery.
                
% %                 if Tot_Heater_Power_wo_PV < 0
% %                     
% %                     Tot_Heater_Power_wo_PV = 0;
% %                     
% %                 elseif Tot_Heater_Power_wo_PV > (Max_heating_capacity - PhotoVoltaic_Elec_Heat)
% %                     
% %                     Tot_Heater_Power_wo_PV = Max_heating_capacity - PhotoVoltaic_Elec_Heat;
% %                     
% %                 end
                
                % Calculate grid supplied space heating amount from the
                % ventilation heating.
                
% %                 if Heating_Ventil > 0       % THIS MIGHT NOT BE CORRECT! CHECK THE OTHER ONES AS WELL.
% %                 
% %                     Heater_Power_wo_PV = Tot_Heater_Power_wo_PV - Heating_Ventil;
% %                     
% %                 elseif Heating_Ventil <= 0
% %                     
% %                     Heater_Power_wo_PV = Tot_Heater_Power_wo_PV;
% %                     
% %                 end
                
                % Check the values so that they are inside the limits.
                
% %                 if Heater_Power_wo_PV < 0
% %                     
% %                     Heater_Power_wo_PV = 0;
% %                     
% %                 elseif Heater_Power_wo_PV > Dwelling_env_heat
% %                     
% %                     Heater_Power_wo_PV = Dwelling_env_heat;
% %                     
% %                 end
                
                % If there is generation from the PV panels it is supplied
                % to the grid as there battery is already discharging. If
                % there is no production, the supplied value is zero.
                
                if PV_usage == 1 && PowerPV > 0
                    
                    Extra_PV_power = PowerPV;
                    
                    if Extra_PV_power < 0
                        Extra_PV_power = 0;
                    end
                    
                else
                    
                    Extra_PV_power = 0;
                    
                end
                
            % Scenario where the battery is out of the discharge cycle and
            % there is no PV generation, but the inside temperature is
            % under the lower temperature threshold value. Then heating is
            % considered to deliver heat equal to the heat demand in order
            % to comply with the thermal comfort limits.
                
            elseif Temp_inside < Temp_Set %LowerTempLimit + 0.5
                
                Total_Heating_Demand = (Heat_Demand/Space_Heating_Efficiency + Heating_Ventil); 
                
%                 Heater_Power_wo_PV = Heat_Demand_Temp_Set / Space_Heating_Efficiency; 
%                 
%                 if Heater_Power_wo_PV < 0
%                     
%                     Heater_Power_wo_PV = 0;
%                     
%                 end
                
                % In this case there is no direct electric heating from the
                % generation and all possible generation is considered to
                % be supplied to the grid.
                
                PhotoVoltaic_Elec_Heat      = 0;
                PhotoVoltaic_Space_Heat     = 0;
                Extra_PV_power              = PowerPV;
                
                Input                       = 0;
                Output                      = 0;
                
            % Scenario where there is no need for heating. Heating values
            % are assigned to zero, and generation is supplied to the grid.
                
            else 
                
                Total_Heating_Demand = (Heat_Demand / Space_Heating_Efficiency) + Heating_Ventil;
%                 Heater_Power_wo_PV          = 0;
                PhotoVoltaic_Elec_Heat      = 0;
%                 PhotoVoltaic_Space_Heat     = 0;
                Extra_PV_power              = PowerPV;
                
                Input                       = 0;
                Output                      = 0;
                
            end
            
        % Scenario where PV panels are not considered to generate
        % electricity, as the input value is wrong. The simulation goes
        % through by considering fulfilling the heat demand. A warning is
        % delivered.
            
        else
            
            msg = 'Either PV generation or battery system is missing!';
            error(msg)
            
        end
        
        % Beginning of general calculations! Here the heater power as an
        % output is calculated. There is also a check-up that the maximum
        % space heating capacity is not crossed over, or that the heating
        % value is not negative.
        
%         Heater_Power = Heater_Power_wo_PV + PhotoVoltaic_Space_Heat;
%         
%         if Heater_Power * Space_Heating_Efficiency > Dwelling_env_heat
%             
%             Heater_Power = Dwelling_env_heat / Space_Heating_Efficiency;
%             
%         elseif Heater_Power < 0
%             
%             Heater_Power = 0;
%             
%         end
        
        
        

%% The final variables
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. 

        Heater_Power            = (Total_Heating_Demand - Heating_Ventil) * Space_Heating_Efficiency;
        Space_Heating           = Heater_Power/Space_Heating_Efficiency;
%         Heater_Power            = Space_Heating * Space_Heating_Efficiency;
        Total_Heating           = Space_Heating + Heating_Ventil;
        Gain                    = Extra_PV_power/1000 * RTP/100;
        Saved_money             = PhotoVoltaic_Elec_Heat/1000 * RTP/100; % The utilized own generation is considered as saving.

%% Outputs

varargout{1} = Heater_Power            ;
varargout{2} = Space_Heating           ;
varargout{3} = Total_Heating           ;
varargout{4} = Extra_PV_power          ;
varargout{5} = Gain                    ;
varargout{6} = Saved_money             ;
varargout{7} = PhotoVoltaic_Elec_Heat  ;
varargout{8} = Current_capacity        ;
varargout{9} = State                   ;
varargout{10}= Input                   ;
varargout{11}= Output                  ;    

end