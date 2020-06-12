function [DataBase, deltaMin, deltaMax, averagedMin, averagedMax] = ConvertDaylyToMonthly(DataBase, Scenario, StartYear, ReferenceYear, AveragePeriod, MorphingYear)
%%% Function for calculating the monthly average values from daily values
%%% and delta values
% [DataBase, deltaMin, deltaMax, deltaMin, deltaMax, averagedMin, averagedMax, deltaAveragedMin, deltaAveragedMax, TotalVariance, deltaTotalVariance] = ConvertDaylyToMonthly(DataBase, Scenario, StartYear, ReferenceYear, AveragePeriod)
% The aim of this function is to calculate the changes in the daily
% temperature variation by comparing the daily minimum and maximum temperatures to
% the mean daily temperature. 

dbstop if error

SimYears = length(DataBase.(Scenario).mean.mean_tasPlace)/365;

% mean_tasPlace       = DataBase.(Scenario).mean.mean_tasPlace;
mean_tasminPlace    = DataBase.(Scenario).min.mean_tasminPlace;
mean_tasmaxPlace    = DataBase.(Scenario).max.mean_tasmaxPlace;

% StartYear = 1981;

ReferencePoint = (ReferenceYear - StartYear) + 1;
FullPeriods = SimYears / AveragePeriod;

MorphingPoint = MorphingYear - StartYear + 1;

% changeMin = zeros(12,SimYears);
% changeMax = zeros(12,SimYears);
% 
% 
%     for i = 1:SimYears
%         
%         m = i - 1;
%     
%         changeMin(1,i) = mean(mean_tasminPlace(m*365+1:m*365+31) - mean_tasPlace(m*365+1:m*365+31));
%         changeMin(2,i) = mean(mean_tasminPlace(m*365+32:m*365+59) - mean_tasPlace(m*365+32:m*365+59));
%         changeMin(3,i) = mean(mean_tasminPlace(m*365+60:m*365+90) - mean_tasPlace(m*365+60:m*365+90));
%         changeMin(4,i) = mean(mean_tasminPlace(m*365+91:m*365+120) - mean_tasPlace(m*365+91:m*365+120));
%         changeMin(5,i) = mean(mean_tasminPlace(m*365+121:m*365+151) - mean_tasPlace(m*365+121:m*365+151));
%         changeMin(6,i) = mean(mean_tasminPlace(m*365+152:m*365+181) - mean_tasPlace(m*365+152:m*365+181));
%         changeMin(7,i) = mean(mean_tasminPlace(m*365+182:m*365+212) - mean_tasPlace(m*365+182:m*365+212));
%         changeMin(8,i) = mean(mean_tasminPlace(m*365+213:m*365+243) - mean_tasPlace(m*365+213:m*365+243));
%         changeMin(9,i) = mean(mean_tasminPlace(m*365+244:m*365+273) - mean_tasPlace(m*365+244:m*365+273));
%         changeMin(10,i) = mean(mean_tasminPlace(m*365+274:m*365+304) - mean_tasPlace(m*365+274:m*365+304));
%         changeMin(11,i) = mean(mean_tasminPlace(m*365+305:m*365+334) - mean_tasPlace(m*365+305:m*365+334));
%         changeMin(12,i) = mean(mean_tasminPlace(m*365+335:m*365+365) - mean_tasPlace(m*365+335:m*365+365));
% 
%         changeMax(1,i) = mean(mean_tasmaxPlace(m*365+1:m*365+31) - mean_tasPlace(m*365+1:m*365+31));
%         changeMax(2,i) = mean(mean_tasmaxPlace(m*365+32:m*365+59) - mean_tasPlace(m*365+32:m*365+59));
%         changeMax(3,i) = mean(mean_tasmaxPlace(m*365+60:m*365+90) - mean_tasPlace(m*365+60:m*365+90));
%         changeMax(4,i) = mean(mean_tasmaxPlace(m*365+91:m*365+120) - mean_tasPlace(m*365+91:m*365+120));
%         changeMax(5,i) = mean(mean_tasmaxPlace(m*365+121:m*365+151) - mean_tasPlace(m*365+121:m*365+151));
%         changeMax(6,i) = mean(mean_tasmaxPlace(m*365+152:m*365+181) - mean_tasPlace(m*365+152:m*365+181));
%         changeMax(7,i) = mean(mean_tasmaxPlace(m*365+182:m*365+212) - mean_tasPlace(m*365+182:m*365+212));
%         changeMax(8,i) = mean(mean_tasmaxPlace(m*365+213:m*365+243) - mean_tasPlace(m*365+213:m*365+243));
%         changeMax(9,i) = mean(mean_tasmaxPlace(m*365+244:m*365+273) - mean_tasPlace(m*365+244:m*365+273));
%         changeMax(10,i) = mean(mean_tasmaxPlace(m*365+274:m*365+304) - mean_tasPlace(m*365+274:m*365+304));
%         changeMax(11,i) = mean(mean_tasmaxPlace(m*365+305:m*365+334) - mean_tasPlace(m*365+305:m*365+334));
%         changeMax(12,i) = mean(mean_tasmaxPlace(m*365+335:m*365+365) - mean_tasPlace(m*365+335:m*365+365));
% 
%     end
%     
%     deltaMin = changeMin - changeMin(:,ReferencePoint);
%     deltaMax = changeMax - changeMax(:,ReferencePoint);
%     
%     FullPeriods = SimYears / AveragePeriod; % AveragePeriod as years
%     
%     averagedMin = zeros(12,FullPeriods);
%     averagedMax = zeros(12,FullPeriods);
%   
%     for j = 1:FullPeriods
%         
%         averagedMin(:,j) = mean(changeMin(:,(j-1)*AveragePeriod+1:j*AveragePeriod),2);
%         averagedMax(:,j) = mean(changeMax(:,(j-1)*AveragePeriod+1:j*AveragePeriod),2);
%          
%     end
%     
%     deltaAveragedMin = averagedMin - averagedMin(:,1);
%     deltaAveragedMax = averagedMax - averagedMax(:,1);
%     
%     TotalVariance = (abs(averagedMin) + abs(averagedMax)); %deltaAveragedMin + deltaAveragedMax;
%     deltaTotalVariance = TotalVariance./TotalVariance(:,1); % - 1;

% Calculate monthly aveerage values for the simulation period on 365
% calendar days per month

deltaMin    = zeros(12,SimYears);
deltaMax    = zeros(12,SimYears);

for i = 1:SimYears
        
        m = i - 1;
    
        deltaMin(1,i) = mean(mean_tasminPlace(m*365+1:m*365+31));
        deltaMin(2,i) = mean(mean_tasminPlace(m*365+32:m*365+59));
        deltaMin(3,i) = mean(mean_tasminPlace(m*365+60:m*365+90));
        deltaMin(4,i) = mean(mean_tasminPlace(m*365+91:m*365+120));
        deltaMin(5,i) = mean(mean_tasminPlace(m*365+121:m*365+151));
        deltaMin(6,i) = mean(mean_tasminPlace(m*365+152:m*365+181));
        deltaMin(7,i) = mean(mean_tasminPlace(m*365+182:m*365+212));
        deltaMin(8,i) = mean(mean_tasminPlace(m*365+213:m*365+243));
        deltaMin(9,i) = mean(mean_tasminPlace(m*365+244:m*365+273));
        deltaMin(10,i) = mean(mean_tasminPlace(m*365+274:m*365+304));
        deltaMin(11,i) = mean(mean_tasminPlace(m*365+305:m*365+334));
        deltaMin(12,i) = mean(mean_tasminPlace(m*365+335:m*365+365));

        deltaMax(1,i) = mean(mean_tasmaxPlace(m*365+1:m*365+31));
        deltaMax(2,i) = mean(mean_tasmaxPlace(m*365+32:m*365+59));
        deltaMax(3,i) = mean(mean_tasmaxPlace(m*365+60:m*365+90));
        deltaMax(4,i) = mean(mean_tasmaxPlace(m*365+91:m*365+120));
        deltaMax(5,i) = mean(mean_tasmaxPlace(m*365+121:m*365+151));
        deltaMax(6,i) = mean(mean_tasmaxPlace(m*365+152:m*365+181));
        deltaMax(7,i) = mean(mean_tasmaxPlace(m*365+182:m*365+212));
        deltaMax(8,i) = mean(mean_tasmaxPlace(m*365+213:m*365+243));
        deltaMax(9,i) = mean(mean_tasmaxPlace(m*365+244:m*365+273));
        deltaMax(10,i) = mean(mean_tasmaxPlace(m*365+274:m*365+304));
        deltaMax(11,i) = mean(mean_tasmaxPlace(m*365+305:m*365+334));
        deltaMax(12,i) = mean(mean_tasmaxPlace(m*365+335:m*365+365));

end

% Calculate averaged max and min temperatures

    averagedMin = zeros(12,FullPeriods);
    averagedMax = zeros(12,FullPeriods);
    alfa        = zeros(12,FullPeriods);

    for j = 1:FullPeriods
        
        averagedMin(:,j) = mean(deltaMin(:,(j-1)*AveragePeriod+1:j*AveragePeriod),2);
        averagedMax(:,j) = mean(deltaMax(:,(j-1)*AveragePeriod+1:j*AveragePeriod),2);
       
        alfa(:,j) = ((averagedMax(:,j) - (averagedMax(:,1))) - (averagedMin(:,j) - averagedMin(:,1)))./(averagedMax(:,1) - averagedMin(:,1)); % Calculate alfa for shifting and stretching scearion in  the future. Always reference to the change from the original scenario.
        
    end
    
    MorphingMeanMax = mean(deltaMax(:,MorphingPoint-(AveragePeriod/2):MorphingPoint+(AveragePeriod/2)), 2);
    MorphingMeanMin = mean(deltaMin(:,MorphingPoint-(AveragePeriod/2):MorphingPoint+(AveragePeriod/2)), 2);
    
    if ReferencePoint - (AveragePeriod/2) <= 0      % In case the reference point does not hit the averaging period, take the first option hitting it
        ReferencePoint = (AveragePeriod/2) + 1;
    end
    
    ReferenceMeanMax = mean(deltaMax(:,ReferencePoint-(AveragePeriod/2):ReferencePoint+(AveragePeriod/2)),2);
    ReferenceMeanMin = mean(deltaMin(:,ReferencePoint-(AveragePeriod/2):ReferencePoint+(AveragePeriod/2)),2);
    
    MorphedAlfa = ((MorphingMeanMax - ReferenceMeanMax) - (MorphingMeanMin - ReferenceMeanMin))./(ReferenceMeanMax - ReferenceMeanMin);

    DataBase.(Scenario).change.deltaMin = deltaMin;
    DataBase.(Scenario).change.deltaMax = deltaMax;
%     DataBase.(Scenario).delta.deltaMin = deltaMin;
%     DataBase.(Scenario).delta.deltaMax = deltaMax;
    DataBase.(Scenario).averaged.averagedMin = averagedMin;
    DataBase.(Scenario).averaged.averagedMax = averagedMax;
    DataBase.(Scenario).alfa                = alfa;
    DataBase.(Scenario).morphedalfa         = MorphedAlfa;
%     DataBase.(Scenario).deltaAveraged.deltaAveragedMin = deltaAveragedMin;
%     DataBase.(Scenario).deltaAveraged.deltaAveragedMax = deltaAveragedMax;
%     DataBase.(Scenario).Total.TotalVariance = TotalVariance;
%     DataBase.(Scenario).Total.deltaTotalVariance = deltaTotalVariance;
    
end

