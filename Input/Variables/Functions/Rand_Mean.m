function [x] = Rand_Mean(n,xmean,xmin,xmax)
xeps = 0.01;
x = randi([xmin xmax],n,1);
while abs(xmean - mean(x)) >= xeps
    if xmean > mean(x)
        x(find(x < xmean,1)) = randi([xmean xmax]);
    elseif xmean < mean(x)
        x(find(x > xmean,1)) = randi([xmin xmean]);
    end
end