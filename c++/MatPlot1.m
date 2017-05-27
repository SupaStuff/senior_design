clc;
clear all;

fid = fopen('data.txt')

s=textscan(fid,'%d %d','headerlines',23)
fclose(fid)


x=s{1}
y=s{2}

plot(x,y);

%BreakPlot(x,y,0,200,'Line'); 