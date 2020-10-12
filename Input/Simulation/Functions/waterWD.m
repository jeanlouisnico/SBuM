function [water_profile, prob] = waterWD(prob, istep, Time_Sim)

randtest    = prob.Rand_Time(istep) ;
loads       = fieldnames(prob.proba) ;



for iload = 1:length(loads)
    loadname = loads{iload} ;

    if strcmp(loadname,'SL')
        prob.proba.(loadname)(istep) ;
    end

    prob_data       = prob.proba.(loadname)(istep) ;
    countname       = ['count' loadname] ;
    countnameday    = ['countday' loadname] ;
    countload       = loadname ;
    countprofile    = [loadname 'profile'] ;
    profilencr      = [loadname 'xincrease'] ;
    countwithdrawal = [loadname 'withdrawal'] ;
    
    if istep == 1 || mod(istep,24) == 0
        % Reset the counter to zero at the beginning of each day
        water_profile.(countnameday) = 0 ;
    end
    
    if randtest <= prob_data && prob.timeleft.(countload) == 0
        % Then there is water draw-off and we start counting the number of
        % draws-off
        water_profile.(countnameday) = water_profile.(countnameday) + 1 ;
        water_profile.(countname)(istep) = 1 ;
        water_profile.(countload)(istep) = 1 ;
        prob.inuse.(countload) = 1 ;
        prob.timeleft.(countload) = duration.(countload) ;
    elseif prob.inuse.(countload)
        prob.timeleft.(countload) = max(0,prob.timeleft.(countload) - 1) ;
        if prob.timeleft.(countload) == 0
            prob.inuse.(countload) = 0 ;
        else
            water_profile.(countload)(istep) = 1 ;
        end
    else
        % no water draw
        prob.inuse.(countload) = 0 ;
    end

    if adjust
        if mod(istep,prob.sim1day) == 0
            % at the end of each day, we reshuffle the array and assign a a
            % time duration and a random mean flow rate of water and
            % recalculate the total water usage.

            %%% for the shower
            instance = sum(water_profile.(countname)((istep - prob.sim1day + 1):istep)) ;
            match_one = find(water_profile.(countname)((istep - prob.sim1day + 1):istep) == 1) ;
            % Reduce the number of points if there are too many
            if instance > incday.(countload)
                if instance == 0
                    A_instance = 0;
                else
                    A_instance = genrand(instance, incday.(countload)) ;
                end

                if A_instance == 0
                    selected_point = [] ;
                else
                    selected_point = nonzeros(match_one .* A_instance) ;
                    arraymult = ones(length(selected_point),1) ;
                end
            else % Increase the number of points in case there are not enough
                try
                    water_profile.(profilencr) = water_profile.(profilencr) + 1 ;
                catch
                    water_profile.(profilencr) = 1 ;
                end

                if instance == 0
                    A_instance = 0              ;
                    selected_point = [] ;
                else
                    maxpoint        = A4 / duration.(loadname) ;
                    arraymult       = min(round(normalize(RandBetween(0,1,instance,1),'norm',1)*incday.(loadname)),maxpoint) ;
                    selected_point  = match_one ;
                end
            end
            if ~isempty(selected_point)
%                 selectedx = genrandgauss(length(selected_point), mu.(countload), amp.(countload)) ;
                for i = 1:length(selected_point)
                    water_profile.(countprofile)(istep - prob.sim1day + 1 + selected_point(i):(istep - prob.sim1day + 1 + selected_point(i) + duration.(loadname) - 1)) = arraymult(i) ;
                end
            end
        end
    else
        water_profile.(countprofile)(istep) = water_profile.(countname)(istep) ;
%             if mod(istep,prob.sim1day) == 0
%                 match_one = find(water_profile.(countname)((istep - prob.sim1day + 1):istep) == 1) ;
%                 selected_point = nonzeros(match_one .* A3) ;
%                 arraymult = ones(length(selected_point),1) ;
%                 
%                 for i = 1:length(selected_point)
%                     water_profile.(countprofile)(istep - prob.sim1day + 1 + selected_point(i):(istep - prob.sim1day + 1 + selected_point(i) + duration.(loadname) - 1)) = arraymult(i) ;
%                 end
%             end
    end
end