function [varargout] = PDU(varargin)
%Function to calculate the flow rates and pressure drops in passive and
%hybrid ductes according to EN 16798-7
%% Inputs 

AirTerminal = varargin{1};
Duct        = varargin{2};
Cowl        = varargin{3};
AATD        = varargin{4};
Cowlzeta    = varargin{5};
uSite       = varargin{6};
dPATDRef    = varargin{7};
hCowl       = varargin{8};
h           = varargin{9};

AsPDU       = varargin{10};

CCowlOrg            = varargin{11};
CpCowlRoof          = 0;    % Default value for worl at roof height

if hCowl < 0.5
    deltaCCowlheight = 0;
elseif hCowl >= 0.5 && hCowl <= 1.0
    deltaCCowlheight = -0.1; 
else
    deltaCCowlheight = -0.2;
end

% deltaCCowlheight    = ;
% Colwzeta            = ;

TimeStep = 3600;    % Seconds in huor
rooARef     = 1.204;
TeRef       = 293.15;
dPATDRef    = varargin{12};
CDADT       = 0.6;
nATD        = 0.5;

% This is the reference calculation mehod
% if hPDU < 3
%     hPDUSt  = hPDU + 2;
% else
%     hPDUZ   = h;
%     hPDUSt  = hPDUZ + 2;
% end

hPDUSt = h + 2;

syms qVPDU

%% Pressure loss at internal air terminal device

if AirTerminal == true

    CATD = TimeStep/10000 * CDATD * AATD * (2/rooARef)^0.5 * (1/dPATDRef)^(nATD-0.5);

    dpATD = -sign(qVPDU) * ((abs(qVPDU)/(CATD))^(1/nATD));
    
else
    
    dpATD = 0;
    
end

%% Pressure loss in the ductwork

if Duct == true
    
    dPPDU = 0;
    
else
    
    dPPDU = 0;
    
end

%% Cowl charactristics

if Cowl == true
    
    if uSite == 0
        
        CCowl = Cowlzeta;
        
        dPCowl = -0.5 * sign(qVPDU) * CCowl * rooARef * ((abs(qVPDU)/(TimeStep * AsPDU))^2);
        
    else
        
        CowlTot = CCowlOrg + CpCowlRoof + deltaCCowlheight;
        
        CCowl = CowlTot;
        
        dPCowl = -0.5 * sign(qVPDU) * CCowl * rooARef * uSite^2;
        
    end
    
    
elseif Cowl == false
    
    dPCowl = 0;
    
end

%% Overall PDU calculation

ValueCheck = [dpATD==0, dPPDU==0, dPCowl==0];

if any(ValueCheck)

    f(qVPDU,PzRef) = dpATD + dPPDU + dPCowl == PzRef + hPDUSt * g *(rooAE - rooAZ);
    
    qVPDUSol = solve(f,qVPDU);
    
else
    
    qVPDUSol = 0;
    
end



%% Mass flow

if qVPDU >= 0
    
    qVPDUIn     = qVPDU * rooARef * (TeRef/Te);
    qVPDUOut    = 0;
    
else
    
    qVPDUIn     = 0;
    qVPDUOut    = qVPDU * rooARef * (TeRef/Tz);
    
end

%% Outputs

varargout{1} = qVPDUIn;
varargout{2} = qVPDUOut;
    

end

