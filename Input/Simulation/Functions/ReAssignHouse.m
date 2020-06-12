function DesStructVar = ReAssignHouse(DesStructVar,SrcStructVar,HouseID, xq, AppList, varargin)
    if isa(SrcStructVar,'struct')
        AllVar = fieldnames(SrcStructVar) ;

        for i = 1:numel(AllVar)
            VarName = AllVar{i} ;
            if isa(SrcStructVar.(VarName),'struct')
                try
                    DesStructVar.(VarName).(HouseID) = SrcStructVar.(VarName).(HouseID) ;
                    if isa(DesStructVar.(VarName).(HouseID),'struct')
                        NoSubArray = false ;
                    else
                        NoSubArray = true ;
                    end
                catch
                    % Exception must be thrown if there are appliances detailed in
                    % the structure of the variable
                    AllApp = fieldnames(SrcStructVar.(VarName)) ;
                    for ik = 1:numel(AllApp)
                        VarApp = AllApp{ik} ;
                        try
                            for isubapp = 1:size(SrcStructVar.(VarName).(VarApp),2)
                                SourceArray  = SrcStructVar.(VarName).(VarApp)(isubapp).(HouseID) ;
                                DesStructVar = ReAssignHouse(DesStructVar,SourceArray,HouseID, xq, VarName, VarApp, isubapp) ;
                            end
                        catch
                            % If it does not work, then it means that this house
                            % does not possess the specific appliance so we can
                            % disregard it
                            continue;
                        end
                    end
                end
                SourceArray  = SrcStructVar.(VarName).(HouseID) ;
                if NoSubArray
                    OutputArray  = DesStructVar.(VarName).(HouseID) ;
                    OutputArray = DateTimeTranspose(xq, SourceArray, OutputArray) ;
                    DesStructVar.(VarName).(HouseID) = OutputArray ;
                    NoSubArray = false ;
                else
                    DesStructVar = ReAssignHouse(DesStructVar,SourceArray,HouseID, xq) ;
                end
            else
                SourceArray = SrcStructVar.(VarName) ;
                if size(xq,1) == size(SourceArray,1)
                    OutputArray = table(xq,SourceArray,'VariableNames',{'Time','DataOutput'}) ;
                elseif size(xq,1) == size(SourceArray,2)
                    OutputArray = table(xq,SourceArray','VariableNames',{'Time','DataOutput'}) ;
                elseif strcmp('App_Energy10s',VarName)
                    SimulationStart = DesStructVar.Info.WashMach.House1.ActionQtyStep.Time(1)   ;
                    SimulationEnd   = DesStructVar.Info.WashMach.House1.ActionQtyStep.Time(end) ;
                    xq = (SimulationStart:seconds(10):SimulationEnd)';
                    OutputArray = table(xq,SourceArray,'VariableNames',{'Time','DataOutput'}) ;
                else
                    OutputArray = SourceArray ;
                end 
                if nargin > 5
                    DesStructVar.(varargin{1}).(varargin{2})(varargin{3}).(HouseID).(VarName) = OutputArray ;
                else
                    DesStructVar.(VarName) = OutputArray ;
                end
            end 
        end
    else
        if size(xq,1) == size(SrcStructVar,1)
            OutputArray = table(xq,SrcStructVar,'VariableNames',{'Time','DataOutput'}) ;
        elseif size(xq,1) == size(SrcStructVar,2)
            OutputArray = table(xq,SrcStructVar','VariableNames',{'Time','DataOutput'}) ;
        else
            OutputArray = SrcStructVar ;
        end 
        DesStructVar.(varargin{1}).(varargin{2})(varargin{3}).(HouseID) = OutputArray ;
    end
end

function OutputArray = DateTimeTranspose(xq, SourceArray, OutputArray)
    % If the size of both rows are the same, then the rows are
    % equal and can be used straight
    if size(xq,1) == size(SourceArray,1)
        OutputArray = table(xq,SourceArray,'VariableNames',{'Time','DataOutput'}) ;
    % If the size of rows from the datatine and the size of the column are the same, 
    % then we shall transpose the columns into rows
    elseif size(xq,1) == size(SourceArray,2)
        OutputArray = table(xq,SourceArray','VariableNames',{'Time','DataOutput'}) ;
    elseif size(SourceArray,1) == 1
        Array2input = SourceArray' ;
        DiffSize = size(xq,1) - size(Array2input,1) ;
        OutputArray = table(xq(1:(end-DiffSize)),Array2input,'VariableNames',{'Time','DataOutput'}) ;
    elseif size(SourceArray,2) == 1
        Array2input = SourceArray ;
        DiffSize = size(xq,1) - size(Array2input,1) ;
        OutputArray = table(xq(1:(end-DiffSize)),Array2input,'VariableNames',{'Time','DataOutput'}) ;
    end
end
