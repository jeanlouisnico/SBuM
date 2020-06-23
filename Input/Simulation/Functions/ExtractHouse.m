function StructVarUnique = ExtractHouse(StructVar,HouseID)

AllVar = fieldnames(StructVar) ;

for i = 1:numel(AllVar)
    VarName = AllVar{i} ;
    if isa(StructVar.(VarName),'struct')
        try
            StructVarUnique.(VarName).(HouseID) = StructVar.(VarName).(HouseID) ;
        catch
            % Exception must be thrown if there are appliances detailed in
            % the structure of the variable
            AllApp = fieldnames(StructVar.(VarName)) ;
            for ik = 1:numel(AllApp)
                VarApp = AllApp{ik} ;
                try
                    for isubapp = 1:size(StructVar.(VarName).(VarApp),2)
                        StructVarUnique.(VarName).(VarApp)(isubapp).(HouseID) = StructVar.(VarName).(VarApp)(isubapp).(HouseID) ;
                    end
                catch
                    % If it does not work, then it means that this house
                    % does not possess the specific appliance so we can
                    % disregard it
                    continue;
                end
            end
        end
    else
        StructVarUnique.(VarName) = StructVar.(VarName) ;
    end 
end