function [varargout] = Sus_Dynamic_Index_Temp(YearStart,YearEnd)

%% Inputs to the index
% Select which database you want to use

Low_Price = -99999;
High_Price = 99999;
Database = 3;
HouseType = 2;
switch Database
    case 1
        Envi_Database = 'EcoInvent'         ;
    case 2
        Envi_Database = 'ENVIMAT' ;
    case 3
        Envi_Database = 'ReCiPe' ;
    otherwise
        Envi_Database = 'ReCiPe' ;    
end

        switch (HouseType)
            % Single house, fuse 3x25 A, consumption 5 000 kWh/year
            case 1 
                ColPrice = 2;
            % Flat, fuse 1x25 A, consumption 2 000 kWh/year
            case 2
                ColPrice = 1;
        end



All_Var = load(strcat('Results_',Envi_Database,'.mat'));
Real_Price = load('Smart_House_Data_MatLab.mat','Hourly_Real_Time_Pricing') ;
Price_Tax = load('Smart_House_Data_MatLab.mat','Price_Tax') ;
StudyYear = datenum(YearStart,1,1) ;

Timeoffset = (datenum(year(StudyYear),month(StudyYear),day(StudyYear))-datenum(2000,1,1))*24;


nbrstep = ((datenum(YearEnd,12,31) - datenum(YearStart,1,1))+1) * 24 - 1;

Nbr_Indic = size(All_Var.EmissionFactorNetto,2) ;

% IndexEmissions = zeros(1,Nbr_Indic + 1) ;
IndexEmissionsOutput = zeros(nbrstep,Nbr_Indic + 1) ;
SDI                  = zeros(nbrstep,1) ;
for timenbr = 0:nbrstep

EmissionFactorNetto = All_Var.EmissionFactorNetto ;    
Time2004 = Timeoffset - (datenum(2004,1,1) - datenum(2000,1,1)) * 24 + timenbr + 1;

if Time2004 <= size(EmissionFactorNetto,1)
%% Data loading
% The real time pricing vector is loaded and stored in the MatLab memory.
    %%% Adjustable variable
    timeyear = year(datenum(YearStart,1,1) + timenbr / 24);
    timemonth = month(datenum(YearStart,1,1) + timenbr / 24);
    timehour = hour(datenum(YearStart,1,1) + timenbr / 24);
    Diff = (timeyear - 2000) * 12 + timemonth       ;
     % Tax on energy ~2.5 €cts/kWh
    Distribution_IncTax_Fix   = Price_Tax.Price_Tax(Diff,ColPrice);
    % Fixe energy tax ~24 %
    Energy_Tax_VAT   = Price_Tax.Price_Tax(Diff,7);
    % Variable Energy Tax ~2 €cts/kWh
    Energy_Tax_Var   = Price_Tax.Price_Tax(Diff,8);
    BasicFee = 0.25 ;
    
    if Low_Price == -99999
        Low_Price = -inf ;
    end
    if High_Price == 99999
        High_Price = inf ;
    end
    Limitation_Low = Low_Price ; % Oulun energia doesn't has low limitation
    Limitation_High = High_Price ; % OE uses 8.6 cts€ as a limit
    %%%
    if Limitation_High == inf
        MonthlyFee = 0 ;
    else
        MonthlyFee = 500 * 12 / (yeardays(timeyear,0) * 24) ;
    end
    if timeyear < 2004
        Energy_Price = Price_Tax.Price_Tax(Diff,ColPrice + 8);
        Real_Price_Temp = ones(48,1) * Energy_Price;
        %price = Real_Price * (1 + Energy_Tax_VAT / 100) + Energy_Tax_Fix + Energy_Tax_Var ;
    else  
        %Real_Spot_Price = Range("e" & Z) * (1 + Range("g" & x) / 100) + Range("i" & x + 1) + Range("g" & x + 1)
        Timeoffset_Adj = Timeoffset - (datenum(2004,1,1) - datenum(2000,1,1)) * 24;
        if timehour >= 18
            Real_Price_Temp = Real_Price.Hourly_Real_Time_Pricing((Timeoffset_Adj + timenbr + 1 - timehour):(Timeoffset_Adj + timenbr + 48 - timehour)) + MonthlyFee;
        else
            Real_Price_Temp = Real_Price.Hourly_Real_Time_Pricing((Timeoffset_Adj + timenbr + 1 - (24 + timehour)):(Timeoffset_Adj + timenbr + (24 - timehour))) + MonthlyFee;
        end
    end
    Real_Price_Temp = max(Limitation_Low,min(Limitation_High,Real_Price_Temp));
    Price_Vector = Real_Price_Temp * (1 + Energy_Tax_VAT / 100) + Distribution_IncTax_Fix + Energy_Tax_Var + BasicFee;
    if timehour >= 18
        current_Price = Price_Vector(timehour + 1);
        RTP = Real_Price_Temp(timehour + 1);
    else
        current_Price = Price_Vector(25+timehour);
        RTP = Real_Price_Temp(25+timehour);
    end
    


EmissionsFactor_Thistime = EmissionFactorNetto(Time2004,:);

%     Envi_Database = All_Var.Emissions ;    

    %% Initialise the variables

    %% Current Emissions

    %% Emissions per dwelling

    Price_Level     = current_Price;

    %% Emissions Mean previous year
    MeanIndicator   = mean(EmissionFactorNetto((Time2004-8760):Time2004,:))   ;
    stdIndicator    = std(EmissionFactorNetto((Time2004-8760):Time2004,:))    ;

    funcEmissions = cell(1,size(MeanIndicator,2));
    for i = 1:size(MeanIndicator,2)
        funcEmissions{i}     = utility_function(MeanIndicator(i),stdIndicator(i)) ;
    end


    %% Index Emissions
    IndexEmissions = zeros(1,size(EmissionsFactor_Thistime,2));
    for i = 1:size(MeanIndicator,2)
        IndexEmissions(i) = EmissionsFactor_Thistime(i) * funcEmissions{i}(1) + funcEmissions{i}(2);
    end
    %% Average Price

    Timeoffset_Adj = Timeoffset - (datenum(2004,1,1) - datenum(2000,1,1)) * 24;
    MeanIndicatorlevel = size(MeanIndicator,2) + 1;
    MeanIndicator(MeanIndicatorlevel)   = mean(Real_Price.Hourly_Real_Time_Pricing((Timeoffset_Adj + timenbr + 1 - 8760):(Timeoffset_Adj + timenbr + 1))) ;
    stdIndicator(MeanIndicatorlevel)    = std(Real_Price.Hourly_Real_Time_Pricing((Timeoffset_Adj + timenbr + 1 - 8760):(Timeoffset_Adj + timenbr + 1))) ;
    funcEmissions{MeanIndicatorlevel}   = utility_function(MeanIndicator(MeanIndicatorlevel),stdIndicator(MeanIndicatorlevel)) ;

    %% Index Price Level
    IndexEmissions(1,end + 1) = RTP * funcEmissions{MeanIndicatorlevel}(1) + funcEmissions{MeanIndicatorlevel}(2) ;
    IndexEmissionsOutput(timenbr + 1,:) = IndexEmissions;
    %% Get the weighted average for each indicator
    % Generate weights
    weights = zeros(1,size(IndexEmissions,2));
    iteration = 10000 ;
    for i=1:iteration
        randNum = rand(1,size(IndexEmissions,2)-1);
        q = [0,sort(randNum),1];
        for j = 2:(size(IndexEmissions,2)+1)
            weights(j-1) = q(j) - q(j-1);
        end
        SDItemp = sum(IndexEmissions .* weights) ;
    end
    SDI(timenbr + 1,1) = SDItemp ;
else
    IndexEmissionsOutput(timenbr + 1,:) = zeros(1,Nbr_Indic + 1) ;
    SDI(timenbr + 1,1) = zeros(1,1) ;
end
end
varargout{1} = SDI;
varargout{2} = IndexEmissionsOutput;
beep
beep
beep
