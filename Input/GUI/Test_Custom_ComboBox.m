Graphing = figure( ...
            'Name', 'Smart house model - Graphing - University of Oulu', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off',...
            'Visible','on');
% Create the Matlab combobox
iconsFolder = fullfile(matlabroot, 'toolbox/matlab/icons');
files = dir(iconsFolder);
hCombobox = uicontrol('Parent',Graphing,'Style','popup', 'String',{files.name}, 'Position',[10,10,120,150]);
 
% Find the uicontrol's underlying Java component
jCombobox = findjobj(hCombobox);  % no scroll-pane for combos
 
% Update the combobox's cell-renderer
javaaddpath 'C:\Users\jlouis\MATLAB Drive V2\MatLab model Beta\Input\GUI'   % location of my LabelListBoxRenderer.class
jRenderer = LabelListBoxRenderer(iconsFolder);
jCombobox.setRenderer(jRenderer);  % Note: not setCellRenderer()
 
% % Give the icons some space...
% jCombobox.setFixedCellHeight(18);
%  
% % Make the drop-down list shorter than the default (=20 items)
% jCombobox.setMaximumRowCount(8);