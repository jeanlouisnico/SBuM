function n = weeknum(d,w,e)
%WEEKNUM Day of week.
%   N = WEEKNUM(D) returns the week of the year given D, a serial date 
%   number or a date string. 
% 
%   N = WEEKNUM(D,W) returns the week of the year given D, a serial date 
%   number or a date string, and W, a numeric representation of the day a 
%   week begins.  The week start values and their corresponding day are:
%
%                       1     Sun   (default)
%                       2     Mon
%                       3     Tue
%                       4     Wed
%                       5     Thu
%                       6     Fri
%                       7     Sat

%   See also DATENUM, DATEVEC, WEEKDAY.
 
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/29 16:33:00 $

%Default input values
%Do not use European standard
if nargin < 3
  e = 0;
end

%If not input or empty, week starts on Sunday
if nargin < 2
  w = 1;
end
if ~exist('w','var')
  w = 1;
end

%Convert date to datenum if necessary
if ~isnumeric(d)
    try
        d = datenum(d); 
    catch exception
       throw(MException('MATLAB:weeknum:ConvertDateString', '%s', exception.message));
    end
end

%Get year value from each date
yrs = year(d);

%Get date number of first day of year
dFirst = datenum(yrs,1,1);

%Get weekday number of each date, offset by given week start day
nDay = mod(fix(dFirst)-2,7)-(w-1);

%Get date number relative to days in year of entered date
n = fix((d - dFirst + nDay)./7)+1;

%European standard considers first week of year to be first week longer
%than 3 days, offset by given week start day
if e
  i = (nDay > 4 + w);
  n(i) = n(i)-1;
end
