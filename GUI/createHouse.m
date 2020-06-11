%--------------------------------------------------------------------------%
    function [SummaryStructure] = createHouse(NewHouse, Housenbr, data)
        Allfield = fieldnames(data.datastructure) ;
        for i = 1:numel(fieldnames(data.datastructure))
           if strcmp(Allfield{i}, 'Appliances')
               SummaryStructure.(NewHouse).Appliances = struct ;
           elseif strcmp(Allfield{i}, 'Headers')
               SummaryStructure.(NewHouse).Headers  = NewHouse ;
           elseif strcmp(Allfield{i}, 'HouseNbr')
               SummaryStructure.(NewHouse).HouseNbr       = Housenbr ;
           elseif any(strcmp(data.AppliancesList(:,3),Allfield{i}))
               % Nothing to do as we do not want the appliances listed here
           elseif any(strcmp(data.AppliancesList(:,4),Allfield{i}))    
               % Nothing to do as we do not want the appliances listed here
           else
               SummaryStructure.(NewHouse).(Allfield{i}) = data.datastructure.(Allfield{i}).Defaultcreate ;
           end
        end
    end %createHouse