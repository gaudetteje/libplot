function plotfft(varargin)
% PLOTFFT  Plots results from GROUPFFT

% Author:   Jason Gaudette
% Company:  Naval Undersea Warfare Center (Newport, RI)
% Phone:    401.832.6601
% Email:    gaudetteje@npt.nuwc.navy.mil
% Date:     20060928
%

winname = 'rectwin'

tic;    % start timer

% get directory to search
if (nargin > 0)
    wdir = char(varargin(1));
else
    wdir = uigetdir;
end
if (wdir(end) ~= '\')
    wdir = [wdir '\'];
end

% log output to file
diary([wdir sprintf('plotfft_log_%s.txt', date)]);
disp(datestr(now))

% compile search results
flist = findfiles(wdir, '^FFT');
nfiles = length(flist);
if ~nfiles
    error('No files found in directory "%s"', wdir);
    diary 'off';
end

disp(sprintf('Found %d files...', nfiles));

for fnum=1:nfiles
    % clear variables for next iteration
    clear ts pulse fd
    
    % parse string for file and path names
    fname = char(flist(fnum));
    ind = max(strfind(fname,'\'));
    fdir = fname(1:ind);
    fname = fname(ind+1:end);
    fname_fft = ['FFT ' fname(1:end-4) ' ' winname '.mat'];
    
    % load MAT file
    load([fdir fname]);
    if ~exist('ts', 'var')
        disp(sprintf('[%d] No time series data struct found!  Bypassing "%s"', fnum, fname));
        continue;
    end
    if ~exist('pulse', 'var')
        disp(sprintf('[%d] Pulses have not yet been located!  Bypassing "%s"', fnum, fname));
        continue;
    end
    if exist(fname_fft, 'file')
        disp(sprintf('[%d] Frequency spectrum already calculated!  Bypassing "%s"', fnum, fname));
        continue;
    end
    
    fprintf('[%d] Processing "%s" using "%s" window\n', fnum, fname, winname);
    
    fd.winname = winname;
    fd.points = length(ts.time);
    fd.fs = ts.fs;
    
    % take Navg distinct pulses
    for N = 1:Navg
        ind = [round(pulse.start(3+N)*fd.fs) : round(pulse.stop(3+N)*fd.fs)];
        [fd.freq, fd.data(N,:), fd.dataDB(N,:)] = signalfft(ts.time(ind), ts.data(ind), fd.points);
    end
    
    fd.avg = mean(fd.data, 1);
    fd.avgDB = db(fd.avg);
    fd.units = 'dB re max';
    
    % save spectrum data into MAT file
    try
        save([fdir fname_fft], 'fd', '-MAT');
    catch
        warning('Could not save data to file: "%s"\n', fname);
        continue
    end
end

fprintf('Finished processing %d files in %.0f seconds (%.2f minutes).\n\n', nfiles, toc, toc/60);
diary off;
