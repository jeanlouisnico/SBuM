function [mean_tasPlace] = ReadDailyMeanNc(FileName, Place, Spacial_Error)
%% This is a function to read nc-files for daily std option
% Suitable for FMI Paituli data

lon = ncread(FileName, 'lon');          % Load longitude information
lat = ncread(FileName, 'lat');          % Load latitude information

Points = ncread(FileName, 'point');     % Load the point values

% Select suitable points

AccLon = lon > Place(2) - Spacial_Error & lon < Place(2) + Spacial_Error; % Gives logical value of accepltable longitudes 

AccLat = lat > Place(1) - Spacial_Error & lat < Place(1) + Spacial_Error; % Gives logical value of acceptable latitude

AccPoint = Points(AccLon & AccLat);     % Select the acceptable points for the simulation

tas = ncread(FileName, 'tas');          % Load the outdoor temperatures

tasPlace = tas(AccPoint,:);             % Select the temperatures from the acceptable points a.k.a. the selected location

mean_tasPlace = mean(tasPlace);         % Calculate the average spacial average value

end

