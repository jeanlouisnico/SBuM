function [AllApp, TVariableNames, varargout] = extractHouseAppliances(opendata, SimulationName)

% SimulationName = 'Simulation_House_1h' ;
HouseExtract = 'House1' ;
AllApps = fieldnames(opendata.(SimulationName).ApplianceOneCode.Appliances_ConsStr) ;
TVariableNames = {} ;
TVariableNames10s = {} ;
iApp10s = 1 ;
for iApp = 1:length(AllApps)
    AppName = AllApps{iApp} ;
    
    T(:,iApp) = opendata.(SimulationName).ApplianceOneCode.Appliances_ConsStr.(AppName).(HouseExtract) ;
    
    
    if opendata.(SimulationName).All_Var.GuiInfo.App10s
        try 
            endextract = size(T10s,1) ;
        catch
            endextract = '' ;
        end
        for subapp = 1:(size(opendata.(SimulationName).App.Info.(AppName),2))
            if isempty(endextract)
                T10s(:,iApp10s) = opendata.(SimulationName).App.Info.(AppName)(subapp).(HouseExtract).App10s.DataOutput ;
            else
                T10s(:,iApp10s) = opendata.(SimulationName).App.Info.(AppName)(subapp).(HouseExtract).App10s.DataOutput(1:endextract) ;
            end
            
            iApp10s = iApp10s + 1 ;
            if (size(opendata.(SimulationName).App.Info.(AppName),2)) > 1
                TVariableNames10s{end + 1} = [AppName num2str(subapp)] ;
            else
                TVariableNames10s{end + 1} = AppName ;
            end
        end
    end
    TVariableNames{end + 1} = AppName ;
end

AllApp = array2table(T,...
    'VariableNames',TVariableNames) ;

if opendata.(SimulationName).All_Var.GuiInfo.App10s
    varargout{1} = array2table(T10s,...
    'VariableNames',TVariableNames10s) ;
    varargout{2} = TVariableNames10s ;
end