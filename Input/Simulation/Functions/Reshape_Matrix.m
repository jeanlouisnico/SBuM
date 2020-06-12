function [Output_Array] = Reshape_Matrix(TimeStep,Array,Method)
% generate big matrix
% Array = Hourly_Temperature;
% TimeStep = 24  ; % want 9-row average.
% reshape
tmp = reshape(Array, [TimeStep numel(Array)/TimeStep]);
% mean column-wise (and only 9 rows per col)
switch Method
    case 'median'
        tmp = median(tmp);
    case 'mean'
        tmp = mean(tmp);
end
%tmp = mean(tmp);
% reshape back
Output_Array = reshape(tmp, [ size(Array,2) size(Array,1)/TimeStep  ])';