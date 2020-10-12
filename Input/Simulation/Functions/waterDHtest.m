function waterDHtest

prob = DHW_distribution_LaunchSim ;

Time_Sim.stp  = 24 ; % number of steps per day

for iday = 0:8760
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% FOR TEST PURPOSES %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SimTime                 = datenum(2012,1,1) + iday/Time_Sim.stp ;
    Time_Sim.SimTime        = SimTime ;
    TimeStr                 = datetime(Time_Sim.SimTime,'ConvertFrom','datenum') ;
    Time_Sim.TimeStr        = TimeStr ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% FOR TEST PURPOSES %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [water_profile, prob] = waterWD(prob, iday + 1, Time_Sim) ;
    
end