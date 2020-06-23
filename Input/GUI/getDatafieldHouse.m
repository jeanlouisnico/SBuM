function [Output] = getDatafieldHouse(InfoNeeded, varargin)

    switch InfoNeeded
        case 'DefaultValue'
            
        case 'DataStructure'
            [Structure] = Datastructure ;
            fieldscomparison = Compareinputfields;
            for structuresize = 1:numel(Structure)
                datastructure.(Structure{structuresize}).FilterValues = fieldscomparison.(Structure{structuresize});
                datastructure.(Structure{structuresize}).Default = DefaultData((Structure{structuresize})) ;
                datastructure.(Structure{structuresize}).DefaultCreated = DefaultCreatedData((Structure{structuresize})) ;
            end
            Fielddatatype = DataType(datastructure) ;
            for structuresize = 1:numel(Structure)
                datastructure.(Structure{structuresize}).DataType = Fielddatatype.(Structure{structuresize});
            end
            Output = datastructure ;
        case 'DataType'
            
        case 'DefaultCreated'
            
        case 'FilterValues'
            Output = Compareinputfields;
    end
%-------------------------------------------------------------------------%    
    function [Comparefield] = Compareinputfields()
        Comparefield.Headers        = 'TO BE REMOVED' ;
        Comparefield.HouseNbr       = 'TO BE REMOVED' ;
        Comparefield.StartingDate   = 'date';
        Comparefield.EndingDate     = 'date';
        Comparefield.Latitude       = 'Compare';
        Comparefield.Longitude      = 'Compare';
        Comparefield.User_Type      = {{'1';'2';'3'} {'Green';'Orange';'Brown'}} ;
        Comparefield.Time_Step      = 'TO BE REMOVED';
        Comparefield.Building_Type	= {{'1','2'} {'Detached house','Appartment building'}} ;
        Comparefield.WindTurbine	= {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.PhotoVol       = {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.FuelCell       = {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.WTPowertot     = 'Compare';
        Comparefield.WindSpeed      = 'Compare';
        Comparefield.Lambdanom      = 'Compare';
        Comparefield.Cp             = 'Compare';
        Comparefield.MaxPowerWT     = 'Compare';
        Comparefield.Baserotspeed	= 'Compare';
        Comparefield.Pitch          = 'Compare';
        Comparefield.EfficiencyWT	= 'Compare';
        Comparefield.NbrmodTot      = 'Compare';
        Comparefield.Nbrmodser      = 'Compare';
        Comparefield.Nbrmodpar      = 'Compare';
        Comparefield.Aspect         = 'Compare';
        Comparefield.Tilt           = 'Compare';
        Comparefield.Voc            = 'Compare';
        Comparefield.Isc            = 'Compare';
        Comparefield.MaxPowerPV     = 'Compare';
        Comparefield.LengthPV       = 'Compare';
        Comparefield.WidthPV        = 'Compare';
        Comparefield.NOCT           = 'Compare';
        Comparefield.MaxPowerFC     = {{'1 kW';'3 kW';'5 kW'} {'1 kW';'3 kW';'5 kW'}} ;
        Comparefield.SolarData      = 'TO BE REMOVED';
        Comparefield.ContElec       = {{'Real-time pricing';'Varmavirta';'Virhevirta';'Tuulivirta'} {'Real-time pricing';'Varmavirta';'Virhevirta';'Tuulivirta'}} ;
        Comparefield.inhabitants    = {{'1';'2';'3';'4';'5';'6'} {'1';'2';'3';'4';'5';'6'}} ;
        Comparefield.nbrRoom        = 'Compare';
        Comparefield.WashMach       = 'Compare';
        Comparefield.clWashMach     = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.DishWash       = 'Compare';
        Comparefield.clDishWash     = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Elec           = 'Compare';
        Comparefield.Kettle         = 'Compare';
        Comparefield.clKettle       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Oven           = 'Compare';
        Comparefield.clOven         = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Coffee         = 'Compare';
        Comparefield.clCoffee       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.MW             = 'Compare';
        Comparefield.clMW           = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Toas           = 'Compare';
        Comparefield.clToas         = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Waff           = 'Compare';
        Comparefield.clWaff         = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Fridge         = 'Compare';
        Comparefield.clFridge       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Tele           = 'Compare';
        Comparefield.clTele         = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Laptop         = 'Compare';
        Comparefield.clLaptop       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Shaver         = 'Compare';
        Comparefield.clShaver       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Hair           = 'Compare';
        Comparefield.clHair         = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Stereo         = 'Compare';
        Comparefield.clStereo       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Vacuum         = 'Compare';
        Comparefield.clVacuum       = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Charger        = 'Compare';
        Comparefield.clCharger      = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Iron           = 'Compare';
        Comparefield.clIron         = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.Elecheat       = 'Compare';
        Comparefield.Sauna          = 'Compare';
        Comparefield.Radio          = 'Compare';
        Comparefield.clRadio        = {{'A or B class';'C or D class';'E or F class'} {'A or B class';'C or D class';'E or F class'}} ;
        Comparefield.clLight        = {{'Low consumption bulbs';'Incandescent bulbs'} {'Low consumption bulbs';'Incandescent bulbs'}} ;
        Comparefield.Metering       = {{'1';'2';'3';'4'} {'No metering';'Metering system 2' ;'Metering system 3';'Metering system 4'}} ;
        Comparefield.Self           = {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.Comp           = {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.Goal           = {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.Bill           = {{'0';'1'} {'Inactive';'Active'}} ;
        Comparefield.myiter         = 'TO BE REMOVED';
        Comparefield.Building_Area  = 'Compare';
        Comparefield.hgt            = 'Compare';
        Comparefield.lgts           = 'Compare';
        Comparefield.lgte           = 'Compare';
        Comparefield.pitchangle     = 'Compare';
        Comparefield.aws            = 'Compare';
        Comparefield.awe            = 'Compare';
        Comparefield.awn            = 'Compare';
        Comparefield.aww            = 'Compare';
        Comparefield.ad             = 'Compare';
        Comparefield.uvs            = 'Compare';
        Comparefield.uve            = 'Compare';
        Comparefield.uvn            = 'Compare';
        Comparefield.uvw            = 'Compare';
        Comparefield.uvsw           = 'Compare';
        Comparefield.uvew           = 'Compare';
        Comparefield.uvnw           = 'Compare';
        Comparefield.uvww           = 'Compare';
        Comparefield.uvd            = 'Compare';
        Comparefield.uvf            = 'Compare';
        Comparefield.uvr            = 'Compare';
        Comparefield.N0             = 'Compare';
        Comparefield.HighNbHouse    = 'TO BE REMOVED';
        Comparefield.HighNbrRoom	= 'TO BE REMOVED';
        Comparefield.VTempCoff      = 'Compare';
        Comparefield.Appliance_Max	= 'Compare';
        Comparefield.Low_Price      = 'Compare';
        Comparefield.High_Price     = 'Compare';
        Comparefield.Contract       = {{'Fixed Tariff';'ToU Tariff'} {'Fixed Tariff';'Time of Use Tariffs'}};
        Comparefield.Profile        = {{'1';'2'} {'Profile 1';'Profile 2'}};
        
%         Comparefieldnames = fieldnames(Comparefield);
%         for i = 1:numel(Comparefieldnames)
%             input = Comparefield.(Comparefieldnames{i}) ;
%             if isa(input,'char')
%                 if strcmp(input,'TO BE REMOVED')
%                     Comparefield = rmfield(Comparefield,Comparefieldnames(i)) ;
%                 end
%             end
%         end
end %Compareinputfields
%-------------------------------------------------------------------------% 
    function [defaultvalue] = DefaultData(field)
    switch field
        case 'Headers'
                defaultvalue = '';
        case 'HouseNbr'
                defaultvalue = '';
        case 'StartingDate'
            defaultvalue = '01/01/12';
        case 'EndingDate'
            defaultvalue = '31/12/12';
        case 'Latitude'
            defaultvalue = '65.0593';
        case 'Longitude'
            defaultvalue = '25.4663';
        case 'User_Type'
            defaultvalue = '1';
        case 'Time_Step'
            defaultvalue = 'Hourly';
        case 'Building_Type'
            defaultvalue = '1';
        case 'WindTurbine'
            defaultvalue = '0';
        case 'PhotoVol'
            defaultvalue = '0';
        case 'FuelCell'
            defaultvalue = '0';
        case 'WTPowertot'
            defaultvalue = '-1';
        case 'WindSpeed'
            defaultvalue = '-1';
        case 'Lambdanom'
            defaultvalue = '-1';
        case 'Cp'
            defaultvalue = '-1';
        case 'MaxPowerWT'
            defaultvalue = '-1';
        case 'Baserotspeed'
            defaultvalue = '-1';
        case 'Pitch'
            defaultvalue = '-1';
        case 'EfficiencyWT'
            defaultvalue = '-1';
        case 'NbrmodTot'  
            defaultvalue = '-1';
        case 'Nbrmodser'
            defaultvalue = '-1';
        case 'Nbrmodpar'
            defaultvalue = '-1';
        case 'Aspect'
            defaultvalue = '-1';
        case 'Tilt'
            defaultvalue = '-1';
        case 'Voc'
            defaultvalue = '-1';
        case 'Isc'
            defaultvalue = '-1';
        case 'MaxPowerPV'
            defaultvalue = '-1';
        case 'LengthPV'
            defaultvalue = '-1';
        case 'WidthPV'
            defaultvalue = '-1';
        case 'NOCT'
            defaultvalue = '-1';
        case 'MaxPowerFC'
            defaultvalue = '1 kW';
        case 'SolarData'
            defaultvalue = 'Hourly Data';
        case 'ContElec'
            defaultvalue = 'Real-time pricing';
        case 'inhabitants'
            defaultvalue = '1';
        case 'nbrRoom'
            defaultvalue = '1';
        case 'WashMach'
            defaultvalue = '0';
        case 'clWashMach'
            defaultvalue = 'A or B class';
        case 'DishWash'
            defaultvalue = '0';
        case 'clDishWash'
            defaultvalue = 'A or B class';
        case 'Elec'
            defaultvalue = '0';
        case 'Kettle'
            defaultvalue = '0';
        case 'clKettle'
            defaultvalue = 'A or B class';
        case 'Oven'
            defaultvalue = '0';
        case 'clOven'
            defaultvalue = 'A or B class';
        case 'Coffee'
            defaultvalue = '0';
        case 'clCoffee'
            defaultvalue = 'A or B class';
        case 'MW'
            defaultvalue = '0';
        case 'clMW'
            defaultvalue = 'A or B class';
        case 'Toas'
            defaultvalue = '0';
        case 'clToas'
            defaultvalue = 'A or B class';
        case 'Waff'
            defaultvalue = '0';
        case 'clWaff'
            defaultvalue = 'A or B class';
        case 'Fridge'
            defaultvalue = '0';
        case 'clFridge'
            defaultvalue = 'A or B class';
        case 'Tele'
            defaultvalue = '0';
        case 'clTele'
            defaultvalue = 'A or B class';
        case 'Laptop'
            defaultvalue = '0';
        case 'clLaptop'
            defaultvalue = 'A or B class';
        case 'Shaver'
            defaultvalue = '0';
        case 'clShaver'
            defaultvalue = 'A or B class';
        case 'Hair'
            defaultvalue = '0';
        case 'clHair'
            defaultvalue = 'A or B class';
        case 'Stereo'
            defaultvalue = '0';
        case 'clStereo'
            defaultvalue = 'A or B class';
        case 'Vacuum'
            defaultvalue = '0';
        case 'clVacuum'
            defaultvalue = 'A or B class';
        case 'Charger'
            defaultvalue = '0';
        case 'clCharger'
            defaultvalue = 'A or B class';
        case 'Iron'
            defaultvalue = '0';
        case 'clIron'
            defaultvalue = 'A or B class';
        case 'Elecheat'
            defaultvalue = '0';
        case 'Sauna'
            defaultvalue = '0';
        case 'Radio'
            defaultvalue = '0';
        case 'clRadio'
            defaultvalue = 'A or B class';
        case 'clLight'
            defaultvalue = 'Low consumption bulbs';
        case 'Metering'
            defaultvalue = '1';
        case 'Self'
            defaultvalue = '0';
        case 'Comp'
            defaultvalue = '0';
        case 'Goal'
            defaultvalue = '0';
        case 'Bill'
            defaultvalue = '0';
        case 'myiter'
            defaultvalue = 'myiter';
        case 'Building_Area'
            defaultvalue = '-1';
        case 'hgt'
            defaultvalue = '12';
        case 'lgts'
            defaultvalue = '9.2';
        case 'lgte'
            defaultvalue = '45';
        case 'pitchangle'
            defaultvalue = '8';
        case 'aws'
            defaultvalue = '3';
        case 'awe'
            defaultvalue = '3';
        case 'awn'
            defaultvalue = '3';
        case 'aww'
            defaultvalue = '3';
        case 'ad'
            defaultvalue = '0.2';
        case 'uvs'
            defaultvalue = '0.2';
        case 'uve'
            defaultvalue = '0.2';
        case 'uvn'
            defaultvalue = '0.2';
        case 'uvw'
            defaultvalue = '1';
        case 'uvsw'
            defaultvalue = '1';
        case 'uvew'
            defaultvalue = '1';
        case 'uvnw'
            defaultvalue = '1';
        case 'uvww'
            defaultvalue = '1';
        case 'uvd'
            defaultvalue = '0.2';
        case 'uvf'
            defaultvalue = '0.1';
        case 'uvr'
            defaultvalue = '1';
        case 'N0'
            defaultvalue = '1';
        case 'HighNbHouse'
            defaultvalue = '1';
        case 'HighNbrRoom'
            defaultvalue = '1';
        case 'VTempCoff'
            defaultvalue = '-1';
        case 'Appliance_Max'
            defaultvalue = '0';
        case 'Low_Price'
            defaultvalue = '-99999';
        case 'High_Price'
            defaultvalue = '99999';
        case 'Contract'
            defaultvalue = 'Fixed Tariff';
        case 'Profile'
            defaultvalue = '1'; 
    end
end %Compareinputfields
%-------------------------------------------------------------------------% 
    function [defaultvalue] = DefaultCreatedData(field)
        switch field
            case 'Headers'
                defaultvalue = '';
            case 'HouseNbr'
                defaultvalue = '';
            case 'StartingDate'
                defaultvalue = '01/01/12';
            case 'EndingDate'
                defaultvalue = '31/12/12';
            case 'Latitude'
                defaultvalue = '65.0593';
            case 'Longitude'
                defaultvalue = '25.4663';
            case 'User_Type'
                defaultvalue = '1';
            case 'Time_Step'
                defaultvalue = 'Hourly';
            case 'Building_Type'
                defaultvalue = '1';
            case 'WindTurbine'
                defaultvalue = '0';
            case 'PhotoVol'
                defaultvalue = '0';
            case 'FuelCell'
                defaultvalue = '0';
            case 'WTPowertot'
                defaultvalue = '-1';
            case 'WindSpeed'
                defaultvalue = '-1';
            case 'Lambdanom'
                defaultvalue = '-1';
            case 'Cp'
                defaultvalue = '-1';
            case 'MaxPowerWT'
                defaultvalue = '-1';
            case 'Baserotspeed'
                defaultvalue = '-1';
            case 'Pitch'
                defaultvalue = '-1';
            case 'EfficiencyWT'
                defaultvalue = '-1';
            case 'NbrmodTot'  
                defaultvalue = '-1';
            case 'Nbrmodser'
                defaultvalue = '-1';
            case 'Nbrmodpar'
                defaultvalue = '-1';
            case 'Aspect'
                defaultvalue = '-1';
            case 'Tilt'
                defaultvalue = '-1';
            case 'Voc'
                defaultvalue = '-1';
            case 'Isc'
                defaultvalue = '-1';
            case 'MaxPowerPV'
                defaultvalue = '-1';
            case 'LengthPV'
                defaultvalue = '-1';
            case 'WidthPV'
                defaultvalue = '-1';
            case 'NOCT'
                defaultvalue = '-1';
            case 'MaxPowerFC'
                defaultvalue = '1 kW';
            case 'SolarData'
                defaultvalue = 'Hourly Data';
            case 'ContElec'
                defaultvalue = 'Select...';
            case 'inhabitants'
                defaultvalue = 'Select...';
            case 'nbrRoom'
                defaultvalue = '1';
            case 'WashMach'
                defaultvalue = '0';
            case 'clWashMach'
                defaultvalue = 'A or B class';
            case 'DishWash'
                defaultvalue = '0';
            case 'clDishWash'
                defaultvalue = 'A or B class';
            case 'Elec'
                defaultvalue = '0';
            case 'Kettle'
                defaultvalue = '0';
            case 'clKettle'
                defaultvalue = 'A or B class';
            case 'Oven'
                defaultvalue = '0';
            case 'clOven'
                defaultvalue = 'A or B class';
            case 'Coffee'
                defaultvalue = '0';
            case 'clCoffee'
                defaultvalue = 'A or B class';
            case 'MW'
                defaultvalue = '0';
            case 'clMW'
                defaultvalue = 'A or B class';
            case 'Toas'
                defaultvalue = '0';
            case 'clToas'
                defaultvalue = 'A or B class';
            case 'Waff'
                defaultvalue = '0';
            case 'clWaff'
                defaultvalue = 'A or B class';
            case 'Fridge'
                defaultvalue = '0';
            case 'clFridge'
                defaultvalue = 'A or B class';
            case 'Tele'
                defaultvalue = '0';
            case 'clTele'
                defaultvalue = 'A or B class';
            case 'Laptop'
                defaultvalue = '0';
            case 'clLaptop'
                defaultvalue = 'A or B class';
            case 'Shaver'
                defaultvalue = '0';
            case 'clShaver'
                defaultvalue = 'A or B class';
            case 'Hair'
                defaultvalue = '0';
            case 'clHair'
                defaultvalue = 'A or B class';
            case 'Stereo'
                defaultvalue = '0';
            case 'clStereo'
                defaultvalue = 'A or B class';
            case 'Vacuum'
                defaultvalue = '0';
            case 'clVacuum'
                defaultvalue = 'A or B class';
            case 'Charger'
                defaultvalue = '0';
            case 'clCharger'
                defaultvalue = 'A or B class';
            case 'Iron'
                defaultvalue = '0';
            case 'clIron'
                defaultvalue = 'A or B class';
            case 'Elecheat'
                defaultvalue = '0';
            case 'Sauna'
                defaultvalue = '0';
            case 'Radio'
                defaultvalue = '0';
            case 'clRadio'
                defaultvalue = 'A or B class';
            case 'clLight'
                defaultvalue = 'Low consumption bulbs';
            case 'Metering'
                defaultvalue = '1';
            case 'Self'
                defaultvalue = '0';
            case 'Comp'
                defaultvalue = '0';
            case 'Goal'
                defaultvalue = '0';
            case 'Bill'
                defaultvalue = '0';
            case 'myiter'
                defaultvalue = 'myiter';
            case 'Building_Area'
                defaultvalue = '-1';
            case 'hgt'
                defaultvalue = '12';
            case 'lgts'
                defaultvalue = '9.2';
            case 'lgte'
                defaultvalue = '45';
            case 'pitchangle'
                defaultvalue = '8';
            case 'aws'
                defaultvalue = '3';
            case 'awe'
                defaultvalue = '3';
            case 'awn'
                defaultvalue = '3';
            case 'aww'
                defaultvalue = '3';
            case 'ad'
                defaultvalue = '0.2';
            case 'uvs'
                defaultvalue = '0.2';
            case 'uve'
                defaultvalue = '0.2';
            case 'uvn'
                defaultvalue = '0.2';
            case 'uvw'
                defaultvalue = '1';
            case 'uvsw'
                defaultvalue = '1';
            case 'uvew'
                defaultvalue = '1';
            case 'uvnw'
                defaultvalue = '1';
            case 'uvww'
                defaultvalue = '1';
            case 'uvd'
                defaultvalue = '0.2';
            case 'uvf'
                defaultvalue = '0.1';
            case 'uvr'
                defaultvalue = '1';
            case 'N0'
                defaultvalue = '1';
            case 'HighNbHouse'
                defaultvalue = '1';
            case 'HighNbrRoom'
                defaultvalue = '1';
            case 'VTempCoff'
                defaultvalue = '-1';
            case 'Appliance_Max'
                defaultvalue = '0';
            case 'Low_Price'
                defaultvalue = '-99999';
            case 'High_Price'
                defaultvalue = '99999';
            case 'Contract'
                defaultvalue = 'Fixed Tariff';
            case 'Profile'
                defaultvalue = 'Select...'; 
        end
    end %Compareinputfields
%-------------------------------------------------------------------------% 
    function [Structure] = Datastructure
        Structure{1} = 'Headers' ;
        Structure{2} = 'HouseNbr' ;
        Structure{3} = 'StartingDate';
        Structure{4} = 'EndingDate';
        Structure{5} = 'Latitude';
        Structure{6} = 'Longitude';
        Structure{7} = 'User_Type' ;
        Structure{8} = 'Time_Step';
        Structure{9} = 'Building_Type';
        Structure{10} = 'WindTurbine' ;
        Structure{11} = 'PhotoVol' ;
        Structure{12} = 'FuelCell' ;
        Structure{13} = 'WTPowertot';
        Structure{14} = 'WindSpeed';
        Structure{15} = 'Lambdanom';
        Structure{16} = 'Cp';
        Structure{17} = 'MaxPowerWT';
        Structure{18} = 'Baserotspeed';
        Structure{19} = 'Pitch';
        Structure{20} = 'EfficiencyWT';
        Structure{21} = 'NbrmodTot';
        Structure{22} = 'Nbrmodser';
        Structure{23} = 'Nbrmodpar';
        Structure{24} = 'Aspect';
        Structure{25} = 'Tilt';
        Structure{26} = 'Voc';
        Structure{27} = 'Isc';
        Structure{28} = 'MaxPowerPV';
        Structure{29} = 'LengthPV';
        Structure{30} = 'WidthPV';
        Structure{31} = 'NOCT';
        Structure{32} = 'MaxPowerFC' ;
        Structure{33} = 'SolarData';
        Structure{34} = 'ContElec' ;
        Structure{35} = 'inhabitants';
        Structure{36} = 'nbrRoom';
        Structure{37} = 'WashMach';
        Structure{38} = 'clWashMach' ;
        Structure{39} = 'DishWash';
        Structure{40} = 'clDishWash';
        Structure{41} = 'Elec';
        Structure{42} = 'Kettle';
        Structure{43} = 'clKettle' ;
        Structure{44} = 'Oven';
        Structure{45} = 'clOven' ;
        Structure{46} = 'Coffee';
        Structure{47} = 'clCoffee' ;
        Structure{48} = 'MW';
        Structure{49} = 'clMW' ;
        Structure{50} = 'Toas';
        Structure{51} = 'clToas';
        Structure{52} = 'Waff';
        Structure{53} = 'clWaff' ;
        Structure{54} = 'Fridge';
        Structure{55} = 'clFridge' ;
        Structure{56} = 'Tele';
        Structure{57} = 'clTele' ;
        Structure{58} = 'Laptop';
        Structure{59} = 'clLaptop' ;
        Structure{60} = 'Shaver';
        Structure{61} = 'clShaver' ;
        Structure{62} = 'Hair';
        Structure{63} = 'clHair' ;
        Structure{64} = 'Stereo';
        Structure{65} = 'clStereo' ;
        Structure{66} = 'Vacuum';
        Structure{67} = 'clVacuum' ;
        Structure{68} = 'Charger';
        Structure{69} = 'clCharger' ;
        Structure{70} = 'Iron';
        Structure{71} = 'clIron' ;
        Structure{72} = 'Elecheat';
        Structure{73} = 'Sauna';
        Structure{74} = 'Radio';
        Structure{75} = 'clRadio' ;
        Structure{76} = 'clLight' ;
        Structure{77} = 'Metering' ;
        Structure{78} = 'Self' ;
        Structure{79} = 'Comp' ;
        Structure{80} = 'Goal' ;
        Structure{81} = 'Bill' ;
        Structure{82} = 'myiter';
        Structure{83} = 'Building_Area';
        Structure{84} = 'hgt';
        Structure{85} = 'lgts';
        Structure{86} = 'lgte';
        Structure{87} = 'pitchangle';
        Structure{88} = 'aws';
        Structure{89} = 'awe';
        Structure{90} = 'awn';
        Structure{91} = 'aww';
        Structure{92} = 'ad';
        Structure{93} = 'uvs';
        Structure{94} = 'uve';
        Structure{95} = 'uvn';
        Structure{96} = 'uvw';
        Structure{97} = 'uvsw';
        Structure{98} = 'uvew';
        Structure{99} = 'uvnw';
        Structure{100} = 'uvww';
        Structure{101} = 'uvd';
        Structure{102} = 'uvf';
        Structure{103} = 'uvr';
        Structure{104} = 'N0';
        Structure{105} = 'HighNbHouse';
        Structure{106} = 'HighNbrRoom';
        Structure{107} = 'VTempCoff';
        Structure{108} = 'Appliance_Max';
        Structure{109} = 'Low_Price';
        Structure{110} = 'High_Price';
        Structure{111} = 'Contract';
        Structure{112} = 'Profile'; 
    end
%-------------------------------------------------------------------------% 
    function [OutPutLimiting] = DataType(Structure)
        Allfield = fieldnames(Structure) ;
        for i = 1:numel(fieldnames(Structure))
            field = Allfield{i} ;
        	a = Structure.(field).FilterValues ;
            
            if isa(a,'char')
                if ~strcmp(a,'TO BE REMOVED')
                        % Look for limiting values
                    defaultvalue = limitation(field) ;
                else
                    defaultvalue.Type     = 'string' ;
                    defaultvalue.LowLimit = ''; % Between -180 and +180
                    defaultvalue.HighLimit = '';
                    defaultvalue.Exception = '';
                end
            elseif isa(a,'cell')
                defaultvalue.Type     = 'cell' ;
                defaultvalue.LowLimit = ''; % Between -180 and +180
                defaultvalue.HighLimit = '';
                defaultvalue.Exception = a{1} ;
            end
            OutPutLimiting.(field) = defaultvalue ;
        end
    end %Compareinputfields
%-------------------------------------------------------------------------% 
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && ((x > 0) || (x==-1));
    function defaultvalue = limitation(field)
        switch field
            case {'StartingDate' 'EndingDate'}
                defaultvalue.Type     = 'date' ;
                defaultvalue.LowLimit = '01/01/2012'; % Between -180 and +180
                defaultvalue.HighLimit = '31/12/2012';
                defaultvalue.Exception = -1;
            case {'Latitude' 'Longitude'}
                defaultvalue.Type     = 'double' ;
                defaultvalue.LowLimit = -180; % Between -180 and +180
                defaultvalue.HighLimit = 180;
                defaultvalue.Exception = '';
            case {'WTPowertot', 'WindSpeed', 'Lambdanom', 'Cp', 'MaxPowerWT', 'Baserotspeed',...
                   'Pitch', 'EfficiencyWT', 'NbrmodTot', 'Nbrmodser', 'Nbrmodpar', 'Aspect',...
                   'Tilt', 'Voc', 'Isc', 'MaxPowerPV', 'LengthPV', 'WidthPV', 'NOCT', 'WashMach',...
                   'DishWash', 'Elec', 'Kettle', 'Oven', 'Coffee', 'MW', 'Toas', 'Waff', 'Fridge',...
                   'Tele', 'Laptop', 'Shaver', 'Hair', 'Stereo', 'Vacuum', 'Charger', 'Iron', 'Elecheat',...
                   'Sauna', 'Radio', 'Building_Area', 'Appliance_Max'}
               defaultvalue.Type     = 'double' ; 
               defaultvalue.LowLimit = 0; %>=
                defaultvalue.HighLimit = Inf;
                defaultvalue.Exception = -1;
            case {'inhabitants' 'nbrRoom'}
                defaultvalue.Type     = 'double' ;
                defaultvalue.LowLimit = 1; %>=
                defaultvalue.HighLimit = Inf;
                defaultvalue.Exception = '';
            case {'hgt' 'lgts' 'lgte' 'pitchangle' 'aws' 'awe' 'awn' 'aww' 'ad' 'uvs' 'uve' 'uvn' 'uvw' 'uvsw' 'uvew' 'uvnw' 'uvww' 'uvd' 'uvf' 'uvr' 'N0' 'VTempCoff'  }
                defaultvalue.Type     = 'double' ;
                defaultvalue.LowLimit = 0.000000001; %>=
                defaultvalue.HighLimit = Inf;
                defaultvalue.Exception = -1;
            case {'Low_Price' 'High_Price'}
                defaultvalue.Type     = 'double' ;
                defaultvalue.LowLimit = -99999; %>=
                defaultvalue.HighLimit = 99999;
                defaultvalue.Exception = '';
        end
    end
end