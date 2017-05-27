addpath ../amtools
%v=42.505
%m=1000
%theta=0
%gear=5
%u=0
%acc = cruisedyn(v, u, gear)

cruise_antiwindup
cruise_pictrl
cruise_statefbk