function [varargout] = AIM2(varargin)
%Function to call amd calculate air flows and energy flows
%% Inputs
qVRef       = varargin{1};
ALeak       = varargin{2};
Af          = varargin{3};
Aroof       = varargin{4};
u10         = varargin{5};
hPath       = varargin{6};
Te          = varargin{7} + 273.15;
Tz          = varargin{8} + 273.15;
SClass      = varargin{9};
CRghFactor  = varargin{10};
slope       = varargin{11};
% fcross      = varargin{12};

aws         = varargin{12};
awe         = varargin{13};
awn         = varargin{14};
aww         = varargin{15};

% AirTerminal     = varargin{16};
% Duct            = varargin{17};
% Cowl            = varargin{18};
% Vent            = varargin{19};
% 
% AATD            = varargin{20};
% dPATDRef        = varargin{21};
% hCowl           = varargin{22};
% CCowlOrg        = varargin{23};
% Cowlzeta        = varargin{24};
% AsPDU           = varargin{25};
% 
% RwArg           = varargin{26};
% Nw              = varargin{27};
% qVODAReq        = varargin{28};
% 
% Avent           = varargin{29};
% dPVentRef       = varargin{30};
% 
% qVSUP           = varargin{31};
% qVETA           = varargin{32};
% TSUP            = varargin{33} + 273.15;
% 
% WOpenable       = varargin{34};
% WOpen           = varargin{35};

rooARef         = 1.204;
TeRef           = 293.15;
g               = 9.81;

%qMSUP           = qVSUP * rooARef * (TeRef/TSUP);
%qMETA           = qVETA * rooARef * (TeRef/Tz);

%% Calculate u10Site and wind coefficents

switch CRghFactor           % Roughness of the site at 10m height, depends on teh terrain
    
    case 'Open Terrain'
        
        CRgh = 1;
        
    case 'Country'
        
        CRgh = 0.9;
        
    case 'Urban/City'
        
        CRgh = 0.8;
        
end
     
CTopSite    = 1;            % Default value from standard EN 16798-7
CRghMet     = 1;            % Default value from standard EN 16798-7
CTopMet     = 1;            % Default value from standard EN 16798-7

uSite       = ((CRgh * CTopSite)/(CRghMet * CTopMet)) * u10;    % Wind speed at the site

%% Determine if cross ventilation is possible

% if (Nw(1) >= 1 && Nw(3) >= 1) || (Nw(2) >= 1 && Nw(4) >= 1)
%     fcross = 1;
% else
%     fcross = 0;
% end

%% Determine the wind pressure coefficient

% [CPPath] = WindPressureCoefOnly(slope, SClass, hPath); %fcross, hPath) ;
% 
% dCp     = CPPath(1) - CPPath(2);

%% Calculate pressure difference

% hPathUseful = [0.25 0.75 0.25 0.75 1] * hPath;
% CPPathUseful = [CPPath(1) CPPath(1) CPPath(2) CPPath(2) CPPath(3)];
% 
% PzRef = sym('PzRef');
% 
% % PzRef = 0;
% 
% %PzRef = sym('PzRef', 'real');
% 
% PePath      = rooARef * (TeRef/Te) *(0.5*CPPathUseful .* uSite^2 - hPathUseful * g);     % External air pressure
% 
% PzPath1      = PzRef - rooARef * hPathUseful(1) * g * (TeRef/Tz);                     % Internal air pressure
% PzPath2      = PzRef - rooARef * hPathUseful(2) * g * (TeRef/Tz);                     % Internal air pressure
% PzPath3      = PzRef - rooARef * hPathUseful(3) * g * (TeRef/Tz);                     % Internal air pressure
% PzPath4      = PzRef - rooARef * hPathUseful(4) * g * (TeRef/Tz);                     % Internal air pressure
% PzPath5      = PzRef - rooARef * hPathUseful(5) * g * (TeRef/Tz);                     % Internal air pressure
% 
% 
% % syms dP(PzRed)
% 
% % dP(PzRef) = sym('dP(PzRef)', 'real');
% 
% dP1          = PePath(1) - PzPath1;                                              % Pressure difference 
% dP2          = PePath(2) - PzPath2;                                              % Pressure difference 
% dP3          = PePath(3) - PzPath3;                                              % Pressure difference 
% dP4          = PePath(4) - PzPath4;                                              % Pressure difference 
% dP5          = PePath(5) - PzPath5;  
% 
% % dP1(PzRef)          = PePath(1) - PzPath1;                                              % Pressure difference 
% % dP2(PzRef)          = PePath(2) - PzPath2;                                              % Pressure difference 
% % dP3(PzRef)          = PePath(3) - PzPath3;                                              % Pressure difference 
% % dP4(PzRef)          = PePath(4) - PzPath4;                                              % Pressure difference 
% % dP5(PzRef)          = PePath(5) - PzPath5;                                              % Pressure difference 
% 
% %dP = [dP1 dP2 dP3 dP4 dP5];
% 
% %% Calculate the Air Leakage mass flow rate
% 
% [qVLeak, qMLeakIn, qMLeakOut]   = AirLeakageOnly(qVRef, ALeak, Af, Aroof, Te, Tz, dP1, dP2, dP3, dP4, dP5);

%% Calculate the air flow rate from passive and hybrid ducts

% if any([AirTerminal, Duct, Cowl])
% 
%     [qMPDUIn, qMPDUOut]             = PDU(AirTerminal, Duct, Cowl, AATD, Cowlzeta, uSite, dPATDRef, hCowl, hPath, AsPDU, CCowlOrg);
%     
% else
%     
%     qMPDUIn     = 0;
%     qMPDUOut    = 0;
%     
% end

%% Calculate the air window opening air flow path

% if WOpenable == 1 && WOpen == 1
% 
%     [qVArgIn, qVArgOut, qMArgIn, qMArgOut] = WindowOpening(RwArg, aws, aww, awe, awn, Nw, Te, Tz, dCp, qVODAReq);
%     
% else
%     
%     qVArgIn     = 0;
%     qVArgOut    = 0;
%     qMArgIn     = 0;
%     qMArgOut    = 0;
%     
% end

%% Calculate the air flow from vents

% if Vent == 1
%     
%     [qVVentIn, qVVentOut, qMVentIn, qMVentOut] = Vents(Te, Tz, Avent, dP, dPVentRef);
%     
% else
%     
%     qVVentIn    = 0;
%     qVVentOut   = 0;
%     qMVentIn    = 0;
%     qMVentOut    = 0;
%     
% end

%% Mass air flow balance

% [QAirFlow, qMLeakIn, qMLeakOut] = AirFlowMassBalanceLeak(qMLeakIn, qMLeakOut, Te, Tz, PzRef);
%     
% qMIn    = qMLeakIn; %sum([qMPDUIn, qMArgIn, qMVentIn, qMLeakIn]);
%             qMOut   = qMLeakOut; %sum([qMPDUOut, qMArgOut, qMVentOut, qMLeakOut]);
% 
% qVIn = qMIn / (rooARef * (TeRef/Te));
% qVOut = qMOut / (rooARef * (TeRef/Tz));

%% AIM2

beta = -0.33; % Empirical constant from Walker & Wilson

pressure = 101325;  % Normal Air pressure
gasConstant = 287.058; % Specific gas constant for dry air

roo = 1.2;
specificAir = 1007;

externalAirDensity = pressure/(gasConstant * Te);  % Calculation for external air density assuming normal air pressure and specific gas constant for dry air

g = 9.81;           %
PaRef   = 50;       % Finnish value
n       = 0.667;    % Flow exponent through leaks (EN 16798-7)

% Clea = qVRef/3600 * (ALeak/(PaRef)^n);

Clea = qVRef * (1/(PaRef)^n);   % Clea in m3/(h * Pa^n), Calculation from ISO 9972
Clea = Clea/3600;               % Transformation of the value from m3/(h * Pa^n) to m3/(s * Pa^n)

CleaW   = Clea * (Af/(Af+Aroof));       % Facade leakage coefficient (EN 16798-7)
CleaR   = Clea * (Aroof/(Af+Aroof));    % Roof leakage coefficient (EN 16798-7)

CleaF = Clea - CleaW - CleaR;           % Floor leakage coefficient is sum of all leakages with assumption of flue to be 0

if CleaF < 0
    CleaF = 0;
end

% Leakage distribution according to AIM-2

R   = (CleaR + CleaF)/Clea;
X   = (CleaR - CleaF)/Clea; 

% Wind factor according to AIM-2 without flue gas
fw = 0.19 * (2-n) * (1-((X+R)/2)^(3/2));

% Stack factor according to AIM-2 without flue gas
fs = ((1 + n*R)/(n+1))*(0.5 - 0.5*(X^2/(2-R))^(5/4))^(n+1);

% Stack pressure difference according to AIM-2

% dPs = externalAirDensity * g * hPath * ((abs(Tz-Te))/Te); % Corrected
% 17.10.2022
dPs = externalAirDensity * g * hPath * ((abs(Tz-Te))/Tz);

% Infiltration air rate according to stack pressure
Qs = Clea * fs * dPs^n;     % m3/s

% Wind pressure difference according to AIM-2

dPw = (externalAirDensity * uSite^2)/2;

% Wind induced air infiltration according to AIM-2

Qw = Clea * fw * dPw^n;

% Total air infiltration according to AIM-2

Qt = (Qw^(1/n) + Qs^(1/n) + beta *(Qs*Qw)^(1/(2*n)))^n; % As m3/s

HeLeak = Qt * roo * specificAir;    % In terms of W/K

%% Outputs

varargout{1} = HeLeak;
varargout{2} = Qt;
% varargout{2} = qMIn;
% varargout{3} = qMOut;
% varargout{4} = qVIn;
% varargout{5} = qVOut;

end

