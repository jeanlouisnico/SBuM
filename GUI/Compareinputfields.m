function [Comparefield] = Compareinputfields(data)
        Allfield = fieldnames(data.datastructure) ;
        for i = 1:numel(fieldnames(data.datastructure))
        	Comparefield.(Allfield{i}) = data.datastructure.(Allfield{i}).Comparefield ;
        end        
        Comparefieldnames = fieldnames(Comparefield);
        for i = 1:numel(Comparefieldnames)
            input = Comparefield.(Comparefieldnames{i}) ;
            if isa(input,'char')
                if strcmp(input,'TO BE REMOVED')
                    Comparefield = rmfield(Comparefield,Comparefieldnames(i)) ;
                end
            end
        end
end
