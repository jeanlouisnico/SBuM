function [varargout] = declarevariable(varargin)
Cont        = varargin{1};
App         = varargin{2};
Time_Sim    = varargin{3};
%Housenbr    = varargin{4};
% Nbr_Building= varargin{5};
% Input_DataStr  = varargin{6};
All_Var     = varargin{4};
% nbrstep = Time_Sim.nbrstep;
%% Controller

Cont.Controller1    = 1;
Cont.Controller2    = 1;
App.NewVar1         = 0;

%% Appliances
AppList = All_Var.GuiInfo.AppliancesList ;
Houses2Create = All_Var.GuiInfo.Simulationdata ;
Housenames = fieldnames(Houses2Create) ;

for HouseVar = 1:numel(Housenames)
    AppSimu = fieldnames(All_Var.GuiInfo.SummaryStructure.(Housenames{HouseVar}).Appliances) ;
    for nbr_appliance = 1:size(AppSimu,1)
        AppName     = All_Var.GuiInfo.SummaryStructure.(Housenames{HouseVar}).Appliances.(AppSimu{nbr_appliance}).SN    ; % AppList{nbr_appliance,3}  ;
        AppQty      = All_Var.GuiInfo.SummaryStructure.(Housenames{HouseVar}).Appliances.(AppSimu{nbr_appliance}).Qty   ;
        
        if isa(AppQty,'char')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'string')
            AppQty = str2double(AppQty) ;
        elseif isa(AppQty,'cell')
            AppQty = str2double(AppQty) ;
        end
        
        if isempty(AppName)
            continue
        end
        Input_DataStr = Houses2Create.(Housenames{HouseVar})         ;
%         if isfield(Input_DataStr, AppName)
%             AppSN = Input_DataStr.(AppName) ;
            Housenbr2 = Input_DataStr.HouseNbr;

            rng(Housenbr2)
            Cont.Response_User_randStr.(Input_DataStr.Headers)(1,:)    = rand(1,Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1)   ;
            rng(Housenbr2)
            Cont.Rand_HourStr.(Input_DataStr.Headers)(1,:)             = randi([21 30],Time_Sim.nbrstep.(Input_DataStr.Headers) ,1);

            Cont.Reference_1Str.(Input_DataStr.Headers)            = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Sum_actStr.(Input_DataStr.Headers)                = zeros(1, 2 + Time_Sim.stp * 6)  ;
            Cont.Mean_weekdayStr.(Input_DataStr.Headers)           = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Daily_ConsStr.(Input_DataStr.Headers)             = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Mean_WeekStr.(Input_DataStr.Headers)              = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Weekly_ConsStr.(Input_DataStr.Headers)            = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.TimemonthnbrStr.(Input_DataStr.Headers)           = zeros(1, 2)  ;
            Cont.MonthnbrStr.(Input_DataStr.Headers)               = zeros(1, 2)  ;
            Cont.MeanMonthStr.(Input_DataStr.Headers)              = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.MeanYearStr.(Input_DataStr.Headers)               = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Avg_MonthStr.(Input_DataStr.Headers)              = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Avg_YearStr.(Input_DataStr.Headers)               = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.TimeyearnbrStr.(Input_DataStr.Headers)            = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.YearnbrStr.(Input_DataStr.Headers)                = zeros(1, 2)  ;
            Cont.Logical_CompStr.(Input_DataStr.Headers)           = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;    
            Cont.Forecasted_Price2Str.(Input_DataStr.Headers)      = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.Forecasted_PriceStr.(Input_DataStr.Headers)       = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.comparisonStr.(Input_DataStr.Headers)             = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.timehour_delayStr.(Input_DataStr.Headers)         = zeros(1, 2)  ;
            Cont.output_comparisonStr.(Input_DataStr.Headers)      = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.delay_out_compStr.(Input_DataStr.Headers)         = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            Cont.ResponseTotStr.(Input_DataStr.Headers)            = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            App.Metering_ConsStr.(Input_DataStr.Headers)           = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
            App.Power_Kitchen.(Input_DataStr.Headers)              = 0 ;
            App.Power_Clean.(Input_DataStr.Headers)                = 0 ;
            App.Power_Living.(Input_DataStr.Headers)               = 0 ;
            App.Power_Bath.(Input_DataStr.Headers)                 = 0 ;
            App.Power_Bedrooms.(Input_DataStr.Headers)             = 0 ;
            App.Power_Calc_Light.(Input_DataStr.Headers)           = 0 ;
%             if ~strcmp(AppSN{1},'0')
                % Generate Random number by field and do not generate for
                % non-existent appliances
            if isfield(App, 'rand_ApplianceStr')    
                if isfield(App.rand_ApplianceStr, AppName)
                    if isfield(App.rand_ApplianceStr.(AppName)(1),Input_DataStr.Headers)
                        % Get the amount of subappliances already declared
                        n = 0 ;
                        iwhile = 1 ;
                        while n == 0
                            try 
                                App.rand_ApplianceStr.(AppName)(iwhile).(Input_DataStr.Headers) ;
                                if isempty(App.rand_ApplianceStr.(AppName)(iwhile).(Input_DataStr.Headers))
                                    n = 1 ;
                                    startApp = iwhile  ;
                                end
                            catch
                                n = 1 ;
                                startApp = iwhile  ;
                            end
                            
                            iwhile = iwhile + 1 ;
                        end
%                         subappdec = size(App.rand_ApplianceStr.(AppName), 2) ;
%                         startApp = subappdec + 1 ;
                    else
                        startApp = 1 ;
                    end
                else
                    startApp = 1 ;
                end
            else
                startApp = 1 ;
            end
                for subapp = startApp:(startApp - 1 + AppQty)
                    rng(Housenbr2)  
                    App.rand_ApplianceStr.(AppName)(subapp).(Input_DataStr.Headers)     = rand(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1,1) ;
                    rng(Housenbr2)  
                    App.rand_actStr.(AppName)(subapp).(Input_DataStr.Headers)           = rand(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1,1) ;
                    rng(Housenbr2)  
                    App.Inc_Pot_RandStr.(AppName)(subapp).(Input_DataStr.Headers)       = rand(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1,1) ;
                    rng(Housenbr2*18)  
                    App.Light_randStr.(Input_DataStr.Headers)                           = rand(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1,1) ;
                    App.Mem_app_actionStr.(AppName)(subapp).(Input_DataStr.Headers)     = zeros(1,2)  ;
                    App.Vec_Mean_Act_WeekStr.(AppName)(subapp).(Input_DataStr.Headers)  = zeros(1,2)  ;
                    App.Mem_app_action2Str.(AppName)(subapp).(Input_DataStr.Headers)    = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;        
                    App.time_for_recordStr.(AppName)(subapp).(Input_DataStr.Headers)    = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
                    App.Total_Action2Str.(AppName)(subapp).(Input_DataStr.Headers)      = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
                    App.Appliances_ConsStr.(AppName)(subapp).(Input_DataStr.Headers)    = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).Time_Cycle       = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).ActionQtyStep    = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).time_for_recordStr = zeros(Time_Sim.nbrstep.(Input_DataStr.Headers)  + 1, 1)  ;
    %                 App.Info.(AppName)(subapp).(Input_DataStr.Headers).App_Energy10s    = uninit(Time_Sim.nbrstep.(Input_DataStr.Headers) * Time_Sim.SecperIter  + 1, 1)  ;
                    App.NbrusesumtotalStr.(AppName)(subapp).(Input_DataStr.Headers)     = zeros(1,2)  ;
                    App.Nbrusesumtotal2Str.(AppName)(subapp).(Input_DataStr.Headers)    = zeros(1,2)  ;
                    App.delaylong_time_appStr.(AppName)(subapp).(Input_DataStr.Headers) = zeros(1,2)  ;
                    App.delay_time_appStr.(AppName)(subapp).(Input_DataStr.Headers)     = zeros(1,2)  ;
                    App.actionStr.(AppName)(subapp).(Input_DataStr.Headers)             = 0      ; % set the first action of the dishwasher to 0 --> no action can take place at 12am the very 1st day
                    App.timeactionStr.(AppName)(subapp).(Input_DataStr.Headers)         = 0                      ;
                    App.timeactiontotStr.(AppName)(subapp).(Input_DataStr.Headers)      = 0                      ;
                    App.NbruseStr.(AppName)(subapp).(Input_DataStr.Headers)             = 0                      ;
                    App.refrnddayStr.(AppName)(subapp).(Input_DataStr.Headers)          = 1                      ;
                    App.refrndStr.(AppName)(subapp).(Input_DataStr.Headers)             = 1                      ;
                    App.xxx_appStr.(AppName)(subapp).(Input_DataStr.Headers)            = 1                      ;
                    App.yyy_appStr.(AppName)(subapp).(Input_DataStr.Headers)            = 0                      ;
                    App.timeStr.(AppName)(subapp).(Input_DataStr.Headers)               = 0                      ;
                    App.Total_Action2StrCount.(AppName)(subapp).(Input_DataStr.Headers) = zeros(1,7)             ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).InUse            = false                  ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).Delayed          = false                  ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).Planned          = false                  ;
                    App.Info.(AppName)(subapp).(Input_DataStr.Headers).InUse10s         = false                  ;
                end
%             end
%         end
    end
end

varargout{1} = Cont;
varargout{2} = App ;
