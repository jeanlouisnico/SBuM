
StepDraw = 1/360 ;

parfor b = 0:(24/StepDraw)
    bLook = b * StepDraw ;
    selectedTimes = hourOfDay >= bLook & hourOfDay < (bLook + StepDraw); 
    StatHour = Profile.(HouseTag)(selectedTimes,:) ;
    ProfileHourTemp = retime(StatHour,'yearly','mean');
    try
            ProfileHour(b).(HouseTag) = ProfileHourTemp(1,:) ;
    catch
         % Profile does not exist so we create it
        if ~isempty(ProfileHourTemp)
            ProfileHour(b).(HouseTag) = ProfileHourTemp(1,:);
        end
    end
end