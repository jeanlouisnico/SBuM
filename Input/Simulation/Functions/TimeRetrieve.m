function [varargout] = TimeRetrieve(Endtime,sim)
% TimeElaMo = floor(Endtime/2419200) ; 
%     RemTimeElaMo = Endtime - TimeElaMo * 2419200 ;
% TimeElaW  = floor(RemTimeElaMo / 604800) ; 
%     RemTimeElaW = RemTimeElaMo - TimeElaW * 604800 ;
% TimeElaD  = floor(RemTimeElaW / 86400) ; 
%     RemTimeElaD = RemTimeElaW - TimeElaD * 86400 ;
% TimeElaH  = floor(RemTimeElaD / 3600) ; 
%     RemTimeElaH = RemTimeElaD - TimeElaH * 3600 ;
TimeElaH  = floor(Endtime / 3600) ; 
    RemTimeElaH = Endtime - TimeElaH * 3600 ;
TimeElaMi = floor(RemTimeElaH / 60) ; 
    RemTimeElaMi = RemTimeElaH - TimeElaMi * 60 ;
TimeElaS  = round(RemTimeElaMi) ;

varargout{1} = timedisplay(sim);

    function [outputtime] = timedisplay(Stringinput)
%         if TimeElaMo>0
%             outputtime = horzcat(Stringinput,num2str(TimeElaMo),' month, ',num2str(TimeElaW),' Weeks, ',...
%                          num2str(TimeElaD),' Days, ',num2str(TimeElaH),' Hours, ',num2str(TimeElaMi),' Minutes, and ',...
%                          num2str(TimeElaS),' Seconds');
%         elseif TimeElaW>0
%             outputtime = horzcat(Stringinput,num2str(TimeElaW),' Weeks, ',...
%                          num2str(TimeElaD),' Days, ',num2str(TimeElaH),' Hours, ',num2str(TimeElaMi),' Minutes, and ',...
%                          num2str(TimeElaS),' Seconds');
%         elseif TimeElaD>0
%             outputtime = horzcat(Stringinput,num2str(TimeElaD),' Days, ',num2str(TimeElaH),' Hours, ',...
%                          num2str(TimeElaMi),' Minutes, and ',num2str(TimeElaS),' Seconds');
        if TimeElaH>0
            outputtime = horzcat(Stringinput,num2str(TimeElaH, '%02.f'),':',...
                         num2str(TimeElaMi, '%02.f'),':',num2str(TimeElaS, '%02.f'));
        elseif TimeElaMi>0
            outputtime = horzcat(Stringinput,'00:',num2str(TimeElaMi, '%02.f'),':',num2str(TimeElaS, '%02.f'));
        else
            outputtime = horzcat(Stringinput,'00:00:',num2str(TimeElaS, '%02.f'));
        end
    end
end