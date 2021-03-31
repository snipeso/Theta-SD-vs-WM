function EEG_filt = hpEEG(EEG, high_pass, hp_stopband)
% special filter for high-pas filtering; done to have more control over
% which frequencies really get removed.

fs = EEG.srate;
StopAtten = 60;
PassRipple = 0.05;

hpFilter = designfilt('highpassfir', 'PassbandFrequency', high_pass, ...
    'StopbandFrequency', hp_stopband, 'StopbandAttenuation', StopAtten, ...
    'PassbandRipple', PassRipple, 'SampleRate', fs, 'DesignMethod', 'kaiser');

EEG_filt = firfilt(EEG, hpFilter.Coefficients);

