function [EnergyOutput, Time_Sim] = DeclareTime(All_Var,Time_Sim,EnergyOutput,Input_Data)

Housenumber = fieldnames(All_Var.GuiInfo.Simulationdata) ;
EnergyOutput.Price = [] ;
EnergyOutput.Price_Foreca = zeros(48,1) ;

Time_Sim.RowForeca = ones(24,1);
switch (Input_Data.Time_Step) 
    case 'Hourly'
        Time_Sim.stepreal    = 1; % This should be expressed in a common unit which is the minimum common denominator for all simulation. 10s?
    case '30 minutes'
        Time_Sim.stepreal    = 0.5;
    case '10s'
        Time_Sim.stepreal    = 1/(6*60);
    case '1 minute'
        Time_Sim.stepreal    = 1/60;
    case '15 minutes'
        Time_Sim.stepreal    = 0.25;
end
Time_Sim.stp         = 24 / Time_Sim.stepreal;

Time_Sim.myiter         = 0     ;
Time_Sim.SimTime        = 0    ;
Time_Sim.TimeStr        = []     ;
Time_Sim.timeyear       = 0    ;
Time_Sim.timemonth      = 0    ;
Time_Sim.timeday        = 0    ;
Time_Sim.timehour       = 0    ;
Time_Sim.timedayyear    = 0    ;
Time_Sim.timeweekday    = 0    ;
Time_Sim.timeweeknbr    = 0    ;
Time_Sim.timedaynbr     = 0    ;
Time_Sim.Alpha          = 0    ;
Time_Sim.Solar_Azim     = 0    ;
Time_Sim.tilt           = 0    ;
Time_Sim.Solar_zenith   = 0    ;
Time_Sim.timedaynbrN    = 0    ;
Time_Sim.Reduce_Time2   = 0    ;


    for i = 1:numel(Housenumber)
        EnergyOutput.PVPower.(Housenumber{i})                 = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.SolarLuminance.(Housenumber{i})          = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.WTPower.(Housenumber{i})                 = zeros(1,Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.Season.(Housenumber{i})                  = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.ElecPower.(Housenumber{i})               = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.FCPower.(Housenumber{i})                 = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.Cons_Appli_Overall.(Housenumber{i})      = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.SolarLuminancev.(Housenumber{i})         = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.Occupancy.(Housenumber{i})               = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
        EnergyOutput.Thermal_Demand.(Housenumber{i})          = zeros(1, Time_Sim.nbrstep.(Housenumber{i}) + 1);
                
        EnergyOutput.Thermal_Model.(Housenumber{i}).Forecast.Weather                                = zeros(1,length(All_Var.Hourly_Temperature));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Forecast.PV_forecast_TRY                        = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));                            
        EnergyOutput.Thermal_Model.(Housenumber{i}).Forecast.Day_ahead_heat_demand_forecast         = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Forecast.Heat_demand_forecast                   = 0;
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).currentyear                                     = 0;
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Model                                           = zeros(1,365);                                 %%%%%%%%%% Change to adapt to the number of time step.                  
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Temperature.Nodal_Temperatures                  = zeros(20,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Temperature.IndoorTemperature                   = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Temperature.OperativeTemperature                = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Temperature.Mean_yesterday                      = 0;
        EnergyOutput.Thermal_Model.(Housenumber{i}).Temperature.Mean_2days                          = 0;
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Thermal_Comfort.Thermal_Comfort_Achieved        = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Thermal_Comfort.Thermal_Comfort_notAchieved  = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Heat_Demand.Heat_Demand                         = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Internal_Heat_Gain                              = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Total_Electricity_Consumption                   = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Heating.Used_hours_underfloor                   = 0;
        EnergyOutput.Thermal_Model.(Housenumber{i}).Heating.CumInput                                = 0;
        EnergyOutput.Thermal_Model.(Housenumber{i}).Heating.CurrentCapacity                         = 0;
        EnergyOutput.Thermal_Model.(Housenumber{i}).Heating.Heating_Scheme                          = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Heating.Set_Up                                  = 0;
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Battery.CurrentCapacity                         = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Battery.Input                                   = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Battery.Output                                  = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Economics.Gain                                  = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        EnergyOutput.Thermal_Model.(Housenumber{i}).Economics.SavedMoney                            = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).PhotoVoltaic_Elec_Heat                          = zeros(1,Time_Sim.nbrstep.(Housenumber{i}));
        
        EnergyOutput.Thermal_Model.(Housenumber{i}).Emissions                                       = zeros(Time_Sim.nbrstep.(Housenumber{i}),size(All_Var.Hourly_Emissions,2));
        
        Time_Sim.wknbrCNT.(Housenumber{i})                    = 0 ;
        Time_Sim.daynbrCNT.(Housenumber{i})                   = 0 ;
        Time_Sim.currentday.(Housenumber{i})                  = 0 ;
        %%%
        % Get the starting date as a timeserie. As it can be seen from the
        % first equation, each variable that are building dependent are
        % expressed in a matrix form. Each row represents a different house
        % while each column can be either a reference value or a function of
        % time. In the second case, each column represents one step in the
        % iteration. This rule applies everywhere else in the model.    
        Time_Sim.StartDate.(Housenumber{i})(1)   = datenum(datetime(Input_Data.StartingDate,'InputFormat','dd/MM/yyyy')) ;
        Time_Sim.EndDate.(Housenumber{i})(1)     = datenum(datetime(Input_Data.EndingDate,'InputFormat','dd/MM/yyyy'));
        %%%
        % _*stp*_ defines the number of step to complete 1 full day of 24 hours
        %%%
        % $$Step_{24h}=\,\frac{24}{Timestep}$$
        %%%
        % Where _Timestep_ is the fraction of step in a reference of 1 hour. In
        % this matter, Timeserie = 0.5 is equivalent of having a 30 minutes
        % time step.
        
        %%%
        % This step is to evaluate the number of step equivalent to 6 month 
        % _*Sixmtheq*_ in order to recalculate the cleanex index for the 
        % PV-Panels. This variable is used much later in section ...
        %%%
        % $$C_{PV}=Step_{24h}\times 183$$
        %%%
        % Where $C_{PV}$ is the equivalent number of steps representing 6 month
        % of simulation. 183 is the number of days in half a year.
        Time_Sim.Sixmtheq.(Housenumber{i})(1) = Time_Sim.stp * 183; 
        %%%
        % Determine the last time of a day. In case the of hourly time step,
        % the last tim of the day is 23h (11pm), if itwould be an
        % minute-to-minute time step, it would be 23h59 (or 11:59pm). This
        % variable is used within the controller and its use is highlighted in
        % the latter section _Controller_.
        Time_Sim.lasthour.(Housenumber{i})(1)   = hour(Time_Sim.StartDate.(Housenumber{i})(1) + (Time_Sim.stp - 1)/Time_Sim.stp);
        Time_Sim.lastminute.(Housenumber{i})(1) = minute(Time_Sim.StartDate.(Housenumber{i})(1) + (Time_Sim.stp - 1)/Time_Sim.stp);   
        Time_Sim.lasttime.(Housenumber{i})(1)   = Time_Sim.lasthour.(Housenumber{i})(1) + Time_Sim.lastminute.(Housenumber{i})(1) / 60;
        %%%
        % In the final section of this module, all checking values are set to 0
        % as their default value. The _Iteration_ variables are used for each
        % sub module e.g. _Scenario_, _SolRad_, and so on. _N_occurence_ are
        % used for the time setting highlighted inthe section below. The last
        % trow of vriables are used by the controller.
        Time_Sim.N_occurence.(Housenumber{i})(1)   = 1;
        Time_Sim.N1_occurence.(Housenumber{i})(1)   = 1;
        Time_Sim.Iteration.(Housenumber{i})(1)     = 0;
        Time_Sim.Iteration2.(Housenumber{i})(1)    = 0;
        Time_Sim.Iteration3.(Housenumber{i})(1)    = 0;
        Time_Sim.Iteration4.(Housenumber{i})(1)    = 0;
        Time_Sim.Iteration5.(Housenumber{i})(1)    = 0;
        Time_Sim.Iteration7.(Housenumber{i})(1)    = 0;
        Time_Sim.currentweek.(Housenumber{i})(1)   = 1;
        Time_Sim.Comp_Cons.(Housenumber{i})(1)      = 0;
        Time_Sim.Delay_time.(Housenumber{i})(1)     = 0; 
        Time_Sim.hour_1_delay.(Housenumber{i})(1)   = 0; 
        Time_Sim.Reduce_time.(Housenumber{i})(1)    = 1;
        %%%
        % The weather database collected come from the 1st of January 2000 to
        % Summer 2013. If the simulation starts in the middle of the database,
        % it is a priority to find the starting point of the database (as each
        % of the iteration will increment the starting time offset by 1 step:
        % either an hour or half an hour).
        %%%
        % NOTE: STP SHOULD BE REMOVED FOR THE SOLAR RADIATION DATA AS THE SOLAR
        % DATABASE EXIST ONLY FOR EVERY HOUR AND NOT EVERY HALF AN HOUR.
        Time_Sim.Timeoffset = Time_Sim.stp * (datenum(year(Time_Sim.StartDate.(Housenumber{i})(1)),month(Time_Sim.StartDate.(Housenumber{i})(1)),day(Time_Sim.StartDate.(Housenumber{i})(1))) ...
                                             -datenum(Time_Sim.YearStartSim,1,1));
    end