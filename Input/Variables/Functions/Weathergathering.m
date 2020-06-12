function Weathergathering
clear all
datestart = datenum(2013,1,1) ;
dateend = datenum(2015,10,18) ;
TableRelease = 5;
n = 1;
TimeCol = 1;
TemperatureCol = 2 ;
WindSpeedCol = 9;

for date = datestart:dateend
    yearvar = year(date)   ;
    monthvar = month(date) ;
    dayvar = day(date) ;
    
    URL_Str = strcat('http://www.wunderground.com/history/airport/EFOU/',num2str(yearvar),'/',num2str(monthvar),'/',num2str(dayvar),'/DailyHistory.html?req_city=Oulu&req_state=&req_statename=Finland&reqdb.zip=00000&reqdb.magic=1&reqdb.wmo=02875') ;
    
    out_table  = getTableFromWeb_mod(URL_Str, TableRelease) ;
    if n == 1
        WeatherTable = out_table;
        Lastcol = size(WeatherTable,2);
        WeatherTable(2:size(out_table,1),Lastcol + 1) = {datestr(date)} ;
    else
        Lastrow = size(WeatherTable,1);
        WeatherTable((Lastrow + 1):((Lastrow + 1) + size(out_table,1) - 2),size(out_table,2)) = {0} ;
        %WeatherTable((Lastrow + 1):((Lastrow + 1) + size(out_table,1) - 2),1:size(out_table,2)) = out_table(2:end,1:size(out_table,2));
        
        for Colvar = 1:size(out_table,2)
            ReportValue = ColReport(out_table{1,Colvar},Colvar) ;
            if isnumeric(ReportValue)
                WeatherTable((Lastrow + 1):((Lastrow + 1) + size(out_table,1) - 2),ReportValue) = out_table(2:end,Colvar);
            else
                WeatherTable((Lastrow + 1):((Lastrow + 1) + size(out_table,1) - 2),Colvar) = {0};
            end
        end
        WeatherTable((Lastrow + 1):((Lastrow + 1) + size(out_table,1) - 2),Lastcol + 1) = {datestr(date)} ;
    end
    n = n+1 ;
end
xlswrite('WeatherTable2.xls',WeatherTable);

function ReportValue = ColReport(Colstr,Colvar)
  
        if strfind(Colstr,'Time') == 1
            ReportValue = 1 ;
        elseif strfind(Colstr,'Temp') == 1
            ReportValue = 2 ;
        elseif strfind(Colstr,'Windchill') == 1
            ReportValue = 3 ;    
        elseif strfind(Colstr,'Dew Point') == 1
            ReportValue = 4 ;
        elseif strfind(Colstr,'Humidity') == 1
            ReportValue = 5 ;
        elseif strfind(Colstr,'Pressure') == 1      
            ReportValue = 6 ;
        elseif strfind(Colstr,'Visibility') == 1    
            ReportValue = 7 ;
        elseif strfind(Colstr,'Wind Dir') == 1
            ReportValue = 8 ;
        elseif strfind(Colstr,'Wind Speed') == 1
            ReportValue = 9 ;
        elseif strfind(Colstr,'Gust Speed') == 1
            ReportValue = 10 ;
        elseif strfind(Colstr,'Precip') == 1  
            ReportValue = 11 ;
        elseif strfind(Colstr,'Events') == 1
            ReportValue = 12 ;
        elseif strfind(Colstr,'Conditions') == 1
            ReportValue = 13 ;
        else
            ReportValue = '-' ;
        end

end
end