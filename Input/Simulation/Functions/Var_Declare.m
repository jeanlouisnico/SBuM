Excel_Var = Read_Excel_File(1,2);
Input_Data= Read_Excel_File(1,3);
for NewVariable = 1:length(Excel_Var)
    ws.(Excel_Var{1,NewVariable})=Input_Data{NewVariable};
end