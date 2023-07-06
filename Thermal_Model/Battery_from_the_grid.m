function [varargout] = Battery_from_the_grid(varargin)
%% This is a function for direct electric space heating utilizing battery systems charged with grid-based electricity
% This function is for direct electric space heating with grid connected
% battery system that can charge themselves with cheaper electricity from
% the grid and discharge at the time of high electricity prices. This does
% not include any local generation.
%% Inputs 

Temp_inside                 = varargin{1};
LowerPriceLimit             = varargin{2};
UpperPriceLimit             = varargin{3};
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
Elec_value_battery          = varargin{15};
myiter                      = varargin{16};
Temp_Set                    = varargin{17};
Heat_Demand_Temp_Set        = varargin{18};
BatteryCapacity             = varargin{19};
RoundTripEfficiency         = varargin{20};

%% Electric space heating part
% This part is used in the direct electric space heating with electricity
% grid connected battery systems. The heating is mainly based on meeting 
% the heat demand and thermal comfort temperatures. Battery charging is
% based on the last year's real-time price and the given percentage. The
% percentage is used to define the electricity price under which the
% percentile of the percentage value was. This is the price limit for
% charging the battery. Similarly, the value of the electricity inside the
% battery is calculated and is used together with the upper price limit as
% a rule for discharging the battery for direct electric space heating. The
% upper price limit considers the investment costs, lower price limit and
% the number and depth of discharge of the battery. 

        % Consider that the maximum take from the grid (heating + charging)
        % is equal to the dwelling heating capacity.
        
        if RTP < LowerPriceLimit && State == 0       % If the price of electricity is lower than the given threshold value, the system should charge the battery if the battery is in the charging state
            
            Input = Dwelling_env_heat;  % The whole capacity can be used in charging the battery. The actual value is likely lower due to the input limitation, but this value can be used in calling the function.
            Output = 0;                 % There is no output as the battery cannot charge and discharge simultaneously.
            Battery_action = 1;         % Action 1 is for charging the battery
            
            [Battery_charge, Input, ~, Extra_input, State] = Electric_battery(Nbr_batteries, Battery_action, Input, Current_capacity, Output, State, BatteryCapacity, RoundTripEfficiency);
                
            Current_capacity        = Battery_charge;   % Use battery charge output to define the current charge of the battery.
%             Battery_efficiency      = 0.9;
            
            if Elec_value_battery == 0
                Elec_value_battery = (RTP * (Input/1000))/(Battery_charge/1000);
            else
                Elec_value_battery   = ((Elec_value_battery * (Battery_charge/1000 - Input/1000 * RoundTripEfficiency)) + (RTP * Input/1000))/(Current_capacity/1000);    % Calculate the value of the electricity inside the battery by €cent/kWh, Current capacity is in Wh so transformation is needed
            end
            
%                             Elec_value_battery(m)   = ((Elec_value_battery(m-1) * (Battery_charge - Input * Battery_efficiency)) + (RTP(m) * Input)/(Input * Battery_efficiency))/Current_capacity;    % Calculate the value of the electricity inside the battery by €/kWh

            
            % Define if the building needs heating and the inside
            % temperature is lower than the upper temperature limit
            
            if Heat_Demand > 0 && Temp_inside < UpperTempLimit - 1.5
                
                Heater_Power = Heat_Demand;     % Heater Power is used to match the heat demand
                
                if Heater_Power > Extra_input   % Heater Power cannot be higher than the extra input from the battery system
                    Heater_Power = Extra_input;
                elseif Heater_Power < 0         % Heater Power cannot be negative
                    Heater_Power = 0;
                end
                
            else
                
                Heater_Power = 0;               % Otherwise there is no need to heat the building.
                
            end
            
                Heater_Power_wo_PV      = 0;    % No electricity comes from the panels
                PhotoVoltaic_Elec_Heat  = 0;
                PhotoVoltaic_Space_Heat = 0;
                Extra_PV_power          = 0;    % Assume no PV generation                
                
        elseif RTP > UpperPriceLimit && RTP > Elec_value_battery && State == 1 && Heat_Demand > 0 && Temp_inside < UpperTempLimit - 1.5 && Current_capacity > 0 % In case it is cheaper to heat the building by using electricity from the battery than from the grid and the battery is in discharge state.
            %Elec_value_battery(m) > UpperPriceLimit &&
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
                
                if Output > Dwelling_env_heat
                    
                    Output = Dwelling_env_heat;
                    
                end
                
                % Output cannot be negative.
                
                if Output < 0
                    
                    Output = 0;
                    
                end
                
                Battery_action = 2;     % Action 2 is for discharging the battery
                
                [Battery_charge, ~, Output, ~, State] = Electric_battery(Nbr_batteries, Battery_action, Input, Current_capacity, Output, State, BatteryCapacity, RoundTripEfficiency);
                
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
                
                if Heating_Ventil > 0
                
                    PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat - Heating_Ventil;
                    
                elseif Heating_Ventil <= 0
                    
                    PhotoVoltaic_Space_Heat = PhotoVoltaic_Elec_Heat;
                    
                end
                
                % Calculate the heating supplied by the grid.
                
                Tot_Heater_Power_wo_PV = Total_Heating_Demand - PhotoVoltaic_Elec_Heat;
                
                % Check that the values are within the capacity ranges. If
                % not calculate heating from maximum heating capacity and
                % electricity supplied from battery.
                
                if Tot_Heater_Power_wo_PV < 0
                    
                    Tot_Heater_Power_wo_PV = 0;
                    
                elseif Tot_Heater_Power_wo_PV > (Max_heating_capacity - PhotoVoltaic_Elec_Heat)
                    
                    Tot_Heater_Power_wo_PV = Max_heating_capacity - PhotoVoltaic_Elec_Heat;
                    
                end
                
                % Calculate grid supplied space heating amount from the
                % ventilation heating.
                
                if Heating_Ventil > 0       % THIS MIGHT NOT BE CORRECT! CHECK THE OTHER ONES AS WELL.
                
                    Heater_Power_wo_PV = Tot_Heater_Power_wo_PV - Heating_Ventil;
                    
                elseif Heating_Ventil <= 0
                    
                    Heater_Power_wo_PV = Tot_Heater_Power_wo_PV;
                    
                end
                
                % Check the values so that they are inside the limits.
                
                if Heater_Power_wo_PV < 0
                    
                    Heater_Power_wo_PV = 0;
                    
                elseif Heater_Power_wo_PV > Dwelling_env_heat
                    
                    Heater_Power_wo_PV = Dwelling_env_heat;
                    
                end
                
                Heater_Power = PhotoVoltaic_Space_Heat + Heater_Power_wo_PV;
                
                Extra_PV_power = 0; %PowerPV;
                
                if myiter == 0
                    Elec_value_battery = Elec_value_battery;
                elseif Current_capacity == 0
                    Elec_value_battery = 0;
                else
                    Elec_value_battery = Elec_value_battery;
                end
                
        elseif Heat_Demand > 0 && Temp_inside < Temp_Set % LowerTempLimit + 1.5        % The case where the heater is on normally
            
            Heater_Power = Heat_Demand_Temp_Set;
            
            Input = 0;
            
            Heater_Power_wo_PV      = 0;    % No electricity comes from the panels
            PhotoVoltaic_Elec_Heat  = 0;
            PhotoVoltaic_Space_Heat = 0;
            Extra_PV_power          = 0; %PowerPV; 
            

            
        else
            
            Input = 0;
            
            Heater_Power            = 0;
            Heater_Power_wo_PV      = 0;    % No electricity comes from the panels
            PhotoVoltaic_Elec_Heat  = 0;
            PhotoVoltaic_Space_Heat = 0;
            Extra_PV_power          = 0; %PowerPV; 
            

                
        end
        
        
%% The final variables
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. 

        Space_Heating = Heater_Power/Space_Heating_Efficiency;
        Total_Heating = Space_Heating + Heating_Ventil;
        Gain = 0;
        Saved_money = PhotoVoltaic_Elec_Heat/1000 * (RTP - Elec_value_battery)/100; % The utilized own generation is considered as saving.
        


%% Outputs

varargout{1} = Heater_Power            ;
varargout{2} = Space_Heating           ;
varargout{3} = Total_Heating           ;
varargout{4} = Gain                    ;
varargout{5} = Saved_money             ;
varargout{6} = PhotoVoltaic_Elec_Heat  ;
varargout{7} = Current_capacity        ;
varargout{8} = State                   ;
varargout{9} = Input                   ;

end