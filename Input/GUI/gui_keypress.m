function [] = gui_keypress()
% Typing in the editbox puts the string in a textbox.

S.fh = figure('units','pixels',...
              'position',[500 500 200 100],...
              'menubar','none',...
              'name','keypress',...
              'numbertitle','off',...
              'resize','off');        
S.ed = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[10 10 180 30],...
                 'fontsize',14,...
                 'callback',@ed_call,...
                 'keypressfcn',@ed_kpfcn);
S.tx = uicontrol('style','text',...
                 'units','pix',...
                 'position',[10 60 180 30]);
S.STR = [];             
guidata(S.fh,S); 
uicontrol(S.ed)

function [] = ed_call(H,E)
% Callback for editbox.
S = guidata(gcbf);  % Get the structure.
set(S.tx,'str',get(S.ed,'string'));  
S.STR = [];
guidata(gcbf,S)

function [] = ed_kpfcn(H,E)
% Keypressfcn for editbox
S = guidata(gcbf);  % Get the structure.

if strcmp(E.Key,'backspace')
    S.STR = S.STR(1:end-1);
elseif isempty(E.Character)
    return
else
    S.STR = [S.STR E.Character];
end

set(S.tx,'string',S.STR)
guidata(gcbf,S)
