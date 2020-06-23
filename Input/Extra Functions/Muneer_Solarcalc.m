function [DEC,Solar_zenith,solar_time,Solar_Azim,SolAlt,Day_Length,Sunrise,Sunset] = Muneer_Solarcalc(varargin)

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

Time = datetime(Time,'ConvertFrom','datenum') ;
Cdeg = pi()/180 ;
IMT = Time.Month - 3 ;
IMT1= Time.Month + 9 ;
IMT2= Time.Month     ;
    if IMT2 > 2
        INTT_1 = fix(30.6 * IMT + 0.5);
        INTT_2 = fix(365.25 * (Time.Year - 1976));
    else
        INTT_1 = fix(30.6 * IMT1 + 0.5);
        INTT_2 = fix(365.25 * ((Time.Year - 1) - 1976));
    end

LSM = 45; 
UT = 12 + LSM/15;

SMLT = (UT/24 + Time.Day + INTT_1 + INTT_2 - 8707.5) / 36525;

CAPG = 357.528 + (35999.05 * SMLT);
if CAPG > 360
    G360_3 = fix(CAPG / 360);
    G360 = CAPG - (G360_3 * 360);
    CAPC = 1.915 * sin(G360 * Cdeg) + 0.02 * sin(2*G360 * Cdeg);
else
    CAPC = 1.915 * sin(CAPG* Cdeg) + 0.02 * sin(2*CAPG * Cdeg);
end

CAPL   = 280.46 + (36000.77 * SMLT) + CAPC;

if CAPL > 360
    XL_360 = CAPL - (fix(CAPL/360)*360);
else
    XL_360 = CAPL;
end
ALPHA = XL_360 - 2.466 * sin((2*XL_360) * Cdeg) + 0.053 * sin((4*XL_360) * Cdeg);
EPSILN = 23.4393 - (0.013 * SMLT) ;            
EOT = (XL_360 - CAPC - ALPHA) / 15;                                                        
DEC = atan(tan(EPSILN * Cdeg) * sin(ALPHA * Cdeg ))/ Cdeg;   

if LSM < 0
    cor = -(abs(LSM) - abs(Longitude)) / 15;
elseif LSM > 0
    cor = (abs(LSM) - abs(Longitude)) / 15;
else
    cor = - (Longitude/15);
end

cortrm = - EOT - cor;
TRM12 = -tan(Latitude * Cdeg) * tan(DEC * Cdeg);
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
solar_time = 15 * (Time.Hour - LSM/15 - 12) - (Longitude - (LSM/15 * 15));
Solar_zenith = acos(sin(DEC * Cdeg) * sin(Latitude * Cdeg) + cos(DEC * Cdeg) * cos(Latitude * Cdeg) * cos(solar_time * Cdeg)) * 1/Cdeg;

if floor(Sunrise) == Time.Hour
    AST = 0.5 * (Time_Sim.timehour + 1 + Sunrise);
elseif floor(Sunset) == Time.Hour
    AST = 0.5 * (Time.Hour + Sunrise);
else
    AST = (Time.Hour + 1) - 0.5;
end
horangsolaz = 15 * Cdeg * abs(12 - AST);

xdum   = sin(Latitude * Cdeg) * sin(DEC * Cdeg) + cos(Latitude * Cdeg) * cos(DEC * Cdeg) * cos(horangsolaz);
SolAlt = asin(xdum) * (180/pi());
xdumsolaz = (cos(DEC * Cdeg) * ((cos(Latitude * Cdeg) * tan(DEC * Cdeg)) - (sin(Latitude * Cdeg) * cos(horangsolaz)))) / cos(SolAlt * Cdeg);
           
if (Time.Hour + 1) > 12
    Solar_Azim = 360 - (acos(xdumsolaz)/Cdeg);
else
    Solar_Azim = acos(xdumsolaz)/Cdeg;
end