function ConvertedArray = ConvertTimeTableProfilePar(Input, TimeStep)
        if isa(Input,'table')
            ConvertedArray = table2timetable(Input,'Timestep',seconds(TimeStep)) ;
        elseif isa(Input,'double')
            ConvertedArray = array2timetable(Input,'Timestep',seconds(TimeStep)) ;
        elseif isa(Input,'timetable')
            ConvertedArray = Input ;
        end
