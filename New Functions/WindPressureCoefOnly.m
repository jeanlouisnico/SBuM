function [Cp] = WindPressureCoefOnly(varargin)
% Function used for determining wind pressure coefficient for air leakage

%% Input

slope   = varargin{1};
SClass  = varargin{2};  

% Wind direction

% WD      = varargin{3};
% alfa    = 0:90:360;

%fcross  = varargin{3};
h       = varargin{3};

% Pre-allocate

Cp = zeros(1,3);

% Determination of windward
% 
% WindWard    = alfa - WD <= 60 && alfa - WD >= -60;
% LeeWard     = alfa - WD >= 120 && alfa - WD <= 240;
% Along       = alfa - WD == 90;

%% Determining the coefficient

%if fcross == true

if h < 15
    
    switch SClass
        
        case 'Open'
            
            Cp(1)    = 0.5;
            Cp(2)     = -0.7;
%             Cp(3)       = 0;

            if slope < 10
                
                Cp(3)       = -0.7;
                
            elseif slope >= 10 && slope <= 30
                
                Cp(3)       = -0.6;
                
            else
                
                Cp(3)       = -0.2;
                
            end
            
        case 'Normal'
            
            Cp(1)    = 0.25;
            Cp(2)     = -0.5;
            %Cp(Along)       = 0;

            if slope < 10
                
                Cp(3)       = -0.6;
                
            elseif slope >= 10 && slope <= 30
                
                Cp(3)       = -0.5;
                
            else
                
                Cp(3)       = -0.2;
                
            end
            
        case 'Shielded'
            
            Cp(1)    = 0.05;
            Cp(2)     = -0.3;
            %Cp(Along)       = 0;

            if slope < 10
                
                Cp(3)       = -0.5;
                
            elseif slope >= 10 && slope <= 30
                
                Cp(3)       = -0.4;
                
            else
                
                Cp(3)       = -0.2;
                
            end
            
    end
    
elseif h >= 15 && h < 50
    
    switch SClass
        
        case 'Open'
            
            Cp(1)    = 0.65;
            Cp(2)     = -0.7;
            %Cp(Along)       = 0;

            if slope < 10
                
                Cp(3)       = -0.7;
                
            elseif slope >= 10 && slope <= 30
                
                Cp(3)       = -0.6;
                
            else
                
                Cp(3)       = -0.2;
                
            end
            
        case 'Normal'
            
            Cp(1)    = 0.45;
            Cp(2)     = -0.5;
            %Cp(Along)       = 0;

            if slope < 10
                
                Cp(3)       = -0.6;
                
            elseif slope >= 10 && slope <= 30
                
                Cp(3)       = -0.5;
                
            else
                
                Cp(3)       = -0.2;
                
            end
            
        case 'Shielded'
            
            Cp(1)    = 0.25;
            Cp(2)     = -0.3;
            %Cp(Along)       = 0;

            if slope < 10
                
                Cp(3)       = -0.5;
                
            elseif slope >= 10 && slope <= 30
                
                Cp(3)       = -0.4;
                
            else
                
                Cp(3)       = -0.2;
                
            end
            
    end
    
else
   
    Cp(1)    = 0.8;
    Cp(2)     = -0.7;
    %Cp(Along)       = 0;

    if slope < 10
                
        Cp(3)       = -0.7;
                
    elseif slope >= 10 && slope <= 30
                
        Cp(3)       = -0.6;
                
    else
                
        Cp(3)       = -0.2;
                
    end
    
    
end

% else
%     
%     Cp(1)    = 0.05;
%     Cp(2)     = -0.05;
%     %Cp(Along)       = 0;
%     Cp(3)           = 0;
%     
% end
        

end

