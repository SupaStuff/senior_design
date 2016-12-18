%AMNYQUIST   Generate Nyquist plots using the conventions in Astrom & Murray
%
% AMNYQUIST(sys, ...) produces a Nyquist plot using the plotting
% conventions in "Feedback Systems" by Astrom and Murray.  This is
% mainly just a wrapper around the regular MATLAB nyquist() command,
% with some processing done on the system to shift poles on the
% imaginary axis and produce better looking plots.  In addition,
% arrows are added to the block to indicate the direction of
% encirclement.

% Written by Richard Murray, 2006
%
% 1 May 2010, RMM: added BSD license and function help
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

function amnyquist(sys, varargin)
global AM_data_linewidth AM_ref_linewidth AM_bode_linewidth
global AM_normal_arrowsize AM_pzmap_markersize
pshift = 0.01;

% Determine the linewidth to use for bode plots
global AM_bode_linewidth
if (isempty(AM_bode_linewidth) || AM_bode_linewidth == 0)
  AM_bode_linewidth = get(gca, 'LineWidth');
end;

% Set defaults if amsetup has not been run (allows more standalone operation)
if (isempty(AM_pzmap_markersize)) AM_pzmap_markersize = 6; end
if (isempty(AM_normal_arrowsize)) AM_normal_arrowsize = 8; end
if (isempty(AM_ref_linewidth)) AM_ref_linewidth = 0.667; end

% Check to see what type of data we received
if (isa(sys, 'frd')) 
  % Use the data directly
  re = real(sys.response);
  im = imag(sys.response);
  w = sys.freq;

else
  % Get a zpk representation
  [zlist, plist, k] = zpkdata(sys);

  % Go through the poles and shift anything on the omega axis
  for i = 1:length(plist{1})
    if (real(plist{1}(i)) == 0) plist{1}(i) = plist{1}(i) - pshift; end;
  end;

  % Construct the new transfer function
  msys = zpk(zlist, plist, k);

  % Now generate the Nyquist plot
  [re, im, w] = nyquist(msys, varargin{:});
end

% Now generate a Nyquist plot the way we want it
plot(squeeze(re), squeeze(im), '-', 'LineWidth', AM_bode_linewidth);
hold on; plot(squeeze(re), -squeeze(im), '--', 'LineWidth', AM_bode_linewidth);

%
% Add some arrows at the "midpoint" of the plot
%

global AM_nyquist_plain;
if (isempty(AM_nyquist_plain) || AM_nyquist_plain == 0)

% Find min and max values on real axis
maxreal = max(re); minreal = min(re);

% Compute potential midpoints 
mid1 = find(squeeze(re) > ((maxreal + minreal) / 2), 1);
mid2 = find(squeeze(re) < ((maxreal + minreal) / 2), 1);

% Choose the one that is furthest from the ends of the plot
% For now just eliminate endpoints
if (mid1 == 1)
  mid = mid2;
elseif (mid2 == 1)
  mid = mid1;
else
  mid = (mid1 + mid2) / 2;
end

% set up the color
global AMPRINT_FLAG
color = 'b';
if (AMPRINT_FLAG==2) color = 'k'; end;

% Now plot the arrow at the midpoint
arrow([re(mid), im(mid)], [re(mid+1), im(mid+1)], AM_normal_arrowsize, ...
  'FaceColor', color, 'EdgeColor', color);
arrow([re(mid+1), -im(mid+1)], [re(mid), -im(mid)], AM_normal_arrowsize, ...
  'FaceColor', color, 'EdgeColor', color);

else
  fprintf('Skipping arrows (AM_nyquist_plain = %d)\n', AM_nyquist_plain);

end;					% AM_nyquist_plain

% Add the -1 point
plot([-1], [0], '+', 'MarkerSize', AM_pzmap_markersize);

% Get the limits of the current axes and draw lines
xlims = get(gca, 'XLim');
ylims = get(gca, 'YLim');
arrow([xlims(1) 0], [xlims(2) 0], AM_normal_arrowsize, ...
  'LineWidth', AM_ref_linewidth);
arrow([0 ylims(1)], [0 ylims(2)], AM_normal_arrowsize, ...
  'LineWidth', AM_ref_linewidth);

% Set up axes so that they are tight (and not showing)
plot(xlims, [0 0], 'ko', 'MarkerSize', 0.01);
plot([0 0], ylims, 'ko', 'MarkerSize', 0.01);
axis tight; axis off;

% Axis labels
if (exist('amtext'))
  amtext(xlims(2) + (xlims(2) - xlims(1))/30, (ylims(2) - ylims(1))/30, ...
    'Re', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
  amtext((xlims(2) - xlims(1))/20, ylims(2) + (ylims(2) - ylims(1))/40, ...
    'Im', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
else
  text(xlims(2) + (xlims(2) - xlims(1))/30, (ylims(2) - ylims(1))/30, ...
    'Re', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
  text((xlims(2) - xlims(1))/20, ylims(2) + (ylims(2) - ylims(1))/40, ...
    'Im', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
end;
