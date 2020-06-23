
for var = 1:size(CO2EmissionsAllHouses,2)
    CO2ExtractOrigin(:,var) = [CO2EmissionsAllHouses{:,var}];
end

for varhouse = 1:size(Daily_Profile_CO2,1)
varCol = 1;
    for varmonth = 1:12
        for varweek=1:3
            CO2ExtractOrigindaily(varhouse).Name(:,varCol) = Daily_Profile_CO2(varhouse,:,varweek,varmonth);
            CO2ExtractOriginyearly(varhouse).Name(:,varCol) = Daily_Profile_CO2_Tot(varhouse,:,varweek,varmonth);
            varCol = varCol + 1;
        end 
    end
end
