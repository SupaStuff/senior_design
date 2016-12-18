% amquiver.m - Function to emulate the MATLAB quiver command, but better
% RMM, 23 Mar 07

function handle = amquiver(x, y, dx, dy, options)
PP_arrow_pixels = 5;

% Figure out the color
global AMPRINT_FLAG
if (AMPRINT_FLAG == 2)
  color = 'k';
else
  color = 'b';
end

% Turn everything into vectors
xpts = reshape(x, prod(size(x)), 1);
ypts = reshape(y, prod(size(y)), 1);
dxpts = reshape(dx, prod(size(dx)), 1);
dypts = reshape(dy, prod(size(dy)), 1);

% Figure out how big the arrow is going to be
xlimv = xlim; ylimv = ylim;		% axis limits in scaled units
axunits = get(gca, 'Units');
set(gca, 'Units', 'pixels');
axposn_pixel = get(gca, 'Position');	% axis limits in pixels
set(gca, 'Units', axunits);
epsx = (xlimv(2) - xlimv(1)) / axposn_pixel(3) * PP_arrow_pixels;
epsy = (ylimv(2) - ylimv(1)) / axposn_pixel(4) * PP_arrow_pixels;

% Normalize the lengths of the arrows
mag = sqrt(dxpts.*dxpts + dypts.*dypts);
dxpts = dxpts ./ mag;
dypts = dypts ./ mag;

for i=1:length(xpts)
  % Only plot arrows if there is a nonzero vector
  if (~isnan(dxpts(i)) && ~isnan(dypts(i)))
    % Compute the amount to backup on the line
    eps = abs(epsx*dxpts(i)) + abs(epsx*dypts(i));
    handle = arrow(...
      [xpts(i) - 0.6*eps*dxpts(i), ypts(i) - 0.6*eps*dypts(i)], ...
      [xpts(i) + 0.4*eps*dxpts(i), ypts(i) + 0.4*eps*dypts(i)], ...
      PP_arrow_pixels, 'EdgeColor', color, 'FaceColor', color);
  end;
end;
% plot(xpts, ypts, 'k.');
