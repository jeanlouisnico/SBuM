for ii = 1:21
    allprofile = 1;
    for varmonth = 1:12
        for varwd = 1:3
            AppProf(:,allprofile) = Stat4Use_New(:,ii,varwd,varmonth);
            allprofile = allprofile + 1;
        end
    end
    ProfileApp(:,ii) = mean(AppProf,2) ;
end