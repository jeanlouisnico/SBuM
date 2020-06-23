function Qty = countApp(AppName, Houseinfo)

allApps = fieldnames(Houseinfo.Appliances) ;
Qty = 0 ;
for i = 1:length(allApps)
    if strcmp(Houseinfo.Appliances.(allApps{i}).SN, AppName)
        AppQty = Houseinfo.Appliances.(allApps{i}).Qty ;
        if isa(AppQty,'char')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'string')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'cell')
            AppQty = str2double(AppQty) ;
        end
        Qty = Qty + AppQty ;
    end
end