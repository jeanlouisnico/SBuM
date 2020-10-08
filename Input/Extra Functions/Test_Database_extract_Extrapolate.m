function [OutputArray, OutputArrayTimed, xq] = Test_Database_extract_Extrapolate(Array_In,ArrayStartYear,ResIni,ResFinal, SimulationStart, SimulationEnd, Replic, OutHeaders)

if size(Array_In,1)<size(Array_In,2)
    Array_In = Array_In';
end

Input.Data         = Array_In    ;
Input.StartYear    = ArrayStartYear         ;
Input.Res          = ResIni                  ;

switch Input.Res
    case 'Hourly'
        stpIn = 60 / 60 ;
    case '30 minutes'
        stpIn = 30 / 60 ;
    case '15 minutes'
        stpIn = 15 / 60 ;
    case '3 minutes'
        stpIn = 3 / 60 ;
    case '10s'
        stpIn = (1/6) / 60 ;
end

[xq, stpOut] = TimeArray(ResFinal, SimulationStart, SimulationEnd) ;

Time2Extract = min(size(Input.Data,1) - 1,((SimulationEnd - SimulationStart) + 1) * (24 / stpIn)) ;

Input.Offset = max(1,(SimulationStart - Input.StartYear) * (24 / stpIn)) ;

for ii = 1:size(Input.Data,2)
    Input.DataSim(:,ii) = Input.Data(Input.Offset:(Input.Offset + Time2Extract),ii);
end

x = (datetime(SimulationStart,'ConvertFrom','datenum'):seconds(3600*stpIn):datetime(SimulationEnd + 1,'ConvertFrom','datenum'))';
x.Format = 'dd/MM/yyyy HH:mm';
OutHeaders = [{'Time'} OutHeaders] ;

WeatherData = table(x,'VariableNames',OutHeaders(1)) ;

if size(WeatherData,1) > size(Input.DataSim,1)
    WeatherData = table(WeatherData.Time(1:size(Input.DataSim,1)),'VariableNames',OutHeaders(1)) ;
end
for ii = 1:size(Input.DataSim,2)
    WeatherData = [WeatherData table(Input.DataSim(:,ii),'VariableNames',OutHeaders(ii + 1))] ;
end
% plot(WeatherData.Time, WeatherData.SolarRadiation, 'o')

%  xq = (datetime(SimulationStart,'ConvertFrom','datenum'):seconds(ResFinalSecond):datetime(SimulationEnd + 1,'ConvertFrom','datenum'))';
OutputArray = zeros(size(xq,1),(length(OutHeaders)-1)) ;
 switch Replic
     case 'Interpolate'
         OutputArrayTimed = table(xq,'VariableNames',OutHeaders(1)) ;
         for ii = 1:(length(OutHeaders)-1)
            OutputArray(:,ii) = interp1(WeatherData.Time, WeatherData.(OutHeaders{ii + 1}), xq, 'linear') ;     
            OutputArrayTimed  = [OutputArrayTimed table(OutputArray(:,ii),'VariableNames',OutHeaders(ii + 1))] ;
         end 
     case 'Replicate'
         RepCount = stpIn / stpOut ;
         OutputArrayTimed = table(xq,'VariableNames',OutHeaders(1)) ;
         for ii = 1:(length(OutHeaders)-1)
            OutputArraytemp = repelem(WeatherData.(OutHeaders{ii + 1}), RepCount) ;
            OutputArray(:,ii) = OutputArraytemp(1:size(xq,1)) ;         
            OutputArrayTimed  = [OutputArrayTimed table(OutputArray(:,ii),'VariableNames',OutHeaders(ii + 1))] ;
         end 
     case 'None'
         OutputArray = zeros(size(WeatherData,1),(length(OutHeaders)-1)) ;
         for i = 2:length(OutHeaders)
            OutHeadersLabel = OutHeaders{i} ; 
            OutputArray(:,i)       = WeatherData.(OutHeadersLabel) ;
         end
         OutputArrayTimed  = WeatherData             ;
     otherwise
         OutputArrayTimed = table(xq,'VariableNames',OutHeaders(1)) ;
         for ii = 1:(length(OutHeaders)-1)
            OutputArray(:,ii) = interp1(WeatherData.Time, WeatherData.(OutHeaders{ii + 1}), xq, 'linear') ;         % 5 Methods, could select any of them   
            OutputArrayTimed  = [OutputArrayTimed table(OutputArray(:,ii),'VariableNames',OutHeaders(ii + 1))] ;
         end 
 end
 
 

% hold on
% plot(xq,OutputArray,'r')