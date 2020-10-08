function outputarray = lin_inter(x,y,style)

OriginalArray               = [x, y];


samplePoints_Tdirt          = {x, 1:size(OriginalArray,2)} ;

F                           = griddedInterpolant(samplePoints_Tdirt,OriginalArray,style) ;

queryPoints_OriginalArray   = {(x(1):x(end)),1:size(OriginalArray,2)};

outputarray                  = F(queryPoints_OriginalArray) ;