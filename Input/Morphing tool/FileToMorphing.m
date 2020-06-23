function [DataBase] = FileToMorphing(InputData)
%% This file is used to initiate the morphing and calculate the values it requires
% The function calculates the input data from files for the use for
% morphing. It also calls the morphing file, saves the morphed file and
% eventually helps in its usage on smart/thermal house model.
%% Input Data
% This part is used to process input data.
StartDate       = InputData.Time.StartDate;     % This is used to save the start date of the current weather file
EndDate         = InputData.Time.EndDate;       % This is used to save the end date of the current weather file
Scenario        = InputData.Scenario;           % This is the name of the selected scenario
Place           = InputData.Place;              % This is the coordinates of the place
Spacial_Error   = InputData.Spacial_Error;      % This is the spacial error  for describing and determining the area to look in the future scenario files
% File names for reading
FileName_monthly= InputData.FileName.FileName_monthly;  % This saves the file name for the monthly future scenario file
FileName_tas    = InputData.FileName.FileName_tas;  % This saves the file name for the average air temperature file for climate change
% FileName_tasmin = InputData.FileName.FileName_tasmin; % This is the file name for the daily minimum temperature for future scenarios
% FileName_tasmax = InputData.FileName.FileName_tasmax; % This is the file name for the daily msximum temperature for future scenarios
FileForSolar    = InputData.FileName.FileForSolar;      % This is the file for solar radiation
Location        = InputData.FileName.Location;      % This is the name of the location
Path            = InputData.FileName.Path;      % This is the path were you want to save your file
DailyTech       = InputData.FileName.DailyTech;     % This describes the daily temperature database, either uses max and min values, or std of daily temperatures
DatabaseType    = InputData.FileName.DatabaseType;  % This the montly mean temperature file's database type
% Additional information
AveragePeriod   = InputData.AveragePeriod;      % This is the period to which the daily results will be averaged
StartYearDaily  = InputData.StartYearDaily;     % This is the start year of the daily database 
ReferenceYear   = InputData.ReferenceYear;      % This is the reference year for daily delta variation calculation (usually the same as in start year daily)
StartYearMonthly = InputData.StartYearMonthly;   % This is the start year of the monthly data base
StartYearRad    = InputData.StartYearRad;       % This is the start year of future radiation data
MorphingYear    = InputData.MorphingYear;       % This is the year to which you want to eventually morph the data (Be sure to be consistent with your selections, so that morphing year will be part of the averaged periods!)

TimeVector      = StartDate:hours(1):EndDate;

ReferencePointMonthly   = ReferenceYear - StartYearMonthly + 1;
MorphingPointMonthly    = MorphingYear - StartYearMonthly + 1;
ReferencePointRad       = ReferenceYear - StartYearRad + 1;
MorphingPointRad        = MorphingYear - StartYearRad + 1;

%% Read the used variables

% Determine the file parts for the temperature and radiation files
[~, ~, TempExt] = fileparts(InputData.FileName.Temperature);
[~, ~, RadExt]  = fileparts(InputData.FileName.SolarRadiation);

FileExtensions  = {TempExt, RadExt};
VariableNames   = {'Temperature', 'Global_horisontal_radiation'};
FileNames       = {'Temperature', 'SolarRadiation'};

for h = 1:2     % Loop through both options
    
    switch FileExtensions{h}
        
        case '.mat'
            
            if h == 1
                
                Temperature     = load(InputData.FileName.(FileNames{h}), 'Temperature');
                
            else
                
                Solar_Radiation = load(InputData.FileName.(FileNames{h}));
                
            end
            
        case '.epw'
            
            [EPW] = EPWreader(InputData.FileName.(FileNames{h}));
            
            if h == 1
                
                Temperature = EPW.Dry_Bulb_Temperature;
                
            else
                
                Solar_Radiation = EPW.Global_Horizontal_Radiation;
                
            end
            
        otherwise
            
            if h == 1
            
                [Temperature]       = readClimateVariables(InputData.FileName.(FileNames{h}), VariableNames{h});
                
            else
                
                [Solar_Radiation]   = readClimateVariables(InputData.FileName.(FileNames{h}), VariableNames{h});
                
            end
            
    end
    
end

%% Variables from current climate
% This part is used to calculate the variables from current climate for
% reference and determining the changes from them

[ClimateVariables] = CalculateClimateVariables(Temperature, Solar_Radiation, StartDate, EndDate);

% Add the variables for future use here!
%% Monthly delta calculation
% Currently this only works for the nc-files from Paituli database (FMI's
% climate change scenario data

[~,~,FileType]     = fileparts(FileName_monthly);

switch FileType
    
    case '.nc'

        [tasOrg]             = deltaMonthly(FileName_monthly, Place, Spacial_Error);
        
        delta               = tasOrg(:,MorphingPointMonthly) - tasOrg(:,ReferencePointMonthly);
    
    otherwise
        
        [delta]             = ReadMonthlyChange(FileName_monthly, ClimateVariables.MonthlyMean, DatabaseType, ReferencePointMonthly, MorphingPointMonthly, AveragePeriod);
        
end

[~, a]             = deltaMonthlyRad(FileForSolar, ReferencePointRad, MorphingPointRad, AveragePeriod);

% Check the name of the variable for future use!

%% Daily changes calculation
% This section is used to calculate the daily changes in mean temperature,
% variance and on so on. The different options are depicted in them as
% well. Currently only nc-files are used in deltadaily and readable files
% for the daily temperature change from standard deviation.

if strcmp(DailyTech, 'MaxMin')

[~, mean_tasPlace, ~, mean_tasminPlace, ~, mean_tasmaxPlace] = deltaDaily(FileName_tas, InputData.FileName.FileName_tasmin, InputData.FileName.FileName_tasmax, Place, Spacial_Error);

% Add here the part for assigning the values to database structure

DataBase.(Scenario).mean.mean_tasPlace      = mean_tasPlace;
DataBase.(Scenario).min.mean_tasminPlace    = mean_tasminPlace;
DataBase.(Scenario).max.mean_tasmaxPlace    = mean_tasmaxPlace;

% Call the function to calculate the daily variation to an averages period

[DataBase] = ConvertDaylyToMonthly(DataBase, Scenario, StartYearDaily, ReferenceYear, AveragePeriod, MorphingYear);

elseif strcmp(DailyTech, 'StdDaily')
    
    if ~iscell(FileName_tas)
    
        [~,~,DailyExt] = fileparts(FileName_tas);
        
    else
        
        DailyExt = '.csv';
        
    end
    
    switch DailyExt
        
        case '.nc'
            
            [mean_tas] = ReadDailyMeanNc(FileName_tas, Place, Spacial_Error);
            
            DataBase.(Scenario).mean.mean_tasPlace      = mean_tas;
            
            [DataBase] = alfaCalculator(DataBase, Scenario, StartYearDaily, ReferenceYear, AveragePeriod, MorphingYear);
            
        otherwise
            
            [DataBase] = stdDailyFunc(FileName_tas, Scenario, StartYearDaily, ReferenceYear, AveragePeriod, MorphingYear);
            
    end
    
end
% Add here the necessary changes of variable names

%% Selection of correct values for morphing
% This part is used to select the correct values from the previous
% variables for the morphing process

% Monthly value
SelectedYearMonthly     = MorphingPointMonthly - ReferencePointMonthly + 1; % MorphingYear - StartYearMonthly + 1;     % Select the suitable column number for the selection of climate change variable
SelectedYearRad         = MorphingPointRad - ReferencePointRad + 1; %MorphingYear - StartYearRad +1;           % Select the suitable column number for the radiation calculation

% From daily values
SelectedYearDaily       = ceil((MorphingYear - StartYearDaily)/AveragePeriod);    % Used to define the selected column from the averaged period values

%% Morphing
% This is the actual morphing part where the morphed hourly temperature and
% solar radiation files are created for the future

[FutureHourlyData] = Morphing(ClimateVariables, delta, DataBase.(Scenario).morphedalfa, InputData.MorphingTech, Temperature, Solar_Radiation, TimeVector, a);

%% Output values from the function
% Just define the output values from the function. Consider whether to have
% a separate file to assing inputs and save the outputs to a folder!

% File names
FileName        = Location+"_"+Scenario+"_"+string(MorphingYear)+"_"+DatabaseType;

FileNameTemp    = Path + "Future Hourly Temperature Data "+Scenario+" "+Location+" "+string(MorphingYear)+"\Temperature_"+FileName+".mat";
FileNameRad     = Path + "Future Hourly Radiation Data "+Scenario+" "+Location+" "+string(MorphingYear)+"\Solar_Radiation_"+FileName+".mat";

% Check if similar file already exists
if ~isfile(FileNameTemp) && ~isfile(FileNameRad)

% Save file
mkdir(Path,"Future Hourly Temperature Data "+Scenario+" "+Location+" "+string(MorphingYear))
mkdir(Path,"Future Hourly Radiation Data "+Scenario+" "+Location+" "+string(MorphingYear))
save(FileNameTemp, '-struct', 'FutureHourlyData','Temperature')
save(FileNameRad, '-struct', 'FutureHourlyData','Radiation')

elseif ~isfile(FileNameTemp)
    save(FileNameTemp, '-struct', 'FutureHourlyData.Temperature')
    
elseif ~isfile(FileNameRad)
    save(FileNameRad, '-struct', 'FutureHourlyData.Radiation')
    
else
    save(FileNameTemp, '-struct', 'FutureHourlyData', 'Temperature')
    save(FileNameRad, '-struct', 'FutureHourlyData', 'Radiation')
    %uiwait('Both paths already exist')
    
end


end

