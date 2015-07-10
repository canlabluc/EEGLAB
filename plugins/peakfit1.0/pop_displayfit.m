% pop_displayfit() - Display single-trial fit to EEG derived using
%                    pop_peakfit().  This GUI displays the EEG data or
%                    ICA component as an image (trials vs. time, top) along
%                    with the corresponding fits (middle).  The bottom plot
%                    shows the fit for one trial and the R^2 value that
%                    describes the goodness-of-fit.  The fit for this trial
%                    can be re-estimated by clicking the plot at an
%                    estimate of the peak time.  EEG and ALLEEG will be
%                    updated to reflect the new parameters of this fit.
%
% Usage:
%   >> pop_displayfit(ALLEEG,EEG,CURRENTSET);
%
% Inputs:
%   ALLEEG     - EEGLAB data set structure
%   EEG        - EEGLAB data set structure
%   CURRENTSET - Current EEGLAB data set
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

function [ALLEEG EEG CURRENTSET]=pop_displayfit(ALLEEG,EEG,CURRENTSET,action);

if nargin < 1
    help pop_displayfit;
    return;
end;
if isempty(EEG)
    error('pop_displayfit(): cannot process empty sets of data');
end;
if ~(isfield(EEG,'eegfit')|isfield(EEG,'icafit')),
    error('pop_displayfit(): Peak fits not present');
end
if nargin<4,
    action='initialize';
end

if strcmp(action,'initialize'),
    x=EEG.times';

    % Search for first set of parameters
    if isfield(EEG,'eegfit'),
        dataselect=1;
    elseif isfield(EEG,'icafit'),
        dataselect=2;
    end

    if dataselect==1,
        data=EEG.data;
        fit=EEG.eegfit;
    elseif dataselect==2,
        if isfield(EEG,'icafit'),
            data=EEG.icaact;
            fit=EEG.icafit;
        else
            set(hdataselect,'Value',1);
            error('pop_displayfit(): Component fits not present');
        end
    end

    channeli=1;
    while isempty(fit(channeli).alpha),
        channeli=channeli+1;
        if channeli>length(fit),
            error('popdisplayfit(): Component fits not present');
        end
    end

    for triali=1:EEG.trials,
        p=[fit(channeli).alpha(triali) fit(channeli).beta(triali) ...
            fit(channeli).sigma(triali) fit(channeli).mu(triali)];
        yfit(triali,:)=eegfit(p,x);
    end

    hdisplayfit=findobj('Tag','displayfit');
    if ~isempty(hdisplayfit),
        % Delete old handles
        figure(hdisplayfit);
        hdataselect=findobj('Tag','dataselect');
        delete(hdataselect);
        delete(hdisplayfit);
    end

    hdisplayfit=figure;
    set(hdisplayfit,'Tag','displayfit','Name','Peak fits','NumberTitle','off');

    subplot(3,1,1);
    y=double(squeeze(data(channeli,:,:))');
    imagesc(EEG.times,1:EEG.trials,y,[-3 3].*std(y(:)));
    set(get(gca,'Children'),'ButtonDownFcn','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''selecttrial'');');

    triali=1;
    displaydata.y=y;
    displaydata.yfit=yfit;
    displaydata.triali=triali;
    displaydata.channeli=channeli;
    set(gcf,'UserData',displaydata);

    if dataselect==1,
        if ~isempty(EEG.chanlocs),
            title(['EEG Channel ' EEG.chanlocs(channeli).labels]);
        else
            title(['EEG Channel ' num2str(channeli)]);
        end
    else
        title(['Component ' num2str(channeli)]);
    end

    ylabel('Trials');
    set(gca,'XTickLabel',[]);

    pos=get(gca,'Position');
    hnextchannel=uicontrol('Units','normalized','Position',[pos(1)+pos(3)-.2 pos(2)-.075 .2 .05 ], ...
        'string','Next Channel','call','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''nextchannel'');');
    hpreviouschannel=uicontrol('Units','normalized','Position',[pos(1) pos(2)-.075 .2 .05 ], ...
        'string','Previous Channel','call','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''previouschannel'');');
    hdataselect=uicontrol('Style','popupmenu','string',{'EEG' 'ICA'}, ...
        'Units','normalized','position',[.805 .85 .1 .1],'call','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''dataselect'');', ...
        'Tag','dataselect','Value',dataselect,'backgroundcolor','w');

    subplot(3,1,2);
    imagesc(EEG.times,1:EEG.trials,yfit,[-3 3].*std(y(:)));
    title('Fit');
    ylabel('Trials');
    set(gca,'XTickLabel',[]);
    set(get(gca,'Children'),'ButtonDownFcn','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''selecttrial'');');

    triali=1;
    subplot(3,1,3);
    hold off;
    plot(EEG.times,y(triali,:));
    hold on;
    plot(EEG.times,yfit(triali,:),'r');
    r2=rsquare(y(triali,:),yfit(triali,:));
    titlestr=sprintf('Trial %d, R^2 = %1.4f', displaydata.triali, r2);
    title(titlestr);
    ylabel('\muV');
    set(gca,'ButtonDownFcn','[ALLEEG EEG CURRENTSET]=pop_displayfit(ALLEEG,EEG,CURRENTSET, ''refittrial'');');

    pos=get(gca,'Position');
    hnexttrial=uicontrol('Units','normalized','Position',[pos(1)+pos(3)-.2 0 .2 .05 ], ...
        'string','Next Trial','call','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''nexttrial'');');
    hprevioustrial=uicontrol('Units','normalized','Position',[pos(1) 0 .2 .05 ], ...
        'string','Previous Trial','call','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''previoustrial'');');
    herpselect=uicontrol('Style','checkbox','Units','normalized', ...
        'Position',[.131 .3 .07 .03],'String','ERP','BackgroundColor','w', ...
        'call','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''erpselect'');', ...
        'Tag', 'erpselect');
    hpolarityselect=uicontrol('Style','popupmenu','string',{'Positive' 'Negative'}, ...
        'Units','normalized','position',[.788 .245 .12 .1],'call', ...
        '[ALLEEG EEG CURRENTSET]=pop_displayfit(ALLEEG,EEG,CURRENTSET, ''switchpolarity'');', ...
        'Tag','polarityselect','Value',(fit(channeli).beta(1)<0)+1,'backgroundcolor','w');

    LASTCOM = sprintf('pop_displayfit(ALLEEG,EEG,CURRENTSET);');

elseif strcmp(action,'previoustrial'),
    displaydata=get(gcf,'UserData');
    displaytrial(EEG,displaydata,-1);

elseif strcmp(action,'nexttrial'),
    displaydata=get(gcf,'UserData');
    displaytrial(EEG,displaydata,1);

elseif strcmp(action,'previouschannel'),
    displaydata=get(gcf,'UserData');
    displaychannel(EEG,displaydata,-1);

elseif strcmp(action,'nextchannel'),
    displaydata=get(gcf,'UserData');
    displaychannel(EEG,displaydata,1);

elseif strcmp(action,'dataselect'),
    displaydata=get(gcf,'UserData');
    displaydata.channeli=0; % Search again for first set of parameters
    displaychannel(EEG,displaydata,0);

elseif strcmp(action,'selecttrial'),
    clickpos=get(gca,'CurrentPoint');
    ypos=clickpos(1,2); % Y position of last mouse click
    displaydata=get(gcf,'UserData');
    displaydata.triali=round(ypos);
    set(gcf,'UserData',displaydata);
    displaytrial(EEG,displaydata,0);

elseif strcmp(action,'refittrial'),
    clickpos=get(gca,'CurrentPoint');
    xpos=clickpos(1,1); % X position of last mouse click
    displaydata=get(gcf,'UserData');
    [EEG,displaydata]=refittrial(EEG,displaydata,xpos);
    ALLEEG(CURRENTSET)=EEG;
    displaytrial(EEG,displaydata,0);
    subplot(3,1,2);
    set(get(gca,'Children'),'CData',displaydata.yfit);

elseif strcmp(action,'switchpolarity'),    
    displaydata=get(gcf,'UserData');
    herpselect=findobj('Tag','erpselect');
    erpselect=get(herpselect,'Value');
    hdataselect=findobj('Tag','dataselect');
    dataselect=get(hdataselect,'Value');
    if dataselect==1,
        fit=EEG.eegfit;
    elseif dataselect==2,
        fit=EEG.icafit;
    end
    if erpselect==0,
        xpos=fit(displaydata.channeli).mu(displaydata.triali);
    else
        xpos=fit(displaydata.channeli).mu_erp;
    end

    [EEG,displaydata]=refittrial(EEG,displaydata,xpos);
    ALLEEG(CURRENTSET)=EEG;
    displaytrial(EEG,displaydata,0);
    subplot(3,1,2);
    set(get(gca,'Children'),'CData',displaydata.yfit);
    
elseif strcmp(action,'erpselect'),
    displaydata=get(gcf,'UserData');
    displaytrial(EEG,displaydata,0);

end


set(gcf,'color','w');

return;

function displaytrial(EEG,displaydata,advance)

subplot(3,1,3);
displaydata.triali=displaydata.triali+advance;

if ismember(displaydata.triali,1:EEG.trials),

    herpselect=findobj('Tag','erpselect');
    erpselect=get(herpselect,'Value');
    hdataselect=findobj('Tag','dataselect');
    dataselect=get(hdataselect,'Value');
    hpolarityselect=findobj('Tag','polarityselect');
    
    if dataselect==1,
        fit=EEG.eegfit;
    elseif dataselect==2,
        fit=EEG.icafit;
    end

    if ~erpselect,
        y=displaydata.y(displaydata.triali,:);
        yfit=displaydata.yfit(displaydata.triali,:);
        polarityselect=(fit(displaydata.channeli).beta(displaydata.triali)<0)+1;        
    else
        y=mean(displaydata.y);
        p=[fit(displaydata.channeli).alpha_erp fit(displaydata.channeli).beta_erp ...
            fit(displaydata.channeli).sigma_erp fit(displaydata.channeli).mu_erp];
        yfit=eegfit(p,EEG.times')';
        polarityselect=(p(2)<0)+1;
    end

    hold off;
    plot(EEG.times,y);
    hold on;
    plot(EEG.times,yfit,'r');
    r2=rsquare(y,yfit);

    if ~erpselect,
        titlestr=sprintf('Trial %d, R^2 = %1.4f', displaydata.triali, r2);
    else
        titlestr=sprintf('ERP, R^2 = %1.4f', r2);
    end

    title(titlestr);
    ylabel('\muV');
    
    set(hpolarityselect,'Value',polarityselect);
    set(gca,'ButtonDownFcn','[ALLEEG EEG CURRENTSET]=pop_displayfit(ALLEEG,EEG,CURRENTSET, ''refittrial'');');
    set(gcf,'UserData',displaydata);
end

return

function displaychannel(EEG,displaydata,advance)

channeli=displaydata.channeli+advance;
herpselect=findobj('Tag','erpselect');
erpselect=get(herpselect,'Value');
hdataselect=findobj('Tag','dataselect');
dataselect=get(hdataselect,'Value');
hpolarityselect=findobj('Tag','polarityselect');

if dataselect==1,
    data=EEG.data;
    fit=EEG.eegfit;
elseif dataselect==2,
    if isfield(EEG,'icafit'),
        data=EEG.icaact;
        fit=EEG.icafit;
    else
        set(hdataselect,'Value',1);
        error('pop_displayfit(): Component fits not present');
    end
end

if channeli==0,
    channeli=1;
    while isempty(fit(channeli).alpha),
        channeli=channeli+1;
        if channeli>length(fit),
            error('pop_displayfit(): Component fits not present');
        end
    end
end

if ismember(channeli,1:length(fit)),

    if ~isempty(fit(channeli).alpha),

        x=EEG.times';

        for triali=1:EEG.trials,
            p=[fit(channeli).alpha(triali) fit(channeli).beta(triali) ...
                fit(channeli).sigma(triali) fit(channeli).mu(triali)];
            yfit(triali,:)=eegfit(p,x);
        end

        subplot(3,1,1);
        y=double(squeeze(data(channeli,:,:))');
        imagesc(EEG.times,1:EEG.trials,y,[-3 3].*std(y(:)));
        set(get(gca,'Children'),'ButtonDownFcn','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''selecttrial'');');
        if dataselect==1,
            if ~isempty(EEG.chanlocs),
                title(['EEG Channel ' EEG.chanlocs(channeli).labels]);
            else
                title(['EEG Channel ' num2str(channeli)]);
            end
        else
            title(['Component ' num2str(channeli)]);
        end

        ylabel('Trials');
        set(gca,'XTickLabel',[]);

        subplot(3,1,2);
        imagesc(EEG.times,1:EEG.trials,yfit,[-3 3].*std(y(:)));
        title('Fit');
        ylabel('Trials');
        set(gca,'XTickLabel',[]);
        set(get(gca,'Children'),'ButtonDownFcn','pop_displayfit(ALLEEG,EEG,CURRENTSET, ''selecttrial'');');

        triali=displaydata.triali;

        displaydata.y=y;
        displaydata.yfit=yfit;
        displaydata.triali=triali;
        displaydata.channeli=channeli;

        subplot(3,1,3);
        if ~erpselect,
            y=displaydata.y(displaydata.triali,:);
            yfit=displaydata.yfit(displaydata.triali,:);
            polarityselect=(fit(displaydata.channeli).beta(displaydata.triali)<0)+1;
        else
            if dataselect==1,
                fit=EEG.eegfit;
            elseif dataselect==2,
                fit=EEG.icafit;
            end
            y=mean(displaydata.y);
            p=[fit(displaydata.channeli).alpha_erp fit(displaydata.channeli).beta_erp ...
                fit(displaydata.channeli).sigma_erp fit(displaydata.channeli).mu_erp];
            yfit=eegfit(p,EEG.times')';
            polarityselect=(p(2)<0)+1;
        end

        hold off;
        plot(EEG.times,y);
        hold on;
        plot(EEG.times,yfit,'r');
        r2=rsquare(y,yfit);

        if ~erpselect,
            titlestr=sprintf('Trial %d, R^2 = %1.4f', displaydata.triali, r2);
        else
            titlestr=sprintf('ERP, R^2 = %1.4f', r2);
        end

        title(titlestr);
        ylabel('\muV');

        set(hpolarityselect,'Value',polarityselect);
        set(gca,'ButtonDownFcn','[ALLEEG EEG CURRENTSET]=pop_displayfit(ALLEEG,EEG,CURRENTSET, ''refittrial'');');
        set(gcf,'UserData',displaydata);

    end
end
return


function [EEG,displaydata]=refittrial(EEG,displaydata,xpos)

hdataselect=findobj('Tag','dataselect');
dataselect=get(hdataselect,'Value');
herpselect=findobj('Tag','erpselect');
erpselect=get(herpselect,'Value');
hpolarityselect=findobj('Tag','polarityselect');
polarityselect=get(hpolarityselect,'Value');

rand('state',0);
options=optimset('lsqcurvefit');
options=optimset(options,'Display','off'); %,'TolFun',1e-3,'TolX',1e-3);

x=EEG.times';

p0=[0 1 40 xpos];

if dataselect==1,
    if polarityselect==1,
        p0(2)=1;
        lb=[-inf  1 0 -inf]; % lower bound - positive peak
        ub=[inf inf 50 inf]; % upper bound - not too broad
    else
        p0(2)=-1;
        lb=[-inf -inf 0 -inf]; % lower bound - negative peak
        ub=[inf    -1 50 inf]; % upper bound - not too broad
    end

    if ~erpselect,
        y=double(squeeze(EEG.data(displaydata.channeli,:,displaydata.triali))');
        p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
        EEG.eegfit(displaydata.channeli).alpha(displaydata.triali)=p(1);
        EEG.eegfit(displaydata.channeli).beta(displaydata.triali)=p(2);
        EEG.eegfit(displaydata.channeli).sigma(displaydata.triali)=p(3);
        EEG.eegfit(displaydata.channeli).mu(displaydata.triali)=p(4);
    else
        y=double(mean(squeeze(EEG.data(displaydata.channeli,:,:)),2));
        p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
        EEG.eegfit(displaydata.channeli).alpha_erp=p(1);
        EEG.eegfit(displaydata.channeli).beta_erp=p(2);
        EEG.eegfit(displaydata.channeli).sigma_erp=p(3);
        EEG.eegfit(displaydata.channeli).mu_erp=p(4);
    end
end

if dataselect==2,
    if polarityselect==1,
        p0(2)=1;
        lb=[-inf  1 0 -inf]; % lower bound - positive peak
        ub=[inf inf 50 inf]; % upper bound - not too broad
    else
        p0(2)=-1;
        lb=[-inf -inf 0 -inf]; % lower bound - negative peak
        ub=[inf    -1 50 inf]; % upper bound - not too broad
    end

    if ~erpselect,
        y=double(squeeze(EEG.icaact(displaydata.channeli,:,displaydata.triali))');
        p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
        EEG.icafit(displaydata.channeli).alpha(displaydata.triali)=p(1);
        EEG.icafit(displaydata.channeli).beta(displaydata.triali)=p(2);
        EEG.icafit(displaydata.channeli).sigma(displaydata.triali)=p(3);
        EEG.icafit(displaydata.channeli).mu(displaydata.triali)=p(4);
    else
        y=double(mean(squeeze(EEG.icaact(displaydata.channeli,:,:)),2));
        p=lsqcurvefit(@eegfit, p0, x, y, lb,ub,options);
        EEG.icafit(displaydata.channeli).alpha_erp=p(1);
        EEG.icafit(displaydata.channeli).beta_erp=p(2);
        EEG.icafit(displaydata.channeli).sigma_erp=p(3);
        EEG.icafit(displaydata.channeli).mu_erp=p(4);
    end
end

if ~erpselect,
    displaydata.yfit(displaydata.triali,:)=eegfit(p,x);
end
set(gcf,'UserData',displaydata);

return


function r2=rsquare(y,yfit)
% Outputs:
%   r2 - Goodness of fit adjusted r-square value

% Data range includes the entire epoch.  This obviously effects r2.

n=length(y);
m=4; % number of fitted parameters (mean, variance, DC offset, scaling)
v=n-m; % degrees of freedom

r2=1-var(y-yfit)./var(y).*((n-1)./v);

return
