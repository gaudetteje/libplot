function groupplot(wdir, pattern, varargin)
% GROUPPLOT   Plots all data sets in subdirectories with file names
% matching the input parameter
%
% GROUPPLOT(DIR, PATTERN) will plot all files matching the PATTERN
%     regular expression under the base directory, DIR.
%
% GROUPPLOT(DIR, PATTERN, CHANNEL) plots only the channel(s) found in the
%     array of integers, CHANNEL.
%
% GROUPPLOT(DIR, PATTERN, false) will plot each file separately
%
% GROUPPLOT(DIR, PATTERN, true, 'log') will use a logarithmic x-axis rather than
%     linear.
%
% Example:
%   Plot all files below the current directory with the exact name
%   "TransferFn_CH001.mat" on a logarithmic scale
%     >> groupplot('.', '^TransferFn\_CH001\.mat$', true, 'log')
%   Plot all files in subdirectory "20090706" with a name starting "FFT 0p1 " and ending "CH002.mat"
%     >> groupplot('20090706', '^FFT 0p1 .*CH002\.mat')
%
% See also  TILEFIGS, SHOWFIGS

% Author:   Jason Gaudette
% Company:  Naval Undersea Warfare Center (Newport, RI)
% Phone:    401.832.6601
% Email:    gaudetteje@npt.nuwc.navy.mil
% Date:     20151224
%

% define default behaviour
XAXIS = 'lin';
SAVEFIG = false;
HOLDING = true;
CHANNEL = 1;

% normalization factor (optional)
xnorm = 1e3;
ynorm = 1;

% parse user input
if nargin > 4
    SAVEFIG = varargin{3};
    XAXIS = varargin{2};
    HOLDING = varargin{1};
elseif nargin > 3
    XAXIS = varargin{2};
    HOLDING = varargin{1};
elseif nargin > 2
    if islogical(varargin{1})
        HOLDING = varargin{1};
    else
        CHANNEL = varargin{1};
    end
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
fprintf('Found %d files...\n', nfiles);

% initialize vars
nplot = 0;
%xmin = 0;
%xmax = 0;
keys = {};

% iterate over each file found
for fnum=1:nfiles
    
    % load MAT file
    fname = char(flist(fnum));
    load(fname);
    if ~exist('fd','var') && ~exist('ts','var')
        fprintf('[%d] No frequency or time series data structs found!  Bypassing "%s"\n', nplot+1, fname);
        continue;
    end
    
    % get x-axis data
    if exist('fd','var')
        xx = fd.freq;
        xUnits = 'Frequency (Hz)';
    elseif exist('ts','var')
        if isfield(ts,'time')
            xx = ts.time;
        else
            xx = (0:size(ts.data,1)-1)./ts.fs;
        end
        xUnits = 'Time (seconds)';
    end
    
    % get y-axis data
    if exist('fd','var')
        fnames = fieldnames(fd);
        for n = 1:numel(fnames)
            if any(strcmpi(fnames{n}, {'avgdb','magdb'}))
                field = fnames{n};
                continue
            end
        end
        if ~exist('field','var') || isempty(field)
            error('Could not identify y-axis data field!');
        end
        yy = fd.(field)(:,CHANNEL);
        yUnits = 'dB';
    elseif exist('ts','var')
        yy = ts.data(:,CHANNEL);
        yUnits = 'Amplitude (Volts)';
    end
    
    % plot results to graph
    fprintf('[%d] Plotting %s\n', fnum, fname);
    switch XAXIS
        case 'lin'
            cline = plot(xnorm * xx, ynorm * yy);
        case 'log'
            cline = semilogx(xnorm * xx, ynorm * yy);
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
    
    % force axes to overall data extent
    %xAxis = axis;
    %xAxis(1) = xnorm * xmin;
    %xAxis(2) = xnorm * xmax;
    %axis(xAxis);
    
    % update count
    nplot = nplot + 1;
    
    if ~HOLDING
        grid on;
        xlabel(xUnits);
        ylabel(yUnits);
        title(strrep(fname(3:end),'_',' '));

        % save figure to working directory
        if SAVEFIG
            figname = [fname(1:end-4) '.fig'];
            saveas(gcf, figname, 'fig');
            fprintf('Saving figure to %s\n', figname);
        end
        
        pause(1)
    end
end

if HOLDING
    grid on;
    xlabel(xUnits);
    ylabel(yUnits);
    title(strrep(pattern, '\', ''), 'Interpreter', 'none');
end
