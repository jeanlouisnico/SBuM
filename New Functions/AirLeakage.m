function [varargout] = AirLeakage(varargin)
% Function for calculating the air-leakage value from building (W/K)
%% Inputs 

qVRef       = varargin{1};
ALeak       = varargin{2};
Af          = varargin{3};
Aroof       = varargin{4};
Te          = varargin{5};
Tz          = varargin{6};
dP          = varargin{7};


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

qVLeaFW(1)     = CLeakF(1) .* sign(dP(1)) .* (abs(dP(1))^nLeak);
qVLeaFW(2)     = CLeakF(2) .* sign(dP(2)) .* (abs(dP(2))^nLeak);

qVLeaFL(1)     = CLeakF(3) .* sign(dP(3)) .* (abs(dP(3))^nLeak);
qVLeaFL(2)     = CLeakF(4) .* sign(dP(4)) .* (abs(dP(4))^nLeak);

qVLeaR      = CLeakR * sign(dP(5)) * (abs(dP(5))^nLeak);

qVLea       = sum(qVLeaFW) + sum(qVLeaFL) + qVLeaR;

%% Mass balance

qmLeakIn    = sum(qVLeaFW) * rooARef * (TeRef/Te);

qmLeakOut   = (sum(qVLeaFL) + qVLeaR) * rooARef * (TeRef/Tz);

%% Outputs

varargout{1} = qVLea;
varargout{2} = qmLeakIn;
varargout{3} = qmLeakOut;

end

