function [varargout] = Underfloor_heating(varargin)
%% This is a function for electrically charged thermal storage for underfloor heating
% The funftion is for electrically charged thermal storage heater, which is
% represented by underfloor heater here. There are several different
% charging strategies for the thermal storage and they are presented here.
% The heat output comes from the indoor temperature function, which is
% modified for input to the floor.
%% Inputs 

Heating_time                    = varargin{1};
Dwelling_env_heat               = varargin{2};
Underfloor_heating_efficiency   = varargin{3};
RTP                             = varargin{4};
timehour                        = varargin{5};
Temperature                     = varargin{6};
Mean_yesterday                  = varargin{7};
Heat_Demand                     = varargin{8};
Current_capacity                = varargin{9};
Heat_Demand_estimation          = varargin{10};
Used_Hours                      = varargin{11};
PV_Usage                        = varargin{12};
PowerPV                         = varargin{13};
PowerPV_estimation              = varargin{14};
Cumulative_input                = varargin{15};
Temp_inside                     = varargin{16};
LowerTempLimit                  = varargin{17};
Charging_strategy               = varargin{18};
lgts                            = varargin{19};
lgte                            = varargin{20};
myiter                          = varargin{21};
Heating_Hours                   = varargin{22};
Previous_Temperature_core       = varargin{23};
Heating_Ventil                  = varargin{24};
Ventilation_Heater              = varargin{25};
Temp_Set                        = varargin{26};
Cumulative_input_PV             = varargin{27};
Input_Matrix                    = varargin{28};
UpperTempLimit                  = varargin{29};

%% Charging the thermal storage
% This section describes the various charging strategies for the thermal
% storage. The current charging strategies are: Set times, Cheapest hours
% and PV charging. The respective strategies are defined here, but their
% differences are utilizing either only electricity from the grid or by
% combining the local generation and grid-based electricity. Similarly,
% grid-based electricity may be used either in set times or by the cheapest
% available hours with real-time-pricing. 

        Max_Input = (Underfloor_heating_efficiency * 24 * 1.3 * Dwelling_env_heat)/Heating_time;    % 1.3 is the safety factor in order for the system to have fast responses, and 0.85 is the annual efficiency of the system
        
        if Max_Input > 200 * (lgts*lgte)
            
            Extra_heater_capacity = Max_Input - 200*(lgts*lgte);
            Max_Input = 200 *(lgts*lgte);               % Devi am; higher than that requires extra heating capacity
            
        end
        
        Max_Storage_capacity = Max_Input * Heating_time;% Storage can be loaded to full in eight hours
        density = 2000;                                 % Density of concrete
        Thickness = 0.15;                               % Thickness of the concrete floor
        Weight = lgts * lgte * Thickness * density;     % Weight of concrete floor
        Heat_capacity = 840/3600;                       % Heat capacity of the concrete inside the storage (From J to Wh)
        Lambda = 1.37;                                  % Thermal conductivity
        R = Thickness / Lambda;                         % Heat resistance of concrete
        % R = 0.125;                                    % Heat resistance value on top of the heating coils on the floor
        U = 1/R;                                        % Total thermal transmittance value for the floor
        
        if myiter == 0 
            
            Current_capacity = 0;
            
        end
        
        Previous_capacity = Current_capacity;           % Store the previous capacity in case of over-charging
        Current_capacity1 = Current_capacity;
        
        switch(Charging_strategy)
            
            case 'Set Time'
                
               if timehour >= 0 && timehour < 8 && (Heat_Demand > 0 || (Temperature < 15 && Mean_yesterday < 15))

                    
                    Input = (Heat_Demand_estimation / Heating_time); % / Underfloor_heating_efficiency;
                    
                    if Input < 0
                        
                        Input = 0;
                        
                    elseif Input > Max_Input
                        
                        Input = Max_Input;
                        
                    end
                    
                    Stored_Heat = Underfloor_heating_efficiency * Input;
                    Current_capacity = Previous_capacity + Stored_Heat;
                    
%                     if Current_capacity > Max_Storage_capacity          % Current capacity cannot be higher than max storage capacity
%                         
%                         Current_capacity = Max_Storage_capacity;
%                         Input = (Current_capacity - Previous_capacity) / Underfloor_heating_efficiency;
                        
%                     end
                    
                    Loading = 1;
                    Extra_PV = PowerPV;
                    PhotoVoltaic_Elec_Heat = 0;
                    
                else
                    
                    Loading = 0;
                    Input = 0;
                    Extra_PV = PowerPV;
                    PhotoVoltaic_Elec_Heat = 0;
                    
               end
                
%                                Previous_Temperature_core = 0;
                
            case 'Cheapest Hours'
                

                % Check if the actual RTP price is lower than the unused
                % heating hours in the prediction
                
%                 if any(timehour == Heating_Hours-1) == 1 && Current_capacity < Max_Storage_capacity && Current_capacity < Heat_Demand_estimation && Temperature < 15 && Mean_yesterday < 15
                if any(timehour + 1 == Input_Matrix(:,1)) == 1 && (Heat_Demand > 0 || (Temperature < 15 && Mean_yesterday < 15)) % && Current_capacity < Max_Storage_capacity && Current_capacity < Heat_Demand_estimation 
                    
                    Input = (Heat_Demand_estimation / Heating_time); %/Underfloor_heating_efficiency;
                    
                    if Input < 0
                        
                        Input = 0;
                        
                    elseif Input > Max_Input 
                        
                        Input = Max_Input;
                        
                    end
                    
                    Stored_Heat = Input;
                    Current_capacity = Previous_capacity + Stored_Heat;
                    Used_Hours = Used_Hours + 1;
                    
                    if Current_capacity > Max_Storage_capacity          % Current capacity cannot be higher than max storage capacity
                        
                        Current_capacity = Max_Storage_capacity;
                        Input = (Current_capacity - Previous_capacity);
                        
                    end
                    
                    Loading = 1;
                    Extra_PV = PowerPV;
                    PhotoVoltaic_Elec_Heat = 0;
                    
                else
                    
                    Loading = 0;
                    Input = 0;
                    Extra_PV = PowerPV;
                    PhotoVoltaic_Elec_Heat = 0;
                    
                end
                
%                 Previous_Temperature_core = 0;
                
            case 'PV charging'
                
                if PV_Usage == 1
                    
                    if PowerPV > 0 && Heat_Demand_estimation > 0 && Mean_yesterday < 15 && Current_capacity < Max_Storage_capacity && Current_capacity < Heat_Demand_estimation && Temp_inside < UpperTempLimit - 1.5 %&& (Cumulative_input/Underfloor_heating_efficiency) < Heat_Demand_estimation
                        
                        Input                   = PowerPV * 1000; % * Underfloor_heating_efficiency;
                        PhotoVoltaic_Elec_Heat  = PowerPV * 1000; %Input/Underfloor_heating_efficiency;
                        Extra_PV                = 0;
                        
                        if Input > Max_Input
                            
                            Input = Max_Input;
                            Extra_PV = PowerPV * 1000 - Input; % /Underfloor_heating_efficiency;
                            
                        elseif Input < 0
                            
                            Input = 0;
                            
                        end
                        
                        Stored_Heat = Underfloor_heating_efficiency * Input;
                        Current_capacity = Previous_capacity + Stored_Heat;
                        Cumulative_input_PV = Cumulative_input_PV + PhotoVoltaic_Elec_Heat;
                        
                        if Current_capacity > Max_Storage_capacity
                            
                            Current_capacity = Max_Storage_capacity;
                            Input = (Max_capacity - Previous_capacity);
                            Extra_PV = PowerPV * 1000 - Input; %/Underfloor_heating_efficiency;
                        
                        end
                        
                        if Heating_Ventil > 0
                            
                            PhotoVoltaic_Elec_Heat  = PhotoVoltaic_Elec_Heat + min(Heating_Ventil,Extra_PV);
                            Extra_PV                = Extra_PV - min(Heating_Ventil,Extra_PV); % PhotoVoltaic_Elec_Heat;
                            
%                         else
%                             
%                             PhotoVoltaic_Elec_Heat = 0;
                            
                        end
                        
                        Loading = 1;
                        
%                         if Input == Max_Input
%                             PhotoVoltaic_Elec_Heat = PhotoVoltaic_Elec_Heat + Input;
%                         else
%                             PhotoVoltaic_Elec_Heat = PhotoVoltaic_Elec_Heat + Input/Underfloor_heating_efficiency;
%                         end
                            
                        if PhotoVoltaic_Elec_Heat > PowerPV * 1000
                            PhotoVoltaic_Elec_Heat = PowerPV * 1000;
%                             Heating_Ventil = Heating_Ventil + (PhotoVoltaic_Elec_Heat - PowerPV);
                        elseif PhotoVoltaic_Elec_Heat < 0
                            PhotoVoltaic_Elec_Heat = 0;
                        end
                        
                    elseif Temp_inside < Temp_Set && Heat_Demand_estimation > 0 && Mean_yesterday < 15 && Cumulative_input_PV < PowerPV_estimation && Cumulative_input < Heat_Demand_estimation %LowerTempLimit + 0.5 && Heat_Demand_estimation > 0 && Mean_yesterday < 15 && Cumulative_input < PowerPV_estimation 
                        
                        Input = (Heat_Demand_estimation - PowerPV_estimation)/Underfloor_heating_efficiency;     % Use the estimated amount of input from the grid as default input value.
                        
                        if Input > (Heat_Demand_estimation/Heating_time)/Underfloor_heating_efficiency
                            
                            Input = (Heat_Demand_estimation / Heating_time)/Underfloor_heating_efficiency;
                            
                            if Input > Max_Input
                                
                                Input = Max_Input;
                                
                            end
                            
                        elseif Input < 0
                            
                            Input = 0;
                        end
                        
                        Stored_Heat = Input;
                        Current_capacity = Previous_capacity + Stored_Heat;
                        
                            Extra_PV = PowerPV * 1000 - Input; %/Underfloor_heating_efficiency;
                            PhotoVoltaic_Elec_Heat = Input - PowerPV * 1000;
                            
                            if PhotoVoltaic_Elec_Heat < 0
                                PhotoVoltaic_Elec_Heat = Input;
                            elseif PowerPV == 0
                                PhotoVoltaic_Elec_Heat = 0;
                            else
                                PhotoVoltaic_Elec_Heat = PowerPV * 1000;
                            end
                            
                            if Extra_PV < 0
                                
                                Extra_PV = 0;
                                
                            end
                            
                            Cumulative_input_PV = Cumulative_input_PV + PhotoVoltaic_Elec_Heat;
                        
                        if Current_capacity > Max_Storage_capacity
                            
                            Current_capacity = Max_Storage_capacity;
                            Input = (Max_Storage_capacity - Previous_capacity);
                            
                            if Input > Max_Input
                                
                                Input = Max_Input;
                                
                            elseif Input < 0
                                
                                Input = 0;
                                
                            end
                            
                            Extra_PV = PowerPV * 1000 - Input; %/Underfloor_heating_efficiency;
                            PhotoVoltaic_Elec_Heat = Input - PowerPV * 1000;
                            
                            if PhotoVoltaic_Elec_Heat < 0
                                PhotoVoltaic_Elec_Heat = Input;
                            elseif PowerPV == 0
                                PhotoVoltaic_Elec_Heat = 0;
                            else
                                PhotoVoltaic_Elec_Heat = PowerPV * 1000;
                            end
                            
                            if Extra_PV < 0
                                
                                Extra_PV = 0;
                                
                            end
                            
%                         else
%                             
%                             Extra_PV = 0;
                            
                        end
                        
%                         PhotoVoltaic_Elec_Heat  = 0;
                        Loading                 = 1;
                        
                    elseif Temp_inside < Temp_Set && Heat_Demand_estimation > 0 && Cumulative_input < Heat_Demand_estimation % LowerTempLimit + 0.5 && Heat_Demand_estimation > 0
                        
                        Input = (Heat_Demand_estimation - Cumulative_input)/Underfloor_heating_efficiency; %(Heat_Demand_estimation / Heating_time)/Underfloor_heating_efficiency;
                        
                        if Input > Max_Input
                            Input = Max_Input;
                        elseif Input > (Heat_Demand_estimation/Heating_Hours)/Underfloor_heating_efficiency
                            Input = (Heat_Demand_estimation/Heating_Hours)/Underfloor_heating_efficiency;
                        end
                        
                        if Input < 0
                            Input = 0;
                        end
                        
                        Stored_Heat = Input;
                        Current_capacity = Previous_capacity + Stored_Heat;
                        
                        if Current_capacity > Max_Storage_capacity
                            
                            Current_capacity = Max_Storage_capacity;
                            Input = (Max_Storage_capacity - Previous_capacity);
                            Extra_PV = PowerPV * 1000 - Input; %/Underfloor_heating_efficiency;
                            
                            if Extra_PV < 0
                                
                                Extra_PV = 0;
                                
                            end
                            
                        else
                            
                            Extra_PV = 0;
                            
                        end
                        
                        PhotoVoltaic_Elec_Heat = 0;
                        Cumulative_input_PV = Cumulative_input_PV + PhotoVoltaic_Elec_Heat;
                        Loading = 1;
                        
                    else
                        
                        Extra_PV = PowerPV * 1000;
                        
                        if Heating_Ventil > 0
                            
                            PhotoVoltaic_Elec_Heat = min(Heating_Ventil, Extra_PV);
                            Extra_PV = Extra_PV - PhotoVoltaic_Elec_Heat;
                            
                            if PhotoVoltaic_Elec_Heat < 0
                                
                                PhotoVoltaic_Elec_Heat = 0;
                                
                            elseif PhotoVoltaic_Elec_Heat > Ventilation_Heater
                                
                                PhotoVoltaic_Elec_Heat = Ventilation_Heater;
                                
                            end
                            
                            if Extra_PV < 0
                                
                                PhotoVoltaic_Elec_Heat = PhotoVoltaic_Elec_Heat - Extra_PV;
                                Extra_PV = 0;
                            end
                           
                        else
                            
                            Extra_PV                = PowerPV * 1000;
                            PhotoVoltaic_Elec_Heat  = 0;
                            
                        end
                        
                        Input = 0;
                        Loading = 0;
                        
                    end
                    
                else
                    
                    msg = 'PV charging cannot be done without PV panels!';
                    error(msg)
                    
                end
                
        end
        
        % Calculate an estimation of the amount of energy stored in the
        % system for preventing the "overcharging" of the underfloor
        % heater. 
        % Consider also just utilizing nodal temperature as a marker of the
        % overcharging!
        
                Temp_Set = LowerTempLimit;
                
                if myiter == 0
                    
                    Temp_surface = Temp_Set;

                    
                else
                    
                    Temp_surface = Previous_Temperature_core;
                    
                end
                
                Temp_concrete = Temp_surface + Current_capacity / (Heat_capacity * Weight);
                Temp_set = Temp_inside;
                Surface_Temp = ((Temp_set * (R + 0.04) + Temp_concrete * 0.10) / (R + 0.10 + 0.04));
                Heat_output = U * lgts * lgte * (Temp_concrete - Surface_Temp);
                Current_capacity = Current_capacity - Heat_output;
                
                if Current_capacity < 0
                    
                    Current_capacity = 0;
                    Heat_output = Current_capacity1;
                end
                
                
                Temperature_core = Surface_Temp;
                Heater_Power = Heat_output;
                if Heater_Power < 0
                    Heater_Power = 0;
                end
                
                Previous_Temperature_core = Temperature_core;
                

%% The final variables
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. 

                
%                 if PowerPV == 0
%                     
%                     Price = Loading * (Input/Underfloor_heating_efficiency)/1000 * RTP/100 + (Heating_Ventil - PhotoVoltaic_Elec_Heat)/1000 * RTP/100;
%                     
%                 else
%                     
%                     Price = Loading * ((Input/Underfloor_heating_efficiency) + Heating_Ventil - PhotoVoltaic_Elec_Heat)/1000 * RTP/100; 
%                     
%                 end

%% Outputs

varargout{1} = Input                   ;
varargout{2} = Current_capacity        ;
varargout{3} = PhotoVoltaic_Elec_Heat  ;
varargout{4} = Extra_PV                ;
varargout{5} = Used_Hours              ;
varargout{6} = Cumulative_input        ;
varargout{7} = Previous_Temperature_core ;
varargout{8} = Cumulative_input_PV;

end