%% Fuel Cell (PEMFC)
% The model presented for the fuel cell to be integrated into the dwelling
% integrate the Proton Exchange Membrane (PEM) technology. So far, this
% module has not been integrated into the simulation as the model require a
% finner simulation model. The PEMFC model works iteratively for
% recalculating the temperature of the fuel cell, the power output, and the
% need for cooling the system. It also integrates a cut-off point when the
% temperature of the fuel cell gets too high (over 65°C) and can restart
% only when the temperature cools down below 55°C. The cooling system
% assumes an air ventilated system using the ambient air. Several
% assumptions have been made in order to ease the model such as: the
% ambient air temperature is constant at 25°C, the fan is an on/off system
% that allow to ventilate 8 m3/h, the volume flow rate of hydrogen is set 
% constant having an on/off system, and several others that will be detailed
% further on in the description of the module.
%% Function trigger
% In order to run the module, the power capacity of the PEMFC as well as
% the house number is sufficient.
function [FCPower] = Fuel_Cell(H2_Flow, timehour, iter4, myiter, MaxPowerFC, Housenbr, Tin_water)
global Cell_Temp, global Cell_Current, global Qcool Iteration4 Temp_H2O_trigger Temp_H2_trigger
%% Initial values
% Three variables have to be passed through every iteration: the cell
% temperature _*Cell_Temp*_, the current delivered by the fuel cell
% _*Cell_Current*_, and the amount of cold produced within the by the heat
% exchanger _*Qcool*_. At the first iteration, the cell temperature is set
% to 25°C which is the equivalent of the room temperature at t = 0, the
% current _*icell*_ characterising the fuell cell is set at a standard value of 125
% mA/cm2, and the cooling power is set to 0 W.
if Iteration4 < 1;
    Cell_Temp(Housenbr, 1)      = 25    ;   
    Cell_Current(Housenbr, 1)   = 125   ;   
    Qcool(housenbr, 1)          = 0     ;  
    Temp_trigger_up(Housenbr, 1)= 0     ;
end
%% Fuel Cell Size
% The fuel cell characteristics depends on the power output of the PEMFC
% chosen for the simulation. Three models are proposed in the simulation
% for three different maximum power output: 1, 3, and 5 kW. The
% characteristics for each PEMFC can be found in the table below.
%%%
% 
% <<Energy Efficiency Calculation - Low Temp FC.PNG>>
% 
%%%
% Nevertheless, only three of all the characteristics will be used in the
% model, the maximum hydrogen consumption for electricity consumption, the
% cell area _*Cell_Area*_ [cm2] of the fuel cell selected, and the number of cell
% within the fuel cell _*Cell_Nbr*_.
switch (MaxPowerFC)
    case '1 kW'
        H2Liters   = 14 * Temp_H2_trigger(Housenbr, 1)      ;
        Cell_Area  = 712.8                                  ;
        Cell_Nbr   = 72                                     ;
    case '3 kW'
        H2Liters    = 42 * Temp_H2_trigger(Housenbr, 1)     ;
        Cell_Area   = 608                                   ;
        Cell_Nbr    = 72                                    ;
    case '5 kW'
        H2Liters    = 84 * Temp_H2_trigger(Housenbr, 1)     ;
        Cell_Area   = 608                                   ;
        Cell_Nbr    = 120                                   ;
    otherwise
        H2Liters = 42;
end
%% Cell stack properties
%%% Hydrogen Mass Flow Rate
% The volume flow rate is assumed to be constant. Nevertheless, the volume 
% flow rate is given in litre per minute while the mass flow rate will be
% used to calculate the power output of the fuel cell.
%%%
% $$V_{H_{2}} = \frac{RT}{P}$$
%%%
% Where _*VH2*_ is the volume of hydrogen [m3/mol] for a given pressure
% _*P*_ [Pa] and a stack temperature _*T*_ [K], and R is the ideal gas 
% constant 8.314 [J/K.mol-1]. In this section, it is
% given in the specification table of the fuel cell that the pressure
% inside the fuel cell varies from 7.2 to 9.4 PSI, which is equivalent to
% 49642 Pa to 64810 Pa. thus an average pressure of 57226 Pa is being used
% in equation ... .
%%%
% $$\rho_{H_{2}} = \frac{M_{H_{2}}}{V_{H_{2}}}$$
%%%
% Where _*rho H2*_ is the hydrogen density the molecular mass _*MH2*_ is 
% equal to 2.0158*10-3 [kg/mol].
%%%
% consequently, the hydrogen mass flow rate is equal to:
%%%
% $$\dot{q}_{m_{H2}}= \rho_{H_{2}} \cdot V_{H_{2}}$$
%%%
% Where qmH2 is the mass flow rate [kg/s].
V_H2 = 8.314 * Cell_Temp(Housenbr, 1) / 57226   ;
Rho_H2 = 0.0020158 / V_H2                       ;
H2_Massflowrate = H2Liters * Rho_H2 / 60000     ;
%%% Theoretical cell voltage
% 
Cell_Temp_Ref = 25 + 273.15;
%%%
% Molar heat Capacity for Steam, Hydrogen, and Oxygen
%%%
% The molar heat capacity for each of the state of the different molecules
% can be expressed for the the water (in gas form), dioxygen, and dihydrogen 
% and are found in Equations ...., ..., and ... respectively. 
%%%
% $$C_{p_{H2O}} = 143.05 - 58.04x^{0.25} + 8.2751x^{0.5} - 0.036989x$$
%%%
% $$C_{p_{H2}} = 56.505 - 22222.6x^{-0.75}+116500x^{-1}-560700x^{-1.5}$$
%%%
% $$C_{p_{O2}} = 37.432 + 0.000020102x^{1.5} - 178570x^{-1.5} +
% 2368800x^{-2}$$
C_p_H2O = @(x) 143.05 - 58.04 .* x.^0.25 + 8.2751.*x.^0.5 - 0.036989.*x;
C_p_H2 = @(x) 56.505 - 22222.6.*x.^(-0.75)+116500.*x.^(-1)-560700.*x.^(-1.5);
C_p_O2 = @(x) 37.432 + 0.000020102.*x.^1.5 - 178570.*x.^(-1.5) + 2368800.*x.^(-2);
%%%
% The molar enthalpy at a certain temperature is given as for each
% molecules is given as:
%%%
% $$ht_{H2O}=\int_{T_{Ref}}^{T_{Cell_{n}}}C_{p_{H2O}}dx$$
%%%
% $$ht_{O2}=\int_{T_{Ref}}^{T_{Cell_{n}}}C_{p_{O2}}dx$$
%%%
% $$ht_{H2}=\int_{T_{Ref}}^{T_{Cell_{n}}}C_{p_{H2}}dx$$
ht_H2O = integral(C_p_H2O,Cell_Temp_Ref,Cell_Temp(Housenbr, 1))  ;
ht_H2  = integral(C_p_H2,Cell_Temp_Ref,Cell_Temp(Housenbr, 1))   ;
ht_O2  = integral(C_p_O2,Cell_Temp_Ref,Cell_Temp(Housenbr, 1))   ;
%%%
% The molar entropy for each molecule is given as:
%%%
% $$St_{H2}=\int_{T_{Ref}}^{T_{Cell_{n}}}\frac{1}{x}C_{p_{H2}}dx$$
%%%
% $$St_{O2}=\int_{T_{Ref}}^{T_{Cell_{n}}}\frac{1}{x}C_{p_{O2}}dx$$
%%%
% $$St_{H2O}=\int_{T_{Ref}}^{T_{Cell_{n}}}\frac{1}{x}C_{p_{H2O}}dx$$
St_H2O = integral(@(x) 1./x.*C_p_H2O(x),Cell_Temp_Ref, Cell_Temp(Housenbr, 1))   ;
St_H2  = integral(@(x) 1./x.*C_p_H2(x),Cell_Temp_Ref, Cell_Temp(Housenbr, 1))    ;
St_O2  = integral(@(x) 1./x.*C_p_O2(x),Cell_Temp_Ref, Cell_Temp(Housenbr, 1))    ;

%%% DSt and Dhf calculation  
% The variation of molar entropy and enthalpy is equal to the sum of each
% molar entropy.
%%%
% $$DS_{t_{O2}}=\left ( St_{H2O}-St_{H2}- \frac{St_{O2}}{2}\right )\times
% 10^{-3}$$
%%%
% $$Dhf=\left ( ht_{H2O}-ht_{H2}- \frac{ht_{O2}}{2}\right )\times 10^{-3}$$
DSt = (St_H2O - St_H2 - 0.5 * St_O2) * 10^(-3);
Dhf = (ht_H2O - ht_H2 - 0.5 * ht_O2) * 10^(-3);
%%%
% $$Dgf=Dhf-Dst \cdot T_{Cell_{n}}$$
%%%
% Where Dgf is ... [kJ/mol].
Dgf = Dhf - Cell_Temp(Housenbr, 1) * DSt;
%%%
% The Maximum voltage coming out from the cell can be evaluted from the ...
% and the Faraday constant C:
%%%
% $$V_{Max} = \frac{-Dgf\cdot10^3 }{2F}$$
Cell_V_Max = -Dgf * 10^3 / (2*96485.3399);
%%% Losses
%%% Activation. fuel cross over and internal losses
% The activation losses from the PEMFC can be evaluated from the current
% _*icell*_, and the reference current _*i0*_:
%%%
% $$V_{Act Loss}=A-ln\left ( \frac{i_{Cell}+2.7}{i_{0}} \right )$$
A_Cst      = (8.314*Cell_Temp(Housenbr,1))/(2*0.5*96485.3399)                   ;
Activ_Loss = Cell_V_Max - A_Cst * log((Cell_Current(Housenbr, 1) + 2.7) / 0.04) ;
%%%
% Tradiationally, i0 takes the value 0.04 mA for a PEM fuel cell. The
% constant A is calculated using the equation below and does not have a
% unit:
%%%
% $$A=\frac{8.314T_{Cell_{n}}}{2\frac{1}{2}F}$$
%%% Resistance Losses
% The second type of losses is called the resistance losses or ohmic losses
% due to the resistance of the materials used for the fuel cell. It is
% expressed as the product of the fuel cell current times the resistance
% losses.
%%%
% $$V_{Res}=i_{Cell}r$$
%%%
% Where r is the resistance [Ohm.cm-2] and takes a standard value of
% 0.000245.
V_Losses             = 0.000245 * Cell_Current(Housenbr, 1);
Resistance_Losses    = Activ_Loss - V_Losses; 
%%% Mass transport losses 
% The final losses is called the mass transport losses and constitute the 
% depletion of reactants at catalyst sites under high loads, causing rapid 
% loss of voltage.
%%%
% $$V_{Tran}=me^{i_{Cell}n}$$
%%%
% _m_ and _n_ are constant taking the values 0.00003 V and 0.008 V
% respectively.
%%%
% The output voltage of the fuel cell can be thus calculated (Eq...) by subtracting
% the maximum theoretical voltage with each voltage drop from the fuel cells by uising equations .........
%%%
% $$V_{Cell}=V_{Max}-V_{Act Loss}-V_{Res}-V_{Tran}$$
Voltage_Losses = Resistance_Losses - 0.0000211 * exp(0.008 * Cell_Current(Housenbr, 1));
%%% Output the Power
% The output power from the fuel cell has shown empirical equations that
% link the hydrogen consumption and the fuel cell voltage.
%%%
% $$P_{Cell}=V_{Cell}\cdot \dot{q}_{v_{H2}}\frac{2F}{M_{H_{2}}}$$
Power_P = Voltage_Losses * H2_Massflowrate / (0.0020158/(2*96485.3399));
%%% Output the current
% Consequently, the current generated can be deducted and and expressed in
% mA.
%%%
% $$i=\frac{P_{Cell}}{V_{Cell}\cdot n_{Cell}}10^{3}$$
%%%
% Where i is the current output of the fuel cell [mA]
Current = Power_P / (Cell_Nbr * Voltage_Losses) * 1000;
%%%
% Nevertheless, the cell current used in the model need to be expressed in
% terms of surface area, thus the fuel cell current must be divided by the
% total surface of the cells.
%%%
% $$i_{Cell} = \frac{i}{A_{Cell}}$$
%%%
% Where _*icell*_ is the fuel cell current [mA.cm-2]
Cell_Current(Housenbr, 1) = Current / Cell_Area; 
%% Thermal input and output
%%% Calculation of the heat produced by the FC
% The heat produced by the fuel cell is calculated by using an empirical
% equation established:
%%%
% $$Q=P_{Cell}\left ( \frac{1.25}{V_{Cell}}-1 \right )$$
%%%
% Qheat = Power_P * (1.25 / Voltage_Losses - 1);
%%% Calculation of the Losses    
% The room temperature is assumed to be 25°C, further development should 
% recalculate the temperature in the room in order to have variation taken 
% into account
%%%
% $$Q_{Loss}=\frac{T_{Cell_{n}}-T_{amb}}{0.115}$$
Room_Temp = 20;
QLoss = (Cell_Temp(Housenbr, 1) - Room_Temp) / 0.115;
%%% Cooling System
% Taken from khan & Iqbal
%%%
% The cooling system considered in this model run a water based heat
% exchanger. An air-ventilated heat exchanger could be used but is not
% advised for fuel cell power output greater than 1 kW. The heat extracted
% from the water heat exchanger depends on the log mean temperature
% difference of the heat exchanger and the UA product. The UA
% characteristics of the heat exchanger can be characterized as a function
% of the current output of the fuel cell _*i*_, and by defining the
% convection and conduction constant of the heat exchanger _*hcond*_ and
% _*hconv*_.
%%%
% $$UA_{HX}=h_{cond}+h_{conv}\frac{i}{1000}$$
%%%
% where UAHX is the characteristic of the heat exchange [W/C], hconv is the
% convection properties of the HEX [W/(C.A)], hcond is the conductive property of the
% HEX [W/C], and i is the current output of the fuel cell [mA]. The usual
% value of hcond and hconv are 35.55 W/C and 0.025 W/(C.A) respectively. 
UAhx = 35.55 + 0.025 * Current / 1000; 
%%%
%  The total power is seen as the power content in the hydrogen, and thus
%  can be evaluated by using the enthalpy for combustion of the hydrogern. 
%%%
% $$P_{total} = \dot{q}_{m_{H2}}\cdot \Delta H_{H2}$$
%%%
% Where qmH2 is the hydrogen mass flow rate [mol/s] and is found from
% Eq..., DH2 is the enthalpy for combustion of the hydrogern and take a
% typical value of 285 500 [J/mol].
H2_Massflowrate_mol = H2_Massflowrate/2.01588*1000  ;
Ptotal = H2_Massflowrate_mol * 285.5 * 1000         ;
%%%
% The next consists at calculating the cooling power depending on the water
% flow rate and the temperature of the fuel cell and the water temperature.
% A general formula considers that the power output can be calculated from
% the water flow rate, the heat capacity of water and the temperature
% difference bwteen the inlet and the outlet.
%%%
% $$Q_{cool}=\dot{q}_{m_{H2O}}C_{p}(T_{out} - T_{in})$$
%%%
% Where qmH2O is the mass flow rate of water [kg/s], tout is the water
% temperature at the outlet [C], Tin is the water temperatrue at the inlet
% [C], and Cp is the water heat capacity [J/(kg.K)]. The input water temperature _*Tin_water*_ is taken from the climatic
% database settled in the model.
%%%
% It is to be noted that the water temperature at the outlet is unknown,
% but can be defined using the HEX characteristics
%%%
% $$Q_{cool}=UA_{HX}\frac{T_{out}-T_{in}}{ln\left (
% \frac{T_{Cell_{n}}-T_{in}}{T_{Cell_{n}}-T_{out}} \right )}$$
%%%
% Thus,
%%%
% $$T_{out}=T_{Cell_{n}}-\frac{T_{Cell_{n}}-T_{in}}{e^{\frac{UA_{HX}}{\dot{q}_{m}
% \cdot C_{p}}}}$$
waterflowrate = 1 * Temp_trigger_up(Housenbre,1)    ;
Tout_water = @(Tcell, Tin_water, waterflowrate, UAhx) Tcell - (Tcell - Tin_water)/(exp(UAhx/(waterflowrate * 4185)))   ;
Qcool(Housenbr, 1) = waterflowrate * 4185 * (Tout_water(Cell_Temp(Housenbr, 1), Tin_water, waterflowrate, UAhx) - Tin_water)                                            ;
%%% With air
% % qv = 1 ;
% % 
% % INCpa  = @(Tin) -7.35654E-10.*Tin.^3+7.03941E-7.*Tin^2-6.61766E-6.*Tin+1.004228352              ;
% % INPws  = @(Tin) (exp(77.345+0.0057.*(Tin+273.15)-7235./(Tin+273.15)))./((Tin+273.15).^8.2)      ;
% % INPw   = @(Tin) INPws(Tin).*0.5                                                                 ;
% % INxvar = @(Tin) 0.62198.*INPw(Tin)./(101325 - INPw(Tin))                                        ;
% % INhw   = @(Tin) 1.84.*Tin+2501                                                                  ;
% % INha   = @(Tin) INCpa(Tin ).*Tin                                                                ;
% % 
% % OUTCpa  = @(Tout) -7.35654E-10.*Tout.^3+7.03941E-7.*Tout^2-6.61766E-6.*Tout+1.004228352         ;
% % OUTPws  = @(Tout) (exp(77.345+0.0057.*(Tout+273.15)-7235./(Tout+273.15)))./((Tout+273.15).^8.2) ;
% % OUTPw   = @(Tout) OUTPws(Tout).*0.9                                                             ;
% % OUTxvar = @(Tout) 0.62198.*OUTPw(Tout)./(101325 - OUTPw(Tout))                                  ;
% % OUThw   = @(Tout) 1.84.*Tout+2501                                                               ;
% % OUTha   = @(Tout) OUTCpa(Tout).*Tout                                                            ;
% % OUTRho  = @(Tout) -2.8354*10^(-8).*Tout.^3+2.01558*10.^(-5).*Tout.^2-0.005597757.*Tout+1.299643247 ;
% % 
% % hout    = @(Tout) OUTha(Tout) + OUTxvar(Tout).*OUThw(Tout)                                      ;
% % hin     = @(Tin) INha(Tin) + INxvar(Tin).*INhw(Tin)                                             ;
% % 
% % qm      = @(Tout) qv*OUTRho(Tout)                                                               ;
% % 
% % Qcool   = @(Tin, Tout) qm(Tout).*(hout(Tout)-hin(Tin)).*1000                                     ;
% % 
% % syms Tout
% % Tout_water = solve(Qcool(25,Tout_water)==Qwater)                                                            ;



%%% Re-calculation of the FC Temperature
% As mentioned in the previous paragraph, heat is produced during the active phase of
% electrical production. On the other hand, the fuel cell sees its temperature rising. It can be
% assumed that the temperature rise in the fuel cell is mostly due to the production of heat
% during the chemical reaction (Khan & Iqbal, 2004).
%%%
% $$\frac{dT}{dt}=\frac{Q_{Heat}-Q_{cool}-Q_{loss}}{C_{t}}$$
%%%
% Where _*Ct*_ is the thermal capacitance and is assumed equal to 17 900
% [J/C], _*dT/dt*_ is the variation of temperature [C/s]
DT_Dt = (Ptotal - Power_P - QLoss - Qcool(Housenbr, 1)) / 17900;
%%%
% Thus, the fuel cell temperature can be incremented by the temperature
% variation
%%%
% $$T_{Cell_{n+1}}=  \frac{dT}{dt} + T_{Cell_{n}}$$
Cell_Temp(Housenbr, 1) = DT_Dt + Cell_Temp(Housenbr, 1);
%% Control System
%%% Regulating the water flow
% In case the temperature of the fuel cell exceed 55 C, the control system
% trigger a relay that allows the circulation of water in the heat
% exchanger to maintain the fuel cell temperature. Although very basic, it
% allows maintaining the temperature within the range..
if Cell_Temp(Housenbr, 1) > 55
    Temp_H2O_trigger(Housenbr, 1) = 1   ;
else
    Temp_H2O_trigger(Housenbr, 1) = 0   ;
end
%%% Regulateing the hydrogen flow
% Similarly, the hydrogen stop feeding the fuel cell when the temperature
% gets over 65C and can re-open the valve once the temperature of the fuel
% cell gets below 55.
if Cell_Temp(Housenbr, 1) > 65
    Temp_H2_trigger(Housenbr, 1) = 0    ;
elseif Cell_Temp(Housenbr, 1) < 55
    Temp_H2_trigger(Housenbr, 1) = 1    ;
end
FCPower = Power_P                       ;