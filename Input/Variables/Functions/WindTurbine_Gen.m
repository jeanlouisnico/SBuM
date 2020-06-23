function [PowerWT] = WindTurbine_Gen(tref, Hourly_Wind_Speed, Wind_Park)
WindSpeed    = 9   ;
Lambdanom    = 8.1 ; 
Cp           = 0.48;
MaxPowerWT   = 0.73;
Baserotspeed = 1.2 ;
Pitch2        = 4   ;        
EfficiencyWT = 0.68;
%tref = (datenum(2012,11,22) + 22/24);
twsrow = tref * 24 - datenum(2000,1,1) * 24;
randwind = max(0.01,RandBetween(0,275,1,size(Wind_Park,2))/100*Hourly_Wind_Speed(twsrow,1));
randwind(randwind > 25) = 0.01;
       
if WindSpeed == 0
    Wind_speed_base = 0;
else
    Wind_speed_base = randwind / WindSpeed ;
end

Wind_Nominal_speed = 1.1 / Baserotspeed;

if Wind_speed_base == 0
    Lambda_pu = 0;
else
    Lambda_pu = Wind_Nominal_speed ./ Wind_speed_base;
end
Lambda = Lambda_pu * Lambdanom;

Lambda_i = 1./(1./(Lambda + 0.08 * Pitch2) - 0.035 / (Pitch2^3 + 1));

Cpnom = 0.5176 .* (116 ./ Lambda_i - 0.40 * Pitch2 - 5) .* exp(-21 ./ Lambda_i) + 0.0068 .* Lambda;
Cperf_pu = Cpnom / Cp;

Pm_pu = Cperf_pu .* Wind_speed_base.^3 .* Wind_Park .* EfficiencyWT;
PowerWS = Pm_pu;
PowerWS(PowerWS<0) = 0;
PowerWT = sum(PowerWS);