%% Solar Panels
%% Function call
function [Power, Luminance,Luminancev,varargout] = SolRad(varargin)

Time_Sim = varargin{1};
Input_Data = varargin{2};
All_Var = varargin{3};
Housenbr = varargin{4};
Latitude =  str2double(Input_Data.Latitude);
Longitude = str2double(Input_Data.Longitude);
SolarData = Input_Data.SolarData ;
Tilt = str2double(Input_Data.Tilt) ;
Aspect = str2double(Input_Data.Aspect) ;
PhotoVol = str2double(Input_Data.PhotoVol) ;
myiter = Time_Sim.myiter;
nbrstep = Time_Sim.nbrstep;
SimDetails = varargin{5};
Output_Folder = SimDetails.Output_Folder;
Project_ID = SimDetails.Project_ID;
Cdeg = pi()/180 ;

%% Initial data
    switch(SolarData)
        case 'Daily Data'
            Solar_Radiation = All_Var.Daily_Solar_Radiation;
        case 'Hourly Data'
            Solar_Radiation = All_Var.Hourly_Solar_Radiation;
    end
    
if Latitude < 0
    Sign_Latitude = -1 ;     
else
    Sign_Latitude = 1 ;   
end
%% Solar coordinates calculation
 Choose_Method = 1 ;
% 
  if Choose_Method == 1
    [Solar_zenith, Solar_Azim, DEC, solar_time,SolAlt,Day_Length,Sunrise,Sunset] = Luque_SolarCalc('Longitude',Longitude,...
                                                                                                   'Time',Time_Sim.SimTime,...
                                                                                                   'Latitude',Latitude) ;
 else
    [DEC,Solar_zenith,solar_time,Solar_Azim,SolAlt,Day_Length,Sunrise,Sunset] = Muneer_Solarcalc('Longitude',Longitude,...
                                                                                                 'Time',Time_Sim.SimTime,...
                                                                                                 'Latitude',Latitude)            ;
 end
Solar_Azim(isnan(Solar_Azim))=0 ;

%% Solar radiation decomposition from measured data 
% Get the Diffuse and Direct emissions from the measured data
switch(SolarData)
    case 'Hourly Data' 
            %                   if strcmp('Hourly Data',SolarData);
            b0 = (1 + 0.033 * cosd(360 * Time_Sim.timedayyear / 365 * Cdeg)) * sind(SolAlt * Cdeg) * 1367;
            if or(b0 <= 1,b0 <= Solar_Radiation(Time_Sim.Timeoffset + myiter+1))
               B0 = -1;
            else
               B0 = b0; 
            end
           Ktm = Solar_Radiation(Time_Sim.Timeoffset + myiter+1) / B0;
           if and(B0>0, B0 < Solar_Radiation(Time_Sim.Timeoffset + myiter+1))
               Ktm = 1;
           end
           if Ktm <= 0
               Fd1 = 1;
           elseif Ktm <= 0.13
               Fd1 = 0.952;
           elseif and(Ktm > 0.13,Ktm <= 0.8)
               Fd1 = 0.868 + 1.335 * Ktm - 5.782 * Ktm^2 + 3.721 * Ktm^3;
           elseif Ktm > 0.8
               Fd1 = 0.141;
           end
           diffuse = Fd1 * Solar_Radiation(Time_Sim.Timeoffset + myiter+1);

           direct  = Solar_Radiation(Time_Sim.Timeoffset + myiter+1) - diffuse;

           G0      = Solar_Radiation(Time_Sim.Timeoffset + myiter+1);     

           AM = 1 / sind(SolAlt * Cdeg);
           E0 = 1 + 0.033 * cosd(360 * Time_Sim.timedayyear / 365 * Cdeg);

           if AM <= 0
               MaxIrr = 0;
           else 
               MaxIrr = 1367 * E0 * (0.7^(AM^0.678));
           end  

   case ('Daily Data')

           E0 = 1 + 0.033 * cosd(360 * Time_Sim.timedayyear / 365 * Cdeg);
           if Day_Length==24
               ws = 180                   ;
           elseif Day_Length==0
               ws = 0                     ;
           else
               ws = -acosd(-tan(Latitude * Cdeg) * tan(DEC * Cdeg)) / (Cdeg);
           end

           B0d0 = 24 / pi() * 1367 * E0 * (-Cdeg * ws * sind(DEC * Cdeg) * sind(Latitude * Cdeg)-cosd(DEC * Cdeg) * cosd(Latitude * Cdeg) * sind(ws * Cdeg));

           Ktm = Solar_Radiation(Time_Sim.Timeoffset + myiter+1) / B0d0;

           if Ktm <= 0
               Fd1 = 1;
           elseif Ktm <= 0.13
               Fd1 = 0.952;
           elseif and(Ktm > 0.13,Ktm <= 0.8)
               Fd1 = 0.868 + 1.335 * Ktm - 5.782 * Ktm^2 + 3.721 * Ktm^3;
           elseif Ktm > 0.8
               Fd1 = 0.141;
           end
           D0 = Fd1 * Solar_Radiation(Time_Sim.Timeoffset + myiter+1);

           B0 = (1 + 0.033 * cosd(360 * Time_Sim.timedayyear / 365 * Cdeg)) * sind(SolAlt * Cdeg) * 1367;
           if SolAlt > 0
               rd = pi()/24 * (cosd(solar_time * Cdeg) - cosd(ws * Cdeg))/(Cdeg * ws * cosd(ws * Cdeg)-sind(ws * Cdeg));
               diffuse = D0 * rd;
           else
               rd = 0;
               diffuse = 0;
           end

            a  = 0.409 - 0.5016 * sind((ws + 60) * Cdeg);
            b  = 0.6609 + 0.4767 * sind((ws + 60) * Cdeg);
           rg = rd * (a + b * cosd(solar_time * Cdeg));

           D1 = rg * Solar_Radiation(Time_Sim.Timeoffset + myiter+1);

           if D1 - diffuse >= 0
               direct = D1 - diffuse;
           else
               direct = 0;
           end

           G0 = direct + diffuse;
end
%% Calculate the Aspect of the solart panels

if Aspect >= 0
    Alpha = abs(180-Aspect);
elseif diffuse == 0
    Alpha = 90;
else
    % Should be equal to the azimuth angle
   Alpha = acos((sind(SolAlt * Cdeg) * sind(Latitude * Cdeg) - sind(DEC * Cdeg)) / (cosd(SolAlt * Cdeg)*cosd(Latitude * Cdeg))) * 180/pi();
end
try
    Time_Sim.Alpha(end+1) = Alpha ;
catch
    Time_Sim.Alpha(1) = Alpha ;
end

try
    Time_Sim.Solar_Azim(end+1) = Solar_Azim ;
catch
    Time_Sim.Solar_Azim(1) = Solar_Azim ;
end

if Tilt >= 0
    tilt = Tilt;
elseif diffuse == 0
    tilt = 90;
else
    % Should be equal to the zenith angle
    tilt = acos(sind(SolAlt * Cdeg)) * 180/pi();
end 

try
    Time_Sim.tilt(end+1) = tilt ;
catch
    Time_Sim.tilt(1) = tilt ;
end

try
    Time_Sim.Solar_zenith(end+1) = Solar_zenith ;
catch
    Time_Sim.Solar_zenith(1) = Solar_zenith ;
end

funcaspect = sind(DEC * Cdeg) * sind(Latitude * Cdeg) * cosd(tilt * Cdeg) - ...
             Sign_Latitude * sind(DEC * Cdeg) * cosd(Latitude * Cdeg) * sind(tilt * Cdeg) * cosd(Alpha * Cdeg) + ...
             cosd(DEC * Cdeg) * cosd(Latitude * Cdeg) * cosd(tilt * Cdeg) * cosd(solar_time * Cdeg) + ...
             Sign_Latitude * cosd(DEC * Cdeg) * sind(Latitude * Cdeg) * sind(tilt * Cdeg) * cosd(Alpha * Cdeg) * cosd(solar_time * Cdeg) + ...
             cosd(DEC * Cdeg) * sind(Alpha * Cdeg) * sind(solar_time * Cdeg) * sind(tilt * Cdeg);
         
if or(diffuse == 0, funcaspect <= 0)
    CosTeta = 0;
else
    CosTeta = funcaspect;
end

Beta =  direct / sind(max(10,SolAlt) * Cdeg) * CosTeta;
Delta = diffuse * (1 - direct / B0) * (1 + cosd(tilt * Cdeg) / 2) + (diffuse * direct / B0) / sind(max(10,SolAlt) * Cdeg) * CosTeta;
if myiter == 0
    Time_Sim.timedaynbrN = 0;
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
            
Betacorr = Beta * Tdirt * (1-(exp(-CosTeta / ar) - exp(-1 / ar)) / (1-exp(-1 /ar)));

Deltacorr = Delta * Tdirt * (1-exp(-1/ar*(4/(3*pi())*sin(tilt * Cdeg)+(pi()- tilt * Cdeg - sin(tilt * Cdeg))...
                        / (1+cosd(tilt * Cdeg))) + C2 * (sind(tilt * Cdeg) + (pi()-tilt * Cdeg - sind(tilt * Cdeg))/(1+cosd(tilt * Cdeg)))^2));
Global_Irr = Betacorr + Deltacorr; 
%% Calculation of the PV-Panel Performances

if PhotoVol == 1
    [PowerPV] = PV_Panels(Global_Irr, Sunrise, Sunset,Time_Sim,Input_Data, All_Var.Hourly_Temperature',Housenbr);
else
    PowerPV = 0;
end 
%% Illuminance

Illuminance = (8.86 * Solar_zenith * Cdeg + 210.12) * G0^0.9 + (-10.98 * ...
(Solar_zenith * Cdeg)^4 + 54.16 * (Solar_zenith * Cdeg)^3 - 102.31 * (Solar_zenith * Cdeg)^2 + 90.21 * Solar_zenith * Cdeg - 29.24)* G0^1.1;    
%%% Incident angle
ai = acos(cos((Solar_Azim - 180)*Cdeg) * cos((SolAlt)*Cdeg));
Illuminancev = max(0,Illuminance * cos(ai));
% Illuminance = (8.86 * Solar_zenith * Cdeg) * G0^0.9 + (-10.98 * ...
% (Solar_zenith * Cdeg)^4 + 54.16 * (Solar_zenith * Cdeg)^3 - 102.31 * (Solar_zenith * Cdeg)^2 + 90.21 * Solar_zenith * Cdeg - 29.24)* G0^1.1;            
%% Output
Power = PowerPV';
Luminance = Illuminance';
Luminancev = Illuminancev;
PV_Spec.alpha(myiter + 1, 1) = MaxIrr;     

if All_Var.DebugMode == 1
    if myiter == nbrstep - 1
        FileName = dbstack() ;
        save(strcat(Output_Folder,filesep,Project_ID,filesep,filesep,'Variable_File',filesep,FileName(1).name,'.mat'));
        %save(strcat(Output_Folder,filesep,Project_ID,filesep,filesep,FileName(1).name,'.mat'));
    end
end

varargout{1} = Time_Sim;
varargout{2} = Global_Irr;
