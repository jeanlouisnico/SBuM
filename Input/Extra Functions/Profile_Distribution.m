function [ApplianceLD, KrRemodece] = Profile_Distribution(varargin)

% Remodece, default value to get

% Default appliance characteristics
if nargin == 0
    [Kr]                = RemodeceDistriv2  ;
    KrRemodece          = Kr                ;
    [Detail_Appliance]  = ApplianceSpec ;
    AllProject = {'Remodece'} ;
    [Powerinput, MaxNbrUse_Week, AverageTimeUse] = averagevalue(Detail_Appliance) ;
    AllApp = fieldnames(Kr) ;
else
    inhabitant          = varargin{1} ;
    Kr                  = varargin{2} ;
    Detail_Appliance    = varargin{3} ;
    KrRemodece          = varargin{4} ;
    DatabaseApp         = varargin{5} ;
    
    AllApp          = fieldnames(Detail_Appliance)                                          ;
    AllProject      = DatabaseApp                                                           ;
    for ij = 1:length(AllProject)
        for i = 1:length(AllApp)
            switch AllApp{i}
                case {'WashMach'}
                    Powerinput.(AllApp{i})      = Detail_Appliance.(AllApp{i}).Power(1)             ;
                    MaxNbrUse_Week.(AllApp{i})  = Detail_Appliance.(AllApp{i}).MaxUse(4)            ; 
                    AverageTimeUse.(AllApp{i})  = Detail_Appliance.(AllApp{i}).TimeUsage(3)         ;
                case {'DishWash', 'Elec', 'Kettle', 'Stereo', 'Iron', 'Vacuum', 'Charger', 'Sauna'}
                    Powerinput.(AllApp{i})      = Detail_Appliance.(AllApp{i}).Power(1)             ;
                    MaxNbrUse_Week.(AllApp{i})  = Detail_Appliance.(AllApp{i}).MaxUse(inhabitant)   ; 
                    AverageTimeUse.(AllApp{i})  = Detail_Appliance.(AllApp{i}).TimeUsage(2)         ;
                case {'Oven', 'MW', 'Coffee', 'Toas', 'Waff', 'Fridge', 'Radio', 'Laptop', 'Elecheat', 'Shaver', 'Hair', 'Tele'}
                    Powerinput.(AllApp{i})      = Detail_Appliance.(AllApp{i}).Power(1)             ;
                    MaxNbrUse_Week.(AllApp{i})  = Detail_Appliance.(AllApp{i}).MaxUse(inhabitant)   ; 
                    AverageTimeUse.(AllApp{i})  = Detail_Appliance.(AllApp{i}).TimeUsage(1)         ;
                otherwise
                    Powerinput.(AllApp{i})      = Detail_Appliance.(AllApp{i}).Power(1)             ;
                    MaxNbrUse_Week.(AllApp{i})  = Detail_Appliance.(AllApp{i}).MaxUse(inhabitant)   ; 
                    if Detail_Appliance.(AllApp{i}).TimeUsage(1) == 0
                        AverageTimeUse.(AllApp{i})  = 0.5                                               ;
                    else
                        AverageTimeUse.(AllApp{i})  = Detail_Appliance.(AllApp{i}).TimeUsage(1)     ;
                    end
            end
        end
    end
%     [Powerinput, MaxNbrUse_Week, AverageTimeUse] = averagevalue(Detail_Appliance, inhabitant)   ;
end

% Download profile from the Finnish decree
decreeProfile = ProfileDecree  ;

% Now we are assuming that all the appliances are present

for ij = 1:length(AllProject)
    for i = 1:length(AllApp)
        Appname     = AllApp{i} ;
        try
            K_R.(AllProject{ij})(:,i)         = Kr.(Appname).(AllProject{ij}) * Powerinput.(Appname) * MaxNbrUse_Week.(Appname) * AverageTimeUse.(Appname) * 52/365.25 ;
            GammaRatio.(AllProject{ij})(:,i)  = Kr.(Appname).(AllProject{ij}) ./ K_R.(AllProject{ij})(:,i) ;
        catch
            continue ;
        end
    end
    GammaRatio.(AllProject{ij})(isnan(GammaRatio.(AllProject{ij}))) = 0 ;
    K_R.(AllProject{ij})(isnan(K_R.(AllProject{ij})))               = 0 ;
    SKr.(AllProject{ij}) = sum(K_R.(AllProject{ij}),2) ;
end
for ij = 1:length(AllProject)
    for i = 1:length(AllApp)
        try
            K_P.(AllProject{ij})(:,i) = K_R.(AllProject{ij})(:,i) ./ SKr.(AllProject{ij}) ;
        catch
            continue ;
        end
    end
end
% Test with one time
for ij = 1:length(AllProject)
    for imonth = 1:12
        for iperiod = 1:3
            try 
                DVar = decreeProfile.Profile1Perc(imonth,iperiod,:) * sum(SKr.(AllProject{ij})) ;
                Array(:,1) = DVar(1,1,:) ;

                PiVar = Array ./ SKr.(AllProject{ij}) - 1 ;

                Kp_tot = (1 + PiVar) .* K_P.(AllProject{ij}) ;

                PTemp  = Kp_tot .* SKr.(AllProject{ij}) ;

                P1 = PTemp .* GammaRatio.(AllProject{ij}) ;
                P2 = PTemp ./ sum(PTemp) ;
                P2 = cumsum(P2) ;
                P2 = insertrows(P2,zeros(1,size(P2,2)),0) ;
                P2(isnan(P2)) = 0 ;

                for i = 1:length(AllApp)
                    Appname     = AllApp{i} ;
                    ApplianceLD(imonth, iperiod, :).(Appname).(AllProject{ij}) = P2(:, i)     ; 
                end
            catch
                continue ;
            end
        end
    end
end
