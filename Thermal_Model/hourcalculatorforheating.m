function [hourtime1] = hourcalculatorforheating(timehour, hourtime, Heater_Power)
%% Function for the heating time of the day to simplify the previous one


    if timehour == 1 && Heater_Power > 0
        hourtime(1) = hourtime(1) + 1;
    elseif timehour == 2 && Heater_Power > 0
        hourtime(2) = hourtime(2) + 1;
    elseif timehour == 3 && Heater_Power > 0
        hourtime(3) = hourtime(3) + 1;
    elseif timehour == 4 && Heater_Power > 0
        hourtime(4) = hourtime(4) + 1;
    elseif timehour == 5 && Heater_Power > 0
        hourtime(5) = hourtime(5) + 1;
    elseif timehour == 6 && Heater_Power > 0
        hourtime(6) = hourtime(6) + 1;
    elseif timehour == 7 && Heater_Power > 0
        hourtime(7) = hourtime(7) + 1;
    elseif timehour == 8 && Heater_Power > 0
        hourtime(8) = hourtime(8) + 1;
    elseif timehour == 9 && Heater_Power > 0
        hourtime(9) = hourtime(9) + 1;
    elseif timehour == 10 && Heater_Power > 0
        hourtime(10) = hourtime(10) + 1;
    elseif timehour == 11 && Heater_Power > 0
        hourtime(11) = hourtime(11) + 1;
    elseif timehour == 12 && Heater_Power > 0
        hourtime(12) = hourtime(12) + 1;
    elseif timehour == 13 && Heater_Power > 0
        hourtime(13) = hourtime(13) + 1;
    elseif timehour == 14 && Heater_Power > 0
        hourtime(14) = hourtime(14) + 1;
    elseif timehour == 15 && Heater_Power > 0
        hourtime(15) = hourtime(15) + 1;
    elseif timehour == 16 && Heater_Power > 0
        hourtime(16) = hourtime(16) + 1;
    elseif timehour == 17 && Heater_Power > 0
        hourtime(17) = hourtime(17) + 1;
    elseif timehour == 18 && Heater_Power > 0
        hourtime(18) = hourtime(18) + 1;
    elseif timehour == 19 && Heater_Power > 0
        hourtime(19) = hourtime(19) + 1;
    elseif timehour == 20 && Heater_Power > 0
        hourtime(20) = hourtime(20) + 1;
    elseif timehour == 21 && Heater_Power > 0
        hourtime(21) = hourtime(21) + 1;
    elseif timehour == 22 && Heater_Power > 0
        hourtime(22) = hourtime(22) + 1;
    elseif timehour == 23 && Heater_Power > 0
        hourtime(23) = hourtime(23) + 1;
    elseif timehour == 0 && Heater_Power > 0
        hourtime(24) = hourtime(24) + 1;
    end

hourtime1 = hourtime;

end

