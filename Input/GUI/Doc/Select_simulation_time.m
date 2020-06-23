DataBase.(Scenario).averaged.averagedMin(:,SelectedYearDaily)%% Select simulation time
%
% <html><h2>What's inside</h2></html>
%
% It includes: 
% 
% * Start and end date for the simulation. Dates must be filled in. At the
% moment, the dates are limited by the default file input.
% * _Optional_: It is possible to work with your own weather data files. In this case, link the file and adjust the starting date of the file. 
% 
%% Start date
% *Default value* : 01/01/2012; *Unit* : [day]         
% 
% You may select the date by inputing manually in the text box the date you
% want to have. The default format is dd/MM/yyyy. It is however possible to
% input the dates in different format. If no dates are given, it
% automatically input today's date in the edit form. The date will appear
% in red if the starting date and ednig date do not match e.g. the ending
% date is older than the starting date.
%
% _Examples_ : day - dd
%              month - MM or MMM (either numeric or full month name)
%              year - yy or yyyy If the year is given with 2-digits, it will
%              be interprated as 19XX if the 2-digits are greater than 60 and
%              as 20XX otherwise.
%
% _Valid Format_ : 02.January.2019, 02/01/2019, 02-01-19
%
% _Accepted separator for dates_ :  . -  / or space
%
% _Exception_ : NaN
% 
%
%% End date
% *Default value* : 31/12/2012; *Unit* : [day]         
% 
% 
%% Temperature file
% *Default value* : none   ; *Unit* : [C]    
%
% It is possible to work with personal temperature file. Link the file by
% clicking the "Add" button and provide the link to the temperature file.
% The file must be an 1-by-X dataset or X-by-1. X is the number of slot and
% so far, only hourly step file is accepted. Click "Remove" to unlink the
% file.
%
%% Radiation file
% *Default value* : none; *Unit* : [W/m2] 
% 
% It is possible to work with personal radiation file. Link the file by
% clicking the "Add" button and provide the link to the radiation file.
% The file must be an 1-by-X dataset or X-by-1. X is the number of slot and
% so far, only hourly step file is accepted. Click "Remove" to unlink the
% file. 
%
%% Price file
% *Default value* : none; *Unit* : Monetary units e.g.[€] [$]
%
% It is possible to work with personal price file. Link the file by
% clicking the "Add" button and provide the link to the price file.
% The file must be an 1-by-X dataset or X-by-1. X is the number of slot and
% so far, only hourly step file is accepted. Click "Remove" to unlink the
% file. 
%
%% Emission file
% *Default value* : none; *Unit* : [W/m2]  
%
% It is possible to work with personal emissio file. Link the file by
% clicking the "Add" button and provide the link to the emission file.
% The file must be an 1-by-X dataset or X-by-1. X is the number of slot and
% so far, only hourly step file is accepted. Click "Remove" to unlink the
% file. 
%
%% Forecasting method
% *Default value* : none
%
% Two sort of forecasting method can be selected in case projection for
% future climate scenario is to be done. The TRY2012 and the TRY2050 (Temperature Reference Year)
% can be selected. TO BE COMPLETED
%%
% 
% <<LogoOulu1.PNG>> 
% 
% Copyright 2016-2019 University of Oulu
% 
