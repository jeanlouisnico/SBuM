%% Luque Solar calculation

function [ZENITH, AZIMUTH, delta, t_h,SolAlt,Day_Length,Sunrise,Sunset] = Luque_SolarCalc(varargin)

if nargin <= 1
    if nargin == 0
        Time = now ;
    else
        Time = varargin{1} ;
    end
    Variable.Latitude  = 65.0166667 ; % This is for Oulu
    Variable.Longitude = 25.4666667 ; % This is for Oulu
    
    % Set pre-defined variable    
    Latitude = Variable.Latitude ;
    Longitude = Variable.Longitude ;
else
    if mod(nargin,2)
        error('wrong number of pairs associated')
    end
    
    for i = 1:2:nargin
        Var2Def = varargin{i} ;
        
        Var2Def_Value = varargin{i + 1} ;
        Variable.(Var2Def) = Var2Def_Value ;
    end
    
    % Check for missing variable
    try
        % Phi is the Latitude
        Latitude = Variable.Latitude ;
    catch
        Variable.Latitude = 65.0166667 ; % This is for Oulu
        Latitude = Variable.Latitude ;
    end
    
    try
        % Phi is the Latitude
        Time = Variable.Time ;
    catch
        Variable.Time = now ;
        Time = Variable.Time ;
    end
    try
        % Phi is the Latitude
        Longitude = Variable.Longitude ;
    catch
        Variable.Longitude = 25.4666667 ; % This is for Oulu
        Longitude = Variable.Longitude  ;
    end
end

Cdeg = pi()/180 ;

[zd,~,~] = timezone(Longitude,'degrees') ;
rot = 0; % [arc-degrees] rotation clockwise from north
TZ =  -(zd) ; % [hrs] offset from UTC, during standard time
DST = true; % local time is daylight savings time

[angles,~,delta,t_h,SolAlt] = solarPosition(Time,Latitude,Longitude,TZ,rot,DST);
ZENITH = angles(:,1) ;
AZIMUTH = angles(:,2) ;

TRM12 = -tan(Latitude * Cdeg) * tan(delta * Cdeg);
if TRM12 < -0.99999  
    Day_Length = 24  ;
elseif TRM12 > 0.9999
    Day_Length = 0   ;
else
    Day_Length = (2/15) * acos(TRM12) / Cdeg;
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

% % Number of dy since the beginning of the year
% ReferenceYear = datenum(year(Time),1,1) ;
% 
% dn = ceil(Time - ReferenceYear) + 1 
% % r0 the distnace frmo the sun and is set to 1.496*10^8
% r0 = 1.496*10^8 ;
% % Distance from the sun to the Earth
% r = r0 * ( 1 + 0.017 * sin( ((360 * (dn - 93))/365 ) * Cdeg )) 
% 
% % eccentricity correction factor
% epsilon0 = 1 + 0.033 * cos(((360 * dn) / 365) * Cdeg)
% 
% % solar declination
% % The maximum variation in ? over 24 h is less than 0.5?
% delta = 23.45 * sin(((360 * (dn + 284))/365) * Cdeg)
% 
% % true solar time (?)
% 
% [zd,~,~] = timezone(Longitude,'degrees') ;
% TimeZoneStr = ['Etc/GMT',num2str(zd)] ;
% t = datetime(Time,'ConvertFrom','datenum','TimeZone',TimeZoneStr) ;
% targetDST = TimezoneConvert( t, t.TimeZone, 'UTC' ) ;
% FormatDateSAT = 'yyyy/mm/dd HH:MM:SS' ;
% UTC = datestr(targetDST,FormatDateSAT ) ;
% [SAT,SMT] = UTC2SolarApparentTime(targetDST,Longitude) ;
% 
% omega = 15 * (hour(Time) - (-zd) - 12) - (Longitude - (LSM/15 * 15));
% % ? = 15 × (TO ? AO ? 12) ? (LL ? LH)
% % solar zenith angle ?ZS
% Theta_ZS = acos(sin(delta * Cdeg) * sin(Phi * Cdeg) + cos(delta * Cdeg) * cos(Phi * Cdeg) * cos(omega * Cdeg)) * 1 / Cdeg 