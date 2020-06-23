function [Powerinput, MaxNbrUse_Week, AverageTimeUse] = averagevalue(varargin)
Detail_Appliance = varargin{1} ; 
if nargin == 1
    Powerinput.WashMach.Remodece      = Detail_Appliance.WashMach.Power(1)  ;
    MaxNbrUse_Week.WashMach.Remodece  = Detail_Appliance.WashMach.MaxUse(4)  ; %6.4   ; % This is dependent on the number of inhabitants
    AverageTimeUse.WashMach.Remodece  = Detail_Appliance.WashMach.TimeUsage(3)  ; %0.75  ;

    Powerinput.DishWash.Remodece      = Detail_Appliance.DishWash.Power(1)  ; %0.929 ;
    MaxNbrUse_Week.DishWash.Remodece  = Detail_Appliance.DishWash.MaxUse(4)  ; %5.6   ; % This is dependent on the number of inhabitants
    AverageTimeUse.DishWash.Remodece  = Detail_Appliance.DishWash.TimeUsage(2)  ; %1  ;

    Powerinput.Elec.Remodece      = Detail_Appliance.Elec.Power(1)  ; %4 ;
    MaxNbrUse_Week.Elec.Remodece  = Detail_Appliance.Elec.MaxUse(4)  ; %5.6   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Elec.Remodece  = Detail_Appliance.Elec.TimeUsage(2)  ; %1/3  ;

    Powerinput.Kettle.Remodece      = Detail_Appliance.Kettle.Power(1)  ; %2 ;
    MaxNbrUse_Week.Kettle.Remodece  = Detail_Appliance.Kettle.MaxUse(4)  ; %20   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Kettle.Remodece  = Detail_Appliance.Kettle.TimeUsage(2)  ; %.1  ;

    Powerinput.Oven.Remodece      = Detail_Appliance.Oven.Power(1)  ; %4 ;
    MaxNbrUse_Week.Oven.Remodece  = Detail_Appliance.Oven.MaxUse(4)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Oven.Remodece  = Detail_Appliance.Oven.TimeUsage(1)  ; %0.5  ;

    Powerinput.MW.Remodece     = Detail_Appliance.MW.Power(1)  ; %0.950 ;
    MaxNbrUse_Week.MW.Remodece  = Detail_Appliance.MW.MaxUse(4)  ; %23    ; % This is dependent on the number of inhabitants
    AverageTimeUse.MW.Remodece  = Detail_Appliance.MW.TimeUsage(1)  ; %2.6/60   ;

    Powerinput.Coffee.Remodece      = Detail_Appliance.Coffee.Power(1)  ; %0.6 ;
    MaxNbrUse_Week.Coffee.Remodece  = Detail_Appliance.Coffee.MaxUse(4)  ; %20   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Coffee.Remodece  = Detail_Appliance.Coffee.TimeUsage(1)  ; %1  ;

    Powerinput.Toas.Remodece      = Detail_Appliance.Toas.Power(1)  ; %0.8 ;
    MaxNbrUse_Week.Toas.Remodece  = Detail_Appliance.Toas.MaxUse(4)  ; %7   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Toas.Remodece  = Detail_Appliance.Toas.TimeUsage(1)  ; %0.25  ;

    Powerinput.Waff.Remodece      = Detail_Appliance.Waff.Power(1)  ; %0.900 ;
    MaxNbrUse_Week.Waff.Remodece  = Detail_Appliance.Waff.MaxUse(4)  ; %1   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Waff.Remodece  = Detail_Appliance.Waff.TimeUsage(1)  ; %70 / 60  ;

    Powerinput.Fridge.Remodece      = Detail_Appliance.Fridge.Power(1)  ; %0.929 ;
    MaxNbrUse_Week.Fridge.Remodece  = Detail_Appliance.Fridge.MaxUse(4)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Fridge.Remodece  = Detail_Appliance.Fridge.TimeUsage(1)  ; %1  ;

    Powerinput.Radio.Remodece      = Detail_Appliance.Radio.Power(1)  ; %0.005 ;
    MaxNbrUse_Week.Radio.Remodece  = Detail_Appliance.Radio.MaxUse(4)  ; %21   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Radio.Remodece  = Detail_Appliance.Radio.TimeUsage(1)  ; %0.5  ;

    Powerinput.Laptop.Remodece      = Detail_Appliance.Laptop.Power(1)  ; %0.06 ;
    MaxNbrUse_Week.Laptop.Remodece  = Detail_Appliance.Laptop.MaxUse(4)  ; %20   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Laptop.Remodece  = Detail_Appliance.Laptop.TimeUsage(1)  ; %1  ;

    Powerinput.Elecheat.Remodece      = Detail_Appliance.Elecheat.Power(1)  ; %1.5 ;
    MaxNbrUse_Week.Elecheat.Remodece  = Detail_Appliance.Elecheat.MaxUse(4)  ; %7   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Elecheat.Remodece  = Detail_Appliance.Elecheat.TimeUsage(1)  ; %1/3  ;

    Powerinput.Shaver.Remodece      = Detail_Appliance.Shaver.Power(1)  ; %0.01 ;
    MaxNbrUse_Week.Shaver.Remodece  = Detail_Appliance.Shaver.MaxUse(4)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Shaver.Remodece  = Detail_Appliance.Shaver.TimeUsage(1)  ; %480/60  ;

    Powerinput.Hair.Remodece      = Detail_Appliance.Hair.Power(1)  ; %1 ;
    MaxNbrUse_Week.Hair.Remodece  = Detail_Appliance.Hair.MaxUse(4)  ; %10   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Hair.Remodece  = Detail_Appliance.Hair.TimeUsage(1)  ; %1/3  ;

    Powerinput.Tele.Remodece      = Detail_Appliance.Tele.Power(1)  ; %0.125 ;
    MaxNbrUse_Week.Tele.Remodece  = Detail_Appliance.Tele.MaxUse(4)  ; %32   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Tele.Remodece  = Detail_Appliance.Tele.TimeUsage(1)  ; %96/60  ;

    Powerinput.Stereo.Remodece      = Detail_Appliance.Stereo.Power(1)  ; %0.08 ;
    MaxNbrUse_Week.Stereo.Remodece = Detail_Appliance.Stereo.MaxUse(4)  ; %15   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Stereo.Remodece  = Detail_Appliance.Stereo.TimeUsage(2)  ; %2  ;

    Powerinput.Iron.Remodece      = Detail_Appliance.Iron.Power(1)  ; %1 ;
    MaxNbrUse_Week.Iron.Remodece  = Detail_Appliance.Iron.MaxUse(4)  ; %3   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Iron.Remodece  = Detail_Appliance.Iron.TimeUsage(2)  ; %7/6  ;

    Powerinput.Vacuum.Remodece      = Detail_Appliance.Vacuum.Power(1)  ; %.7 ;
    MaxNbrUse_Week.Vacuum.Remodece  = Detail_Appliance.Vacuum.MaxUse(4)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Vacuum.Remodece  = Detail_Appliance.Vacuum.TimeUsage(2)  ; %1  ;

    Powerinput.Charger.Remodece      = Detail_Appliance.Charger.Power(1)  ; %.01 ;
    MaxNbrUse_Week.Charger.Remodece  = Detail_Appliance.Charger.MaxUse(4)  ; % 22  ; % This is dependent on the number of inhabitants
    AverageTimeUse.Charger.Remodece  = Detail_Appliance.Charger.TimeUsage(2)  ; %30/6  ;

    Powerinput.Sauna.Remodece      = Detail_Appliance.Sauna.Power(1)  ; %6 ;
    MaxNbrUse_Week.Sauna.Remodece  = Detail_Appliance.Sauna.MaxUse(4)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Sauna.Remodece  = Detail_Appliance.Sauna.TimeUsage(2)  ; %2  ;
else
    inhabitants = varargin{2} ;
    
    Powerinput.WashMach      = Detail_Appliance.WashMach.Power(1)  ;
    MaxNbrUse_Week.WashMach  = Detail_Appliance.WashMach.MaxUse(4)  ; %6.4   ; % This is dependent on the number of inhabitants
    AverageTimeUse.WashMach  = Detail_Appliance.WashMach.TimeUsage(3)  ; %0.75  ;

    Powerinput.DishWash      = Detail_Appliance.DishWash.Power(1)  ; %0.929 ;
    MaxNbrUse_Week.DishWash  = Detail_Appliance.DishWash.MaxUse(inhabitants)  ; %5.6   ; % This is dependent on the number of inhabitants
    AverageTimeUse.DishWash  = Detail_Appliance.DishWash.TimeUsage(2)  ; %1  ;

    Powerinput.Elec      = Detail_Appliance.Elec.Power(1)  ; %4 ;
    MaxNbrUse_Week.Elec  = Detail_Appliance.Elec.MaxUse(inhabitants)  ; %5.6   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Elec  = Detail_Appliance.Elec.TimeUsage(2)  ; %1/3  ;

    Powerinput.Kettle      = Detail_Appliance.Kettle.Power(1)  ; %2 ;
    MaxNbrUse_Week.Kettle  = Detail_Appliance.Kettle.MaxUse(inhabitants)  ; %20   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Kettle  = Detail_Appliance.Kettle.TimeUsage(2)  ; %.1  ;

    Powerinput.Oven      = Detail_Appliance.Oven.Power(1)  ; %4 ;
    MaxNbrUse_Week.Oven  = Detail_Appliance.Oven.MaxUse(inhabitants)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Oven  = Detail_Appliance.Oven.TimeUsage(1)  ; %0.5  ;

    Powerinput.MW      = Detail_Appliance.MW.Power(1)  ; %0.950 ;
    MaxNbrUse_Week.MW  = Detail_Appliance.MW.MaxUse(inhabitants)  ; %23    ; % This is dependent on the number of inhabitants
    AverageTimeUse.MW  = Detail_Appliance.MW.TimeUsage(1)  ; %2.6/60   ;

    Powerinput.Coffee      = Detail_Appliance.Coffee.Power(1)  ; %0.6 ;
    MaxNbrUse_Week.Coffee  = Detail_Appliance.Coffee.MaxUse(inhabitants)  ; %20   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Coffee  = Detail_Appliance.Coffee.TimeUsage(1)  ; %1  ;

    Powerinput.Toas      = Detail_Appliance.Toas.Power(1)  ; %0.8 ;
    MaxNbrUse_Week.Toas  = Detail_Appliance.Toas.MaxUse(inhabitants)  ; %7   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Toas  = Detail_Appliance.Toas.TimeUsage(1)  ; %0.25  ;

    Powerinput.Waff      = Detail_Appliance.Waff.Power(1)  ; %0.900 ;
    MaxNbrUse_Week.Waff  = Detail_Appliance.Waff.MaxUse(inhabitants)  ; %1   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Waff  = Detail_Appliance.Waff.TimeUsage(1)  ; %70 / 60  ;

    Powerinput.Fridge      = Detail_Appliance.Fridge.Power(1)  ; %0.929 ;
    MaxNbrUse_Week.Fridge  = Detail_Appliance.Fridge.MaxUse(inhabitants)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Fridge  = Detail_Appliance.Fridge.TimeUsage(1)  ; %1  ;

    Powerinput.Radio      = Detail_Appliance.Radio.Power(1)  ; %0.005 ;
    MaxNbrUse_Week.Radio  = Detail_Appliance.Radio.MaxUse(inhabitants)  ; %21   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Radio  = Detail_Appliance.Radio.TimeUsage(1)  ; %0.5  ;

    Powerinput.Laptop      = Detail_Appliance.Laptop.Power(1)  ; %0.06 ;
    MaxNbrUse_Week.Laptop  = Detail_Appliance.Laptop.MaxUse(inhabitants)  ; %20   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Laptop  = Detail_Appliance.Laptop.TimeUsage(1)  ; %1  ;

    Powerinput.Elecheat      = Detail_Appliance.Elecheat.Power(1)  ; %1.5 ;
    MaxNbrUse_Week.Elecheat  = Detail_Appliance.Elecheat.MaxUse(inhabitants)  ; %7   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Elecheat  = Detail_Appliance.Elecheat.TimeUsage(1)  ; %1/3  ;

    Powerinput.Shaver      = Detail_Appliance.Shaver.Power(1)  ; %0.01 ;
    MaxNbrUse_Week.Shaver  = Detail_Appliance.Shaver.MaxUse(inhabitants)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Shaver  = Detail_Appliance.Shaver.TimeUsage(1)  ; %480/60  ;

    Powerinput.Hair      = Detail_Appliance.Hair.Power(1)  ; %1 ;
    MaxNbrUse_Week.Hair  = Detail_Appliance.Hair.MaxUse(inhabitants)  ; %10   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Hair  = Detail_Appliance.Hair.TimeUsage(1)  ; %1/3  ;

    Powerinput.Tele      = Detail_Appliance.Tele.Power(1)  ; %0.125 ;
    MaxNbrUse_Week.Tele  = Detail_Appliance.Tele.MaxUse(inhabitants)  ; %32   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Tele  = Detail_Appliance.Tele.TimeUsage(1)  ; %96/60  ;

    Powerinput.Stereo      = Detail_Appliance.Stereo.Power(1)  ; %0.08 ;
    MaxNbrUse_Week.Stereo  = Detail_Appliance.Stereo.MaxUse(inhabitants)  ; %15   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Stereo  = Detail_Appliance.Stereo.TimeUsage(2)  ; %2  ;

    Powerinput.Iron      = Detail_Appliance.Iron.Power(1)  ; %1 ;
    MaxNbrUse_Week.Iron  = Detail_Appliance.Iron.MaxUse(inhabitants)  ; %3   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Iron  = Detail_Appliance.Iron.TimeUsage(2)  ; %7/6  ;

    Powerinput.Vacuum      = Detail_Appliance.Vacuum.Power(1)  ; %.7 ;
    MaxNbrUse_Week.Vacuum  = Detail_Appliance.Vacuum.MaxUse(inhabitants)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Vacuum  = Detail_Appliance.Vacuum.TimeUsage(2)  ; %1  ;

    Powerinput.Charger      = Detail_Appliance.Charger.Power(1)  ; %.01 ;
    MaxNbrUse_Week.Charger  = Detail_Appliance.Charger.MaxUse(inhabitants)  ; % 22  ; % This is dependent on the number of inhabitants
    AverageTimeUse.Charger  = Detail_Appliance.Charger.TimeUsage(2)  ; %30/6  ;

    Powerinput.Sauna      = Detail_Appliance.Sauna.Power(1)  ; %6 ;
    MaxNbrUse_Week.Sauna  = Detail_Appliance.Sauna.MaxUse(inhabitants)  ; %2   ; % This is dependent on the number of inhabitants
    AverageTimeUse.Sauna  = Detail_Appliance.Sauna.TimeUsage(2)  ; %2  ;
end