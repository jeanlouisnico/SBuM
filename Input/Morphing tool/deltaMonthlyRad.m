function [FRad, a] = deltaMonthlyRad(FileForSolar, ReferencePointRad, MorphingPoint, AveragePeriod)
%% This function is used to calculate the relative change in solar radiation due to climate change
% Define the current average value and future change to here, currently on
% monthly basis

Values      = readtable(FileForSolar);
VariableName= 'SolarRadiation';
ChangeInRad = Values.(VariableName);

%% Loop through the months to discover the relative change in solar radiation

% a       = zeros(12,length(ChangeInRad)/12);
FRad 	= zeros(12,length(ChangeInRad)/12);

for i = 1:12
    SelectedMonth = i;  % Assign selected month
    idx = 1;            % Index value for allocating
    for j = SelectedMonth:12:length(ChangeInRad) % Loop every month for the lenght of the database
        FRad(SelectedMonth,idx) = ChangeInRad(j);   % This organises the average values to a useble and comparable form
        idx = idx + 1;
    end
end

if ReferencePointRad - AveragePeriod/2 <= 0
    ReferencePointRad = (AveragePeriod/2) + 1;
end

a = mean(FRad(:,MorphingPoint-(AveragePeriod/2):MorphingPoint+(AveragePeriod/2)),2)./mean(FRad(:,ReferencePointRad-(AveragePeriod/2):ReferencePointRad+(AveragePeriod/2)),2);

% a = ChangeInRad./ChangeInRad(ReferencePointRad);  % Compare to the first year!

end

