function addmatfile(newpath,IDhouse)


newname = strcat(newpath,'/VariableHouseSim',IDhouse,'.mat');
actionbed1charger = 0;
actionbed1lap = 0;
actionbed1rad = 0;
actionbed1ster = 0;
actioncoff = 0;
actiondish = 0;
actionhair = 0;
actionhobs = 0;
actioniron = 0;
actionkett = 0;
actionmicrowave = 0;
actionoven = 0;
actionsaun = 0;
actionshav = 0;
actionster = 0;
actiontoas = 0;
actiontv = 0;
actionwaff = 0;
actionwash = 0;
Activity_tot_bed1charger = 0;
Activity_tot_bed1lap = 0;
Activity_tot_bed1rad = 0;
Activity_tot_bed1ster = 0;
Activity_tot_coff = 0;
Activity_tot_dish = 0;
Activity_tot_hair = 0;
Activity_tot_hobs = 0;
Activity_tot_iron = 0;
Activity_tot_kett = 0;
Activity_tot_microwave = 0;
Activity_tot_oven = 0;
Activity_tot_saun = 0;
Activity_tot_shav = 0;
Activity_tot_ster = 0;
Activity_tot_toas = 0;
Activity_tot_tv = 0;
Activity_tot_waff = 0;
Activity_tot_wash = 0;
Avg_Month = 0;
Avg_Year = 0;
bed1charger_rand = 0;
bed1charger_rand_act = 0;
bed1charger_time = 0;
bed1lap_rand = 0;
bed1lap_rand_act = 0;
bed1lap_time = 0;
bed1rad_rand = 0;
bed1rad_rand_act = 0;
bed1rad_time = 0;
bed1ster_rand = 0;
bed1ster_rand_act = 0;
bed1ster_time = 0;
coff_rand = 0;
coff_rand_act = 0;
coff_time = 0;
Comp_Cons = 0;
comparison = 0;
Cons_Appli_Overall = 0;
Controller1 = 0;
Controller2 = 0;
currentday = 0;
currentweek = 0;
Daily_Cons = 0;
daynbrCNT = 0;
daynbrCNT_bed1charger = 0;
daynbrCNT_bed1lap = 0;
daynbrCNT_bed1rad = 0;
daynbrCNT_bed1ster = 0;
daynbrCNT_coff = 0;
daynbrCNT_dish = 0;
daynbrCNT_hair = 0;
daynbrCNT_hobs = 0;
daynbrCNT_iron = 0;
daynbrCNT_kett = 0;
daynbrCNT_microwave = 0;
daynbrCNT_oven = 0;
daynbrCNT_saun = 0;
daynbrCNT_shav = 0;
daynbrCNT_ster = 0;
daynbrCNT_toas = 0;
daynbrCNT_tv = 0;
daynbrCNT_waff = 0;
daynbrCNT_wash = 0;
delay_out_comp = 0;
Delay_time = 0;
delay_time_dish = 0;
delay_time_saun = 0;
delay_time_wash = 0;
Dish_rand = 0;
Dish_rand_act = 0;
dish_time = 0;
ElecPower = 0;
EndDate = 0;
Entire_simulation_bed1charger = 0;
Entire_simulation_bed1lap = 0;
Entire_simulation_bed1rad = 0;
Entire_simulation_bed1ster = 0;
Entire_simulation_coff = 0;
Entire_simulation_dish = 0;
Entire_simulation_hair = 0;
Entire_simulation_hobs = 0;
Entire_simulation_iron = 0;
Entire_simulation_kett = 0;
Entire_simulation_microwave = 0;
Entire_simulation_oven = 0;
Entire_simulation_saun = 0;
Entire_simulation_shav = 0;
Entire_simulation_ster = 0;
Entire_simulation_toas = 0;
Entire_simulation_tv = 0;
Entire_simulation_waff = 0;
Entire_simulation_wash = 0;
F = 0;
FCPower = 0;
Forecast = 0;
Forecasted_Price = 0;
hair_rand = 0;
hair_rand_act = 0;
hair_time = 0;
hobs_rand = 0;
hobs_rand_act = 0;
hobs_time = 0;
hour_1_delay = 0;
iron_rand = 0;
iron_rand_act = 0;
iron_time = 0;
iter = 0;
iter2 = 0;
iter3 = 0;
iter4 = 0;
iter5 = 0;
iter6 = 0;
iter7 = 0;
kett_rand = 0;
kett_rand_act = 0;
kett_time = 0;
lasthour = 0;
lastminute = 0;
lasttime = 0;
Light_rand = 0;
Logical_Comp = 0;
Mean_Week = 0;
Mean_weekday = 0;
MeanMonth = 0;
MeanYear = 0;
Mem_Dish_action = 0;
Mem_Dish_action2 = 0;
Mem_saun_action = 0;
Mem_saun_action2 = 0;
Mem_wash_action = 0;
Mem_wash_action2 = 0;
microwave_rand = 0;
microwave_rand_act = 0;
microwave_time = 0;
Monthnbr = 0;
N = 0;
N1 = 0;
nbrstep = 0;
Nbruse_bed1charger = 0;
Nbruse_bed1lap = 0;
Nbruse_bed1rad = 0;
Nbruse_bed1ster = 0;
Nbruse_coff = 0;
Nbruse_dish = 0;
Nbruse_hair = 0;
Nbruse_hobs = 0;
Nbruse_iron = 0;
Nbruse_kett = 0;
Nbruse_microwave = 0;
Nbruse_oven = 0;
Nbruse_saun = 0;
Nbruse_shav = 0;
Nbruse_ster = 0;
Nbruse_toas = 0;
Nbruse_tv = 0;
Nbruse_waff = 0;
Nbruse_wash = 0;
Nbrusesumtotal_bed1charger = 0;
Nbrusesumtotal_bed1lap = 0;
Nbrusesumtotal_bed1rad = 0;
Nbrusesumtotal_bed1ster = 0;
Nbrusesumtotal_coff = 0;
Nbrusesumtotal_dish = 0;
Nbrusesumtotal_hair = 0;
Nbrusesumtotal_hobs = 0;
Nbrusesumtotal_iron = 0;
Nbrusesumtotal_kett = 0;
Nbrusesumtotal_microwave = 0;
Nbrusesumtotal_oven = 0;
Nbrusesumtotal_saun = 0;
Nbrusesumtotal_shav = 0;
Nbrusesumtotal_ster = 0;
Nbrusesumtotal_toas = 0;
Nbrusesumtotal_tv = 0;
Nbrusesumtotal_waff = 0;
Nbrusesumtotal_wash = 0;
Nbrusetotal_bed1charger = 0;
Nbrusetotal_bed1lap = 0;
Nbrusetotal_bed1rad = 0;
Nbrusetotal_bed1ster = 0;
Nbrusetotal_coff = 0;
Nbrusetotal_dish = 0;
Nbrusetotal_hair = 0;
Nbrusetotal_hobs = 0;
Nbrusetotal_iron = 0;
Nbrusetotal_kett = 0;
Nbrusetotal_microwave = 0;
Nbrusetotal_oven = 0;
Nbrusetotal_saun = 0;
Nbrusetotal_shav = 0;
Nbrusetotal_ster = 0;
Nbrusetotal_toas = 0;
Nbrusetotal_tv = 0;
Nbrusetotal_waff = 0;
Nbrusetotal_wash = 0;
Occupancy = 0;
output_comparison = 0;
oven_rand = 0;
oven_rand_act = 0;
oven_time = 0;
Power_Bed1Charger = 0;
Power_Bed1Lap = 0;
Power_Bed1Rad = 0;
Power_Bed1Ster = 0;
Price = 0;
PVPower = 0;
Rand_Hour = 0;
Real_Price = 0;
Reduce_time = 0;
Reference_1 = 0;
refrnd_bed1charger = 0;
refrnd_bed1lap = 0;
refrnd_bed1rad = 0;
refrnd_bed1ster = 0;
refrnd_coff = 0;
refrnd_dish = 0;
refrnd_hair = 0;
refrnd_hobs = 0;
refrnd_iron = 0;
refrnd_kett = 0;
refrnd_microwave = 0;
refrnd_oven = 0;
refrnd_saun = 0;
refrnd_shav = 0;
refrnd_ster = 0;
refrnd_toas = 0;
refrnd_tv = 0;
refrnd_waff = 0;
refrnd_wash = 0;
refrndday_bed1charger = 0;
refrndday_bed1lap = 0;
refrndday_bed1rad = 0;
refrndday_bed1ster = 0;
refrndday_coff = 0;
refrndday_dish = 0;
refrndday_hair = 0;
refrndday_hobs = 0;
refrndday_iron = 0;
refrndday_kett = 0;
refrndday_microwave = 0;
refrndday_oven = 0;
refrndday_saun = 0;
refrndday_shav = 0;
refrndday_ster = 0;
refrndday_toas = 0;
refrndday_tv = 0;
refrndday_waff = 0;
refrndday_wash = 0;
Response_User_rand = 0;
saun_rand = 0;
saun_rand_act = 0;
saun_time = 0;
Season = 0;
shav_rand = 0;
shav_rand_act = 0;
shav_time = 0;
Sixmtheq = 0;
Sol = 0;
SolarLuminance = 0;
StartDate = 0;
stepreal = 0;
ster_rand = 0;
ster_rand_act = 0;
ster_time = 0;
stp = 0;
Sum_act = 0;
Temp = 0;
Thermal_Demand = 0;
Three_hours = 0;
timeaction_bed1charger = 0;
timeaction_bed1lap = 0;
timeaction_bed1rad = 0;
timeaction_bed1ster = 0;
timeaction_coff = 0;
timeaction_dish = 0;
timeaction_dish2 = 0;
timeaction_hair = 0;
timeaction_hobs = 0;
timeaction_iron = 0;
timeaction_kett = 0;
timeaction_microwave = 0;
timeaction_oven = 0;
timeaction_saun = 0;
timeaction_shav = 0;
timeaction_ster = 0;
timeaction_toas = 0;
timeaction_tv = 0;
timeaction_waff = 0;
timeaction_wash = 0;
timeactiontot_bed1charger = 0;
timeactiontot_bed1lap = 0;
timeactiontot_bed1rad = 0;
timeactiontot_bed1ster = 0;
timeactiontot_coff = 0;
timeactiontot_dish = 0;
timeactiontot_hair = 0;
timeactiontot_hobs = 0;
timeactiontot_iron = 0;
timeactiontot_kett = 0;
timeactiontot_microwave = 0;
timeactiontot_oven = 0;
timeactiontot_saun = 0;
timeactiontot_shav = 0;
timeactiontot_ster = 0;
timeactiontot_toas = 0;
timeactiontot_tv = 0;
timeactiontot_waff = 0;
timeactiontot_wash = 0;
timedaynbrN = 0;
timehour_delay = 0;
Timemonthnbr = 0;
Timeyearnbr = 0;
toas_rand = 0;
toas_rand_act = 0;
toas_time = 0;
tv_rand = 0;
tv_rand_act = 0;
tv_time = 0;
Vec_Mean_Act_Week_bed1charger = 0;
Vec_Mean_Act_Week_bed1lap = 0;
Vec_Mean_Act_Week_bed1rad = 0;
Vec_Mean_Act_Week_bed1ster = 0;
Vec_Mean_Act_Week_coff = 0;
Vec_Mean_Act_Week_hair = 0;
Vec_Mean_Act_Week_iron = 0;
Vec_Mean_Act_Week_kett = 0;
Vec_Mean_Act_Week_microwave = 0;
Vec_Mean_Act_Week_saun = 0;
Vec_Mean_Act_Week_shav = 0;
Vec_Mean_Act_Week_ster = 0;
Vec_Mean_Act_Week_toas = 0;
Vec_Mean_Act_Week_tv = 0;
waff_rand = 0;
waff_rand_act = 0;
waff_time = 0;
wash_rand = 0;
wash_rand_act = 0;
wash_time = 0;
Weekly_Cons = 0;
wkdaycst_temp_bed1charger = 0;
wkdaycst_temp_bed1lap = 0;
wkdaycst_temp_bed1rad = 0;
wkdaycst_temp_bed1ster = 0;
wkdaycst_temp_coff = 0;
wkdaycst_temp_hair = 0;
wkdaycst_temp_iron = 0;
wkdaycst_temp_kett = 0;
wkdaycst_temp_microwave = 0;
wkdaycst_temp_saun = 0;
wkdaycst_temp_shav = 0;
wkdaycst_temp_ster = 0;
wkdaycst_temp_toas = 0;
wkdaycst_temp_tv = 0;
wkendcst_temp_bed1charger = 0;
wkendcst_temp_bed1lap = 0;
wkendcst_temp_bed1rad = 0;
wkendcst_temp_bed1ster = 0;
wkendcst_temp_coff = 0;
wkendcst_temp_hair = 0;
wkendcst_temp_iron = 0;
wkendcst_temp_kett = 0;
wkendcst_temp_microwave = 0;
wkendcst_temp_saun = 0;
wkendcst_temp_shav = 0;
wkendcst_temp_ster = 0;
wkendcst_temp_toas = 0;
wkendcst_temp_tv = 0;
wknbrCNT = 0;
wkNbrCNT_bed1charger = 0;
wkNbrCNT_bed1lap = 0;
wkNbrCNT_bed1rad = 0;
wkNbrCNT_bed1ster = 0;
wkNbrCNT_coff = 0;
wkNbrCNT_dish = 0;
wkNbrCNT_hair = 0;
wkNbrCNT_hobs = 0;
wkNbrCNT_iron = 0;
wkNbrCNT_kett = 0;
wkNbrCNT_microwave = 0;
wkNbrCNT_oven = 0;
wkNbrCNT_saun = 0;
wkNbrCNT_shav = 0;
wkNbrCNT_ster = 0;
wkNbrCNT_toas = 0;
wkNbrCNT_tv = 0;
wkNbrCNT_waff = 0;
wkNbrCNT_wash = 0;
WTPower = 0;
xxx_dish = 0;
xxx_wash = 0;
Yearnbr = 0;
yyy_dish = 0;
yyy_wash = 0;
zzz_dish = 0;
zzz_wash = 0;

save(newname,'actionbed1charger','actionbed1rad','actionbed1ster','actioncoff','actiondish','actionhair','actionhobs','actioniron','actionkett','actionmicrowave','actionoven','actionsaun','actionshav','actionster','actiontoas','actiontv','actionwaff','actionwash','Activity_tot_bed1charger','Activity_tot_bed1lap','Activity_tot_bed1rad','Activity_tot_bed1ster','Activity_tot_coff','Activity_tot_dish','Activity_tot_hair','Activity_tot_hobs','Activity_tot_iron','Activity_tot_kett','Activity_tot_microwave','Activity_tot_oven','Activity_tot_saun','Activity_tot_shav','Activity_tot_ster','Activity_tot_toas','Activity_tot_tv','Activity_tot_waff','Activity_tot_wash','Avg_Month','Avg_Year','bed1charger_rand','bed1charger_rand_act','bed1charger_time','bed1lap_rand','bed1lap_rand_act','bed1lap_time','bed1rad_rand','bed1rad_rand_act','bed1rad_time','bed1ster_rand','bed1ster_rand_act','bed1ster_time','coff_rand','coff_rand_act','coff_time','Comp_Cons','comparison','Cons_Appli_Overall','Controller1','Controller2','currentday','currentweek','Daily_Cons','daynbrCNT','daynbrCNT_bed1charger','daynbrCNT_bed1lap','daynbrCNT_bed1rad','daynbrCNT_bed1ster','daynbrCNT_coff','daynbrCNT_dish','daynbrCNT_hair','daynbrCNT_hobs','daynbrCNT_iron','daynbrCNT_kett','daynbrCNT_microwave','daynbrCNT_oven','daynbrCNT_saun','daynbrCNT_shav','daynbrCNT_ster','daynbrCNT_toas','daynbrCNT_tv','daynbrCNT_waff','daynbrCNT_wash','delay_out_comp','Delay_time','delay_time_dish','delay_time_saun','delay_time_wash','Dish_rand','Dish_rand_act','dish_time','ElecPower','EndDate','Entire_simulation_bed1charger','Entire_simulation_bed1lap','Entire_simulation_bed1rad','Entire_simulation_bed1ster','Entire_simulation_coff','Entire_simulation_dish','Entire_simulation_hair','Entire_simulation_hobs','Entire_simulation_iron','Entire_simulation_kett','Entire_simulation_microwave','Entire_simulation_oven','Entire_simulation_saun','Entire_simulation_shav','Entire_simulation_ster','Entire_simulation_toas','Entire_simulation_tv','Entire_simulation_waff','Entire_simulation_wash','F','FCPower','Forecast','Forecasted_Price','hair_rand','hair_rand_act','hair_time','hobs_rand','hobs_rand_act','hobs_time','hour_1_delay','iron_rand','iron_rand_act','iron_time','iter','iter2','iter3','iter4','iter5','iter6','iter7','kett_rand','kett_rand_act','kett_time','lasthour','lastminute','lasttime','Light_rand','Logical_Comp','Mean_Week','Mean_weekday','MeanMonth','MeanYear','Mem_Dish_action','Mem_Dish_action2','Mem_saun_action','Mem_saun_action2','Mem_wash_action','Mem_wash_action2','microwave_rand','microwave_rand_act','microwave_time','Monthnbr','N','N1','nbrstep','Nbruse_bed1charger','Nbruse_bed1lap','Nbruse_bed1rad','Nbruse_bed1ster','Nbruse_coff','Nbruse_dish','Nbruse_hair','Nbruse_hobs','Nbruse_iron','Nbruse_kett','Nbruse_microwave','Nbruse_oven','Nbruse_saun','Nbruse_shav','Nbruse_ster','Nbruse_toas','Nbruse_tv','Nbruse_waff','Nbruse_wash','Nbrusesumtotal_bed1charger','Nbrusesumtotal_bed1lap','Nbrusesumtotal_bed1rad','Nbrusesumtotal_bed1ster','Nbrusesumtotal_coff','Nbrusesumtotal_dish','Nbrusesumtotal_hair','Nbrusesumtotal_hobs','Nbrusesumtotal_iron','Nbrusesumtotal_kett','Nbrusesumtotal_microwave','Nbrusesumtotal_oven','Nbrusesumtotal_saun','Nbrusesumtotal_shav','Nbrusesumtotal_ster','Nbrusesumtotal_toas','Nbrusesumtotal_tv','Nbrusesumtotal_waff','Nbrusesumtotal_wash','Nbrusetotal_bed1charger','Nbrusetotal_bed1lap','Nbrusetotal_bed1rad','Nbrusetotal_bed1ster','Nbrusetotal_coff','Nbrusetotal_dish','Nbrusetotal_hair','Nbrusetotal_hobs','Nbrusetotal_iron','Nbrusetotal_kett','Nbrusetotal_microwave','Nbrusetotal_oven','Nbrusetotal_saun','Nbrusetotal_shav','Nbrusetotal_ster','Nbrusetotal_toas','Nbrusetotal_tv','Nbrusetotal_waff','Nbrusetotal_wash','Occupancy','output_comparison','oven_rand','oven_rand_act','oven_time','Power_Bed1Charger','Power_Bed1Lap','Power_Bed1Rad','Power_Bed1Ster','Price','PVPower','Rand_Hour','Real_Price','Reduce_time','Reference_1','refrnd_bed1charger','refrnd_bed1lap','refrnd_bed1rad','refrnd_bed1ster','refrnd_coff','refrnd_dish','refrnd_hair','refrnd_hobs','refrnd_iron','refrnd_kett','refrnd_microwave','refrnd_oven','refrnd_saun','refrnd_shav','refrnd_ster','refrnd_toas','refrnd_tv','refrnd_waff','refrnd_wash','refrndday_bed1charger','refrndday_bed1lap','refrndday_bed1rad','refrndday_bed1ster','refrndday_coff','refrndday_dish','refrndday_hair','refrndday_hobs','refrndday_iron','refrndday_kett','refrndday_microwave','refrndday_oven','refrndday_saun','refrndday_shav','refrndday_ster','refrndday_toas','refrndday_tv','refrndday_waff','refrndday_wash','Response_User_rand','saun_rand','saun_rand_act','saun_time','Season','shav_rand','shav_rand_act','shav_time','Sixmtheq','Sol','SolarLuminance','StartDate','stepreal','ster_rand','ster_rand_act','ster_time','stp','Sum_act','Temp','Thermal_Demand','Three_hours','timeaction_bed1charger','timeaction_bed1lap','timeaction_bed1rad','timeaction_bed1ster','timeaction_coff','timeaction_dish','timeaction_dish2','timeaction_hair','timeaction_hobs','timeaction_iron','timeaction_kett','timeaction_microwave','timeaction_oven','timeaction_saun','timeaction_shav','timeaction_ster','timeaction_toas','timeaction_tv','timeaction_waff','timeaction_wash','timeactiontot_bed1charger','timeactiontot_bed1lap','timeactiontot_bed1rad','timeactiontot_bed1ster','timeactiontot_coff','timeactiontot_dish','timeactiontot_hair','timeactiontot_hobs','timeactiontot_iron','timeactiontot_kett','timeactiontot_microwave','timeactiontot_oven','timeactiontot_saun','timeactiontot_shav','timeactiontot_ster','timeactiontot_toas','timeactiontot_tv','timeactiontot_waff','timeactiontot_wash','timedaynbrN','timehour_delay','Timemonthnbr','Timeyearnbr','toas_rand','toas_rand_act','toas_time','tv_rand','tv_rand_act','tv_time','Vec_Mean_Act_Week_bed1charger','Vec_Mean_Act_Week_bed1lap','Vec_Mean_Act_Week_bed1rad','Vec_Mean_Act_Week_bed1ster','Vec_Mean_Act_Week_coff','Vec_Mean_Act_Week_hair','Vec_Mean_Act_Week_iron','Vec_Mean_Act_Week_kett','Vec_Mean_Act_Week_microwave','Vec_Mean_Act_Week_saun','Vec_Mean_Act_Week_shav','Vec_Mean_Act_Week_ster','Vec_Mean_Act_Week_toas','Vec_Mean_Act_Week_tv','waff_rand','waff_rand_act','waff_time','wash_rand','wash_rand_act','wash_time','Weekly_Cons','wkdaycst_temp_bed1charger','wkdaycst_temp_bed1lap','wkdaycst_temp_bed1rad','wkdaycst_temp_bed1ster','wkdaycst_temp_coff','wkdaycst_temp_hair','wkdaycst_temp_iron','wkdaycst_temp_kett','wkdaycst_temp_microwave','wkdaycst_temp_saun','wkdaycst_temp_shav','wkdaycst_temp_ster','wkdaycst_temp_toas','wkdaycst_temp_tv','wkendcst_temp_bed1charger','wkendcst_temp_bed1lap','wkendcst_temp_bed1rad','wkendcst_temp_bed1ster','wkendcst_temp_coff','wkendcst_temp_hair','wkendcst_temp_iron','wkendcst_temp_kett','wkendcst_temp_microwave','wkendcst_temp_saun','wkendcst_temp_shav','wkendcst_temp_ster','wkendcst_temp_toas','wkendcst_temp_tv','wknbrCNT','wkNbrCNT_bed1charger','wkNbrCNT_bed1lap','wkNbrCNT_bed1rad','wkNbrCNT_bed1ster','wkNbrCNT_coff','wkNbrCNT_dish','wkNbrCNT_hair','wkNbrCNT_hobs','wkNbrCNT_iron','wkNbrCNT_kett','wkNbrCNT_microwave','wkNbrCNT_oven','wkNbrCNT_saun','wkNbrCNT_shav','wkNbrCNT_ster','wkNbrCNT_toas','wkNbrCNT_tv','wkNbrCNT_waff','wkNbrCNT_wash','WTPower','xxx_dish','xxx_wash','Yearnbr','yyy_dish','yyy_wash','zzz_dish','zzz_wash');
