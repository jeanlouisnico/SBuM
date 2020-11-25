function prob = DHW_distribution_LaunchSim(varargin)

% A2:               nbr of households
% A3:               Nbr of categories
% A4:               Time duration [min]
% A5:               Start day of profile
% A6:               Total duration (profile) [days]
% A7:               Total mean daily draw-off volume [l/day]
% A8:               Daylight saving time (1.04 - 31 Oct.
% A9:               File name of profile
% A15:              Save profile name
% A16:              Load profile name needs a path
% plotvar:          Load profile name needs a path
% peakm:            Load profile name needs a path
% spantime:         Load profile name needs a path
% B2:               percentage
% B3:               degree of freedom of the seasonal varation (default = 10)
% duration_ML:      duration Medium load [min]
% MeanVolume_ML:    Mean Volume Medium load [l/min]
% incday_ML:        Incidence per day [inc/day]
% duration_SL:      duration Small load [min]
% MeanVolume_SL:    Mean Volume Small load [l/min]
% incday_SL:        Incidence per day [inc/day]
% duration_shower:  duration shower [min]
% MeanVolume_shower:Mean Volume shower [l/min]
% day_shower:       Incidence per day [inc/day]
% duration_bath:    duration bath [min]
% MeanVolume_bath:  Mean Volume bath [l/min]
% incday_bath:      Incidence per day [inc/day]
% distri_shower:    Distribution of the shower usage. As it is normalize,
%                   the input units can be either litres or dimensionless

    
   defaultA1    = 'single' ;
        expectedA1 = {'single','multi'} ;
   defaultA2     = 1 ;                      % nbr of households
   defaultA3     = 4 ;                      % Nbr of categories
   defaultA4     = 60 ;                     % Time duration [min]
   defaultA5     = 1 ;                      % Start day of profile
   defaultA6     = 365 ;                    % Total duration (profile) [days]
   defaultA7     = 200 ;                    % Total mean daily draw-off volume [l/day]
   defaultA8     = false ;                   % Daylight saving time (1.04 - 31 Oct.
   defaultA9     = 'DHW0001' ;              % File name of profile
   defaultA15    = 'DHW_input' ;            % Save profile name
   defaultA16    = '' ;                     % Load profile name needs a path
   defaultplotvar = false ;
   
    defaultB2 = 120 ; % percentage
    defaultB3 = 10 ; % why not
     
    defaultpeakm       = 5  ; %month or days
    defaultspantime    = 12 ; %month or days
    
    defaultduration_ML      = 1  ; % [min]
    defaultMeanVolume_ML    = 6  ; % [l/min]
    defaultincday_ML        = 12 ;
    
    defaultduration_SL     = 1    ; % [min]
    defaultMeanVolume_SL   = 1    ; % [l/min]
    defaultincday_SL       = 28   ;
    
    defaultduration_shower     = 5    ; % [min]
    defaultMeanVolume_shower   = 8    ; % [l/min]
    defaultincday_shower       = 2    ;

    defaultduration_bath     = 10    ; % [min]
    defaultMeanVolume_bath   = 14         ; % [l/min]
    defaultincday_bath       = 1 / 7      ;
    
    defaultdistri_shower = [0 0 0 0 .6/24 3.5/24 5.8/24 3.5/24 .6/24 .6/24 .6/24 .6/24 .6/24 .6/24 .6/24 .6/24 .6/24 .6/24 1.7/24 1.7/24 .6/24 .6/24 0 0] ;
    defaultdistri_SL     = [.1/24 .1/24 .1/24 .1/24 .1/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 .1/24] ;
    defaultdistri_ML    = [.1/24 .1/24 .1/24 .1/24 .1/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 1.3/24 .1/24] ;
    defaultdistri_bath   = [0 0 0 0 0 0 0 0 0.45/24 0.65/24 0.9/24 1/24 1.2/24 1.3/24 1.4/24 1.42/24 1.4/24 1.3/24 3.4/24 5.3/24 3.4/24 0.6/24 0.3/24 0];
        
    p = inputParser;
   validScalarPosNumint = @(x) isnumeric(x) && isscalar(x) && (x > 0) && (mod(x,1)==0);
   validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0) ;
   
   validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
%    addRequired(p,'width',validScalarPosNum);
%    addOptional(p,'height',defaultHeight,validScalarPosNum);
   addParameter(p,'A1',defaultA1,@(x) any(validatestring(x,expectedA1)));
   addParameter(p,'A2',defaultA2,validScalarPosNum);
   addParameter(p,'A3',defaultA3,validScalarPosNum);
   addParameter(p,'A4',defaultA4,validScalarPosNum);
   addParameter(p,'A5',defaultA5,validScalarPosNum);
   addParameter(p,'A6',defaultA6,validScalarPosNum);
   addParameter(p,'A7',defaultA7,validScalarPosNum);
   addParameter(p,'A8',defaultA8,@islogical);
   addParameter(p,'A9',defaultA9,@isstring);
   addParameter(p,'A15',defaultA15,@isstring);
   addParameter(p,'A16',defaultA16,@isstring);
   addParameter(p,'plotvar',defaultplotvar,@islogical);
   
   addParameter(p,'peakm',defaultpeakm,validScalarPosNum);
   addParameter(p,'spantime',defaultspantime,validScalarPosNum);
   addParameter(p,'B2',defaultB2,validScalarPosNum);
   addParameter(p,'B3',defaultB3,validScalarPosNum);
   
   addParameter(p,'duration_SL',defaultduration_SL,validScalarPosNum);
   addParameter(p,'MeanVolume_SL',defaultMeanVolume_SL,validScalarPosNum);
   addParameter(p,'incday_SL',defaultincday_SL,validScalarPosNumint);
   
   addParameter(p,'duration_ML',defaultduration_ML,validScalarPosNum);
   addParameter(p,'MeanVolume_ML',defaultMeanVolume_ML,validScalarPosNum);
   addParameter(p,'incday_ML',defaultincday_ML,validScalarPosNumint);
   
   addParameter(p,'duration_shower',defaultduration_shower,validScalarPosNum);
   addParameter(p,'MeanVolume_shower',defaultMeanVolume_shower,validScalarPosNum);
   addParameter(p,'incday_shower',defaultincday_shower,validScalarPosNumint);

   addParameter(p,'duration_bath',defaultduration_bath,validScalarPosNum);
   addParameter(p,'MeanVolume_bath',defaultMeanVolume_bath,validScalarPosNum);
   addParameter(p,'incday_bath',defaultincday_bath,validScalarPosNumint);
   
   addParameter(p,'distri_shower',defaultdistri_shower,validVector);
   addParameter(p,'distri_SL',defaultdistri_SL,validVector);
   addParameter(p,'distri_ML',defaultdistri_ML,validVector);
   addParameter(p,'distri_bath',defaultdistri_bath,validVector);
   
   parse(p, varargin{:});
   
   results = p.Results ; 

p_WD = (results.A7 * 7 / (5 + 2 * results.B2/100)) / results.A7 ;
p_WE = p_WD * results.B2/100 ;

%%% P_day

% Normalize the input values for the day. so we can input either litres or
% fractions

Default.shower  = normalize(results.distri_shower,'norm',1) ;
Default.SL      = normalize(results.distri_SL,'norm',1) ;
Default.ML      = normalize(results.distri_ML,'norm',1) ;
Default.bath    = normalize(results.distri_bath,'norm',1) ;

prob.plotvar    = results.plotvar ;
prob.A4         = results.A4;
% Seasonal probability function
t = 1:results.spantime;

yseason = (100 + results.B3.*sin(1/results.spantime * 2 * pi * t ...
                                 - (results.peakm - 3)/results.spantime * 2 * pi ...
                                 + (results.A5)/(365) * 2 * pi )) / 100; % [%]

if results.plotvar
    figure ;
    plot(t,yseason);
end

%%%%% Medium Load
prob.duration.ML     = results.duration_ML    ; % [min]
prob.MeanVolume.ML   = results.MeanVolume_ML    ; % [l/min]
prob.incday.ML       = results.incday_ML   ;

prob.ysum.ML            = prob.MeanVolume.ML * prob.duration.ML * prob.incday.ML  * 365;

sigma   = sqrt(2) ;
mu.ML   = prob.MeanVolume.ML ;

f = @(xamp) myfunDHW(xamp, mu.ML, sigma)-prob.ysum.ML  ;
amp.ML = fsolve(f,200) ;

x.ML = max(0.2,mu.ML - 2*sigma):.2:(mu.ML + 2*sigma) ;
y.ML = amp.ML / (1/(sqrt(2*pi)*sigma))*normpdf(x.ML,mu.ML,sigma);

zMLproduct = sum(x.ML .* y.ML) ;

if prob.plotvar
    prob.distifig = figure ;
    figure(prob.distifig);
    plot(x.ML,y.ML)
    grid on
    grid minor 
    hold on
end

%%%%% Short Load
prob.duration.SL     = results.duration_SL    ; % [min]
MeanVolume.SL        = results.MeanVolume_SL * .4    ; % [l/min]
prob.incday.SL       = results.incday_SL   ;

prob.ysum.SL         = MeanVolume.SL * prob.duration.SL * prob.incday.SL  * 365;

sigma   = sqrt(4) ;
mu.SL   = MeanVolume.SL ;

f = @(xamp) myfunDHW(xamp, mu.SL, sigma)-prob.ysum.SL ;
amp.SL = fsolve(f,200)  ;

% This is for statistic purpose and account for the right amount meant ot
% be calculated

prob.ysum.SL         = results.MeanVolume_SL * prob.duration.SL * prob.incday.SL  * 365;
prob.MeanVolume.SL   = results.MeanVolume_SL ;

x.SL = max(0.4,mu.SL - 2*sigma):.2:(mu.SL + 2*sigma) ;
y.SL = amp.SL / (1/(sqrt(2*pi)*sigma))*normpdf(x.SL,mu.SL,sigma);

pd      = makedist('Normal','mu',mu.SL,'sigma',sigma) ;
t_pd    = truncate(pd,max(0.4,mu.SL - 2*sigma),(mu.SL + 2*sigma)) ;
y.SL    = amp.SL / (1/(sqrt(2*pi)*sigma)) * pdf(t_pd,x.SL) ;
amplitude = 728 ;
y.SL    = amplitude * exp(-(x.SL - mu.SL).^2 / sigma^2) ;

zSLproduct = sum(x.SL .* y.SL) ;

if prob.plotvar
    plot(x.SL,y.SL)
end

%%%% Shower 
prob.duration.shower     = results.duration_shower    ; % [min]
prob.MeanVolume.shower   = results.MeanVolume_shower    ; % [l/min]
prob.incday.shower       = results.incday_shower    ;

prob.ysum.shower                = prob.MeanVolume.shower * prob.duration.shower * prob.incday.shower  * 365;
sigma               = sqrt(2) ;
mu.shower           = prob.MeanVolume.shower ;

f = @(xamp) myfunDHW(xamp, mu.shower, sigma)-prob.ysum.shower  ;
amp.shower = fsolve(f,200) ;

x.shower = max(0.2,mu.shower - 2*sigma):.2:(mu.shower + 2*sigma) ;

y.shower = amp.shower / (1/(sqrt(2*pi)*sigma))*normpdf(x.shower,mu.shower,sigma);

zshowerproduct = sum(x.shower .* y.shower) ;

if prob.plotvar
    plot(x.shower,y.shower)
end
%%%%% Bath
prob.duration.bath     = results.duration_bath    ; % [min]
prob.MeanVolume.bath   = results.MeanVolume_bath         ; % [l/min]
prob.incday.bath       = results.incday_bath      ;

prob.ysum.bath  = prob.MeanVolume.bath * prob.duration.bath * prob.incday.bath  * 365;
% amp     = 30 ;
sigma       = sqrt(2) ;
mu.bath     = prob.MeanVolume.bath  ;

f = @(xamp) myfunDHW(xamp, mu.bath, sigma)-prob.ysum.bath ;
amp.bath = fsolve(f,200)  ;

x.bath = max(0.2,mu.bath - 2*sigma):.2:(mu.bath + 2*sigma) ;
y.bath = amp.bath / (1/(sqrt(2*pi)*sigma))*normpdf(x.bath,mu.bath,sigma);

zbathproduct = sum(x.bath .* y.bath)  ;

if prob.plotvar
    plot(x.bath,y.bath)
    hold off
end

%
water_profile.YEarly_WL = zSLproduct + zMLproduct + zshowerproduct + zbathproduct ;

Holiday_start.Period1 = datetime(2013,7,14) ;
Holiday_end.Period1 = datetime(2013,7,28)   ;

Holiday_start.Period2 = datetime(2013,8,8) ;
Holiday_end.Period2 = datetime(2013,8,22)   ;

% Loop through each step and define the amount of withdrawl

simulation_size = results.A6 * 24 * 60 / results.A4 ; % define the number of steps to loop through and the length of the array
prob.sim1day = 24 * 60 / results.A4 ;

stpIn = results.A4 / 60 ;
datevector = (datetime(datenum(2013,1,1),'ConvertFrom','datenum'):seconds(3600*stpIn):datetime(datenum(2013,1,results.A6+1),'ConvertFrom','datenum'))';
datevector = datevector(1:simulation_size) ;
% Replicate or not
rng(1)  
prob.Rand_Time                   = RandBetween(0,1-results.A4*1.25/100,simulation_size,1) ;

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
    prob_holiday(holidays == 1) = (results.A7 - 100) / results.A7   ;

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

prob.A4 = results.A4 ;
prob.A6 = results.A6 ;
prob.incday = incday         ;
prob.duration = duration     ;
prob.MeanVolume = MeanVolume ;

rng(1)
prob.randgen = rand(simulation_size,1) ;

loads       = fieldnames(prob.proba) ;

for iload = 1:length(loads)
    loadname            = loads{iload} ;
    countprofile        = [loadname 'profile'] ;
    countwithdrawal     = [loadname 'withdrawal'] ;
    meanvol             = ['MeanVolume_' loadname ] ;
    
    distx       = repelem(x.(loadname),floor(y.(loadname)));
    distxrand   = distx(randperm(length(distx)));
    if length(distxrand) > simulation_size
        prob.(countwithdrawal) = distxrand(1:simulation_size) ; % Shrink the array to the same size
    else
        temparr                = repmat(distxrand,ceil(simulation_size / length(distxrand)),1) ;
        prob.(countwithdrawal) = temparr(1:simulation_size) ;
        if any(strcmp(loadname,{'SL', 'ML'}))
            ratiomean = mean(prob.(countwithdrawal)) / results.(meanvol) ;
            prob.(countwithdrawal) = prob.(countwithdrawal) / ratiomean;
        end
        % ratio is used to have the right mean otherwise the SL components
        % is incorrect as the gaussian distribution is truncated.
        
    end
end

