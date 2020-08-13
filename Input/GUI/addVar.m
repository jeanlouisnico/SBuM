function addVar(varSel,varDetail,value2copy, List)
    ExistingVar = uimulticollist(List,'string') ;
    if any(strcmp(varSel,ExistingVar(:,1)))
        % The variable is already listed
        rowIndex = find(strcmp(varSel,ExistingVar(:,1)) == 1 ) ;
        if isa(value2copy,'cell')
            value2copy = 'Too many inputs' ;
        end
        uimulticollist( List, 'changeItem', value2copy, rowIndex, 4 )
    else
        % The variable is not yet listed
        if ~isa(value2copy,'string') && ~isa(value2copy,'char')
            warning('Error') ;
        end
        if isa(value2copy,'cell')
            value2copy = 'Too many inputs' ;
        elseif isa(value2copy,'struct')
            value2copy = 'Too many inputs' ;
        end
        rowItems = { varDetail.ShortName , varDetail.LongName, varDetail.Unit, value2copy, varDetail.Tooltip} ;
        uimulticollist( List, 'addRow', rowItems)
    end