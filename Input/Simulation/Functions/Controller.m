%% Controller
function [Delay_time, hour_1_delay, Reduce_time, varargout] = Controller(varargin)

Time_Sim    = varargin{1}            ;
Input_Data  = varargin{2}            ;
Housenbr    = varargin{3}            ;
All_Var     = varargin{6}            ;
EnergyOuput = varargin{4}            ;
Cont        = varargin{5}            ;
SDI         = varargin{6}            ;
myiter      = Time_Sim.myiter        ;
timehour    = Time_Sim.timehour      ;
timeweekday = Time_Sim.timeweekday   ;
timeweeknbr = Time_Sim.timeweeknbr   ;
timemonth   = Time_Sim.timemonth     ;
timeyear    = Time_Sim.timeyear      ;
%nbrstep     = Time_Sim.nbrstep       ;
stepreal    = Time_Sim.stepreal      ;
lasttime    = Time_Sim.lasttime      ;
stp         = Time_Sim.stp           ;
Forecast    = EnergyOuput.Price_Foreca;
Metering    = str2double(Input_Data.Metering)       ;
Self        = str2double(Input_Data.Self) ;
Comp        = str2double(Input_Data.Comp)      ;
Goal        = str2double(Input_Data.Goal)      ;
Bill        = str2double(Input_Data.Bill)      ;
ContElec    = Input_Data.ContElec    ;
User_Type   = str2double(Input_Data.User_Type)      ;
Contracts   = Input_Data.Contract ;
%% Self-Historical Consumption
%% Statistical Data
Cont.Timemonthnbr(Housenbr, 2)          = Cont.Timemonthnbr(Housenbr, 1); 
Cont.Timemonthnbr(Housenbr, 1)          = timemonth; 
Cont.Timeyearnbr(Housenbr, 2)           = Cont.Timeyearnbr(Housenbr, 1);  
Cont.Timeyearnbr(Housenbr, 1)           = timeyear;
Cont.Monthnbr(Housenbr, 1)              = Cont.Monthnbr(Housenbr, 2);
Cont.Yearnbr(Housenbr, 1)               = Cont.Yearnbr(Housenbr, 2);
Cont.Sum_act(Housenbr, 1)               = Cont.Sum_act(Housenbr, 2);
Cont.Sum_act(Housenbr, 3:(stp * 6 + 3)) = Cont.Sum_act(Housenbr, 2:(stp * 6 + 2));
if ~(myiter == 0)
    Cont.Sum_act(Housenbr, 2) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.Sum_act(Housenbr, 1);
    %%%
    % Count the number of month since the beginning of the simulation
    if ~(Cont.Timemonthnbr(Housenbr, 2) == Cont.Timemonthnbr(Housenbr, 1))
        Cont.Monthnbr(Housenbr, 2) = 1 + Cont.Monthnbr(Housenbr, 1);
    else
        Cont.Monthnbr(Housenbr, 2) = Cont.Monthnbr(Housenbr, 1);
    end
    %%%
    % Count the number of years since the beginning of the simulation
    if ~(Cont.Timeyearnbr(Housenbr, 2) == Cont.Timeyearnbr(Housenbr, 1))
        Cont.Yearnbr(Housenbr, 2) = 1 + Cont.Yearnbr(Housenbr, 1);
    else
        Cont.Yearnbr(Housenbr, 2) = Cont.Yearnbr(Housenbr, 1);
    end
else
    Cont.Sum_act(Housenbr, 2) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1);
    Cont.Monthnbr(Housenbr, 2) = 1;
    Cont.Yearnbr(Housenbr, 2) = 1;
end
%% Decision retrieval
if Metering > 1
    if and(timehour == lasttime(Housenbr, 1), myiter > stp * 6)
        Cont.Mean_weekday(Housenbr, myiter + 1) = (Cont.Sum_act(Housenbr, 2) - Cont.Sum_act(Housenbr, 2 + (stp * 6))) / 7; 
        if timeweekday == 7
            Cont.Mean_Week(Housenbr, myiter + 1) = Cont.Sum_act(Housenbr,2) / timeweeknbr;
        else
            Cont.Mean_Week(Housenbr, myiter + 1) = Cont.Mean_Week(Housenbr, myiter);
        end
    else
        if ~myiter == 0
            Cont.Mean_weekday(Housenbr, myiter + 1) = Cont.Mean_weekday(Housenbr, myiter);
            Cont.Mean_Week(Housenbr, myiter + 1) = Cont.Mean_Week(Housenbr, myiter);
        else
            Cont.Mean_weekday(Housenbr, myiter + 1) = 0;
            Cont.Mean_Week(Housenbr, myiter + 1) = 0;
        end
    end
    if ~(myiter == 0)
        %%% Cumulated per weekday
        if timehour == 0
            Cont.Daily_Cons(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1);
        else
            Cont.Daily_Cons(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.Daily_Cons(Housenbr, myiter);
        end
        %%% Cumulated per week
        if and(timehour == 0, timeweekday == 1)
            Cont.Weekly_Cons(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1);
        else
            Cont.Weekly_Cons(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.Weekly_Cons(Housenbr, myiter);
        end
        %%% Daily and weekly response.
            if Cont.Daily_Cons(Housenbr, myiter + 1) > Cont.Mean_weekday(Housenbr, myiter + 1)
                Response_Self_wkday = 1;
            else
                Response_Self_wkday = 0;
            end
            if Cont.Weekly_Cons(Housenbr, myiter + 1) > Cont.Mean_Week(Housenbr, myiter + 1)
                Response_Self_week = 1;
            else
                Response_Self_week = 0;
            end
        %%% Monthly average electricity consumption
        if ~(Cont.Timemonthnbr(Housenbr, 2) == Cont.Timemonthnbr(Housenbr, 1))
            if timehour == 0
                if Cont.Monthnbr(Housenbr, 2) <= 1
                     Cont.Avg_Month(Housenbr, myiter + 1) = Cont.Sum_act(Housenbr, 1) / Cont.Monthnbr(Housenbr, 2);
                 else
                     Cont.Avg_Month(Housenbr, myiter + 1) = Cont.Sum_act(Housenbr, 1) / (Cont.Monthnbr(Housenbr, 2) - 1);
                end
            else
                Cont.Avg_Month(Housenbr, myiter + 1) = (Cont.Sum_act(Housenbr, 1) + Cont.Avg_Month(Housenbr, myiter)) / Cont.Monthnbr(Housenbr, 2);
            end
        else
            if Cont.Monthnbr(Housenbr, 2) <= 1
                Cont.Avg_Month(Housenbr, myiter + 1) = Cont.Avg_Month(Housenbr, myiter);
            else
                Cont.Avg_Month(Housenbr, myiter + 1) = Cont.Avg_Month(Housenbr, myiter);
            end
        end
        if ~(Cont.Timemonthnbr(Housenbr, 2) == Cont.Timemonthnbr(Housenbr, 1))
            if timehour == 0
                Cont.MeanMonth(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1);
            else
                Cont.MeanMonth(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.MeanMonth(Housenbr, myiter);
            end
        else
            Cont.MeanMonth(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.MeanMonth(Housenbr, myiter);
        end
        if and(Cont.Avg_Month(Housenbr, myiter + 1) < Cont.MeanMonth(Housenbr, myiter + 1), Cont.Avg_Month(Housenbr, myiter + 1) > 0)
            Response_Self_month = 1;
        else
            Response_Self_month = 0;
        end
        if ~(Cont.Timeyearnbr(Housenbr, 2) == Cont.Timeyearnbr(Housenbr, 1))
            if timehour == 0
                if Cont.Yearnbr(Housenbr, 2) <= 1
                     Cont.Avg_Year(Housenbr, myiter + 1) = Cont.Sum_act(Housenbr, 1) / Cont.Yearnbr(Housenbr, 2);
                 else
                     Cont.Avg_Year(Housenbr, myiter + 1) = Cont.Sum_act(Housenbr, 1) / (Cont.Yearnbr(Housenbr, 2) - 1);
                end
            else
                Cont.Avg_Year(Housenbr, myiter + 1) = (Cont.Sum_act(Housenbr, 1) + Cont.Avg_Year(Housenbr, myiter)) / Cont.Yearnbr(Housenbr, 2);
            end
        else
            if Cont.Yearnbr(Housenbr, 2) <= 1
                Cont.Avg_Year(Housenbr, myiter + 1) = Cont.Avg_Year(Housenbr, myiter);
            else
                Cont.Avg_Year(Housenbr, myiter + 1) = Cont.Avg_Year(Housenbr, myiter);
            end
        end
        if ~(Cont.Timeyearnbr(Housenbr, 2) == Cont.Timeyearnbr(Housenbr, 1))
            if timehour == 0
                Cont.MeanYear(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1);
            else
                Cont.MeanYear(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.MeanYear(Housenbr, myiter);
            end
        else
            Cont.MeanYear(Housenbr, myiter + 1) = EnergyOuput.Cons_Appli_Overall(Housenbr, myiter + 1) + Cont.MeanYear(Housenbr, myiter);
        end
        if and(Cont.Avg_Year(Housenbr, myiter + 1) < Cont.MeanYear(Housenbr, myiter + 1), Cont.Avg_Year(Housenbr, myiter + 1) > 0) 
            Response_Self_year = 1;
        else
            Response_Self_year = 0;
        end 
    else
        Cont.Daily_Cons(Housenbr, myiter + 1) = 0;
        Cont.Weekly_Cons(Housenbr, myiter + 1) = 0;
        Cont.Avg_Month(Housenbr, myiter + 1) = 0;
        Response_Self_wkday = 0;
        Response_Self_week = 0;
        Response_Self_month = 0;
        Cont.Avg_Year(Housenbr, myiter + 1) = 0;
        Response_Self_year = 0;
    end
else
    Response_Self_wkday = 0;
    Response_Self_week = 0;
    Response_Self_month = 0;
    Response_Self_year = 0;
end
%% User Reponse
People_Response = [0.975, 0.950, 0.925, 0.900]';
Response = Response_Self_wkday + Response_Self_week + Response_Self_month + Response_Self_year;
if ~(Response == 0)
    Self_Response = People_Response(Response);
else
    Self_Response = 1;
end
%% Inter-Comparison, Historical Consumption
if and(Metering > 1, Comp == 1)
    if Cont.MeanMonth(Housenbr, myiter + 1) * 1.2 > Time_Sim.Comp_Cons(Housenbr,1)
        Self_Comp = 1;
    else
        Self_Comp = 0;
    end
else
    Self_Comp = 0;
end
%% Weekly Target Control system
if and(Metering > 1, Goal == 1)
    if timehour == 0
        Cont.Reference_1(Housenbr, myiter + 1) = 1 / stp;
        Cont.EnerCumDay(Housenbr, myiter + 1) = Cont.Sum_act(Housenbr, 2);
    else
        Cont.Reference_1(Housenbr, myiter + 1) = Cont.Reference_1(Housenbr, myiter) + 1 / stp;
        Cont.EnerCumDay(Housenbr, myiter + 1) = Cont.EnerCumDay(Housenbr, myiter) + Cont.Sum_act(Housenbr, 2);
    end
    Reference_Perc = Cont.Reference_1(Housenbr, myiter + 1) * (1.1 - Cont.Reference_1(Housenbr, myiter + 1) / 10);
    if myiter > stp * 6
        if Cont.Logical_Comp(Housenbr, myiter + 1 - (stp * 6)) == 1
            Perc_Setting = 0.950;
        else
            Perc_Setting = 0.975;
        end
        Multi = Perc_Setting * Cont.Mean_weekday(Housenbr, myiter + 1 - (stp * 6));
    else
        Multi = 0;
    end
    if Multi /  Cont.EnerCumDay(Housenbr, myiter + 1) <= Reference_Perc
        Cont.Logical_Comp(Housenbr, myiter + 1) = 1;
    else
        Cont.Logical_Comp(Housenbr, myiter + 1) = 0;
    end
    
    if Cont.Logical_Comp(Housenbr, myiter + 1) == 1
        Self_Target = 1;
    else
        Self_Target = 0.9;
    end
else
    Self_Target = 1;
end
%% High price definition
%%%
% In case the solution with the fix priceing is used or the ToU is used,
% the selection for the cheapest hour is chosen.
if ~(strcmp(ContElec,'Real-time pricing'))
    if EnergyOuput.Season == 1
        High_Price_List = [7.21, 7.36, 7.01]';
    else
        High_Price_List = [6.86, 7.01, 7.16]';
    end
    switch(ContElec)
        case 'Varmavirta'
            High_Price = High_Price_List(1);
        case 'Vihrevirta'
            High_Price = High_Price_List(2);    
        case 'Tuulivirta'
            High_Price = High_Price_List(3);
    end
else
    %%%
    % In case the dynamic pricing is used, the highest price on the range
    % of should be
    Timeoffset = Time_Sim.Timeoffset;
    Real_Price = All_Var.Hourly_Real_Time_Pricing   ;
    Timeoffset_Adj = Timeoffset - (datenum(Time_Sim.YearStartSim2004,1,1) - datenum(Time_Sim.YearStartSim,1,1)) * 24;
    if (Timeoffset_Adj + myiter + 1 - 8760) <= 0
        MedianSpot = 9.35112    ;
        Dev_Spot = 2.92661      ;
    else
        MedianSpot = median(Real_Price((Timeoffset_Adj + myiter + 1 - 8760):(Timeoffset_Adj + myiter + 1))) ;
        Dev_Spot = std(Real_Price((Timeoffset_Adj + myiter + 1 - 8760):(Timeoffset_Adj + myiter + 1))) ;
    end
    High_Price = MedianSpot + Dev_Spot ;
end
%% People Response vizualisation
Response_User = [0.3, 0.5, 0.7]';
if Self_Comp == 0
    Multi_Comp = 1;
else
    Multi_Comp = 0.9;
end
if or(Metering < 3,strcmp(ContElec,'Real-time pricing'))
    Multi_Price = 1;
else
    if EnergyOuput.Price >= High_Price
        Multi_Price = 0.9;
    else
        Multi_Price = 1;
    end
end
if Self_Target == 0
    Multi_Target = 1;
else
    Multi_Target = 0.9;
end

Final_Response_Temp = Response_User(User_Type) * Multi_Comp * Self_Response * Multi_Price * Multi_Target;
Cont.ResponseTot(Housenbr, myiter + 1) = Final_Response_Temp;
if Cont.Response_User_rand(Housenbr, myiter + 1) < Final_Response_Temp
    Final_Response = 0;
else
    Final_Response = 1;
end
%% Control by Price
Cont.timehour_delay(Housenbr, myiter + 1) = timehour;
Reducing_time_Matrix = [0.85, 0.90, 0.95]';
if Metering > 1
    %%%
    % Cheap price delay - Long Time delay
    if ~(strcmp(ContElec, 'Real time pricing'))
        switch Contracts
            case 'Fixed price'
                longdelay = 0;
            case 'Time of Use'
                if and(timehour >= 7, timehour < 22)
                    longdelay = Cont.Rand_Hour(Housenbr, myiter + 1) - timehour;
                else
                    longdelay = 0;
                end
        end
    else
        if timehour >= 18
            Rowhour = timehour + 1;
            if size(Forecast,1) <= 24
                EndLine = size(Forecast,1) ;
            else
                EndLine = Rowhour + 3 ;
            end
        else
            if size(Forecast,1) <= 24
                Rowhour = 1 ;
            else
                Rowhour = 25+timehour;
            end
            EndLine = Rowhour + 3 ;
        end
        %%%
        % Get the time where the price is the lower in the next 3
        % hours. This is used in case we are in the daytime. If an
        % action is to happen during the night, it is planned to look
        % at the all night period where the price is the cheapest.
        if and(timehour >= 7, timehour < 22)
            testlongedelay = find(Forecast(Rowhour:EndLine) == (min(Forecast(Rowhour:EndLine)))) - 1;
            longdelay = testlongedelay(1);
        else
            if timehour >= 22
                if size(Forecast,1) <= 24
                    timeleft = size(Forecast,1) - (timehour + 1) ;
                else
                    timeleft = 31 - timehour ;
                end
            else
                    timeleft = 7 - timehour;
            end
            testlongedelay = find(Forecast(Rowhour:Rowhour + timeleft) == (min(Forecast(Rowhour:Rowhour + timeleft)))) - 1;
            longdelay = testlongedelay(1);
        end
    end
    if Metering == 4
        Delay_time = longdelay                  ;
    else
        Delay_time = longdelay * Final_Response ;
    end
    %%%
    % 1 hour delay - Short Delay
    if 22 - timehour <= 1
        hour_1_delay = Final_Response * 1 / stepreal;
    else
        hour_1_delay = 0;
    end
    %%%
    % Reduce_time controller
    if Final_Response == 1
        Reduce_time = Reducing_time_Matrix(User_Type);
    else
        Reduce_time = 1;
    end
else
    Delay_time   = 0;
    hour_1_delay = 0;
    Reduce_time  = 1;
end
varargout{1} = Cont                 ;
