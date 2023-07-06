function [Battery_charge, Input, Output, Extra_input, State] = Electric_battery(varargin)
%% The function for electric battery
% This function is for charging and discharging of electric batteries. 
% The example used here is Tesla Powerwall 2.
%% Inputs
% The inputs for the battery are presented here.

Nbr_batteries           = varargin{1};
Battery_action          = varargin{2};
Input                   = varargin{3};
Battery_charge          = varargin{4};
Output                  = varargin{5};
State                   = varargin{6};
BatteryCapacity         = varargin{7};
RoundTripEfficiency     = varargin{8};

Previous_battery_charge = Battery_charge;
Usable_energy_max       = Nbr_batteries * BatteryCapacity;     % Tesla Powerwall 2 has 13.5 kWh of usable energy.
% Battery_efficiency      = 0.9;                      % Tesla Powerwall 2 has 90 % of round trip efficiency with 3.3 kW of charge/discharge
Input_max               = 5000 ;                       % Tesla Powerwall 2 has max continuous charging of 5 kW.
Output_max              = 5000 ;                       % Tesla Powerwall 2 has max continuous discharge of 5 kW. 

%% The battery system
% This represents the battery system.
Input_to_system = Input;

if Battery_action == 1
    
    if Input > Input_max * Nbr_batteries
        Input = Input_max * Nbr_batteries;
        Extra_input = Input_to_system - Input;
        
    else 
        Extra_input = 0;
        
    end
    
    Battery_charge = Battery_charge + Input * RoundTripEfficiency; % Battery_efficiency;
    
    if Battery_charge > Usable_energy_max
        
        Battery_charge = Usable_energy_max;
        Input = Battery_charge - Previous_battery_charge;
        Extra_input = Input_to_system - Input;

    end
    
    if Battery_charge > 0.8 * Usable_energy_max
        
        State = 1;                              % Tells the state that the battery has recharged itself
        
    end
    
    Output = 0;
    
elseif Battery_action == 2
    
    if Output > Output_max * Nbr_batteries
        
        Output = Output_max * Nbr_batteries;
    end
    
    Battery_charge = Battery_charge - Output;       
    
    if Battery_charge < Usable_energy_max * 0.1         % Battery cannot be discharged under 10 % of State-of-Charge
        
        Output = Previous_battery_charge - Usable_energy_max * 0.1;
        Battery_charge = Usable_energy_max * 0.1;
        
    end
    
    if Battery_charge < Usable_energy_max * 0.3
        
        State = 0;                          % Tells that the battery has completed the discharge cycle
        
    end
    
    Input = 0;
    Extra_input = 0;
    
end

end
