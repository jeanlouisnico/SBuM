function [cellarray] = orderalphacellarray(cellarray,varargin)

defaultStart = 1 ;
p = inputParser;
validinput = @(x) iscell(x);
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);

cellarray(cellfun(@isempty,cellarray)) = {'more...'} ;

addRequired(p,'cellarray',validinput);
addOptional(p,'Start',defaultStart,validScalarPosNum);
addOptional(p,'End',defaultStart,validScalarPosNum);
addOptional(p,'Col',defaultStart,validScalarPosNum);

%cellarray = cellfun(@num2str,cellarray,'un',0) ;
        if nargin == 1
            Start = 1 ;
            End = 'end' ;
            Col = size(cellarray,2) ;
            ColStart = 1 ;
        elseif nargin == 2
            Start = varargin{1} ;
            End = 'end' ;
            Col = size(cellarray,2) ;
            ColStart = 1 ;
        elseif nargin == 3
            Start = varargin{1} ;
            End = varargin{2} ;
            Col = size(cellarray,2) ;
            ColStart = 1 ;
        elseif nargin == 4 
            Start = varargin{1} ;
            End = varargin{2} ;
            Col = varargin{3} ;
            ColStart = Col ;
        else
            warning('Too many input arguments')
            return;
        end
        for i=ColStart:Col
            if strcmp(End,'end')
                Col2convert = cellarray(Start:end,i);
                [cellarray(Start:end,i)] = convert(Col2convert) ;
            else
                Col2convert = cellarray(Start:End,i);
                [cellarray(Start:End,i)] = convert(Col2convert) ;
            end
        end
    function [test] = convert(Col2convert)
        [nrows, ~] = size(Col2convert);   
                
        a = cellfun('isclass', Col2convert, 'char') ;
        b = cellfun('isclass', Col2convert, 'double') ;
        suma = sum(a);
        sumb = sum(b);

        if suma == nrows
            % Check to see if cell array 'B' contained only numeric values.
             newarray = sort(Col2convert) ;
        elseif sumb == nrows
              % If the cells in cell array 'B' contain numeric values retrieve the cell
              % contents and change 'B' to a numeric array.
              bprimenum = [Col2convert{:}];
              bprimenum = sort(bprimenum) ;
              newarray = num2cell(bprimenum) ;
        else
            warning('This column is completed first in numerical order then in string order.')
            % First sort the numeric values
                bprime = Col2convert(find(b==1)) ;
                bprimenum(:,1) = [bprime{:}] ;
                bprimenum = sort(bprimenum) ;
                bordered = num2cell(bprimenum) ;
            % Sort the string values
                aprime = Col2convert(find(a==1)) ;
                aordered = sort(aprime) ;
            % merge the 2 cell arrays  
                newarray = [bordered; aordered];
        end
        test = newarray  ;
    end
end %orderalphacellarray