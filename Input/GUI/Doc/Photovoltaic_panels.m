%% Photovoltaic panels
%
% <html><h2>What's inside</h2></html>
%
% It includes: 
% 
% * An on/off check box that allows to 'install' or 'uninstall' a
% PV-System;
% * _Optional_: A set of variables that defines the characterisitcs of the
% solar pv-panel installed.
% 
%% Max Power of 1 module (MaxPowerPV)
% *Default value* : 200; *Unit* : W         
% 
% The maximum power of the PV panels must characterize the maximum output of 1 and only 1 module. Consequently, it is assumed that only one brand at a time can be installed.It is expressed in [W] and the data is available from Photon Magazine. 
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of 200W. 
% 
%% Number of module in parallel (Nbrmodpar)
% *Default value* : 1; *Unit* : No Unit
%
% Number of module in Parallel. Remember that this equation has to be satisfied: Nbrmodser * Nbrmodpar = NbrmodTot.
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of 1 panel in parallel. 
% 
%% Number of module in Series (Nbrmodser)
% *Default value* : 1; *Unit* : No Unit
%
% Number of module in Series. Remember that this equation has to be satisfied: Nbrmodser * Nbrmodpar = NbrmodTot.
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of 1 panel in series. 
% 
%% Angle of the panel on a N/S axis (Aspect)
% *Default value* : -1; *Unit* : [°]
%
% Angle of the panel on a N/S axis (0° = N, 180° = S). If data = -1 then the values are automatically generated during the simulation. It will be considered either as a 1-axis or 2-axis tracking device.
%
% Accepted value: any positive integer --> [0 180]
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1. 

%% Angle of the panels to the horizontal surface (Tilt)
% *Default value* : -1; *Unit* : [°]
%
% Angle of the panels to the horizontal surface (0° = Horiz, 90° = Ver). If Data = -1 then the values are automatically generated during the simulation. It will be considered either as a 1-axis or 2-axis tracking device.
%
% Accepted value: any positive integer --> [0 90]
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.

%% Open circuit voltage (Voc)
% *Default value* : -36.3; *Unit* : [V]
%
% The Open Circuit Voltage (Voc) is a characteristics of a PV cell. It represents the maximum voltage output by the cell (in open circuit). This is a manufacturer information. It is considered that 1 and only 1 brand can be used and installed at the same time on a building. It can be accessed through Photon Magazine and is expressed in [V].
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.

%% Open circuit voltage (Isc)
% *Default value* : 8.2; *Unit* : [A]
%
% The Short Circuit current (Isc) is a characteristics of a PV cell. It represents the maximum intensity output by the cell (in short circuit position). This is a manufacturer information. It is considered that 1 and only 1 brand can be used and installed at the same time on a building. It can be accessed through Photon Magazine. It is expressed in [A].
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.
%% Length of 1 module (LengthPV)
% *Default value* : 1657; *Unit* : [mm]
%
% The length of the PV panels must characterize the maximum output of 1 and only 1 module. Consequently, it is assumed that only one brand at a time can be installed.It is expressed in [mm] and the data is available from Photon Magazine.
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.
%% Width of 1 module (WidthPV)
% *Default value* : 987; *Unit* : [mm]
%
% The width the PV panels must characterize the maximum output of 1 and only 1 module. Consequently, it is assumed that only one brand at a time can be installed.It is expressed in [mm] and the data is available from Photon Magazine.
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.
%% Normal Operating Cell Temperature (NOCT)
% *Default value* : 45; *Unit* : [°C]
%
% The Nominal Operating Cell Temperature of the PV panels must characterize the maximum output of 1 and only 1 module. Consequently, it is assumed that only one brand can be installed. It is expressed in [°C] and the data is available from Photon Magazine.
%
% Accepted value: any positive integer --> [0 Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.
%% Coefficient of voltage (VTempCoff)
% *Default value* : -0.0023; *Unit* : [°C]
%
% The Nominal Operating Cell Temperature of the PV panels must characterize the maximum output of 1 and only 1 module. Consequently, it is assumed that only one brand can be installed. It is expressed in [°C] and the data is available from Photon Magazine.
%
% Accepted value: any positive integer --> ]-Inf Inf[
%
% Exception: -1
% 
% Exception value is preset if nothing is set for this value. It will take the default value of -1.
%%
% 
% <<LogoOulu1.PNG>> 
% 
% Copyright 2016-2018 University of Oulu
%     

