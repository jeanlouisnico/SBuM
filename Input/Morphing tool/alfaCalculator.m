function [DataBase] = alfaCalculator(DataBase, Scenario, StartYear, ReferenceYear, AveragePeriod, MorphingYear)
%% This function is used to calculate values of alfa in case nc-files are used in daily std scenario
% Can be used with FMI Paituli data.

SimYears = length(DataBase.(Scenario).mean.mean_tasPlace)/365;

FullPeriods = SimYears / AveragePeriod;

mean_tasmeanPlace = DataBase.(Scenario).mean.mean_tasPlace;

ReferencePoint = ReferenceYear - StartYear + 1;

MorphingPoint = MorphingYear - StartYear + 1;

AnnualStd = zeros(12,SimYears);

for i = 1:SimYears  % Here there is only one file from which to calculate the std
        
        m = i - 1;
    
        AnnualStd(1,i) = std(mean_tasmeanPlace(m*365+1:m*365+31));
        AnnualStd(2,i) = std(mean_tasmeanPlace(m*365+32:m*365+59));
        AnnualStd(3,i) = std(mean_tasmeanPlace(m*365+60:m*365+90));
        AnnualStd(4,i) = std(mean_tasmeanPlace(m*365+91:m*365+120));
        AnnualStd(5,i) = std(mean_tasmeanPlace(m*365+121:m*365+151));
        AnnualStd(6,i) = std(mean_tasmeanPlace(m*365+152:m*365+181));
        AnnualStd(7,i) = std(mean_tasmeanPlace(m*365+182:m*365+212));
        AnnualStd(8,i) = std(mean_tasmeanPlace(m*365+213:m*365+243));
        AnnualStd(9,i) = std(mean_tasmeanPlace(m*365+244:m*365+273));
        AnnualStd(10,i) = std(mean_tasmeanPlace(m*365+274:m*365+304));
        AnnualStd(11,i) = std(mean_tasmeanPlace(m*365+305:m*365+334));
        AnnualStd(12,i) = std(mean_tasmeanPlace(m*365+335:m*365+365));
        
        
end

stdDaily = zeros(12,FullPeriods);

for t = 1:FullPeriods
    
    stdDaily(:,t) = mean(AnnualStd(:,(t-1)*AveragePeriod+1:t*AveragePeriod),2);
    
end

if ReferencePoint - (AveragePeriod/2) <=0
    ReferencePoint = (AveragePeriod/2) + 1;
end

stdReferencePeriod = mean(AnnualStd(:,ReferencePoint-(AveragePeriod/2):ReferencePoint+(AveragePeriod/2)));

stdMorphYear = mean(AnnualStd(:,MorphingPoint-(AveragePeriod/2):MorphingPoint+(AveragePeriod/2)));

stdChangeMorp   = stdMorphYear./stdReferencePeriod; %stdDaily(:,ReferencePoint);
MorphingAlfa    = stdChangeMorp-1;

stdChange   = stdDaily./stdReferencePeriod; %stdDaily(:,ReferencePoint);
alfa        = stdChange-1;

DataBase.(Scenario).alfa = alfa;
DataBase.(Scenario).morphedalfa = MorphingAlfa;

end

