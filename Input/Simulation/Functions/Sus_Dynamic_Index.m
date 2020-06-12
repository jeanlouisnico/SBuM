function [varargout] = Sus_Dynamic_Index(Time_Sim,Nbr_Building,All_Var, current_Price,ElecUsed,SDindex,Housenbr)

%% Inputs to the index
% Select which database you want to use

Time2004 = Time_Sim.Timeoffset - (datenum(2004,1,1) - datenum(Time_Sim.YearStartSim,1,1)) * 24 + Time_Sim.myiter + 1;
Envi_Database = All_Var.Emissions ;
EmissionsFactor_Thistime = Envi_Database.EmissionFactorNetto(Time2004,:);

if Housenbr > 1
    SDindex.SDI = SDindex.SDI;
    Emissions_Dwel = EmissionsFactor_Thistime * ElecUsed ;
    SDindex.IndexEmissionsOutput = SDindex.IndexEmissions;
else
    Envi_Database = All_Var.Emissions ;    

    %% Initialise the variables

%     Time2004 = Time_Sim.Timeoffset - (datenum(2004,1,1) - datenum(Time_Sim.YearStartSim,1,1)) * 24 + Time_Sim.myiter + 1;
%     Time2010 = Time_Sim.Timeoffset - (datenum(2010,1,1) - datenum(Time_Sim.YearStartSim,1,1)) * 24 + Time_Sim.myiter + 1;
%     Time2000 = Time_Sim.Timeoffset + Time_Sim.myiter + 1;

    % EnLoad  = sum(Envi_Database.hgen(Time2004,1:7),2);  
    % EnLoad2 = All_Var.Hourly_Fingrid(Time2004,2) ;

    % Nuclear_Power = All_Var.Hourly_Fingrid_Detail(Time2010,4) ;
%     Nbr_Indic = size(Envi_Database.EmissionFactorNetto,2) ;

    %% Current Emissions
    % NoxCurrent = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 13:18)) ;
    % CH4Current = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 7:12));
    % SOxCurrent = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 31:36));
    % PM2Current = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 19:24));
    % PM2_10Current = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 25:30));
    % CO2Current = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 1:6));
    % Emissions_Nuclear = All_Var.Nuc.Emissions_Nuclear ;

    EmissionsFactor_Thistime = Envi_Database.EmissionFactorNetto(Time2004,:);

    % for ii = 1:Nbr_Indic
    %     endIndex = 6 * ii;
    %     startIndex    = 6 * (ii - 1) + 1 ;
    %     
    %     EmissionCurrent(ii) = sum(All_Var.Hourly_CO2_EcoInvent(Time2000, startIndex:endIndex)) + Emissions_Nuclear(ii,1) * Nuclear_Power;
    % 
    %     EmissionCurrent(1) = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 13:18)) + Emissions_Nuclear(1,6) * Nuclear_Power;
    %     EmissionCurrent(2) = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 7:12))  + Emissions_Nuclear(1,7) * Nuclear_Power;
    %     EmissionCurrent(3) = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 31:36)) + Emissions_Nuclear(1,5) * Nuclear_Power;
    %     EmissionCurrent(4) = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 19:24)) + Emissions_Nuclear(1,2) * Nuclear_Power;
    %     EmissionCurrent(5) = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 25:30)) + Emissions_Nuclear(1,4) * Nuclear_Power;
    %     EmissionCurrent(6) = sum(All_Var.Hourly_CO2_EcoInvent(TimeEmission, 1:6))   + Emissions_Nuclear(1,1) * Nuclear_Power;
    % end
    %% Emissions per dwelling

    Emissions_Dwel = EmissionsFactor_Thistime * ElecUsed ;
    % for i = 1:Nbr_Indic
    %     Emissions_Dwel(i) = EmissionsFactor_Thistime(i) * ElecUsed ;
    % end
    % Noxlevel        = EmissionCurrent(1)/EnLoad * ElecUsed * 1000;
    % CH4_Level       = EmissionCurrent(2)/EnLoad * ElecUsed * 1000;
    % SOx_Level       = EmissionCurrent(3)/EnLoad * ElecUsed * 1000;
    % PM2_Level       = EmissionCurrent(4)/EnLoad * ElecUsed * 1000;
    % PM2_10_Level    = EmissionCurrent(5)/EnLoad * ElecUsed * 1000;
    % CO2_Level       = EmissionCurrent(6)/EnLoad * ElecUsed * 1000;

    Price_Level     = current_Price;

    %% Emissions Mean previous year
    % MeanNOx     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 13:18)));
    % MeanCH4     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 7:12)));
    % MeanSOx     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 31:36)));
    % MeanPM2     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 19:24)));
    % MeanPM2_10  = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 25:30)));
    % MeanCO2     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 1:6)));

    MeanIndicator   = mean(Envi_Database.EmissionFactorNetto((Time2004-8760):Time2004,:))   ;
    stdIndicator    = std(Envi_Database.EmissionFactorNetto((Time2004-8760):Time2004,:))    ;

    % for ii = 1:Nbr_Indic
    % %     endIndex = ii;
    % %     startIndex    = 6 * (ii - 1) + 1 ;
    %     MeanIndicator(ii) = sum(mean(Envi_Database.EmissionFactorNetto((Time2004-8760):Time2004, ii)));
    %     stdIndicator(ii)  = sum(std(Envi_Database.EmissionFactorNetto((Time2004-8760):Time2004, ii)));
    % end

    % MeanIndicator(1)     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 13:18)));
    % MeanIndicator(2)     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 7:12)));
    % MeanIndicator(3)     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 31:36)));
    % MeanIndicator(4)     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 19:24)));
    % MeanIndicator(5)     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 25:30)));
    % MeanIndicator(6)     = sum(mean(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 1:6)));
    % stdIndicator(1)     = sum(std(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 13:18)));
    % stdIndicator(2)     = sum(std(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 7:12)));
    % stdIndicator(3)     = sum(std(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 31:36)));
    % stdIndicator(4)     = sum(std(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 19:24)));
    % stdIndicator(5)     = sum(std(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 25:30)));
    % stdIndicator(6)     = sum(std(All_Var.Hourly_CO2_EcoInvent((TimeEmission-8760):TimeEmission, 1:6)));
    funcEmissions = cell(1,size(MeanIndicator,2));
    for i = 1:size(MeanIndicator,2)
        funcEmissions{i}     = utility_function(MeanIndicator(i),stdIndicator(i)) ;
    end


    %% Index Emissions
    IndexEmissions = zeros(1,size(EmissionsFactor_Thistime,2));
    for i = 1:size(MeanIndicator,2)
        IndexEmissions(i) = EmissionsFactor_Thistime(i) * funcEmissions{i}(1) + funcEmissions{i}(2);
    end
    % IndexEmissions(1) = EmissionCurrent * 0.5 / MeanNOx;
    % IndexEmissions(2) = CH4Current * 0.5 / MeanCH4;
    % IndexEmissions(3) = SOxCurrent * 0.5 / MeanSOx;
    % IndexEmissions(4) = PM2Current * 0.5 / MeanPM2;
    % IndexEmissions(5) = PM2_10Current * 0.5 / MeanPM2_10;
    % IndexEmissions(6) = CO2Current * 0.5 / MeanCO2;


    %% Average Price
    Timeoffset = Time_Sim.Timeoffset;
    Real_Price = All_Var.Hourly_Real_Time_Pricing   ;
    Timeoffset_Adj = Timeoffset - (datenum(2004,1,1) - datenum(Time_Sim.YearStartSim,1,1)) * 24;
    MeanIndicatorlevel = size(MeanIndicator,2) + 1;
    MeanIndicator(MeanIndicatorlevel)   = mean(Real_Price((Timeoffset_Adj + Time_Sim.myiter + 1 - 8760):(Timeoffset_Adj + Time_Sim.myiter + 1))) ;
    stdIndicator(MeanIndicatorlevel)    = std(Real_Price((Timeoffset_Adj + Time_Sim.myiter + 1 - 8760):(Timeoffset_Adj + Time_Sim.myiter + 1))) ;
    funcEmissions{MeanIndicatorlevel}   = utility_function(MeanIndicator(MeanIndicatorlevel),stdIndicator(MeanIndicatorlevel)) ;

    %% Index Price Level
    IndexEmissions(1,end + 1) = Price_Level * funcEmissions{MeanIndicatorlevel}(1) + funcEmissions{MeanIndicatorlevel}(2) ;
    SDindex.IndexEmissionsOutput(Time_Sim.myiter + 1,:) = IndexEmissions;
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
    SDindex.SDI(Time_Sim.myiter + 1,1) = SDItemp ;
end
varargout{1} = SDindex.SDI;
varargout{2} = Emissions_Dwel;
varargout{3} = SDindex.IndexEmissionsOutput;
