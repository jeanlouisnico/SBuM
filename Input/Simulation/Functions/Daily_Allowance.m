function [Increase_Potential,wkdaycst_saun] = Daily_Allowance(WeekDayProfileAcc,Daily_Profile,wkdaycst_temp_saun,Total_Action,Vec_Mean_Act_Week_saun,TimeVector, ...
                                                              Timeoffset,timeweekday,weekday_saun,Max_use_saun)

WeekEndProfileAcc = 1-WeekDayProfileAcc;
Daily_Perc(1:5) = Daily_Profile(1:5)*WeekDayProfileAcc/sum(Daily_Profile(1:5))';
Daily_Perc(6:7) = Daily_Profile(6:7)*WeekEndProfileAcc/sum(Daily_Profile(6:7))';
DailyAllowance = Daily_Perc(timeweekday);
a_saun_day = (1 - weekday_saun) / (Max_use_saun(6) - Max_use_saun(1));
b_saun_day = weekday_saun - (Max_use_saun(1) * a_saun_day);
wkdaycst_temp_saun(Housenbr, myiter + 1) = a_saun_day * Max_use_saun(inhabitants) + b_saun_day;
Perc_Var = wkdaycst_temp_saun(Housenbr, myiter + 1)/weekday_saun;
maxValue = max(5,ceil((1 / DailyAllowance) / (mean(wkdaycst_temp_saun(Housenbr,1:myiter)) / weekday_saun)));  
if myiter<=1
    Inc_Fac = 1;
elseif size(find(Total_Action(Housenbr, 1:myiter + 1) == 1 & myweekday(TimeVector(Timeoffset:Timeoffset + myiter))==timeweekday),2)/Activity_tot_saun < DailyAllowance
    y = 1:maxValue; x = weekday_saun:((((mean(wkdaycst_temp_saun(Housenbr,1:myiter)) / weekday_saun)-1))-weekday_saun)/(maxValue-1):(((mean(wkdaycst_temp_saun(Housenbr,1:myiter)) / weekday_saun)-1));
    Coeff = [reshape(x,length(x),1),ones(length(x),1)] \ reshape(y,length(y),1);
    Inc_Fac = polyval(Coeff,Perc_Var-1);
else
    Inc_Fac = 1;
end
Increase_Potential = Inc_Fac * Perc_Var; 
if myiter == 0;
    cmp_Week_Act_saun = Vec_Mean_Act_Week_saun(Housenbr, myiter + 1);
    cmp_wkdaycst_saun = wkdaycst_temp_saun(Housenbr, myiter + 1)    ;
else
    cmp_Week_Act_saun = Vec_Mean_Act_Week_saun(Housenbr, myiter)    ;
    cmp_wkdaycst_saun = wkdaycst_temp_saun(Housenbr, myiter)        ;
end
if and(Max_use_saun(inhabitants) * 0.75 > Mean_Act_Week_saun, cmp_Week_Act_saun < Mean_Act_Week_saun);
    wkdaycst_saun = max(0, min(2*(a_saun_day * Max_use_saun(inhabitants) + b_saun_day) - cmp_wkdaycst_saun + 0.1,1));
else
    wkdaycst_saun = (a_saun_day * Max_use_saun(inhabitants) + b_saun_day);
end