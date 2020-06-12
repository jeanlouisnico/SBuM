function Retrieve_Variable()
clear all
filename = 'Variables_Name.xlsx';

sheet = 'Sheet1';
files = dir(strcat('C:\Users\jlouis\Desktop\Smart_Energy_Grid_and_House\Simulation\NorTech Library\MatLab model Beta\Output\febdgfsa\Variable_File\','*.mat'));
for m = 1:size(files)
    xlRange1 = strcat(char(64 + m),'2');
    details = whos(matfile(files(m).name));
    for n = 1:size(details)
        StringName(n,:) ={details(n).name};
    end
    xlRange2 = strcat(char(64 + m),'1');
    xlswrite(filename,{files(m).name},sheet,xlRange2)
    xlswrite(filename,StringName,sheet,xlRange1);
    StringName(:,:) ='';
end