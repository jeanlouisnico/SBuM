function [varargout] = Vents(varargin)
% Function to calculate air flow from vents
%% Inputs

Te          = varargin{1};
Tz          = varargin{2};
Avent       = varargin{3};
dP          = varargin{4};
dPVentRef   = varargin{5};


g           = 9.81;
rooARef     = 1.204;
TeRef       = 293.15;
CDvent      = 0.6;
nVent       = 0.5; 

%% Air Flow

CventTot = 3600/10000 * CDvent * Avent * (2/rooARef)^0.5 * (1/dPVentRef)^(nVent-0.5);

% Distribute vents equally, 2 windward and 2 leeward vents

Cvent = ones(1,4) * CventTot * 0.25;

qVVentIn = Cvent(1) * dP(1) * abs(dP(1))^nVent + Cvent(2) * dP(2) * abs(dP(2))^nVent;

qVVentOut = Cvent(3) * dP(3) * abs(dP(3))^nVent + Cvent(4) * dP(4) * abs(dP(4))^nVent; % + Cvent * dP(3) * abs(dP(3))^nVent;

qVVent = qVVentIn + qVVentOut;

%% Mass Flows 

qMVentIn = rooARef * (TeRef/Te) * qVVentIn;

qMVentOut = rooARef * (TeRef/Tz) * qVVentOut;

%% Outputs

varargout{1} = qVVentIn;
varargout{2} = qVVentOut;
varargout{3} = qMVentIn;
varargout{4} = qMVentOut;

end

