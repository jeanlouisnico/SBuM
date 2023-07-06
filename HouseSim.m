function [Power_prod, Cons_Tot, Occ, Money,varargout] = HouseSim(varargin) 
%% Passing Inputs
%%% Passing first

BuildSim = varargin{1} - 1;
Nbr_Building = varargin{2};
Input_Data = varargin{3};
All_Var = varargin{4};
Time_Sim = varargin{5};
% Time_Step = Input_Data.Time_Step ;
SimDetails = varargin{6};
HouseTitle = varargin{7};
Cont = varargin{8};
App = varargin{9};
EnergyOutput = varargin{10};
SDI = varargin{11};
%% Default values setting
% Building_Area
if strcmp(Input_Data.Building_Area,'-1')
    Input_Data.Building_Area = num2str(39.6 * str2double(Input_Data.inhabitants))   ;
end
%% Time definition
%%%
% at each iteration, the time is calculated in terms of year, month, day, 
% Weekday name, hour, and minute when relevant. At each iteration, a step
% is incremented in the time functions and return the corresponding time to
% the specific step being carried out.
%%%
% The variable calculated below are the year " _*timeyear*_ ", the month
% " _*timemonth*_ ", the day " _*timeday*_ ", the hour " _*Hour*_ ", the minute
% " _*Minute*_ ", the time of the day in term of hours plus decimales
% " _*timehour*_ ", the starting year of the current year " _*startyr*_ ", and the
% day number of the year " _*timedayyear*_ "
%%%
% _*Note*_: the timeserie embedded in MatLab interpret '1' as a number of
% day. Thus, in order to increment the right timestep, it is necessary to
% divide the iteration number by the number of steps that a full day has.

SimTime                 = Time_Sim.StartDate.(Input_Data.Headers)(1) + Time_Sim.myiter/Time_Sim.stp ;
Time_Sim.SimTime        = SimTime ;
TimeStr                 = datetime(Time_Sim.SimTime,'ConvertFrom','datenum') ;
Time_Sim.TimeStr        = TimeStr ;
Time_Sim.timeyear       = TimeStr.Year   ;
Time_Sim.timemonth      = TimeStr.Month  ;
Time_Sim.timeday        = TimeStr.Day    ;   
Time_Sim.timeminute     = TimeStr.Minute ;
Time_Sim.timesecond     = TimeStr.Second ;
Time_Sim.Hour           = TimeStr.Hour   ;
Time_Sim.timehour       = Time_Sim.Hour + (Time_Sim.timeminute / 60) + (Time_Sim.timesecond  / 3600)                               ; % Convert time step into hourly fraction
startyr                 = datenum(Time_Sim.timeyear,1,1)                                        ;
currtyr                 = datenum(Time_Sim.timeyear,Time_Sim.timemonth,Time_Sim.timeday) + 1    ;
Time_Sim.timedayyear    = currtyr - startyr                                                     ; % Day of the year
%%%
% The particularity of the _*weekday*_ function is that it starts the week on
% a Sunday (American standard). Thus, the function _*myweekday*_ is an
% adapted version of the original function where the weeks start on a
% Monday (European standard).
   Time_Sim.timeweekday     = myweekday(Time_Sim.StartDate.(Input_Data.Headers)(1) + Time_Sim.myiter/Time_Sim.stp);
%%%
% The number of weeks elapsed since the beginning of the simulation is
% calculated and is used for statistical purposes. A week is inceremented
% everytime it comes back to Monday.
if Time_Sim.timeweekday - myweekday(Time_Sim.StartDate.(Input_Data.Headers)(1) + (Time_Sim.myiter - 1)/Time_Sim.stp) < 0
   Time_Sim.wknbrCNT.(Input_Data.Headers)(1)    = Time_Sim.N_occurence.(Input_Data.Headers)(1) + 1;
   Time_Sim.N_occurence.(Input_Data.Headers)(1) = Time_Sim.N_occurence.(Input_Data.Headers)(1) + 1;
   Time_Sim.currentweek.(Input_Data.Headers)(1) = Time_Sim.wknbrCNT.(Input_Data.Headers)(1)       ;
else
   Time_Sim.wknbrCNT.(Input_Data.Headers)(1)    = Time_Sim.currentweek.(Input_Data.Headers)(1)    ;
end
Time_Sim.timeweeknbr                 = Time_Sim.wknbrCNT.(Input_Data.Headers)(1)       ;
%%%
% Similarly, the number of days elapsed since the beginning of the simulation is
% calculated and is used for statistical purposes. A day is inceremented
% everytime the clock passes midnight.
if ((minute(Time_Sim.StartDate.(Input_Data.Headers)( 1) + Time_Sim.myiter/24) / 60) + hour(Time_Sim.StartDate.(Input_Data.Headers)(1) + Time_Sim.myiter/Time_Sim.stp)) - ((minute(Time_Sim.StartDate.(Input_Data.Headers)(1) ...
  + (Time_Sim.myiter - 1)/Time_Sim.stp) / 60) + hour(Time_Sim.StartDate.(Input_Data.Headers)(1) + (Time_Sim.myiter - 1)/Time_Sim.stp)) < 0
   Time_Sim.daynbrCNT.(Input_Data.Headers)(1)       = Time_Sim.N1_occurence.(Input_Data.Headers)(1) + 1 ;
   Time_Sim.N1_occurence.(Input_Data.Headers)(1)    = Time_Sim.N1_occurence.(Input_Data.Headers)(1) + 1 ;
   Time_Sim.currentday.(Input_Data.Headers)(1)      = Time_Sim.daynbrCNT.(Input_Data.Headers)(1)        ;
else
   Time_Sim.daynbrCNT.(Input_Data.Headers)(1)       = Time_Sim.currentday.(Input_Data.Headers)(1)       ;
end
Time_Sim.timedaynbr                      = Time_Sim.daynbrCNT.(Input_Data.Headers)(1)       ;
%% Energy Systems
%%%
% This section of the module is successively calling different function
% from the energy production systems, to the scenario, pricing and
% controller. Each function are detailed in their section later in this
% paper.
%%% 
%% Activate the PV-Panel function
[EnergyOutput.PVPower.(Input_Data.Headers)(Time_Sim.myiter+1), EnergyOutput.SolarLuminance.(Input_Data.Headers)(Time_Sim.myiter+1),EnergyOutput.SolarLuminancev.(Input_Data.Headers)(Time_Sim.myiter+1),Time_Sim]...
    = SolRad(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails);
Time_Sim.Iteration.(Input_Data.Headers)(1) = 1;  
%% Activate the Wind Turbine function 
if str2double(Input_Data.WindTurbine) == 1
    [EnergyOutput.WTPower.(Input_Data.Headers)(Time_Sim.myiter+1)] = WindTurbinefunc(Time_Sim, Input_Data, All_Var, BuildSim);
    Time_Sim.Iteration2.(Input_Data.Headers)(1) = 1;
else
    EnergyOutput.WTPower.(Input_Data.Headers)(Time_Sim.myiter+1) = 0;
end 
%% Activate the Electricity Contract 
[EnergyOutput.Season.(Input_Data.Headers)(Time_Sim.myiter+1),EnergyOutput.Price,EnergyOutput.Price_Foreca]= Elec_Contract(Time_Sim, Input_Data, All_Var, BuildSim);
Time_Sim.Iteration3.(Input_Data.Headers)(1) = 1; 
%% Activate the Electrolyser and FC
if str2double(Input_Data.FuelCell) == 1
    [EnergyOutput.ElecPower.(Input_Data.Headers)(Time_Sim.myiter+1),EnergyOutput.FCPower.(Input_Data.Headers)(Time_Sim.myiter+1)] = Electroylzer(Time_Sim.timehour, Time_Sim.myiter);
    Time_Sim.Iteration4.(Input_Data.Headers)(1) = 1;
else
    EnergyOutput.FCPower.(Input_Data.Headers)(Time_Sim.myiter+1) = 0;
end 
%% Create the scenarios for the appliances

AppFields = fieldnames(App);

if any(strcmp(AppFields,'AppStatus')) % Jari's Addition

	EnergyOutput.Cons_Appli_Overall.(Input_Data.Headers)(Time_Sim.myiter + 1) 	= App.Cons_Tot.(Input_Data.Headers);
	EnergyOutput.Occupancy.(Input_Data.Headers)(Time_Sim.myiter + 1) 			= App.Occupancy.(Input_Data.Headers);

else

	[EnergyOutput.Cons_Appli_Overall.(Input_Data.Headers)(Time_Sim.myiter + 1), ...
	EnergyOutput.Occupancy.(Input_Data.Headers)(Time_Sim.myiter + 1),...   
	App] = ...
        Scenario(Time_Sim,Nbr_Building,Input_Data,BuildSim,All_Var,SimDetails,...
                 EnergyOutput.SolarLuminancev.(Input_Data.Headers), HouseTitle,App);
				 
end

                                                                                                                                                       
                                                                                                                                                       
Time_Sim.Iteration5.(Input_Data.Headers)(1) = 1;
%% Sustainability Dynamic Index calculation

%  [SDI.SDI,SDI.Emissions_Dwel.(Input_Data.Headers)(:, Time_Sim.myiter + 1),SDI.IndexEmissions] = Sus_Dynamic_Index(Time_Sim,Nbr_Building,All_Var,EnergyOuput.Price, ...
%                                                                                                       EnergyOuput.Cons_Appli_Overall.(Input_Data.Headers)(Time_Sim.myiter + 1),SDI,Input_Data{BuildSim,1} );
if Time_Sim.myiter == 500
    vdwvde=1;
end
%% Thermal  Calculation for the Houses
% [EnergyOutput.Thermal_Demand.(Input_Data.Headers)(Time_Sim.myiter + 1)] = Thermal_House(Input_Data, Time_Sim,BuildSim,All_Var);
%% TO BE MODIFIED BY JARI TO ACCEPT THE NEW ARRAY
 [EnergyOutput.Thermal_Model.(Input_Data.Headers), Input_Data]    = Thermal_House2(Input_Data, Time_Sim, All_Var, EnergyOutput.Thermal_Model.(Input_Data.Headers), ...
                                                                                   HouseTitle, BuildSim, SimDetails, App,...
                                                                                   EnergyOutput.PVPower.(Input_Data.Headers)(Time_Sim.myiter+1),...
                                                                                   EnergyOutput.Cons_Appli_Overall.(Input_Data.Headers)(Time_Sim.myiter + 1),...
                                                                                   EnergyOutput.Occupancy.(Input_Data.Headers)(Time_Sim.myiter + 1)); 

%% Water withdrawal profiles
    All_Var.water_profile.(Input_Data.Headers).start = 0 ;
    [All_Var.water_profile.(Input_Data.Headers), All_Var.prob.(Input_Data.Headers)] = waterWD(All_Var.prob.(Input_Data.Headers), Time_Sim.myiter + 1, Time_Sim, All_Var.water_profile.(Input_Data.Headers), EnergyOutput.Occupancy.(Input_Data.Headers)(Time_Sim.myiter + 1)) ;                                                                               
                                                                               %%
% %% Heat production
% 
%     [Power] = Heat_Pump(HP_Power, iter7, Temp_out, Thermal_Demand);
% 
% iter7(Housenbr, 1) = 1;
%%% 
% Input the data and send to the controller
%[Time_Sim.Delay_time.(Input_Data.Headers)(1), Time_Sim.hour_1_delay.(Input_Data.Headers)(1), Time_Sim.Reduce_time.(Input_Data.Headers)(1),Cont2] = Controller(Time_Sim,Input_Data,BuildSim,EnergyOuput,Cont,All_Var);

AppFields = fieldnames(App);

if ~any(strcmp(AppFields,'AppStatus')) 	% Jari's addition

	[Time_Sim.Delay_time.(Input_Data.Headers)(1), Time_Sim.hour_1_delay.(Input_Data.Headers)(1), Time_Sim.Reduce_time.(Input_Data.Headers)(1),Cont2] = ControllerStr(Time_Sim,Input_Data,BuildSim,EnergyOutput,Cont,All_Var);
	Cont = Cont2 ;
	
end

Time_Sim.Iteration6 = 1;
Time_Sim.Reduce_Time2(Time_Sim.myiter + 1) = Time_Sim.Reduce_time.(Input_Data.Headers)(1);
% if myiter > 480 && timehour == 0
%     [RowForeca(:,size(RowForeca,2)+1)] = Test_Forecast(myiter, Cons_Appli_Overall, timehour);
% end
% if Time_Sim.myiter == Time_Sim.nbrstep
%     save('EnergyOuput.mat','EnergyOuput');
% end

%% Output Variables
% Declare Cons_Appli_Overall
Cons_Tot        = EnergyOutput.Cons_Appli_Overall.(Input_Data.Headers)(Time_Sim.myiter + 1)                                                                                             ;
Occ             = EnergyOutput.Occupancy.(Input_Data.Headers)(Time_Sim.myiter + 1)                                                                                                      ;
Money           = EnergyOutput.Price * ((EnergyOutput.Cons_Appli_Overall.(Input_Data.Headers)(Time_Sim.myiter + 1) * ((Time_Sim.MinperIter * 60)/3600)) + (EnergyOutput.Thermal_Model.(Input_Data.Headers).Total_Electricity_Consumption(Time_Sim.myiter + 1)/1000));
SavedMoney      = EnergyOutput.Price * (EnergyOutput.Thermal_Model.(Input_Data.Headers).PhotoVoltaic_Elec_Heat(Time_Sim.myiter+1))/1000;        % Jari's addition for the money saved from the electricity consumption from the PV panels in heating.
EnergyOutput.Thermal_Model.(Input_Data.Headers).SavedMoney(Time_Sim.myiter+1) = SavedMoney;         % Jari's addition!
Emissions       = All_Var.Hourly_Emissions((Time_Sim.StartDate.(Input_Data.Headers)-datenum(Time_Sim.YearStartSim2004,1,1))*24+Time_Sim.myiter+1,:) * EnergyOutput.Thermal_Model.(Input_Data.Headers).Total_Electricity_Consumption(Time_Sim.myiter+1)/1000;    % JARI'S ADDITION
EnergyOutput.Thermal_Model.(Input_Data.Headers).Emissions(Time_Sim.myiter+1,:) = Emissions;       % JARI'S ADDITION
%%% Power production from the building 
Power_prod      = EnergyOutput.FCPower.(Input_Data.Headers)(Time_Sim.myiter+1) + EnergyOutput.PVPower.(Input_Data.Headers)(Time_Sim.myiter+1) + EnergyOutput.WTPower.(Input_Data.Headers)(Time_Sim.myiter +1)   ;
varargout{1}    = Input_Data                                                                                                                                                ;
varargout{2}    = All_Var                                                                                                                                                   ; 
varargout{3}    = Time_Sim                                                                                                                                                  ;    
varargout{4}    = SimDetails                                                                                                                                                ;
varargout{5}    = Cont                                                                                                                                                      ;
varargout{6}    = App                                                                                                                                                       ;
varargout{7}    = EnergyOutput                                                                                                                                               ;
varargout{8}    = SDI                                                                                                                                                       ;
