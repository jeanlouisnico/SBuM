%% Micro Fuel Cell
% The micro fuel cell model considers PEMFC and is a basic model of the
% working conditions of a regular FC. The model is split in two part: the
% hydrogen production from a small electrolyzer and the electricity
% production from the PEMFC. As the simulation step is set to be 1h, it is
% unnecessary to have a fine representation of the hydrogen production from
% the electrolyzer as well as the behaviour of the FC depending on the
% production of electricity and its consumption of hydrogen. This is left
% for future development when a finner time step will be used as the
% temperature of the fuel cell will influence the electricity production.
% Nevertheless, the model below has been nuilt to evaluate the hydrogen
% production from an electrolyser at a lower level of resolution.
%% Function call
% The function to be called regroup multiple variable either as global or
% passed throught the function. Climatic and temporal data: _*timehour*_
% that represents the current hour, _*myiter*_ respresents the number of
% iteration in the simulation, _*Temp_Water*_ is a timeserie vector of the
% water temperature, _*timeoffset*_ is the amount of steps that has to be
% considered to be skipped in order to have read the right row of
% information data (used for the water data), _*Season*_ is a boolean
% indicating if we are in winter or in summer. Then, the electric contract
% chosen is passed through _*ContElec*_, the power of the FC chosen is
% _*MaxPowerFC*_, the price of electricity at a given time is given by the
% variable _*Price*_. The state of the electrolyser such as the hydrogen
% accumulated _*V_H2_Cumul*_ retrieve a boolean.
function [ElecPower, FCPower, All_Var] = Electroylzer(Time_Sim, All_Var, Input_Data, EnergyOutput)

ContElec = Input_Data.ContElec ;
MaxPowerFC = Input_Data.MaxPowerFC ;
timehour    = Time_Sim.timehour ;
myiter      = Time_Sim.myiter   ;
Temp_Water  = All_Var.Hourly_Water ;
%% Data initialization
% The water dataset is uploaded in the global memory of the workspace, and
% other data related to the electrolyser are set to 0.
if Time_Sim.Iteration4.(Input_Data.Headers) < 1
    All_Var.V_H2_Cumul.(Input_Data.Headers) = 0;
    All_Var.Fcn3.(Input_Data.Headers)       = 0;
    All_Var.Cumul.(Input_Data.Headers)      = 0;
end
%%%
% Some of the variables characterizing the electrolyser are set in this
% section. It is possible to change the characteristics but the choice has
% been made to set the charachateristics of the electrodes' area to 0.25
% m2, the operating temperature of the electrolyser to 50C, setting the
% number of electron moles at 2, and the number of cells to 21.
A_el = 0.25;T_op = 50;mol_e = 2; N_el = 21;Electro_Power=4000;
%% Contract statement
% The model of the electrolyser working in a real-time pricing environment
% has not been made. For this reason, the output is set to 0 for not
% producing any energy. The production of hydrogen occurs when the price of
% electricity is lower, meaning at night time, from 22 to 7 in the morning.
if strcmp(ContElec,'Varmavirta') || strcmp(ContElec,'Vihrevirta') || strcmp(ContElec,'Tuulivirta')
    if or(timehour < 7, timehour >= 22)
        Contract = 1;
    else
        Contract = 0;
    end
else
    Contract = 0;
end
%% Electrolyser
% The modeling part has been taken from Barthels et al. (1998). The power
% of the electrolyser is defined from the 
%%%
% $$P_{E_{z}}=C_{elec}\wedge E_{z}\times P_{E_{z}}$$
%%%
% Where _PEz_ is the power of the electrolyser, _Ez_ is the state of the
% hydrogen storage and is a boolean (see Equation...), and _Celec_ is the
% state of the elecotrlyser and is also a boolean, as defined above.
Powerelectrolyzer = Contract * Electro_Power * All_Var.V_H2_Cumul.(Input_Data.Headers);
PowerElectrolyzer = Powerelectrolyzer / 1000;
%%%
% The hydrogen production is a function of the operating temperature of the
% electrolyser. as it can be noticed, the temperature does not vary in time
% and represent one of the many simplification of the model.

%%%
% $$Fc = N_{el}\cdot 0.995\, e^{\left (
% \frac{-9.58-0.056T_{op}}{\frac{P_{E_{z}}-F_{c2-n-1}}{40}\times
% \frac{1}{A_{el}}} \right )+\left ( \frac{1502.7-70.8T_{op}}{\left
% (\frac{P_{E_{z}}-F_{c2-n-1}}{40}\times \frac{1}{A_{el}}  \right )^{2}}
% \right )}$$
Add1 = (Powerelectrolyzer - All_Var.Fcn3.(Input_Data.Headers) ) / 40;
if max(0,Add1) == 0
    Fcn  = 0;
    Fcn2 = 0;
else
    Fcn  = (-9.58 - 0.056 * T_op) / (max(0,Add1)/A_el);
    Fcn2 = (1502.7 - 70.8 * T_op)/(max(0,Add1)/A_el)^2;
end
Fcn1 = N_el * (0.995 * exp(Fcn + Fcn2));
%%%
% Finally, the volume of hydrogen can be calculated as:
%%%
% $$V_{H_{2}}=F_{c}\times \frac{P_{E_{z}}-F_{c2-n-1}}{40}\cdot \left (
% \frac{1}{96485\cdot mol_{H_{2}}} \cdot V\times 3600\right )$$
%%%
% Where _VH2_ is the volume of hydrogen in [m3], 96485 is the
% Faraday constant, and _V_ is the molar volume of hydrogen (0.0224
% m3/mol].
H2_L = Fcn1 * Add1 * (1 / (96485 * mol_e) * 0.0224 * 3600);
%%%
% Where,
%%%
% $$F_{c2-n-1}=18T_{w}e^{-3}\cdot \frac{4187}{3600}\cdot \left (
% T_{op}-\frac{V_{H_{2}}}{0.0224} \right )$$
All_Var.Fcn3.(Input_Data.Headers) = Temp_Water(myiter+1) * 18 * exp(-3) * 4187 / 3600 * (T_op - H2_L / 0.0224);
SwitchH2_L = max(0,H2_L);
%% High price definition
% Defines the high price rate for each contract type for both seasons
% winter and summer.
% TO BE MODIFIED

[varseason, ~, ~] = Forecaste_Timeslot(Time_Sim, 0, Input_Data) ;

if varseason == 1
    switch(ContElec)
        case 'Varmavirta'
            Highprice = 7.21;
        case 'Vihrevirta'
            Highprice = 7.36;
        case 'Tuulivirta'
            Highprice = 7.51;
        otherwise
            Highprice = 7.51;
    end
else
    switch(ContElec)
        case 'Varmavirta'
            Highprice = 6.86;
        case 'Vihrevirta'
            Highprice = 7.01;
        case 'Tuulivirta'
            Highprice = 7.16;
        otherwise
            Highprice = 7.51;
    end
end
%% Energy Production
% If the price of electricity reach the high price (day time), then the FC
% is producing its energy and the corresponding volume of hydrogen is
% withdrawn from the hydrogen tank storage. Otherwise, the FC is not
% activated.
if Highprice <= EnergyOutput.Price
    switch (MaxPowerFC)
        case '1 kW'
            H2Liters = 14;
            MaxPowerFC2 = 1;
        case '3 kW'
            H2Liters = 42;
            MaxPowerFC2 = 3;
        case '5 kW'
            H2Liters = 84;
            MaxPowerFC2 = 5;
        otherwise
            H2Liters = 42;
            MaxPowerFC2 = 0;
    end
else
        H2Liters = 0;
        MaxPowerFC2 = 0;
end
%% Hydrogen storage
% The amount of hydrogen to be taken from the storage tank in order to run
% the FC depends on the size of the fuel cell. Nevertheless, the hydrogen
% flow rate _*qvh2*_ is considered in the following equation:
%%%
% $$q_{H_{2}}=\dot{q_{v}}_{H_{2}}\cdot \, \frac{60}{stp}\cdot \,
% \frac{1}{1000}$$
H2_Stored = H2Liters * 60 * Time_Sim.stepreal / 1000;
%%%
% and the amount left in the hydrogen tank is:
%%%
% $$S_{H_{2}-\left (n  \right )}=S_{H_{2}-\left (n-1  \right
% )}+max(0,V_{H_{2}})-q_{H_{2}}$$
All_Var.Cumul.(Input_Data.Headers) = All_Var.Cumul.(Input_Data.Headers) + SwitchH2_L - H2_Stored;
H2_Liters = All_Var.Cumul.(Input_Data.Headers) * 1000;
%%%
% In case the hydrogen storage tank is full, the production of hydrogen is
% null as there is no space to store the hydrogen.
if H2_Liters >= 760
    All_Var.V_H2_Cumul.(Input_Data.Headers) = 0;
else
    All_Var.V_H2_Cumul.(Input_Data.Headers) = 1;
end

%[FCPower] = FuelCell(H2Liters, timehour, iter4, myiter); Consider this
%option if the somulation is taken down to a second

FCPower = MaxPowerFC2 * 0.9;

ElecPower = PowerElectrolyzer';

