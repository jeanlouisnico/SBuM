function [data] = CheckAppliances(simuldata, datastructure, data)
    Housenumber = fieldnames(simuldata);
    Eachfield   = fieldnames(datastructure);

      for i = 1:numel(Housenumber)
           % Check each field of each house
           for ii = 1:numel(Eachfield)
               % Get the data type
               DTField = datastructure.(Eachfield{ii}) ;
               if contains(DTField.LongName,'Class')
                   continue; % By pass checking all the fields of class that are from the previous version of the model.
               end
               try
                  if contains(DTField.ClassName,'cl')
                       continue; % By pass checking all the fields of class that are from the previous version of the model.
                  end 
               catch
                   % Nothing happens, just continues
               end
               if isfield(simuldata.(Housenumber{i}), Eachfield{ii})
                   if strcmp(Eachfield{ii},'Appliances')
                       % If this is an appliance then check that all
                       % self-defined rate are set in the selfDefined
                       % variable
                       DatatoCheck = simuldata.(Housenumber{i}).(Eachfield{ii}) ;
                       AppNames = fieldnames(DatatoCheck) ;
                       for iApp = 1:length(AppNames)
                           App2Check = DatatoCheck.(AppNames{iApp}) ;
                           if strcmp(App2Check.Class, 'Self-defined')
                               if ~isfield(simuldata.(Housenumber{i}).SelfDefinedAppliances, App2Check.SN)
                                    data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).StandBy = 0  ;
                                    data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).Rate = 0  ;
                                    data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).Sleep = 0  ;
                                    warning(['Self defined appliance ' App2Check.SN ' in ' Housenumber{i} ' was set to 0 as it was missing']) ;
                               elseif ~isfield(simuldata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN), App2Check.DB)
                                    data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).StandBy = 0  ;
                                    data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).Rate = 0     ;
                                    data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).Sleep = 0    ;
                                    warning(['Self defined appliance ' App2Check.SN ' in ' Housenumber{i} ' was set to 0 as it was missing']) ;
                               else
                                   if ~isfield(simuldata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB), 'StandBy')
                                       data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).StandBy = 0  ;
                                       warning(['Self defined appliance ' App2Check.SN ' in ' Housenumber{i} ' was set to 0 as it was missing']) ;
                                   end
                                   if ~isfield(simuldata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB), 'Rate')
                                       data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).Rate = 0  ;
                                       warning(['Self defined appliance ' App2Check.SN ' in ' Housenumber{i} ' was set to 0 as it was missing']) ;
                                   end
                                   if ~isfield(simuldata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB), 'Sleep')
                                       data.Simulationdata.(Housenumber{i}).SelfDefinedAppliances.(App2Check.SN).(App2Check.DB).Sleep = 0  ;
                                       warning(['Self defined appliance ' App2Check.SN ' in ' Housenumber{i} ' was set to 0 as it was missing']) ;
                                   end
                               end
                           end
                       end
                   end
               end
           end
      end
end
