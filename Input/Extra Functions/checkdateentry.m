%% checkdateentry
function [Outputdatstr,Outputdate] = checkdateentry(hObject)

if isobject(hObject)
    user_entry = get(hObject,'string');
elseif ischar(hObject)
    user_entry = hObject ;
elseif isnumeric(hObject)
    user_entry = datestr(hObject,'dd/mm/yyyy') ;
end
monthsFullName = {'January', 'February', 'March', 'April', 'May', 'June', ...
  'July', 'August', 'September', 'October', 'November', 'December'};

if isempty(user_entry)
    Outputdate = datenum(now) ;
    Formatout = 'dd/mm/yyyy' ;
    Outputdatstr = datestr(Outputdate,Formatout) ;
    return
end
usecase = dateseparator(user_entry) ;

if usecase == -1
    return
end

user_entrysplit = strsplit(user_entry,usecase) ;

if numel(user_entrysplit) == 3
    tokenNames.year  = user_entrysplit{3} ;
    tokenNames.month = user_entrysplit{2} ;
    tokenNames.day   = user_entrysplit{1} ;
else 
    errordlg('Invalid Input Format. Date must include day, month, and year','Error Message','modal')
    if isobject(hObject)
        uicontrol(hObject) ;
    end
    Outputdate = datenum(2012,1,1) ;
    Formatout = ['dd',usecase,'mm',usecase,'yyyy'] ;
    Outputdatstr = datestr(Outputdate,Formatout) ;
    return
end

[~,FormatoutDS] = getformatDate(tokenNames,usecase) ;

% Check the year entry
if length(tokenNames.year) == 2
    % Year entry is a 2 number digit. As of now, if nothing is specified
    % anydate below 60 is considered as 2060 and any number higher than 60
    % are considered to be from 1961
    if str2double(tokenNames.year) > 60
        Yearin = ['19',tokenNames.year] ;
    else
        Yearin = ['20',tokenNames.year] ;
    end
    Yearin = str2double(Yearin) ;
elseif length(tokenNames.year) == 4
    Yearin = str2double(tokenNames.year) ;
else
    errordlg('Invalid Input Format for years (YY or YYYY)','Error Message','modal')
    if isobject(hObject)
        uicontrol(hObject) ;
    end
    Outputdate = datenum(2012,1,1) ;
    Outputdatstr = datestr(Outputdate,FormatoutDS) ;
    return
end

% Check the Month entry
if isnan(str2double(tokenNames.month))
    % This means that the input is a string
    try
        date2check = ['2012-',tokenNames.month,'-01'] ;
        dateentry = datetime(date2check,'InputFormat','yyyy-MMM-dd') ;
    catch
        errordlg('Invalid Input Format for month (either use abbreviated month in English e.g. Jan Feb... or express month as numbers)','Error Message','modal')
        if isobject(hObject)
            uicontrol(hObject) ;
        end
        Outputdate = datenum(Yearin,1,1) ;
        Outputdatstr = datestr(Outputdate,FormatoutDS) ;
        return
    end
    Monthin = month(dateentry) ;
else
    % Entry is a number
    if str2double(tokenNames.month) < 1 || str2double(tokenNames.month) > 12
        errordlg('Invalid Input Format for month. Month must be greater than 0 and smaller than 12.','Error Message','modal')
        if isobject(hObject)
            uicontrol(hObject) ;
        end
        Outputdate = datenum(Yearin,1,1) ;
        Outputdatstr = datestr(Outputdate,FormatoutDS) ;
        return
    end
    Monthin = str2double(tokenNames.month) ;
    
end

% Check the Day Entry
if isnan(str2double(tokenNames.day))
    % This means that the input is a string
    errordlg('Invalid Input Format for day (express days as numbers e.g. 01 or 1)','Error Message','modal')
    if isobject(hObject)
        uicontrol(hObject) ;
    end
    return
else
    % Entry is a number
    MaxDayMonth = eomday(Yearin,Monthin) ;
    if str2double(tokenNames.day) < 1 || str2double(tokenNames.day) > MaxDayMonth
        if str2double(tokenNames.day) < 1
            Outputdate = datenum(Yearin,Monthin,1) ;
            Outputdatstr = datestr(Outputdate,FormatoutDS) ;
            errordlg('Invalid Input Format for day. Day must be greater than 0','Error Message','modal')
        elseif str2double(tokenNames.day) > MaxDayMonth
            Outputdate = datenum(Yearin,Monthin,MaxDayMonth) ;
            Outputdatstr = datestr(Outputdate,FormatoutDS) ;
            Message = ['There was a maximum of ',num2str(MaxDayMonth),' days in ',monthsFullName{Monthin},' ',num2str(Yearin)];
            errordlg(Message,'Error Message','modal')
        end
        if isobject(hObject)
            uicontrol(hObject) ;
        end
        return
    end
    Dayin = str2double(tokenNames.day) ;
end

% Return the proper date as date format
Outputdate = datenum(Yearin,Monthin,Dayin) ;
Outputdatstr = datestr(Outputdate,FormatoutDS) ;
end

