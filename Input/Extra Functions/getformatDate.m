function [FromattingDateTime,FromattingDateStr] = getformatDate(tokenNames,usecase)
    if length(tokenNames.year) == 2
        FormatYear = 'yy' ;
    else
        FormatYear = 'yyyy' ;
    end
    if isnan(str2double(tokenNames.month))
        FormatMonth = 'MMM' ;
        FormatMonthDateStr = 'mmm' ;
    else
        FormatMonth = 'MM' ;
        FormatMonthDateStr = 'mm' ;
    end
    FormatDay = 'dd' ;
    
    FromattingDateTime = [FormatDay,usecase,FormatMonth,usecase,FormatYear] ;
    FromattingDateStr  = [FormatDay,usecase,FormatMonthDateStr,usecase,FormatYear] ;
end