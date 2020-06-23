function [T_inside, T_radiative, T_operative, Temperatures1] = InsideTemperature2(varargin)
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

uvs                         = (1/1.789); %varargin{1};
uve                         = (1/1.789); %varargin{2};
uvw                         = (1/1.789); %varargin{3};
uvn                         = (1/1.789); %varargin{4};
    
uvsw                        = 2.984; %varargin{5};
uvew                        = 2.984; %varargin{6};
uvnw                        = 2.984; %varargin{7};
uvww                        = 2.984; %varargin{8};
    
uvd                         = 2.984; %varargin{9};
    
uvf                         = (1/25.254); %varargin{10};
uvr                         = (1/2.992); %varargin{11};

hgt                         = 2.7; % varargin{12};
lgts                        = 8; %varargin{13};
lgte                        = 6; %varargin{14};
pitch                       = 0; %varargin{15};
aws                         = 12; %varargin{16};
awe                         = 0; %varargin{17};
awn                         = 0; %varargin{18};
aww                         = 0; %varargin{19};
ad                          = 0; %varargin{20};

A_roof                      = 48; %varargin{21};
A_floor                     = 48; %varargin{22};

House_Volume                = 129.6; %varargin{23};

Building_envelope           = 171.6; %varargin{24};

Building_Thermal_mass       = 0; %varargin{25};

Air_Leak                    = 1.2*1007*0.0148; %varargin{26};
Ventilation_Type            = {'Natural ventilation'}; %varargin{27};
Flow_rate                   = 0; %varargin{28}; 

Internal_Heat_Gain          = 200; %varargin{29};
Solar_Heat_Gain             = Solar_Radiation_S * 0.71 * 12;  %varargin{30};

Heater_Power                = varargin{31};

Temperature                 = varargin{32};
T_ground                    = varargin{33};
T_inlet                     = Temperature; % varargin{34};

Temperatures_nodal          = varargin{35};

Solar_Radiation             = varargin{36};
Global_Radiation            = varargin{37};

%% Variables from the standards
% Variables used in the calculations that are defined in the standards.

% ISO 13789:2017
% Convective and radiative sRrface heat transfer coefficients.

hci_h   = 2.5;
hci_u   = 5;
hci_d   = 0.7;
hce     = 20;
hri     = 5.13;
hre     = 4.14;

% ISO 52016-1:2017
% Difference between sky and outside air Temperature
deltaSky = 11;  % For intermediate zones

% View factor to the sky
Fskyr = 1;
Fskyv = 0.5;

% Opaque material solar absorption coefficient
asol = 0.6;     % For intermediate color and default value

% Convective fractions
fi = 0.4;
fs = 0.1;
fh = 1; %0.7; %0.4;

% Thermal mass of air and fRrnitRres
Air_capacitance = 133.33; % 10000;


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
Rws = 1.789; % ((1/uvs) - 0.13 - 0.04);            % Calculation accoring to ISO 6946:2017. Rsi & Rse values (0.13 & 0.04) from the same standard
Rww = 1.789; % ((1/uvw) - 0.13 - 0.04);
Rwn = 1.789; % ((1/uvn) - 0.13 - 0.04);
Rwe = 1.789; % ((1/uve) - 0.13 - 0.04);
% Rw = (1/((1/Rw) - (1/hci_h) - (1/hce) - (1/hri) - (1/hre)));                            % The corrected U-value for the wall without sRrface transfer coefficients
Wall_capacitance = 13.89; % (Building_Thermal_mass * A_floor)/Building_envelope;    % The building thermall mass is in Wh/m2K for the building area, it needs to be transferred into Wh/m2K per construction element. All the elements are considered to have equal amount of thermal mass.

% Roof

Rr = 2.992; % (1/uvr) - 0.10 - 0.04;             % Calculation from ISO 6946:2017. Rsi & Rse values from the same standard.
% Rr = (1/((1/Rr) - (1/hci_u) - (1/hce) - (1/hri) - (1/hre)));
Roof_capacitance = 13.89; % Wall_capacitance;

% Floor

Rfg = 25.254; % (1/uvf) - 0.17 - 0.04;
Floor_capacitance = 13.89; % Wall_capacitance;

% Calculation of ground's thermal capacity & thermal conductance. Sand or
% gravel is assumed as the ground type as discussed in ISO 13370:2017

Ground_capacitance = 2000000 * 0.5 /3600;              % Thermal capacity of 0.5m deep ground. J changed to Wh.
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
Rvi = (1/0.16) - 0.17 - Rf - Rg;                    % U is equal to 2010 regulation value for slab on ground, Rsi is from ISO 6946:2017 for downwards flowing heat.

hf2 = (1/((Rfg/4)+(Rg/2)));                         % One of the nodal transmittances from ISO 52016-1:2017


% Windows and doors thermal conductance

% uvw = (uvsw * aws + uvew * awe + uvnw * awn + uvww * aww)/A_wind; % Area weighted mean value of the U-values of windows.
Rwsd = (1/((1/uvsw) - 0.13 - 0.04));      % U-value of windows when reducing sRrface transfers. 0.13 and 0.04 are from ISO 52016-1:2017
Rwwd = (1/((1/uvww) - 0.13 - 0.04));
Rwnd = (1/((1/uvnw) - 0.13 - 0.04));
Rwed = (1/((1/uvew) - 0.13 - 0.04));


ud = (1/((1/uvd) - 0.13 - 0.04));       % Same as with window

% Internal heat gain needs to declude solar heat gain
Internal_Heat_Gain = 200; %Internal_Heat_Gain - Solar_Heat_Gain;

%% Temperature calculation according to the standard

MatrixA = [hce + hre + 6/Rws, -6/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    -6/Rws,  3/Rws + 6/Rws, -3/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, -3/Rws, 3/Rws + 3/Rws, -3/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, -3/Rws, 6/Rws + 3/Rws, -6/Rws, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, -6/Rws, Wall_capacitance + hci_h + hri + 6/Rws - (A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, hce + hre + 6/Rww, -6/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, -6/Rww,  3/Rww + 6/Rww, -3/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, -3/Rww, 3/Rww + 3/Rww, -3/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, -3/Rww, 6/Rww + 3/Rww, -6/Rww, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, -6/Rww, Wall_capacitance + hci_h + hri + 6/Rww - (A_wwall/Building_envelope) * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + 6/Rwn, -6/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6/Rwn,  3/Rwn + 6/Rwn, -3/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwn, 3/Rwn + 3/Rwn, -3/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwn, 6/Rwn + 3/Rwn, -6/Rwn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, -6/Rwn, Wall_capacitance + hci_h + hri + 6/Rwn - (A_nwall/Building_envelope) * hri,  0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + 6/Rwe, -6/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6/Rwe,  3/Rwe + 6/Rwe, -3/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwe, 3/Rwe + 3/Rwe, -3/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rwe, 6/Rwe + 3/Rwe, -6/Rwe, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, -6/Rwe, Wall_capacitance + hci_h + hri + 6/Rwe - (A_ewall/Building_envelope) * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, (1/Rvi) + hg, -hg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -hg, Ground_capacitance + hf2 + hg, -hf2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -hf2, 2/Rfg + hf2, -2/Rfg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2/Rfg, 4/Rfg + 2/Rfg, -4/Rfg, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, -4/Rfg, Floor_capacitance + hci_d + hri + 4/Rfg - (A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_d; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + 6/Rr, -6/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -6/Rr, 3/Rr + 6/Rr, -3/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rr, 3/Rr + 3/Rr, -3/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -3/Rr, 6/Rr + 3/Rr, -6/Rr, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, -6/Rr, Wall_capacitance + hci_u + hri + 6/Rr - (A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_u; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + Rwsd, -Rwsd, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, -Rwsd, hci_h + hri + Rwsd - (aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + Rwwd, -Rwwd, 0, 0, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, -Rwwd, hci_h + hri + Rwwd - (aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + Rwnd, -Rwnd, 0, 0, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, -Rwnd, hci_h + hri + Rwnd - (awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + Rwed, -Rwed, 0, 0, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, -Rwed, hci_h + hri + Rwed - (awe/Building_envelope) * hri, 0, -(A_door/Building_envelope) * hri, -hci_h;
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hce + hre + ud, -ud, 0; 
    0, 0, 0, 0, -(A_swall/Building_envelope) * hri, 0, 0, 0, 0, -(A_wwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_nwall)/Building_envelope * hri, 0, 0, 0, 0, -(A_ewall)/Building_envelope * hri, 0, 0, 0, 0, -(A_floor/Building_envelope) * hri, 0, 0, 0, 0, -(A_roof/Building_envelope) * hri, 0, -(aws/Building_envelope) * hri, 0, -(aww/Building_envelope) * hri, 0, -(awn/Building_envelope) * hri, 0, -(awe/Building_envelope) * hri, -ud, hci_h + hri + ud - (A_door/Building_envelope) * hri, -hci_h; 
    0, 0, 0, 0, -(A_swall) * hci_h, 0, 0, 0, 0, -(A_wwall) * hci_h, 0, 0, 0, 0, -(A_nwall) * hci_h, 0, 0, 0, 0, -(A_ewall) * hci_h, 0, 0, 0, 0, -A_floor * hci_d, 0, 0, 0, 0, -A_roof * hci_u, 0, -aws * hci_h, 0, -aww * hci_h, 0, -awn * hci_h, 0, -awe * hci_h, 0, -A_door * hci_h, Air_capacitance + (A_swall + A_nwall + A_ewall + A_wwall + A_wind + A_door) * hci_h + A_floor * hci_d + A_roof * hci_u + Hve + Air_Leak]; 

switch Ventilation_Type
    
    case {'Natural ventilation', 'Mechanical ventilation'}
        
    MatrixB = [(hce + hre) * (Temperature) + asol * Solar_Radiation_South - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(5) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * Solar_Radiation_West - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(10) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * Solar_Radiation_North - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(15) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * Solar_Radiation_East - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(20) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (1/Rvi) * T_ground; ...
    Ground_capacitance * T_ground; ...
    0; ...
    0; ...
    Floor_capacitance * Temperatures_nodal(25) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * (Global_Radiation) - hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Roof_capacitance * Temperatures_nodal(30) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    Air_capacitance * (Temperatures_nodal(41)) + fi * Internal_Heat_Gain + fs * Solar_Heat_Gain + fh * Heater_Power + Air_Leak * Temperature + Hve * Temperature]; %HVE IS NOT THE SAME IN BOTH OF THEM!

        
    case 'Air-Air H-EX'

    MatrixB = [(hce + hre) * (Temperature) + asol * Solar_Radiation - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(5) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * Solar_Radiation - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(10) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * Solar_Radiation - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(15) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * Solar_Radiation - Fskyv * hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Wall_capacitance * Temperatures_nodal(20) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (1/Rvi) * T_ground; ...
    Ground_capacitance * T_ground; ...
    0; ...
    0; ...
    Floor_capacitance * Temperatures_nodal(25) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * (Temperature) + asol * (Global_Radiation) - hre * deltaSky; ...
    0; ...
    0; ...
    0; ...
    Roof_capacitance * Temperatures_nodal(30) + 1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
    1/Building_envelope * ((1-fi) * Internal_Heat_Gain + (1-fs) * Solar_Heat_Gain + (1-fh) * Heater_Power); ...
    (hce + hre) * Temperature;... 
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

