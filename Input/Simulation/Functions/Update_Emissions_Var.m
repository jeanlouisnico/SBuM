function Update_Emissions_Var(varargin)
clc
 filename='Smart_House_Data_MatLab.mat';
 m = matfile(filename, 'Writable', true); %Note: writable is true by default IF the file does not exist

%% Update the Weeks Statistic
disp('Updating the weekly energy statistics...');
ImportedSheet = xlsread('Statistics_Finnish_Industry_Association_RECIPE.xlsm', 'Weeks');
RowStartupdate = find(ImportedSheet==2000,1) ;
RowEndupdate = length(ImportedSheet);
ColStartupdate = 3 ;
ColEndupdate = 20 ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Weeks_Stat = var;
clear var
%% Update the Weeks Statistic
disp('Updating the weekly emissions statistics...');
ImportedSheet = xlsread('Statistics_Finnish_Industry_Association_RECIPE.xlsm', 'Emissions_Weeks');
RowStartupdate = 5 ;
RowEndupdate = length(ImportedSheet);
var = zeros(RowEndupdate - (RowStartupdate - 1),size(ImportedSheet,2)-2) ;
for Segmentupdate = 1:2
    switch Segmentupdate
        case 1
            ColStartupdate = 1 ;
            ColEndupdate = 2 ;
        case 2
            ColStartupdate = 5 ;
            ColEndupdate = size(ImportedSheet,2) ;
    end
    varTemp = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);
    if Segmentupdate == 1
       var(:,ColStartupdate:ColEndupdate) = varTemp ; 
    else
       var(:,3:end) = varTemp ; 
    end
end
m.CO2w_ReCiPe_v_1_12 = var;
%% Update the Months Statistic
%%% Update the emissions Statistic
%Matlab Import
disp('Updating the monthly emissions statistics...');
ImportedSheet = xlsread('Statistics_Finnish_Industry_Association_RECIPE.xlsm', 'Matlab Import');
RowStartupdate = 11 ;
RowEndupdate = size(ImportedSheet,1);
ColStartupdate = 1 ;
ColEndupdate = size(ImportedSheet,2) ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Emissions_Month = var;

%%% Update the Energy Statistic
disp('Updating the monthly energy statistics...');
RowStartupdate = 2 ;
RowEndupdate = 8;
ColStartupdate = 1 ;
ColEndupdate = size(ImportedSheet,2) ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Energy_Month = var;

%% Update the Correlation Statistic
%%% Update the emissions Statistic
%Matlab Import
disp('Updating the correlation coefficients...');
ImportedSheet = xlsread('Correlation Coefficient_ReciPe_v_1_12.xlsx', 'EcoInvent');
RowStartupdate = 1 ;
RowEndupdate = 108;
ColStartupdate = 15 ;
ColEndupdate = 18 ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Emissions_Correlation_ReCiPev1_12 = var;


%% Update Fingrid Data
%Hourly_Fingrid_Detail
%Import_Fingrid.xlsx
disp('Updating the hourly fingrid production by technology...');
ImportedSheet = xlsread('Import_Fingrid.xlsx', 'FEI');

RowStartupdate = 3 ;
RowEndupdate = size(ImportedSheet,1);
ColStartupdate = 4 ;
ColEndupdate = 14 ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Hourly_Fingrid_Detail = var;

%Hourly_Fingrid
%Load_Gen_fingrid.xlsx
disp('Updating the hourly fingrid total production...');
ImportedSheet = xlsread('Load_Gen_fingrid.xlsx', 'Sheet1');

RowStartupdate = 1 ;
RowEndupdate = size(ImportedSheet,1);
ColStartupdate = 1 ;
ColEndupdate = 3 ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Hourly_Fingrid = var;

%% Update Import Export Data Data
disp('Updating the exported and imported values...');
filename='Exchanged.mat';
m = matfile(filename, 'Writable', true);

ImportedSheet = xlsread('Import-Export.xlsx', 'Exchange FI connections_2012_Ho');

RowStartupdate = 4 ;
RowEndupdate = size(ImportedSheet,1);
ColStartupdate = 8 ;
ColEndupdate = 15 ;

var = ImportedSheet(RowStartupdate:RowEndupdate,ColStartupdate:ColEndupdate);

m.Exchanged_Electricity = var;

%% Update the EmissionsStatistic from other countries
%%% Update the emissions Statistic
%Matlab Import
disp('Updating the emission factors for the trading countries...');
[ImportedSheet] = xlsread('Statistics_Finnish_Industry_Association_RECIPE.xlsm', 'Country');

% Choose the emission database to update: 
% 1. EcoInvent 3.01, 
% 2. ENVIMAT (SYKE database)
% 3. ReCiPe v1.11 (SimaPro database)
% 4. ReCiPe v1.12 (SimaPro database)

Database = 4 ;
Rowsize = size(ImportedSheet,1) ;
ColSize = size(ImportedSheet,2) ;
var = ImportedSheet;
PartialLoad = m.Emissions_Country ;
PartialLoad(1:Rowsize,1:ColSize,Database) = var ; 

m.Emissions_Country = PartialLoad ;

%% Unload the variable
clear m;
end