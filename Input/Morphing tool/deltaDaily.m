function [tasPlace, mean_tasPlace, tasminPlace, mean_tasminPlace, tasmaxPlace, mean_tasmaxPlace] = deltaDaily(FileName_tas, FileName_tasmin, FileName_tasmax, Place, Spacial_Error)
% This function is used to read daily data from nc-file

%% Set up the simulation

FileName = {FileName_tas, FileName_tasmin, FileName_tasmax};    % Save all the filenames under one variable

for i = 1:3         % Loop through all the daily options

% Load the location information

lon = ncread(FileName{i}, 'lon');          % Load longitude information
lat = ncread(FileName{i}, 'lat');          % Load latitude information

Points = ncread(FileName{i}, 'point');     % Load the point values

% Select suitable points

AccLon = lon > Place(2) - Spacial_Error & lon < Place(2) + Spacial_Error; % Gives logical value of accepltable longitudes 

AccLat = lat > Place(1) - Spacial_Error & lat < Place(1) + Spacial_Error; % Gives logical value of acceptable latitude

AccPoint = Points(AccLon & AccLat);     % Select the acceptable points for the simulation

%% Daily mean outdoor temperature

if i == 1   % First loop for mean temperature

    tas = ncread(FileName{i}, 'tas');          % Load the outdoor temperatures

    tasPlace = tas(AccPoint,:);             % Select the temperatures from the acceptable points a.k.a. the selected location

    mean_tasPlace = mean(tasPlace);         % Calculate the average spacial average value


%% Daily minimum outdoor temperature

elseif i == 2 % Second loop for minimum temperature

    tasmin = ncread(FileName{i}, 'tasmin');     % Load the minimum outdoor temperatures
    
    tasminPlace = tasmin(AccPoint,:);           % Select the acceptable data points
    
    mean_tasminPlace = mean(tasminPlace);       % Calculate the mean value
    

%% Daily maximum outdoot temperature

else
    
    tasmax = ncread(FileName{i}, 'tasmax');
    
    tasmaxPlace = tasmax(AccPoint,:);
    
    mean_tasmaxPlace = mean(tasmaxPlace);
    
end

end

end

