function [data, addedHouses] = importXMLSavedHouse(varargin)
% 
% Load the XML file that you want to import

if nargin == 0
    filter = {'*.xml'};
    [file, path] = uigetfile(filter);
    if path == 0; return; end
    if strcmp(path(end),filesep)
       LoadFullPath = [path,file] ;
    else
       LoadFullPath = [path,filesep,file];
    end
    data.AppliancesList      = ApplianceListfunc ;
    HouseNbr = 0 ;
else
    LoadFullPath            = varargin{1} ;
    data.AppliancesList     = varargin{2} ;
    HouseNbr                = varargin{3} ;
end

% Read the XML file
tree = xml_read(LoadFullPath);

AllElements = fieldnames(tree) ;


for i = 1:length(AllElements)
    for ik = 1:size(tree.Element, 1)
        ElementName     = tree.Element(ik).CONTENT      ;
        ElementContent  = tree.Element(ik).subElement   ; %Struct array

        for iHouse = 1:numel(ElementContent)
            if ik == 103
                x = 1;
            end
            HouseNbr2Input  = iHouse + HouseNbr ;   
            VarNameHouse = ['House',num2str(HouseNbr2Input)] ;
            addedHouses{iHouse} = VarNameHouse ;
            try 
                test = data.SummaryStructure.(VarNameHouse) ;
            catch
                data.SummaryStructure.(VarNameHouse) = [] ;
            end
            datain = unloadstruct(ElementContent(iHouse), data.AppliancesList, data.SummaryStructure.(VarNameHouse), ElementName, HouseNbr2Input, VarNameHouse) ;
            field = fieldnames(datain) ;
            data.SummaryStructure.(VarNameHouse).(field{1}) = datain.(field{1}) ;
         end
    end
end

    function dataout = unloadstruct(ElementContent, AppList, datain, VarName, HouseNbr2Input, VarNameHouse)
        if isfield(ElementContent,'CONTENT')
            % This is the last layer and we can start dispatching the
            % result.
            GetallInfo      = ElementContent.ATTRIBUTE;
            GetallFields    = fieldnames(GetallInfo) ;
            
            for mm = 2:numel(GetallFields)
                Field2retrieve = GetallFields{mm} ;
                Value2Input = GetallInfo.(Field2retrieve) ;

                if numel(GetallFields) > 2 || sum(strcmp(VarName, AppList(:,3))) >= 1
                    % In this case, store each variable as a
                    % cell
                    if isnumeric(Value2Input)
                        Value2Input = num2str(Value2Input) ;
                    end
                    if any(strcmp(VarName,AppList(:,4)))
                        % This means that this is a class
                        % variable
                        % Get the appliance variable name
                        AppLoc = find(strcmp(VarName, AppList(:,4))==1) ;
                        AppName  = AppList{AppLoc,3} ;

                        if isempty(AppName)
                            % This means that this is the
                            % lighting system
                            % In this case, do nothing
                        else
                            InfoApp = datain.(AppName) ;
                        end
                        if mm > (1 + numel(InfoApp))
                            continue
                        end
                    else
                        %This means that this is a appliance
                        %variable name 
                        if mm > 2 && strcmp(Value2Input,'0')
                            continue
                        end
                    end
                    
                    dataout.(VarName)(mm-1) = {Value2Input} ;
                elseif strcmp(VarName,'HouseNbr')
                    % Only this variable is stroed as a double
                    dataout.(VarName) = HouseNbr2Input ;
                elseif strcmp(VarName,'Headers')
                    % Only this variable is stroed as a double
                    dataout.(VarName) = VarNameHouse ;
                else
                    % In this case, store each variable as a
                    % string
                    if isnumeric(Value2Input)
                        Value2Input = num2str(Value2Input) ;
                    end
                    dataout.(VarName) = Value2Input ;
                end
            end
        else
            if isa(ElementContent, 'struct')
                % Get fieldnames
                ElementContentv2 = fieldnames(ElementContent) ;
                for im = 1:length(ElementContentv2)
                    if ~strcmp(ElementContentv2{im},'ATTRIBUTE')
                        ElementContentName = ElementContent.(ElementContentv2{im}) ;
                        if ~isempty(ElementContentName)
                            dataout.(VarName).(ElementContentv2{im}) = ElementContentName;
                        end
                    end
                end
            elseif isa(ElementContent, 'char')    
                dataout = ElementContent ;
            end
        end
    end
end