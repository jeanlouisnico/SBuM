classdef workspace < handle

    properties
        wstype = 'caller'; % ['caller'] or 'base'
        verbose = 1; % interger (0: no verbose
        %            1: basic info
        %            2: warning when clear unknown variables)
    end % properties

    properties %(Hidden=true)
        % list of local variables that have been assigned through the
        % workspace
        localasgn

    end % properties (Hidden=true)

    events
        ClearEvent % method clearstrvar is invoked (clear variables)
    end

    methods
        % Constructor to create workspace object
        function obj = workspace(varargin)
            % CLASS workspace
            %
            % Purpose: create and manipulate variable names in the target
            %          workspace by using strings
            % Create workspace container syntax:
            %    ws=worskpace
            %    ws=workspace(wstype) % with wstype is 'caller' (default)
            %                         % or 'base'
            %    ws=workspace(..., Property1, Val1, ...)
            %
            % Modify properties
            %    ws=workspace(ws, Property1, Val1, ...)
            % Properties are 'wstype' or 'verbose'
            % Value for 'verbose' is interger
            %   0: no verbose
            %   1: basic info displayed [default]
            %   2: warning when clear unknown variables
            %
            % Example of usages:
            %   % Create variables on your workspace from strings
            %   ws('data1', 'y') = load('data1.txt')
            %   ws{'data1', 'y'} = load('data1.txt') % comma is neeed
            %   ws.('data1') = load('data1.txt')
            %   ws.('data1')(10:end-10)=0 % data1 must exists
            %   ws{:}(1:10) = rand(1,10) % assign a part of all variables
            %
            %   % Accessing variables on your workspace from strings
            %   rhs = ws.('data1')(1:30)
            %   [dtruncated ytruncated] = ws{'data1', 'y'}(1:60)
            %   % Note: unreferenced (to variables) expressions are allowed
            %   [d newy] = ws('data1', data1.^2)
            %   % A string expression must be enclosed in double quote
            %   d = ws('data1') % returns the *value* of variable data1
            %   d = ws('"data1"') % returns the *string* 'data1'
            %   [a b] = ws{:}(1:10) % return truncated subarray
            %                       % of all assigned variables
            %
            % Methods:
            %   varnames = getstrvar(ws) % get variable names has been
            %                            % assigned
            %   clearstrvar(ws) % clear variable names has been assigned
            %   clearstrvar(ws, var1, ...) % clear specified variables
            %   clearstrvar(..., wildchar, '-regexp', p1, p2, ...)
            %     % Clear selected variables that match wilchard (X*)
            %     % or regular expressions with pattern p1, p2, ...
            %
            % Restriction: Matlab version 7.7 (R2006b) and ulterior
            %
            % Author: Bruno Luong <brunoluong@yahoo.com>
            % Original: 23/Feb/2009 (Bug corrected)
            %           24/Feb/2009: can clear specified variables
            %                   + wildcard/regexp to filter clear variables
            %           27/Feb/2008: Java containers map
            %                        Backward compatible (test with 2006B)

            options = varargin;

            % Create containers Maps
            if isempty(obj.localasgn)
                if containersMapdefined()
                    % containers defined from 2008B
                    obj.localasgn = containers.Map('uniformvalues', ...
                                                   true);
                else
                    % Java containers
                    obj.localasgn = java.util.Hashtable;
                end
            end

            % Sparse first input
            if nargin>=1
                % valid wstype
                if (ischar(varargin{1}) && ...
                        (strcmpi(varargin{1},'caller') || ...
                        strcmpi(varargin{1},'base')))
                    obj.wstype = varargin{1};
                    options(1) = []; % delete from the list
                elseif strcmp(class(varargin{1}),'workspace')
                    % modifyng workspace
                    % nothing to do beside this
                    obj = varargin{1};
                    options(1) = []; % delete from the list
                end
            end

            % Retrieve the list of properties
            privatepropnames = fieldnames(obj);
            % delete last underscore
            publicpropnames = regexprep(privatepropnames,'\_$','');
            % propnames = properties('workspace');

            % Check validity of input properties
            for propin=options(1:2:end)
                if isempty(strmatch(lower(propin{1}), publicpropnames))
                    error('workspace: unknown property ''%s''', propin{1});
                end
            end

            % Assign properties
            for k=1:length(publicpropnames)
                privatefieldk=privatepropnames{k};
                publicfieldk=regexprep(privatefieldk,'\_$','');
                obj.(privatefieldk) = getvarginopt(options, publicfieldk, ...
                    obj.(privatefieldk));
            end
%% PRINT THE PATH SELECTED
%             % print some info
%             if obj.verbose
%                 fprintf('workspace ''%s'' (ws) usage:\n', obj.wstype);
%                 fprintf('\tws.(name)(...) = value;\n');
%                 fprintf('\trhs = ws.(name)(...);\n');
%                 fprintf('\thelp workspace %% for more\n');
%             end
        end % constructor workspace

        % Assign verbose
        function obj = set.verbose(obj, val) %#ok
            if isscalar(val)
                obj.verbose = val;
            else
                error('workspace: verbose must be a scalar');
            end
        end

        % Assign wstype
        function obj = set.wstype(obj, val)
            if ischar(val) && (strcmpi(val,'caller') || strcmpi(val,'base'))
                obj.wstype = val;
            else
                error('workspace: wstype must be ''base'' or ''caller''');
            end
        end

        function varnames = getstrvar(obj, varargin)
            % Implementation for workspace ws:
            %   varnames = getstrvar(ws)
            % purpose: Get the names of variables that has been assigned

            [listvar pattern] = regexppattern(varargin{:});

            if isempty(listvar)
                % Get the list of variables
                if containersMapdefined()
                    varnames = obj.localasgn.keys;
                else
                    varnames = alljavakeys(obj.localasgn);
                end
            else
                % Check if they are known by ws
                if containersMapdefined()
                    isVar = obj.localasgn.isKey(listvar);
                else
                    vknown = alljavakeys(obj.localasgn);
                    isVar = cellfun(@(v) ~isempty(strmatch(v, vknown)), ...
                        varargin);
                end
                varnames = varargin(isVar);

                % Warning if clear variables in unknown
                if any(~isVar) && obj.verbose>1
                    vlist = sprintf('''%s'' ', varargin{~isVar});
                    warning('workspace:UnknownVariables', ...
                        'Unknown variable(s) to workspace: %s\n', vlist);

                end

            end

            % Filtering: Select those who match regular expressions (by OR)
            if ~isempty(pattern)
                keep = false(size(varnames));
                for p=pattern
                    idx = regexp(varnames,p,'once');
                    match = ~cellfun(@isempty, idx);
                    keep = keep | match; % OR between selections
                end
                varnames = varnames(keep);
            end

            % nested function regexppattern, separate the list of variables
            % and regular expressions from the input argument list
            function [listvar pattern] = regexppattern(varargin)

                % Look for where the string '-regexp' appears
                regpos = ~cellfun(@isempty,strfind(varargin,'-regexp'));
                % Find it
                if any(regpos)
                    pos1 = find(regpos,1,'first');
                    regexpflag = ~regpos;
                    regexpflag(1:pos1)=false;
                    listvar = varargin(1:pos1-1);
                    pattern = varargin(regexpflag);
                else
                    listvar = varargin;
                    pattern = {};
                end

                % Look for wildcard '*'
                starpos = ~cellfun(@isempty,strfind(listvar,'*'));
                wildcardlist = listvar(starpos);
                % Add '^' at the begining
                wildcardlist = cellfun(@(p) ['^' p], wildcardlist, ...
                    'UniformOutput', false);
                % move the string with wildcard to pattern list
                [listvar pattern] = deal(listvar(~starpos), ...
                    [pattern wildcardlist]);
            end % regexppattern
        end % getstrvar

        function obj = clearstrvar(obj, varargin)
            % Implementation for workspace ws:
            %   ws=clearstrvar(ws);
            % purpose: Clear variables that has been assigned
            varnames=getstrvar(obj, varargin{:});
            if ~isempty(varnames)
                % add a two quotes and comma
                vlist = sprintf('''%s'', ', varnames{:});
                % remove trailing space-comma
                vlist = vlist(1:end-2);
                % clear-command string
                clearcmd = ['clear(' vlist ')'];
                evalin(obj.wstype, clearcmd);
                % Clear variables from the internal list
                if containersMapdefined()
                    obj.localasgn.remove(varnames);
                else
                    for k=1:length(varnames)
                        obj.localasgn.remove(varnames{k});
                    end
                end
                if obj.verbose
                    fprintf('\tPerform: %s\n', clearcmd);
                end
                % Broadcast notice of ClearEvent
                notify(obj,'ClearEvent');
            end
        end % clearstrvar


        function obj = subsasgn(obj, s, value)
            % Implementation for workspace ws:
            %   ws('data1', 'y') = load('data1.txt')
            %   ws{'data1', 'y'} = load('data1.txt') % comma is neeed
            %   ws.('data1') = load('data1.txt')
            %   ws.('data1')(10:end-10)=0 % data1 must exists
            %   ws{:}(1:10) = rand(1,10) % assign a part of all variables

            if isstruct(s) && isfield(s,'type')
                switch s(1).type
                    case {'()' '{}'},
                        subs = s(1).subs;
                    case ('.')
                        subs = {s(1).subs};
                end

                subs = subsprocess(obj, subs);

                % Loop over variables in parenthesis
                for k=1:length(subs)
                    vname = subs{k};
                    if ischar(vname)
                        % assign workspace own properties
                        if isWorkspaceProperty(obj, vname)
                            ss = [substruct('.',vname) s(2:end)];
                            obj = builtin('subsasgn', obj, ss, value);
                            return          
                        end                      
                        if length(s)>1 % assign subsref of variables
                            tmp = evalin(obj.wstype, vname);
                            val = builtin('subsasgn', tmp, s(2:end), value);
                        else
                            val = value;
                        end
                        assignin(obj.wstype, vname, val);
                        % Keep track of names of assigned variables locally
                        if containersMapdefined()
                            obj.localasgn(vname) = vname;
                        else
                            obj.localasgn.put(vname,vname);
                        end
%% PRINT THE VARIABLE VALUE ASSIGNED
%                         if obj.verbose
%                             fprintf('\tValue assigned to %s\n', vname);
%                         end
%%
                    end
                end % for-loop

            end
        end %subsasgn

        function varargout = subsref(obj, s)
            % Implementation for workspace ws:
            %   % Accessing variables on your workspace from strings
            %   rhs = ws.('data1')(1:60)
            %   [dtruncated ytruncated] = ws{'data1', 'y'}(1:60)
            %   % Note: unreferenced (to variables) expressions are allowed
            %   [d newy] = ws('data1', data1.^2)
            %   % A string expression must be enclosed in double quote
            %   d = ws('data1') % returns the *value* of variable data1
            %   d = ws('"data1"') % returns the *string* 'data1'
            %   [a b] = ws{:}(1:10) % return truncated subarray
            %                       % of all assigned variables

            vout = cell(nargout);

            if isstruct(s) && isfield(s,'type')
                switch s(1).type
                    case {'()' '{}'},
                        subs = s(1).subs;
                    case ('.')
                        subs = {s(1).subs};
                end

                subs = subsprocess(obj, subs);

                % Loop over the list of variables (only parentheis or
                % curly-braket syntax allow a list)
                for k=1:length(subs)
                    vname = subs{k};
                    if ischar(vname)
                        % retreive workspace own properties
                        if isWorkspaceProperty(obj, vname)
                            ss = [substruct('.',vname) s(2:end)];
                            val = builtin('subsref', obj, ss);
                        elseif isWorkspaceMethod(obj, vname)
                            mfun = str2func(vname);
                            if length(s)==1
                                argfun = {};
                            elseif length(s)==2 && strcmp(s(2).type,'()')
                                argfun = s(2).subs;
                            else
                                error('workspace: invalid syntax');
                            end
                            varargout{k} = mfun(obj, argfun{:});
                            return
                        elseif vname(1)=='"' &&  vname(end)=='"'
                        % string, must be passed as '"AString"' (double
                        % quote) by convention
                        
                            val = vname(2:end-1);
                        else
                            val = evalin(obj.wstype,vname);
                        end
                    else
                        val = vname;
                    end
                    if length(s)==1
                        vout{k} = val;
                    else % retreive subsref of variable
                        vout{k} = builtin('subsref', val, s(2:end));
                    end
                end % for-loop

            end

            varargout = vout;

        end % subsref

    end % methods
    
    methods %(Access=protected)
        % Check if name is workspace property
        function yesno = isWorkspaceProperty(obj, name)
            if ischar(name) && ~isempty(name)
                % Get the list of properties
                privatepropnames = fieldnames(obj);
                yesno = ~isempty(strmatch(name, privatepropnames, 'exact'));
            else
                yesno = false;
            end
        end
        function yesno = isWorkspaceMethod(obj, name)
            if ischar(name) && ~isempty(name)
                % Get the list of properties
                methodnames = methods(obj);
                yesno = ~isempty(strmatch(name, methodnames, 'exact'));
            else
                yesno = false;
            end
        end
    end
    
end % workspace classdef

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% private nested function
function value = getvarginopt(argin, keyword, default)
% function value = getvarginopt(argin, keyword, default)
%
% Try to parse the argin cell list of the form:
%   { option1, value1, ... }
% to match keyword
% If keyword is not found, then return DEFAULT as value
% History: Original: 13/Jan/2009, Bruno Luong <brunoluong@yahoo.com>

if nargin<3
    default = [];
end

if ~iscell(keyword)
    keyword = {keyword};
end

% remove space and trim
optnames = strtrim(upper(argin(1:2:end)));
keyword = strtrim(upper(keyword));

values = argin(2:2:end);

value = default;

for k=1:length(keyword)
    kw = keyword{k};
    where = strmatch(kw,optnames);
    if ~isempty(where)
        value = values{where};
        return
    end
end

end % getvarginopt(argin, keyword, default)

% Process subs index.
function subs = subsprocess(obj, subs)
% if ':', return all the variable names
if length(subs)==1 && ischar(subs{1}) && strcmp(subs{1},':')
    subs = getstrvar(obj);
end
end

% Check if built-in containers.Map exists
function yesno = containersMapdefined
persistent flag
if isempty(flag)
    s=which('containers.Map');
    flag=ischar(s) && ~isempty(findstr('built-in',s));
end
% already check, return the persistent result
yesno=flag;
end


function list=splitstr(s)
s = [s ','];
comma=[0 find(s==',')];
l=comma(2:end)-comma(1:end-1);
c=mat2cell(s,1,l);
list=cellfun(@(s) strtrim(s(1:end-1)), c, 'UniformOutput', 0);
end

% Return the cell list of key in Java containers Maps;
function varnames = alljavakeys(javaMaps)
javakeys=char(javaMaps.keySet);
javakeys=javakeys(2:end-1); % remove '[' and ']'
if isempty(javakeys)
    varnames = {};
else
    % split them
    varnames=splitstr(javakeys);
    %varnames=strtrim(regexp(javakeys,',','split'));
end
end
% End of workspace.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
