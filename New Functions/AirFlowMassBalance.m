function [varargout] = AirFlowMassBalance(varargin)
% This function is used to solve the air flow mass balance calculation
%% Inputs
qMSUP   = varargin{1};
qMETA   = varargin{2};
qMPDUIn = varargin{3};
qMPDUOut = varargin{4};
qMArgIn     = varargin{5};
qMArgOut    = varargin{6};
qMVentIn    = varargin{7};
qMVentOut   = varargin{8};
qMLeakIn    = varargin{9};
qMLeakOut   = varargin{10};

Te          = varargin{11};
Tz          = varargin{12};

PzRef       = varargin{13};
dP          = varargin{14};

qMCombIn    = 0;
qMCombOut   = 0;

TimeStep = 3600;

Ca          = 1006/TimeStep; % 0.000279;     % kWh/kg*K
%% Mass balance calculation

f        = qMSUP + qMETA + qMCombIn + qMCombOut + qMPDUIn + qMPDUOut + ...
           qMArgIn + qMArgOut + qMVentIn + qMVentOut + qMLeakIn + qMLeakOut == 0;

dP1       = vpasolve(f,dP); %fsolve(f(PzRef)); %vpasolve(f,PzRef,0);
Pz        = vpasolve(dP1,PzRef);

%% Calculate mass balance functions

if qMPDUIn ~= 0
    qMPDUIn = subs(qMPDUIn, PzRef, Pz);
    qMPDUIn = double(qMPDUIn);
end

if qMPDUOut ~= 0
    qMPDUOut = subs(qMPDUOut, PzRef, Pz);
    qMPDUOut = double(qMPDUOut);
end

if qMArgIn ~= 0
    qMArgIn = subs(qMArgIn, PzRef, Pz);
    qMArgIn = double(qMArgIn);
end

if qMArgOut ~= 0
    qMArgOut = subs(qMArgOut, PzRef, Pz);
    qMArgOut = double(qMArgOut);
end

if qMVentIn ~= 0
    qMVentIn = subs(qMVentIn, PzRef, Pz);
    qMVentIn = double(qMVentIn);
end

if qMVentOut ~= 0
    qMVentOut = subs(qMVentOut, PzRef, Pz);
    qMVentOut = double(qMVentOut);
end

if qMLeakIn ~= 0
    qMLeakIn = subs(qMLeakIn, PzRef, Pz);
    qMLeakIn = double(qMLeakIn);
end

if qMLeakOut ~= 0
    qMLeakOut = subs(qMLeakOut, PzRef, Pz);
    qMLeakOut = double(qMLeakOut);
end

%% Determine the flow rate from outdoors to indoors
% This is used to determine the heat demand and indoor temperatures. This
% is also done only for air-flows which come at ourdoor temperature

qMIn    = qMPDUIn + qMArgIn + qMVentIn + qMLeakIn;
qMOut   = qMPDUOut + qMArgOut + qMVentOut + qMLeakOut;

%% Determine the heat loss indoors

% if qMIn == abs(qMOut)
% 
%     QAirFlow = Ca * qMIn;
% 
% else
%     
%     QAirFlow = Ca * abs(qMOut);
    
    EnergyIn = qMIn * Ca * Te;
    EnergyOut = qMOut * Ca * Tz;
    ChangeInEnergy = (EnergyIn+EnergyOut);
%     
    QAirFlow = ChangeInEnergy/(Tz-Te);
    
%     QAirFlow = (Cp * (qMOut * Tz - qMIn * Te))/(Tz-Te);
    
% end

%% Outputs
varargout{1} = QAirFlow;
varargout{2} = qMPDUIn;
varargout{3} = qMPDUOut;
varargout{4} = qMArgIn;
varargout{5} = qMArgOut;
varargout{6} = qMVentIn;
varargout{7} = qMVentOut;
varargout{8} = qMLeakIn;
varargout{9} = qMLeakOut;

end

