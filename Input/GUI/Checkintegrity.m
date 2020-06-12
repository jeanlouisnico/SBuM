function [ErrorList] = Checkintegrity(simuldata, datastructure)
    Housenumber = fieldnames(simuldata);
    Eachfield = fieldnames(datastructure);
%     for i = 1:numel(Eachfield)
%        % Restructure the variable for saving it
%        s.(Eachfield{i}) = {};
%     end
%     
%         Allfield = fieldnames(data.datastructure) ;
%         for i = 1:numel(fieldnames(data.datastructure))
%         	ndfs = data.datastructure.(Allfield{i}).Default ;
%         end
validScalarPosNumException = @(x,LowLimit,HighLimit,Exception) isnumeric(x) && isscalar(x) && ((x >= LowLimit && x <= HighLimit) || (x==Exception));   
validScalarPosNumNoException = @(x,LowLimit,HighLimit) isnumeric(x) && isscalar(x) && (x >= LowLimit && x <= HighLimit);   

validdateNumNoException = @(x,LowLimit,HighLimit)  datenum(datetime(x,'InputFormat','dd/MM/yyyy')) >= datenum(datetime(LowLimit,'InputFormat','dd/MM/yyyy')) &&  datenum(datetime(x,'InputFormat','dd/MM/yy')) <= datenum(datetime(HighLimit,'InputFormat','dd/MM/yyyy')) ; 
space = {' '};
ErrorList = {};
      for i = 1:numel(Housenumber)
           % Check each field of each house
           for ii = 1:numel(Eachfield)
               % Get the data type
               DTField = datastructure.(Eachfield{ii}) ;
               if isfield(simuldata.(Housenumber{i}), Eachfield{ii})
                   if ~strcmp(Eachfield{ii},'Appliances')
                       DatatoCheck = simuldata.(Housenumber{i}).(Eachfield{ii}) ;
        %                if strcmp(Eachfield{ii},'ContElec')
        %                    x = 1
        %                end
                       Errormessage = {} ;
                       switch DTField.Type
                           case 'double'
                               DatatoCheck = str2double(DatatoCheck);
                               Validoutput = zeros(1,numel(DatatoCheck)) ;
                               for ij = 1:numel(DatatoCheck)
                                   TrempData2Check = DatatoCheck(ij) ;
                                   if isempty(DTField.Exception)
                                       Validoutput(ij) = validScalarPosNumNoException(TrempData2Check,DTField.LowLimit,DTField.HighLimit) ;
                                   else
                                       Validoutput(ij) = validScalarPosNumException(TrempData2Check,DTField.LowLimit,DTField.HighLimit,DTField.Exception) ;
                                   end
                               end
                               Validoutput = sum(Validoutput) ;
                               if Validoutput == 0
                                   if TrempData2Check < DTField.LowLimit
                                       VarSize = 'greater of equal to' ;
                                       VarVal  = DTField.LowLimit              ;
                                   elseif TrempData2Check > DTField.HighLimit
                                       VarSize = 'smaller of equal to' ;
                                       VarVal  = DTField.HighLimit             ;
                                   else
                                       VarSize = 'defined accordingly' ;
                                   end
                                   Errormessage(end+1) = strcat({'The input data should should be'},space,{VarSize},space,{num2str(VarVal)});
                               end
                           case 'string'
                               Validoutput = 1 ;
                           case 'cell'
                               if isa(DatatoCheck,'cell')
                                   for ij = 1:numel(DatatoCheck)
                                        Validoutput(ij) = ~isempty(find(strcmp(DTField.Exception,DatatoCheck{ij}))) ;
                                   end
                                   Validoutput = sum(Validoutput) ;
                               else
                                   Validoutput = ~isempty(find(strcmp(DTField.Exception,DatatoCheck))) ;
                               end

                               if Validoutput == 0
                                   if size(DTField.Exception,1) > 1
                                       ExceptionList = DTField.Exception' ;
                                   else
                                       ExceptionList = DTField.Exception ;
                                   end
                                   Errormessage(end+1) = strcat({'The Variable was not set properly. Variable set to:'},space,{DatatoCheck},space,{'Valid data are:'},space);
                                   for el = 1:numel(ExceptionList)
                                       if el == (numel(ExceptionList) - 1)
                                           Errormessage(end+1) = strcat(Errormessage,ExceptionList(el),', or',space) ;
                                       elseif el == numel(ExceptionList)
                                           Errormessage(end+1) = strcat(Errormessage,ExceptionList(el),'.');
                                       else
                                           Errormessage(end+1) = strcat(Errormessage,ExceptionList(el),',',space) ;
                                       end
                                   end
                               end
                           case 'date'
        %                        if data.DvptMode == 0
        %                            Validoutput = 1 ;
                               if isempty(DTField)
                                   Validoutput = validdateNumNoException(DatatoCheck,DTField.LowLimit,DTField.HighLimit) ;
                               else
                                   Validoutput = validdateNumNoException(DatatoCheck,DTField.LowLimit,DTField.HighLimit) ; 
                               end
                               if strcmp(Eachfield{ii},'StartingDate')
                                   DatatoCheckED = simuldata.(Housenumber{i}).EndingDate ;
                                    [~,SDate] = checkdateentry(DatatoCheck)   ;
                                    [~,EDate] = checkdateentry(DatatoCheckED) ;
                                    if SDate > EDate
                                        Validoutput = 0 ;
                                        Errormessage(end+1) = {'Ending date finishes before the starting date. Starting date must be prior than the ending date of the simulation.'};
                                    end
                               end

                               if Validoutput == 0
                                   LowDate = datestr(datetime(DTField.LowLimit,'InputFormat','dd/MM/yyyy'));
                                   HighDate = datestr(datetime(DTField.HighLimit,'InputFormat','dd/MM/yyyy'));
                                   Errormessage(end+1) = strcat({'The input date should be comprised between'},space,{LowDate},space,{'and'},space,{HighDate});
                               end
                       end
                       if Validoutput == 0
                           for ierror = 1:numel(Errormessage)
                               ErrorListNew = {Housenumber{i} Eachfield{ii} Errormessage{ierror}};
                               ErrorList = [ErrorList;ErrorListNew] ;
                           end
                       end
                   end
               end
           end
      end
end