%% Environmental Emissions calculation
function [hgen,hgencmp,varargout] = Emissions(varargin)
%% Introduction
% The purpose of this code is to create an hourly vector of CO2 emissions
% from the electricity produced in a country. The calculation is made in 3
% steps depending on the data availability. At first, ...
dbstop if error
%%% 
% First full week of the month
disp('Load .mat file...')
Input_Data = load('Smart_House_Data_MatLab.mat');

Public = 0 ; %1: distributed, 0:working file.
if Public == 1
    YearStartSim = 2012 ;
    YearStartSim2004 = 2012 ;
else
    YearStartSim = 2000 ;
    YearStartSim2004 = 2004 ;
end

if nargin > 1
    Yearst = varargin{1};
    Date_Ref = datenum(Yearst,1,(1:53)*7-2)-weekday(datenum(Yearst,1,3));
    Database = varargin{2}  ;
else
    if size(varargin{1},2)>1
        error('Too Many Input, you can input only 1 year at a time');
    else
        Yearst = varargin{1};
        Date_Ref = datenum(Yearst,1,(1:53)*7-2)-weekday(datenum(Yearst,1,3));
        Database = 3    ;
    end
end
disp('Load the UMM values...')
Comparison = 0;
newcol = 1;
if nargin > 1
    if ~(exist('alldata','var') == 1) || varargin{2} == 1
        [~, alldata, ~] = xlsread('Statistics_Finnish_Industry_Association.xlsm', 'Sheet1', 'AK1');
        [~, ~, alldata] = xlsread('Statistics_Finnish_Industry_Association.xlsm', 'Sheet1', alldata{1});
        for rcol = 1:1:size(alldata,2)
            newrow = 1;
            for nrow = 1:size(alldata,1)
                if rcol == 1 || rcol == 2
                    UMM{newrow,newcol} = x2mdate([alldata{nrow,rcol}]);
                    newrow = newrow + 1;
                elseif (15 <= rcol && rcol <= 23)
                    continue
                else
                    UMM{newrow,newcol} = alldata{nrow,rcol};
                    newrow = newrow + 1;
                end
            end
            if rcol == 1 || rcol == 2
                newcol = newcol + 1;
            elseif (15 <= rcol && rcol <= 23)
                continue
            else
                newcol = newcol + 1;
            end
         end
    end
end
Techn = 1:7;
CO2em = zeros(length(Date_Ref),length(Techn));
a = zeros(length(Techn),1);
%% Generate the weekly emission profile
% The emissions are given by the Finnish Industry Association, or can be
% calculated using the segmentation of the energy source used on a monthly
% basis per technology.
disp('Generate the weekly emission profiles...')
Iter1 = 1;
if day(datenum(year(Date_Ref(1)),month(Date_Ref(1)),day(Date_Ref(1)))) > 1
    add_week = 1;
else
    add_week = 0;
end
m = 1;
for n = 1:length(Date_Ref)
    if datenum(year(Date_Ref(n)),month(Date_Ref(n)),day(Date_Ref(n))) >= datenum(2011,7,1)
        nweeks_diff_En = fix((datenum(year(Date_Ref(n)),month(Date_Ref(n)),day(Date_Ref(n))) - datenum(YearStartSim,1,1))/7) + 1 - add_week;
        if nweeks_diff_En < size(Input_Data.Weeks_Stat,1)
            if day(datenum(year(Date_Ref(n)),month(Date_Ref(n)),day(Date_Ref(n)))) > 1 && Iter1 == 1
                nmonth_diff_Em = round((year(Date_Ref(n)) + month(Date_Ref(n))/12 - (2011 + 7/12)) * 12 + 1) - 1;
            else
                nmonth_diff_Em = round((year(Date_Ref(n)) + month(Date_Ref(n))/12 - (2011 + 7/12)) * 12 + 1);
            end
                % Emissions per month for all the technologies
                try Input_Data.Emissions_Months(:,nmonth_diff_Em) ;            %# Attempt to perform some computation
                   mEm = Input_Data.Emissions_Months(:,nmonth_diff_Em);
                catch  %# Catch the exception
                    continue
                end
                % Energy produced per month for all technologies
                mEn = Input_Data.Energy_Month(:,nmonth_diff_Em + 102); % 102 is because the data start from 2003
            daypermonth = eomday(year(Date_Ref(n)),month(Date_Ref(n)));
            daypermonth7 = eomday(year(Date_Ref(n)),month(Date_Ref(n) + 7));
            for m = 1:length(Techn)
                if day(Date_Ref(n)) + 6 > daypermonth
                    a(m) = myweekday(datenum(year(Date_Ref(n)),month(Date_Ref(n)),daypermonth)) ...
                             * (mEm(Techn(m)) / daypermonth) + ...
                             (7 - myweekday(datenum(year(Date_Ref(n)),month(Date_Ref(n)),daypermonth))) ...
                             * (mEm(Techn(m)) / daypermonth7);
                else
                        a(m) = (mEm(Techn(m)) / daypermonth) * 7 ;
                end
                CO2em(n,m) = a(m) * (Input_Data.Weeks_Stat(nweeks_diff_En,Techn(m))/ mEn(Techn(m))) * (daypermonth / 7) ;
            end
        else
                CO2em(n,m) = 0;
        end
    else
        %disp('No Emission data for the period');
    end
    Iter1 = 0;
end
%% Generate the hourly energy production profile
% Energy Produced per hour for each technology
% Look first if the date has been downloaded already
disp('Generate the hourly energy production profiles...')
varstep = 1;
nbrhouryear = yeardays(Yearst) * 24 ;
% length(Date_Ref) * 24 * 7
vardet = 1; hgen = zeros(nbrhouryear,length(Techn));
hgencmp = zeros(nbrhouryear,length(Techn));



% Choose the emission database: 
% 1. EcoInvent 3.01, 
% 2. ENVIMAT (SYKE database)
% 3. ReCiPe v1.11 (SimaPro database)
% 4. ReCiPe v1.12 (SimaPro database)

switch Database
    case 1
        CO2weekimport = Input_Data.CO2w             ;
        Correlation = Input_Data.Emissions_Correlation         ;
    case 2
        CO2weekimport = Input_Data.CO2w_ENVIMAT     ;
        Correlation = Input_Data.Emissions_Correlation_ENVIMAT ;
    case 3
        CO2weekimport = Input_Data.CO2w_ReCiPe     ;
        Correlation = Input_Data.Emissions_Correlation_ReCiPe ;
    case 4
        CO2weekimport = Input_Data.CO2w_ReCiPe_v_1_12     ;
        Correlation = Input_Data.Emissions_Correlation_ReCiPev1_12 ;
    otherwise
        CO2weekimport = Input_Data.CO2w             ;    
end

nbr_Emissions_Indicator = (size(CO2weekimport,2)-2)/7 ;

Em_Global = zeros(nbrhouryear,6,nbr_Emissions_Indicator);


for varm = 1:12
    nmonth_diff_Em = round((year(Date_Ref(2)) + month(Date_Ref(2))/12 - (2003 + 1/12)) * 12 + 1);
    for vard = 1:eomday(year(Date_Ref(2)),varm)
        nweeks_diff_En = fix((datenum(year(Date_Ref(2)),varm,vard) - datenum(YearStartSim,1,3))/7) + 1;
        
        % The last day depends on the availability of the data: Both the
        % generated power and the emissions must be given in order to
        % proceed.
            if Input_Data.Hourly_Fingrid_Detail(end,1) > datenum(Yearst,varm,vard)
                
                if datenum(CO2weekimport(end,1),1,CO2weekimport(end,2) * 7) >= datenum(Yearst,1,str2double(datestr8601(datenum(Yearst,varm,vard),'WW')) * 7)
                    testpass = 1;
                    Mess = 'Hourly CO2 OK' ;
                else
                    testpass = 0;
                    Mess = 'Fingrid information: OK - Missing CO2 information' ;
                end
            else
                testpass = 0;
                Mess = 'Missing fingrid information' ;
            end
            
        if nweeks_diff_En < size(Input_Data.Weeks_Stat,1) && testpass == 1
            for varh = 1:24
                    vartF  = (fix((datenum(year(Date_Ref(2)),varm,vard) - datenum(YearStartSim2004,1,1)))) * 24 + varh;
                    %%% Get the right date
                    DayofWeek       = day(datetime(year(Date_Ref(2)),varm,vard,varh - 1,0,0),'dayofweek')   ;
                    NormalweekDay   = [7 1 2 3 4 5 6]                                                       ;
                    DayofWeek       = NormalweekDay(DayofWeek)                                              ;
                    DateMonday      = datenum(year(Date_Ref(2)),varm,vard + (1 - DayofWeek))                ;
                    DateSunday      = datenum(year(Date_Ref(2)),varm,vard + (7 - DayofWeek))                ;
                    numdaystart     = (max(1,(DateMonday - datenum(YearStartSim2004,1,1)))) * 24 + 1;
                    numdayends      = (DateSunday - datenum(YearStartSim2004,1,1) + 1) * 24 ;   
                        for vart = 1:length(Techn)
                            if varstep == 3121
                                y = 1;
                            end
                            wEn = Input_Data.Weeks_Stat(nweeks_diff_En,Techn(vart));
                            dateref = datenum(year(Date_Ref(2)),varm,vard) + (varh-1) / 24;
                            
                            
                            % If the data has been downloaded from Fingrid, then we
                            % use the real data
                            %%%
                            % Order to look at the data
                            % 1: Nuclear
                            % 2: Wind Power
                            % 3: DH
                            % 4: Industry
                            % 5: Condensing Power
                            % 6: Hydro Power
                            % 7: Gas Turbine
                            if datenum(year(Date_Ref(2)),varm,vard) + (varh - 1) /24 >= datenum(2010,1,1) && ...
                                    size(find(round(Input_Data.Hourly_Fingrid_Detail(:,1)*10000)/10000 == round((datenum(year(Date_Ref(2)),varm,vard) + (varh - 1) / 24)*10000)/10000),1)>0
                                hgen(varstep,Techn(vart)) = Input_Data.Hourly_Fingrid_Detail(find(round(Input_Data.Hourly_Fingrid_Detail(:,1)*10000)/10000 == round((datenum(year(Date_Ref(2)),varm,vard) + (varh - 1) / 24)*10000)/10000),Techn(vart)+3);
                                if vart == 7
                                    hgen(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgen(varstep,5);
                                    hgen(varstep,5) = hgen(varstep,5) - hgen(varstep,7); 
                                    vardet = vardet + 1;
                                end
                                if Comparison == 1
                                    time_step = 2;
                                    hgencmp(varstep,Techn(vart)) = Power_Gen(vart,dateref, wEn, nweeks_diff_En, Techn, vartF,hgencmp,Input_Data,time_step,Date_Ref,varm,vard,varh,varstep,nmonth_diff_Em);
                                    if vart == 7 && time_step == 1
                                        hgencmp(varstep,6) = Input_Data.Hourly_Fingrid(vartF,3) - sum(hgencmp(varstep,:));
                                        hgencmp(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgencmp(varstep,5);
                                        hgencmp(varstep,5) = hgencmp(varstep,5) - hgencmp(varstep,7); 
                                    elseif vart == 7 && time_step == 2
                                        hgencmp(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgencmp(varstep,5);
                                        hgencmp(varstep,5) = hgencmp(varstep,5) - hgencmp(varstep,7);
                                    end
                                end
                            % If the data is available on a daily basis, then we
                            % use daily statistics
                            elseif datenum(year(Date_Ref(2)),varm,vard) + (varh - 1) /24 >= datenum(2010,1,1)
                                time_step = 2;
                                hgen(varstep,Techn(vart)) = Power_Gen(vart,dateref, wEn, nweeks_diff_En, Techn, vartF,hgen,Input_Data,time_step,Date_Ref,varm,vard,varh,varstep,nmonth_diff_Em);
                                if vart == 7
                                    hgen(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgen(varstep,5);
                                    hgen(varstep,5) = hgen(varstep,5) - hgen(varstep,7);
                                end
                                if Comparison == 1
                                    time_step = 2;
                                    hgencmp(varstep,Techn(vart)) = Power_Gen(vart,dateref, wEn, nweeks_diff_En, Techn, vartF,hgencmp,Input_Data,time_step,Date_Ref,varm,vard,varh,varstep,nmonth_diff_Em);
                                    if vart == 7 && time_step == 1
                                        hgencmp(varstep,6) = Input_Data.Hourly_Fingrid(vartF,3) - sum(hgencmp(varstep,:));
                                        hgencmp(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgencmp(varstep,5);
                                        hgencmp(varstep,5) = hgencmp(varstep,5) - hgencmp(varstep,7);
                                    elseif vart == 7 && time_step == 2
                                        hgencmp(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgencmp(varstep,5);
                                        hgencmp(varstep,5) = hgencmp(varstep,5) - hgencmp(varstep,7);
                                    end
                                end
                            % If none of the above exist, then we use the weekly
                            % and monthly statistics.
                            else
                                time_step = 1;
                                hgen(varstep,Techn(vart)) = Power_Gen(vart,dateref, wEn, nweeks_diff_En, Techn, vartF,hgen,Input_Data,time_step,Date_Ref,varm,vard,varh,varstep,nmonth_diff_Em);
                                if vart == 7
                                    if numdaystart == 25
                                        EnGene = Input_Data.Hourly_Fingrid(vartF,3) / (7/4 * sum(Input_Data.Hourly_Fingrid(1:numdayends,3))) * (sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))) * 1000);
                                    else
                                        EnGene = Input_Data.Hourly_Fingrid(vartF,3) / sum(Input_Data.Hourly_Fingrid(numdaystart:numdayends,3)) * (sum(Input_Data.Weeks_Stat(nweeks_diff_En,1:length(Techn))) * 1000);
                                    end
                                    hgen(varstep,6) = max(0,EnGene - sum(hgen(varstep,:)));
                                    hgen(varstep,7) = (Input_Data.Energy_Month(7,nmonth_diff_Em) / sum(Input_Data.Energy_Month(6:7,nmonth_diff_Em))) * hgen(varstep,5);
                                    hgen(varstep,5) = hgen(varstep,5) - hgen(varstep,7); 
                                end
                            end
                        end
                    hgen(varstep,8) = datenum(year(Date_Ref(2)),varm,vard) + (varh-1)/24;
                    %% Emissions from the electricity produced
                    WeekNbr = datestr8601(datenum(year(Date_Ref(2)),varm,vard,varh - 1,0,0),'WW');
                    
                    % For further notice, CO2w is the variable with data
                    % from the Excel spreadsheet. It could be equal to the
                    % CO2em calculated above.
                    if str2double(WeekNbr) > 10 && varm == 1
                        CO2week = find(CO2weekimport(:,1) == (year(Date_Ref(2))-1) & CO2weekimport(:,2) == str2double(WeekNbr));
                    else
                        CO2week = find(CO2weekimport(:,1) == year(Date_Ref(2)) & CO2weekimport(:,2) == str2double(WeekNbr));
                    end
                    % Order to look at the data
                            % 1: Nuclear
                            % 2: Wind Power
                            % 3: DH
                            % 4: Industry
                            % 5: Condensing Power
                            % 6: Hydro Power
                            % 7: Gas Turbine
                    if ~CO2week==0
                        % If CO2 level are given by the Energy Association
                        for nvartech = 1:6
                            k1 = hgen(varstep,nvartech) ;
                            k2 =  hgen(varstep,(nvartech + 2)) ;
                            EnW1 = Input_Data.Weeks_Stat(nweeks_diff_En,nvartech) ;
                            EnW2 = Input_Data.Weeks_Stat(nweeks_diff_En,(nvartech + 2)) ;
                            if nvartech == 5
                                for ii = 1:nbr_Emissions_Indicator
                                    Em_Global(varstep,nvartech,ii) = (k1 + k2) / 1000 / (EnW1 + EnW2) * (CO2weekimport(CO2week(1),(nvartech + 2) * ii) + CO2weekimport(CO2week(1),(nvartech + 2) * ii + 2));
                                end
                            else
                                for ii = 1:nbr_Emissions_Indicator
                                    Em_Global(varstep,nvartech,ii) = k1 / 1000 / EnW1 * CO2weekimport(CO2week(1),nvartech + 2 + 7 * (ii - 1));
                                end
                            end
                        end
                    else
                        % If the CO2 level is not given, we will use
                        % average values from the previous year.
                        dateref = round((datenum(year(Date_Ref(2)),varm,vard) + (varh-1)/24) - datenum(YearStartSim,1,1));
                        for nvartech = 1:6
                            switch nvartech
                                case 1
                                    rowref = 4;
                                case 2
                                    rowref = 5;
                                case 3
                                    rowref = 1;
                                case 4
                                    rowref = 2;
                                case 5
                                    rowref = 3;
                                case 6
                                    rowref = 6;
                            end
                            for ii = 1:nbr_Emissions_Indicator
                                refrow = ((rowref-1) * nbr_Emissions_Indicator) + ii ;
                                Em_Global(varstep,nvartech,ii) = Correlation(refrow,1) + Correlation(refrow,2) * hgen(varstep,nvartech) + Correlation(refrow,3) * hgen(varstep,7) + Correlation(refrow,4) * Input_Data.Hourly_Temperature(dateref);
                            end
                        end
                    end
                    varstep = varstep + 1;
            end
        else
            hgen(varstep,:) = 0;
        end
    end
end

for jj = 1:nbr_Emissions_Indicator
    Em_GlobalOutput_h = Em_Global(:,:,jj) ; 
    Em_GlobalOutput_h(isnan(Em_GlobalOutput_h)) = 0; 
    Em_GlobalOutput_h_Cong = sum(Em_GlobalOutput_h,2);
    GlobalOutput_h{jj,1} = Em_GlobalOutput_h;
    GlobalOutput_h{jj,2} = Em_GlobalOutput_h_Cong;
end

%% Get the environmental emission factor
disp('Get the environmental emission factor...')
        Exchanged = load('Exchanged.mat');
        
        En_Load = zeros(1,nbrhouryear);
        
        switch Database
            case 1
                HourlyEmissions = Input_Data.Hourly_CO2_EcoInvent             ;
                ResultName = 'Emissions_EcoInvent' ;
            case 2
                HourlyEmissions = Input_Data.Hourly_CO2_ENVIMAT     ;
                ResultName = 'Emissions_ENVIMAT' ;
            case 3 
                HourlyEmissions = Input_Data.Hourly_CO2_ReCiPe     ;
                ResultName = 'Emissions_ReCiPe' ;
            case 4 
                HourlyEmissions = Input_Data.Hourly_CO2_ReCiPe     ;
                ResultName = 'Emissions_ReCiPe' ;
            otherwise
                HourlyEmissions = Input_Data.Hourly_CO2_ReCiPe     ;   
                ResultName = 'Emissions_ReCiPe' ;
        end
                
        datestart   = datenum(Yearst,1,1) ;
        dateend     = datenum(Yearst,12,31) ;
    
        tic
        Em_Start = datestart - datenum(YearStartSim,1,1);
        Em_End = dateend - datenum(YearStartSim,1,1);
        Em_Start2 = datestart - datenum(YearStartSim2004,1,1);
        Em_End2 = dateend - datenum(YearStartSim2004,1,1);
        
        En_Generation = sum(hgen(:,1:7),2)';
        
        En_Load = Input_Data.Hourly_Fingrid(((((Em_Start2)*24) + 1):min(size(Input_Data.Hourly_Fingrid,1),((Em_End2 + 1)*24))),2)';
        
        Traded = Exchanged.Exchanged_Electricity(((((Em_Start2)*24) + 1):min(size(Input_Data.Hourly_Fingrid,1),((Em_End2 + 1)*24))),:)';
        EmissionsCountry = Exchanged.Emissions_Country(:,:,Database) ;
        
        %Import environmental data
        Nbr_Indic = size(HourlyEmissions,2) / 6 ;
        for ii = 1:Nbr_Indic
            endIndex = 6 * ii;
            startIndex    = 6 * (ii - 1) + 1 ;
            
            Emissions_Gen = GlobalOutput_h{ii,2};
                           
            endIndex = 6 * ii;
            startIndex    = 6 * (ii - 1) + 1 ;

            switch Database
                case 3
                    if and(ii >= 13,ii<=16) 
                        Multiple = 0.001;
                    else
                        Multiple = 1000 ;
                    end
                case 4
                    if and(ii >= 13,ii<=16) 
                        Multiple = 0.001;
                    else
                        Multiple = 1000 ;
                    end 
                otherwise
                    Multiple = 1000 ;
            end
                EmissionGen(:,ii) = (Emissions_Gen * Multiple) ;
                EmissionFactorGen(:,ii) = (Emissions_Gen * Multiple) ./ En_Generation';
                
                EmissionFix(:,ii) = EmissionsCountry(ii,5) * En_Generation' ;
                
                EmissionFactor(:,ii) = Emissions_Gen ./ En_Generation'; 
                %Emissions_ReCiPe{1}.EmissionsfactProduced(:,ii) = (sum(HourlyEmissions((((Em_Start-1)*24) + 1):(Em_End*24),startIndex:endIndex),2) * Multiple) ./ En_Generation';
                
                for ww = 1:size(En_Load,2) % ww = number of dates
                    NetImportCO2(ww,1)      = sum(diag(Traded(2:2:size(Traded,1),ww) * EmissionsCountry(ii,1:4))) / 1000 ;
                    NetProducedCO2(ww,1)    =(EmissionFactor(ww,ii)) * (En_Generation(1,ww) - sum(Traded(1:2:size(Traded,1),ww))) ;
                    NetFixCO2(ww,1)         = NetImportCO2(ww,1) +  (EmissionFix(ww,ii)) * (En_Generation(1,ww) - sum(Traded(1:2:size(Traded,1),ww))) ;
                    NetCO2(ww,1)            = NetImportCO2(ww,1) +  NetProducedCO2(ww,1) ;
                end
                EmcountryFixTotal(:,ii)     = NetFixCO2(:,1);
                EmcountryTotal(:,ii)        = NetCO2(:,1);
                EmissionFactorNetto(:,ii)   = NetCO2(:,1) ./ En_Load' * Multiple ;
        end

disp(Mess)                          ;
disp(strcat('Year ',num2str(Yearst),'Completed...'))                          ;
varargout{1} = GlobalOutput_h       ;
varargout{2} = EmissionFactorGen    ;
varargout{3} = EmissionFactorNetto  ;
varargout{4} = EmcountryTotal       ;
varargout{5} = EmissionGen          ;
varargout{6} = EmissionFix    ;
