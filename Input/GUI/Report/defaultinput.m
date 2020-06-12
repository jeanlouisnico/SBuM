function output = defaultinput(ToAdd,MachineInfo)
        switch ToAdd
            case 'Title'
                output = 'House details' ;
            case 'Subtitle'
                output = 'Input data' ;
            case 'Logo' 
                output = which('LogoOulu1.png') ;
            case 'Author'
                output = MachineInfo.name ;
            case 'Publisher'
                output = 'University of Oulu';
            case 'PubDate'
                output = date();
        end