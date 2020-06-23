function [PowerSP] = SmartPlugEnergy(varargin)

switch size(varargin,2)
    case 0
        Occurence     = 300 ;
        Time_transfer = 100 ;
        Active_Power  = 4   ;
        NbrApp        = 1   ;  
    case 1
        Occurence     = 300 ;
        Time_transfer = 100 ;
        Active_Power  = 4   ;
        NbrApp        = varargin{1}   ;  
    case 2
        Occurence     = 300 ;
        Time_transfer = 100 ;
        Active_Power  = varargin{2}   ;
        NbrApp        = varargin{1}   ;  
    case 3
        Occurence     = varargin{3} ;
        Time_transfer = 100 ;
        Active_Power  = varargin{2}   ;
        NbrApp        = varargin{1}   ;    
    case 4
        Occurence     = varargin{3} ;
        Time_transfer = varargin{4} ;
        Active_Power  = varargin{2}   ;
        NbrApp        = varargin{1}   ;
    otherwise
        disp('Too many inputs');
end

LpowerMode = Active_Power * 0.385 ;
Active_time = Time_transfer / 1000 / Occurence ;

Powerh_PerApp =(Active_time*Active_Power+(1-Active_time)*LpowerMode)/1000 ;

PowerSP = Powerh_PerApp * NbrApp ;