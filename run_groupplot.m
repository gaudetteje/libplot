% script to automatically compile AP characterization results using
% groupplot();

close all
clc

BOARDSN = 'BUMP';
PLOTTF = 1;
PLOTNF = 1;
PLOTFFT = 1;
PLOTIMD = 1;
vRangeFFT = [0.001 0.01 0.0195];
fRangeFFT = [25:10:85];
vRangeIMD = [0.001 0.00975];
fRangeIMD = [20 50];
cwd = '.';

if PLOTFFT
    % plot each FFT specified
    for v=vRangeFFT
        for f=fRangeFFT
            rexp = sprintf('^FFT\\ %s\\ V\\ %d\\ kHz_CH002.mat$', strrep(num2str(v),'.','p'), f);
            disp(sprintf('>> groupplot(''%s'',''%s'')',cwd,rexp))
            groupplot(cwd, rexp)
            title(sprintf('%s Tone Injection (%gkHz, %gmV_{RMS})', BOARDSN, f, v*1e3))
            xlabel('Frequency (kHz)')
            ylabel('Magnitude (dB re 1Vrms)')
            figname = sprintf('%s_ToneFFT_%skHz_%sV.fig', BOARDSN, strrep(num2str(f),'.','p'),strrep(num2str(v),'.','p'));
            saveas(gcf, figname, 'fig');
        end
    end
end

if PLOTIMD
    % plot each IMD specified
    for v=vRangeIMD
        for f=fRangeIMD
            rexp = sprintf('^IMD\\ %s\\ V\\ %d\\ kHz.*CH002.mat$', strrep(num2str(v),'.','p'), f);
            disp(sprintf('>> groupplot(''%s'',''%s'')',cwd,rexp))
            groupplot(cwd, rexp)
            title(sprintf('%s Dual Tone Injection (%gkHz, %gmV_{RMS})', BOARDSN, f, v*1e3))
            xlabel('Frequency (kHz)')
            ylabel('Magnitude (dB re 1Vrms)')
            figname = sprintf('%s_ToneIMD_%skHz_%sV.fig', BOARDSN, strrep(num2str(f),'.','p'),strrep(num2str(v),'.','p'));
            saveas(gcf, figname, 'fig');
        end
    end
end

if PLOTTF
    % plot TF magnitude
    rexp = '^TransferFn_CH001.mat$';
    disp(sprintf('>> groupplot(''%s'',''%s'',true,''log'')',cwd,rexp))
    groupplot(cwd,rexp,1,'log')
    title(sprintf('%s Transfer Function', BOARDSN))
    xlabel('Frequency (kHz)')
    ylabel('Magnitude (dB re 1Vrms)')
    figname = sprintf('%s_TransferFn_Mag', BOARDSN);
    saveas(gcf, figname, 'fig');

    % plot TF phase
    rexp = '^TransferFn_CH002.mat$';
    disp(sprintf('>> groupplot(''%s'',''%s'',true,''log'')',cwd,rexp))
    groupplot(cwd,rexp,1,'log')
    title(sprintf('%s Transfer Function', BOARDSN))
    xlabel('Frequency (kHz)')
    ylabel('Phase (degrees)')
    figname = sprintf('%s_TransferFn_Phs', BOARDSN);
    saveas(gcf, figname, 'fig');

end

if PLOTNF
    % plot noise floor
    rexp = '^WGN\ Input\ 0\ V_CH002.mat$';
    disp(sprintf('>> groupplot(''%s'',''%s'')',cwd,rexp))
    groupplot(cwd, rexp)
    title(sprintf('%s Noise Floor',BOARDSN))
    xlabel('Frequency (kHz)')
    ylabel('Magnitude (dB re 1Vrms)')
    figname = sprintf('%s_NoiseFloor', BOARDSN);
    saveas(gcf, figname, 'fig');

end
