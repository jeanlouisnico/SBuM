function [Monthly_values, Daily_average_per_month] = Monthly_heating_values(varargin)
%% Mohtly heating values
% This function is to calculate the monthly heating sums of Space and total
% heating
SimulationTime      = varargin{1};
Total_Elec          = varargin{2};
Time_Sim            = varargin{3};

% SimulationTime = datetime(Time_Sim.StartDate.(Housenbr),'ConvertFrom','datenum'):hours(1):datetime((Time_Sim.EndDate.(Housenbr)+23/24),'ConvertFrom','datenum');
% timemonth = SimulationTime.Month;

% Pre-allocation
% January_values      = zeros(1,4);
% February_values     = zeros(1,4);
% March_values        = zeros(1,4);
% April_values        = zeros(1,4);
% May_values          = zeros(1,4);
% June_values         = zeros(1,4);
% July_values         = zeros(1,4);
% August_values       = zeros(1,4);
% September_values    = zeros(1,4);
% October_values      = zeros(1,4);
% November_values     = zeros(1,4);
% December_values     = zeros(1,4);

% Looping the monthly heating values
% for i = 1:Time_Sim.nbrstep.Housenbr
%     if timemonth(i) == 1
%         January_values      = sum(Total_Elec(SimulationTime.Month==1)); %January_values + Total_Elec(i);
% %     elseif timemonth(i) == 2
%         February_values     = sum(Total_Elec(SimulationTime.Month==2));
% %     elseif timemonth(i) == 3
%         March_values        = sum(Total_Elec(SimulationTime.Month==3));
% %     elseif timemonth(i) == 4
%          April_values       = sum(Total_Elec(SimulationTime.Month==4));
% %     elseif timemonth(i) == 5
%          May_values         = sum(Total_Elec(SimulationTime.Month==5));
% %     elseif timemonth(i) == 6
%          June_values        = sum(Total_Elec(SimulationTime.Month==6));
% %     elseif timemonth(i) == 7
%          July_values        = sum(Total_Elec(SimulationTime.Month==7));
% %     elseif timemonth(i) == 8
%          August_values      = sum(Total_Elec(SimulationTime.Month==8));
% %     elseif timemonth(i) == 9
%          September_values   = sum(Total_Elec(SimulationTime.Month==9));
% %     elseif timemonth(i) == 10
%          October_values     = sum(Total_Elec(SimulationTime.Month==10));
% %     elseif timemonth(i) == 11
%          November_values    = sum(Total_Elec(SimulationTime.Month==11));
% %     else
%          December_values    = sum(Total_Elec(SimulationTime.Month==12));
% %     end
% % end
Month31 = [1 3 5 7 8 10 12] ;
Month30 = [4 6 9 11] ;
for i = 1:(Time_Sim.TimeStr.Month)
     Monthly_values(i,1) = sum(Total_Elec(SimulationTime.Month==i));
     if any(ismember(i,Month31))
         Daily_average_per_month(i,1) = Monthly_values(i,1) / 31 ;
     elseif any(ismember(i,Month30))
         Daily_average_per_month(i,1) = Monthly_values(i,1) / 30 ;
     elseif leapyear(SimulationTime.Year) == 1
         Daily_average_per_month(i,1) = Monthly_values(i,1) / 29 ;
     else
         Daily_average_per_month(i,1) = Monthly_values(i,1) / 28 ;
     end 
end
% Calculation of monthly values

% Monthly_values = [January_values; February_values; March_values; April_values; May_values; June_values; July_values; August_values; September_values; October_values; November_values; December_values];
% 
% % Calculation of daily average values and checking of leap year
% 
% if leapyear(SimulationTime.Year) == 1
%     Daily_average_per_month = [January_values/31; February_values/29; March_values/31; April_values/30; May_values/31; June_values/30; July_values/31; August_values/31; September_values/30; October_values/31; November_values/30; December_values/31];
% else
%     Daily_average_per_month = [January_values/31; February_values/28; March_values/31; April_values/30; May_values/31; June_values/30; July_values/31; August_values/31; September_values/30; October_values/31; November_values/30; December_values/31];
% end

% Draw a pie chart for the rest of the values, From Matworks documentation
% "label pie chart with text and percentages"
% h               = pie(Monthly_values(:,end));         % Pie chart for the total heating
% hText           = findobj(h,'Type','text');       % text object handles
% percentValues   = get(hText,'String');    % percent values
% txt             = {'January: '; 'February: '; 'March: '; 'April: '; 'May: '; 'June: '; 'July: '; 'August: '; 'September: '; 'October: '; 'November: '; 'December: '};
% combinedtxt     = strcat(txt,percentValues);
% oldExtents_cell = get(hText,'Extent');
% oldExtents      = cell2mat(oldExtents_cell);
% set(hText(1),'String',combinedtxt(1));
% set(hText(2),'String',combinedtxt(2));
% set(hText(3),'String',combinedtxt(3));
% set(hText(4),'String',combinedtxt(4));
% set(hText(5),'String',combinedtxt(5));
% set(hText(6),'String',combinedtxt(6));
% set(hText(7),'String',combinedtxt(7));
% set(hText(8),'String',combinedtxt(8));
% set(hText(9),'String',combinedtxt(9));
% set(hText(10),'String',combinedtxt(10));
% set(hText(11),'String',combinedtxt(11));
% set(hText(12),'String',combinedtxt(12));
% % hText(1).String = combinedtxt(1);
% % htext(2).String = combinedtxt(2);
% % htext(3).String = combinedtxt(3);
% % htext(4).String = combinedtxt(4);
% % htext(5).String = combinedtxt(5);
% % htext(6).String = combinedtxt(6);
% % htext(7).String = combinedtxt(7);
% % htext(8).String = combinedtxt(8);
% % htext(9).String = combinedtxt(9);
% % htext(10).String = combinedtxt(10);
% % htext(11).String = combinedtxt(11);
% % htext(12).String = combinedtxt(12);
% newExtents_cell = get(hText,'Extent');
% newExtents = cell2mat(newExtents_cell);
% width_change = newExtents(:,3)-oldExtents(:,3);
% signValues = sign(oldExtents(:,1));
% offset = signValues.*(width_change/2);
% textPosition_cell = get(hText,{'Position'});
% textPositions = cell2mat(textPosition_cell);
% textPositions(:,1) = textPositions(:,1) + offset;
% hText(1).Position = textPositions(1,:);
% hText(2).Position = textPositions(2,:);
% hText(3).Position = textPositions(3,:);
% hText(4).Position = textPositions(4,:);
% hText(5).Position = textPositions(5,:);
% hText(6).Position = textPositions(6,:);
% hText(7).Position = textPositions(7,:);
% hText(8).Position = textPositions(8,:);
% hText(9).Position = textPositions(9,:);
% hText(10).Position = textPositions(10,:);
% hText(11).Position = textPositions(11,:);
% hText(12).Position = textPositions(12,:);
% 
% title('Monthly proportion of the annual heating')

end

