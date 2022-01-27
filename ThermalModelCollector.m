function ThermalModelCollector
%A function to be used in collecting thermal model results from SBuM sims
%   This function can be used to collect thermal model results from Smart
%   Building Model simulations. It collects: Total Thermal Demand, Space 
%   Heating Power (if applicable), Ventilation Heating Power, Total
%   Electricity consumption from HVAC, Indoor and operational
%   temperatures, and Climate Change Emissions. Collection file can be
%   saved as .mat, .csv or .xls
%% Begin the function

% Select the file to load
[fileToLoad, pathToLoad] = uigetfile('*.mat','Select the EnergyOutput.mat file you wish to collect the data from');   

% Select if the file is correct and if not give an error
if ~strcmp(fileToLoad,'EnergyOutput.mat')
    errordlg('You have selected wrong file. Please select EnergyOutput.mat file','Wrong file selection')
end

% Create variable for the full path for loading
fullFileDir = fullfile(pathToLoad,fileToLoad);

% Load ThermalVariables from EnergyOutput.Thermal_Model
EnergyOutput = load(fullFileDir, 'EnergyOutput');

% Assign Thermal Model Variables
ThermalModel = EnergyOutput.EnergyOutput.Thermal_Model;

% Collect the house names 
Houses = fieldnames(ThermalModel);

%% Run for-loop to collect data

% Pre-allocation
% ThermalVariables = struct([]);

% Start for loop
for i = 1:length(Houses)
    
    % Collect Total Thermal Demand
    ThermalVariables.(Houses{i}).TotalThermalDemand         = ThermalModel.(Houses{i}).Heat_Demand.Total_EnergyDemand;
    
    % Check if space heating power or input to underfloor heater is an
    % option
    if any(contains(fieldnames(ThermalModel.(Houses{i}).Heating), 'HeaterPower'))
    
        % Collect Space heating power consumption, if it exists
        ThermalVariables.(Houses{i}).SpaceHeatingPower      = ThermalModel.(Houses{i}).Heating.HeaterPower;
        
    elseif any(contains(fieldnames(ThermalModel.(Houses{i}).Heating), 'Input'))
        
        ThermalVariables.(Houses{i}).SpaceHeatingPower      = ThermalModel.(Houses{i}).Heating.Input;
        
    end
    
    % Collect Ventilation heating power 
    ThermalVariables.(Houses{i}).VentilationHeatingPower    = ThermalModel.(Houses{i}).Heating_Ventil;
    
    % Collect HVAC system total electricity consumption
    ThermalVariables.(Houses{i}).TotalElecHVAC              = ThermalModel.(Houses{i}).Total_Electricity_Consumption;
    
    % Collect indoor air temperature
    ThermalVariables.(Houses{i}).IndoorTemp                 = ThermalModel.(Houses{i}).Temperature.IndoorTemperature;
    
    % Collect operative temperature
    ThermalVariables.(Houses{i}).OperativeTemp              = ThermalModel.(Houses{i}).Temperature.OperativeTemperature;
    
    % Collect climate change emissions 
    ThermalVariables.(Houses{i}).CC                         = table(ThermalModel.(Houses{i}).Emissions.Time, ThermalModel.(Houses{i}).Emissions.DataOutput(:,1));
    
    ThermalVariables.(Houses{i}).CC.Properties.VariableNames = {'Time' 'DataOutput'};
    
end

%% Saving file

saveFileType = questdlg('Select the file type you want to use to save your variables to',...
                        'Save file type selection',...
                        '*.mat',... %'*.csv',
                        '*.xls');%,'*.mat');
                    
switch saveFileType
    
    case '*.mat'
        
        uisave('ThermalVariables','ThermalVariables.mat')
        
%     case '*.csv'
%         
%         %for i = 1:length(Houses)
%             
%             [newFile,newPath] = uiputfile('*.csv','Select file name and path for saving');
%             
%             newFileSave = fullfile(newPath,newFile);
%             
%             writetable(struct2table(ThermalVariables), newFileSave)
            
    case '*.xls'
        
            [newFile,newPath] = uiputfile('*.xls','Select file name and path for saving');
            
            newFileSave = fullfile(newPath,newFile);
            
            for j = 1:length(Houses)
                
                VarNamesStruct = fieldnames(ThermalVariables.(Houses{j}));
                
                xlsSaveTable = table(ThermalVariables.(Houses{j}).TotalThermalDemand.Time);
                
                xlsSaveTable.Properties.VariableNames = {'Time'};
                
                for m = 1:length(VarNamesStruct)
                
                    xlsSaveTable.(VarNamesStruct{m}) = ThermalVariables.(Houses{j}).(VarNamesStruct{m}).DataOutput;
                    
                end
            
                writetable(xlsSaveTable, newFileSave, 'Sheet', j)
                
            end
            
end

%% Confirm the user of succesfull saving

msgbox('Operation complete!');

end

