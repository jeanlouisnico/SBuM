%% Solar Panels
%% Function call
function [Power, Luminance,Luminancev, Global_Irr, varargout] = SolRad2(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection)

%%% load Test_Values_2132018_2.mat
% Unload the variables for faster processing time
Latitude    = str2double(Input_Data.Latitude); 
Longitude   = str2double(Input_Data.Longitude); 
SolarData   = str2double(Input_Data.SolarData); 
PhotoVol    = str2double(Input_Data.PhotoVol); 

%%% load TRY2012

if Selection == 1
    Aspect = 0;
    Tilt = 90;
    PhotoVol = 0;
    myiter = Time_Sim.myiter;
    nbrstep = Time_Sim.nbrstep + 24;
elseif Selection == 2
    Aspect = 90;
    Tilt = 90;
    PhotoVol = 0;
    myiter = Time_Sim.myiter;
    nbrstep = Time_Sim.nbrstep + 24;
elseif Selection == 3
    Aspect = 180;
    Tilt = 90;
    PhotoVol = 0;
    myiter = Time_Sim.myiter;
    nbrstep = Time_Sim.nbrstep + 24;
elseif Selection == 4
    Aspect = 270;
    Tilt = 90;
    PhotoVol = 0;
    myiter = Time_Sim.myiter;
    nbrstep = Time_Sim.nbrstep + 24;
elseif Selection == 5
    Tilt = str2double(Input_Data.Tilt); 
    Aspect = str2double(Input_Data.Aspect); 
    
    switch Input_Data.SimulationTimeFrame
        case 'TRY2050'
            a = load('2050_global_radiation') ;
            Hourly_Global_Radiation_2050 = a.Hourly_Global_Radiation_2050 ;
            %Temperature = a.Temperature ;
            SolarData = 'TRY2050';
        case 'TRY2012'
            b = load('TRY2012') ;
            TRY2012_Global_Radiation = b.TRY2012_Global_Radiation ;
            %TRY2012_Temperature = b.TRY2012_Temperature ;
            SolarData = 'TRY2012';
        otherwise
            b = load('TRY2012') ;
            TRY2012_Global_Radiation = b.TRY2012_Global_Radiation ;
            %TRY2012_Temperature = b.TRY2012_Temperature ;
            SolarData = 'TRY2012';
            
    end
    
    if leapyear(Time_Sim.timeyear)
        myiter = 1:8784;
    else
        myiter = 1:8760;
    end
    
    
    
    nbrstep = Time_Sim.nbrstep;
%     Time_Sim.timemonth  = month(datetime(2012,1,1,0,0,0):hours(1):datetime(2012,12,31,23,0,0));
%     Time_Sim.timeday    = day(datetime(2012,1,1,0,0,0):hours(1):datetime(2012,12,31,23,0,0));
%     Time_Sim.timehour   = hour(datetime(2012,1,1,0,0,0):hours(1):datetime(2012,12,31,23,0,0));
%     Time_Sim.timeyear   = year(datetime(2012,1,1,0,0,0):hours(1):datetime(2012,12,31,23,0,0));
%     Time_Sim.timedayyear    = datenum(Time_Sim.timeyear,Time_Sim.timemonth,Time_Sim.timeday)+1-datenum(Time_Sim.timeyear,1,1);                                                     ; % Day of the year
%     Time_Sim.timedayyear = abs(datenum(2012,1,1,0,0,0)-(datenum(2012,1,1,0,0,0):hours(1):datenum(2012,12,31,23,0,0)));
    Time_Sim.timemonth  = month(datetime(Time_Sim.StartDate.(Input_Data.Headers), 'ConvertFrom', 'datenum'):hours(1):datetime(Time_Sim.EndDate.(Input_Data.Headers)+1-1/24, 'ConvertFrom', 'datenum'));
    Time_Sim.timeday    = day(datetime(Time_Sim.StartDate.(Input_Data.Headers), 'ConvertFrom', 'datenum'):hours(1):datetime(Time_Sim.EndDate.(Input_Data.Headers)+1-1/24, 'ConvertFrom', 'datenum'));
    Time_Sim.timehour   = hour(datetime(Time_Sim.StartDate.(Input_Data.Headers), 'ConvertFrom', 'datenum'):hours(1):datetime(Time_Sim.EndDate.(Input_Data.Headers)+1-1/24, 'ConvertFrom', 'datenum'));
    Time_Sim.timeyear   = year(datetime(Time_Sim.StartDate.(Input_Data.Headers), 'ConvertFrom', 'datenum'):hours(1):datetime(Time_Sim.EndDate.(Input_Data.Headers)+1-1/24, 'ConvertFrom', 'datenum'));
    Time_Sim.timedayyear    = datenum(Time_Sim.timeyear,Time_Sim.timemonth,Time_Sim.timeday)+1-datenum(Time_Sim.timeyear,1,1);                                                      % Day of the year
%     Time_Sim.timedayyear = abs(datenum(Time_Sim.StartDate.(Input_Data.Headers))-(datenum(Time_Sim.StartDate.(Input_Data.Headers)):hours(1):datenum(Time_Sim.EndDate.(Input_Data.Headers))));
%     SolarData = 'TRY2050';
%     SolarData = 'TRY2012';

    if myiter(end) > nbrstep.(Input_Data.Headers)
        myiter = Time_Sim.myiter+1:Time_Sim.myiter+length(Time_Sim.timedayyear);
    end
    
    if Tilt == -1 
        Tilt = 45;
    end
    if Aspect == -1
        Aspect = 180;
    end
else
    Tilt = Input_Data.Tilt;
    Aspect = Input_Data.Aspect;
    myiter = Time_Sim.myiter;
%     if length(myiter) > 8760        % if myiter is longer than a normal year the simulation does not go through!
%         myiter = myiter(1:8760);
%     end
%     Time_Sim.timemonth      = [Time_Sim.timemonth(1:1416) Time_Sim.timemonth(1441:end)];
%     Time_Sim.timeday        = Time_Sim.timeday(1:end-24);
%     Time_Sim.timehour       = Time_Sim.timehour(1:end-24);
%     Time_Sim.timeyear       = Time_Sim.timeyear(1:end-24);
%     Time_Sim.timedayyear    = [Time_Sim.timedayyear(1:1416) Time_Sim.timedayyear(1441:end)];
    nbrstep                 = Time_Sim.nbrstep;
end
% myiter = Time_Sim.myiter;
% nbrstep = Time_Sim.nbrstep;
 %SimDetails = varargin{1}{5};
% Output_Folder = SimDetails.Output_Folder;
% Project_ID = SimDetails.Project_ID;
%% Initial data
    switch(SolarData)
        case 'Daily Data'
            Solar_Radiation = All_Var.Daily_Solar_Radiation;
        case 'Hourly Data'
            Solar_Radiation = All_Var.Hourly_Solar_Radiation;
%             Solar_Radiation = TRY2012_Global_Radiation';
%             Solar_Radiation = [Solar_Radiation(1:1416); Solar_Radiation(1393:1416); Solar_Radiation(1417:end)];
        case 'TRY2012'              % Consider having different TRY if simulation is located somewhere else
            Solar_Radiation = TRY2012_Global_Radiation;
            if leapyear(Time_Sim.timeyear(Time_Sim.myiter+1)) == 1
                Solar_Radiation = [Solar_Radiation(1:1392) Solar_Radiation(1369:1392) Solar_Radiation(1393:end)]';
            end
            
            if Time_Sim.nbrstep.(Input_Data.Headers) > length(Solar_Radiation)
                nbrstep.(Input_Data.Headers) = length(Solar_Radiation);
                Time_Sim.timemonth = Time_Sim.timemonth(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timeday = Time_Sim.timeday(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timeyear = Time_Sim.timeyear(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timehour = Time_Sim.timehour(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timedayyear = Time_Sim.timedayyear(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                if length(Time_Sim.timemonth) > Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1
                    Time_Sim.timemonth = Time_Sim.timemonth(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timeday = Time_Sim.timeday(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timeyear = Time_Sim.timeyear(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timehour = Time_Sim.timehour(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timedayyear = Time_Sim.timedayyear(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                end
            end
            
            SolarData       = 'Hourly Data';
        case 'TRY2050'
%             load Radiation2050_simulation
            Solar_Radiation = Hourly_Global_Radiation_2050'; % Solar radiation for 2050 from TRY2050.
            
            if leapyear(Time_Sim.timeyear(Time_Sim.myiter+1)) == 0
                Solar_Radiation = [Solar_Radiation(1:1368) Solar_Radiation(1393:end)]';
            end
            
            if Time_Sim.nbrstep.(Input_Data.Headers) > length(Solar_Radiation)
                nbrstep.(Input_Data.Headers) = length(Solar_Radiation);
                Time_Sim.timemonth = Time_Sim.timemonth(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timeday = Time_Sim.timeday(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timeyear = Time_Sim.timeyear(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timehour = Time_Sim.timehour(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                Time_Sim.timedayyear = Time_Sim.timedayyear(Time_Sim.myiter+1:Time_Sim.myiter+length(Solar_Radiation));
                if length(Time_Sim.timemonth) > Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1
                    Time_Sim.timemonth = Time_Sim.timemonth(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timeday = Time_Sim.timeday(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timeyear = Time_Sim.timeyear(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timehour = Time_Sim.timehour(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                    Time_Sim.timedayyear = Time_Sim.timedayyear(1:(Time_Sim.nbrstep.(Input_Data.Headers)-Time_Sim.myiter+1));
                end
            end

            SolarData       = 'Hourly Data';
    end

%% Solar coordinates calculation
IMT = Time_Sim.timemonth - 3;
IMT1= Time_Sim.timemonth + 9;
IMT2= Time_Sim.timemonth;
    if IMT2 > 2
        INTT_1 = fix(30.6 * IMT + 0.5);
        INTT_2 = fix(365.25 * (Time_Sim.timeyear - 1976));
    else
        INTT_1 = fix(30.6 * IMT1 + 0.5);
        INTT_2 = fix(365.25 * ((Time_Sim.timeyear - 1) - 1976));
    end

LSM = 45; 
UT = 12 + LSM/15;

SMLT = (UT/24 + Time_Sim.timeday + INTT_1 + INTT_2 - 8707.5) / 36525;

CAPG = 357.528 + (35999.05 * SMLT);
if CAPG > 360
    G360_3 = fix(CAPG / 360);
    G360 = CAPG - (G360_3 * 360);
    CAPC = 1.915 * sin(G360*(pi()/180)) + 0.02 * sin(2*G360*(pi()/180));
else
    CAPC = 1.915 * sin(CAPG*(pi()/180)) + 0.02 * sin(2*CAPG*(pi()/180));
end

CAPL   = 280.46 + (36000.77 * SMLT) + CAPC;

if CAPL > 360
    XL_360 = CAPL - (fix(CAPL/360)*360);
else
    XL_360 = CAPL;
end
ALPHA = XL_360 - 2.466 * sin((2*XL_360)*(pi()/180)) + 0.053 * sin((4*XL_360)*(pi()/180));
EPSILN = 23.4393 - (0.013 * SMLT) ;            
EOT = (XL_360 - CAPC - ALPHA) / 15;                                                        
DEC = atan(tan(EPSILN*(pi()/180)) .* sin(ALPHA * (pi()/180)))/(pi()/180);   

if LSM < 0
    cor = -(abs(LSM) - abs(Longitude)) / 15;
elseif LSM > 0
    cor = (abs(LSM) - abs(Longitude)) / 15;
else
    cor = - (Longitude/15);
end

cortrm = - EOT - cor;
TRM12 = -tan(Latitude * (pi()/180)) * tan(DEC * (pi()/180));
if TRM12 < -0.99999  
    Day_Length = 24  ;
elseif TRM12 > 0.9999
    Day_Length = 0   ;
else
    Day_Length = (2/15) * acos(TRM12) / (pi()/180);
end

if Day_Length == 0     
    Sunrise = 0        ;
    Sunset  = 0        ;
elseif Day_Length == 24
    Sunrise = 24       ;
    Sunset  = 24       ;
else
    Sunrise = 12 - (Day_Length / 2);
    Sunset  = 12 + (Day_Length / 2);
end            
solar_time = 15 * (Time_Sim.timehour - LSM/15 - 12) - (Longitude - (LSM/15 * 15));
Solar_zenith = acos(sin(DEC * (pi()/180)) * sin(Latitude * (pi()/180)) + cos(DEC * (pi()/180)) * cos(Latitude * (pi()/180)) .* cos(solar_time * (pi()/180))) * (180/pi());

if floor(Sunrise) == Time_Sim.timehour
    AST = 0.5 * (Time_Sim.timehour + 1 + Sunrise);
elseif floor(Sunset) == Time_Sim.timehour
    AST = 0.5 * (Time_Sim.timehour + Sunrise);
else
    AST = (Time_Sim.timehour + 1) - 0.5;
end
horangsolaz = 15 * (pi()/180) * abs(12 - AST);

xdum   = sin(Latitude * (pi()/180)) * sin(DEC * (pi()/180)) + cos(Latitude * (pi()/180)) * cos(DEC * (pi()/180)) .* cos(horangsolaz);
SolAlt = asin(xdum) * (180/pi());
xdumsolaz = (cos(DEC * (pi()/180)) .* ((cos(Latitude * (pi()/180)) .* tan(DEC * (pi()/180))) - (sin(Latitude * (pi()/180)) .* cos(horangsolaz)))) ./ cos(SolAlt * (pi() / 180));
           
if (Time_Sim.timehour + 1) > 12
    Solar_Azim = 360 - (acos(xdumsolaz)/(pi()/180));
else
    Solar_Azim = acos(xdumsolaz)/(pi()/180);
end
%% Solar radiation decomposition from measured data 
switch(SolarData)
    case 'Hourly Data' 
            %                   if strcmp('Hourly Data',SolarData);
            b0 = (1 + 0.033 * cos(360 * Time_Sim.timedayyear / 365 * pi()/180)) .* sin(SolAlt * pi()/180) * 1367;
            for n = 1:nbrstep.(Input_Data.Headers)
                if or(b0(n) <= 1,b0(n) <= Solar_Radiation(n))
                    B0(n) = -1;
                else
                    B0(n) = b0(n); 
                end
            end
            m = 1416 ;
%             if Selection == 1 || Selection == 2 || Selection == 3 || Selection == 4
%                 B0(m+24:end+24) = B0(m:end);
%             end
           Ktm = Solar_Radiation' ./ B0;
           for n = 1:nbrstep.(Input_Data.Headers)
               if and(B0(n)>0, B0(n) < Solar_Radiation(n))
                   Ktm(n) = 1;
               end
           end
           for n = 1:nbrstep.(Input_Data.Headers)
               if Ktm(n) <= 0
                   Fd1(n) = 1;
               elseif Ktm(n) <= 0.13
                   Fd1(n) = 0.952;
               elseif and(Ktm(n) > 0.13,Ktm(n) <= 0.8)
                   Fd1(n) = 0.868 + 1.335 * Ktm(n) - 5.782 * Ktm(n)^2 + 3.721 * Ktm(n)^3;
               elseif Ktm(n) > 0.8
                   Fd1(n) = 0.141;
               end
           end
           diffuse = Fd1 .* Solar_Radiation';

           direct  = Solar_Radiation' - diffuse;

           G0      = Solar_Radiation';     

           AM = 1 ./ sin(SolAlt * pi()/180);
           E0 = 1 + 0.033 * cos(360 * Time_Sim.timedayyear / 365 * pi()/180);

           for n = 1:nbrstep.(Input_Data.Headers)
               if AM(n) <= 0
                   MaxIrr(n) = 0;
               else 
                   MaxIrr(n) = 1367 * E0(n) * (0.7^(AM(n)^0.678));
               end
           end

   case ('Daily Data')

           E0 = 1 + 0.033 * cos(360 * Time_Sim.timedayyear / 365 * pi()/180);
           if Day_Length==24
               ws = 180                   ;
           elseif Day_Length==0
               ws = 0                     ;
           else
               ws = -acos(-tan(Latitude * pi()/180) * tan(DEC * pi()/180)) / (pi()/180);
           end

           B0d0 = 24 / pi() * 1367 * E0 * (-pi()/180 * ws * sin(DEC * pi()/180) * sin(Latitude * pi()/180)-cos(DEC * pi()/180) * cos(Latitude * pi()/180) * sin(ws * pi()/180));

           Ktm = Solar_Radiation / B0d0;

           if Ktm <= 0
               Fd1 = 1;
           elseif Ktm <= 0.13
               Fd1 = 0.952;
           elseif and(Ktm > 0.13,Ktm <= 0.8)
               Fd1 = 0.868 + 1.335 * Ktm - 5.782 * Ktm^2 + 3.721 * Ktm^3;
           elseif Ktm > 0.8
               Fd1 = 0.141;
           end
           D0 = Fd1 * Solar_Radiation;

           B0 = (1 + 0.033 * cos(360 * Time_Sim.timedayyear / 365 * pi()/180)) * sin(SolAlt * pi()/180) * 1367;
           if SolAlt > 0
               rd = pi()/24 * (cos(solar_time * pi()/180) - cos(ws * pi()/180))/(pi()/180 * ws * cos(ws * pi()/180)-sin(ws * pi()/180));
               diffuse = D0 * rd;
           else
               rd = 0;
               diffuse = 0;
           end

            a  = 0.409 - 0.5016 * sin((ws + 60) * pi()/180);
            b  = 0.6609 + 0.4767 * sin((ws + 60) * pi()/180);
           rg = rd * (a + b * cos(solar_time * pi()/180));

           D1 = rg * Solar_Radiation;

           if D1 - diffuse >= 0
               direct = D1 - diffuse;
           else
               direct = 0;
           end

           G0 = direct + diffuse;
end

if Aspect >= 0
    Alpha = abs(180-Aspect);
elseif diffuse == 0
        Alpha = 90;
else
        Alpha = acos((sin(SolAlt * pi()/180) * sin(Latitude * pi()/180) - sin(DEC * pi()/180)) / (cos(SolAlt * pi()/180)*cos(Latitude * pi()/180))) * 180/pi();
end

if Tilt >= 0
    tilt = Tilt;
elseif diffuse == 0
    tilt = 90;
else
    tilt = acos(sin(SolAlt * pi()/180)) * 180/pi();
end            
funcaspect = sin(DEC * pi()/180) * sin(Latitude * pi()/180) * cos(tilt * pi()/180) - sin(DEC * pi()/180) * cos(Latitude * pi()/180) * sin(tilt * pi()/180) * ...
             cos(Alpha * pi()/180) + cos(DEC * pi()/180) * cos(Latitude * pi()/180) * cos(tilt * pi()/180).*cos(solar_time * pi()/180) + cos(DEC * pi()/180) * ...
             sin(Latitude * pi()/180) * sin(tilt * pi()/180) * cos(Alpha * pi()/180) .* cos(solar_time * pi()/180) + cos(DEC * pi()/180) * sin(Alpha * pi()/180) .* ...
             sin(solar_time * pi()/180) * sin(tilt * pi()/180);
for n = 1:nbrstep.(Input_Data.Headers)
    if or(diffuse(n) == 0, funcaspect(n) <= 0)
        CosTeta(n) = 0;
    else
        CosTeta(n) = funcaspect(n);
    end
end

Beta =  direct ./ sin(max(10,SolAlt) * pi()/180) .* CosTeta;
Delta = diffuse .* (1 - direct ./ B0) * (1 + cos(tilt + pi()/180) / 2) + (diffuse .* direct ./ B0) ./ sin(max(10,SolAlt) * pi()/180) .* CosTeta;
for n = 1:nbrstep.(Input_Data.Headers)
    if myiter(n) == 0
    Time_Sim.timedaynbrN = 0;
    end
end

if Time_Sim.timedaynbrN > Time_Sim.Sixmtheq.(Input_Data.Headers)
    NtimedaynbrCNT = 1;
    Time_Sim.timedaynbrN = NtimedaynbrCNT;
else
    NtimedaynbrCNT = Time_Sim.timedaynbrN + 1;
    Time_Sim.timedaynbrN = NtimedaynbrCNT;
end

x = [1,Time_Sim.Sixmtheq.(Input_Data.Headers)/3,Time_Sim.Sixmtheq.(Input_Data.Headers)/3 * 2,Time_Sim.Sixmtheq.(Input_Data.Headers)]';
yC2     = [-0.069,-0.054,-0.049,-0.023]';
yTdirt  = [1,0.98,0.97,0.92]'; 
yar     = [0.17,0.20,0.21,0.27]';

C2Coeff     = polyfit(x,yC2,2)';
TdirtCoeff  = polyfit(x,yTdirt,2)';
arCoeff     = polyfit(x,yar,2)';

C2      = C2Coeff(3) + C2Coeff(2) * Time_Sim.timedaynbrN + C2Coeff(1) * Time_Sim.timedaynbrN ^2;
ar      = arCoeff(3) + arCoeff(2) * Time_Sim.timedaynbrN + arCoeff(1) * Time_Sim.timedaynbrN ^2;
Tdirt   = TdirtCoeff(3) + TdirtCoeff(2) * Time_Sim.timedaynbrN + TdirtCoeff(1) * Time_Sim.timedaynbrN ^2;

if Selection == 1 || Selection == 2 || Selection == 3 || Selection == 4
    C2 = -0.069;
    ar = 0.17;
    Tdirt = 1;
end
            
Betacorr = Beta * Tdirt .* (1-(exp(-CosTeta / ar) - exp(-1 / ar)) / (1-exp(-1 /ar)));

Deltacorr = Delta * Tdirt * (1-exp(-1/ar*(4/(3*pi())*sin(tilt * pi()/180)+(pi()- tilt * pi()/180 - sin(tilt * pi()/180))...
                        ./ (1+cos(tilt * pi()/180))) + C2 * (sin(tilt * pi()/180) + (pi()-tilt * pi()/180 - sin(tilt * pi()/180))/(1+cos(tilt * pi()/180)))^2));
Global_Irr = Betacorr + Deltacorr; 
%% Calculation of the PV-Panel Performances


if PhotoVol == 1
    if Selection == 5 || Selection == 0
        PowerPV1 = zeros(1,8760);
    for n = 1:nbrstep.(Input_Data.Headers)
        if Global_Irr(n) < 0
            Global_Irr(n) = 0;
        end
        [PowerPV] = PV_Panels1(Global_Irr(n), Sunrise(n), Sunset(n),Time_Sim,Input_Data, All_Var.Hourly_Temperature(n)',Housenbr,n);
        PowerPV1(n) = PowerPV;
    end
    PowerPV = PowerPV1;
    else
        n = 0;
        [PowerPV] = PV_Panels(Global_Irr, Sunrise, Sunset,Time_Sim,Input_Data, All_Var.Hourly_Temperature',Housenbr,n);
    end
else
    PowerPV = 0;
end 
%% Illuminance

Illuminance = (8.86 * Solar_zenith * pi()/180 + 210.12) .* G0.^0.9 + (-10.98 * ...
(Solar_zenith * pi()/180).^4 + 54.16 .* (Solar_zenith * pi()/180).^3 - 102.31 * (Solar_zenith * pi()/180).^2 + 90.21 .* Solar_zenith * pi()/180 - 29.24).* G0.^1.1;    
%%% Incident angle
ai = acos(cos((Solar_Azim - 180)*pi()/180) .* cos((SolAlt)*pi()/180));
Illuminancev = max(0,Illuminance .* cos(ai));
% Illuminance = (8.86 * Solar_zenith * pi()/180) * G0^0.9 + (-10.98 * ...
% (Solar_zenith * pi()/180)^4 + 54.16 * (Solar_zenith * pi()/180)^3 - 102.31 * (Solar_zenith * pi()/180)^2 + 90.21 * Solar_zenith * pi()/180 - 29.24)* G0^1.1;            
%% Output
Power = PowerPV';
Luminance = Illuminance';
Luminancev = Illuminancev;
PV_Spec.alpha(myiter + 1, 1) = MaxIrr;     

if All_Var.DebugMode == 1
    if myiter == nbrstep - 1
        FileName = dbstack() ;
        save(strcat(Output_Folder,filesep,Project_ID,filesep,filesep,'\Variable_File',filesep,FileName(1).name,'.mat'));
        %save(strcat(Output_Folder,filesep,Project_ID,filesep,filesep,FileName(1).name,'.mat'));
    end
end
varargout{1} = Time_Sim;
varargout{2} = Global_Irr;
