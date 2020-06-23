%% Function "Scenario"

%% Declare the function to call
function [Action, Occupancy,App] = Scenario(varargin)                     
%% Declare and structure the variables
                                    
%% Calculate the power use in the kitchen
% for each of the appliances, if the variable designating the appliance is equal to 1, 
% then the system understands that the appliance is present in the dwelling
% and pass inside the function, otherwise, it just go on to the next
% function evaluation.
            %% 
            % *DishWasher*
            Time_Sim        = varargin{1}              ;
            Nbr_Building    = varargin{2}              ;
            Input_Data      = varargin{3}              ;
            Housenbr        = varargin{4}              ;
            All_Var         = varargin{5}              ;
            SimDetails      = varargin{6}              ;
            SolarLuminancev = varargin{7}       ;
            HouseTitle      = varargin{8}       ;
            App             = varargin{9}       ;
                myiter      = Time_Sim.myiter       ;
                nbrstep     = Time_Sim.nbrstep.(Input_Data.Headers)      ;
                DebugMode = varargin{5}.DebugMode ;
            
           Version = 2 ;
           
           if Version == 1
                [TestCons,Power_Calc_Light,App] = Appliances_One_Code(Time_Sim,...
                                                                                  Nbr_Building,...
                                                                                  Input_Data,...
                                                                                  Housenbr,...
                                                                                  All_Var,...
                                                                                  SimDetails,...
                                                                                  SolarLuminancev,...
                                                                                  HouseTitle,...
                                                                                  App);
           elseif Version == 2
                [TestConsStr,Power_Calc_LightStr,App] = Appliances_One_CodeStrv2(Time_Sim,...
                                                                                  Nbr_Building,...
                                                                                  Input_Data,...
                                                                                  Housenbr,...
                                                                                  All_Var,...
                                                                                  SimDetails,...
                                                                                  SolarLuminancev,...
                                                                                  HouseTitle,...
                                                                                  App);
           end
            
            App.Calc_Time(Housenbr,myiter + 1) = toc;
            
            % Save some files related to time (Debug Mode)
            if DebugMode == 1
                if myiter == nbrstep - 1
                    SimDetails      = varargin{6}            ;
                    Calc_Time = App.Calc_Time';
                    save(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Calc_Time.mat'),'Calc_Time')                ;
                end
            end
            Cons_Appli_Overall = TestConsStr;

            Action = Cons_Appli_Overall;

            Occupancy = Power_Calc_LightStr;
                
end