function water_profile = DHW_distribution

% profile on

A1 = 'single' ;
A2 = 1 ; %nbr of households
A3 = 4 ; % Nbr of categories
A4 = 60 ; % Time duration [min]
A5 = 1 ; % Start day of profile
A6 = 365 ; % Total duration (profile) [days]
A7 = 200 ; % Total mean daily draw-off volume [l/day]
A8 = true ; % Daylight saving time (1.04 - 31 Oct.
A9 = 'DHW0001' ; % File name of profile
A15 = 'DHW_input' ; % Save profile name
A16 = '' ; % Load profile name needs a path
adjust = true ;

plotvar = false ;

peakm       = 5  ; %month or days
spantime    = 12 ; %month or days

B2 = 120 ; % percentage
B3 = 10 ; % why not

p_WD = (A7 * 7 / (5 + 2 * B2/100)) / A7 ;
p_WE = p_WD * B2/100 ;

% Seasonal probability function
t = 1:spantime;

yseason = (100 + B3.*sin(1/spantime * 2 * pi * t - (peakm - 3)/spantime * 2 * pi))/100; % [%]

if plotvar
    plot(t,yseason);
end

%%%%% Medium Load
duration.ML     = 1    ; % [min]
MeanVolume.ML   = 6    ; % [l/min]
incday.ML       = 12   ;

ysum            = MeanVolume.ML * duration.ML * incday.ML  * 365;

sigma   = sqrt(2) ;
mu.ML   = MeanVolume.ML ;

f = @(xamp) myfunDHW(xamp, mu.ML, sigma)-ysum ;
amp.ML = fsolve(f,200) ;

x.ML = max(0.2,mu.ML - 2*sigma):.2:(mu.ML + 2*sigma) ;
y.ML = amp.ML / (1/(sqrt(2*pi)*sigma))*normpdf(x.ML,mu.ML,sigma);

zMLproduct = sum(x.ML .* y.ML) ;
if plotvar
    distifig = figure ;
    figure(distifig);
    plot(x.ML,y.ML)
    grid on
    grid minor 
    hold on
end
%%%%% Short Load
duration.SL     = 1    ; % [min]
MeanVolume.SL   = 1    ; % [l/min]
incday.SL       = 28   ;

ysum            = MeanVolume.SL * duration.SL * incday.SL  * 365;

sigma   = sqrt(2) ;
mu.SL   = MeanVolume.SL ;

f = @(xamp) myfunDHW(xamp, mu.SL, sigma)-ysum ;
amp.SL = fsolve(f,200)  ;

x.SL = max(0,mu.SL - 2*sigma):.2:(mu.SL + 2*sigma) ;
y.SL = amp.SL / (1/(sqrt(2*pi)*sigma))*normpdf(x.SL,mu.SL,sigma);

pd      = makedist('Normal','mu',mu.SL,'sigma',sigma) ;
t_pd    = truncate(pd,max(0,mu.SL - 2*sigma),(mu.SL + 2*sigma)) ;
y.SLv2  = amp.SL / (1/(sqrt(2*pi)*sigma)) * pdf(t_pd,x.SL) ;

zSLproduct = sum(x.SL .* y.SL) ;

if plotvar
    plot(x.SL,y.SL)
end

%%%% Shower 
duration.shower     = 5    ; % [min]
MeanVolume.shower   = 8    ; % [l/min]
incday.shower       = 2    ;

ysum                = MeanVolume.shower * duration.shower * incday.shower  * 365;
sigma               = sqrt(2) ;
mu.shower           = MeanVolume.shower ;

f = @(xamp) myfunDHW(xamp, mu.shower, sigma)-ysum ;
amp.shower = fsolve(f,200) ;

x.shower = max(0.2,mu.shower - 2*sigma):.2:(mu.shower + 2*sigma) ;

y.shower = amp.shower / (1/(sqrt(2*pi)*sigma))*normpdf(x.shower,mu.shower,sigma);

zshowerproduct = sum(x.shower .* y.shower) ;

if plotvar
    plot(x.shower,y.shower)
end
%%%%% Bath
duration.bath     = 10    ; % [min]
MeanVolume.bath   = 14         ; % [l/min]
incday.bath       = 1 / 7      ;

ysum = MeanVolume.bath * duration.bath * incday.bath  * 365;
% amp     = 30 ;
sigma       = sqrt(2) ;
mu.bath     = MeanVolume.bath  ;

f = @(xamp) myfunDHW(xamp, mu.bath, sigma)-ysum ;
amp.bath = fsolve(f,200)  ;

x.bath = max(0.2,mu.bath - 2*sigma):.2:(mu.bath + 2*sigma) ;
y.bath = amp.bath / (1/(sqrt(2*pi)*sigma))*normpdf(x.bath,mu.bath,sigma);

zbathproduct = sum(x.bath .* y.bath)  ;

if plotvar
    plot(x.bath,y.bath)
    hold off
end

%
water_profile.YEarly_WL = zSLproduct + zMLproduct + zshowerproduct + zbathproduct ;

%%% P_day

Default.shower = [0
0
0
0
0.024383575
0.146376019
0.243960032
0.146376019
0.024383575
0.024383575
0.024383575
0.024383575
0.024383575
0.024383575
0.024383575
0.024383575
0.024383575
0.024383575
0.073150726
0.073150726
0.024383575
0.024383575
0
0
] ;

Default.SL = [0.004
0.004
0.004
0.004
0.004
0.054
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.004
] ;

Default.ML = [0.004
0.004
0.004
0.004
0.004
0.054
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.055
0.004
] ;

Default.bath = [0
0
0
0
0
0
0
0
0.018
0.027
0.038
0.044
0.0508
0.055
0.058
0.059
0.058
0.055
0.143
0.22
0.143
0.028
0.014
0
] ;

Holiday_start.Period1 = datetime(2013,7,14) ;
Holiday_end.Period1 = datetime(2013,7,28)   ;

Holiday_start.Period2 = datetime(2013,8,8) ;
Holiday_end.Period2 = datetime(2013,8,22)   ;

% Loop through each step and define the amount of withdrawl

simulation_size = A6 * 24 * 60 / A4 ; % define the number of steps to loop through and the length of the array
prob.sim1day = 24 * 60 / A4 ;

stpIn = A4 / 60 ;
datevector = (datetime(datenum(2013,1,1),'ConvertFrom','datenum'):seconds(3600*stpIn):datetime(datenum(2013,1,A6+1),'ConvertFrom','datenum'))';
datevector = datevector(1:simulation_size) ;
% Replicate or not
rng(1)  
prob.Rand_Time                   = RandBetween(0,1-A4*1.25/100,simulation_size,1) ;

loads = fieldnames(Default) ;

for i  = 1:length(loads)
    countname       = ['count' loads{i}] ;
    countload       = loads{i} ;
    countprofile    = [loads{i} 'profile'] ;
    
    water_profile.(countname)       = zeros(simulation_size,1) ;
    water_profile.(countload)       = zeros(simulation_size,1) ;
    water_profile.(countprofile)    = zeros(simulation_size,1) ;
    
    prob_array.(countload)       = zeros(simulation_size,1) ;
    
    prob.inuse.(countload)    = 0 ;
    prob.timeleft.(countload) = 0 ;
end

% Test Vectorized solutions
holidays        = zeros(simulation_size,2) ;
prob_holiday    = zeros(simulation_size,1) ;
% prob_array      = zeros(simulation_size,1) ;
prob_year       = yseason(datevector.Month) ;

weekday_vector  = weekday(datevector-1) ;
    prob_weekday(weekday_vector<=5) = p_WD ;
    prob_weekday(weekday_vector>5)  = p_WE;
    
nbrholidays = fieldnames(Holiday_start) ;
    for iholidays = 1:length(nbrholidays)
        holidays(:,iholidays) = (datevector >= Holiday_start.(['Period' num2str(iholidays)]) & datevector <= Holiday_end.(['Period' num2str(iholidays)])) ;
    end
    holidays = sum(holidays,2);
    
    prob_holiday(holidays == 0) = 1                 ; 
    prob_holiday(holidays == 1) = (A7 - 100) / A7   ;

% prob_day(weekday_vector<=5) = 1 ;
% prob_day(weekday_vector>5) = 2;

for ihour = 1 : 24
    prob_array.shower(datevector.Hour == ihour,1) = Default.shower(ihour) ;
%     prob_array.shower(datevector.Hour == ihour & weekday_vector >  5,1) = Default.shower(ihour) ;
    
    prob_array.SL(datevector.Hour == ihour,1)  = Default.SL(ihour) ;
    prob_array.ML(datevector.Hour == ihour,1)  = Default.ML(ihour) ;
    prob_array.bath(datevector.Hour == ihour,1)   = Default.bath(ihour) ;
end
    
prob.proba.shower  = prob_year' .* prob_weekday' .* prob_holiday .* prob_array.shower ;
prob.proba.SL      = prob_year' .* prob_weekday' .* prob_holiday .* prob_array.SL ;
prob.proba.ML      = prob_year' .* prob_weekday' .* prob_holiday .* prob_array.ML ;
prob.proba.bath    = prob_year' .* prob_weekday' .* prob_holiday .* prob_array.bath ;

loads = fieldnames(prob.proba) ;

for istep = 1:simulation_size
    randtest = prob.Rand_Time(istep) ;
        
    for iload = 1:length(loads)
        loadname = loads{iload} ;
        
        if strcmp(loadname,'SL')
            prob.proba.(loadname)(istep) ;
        end
        
        prob_data = prob.proba.(loadname)(istep) ;
        countname       = ['count' loadname] ;
        countload       = loadname ;
        countprofile    = [loadname 'profile'] ;
        profilencr      = [loadname 'xincrease'] ;
        
        if randtest <= prob_data && prob.timeleft.(countload) == 0
            % Then there is water draw-off
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
end

for iload = 1:length(loads)
    loadname            = loads{iload} ;
    countprofile        = [loadname 'profile'] ;
    countwaterprofile   = [loadname 'water_profile'] ;
    countwithdrawal     = [loadname 'withdrawal'] ;
    counttotal          = [loadname 'total'] ;
    normalisedload      = [loadname '_norm'] ;
    
    distx       = repelem(x.(loadname),floor(y.(loadname)));
    distxrand   = distx(randperm(length(distx)));
    if length(distxrand) > length(water_profile.(countprofile))
        xstop = 1 ; % Shrink the array to the same size
    else
        temparr                                 = repmat(distxrand,ceil(length(water_profile.(countprofile)) / length(distxrand)),1) ;
        water_profile.(countwithdrawal).temparr = temparr(1:length(water_profile.(countprofile))) ;
        % ratio is used to have the right mean otherwise the SL components
        % is incorrect as the gaussian distribution is truncated.
        ratiomean                               = mean(water_profile.(countwithdrawal).temparr) / MeanVolume.(loadname) ;
    end
    water_profile.(countwaterprofile)           = water_profile.(countprofile) .* water_profile.(countwithdrawal).temparr' / ratiomean ;
    water_profile.(counttotal)                  = sum(water_profile.(countwaterprofile)) ;
    A_wd = zeros(1,length(water_profile.(countwaterprofile))) ;
    A_wd(water_profile.(countprofile)>0) = 1 ;
    water_profile.(countwithdrawal).statwithdrawl = A_wd .* water_profile.(countwithdrawal).temparr ;
    % some statistics
    for istep = 1 : prob.sim1day
        B               = water_profile.(countprofile)(istep:prob.sim1day:end,:);
        B_water_profile.(countprofile)(istep) = sum(B) ;
        if B_water_profile.(countprofile)(istep) > 0
            xstop = 1;
        end
    end
    water_profile.(normalisedload) = normalize(B_water_profile.(countprofile),'norm',1);
    water_profile.randomgen.(loadname) = normalize(water_profile.(loadname)(1:prob.sim1day),'norm',1) ;
    if plotvar
        figure 
        plot(water_profile.randomgen.(loadname));
        hold on;
        plot(water_profile.(normalisedload));
        title([loadname ' - ' num2str(A4) ' min']) ;
        hold off;

        figure(distifig);
        hold on;
        probapp = nonzeros(water_profile.(countwithdrawal).statwithdrawl) ;
        histfit(probapp);
        hold off;
    end
end
water_profile.totalwaterwithdraw = water_profile.bathtotal + water_profile.showertotal + water_profile.MLtotal + water_profile.SLtotal ;




% profile viewer

% profile off