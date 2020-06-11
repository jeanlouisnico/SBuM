function open_Waiting_Window_Test
        guiwait.Figure = figure( ...
                                'NumberTitle', 'off', ...
                                'MenuBar', 'none', ...
                                'Toolbar', 'none', ...
                                'HandleVisibility', 'on',...
                                'Visible','off');
        
        mainLayout = uix.HBox( 'Parent', guiwait.Figure, 'Spacing', 3 );
        
        AxesFigure = axes(mainLayout,'Tag','AxesFigure');
        
        filename = 'Logo_UOulu.png';
        
        GetPath = mfilename('fullpath');
        ParentFolder = GetPath(1:max(strfind(GetPath,filesep)));
        
        var=strcat(ParentFolder,'Images',filesep,filename);
        ORI_IMG=imread(var);
        
        if ishandle( AxesFigure )
            delete( AxesFigure );
        end
        
        fig = figure( 'Visible', 'off' );
        AxesFigure = gca();
        set(AxesFigure,'Units','pixels','position',[0 0 4444 5876]);
        set(AxesFigure,'Units','pixels');
        
        resizePos = get(AxesFigure,'Position');
        ORI_IMG = imresize(ORI_IMG, [resizePos(4) resizePos(3)]);
        imshow(ORI_IMG);
        
        cmap = colormap( AxesFigure );
        set( AxesFigure, 'Parent', mainLayout );
        
        set(AxesFigure,'Units','normalized','position',[0 0 1 1]);
        
        colormap( AxesFigure, cmap );
        
%         axis(gui.AxesFigure);
        close( fig );
        
        str = [char(169),' University of Oulu, 2019'] ;
        
        position = [0.1 0.5 0.3 0.3];
        axes('Position', position,...
                 'Visible',  'off',...
                 'Parent',   mainLayout);
        text(0,0.5,str,'Units','Normalized')
        
        set(mainLayout,'Widths',[-1 -1])
        
        % Set the size of the figure
        Pos = guiwait.Figure.Position ;
        Pos(3) = Pos(3) / 2 ; % Width
        Pos(4) = Pos(4) / 2.5 ; % Height
        guiwait.Figure.Position = Pos ;
        
        scrsz = get(groot,'ScreenSize');
        WLeft = scrsz(3) / 2 - Pos(3) / 2 ; % Half the window
        WHeight = scrsz(4) / 2 - Pos(4) / 2 ; % Half the window
        
        set(guiwait.Figure,'Position',[WLeft WHeight Pos(3) Pos(4)]) ;
        pause(1);
        set(guiwait.Figure,'Visible', 'on') ;
        undecorateFig(guiwait.Figure);
        
    end