function AllApp = extractHouseAppliances(opendata)

SimulationName = 'Simulation_NewPower_15min' ;
HouseExtract = 'House1' ;
AllApps = fieldnames(opendata.(SimulationName).ApplianceOneCode.Appliances_ConsStr) ;
TVariableNames = {} ;
for iApp = 1:length(AllApps)
    AppName = AllApps{iApp} ;
    
    T(:,iApp) = opendata.(SimulationName).ApplianceOneCode.Appliances_ConsStr.(AppName).(HouseExtract) ;
    
    TVariableNames{end} = AppName ;
end

AllApp = array2table(T,...
    'VariableNames',TVariableNames) ;