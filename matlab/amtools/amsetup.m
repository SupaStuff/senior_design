% amsetup.m - setup script for AM book
% RMM, 3 Jul 06

% Initialize the variable that controls whether we print out plots
global AMPRINT_FLAG;
AMPRINT_FLAG = 0; 
fprintf(1, 'Printing turned off; set AMPRINT_FLAG = 1 to print\n');

% Plotting parameters; use these to keep things consistent
global AM_data_linewidth AM_ref_linewidth AM_thick_linewidth AM_thin_linewidth

AM_ref_linewidth = 0.667;	AM_ref_linestyle = 'k-';
AM_data_linewidth = 1;		AM_data_linestyle = 'b-';
AM_thin_linewidth = 0.5;		% thin lines (use sparingly)
AM_thick_linewidth = 1.5;		% thick lines (use sparingly)
AM_tick_linewidth = 0.4;		% use for tick marks on plots

global AM_bode_linewidth AM_bode_markersize AM_pzmap_markersize
AM_bode_linewidth = 1;			% linewidth for bode plots
AM_bode_markersize = 4;			% marker size for margins
AM_pzmap_markersize = 6;		% marker size for pole/zero maps

global AM_data_makersize AM_normal_arrowsize AM_small_arrowsize
AM_data_markersize = 4;			% marker size for data plots
AM_normal_arrowsize = 8;		% regular size arrowhead
AM_small_arrowsize = 6;			% small arrow (for tight plots)

% Set up default plots to use data linewidth
set(0, 'DefaultLineLineWidth', AM_data_linewidth);

% Location parameters for Bode plots
global AM_bode_magloc AM_bode_phaseloc
AM_bode_magloc = 321;
AM_bode_phaseloc = 323;

% Paramter specifications for Nyquist plots
global AM_nyquist_plain;
AM_nyquist_plain = 0;			% Set to turn off annotations
