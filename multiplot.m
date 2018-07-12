function multiplot(varargin)
% MULTIPLOT   Plot multiple user selected FFT data on an overlapping figure
%
% MULTIPLOT()  prompts you for frequency spectrum plots until you select
% cancel.
% MULTIPLOT(DBnorm,Fnorm)  normalizes the plots by adding DBnorm to the
% vertical axis and dividing by Fnorm on the frequency scale.  D=0 and F=1
% are the default values.
% MULTIPLOT(DBnorm,Fnorm,'log')  plots a logarithmic x axis useful for some
% data sets.

% define default behaviour
xaxis = 'lin';

% normalization factor
fnorm = 1;
dnorm = 0;

% parse user input
switch nargin
    case 3
        xaxis = varargin{3};
        fnorm = varargin{2};
        dnorm = varargin{1};
    case 2
        fnorm = varargin{2};
        dnorm = varargin{1};
    case 0
    otherwise
        error('Incorrect number of arguments');
end

% set up figure window
fh = figure('Visible', 'off');
colors = get(gca,'ColorOrder');

% initialize vars
nplot = 0;
fmin = 0;
fmax = 0;
keys = {};

% iterate over each file to plot
while 1
    [fname, fpath] = uigetfile('*.mat', 'Select a file to plot');
    % stop when user presses "cancel"
    if ~fname
        if ~nplot
            close(fh);
            return;
        else
            break;
        end
    end
    
    % load MAT file
    load(fullfile(fpath, fname));
    if ~exist('fd', 'var')
        disp(sprintf('[%d] No frequency data struct found!  Bypassing "%s"', nplot+1, fullfile(fpath, fname)));
        continue;
    end
    
    % extract data for plotting window
    fd.magdb(fd.magdb < -500) = NaN;        % remove any invalid data points
    fmin = min(fd.freq);
    fmax = max(fd.freq);
    dname = fname;
    
    % plot results to graph
    set(fh,'Visible','on');
    switch xaxis
        case 'lin'
            cline = plot(fd.freq ./ fnorm, dnorm + fd.magdb, 'DisplayName', dname);
        case 'log'
            cline = semilogx(fd.freq ./ fnorm, dnorm + fd.magdb, 'DisplayName', dname);
        otherwise
            error('Incorrect mode for xaxis plot')
    end
    hold on;
    grid on;
    xlabel('Frequency');
    ylabel('dB');
    clr = colors(mod(nplot,length(colors))+1,:);    % force use of next color
    set(cline, 'Color', clr);
    
    % setup legend
    dirs = findstr(filesep,fpath);
    parentdir = fpath(dirs(end-1)+1:end);
    keys(end+1) = {[parentdir dname]};
    legend(char(keys));
    set(legend, 'Interpreter', 'none');
    
    % setup axes
    faxis = axis;
    faxis(1) = fmin / fnorm;
    faxis(2) = fmax / fnorm;
    axis(faxis);
    
    % update count
    nplot = nplot + 1;
    
    pause(.1);
end

% save plot to user specefied file
[dname, dpath] = uiputfile;
if dname
    saveas(gcf, fullfile(dpath, dname), 'fig');
end
