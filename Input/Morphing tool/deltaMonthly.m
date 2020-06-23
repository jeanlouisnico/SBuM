%%% This is a script to convert Monthly average values to monthly delta
%%% values on annual basis with nc-files.

% The script loops every month and year separately, and creates 12 x years
% matrix out of it.

function[tasOrg, mean_tasPlace] = deltaMonthly(FileName, Place, Spacial_Error)

%% Set up the simulation

% Place = [62+(14.5/60), 25+(44.5/60)];   % Add the coordinates of the place

% Spacial_Error = 0.1;                   % Describe the error in degrees

lon = ncread(FileName, 'lon');          % Load longitude information
lat = ncread(FileName, 'lat');          % Load latitude information

Points = ncread(FileName, 'point');     % Load the point values

AccLon = lon > Place(2) - Spacial_Error & lon < Place(2) + Spacial_Error; % Gives logical value of accepltable longitudes 

AccLat = lat > Place(1) - Spacial_Error & lat < Place(1) + Spacial_Error; % Gives logical value of acceptable latitude

AccPoint = Points(AccLon & AccLat);     % Select the acceptable points for the simulation

tas = ncread(FileName, 'tas');          % Load the outdoor temperatures

tasPlace = tas(AccPoint,:);             % Select the temperatures from the acceptable points a.k.a. the selected location

mean_tasPlace = mean(tasPlace);         % Calculate the average spacial average value

delta   = zeros(12,length(tasPlace)/12);      % Preallocate delta
tasOrg  = zeros(12,length(tasPlace)/12);     % Preallocate tasOrg

%% Loop through the months and years

for j = 1:12    % Months
    SelectedMonth = j;  % Assign selected month
    idx = 1;            % Index value for allocating
    for i = SelectedMonth:12:length(tasPlace) % Loop every month for the lenght of the database
%         delta(SelectedMonth,idx) = mean_tasPlace(i) - mean_tasPlace(SelectedMonth);  % Compare to the first year!
        tasOrg(SelectedMonth,idx) = mean_tasPlace(i);   % This organises the average values to a useble and comparable form
        idx = idx + 1;
    end
end

end