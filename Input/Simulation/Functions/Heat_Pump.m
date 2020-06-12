function [Power] = Heat_Pump(HP_Power, iter7, Temp_out, Thermal_Demand)


global Ext_Temp_e Ext_Temp_d Ext_Temp_c Ext_Temp_b Ext_Temp_a
global Wat_Temp_e Wat_Temp_d Wat_Temp_c Wat_Temp_b Wat_Temp_a
global Mot_Speed_e Mot_Speed_d Mot_Speed_c Mot_Speed_b Mot_Speed_a Iteration7


if Iteration7(Housenbr, 1) == 0;
    switch(HP_Power)
        case '5 kW'
            Machine = 1;
        case '6 kW'
            Machine = 2;
        case '8 kW'
            Machine = 3;
        case '10 kW'
            Machine = 4;
        case '16 kW'
            Machine = 5;
    end
    
    data = load ('Smart_House_Data_MatLab.mat');
    Ext_Temp_e  = data.Heat_Pump_Ext_Temp(Machine, 1) ;
    Ext_Temp_d  = data.Heat_Pump_Ext_Temp(Machine, 2) ;
    Ext_Temp_c  = data.Heat_Pump_Ext_Temp(Machine, 3) ;
    Ext_Temp_b  = data.Heat_Pump_Ext_Temp(Machine, 4) ;
    Ext_Temp_a  = data.Heat_Pump_Ext_Temp(Machine, 5) ;
    
    Wat_Temp_e  = data.Heat_Pump_Wat_Temp(Machine, 1) ;
    Wat_Temp_d  = data.Heat_Pump_Wat_Temp(Machine, 2) ;
    Wat_Temp_c  = data.Heat_Pump_Wat_Temp(Machine, 3) ;
    Wat_Temp_b  = data.Heat_Pump_Wat_Temp(Machine, 4) ;
    Wat_Temp_a  = data.Heat_Pump_Wat_Temp(Machine, 5) ;
    
    Mot_Speed_e = data.Heat_Pump_Mot_Speed(Machine, 1);
    Mot_Speed_d = data.Heat_Pump_Mot_Speed(Machine, 2);
    Mot_Speed_c = data.Heat_Pump_Mot_Speed(Machine, 3);
    Mot_Speed_b = data.Heat_Pump_Mot_Speed(Machine, 4);
    Mot_Speed_a = data.Heat_Pump_Mot_Speed(Machine, 5);
    
end





