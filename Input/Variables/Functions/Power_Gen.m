function [PTot] = Power_Gen(tech, timeref, wEn, nweeks_diff_En, Techn, vartF,hgen,Input_Data,time_step,Date_Ref,varm,vard,varh,varstep,nmonth_diff_Em,numdaystart,numdayends)
%%% Get the right date
                    DayofWeek       = day(datetime(year(Date_Ref(2)),varm,vard,varh - 1,0,0),'dayofweek')   ;
                    NormalweekDay   = [7 1 2 3 4 5 6]                                                       ;
                    DayofWeek       = NormalweekDay(DayofWeek)                                              ;
                    DateMonday      = datenum(year(Date_Ref(2)),varm,vard + (1 - DayofWeek))                ;
                    DateSunday      = datenum(year(Date_Ref(2)),varm,vard + (7 - DayofWeek))                ;
                    numdaystart     = (max(1,(DateMonday - datenum(2004,1,1)))) * 24 + 1;
                    numdayends      = (DateSunday - datenum(2004,1,1) + 1) * 24 ;   
if ~(tech == 6 || tech == 2 || tech == 7)
    switch tech
        case 3
            techname = 'District heating CHP';
            nbrstat = 23;
        case 4
            techname = 'Industry CHP';
            nbrstat = 25;
        case 1
            techname = 'Nuclear energy';
            nbrstat = 21;
        case 5
            techname = 'Separate electricity production';
            nbrstat = 27;
    end
    Nbr_stations = length(unique(Input_Data.text(:,nbrstat))) - 1;
    UMM2 = repmat(Input_Data.UMM(:,6),1,Nbr_stations);
    newcmp = repmat(Input_Data.text(1:Nbr_stations,nbrstat)',size(Input_Data.text,1),1);
    Cmp_str = strcmp(UMM2,newcmp);
%     if datenum(year(Date_Ref(2)),varm,vard) + (varh - 1) / 24 == datenum(2013,12,1) + 12/24
%         y = 1;
%     end
    for var_tech  = 1:Nbr_stations
        countif_func(1,var_tech) = sum(([Input_Data.UMM{:,1}] <= timeref & [Input_Data.UMM{:,2}] >= timeref & strcmp(Input_Data.UMM(:,14),techname)') .* Cmp_str(:,var_tech)');
        if isempty(find(([Input_Data.UMM{:,1}] <= timeref & [Input_Data.UMM{:,2}] >= timeref & strcmp(Input_Data.UMM(:,14),techname)') .* Cmp_str(:,var_tech)')')
            Power_func(:,var_tech) = 0;
        else
            Power_func(1:countif_func(1,var_tech),var_tech) = find(([Input_Data.UMM{:,1}] <= timeref & [Input_Data.UMM{:,2}] >= timeref & strcmp(Input_Data.UMM(:,14),techname)') .* Cmp_str(:,var_tech)')';
        end
        Power(1,var_tech) = sum(Input_Data.ndata(Power_func(1:countif_func(1,var_tech),var_tech),7))/countif_func(1,var_tech);
    end
    Power(isnan(Power)) = 0;
    Pfault = sum(Power);
    clear countif_func Power_func Power
else
    Pfault = 0;
end
if time_step == 1
    if numdaystart == 25
        EnGene = Input_Data.Hourly_Fingrid(vartF,3) / (7/4 * sum(Input_Data.Hourly_Fingrid(1:numdayends,3))) * (sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))) * 1000);
    else
        EnGene = Input_Data.Hourly_Fingrid(vartF,3) / sum(Input_Data.Hourly_Fingrid(numdaystart:numdayends,3)) * (sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))) * 1000);
    end
    switch tech
        case 6 % hydro
            PTot = 0;
        case 2 % Wind
            WP          = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),2);
            WPinstalled = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),6);
            WPmean      = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),3);
            WPmin       = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),4);
            WPmax       = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),5);
            PTot        = WindTurbine_Gen(timeref, Input_Data.Hourly_Wind_Speed, Rand_Mean(floor(WP/(WPinstalled/(Input_Data.Weeks_Stat(nweeks_diff_En,2)/168*1000))),WPmean,WPmin,WPmax)'/1000);
        case 3 % DH
            PTot = EnGene * ((4392.26 - Pfault) / 4392.26) * (wEn / sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))));
        case 4 % CHP Ind
            PTot = EnGene * ((2886.50 - Pfault) / 2886.50) * (wEn / sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))));
        case 1 % Nuclear
            PTot = 2770 * (1 + RandBetween(-280,280,1,1) / 1000000) - Pfault;
        case 5 % Separate
            PTot = EnGene * ((3461.30 - Pfault) / 3461.30) * (wEn / sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))));
        case 7 % Gas turbine
            PTot = 0;
    end
    % hgen(varstep,Techn(vart)) = wEn / sum(Weeks_Stat(nweeks_diff_En,1:length(Techn))) * Hourly_Fingrid(vartF,3);
elseif time_step == 2
    Day_Ref = find(Input_Data.Daily_Energy(:,1)==floor((datenum(year(Date_Ref(2)),varm,vard) + (varh - 1) / 24)*10000/10000));
    Perc_DH = Input_Data.Weeks_Stat(nweeks_diff_En,3) / sum(Input_Data.Weeks_Stat(nweeks_diff_En,3:4));
    switch tech
        case 1 % Nuclear
            PTot = 2770 * (1 + RandBetween(-280,280,1,1) / 1000000) - Pfault;
        case 2 % Wind
            %PTot = Input_Data.Daily_Energy(Day_Ref,4) / sum(Input_Data.Daily_Energy(Day_Ref,2:6)) * Input_Data.Hourly_Fingrid(vartF,3);
            WP = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),2);
            WPinstalled = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),6);
            WPmean = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),3);
            WPmin = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),4);
            WPmax = Input_Data.Wind_Park(find(year(Date_Ref(2))==Input_Data.Wind_Park(:,1)),5);
            nBRwt_Allowed = min(floor((Input_Data.Daily_Energy(Day_Ref,3)) / (WPmean / 1000)),WPinstalled) ;
            PTot = WindTurbine_Gen(timeref, Input_Data.Hourly_Wind_Speed, Rand_Mean(nBRwt_Allowed,WPmean,WPmin,WPmax)'/1000);
        case 3 % DH
            PTot = Input_Data.Daily_Energy(Day_Ref,4) / sum(Input_Data.Daily_Energy(Day_Ref,2:6)) * Input_Data.Hourly_Fingrid(vartF,3) * Perc_DH;
        case 4 % CHP Ind
            PTot = Input_Data.Daily_Energy(Day_Ref,4) / sum(Input_Data.Daily_Energy(Day_Ref,2:6)) * Input_Data.Hourly_Fingrid(vartF,3) * (1-Perc_DH);
        case 5 % Other
            PTot = Input_Data.Daily_Energy(Day_Ref,6) / sum(Input_Data.Daily_Energy(Day_Ref,2:6)) * Input_Data.Hourly_Fingrid(vartF,3);
        case 6 % Hydro
            PTot = Input_Data.Hourly_Fingrid(vartF,3) - sum(hgen(varstep,:));
        case 7 % Gas turbine
            PTot = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgen(varstep,5); 
    end
end