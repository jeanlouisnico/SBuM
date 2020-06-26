function AllApp = extractHouseAppliances(opendata, SimulationName)

% SimulationName = 'Simulation_House_1h' ;
HouseExtract = 'House1' ;
AllApps = fieldnames(opendata.(SimulationName).ApplianceOneCode.Appliances_ConsStr) ;
TVariableNames = {} ;
for iApp = 1:length(AllApps)
    AppName = AllApps{iApp} ;
    
    T(:,iApp) = opendata.(SimulationName).ApplianceOneCode.Appliances_ConsStr.(AppName).(HouseExtract) ;
    
    TVariableNames{end + 1} = AppName ;
end

AllApp = array2table(T,...
    'VariableNames',TVariableNames) ;