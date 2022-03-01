function collectdata
%A function to be used in collecting thermal model results from SBuM sims
%   This function can be used to collect thermal model results from Smart
%   Building Model simulations. It collects: Total Thermal Demand, Space 
%   Heating Power (if applicable), Ventilation Heating Power, Total
%   Electricity consumption from HVAC, Indoor and operational
%   temperatures, and Climate Change Emissions. Collection file can be
%   saved as .mat, .csv or .xls
%% Begin the function
currentFolder = pwd ;
% Select the file to load
[pathToLoad] = uigetdir(currentFolder,'Select the simulation folder you wish to collect the data from');   

% Select if the file is correct and if not give an error
% if ~strcmp(fileToLoad,'EnergyOutput.mat')
%     errordlg('You have selected wrong file. Please select EnergyOutput.mat file','Wrong file selection')
% end

% Create variable for the full path for loading
fullFileDir.EnergyOutput = fullfile(pathToLoad,'EnergyOutput.mat');
fullFileDir.Bill_Global = fullfile(pathToLoad,'Bill_Global.mat');
fullFileDir.Cons_Tot_Global = fullfile(pathToLoad,'Cons_Tot_Global.mat');
fullFileDir.Emissions_Houses = fullfile(pathToLoad,'Emissions_Houses.mat');
fullFileDir.Cons_app = fullfile([pathToLoad filesep 'Variable_File'],'Appliances_One_CodeStrv2.mat');

% Load ThermalVariables from EnergyOutput.Thermal_Model
EnergyOutput        = load(fullFileDir.EnergyOutput, 'EnergyOutput');
Bill_Global         = load(fullFileDir.Bill_Global, 'Price');
Cons_Tot_Global     = load(fullFileDir.Cons_Tot_Global, 'Cons_Tot');
Emissions_Houses    = load(fullFileDir.Emissions_Houses, 'Emissions_Houses');
Cons_app            = load(fullFileDir.Cons_app, 'NewVar');
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
    ThermalVariables.(Houses{i}).TotalThermalDemand         = convert2timetable(ThermalModel.(Houses{i}).Heat_Demand.Total_EnergyDemand) ;
    
    % Check if space heating power or input to underfloor heater is an
    % option
    if any(contains(fieldnames(ThermalModel.(Houses{i}).Heating), 'HeaterPower'))
        tTime = ThermalVariables.(Houses{i}).TotalThermalDemand.Time ;
        % Collect Space heating power consumption, if it exists
        if isa(ThermalModel.(Houses{i}).Heating.HeaterPower,'double')
            ThermalVariables.(Houses{i}).SpaceHeatingPower      = array2timetable(ThermalModel.(Houses{i}).Heating.HeaterPower','RowTimes',tTime(1:length(ThermalModel.(Houses{i}).Heating.Input)));
        else
            ThermalVariables.(Houses{i}).SpaceHeatingPower      = convert2timetable(ThermalModel.(Houses{i}).Heating.HeaterPower);
        end
    elseif any(contains(fieldnames(ThermalModel.(Houses{i}).Heating), 'Input'))
        tTime = ThermalVariables.(Houses{i}).TotalThermalDemand.Time ;
        if isa(ThermalModel.(Houses{i}).Heating.HeaterPower,'double')
           ThermalVariables.(Houses{i}).SpaceHeatingPower      = array2timetable(ThermalModel.(Houses{i}).Heating.Input','RowTimes',tTime(1:length(ThermalModel.(Houses{i}).Heating.Input)));
        else
            ThermalVariables.(Houses{i}).SpaceHeatingPower      = convert2timetable(ThermalModel.(Houses{i}).Heating.Input);
        end
    end
    
    % Collect Ventilation heating power 
    ThermalVariables.(Houses{i}).VentilationHeatingPower    = convert2timetable(ThermalModel.(Houses{i}).Heating_Ventil);
    
    % Collect HVAC system total electricity consumption
    ThermalVariables.(Houses{i}).TotalElecHVAC              = convert2timetable(ThermalModel.(Houses{i}).Total_Electricity_Consumption);
    
    % Collect indoor air temperature
    ThermalVariables.(Houses{i}).IndoorTemp                 = convert2timetable(ThermalModel.(Houses{i}).Temperature.IndoorTemperature);
    
    % Collect operative temperature
    ThermalVariables.(Houses{i}).OperativeTemp                  = convert2timetable(ThermalModel.(Houses{i}).Temperature.OperativeTemperature);
    
    % Collect climate change emissions 
    ThermalVariables.(Houses{i}).CC                             = timetable(ThermalModel.(Houses{i}).Emissions.Time, ThermalModel.(Houses{i}).Emissions.DataOutput(:,1));
    
    ThermalVariables.(Houses{i}).CC.Properties.VariableNames    = {'emissions'};
    ThermalVariables.(Houses{i}).Priceheating                          = Bill_Global.Price.(Houses{i})(:,'Heating') ;

    powervariables.(Houses{i}).CC.Total = Emissions_Houses.Emissions_Houses.(Houses{i}).Cons_Tot.CC ;
    powervariables.(Houses{i}).CC.byAppliance = Emissions_Houses.Emissions_Houses.(Houses{i}).Appliances ;
    powervariables.(Houses{i}).Price = Bill_Global.Price.(Houses{i})(:,'Electrical_consumption') ;
    powervariables.(Houses{i}).consumption.total = Cons_Tot_Global.Cons_Tot.House1 ; 

    Allapp = fieldnames(Cons_app.NewVar.Appliances_ConsStr) ;
    
    for iapp = 1:length(Allapp)
        try
            powervariables.(Houses{i}).consumption.appliance.(Allapp{iapp}) = array2timetable(Cons_app.NewVar.Appliances_ConsStr.(Allapp{iapp}).(Houses{i}), 'RowTimes', powervariables.(Houses{i}).CC.Total.Time) ;
        catch
            continue ;
        end
    end

    % Collect the data for the applicances


end

%% Saving file

saveFileType = questdlg('Select the file type you want to use to save your variables to',...
                        'Save file type selection',...
                        '*.mat','*.xlsx','*.mat') ; %'*.csv',
                        %'*.xls');%,'*.mat');
                    
switch saveFileType
    
    case '*.mat'
        
        uisave({'ThermalVariables','powervariables'},'datacollector.mat')
        
%     case '*.csv'
%         
%         %for i = 1:length(Houses)
%             
%             [newFile,newPath] = uiputfile('*.csv','Select file name and path for saving');
%             
%             newFileSave = fullfile(newPath,newFile);
%             
%             writetable(struct2table(ThermalVariables), newFileSave)
            
    case '*.xlsx'
        
            [newFile,newPath] = uiputfile('*.xlsx','Select file name and path for saving');
            
            newFileSave = fullfile(newPath,newFile);
            
            for j = 1:length(Houses)
                source = ThermalVariables.(Houses{j}) ;
                VarNamesStruct = fieldnames(source);
                
                out = synchronize(source.(VarNamesStruct{1}), source.(VarNamesStruct{2})) ;
                
                for ivar = 3:length(VarNamesStruct)
                    out = synchronize(out, source.(VarNamesStruct{ivar}),"commonrange") ;
                end
                
                legend = VarNamesStruct ;

                source = powervariables.(Houses{j}) ;
                VarNamesStruct = fieldnames(source);

                for ivar = 1:length(VarNamesStruct)
                    switch VarNamesStruct{ivar}
                        case 'CC'
                            out = synchronize(out, source.(VarNamesStruct{ivar}).Total,"commonrange") ;
                            legend{end+1} = 'Emissions_Total_CC' ;
                            Allapp = fieldnames(source.(VarNamesStruct{ivar}).byAppliance) ;
                            for iapp = 1:length(Allapp)
                                try
                                    out = synchronize(out, source.(VarNamesStruct{ivar}).byAppliance.(Allapp{iapp}).CC,"commonrange") ;
                                    legend{end+1} = ['Emissions_' Allapp{iapp} '_CC'] ;
                                catch
                                    continue ;
                                end
                            end    
                        case 'Price'
                            out = synchronize(out, source.(VarNamesStruct{ivar}),"commonrange") ;
                            legend{end+1} = 'Price_total' ;
                        case 'consumption'
                            out = synchronize(out, source.(VarNamesStruct{ivar}).total,"commonrange") ;
                            legend{end+1} = 'consumption_total_elec_noheating' ;
                            Allapp = fieldnames(source.(VarNamesStruct{ivar}).appliance) ;
                            for iapp = 1:length(Allapp)
                                try
                                    out = synchronize(out, source.(VarNamesStruct{ivar}).appliance.(Allapp{iapp}),"commonrange") ;
                                    legend{end+1} = ['consumption_' Allapp{iapp} '_elec'] ;
                                catch
                                    continue ;
                                end
                            end    
                    end
                end

                out.Properties.VariableNames =  makevalidstring(legend) ;            
                writetimetable(out, newFileSave,'Sheet',Houses{j})
                
            end
            
end

%% Confirm the user of succesfull saving

msgbox('Operation complete!');

end

function dataout = convert2timetable(datain)
    if istimetable(datain)
        dataout = datain ;
    elseif istable(datain)
        dataout = table2timetable(datain) ; 
    elseif isa(datain,'double')
        dataout = array2timetable(datain) ;    
    end
end