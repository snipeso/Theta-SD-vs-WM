function EEG_filt = lineFilter(EEG, linefs, showFiltPlots)
% removes line noise, and harmonics

EEG_filt = EEG;
fs = EEG.srate; % Sampling Frequency (Hz)

Harmonics = linefs:linefs:(round(fs/2)-4);
fcuts = [Harmonics - 4; Harmonics - 2; Harmonics + 2; Harmonics + 4];
fcuts = fcuts(:);

%%% create filter weights
mags = [repmat([1, 0], 1, numel(Harmonics)), 1];  % Passbands & Stopbands
devs = [repmat([0.05, 0.01], 1, numel(Harmonics)), .05]; % Tolerances

[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs); % Kaiser Window FIR Specification
n = n + rem(n,2);
hh = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale'); % Filter realisation

%%% filter the data
EEG_filt.data = filtfilt(hh, 1, double(EEG.data)')';

%%% plot filter if requested
if exist('showFiltPlots', 'var') && showFiltPlots
    
    % plot filter
    figure
    freqz(hh,1,2^14,fs)
    set(subplot(2,1,1), 'XLim',[0 200]); % Zoom Frequency Axis
    set(subplot(2,1,2), 'XLim',[0 200]);
    
    % plot power spectrum of a filtered channel
    x = EEG.data(1, :);
    [pxx,f] = pwelch(x,length(x),[],length(x),fs);
    figure
    plot(f, log(pxx))
    hold on
     x = EEG_filt.data(1, :);
    [pxx,f] = pwelch(x,length(x),[],length(x),fs);
     plot(f, log(pxx))
    
    % plot filtered and unfiltered data for comparison
    figure
    hold on
    t = linspace(0, length(x)/fs, length(x));
    plot(t, EEG.data(1, :))
    plot(t, x)
    legend({'unfilt', 'filt'})
    
end

