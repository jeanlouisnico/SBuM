function [vargout] = EPWreader(TMY_filename)

% EPW,design_cooling_temp, design_heating_temp, daily_cooling_range, average_dry_bulb_temperature_jan, diffuse_peak, direct_peak, E_total

%----------------------------------------------------%
% EPWreader.m
%----------------------------------------------------%
%***Description:***
% Reads in an EPW file for key data
%
% Matthew Dahlhausen
% October 2014
%
%***Inputs:***
% -TMYfile
%
%***Outputs:***
% HeatingDegreeDays
% CoolingDegreeDays
% Average monthly/annual DB Temperatures
% Average monthly/annual windspeed
%
%
%%***************************************************%
dbstop if error
%% READ IN WEATHER FILE
%addpath('D:\DESKTOP\Courses\UMD\ENME610 - Optimization\Project\weather')
%TMY_filename = '722190TY.csv'; %'724060TY.csv';
fid=fopen(TMY_filename,'r'); % Open TMY file
if fid == -1
  disp(['file not found: ',TMY_filename]);
else
  tmy = read_mixed_csv(TMY_filename,',');      %read the file 
  
  % file header information
  
%   LOCATION,
%   A1, \field city
%       \type alpha
%   A2, \field State Province Region
%       \type alpha
%   A3, \field Country
%       \type alpha
%   A4, \field Source
%       \type alpha
%   N1, \field WMO
%       \note usually a 6 digit field. Used as alpha in EnergyPlus
%       \type alpha
%   N2 , \field Latitude
%       \units deg
%       \minimum -90.0
%       \maximum +90.0
%       \default 0.0
%       \note + is North, - is South, degree minutes represented in decimal (i.e. 30 minutes is .5)
%       \type real
%   N3 , \field Longitude
%       \units deg
%       \minimum -180.0
%       \maximum +180.0
%       \default 0.0
%       \note - is West, + is East, degree minutes represented in decimal (i.e. 30 minutes is .5)
%       \type real
%   N4 , \field TimeZone
%       \units hr - not on standard units list???
%       \minimum -12.0
%       \maximum +12.0
%       \default 0.0
%       \note Time relative to GMT.
%       \type real
%   N5 ; \field Elevation
%       \units m
%       \minimum -1000.0
%       \maximum< +9999.9
%       \default 0.0
%       \type real
  
  EPW.station_name = tmy(1,2); 
  EPW.station_state = tmy(1,3); 
  EPW.station_country = tmy(1,4);
  EPW.site_latitude = str2double(tmy(1,7));
  EPW.site_longitude = str2double(tmy(1,8));
  EPW.site_TimeZone = str2double(tmy(1,9));
  EPW.site_elevation = str2double(tmy(1,10)); 
 
%  N1, \field Year
%  N2, \field Month
%  N3, \field Day
%  N4, \field Hour
%  N5, \field Minute

  MaxRow = size(tmy,1) - 8 ;
  
  EPW.date = ones(MaxRow,1); % field 1
  time = cell(MaxRow,1); % field 2

%  N1, \field Year
%  N2, \field Month
%  N3, \field Day
%  N4, \field Hour
%  N5, \field Minute
%  A1, \field Data Source and Uncertainty Flags
%  N6, \field Dry Bulb Temperature
%       \units C
%       \minimum> -70
%       \maximum< 70
%       \missing 99.9
%  N7, \field Dew Point Temperature
%       \units C
%       \minimum> -70
%       \maximum< 70
%       \missing 99.9
%  N8, \field Relative Humidity
%       \missing 999.
%       \minimum 0
%       \maximum 110
%  N9, \field Atmospheric Station Pressure
%       \units Pa
%       \missing 999999.
%       \minimum> 31000
%       \maximum< 120000
%  N10, \field Extraterrestrial Horizontal Radiation
%       \units Wh/m2
%       \missing 9999.
%       \minimum 0
%  N11, \field Extraterrestrial Direct Normal Radiation
%       \units Wh/m2
%       \missing 9999.
%       \minimum 0
%  N12, \field Horizontal Infrared Radiation Intensity
%       \units Wh/m2
%       \missing 9999.
%       \minimum 0
%  N13, \field Global Horizontal Radiation
%       \units Wh/m2
%       \missing 9999.
%       \minimum 0
%  N14, \field Direct Normal Radiation
%       \units Wh/m2
%       \missing 9999.
%       \minimum 0
%  N15, \field Diffuse Horizontal Radiation
%       \units Wh/m2
%       \missing 9999.
%       \minimum 0
%  N16, \field Global Horizontal Illuminance
%       \units lux
%       \missing 999999.
%       \note will be missing if >= 999900
%       \minimum 0
%  N17, \field Direct Normal Illuminance
%       \units lux
%       \missing 999999.
%       \note will be missing if >= 999900
%       \minimum 0
%  N18, \field Diffuse Horizontal Illuminance
%       \units lux
%       \missing 999999.
%       \note will be missing if >= 999900
%       \minimum 0
%  N19, \field Zenith Luminance
%       \units Cd/m2
%       \missing 9999.
%       \note will be missing if >= 9999
%       \minimum 0
%  N20, \field Wind Direction
%       \units degrees
%       \missing 999.
%        \minimum 0
%       \maximum 360
%  N21, \field Wind Speed
%       \units m/s
%       \missing 999.
%       \minimum 0
%        \maximum 40
%  N22, \field Total Sky Cover
%       \missing 99
%        \minimum 0
%       \maximum 10
%  N23, \field Opaque Sky Cover (used if Horizontal IR Intensity missing)
%       \missing 99
%       \minimum 0
%       \maximum 10
%  N24, \field Visibility
%       \units km
%       \missing 9999
%  N25, \field Ceiling Height
%       \units m
%       \missing 99999
%  N26, \field Present Weather Observation
%  N27, \field Present Weather Codes
%  N28, \field Precipitable Water
%       \units mm
%       \missing 999
%  N29, \field Aerosol Optical Depth
%       \units thousandths
%       \missing .999
%  N30, \field Snow Depth
%       \units cm
%       \missing 999
%  N31, \field Days Since Last Snowfall
%       \missing 99
%  N32, \field Albedo
%       \missing 999
%  N33, \field Liquid Precipitation Depth
%       \units mm
%       \missing 999
%  N34; \field Liquid Precipitation Quantity
%       \units hr
%       \missing 99

    EPW.Dry_Bulb_Temperature = ones(MaxRow,1);
    EPW.Dew_Point_Temperature = ones(MaxRow,1);
    EPW.Relative_Humidity = ones(MaxRow,1);
    EPW.Atmospheric_Station_Pressure = ones(MaxRow,1);
    EPW.Extraterrestrial_Horizontal_Radiation = ones(MaxRow,1);
    EPW.Extraterrestrial_Direct_Normal_Radiation = ones(MaxRow,1);
    EPW.Horizontal_Infrared_Radiation_Intensity = ones(MaxRow,1);
    EPW.Global_Horizontal_Radiation = ones(MaxRow,1);
    EPW.Direct_Normal_Radiation = ones(MaxRow,1);
    EPW.Diffuse_Horizontal_Radiation = ones(MaxRow,1);
    EPW.Global_Horizontal_Illuminance = ones(MaxRow,1);
    EPW.Direct_Normal_Illuminance = ones(MaxRow,1);
    EPW.Diffuse_Horizontal_Illuminance = ones(MaxRow,1);
    EPW.Zenith_Luminance = ones(MaxRow,1);
    EPW.Wind_Direction = ones(MaxRow,1);
    EPW.Wind_Speed = ones(MaxRow,1);
    EPW.Total_Sky_Cover = ones(MaxRow,1);
    EPW.Opaque_Sky_Cover = ones(MaxRow,1);
    EPW.Visibility = ones(MaxRow,1);
    EPW.Ceiling_Height = ones(MaxRow,1);
    EPW.Present_Weather_Observation = ones(MaxRow,1);
    EPW.Present_Weather_Codes = ones(MaxRow,1);
    EPW.Precipitable_Water = ones(MaxRow,1);
    EPW.Aerosol_Optical_Depth = ones(MaxRow,1);
    EPW.Snow_Depth = ones(MaxRow,1);
    EPW.Days_Since_Last_Snowfall = ones(MaxRow,1);
    EPW.Albedo = ones(MaxRow,1);
    EPW.Liquid_Precipitation_Depth = ones(MaxRow,1);
    EPW.Liquid_Precipitation_Quantity = ones(MaxRow,1);
  
  
  yearRef = str2double(tmy(9,1)) ;
  for i=9:(MaxRow+8) %EOF
    EPW.date(i-8) = datenum(yearRef,str2double(tmy(i,2)),str2double(tmy(i,3)))+(str2double(tmy(i,4))-1)/24;
    EPW.Dry_Bulb_Temperature(i-8) = str2double(tmy(i,7));
    EPW.Dew_Point_Temperature(i-8) = str2double(tmy(i,8));
    EPW.Relative_Humidity(i-8) = str2double(tmy(i,9));
    EPW.Atmospheric_Station_Pressure(i-8) = str2double(tmy(i,10));
    EPW.Extraterrestrial_Horizontal_Radiation(i-8) = str2double(tmy(i,11));
    EPW.Extraterrestrial_Direct_Normal_Radiation(i-8) = str2double(tmy(i,12));
    EPW.Horizontal_Infrared_Radiation_Intensity(i-8) = str2double(tmy(i,13));
    EPW.Global_Horizontal_Radiation(i-8) = str2double(tmy(i,14));
    EPW.Direct_Normal_Radiation(i-8) = str2double(tmy(i,15));
    EPW.Diffuse_Horizontal_Radiation(i-8) = str2double(tmy(i,16));
    EPW.Global_Horizontal_Illuminance(i-8) = str2double(tmy(i,17));
    EPW.Direct_Normal_Illuminance(i-8) = str2double(tmy(i,18));
    EPW.Diffuse_Horizontal_Illuminance(i-8) = str2double(tmy(i,19));
    EPW.Zenith_Luminance(i-8) = str2double(tmy(i,20));
    EPW.Wind_Direction(i-8) = str2double(tmy(i,21));
    EPW.Wind_Speed(i-8) = str2double(tmy(i,22));
    EPW.Total_Sky_Cover(i-8) = str2double(tmy(i,23));
    EPW.Opaque_Sky_Cover(i-8) = str2double(tmy(i,24));
    EPW.Visibility(i-8) = str2double(tmy(i,25));
    EPW.Ceiling_Height(i-8) = str2double(tmy(i,26));
    EPW.Present_Weather_Observation(i-8) = str2double(tmy(i,27));
    EPW.Present_Weather_Codes(i-8) = str2double(tmy(i,28));
    EPW.Precipitable_Water(i-8) = str2double(tmy(i,29));
    EPW.Aerosol_Optical_Depth(i-8) = str2double(tmy(i,30));
    EPW.Snow_Depth(i-8) = str2double(tmy(i,31));
    EPW.Days_Since_Last_Snowfall(i-8) = str2double(tmy(i,32));
    EPW.Albedo(i-8) = str2double(tmy(i,33));
    EPW.Liquid_Precipitation_Depth(i-8) = str2double(tmy(i,34));
    EPW.Liquid_Precipitation_Quantity(i-8) = str2double(tmy(i,35));
  end  
end

if fid ~= -1
  fclose(fid); % Close TMY file 
end
clear TM_filename fid tmy i

vargout(1) = EPW ;

if nargout == 1
    return;
end

month = zeros(MaxRow,1);
day = zeros(MaxRow,1);
for i=1:MaxRow
  DateStrFull = datetime(EPW.date(i),'ConvertFrom','datenum')   ;
  month(i) = DateStrFull.Month                                  ;
  day(i) = DateStrFull.Day                                      ;
end

%% CALCULATE WEATHER INFORMATION

order_dry_bulb_temperature = sort(EPW.Dry_Bulb_Temperature);
design_cooling_temp = order_dry_bulb_temperature(round(MaxRow*0.99));
design_heating_temp = order_dry_bulb_temperature(round(MaxRow*0.01));

% calculate outdoor air mean dry bulb temperature in january 
count = 0;
average_dry_bulb_temperature_jan = 0;
for i=1:8760
  if month(i) == 1
    average_dry_bulb_temperature_jan = average_dry_bulb_temperature_jan + EPW.Dry_Bulb_Temperature(i);  
    count = count + 1;    
  end    
end
average_dry_bulb_temperature_jan = average_dry_bulb_temperature_jan/count;

% calculate average daily cooling range in July
daily_cooling_ranges = 0;
july_start = 0;
for i=1:8760
  if month(i) == 7
    if july_start == 0 
      july_start = i;
    end
    daily_cooling_ranges(i-july_start+1) = max(EPW.Dry_Bulb_Temperature((i-24):(i-1))) - min(EPW.Dry_Bulb_Temperature((i-24):(i-1))); 
  end    
end
daily_cooling_range = mean(daily_cooling_ranges);
max_daily_cooling_range = max(daily_cooling_ranges);

%%
% IRRADIANCE CALCULATIONS BASED ON 
% ASHRAE HANDBOOK OF FUNDAMENTALS 2005 - SI
% CHAPTER 30 - NONRESIDENTIAL COOLING AND HEATING LOAD CALCULATIONS
% CHAPTER 31 - FENESTRATION

for i=1:MaxRow
  DateStrFull = datetime(EPW.date(i),'ConvertFrom','datenum')   ;
  %time_string = strsplit(char(time(i)),':');
  LST(i) = DateStrFull.Hour; % (decimal hours), local solar time
end
LST = LST';

day = (1:MaxRow)*(365/MaxRow); day=day';
ET = -7.655*sind(day) + 9.873*sind(2*day + 3.588); % (decimal minutes), equation of time
LSM = 75; % (decimal ° of arc), local standard time meridian for Eastern Standard Time
LON = -EPW.site_longitude; % (decimal ° of arc), local longitude
L = EPW.site_latitude; % (decimal ° of arc), local latitude
AST = LST + ET/60 + (LSM - LON)/15; % (decimal hours), apparent solar time 

epsilon = 23.45*sind(((360*(284 + day))/365)); % solar declination 
H = 15*(AST - 12); % (degrees), hour angle 
beta = asind( cosd(L).*cosd(epsilon).*cosd(H) + sind(L).*sind(epsilon) ); % solar alitude
phi = acosd( (sind(beta).*sind(L) - sind(epsilon)) ./ (cosd(beta).*cosd(L)) ); % solar azimuth

psi = 0; % surface azimuth, 0 for due south
gamma = phi - psi; % surface solar azimuth
sigma = 90; % (decimal ° of arc), tilt angle, 90 is vertical
theta = acosd( cosd(beta).*cosd(gamma).*sind(sigma) + sind(beta).*cosd(sigma) ); % (decimal ° of arc), incident angle
Y = 0.45*ones(8760,1); % ratio of sky diffuse radiation on avertical surface to sky diffuse radiation on a horizontal surface
for i=1:length(theta)
  if cosd(theta(i)) > -0.2
    Y(i) = 0.55 + 0.437*cosd(theta(i)) + 0.313*(cosd(theta(i)).^2);
  end
end
rho_g = 0.2; % ground relectivity
theta_horizontal = acosd(sind(beta)); % (decimal ° of arc), incident angle on a horizontal surface

%% PEAK IRRADIANCE
[direct_peak, diffuse_peak, total_peak] = peakIrradiance(EPW.site_latitude, psi, 'vertical');

%% ASHRAE CLEAR SKY SOLAR MODEL
A = zeros(MaxRow,1);
B = zeros(MaxRow,1);
C = zeros(MaxRow,1);
for i=1:MaxRow
  switch month(i)
      case 1
          A(i) = 1202; % (W/m^2)
          B(i) = 0.141;
          C(i) = 0.103;
      case 2
          A(i) = 1187; % (W/m^2)
          B(i) = 0.142;
          C(i) = 0.104;
      case 3
          A(i) = 1164; % (W/m^2)
          B(i) = 0.149;
          C(i) = 0.109;
      case 4
          A(i) = 1130; % (W/m^2)
          B(i) = 0.164;
          C(i) = 0.120;
      case 5
          A(i) = 1106; % (W/m^2)
          B(i) = 0.177;
          C(i) = 0.130;
      case 6
          A(i) = 1092; % (W/m^2)
          B(i) = 0.185;
          C(i) = 0.137;
      case 7 
          A(i) = 1093; % (W/m^2)
          B(i) = 0.186;
          C(i) = 0.138;
      case 8
          A(i) = 1107; % (W/m^2)
          B(i) = 0.182;
          C(i) = 0.134;
      case 9
          A(i) = 1136; % (W/m^2)
          B(i) = 0.165;
          C(i) = 0.121;
      case 10
          A(i) = 1166; % (W/m^2)
          B(i) = 0.152;
          C(i) = 0.111;
      case 11
          A(i) = 1190; % (W/m^2)
          B(i) = 0.144;
          C(i) = 0.106;
      case 12
          A(i) = 1204; % (W/m^2)
          B(i) = 0.141;
          C(i) = 0.103;
  end        
end

beta_valid = beta;
beta_valid(beta_valid < 0) = 0;
E_direct_normal_clrsky = A./exp(B./sind(beta_valid)); % (W/m^2), direct normal irradiation

% calculation for horizontal surface
E_total_clrsky_horizontal = E_direct_normal_clrsky.*cosd(theta_horizontal);
E_total_clrsky_horizontal(E_total_clrsky_horizontal < 0) = 0;
E_total_clrsky_horizontal = E_total_clrsky_horizontal + C.*E_direct_normal_clrsky;

% calculate for south facing window
E_diffuse_clrsky = C.*Y.*E_direct_normal_clrsky;  % (W/m^2), diffuse irradiation  
E_reflected_clrsky = E_direct_normal_clrsky.*(C + sind(beta_valid))*rho_g.*((1 - cosd(sigma))./2);  % (W/m^2), ground-reflected irradiation  
E_direct_normal_clrsky_component = E_direct_normal_clrsky.*cosd(theta); % (W/m^2), direct irradiation in incident direction  
E_direct_normal_clrsky_component(E_direct_normal_clrsky_component < 0) = 0; % ignore negative values  
E_total_clrsky = E_direct_normal_clrsky_component + E_diffuse_clrsky + E_reflected_clrsky; % (W/m^2), total irradiation on a south-facing window

%% CALCULATE IRRADIANCE FROM DATA

% calculation for horizontal surface
E_total_calc_horizontal = EPW.Direct_Normal_Radiation.*cosd(theta_horizontal);
E_total_calc_horizontal(E_total_calc_horizontal < 0) = 0;
E_total_calc_horizontal = E_total_calc_horizontal + C.*EPW.Direct_Normal_Radiation;

% calculation for a south facing window
E_direct_normal_component  = EPW.Direct_Normal_Radiation.*cosd(theta); % (W/m^2), direct irradiation in incident direction  
E_direct_normal_component(E_direct_normal_component < 0) = 0; % ignore negative values  
E_diffuse = C.*Y.*EPW.Direct_Normal_Radiation;  % (W/m^2), diffuse irradiation  
E_reflected = EPW.Direct_Normal_Radiation.*(C + sind(beta_valid))*rho_g.*((1 - cosd(sigma))./2);  % (W/m^2), ground-reflected irradiation  
E_reflected(beta_valid == 0) = 0;
E_total = E_direct_normal_component + E_diffuse + E_reflected; % (W/m^2), total irradiation on a south-facing window

%% Output

vargout(2) = design_cooling_temp ; 
vargout(3) = design_heating_temp ; 
vargout(4) = daily_cooling_range ;
vargout(5) = average_dry_bulb_temperature_jan ;
vargout(6) = diffuse_peak ;
vargout(7) = direct_peak ;
vargout(8) = E_total ;

%% PLOT IRRADIATION COMPARISON
%{
strt = 4800; 
endt = 4900;
figure(1)
hold on
plot(strt:endt,direct_normal_irradiance(strt:endt),'k','LineWidth',1)
plot(strt:endt,E_direct_normal_clrsky(strt:endt),':r','LineWidth',1)
title('ASHRAE Clear Sky Model (red) vs. EPW Data (black) direct normal')
xlabel('Hour')
ylabel('W/m^2')
hold off
figure(2)
hold on
plot(strt:endt,global_horizontal_irradiance(strt:endt),'k','LineWidth',1)
plot(strt:endt,E_total_clrsky_horizontal(strt:endt),':r','LineWidth',1)
title('ASHRAE Clear Sky Model (red) vs. EPW Data (black) on a horizontal surface')
xlabel('Hour')
ylabel('W/m^2')
hold off
figure(3)
hold on
plot(strt:endt,E_total(strt:endt),'k','LineWidth',1)
plot(strt:endt,E_total_clrsky(strt:endt),':r','LineWidth',1)
title('ASHRAE Clear Sky Model (red) vs. EPW Data (black) south window')
xlabel('Hour')
ylabel('W/m^2')
hold off
%}

end