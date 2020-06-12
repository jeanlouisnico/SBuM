function [DataBase] = stdDailyFunc(tas, Scenario, StartYearDaily, ReferenceYear, AveragePeriod, MorphingYear)
%% This is a function to calculate the standard deviation from daily temperature files
% This is used to determine the change in the daily deviation of
% temperatures for morphing. In case several files are selected, all those
% are looped through.

tasDailyTable = readtable(tas{1});
tasDaily = zeros(length(tasDailyTable.Temperature),length(tas));

for i = 1:length(tas)
    tasDailyTable = readtable(tas{i});
    tasDaily(:,i) = tasDailyTable.Temperature;
end

%% Calculate standard deviation

SimPeriod   = datetime(StartYearDaily,1,1:length(tasDaily));
Month       = SimPeriod.Month;
SimYears    = year(SimPeriod(end))-year(SimPeriod(1))+1;
Years       = SimPeriod.Year;
UniqueYears = unique(SimPeriod.Year);

FullPeriods = round(SimYears / AveragePeriod);

ReferencePoint = ReferenceYear - StartYearDaily + 1;

MorphingPoint = MorphingYear - StartYearDaily + 1;

AnnualStd       = zeros(12,length(tas));
stdDailyAnnual  = zeros(12,SimYears);

for ii = 1:SimYears   % Loop every month
    
    for j = 1:12  % Loop every month
        
        for model = 1:length(tas)
        
            AnnualStd(j,model) = std(tasDaily(Month==j&Years==UniqueYears(ii),model));
            
        end
        
    end
    
    stdDailyAnnual(:,ii) = mean(AnnualStd,2);
    
end

%% Average the changes

stdDaily = zeros(12,FullPeriods);

for m = 1:FullPeriods
    
    stdDaily(:,m) = mean(stdDailyAnnual(:,(m-1)*AveragePeriod+1:m*AveragePeriod),2);
    
end

if ReferencePoint - (AveragePeriod/2) <=0
    ReferencePoint = (AveragePeriod/2) + 1;
end

stdReferencePeriod = mean(stdDailyAnnual(:,ReferencePoint-(AveragePeriod/2):ReferencePoint+(AveragePeriod/2)),2);

stdMorphYear = mean(stdDailyAnnual(:,MorphingPoint-(AveragePeriod/2):MorphingPoint+(AveragePeriod/2)),2);

%% Reference the changes to the first period

stdChange   = stdDaily./stdReferencePeriod; %stdDaily(:,ReferencePoint);
alfa        = stdChange-1;

stdChangeMorp   = stdMorphYear./stdReferencePeriod; %stdDaily(:,ReferencePoint);
MorphingAlfa    = stdChangeMorp-1;

%% Assign the achieved change to correct variables for future use

DataBase.(Scenario).alfa = alfa;
DataBase.(Scenario).morphedalfa = MorphingAlfa;

end

