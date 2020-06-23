function App = App10sec(varargin)

    if nargin > 0
        App         = varargin{1} ;
        Time_Sim    = varargin{2} ;
        TimeStep    = Time_Sim.MinperIter * 60 ;
        % array2timetable(Power_prod1','Timestep',seconds(Time_Sim.MinperIter * 60),'VariableNames',{'DataOutput'},'StartTime',stime) ;
    else
        [file,path] = uigetfile;
        %%%
        if file == 0; return; end

        App = load([path file]) ;
        App = App.App ;
    end

    GetData = App.Info ;
    AllApps = fieldnames(GetData) ;

    for i = 1:length(AllApps)
        HouseList = fieldnames(GetData.(AllApps{i})) ;
        for io = 1:size(GetData.(AllApps{i}),2)
            for ij = 1:length(HouseList)
                if ~isempty(GetData.(AllApps{i})(io).(HouseList{ij}))
                    stime               = datetime(Time_Sim.StartDate.(HouseList{ij}),'ConvertFrom','datenum')  ;
                    ActionQtyStep       = GetData.(AllApps{i})(io).(HouseList{ij}).ActionQtyStep  ;
                    New10sTime          = ConvertTimeTable(ActionQtyStep, TimeStep, stime)    ;
    %                 New10sTime          = table2timetable(ActionQtyStep) ;
                    App_Energy10scell   = GetData.(AllApps{i})(io).(HouseList{ij}).App_Energy10scell  ;
        %             App_Energy10sReTime = retime(New10sTime,'regular','fillwithconstant','TimeStep',seconds(10));
                    TimeAction          = New10sTime.Time(New10sTime.DataOutput>0);
            %         TempArray           = App_Energy10sReTime ;
                    if ~(TimeAction(1) == New10sTime.Time(1))
                        TempArray = timetable(New10sTime.Time(1), 0) ;
                        TempArray.Properties.VariableNames = {'DataOutput'} ;
                    end
                    if strcmp(AllApps{i},'Fridge')
                        TempArrayCell = [] ;
                        for ik = 1:length(TimeAction)
                            TempArrayCell = [TempArrayCell; App_Energy10scell{ik}] ;
                        end
                        SimulationStart = TimeAction(1) ;
                        SimulationEnd   = SimulationStart + seconds(size(TempArrayCell,1) * 10) ;
                        xq = (SimulationStart:seconds(10):SimulationEnd)';
                        TempArray = table2timetable(table(xq(1:(end-1)),TempArrayCell,'VariableNames',{'Time','DataOutput'})) ;
                    else
                        for ik = 1:length(TimeAction)
                            SimulationStart = TimeAction(ik) ;
                            SimulationEnd   = SimulationStart + seconds(size(App_Energy10scell{1},1) * 10) ;
                            xq = (SimulationStart:seconds(10):SimulationEnd)';
                            OutPutArray = table2timetable(table(xq(1:(end-1)),App_Energy10scell{1},'VariableNames',{'Time','DataOutput'})) ;
                            try 
                                TempArray = [TempArray ; OutPutArray] ;
                            catch
                                TempArray = OutPutArray ;
                            end
                        end
                    end
                    if ~(TempArray.Time(end) == New10sTime.Time(end))
                        TempArray_End = timetable(New10sTime.Time(end), 0) ;
                        TempArray_End.Properties.VariableNames = {'DataOutput'} ;
                        TempArray = [TempArray ; TempArray_End] ;
                    end
                    TempArray = retime(TempArray,'regular','fillwithconstant','TimeStep',seconds(10));
                end
            end
            App.Info.(AllApps{i})(io).(HouseList{ij}).App10s = TempArray ;
        end
    end
end

%% Function to convert array
function ConvertedArray = ConvertTimeTable(Input, TimeStep, stime)
    if isa(Input,'table')
        ConvertedArray = array2timetable(Input.DataOutput,'Timestep',seconds(TimeStep),'VariableNames',{'DataOutput'},'StartTime',stime) ;
    elseif isa(Input,'double')
        ConvertedArray = array2timetable(Input,'Timestep',seconds(TimeStep),'VariableNames',{'DataOutput'},'StartTime',stime) ;
    end
end
