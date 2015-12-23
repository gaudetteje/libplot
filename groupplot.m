function groupplot(wdir, pattern, varargin)
% GROUPPLOT   Plots all data sets in subdirectories with file names
% matching the input parameter
%
% GROUPPLOT(DIR, PATTERN) will plot all files matching the PATTERN
% regular expression under the base directory, DIR.
%
% GROUPPLOT(DIR, PATTERN, false) will plot each file separately
%
% GROUPPLOT(DIR, PATTERN, true, 'log') will use a logarithmic x-axis rather than
% linear.
%
% Example:
%   Plot all files below the current directory with the exact name
%   "TransferFn_CH001.mat" on a logarithmic scale
%     >> groupplot('.', '^TransferFn\_CH001\.mat$', true, 'log')
%   Plot all files in subdirectory "20090706" with a name starting "FFT 0p1 " and ending "CH002.mat"
%     >> groupplot('20090706', '^FFT 0p1 .*CH002\.mat')





% 
%

% define default behaviour
XAXIS = 'lin';
SAVEFIG = false;
HOLDING = true;

% normalization factor
fnorm = 1/1000;
dnorm = 0;

% parse user input
if nargin > 4
    SAVEFIG = varargin{3};
    XAXIS = varargin{2};
    HOLDING = varargin{1};
elseif nargin > 3
    XAXIS = varargin{2};
    HOLDING = varargin{1};
elseif nargin > 2
    HOLDING = varargin{1};
end

% set up figure window
fh = figure;
colors = get(gca,'ColorOrder');

% search subdirectories for matching files
flist=findfiles(wdir, pattern, 1);
nfiles=length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
end
disp(sprintf('Found %d files...', nfiles));

% initialize vars
nplot = 0;
fmin = 0;
fmax = 0;
keys = {};

% iterate over each file found
for fnum=1:nfiles
    
    % load MAT file
    fname = char(flist(fnum));
    load(fname);
    if ~exist('fd', 'var')
        disp(sprintf('[%d] No frequency data struct found!  Bypassing "%s"', nplot+1, fname));
        continue;
    end
    
    % extract data for plotting window
    ind = find(fd.avgDB < -500,1);      % remove any invalid data points
    if isempty(ind)
        ind = length(fd.avgDB);
    end
    fmin = min(fmin, fd.freq(1));
    fmax = max(fmax, fd.freq(ind));
    
    % plot results to graph
    disp(sprintf('[%d] Plotting %s', fnum, fname));
    switch XAXIS
        case 'lin'
            cline = plot(fnorm * fd.freq(1:ind-1), dnorm + fd.avgDB(1:ind-1));
        case 'log'
            cline = semilogx(fnorm * fd.freq(1:ind-1), dnorm + fd.avgDB(1:ind-1));
        otherwise
            error('Incorrect mode for xaxis plot')
    end
    
    if HOLDING
        hold on;

        clr = colors(mod(nplot,length(colors))+1,:);    % force use of next color
        set(cline, 'Color', clr);
    end
    
    % setup legend
    dirs = findstr(filesep,fname);
    if length(dirs) > 1
        parentdir = fname(dirs(end-1)+1:dirs(end));
    else
        parentdir = '';
    end
    keys(end+1) = {[parentdir fname(dirs(end)+1:end)]};
    legend(char(keys));
    set(legend, 'Interpreter', 'none');
    legend hide
    
    % setup axes
    faxis = axis;
    faxis(1) = fnorm * fmin;
    faxis(2) = fnorm * fmax;
    axis(faxis);
    
    % update count
    nplot = nplot + 1;
    
    %pause(2);
    if ~HOLDING

        grid on;
        xlabel('Frequency');
        ylabel('dB');
        title(strrep(fname(3:end),'_',' '));

        % save figure to working directory
        if SAVEFIG
            figname = [fname(1:end-4) '.fig'];
            saveas(gcf, figname, 'fig');
            disp(sprintf('Saving figure to %s', figname));
        end
        
        pause(1)
    end
end

if HOLDING
    grid on;
    xlabel('Frequency');
    ylabel('dB');
    title(strrep(pattern, '\', ''), 'Interpreter', 'none');
end
