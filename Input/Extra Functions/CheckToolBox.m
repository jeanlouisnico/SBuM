function CheckToolBox(builtversion)
        space = {' '};
        try
          v = ver( 'layout' );
        catch
            MissingText = 'The toolbox GUI Layout Toolbox is missing.' ;
            answer = questdlg(MissingText,'Missing toolbox','Download','Go to website','Close','Download');
            switch answer
                case 'Download'
                    web('https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/47982/versions/12/download/mltbx')
                    return;
                case 'Go to website'
                    web('https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox' ) ;
                    return;
                case 'Close'
                    return;
                otherwise
                    return;
            end
        end
        if isempty(v)
            MissingText = 'The toolbox GUI Layout Toolbox is missing.' ;
            answer = questdlg(MissingText,'Missing toolbox','Download','Go to website','Close','Download');
            switch answer
                case 'Download'
                    web('https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/47982/versions/12/download/mltbx')
                    return;
                case 'Go to website'
                    web('https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox' ) ;
                    return;
                case 'Close'
                    return;
                otherwise
                    return;
            end
        end
        v = v(1) ;
        if ~strcmp(v.Version,builtversion)
            IndBuilt = split(builtversion,'.');
            IndRun = split(v.Version,'.');
            Loopver = 1 ;
            vers = 0 ;
            while vers == 0
                if ~strcmp(IndBuilt{Loopver},IndRun{Loopver})
                    if str2double(IndBuilt{Loopver}) < str2double(IndRun{Loopver})
                        % Running version is higher than the current version
                        Strwarn = strcat({'You are running a more recent version ('},v.Version,{') of'},space,v.Name,...
                                         {' (v.'},builtversion,{').'},...
                                          {' In case of error please refer to the version'},space,builtversion,space,{'of the toolbox or check for a newer version of the smart house model.'});
                        warning(Strwarn{1});
                    else
                        Strwarn = strcat({'You are running an older version ('},v.Version,{') of'},space,v.Name,...
                                         {' (v.'},builtversion,{').'},...
                                          {' In case of error please refer to the version'},space,builtversion,space,{'of the toolbox.'},...
                                          {' visit the toolbox website for more information: https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox'});
                        warning(Strwarn{1});
                    end
                    vers = 1;
                else
                    Loopver = Loopver + 1 ;
                end
            end
        end
        %%% Check for updates
        
        
end %CheckToolBox