function [varargout] = WindowOpening(varargin)
% Function to determine the  air flow due to window opening
%% Input

RwArg = varargin{1};

Aws = varargin{2};
Aww = varargin{3}; 
Awe = varargin{4};
Awn = varargin{5};

Nw  = varargin{6};

Te  = varargin{7};
Tz  = varargin{8};
u10Site = varargin{9};

dCp     = varargin{10};

qVODAReq = varargin{11};

rooARef     = 1.204;
TeREf       = 293.15;
Cwnd        = 0.001;    % Default from EN 16798-7 in 1/(m/S)
Cst         = 0.0035;   % Default from EN 16798-7 in (m/s)/(m*K)
CDW         = 0.67;     % Default from EN 16798-7
u10SiteMax  = 3;        % Default max wind speed used in calculation


%% Windows information
% General information and assumptions used in the window calculations

hwfa    = 2.1 - 0.9;    % Assume that window's upper level is equal to the height of the door (2.1 meters, assumed), and that the lower level of the window is at 0.9 meter height (assumed)

hwPath = 0.9+hwfa/2;   % Assume that the window is installed at 0.9 meter height

farg = 1.8;

Orientations = 0:90:270;

alfaW   = ones(4,max(Nw)) .* Orientations;  % Assume that the windows are located towards each main orientation

beta = ones(4,max(Nw))*90; % Assume that all wall are vertical

%% Window opening area

AwMax       = Aws + Awe + Aww + Awn;

AwTot = RwArg * AwMax;

Aw      = zeros(4);
AwDef   = [Aws, Awe, Awn, Aww];

for a = 1:4 
    if AwDef(a) > 0 && Nw(a) > 0
        Aw(a)  = AwDef(a)/Nw(a); %[Aws/Nw(1), Awe/Nw(2), Aws/Nw(3), Aww/Nw(4)];
    else
        Aw(a) = 0;
    end
end

%% Calculation of air flow

hwst = max(hwPath+hwfa/2)-min(hwPath-hwfa/2);

rooAE = rooAref * (TeRef/Te);
        
rooAZ = rooARef * (TeRef/Tz);

switch(AiringFactor)
    
    case 'Simplified'
        
        qVArgIn = rooARef/rooAE * farg * qVODAReq;
        
        qVArgOut = -(rooARef/rooAZ) * farg * qVODAReq;
        
    case 'SingleSided'
        
        Argument1 = Cwnd * u10Site^2;
        
        Argument2 = Cst * hwst * abs(Tz-Te);
        
        qVArgIn = 3600 * rooARef/rooAE * AwTot/2 * (max(Argument1, Argument2))^0.5;
        
        qVArgOut = -3600 * rooARef/rooAZ * AwTot/2 * (max(Argument1, Argument2))^0.5;
        
    case 'CrossVentilation'
        
        AwOri = zeros(2,4);
        
        for i = 1:2
            
            for j = 1:4
                
                AwOri(i,j) = 0;
                
                alfaRef = (i-1)*45 + (j-1)*90;
                alfaMax = alfaRef +45;
                alfaMin = alfaRef -45;
                
                for k = 1:Nw(j)
                    
                    if alfaW(k) < alfaMax && alfaW(k) >= alfaMin && beta(j,k) >= 60
                        
                        AwOri(i,j) = AwOri(i,j) + Aw(k);
                        
                    end
                    
                end
                
            end
            
            AwCross(i) = 0.25 * ((1/(sqrt((1/AwOri(i,:)^2)+(1/(AwTot-AwOri(i,:))^2)))));
            
        end
        
        AwCross = min(AwCross);
        
        Argument1 = CDW * AwCross * min(u10Site,u10SiteMax) * (dCp)^0.5;
        
        Argument2 = (AwTot/2) *  (Cst * hwst * abs(Tz-Te))^0.5; 
        
        qVArgIn = 3600 * (rooARef/rooAE) * max(Argument1,Argument2);
        
        qVArgOut = -3600 * (rooARef/rooAZ) * max(Argument1,Argument2);
        
end

%% Mass flow rates

qMArgIn = qVArgIn * rooAE;
qMArgOut = qVargOut * rooAZ;

%% Outputs

varargout{1} = qVArgIn;
varargout{2} = qVArgOut;
varargout{3} = qMArgIn;
varargout{4} = qMArgOut;


end

