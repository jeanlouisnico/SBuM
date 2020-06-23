function [delta] = ReadMonthlyChange(FileName_monthly, CurrentMean, DatabaseType, ReferencePointMonthly, MorphingPointMonthly, AveragePeriod)
%% Function for calculating the delta values for monthly changes from other than .nc-files

switch DatabaseType
    
    case 'LongTermMean'     % Currently only works for ECEM data. (The averages are 1981-2010 and 2035-2064)
        
        NewAverage = readtable(FileName_monthly);
        FutureAverage = NewAverage.Temperature(13:24);
        
        delta = FutureAverage - CurrentMean;
        
    otherwise
        
        Monthly     = readtable(FileName_monthly);
        tasPlace    = Monthly.Temperature;
        
        tas_org = zeros(1,length(tasPlace)/12);
        
    for j = 1:12    % Months
        SelectedMonth = j;  % Assign selected month
        idx = 1;            % Index value for allocating
        for i = SelectedMonth:12:length(tasPlace) % Loop every month for the lenght of the database
            tas_org(SelectedMonth,idx) = tasPlace(i); %CurrentMean(SelectedMonth);  % Compare to the original values!
            idx = idx + 1;
        end
    end
    
    if strcmp(DatabaseType,'Paituli')
    
        delta = tas_org(:,MorphingPointMonthly) - tas_org(:,ReferencePointMonthly);
        
    else
        
        if ReferencePointMonthly - (AveragePeriod/2) <=0
            ReferencePointMonthly = (AveragePeriod/2) + 1;
        end
    
        delta = mean(tas_org(:,MorphingPointMonthly-(AveragePeriod/2):MorphingPointMonthly+(AveragePeriod/2)),2) - mean(tas_org(:,ReferencePointMonthly-(AveragePeriod/2):ReferencePointMonthly+(AveragePeriod/2)),2);
        
    end
    
end
        

end

