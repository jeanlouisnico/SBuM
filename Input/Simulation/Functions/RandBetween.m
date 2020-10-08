function [r] = RandBetween(varargin)
% INPUTS:
% Arg1               : Lower limit to generate a number
% Arg2               : Higher limit to generate a number
% Optional Arg3      : Number of row that needs to be generated (def=1)
% Optional Arg4      : Number of Column that needs to be generated (def=1)
%
% OUTPUTS:
% Arg3 * Arg4 matrix of random numbers within the limits [Arg1 Arg2]
%
% Jean-Nicolas Louis 2015


if nargin == 2
    a = varargin{1}; b = varargin{2};
    r = a + (b-a).*rand(1,1);
elseif nargin == 3
    a = varargin{1}; b = varargin{2};
    x = varargin{3};
    r = a + (b-a).*rand(x,1);
elseif nargin == 4
    a = varargin{1}; b = varargin{2};
    x = varargin{3}; y = varargin{4};
    r = a + (b-a).*rand(x,y);
end