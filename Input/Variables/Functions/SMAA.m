% /*
%     This file is part of SMAA matlab implementation.
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

% Enter criteria measurements

function [rankaccept, central, confidence] = SMAA(varargin)

if nargin == 3
    alternatives = varargin{1};
    criteria = varargin{2};
    iterations = varargin{3};
elseif nargin == 0
    alternatives = 4;
    criteria = 6;
    iterations = 10000;
else
   disp('Not enough or too many arguments'); 
end


% mean = [0,0.086,0.095,0.113;11.7,9.2,15.4,5.5;7.2,10.6,7.5,15.7;16.6,21.2,20.2,12.8;13.7,14.3,15,11.2;18.6,18.3,19.5,31];
% standard = [0,0.056,0.044,0.048;2.5,1.86,2.65,2.32;1.45,1.58,1.48,4.44;3.27,5.15,3.78,2.45;1.89,2.93,3.21,3.98;1.79,3.7,2.6,1.68];

 average = [ 0      ,0.086  ,0.095  ,0.113;...
             11.7   ,9.2    ,15.4   ,5.5;...
             7.2    ,10.6   ,7.5    ,15.7;...
             16.6   ,21.2   ,20.2   ,12.8;...
             13.7   ,14.3   ,15     ,11.2;...
             18.6   ,18.3   ,19.5   ,31];
 standard = [0      ,0.056  ,0.044  ,0.048;...
             2.5    ,1.86   ,2.65   ,2.32;...
             1.45   ,1.58   ,1.48   ,4.44;...
             3.27   ,5.15   ,3.78   ,2.45;...
             1.89   ,2.93   ,3.21   ,3.98;...
             1.79   ,3.7    ,2.6    ,1.68];

% Initialization

rankaccept = zeros(alternatives);
central = zeros(alternatives,criteria);
confidence = zeros(1,alternatives);
weights = zeros(1,criteria);
meanvalue = zeros(1,alternatives);

% Define Value Function
for o = 1:criteria
   xmin = min(norminv(0.025,average(o,:),standard(o,:)))       ;
   xmax = max(norminv(0.975,average(o,:),standard(o,:)))       ;
   ymin = 0;
   ymax = 1;
   x1 = [xmin xmax];
   y = [ymin ymax];
   flin(o,:) = polyfit(x1,y,1) ;
end

% Compute rank acceptability indices + central weight vectors


for i = 1:iterations
    
    % Generate weights
    
    randNum = rand(1,criteria-1);
    q = [0,sort(randNum),1];
    for j = 2:criteria+1
        weights(j-1) = q(j) - q(j-1);
    end
       
    % Generate criteria measuments + compute utility of each alternative
    meanval = mean(meanvalue) ;
    value=zeros(1,alternatives);
    for a = 1:alternatives
        %measurements=[];
        measurements = zeros(1,criteria);
        for c = 1:criteria
            measurements(c) = average(c,a) ; %+ standard(c,a)*randn;
        end
        %measurements(1) = exp(measurements(1));
        value(a)=utility(measurements,weights,flin);
    end
    meanvalue(i,:) = value;
    % Ranking of the alternatives based on their utility scores
    
    [~,rank] = sort(value);
    rank = flipud(rank');
    rank = rank';
        
    % Update counters
    
    for a = 1:alternatives
        rankaccept(rank(a),a) = rankaccept(rank(a),a) + 1;
        if rank(1)==a
            for c = 1:criteria
                central(a,c) = central(a,c) + weights(c);
            end
        end
    end
    
end

% Compute SMAA descriptive measures

for a = 1:alternatives
    if rankaccept(a,1)>0
        for c = 1:criteria
            central(a,c) = central(a,c)/rankaccept(a,1);
        end
    end
end
rankaccept = rankaccept/iterations;

% Compute confidence facors

for alt = 1:alternatives
    weights=central(alt,:); % Get central weight factor of alternative alt
    
    for i = 1:iterations
        
        % Generate criteria measuments + compute utility of each alternative
        
        value=zeros(1,alternatives);
        for a = 1:alternatives
            measurements = zeros(1,criteria);
            for c = 1:criteria
                measurements(c) = average(c,a) + standard(c,a)*randn;
            end
            %measurements(1) = exp(measurements(1));
            value(a)=utility(measurements,weights,flin);
        end
    
        % Ranking of the alternatives based on their utility scores
    
        [~,rank] = sort(value);
        rank = flipud(rank');
        rank = rank';
    
        % Update counter
    
        if rank(1)==alt
            confidence(alt) = confidence(alt) + 1;
        end
    
    end
end
confidence = confidence/iterations;

% Display SMAA descriptive measures

rankaccept
central
confidence
meanval

    