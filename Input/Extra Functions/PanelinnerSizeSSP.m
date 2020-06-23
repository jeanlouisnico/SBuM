    function [Size]=PanelinnerSizeSSP(Panel)
        Header = 23 ;
        found = 0 ;
        ChildOld = Panel ;

        while found == 0
            try
                ChildNew = ChildOld(1).Children(1) ;
            catch
               Size = 0;
               return; 
            end
            found = 1 ;
            pos1 = 0 ;
            
            pos1 = GetHeightContainer(ChildNew,pos1) ;      
        end
        Size = Header + 2*Panel.Padding + pos1 ;
    end %PanelinnerSize
    
    function [Heightreturn] = GetHeightContainer(ContainerID, Heightreturn)
        switch class(ContainerID)
            case 'uix.HBox'
                TypeinVBox = ContainerID(1).Children(1).Type ;
                switch TypeinVBox
                    case 'uicontainer'
                        Heightreturn = GetHeightContainer(ContainerID(1).Children(1),Heightreturn) ;
                        Heightreturn = Heightreturn + ContainerID(1).Children(1).Parent.Padding * 2 ;
                    case 'uicontrol'
                        pos = get(ContainerID(1).Children(1),'Extent');
                        Heightreturn = Heightreturn + pos(4) ;
                end
            case 'uix.VBox'
                    for i = 1:numel(ContainerID)
                        for ii = 1:numel(ContainerID(i).Children)
                            TypeinVBox = ContainerID(i).Children(ii).Type ;
                            switch TypeinVBox
                                case 'uicontainer'
                                    Heightreturn = GetHeightContainer(ContainerID(i).Children(ii),Heightreturn) ;
                                    Heightreturn = Heightreturn + ContainerID(i).Children(ii).Spacing * 2 + ContainerID(i).Children(ii).Padding * 2 ;
                                case 'uicontrol'
                                    pos = get(ContainerID(i).Children(ii),'Extent');
                                    style = get(ContainerID(i).Children(ii),'Style') ;
                                    if strcmp(style,'listbox')
                                        NbrInputMax = 6 ;
                                        NbrInput = size(ContainerID(i).Children(ii).String,1) + 1 ;
                                        Heightreturn = Heightreturn + pos(4)*(min(NbrInput,NbrInputMax)) ;
                                    else
                                        Heightreturn = Heightreturn + pos(4) ;
                                    end
                            end
                        end
                    end
        end
    end