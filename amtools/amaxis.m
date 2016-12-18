function v = amaxis(varargin)
% AMAXIS Set the axis along with default style for AM08

% Decide what to do based on the arguments
if (nargin == 0)
  % No arguments; set the current axes to use the right style
  v = axis;
else
  axis(varargin{1:nargin});
end

% Set fonts to use 12 pt (will be scaled to 9 pt)
set(gca, 'FontName', 'Times New Roman');
set(gca, 'FontSize', 12);

% For short plots, double the tick length
position = get(gca, 'Position');
if (position(3) < 0.5) set(gca, 'TickLength', [0.02 0.025]); end;

return;
