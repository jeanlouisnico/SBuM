function [varargout] = CHTC(varargin)
%% This is a function to calculate the convective heat transfer coefficient
% The current function contains several methods to calculate the CHTC
% according to various available methods from EnergyPLUS engineering
% manual.
%% Inputs
Uw          = varargin{1};      % Wind speed
WD          = varargin{2};      % Wind direction in degrees
CHTCmethod  = varargin{3};      % Selected method
lgts        = varargin{4};
lgte        = varargin{5};
hgt         = varargin{6};
pitch       = varargin{7};
Rf          = varargin{8};
Te          = varargin{9};      % Exterior structure temperature
Ta          = varargin{10};     % Ambient temperature
HouseVolume = varargin{11};

% Calculate the angle (surfaace-to-wind)
orgOrientation = [0 90 180 270]; % North, East, South and West

    StWa = orgOrientation - WD + 360; % Calculate the iangle between the wind and the wall
    StRa = 0 - WD + 360;
    
    WindWard = abs(orgOrientation - WD);
    WindWardSide = WindWard==min(WindWard);
    
    if sum(WindWardSide(:)==1)>1
        firstValue = find(WindWardSide==1,1);
        WindWardSide(:) = 0;
        WindWardSide(firstValue) = 1;
    end
    
    if length(Te) > 1
        Te = [Te(1) Te(6) Te(11) Te(16)];
    end
    
% Temperature difference calculation
dT  = Te - Ta;  
    
%% Selection of the wind impact calculation method
switch(CHTCmethod)
    
    case 'Default'
        
        hc = ones(1,4)*20;
        
        hcr = 20;
    
%% TARPWindward (Sparrow et al. 1979)
% This is the TARPwindwand method by Sparrow et al. (1979) for calculating
% CHTC with forced convection and windward surface

    case 'TARPWinward'

        Perimeter = [2*lgts + 2*hgt, 2*lgte + 2*hgt, 2*lgts + 2*hgt, 2*lgte + 2*hgt];    % Perimeters of all 4 walls in order: N, E, S, W
        
        A =[lgts * hgt, lgte * hgt, lgts * hgt, lgte * hgt];
        
        hfc = 2.53 * Rf(WindWardSide) * ((Perimeter(WindWardSide) .* Uw) ./ A(WindWardSide))^0.5;   % Confirm the Rf value and if it means exactly this
        
        hn = 1.31 * abs(dT)^(1/3);
        
        hc = hfc + hn; 
        
        hcr = hc;

%% MoWiTTWindward (Yazdanian and Klemens, 1994)
% This is the MoWiTTWindward method created by Yazdanian and Klemens (1994) 
% to calculate CHTC value for mixed convection on windward surface.

    case 'MoWiTTWindward'

        hc = sqrt((0.84 * abs(dT)^(1/3))^2 + (2.38 * Uw^0.89)^2);
        
        hcr = hc;

%% Nusselt-Jurges (Nusselt and Jurges 1922)
% This is the Nusselt-Jurgens method created by Nusselt and Jurges (1922)
% for calculating CHTC with mixed convection and windward surface

    case 'Nusselt-Jurges'

        hc = 5.8 + 3.94 * Uw;
        
        hcr = hc;

%% McAdams (McAdams 1954)
% This is the McAdams method created by McAdams (1954) to calculate CHTC
% for mixed convection and windward surface.

    case 'McAdams'

        hc = 5.7 + 3.8 * Uw;
        
        hcr = hc;

%% Mitchell (Mitchell 1976)
% This is the Mithcell method by Mitchell (1976) for calculating CHTC for
% forced convection and windward surface

    case 'Mitchell'
        
        L = HouseVolume^(1/3);

        hfc = (8.6 * Uw^0.6)/(L^0.4);
        
        hn = 1.31 * abs(dT)^(1/3); 
        
        hc = hfc + hn;
        
        hcr = hc;

%% EmmetVertical (Emmel et al. 2007) method
% This is a method created by Emmel et al. (2007), taking into account the
% direction of the wind

    case 'EmmelVertical'

        hfc = zeros(1,4); % Pre-allocation

        % Walls
        for w = 1:4 % loop through all the walls, from 1 to 4: N, E, S, W (orientation)
    
            if StWa(w) == 0
    
                hfc(w) = 5.15 * Uw^0.81;
        
            elseif StWa(w) == 315 || StWa(w) == 45
        
                hfc(w) = 3.34 * Uw^0.81;
        
            elseif StWa(w) == 270 || StWa(w) == 90
        
                hfc(w) = 4.78 * Uw^0.71;
        
            elseif StWa(w) == 225 || StWa(w) == 135
        
                hfc(w) = 4.05 * Uw^0.77;
        
            elseif StWa(w) == 180
        
                hfc(w) = 3.54 * Uw^0.76;
        
            end
    
        end

        % Roof 
        if StRa == 0 || StRa == 180
            hfcr = 5.11 * Uw^0.78;
        elseif StRa == 135 || StRa == 45 || StRa == 135 || StRa == 225
            hfcr = 4.6 * Uw^0.79;
        elseif StRa == 90 || StRa == 270
            hfcr = 3.67 * Uw^0.85;
        end
        
        % Natural convection
        
        hn = 1.31 * abs(dT)^(1/3);
        
        % Total CHTC
        
        hc = hfc + hn;
        
        hcr = hfcr + hn;

end

%% Output arguments

varargout{1}  = hc;
varargout{2}  = hcr;

end

