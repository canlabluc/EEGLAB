% pop_peakfit() - Fit single-trial EEG with Gaussian function with
%                 parameters for peak time, duration, amplitude and
%                 baseline offset.
%
% Usage:
%   >> [EEG, LASTCOM] = pop_peakfit(EEG);
%
% Inputs:
%   EEG    - EEGLAB data set structure
%   offset - Initial peak time estimate (EEG.times units)
%            If ICA activations are present then the number of offsets
%            specified may be equal to the number of ICA activations.  In
%            this case the initial peak estimate is specified for each ICA
%            activation.  This may be useful in conjunction with the linear
%            discrimination plugin in order to find peaks from
%            discriminating components derived using training windows with
%            different center times (\tau in the reference below)
%
%            NOTE: The initial setting for this parameter is critical.  The
%            default is the middle sample of the epoch however it should be
%            some expected position such as time of the P300 or center of
%            the training window used with the linear discrimination
%            plugin.
%
% Outputs:
%   EEG    - EEG data set structure with the addition of the following
%            fields (existing parameters will be preserved unless channel 
%            or ICA activition is specified):
%   EEG.eegfit  - (1 x EEG.nbchan) structure containing peak fit
%                 parameters of EEG channels (if requested):
%                       alpha (1 x EEG.trials)   : DC offset
%                       beta  (1 x EEG.trials)   : scaling
%                       sigma (1 x EEG.trials)   : variance
%                       mu    (1 x EEG.trials)   : mean (peak time)
%                 as well as the parameters from fitting the channel ERPs:
%                       alpha_erp		 : DC offset
%                       beta_erp		 : scaling
%                       sigma_erp		 : variance
%                       mu_erp			 : mean (peak time)
%   EEG.icafit  - (1 x size(EEG.icaact,1)) structure containing peak fit
%                 parameters of ICA activations (if requested)
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
%          and Paul Sajda (ps629@columbia,edu 2005)

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

function [EEG, LASTCOM] = pop_peakfit(EEG, offset);

LASTCOM = '';
if nargin < 1
    help pop_peakfit;
    return;
end;
if isempty(EEG)
    error('pop_peakfit(): cannot process empty sets of data');
end;
if nargin < 2
    uilist = {
        { 'style' 'text' 'string' 'Initial peak time estimate (samples, 1 = epoch start):' } ...
        { 'style' 'edit' 'string' '' } ...
        {} ...
        { 'style' 'text' 'string' 'Fit EEG channels' } ...
        {} { 'style' 'checkbox' 'string' '' 'value' 0 } {} ...
        { 'style' 'text' 'string' 'Enter channel subset ([] = all):' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Peak polarity' } ...
        { 'style' 'popupmenu' 'string' {'Positive' 'Negative'} 'backgroundcolor' 'w'} ...        
        {} ...
        { 'style' 'text' 'string' 'Fit ICA activations (if present)' } ...
        {} { 'style' 'checkbox' 'string' '' 'value' 0 } {} ...
        { 'style' 'text' 'string' 'Enter ICA activation subset ([] = all):' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Peak polarity' } ...
        { 'style' 'popupmenu' 'string' {'Positive' 'Negative'} 'backgroundcolor' 'w'} ...                
        };
    result = inputgui_peakfit( { [2 .5] [2.5] [2 .15 .2 .15] [2 .5] [2 .5] [2.5] [2 .15 .2 .15] [2 .5] [2 .5]}, ...
        uilist, 'pophelp(''pop_peakfit'')', ...
        'Peak fit -- pop_peakfit()');

    if length(result) == 0 return; end;
    offset = eval( [ '[' result{1} ']' ] );
    if isempty(offset)
        offset = median(EEG.times);
    end;
    if (length(offset)>1) & (length(offset)~=size(EEG.icaact,1)),
        error('pop_peakfit(): If specifying multiple initial peak times estimates, the number must match the number of component activations');
    end

    fiteegchan=result{2};
    if isempty(fiteegchan),
        regularize=0;    
    end
    eegchansubset   = eval( [ '[' result{3} ']' ] );
    if isempty( eegchansubset ), eegchansubset = 1:EEG.nbchan; end;
    
    eegpolarity = result{4};
    if isempty(eegpolarity), eegpolarity=1; end
    
    fiticachan=result{5};
    if isempty(fiticachan),
        fiticachan=0;
    end
    icachansubset   = eval( [ '[' result{6} ']' ] );
    if isempty( icachansubset ), icachansubset = 1:size(EEG.icaact,1); end;
    if fiticachan&isempty(EEG.icaact),
        error('pop_peakfit(): ICA activations must be stored in EEG data set in order to fit peaks to these components');
    end
    
    icapolarity = result{7};
    if isempty(icapolarity), icapolarity=1; end
    
end;

try, icadefs; catch, end;

rand('state',0);
options=optimset('lsqcurvefit');
options=optimset(options,'Display','off'); %,'TolFun',1e-3,'TolX',1e-3);

x=EEG.times';

p0=[0 1 40 offset(1)];

if fiteegchan,
    fprintf('Fitting peaks for EEG channel: ');
    
    if eegpolarity==1,
        p0(2)=1;
        lb=[-inf  1 0 -inf]; % lower bound - positive peak
        ub=[inf inf 50 inf]; % upper bound - not too broad
    elseif eegpolarity==2,
        p0(2)=-1;
        lb=[-inf -inf 0 -inf]; % lower bound - negative peak
        ub=[inf    -1 50 inf]; % upper bound - not too broad
    end
    
    for channeli=eegchansubset,
        fprintf([num2str(channeli) '..']);
        p0(4)=offset(1);
        for triali=1:EEG.trials,            
            y=double(squeeze(EEG.data(channeli,:,triali))');
            p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
            EEG.eegfit(channeli).alpha(triali)=p(1);
            EEG.eegfit(channeli).beta(triali)=p(2);
            EEG.eegfit(channeli).sigma(triali)=p(3);
            EEG.eegfit(channeli).mu(triali)=p(4);
        end
        y=double(mean(squeeze(EEG.data(channeli,:,:)),2));
        p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
        EEG.eegfit(channeli).alpha_erp=p(1);
        EEG.eegfit(channeli).beta_erp=p(2);
        EEG.eegfit(channeli).sigma_erp=p(3);
        EEG.eegfit(channeli).mu_erp=p(4);
    end
    fprintf('Done.\n');
end

if fiticachan,
    if ~isempty(EEG.icaact),
        fprintf('Fitting peaks for component: ');
        
        if icapolarity==1,
            p0(2)=1;
            lb=[-inf  1 0 -inf]; % lower bound - positive peak
            ub=[inf inf 50 inf]; % upper bound - not too broad
        elseif icapolarity==2,
            p0(2)=-1;
            lb=[-inf -inf 0 -inf]; % lower bound - negative peak
            ub=[inf    -1 50 inf]; % upper bound - not too broad
        end

        if length(offset)==1,
            offset=repmat(offset,[1 size(EEG.icaact,1)]);
        end
        for channeli=icachansubset,
            fprintf([num2str(channeli) '..']);
            p0(4)=offset(channeli);
            for triali=1:EEG.trials,                
                y=double(squeeze(EEG.icaact(channeli,:,triali))');
                p=lsqcurvefit(@eegfit, p0, x, y,lb,ub,options);
                EEG.icafit(channeli).alpha(triali)=p(1);
                EEG.icafit(channeli).beta(triali)=p(2);
                EEG.icafit(channeli).sigma(triali)=p(3);
                EEG.icafit(channeli).mu(triali)=p(4);
            end
            y=double(mean(squeeze(EEG.icaact(channeli,:,:)),2));
            p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
            EEG.icafit(channeli).alpha_erp=p(1);
            EEG.icafit(channeli).beta_erp=p(2);
            EEG.icafit(channeli).sigma_erp=p(3);
            EEG.icafit(channeli).mu_erp=p(4);
        end
        fprintf('Done.\n');
    end
end

LASTCOM = sprintf('pop_peakfit(EEG, [%s]);',num2str(offset));

return;
