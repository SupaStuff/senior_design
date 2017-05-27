%AMPHASEPLOT   Phase plot for 2D dynamical systems
%
% AMPHASEPLOT('F', X1range, X2range, scale) produces a quiver plot for
% the function 'F'.  X1range and X2range have the form [min, max, num]
% and specify the axis limits for the plot, along with the number of
% subdivisions in each axis, used to produce an quiver plot for the
% vector field.  The vector field is scaled by a factor 'scale'
% (default = 1).
%
% The function 'F' should be the same for as used for ODE45.  Namely, it
% should be a function of the form dxdt = F(t,x) that accepts a state x of 
% dimension 2 and returns a derivative dxdt of dimension 2.
%
% AMPHASEPLOT('F', X1range, X2range, scale, Xinit) produces a phase
% plot for the function 'F', consisting of the quiver plot plus stream
% lines.  The streamlines start at the initial conditions listed in
% Xinit, which should be a matrix whose rows give the desired inital
% conditions for x1 and x2.  X1range or X2range is 'auto', the arrows
% are produced based on the stream lines.  If 'scale' is negative,
% dots are placed at the base of the arrows.  If 'scale' is zero, no
% dots are produced.
% 					
% AMPHASEPLOT('F', X1range, X2range, scale, boxgrid(X1range2,
% X2range2)) produces a phase plot with stream lines generated at the
% edges of the rectangle defined by X1range2, X2range2.  These ranges
% are in the same form as X1range, X2range.
%
% AMPHASEPLOT('F', X1range, X2range, scale, Xinit, T) produces a phase
% plot where the streamlines are simluted for time T (default = 50).
%
% AMPHASEPLOT('F', X1range, X2range, scale, Xinit, T, P1, P2, ...)
% passes additional parameters to the function 'F', in the same way as
% ODE45.
%
% Instead of drawing arrows on a grid, arrows can also be drawn on
% streamlines by usinge the X1range and X2range arguments as follows:
%
%   X1range	X2range
%   -------	-------
%   'auto'	N	  Draw N arrows using equally space time points
%   'logtime'   [N, lam]  Draw N arrows using exponential time constant lam
%   'timepts'	[t1, t2, ...]  Draw arrows at the list times

% Written by Richard Murray, Fall 2002, based on a version by Kristi Morgansen
%
% 1 May 2010, RMM: updated documentation + added BSD license info
% 24 Feb 07, RMM: added ability to generate arrows on stream lines
% 11 Oct 03, RMM: added parameters as additional arguments + dimen bug fix
%   * function now allows parameters in the same way as ODE45
%   * fixed bug with mesh dimensions caused by MATLAB length() behavior
%   * got completely frustrated with MATLAB as a psuedo-programming language
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%
%   2. Redistributions in binary form must reproduce the above copyright 
%      notice, this list of conditions and the following disclaimer in the 
%      documentation and/or other materials provided with the distribution.
%
%   3. The name of the author may not be used to endorse or promote products 
%      derived from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
% IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
% IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

function [a, varargout] = phaseplot(odefun, xlimv, ylimv, scale, xinit, T, varargin)
%
% Parameters defining the plot
%
% The constants below define the parameters that control how the plot
% looks.  These can be modified to customize the look of the phase plot.
%

% PP color = ['m', 'c', 'r', 'g', 'b', 'k', 'y'];
PP_stream_color = ['b'];		% color array for streamlines
PP_stream_linewidth = 1;		% line width for stream lines

PP_arrow_linewidth = 1;			% line width for arrows (quiver)
PP_arrow_markersize = 10;		% size of arrow base marker

% Argument processing
if (nargin < 4) scale = 1; end;

auto = 0; logtime = 0; timepts = 0; Narrows = 0;
if (ischar(xlimv) && strcmp(xlimv, 'auto'))
  auto = 1;
  Narrows = ylimv;
  fprintf(1, 'Using auto arrows\n');

elseif (ischar(xlimv) && strcmp(xlimv, 'logtime'))
  logtime = 1;
  Narrows = ylimv(1);
  lambda = ylimv(2);
  fprintf(1, 'Using logtime arrows\n');

elseif (ischar(xlimv) && strcmp(xlimv, 'timepts'))
  timepts = 1;
  Narrows = length(ylimv);

else
  % Figure out the set of points for the quiver plot
  [x1,x2] = meshgrid(xlimv(1):(xlimv(2)-xlimv(1))/xlimv(3):xlimv(2), ...
    ylimv(1):(ylimv(2)-ylimv(1))/ylimv(3):ylimv(2));
end

% Figure out if we have parameter arguments and create the required string
if (length(varargin) == 0)
  parms = '';
else
  parms = ', []';
  for (k = 1:length(varargin))
    parms = strcat(parms, sprintf(', %g', varargin{k}));
  end;
end;

if (~auto && ~logtime && ~timepts)
  % Now calculate the vector field at those points
  [nr,nc] = size(x1);
  for i = 1:nr
    for j = 1:nc
      eval(['dx(' num2str(i) ',' num2str(j) ',1:2) = ' ...
  	odefun '(0, [' num2str(x1(i,j)) ' ' num2str(x2(i,j)) ']' parms ');']);
    end
  end

  % Plot the quiver plot
  % clf; 
  if (isnan(scale))
    amquiver(x1, x2, dx(:,:,1), dx(:,:,2), 0);
  elseif (scale ~= 0)
    xy = quiver(x1, x2, dx(:,:,1)*abs(scale), dx(:,:,2)*abs(scale), 0);
    set(xy, 'LineWidth', PP_arrow_linewidth, 'Color', 'b');
  end

  a=gca; set(a,'DataAspectRatio',[1,1,1]);
  set(a,'XLim',xlimv(1:2)); set(a,'YLim',ylimv(1:2));
  xlabel('x1'); ylabel('x2','Rotation',0);
end

% See if we should also generate the streamlines
if (nargin < 5 || isempty(xinit)) return; end
  
% See if we were passed a simulation time
if (nargin < 6) T = 50; end;

% Parse the time we were passed
TSPAN = T;
if (length(T) == 1) TSPAN = [0 T]; end;

% Figure out the limits for the plot
if (isnan(scale)) 
  % Assume that the current axis are set as we want them
  alim = axis;
  xmin = alim(1); xmax = alim(2); 
  ymin = alim(3); ymax = alim(4);
else
  % Use the maximum extent of all trajectories
  xmin = min(xinit(:,1)); xmax = max(xinit(:,1));
  ymin = min(xinit(:,2)); ymax = max(xinit(:,2));
end

% Generate the streamlines for each initial condition
[nr, nc] = size(xinit);
for i = 1:nr
  [time, state] = ode45(odefun, TSPAN, xinit(i,:), [], varargin{:});
  hold on;
  h(i) = plot(state(:,1), state(:,2), ...
    PP_stream_color(mod(i-1, length(PP_stream_color))+1));
  set(h(i), 'LineWidth', PP_stream_linewidth);

  % Plot arrows if quiver parameters were 'auto'
  if (auto || logtime || timepts)
    % Compute the locations of the arrows
    for j = 1:Narrows
      
      % Figure out starting index; headless arrows start at 1
      k = 1 - isnan(scale);
      
      % Figure out what time index to use for the next point
      if (auto) 
	% Use a linear scaling based on ODE time vector
	tind = floor((length(time)/Narrows) * (j-k)) + k;
      elseif (logtime)
	% Use an exponential time vector
	% tind = find(time < log(Narrows/(Narrows-(j-k))) / lambda, 1, 'last');
	tind = find(time < (j-k) / lambda, 1, 'last');
      elseif (timepts)
	% Use specified time points
	tind = find(time < ylimv(j), 1, 'last');
      end
      
      % Make sure that we start at the first point
      if (isempty(tind))
	tind = 1;
      end
      
      % For tailless arrows, skip the first point
      if (tind == 1 && isnan(scale)) continue; end;
      
      % Figure out the arrow at this point on the curve
      x1(i,j) = state(tind,1);
      x2(i,j) = state(tind,2);

      % If we are using amquiver, skip arrows outside of initial condition box
      if (~isnan(scale) || ...
          (x1(i,j) <= xmax && x1(i,j) >= xmin && ...
	   x2(i,j) <= ymax && x2(i,j) >= ymin))
      	  eval(['dx(', num2str(i) ',' num2str(j) ',:) = ' ...
	      odefun '(0, [' num2str(x1(i,j)) ' ' ...
		num2str(x2(i,j)) ']' parms ');']);
      else
	dx(i, j, 1) = 0; dx(i, j, 2) = 0;
      end	    
    end
  end
end

% Set the plot shape before plotting arrows to avoid warping
a=gca;  
if (~isnan(scale))
  set(a,'DataAspectRatio', [1,1,1]);
  if (xmin ~= xmax && ymin ~= ymax) 
    if (exist('amaxis'))
      amaxis([xmin xmax ymin ymax]);
    else
      axis([xmin xmax ymin ymax]);
    end
  end
end
set(a, 'Box', 'on');

% Plot arrows on the streamlines
if (isnan(scale) && Narrows > 0)
  % Use a tailless arrow
  amquiver(x1, x2, dx(:,:,1), dx(:,:,2), 0);
elseif (scale ~= 0 && Narrows > 0) 
  xy = quiver(x1, x2, dx(:,:,1)*abs(scale), dx(:,:,2)*abs(scale), 0);
  set(xy, 'LineWidth', PP_arrow_linewidth);
  set(xy, 'AutoScale', 'off');
  set(xy, 'AutoScaleFactor', 0);
end;

if (scale < 0) 
  bp = plot(x1, x2, 'b.');		% add dots at base
  set(bp, 'MarkerSize', PP_arrow_markersize);
end;

% Set the output arguments
if (nargout >= 2) varargout(1) = {h}; end;
