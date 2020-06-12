function [Global_Irradiance_North, Global_Irradiance_East, Global_Irradiance_South, Global_Irradiance_West] = verticalrad1(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails)
% Solar radiation function is called with this function
%   The only big idea here is to fasten the simulation!
%%%
% Save the original variables for PV estimation calculations
% aspect      = Input_Data{30};
% tilt        = Input_Data{31};
% Photovolt   = Input_Data{17};
% Solar radiation on a tilted surface facing ordinal points can be
% calculated with SolRad function. First, selections for the ordinal points
% are:
% North: 1
% East: 2
% South: 3
% West: 4
Housenbr    = BuildSim;
Selection = 1;
% NORTH!
    Input_Data.Aspect   = '0';
    Input_Data.Tilt     = '90';
    Input_Data.PhotoVol = '0';
[~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);

    if Global_Irr < 0
        Global_Irr = 0;
    end

Global_Irradiance_North = Global_Irr;

% EAST!
Selection = 2;
    Input_Data.Aspect   = '90';
    Input_Data.Tilt     = '90';
    Input_Data.PhotoVol = '0';
[~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);

    if Global_Irr < 0
        Global_Irr = 0;
    end

Global_Irradiance_East = Global_Irr;

% SOUTH! 
Selection = 3;
    Input_Data.Aspect   = '180';
    Input_Data.Tilt     = '90';
    Input_Data.PhotoVol = '0';
[~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);

    if Global_Irr < 0
        Global_Irr = 0;
    end

Global_Irradiance_South = Global_Irr;

% WEST! 
Selection = 4;
    Input_Data.Aspect   = '270';
    Input_Data.Tilt     = '90';
    Input_Data.PhotoVol = '0';
[~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);

    if Global_Irr < 0
        Global_Irr = 0;
    end

Global_Irradiance_West = Global_Irr;

% Time_Sim.verticalrad
end

% % PV PRODUCTION ESTIMATION!
% Selection = 5;
%     Input_Data{30} = aspect;
%     Input_Data{31} = tilt;
%     Input_Data{17} = Photovolt;
%     Input_Data{39} = 'TRY2012';
% % for myiter = 0:(Time_Sim.nbrstep +24 - 1)
% %             Time_Sim.myiter = myiter;
% % myiter      = Time_Sim.myiter;
% % timehour    = Time_Sim.timehour;
% if leapyear(Time_Sim.timeyear) == 1
% %     PV_production_estimation = zeros(1,8784);
% %     for n = 1:8784
% %         Time_Sim.myiter = myiter + n - 1;
% %         Time_Sim.timehour = timehour + n - 1;
%             [PV_production_estimation,~,~,~,~] = SolRad2(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%             PV_production_estimation = PV_production_estimation * 1000;     % Original values are in kW, I guess
% else
% %     PV_production_estimation = zeros(1,8760);
% %     for n = 1:8760
% %         Time_Sim.myiter = myiter + n - 1;
% %         Time_Sim.timehour = timehour + n - 1;
%             [PV_production_estimation,~,~,~,~] = SolRad2(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%             PV_production_estimation = PV_production_estimation * 1000;     % Original values are in kW, I guess
% %     end
% end

