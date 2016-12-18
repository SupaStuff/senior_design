%AMBODE   Generate Bode plots using the conventions in Astrom & Murray
%
% AMBODE(sys, ...) produces a Bode plot using the plotting conventions
% in "Feedback Systems" by Astrom and Murray.  This includes using
% powers of 10 for the gain plot and a standard set of labels.  The
% arguments to the AMBODE function are the same as the BODE command,
% with a few exceptions:
%
% * Only a single transfer function can be passed as an argument.  To
%   plot Bode plots for multiple transfer functions, use the MATLAB
%   HOLD command.
%
% * [gainh, phaseh] = AMBODE(sys) returns handles to the gain and
%   phase subplots.  These can be use if you need to make annotates to
%   the plots.  If you want to get back the gain, phase and frequency,
%   use the BODE command.

% Written by Richard Murray, 2006
%
% 1 May 2010, RMM: added BSD license 
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

function [magh, phaseh] = ambode(sys, varargin)

% Determine the linewidth to use for bode plots
global AM_bode_linewidth
if (isempty(AM_bode_linewidth) || AM_bode_linewidth == 0)
  AM_bode_linewidth = get(gca, 'LineWidth');
end;

% Generate the Bode plot data using the MATLAB bode command
[mag, phase, omega] = bode(sys, varargin{:});
phase = unwrap(pi*phase/180) * 180/pi;

% Get the dimensions of the current axis, which will divide up
curpos = get(gca, 'Position');
height = curpos(4) * 0.45;
magbot = curpos(2) + curpos(4) * 0.55;
phabot = curpos(2);

% Turn off the background axes
axis off;

% Magnitude plot
magh = axes('position', [curpos(1), magbot, curpos(3), height]);
h = loglog(omega, squeeze(mag));
set(h, 'LineWidth', AM_bode_linewidth);

% Reset the axes to something reasonable
omega_min = min(omega);
omega_max = max(omega);
mag_min = 10^floor(log10(min(mag)));
mag_max = 10^ceil(log10(max(mag)));

% Make sure min and max magnitude axes are not equal
if (mag_min == mag_max)
  mag_min = mag_min/10;
  mag_max = mag_max*10;
end

set(gca, 'XTickLabel', {});
if (exist('amaxis'))
  amaxis([omega_min, omega_max, mag_min, mag_max]);
else
  axis([omega_min, omega_max, mag_min, mag_max]);
end
ylabel('Gain');

% Set the tick labels at reasonable powers of 10
mag_incr = ceil((log10(mag_max) - log10(mag_min))/3);
set(gca, 'YTick', 10.^(log10(mag_min):mag_incr:log10(mag_max)));

% Set the frequency labels at reasonable powers of 10
omega_incr = ceil((log10(omega_max) - log10(omega_min))/4);
set(gca, 'XTick', 10.^(log10(omega_min):omega_incr:log10(omega_max)));

% Phase plot
phaseh = axes('position', [curpos(1), phabot, curpos(3), height]);
h = semilogx(omega, squeeze(phase));
set(h, 'LineWidth', AM_bode_linewidth);

% Set the axis limits to something sensible
phase_min = floor(min(phase)/90) * 90; phase_max = ceil(max(phase)/90) * 90;
if (phase_max < 0) phase_max = 0; end;
if (phase_min > 0) phase_min = 0; end;
if (phase_min == phase_max) 
  phase_max = phase_max + 45;
  phase_min = phase_min - 45;
end
if (exist('amaxis'))
  amaxis([min(omega), max(omega), phase_min, phase_max]);
else
  axis([min(omega), max(omega), phase_min, phase_max]);
end;
ylabel('Phase [deg]'); xlabel('Frequency [rad/s]');

% Set the tick labels to be at 90 degree increments
set(gca, 'YTick', [phase_min:90:phase_max]);
set(gca, 'XTick', 10.^(log10(omega_min):omega_incr:log10(omega_max)));
