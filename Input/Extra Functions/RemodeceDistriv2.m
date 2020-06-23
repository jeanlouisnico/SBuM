function [Remodeceout] = RemodeceDistriv2(FileName)
% This is an average distribution from the Remodece database for each
% appliance for Norway mostly. This is an aggregated value from multiple
% measurments.
 % 'Remodece_Distribution.xlsx'
 
Remodece_Distribution = readtable(FileName,'ReadRowNames',true) ;
AllApps = fieldnames(Remodece_Distribution) ;


for i = 1:length(AllApps)
    if ~any(strcmp(AllApps{i},{'Properties' 'Time' 'Variables'}))
        Remodeceout.(AllApps{i}) = Remodece_Distribution.(AllApps{i}) ;
    end
end