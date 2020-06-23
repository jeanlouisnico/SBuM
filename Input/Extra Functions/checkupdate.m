function checkupdate()
%% Check the layout toolbox
v = ver( 'layout' );
space = {' '};
url = 'https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox' ;
webdata = webread(url);tree = htmlTree(webdata);
subtrees = findElement(tree,'span');
HTML_Text = extractHTMLText(subtrees) ;
n = 0 ;
i = 0 ;
while n == 0 && i < numel(HTML_Text)
    i = i + 1 ;
    Text2Check = HTML_Text(i) ;
    if contains(Text2Check,'version ')
        n = 1 ;
        Versioning = Text2Check ;
    end
end 
if n == 0
    % This means that we could not find the version in the html
    % string
    Latestver = '' ;
else
    newver = erase(Versioning,'version ')   ;
    firstspace = strfind(newver,' ')        ;    
    newver = convertStringsToChars(newver)  ;
    Latestver = newver(1:(firstspace(1)-1))    ;
end

%% Check for smart house updates


%% Report update status
Strwarn = {} ;
builtversion = Latestver ;%'2.3.4' ;
if ~strcmp(v.Version,builtversion)
    IndBuilt = split(builtversion,'.');
    IndRun = split(v.Version,'.');
    Loopver = 1 ;
    vers = 0 ;
    while vers == 0
        if ~strcmp(IndBuilt{Loopver},IndRun{Loopver})
            if str2double(IndBuilt{Loopver}) > str2double(IndRun{Loopver})
                Strwarn(end+1) = strcat({'You are running an older version ('},v.Version,{') of'},space,v.Name,...
                                 {' (update v.'},builtversion,{' is available online).'},...
                                  {' visit the toolbox website for more information: https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox'});
            end
            vers = 1;
            updateavailable = 1 ;
        else
            Loopver = Loopver + 1 ;
        end
    end
else
    updateavailable = 0 ;
    msgbox('You are up-to-date!','Update') ;
end

if updateavailable == 1
    Update2Display = '';
    for i = 1:numel(Strwarn)
        Update2Display = [Update2Display,newline,Strwarn{i}] ;
    end
    msgbox(Update2Display,'Update','help') ;
else
    msgbox('You are up-to-date!','Update') ;
end