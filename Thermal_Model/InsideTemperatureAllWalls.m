function [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperatureAllWalls(varargin)
%% Inside Temperature calculation function
% This is the function for calculating the inside Temperature and radiative
% Temperature of the building. This calculation procedRre is taken from an
% international standard EN ISO 52016-1:2017. This is part of the EPB
% standards, which were defined to be created in EU directive on energy
% performance of buildings. This is considered as an hoRrly model, so
% hoRrly calculation procedRre of internal Temperatures is used. The system
% is condidered to be a single zone system including the whole building,
% without any adjustments. Thus, the same Temperature should be all around
% the building. The system includes 5 nodes in each of the opaque building
% elements, and 2 with windows and doors. The themal mass of the building
% is included in the nodal calculations. The calculations are for sensible 
% heat only. Assumptions are discussed in the standard, as well as the 
% equations. Convective heating fractions are from EN 15316-2:2017.

%% Inputs

uvs                         = varargin{1};
uve                         = varargin{2};
uvw                         = varargin{3};
uvn                         = varargin{4};
    
uvsw                        = varargin{5};
uvew                        = varargin{6};
uvnw                        = varargin{7};
uvww                        = varargin{8};
    
uvd                         = varargin{9};
    
uvf                         = varargin{10};
uvr                         = varargin{11};

hgt                         = varargin{12};
lgts                        = varargin{13};
lgte                        = varargin{14};
pitch                       = varargin{15};
aws                         = varargin{16};
awe                         = varargin{17};
awn                         = varargin{18};
aww                         = varargin{19};
ad                          = varargin{20};

A_roof                      = varargin{21};
A_floor                     = varargin{22};

House_Volume                = varargin{23};

Building_envelope           = varargin{24};

Building_Thermal_mass       = varargin{25};

Air_Leak                    = varargin{26};
Ventilation_Type            = varargin{27};
Flow_rate                   = varargin{28}; 

Internal_Heat_Gain          = varargin{29};

Solar_Radiation_N           = varargin{30};
Solar_Radiation_E           = varargin{31};
Solar_Radiation_S           = varargin{32};
Solar_Radiation_W           = varargin{33};

Global_Radiation            = varargin{34};

Heater_Power                = varargin{36};

Solar_Heat_Gain             = varargin{35};

Temperature                 = varargin{37};
T_ground                    = varargin{38};
T_inlet                     = varargin{39};

Temperatures_nodal          = varargin{40}; %varargin{35};

CHTCvalue                   = varargin{41};

TimeStep                    = varargin{42} * 60;

WallThermalClass            = varargin{43};

RoofThermalClass            = varargin{44};

FloorThermalClass           = varargin{45};

alfaOpaque                  = varargin{46};

WallThermalCapacity         = varargin{47};
RoofThermalCapacity         = varargin{48};
FloorThermalCapacity        = varargin{49};

% Solar_Radiation             = varargin{36};
% Global_Radiation            = varargin{37};

%% Variables from the standards
% Variables used in the calculations that are defined in the standards.

% ISO 13789:2017
% Convective and radiative sRrface heat transfer coefficients.

hci_h   = 2.5;
hci_u   = 5;
hci_d   = 0.7;
hce     = CHTCvalue; % 20;
hceD    = 20;
hri     = 5.13;
hre     = 4.14;

RsiHor  = 0.13;
RsiUp   = 0.10;
RsiDown = 0.17;

Rse     = 0.04;

% ISO 52016-1:2017
% Difference between sky and outside air Temperature
deltaSky = 11;  % For intermediate zones

% View factor to the sky
Fskyr = 1;
Fskyv = 0.5;

% Opaque material solar absorption coefficient
asol = alfaOpaque;     % For intermediate color and default value

% Convective fractions
fi = 0.4;
fs = 0.1;
fh = 1; %0.7; %0.4;

% Thermal mass of air and fRrnitRres
Air_capacitance = 10000/TimeStep;


%% Calculations for the variables used in the matrices
% Here the variables required in the matrices are calculated from the input
% values. 

% First the areas in the building
A_swall = lgts * hgt - aws - ad;  
A_nwall = lgts * hgt - awn;
A_ewall = lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - awe;
A_wwall = lgte * hgt + 0.5 * (tand(pitch) * lgte^2) - aww;

% A_wall = A_swall + A_nwall + A_ewall + A_wwall;

A_wind  = aws + awn + awe + aww;
A_door  = ad;

% Calculation of the ventilation
Hve = (Flow_rate * House_Volume * 1.2 * 1.007)/3.6;     % Hve needs to be in W/K. Flow rate is in 1/h, House volume in m3, heat capacity per air volume kJ/m3K, thus division by 3.6.

% Calculation of opaque elements thermal masses and conductances

% Walls

% uw = (uvs * A_swall + uve * A_ewall + uvn * A_nwall + uvw * A_wwall)/(A_swall + A_ewall + A_nwall + A_wwall); % Thermal transimittance value with weighted areal average.
Rws = ((1/uvs) - RsiHor - Rse);            % Calculation accoring to ISO 6946:2017. Rsi & Rse values (0.13 & 0.04) from the same standard
Rww = ((1/uvw) - RsiHor - Rse);
Rwn = ((1/uvn) - RsiHor - Rse);
Rwe = ((1/uve) - RsiHor - Rse);
% Rw = (1/((1/Rw) - (1/hci_h) - (1/hce) - (1/hri) - (1/hre)));                            % The corrected U-value for the wall without sRrface transfer coefficients
% Wall_capacitanceTot = ((Building_Thermal_mass * A_floor)/Building_envelope)/TimeStep;    % The building thermall mass is in Wh/m2K for the building area, it needs to be transferred into Wh/m2K per construction element. All the elements are considered to have equal amount of thermal mass.

switch(WallThermalCapacity)
   
    case 'Very light'
        
        Wall_capacitanceTot = 50000/TimeStep;
        
    case 'Light'
        
        Wall_capacitanceTot = 75000/TimeStep;
    
    case 'Medium'
        
        Wall_capacitanceTot = 110000/TimeStep;
        
    case 'Heavy'
        
        Wall_capacitanceTot = 175000/TimeStep;
        
    case 'Very heavy'
        
        Wall_capacitanceTot = 250000/TimeStep;
        
end

switch(WallThermalClass)
    
    case 'ClassI'
        
        Wall_capacitance = [0 0 0 0 Wall_capacitanceTot];
        
    case 'ClassE'
        
        Wall_capacitance = [Wall_capacitanceTot 0 0 0 0];
        
    case 'ClassIE' 
        
        Wall_capacitance = [Wall_capacitanceTot/2 0 0 0 Wall_capacitanceTot/2];
        
    case 'ClassD'
        
        Wall_capacitance = [Wall_capacitanceTot/8 Wall_capacitanceTot/4 Wall_capacitanceTot/4 Wall_capacitanceTot/4 Wall_capacitanceTot/8];
        
    case 'ClassM'
        
        Wall_capacitance = [0 0 Wall_capacitanceTot 0 0];
        
end

% Roof

Rr = (1/uvr) - RsiUp - Rse;             % Calculation from ISO 6946:2017. Rsi & Rse values from the same standard.
% Rr = (1/((1/Rr) - (1/hci_u) - (1/hce) - (1/hri) - (1/hre)));
% Roof_capacitance = Wall_capacitanceTot;

switch(RoofThermalCapacity)
   
    case 'Very light'
        
        Roof_capacitanceTot = 50000/TimeStep;
        
    case 'Light'
        
        Roof_capacitanceTot = 75000/TimeStep;
    
    case 'Medium'
        
        Roof_capacitanceTot = 110000/TimeStep;
        
    case 'Heavy'
        
        Roof_capacitanceTot = 175000/TimeStep;
        
    case 'Very heavy'
        
        Roof_capacitanceTot = 250000/TimeStep;
        
end

switch(RoofThermalClass)
    
    case 'ClassI'
        
        Roof_capacitance = [0 0 0 0 Roof_capacitanceTot];
        
    case 'ClassE'
        
        Roof_capacitance = [Roof_capacitanceTot 0 0 0 0];
        
    case 'ClassIE' 
        
        Roof_capacitance = [Roof_capacitanceTot/2 0 0 0 Roof_capacitanceTot/2];
        
    case 'ClassD'
        
        Roof_capacitance = [Roof_capacitanceTot/8 Roof_capacitanceTot/4 Roof_capacitanceTot/4 Roof_capacitanceTot/4 Roof_capacitanceTot/8];
        
    case 'ClassM'
        
        Roof_capacitance = [0 0 Roof_capacitanceTot 0 0];
        
end

% Floor

Rfg = (1/uvf) - RsiDown - Rse;
% Floor_capacitance = Wall_capacitanceTot;
Ground_capacitance = (2000000 * 0.5)/TimeStep;              % Thermal capacity of 0.5m deep ground. J changed to Wh.

switch(FloorThermalCapacity)
   
    case 'Very light'
        
        Floor_capacitanceTot = 50000/TimeStep;
        
    case 'Light'
        
        Floor_capacitanceTot = 75000/TimeStep;
    
    case 'Medium'
        
        Floor_capacitanceTot = 110000/TimeStep;
        
    case 'Heavy'
        
        Floor_capacitanceTot = 175000/TimeStep;
        
    case 'Very heavy'
        
        Floor_capacitanceTot = 250000/TimeStep;
        
end

switch(FloorThermalClass)
    
    case 'ClassI'
        
        Floor_capacitance = [0 Ground_capacitance 0 0 Floor_capacitanceTot];
        
    case 'ClassE'
        
        Floor_capacitance = [0 Ground_capacitance Floor_capacitanceTot 0 0];
        
    case 'ClassIE' 
        
        Floor_capacitance = [0 Ground_capacitance Floor_capacitanceTot/2 0 Floor_capacitanceTot/2];
        
    case 'ClassD'
        
        Floor_capacitance = [0 Ground_capacitance Floor_capacitanceTot/4 Floor_capacitanceTot/2 Floor_capacitanceTot/4];
        
    case 'ClassM'
        
        Floor_capacitance = [0 Ground_capacitance 0 Floor_capacitanceTot 0];
        
end

% Calculation of ground's thermal capacity & thermal conductance. Sand or
% gravel is assumed as the ground type as discussed in ISO 13370:2017

Ug              = 1/(0.5/2);                        % Thermal conductance of 0.5m deep ground
Rg              = 1/Ug;                             % Needed for the virtual ground layer calculations
hg              = 2/Rg;

                                         
% The effect of virtual ground layer is considered to be fixed by building.
% This example is calculated with an example from RIL 249-2009 for 2010
% building regulation level insulation. They estimated that the insulation
% leyer is ~0.2m deep with an insulation material transmittance value of
% ~0.036. This gives value for Rf, which is then used in equation of 
% Rvi = (1/U) - Rsi - Rf - Rg; This gives the virtual ground layer's 
% thermal resistance. Thus, it is assumed the change in overall thermal 
% transmittance value comes from the change in thermal resistance value of 
% floor. Calculation for the resistance of virtual ground layer from 
% ISO 13370:2017.

Rf = 0.2/0.036;
Rvi = (1/0.16) - RsiDown - Rf - Rg;                    % U is equal to 2010 regulation value for slab on ground, Rsi is from ISO 6946:2017 for downwards flowing heat.

hf2 = (1/((Rfg/4)+(Rg/2)));                         % One of the nodal transmittances from ISO 52016-1:2017


% Windows and doors thermal conductance

% uvw = (uvsw * aws + uvew * awe + uvnw * awn + uvww * aww)/A_wind; % Area weighted mean value of the U-values of windows.
Rwsd = ((1/uvsw) - RsiHor - Rse);      % U-value of windows when reducing sRrface transfers. 0.13 and 0.04 are from ISO 52016-1:2017
Rwwd = ((1/uvww) - RsiHor - Rse);
Rwnd = ((1/uvnw) - RsiHor - Rse);
Rwed = ((1/uvew) - RsiHor - Rse);


ud = (1/((1/uvd) - RsiHor - Rse));       % Same as with window

% Internal heat gain needs to declude solar heat gain
Internal_Heat_Gain = Internal_Heat_Gain - Solar_Heat_Gain;

%% Temperature calculation according to the standard

MatrixA = [Wall_capacitance(1) + hce(1) + hre + 6/Rws, -6/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    -6/Rws, Wall_capacitance(2) + 3/Rws + 6/Rws, -3/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, -3/Rws, Wall_capacitance(3) + 3/Rws + 3/Rws, -3/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, -3/Rws, Wall_capacitance(4) + 6/Rws + 3/Rws, -6/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, -6/Rws, Wall_capacitance(5) + hci_h + hri + 6/Rws - (A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, Wall_capacitance(1) + hce(2) + hre + 6/Rww, -6/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, -6/Rww, Wall_capacitance(2) + 3/Rww + 6/Rww, -3/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, -3/Rww, Wall_capacitance(3) + 3/Rww + 3/Rww, -3/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, -3/Rww, Wall_capacitance(4) + 6/Rww + 3/Rww, -6/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, -6/Rww, Wall_capacitance(5) + hci_h + hri + 6/Rww - (A_wwall/Building_envelope) * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Wall_capacitance(1) + hce(3) + hre + 6/Rwn, -6/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6/Rwn, Wall_capacitance(2) + 3/Rwn + 6/Rwn, -3/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwn, Wall_capacitance(3) + 3/Rwn + 3/Rwn, -3/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwn, Wall_capacitance(4) + 6/Rwn + 3/Rwn, -6/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, -6/Rwn, Wall_capacitance(5) + hci_h + hri + 6/Rwn - (A_nwall/Building_envelope) * hri,  0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Wall_capacitance(1) + hce(4) + hre + 6/Rwe, -6/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6/Rwe, Wall_capacitance(2) + 3/Rwe + 6/Rwe, -3/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwe, Wall_capacitance(3) + 3/Rwe + 3/Rwe, -3/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwe, Wall_capacitance(4) + 6/Rwe + 3/Rwe, -6/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, -6/Rwe, Wall_capacitance(5) + hci_h + hri + 6/Rwe - (A_ewall/Building_envelope) * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Floor_capacitance(1) + (1/Rvi) + hg, -hg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -hg, Floor_capacitance(2) + hf2 + hg, -hf2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -hf2, Floor_capacitance(3) + 2/Rfg + hf2, -2/Rfg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2/Rfg, Floor_capacitance(4) + 4/Rfg + 2/Rfg, -4/Rfg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, -4/Rfg, Floor_capacitance(5) + hci_d + hri + 4/Rfg - (A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_d; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Roof_capacitance(1) + hce(5) + hre + 6/Rr, -6/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6/Rr, Roof_capacitance(2) + 3/Rr + 6/Rr, -3/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rr, Roof_capacitance(3) + 3/Rr + 3/Rr, -3/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rr, Roof_capacitance(4) + 6/Rr + 3/Rr, -6/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, -6/Rr, Roof_capacitance(5) + hci_u + hri + 6/Rr - (A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_u; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce(1) + hre + 1/Rwsd, -1/Rwsd, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, -1/Rwsd, hci_h + hri + 1/Rwsd - (aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce(2) + hre + 1/Rwwd, -1/Rwwd, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, -1/Rwwd, hci_h + hri + 1/Rwwd - (aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce(3) + hre + 1/Rwnd, -1/Rwnd, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, -1/Rwnd, hci_h + hri + 1/Rwnd - (awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce(4) + hre + 1/Rwed, -1/Rwed, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, -1/Rwed, hci_h + hri + 1/Rwed - (awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce(1) + hre + ud, -ud, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, -ud, hci_h + hri + ud - (A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, -(A_swall) * hci_h, 0, 0, 0, 0, -(A_wwall) * hci_h, 0, 0, 0, 0, -(A_nwall) * hci_h, 0, 0, 0, 0, -(A_ewall) * hci_h, 0, 0, 0, 0, -A_floor * hci_d, 0, 0, 0, 0, -A_roof * hci_u, 0, -aws * hci_h, 0, -aww * hci_h, 0, -awn * hci_h, 0, -awe * hci_h, 0, -A_door * hci_h, Air_capacitance + (A_swall + A_nwall + A_ewall + A_wwall + A_wind + A_door) * hci_h + A_floor * hci_d + A_roof * hci_u + Hve + Air_Leak]; 

switch Ventilation_Type
    
    case {'Natural ventilation', 'Mechanical ventilation'}
        
    MatrixB = [Wall_capacitance(1) * Temperatures_nodal(1) + (hce(1) + hre) * (Temperature) + asol * Solar_Radiation_S - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(2); ...
    Wall_capacitance(3) * Temperatures_nodal(3); ...
    Wall_capacitance(4) * Temperatures_nodal(4); ...
    Wall_capacitance(5) * Temperatures_nodal(5) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Wall_capacitance(1) * Temperatures_nodal(6) + (hce(2) + hre) * (Temperature) + asol * Solar_Radiation_W - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(7); ...
    Wall_capacitance(3) * Temperatures_nodal(8); ...
    Wall_capacitance(4) * Temperatures_nodal(9); ...
    Wall_capacitance(5) * Temperatures_nodal(10) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Wall_capacitance(1) * Temperatures_nodal(11) + (hce(3) + hre) * (Temperature) + asol * Solar_Radiation_N - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(12); ...
    Wall_capacitance(3) * Temperatures_nodal(13); ...
    Wall_capacitance(4) * Temperatures_nodal(14); ...
    Wall_capacitance(5) * Temperatures_nodal(15) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Wall_capacitance(1) * Temperatures_nodal(16) + (hce(4) + hre) * (Temperature) + asol * Solar_Radiation_E - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(17); ...
    Wall_capacitance(3) * Temperatures_nodal(18); ...
    Wall_capacitance(4) * Temperatures_nodal(19); ...
    Wall_capacitance(5) * Temperatures_nodal(20) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Floor_capacitance(1) * Temperatures_nodal(21) + (hceD + hre) * T_ground; ...
    Floor_capacitance(2) * Temperatures_nodal(22); ...
    Floor_capacitance(3) * Temperatures_nodal(23); ...
    Floor_capacitance(4) * Temperatures_nodal(24); ...
    Floor_capacitance(5) * Temperatures_nodal(25) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Roof_capacitance(1) * Temperatures_nodal(26) + (hce(5) + hre) * (Temperature) + asol * (Global_Radiation) - hre * deltaSky; ...
    Roof_capacitance(2) * Temperatures_nodal(27); ...
    Roof_capacitance(3) * Temperatures_nodal(28); ...
    Roof_capacitance(4) * Temperatures_nodal(29); ...
    Roof_capacitance(5) * Temperatures_nodal(30) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(1) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(2) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(3) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(4) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(1) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Air_capacitance * (Temperatures_nodal(41)) + fi * Internal_Heat_Gain + fs * Solar_Heat_Gain + fh * Heater_Power + Air_Leak * Temperature + Hve * Temperature]; %HVE IS NOT THE SAME IN BOTH OF THEM!

        
    case 'Air-Air H-EX'

    MatrixB = [Wall_capacitance(1) * Temperatures_nodal(1) + (hce(1) + hre) * (Temperature) + asol * Solar_Radiation_S - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(2); ...
    Wall_capacitance(3) * Temperatures_nodal(3); ...
    Wall_capacitance(4) * Temperatures_nodal(4); ...
    Wall_capacitance(5) * Temperatures_nodal(5) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Wall_capacitance(1) * Temperatures_nodal(6) + (hce(2) + hre) * (Temperature) + asol * Solar_Radiation_W - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(7); ...
    Wall_capacitance(3) * Temperatures_nodal(8); ...
    Wall_capacitance(4) * Temperatures_nodal(9); ...
    Wall_capacitance(5) * Temperatures_nodal(10) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Wall_capacitance(1) * Temperatures_nodal(11) + (hce(3) + hre) * (Temperature) + asol * Solar_Radiation_N - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(12); ...
    Wall_capacitance(3) * Temperatures_nodal(13); ...
    Wall_capacitance(4) * Temperatures_nodal(14); ...
    Wall_capacitance(5) * Temperatures_nodal(15) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Wall_capacitance(1) * Temperatures_nodal(16) + (hce(4) + hre) * (Temperature) + asol * Solar_Radiation_E - Fskyv * hre * deltaSky; ...
    Wall_capacitance(2) * Temperatures_nodal(17); ...
    Wall_capacitance(3) * Temperatures_nodal(18); ...
    Wall_capacitance(4) * Temperatures_nodal(19); ...
    Wall_capacitance(5) * Temperatures_nodal(20) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Floor_capacitance(1) * Temperatures_nodal(21) + (hceD + hre) * T_ground; ...
    Floor_capacitance(2) * Temperatures_nodal(22); ...
    Floor_capacitance(3) * Temperatures_nodal(23); ...
    Floor_capacitance(4) * Temperatures_nodal(24); ...
    Floor_capacitance(5) * Temperatures_nodal(25) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Roof_capacitance(1) * Temperatures_nodal(26) + (hce(5) + hre) * (Temperature) + asol * (Global_Radiation) - hre * deltaSky; ...
    Roof_capacitance(2) * Temperatures_nodal(27); ...
    Roof_capacitance(3) * Temperatures_nodal(28); ...
    Roof_capacitance(4) * Temperatures_nodal(29); ...
    Roof_capacitance(5) * Temperatures_nodal(30) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(1) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(2) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(3) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(4) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce(1) + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Air_capacitance * (Temperatures_nodal(41)) + fi * Internal_Heat_Gain + fs * Solar_Heat_Gain + fh * Heater_Power + Air_Leak * Temperature + Hve * T_inlet]; %HVE IS NOT THE SAME IN BOTH OF THEM!

end


Temperatures1           = MatrixA\MatrixB;

% Calculate and save radiative, inside and operative Temperatures for
% futRre use

% Radiative Temperature is weighted average of internal sRrface
% Temperatures (ISO 52016-1)
T_radiative = (A_swall * Temperatures1(5) + A_wwall * Temperatures1(10) + A_nwall * Temperatures1(15) + A_ewall * Temperatures1(20) + A_floor * Temperatures1(25) + A_roof * Temperatures1(30) + aws * Temperatures1(32) + aww * Temperatures1(34) + awn * Temperatures1(36) + awe * Temperatures1(38) + A_door * Temperatures1(40))/Building_envelope; %(A_wall * Temperatures1(5) + A_floor * Temperatures1(10) + A_roof * Temperatures1(15) + A_wind * Temperatures1(17) + A_door * Temperatures1(19))/Building_envelope;

% Inside Temperature is the last calculated Temperature
T_inside = Temperatures1(41);

% Operative Temperature is mean of radiative and inside Temperatures
T_operative = (T_radiative + T_inside)/2;

end

