function [connected,timing]=isnetavl
% Ping to one of Google's DNSes.
% Optional second output is the ping time.
%
% Windows code adapted from:
% https://www.mathworks.com/matlabcentral/fileexchange/
% 50498-internet-connection-status
%
% Logo adapted from:
% https://commons.wikimedia.org/wiki/File:Blank_globe.svg
%
% Compatibility:
% Matlab: should work on all releases (tested on R2017b, R2012b and R6.5)
% Octave: tested on 4.2.1
% OS:     written on Windows 10 (64bit), Octave tested on a virtual (32bit)
%         Ubuntu 16.04 LTS, might work on Mac
%
% Version: 1.1
% Date:    2018-01-10
% Author:  H.J. Wisselink
% Email=  'h_j_wisselink*alumnus_utwente_nl';
% Real_email = regexprep(Email,{'*','_'},{'@','.'})
if ispc
    %8.8.4.4 will also work
    [ignore_output,b]=system('ping -n 1 8.8.8.8');%#ok ~
    n=strfind(b,'Lost');
    n1=b(n+7);
    if(n1=='0')
        connected=1;
        if nargout==2
            n=strfind(b,'time=');m=strfind(b,'ms');m=m(m>n);m=m(1)-1;
            timing=str2double(b((n+5):m));
        end
    else
        connected=0;
        timing=0;
    end
elseif isunix
    %8.8.4.4 will also work
    [ignore_output,b]=system('ping -c 1 8.8.8.8');%#ok ~
    n=strfind(b,'received');
    n1=b(n-2);
    if(n1=='1')
        connected=1;
        if nargout==2
            n=strfind(b,'/');n=n([end-1 end]);
            timing=str2double(b(n(1):n(2)));
        end
    else
        connected=0;
        timing=0;
    end
else
    error('How did you even get Matlab to work?')
end
end