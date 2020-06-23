dbstop if error
% clear all
[~, MaxEnergy, ~] = xlsread('C:\Users\jlouis\Desktop\Work\Smart_Energy_Grid_and_House\Simulation\Smart Buidling Simulation\Version\Test Version\MatLab model Beta\Input\Variables\Statistics_Finnish_Industry_Association.xlsm','Matlab Import','F1');
[~, MaxEmission, ~] = xlsread('C:\Users\jlouis\Desktop\Work\Smart_Energy_Grid_and_House\Simulation\Smart Buidling Simulation\Version\Test Version\MatLab model Beta\Input\Variables\Statistics_Finnish_Industry_Association.xlsm','Matlab Import','B10');

%% Import the data
[a, ~, ~] = xlsread('C:\Users\jlouis\Desktop\Work\Smart_Energy_Grid_and_House\Simulation\Smart Buidling Simulation\Version\Test Version\MatLab model Beta\Input\Variables\Statistics_Finnish_Industry_Association.xlsm','Matlab Import',MaxEnergy{1});
Energy_Month = a;
[a, ~, ~] = xlsread('C:\Users\jlouis\Desktop\Work\Smart_Energy_Grid_and_House\Simulation\Smart Buidling Simulation\Version\Test Version\MatLab model Beta\Input\Variables\Statistics_Finnish_Industry_Association.xlsm','Matlab Import',MaxEmission{1});
Emissions_Months = a;
