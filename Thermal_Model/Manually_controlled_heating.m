function [varargout] = Manually_controlled_heating(varargin)
%% Manually controlled heating
% This is a function for manually controlled heating technology. It
% utilizes heat demand, and manual adjustments to its variations.
%% Inputs

Max_heating                 = varargin{1};
Dwelling_env_heat           = varargin{2};
tenancy                     = varargin{3};
Heat_Demand                 = varargin{4};
UpperTempLimit              = varargin{5};
Space_Heating_Efficiency    = varargin{6};
Heating_Ventil              = varargin{7};
Temp_inside                 = varargin{8};
myiter                      = varargin{9};
Set_Up                      = varargin{10};
LowerTempLimit              = varargin{11};
Heat_Demand_Temp_Set        = varargin{12};
Temperature                 = varargin{13};
Heat_Demand_Manual          = varargin{14};

LowerTempLimit = 20;    % For this simulation time
UpperTempLimit = 22;    % For this simulation time

%% Define the manual heater & Electric space heating function
% The used manual heater is defined here. The possible heating power
% outputs are from K-rauta and Clas Ohlson heaters, and have three possible
% heating power outputs: 750, 1250 and 2000 W. The sizing is
% based on the previously calculated maximum capacities, so that there are
% enough radiators to at least match the calculated design heating
% capacity. The sizing gives out the number of radiators in use. After 
% that, all the possible heating power outputs are calculated by the
% outputs from a single heater and the number of heaters in total. These
% values are inputs for the possible thermostat positions for the
% following section.
%%%
% The electric space heating with manual control is defined here. The
% pricinple is that the thermostat is controlled manually, and that it is
% adjusted according to the current heat demand if there is somebody
% inside. Overheating is prevented by shutting down the heater in case
% the indoor temperature has risen too high. If there is no occupancy the
% previous heating setting is applied.

% Maximum heating power from one heater

Max_Heating_Heater = 2000;

% Defining the number of heaters needed to heat up the house. Minimum
% amount to meet the design heating power is considered to be the number of
% manual heaters. As the heaters have fixed maximum heating power, the
% rounding of the number of heaters is made upwards.

Heater_amount = ceil(Dwelling_env_heat/Max_Heating_Heater);

% The heating powers coming from an individual heater are presented here.
% Change these values if another kind of heating set ups is considered.

Heater_Sets = [750 1250 2000];

% Pre-allocating the amount of different heating power scenarios from the
% heaters.

Heater_Sets_sums = zeros(Heater_amount,length(Heater_Sets));

% Calculate all the possible scenarios for the manual heater powers.
% Consider that in each scenario only one heaters' heating power is being
% changed while others stay the same. This way it is possible to get all
% the possible combinations of the heating powers.
% If the number of heaters is equal or higher than
% the heater's set ups, 3rd dimension needs to be utilized in order to
% achieve all the possible set ups.

for n = 1:Heater_amount %+ 1
    
%     if n <= length(Heater_Sets)
%         Heater_Sets_no_power = [0 0 0];
%         Heater_Sets_only_one = Heater_Sets;
%     else
        Heater_Sets_no_power = zeros(Heater_amount, length(Heater_Sets));
        Heater_Sets_only_one = ones(Heater_amount, length(Heater_Sets)) .* Heater_Sets;
%     end
    
    if n == 1
        Heater_Sets_sums(n,:,1) = [Heater_Sets(n) + Heater_Sets(1), Heater_Sets(n) + Heater_Sets(2), Heater_Sets(n) + Heater_Sets(3)];
        Heater_Sets_sums(n,:,2) = [Heater_Sets(n+1) + Heater_Sets(1), Heater_Sets(n+1) + Heater_Sets(2), Heater_Sets(n+1) + Heater_Sets(3)];
        Heater_Sets_sums(n,:,3) = [Heater_Sets(n+2) + Heater_Sets(1), Heater_Sets(n+2) + Heater_Sets(2), Heater_Sets(n+2) + Heater_Sets(3)];
    else
        Heater_Sets_sums(n,:,1) = [Heater_Sets_sums(n-1,1,1) + Heater_Sets(1), Heater_Sets_sums(n-1,2,1) + Heater_Sets(1), Heater_Sets_sums(n-1,3,1) + Heater_Sets(1)];
        Heater_Sets_sums(n,:,2) = [Heater_Sets_sums(n-1,1,2) + Heater_Sets(2), Heater_Sets_sums(n-1,2,2) + Heater_Sets(2), Heater_Sets_sums(n-1,3,2) + Heater_Sets(2)];
        Heater_Sets_sums(n,:,3) = [Heater_Sets_sums(n-1,1,3) + Heater_Sets(3), Heater_Sets_sums(n-1,2,3) + Heater_Sets(3), Heater_Sets_sums(n-1,3,3) + Heater_Sets(3)];
    end
    
%     if n <= length(Heater_Sets)
%         Heater_Sets_sums(n,:) = [Heater_Sets(n) + Heater_Sets(1), Heater_Sets(n) + Heater_Sets(2), Heater_Sets(n) + Heater_Sets(3)];
%     else
%         Heater_Sets_high_number = [Heater_Sets; Heater_Sets; Heater_Sets];
%         Heater_Sets_sums(n,:) = Heater_Sets_sums(n-length(Heater_Sets),:) + Heater_Sets_high_number(1,:);
%         Heater_Sets_sums(:,:,n - length(Heater_Sets + 1)) = Heater_Sets_sums(:,:,n-length(Heater_Sets)) + Heater_Sets_high_number;
%     end
    
end

% Now define all the unique heater power set ups so that the possible
% heating powers can be defined. First row considers no power at all,
% second considers only one heater on and then all the combination
% scenarios are added. Then unique values are selected and they define the
% possible heating powers. Again, if the number of heaters is equal or higher than
% the heater's set ups, 3rd dimension needs to be utilized in order to
% achieve all the possible set ups.

% if Heater_amount + 1 <= length(Heater_Sets)
%     Heater_Set_Ups = [Heater_Sets_no_power; Heater_Sets_only_one; Heater_Sets_sums]; 
%     Heater_Set_Ups = Heater_Set_Ups(:);
%     Heater_Set_Ups = unique(Heater_Set_Ups);
% else
    Heater_Set_Ups = cat(3, Heater_Sets_no_power, Heater_Sets_only_one, Heater_Sets_sums);
    Heater_Set_Ups = unique(Heater_Set_Ups);
% end

% First guess is maximum power. 

Set_Up_first = Heater_Set_Ups(end);

    % If there is someone inside the building, the heating power can be
    % changed.

    if tenancy == 1 && Temperature < 15 % Heat_Demand > 0
        
        % Guess is that the heating power selected is closest to the
        % heat demand. Thus the set up which has the lowest difference from
        % the heat demand is selected.
        
%         [~,idx] = min(abs(Heater_Set_Ups - Heat_Demand));
%         [~,idx] = min(abs(Heater_Set_Ups - Heat_Demand_Temp_Set));
        if Heat_Demand_Manual > 0 && Temp_inside < UpperTempLimit
            [~,idx] = min(abs(Heater_Set_Ups - Heat_Demand_Manual));
            Set_Up = Heater_Set_Ups(idx);
        else
            idx = 1;
            Set_Up = 0; % Heater_Set_Ups(idx);
        end
        
        % Now if temperature inside drops under the lowest thermal comfort
        % value, the heating power is increased by one set-up.
        
        if Temp_inside < LowerTempLimit
        
            if abs(Temp_inside - LowerTempLimit) > 2
                
                if idx < numel(Heater_Set_Ups)
                
                    Set_Up = Heater_Set_Ups(end);
                
                end
        
            elseif abs(Temp_inside - LowerTempLimit) > 1
            
                if idx + 1 < numel(Heater_Set_Ups)
                
                    Set_Up = Heater_Set_Ups(idx + 2);
                
                elseif idx < numel(Heater_Set_Ups)
                
                    Set_Up = Heater_Set_Ups(idx + 1);
                
                end
                
            elseif abs(Temp_inside - LowerTempLimit) < 1     % This is the current issue. Consider also adding an extra heat demand calculation for the higher temperature
            
                if idx < numel(Heater_Set_Ups)
                
                    Set_Up = Heater_Set_Ups(idx + 1);
                
                end
                
            end
                

        % Similarly, if the temperature is higher than the defined upper temperature limit of thermal comfort
        % the set up is considered to be dropped by one step.
            
        elseif Temp_inside > UpperTempLimit
            
            if idx > 1 && Temp_inside - UpperTempLimit < 1
                
                Set_Up = Heater_Set_Ups(idx - 1);
                
            elseif idx > 1 && Temp_inside - UpperTempLimit >= 1
                
                Set_Up = Heater_Set_Ups(1);
                
            end
            
        end
        
    % If nobody is inside the building, the previous selection is considered to be on, as there is no one to change the setting. Hence, there is no value here as the previous set up
    % is added to the model as an input. 
        
    else
        
        % If the time is at the first simulation step, the first guess is
        % considered to be selected.
        
        if myiter == 0
            
            Set_Up = Set_Up_first;           
            
        end
        
    end


%% The final variables
% In this part the final variables for the function are calculated. This
% equals to space heating delivery, total heating delivery and price of
% electricity according to consumption and real-time-price. Also back-up is
% created in case the temperature would start to drop too low, to keep the
% simulation running. Similarly, too high temperatures are prevented. These
% are operated even during unoccupied periods.

if Temp_inside < 18     % This can be added as extra input as well.
    Heater_Power = Heater_Set_Ups(end);
%     Heater_Power = Heat_Demand;
    warning('Temperature dropped too low!')
elseif Temp_inside > 25
    Heater_Power = 0;
elseif Temp_inside > UpperTempLimit && tenancy == 0     % Consider the possibility to have a thermostat to prevent over and underheating when there is nobody present!
    Heater_Power = 0;
elseif Temp_inside < LowerTempLimit && tenancy == 0
    Heater_Power = Heater_Set_Ups(end);
else
    Heater_Power = Set_Up;
end
Space_Heating = Heater_Power / Space_Heating_Efficiency ;
Total_Heating = Space_Heating + Heating_Ventil;

%% Output definitions

varargout{1} = Heater_Power;
varargout{2} = Space_Heating;
varargout{3} = Total_Heating;
varargout{4} = Set_Up;
end

