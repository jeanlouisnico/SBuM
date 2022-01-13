function water_profile = Waterstats(prob, water_profile)

loads       = fieldnames(prob.proba) ;
for iload = 1:length(loads)
    loadname            = loads{iload} ;
    countwaterprofile   = [loadname 'profile'] ;
    counttotal          = [loadname 'total'] ;
    countprofile        = [loadname 'profile'] ;
    normalisedload      = [loadname '_norm'] ;
    countwithdrawal     = [loadname 'withdrawal'] ;
    countndstor_Mean    = ['countndstor_Mean' loadname] ;
    loadcorrect         = [loadname 'correct'] ;
    flow                = [loadname 'flow'] ;
    
    water_profile.(counttotal)                  = sum(water_profile.(countwaterprofile)) ;
    
    Meanday_simulated(iload,1)      = water_profile.(countndstor_Mean) ;
    Meanday_input(iload,1)          = prob.incday.(loadname) ;
    Meanflow_simulated(iload,1)     = mean(prob.(flow)) ;
    Meanflow_input(iload,1)         = mean(prob.MeanVolume.(loadname)) ;
    duration_input(iload,1)         = mean(prob.duration.(loadname)) ;
    Correction(iload,1)             = water_profile.(loadcorrect) ;
    Total_simulated(iload,1)        = water_profile.(counttotal)  ;
    Total_input(iload,1)            = prob.ysum.(loadname)  ;
    
    
    if prob.plotvar       
        A_wd = zeros(1,length(water_profile.(countwaterprofile))) ;
        A_wd(water_profile.(countprofile)>0) = 1 ;
        water_profile.(countwithdrawal).statwithdrawl = A_wd .* prob.(countwithdrawal) ;
        
        for istep = 1 : prob.sim1day
            B               = water_profile.(countprofile)(1, istep:prob.sim1day:end);
            B_water_profile.(countprofile)(istep) = sum(B) ;
            if B_water_profile.(countprofile)(istep) > 0
                xstop = 1;
            end
        end
        water_profile.(normalisedload) = normalize(B_water_profile.(countprofile),'norm',1);
        water_profile.randomgen.(loadname) = normalize(prob.proba.(loadname)(1:prob.sim1day),'norm',1) ;
        figure 
        plot(water_profile.randomgen.(loadname));
        hold on;
        plot(water_profile.(normalisedload));
        title([loadname ' - ' num2str(prob.A4) ' min']) ;
        hold off;

        figure(prob.distifig);
        hold on;
        probapp = nonzeros(water_profile.(countwithdrawal).statwithdrawl) ;
        histfit(probapp);
        hold off;
    end
end
water_profile.Table_summary = table(Meanday_simulated,Meanday_input,Meanflow_simulated, Meanflow_input, duration_input, Correction,Total_simulated, Total_input);
water_profile.Table_summary.Properties.RowNames = loads;

[~, neworder]   = sort(lower(fieldnames(water_profile)));
water_profile   = orderfields(water_profile, neworder) ;

water_profile.totalwaterwithdraw = water_profile.bathtotal + water_profile.showertotal + water_profile.MLtotal + water_profile.SLtotal ;