function [Solar_Heat_Gain, F_permeability] = Sol_rad_windows1(Input_Data, Time_Sim, All_Var, Housenbr, Temp_inside, varargin)
% The function is used to calculate the radiation towards the windows
%   Detailed explanation goes here
% load Test_Values_2132018_2.mat
% The input values are presented here
%Input_Data = varargin{1};
%Time_Sim = varargin{2};
%All_Var = varargin{3};
%Housenbr = varargin{4};
Global_Irradiance_North     = varargin{1}; 
Global_Irradiance_East      = varargin{2};
Global_Irradiance_South     = varargin{3};
Global_Irradiance_West      = varargin{4};
tenancy                     = varargin{5};
F_permeability              = varargin{6};
gwindow                     = varargin{7};
Temperature                 = varargin{8};

Temp_cooling                = str2double(Input_Data.Temp_cooling);

myiter = Time_Sim.myiter;

% Temperature = All_Var.Hourly_Temperature;
% Wind_Direction = All_Var.Hourly_Wind_Direction;
% Wind_Speed = All_Var.Hourly_Wind_Speed;

% Convective_transfer_coeff = 1/0.13;     % Inside resistance

% if Wind_Speed(m) <= 8
%     Convective_transfer_coeff = ((3 * (5 + 4.5 * Wind_Speed(m)) - 0.14 * Wind_Speed(m)^2) + 5 * 1.5 * Wind_Speed(m)) / 4; % One side is considered to be leeward and three on the windward
% elseif Wind_Speed(m) > 8 && Wind_Speed(m) <= 10
%     Convective_transfer_coeff = ((3 * (5 + 4.5 * Wind_Speed(m)) - 0.14 * Wind_Speed(m)^2) + 7.41 * Wind_Speed(m)^0.78) / 4; % One side is considered to be leeward, and for that the common equation is being used as the speed is higher than for other equation and three on the windward
% else
%     Convective_transfer_coeff = 7.41 * Wind_Speed(m)^0.78; % Only common equation can be used!
% end

% Total_Thermal_Coefficient = 61.4321; % Calculated by hand before, CHANGE! (Total_Loss)
% Radiative_Coefficient = Total_Thermal_Coefficient - Convective_transfer_coeff;
% Tr = 1.1 * Temperature(m) - 5;      % Clear-sky and vertical surface!
% SimDetails = 1;
%Solar_Radiation = All_Var.Hourly_Solar_Radiation;
%Latitude = [Input_Data{11}];
%Longitude = [Input_Data{12}];
hgt     = str2double(Input_Data.hgt); %.(Input_Data.Headers)); % [Input_Data{90}];
lgts    = str2double(Input_Data.lgts); % .(Input_Data.Headers)); % [Input_Data{91}];
lgte    = str2double(Input_Data.lgte); %.(Input_Data.Headers)); % [Input_Data{92}];
pitch   = str2double(Input_Data.pitchangle); %.(Input_Data.Headers)); % [Input_Data{93}];
aws     = str2double(Input_Data.aws); %.(Input_Data.Headers)); % [Input_Data{94}];
awe     = str2double(Input_Data.awe); %.(Input_Data.Headers)); % [Input_Data{95}];
awn     = str2double(Input_Data.awn); %.(Input_Data.Headers)); % [Input_Data{96}];
aww     = str2double(Input_Data.aww); %.(Input_Data.Headers)); % [Input_Data{97}];

A_wall_north        = hgt * lgts - awn;
A_wall_east         = hgt * lgte + 0.5 * tand(pitch) * lgte^2 - awe;
A_wall_south        = hgt * lgts - aws;
A_wall_west         = hgt * lgte + 0.5 * tand(pitch) * lgte^2 - aww; 
A_roof              = 2 * (lgte/2) * lgts / cosd(pitch);
% StartDate = datetime([Input_Data{7}],[Input_Data{6}],[Input_Data{5}]);
% EndDate = datetime([Input_Data{10}],[Input_Data{9}],[Input_Data{8}]);
% Day_Number = linspace(1, daysact(StartDate, EndDate), daysact(StartDate, EndDate));
% Simulation_Time = datetime(StartDate): hours(1): datetime(EndDate);
% Simulation_Time = Simulation_Time(1:end-1);
% if Day_Number > 366
%     Years = floor(Day_Number(1,end)/366);
%     Over_days = Day_Number(1,end) - Years * 366;
%     Day_Number = [repmat(Day_Number(1,1:366), Years), linspace(1,Over_days, Over_days)];
% else
%     Day_Number = Day_Number;
% end
% Make the Day_Number match in elements to hourly values
%Day_Number = repelem(Day_Number, 24);
% Day_hour = hour(Simulation_Time);
%%%
% The actual calculations start here
% Firstly calculate the eccentricity correction factor
% Epsilon0 = 1 + 0.033 * cosd((360*Day_Number)/365);
% Epsilon0 = repelem(Epsilon0, 24);
% Solar Declination is
% Solar_Declination = 23.45 * sind((360*(Day_Number + 284))/365);
% Solar_Declination = repelem(Solar_Declination, 24);
% Then Calculate the actual solar time with and without day-light saving
% time in Finland
% HOX!!! Matrix issue likely!!!
% Daylightsave = isdst(Simulation_Time);
% [~,simulationhours] = size(Simulation_Time);
% Solar_Time = zeros(1,simulationhours);
% for n = 1:simulationhours
%     if Daylightsave(n) == 0
%         Solar_Time(n) = 15 * (Day_hour(n) - 2 - 12) - (Longitude - 2 * 15);
%     else
%         Solar_Time(n) = 15 * (Day_hour(n) - 3 - 12) - (Longitude - 3 * 15);
%     end
% end
% Calculate the cosine of the solar zenith angle
% Cos_Solar_Zenith = (sind(Solar_Declination)*sind(Latitude) + cosd(Solar_Declination)*cosd(Latitude).*cosd(Solar_Time));
% Solar_Zenith = acosd(Cos_Solar_Zenith);
%%%
% Validate the solar zenith angles as the radiation does not hit the
% vertical surface if the angle is higher than 90 degrees or smaller than 0
% for n = 1:simulationhours
%     if Solar_Zenith(n) > 90 || Solar_Zenith(n) < 0
%         Solar_Zenith(n) = 90;
%     else
%         Solar_Zenith(n) = Solar_Zenith(n);
%     end
% end
% Calculate the sunrise angle
% sun_rise_ang = ( - acosd(- tand(Solar_Declination)*tand(Latitude)));
% Next the extraterrestrial radiation on horizontal south-facing surface
% B0 = 1367;
% B0_horizontalsouth = B0 * Epsilon0 .* cosd(Solar_Zenith);
% for n = 1:simulationhours
%     if B0_horizontalsouth(n) <= 0
%         B0_horizontalsouth(n) = 0;
%     else
%         B0_horizontalsouth(n) = B0_horizontalsouth(n);
%     end
% end
% Extraterrestrial radiation over a day on horizontal south-facing surface
% B0_horizontalsouth_day_extended = ((24/pi()) * B0 * Epsilon0 .* ((- (pi() / 180) * sun_rise_ang) .* sind(Solar_Declination) * sind(Latitude) - cosd(Solar_Declination)*cosd(Latitude).*sind(sun_rise_ang)));
% B0_horizontalsouth_day = B0_horizontalsouth_day_extended(1:24:end);
% In order to the gather the right solar radiation data, the
% solar_radiation variable needs to be re-assessed to match the timeframe.
% DataBase_Start = datetime(2000,1,1);
% HoursToStartSimulation = datetime(DataBase_Start) : hours(1): datetime(StartDate);
% [~, StartingHour] = size(HoursToStartSimulation);
% [~, SimulationHours] = size(Day_hour);
% Solar_Radiation = Solar_Radiation(StartingHour:(StartingHour + SimulationHours -1));
% Global_horizontalsouth_day = zeros(1,daysact(StartDate,EndDate));
% for n = 1:daysact(StartDate,EndDate)
%     Global_horizontalsouth_day(n) = sum(Solar_Radiation((n-1)*24+1 : n*24));
% end
% Clearness index over a day is
% Ktd = Global_horizontalsouth_day./B0_horizontalsouth_day;
% Calculation for the diffuse fraction of horizontal radiation
% [~, KtdSize] = size(Ktd);
% FDd = zeros(1,KtdSize);
% for n = 1:KtdSize
%     if Ktd(n) <= 0.17
%         FDd(n) = 0.99;
%     else
%         FDd(n) = 1.188 - 2.272 * Ktd(n) + 9.473 * (Ktd(n)^2) - 21.856 * (Ktd(n)^3) + 14.648 * (Ktd(n)^4);
%     end
% end
% Diffuse radiation on horizontal south-facing surface
% Diffuse_horizontalsouth_day = FDd .* Global_horizontalsouth_day;
% Then the ratio rD, and the diffuse radiation on horizontal south-facing
% surface is
% Diffuse_horizontalsouth_day_extended = repelem(Diffuse_horizontalsouth_day, 24);
% Diffuse_horizontalsouth = ((B0_horizontalsouth./B0_horizontalsouth_day_extended).*Diffuse_horizontalsouth_day_extended);
%%% Let's then check the validity of data, as diffuse radiation cannot
%%% exceed the global radiation
% for n = 1:simulationhours
%     if Diffuse_horizontalsouth(n) > Solar_Radiation(n)
%         Diffuse_horizontalsouth(n) = Solar_Radiation(n);
%     else
%         Diffuse_horizontalsouth(n) = Diffuse_horizontalsouth(n);
%     end
% end
% The Direct radiation is global-diffuse
% B0_horizontal = Solar_Radiation' - Diffuse_horizontalsouth;
% Next the sun rays' incident angle, E =-90 , N = 180, W =90 , S = 0 
% Check the East and West degrees!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Cos_Sun_Incident_ang_E = sind(Solar_Declination)*sind(Latitude)*cosd(90)-1*sind(Solar_Declination)*cosd(Latitude)*sind(90)*cosd(-90) + ...
%     cosd(Solar_Declination)*cosd(Latitude)*cosd(90).*cosd(Solar_Time)+1*cosd(Solar_Declination)*sind(Latitude)*sind(90)*cosd(-90).*cosd(Solar_Time) + ...
%     cosd(Solar_Declination)*sind(-90).*sind(Solar_Time)*sind(90);
% Cos_Sun_Incident_ang_N = sind(Solar_Declination)*sind(Latitude)*cosd(90)-1*sind(Solar_Declination)*cosd(Latitude)*sind(90)*cosd(180) + ...
%     cosd(Solar_Declination)*cosd(Latitude)*cosd(90).*cosd(Solar_Time)+1*cosd(Solar_Declination)*sind(Latitude)*sind(90)*cosd(180).*cosd(Solar_Time) + ...
%     cosd(Solar_Declination)*sind(180).*sind(Solar_Time)*sind(90);
% Cos_Sun_Incident_ang_W = sind(Solar_Declination)*sind(Latitude)*cosd(90)-1*sind(Solar_Declination)*cosd(Latitude)*sind(90)*cosd(90) + ...
%     cosd(Solar_Declination)*cosd(Latitude)*cosd(90).*cosd(Solar_Time)+1*cosd(Solar_Declination)*sind(Latitude)*sind(90)*cosd(90).*cosd(Solar_Time) + ...
%     cosd(Solar_Declination)*sind(90).*sind(Solar_Time)*sind(90);
% Cos_Sun_Incident_ang_S = sind(Solar_Declination)*sind(Latitude)*cosd(90)-1*sind(Solar_Declination)*cosd(Latitude)*sind(90)*cosd(0) + ...
%     cosd(Solar_Declination)*cosd(Latitude)*cosd(90).*cosd(Solar_Time)+1*cosd(Solar_Declination)*sind(Latitude)*sind(90)*cosd(0).*cosd(Solar_Time) + ...
%     cosd(Solar_Declination)*sind(0).*sind(Solar_Time)*sind(90);
%% Solar Radiation Calculations on Ordinal Points and on to Vertical Surface
% Calculations for the parts of the global radiation
% Firstly the direct radiation calculation
% The Direct radiation is estimated to be global - diffuse
% B_vertical_East = (((Solar_Radiation' - Diffuse_horizontalsouth)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_E));
% B_vertical_North = (((Solar_Radiation' - Diffuse_horizontalsouth)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_N));
% B_vertical_West = (((Solar_Radiation' - Diffuse_horizontalsouth)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_W));
% B_vertical_South = (((Solar_Radiation' - Diffuse_horizontalsouth)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_S));
% Anisotropic index is
% k1 = ((Solar_Radiation' - Diffuse_horizontalsouth)./(B0_horizontalsouth));
% With which the diffuse radiation can be calculated
% Diffuse_vertical_East = Diffuse_horizontalsouth .* (1-k1) * ((1 + cosd(90))/2) + ((Diffuse_horizontalsouth .* k1)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_E);
% Diffuse_vertical_North = Diffuse_horizontalsouth .* (1-k1) * ((1 + cosd(90))/2) + ((Diffuse_horizontalsouth .* k1)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_N);
% Diffuse_vertical_West = Diffuse_horizontalsouth .* (1-k1) * ((1 + cosd(90))/2) + ((Diffuse_horizontalsouth .* k1)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_W);
% Diffuse_vertical_South = Diffuse_horizontalsouth .* (1-k1) * ((1 + cosd(90))/2) + ((Diffuse_horizontalsouth .* k1)./cosd(Solar_Zenith)).*max(0, Cos_Sun_Incident_ang_S);
% Albedo radiation is
% Ground_Reflectivity = 0.2; 
% Albedo_vertical_Direction = Ground_Reflectivity * Solar_Radiation' * (1 - cosd(90)/2);
% Total radiation on windows
% Solar_radiation_Windows_East = (B_vertical_East + Diffuse_vertical_East + Albedo_vertical_Direction);
% Solar_radiation_Windows_North = (B_vertical_North + Diffuse_vertical_North + Albedo_vertical_Direction);
% Solar_radiation_Windows_West = (B_vertical_West + Diffuse_vertical_West + Albedo_vertical_Direction);
% Solar_radiation_Windows_South = (B_vertical_South  + Diffuse_vertical_South + Albedo_vertical_Direction);
%%%
% Solar radiation on a tilted surface facing ordinal points can be
% calculated with SolRad function. First, selections for the ordinal points
% are:
% North: 1
% East: 2
% South: 3
% West: 4
% Selection = 1;
% [~,~,~,Global_Irr,~] = SolRad1(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%     if Global_Irr(m) < 0
%         Global_Irr(m) = 0;
%     end
% Global_Irradiance_North(m) = Global_Irr(m);
% Selection = 2;
% [~,~,~,Global_Irr,~] = SolRad1(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%     if Global_Irr(m) < 0
%         Global_Irr(m) = 0;
%     end
% Global_Irradiance_East(m) = Global_Irr(m);
% Selection = 3;
% [~,~,~,Global_Irr,~] = SolRad1(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%     if Global_Irr(m) < 0
%         Global_Irr(m) = 0;
%     end
% Global_Irradiance_South(m) = Global_Irr(m);
% Selection = 4;
% [~,~,~,Global_Irr,~] = SolRad1(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%     if Global_Irr(m) < 0
%         Global_Irr(m) = 0;
%     end
% Global_Irradiance_West(m) = Global_Irr(m);
%% Total heat gain calculations from solar radiation
% First the window's permeability factor is decided
% Input_g = 0; % When input is 0, the value is standard value; 1 is adding own value
% if Input_g == 0
%     Windows_permeability = gwindow; % from database
% else
%     Windows_permeability = [Input_Data{111}]; % Check the input data and the necessity to create a new input data
% end

Windows_permeability = gwindow;

%%%
% Then the permeability factor is to be defined
% If there are no shades, BCoC (Building code of conduct) D5
% suggests that permeability value 0.75 can be used for the frame and the
% other permeability values are 0. The blinds are considered to be open all
% the time, except when the temperature rises over 25 degrees, when the
% occupant is likely going to close them in order to reduce the
% overheating. On the other hand, manual control requires person to be
% present in order to turn the blinds. Otherwise the previous state is
% considered to apply. When temperature drops under 25 or there is no
% radiation the occupant is expected to open the blinds if present.
%%%
if myiter == 0
    F_permeability = 0.75;
else
    if Temp_inside > Temp_cooling && (Global_Irradiance_East > 0 || Global_Irradiance_North > 0 || Global_Irradiance_South > 0 || Global_Irradiance_West > 0) 
        if tenancy == 1
            F_permeability = 0.75 * 0.6; % Employing internal white venetian blinds
%         else
%             F_permeability(m) = F_permeability(m-1); % There is nobody to turn the blinds
        end
    else
        if tenancy == 1
            F_permeability = 0.75; % Can be used if not any shading losses and no curtains
%         else
%             F_permeability = F_permeability; % There is no one to turn the blinds
        end
    end
end
Solar_Heat_Gain = (Global_Irradiance_East * F_permeability * awe * Windows_permeability + Global_Irradiance_North * F_permeability * awn * Windows_permeability + ...
    Global_Irradiance_West * F_permeability * aww * Windows_permeability + Global_Irradiance_South * F_permeability * aws * Windows_permeability);

% Next the opaque material solar radiation gain is added to the system.
% a_roof      = 0.93;         % Absorption factor for bitumen roof
% a_wall      = 0.75;         % Absorption factor for red bricks
% e_brick     = 0.93;         % Brick's emissivity
% e_gypsum    = 0.85;         % Gypsum board's emissivity https://www.engineeringtoolbox.com/emissivity-coefficients-d_447.html
% StefanBoltzman_constant = 5.67 * 10^(-8);  % Stefan-Boltzman constant for long wave radiation

% Solar heat gains from opaque materials can be calculated with an equation
% I = A * Isol * cos(theta) * alfa. Isol * cos(theta) is already calculated
% by sol_rad function. A is the surface area of the opaque material and
% alfa is absorption factor. 
% Solar_gain_north_wall   = Global_Irradiance_North(m) * a_wall;
% Solar_gain_east_wall    = Global_Irradiance_East(m) * a_wall;
% Solar_gain_south_wall   = Global_Irradiance_South(m) * a_wall;
% Solar_gain_west_wall    = Global_Irradiance_West(m) * a_wall;
% % Add the roof here !
% Opaque_Solar_Heat_Gain = Solar_gain_north_wall + Solar_gain_east_wall + Solar_gain_south_wall + Solar_gain_west_wall; % Add roof !
% % Equivalent external temperature
% Te = Temperature(m) + Total_Thermal_Coefficient^(-1) * (Opaque_Solar_Heat_Gain + (Tr - Temperature(m)) * Radiative_Coefficient);
end

