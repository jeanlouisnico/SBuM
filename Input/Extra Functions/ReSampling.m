% This function aims at resampling the datarate of an appliance. This
% preserve the signal but shorten it for different usage.


function [OutputSignal, OutputSignal10s] = ReSampling(InVar, Time_Cycle, AppName, CycleTime, MinperIter)
    
    if Time_Cycle > CycleTime
        % Extend or Repeat the signal 
        if sum(strcmp(AppName, {'WashMach','DishWash'}))
            OutputSignal = repelem(InVar ,2) ;
        else
            OutputSignal = repmat(InVar,ceil(Time_Cycle/CycleTime),1);
            OutputSignal = OutputSignal(1:(ceil(Time_Cycle*6*MinperIter))) ;
        end
        OutputSignal10s = OutputSignal                         ;
        OutputSignal    = shrink2fit(OutputSignal, Time_Cycle) ;
    else
        % Shrink signal to match the simulation resolution
        if any(strcmp(AppName, {'WashMach','DishWash'}))
            s1              = size(InVar, 1);      % Find the next smaller multiple of n
            n               = round(((s1 * 10) / (MinperIter * 60) ) / (Time_Cycle)) ;             % Number of elements to create the mean over
            m               = s1 - mod(s1, n);
            y               = reshape(InVar(1:m), n, []);     % Reshape x to a [n, m/n] matrix
            OutputSignal    = transpose(sum(y, 1) / n); 
            OutputSignal10s = OutputSignal                         ;
            OutputSignal    = shrink2fit(OutputSignal, Time_Cycle) ;
        else
            OutputSignal    = mean(InVar(1:(round(length(InVar) * (Time_Cycle/CycleTime) )))) ;
            OutputSignal10s = InVar(1:(round(length(InVar) * (Time_Cycle/CycleTime) )))       ;
        end
    end
end    
    
    function OutputSignal = shrink2fit(InVar, Time_Cycle)    
        s1 = size(InVar, 1);      % Find the next smaller multiple of n
        if Time_Cycle < 1
            OutputSignal = mean(InVar) * Time_Cycle ;
        else
            n  = ceil(s1 / Time_Cycle) ;             % Number of elements to create the mean over
            m  = s1 - mod(s1, n);
            y  = reshape(InVar(1:m), n, []);     % Reshape x to a [n, m/n] matrix
            OutputSignal = transpose(sum(y, 1) / n);  
        end
    end
 
% Alternative code

% Create sample data
% tic
% PulseRateF = WashMach ;
% Define the block parameter.  Average in a 100 row by 1 column wide window.
% blockSize = [4.2852, 1];
% Block process the image to replace every element in the 
% 100 element wide block by the mean of the pixels in the block.
% First, define the averaging function for use by blockproc().
% meanFilterFunction = @(theBlockStructure) mean2(theBlockStructure.data(:));
% Now do the actual averaging (block average down to smaller size array).
% blockAveragedDownSignal = blockproc(PulseRateF, blockSize, meanFilterFunction);
% Let's check the output size.
% [rows, columns] = size(blockAveragedDownSignal); 
% toc