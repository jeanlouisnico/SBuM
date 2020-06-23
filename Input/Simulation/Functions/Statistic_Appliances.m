function [r] = Statistic_Appliances(Array, Housenbr)
global TimeVector Timeoffset
load('C:\Users\jlouis\Desktop\Smart_Energy_Grid_and_House\Simulation\NorTech Library\MatLab model Beta\Input\Smart_House_Data_MatLab.mat')
TimeVector = Hourly_Time;
%Timeoffset = 96409;
%myiter = 8736;
for i = 1:7
    [r(i)] = size(find(Array(Housenbr,:)' > 0 & myweekday(TimeVector(Timeoffset:Timeoffset + myiter)) == i),1);
end