%% Electric contracts
% This section of the model consists at detailing the price of electricity
% on the network, without taxes, considering the different contract offered
% by the local energy company, Oulun Energia Oy. Three different contracts
% are available to private consumers: "Varmavirta", "Vihrevirta", and
% "Tuulivirta". The first one guarantee a mix of energy available, the
% second one guarantee electricity from bioomass, and the third one
% guarantee the source of electricity from wind power. The price of
% electricity, for each of the contract offered, is spread throughout six
% pricing levels. Each level is defined depending on the seasons _*varseason*_, the
% weekday _*timeweekday*_, and the time of the day _*timehour*_.
%%%
% A fourth option is available to private consumers consisting in offering 
% hourly electricity pricing. As hourly pricing vectors were not available,
% a pricing vector as been created. The calculation is based on the grid market price
% where hourly selling (Sp) and purchasing (Pp) price is available at the network level. Data
% are handled by Fingrid. To evaluate what would be the potential hourly price at the dwelling level, historical data
% about the electricity price (DHpm) have been used (EMV, 2012) by distinguishing the
% building type. Ten different building architectures are defined where three ���single house���
% categories are differentiated. Equations ... and ... are used to link the market price and
% the electricity price at the building level to draw an hourly vector of electricity price for
% purchasing and selling. 
%%%
% $$P_{DH}=DH_{pm}\cdot \frac{Max(10, P_{p})}{\overline{P}_{pm}}$$
%%%
% Similarly, the selling price SDH is calculated as
%%%
% $$S_{DH}=DH_{pm}\cdot \frac{Max(10,\, S_{p})}{\overline{S}_{pm}}$$
%%%
% Where, PDH is the hourly electricity purchase price of a detached house [��� cent/kWh], Ppm
% is the mean monthly purchasing price at the network level [���/MWh], Pp is the hourly purchasing
% price at the network level [���/MWh], DHpm is the monthly purchasing price at the
% building level [��� cent/kWh]. The constant 10 is added for setting the minimum purchase
% price at 10 ���/MWh because the data contain negative values for some hours, meaning that
% people were paid to use electricity.
%%%
% This method allows calculating a purchasing price for every hour, based on the historical
% price data at the network level. This method can be used at the building level and find
% its usefulness in a direct, dynamic and simple way to provide a price vector. However,
% this method sees its limits at the grid level when speaking about smart grid because the
% grid price would evolve with the electric flow. In case the grid is able to read the energy
% consumption of a house or a given location instantly, it would be possible to influence
% the end-user by changing drastically the price of electricity on a given period. This period
% may vary from building to building and is handled by the grid in order to reduce the peak
% consumption. For modelling such behaviour, it is necessary to have a set of buildings
% connected in a micro grid. Although the model could already integrate such architecture,
% the iterative model for integrating price variation at the grid level does not exist. Thus, the
% method used in the model does not influence the grid price while, when studying a smart
% grid, the influence of building energy consumption will influence the grid price.
%%
function [Season,Price,PriceForca]= Elec_Contract(varargin)
Time_Sim = varargin{1};
Input_Data = varargin{2};
All_Var = varargin{3};
BuildSim = varargin{4};
timemonth = Time_Sim.timemonth;
timehour = Time_Sim.timehour;
timeyear = Time_Sim.timeyear;
myiter = Time_Sim.myiter;
ContElec = Input_Data.ContElec;
HouseType = str2double(Input_Data.Building_Type) ;
% Timeoffset = Time_Sim.Timeoffset;
Low_Price = str2double(Input_Data.Low_Price) ;
High_Price = str2double(Input_Data.High_Price) ;
Contracts = Input_Data.Contract ;
%% Season definition
% Two seasons are defined in the contracts from Oulun Energia Oy, the
% winter time and the summer time. Winter season is defined from 1.11 to
% 31.3. The summer season is defined for the other half of the year. If the
% season is winter, the variable _*varseason*_ takes the value 1, otherwise
% 0.
[varseason, varweekday, varhour] = Forecaste_Timeslot(Time_Sim, 0, Input_Data) ;
%% Taxes
Price_Tax  = All_Var.Price_Tax                  ;
Diff = (timeyear - 2000) * 12 + timemonth       ;
        switch (HouseType)
            % Single house, fuse 3x25 A, consumption 5 000 kWh/year
            case 1 
                ColPrice = 2;
            % Flat, fuse 1x25 A, consumption 2 000 kWh/year
            case 2
                ColPrice = 1;
        end
    % Tax on energy ~2.5 ���cts/kWh
    Distribution_IncTax_Fix   = Price_Tax(Diff,ColPrice);
    % Fixe energy tax ~24 %
    Energy_Tax_VAT   = Price_Tax(Diff,7);
    % Variable Energy Tax ~2 ���cts/kWh
    Energy_Tax_Var   = Price_Tax(Diff,8);
if strcmp(ContElec,'Varmavirta') || strcmp(ContElec,'Vihrevirta') || strcmp(ContElec,'Tuulivirta')
%% Contracts
% Depending on the time (season, day, hour), the selection of the
% electricity price within the price table. The price table is available
% hereafter.
    switch Contracts
        case 'Fixed Tariff'
            ToUTariff = 0;
            FixedTariff = 1;
        case 'ToU Tariff'
            ToUTariff = 1;
            FixedTariff = 0;
    end
    if ToUTariff == 1
        %%%
        % The location within the table is chosen with the boolean values of time.
        Tableoption = [varseason,varweekday,varhour]';
        price = Season_Price_Variation(Tableoption, ContElec, timeyear, Energy_Tax_VAT, Distribution_IncTax_Fix, Energy_Tax_Var) ;

        varp = 1 ;
        % Make the price vectors for 2 days
        Price_Vector = zeros(48/Time_Sim.stepreal,1) ;
        if timehour >= 18
            for varprice = (timehour - 18):Time_Sim.stepreal:(timehour + 30)
                [varseason, varweekday, varhour] = Forecaste_Timeslot(Time_Sim, varprice, Input_Data) ;
                Tableoption = [varseason,varweekday,varhour]';
                Price_Vector(varp) = Season_Price_Variation(Tableoption, ContElec, timeyear, Energy_Tax_VAT, Distribution_IncTax_Fix, Energy_Tax_Var) ;
                varp = varp + 1;
            end
        else
            for varprice = (-(timehour + 6)):Time_Sim.stepreal:(42 - timehour)
                [varseason, varweekday, varhour] = Forecaste_Timeslot(Time_Sim, varprice, Input_Data) ;
                Tableoption = [varseason,varweekday,varhour]';
                Price_Vector(varp) = Season_Price_Variation(Tableoption, ContElec, timeyear, Energy_Tax_VAT, Distribution_IncTax_Fix, Energy_Tax_Var) ;
                varp = varp + 1;
            end 
        end
    elseif FixedTariff == 1
        switch(ContElec)
            case 'Varmavirta'
                MonthlyFee = 355 * 12 / (yeardays(timeyear,0) * 24) ; 
                price2 = 6.74;
            case 'Vihrevirta'
                MonthlyFee = 355 * 12 / (yeardays(timeyear,0) * 24) ; 
                price2 = 6.89;    
            case 'Tuulivirta'
                MonthlyFee = 355 * 12 / (yeardays(timeyear,0) * 24) ; 
                price2 = 7.04;
            otherwise
                error('Problem with the pricing system!!')
        end
        price = price2 * (1 + Energy_Tax_VAT / 100) + Distribution_IncTax_Fix + Energy_Tax_Var + MonthlyFee ;
        Price_Vector = ones(48,1) * price;
    else
        error('Problem with the pricing system!!')
    end
else
    %% Data loading
    % The real time pricing vector is loaded and stored in the MatLab memory.
    Real_Price = All_Var.Hourly_Real_Time_Pricing   ;
    
%     Real_Price_Timed = All_Var.Hourly_Real_Time_PricingTimed   ;
    
    CurrentPrice = Real_Price(myiter + 1) ;
    
%     DatabaseRes = 'Hourly' ; % This is the resolution of the dynamic pricing database and should be composed accordinlgy depending on the resolution chosen for the simulation.

    %%% Adjustable variable
    BasicFee = 0.25 ;
    if Low_Price == -99999
        Low_Price = -inf ;
    end
    if High_Price == 99999
        High_Price = inf ;
    end
    Limitation_Low = Low_Price ; % Oulun energia doesn't has low limitation
    Limitation_High = High_Price ; % OE uses 8.6 cts� as a limit
    %%%
    if Limitation_High == inf
        MonthlyFee = 0 ;
    else
        MonthlyFee = 500 * 12 / (yeardays(timeyear,0) * (24 / Time_Sim.stepreal)) ; %Monthly fee is given for every time step, normalised by hours
    end
    if timeyear < 2004
        Energy_Price = Price_Tax(Diff,ColPrice + 8);
        Real_Price_Temp = ones(48/Time_Sim.stepreal,1) * Energy_Price;
        %price = Real_Price * (1 + Energy_Tax_VAT / 100) + Energy_Tax_Fix + Energy_Tax_Var ;
    else  
        % Update the forecast array at 18 O'Clock
        Update_Time   = str2double(Input_Data.RTP_Update ) ; %Hour
        End_Hour      = str2double(Input_Data.RTP_EndTime) ;
%         Length_Update = 48 / Time_Sim.stepreal  ; %Hours
        
%         if timehour == Update_Time
%             % Extract the time from the timeline defined
%             All_Var.End_Day = datestr(datenum(Time_Sim.TimeStr.Year,Time_Sim.TimeStr.Month,Time_Sim.TimeStr.Day + 1,End_Hour,0,0))  ;
%         end
%         try
%             All_Var.End_Day ;
%         catch
%             All_Var.End_Day = datestr(datenum(Time_Sim.TimeStr.Year,Time_Sim.TimeStr.Month,Time_Sim.TimeStr.Day + 1,End_Hour,0,0))  ;
%         end
%         PricetimeRange = timerange(datestr(Time_Sim.TimeStr),All_Var.End_Day,'closed') ;
%         Real_Price_Temp = Real_Price_Timed(PricetimeRange,:) ; 
            
        if timehour >= Update_Time
            
            Length_Update = (datenum(Time_Sim.TimeStr.Year,Time_Sim.TimeStr.Month,Time_Sim.TimeStr.Day + 1,End_Hour,0,0) - ... 
                            Time_Sim.SimTime)*24 / ...
                            Time_Sim.stepreal      ; %expressed in number of steps
            
            if (myiter + Length_Update) >= size(Real_Price,1)
                EndLine = size(Real_Price,1) ;
            else
                EndLine = round(myiter + Length_Update) ;
            end
            Real_Price_Temp = Real_Price((myiter + 1):EndLine);
        else
            Length_Update = (datenum(Time_Sim.TimeStr.Year,Time_Sim.TimeStr.Month,Time_Sim.TimeStr.Day,End_Hour,0,0) - ... 
                            Time_Sim.SimTime) * 24 / ...
                            Time_Sim.stepreal      ; %expressed in number of steps
            EndLine = round(myiter + Length_Update) ;            
            Real_Price_Temp = Real_Price((myiter + 1):EndLine);
        end
    end

%    Real_Price_Temp = repelem(Real_Price_Temp, 1 / Time_Sim.stepreal) ; % Valid if the pricing is an hourly value.
    
    Real_Price_Temp = max(Limitation_Low,min(Limitation_High, Real_Price_Temp)) + MonthlyFee ;
    
    CurrentPrice = max(Limitation_Low,min(Limitation_High,CurrentPrice));
    price = CurrentPrice * (1 + Energy_Tax_VAT / 100) + Distribution_IncTax_Fix + Energy_Tax_Var + BasicFee;
    
    Price_Vector = Real_Price_Temp * (1 + Energy_Tax_VAT / 100) + Distribution_IncTax_Fix + Energy_Tax_Var + BasicFee;
    
end
%%% Electricity price by iteration
% Finally, the electricity price for a particular hour is retrieved in the
% _*price*_ variable to the next stage.

Season = varseason';
Price = price';
PriceForca = Price_Vector;
