% This function aims at resampling the datarate of an appliance. This
% preserve the signal but shorten it for different usage.


function [OutputSignal, OutputSignal10s, vargout] = ReSampling(InVar, Time_Cycle, AppName, CycleTime, MinperIter, varargin)
    if nargin > 5
        % This means this is the Fridge because it has one more input
        cycleLeft = varargin{1} ;
        if isa(cycleLeft,'cell')
            cycleLeft = cycleLeft{1} ;
        end
        InVarOriginal = InVar ;
        if cycleLeft < 1 && cycleLeft > 0
            % Resample with the next batch of signature to re-create the
            % InVar
            
            Startextract    = floor((1 - cycleLeft) * length(InVarOriginal)) + 1  ; 
            Finishextract   = length(InVarOriginal) ;
            
            InVArtest   = InVarOriginal((Startextract):Finishextract) ;
            InVartest2       = [InVArtest;  repmat(InVarOriginal,ceil(Time_Cycle/CycleTime),1)] ;
            InVar = InVartest2 ;
            CycleTime   = (length(InVar)) / (MinperIter*60/10) ;
        end
    end
    if Time_Cycle > CycleTime
        % Extend or Repeat the signal 
        if sum(strcmp(AppName, {'WashMach','DishWash'}))
            OutputSignal = repelem(InVar ,2) ;
        else
            OutputSignalFull = repmat(InVar,ceil(Time_Cycle/CycleTime),1);
            OutputSignal = OutputSignalFull(1:(ceil(Time_Cycle*6*MinperIter))) ;
            if any(strcmp(AppName, {'Fridge'}))
                cycleleftv2 = OutputSignalFull((length(OutputSignal) + 1):end) ;
                vargout{1}      = length(cycleleftv2) / length(InVar) ;
            end
        end
        OutputSignal10s = OutputSignal                         ;
        OutputSignal    = shrink2fit(OutputSignal, Time_Cycle) ;
%         if any(strcmp(AppName, {'Fridge'}))
%             vargout{1}      = 0 ;
%         end
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
        elseif any(strcmp(AppName, {'Fridge'}))
            % Resample for the next 2 cycles 
            OutputSignal    = mean(InVar(1:(MinperIter*60/10))) ;
            OutputSignal10s = InVar(1:(MinperIter*60/10))       ;
            LeftArray = length(InVar) - MinperIter*60/10 ;
            if LeftArray > length(InVarOriginal)
                 multiplier = floor(LeftArray / length(InVarOriginal)) ;
                 LeftArray2 = LeftArray - (length(InVarOriginal) * multiplier ) ;
                 vargout{1}      = LeftArray2 / length(InVarOriginal) ;
            else
                vargout{1}      = LeftArray / length(InVarOriginal) ;
            end
            
        else
            OutputSignal10s = InVar(1:(round(length(InVar) * (Time_Cycle/CycleTime) )))       ;
            if Time_Cycle > 1
                % Reshape the signal to fit the length of the cycles
                OutputSignal10sTemp = OutputSignal10s ;
                ArrayLength  = (MinperIter*60/10) * ceil(Time_Cycle) ;
                Missingarray = ArrayLength - length(OutputSignal10sTemp) ;
                MissingarrayZeros = zeros(Missingarray, 1) ;
                OutputSignal10s = [OutputSignal10sTemp ; MissingarrayZeros];
                
                OutputSignalLong  = reshape(OutputSignal10s, MinperIter*60/10, ceil(Time_Cycle)) ;
                OutputSignal    = mean(OutputSignalLong) ;
            else
                % reshape the array to fill in the gaps of the timestep
                OutputSignal10sTemp = OutputSignal10s   ;
                ArrayLength         = MinperIter*60/10         ;
                Missingarray        = ArrayLength - length(OutputSignal10sTemp) ;
                MissingarrayZeros   = zeros(Missingarray, 1) ;
                OutputSignal10s = [OutputSignal10sTemp ; MissingarrayZeros];
                
                OutputSignal    = mean(OutputSignal10s) ;
            end
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