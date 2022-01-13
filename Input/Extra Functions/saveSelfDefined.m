function [data, gui] = saveSelfDefined(data, HouseSelected,Source, gui, AppName, Inputstr1, DBsel)
    for hh = 1:size(HouseSelected,1)
        switch Source
            case 'ApplianceStandBy'
                if strcmp(Inputstr1,'Lighting System')
                    data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).StandBy            = str2double(gui.(Source).String)   ;
                else
                    data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).StandBy    = str2double(gui.(Source).String)   ;
                end
            case 'ApplianceRate' 
                if strcmp(Inputstr1,'Lighting System')
                    data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).Rate               = str2double(gui.(Source).String)   ;
                else
                    data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Rate       = str2double(gui.(Source).String)   ;
                end                
            case 'ApplianceSleep'
                if strcmp(Inputstr1,'Lighting System')
                   data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).Sleep      = str2double(gui.(Source).String)   ;
                else
                    data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Sleep      = str2double(gui.(Source).String)   ;
                end                
        end
        % Fill in the missing fields if they have never
        % been declared before
        if strcmp(Inputstr1,'Lighting System')
            if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName),'Rate')
                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).Rate   = 0 ;
            end
            if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName),'StandBy')
                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).StandBy   = 0 ;
            end
            if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName),'Sleep')
                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).Sleep   = 0 ;
            end
        else
            if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel),'Rate')
                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Rate   = 0 ;
            end
            if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel),'StandBy')
                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).StandBy   = 0 ;
            end
            if ~isfield(data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel),'Sleep')
                data.SelfDefinedAppliances.(HouseSelected{hh}).(AppName).(DBsel).Sleep   = 0 ;
            end
        end
    end  
end