function groupplot(wdir, varargin)
% SINGLEPLOT   Plots all frequency domain data sets in their own figures
%
% SINGLEPLOT(DIR) searches the directory DIR and all subdirectories for any
% MAT data files containing the FD struct.
%
% SINGLEPLOT(DIR, 'log') will plot data on a logarithmic axis

% define default behaviour
XAXIS = 'lin';
SAVEFIG = false;

% normalization factor
fnorm = 20/1000;
dnorm = 0;

% parse user input
if nargin > 3
    SAVEFIG = varargin{2};
    XAXIS = varargin{1};
elseif nargin > 2
    XAXIS = varargin{1};
end

% search subdirectories for matching files
flist=findfiles(wdir, '\.mat', 1);
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
    dname = fname(23:25);
    
    % plot results to graph
    disp(sprintf('[%d] Plotting %s', fnum, fname));
    switch XAXIS
        case 'lin'
            cline = plot(fnorm * fd.freq(1:ind-1), dnorm + fd.avgDB(1:ind-1), 'DisplayName', dname);
        case 'log'
            cline = semilogx(fnorm * fd.freq(1:ind-1), dnorm + fd.avgDB(1:ind-1), 'DisplayName', dname);
        otherwise
            error('Incorrect mode for xaxis plot')
    end
    
    % setup axes
    faxis = axis;
    faxis(1) = fnorm * fmin;
    faxis(2) = fnorm * fmax;
    axis(faxis);
    
    grid on;
    xlabel('Frequency');
    ylabel('dB');
    title(strrep(pattern,'_',' '));

    % save figure to working directory
    if SAVEFIG
        figname = [pattern(1:end-4) '.fig'];
        saveas(gcf, figname, 'fig');
        disp(sprintf('Saving figure to %s', figname));
    end
end
