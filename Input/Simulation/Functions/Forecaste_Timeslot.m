function [varargout] = Forecaste_Timeslot(Time_Sim, offset, Input_Data)

myiter2 = Time_Sim.myiter + offset ;

Timeconsidered = Time_Sim.StartDate.(Input_Data.Headers)(1) + myiter2/Time_Sim.stp ;
TimeconsideredStr = datetime(Timeconsidered,'ConvertFrom','datenum') ;
timemonth2     = TimeconsideredStr.Month ;
timeweekday2   = myweekday(Timeconsidered);
Minute         = TimeconsideredStr.Minute ;
Hour           = TimeconsideredStr.Hour  ;
Seconds        = TimeconsideredStr.Second ;
timehour2      = Hour + (Minute / 60) + (Seconds / 3600)                               ;

if or(timemonth2 < 4, timemonth2 >= 11)
    %%%
    % Winter
    varargout{1} = 1;
else
    %%%
    % Summer
    varargout{1} = 0;
end
%%%
% Two zones for the type of day is defined: weekday (Mon-Fr) and weekends
% (Sat- Sun). If the time is a weekday, the variable _*varweekday*_ take
% the value 1, otherwise 0.
if timeweekday2 <=5
    %%%
    % Weekday
    varargout{2} = 1;
else
    %%%
    % Weekend
    varargout{2} = 0;
end
%%%
% Similarly, two zones are defined within a day. The first zone is defined
% between 22 to 7, and the second zone occur during daytime from 7 to 22.
% In the first case, the variable _*varhour*_ take the value 1, otherwise
% 0.
if or(timehour2 < 7, timehour2 >= 22)
    %%%
    % Night
    varargout{3} = 1;
else
    %%%
    % Day
    varargout{3} = 0;
end
