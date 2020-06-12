% /*
% 	This file is part of SMAA matlab implementation.
% 	(c) Douwe Postmus, 2009	
% 
%     This is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this package.  If not, see <http://www.gnu.org/licenses/>.
% */


function [y] = utility(x,w,flin)
input = 1;
switch input
    case 1
        for o = 1:size(x,2)
           yy(o) = flin(o,1) * x(o) +  flin(o,2) ;
        end
        % Multiply by the weight
        y = sum(yy .* w) ;
    case 2
        y = w(1)*(	 (x(1)-0.98) /(1.23-0.98))   + ...
            w(2)*(1- (x(2)-1)    /(20.6-1))      + ...
            w(3)*(1- (x(3)-4.4)  /(24.4-4.4))    + ...
            w(4)*(1- (x(4)-8)    /(31.3-8))      + ...
            w(5)*(1- (x(5)-3.4)  /(21.3-3.4))    + ...
            w(6)*(1- (x(6)-11.1) /(34-11.1))     ;
    otherwise
        y=0;
end
