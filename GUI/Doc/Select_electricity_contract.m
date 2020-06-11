%% Select electricity contract
%
% <html><h2>What's inside</h2></html>
%
% It includes: 
% 
% * Different electricity contract that are available for individual people;
% 
% 
%% Electricity contract
%
% The electric contracts have been taken from the commercial offers from Oulun Energia. 
% Oulun energia has 3 main contracts: 
%
% # Varmavirta (energy mix, cheap contract), 
% # Vihreävirta (Energy based on biomass production, Middle price), 
% # Tuulirvirta (Energy based on wind, High price). 
%
% There is also an option to use the real-time pricing as an optional input. 
% Real-time pricing is based on the NordPool price.
% 
% Four (4) types of electricity contracts are available: 
% 
% # Real-time pricing
% # Varmavirta (Energy mix contract)
% # Vihreavirta (Biomass based contract)
% # Tuulivirta (Wind contract)
% 
%% Real-time pricing
%
% Real time pricing are using hourly data from NordPool for historical data
% or hourly electricity price in general (if the price profile is provided
% in the "time setting" tab.
%
% Two options for limiting the electricty price to peak down or up will
% limit the electricity price. In case an upper and lower limit are set, an
% associated monthly fee is added to the bill for compensating the energy
% producers. In case the real-time (RTT) pricing is chosen, then it is possible 
% to set a low limiting value. In case no limiting value needs to be set, 
% the default value is "-99999" or "99999" for the higher limit, but you can 
% leave the cell blank, it will get filled automatically. One of the condition 
% to be respected is that the low price must be greater than the higher limit value and vice versa. 
%% Varmavirta
%
% Varmavirta is the cheapest electricity contract available
%
% _Option_ :  Fix price or time of use (ToU) tariffs. Fix price considers a
% fixed price for electricty tariffs throughout the year while ToU
% considers the time between 7 to 22 and from 22 to 7 as different prices. 
% Winter and summer periods are also differentiated.
%% Vihreavirta
%
% _Option_ :  Fix price or time of use (ToU) tariffs. Fix price considers a
% fixed price for electricty tariffs throughout the year while ToU
% considers the time between 7 to 22 and from 22 to 7 as different prices. 
% Winter and summer periods are also differentiated.
%% Tuulivirta
%
% _Option_ :  Fix price or time of use (ToU) tariffs. Fix price considers a
% fixed price for electricty tariffs throughout the year while ToU
% considers the time between 7 to 22 and from 22 to 7 as different prices. 
% Winter and summer periods are also differentiated.
%%
% 
% <<LogoOulu1.PNG>> 
% 
% Copyright 2016-2019 University of Oulu
% 