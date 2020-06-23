function houseprofile(App, Time_Sim)

House = 'House1' ;
stime = datetime(Time_Sim.StartDate.(House),'ConvertFrom','datenum')  ;
Appliance = fieldnames(App.Appliances_ConsStr) ;

for i=1:length(Appliance)
    AppName = Appliance{i} ;
    Appsignature = array2timetable(App.Appliances_ConsStr.(AppName).(House),'Timestep',seconds(Time_Sim.MinperIter * 60),'VariableNames',{'DataOutput'},'StartTime',stime) ;
    
end