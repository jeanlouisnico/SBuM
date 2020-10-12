function A3 = genrand(longarray, nbr)

n = longarray ; m = 1 ;

% A1 = rand(n,m) < 0.5  ; % a logical array consuming little memory
% A2 = round(rand(n,m)) ;

% For the bath we remove the ones that are unnecessary
if nbr < 1
    if nbr > rand
        nbr = 1 ;
    else
        nbr = 0 ;
    end
end
    
N0 = longarray - floor(nbr) ; % specify some exact number of zeros

A3 = ones(n,m) ; 


A3(1:N0) = 0 ; 

A3(randperm(numel(A3))) = A3 ;