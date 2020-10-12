function waterDHtest

prob = DHW_distribution_LaunchSim ;

Time_Sim.stp  = 24 ; % number of steps per day

for iday = 1:8760
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
    
    
    if iday == 1 || mod(iday,24) == 0
        % Reset the counter to zero at the beginning of each day
        water_profile.(countnameday) = 0 ;
    end
    
    [water_profile, prob] = waterWD(prob, iday, Time_Sim) ;
    
end