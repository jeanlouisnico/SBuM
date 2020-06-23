function [Output] = readClimateVariables(FileName, VariableName)
%% This is a function to read the temperature and solar radiation files
% Reason for this simple file is to reduce the use of memory from the
% original file

Variable   = readtable(FileName);
% RadTable    = readtable(SolarRadiationFile);

Output         = Variable.(VariableName);
% Solar_Radiation     = RadTable.Global_horisontal_radiation;     % Currently suitable for TRY from FMI

end

