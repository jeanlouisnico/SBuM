function [CoolingPower] = Cooling(varargin)
%% This is the cooling function for the smart house model
% The aim of this function is to calculate the applied cooling power in
% case the temperature indoor increases over the threshold value.
% Currently, this model only considers the amount of cooling required and
% it does not represent any specific cooling technology.

Heat_Demand = varargin{1};
Temp_cooling = varargin{2};
Temp_inside = varargin{3};
Heat_Demand_cooling = varargin{4};

%% This part calculates the amount of cooling needed

if Temp_inside > Temp_cooling && Heat_Demand_cooling > 0
    CoolingPower = Heat_Demand + Heat_Demand_cooling;
end

end

