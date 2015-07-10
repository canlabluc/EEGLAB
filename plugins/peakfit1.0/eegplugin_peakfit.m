% eegplugin_peakfit() - Peak fitting plugin
%
% Usage:
%   >> eegplugin_peakfit(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer] eeglab figure.
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
%
% Reference:
%
% @article{gerson2005,
%       author = {Adam D. Gerson and Lucas C. Parra and Paul Sajda},
%       title = {Cortical Origins of Response Time Variability
%                During Rapid Discrimination of Visual Objects},
%       journal = {{NeuroImage}},
%       year = {in revision}}
%
% Authors: Adam Gerson (adg71@columbia.edu, 2005),
%          with Lucas Parra (parra@ccny.cuny.edu, 2005)
%	   and Paul Sajda (ps629@columbia,edu 2005)

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2005 Adam Gerson, Lucas Parra and Paul Sajda
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function vers = eegplugin_peakfit(fig, try_strings, catch_strings); 

vers='peakfit1.0';
if nargin < 3
    error('eegplugin_peakfit requires 3 arguments');
end;

% add peakfit folder to path
% -----------------------
if ~exist('pop_peakfit')
    p = which('eegplugin_peakfit');
    p = p(1:findstr(p,'eegplugin_peakfit.m')-1);
    addpath([ p vers ] );
end;


% create menu
menu = findobj(fig, 'tag', 'tools');

% menu callback commands
% ----------------------

cmd = [try_strings.no_check '[EEG LASTCOM]=pop_peakfit(EEG); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' catch_strings.store_and_hist];

% add new submenu
uimenu( menu, 'label', 'Fit peaks', 'callback', cmd);
uimenu(menu,'label','Display peak fit','callback',['pop_displayfit(ALLEEG, EEG, CURRENTSET);']);
