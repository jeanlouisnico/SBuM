function [xq, stpOut, ResFinalSecond] = TimeArray(ResFinal, SimulationStart, SimulationEnd)

    switch ResFinal
        case 'Hourly'
            ResFinalSecond = 3600;
            stpOut = 1 ;
        case '10s'
            ResFinalSecond = 10 ;
            stpOut = 1/(6 * 60) ;
        case '1 minute'
            ResFinalSecond = 60 ;
            stpOut = 1/60 ;
        case '15 minutes'
            ResFinalSecond = 15 * 60 ;
            stpOut = 1/4 ;
        case '30 minutes'
            ResFinalSecond = 30 * 60 ;
            stpOut = 0.5 ;
        otherwise
            ResFinalSecond = 3600;
    end

xq = (datetime(SimulationStart,'ConvertFrom','datenum'):seconds(ResFinalSecond):datetime(SimulationEnd + 1,'ConvertFrom','datenum'))';