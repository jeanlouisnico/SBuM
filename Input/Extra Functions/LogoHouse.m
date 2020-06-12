function [FileName] = LogoHouse(UserType,gui)
    if strcmp(gui,'on')
        switch UserType
            case '1'
                FileName = 'House_Logo_Green.png' ;
            case '2' 
                FileName = 'House_Logo_Orange.png' ;
            case '3' 
                FileName = 'House_Logo_Brown.png' ;
            otherwise
                FileName = 'House_Logo_Black.png' ;
        end
    else
        FileName = 'House_Logo_Black.png' ;
    end