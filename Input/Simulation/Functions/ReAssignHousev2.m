function [DesStructVar, OutPutArray, VarPath, SaveVar] = ReAssignHousev2(DesStructVar,SrcStructVar,HouseID, xq, AppList, varargin)
    if isa(SrcStructVar,'struct')
        AllVar = fieldnames(SrcStructVar) ;
        for i = 1:numel(AllVar)
            VarName = AllVar{i} ;
            if any(strcmp(VarName,{'AppSign', 'PowerConsProfile', 'ActionStart', 'TimeArray', 'TimeStr'}))
                continue ;
            end
            if strcmp(VarName,'Info')
                x = 1 ;
            end
            % If this is an app, then loop through the app
            if any(strcmp(AppList,VarName))
                if nargin > 5
                    VarPath = [varargin{2} '.' VarName] ;
                else
                    VarPath = VarName ;
                end
                try
                    for isubapp = 1:size(SrcStructVar.(VarName),2)
                        AppRef = ['App' num2str(isubapp)] ;
                        VarPath = [varargin{2} '.' VarName '.' HouseID] ;
                        SourceArray  = SrcStructVar.(VarName)(isubapp).(HouseID) ;
                        [DesStructVar, OutPutArrayApp, VarPath, ~] = ReAssignHousev2(DesStructVar,SourceArray,HouseID, xq, AppList,num2str(isubapp),VarPath) ;
                        SaveVar = 0;
                        OutPutArray.(AppRef) = OutPutArrayApp  ;
                    end
                catch
                    % If it does not work, then it means that this house
                    % does not possess the specific appliance so we can
                    % disregard it
                    continue;
                end
            else
            % Otherwise
                if nargin > 5
                    VarPath = [varargin{2} '.' VarName] ;
                    App     = varargin{1} ;
                else
                    VarPath = VarName ;
                    App     = VarName  ;
                end
                
                SourceArray  = SrcStructVar.(VarName) ;
                [DesStructVar, OutPutArray, VarPath, SaveVar] = ReAssignHousev2(DesStructVar,SourceArray,HouseID, xq, AppList, App, VarPath) ;
            end
            if SaveVar
                SaveVar = false ;
                Varsplit = split(VarPath,'.') ;
                switch length(Varsplit)
                    case 1
                        if isa(OutPutArray,'struct') || sum(ismember(Varsplit,AppList)) >= 1
                            if isa(OutPutArray,'table')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'double')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'logical')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'cell')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'char')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'timetable')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            else
                                 OutPutArrayNew = OutPutArray         ;                                 
                            end
                            AllApp = fieldnames(OutPutArray) ;
                            for fn = 1:length(AllApp) 
                                DesStructVar.(Varsplit{1})(fn) = OutPutArray.(AllApp{fn}) ;
                            end
                        else
                            DesStructVar.(Varsplit{1}) = OutPutArray ;
                        end
                    case 2
                        if isa(OutPutArray,'struct') || sum(ismember(Varsplit,AppList)) >= 1
                            AppPos = find(ismember(Varsplit,AppList)) ;
                            if isa(OutPutArray,'table')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'double')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'logical')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'cell')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'char')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'timetable')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            else
                                 OutPutArrayNew = OutPutArray         ;                                 
                            end
                            AllApp = fieldnames(OutPutArray) ;
                            for fn = 1:length(AllApp) 
                                switch AppPos
                                    case 1
                                        DesStructVar.(Varsplit{1})(fn).(Varsplit{2}) = OutPutArray.(AllApp{fn}) ;
                                    case 2
                                        DesStructVar.(Varsplit{1}).(Varsplit{2})(fn) = OutPutArray.(AllApp{fn}) ;
                                end
                            end
                        else
                            DesStructVar.(Varsplit{1}).(Varsplit{2}) = OutPutArray ;
                        end
                    case 3
                        if isa(OutPutArray,'struct') || sum(ismember(Varsplit,AppList)) >= 1
                            AppPos = find(ismember(Varsplit,AppList)) ;
                            if isa(OutPutArray,'table')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'double')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'logical')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'cell')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'char')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'timetable')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            else
                                 OutPutArrayNew = OutPutArray         ;                                 
                            end
                            AllApp = fieldnames(OutPutArray) ;
                            for fn = 1:length(AllApp) 
                                switch AppPos
                                    case 1
                                        DesStructVar.(Varsplit{1})(fn).(Varsplit{2}).(Varsplit{3}) = OutPutArray.(AllApp{fn}) ;
                                    case 2
                                        DesStructVar.(Varsplit{1}).(Varsplit{2})(fn).(Varsplit{3}) = OutPutArray.(AllApp{fn}) ;
                                    case 3
                                        DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3})(fn) = OutPutArray.(AllApp{fn}) ;
                                end
                            end
                        else
                            DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3}) = OutPutArray ;
                        end
                    case 4
                        if isa(OutPutArray,'struct') || sum(ismember(Varsplit,AppList)) >= 1
                            AppPos = find(ismember(Varsplit,AppList)) ;
                            if isa(OutPutArray,'table')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'double')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'logical')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'cell')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'char')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'timetable')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            else
                                 OutPutArrayNew = OutPutArray         ;                                 
                            end
%                             AllApp = fieldnames(OutPutArrayNew) ;
%                             for fn = 1:length(AllApp) 
                                fn = str2double(varargin{1}) ;
                                switch AppPos
                                    case 1
                                        DesStructVar.(Varsplit{1})(fn).(Varsplit{2}).(Varsplit{3}).(Varsplit{4}) = OutPutArrayNew.AllApp1 ;
                                    case 2
                                        DesStructVar.(Varsplit{1}).(Varsplit{2})(fn).(Varsplit{3}).(Varsplit{4}) = OutPutArrayNew.AllApp1 ;
                                    case 3
                                        DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3})(fn).(Varsplit{4}) = OutPutArrayNew.AllApp1 ;
                                    case 4
                                        DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3}).(Varsplit{4})(fn) = OutPutArrayNew.AllApp1 ;
                                end
%                             end
                        else
                            DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3}).(Varsplit{4}) = OutPutArray ;
                        end
                    case 5
                        if isa(OutPutArray,'struct') || sum(ismember(Varsplit,AppList)) >= 1
                            AppPos = find(ismember(Varsplit,AppList)) ;
                            if isa(OutPutArray,'table')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'double')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'logical')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'cell')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'char')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            elseif isa(OutPutArray,'timetable')
                                 OutPutArrayNew.AllApp1 = OutPutArray ;
                            else
                                 OutPutArrayNew = OutPutArray         ;                                 
                            end
                            AllApp = fieldnames(OutPutArray) ;
                            for fn = 1:length(AllApp) 
                                switch AppPos
                                    case 1
                                        DesStructVar.(Varsplit{1})(fn).(Varsplit{2}).(Varsplit{3}).(Varsplit{4}).(Varsplit{5}) = OutPutArray.(AllApp{fn}) ;
                                    case 2
                                        DesStructVar.(Varsplit{1}).(Varsplit{2})(fn).(Varsplit{3}).(Varsplit{4}).(Varsplit{5}) = OutPutArray.(AllApp{fn}) ;
                                    case 3
                                        DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3})(fn).(Varsplit{4}).(Varsplit{5}) = OutPutArray.(AllApp{fn}) ;
                                    case 4
                                        DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3}).(Varsplit{4})(fn).(Varsplit{5}) = OutPutArray.(AllApp{fn}) ;
                                    case 5
                                        DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3}).(Varsplit{4}).(Varsplit{5})(fn) = OutPutArray.(AllApp{fn}) ;
                                end
                            end
                        else
                            DesStructVar.(Varsplit{1}).(Varsplit{2}).(Varsplit{3}).(Varsplit{4}).(Varsplit{5}) = OutPutArray ;
                        end
                end
            end
        end
    elseif isa(SrcStructVar,'double')
        VarPath = varargin(2)  ;
        if strcmp(varargin(1),'App')
            SaveVar = false ;
        else
            SaveVar = true         ;
        end
        SourceArray = SrcStructVar ;
        if size(xq,1) == size(SourceArray,1)
            OutPutArray = table(xq,SourceArray,'VariableNames',{'Time','DataOutput'}) ;
        elseif (size(xq,1) - 1) == size(SourceArray,1)
            OutPutArray = table(xq(1:(end-1)),SourceArray,'VariableNames',{'Time','DataOutput'}) ;
        elseif size(xq,1) == size(SourceArray,2)
            OutPutArray = table(xq,SourceArray','VariableNames',{'Time','DataOutput'}) ;
        elseif (size(xq,1) - 1) == size(SourceArray,2)
            OutPutArray = table(xq(1:(end-1)),SourceArray','VariableNames',{'Time','DataOutput'}) ;
        elseif size(xq,1) < size(SourceArray,1)
            x = 'TO BE WRITTEN' ;
            OutPutArray = SourceArray ; 
        elseif size(xq,1) < size(SourceArray,2)   
            x = 'TO BE WRITTEN';
            OutPutArray = SourceArray ; 
        else
            OutPutArray = SourceArray ; 
        end
%         if nargin > 7
%             DesStructVar.(varargin{1}).(varargin{2})(varargin{3}).(HouseID).(VarName) = OutputArray ;
%         elseif nargin > 5
%             try
%                 VarName = split(varargin{2},'.') ;
%             catch
%                 VarName{1} = varargin{1} ;
%             end
%             VarPath = DesStructVar ;
%             for i = 1:length(VarName)
%                 VarPath = VarPath.(VarName{i}) ;
%             end
%             VarPath  = SrcStructVar  ;
% %             VarName                 = varargin{1} ;
% %             DesStructVar.(VarName)  = OutputArray ;
%         end    
    elseif isa(SrcStructVar,'logical')
        if strcmp(varargin(1),'App')
            SaveVar = false ;
        else
            SaveVar = true         ;
        end
        VarPath = varargin(2) ;
        OutPutArray  = SrcStructVar  ;
    elseif isa(SrcStructVar,'char')
        if strcmp(varargin(1),'App')
            SaveVar = false ;
        else
            SaveVar = true         ;
        end
        VarPath = varargin(2) ;
        OutPutArray  = SrcStructVar  ;
    elseif isa(SrcStructVar,'timetable')
        if strcmp(varargin(1),'App')
            SaveVar = false ;
        else
            SaveVar = true         ;
        end
        VarPath = varargin(2) ;
        OutPutArray  = SrcStructVar  ;
    elseif isa(SrcStructVar,'table')
        if strcmp(varargin(1),'App')
            SaveVar = false ;
        else
            SaveVar = true         ;
        end
        VarPath = varargin(2) ;
        OutPutArray  = SrcStructVar  ;
    elseif isa(SrcStructVar,'cell')
        if strcmp(varargin(1),'App')
            SaveVar = false ;
        else
            SaveVar = true         ;
        end
        VarPath = varargin(2) ;
        OutPutArray  = SrcStructVar  ;
    end
    try 
        OutPutArray ;
    catch
        x = 1;
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