function [HourlyProfile] = HourlyHeatingPower(varargin)
%% This is a function to calculate the average hourly power of the building system drawn out of the grid
% The function aims in calculating how much and how often does the building
% system use grid electricity. This function allows the comparison of
% different scenarios from the utility's point-of-view.

%% Input
Total_Elec      = varargin{1};
Time_Sim        = varargin{2};
% Heater_Power    = varargin{3};
Housenbr        = varargin{3};

SimulationTime = datetime(Time_Sim.StartDate.(Housenbr),'ConvertFrom','datenum'):hours(1):datetime((Time_Sim.EndDate.(Housenbr)+23/24),'ConvertFrom','datenum');

%% Hourly load from the grid
% This part calculates the hourly load from the grid by the month and year

NbrYears = SimulationTime(end).Year - SimulationTime(1).Year;

if NbrYears == 0
%     for i = 1:Time_Sim.nbrstep.Housenbr
%         HourlyPower.(SimulationTime(i).Month) = 
%         January_values      = (Total_Elec(SimulationTime.Month==1)); 
%         February_values     = (Total_Elec(SimulationTime.Month==2));
%         March_values        = (Total_Elec(SimulationTime.Month==3));
%          April_values       = (Total_Elec(SimulationTime.Month==4));
%          May_values         = (Total_Elec(SimulationTime.Month==5));
%          June_values        = (Total_Elec(SimulationTime.Month==6));
%          July_values        = (Total_Elec(SimulationTime.Month==7));
%          August_values      = (Total_Elec(SimulationTime.Month==8));
%          September_values   = (Total_Elec(SimulationTime.Month==9));
%          October_values     = (Total_Elec(SimulationTime.Month==10));
%          November_values    = (Total_Elec(SimulationTime.Month==11));
%          December_values    = (Total_Elec(SimulationTime.Month==12));
%          Yearly             = struct('January', January_values, 'February', February_values, 'March', March_values, 'April', April_values, 'May', May_values, ...
%                                     'June', June_values, 'July', July_values, 'August', August_values, 'September', September_values, 'October', October_values, 'November', November_values, 'December', December_values);
                                
        for i = 1:(Time_Sim.TimeStr.Month)
            for n = 1:24
                HourlyPower(n,i) = mean(Total_Elec(SimulationTime.Hour == (n-1) & SimulationTime.Month == i));
            end
        end
                                
    % Code here
else
    % Code here. Assign each year to their own structure
end

HourlyProfile = HourlyPower;
end

