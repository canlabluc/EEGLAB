% F = eegfit(p,xdata)
%   Returns fit to data according to parameters p for data point xdata
%
% Inputs:
%      xdata:   - vector of points to perform fit
%      p        - parameters of fit = [alpha beta sigma mu]
%                       alpha: DC offset
%                       beta:  scaling
%                       sigma: variance
%                       mu:    mean (peak time)
%
% Output:
%      F: fitted data
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
% Authors: Adam Gerson (adg71@columbia.edu, 2004),
%          with Lucas Parra (parra@ccny.cuny.edu, 2004)
%          and Paul Sajda (ps629@columbia,edu 2004)

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004 Adam Gerson, Lucas Parra and Paul Sajda
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

function F = eegfit(p,xdata)

F = p(2)/p(3)/sqrt(2*pi)*exp(-(xdata-p(4)).^2/2/p(3)^2)+p(1);

%F = p(2)/(p(3).*(sqrt(2*pi)*exp(-(xdata-p(4)).^2/(2.*p(3)^2))+p(1);
