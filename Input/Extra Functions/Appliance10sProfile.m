%% Appliance 10s profiles
function [AppArr] = Appliance10sProfile(CSVInput)
T = readtable(CSVInput);
Tp = table2struct(T) ;

AppNames = fieldnames(Tp) ;

for i = 1:length(AppNames)
    % Loop through all the Appliances 
    AppArray = [Tp.(AppNames{i})]' ;
    
    AppArray = AppArray(~isnan(AppArray)) ;
    
    AppArr.(AppNames{i}) = AppArray ;
    
end