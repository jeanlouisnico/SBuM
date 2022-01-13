function EmissionsArray=emiCalc(AppOut, HouseInfo, All_Var, Cons_Tot)

Emissions = All_Var.Hourly_EmissionsTimed ;
Emissions = table2timetable(Emissions) ;
% Double looping through each appliance and then through the amount of
% appliances under it

SDate = datetime(datenum(datetime(HouseInfo.StartingDate,'InputFormat','dd/MM/yyyy')),'ConvertFrom','datenum') ;
EDate = datetime(datenum(datetime(HouseInfo.EndingDate,'InputFormat','dd/MM/yyyy')),'ConvertFrom','datenum') + hours(25);

S = timerange(SDate,EDate) ;

Emissionextract = Emissions(S,:);
xq = Emissionextract.Time;

Apps = fieldnames(AppOut.(HouseInfo.Headers).Appliances_ConsStr) ;
EmissionsIndic = Emissionextract.Properties.VariableNames ;

for iEmi = 1:length(EmissionsIndic)
    % Loop for each App and then calculate the total emissions
    for iApp = 1:length(Apps)
        Appsname = Apps{iApp} ;
        % Extract the consumption per appliance and get the emissions for
        % all emissions type.
        for iqtyApp = 1:size(AppOut.(HouseInfo.Headers).Appliances_ConsStr.(Appsname), 2)
            EmissionsArrayfact  = Emissionextract.(EmissionsIndic{iEmi}) ;
            ElecApp             = AppOut.(HouseInfo.Headers).Appliances_ConsStr.(Appsname)(iqtyApp).(HouseInfo.Headers) ;
            
            if ~isempty(ElecApp)
                EmissionsCalc = ElecApp .* EmissionsArrayfact ;
                tableout = table(xq,EmissionsCalc,'VariableNames',{'Time','DataOutput'}) ;
                EmissionsArray.Appliances.(Appsname)(iqtyApp).(EmissionsIndic{iEmi}) =  table2timetable(tableout) ;
            end            
            
        end
    end
    
    % Calculate the emissions for ConsTot
    ElecApp = Cons_Tot.(HouseInfo.Headers).DataOutput ;
    EmissionsCalc = ElecApp .* EmissionsArrayfact ;
    tableout = table(xq,EmissionsCalc,'VariableNames',{'Time','DataOutput'}) ;
    EmissionsArray.Cons_Tot.(EmissionsIndic{iEmi}) = table2timetable(tableout) ;
end
