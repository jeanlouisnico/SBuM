function [varargout] = AirLeakFunction(varargin)
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

AirTerminal     = varargin{16};
Duct            = varargin{17};
Cowl            = varargin{18};
Vent            = varargin{19};

AATD            = varargin{20};
dPATDRef        = varargin{21};
hCowl           = varargin{22};
CCowlOrg        = varargin{23};
Cowlzeta        = varargin{24};
AsPDU           = varargin{25};

RwArg           = varargin{26};
Nw              = varargin{27};
qVODAReq        = varargin{28};

Avent           = varargin{29};
dPVentRef       = varargin{30};

qVSUP           = varargin{31};
qVETA           = varargin{32};
TSUP            = varargin{33} + 273.15;

WOpenable       = varargin{34};
WOpen           = varargin{35};

rooARef         = 1.204;
TeRef           = 293.15;
g               = 9.81;

qMSUP           = qVSUP * rooARef * (TeRef/TSUP);
qMETA           = qVETA * rooARef * (TeRef/Tz);

%% Calculate u10Site and wind coefficents

switch CRghFactor           % Roughness of the site at 10m height, depends on teh terrain
    
    case 'Open Terrain'
        
        CRgh = 1;
        
    case 'Country'
        
        CRgh = 0.9;
        
    case 'Urban'
        
        CRgh = 0.8;
        
end
     
CTopSite    = 1;            % Default value from standard EN 16798-7
CRghMet     = 1;            % Default value from standard EN 16798-7
CTopMet     = 1;            % Default value from standard EN 16798-7

uSite       = ((CRgh * CTopSite)/(CRghMet * CTopMet)) * u10;    % Wind speed at the site

%% Determine if cross ventilation is possible

if (Nw(1) >= 1 && Nw(3) >= 1) || (Nw(2) >= 1 && Nw(4) >= 1)
    fcross = 1;
else
    fcross = 0;
end

%% Determine the wind pressure coefficient

[CPPath] = WindPressureCoef(slope, SClass, fcross, hPath) ;

dCp     = CPPath(1) - CPPath(2);

%% Calculate pressure difference

hPathUseful = [0.25 0.75 0.25 0.75 1] * hPath;
CPPathUseful = [CPPath(1) CPPath(1) CPPath(2) CPPath(2) CPPath(3)];

syms PzRef

PePath      = rooARef * (TeRef/Te) *(0.5*CPPathUseful .* uSite^2 - hPathUseful * g);     % External air pressure

PzPath      = PzRef - rooARef * hPathUseful * g * (TeRef/Tz);                     % Internal air pressure

syms dP(PzRed)

dP(PzRef)          = PePath - PzPath;                                              % Pressure difference 


%% Calculate the Air Leakage mass flow rate

[qVLeak, qMLeakIn, qMLeakOut]   = AirLeakage(qVRef, ALeak, Af, Aroof, Te, Tz, dP);

%% Calculate the air flow rate from passive and hybrid ducts

if any([AirTerminal, Duct, Cowl])

    [qMPDUIn, qMPDUOut]             = PDU(AirTerminal, Duct, Cowl, AATD, Cowlzeta, uSite, dPATDRef, hCowl, hPath, AsPDU, CCowlOrg);
    
else
    
    qMPDUIn     = 0;
    qMPDUOut    = 0;
    
end

%% Calculate the air window opening air flow path

if WOpenable == 1 && WOpen == 1

    [qVArgIn, qVArgOut, qMArgIn, qMArgOut] = WindowOpening(RwArg, aws, aww, awe, awn, Nw, Te, Tz, dCp, qVODAReq);
    
else
    
    qVArgIn     = 0;
    qVArgOut    = 0;
    qMArgIn     = 0;
    qMArgOut    = 0;
    
end

%% Calculate the air flow from vents

if Vent == 1
    
    [qVVentIn, qVVentOut, qMVentIn, qMVentOut] = Vents(Te, Tz, Avent, dP, dPVentRef);
    
else
    
    qVVentIn    = 0;
    qVVentOut   = 0;
    qMVentIn    = 0;
    qMVentOut    = 0;
    
end

%% Mass air flow balance

[QAirFlow, qMPDUIn, qMPDUOut, qMArgIn, qMArgOut, qMVentIn, qMVentOut, qMLeakIn, qMLeakOut] = AirFlowMassBalance(qMSUP, qMETA, qMPDUIn, qMPDUOut, qMArgIn, qMArgOut, qMVentIn, qMVentOut, qMLeakIn, qMLeakOut, Te, Tz, PzRef);

qMIn    = sum([qMPDUIn, qMArgIn, qMVentIn, qMLeakIn]);
qMOut   = sum([qMPDUOut, qMArgOut, qMVentOut, qMLeakOut]);

qVIn = qMIn / (rooARef * (TeRef/Te));
qVOut = qMOut / (rooARef * (TeRef/Tz));

%% Outputs

varargout{1} = QAirFlow;
varargout{2} = qMIn;
varargout{3} = qMOut;
varargout{4} = qVIn;
varargout{5} = qVOut;

end

