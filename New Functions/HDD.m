function [AnnualData,MonthlyDataHDD,MonthlyDataCDD,MonthlyAverageTable,MonthlyMinDaily,MonthlyMaxDaily,DataCollectionTable] = HDD(Folder,FileName,NewFolder,NewFileName)
%% Funtion to calculate HDD and CDD for a location from csv file
%% Load file
DailyData = readtable(append(Folder,'\',FileName));

%% Create and anjust variables

Years   = unique(DailyData.Year);
Months  = unique(DailyData.Month);

HDD_Temp        = 17;
HDD_Threshold    = 15;

CDD_Temp        = 21;
CDD_Threshold    = 24;

%% Pre-allocate new one

MonthlyAverageTemp  = zeros(12,length(Years));
MonthlyMinDailyTemp = zeros(12,length(Years));
MonthlyMaxDailyTemp = zeros(12,length(Years));
MonthlyHDD          = zeros(12,length(Years));
MonthlyCDD          = zeros(12,length(Years));
YearlyHDD           = zeros(1,length(Years));
YearlyCDD           = zeros(1,length(Years));
%WarmestAverage      = zeros(1,length(Years));
%ColdestAverage      = zeros(1,length(Years));
%WarmestMonth        = zeros(1,length(Years));
%ColdestMonth        = zeros(1,length(Years));

%% Run loop for the calculation

for i = 1:length(Years)
    
    % Logical variable for checking the year
    
    CorYear = DailyData.Year == Years(i);
    
    YearlyData = DailyData.AirTemperature(CorYear);
    
    % HDD if temp < HDD Threshold
    
    HDDDays = YearlyData < HDD_Threshold; 
    CDDDays = YearlyData > CDD_Threshold;

    % Calculate annual HDD and CDD 
    
    DailyHDD = HDD_Temp - YearlyData;
    DailyCDD = YearlyData - CDD_Temp;
    
    YearlyHDD(i) = sum(DailyHDD(HDDDays));
    YearlyCDD(i) = sum(DailyCDD(CDDDays));
    
    for j = 1:12    % nbr of months
        
        CorMonths = DailyData.Month(CorYear) == Months(j);
        
        MonthlyData = YearlyData(CorMonths);
        
        MonthlyHDDDays = MonthlyData < HDD_Threshold;
        MonthlyCDDDays = MonthlyData > CDD_Threshold;
        
        MonthlyHDDperDay = HDD_Temp - MonthlyData;
        MonthlyCDDperDay = MonthlyData - CDD_Temp;
        
        MonthlyHDD(j,i) = sum(MonthlyHDDperDay(MonthlyHDDDays));
        MonthlyCDD(j,i) = sum(MonthlyCDDperDay(MonthlyCDDDays));
        
        MonthlyAverageTemp(j,i) = mean(MonthlyData);
        
        MonthlyMinDailyTemp(j,i) = min(MonthlyData);
        MonthlyMaxDailyTemp(j,i) = max(MonthlyData);
        
    end
    
end

%% Add varible for warmest and coldest month for the year and warmest and coldest days of the year
    
    [WarmestAverage,WarmestMonth] = max(MonthlyAverageTemp);
    [ColdestAverage,ColdestMonth] = min(MonthlyAverageTemp);
    
    [WarmestDailyAverage,WarmestDayMonth] = max(MonthlyMaxDailyTemp);
    %[ColdestWarmestDailyAverage,ColdestWarmestDay] = min(MonthlyMaxDailyTemp);
    
    [ColdestDailyAverage,ColdestDayMonth] = min(MonthlyMinDailyTemp);
    %[WarmestColdestDailyAverage,WarmestColdestDay] = max(MonthlyMinDailyTemp);
    
%% Collection of additional data

[HighestHeatingNeed, HHN]   = max(YearlyHDD);
[LowestHeatingNeed, LHN]    = min(YearlyHDD);
[HighestCoolingNeed, HCN]   = max(YearlyCDD);
[LowestCoolingNeed, LCN]    = min(YearlyCDD);

[ColdestAverageMonth, CAM]          = min(ColdestAverage);
[WarmestColdestAverageMonth, WCAM]  = max(ColdestAverage);

[WarmestAveregeMonth, WAM]          = max(WarmestAverage);
[ColdestWarmestAverageMonth, CWAM]  = min(WarmestAverage);

[ColdestDay, CD]                    = min(ColdestDailyAverage);
[WarmestColdDay, WCD]               = max(ColdestDailyAverage);

[WarmestDay, WD]                    = max(WarmestDailyAverage);
[ColdestWarmDay, CWD]               = min(WarmestDailyAverage);

VarNamesDataCollection = {'HighestHDD'; 'LowestHDD'; 'HighestCDD'; 'LowestCDD'; 'ColdestAverageMonthTemp'; 'WarmestColdAverageMonthTemp'; 'WarmestAverageMonthTemp'; 'ColdestWarmAverageMonthTemp'; 'ColdestDay'; 'WarmestColdDay'; 'WarmestDay'; 'ColdestWarmDay'};

DataColumn = [HighestHeatingNeed; LowestHeatingNeed; HighestCoolingNeed; LowestCoolingNeed; ColdestAverageMonth; WarmestColdestAverageMonth; WarmestAveregeMonth; ColdestWarmestAverageMonth; ColdestDay; WarmestColdDay; WarmestDay; ColdestWarmDay];
YearColumn = [Years(HHN); Years(LHN); Years(HCN); Years(LCN); Years(CAM); Years(WCAM); Years(WAM); Years(CWAM); Years(CD); Years(WCD); Years(WD); Years(CWD)];
MonthsColumn = [0; 0; 0; 0; ColdestMonth(CAM); ColdestMonth(WCAM); WarmestMonth(WAM); WarmestMonth(CWAM); ColdestDayMonth(CD);ColdestDayMonth(WCD); WarmestDayMonth(WD); WarmestDayMonth(CWD)]; 

%% Create tables for better understanding data

AnnualData      = table(Years,YearlyHDD',YearlyCDD',ColdestAverage',ColdestMonth',WarmestAverage',WarmestMonth',ColdestDailyAverage',ColdestDayMonth',WarmestDailyAverage',WarmestDayMonth');
MonthlyDataHDD  = array2table([Months,MonthlyHDD]);
MonthlyDataCDD  = array2table([Months,MonthlyCDD]);
MonthlyMinDaily = array2table([Months,MonthlyMinDailyTemp]);
MonthlyMaxDaily = array2table([Months,MonthlyMaxDailyTemp]);
MonthlyAverageTable = array2table([Months,MonthlyAverageTemp]);

DataCollectionTable = table(VarNamesDataCollection, DataColumn, YearColumn, MonthsColumn);

% Modify tables 

MonthlyDataVarNames = cellstr(num2str(Years));
MonthlyDataVarNames(2:end+1) = MonthlyDataVarNames;
MonthlyDataVarNames(1)        = {'Month'};
%MonthlyDataVarNames(2:end) = cellstr(num2str(Years));

%AnnualData.Properties.RowNames = cellstr(num2str(Years));
AnnualData.Properties.VariableNames = {'Year';'YearlyHDD';'YearlyCDD';'ColdestAverage';'ColdestMonth';'WarmestAverage';'WarmestMonth';'ColdestDailyAverage';'ColdestDayMonth';'WarmestDailyAverage';'WarmestDayMonth'};

%MonthlyDataHDD.Properties.RowNames = cellstr(num2str(Months));
MonthlyDataHDD.Properties.VariableNames = MonthlyDataVarNames;

%MonthlyDataCDD.Properties.RowNames = cellstr(num2str(Months));
MonthlyDataCDD.Properties.VariableNames = MonthlyDataVarNames;

MonthlyAverageTable.Properties.VariableNames = MonthlyDataVarNames;

%% Save created tables as csv-files

SaveName = append(NewFolder,'\',NewFileName);

% SaveTableNames = {'AnnualData','MonthlyDataHDD','MonthlyDataCDD','MonthlyAverageTable','MonthlyMinDaily','MonthlyMaxDaily','DataCollectionTable'};

writetable(AnnualData,append(SaveName,'_AnnualData.csv'));
writetable(MonthlyDataHDD,append(SaveName,'_MonthlyDataHDD.csv'));
writetable(MonthlyDataCDD,append(SaveName,'_MonthlyDataCDD.csv'));
writetable(MonthlyAverageTable,append(SaveName,'_MonthlyAverageTable.csv'));
writetable(MonthlyMinDaily,append(SaveName,'_MonthlyMinDaily.csv'));
writetable(MonthlyMaxDaily,append(SaveName,'_MonthlyMaxDaily.csv'));
writetable(DataCollectionTable,append(SaveName,'_DataCollectionTable.csv'));

end

