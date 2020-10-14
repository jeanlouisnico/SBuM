function [water_profile] = waterDHtest

dbstop if error

prob = DHW_distribution_LaunchSim('plotvar',true, 'A4', 60) ;

Time_Sim.stp  = 24 * 60 / prob.A4 ; % number of steps per day

for iday = 0:(8760*60/prob.A4 - 1)
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
    water_profile.start = 0 ;
    [water_profile, prob] = waterWD(prob, iday + 1, Time_Sim, water_profile, 1) ;
    
end

water_profile = Waterstats(prob, water_profile) ;

