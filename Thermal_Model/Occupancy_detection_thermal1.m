function [varargout] = Occupancy_detection_thermal(varargin)
%% This is a function for occupancy detection in the thermal model
% The aim of this function is to determine the occupancy of the inhabitants
% and determine their actions in the building. This is used in calculating
% the heat gain from inhabitants and the metabolic rate to be used in
% thermal comfort determination.
%% Input variables
% The input variables go here. 

HouseTitle              = varargin{1};
Input_Data              = varargin{2};
All_Var                 = varargin{3};
timehour                = varargin{4};
% EnergyOutput            = varargin{5};
Appliances_consumption  = varargin{5};
Occupancy               = varargin{6};
SimDetails              = varargin{7};
Ventilation_Type        = varargin{8};
T_inlet                 = varargin{9};
myiter                  = varargin{10};
Temp_inside             = varargin{11};
Temperature             = varargin{12};
App                     = varargin{13};
Temp_Cooling            = varargin{14};

Inhabitants = str2double(Input_Data.inhabitants);
N0          = str2double(Input_Data.N0);

%% Predefined variables for the metabolic rate calculation
% These values are based on Ahmed et al. (2017) and SFS-EN ISO 7730:2005.
%%%
% People activities based on met. The calculation is Q = met(action) *
% A(person). A(person) is 1.80 m2 by default. Activities are sleeping (0.8),
% Seating (1.0), Domestic work (2.0) and sedentary activity (1.2). One met
% is considered to be 58 W/m2.

A_Person            = 1.80;

Sleeping            = 46 * A_Person;
Seated              = 58 * A_Person;
Domestic_Work       = 116 * A_Person;
Sedentary_activity  = 70 * A_Person;

%% Determine the used appliances and their positions in the sturcture

% Call the function for the appliance numbering

% [nbr_appliances, Series_App] = App_Nbr(HouseTitle, Input_Data);
% 
% % With the appliance numbering, determine which appliance in the NewVar
% % variable is which appliance. Consider doing this only once for speed!
% 
% placingInput = zeros(1,length(nbr_appliances(:,2)));     % Pre-allocate
% 
% % for loop for determining the positions of each of the used appliance
% % from the HouseTitle.
% 
% for i = 1:length(nbr_appliances(:,2))
%     [I,~] = find(Series_App == nbr_appliances(i,2));
%     placingInput(i) = Series_App(I,1);
% end
% 
% % Name the appliances 
% 
% Appliance_Name_Structure = HouseTitle(placingInput);

% Loop for determining the NewVar variable appliances, and which value is
% equal to which appliance. Start by pre-allocating the variables. 

App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers)      = 0;
App.OccupancyDetection.Tele.(Input_Data.Headers)                = 0;
App.OccupancyDetection.Laptop.(Input_Data.Headers)              = 0;
App.OccupancyDetection.WashMach.(Input_Data.Headers)            = 0;
App.OccupancyDetection.DishWash.(Input_Data.Headers)            = 0;
App.OccupancyDetection.HobOven.(Input_Data.Headers)             = 0;
App.OccupancyDetection.Sauna.(Input_Data.Headers)               = 0;
App.OccupancyDetection.Elecheat.(Input_Data.Headers)            = 0;
App.OccupancyDetection.Other.(Input_Data.Headers)               = 0;
StandBy                                                         = 0;
StandBy_sedentary                                               = 0;
StandBy_Domestic                                                = 0;
StandBy_seated                                                  = 0;

% for i = 1:length(nbr_appliances(:,2))
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr),'Iron') == 1)  % ironing and vacuuming are domestic works
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Iron),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Iron,2)
        
                App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers)   = App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) + (App.Appliances_ConsStr.Iron(i).(Input_Data.Headers)(myiter+1));
                
            end
        
        switch char(Input_Data.clIron)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Iron(4).Power * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Iron(4).Power * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Iron(4).Power * 5/3 * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Iron(4).Power * 5/3 * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Iron(4).Power * 10/3 * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Iron(4).Power * 10/3 * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Iron'),3) * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Iron'),3) * size(Input_Data.Iron,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
                
        end
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Vacuum') == 1)
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Vacuum),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Vacuum,2)

                App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers)   = App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) + (App.Appliances_ConsStr.Vacuum(i).(Input_Data.Headers)(myiter+1));
                
            end
        
        switch char(Input_Data.clVacuum)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Vacuum(4).Power * size(Input_Data.Vacuum,2); % size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Vacuum(4).Power * size(Input_Data.Vacuum,2); %  size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Vacuum(4).Power * 5/3 * size(Input_Data.Vacuum,2); % size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Vacuum(4).Power * 5/3 * size(Input_Data.Vacuum,2); % size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Vacuum(4).Power * 10/3 * size(Input_Data.Vacuum,2); % size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Vacuum(4).Power * 10/3 * size(Input_Data.Vacuum,2); % size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
           
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Vacuum'),3) * size(Input_Data.Vacum,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_Domestic = StandBy_Domestic + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Vacuum'),3) * size(Input_Data.Vacuum,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Vacuum(4).Power * size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
%         StandBy_Domestic = StandBy_Domestic + All_Var.Detail_Appliance_List.Vacuum(4).Power * size(App.Appliances_ConsStr.Vacuum.(Input_Data.Headers),1);
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Tele') == 1)
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Tele),Input_Data.Headers) == 1)
            
                for i = 1:size(Input_Data.Tele,2)
        
                    App.OccupancyDetection.Tele.(Input_Data.Headers)                = App.OccupancyDetection.Tele.(Input_Data.Headers) + App.Appliances_ConsStr.Tele(i).(Input_Data.Headers)(myiter+1);
                    
                end
        
        switch char(Input_Data.clTele)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Tele(4).Power * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Tele(4).Power * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Tele(4).Power * 5/3 * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Tele(4).Power * 5/3 * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Tele(4).Power * 10/3 * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Tele(4).Power * 10/3 * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Tele'),3) * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Tele'),3) * size(Input_Data.Tele,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Tele(4).Power * size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);
%         StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Tele(4).Power * size(App.Appliances_ConsStr.Tele.(Input_Data.Headers),1);

        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Laptop') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Laptop),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Laptop,2)
        
                App.OccupancyDetection.Laptop.(Input_Data.Headers)              = App.OccupancyDetection.Laptop.(Input_Data.Headers) + App.Appliances_ConsStr.Laptop(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clLaptop)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
%                 StandBy = StandBy + All_Var.Detail_Appliance_List.Laptop(4).Power * size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Laptop(4).Power * size(Input_Data.Laptop,2); % size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
                
            case 'C or D class'
                
%                 StandBy = StandBy + All_Var.Detail_Appliance_List.Laptop(4).Power * 5/3 * size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Laptop(4).Power * 5/3 * size(Input_Data.Laptop,2);  %size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
                
            case 'E or F class'
                
%                 StandBy = StandBy + All_Var.Detail_Appliance_List.Laptop(4).Power * 10/3 * size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Laptop(4).Power * 10/3 * size(Input_Data.Laptop,2); % size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
                
            case 'Self-Defined'

%                 StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Laptop'),3) * size(Input_Data.Laptop,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_seated = StandBy_seated + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Laptop'),3) * size(Input_Data.Laptop,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Laptop(4).Power * size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
%         StandBy_seated = StandBy_seated + All_Var.Detail_Appliance_List.Laptop(4).Power * size(App.Appliances_ConsStr.Laptop.(Input_Data.Headers),1);
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'WashMach') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.WashMach),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.WashMach,2)
        
                App.OccupancyDetection.WashMach.(Input_Data.Headers)              = App.OccupancyDetection.WashMach.(Input_Data.Headers) + App.Appliances_ConsStr.WashMach(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'DishWash') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.DishWash),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.DishWash,2)
        
                App.OccupancyDetection.DishWash.(Input_Data.Headers)              = App.OccupancyDetection.DishWash.(Input_Data.Headers) + App.Appliances_ConsStr.DishWash(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Elec') == 1) % Using Electric Hob
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Elec),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Elec,2)
        
                App.OccupancyDetection.HobOven.(Input_Data.Headers)              = App.OccupancyDetection.HobOven.(Input_Data.Headers) + App.Appliances_ConsStr.Elec(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Oven') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Oven),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Oven,2)
        
                App.OccupancyDetection.HobOven.(Input_Data.Headers)              = App.OccupancyDetection.HobOven.(Input_Data.Headers) + App.Appliances_ConsStr.Oven(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Sauna') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Sauna),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Sauna,2)
        
                App.OccupancyDetection.Sauna.(Input_Data.Headers)              = App.OccupancyDetection.Sauna.(Input_Data.Headers) + App.Appliances_ConsStr.Sauna(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        end
        
    end
        
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Elecheat') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Elecheat),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Elecheat,2)
        
                App.OccupancyDetection.Elecheat.(Input_Data.Headers)              = App.OccupancyDetection.Elecheat.(Input_Data.Headers) + App.Appliances_ConsStr.Elecheat(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Kettle') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Kettle),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Kettle,2)
        
                App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.Kettle(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clKettle)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Kettle(4).Power * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Kettle(4).Power * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Kettle(4).Power * 5/3 * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Kettle(4).Power * 5/3 * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Kettle(4).Power * 10/3 * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Kettle(4).Power * 10/3 * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Kettle'),3) * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Kettle'),3) * size(Input_Data.Kettle,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Kettle(4).Power * size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Kettle(4).Power * size(App.Appliances_ConsStr.Kettle.(Input_Data.Headers),1);

        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'MW') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.MW),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.MW,2)
        
                App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.MW(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clMW)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.MW(4).Power * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.MW(4).Power * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.MW(4).Power * 5/3 * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.MW(4).Power * 5/3 * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.MW(4).Power * 10/3 * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.MW(4).Power * 10/3 * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'MW'),3) * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'MW'),3) * size(Input_Data.MW,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.MW(4).Power * size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.MW(4).Power * size(App.Appliances_ConsStr.MW.(Input_Data.Headers),1);

        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Coffee') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Coffee),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Coffee,2)
        
            App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.Coffee(i).(Input_Data.Headers)(myiter+1);
            
            end
        
        switch char(Input_Data.clCoffee)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Coffee(4).Power * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Coffee(4).Power * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Coffee(4).Power * 5/3 * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Coffee(4).Power * 5/3 * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Coffee(4).Power * 10/3 * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Coffee(4).Power * 10/3 * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Coffee'),3) * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Coffee'),3) * size(Input_Data.Coffee,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Coffee(4).Power * size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Coffee(4).Power * size(App.Appliances_ConsStr.Coffee.(Input_Data.Headers),1);
        
        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Toas') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Toas),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Toas,2)
        
                App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.Toas(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clToas)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Toas(4).Power * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Toas(4).Power * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Toas(4).Power * 5/3 * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Toas(4).Power * 5/3 * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Toas(4).Power * 10/3 * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Toas(4).Power * 10/3 * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Toas'),3) * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Toas'),3) * size(Input_Data.Toas,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Toas(4).Power * size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Toas(4).Power * size(App.Appliances_ConsStr.Toas.(Input_Data.Headers),1);
        
        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Waff') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Waff),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Waff,2)
        
                App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.Waff(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clWaff)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Waff(4).Power * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Waff(4).Power * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Waff(4).Power * 5/3 * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Waff(4).Power * 5/3 * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Waff(4).Power * 10/3 * size(Input_Data.Waff,2); %  size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Waff(4).Power * 10/3 * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Waff'),3) * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Waff'),3) * size(Input_Data.Waff,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Waff(4).Power * size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Waff(4).Power * size(App.Appliances_ConsStr.Waff.(Input_Data.Headers),1);
        
        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Stereo') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Stereo),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Stereo,2)
        
                App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.Stereo(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clStereo)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Stereo(4).Power * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Stereo(4).Power * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Stereo(4).Power * 5/3 * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Stereo(4).Power * 5/3 * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Stereo(4).Power * 10/3 * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Stereo(4).Power * 10/3 * size(Input_Data.Stereo,2); %  size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Stereo'),3) * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Stereo'),3) * size(Input_Data.Stereo,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Stereo(4).Power * size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Stereo(4).Power * size(App.Appliances_ConsStr.Stereo.(Input_Data.Headers),1);
        
        end
        
    end
    
    if any(strcmp(fieldnames(App.Appliances_ConsStr), 'Hair') == 1) % Using Televion or laptop means seating
        
        if any(strcmp(fieldnames(App.Appliances_ConsStr.Hair),Input_Data.Headers) == 1)
            
            for i = 1:size(Input_Data.Hair,2)
        
                App.OccupancyDetection.Other.(Input_Data.Headers)              = App.OccupancyDetection.Other.(Input_Data.Headers) + App.Appliances_ConsStr.Hair(i).(Input_Data.Headers)(myiter+1);
                
            end
        
        switch char(Input_Data.clHair)      % Different class devices have different stand-by powers
            
            case 'A or B class'
        
                StandBy = StandBy + All_Var.Detail_Appliance_List.Hair(4).Power * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Hair(4).Power * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
                
            case 'C or D class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Hair(4).Power * 5/3 * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Hair(4).Power * 5/3 * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
                
            case 'E or F class'
                
                StandBy = StandBy + All_Var.Detail_Appliance_List.Hair(4).Power * 10/3 * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Hair(4).Power * 10/3 * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
                
            case 'Self-Defined'

                StandBy = StandBy + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Hair'),3) * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);
                StandBy_sedentary = StandBy_sedentary + All_Var.GuiInfo.SelfDefinedAppliances(strcmp(All_Var.GuiInfo.SelfDefinedAppliances, 'Hair'),3) * size(Input_Data.Hair,2); % size(App.Appliances_ConsStr.Iron.(Input_Data.Headers),1);

                
        end
        
%         StandBy = StandBy + All_Var.Detail_Appliance_List.Hair(4).Power * size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
%         StandBy_sedentary = StandBy_sedentary + All_Var.Detail_Appliance_List.Hair(4).Power * size(App.Appliances_ConsStr.Hair.(Input_Data.Headers),1);
        
        end
        
    end
    
%     if strcmp(Appliance_Name_Structure{i},'Kettle') == 1 || strcmp(Appliance_Name_Structure{i},'MW') == 1 || strcmp(Appliance_Name_Structure{i},'Coffee') == 1 || strcmp(Appliance_Name_Structure{i},'Toas') == 1 || strcmp(Appliance_Name_Structure{i},'Waff') == 1 || strcmp(Appliance_Name_Structure{i},'Tele') == 1 || strcmp(Appliance_Name_Structure{i},'Stereo') == 1 || strcmp(Appliance_Name_Structure{i},'Iron') == 1 || strcmp(Appliance_Name_Structure{i},'Vacuum') == 1
%         
%         OccupancyDevices = [OccupancyDevices, i];
%     
%     end
    
% end

    
    

%% Appliances heat gains
% This section defines the heat gains from the appliances. Washing machine,
% dish washer, hob and oven have their own heat gain coefficients to be
% used in the heat gain calculation. The impact of sauna and electric
% heater are neglected in the appliances heat gain calculations.

% First load the file including the NewVar variable needed in determining
% the individual consumptions of the appliances.

% load(strcat(SimDetails.Output_Folder,filesep,SimDetails.Project_ID,filesep,'Variable_File',filesep,FileName(1).name,'.mat'));

% Determine  the heat gain from appliances by reducing the not internal
% heat gains from the total appliance consumption.

Internal_Heat_Gain_Appl = Appliances_consumption * 1000 - ((1-0.8) * App.OccupancyDetection.WashMach.(Input_Data.Headers) * 1000 + (1-0.6) * App.OccupancyDetection.DishWash.(Input_Data.Headers)*1000 + (1-0.4) * App.OccupancyDetection.HobOven.(Input_Data.Headers) * 1000 + App.OccupancyDetection.Sauna.(Input_Data.Headers) * 1000 + App.OccupancyDetection.Elecheat.(Input_Data.Headers) * 1000);
% Internal_Heat_Gain_Appl = Appliances_consumption - ((1-0.8) * App.Appliances_ConsStr.WashMach.(Input_Data.Headers) * 1000 + (1-0.6) * App.Appliances_ConsStr.DishWash.(Input_Data.Headers)*1000 + (1-0.4) * App.Appliances_ConsStr.Elec.(Input_Data.Headers) * 1000 + (1-0.4) * App.Appliances_ConsStr.Oven.(Input_Data.Headers) * 1000 + App.OccupancyDetection.Sauna.(Input_Data.Headers) * 1000 + App.OccupancyDetection.Elecheat.(Input_Data.Headers) * 1000);


%% Calculate the stand-by power of the occupancy detection appliances
% With the stand-by power the occupancy can be determined. The devices
% which are considered in occupancy detection are: 'Kettle', 'Microwave',
% 'Coffee Machine', 'Toaster', 'Waffle Iron', 'Television', 'Stereo',
% 'Iron' and 'Vacuum'. (For more info check Appliances_One_Code.m)



%% People heat gains and their metabolic rates

% Determine tenancy first

% if Occupancy > sum(All_Var.Detail_Appliance(4,8,OccupancyDevices))
if Occupancy > StandBy
    tenancy = 1;
else 
    tenancy = 0;
end

% SedentaryActivityDetection = (Occupancy - (NewVar.Appliances_Cons(BuildSim,myiter+1,DomesticWork1) + NewVar.Appliances_Cons(BuildSim,myiter+1,Tele) + NewVar.Appliances_Cons(BuildSim,myiter+1,Laptop))) > sum(All_Var.Detail_Appliances(4,8,OccupancyDevices));
SedentaryActivityDetection = App.OccupancyDetection.Other.(Input_Data.Headers) > StandBy_sedentary;

if Inhabitants == 1
    
    if timehour > 22 || timehour < 8
        
        People_Heat_Gain    = Inhabitants * Sleeping;
        Met_rate            = 46; 
    
    elseif tenancy == 1 && App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic
        
        People_Heat_Gain    = Inhabitants * Domestic_Work;
        Met_rate            = 116;
        
    elseif tenancy == 1 && (App.OccupancyDetection.Tele.(Input_Data.Headers) + App.OccupancyDetection.Laptop.(Input_Data.Headers)) > StandBy_seated 
        
        People_Heat_Gain    = Inhabitants * Seated;
        Met_rate            = 58;
        
    elseif tenancy == 1 
        
        People_Heat_Gain    = Inhabitants * Sedentary_activity;
        Met_rate            = 70;
        
    else
        
        People_Heat_Gain    = 0;
        Met_rate            = 0;
        
    end
    
else
    
    if timehour > 22 || timehour < 8
        
        People_Heat_Gain    = Inhabitants * Sleeping;
        Met_rate            = 46;
        
    elseif tenancy == 1 && App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic && (App.OccupancyDetection.Tele.(Input_Data.Headers) + App.OccupancyDetection.Laptop.(Input_Data.Headers)) > StandBy_seated
        
        People_Heat_Gain    = (Inhabitants - 1) * Seated + Domestic_Work;
        Met_rate            = 116;
        
    elseif tenancy == 1 && App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic && SedentaryActivityDetection == 1 %&& any((NewVar.Appliances_Cons(BuildSim,myiter+1,find(nbr_appliances(:,2) ~= DomesticWork1 && nbr_appliances(:,2) ~= Tele && nbr_appliances(:,2) ~= Laptop && nbr_appliances(:,2) ~= Elecheat)) > 0) == 1)
        
        People_Heat_Gain    = (Inhabitants - 1) * Sedentary_activity + Domestic_Work;
        Met_rate            = 116;
        
    elseif tenancy == 1 && App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic
        
        People_Heat_Gain    = Domestic_Work;
        Met_rate            = 116;
        
    elseif tenancy == 1 && (App.OccupancyDetection.Tele.(Input_Data.Headers) + App.OccupancyDetection.Laptop.(Input_Data.Headers)) > StandBy_seated
        
        People_Heat_Gain    = Inhabitants * Seated;
        Met_rate            = 58;
        
    elseif tenancy == 1 && SedentaryActivityDetection == 1
        
        People_Heat_Gain    = Inhabitants * Sedentary_activity;
        Met_rate            = 70;
        
    else 
        People_Heat_Gain    = 0;
        Met_rate            = 0;
        
    end
    
end

%% Define the flow rate 
% This part is used in defining the flow rate of the ventilation system as
% it may vary by the time and device usage.

switch Ventilation_Type
        
        case{'Mechanical ventilation','Air-Air H-EX'}     
            % These technologies can adjust the ventilation rate of the
            % building. Consider also option to attach the flow rate to the
            % N0.

            if tenancy == 0             % From RIL 249-2009 p. 114
                
                Flow_rate       = 0.2;
                
                if strcmp(Ventilation_Type,'Air-Air H-EX') == 1
                    
                
                T_inlet         = T_inlet;
                
                else
                    
                    T_inlet = Temperature;
                    
                end
                
            elseif tenancy == 1 && App.OccupancyDetection.Domestic_Work1.(Input_Data.Headers) > StandBy_Domestic    % Increased ventilation air flow when cooking or cleaning
                
                Flow_rate       = 1.0;
                
                T_inlet         = T_inlet;
                
            elseif myiter+1 > 1 && Temp_inside > Temp_Cooling && (timehour > 8 && timehour < 22) % Summer daytime increased ventilation flow
                
                Flow_rate       = 0.7;
                
                if Temperature > 10 && Temperature < 18 && strcmp(Ventilation_Type, 'Air-Air H-EX')
                    
                    T_inlet     = Temperature;
                    
%                 elseif Temperature > T_inlet
                    
                else
                    
                    T_inlet     = T_inlet;
                    
                end
                
            elseif myiter+1 > 1 && Temp_inside > Temp_Cooling && (timehour < 8 || timehour > 22) % Increased ventilation flow for summer nights for cooling
                
                Flow_rate       = 1.5;
                
                if Temperature > 10 && Temperature < 18
                    
                    T_inlet     = Temperature;
                    
                else
                    
                    T_inlet     = T_inlet;
                    
                end
                
            else
                
                Flow_rate       = N0;
                
                T_inlet         = T_inlet;
                
            end
    
        case('Natural ventilation')
            
            Flow_rate = N0;
            
            T_inlet   = T_inlet;
            
end

%% Output variables
% The output variables for the thermal house model

varargout{1} = People_Heat_Gain;
varargout{2} = Met_rate;
varargout{3} = Internal_Heat_Gain_Appl;
varargout{4} = tenancy;
varargout{5} = Flow_rate;
varargout{6} = T_inlet;

end

