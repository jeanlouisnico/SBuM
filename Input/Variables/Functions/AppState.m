function [App, AppStatus] = AppState(AppName, App, Input_Data, AppStatus, myiter)
        if any(strcmp(fieldnames(App.Appliances_ConsStr),AppName))  % ironing and vacuuming are domestic works
            if any(strcmp(fieldnames(App.Appliances_ConsStr.(AppName)), Input_Data.Headers))
                Qty = countApp(AppName, Input_Data) ;
                for i = 1:Qty
                    switch AppName
                        case {'Iron','Vacuum'}
                            OccDec = 'Domestic_Work1' ;
                        case {'Tele'}
                            OccDec = 'Tele' ;
                        case 'Laptop'
                            OccDec = 'Laptop' ;
                        case 'WashMach'
                            OccDec = 'WashMach' ;
                        case 'DishWash'
                            OccDec = 'DishWash' ;
                        case {'Elec', 'Oven'}
                            OccDec = 'HobOven' ;
                        case 'Sauna'
                            OccDec = 'Sauna' ;
                        case 'Elecheat'
                            OccDec = 'Elecheat' ;
                        case {'Kettle','MW', 'Coffee', 'Toas', 'Waff', 'Stereo', 'Hair'}
                            OccDec = 'Other';
                        otherwise % e.g. Fridge, Shaver, Charger, Radio
                            break;
                    end
                    App.OccupancyDetection.(OccDec).(Input_Data.Headers)   = App.OccupancyDetection.(OccDec).(Input_Data.Headers) + (App.Appliances_ConsStr.(AppName)(i).(Input_Data.Headers)(myiter+1));
                end

                ii = 1 ;
                n  = 0 ;

                while n == 0
                    try
                        OutUse = App.Info.(AppName)(ii).(Input_Data.Headers).InUse ;
                    catch
                        AppActive = false ;
                        break;
                    end
                    if OutUse
                        n = 1               ;
                        AppActive = true   ;
                    elseif size(App.Info.(AppName), 2) == ii
                        n = 1               ;
                        AppActive = false  ;
                    else
                        ii = ii + 1         ;
                    end
                end
                switch AppName
                    case {'Iron','Vacuum'}
                        if AppActive % any(App.AppliancesInUse.Iron.(Input_Data.Headers))
                            AppStatus.tenancy          = 1;      
                            AppStatus.StandBy_Domestic = 1;
                        end
                    case {'Tele', 'Laptop'}
                        if AppActive % any(App.AppliancesInUse.Iron.(Input_Data.Headers))
                            AppStatus.tenancy          = 1                          ;  
                            AppStatus.StandBy_seated   = 1                          ;
                        end
                    case {'Kettle', 'MW', 'Coffee', 'Toas', 'Waff', 'Stereo', 'Hair'}
                        if AppActive % any(App.AppliancesInUse.Iron.(Input_Data.Headers))
                            AppStatus.tenancy          = 1                          ;  
                            AppStatus.StandBy_sedentary= 1                          ;
                        end
                end
            end
        end
end