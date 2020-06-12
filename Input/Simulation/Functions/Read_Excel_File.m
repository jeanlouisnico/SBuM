function [alldata] = Read_Excel_File(Nbr_Building,rowstart)
Sheet = 'Input_Param';

MaxCol = xlsread('Variables and matrix.xlsm', Sheet, 'P1');
if MaxCol < 26
    MaxCol = char(reshape(64+MaxCol,1,1));
else
    MaxCol = strcat(char(64+floor(MaxCol/26)),char(64+(MaxCol/26-floor(MaxCol/26))*26)+1);
end

xlRange = strcat('A',num2str(rowstart),':',MaxCol,num2str(Nbr_Building + 2));

[~, ~, alldata] = xlsread('Variables and matrix.xlsm', Sheet, xlRange);
% for appmax = 1:Nbr_Building
%     alldata{appmax + 1,114} = max([alldata{2:end,114}]);
% end

