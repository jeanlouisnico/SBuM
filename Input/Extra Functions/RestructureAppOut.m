function App = RestructureAppOut(AppOut)

HouseList = fieldnames(AppOut) ;

for i = 1:length(HouseList)
    Housetag = HouseList{i} ;
    App.Metering_ConsStr.(Housetag) = AppOut.(Housetag).Metering_ConsStr.(Housetag) ;
    
    AllAppliances = fieldnames(AppOut.(Housetag).Info) ;
    
    for ik = 1:length(AllAppliances)
        AppName = AllAppliances{ik} ;
        if strcmp(AppName,'Charger')
            x=1;
        end
        subapp = size(AppOut.(Housetag).Info.(AppName),2) ;
        for isubapp = 1:subapp
            try
                App.Info.(AppName)(isubapp).(Housetag) = AppOut.(Housetag).Info.(AppName)(isubapp).(Housetag) ;
            catch
                App.Info.(AppName)(isubapp).(Housetag) = [] ;
            end
            try
                App.OutputSignal10s.(AppName)(isubapp).(Housetag) = AppOut.(Housetag).OutputSignal10s.(AppName)(isubapp).(Housetag) ;
            catch
                App.OutputSignal10s.(AppName)(isubapp).(Housetag) = [] ;
            end
            try
                App.Appliances_ConsStr.(AppName)(isubapp).(Housetag) = AppOut.(Housetag).Appliances_ConsStr.(AppName)(isubapp).(Housetag) ;
            catch
                App.Appliances_ConsStr.(AppName)(isubapp).(Housetag) = [] ; 
            end
        end
    end
end