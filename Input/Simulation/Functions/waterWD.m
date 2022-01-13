function [water_profile, prob] = waterWD(prob, istep, Time_Sim, water_profile, occupancy)

randtest    = prob.Rand_Time(istep) ;
loads       = fieldnames(prob.proba) ;



for iload = 1:length(loads)
    loadname = loads{iload} ;

    if strcmp(loadname,'SL')
        prob.proba.(loadname)(istep) ;
    end
    
    if occupancy > 0 
        occupancy = 1 ;
    end
    
    prob_data       = prob.proba.(loadname)(istep) * occupancy ;
    countname       = ['count' loadname] ;
    countnameday    = ['countday' loadname] ;
    countnamedaystor= ['countdaystorage' loadname] ;
    countndstor_Mean= ['countndstor_Mean' loadname] ;
    countload       = loadname ;
    countprofile    = [loadname 'profile'] ;
    profilencr      = [loadname 'xincrease'] ;
    countwithdrawal = [loadname 'withdrawal'] ;
    countlength     = [loadname 'length'] ;
    flow            = [loadname 'flow'] ;
    
    loadcorrect     = [loadname 'correct'] ;
    if istep == 1 || mod(istep,prob.sim1day) == 0
        % Reset the counter to zero at the beginning of each day
        if ~(istep == 1)
            water_profile.(countnamedaystor)(istep/prob.sim1day) = water_profile.(countnameday) ;
            water_profile.(countndstor_Mean)                     = mean(water_profile.(countnamedaystor)) ;
            if water_profile.(countndstor_Mean) == 0
                water_profile.(loadcorrect)                      = prob.incday.(loadname) ;
            else
                water_profile.(loadcorrect)                      = prob.incday.(loadname) / water_profile.(countndstor_Mean) ;
            end
        else
            water_profile.(loadcorrect) = 1 ;
        end
        water_profile.(countnameday) = 0 ;
        
    end

    switch loadname
        case 'shower'
            Multi = (rand < (water_profile.(loadcorrect) * min(1,prob.A4 / 30)) ) ;
            if Multi
                Multi = max(1,water_profile.(loadcorrect)) ;
            else
                Multi = 0 ;
            end
        case 'bath'
            Multi = 1 ;
            Multi = (rand < 1/ (7*4)) ;
            if Multi
                Multi = 1 * max(1,water_profile.(loadcorrect)) ;
            else
                Multi = 0 ;
            end
        case 'SL'
            var = 8.7 ;
            if var > prob.A4
                var = prob.A4 ;
            end
            Multi = max(1,prob.incday.(loadname) * var / 28 * min(prob.incday.(loadname) * 2,water_profile.(loadcorrect)))  ;
        case 'ML'
            var = 3.7 ;
            if var > prob.A4
                var = prob.A4 ;
            end
            Multi = max(1,prob.incday.(loadname) * var / 12 * min(prob.incday.(loadname) * 2,water_profile.(loadcorrect))) ; %3.5 ; %
    end
    
    if randtest <= prob_data && prob.timeleft.(countload) == 0 && Multi > 0
        % Then there is water draw-off and we start counting the number of
        % draws-off
        water_profile.(countnameday) = water_profile.(countnameday) + 1 * Multi ;
        water_profile.(countname)(istep) = 1 ;
        water_profile.(countload)(istep) = 1 * Multi;
        water_profile.(countlength)(istep) = 1 * Multi * prob.duration.(countload);
        prob.inuse.(countload) = 1 ;
        prob.timeleft.(countload) = prob.duration.(countload) / prob.A4 ;
    elseif prob.inuse.(countload)
        prob.timeleft.(countload) = max(0,prob.timeleft.(countload) - 1) ;
        if prob.timeleft.(countload) == 0
            prob.inuse.(countload) = 0 ;
            water_profile.(countload)(istep) = 0 ;  
            water_profile.(countlength)(istep) = 0 ;
        else
            water_profile.(countload)(istep)   = 1 ;
            water_profile.(countlength)(istep) = 1 * Multi * prob.duration.(countload);
        end
    else
        % no water draw
        water_profile.(countload)(istep) = 0 ;
        prob.inuse.(countload) = 0 ;
        water_profile.(countlength)(istep) = 0; 
    end
    if water_profile.(countlength)(istep) > 0
        try
            prob.(flow)(end + 1,1) = prob.(countwithdrawal)(istep) ;
        catch
            prob.(flow)(1,1) = prob.(countwithdrawal)(istep) ;
        end
    else
        try
            prob.(flow)(end + 1,1) = 0 ;
        catch
            prob.(flow)(1,1) = 0 ;
        end
    end
        
    water_profile.(countprofile)(istep) = water_profile.(countlength)(istep) * prob.(countwithdrawal)(istep) ;
end

water_profile.WaterWD = water_profile.bathprofile(istep) + water_profile.showerprofile(istep)  + water_profile.MLprofile(istep)  + water_profile.SLprofile(istep)  ;
