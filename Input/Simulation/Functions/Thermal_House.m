%% Detached house thermal demand
% This section details the calculation of the thermal femand for a detached
% house. The model is over simplified as there was no need for heavy thermal
% model. The model investigate the conduction and convection losses through
% different surface areas such as the windows, walls, door, floor, and
% roof. Furthermore, a natural ventilation is considered with its
% associated heat losses. Although this is far from being the technology
% employed, it has been the easiest way to work around the thermal losses
% so far. A lot of improvement are expected to come on this particular
% model. The thermal model has not been of use too much so far as mostly
% the electricity part has been considered. No standard values are used in
% the model, thus it is mandatory to give the values to the different
% variables from the Excel Spreadsheet _Variables and matrix.xlsm_.
%%%
% The variables to be intergated consider the external dimensions of the detached
% house such as the height _*hgt*_, the length of the wall on the South
% side _*lgts*_, on the Eastern side _*lgte*_. The U-Value of the walls are given for each side _*uve*_, _*uvw*_, _*uvs*_, and _*uvn*_. As the detached house is
% considered to be very basic, a cube-like building is used. Further, the
% surface area of windows are given for each wll surface on the North side
% _*awn*_, south side _*aws*_, Western side _*aww*_, and Eastern side
% _*awe*_. The windows asociated U-Value are given also as an input _*uvsw*_
% for the Southern windows, _*uvew*_, _*uvww*_, and _*uvnw*_ for the
% Southern, Eastern, Western, and Northern surfaces respectively. On top of
% it, the door surface _*ad*_ is to be given with its associated U-Value
% _*uvd*_, the floor U-Value _*uvf*_, and the roof U-Value _*uvr*_. In
% order to calculate the heat losses through natural ventilation, the
% number of air change is to be given (usual equal to 1.5 times house
% volume per hour).
%%
% The external temperature profile is given as a global variable, thus the
% variable has already been uploaded into the MatLab memory.
function [Thermal_Power] = Thermal_House(varargin)

Input_Data = varargin{1};
Time_Sim = varargin{2};
% BuildSim = varargin{3};
All_Var = varargin{4};
hgt = str2double(Input_Data.hgt) ;
lgts = str2double(Input_Data.lgts) ;
lgte = str2double(Input_Data.lgte) ;
pitch = str2double(Input_Data.Pitch) ;
aws = str2double(Input_Data.aws) ;
awe = str2double(Input_Data.awe) ;
awn = str2double(Input_Data.awn) ;
aww = str2double(Input_Data.aww) ;
ad = str2double(Input_Data.ad) ;
uvs = str2double(Input_Data.uvs) ;
uve = str2double(Input_Data.uve) ;
uvn = str2double(Input_Data.uvn) ;
uvw = str2double(Input_Data.uvw) ;
uvsw = str2double(Input_Data.uvsw) ;
uvew = str2double(Input_Data.uvew) ;
uvnw = str2double(Input_Data.uvnw) ;
uvww = str2double(Input_Data.uvww) ;
uvd = str2double(Input_Data.uvd) ;
uvf = str2double(Input_Data.uvf) ;
uvr = str2double(Input_Data.uvr) ;
N0 = str2double(Input_Data.N0) ;
timehour = Time_Sim.timehour;
myiter = Time_Sim.myiter;
Time_Step = Input_Data.Time_Step;

    switch(Time_Step)
        case 'Hourly'
            Temperature = All_Var.Hourly_Temperature';
        case 'Half Hourly'
            Temperature = All_Var.Half_Hourly_Temperature';
    end
%% Thermal losses
%%% Walls
% For calculating the losses through the walls, a general formula is used
% Eq.... The entrance door is placed on the south wall, consequently, the
% door surface is set to 0 for the other surfaces.
%%%
% $$Q_{wall}=UV_{surf}((h\cdot L_{surf})-A_{door}-A_{window-surf})$$
%%%
% Where QSurf is the heat loss through the wall [W/K], UV_{surf} is the
% U-Value of the studied surface [W/m2.K-1], h is the height of the wall
% [m], Lsurf is the lenght of the wall [m], Adoor is the surface area of
% the door [m2], Awindow-surf is total the surface area of windows on the
% studied surface [m2].
Wall_Loss = @(Length, height, door, window, UVwall) UVwall.*((height.*Length)-door-window); 
Specific_Loss_North = Wall_Loss(lgts, hgt, 0, awn, uvn);
Specific_Loss_South = Wall_Loss(lgts, hgt, ad, aws, uvs);
Specific_Loss_West  = Wall_Loss(lgte, hgt, 0, awe, uvw);
Specific_Loss_East  = Wall_Loss(lgte, hgt, 0, aww, uve);
%%% Windows and door
% The calculation of the heat loss through the window is pretty straight 
% forward as it is the product of the total surface area of the window on a
% particular surface times the U-Value of the windows. It is assumed that
% the U-Value for a given surface is similar to all windows.
%%%
% $$Q_{surface}=UV_{window}\, \cdot \, A_{window}$$
%%%
% Where Qwindow is the heat loss through the window [W/K], UVwindow is the
% U-Value of the windoes on the studied surface [W/m2.K-1], and Awindow is
% the total surface area of window on w given surface [m2].
Surface_Loss = @(UV, A) UV.*A;
Loss_Wind_South = Surface_Loss(uvsw, aws);
Loss_Wind_North = Surface_Loss(uvnw, awn);
Loss_Wind_West  = Surface_Loss(uvww, aww);
Loss_Wind_East  = Surface_Loss(uvew, awe);
Loss_Door       = Surface_Loss(uvd, ad)  ;
%%% Losses through the floor and roof
% As the floor area is not given as an input, it has to be calculated from
% the lenghts of the walls on the different surface. Afterwards, the heat
% loss through the floor is calculated using Eq...
% . The heat loss through the roof is calculated also with Eq... but the
% surface area of the roof needs to be evaluated first using Eq...
%%%
% $$A_{roof}=\frac{L_{East} \cdot L_{South}}{cos\left (\frac{2\pi \beta
% }{360}  \right )}$$
%%%
% Where Aroof is the roof surface are [m2], Least is the lenght of the
% Eastern wall [m], Lsouth is the lenght of the Southern wall [m], and beta is
% the pitch angle of the roof [o].
A_Roof      = ((lgte * lgts)/cos(pitch * 2 * pi() / 360))   ;
Loss_floor  = (lgte * lgts) * uvf                           ;
Loss_roof   = Surface_Loss(uvr, A_Roof)                     ;
%%% Ventilation losses
% The heat loss through natural ventilation consider the number of air
% change per hour. Thus, the general formula is given in Eq.
%%%
% $$Q_{Ventil} = N_{0} V_{House} \rho_{air} \frac{C_{p-air}}{3.6}$$
%%%
% Where Qventil is the heat loss through natural ventilation [W/K], Vhouse
% is the total volume of the house and is evaluated from Eq... [m3], Rhoair
% is the air density [kg/m3], and Cpair is the heat capacity of air
% [kJ/kg.K-1] usually taken at 1.007.
%%%
% $$V_{house}=h\cdot L_{South}L_{East} + \left ( tan\left ( \frac{2\pi
% \beta}{360} \right )\cdot \left ( \frac{L_{East}}{2} \right )^2 \cdot
% L_{South} \right )$$
% Heat recovery of the system is 0%
HRecovery = 0;
House_Volume = hgt*lgts*lgte + (tan(pitch * 2 * pi() / 360) * (lgte/2)^2 * lgts);
Loss_Ventil = (N0 * House_Volume * 1.2 * 1.007/3.6) * (1-HRecovery);
%%% Heat load
% The total heat load of the house is calculated as the summ of the
% different heat loss on surfaces, walls and ventilation.
%%%
% $$Q_{total} = \sum Q_{wall} + \sum Q_{surface} + Q_{Ventil}$$
%%%
% Where Qtotal is the total heat loss [W/K].
Total_Loss = Specific_Loss_East + Specific_Loss_North + Specific_Loss_South + Specific_Loss_West + Loss_Wind_East + Loss_Wind_North + Loss_Wind_South + Loss_Wind_West + Loss_Door + Loss_floor + Loss_roof + Loss_Ventil;
%%% Temperature setpoint
% fixed temperature setpoint are defined for two time zone during the day:
% from 18h to 10h, the indoor temperature is set 21oC, and from 10h to 18h,
% the indoor temperature is set to 19oC.
%%%
% Work to do: 
% Temperature setting in the building
% --> look the possibility to couple the set temperature with the occupancy
% Loop the room temperature with the activity in the home, depending on how
% many people are living the house
if or(timehour >= 18, timehour < 10)
    Temp_Set = 21;
else
    Temp_Set = 19;
end
%%% Total losses
% Total heat losses in kW
%%%
% $$Q_{house}=max(0, Q_{total}(T_{in}-T_{out}))$$
%%%
% Where Qhouse is the heat demand [W], Tin is the indoor temperatur [C] and tout is the outdoor
% temperature [C]
Thermal_Power = max(0, Total_Loss * (Temp_Set - Temperature(myiter + 1)));