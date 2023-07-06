function [PV_production_estimation, varargout] = PV_production_estimation_function(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails)
%% This is a function for estimating PV production and global irradiance on vertical surfaces

%% PV generation estimator
Selection = 5;



% if leapyear(Time_Sim.timeyear) == 1
    
%             [PV_production_estimation,~,~,~,~] = SolRad2(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails, Selection);
%             PV_production_estimation = PV_production_estimation * 1000;     % Original values are in kW, I guess
            
% else
Input_Data.AspectThermal   =  Input_Data.Aspect ;   
[PV_production_estimation,~,~,~,~]                = SolRad3(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails);   

% [PV_production_estimation,~,~,~,~]  = SolRad2(Time_Sim, Input_Data, All_Var, BuildSim, SimDetails, Selection);
 PV_production_estimation           = PV_production_estimation * 1000;     % Original values are in kW, I guess
            

% end

%% Global irradiance on vertical surfaces estimator
% This part is dedicated to estimate the hourly solar radiations on
% vertical surfaces to be utilized in the estimation of the solar heat
% gains in the heat demand forecasts

Global_Irradiance_North = zeros(8760,1);
Global_Irradiance_East  = zeros(8760,1);
Global_Irradiance_South = zeros(8760,1);
Global_Irradiance_West  = zeros(8760,1);
Housenbr                = BuildSim;
Time_Sim.Thermalhouse.Timeoffset     = 0;    % During the forecast simulation assign the time offset to 0.
Time_Sim.Thermalhouse.timedayyear    = 1;    % First day of the year for the annual simulation

%     if strcmp(Input_Data.SimulationTimeFrame, 'TRY2050') 
%         Try2050 = load('2050_global_radiation') ;
%         All_Var.Hourly_Solar_Radiation = Try2050.Hourly_Global_Radiation_2050';
%         Time_Sim.StartDate.(Input_Data.Headers) = datenum(2050,1,1);
%     else   
%         Try2012 = load('TRY2012.mat') ; 
%         All_Var.Hourly_Solar_Radiation = Try2012.TRY2012_Global_Radiation';
%         Time_Sim.StartDate.(Input_Data.Headers) = datenum(2012,1,1);  
%     end

% NORTH!
    Input_Data.AspectIni   = {'360' '270' '180' '90'};
    Input_Data.Tilt     = '90';
    Input_Data.PhotoVol = '0';
    
for i = 1:length(Input_Data.AspectIni)
    
    Input_Data.AspectThermal = Input_Data.AspectIni{i} ;
    
    [~,~,~,~,Global_Irr] = SolRad3(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);
    
    Global_Irr(Global_Irr<0) = 0 ;
    switch i
        case 1
            Global_Irradiance_NorthArray      = Global_Irr;
        case 2
            Global_Irradiance_EastArray       = Global_Irr;
        case 3
            Global_Irradiance_SouthArray      = Global_Irr;
        case 4
            Global_Irradiance_WestArray       = Global_Irr;
    end
    
end
    
% Time_Sim.timedaynbrN does not seem to be recalculated for every step in the loop below, which gives a deviation that becomse significant 
% after some time in the simulation. That changes the dirtiness index of in
% the SolRad function.

% for j = 1:8760  % Loop through the TRY2012 normal year
%     if j == 1907
%         x = 1;
%     end
%         Time_Sim.myiter         = j - 1;            % assign new myiter
%         
%         Time_Sim.SimTime = Time_Sim.StartDate.(Input_Data.Headers)(1) + Time_Sim.myiter/Time_Sim.stp ;   % From House_Sim, required for the calculation
% %         Time_Sim.SimTime = datenum((Time_Sim.StartDate.(Input_Data.Headers)(1):seconds(3600*1):Time_Sim.EndDate.(Input_Data.Headers)(1) + 1))' ;
%         
%         if rem(Time_Sim.myiter+1,24) == 0
%             Time_Sim.timedayyear = Time_Sim.timedayyear + 1;
%         end
% 
% % Selection = 1;
% % NORTH!
%     Input_Data.Aspect   = '360';
%     Input_Data.Tilt     = '90';
%     Input_Data.PhotoVol = '0';
% [~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);
% 
%     if Global_Irr < 0
%         Global_Irr = 0;
%     end
% 
% Global_Irradiance_North(j) = Global_Irr;
% 
% % EAST!
% % Selection = 2;
%     Input_Data.Aspect   = '270';        % Cretes solar negative solar azimuth
%     Input_Data.Tilt     = '90';
%     Input_Data.PhotoVol = '0';
% [~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);
% 
%     if Global_Irr < 0
%         Global_Irr = 0;
%     end
% 
% Global_Irradiance_East(j) = Global_Irr;
% 
% % SOUTH! 
% % Selection = 3;
%     Input_Data.Aspect   = '180';
%     Input_Data.Tilt     = '90';
%     Input_Data.PhotoVol = '0';
% [~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);
% 
%     if Global_Irr < 0
%         Global_Irr = 0;
%     end
% 
% Global_Irradiance_South(j) = Global_Irr;
% 
% % WEST! 
% % Selection = 4;
%     Input_Data.Aspect   = '90';         % Creates positive solar azimuth
%     Input_Data.Tilt     = '90';
%     Input_Data.PhotoVol = '0';
% [~,~,~,~,Global_Irr] = SolRad(Time_Sim, Input_Data, All_Var, Housenbr, SimDetails);
% 
%     if Global_Irr < 0
%         Global_Irr = 0;
%     end
% 
% Global_Irradiance_West(j) = Global_Irr;
% 
% 
% end

varargout{1} = Global_Irradiance_NorthArray;
varargout{2} = Global_Irradiance_EastArray;
varargout{3} = Global_Irradiance_SouthArray;
varargout{4} = Global_Irradiance_WestArray;

end

