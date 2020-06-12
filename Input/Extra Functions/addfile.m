function addfile(Project_ID, folder_name)

if isnumeric(Project_ID)
    mkdir(folder_name,num2str(Project_ID));
    mkdir([folder_name,filesep,num2str(Project_ID),filsep,'Variable_File']);
else
    mkdir(folder_name,Project_ID);
    mkdir([folder_name,filesep,Project_ID,filesep,'Variable_File']);
end