
function [Data2Check] = Check_signature_appliances(varargin)

if nargin > 0
    App = varargin{1} ;
    Appliance = varargin{2} ;
    HouseTag  = varargin{3}   ;
else
    App = load('C:\Users\jlouis\MATLAB Drive V2\MatLab model Beta\Output\Simulation_15min_10s\App.mat') ;
    App = App.App ;
    Appliance = 'Oven' ;
    HouseTag  = 'House1'   ;
end
[varname] = variable_names;
AllProjects = fieldnames(App) ;

for iProject = 1:length(AllProjects)
    ProjectName = AllProjects{iProject} ;
    for iHouse = 1:length(HouseTag)
        ProjectHouse= HouseTag{iHouse}     ;
        AppProject  = App.(ProjectName)     ;
        if strcmp(Appliance,'All')
            AllApp = fieldnames(AppProject.Info) ;
            for iApp = 1:length(AllApp)
                App2extract = AllApp{iApp} ;
                [Data2Check]                                    = appsignature(AppProject, App2extract, ProjectHouse) ;
                Info.(App2extract).(ProjectName).(ProjectHouse).Data2Check    = array2timetable(Data2Check,'SampleRate',0.1) ;
            end
        else
            [Data2Check]                                    = appsignature(AppProject, Appliance, ProjectHouse) ;
            Info.(Appliance).(ProjectName).(ProjectHouse).Data2Check      = array2timetable(Data2Check,'SampleRate',0.1) ;
        end
    end
end

% Plot all the data, differentiate if multiple sources
ToTrace = fieldnames(Info) ;
newgcf = gcf ;
if isempty(newgcf.Number)
    startingnumber = 1;
else
    startingnumber = newgcf.Number ;
end
hFigures(startingnumber) = figure('Visible','off') ;
if length(ToTrace) > 1
    % Plot a single plot
    nrow = floor(sqrt(length(ToTrace))) ;
    ncol = ceil(length(ToTrace)/nrow)  ;
    for kplot = 1:length(ToTrace)
        iplot             = 1  ;
        dataStat4Use      = [] ;
        dataStat4Use2plot = [] ;
        for iProject = 1:length(AllProjects)
            ProjectName = AllProjects{iProject} ;
            for iHouse = 1:length(HouseTag)
                ProjectHouse        = HouseTag{iHouse} ;
                dataStat4Use = Info.(ToTrace{kplot}).(ProjectName).(ProjectHouse).Data2Check ;
                if isempty(dataStat4Use)
                    % There is nothing to do, just continue to the next
                    % ihouse
                    continue ;
                elseif size(dataStat4Use.Data2Check,1) == size(dataStat4Use2plot,1) || iplot == 1
                    % this is the same size array, so just allocate it
                    dataStat4Use2plot(:,iplot) = dataStat4Use.Data2Check ;
                elseif size(dataStat4Use.Data2Check,1) < size(dataStat4Use2plot,1)
                    % It is smaller, so add zeros to the new one to match
                    % the size array
                    MissingData = size(dataStat4Use2plot,1) - size(dataStat4Use.Data2Check,1) ;
                    newdataStat4Use = [dataStat4Use.Data2Check ; zeros(MissingData,1)] ;
                    dataStat4Use2plot(:,iplot) = newdataStat4Use ;
                elseif  size(dataStat4Use.Data2Check,1) > size(dataStat4Use2plot,1)
                    % this means that the new array is greater than the
                    % previous array, so resize all the previous array to
                    % match the new length
                    MissingData = size(dataStat4Use.Data2Check,1) - size(dataStat4Use2plot,1) ;
%                     dataStat4Use2plot = insertrows(dataStat4Use2plot, size(dataStat4Use2plot,1) + 1, MissingData) ;
                    dataStat4Use2plot = insertrows(dataStat4Use2plot, zeros(MissingData,size(dataStat4Use2plot,2)), size(dataStat4Use2plot,1) + 1 ) ;
                    dataStat4Use2plot(:,iplot) = dataStat4Use.Data2Check ;
                end
                iplot = iplot + 1;
            end
        end
        TT = array2timetable(dataStat4Use2plot,'TimeStep',seconds(10)) ;
        subplot(nrow,ncol,kplot)
        for ip = 1:(iplot - 1)
            hold on
            plot(TT.Time, TT{:,ip})
            grid on
            grid minor
        end
        hold off
        title(varname.(ToTrace{kplot}).LongName)
    end
    legend('Signature') ;
else
    % Plot all as subplots and re-arrange them
    plot(Info.(Appliance).Data2Check)     ;
    legend('Signature') ;
end
hFigures(startingnumber).Visible = 'on' ;     
    
%-------------------------------------------------------------------------%
    function [Data2Check] = appsignature(App, Appliance, HouseTag)
        try
            Data2Check          = App.OutputSignal10s.(Appliance)(1).(HouseTag) ;
        catch
            Data2Check = [] ;
        end
    end
end
