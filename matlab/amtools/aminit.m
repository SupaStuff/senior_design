% aminit-link.m - initialization script for MATLAB
% RMM, 25 Jul 06
%
% This script is called by various files that are used to generate
% plots for printing.  This file should be called from a directory
% such that the path '../../matlab' points to the location of the AM
% MATLAB library.
%
% Makefiles should create a link from 'aminit.m' in the directory
% where the scripts that generate figures live to this file.

% Check to see if path already includes AM matlab dir
if exist('amsetup') ~= 2
  % Look in standard loations for the file, assuming AM08 directory structure
  if (exist('../../matlab/amsetup.m'))
    addpath('../../matlab');		% add path to AM commands
  elseif (exist('../matlab/amsetup.m'))
    addpath('../matlab');
  elseif (exist('../amsetup.m'))
    addpath('../matlab');
  else
    fprintf(1, 'Warning: cannot find path to amsetup\n');
    return;    
  end
end

% Make sure that we have actually run amsetup
if (exist('AMPRINT_FLAG') ~= 1)
    evalin('base', 'amsetup');		% initialize global variables
end

% Reset figures for scripts that aren't smart about clearing them
figure(1); clf;
