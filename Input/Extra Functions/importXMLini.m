function data = importXMLini(varargin)
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
else
    LoadFullPath = varargin{1} ;
end

% Read the XML file
tree = xml_read(LoadFullPath);

AllElements = fieldnames(tree) ;
data.DatabaseApp    = [] ;
data.ApplianceMax   = {} ;
data.AppliancesList = {} ;
for i = 1:length(AllElements)
    AllsubElements = fieldnames(tree.(AllElements{i})) ;
    for ik = 1:length(AllsubElements)
        switch AllsubElements{ik}
            case {'Defaultvalue', 'Unit',  'Tooltip', 'Comparefield', 'Defaultcreate', 'Type', 'LowLimit', 'HighLimit', 'Exception'}
                if any(ismember(tree.(AllElements{i}).(AllsubElements{ik}), char([10 13])))
                    field = splitlines(tree.(AllElements{i}).(AllsubElements{ik})) ;
                    if strcmp(AllsubElements{ik}, 'Comparefield')
                        data.datastructure.(AllElements{i}).(AllsubElements{ik}){1,1} = field ;
                        data.datastructure.(AllElements{i}).(AllsubElements{ik}){1,2} = field ;
                    else
                        data.datastructure.(AllElements{i}).(AllsubElements{ik})    = field ;
                    end
                else
                    data.datastructure.(AllElements{i}).(AllsubElements{ik})    = tree.(AllElements{i}).(AllsubElements{ik}) ; 
                end

            case {'LongName', 'ShortName', 'Rate', 'ClassName'}
                data.datastructure.(AllElements{i}).(AllsubElements{ik})    = tree.(AllElements{i}).(AllsubElements{ik}) ;
                if ~contains(tree.(AllElements{i}).LongName,{' class', ' Class'})
                    if strcmp(AllsubElements{ik}, 'LongName')
                        data.AppliancesList{end + 1,1}                                = tree.(AllElements{i}).LongName;
                    elseif strcmp(AllsubElements{ik}, 'ShortName')
                        data.AppliancesList{end,3}                                    = tree.(AllElements{i}).ShortName;
                    elseif strcmp(AllsubElements{ik}, 'Rate')
                        data.AppliancesList{end,2}                                    = tree.(AllElements{i}).Rate;
                    elseif strcmp(AllsubElements{ik}, 'ClassName')
                        data.AppliancesList{end,4}                                    = tree.(AllElements{i}).ClassName;
                    end    
                end
            case {'MaxUse', 'Temp', 'TimeUsage', 'Weekdistr', 'Weekdayweight', 'Weekdayacc', 'Delay', 'Power'}
                s.(AllsubElements{ik})  = tree.(AllElements{i}).(AllsubElements{ik}) ;
            case 'AppProfile'
                Project = fieldnames(tree.(AllElements{i}).(AllsubElements{ik})) ;
                for ij = 1:length(Project)
                    if ~any(strcmp(Project{ij},data.DatabaseApp))
                        if isempty(data.DatabaseApp)
                            data.DatabaseApp = Project(ij) ;
                        else
                            data.DatabaseApp{end+1} = Project{ij} ;
                        end
                    end
                    ProjectName = Project{ij} ;
                    data.ApplianceSpec.(AllsubElements{ik}).(AllElements{i}).(ProjectName) = tree.(AllElements{i}).(AllsubElements{ik}).(ProjectName)  ;
                end
            case 'ApplianceMax'
                if isempty(data.ApplianceMax)
                    data.ApplianceMax          = [{tree.(AllElements{i}).ShortName} num2cell(tree.(AllElements{i}).(AllsubElements{ik}))'];
                else
                    data.ApplianceMax(end + 1,:) = [{tree.(AllElements{i}).ShortName} num2cell(tree.(AllElements{i}).(AllsubElements{ik}))'];
                end
            otherwise
                
        end 
    end
    if isempty(strfind(AllElements{i},'cl') == 1)
        C = [s.MaxUse   s.Temp     s.TimeUsage    s.Weekdistr     s.Weekdayweight    s.Weekdayacc     s.Delay     s.Power];
        data.Detail_Appliance.(AllElements{i}) = array2table(C,'VariableNames',{'MaxUse'    'Temp'    'TimeUsage'   'Weekdistr'    'Weekdayweight'    'Weekdayacc'    'Delay'    'Power'}) ;
    end
end
% Add the lighting system that is not saved in the ini file
data.AppliancesList{end+1,1}    = 'Lighting System';
data.AppliancesList{end,2}      = 'Rate';
data.AppliancesList{end,3}      = '';
data.AppliancesList{end,4}      = 'clLight';
