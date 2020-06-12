function [flin] = utility_function(mean, stdv)
   xmin = min(norminv(0.001,mean,stdv))       ;
   xmax = max(norminv(0.999,mean,stdv))       ;
   ymin = 1;
   ymax = 0;
   x1 = [xmin xmax];
   y = [ymin ymax];
   flin(:) = polyfit(x1,y,1) ;
end