function [ClimateVariables] = CalculateClimateVariables(Temperature, Solar_Radiation, StartDate, EndDate)
%% Function to calculate monthly mean and variation files, and daily variation files
% This function is used to transform current hourly weather file to useful
% in morphing
%% Input data
% Define input variables if needed

%% Time frame
% Calculate the time frame for defining the correct months
TimeVector  = StartDate:hours(1):EndDate; %datetime(StartDate):hour(1):datetime(EndDate);    % Time vector for defining date time from start to end date
Year        = TimeVector.Year;                                  % Define the year
Month       = TimeVector.Month;                                 % Defince the month for future use
DaysVector  = StartDate:days(1):EndDate;                        % Define vector per day
DailyMonth  = DaysVector.Month;                                 % Define the month numbers per day
% YearNumber  = DaysVector.Year;
% UniqueYears = unique(YearNumber);   
DayYear     = day(TimeVector,'dayofyear');                      % Determine the day of the year for future use
DayNumberYear = day(DaysVector,'dayofyear');
NboDays     = ceil(datenum(TimeVector(end)-TimeVector(1)));     % Define the number of days
%% Preallocation of future variables
ClimateVariables.MonthlyMean = zeros(1,12);
ClimateVariables.MeanToMax   = zeros(1,12);
ClimateVariables.MinToMean   = zeros(1,12);
ClimateVariables.MeanMax     = zeros(1,12);
ClimateVariables.MeanMin     = zeros(1,12);
ClimateVariables.MeanRad     = zeros(1,12);
ClimateVariables.DailyMax    = zeros(1,NboDays);
ClimateVariables.DailyMean   = zeros(1,NboDays);
ClimateVariables.DailyMin    = zeros(1,NboDays);
%% Monthly values
% Create a loop for calculating the mean value for each month
for i =1:12
    ClimateVariables.MonthlyMean(i)     = mean(Temperature(Month==i));
    ClimateVariables.MonthlyMeanRad(i)  = mean(Solar_Radiation(Month==i));
end
%% Daily values
% This part is used to calculate daily max, mean and min values and then
% their montly means in absolute and change values
for j = 1:NboDays   % Loop through each day
    for k = Year(1):Year(end)
        ClimateVariables.DailyMax(j)    = max(Temperature(DayYear == DayNumberYear(j) & Year == k));
        ClimateVariables.DailyMean(j)   = mean(Temperature(DayYear == DayNumberYear(j) & Year == k));
        ClimateVariables.DailyMin(j)    = min(Temperature(DayYear == DayNumberYear(j) & Year == k));
        ClimateVariables.MeanRad(j)     = mean(Solar_Radiation(DayYear == DayNumberYear(j) & Year == k));
    end
end

% Describe here the absolute average values and changes per month
for m = 1:12
    ClimateVariables.MeanToMax(m)       = mean(ClimateVariables.DailyMax(DailyMonth == m) - ClimateVariables.DailyMean(DailyMonth == m));
    ClimateVariables.MinToMean(m)       = mean(ClimateVariables.DailyMean(DailyMonth == m) - ClimateVariables.DailyMin(DailyMonth == m));
    ClimateVariables.MeanMax(m)         = mean(ClimateVariables.DailyMax(DailyMonth == m));
    ClimateVariables.MeanMin(m)         = mean(ClimateVariables.DailyMin(DailyMonth == m));
end
    


end

