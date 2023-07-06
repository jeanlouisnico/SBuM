function [varargout] = AirLeakageOnly(varargin)
% Function for calculating the air-leakage value from building (W/K)
%% Inputs 

qVRef       = varargin{1};
ALeak       = varargin{2};
Af          = varargin{3};
Aroof       = varargin{4};
Te          = varargin{5};
Tz          = varargin{6};
dP1          = varargin{7};
dP2          = varargin{8};
dP3          = varargin{9};
dP4          = varargin{10};
dP5          = varargin{11};


nLeak       = 0.667;        % Default value for usage in design conditions calculation. Dimensionless
PLeakRef    = 50;           % Default pressure difference for design conditions calculation. Pa
TeRef       = 293.15;       % Reference external temperature in K, (20 C)
rooARef     = 1.204;        % Reference density of air at reference temperature (kg/m3)
% g           = 9.81;         % Acceleration of gravity (m2/s)


%% Design conditions

CLeak       = qVRef * (ALeak/(PLeakRef^nLeak));     % Leakage coefficient on the zone

CLeakFTot   = CLeak * (Af/(Af+Aroof));              % Leakage coefficient no the facade
CLeakR      = CLeak * (Aroof/(Aroof+Af));           % Leakage coefficient on the roof

% Divide the leakage to 5 leaks, 2 on windward and leeward sides and 1 on
% the roof. Calculate the respective CLeak values for them.

CLeakF      = ones(1,4)*(CLeakFTot*0.25);

%% Air leakage flow

% qVLeaFW(1)     = CLeakF(1) * sign(dP(1)) * (abs(dP(1))^nLeak);
% qVLeaFW(2)     = CLeakF(2) * sign(dP(2)) * (abs(dP(2))^nLeak);

% qVLeaFL(1)     = CLeakF(3) * sign(dP(3)) * (abs(dP(3))^nLeak);
% qVLeaFL(2)     = CLeakF(4) * sign(dP(4)) * (abs(dP(4))^nLeak);

% qVLeaR      = CLeakR * sign(dP(5)) * (abs(dP(5))^nLeak);

qVLeaFW1     = CLeakF(1) * sign(dP1) * (abs(dP1)^nLeak);
qVLeaFW2     = CLeakF(2) * sign(dP2) * (abs(dP2)^nLeak);

qVLeaFL1     = CLeakF(3) * sign(dP3) * (abs(dP3)^nLeak);
qVLeaFL2     = CLeakF(4) * sign(dP4) * (abs(dP4)^nLeak);

qVLeaR      = CLeakR * sign(dP5) * (abs(dP5)^nLeak);

qVLea       = qVLeaFW1 + qVLeaFW2 + qVLeaFL1 + qVLeaFL2 + qVLeaR;

%% Mass balance

qmLeakIn    = (qVLeaFW1 + qVLeaFW2) * rooARef * (TeRef/Te);

qmLeakOut   = (qVLeaFL1 + qVLeaFL2 + qVLeaR) * rooARef * (TeRef/Tz);

%% Outputs

varargout{1} = qVLea;
varargout{2} = qmLeakIn;
varargout{3} = qmLeakOut;

end

