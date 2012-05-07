function tsplot(varargin)
% TSPLOT   This script will plot time-series data converted into MATLAB's
% binary format and stored in the standard structure format
% 
% ts.time is assumed to contain the time sequence





% 
%

tic;    % start timer

% get directory to search
switch nargin
    case 0
        wdir = uigetdir;
    case 1
        wdir = char(varargin(1));
    case 2
        wdir = char(varargin(1));
        varnames = varargin{2};
    otherwise
        error('Incorrect number of parameters entered!')
end

if (wdir(end) ~= filesep)
    wdir = [wdir filesep];
end

% log output to file
diary([wdir sprintf('tsplot_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist = findfiles(wdir, '\.mat$', false);
nfiles = length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

% initialize figure window for plotting
close all hidden;
fh = figure('Visible', 'off');
colors = get(gca,'ColorOrder');

for fnum=1:nfiles
    
    % parse string for file and path names
    fname = char(flist(fnum));
    ind = max(strfind(fname,filesep));
    fdir = fname(1:ind);
    fname = fname(ind+1:end);
    fname_fig = [fname(1:end-4) '.fig'];
    
    % check for previously generated plot
%     if exist([fdir fname_fig], 'file')
%         disp(sprintf('[%d] Time series already plotted for "%s"', fnum, [fdir fname]));
%         continue;
%     end
    
    % load MAT file
    load([fdir fname]);
    if ~exist('ts', 'var')
        disp(sprintf('[%d] No time series data struct found!  Bypassing "%s"', fnum, [fdir fname]));
        continue;
    end
    fprintf('[%d] Plotting time series data of "%s"\n', fnum, fname);
    
    % plot data in file, if specified or otherwise found
    if exist('varnames','var')
        keys = varnames;
        
        % iterate over each variable entered by user
        nplot = 0;
        for pnum = 1:length(keys)
            if isfield(ts,keys{pnum})
                clr = colors(mod(nplot,length(colors))+1,:);  % force use of next color
                nplot = nplot + 1;
                plot(ts.time, ts.(keys{pnum}), 'Color', clr)
                hold on;
            else
                keys = keys([1:pnum-1 pnum+1:end]);
                warning(sprintf('    "ts.%s" not found... Skipping this variable.',varnames{pnum}))
            end
        end
        
        % setup legend
        lh = legend(keys);
        set(lh,'Interpreter','none')
    
    elseif exist('ts.data')
        plot(ts.time, ts.data);
    else
        disp(sprintf('[%d] ts.data not found and no variables specified!  Bypassing "%s"', fnum, [fdir fname]));
        continue;
    end
    
    % setup plot attributes
    grid on;
    title(fname,'interpreter','none')
    xlabel('Time (seconds)')
    ylabel('Amplitude')
    
    % save plot of time series
    try
        set(fh, 'Visible', 'on');
        saveas(fh, [fdir fname_fig], 'fig');
        set(fh, 'Visible', 'off');
    catch
        warning('Could not save figure to file: "%s"\n', fname_fig);
        continue
    end
end

fprintf('Finished plotting %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
