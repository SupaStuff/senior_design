function list = boxgrid(xlimp, ylimp)
%BOXGRID   generate list of points on edge of box
%
%  list = BOXGRID([xmin xmax xnum], [ymin ymax ynum]) generates a list 
%  of points that correspond to a uniform grid at the end of the box 
%  defined by the corners [xmin ymin] and [xmax ymax].

sx10=xlimp(1):(xlimp(2)-xlimp(1))/xlimp(3):xlimp(2);
sy10=ylimp(1):(ylimp(2)-ylimp(1))/ylimp(3):ylimp(2);

sx1=[0, sx10, 0*sy10+sx10(1), sx10, 0*sy10+sx10(length(sx10))]; 
sx2=[0, 0*sx10+sy10(1), sy10, 0*sx10+sy10(length(sy10)), sy10];

list = [sx1; sx2]';
