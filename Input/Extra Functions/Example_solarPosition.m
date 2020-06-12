% The following examples show different uses of datetime and DST for
% Golden, Colorado.
lat = 65.0166667 ; % [arc-degrees] latitude
long = 25.4666667 ; % [arc-degrees] longitude

rot = 0; % [arc-degrees] rotation clockwise from north

[zd,~,~] = timezone(long,'degrees') ;
% TimeZoneStr = ['Etc/GMT',num2str(zd)] ;
% t = datetime(Time,'ConvertFrom','datenum','TimeZone',TimeZoneStr) ;
% targetDST = TimezoneConvert( t, t.TimeZone, 'UTC' ) ;
Time = now ;
TZ =  -(zd) ; % [hrs] offset from UTC, during standard time

% cell array of local date-times during DST
datetimes = {'11/29/2012 1:00 AM','11/29/2012 10:00 AM','11/29/2012 11:00 AM','11/29/2012 12:00 PM','11/29/2012 1:00 PM'} ; %{'3/31/2009 10:00 AM','3/31/2009 11:00 AM'};
DST = true; % local time is daylight savings time
% calculate solar position
a = solarPosition(datetimes,lat,long,TZ,rot,DST); % [arc-degrees]
% compare to NREL SOLPOS calculator http://www.nrel.gov/midc/solpos/
a_nrel = a;
for n = 1:size(a,1)
    dt_nrel = datevec(datetimes);dt_nrel(:,4) = dt_nrel(:,4)-DST;
    [a_nrel(n,:),~] = solpos([lat,long,TZ],dt_nrel,[1013,25]);
    night = a_nrel(:,1)>90;a_nrel(night,:) = NaN(sum(night),2);
end
fprintf('%-20s %-3s %-7s %-8s %-7s %-8s %-7s %-8s\n','date/time','DST', ...
    'Zenith','Azimuth','Ze_NREL','Az_NREL','Ze_Err %','Az_Err %')
fprintf('%-20s|%-3s|%-7s|%-8s|%-7s|%-8s|%-7s|%-8s|\n',repmat('-',1,20), ...
    '---','-------','--------','-------','--------','-------','--------')
for n = 1:size(a,1)
  fprintf('%20s %-3s %7.4f %8.4f %7.4f %8.4f %7.4f %8.4f\n',datetimes{n}, ...
      DST*'yes'+~DST*'no ',a(n,1),a(n,2),a_nrel(n,1),a_nrel(n,2), ...
      100*(a(n,1)-a_nrel(n,1))./a_nrel(n,1), ...
      100*(a(n,2)-a_nrel(n,2))./a_nrel(n,2))
end

fprintf('%-20s|%-3s|%-7s|%-8s|%-7s|%-8s|%-7s|%-8s|\n',repmat('-',1,20), ...
    '---','-------','--------','-------','--------','-------','--------')
fprintf('\n')

% array of standard date-times, DST removed
datetimes = [2009,3,31,9,0,0;2009,3,31,10,0,0];
DST = false; % daylight savings time has been removed
% calculate solar position
a = solarPosition(datetimes,lat,long,TZ,rot,DST); % [arc-degrees]
% compare to NREL SOLPOS calculator http://www.nrel.gov/midc/solpos/
a_nrel = a;
for n = 1:size(a,1)
    dt_nrel = datetimes(n,:);dt_nrel(:,4) = dt_nrel(:,4)-DST;
    [a_nrel(n,:),~] = solpos([lat,long,TZ],dt_nrel,[1013,25]);
    night = a_nrel(:,1)>90;a_nrel(night,:) = NaN(sum(night),2);
end

fprintf('%-20s %-3s %-7s %-8s %-7s %-8s %-7s %-8s\n','date/time','DST', ...
    'Zenith','Azimuth','Ze_NREL','Az_NREL','Ze_Err %','Az_Err %')
fprintf('%-20s|%-3s|%-7s|%-8s|%-7s|%-8s|%-7s|%-8s|\n',repmat('-',1,20), ...
    '---','-------','--------','-------','--------','-------','--------')
for n = 1:size(a,1)
  fprintf('%20s %-3s %7.4f %8.4f %7.4f %8.4f %7.4f %8.4f\n', ...
      datestr(datetimes(n,:)),DST*'yes'+~DST*'no ',a(n,1),a(n,2), ...
      a_nrel(n,1),a_nrel(n,2),100*(a(n,1)-a_nrel(n,1))./a_nrel(n,1), ...
      100*(a(n,2)-a_nrel(n,2))./a_nrel(n,2))
end
fprintf('%-20s|%-3s|%-7s|%-8s|%-7s|%-8s|%-7s|%-8s|\n',repmat('-',1,20), ...
    '---','-------','--------','-------','--------','-------','--------')
fprintf('\n')

% linear sequence of `datenum` for one day at hourly intervals
datetimes = linspace(datenum([2009,3,31]),datenum([2009,4,1]),25); % [days]
DST = false; % daylight savings time has been removed
% calculate solar position
a = solarPosition(datetimes,lat,long,TZ,rot,DST); % [arc-degrees]
% compare to NREL SOLPOS calculator http://www.nrel.gov/midc/solpos/
a_nrel = a;
for n = 1:size(a,1)
    dt_nrel = datevec(datetimes(n));dt_nrel(:,4) = dt_nrel(:,4)-DST;
    [a_nrel(n,:),~] = solpos([lat,long,TZ],dt_nrel,[1013,25]);
    night = a_nrel(:,1)>90;a_nrel(night,:) = NaN(sum(night),2);
end
ax = datefig.plotyy(datetimes,[a,a_nrel], ...
    datetimes,(a-a_nrel)./a_nrel*100);
title('Solar Position - 3/31/2009, Golden, CO [39.5\circ, -103.8\circ, -7.0]')
ylabel(ax(1),'angle [\circ]')
ylabel(ax(2),'rel. err. [%]')
legend('zenith','azimuth','ze_{NREL}','az_{NREL}','ze_{err}','az_{err}')