%% Solar Panels
%% Function call
function [Power, Luminance,Luminancev,varargout] = SolRad3(varargin)

Time_Sim = varargin{1};
Input_Data = varargin{2};
All_Var = varargin{3};
Housenbr = varargin{4};
Latitude =  str2double(Input_Data.Latitude);
Longitude = str2double(Input_Data.Longitude);
SolarData = Input_Data.SolarData ;
Tilt = str2double(Input_Data.Tilt) ;
Aspect = str2double(Input_Data.AspectThermal) ;
PhotoVol = str2double(Input_Data.PhotoVol) ;
myiter = Time_Sim.myiter;
nbrstep = Time_Sim.nbrstep.(Input_Data.Headers);
SimDetails = varargin{5};
Output_Folder = SimDetails.Output_Folder;
Project_ID = SimDetails.Project_ID;
Cdeg = pi()/180 ;

%% Initial data
    switch(SolarData)
        case 'Daily Data'
            Solar_Radiation = All_Var.Daily_Solar_Radiation;
        case 'Hourly Data'
            Solar_Radiation = All_Var.Hourly_Solar_RadiationTimed.DataOutput ;
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
                                                                                                   'Time',Time_Sim.TimeArray,...
                                                                                                   'Latitude',Latitude) ;
 else
    [DEC,Solar_zenith,solar_time,Solar_Azim,SolAlt,Day_Length,Sunrise,Sunset] = Muneer_Solarcalc('Longitude',Longitude,...
                                                                                                 'Time',Time_Sim.TimeArray,...
                                                                                                 'Latitude',Latitude)            ;
 end
Solar_Azim(isnan(Solar_Azim))=0 ;

%% Solar radiation decomposition from measured data 
% Get the Diffuse and Direct emissions from the measured data

% Linear interpolation between the measured data for lower time resolution
% in the simulation

% Lorenzo, E.
% Luque, A. & Hegedus, S. S. (Eds.)
% Energy Collected and Delivered by PV Modules 
% 20, Handbook of Photovoltaic Science and Engineerings, John Wiley & Sons Ltd, 2003, 1-66

switch(SolarData)
    case 'Hourly Data'
            SolarRad_Database = Solar_Radiation(1:min(size(SolAlt,1),size(Solar_Radiation,1))) ; %(myiter + 1) ;
            
            b0 = (1 + 0.033 * cos(360 * Time_Sim.timedayyearArray / 365 * Cdeg)) .* sin(SolAlt * Cdeg) * 1367;
            
            B0                          = b0 ;
            B0(B0<=1)                   = -1;
            B0(B0<=SolarRad_Database)   = -1;
%             if or(b0 <= 1,b0 <= SolarRad_Database)
%                B0 = -1;
%             else
%                B0 = b0; 
%             end
           Ktm = SolarRad_Database ./ B0;
           Ktm(B0>0 & B0 < SolarRad_Database) = 1 ;
           
%            if and(B0>0, B0 < SolarRad_Database)
%                Ktm = 1;
%            end
           Fd1 = 0.868 + 1.335 * Ktm - 5.782 * Ktm.^2 + 3.721 * Ktm.^3 ;
           Fd1(Ktm <= 0)                 = 1                                                     ;
           Fd1(Ktm > 0    & Ktm <= 0.13) = 0.952                                    ;
           Fd1(Ktm > 0.8)                = 0.141                                                 ;  
           
           diffuse = Fd1 .* SolarRad_Database;

           direct  = SolarRad_Database - diffuse;

           G0      = SolarRad_Database;     

           AM = (1 ./ sin(SolAlt * Cdeg)) ;
           E0 = 1 + 0.033 * cos(360 * Time_Sim.timedayyearArray / 365 * Cdeg);
           
           MaxIrr = 1367 * E0 .* (0.7.^(AM.^0.678)) ;
           
           MaxIrr(AM <= 0) = 0                               ;

   case ('Daily Data')

           E0 = 1 + 0.033 * cos(360 * Time_Sim.timedayyearArray / 365 * Cdeg);
           if Day_Length==24
               ws = 180                   ;
           elseif Day_Length==0
               ws = 0                     ;
           else
               ws = -acos(-tan(Latitude * Cdeg) * tan(DEC * Cdeg)) / (Cdeg);
           end

           B0d0 = 24 / pi() * 1367 * E0 * (-Cdeg * ws * sin(DEC * Cdeg) * sin(Latitude * Cdeg)-cos(DEC * Cdeg) * cos(Latitude * Cdeg) * sin(ws * Cdeg));

           Ktm = Solar_Radiation(myiter + 1) / B0d0;

           if Ktm <= 0
               Fd1 = 1;
           elseif Ktm <= 0.13
               Fd1 = 0.952;
           elseif and(Ktm > 0.13,Ktm <= 0.8)
               Fd1 = 0.868 + 1.335 * Ktm - 5.782 * Ktm^2 + 3.721 * Ktm^3;
           elseif Ktm > 0.8
               Fd1 = 0.141;
           end
           D0 = Fd1 * Solar_Radiation(myiter + 1);

           B0 = (1 + 0.033 * cos(360 * Time_Sim.timedayyear / 365 * Cdeg)) * sin(SolAlt * Cdeg) * 1367;
           if SolAlt > 0
               rd = pi()/24 * (cos(solar_time * Cdeg) - cos(ws * Cdeg))/(Cdeg * ws * cos(ws * Cdeg)-sin(ws * Cdeg));
               diffuse = D0 * rd;
           else
               rd = 0;
               diffuse = 0;
           end

            a  = 0.409 - 0.5016 * sin((ws + 60) * Cdeg);
            b  = 0.6609 + 0.4767 * sin((ws + 60) * Cdeg);
           rg = rd * (a + b * cos(solar_time * Cdeg));

           D1 = rg * Solar_Radiation(myiter + 1);

           if D1 - diffuse >= 0
               direct = D1 - diffuse;
           else
               direct = 0;
           end

           G0 = direct + diffuse;
end
%% Calculate the Aspect of the solart panels
% Should be equal to the azimuth angle

Alpha = acos((sin(SolAlt * Cdeg) * sin(Latitude * Cdeg) - sin(DEC * Cdeg)) ./ (cos(SolAlt * Cdeg)*cos(Latitude * Cdeg))) * 180/pi();
Alpha(diffuse == 0) = 90 ;
if Aspect >= 0
    Alpha(:) = 180-Aspect; %abs(180-Aspect);
% elseif diffuse == 0
%     Alpha(:) = 90;   
end
% try
%     Time_Sim.Alpha(end+1) = Alpha ;
% catch
%     Time_Sim.Alpha(1) = Alpha ;
% end
% 
% try
%     Time_Sim.Solar_Azim(end+1) = Solar_Azim ;
% catch
%     Time_Sim.Solar_Azim(1) = Solar_Azim ;
% end

tilt            = acos(sin(SolAlt * Cdeg)) * 180/pi() ;
tilt(diffuse == 0) = 90 ;

if Tilt >= 0
    tilt(:) = Tilt;
% elseif diffuse == 0
%     tilt(:) = 90;
end 

% try
%     Time_Sim.tilt(end+1) = tilt ;
% catch
%     Time_Sim.tilt(1) = tilt ;
% end

% try
%     Time_Sim.Solar_zenith(end+1) = Solar_zenith ;
% catch
%     Time_Sim.Solar_zenith(1) = Solar_zenith ;
% end

funcaspect = sin(DEC * Cdeg) * sin(Latitude * Cdeg) .* cos(tilt * Cdeg) - ...
             Sign_Latitude * sin(DEC * Cdeg) * cos(Latitude * Cdeg) .* sin(tilt * Cdeg) .* cos(Alpha * Cdeg) + ...
             cos(DEC * Cdeg) * cos(Latitude * Cdeg) .* cos(tilt * Cdeg) .* cos(solar_time * Cdeg) + ...
             Sign_Latitude * cos(DEC * Cdeg) * sin(Latitude * Cdeg) .* sin(tilt * Cdeg) .* cos(Alpha * Cdeg) .* cos(solar_time * Cdeg) + ...
             cos(DEC * Cdeg) .* sin(Alpha * Cdeg) .* sin(solar_time * Cdeg) .* sin(tilt * Cdeg);

CosTeta = funcaspect;         
CosTeta(diffuse    == 0) = 0 ;
CosTeta(funcaspect <= 0) = 0 ;
% if or(diffuse == 0, funcaspect <= 0)
%     CosTeta = 0;
% else
%     CosTeta = funcaspect;
% end

Beta =  direct ./ sin(max(10,SolAlt) * Cdeg) .* CosTeta;
Delta = diffuse .* (1 - direct ./ B0) .* (1 + cos(tilt * Cdeg) / 2) + ...
       (diffuse .* direct ./ B0) ./ sin(max(10,SolAlt) * Cdeg) .* CosTeta;
% if myiter == 0
%     Time_Sim.timedaynbrN = 0;
% end

j = 0 ;
timedaynbrNArray = zeros(size(Time_Sim.timedaynbrNArray,1),1) ;
for ij = 1:size(Time_Sim.timedaynbrNArray,1)
    if mod(Time_Sim.timedaynbrNArray(ij)/183,183) == 0                            
        j = Time_Sim.timedaynbrNArray(ij) / 183   ;
    end
    timedaynbrNArray(ij, 1) = ((Time_Sim.timedaynbrNArray(ij) / 183) - j) * 183 ;
end
% if Time_Sim.timedaynbrNArray > Time_Sim.Sixmtheq.(Input_Data.Headers)
%     NtimedaynbrCNT = 1;
%     Time_Sim.timedaynbrN = NtimedaynbrCNT;
% else
%     NtimedaynbrCNT = Time_Sim.timedaynbrN + 1;
%     Time_Sim.timedaynbrN = NtimedaynbrCNT;
% end

x = [1,Time_Sim.Sixmtheq.(Input_Data.Headers)/3,Time_Sim.Sixmtheq.(Input_Data.Headers)/3 * 2,Time_Sim.Sixmtheq.(Input_Data.Headers)]';
yC2     = [-0.069,-0.054,-0.049,-0.023]';
yTdirt  = [1,0.98,0.97,0.92]'; 
yar     = [0.17,0.20,0.21,0.27]';

% [C2Coeff, ~, mu] = polyfit(x,yC2,2) ;
% C2 = polyval(C2Coeff,timedaynbrNArray,[],mu) ;

outputarray = lin_inter(x,yC2,'linear');

Replicate = ceil(size(Beta,1) / size(outputarray,1)) ;
C2 = repmat(outputarray(:,2),Replicate,1) ;

C2 = C2(1:size(Beta,1),1) ;

% C2Coeff     = polyfit(x,yC2,2)';
% [TdirtCoeff, ~, mu] = polyfit(x,yTdirt,2) ;
% ar = polyval(TdirtCoeff,timedaynbrNArray,[],mu) ;

outputarray = lin_inter(x,yTdirt,'linear');

Replicate = ceil(size(Beta,1) / size(outputarray,1)) ;
Tdirt = repmat(outputarray(:,2),Replicate,1) ;

Tdirt = Tdirt(1:size(Beta,1),1) ;

% TdirtCoeff  = polyfit(x,yTdirt,2)';
% [arCoeff, ~, mu] = polyfit(x,yar,2) ;
% Tdirt = polyval(arCoeff,timedaynbrNArray,[],mu) ;

outputarray = lin_inter(x,yar,'linear');

Replicate = ceil(size(Beta,1) / size(outputarray,1)) ;
ar = repmat(outputarray(:,2),Replicate,1) ;

ar = ar(1:size(Beta,1),1) ;

% arCoeff     = polyfit(x,yar,2)';

% C2      = C2Coeff(3) + C2Coeff(2) * Time_Sim.timedaynbrN + C2Coeff(1) * Time_Sim.timedaynbrN ^2;
% ar      = arCoeff(3) + arCoeff(2) * Time_Sim.timedaynbrN + arCoeff(1) * Time_Sim.timedaynbrN ^2;
% Tdirt   = TdirtCoeff(3) + TdirtCoeff(2) * Time_Sim.timedaynbrN + TdirtCoeff(1) * Time_Sim.timedaynbrN ^2;

OtherArray = 1 - (exp(-CosTeta ./ ar) - exp(-1 ./ ar)) ./ (1-exp(-1 ./ar));

Betacorr = Beta .* Tdirt .* OtherArray(:,1) ;
 
Deltacorr = Delta .* Tdirt .* (1-exp( -1./ar .* ...
                     ( 4 / (3*pi()) * sin(tilt * Cdeg) + (pi() - tilt * Cdeg - sin(tilt * Cdeg)) ./ (1+cos(tilt * Cdeg))) + ...
                     C2 .* ...
                     (sin(tilt * Cdeg) + (pi()-tilt * Cdeg - sin(tilt * Cdeg))./(1+cos(tilt * Cdeg))).^2));
Global_Irr = Betacorr + Deltacorr; 
%% Calculation of the PV-Panel Performances

if PhotoVol == 1
    [PowerPV] = PV_Panels(Global_Irr, Sunrise, Sunset,Time_Sim,Input_Data, All_Var.Hourly_Temperature',Housenbr);
else
    PowerPV = zeros(size(Global_Irr,1),1) ;
end 
%% Illuminance

Illuminance =   (8.86 * Solar_zenith * Cdeg + 210.12) .* G0.^0.9 + ...
                (-10.98 * (Solar_zenith * Cdeg).^4 + 54.16 * (Solar_zenith * Cdeg).^3 - 102.31 * (Solar_zenith * Cdeg).^2 + 90.21 * Solar_zenith * Cdeg - 29.24)...
                .* G0.^1.1;    
%%% Incident angle
ai = acos(cos((Solar_Azim - 180)*Cdeg) .* cos((SolAlt)*Cdeg));
Illuminancev = max(0,Illuminance .* cos(ai));
% Illuminance = (8.86 * Solar_zenith * Cdeg) * G0^0.9 + (-10.98 * ...
% (Solar_zenith * Cdeg)^4 + 54.16 * (Solar_zenith * Cdeg)^3 - 102.31 * (Solar_zenith * Cdeg)^2 + 90.21 * Solar_zenith * Cdeg - 29.24)* G0^1.1;            
%% Output
Power = PowerPV;
Luminance = Illuminance';
Luminancev = Illuminancev;
% PV_Spec.alpha(myiter + 1, 1) = Global_Irr;     

if All_Var.DebugMode == 1
    if myiter == nbrstep - 1
        FileName = dbstack() ;
        save(strcat(Output_Folder,filesep,Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'),'PV_Spec');
        %save(strcat(Output_Folder,filesep,Project_ID,filesep,FileName(1).name,'.mat'));
    end
end

varargout{1} = Time_Sim;
varargout{2} = Global_Irr;
