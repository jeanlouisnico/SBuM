%% Wind Turbine
% The wind turbine model is a simplified model taken from the matlab
% repository. The original work comes from
% <http://www.mathworks.se/help/physmod/sps/powersys/ref/windturbine.html
% Mathworks>. Wind speed data comes from the climatic database for Oulu
% region from 2000 to 2013 for every half an hour. The input data for
% enhancing the model of the wind turbine requires a set of technological
% specifications. The only mandatory variable is the rated power of the
% wind turbine _*WTPowertot*_. The other variables can be set from the
% Excel Spreadsheet _*Variables and matrix.xlsm*_ or be let as default
% value. _*myiter*_ variable pass through the simulation the number of step
% . _*Time_Step*_ is a variable that inform on the time step chosend for
% the simulation (hourlt or half-hourly).
%% 
function [PowerWS] = WindTurbinefunc(varargin)
global Wind_Speed
Input_Data = varargin{2};
Time_Sim = varargin{1};
All_Var = varargin{3};
WindSpeed = str2double(Input_Data.WindSpeed) ;
Lambdanom = str2double(Input_Data.Lambdanom) ;
Cp = str2double(Input_Data.Cp) ;
Baserotspeed = str2double(Input_Data.Baserotspeed) ;
Pitch = str2double(Input_Data.Pitch) ;
EfficiencyWT = str2double(Input_Data.EfficiencyWT) ;
WTPowertot = str2double(Input_Data.WTPowertot) ;
% WindSpeed
%if Input_Data{20}<= 0; Input_Data{20}= 9   ; WindSpeed = Input_Data{20}; end
% Lambdanom
%if Input_Data{21}<= 0; Input_Data{21}= 8.1   ; Lambdanom = Input_Data{21}; end
% Cp
%if Input_Data{22}<= 0; Input_Data{22}= 0.48   ; Cp = Input_Data{22}; end
% MaxPowerWT
% if Input_Data{23}<= 0; Input_Data{23}= 0.73   ; MaxPowerWT = Input_Data{23}; end
% Baserotspeed
%if Input_Data{24}<= 0; Input_Data{24}= 1.2   ; Baserotspeed = Input_Data{24}; end
% Pitch
%if Input_Data{25}<= 0; Input_Data{25}= 4   ; Pitch = Input_Data{25}; end
% EfficiencyWT
%if Input_Data{26}<= 0; Input_Data{26}= 0.68   ; EfficiencyWT = Input_Data{26}; end
% WTPowertot = [Input_Data{19}];
Time_Step = Input_Data.Time_Step ;
    switch(Time_Step)
        case 'Hourly'
            Wind_Speed = All_Var.Hourly_Wind_Speed';
        case 'Half Hourly'
            Wind_Speed = All_Var.Half_Hourly_Wind_Speed';
    end    
myiter = Time_Sim.myiter;
%% Climatic data
% Climatic data are loaded once in the simulation and then is stored in the
% memory of MatLab. Only one array is stored depending on the time step
% chosen for the simulation.

%% Characterisitcs
% The following italic text is a copy/paste from the <http://www.mathworks.se/help/physmod/sps/powersys/ref/windturbine.html
% Mathworks> website as all the equations come from there.
%%%
% _The model is based on the steady-state power characteristics of the 
% turbine. The stiffness of the drive train is infinite and the friction 
% factor and the inertia of the turbine must be combined with those of the 
% generator coupled to the turbine. The output power of the turbine is given 
% by the following equation._
%%%
% $$P_{m}=C_{perf}(\lambda ,\beta )\frac{\rho_{air} A}{2}v^{3}_{wind}$$
%%% Italic
% Where _Pm_ is the mechanical output power of the turbine [W], _Cperf_ is
% the performance coefficient of the turbine, _Rhoair_ is the air density
% [kg/m3], _A_ is the swept area [m2], _vwind_ is the wind speed [m/s],
% _Lambda_ is the tip speed ration of the roto blade tip sped to wind
% speed, and _Beta_ is the blade pitch angle [o].
%%%
% In the model, the wind speed per unit can be expressed tfrom the wind
% speed base.
%%%
% $$P_{m-pu}=k_{perf}\cdot C_{perf-pu}\cdot v^{3}_{wind-pu}$$
%%%
% _Where Pm-pu is the power in "per unit" of the nominal power for
% paritcular values of the air density and swept area, Cp-pu is the 
% performance coefficient in "per uni" of the maximum value of Cp, vwind-pu
% is the wind speed in pu of the base wind speed. The base wind speed is 
% the mean value of the expected wind speed [m/s], and kp is Power gain 
% for Cp_pu = 1 pu and vwind_pu = 1 pu, kp is less than or equal to 1._
%%%
% vwind-pu can be expressed as:
%%%
% $$v_{wind-pu}=\frac{v_{wind}}{v_{pu}}$$
%%%
% _Where vpu is the base wind speed *WindSpeed* [m/s]_
if WindSpeed == 0
    Wind_speed_base = 0;
else
    Wind_speed_base = Wind_Speed(myiter+1) / WindSpeed ;
end
%%% Base rotational speed
% _The rotational speed at maximum power for the base wind speed. The base
% rotational speed is in "per unit" of the base generator speed. For a synchronous 
% or asynchronous generator, the base speed is the synchronous speed. For 
% a permanent-magnet generator, the base speed is defined as the speed 
% producing nominal voltage at no load._
%%%
% $$\omega_{pu}=\frac{1.1}{\omega_{base}}$$
%%%
% Where omega_{pu} is the rotational speed and \omega_{base} is the base
% rotational speed, given as an input to the model
Wind_Nominal_speed = 1.1 / Baserotspeed;
%%% Tip speed ratio
% _The tip speed ratio Lambda in pu of Lambda_nom is obtained by the division of the
% rational speed in pu of the base rotational speed (defined below) and the 
% wind speed in pu of the base wind speed. The output is the torque applied 
% to the generator shaft._
%%%
% $$\lambda =\lambda_{pu}\lambda_{nom}$$
%%%
% Where Lambda is the tip speed ratio, Lambdanom is the nominal tip speed
% ratio given as an input to the model, and Lambdapu is the tip speed
% ration per unit expressed as follow:
%%%
% $$\lambda_{pu}=\frac{\omega_{pu}}{v_{wind-pu}}$$
if Wind_speed_base == 0
    Lambda_pu = 0;
else
    Lambda_pu = Wind_Nominal_speed / Wind_speed_base;
end
Lambda = Lambda_pu * Lambdanom;
%%%
% Consequently, for a particular pitch angle _beta_, the tip speed ratio
% can be formulated as:
%%%
% $$\lambda_{i}=\frac{1}{\frac{1}{\lambda +0.08\beta
% }-\frac{0.035}{\beta^3+1}}$$
%%%
% Where _Beta_ is the pitch angle [o]
Lambda_i = 1/(1/(Lambda + 0.08 * Pitch) - 0.035 / (Pitch^3 + 1));
%%% Coefficient of performance
% The coefficient of performance Cperf per unit is obtained by:
%%%
% $$C_{perf-pu}=\frac{C_{perf}(\lambda ,\beta )}{C_{perf-nom}}$$
%%%
% Where the coefficient of performance for a given tip speed ratio and
% pitch angle is expressed as:
%%%
% $$C_{perf}(\lambda ,\beta )=0.5176\left ( \frac{116}{\lambda _{i}}-0.4\beta
% -5 \right )e^{-\frac{21}{\lambda _{i}}}+0.0068 \lambda$$
Cpnom = 0.5176 * (116 / Lambda_i - 0.40 * Pitch - 5) * exp(-21 / Lambda_i) + 0.0068 * Lambda;
Cperf_pu = Cpnom / Cp;
%% Power Output
%%%
% Finally, the power output from the wind turbine can be calculated as the
% product of the coefficient of performace per unit, the wind speed per
% unit, the rated power of the installed wind turbine that is given as an
% input entry in the model and the theoretical efficiency
%%%
% $$P_{m-pu} = C_{perf-pu} \cdot v_{wind-pu}^3 \cdot P_{WT} \cdot
% \eta_{WT}$$
Pm_pu = Cperf_pu * Wind_speed_base^3 * WTPowertot * EfficiencyWT;
if Pm_pu >= 0
    PowerWS = Pm_pu;
else
    PowerWS = 0;
end
%%% Power profile
% A power output profile from the equations above (... to ...) is drawn
% below.
%%%
% 
% <<Wind Turbine Checking complement.PNG>>
%