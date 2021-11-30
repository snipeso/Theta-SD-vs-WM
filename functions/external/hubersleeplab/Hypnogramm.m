% This script draws the hypnogramm based on a .vis file. It also draws the
% power in SWA, theta, alpha and sigma in time.
%
% Polished script, Sven Leach, 12.02.2020

clear all; 
close all;
clc;

% set variables
srate   = 128;      % sampling rate of sleep scoring files
chsel   = 4;        % f3a2


% get files
% -------------------------------------------------------------------------

% Select .vis 
[filevis, pathvis] = uigetfile('*.vis', 'Select a file', 'Select a .vis file', 'MultiSelect', 'off');

% Select .r09 file
[filer09, pathr09] = uigetfile('*.r09', 'Select a file', 'Select a .r09 file', 'MultiSelect', 'off');



% plot hypnogram
% -------------------------------------------------------------------------

% read .vis file
[vistrack, vissymb, offs] = visfun.readtrac(fullfile(pathvis, filevis), 1);
[visnum]                  = visfun.numvis(vissymb, offs);
[visplot]                 = visfun.plotvis(visnum, 10);

% variables and functions for plotting
hex2rgb  = @(hex) (sscanf(hex(1:end),'%2x%2x%2x',[1 3])/255); % hex2rgb (color)
t        = 0:1/180:(length(visnum)/180)-1/180;                % time vector

% color REM and WAKE in another color
rem               = visnum;  % REM sleep
rem(rem~=0)       = -3.5;    % So that only REM sleep is colored differently
wake              = visnum;  % WAKE
wake(wake~=1)     = -3.5;    % So that only wake is colored differently
wake(wake==1)     = -3.3;    % Wake bouts are just small bumps
visnum(visnum==1) = -3.5;    % Don't plot wake

% % plot hypnogram as lineplot (basic)
% figure; set(gcf, 'color','w', 'units','normalized', 'outerposition',[0 0 1 1])
% plot(visplot(:,1), visplot(:,2), 'k')
% xlabel('time [h]'); yticks(-2.5:1:1.5); yticklabels({'N3', 'N2', 'N1', 'REM', 'wake'}); ylim([-3, 2]); set(gca, 'FontSize', 20);

% % plot a nice hypnogram all in black
% figure; set(gcf, 'color','w', 'units','normalized', 'outerposition',[0 0 1 1]); hold on;
% area(t(1:end-1), visnum(1:end-1), 'basevalue', -4, 'FaceColor', hex2rgb('292826'));
% xlabel('time [h]'); title('hypnogram'); yticks(-3:1:1); yticklabels({'N3', 'N2', 'N1', 'REM', 'wake'}); ylim([-3.5, 1]); xlim([0, t(end)]); set(gca, 'FontSize', 20);

% plot a nice hypnogram in colors
figure; set(gcf, 'color','w', 'units','normalized', 'outerposition',[0 0 1 1]); hold on;
area(t(1:end-1), visnum(1:end-1), 'basevalue', -4, 'FaceColor', hex2rgb('161b21'), 'Edgecolor', hex2rgb('161b21'));
area(t(1:end-1), rem(1:end-1), 'basevalue', -4, 'FaceColor', hex2rgb('FCC834'), 'Edgecolor', hex2rgb('FCC834'));
area(t(1:end-1), wake(1:end-1), 'basevalue', -4, 'FaceColor', hex2rgb('509af4'), 'Edgecolor', hex2rgb('509af4'));
xlabel('time [h]'); title('hypnogram'); yticks(-3:1:1); yticklabels({'N3', 'N2', 'N1', 'REM', 'wake'}); ylim([-3.5, 0]); xlim([0, t(end)]); set(gca, 'FontSize', 20);
legend({'NREM', 'REM', 'wake'}, 'Location', 'eastoutside')


% plot hypnogram + power
% -------------------------------------------------------------------------

% load .r09
fid = fopen(fullfile(pathr09, filer09), 'r');
r09 = fread(fid, 'short');
fclose(fid);

% set variables
numchans  = str2num(filer09(end-1:end));                  % number of channels in sleep scoring file
r09       = reshape(r09, numchans, length(r09)/numchans); % channels x samples
pnts      = size(r09, 2);                                 % sample points
numepo20s = floor(pnts/srate/20);                         % number of 20s epochsnumepo20s
FFTtot    = double(NaN(numchans, 161, numepo20s));        % stores final power values
FFTepoch  = double([]);                                   % stores power values per 20s epoch 

% power computation
for epo = 1:numepo20s
 
    % sample points in each 20s window
    from              = (epo-1)*20*srate+1;
    to                = (epo-1)*20*srate+20*srate;

    % pwelch
    [FFTepoch, freq] = pwelch(r09(:, from:to)', hanning(4*srate), 0, 4*srate, srate);
    FFTepoch         = FFTepoch'; % to get channel x frequency
    
    % frequencies of interest
    freq40 = freq <= 40; 
    
    % concatenate 20s epochs
    FFTtot(:, :, epo) = FFTepoch(:, freq40); % in channel x frequency x epoch
end  
clear FFTepoch % big and not used anymore

% artefact index
try
    badepo = find(sum(artndxn) == 0);
catch
    badepo = find(sum(vistrack')>0);
end

% frequencies of interest
freq4  = find(freq >= 0.5  & freq <= 4.0);
freq8  = find(freq >= 4.25 & freq <= 7.75);
freq10 = find(freq >= 8.0  & freq <= 11.75);
freq14 = find(freq >= 12.0 & freq <= 16.0);
freq30 = find(freq >= 20.0 & freq <= 40.0);
freq1  = find(freq >= 0    & freq <= 0.75);

% time courses
swa = mean(squeeze(FFTtot(chsel, freq4,  :))); swa(badepo)=NaN;
the = mean(squeeze(FFTtot(chsel, freq8,  :))); the(badepo)=NaN;
alp = mean(squeeze(FFTtot(chsel, freq10, :))); alp(badepo)=NaN;
sig = mean(squeeze(FFTtot(chsel, freq14, :))); sig(badepo)=NaN;
emg = log(sum(squeeze(FFTtot(1,  freq30, :))));
eog = log(sum(squeeze(FFTtot(2,  freq1,  :))));

% plot
t=0:1/180:(numepo20s/180)-1/180;

% sleep parameters (displayed in the title)
wake  = sum([vissymb=='0']) / numepo20s * 100;                                          % time spend awake (in %)
s1    = sum([vissymb=='1']) / numepo20s * 100;                                          % time spend in N1 (in %)
nrem  = sum([vissymb=='2', vissymb=='3', vissymb=='4']) / numepo20s * 100;              % time spend in NREM (in %)
rem   = sum([vissymb=='r']) / numepo20s * 100;                                          % time spend in REM (in %)
sl    = find(vissymb=='2' | vissymb=='3' | vissymb=='4' | vissymb=='r'); sl=sl(1)/3;    % sleep latency
sleep = find(vissymb=='1' | vissymb=='2' |vissymb=='3' | vissymb=='4' | vissymb=='r')'; % 20s epochs corresponding to sleep
tots  = length(sleep)/3;                                                                % total sleep time (min)

% whatever this is for???
indexNotScor = find(vissymb == ' ');
indexScored  = setdiff([1:numepo20s], indexNotScor);
totScored    = length(indexScored)/3;
seff         = (100/totScored)*tots;

% plot hypnogram and power of different frequency bands
figure('Color', 'w','PaperOrientation','landscape','PaperUnits','centimeters','PaperPosition',[1 1 26 20])
subplot(711)
    plot(visplot(:,1), visplot(:,2))
    grid
    title([filevis,'                ','SL(min) = ',num2str(sl,'%2.1f'),'  SEF(%) = ',num2str(seff,'%2.1f'),'     W% = ',num2str(wake,'%2.1f'),'     S1% = ',num2str(s1,'%2.1f'),'     NREM% = ',num2str(nrem,'%2.1f'),'     REM% = ',num2str(rem,'%2.1f'), '       TST = ',num2str(tots, '%2.1f'), '                   ',date])
    xlim([0 t(numepo20s)])
    ylabel('Hypnogram')
    ylim([-3 2])
subplot(712)
    bar(t,swa,'EdgeColor','k') 
    grid
    ylabel('SWA')
    xlim([0 t(numepo20s)])
    ylim([0 max(swa(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
subplot(713)
    bar(t,the) 
    grid
    ylabel('Theta')
    xlim([0 t(numepo20s)])
    ylim([0 max(the(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
subplot(714)
    bar(t,alp)
    grid
    ylabel('Alpha')
    xlim([0 t(numepo20s)])
    ylim([0 max(alp(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
subplot(715)
    bar(t,sig)
    grid
    ylabel('Sigma')
    xlim([0 t(numepo20s)])
    ylim([0 max(sig(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
subplot(716)
    plot(t,emg,'r')
    grid
    ylabel('log EMG')
    xlim([0 t(numepo20s)])
subplot(717)
    plot(t,eog)
    grid
    ylabel('log EOG')
    xlabel('hours')
    xlim([0 t(numepo20s)])










% 
% 
% 
% %plots Hypnogram, SWA time course,...
% %rh, 6.8.2008
% 
% clear all; close all;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visname='BMS_b_x.vis';
% % vispath='O:\Huber\Scoring\check scored MR\';
% vispath='D:\Zurich_Scoring\BMS\BMS_005';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% %%%%read vis file
% offset=0;
% track=1;
% VisName=[vispath,visname,'.vis'];
% [vistrack,vissymb,offset]=readtrac(VisName,track);
% VisNum=numvis(vissymb,offset);
% numepo=length(VisNum);
% 
% 
% %%%%calculates sleep parameters
% wak=length(find(vissymb=='0'))/numepo*100;
% sl=find(vissymb=='2' | vissymb=='3' | vissymb=='4' | vissymb=='r'); sl=sl(1)/3;
% s1=length(find(vissymb=='1'))/numepo*100;
% nr=length(find(vissymb=='2' | vissymb=='3' | vissymb=='4'))/numepo*100;
% rem=length(find(vissymb=='r'))/numepo*100;
% 
% indexsleep1=find(vissymb=='1' | vissymb=='2' |vissymb=='3' | vissymb=='4' | vissymb=='r')';
% tots=length(indexsleep1)/3;
% 
% indexNotScor=find(vissymb== ' ');
% indexScored=setdiff([1:length(vissymb)],indexNotScor);
% totScored=length(indexScored)/3;
% seff=(100/totScored)*tots;
% 
% 
% 
% %%%%read data file
% R09Name=[vispath,visname,'.r09']
% fs=128;
% numchan=str2num(R09Name(length(R09Name)));
% 
% fid = fopen(R09Name,'r');
% scordat=fread(fid,'short');
% fclose(fid);
% 
% scordat=reshape(scordat,numchan,length(scordat)/numchan);
% 
% %%%%fft
% ffttot=[];
% fftblock=zeros(numchan,120,numepo);
% fprintf('fft channel  ')
% for ch=1:numchan
% fprintf('...%d',ch)
%     for epoch=1:numepo
%         start=1+((epoch-1)*20*fs);
%         ending=20*fs+((epoch-1)*20*fs);
%         ffte=pwelch(scordat(ch,start:ending),hanning(4*fs),0,4*fs,fs);
%         ffte=ffte(1:120);
%         fftblock(ch,:,epoch)=ffte;
%     end
% end
% ffttot=[ffttot fftblock];
% fprintf('\n');
% 
% 
% %%%%artefact index
% artndx=find(sum(vistrack')>0);
% 
% %%%%time courses
% ch=4; %%%%f3a2
% swa=mean(squeeze(ffttot(ch,4:18,:))); swa(artndx)=NaN;
% the=mean(squeeze(ffttot(ch,20:32,:))); the(artndx)=NaN;
% alp=mean(squeeze(ffttot(ch,36:44,:))); alp(artndx)=NaN;
% sig=mean(squeeze(ffttot(ch,48:60,:))); sig(artndx)=NaN;
% 
% emg=log(sum(squeeze(ffttot(1,80:120,:))));
% eog=log(sum(squeeze(ffttot(2,1:4,:))));
% 
% %%%%figure
% density=10;
% [Vis]=plotvis(visnum,density);
% 
% t=0:1/180:(length(visnum)/180)-1/180;
% 
% figure('Color',[1 1 1],'PaperOrientation','landscape','PaperUnits','centimeters','PaperPosition',[1 1 26 20])
% subplot(711)
%     plot(Vis(:,1),Vis(:,2))
%     grid
%     title([visname,'                ','SL(min) = ',num2str(sl,'%2.1f'),'  SEF(%) = ',num2str(seff,'%2.1f'),'     W% = ',num2str(wak,'%2.1f'),'     S1% = ',num2str(s1,'%2.1f'),'     NREM% = ',num2str(nr,'%2.1f'),'     REM% = ',num2str(rem,'%2.1f'),'                   ',date])
%     xaxis([0 t(numepo)])
%     ylabel('Hypnogram')
%     yaxis([-3 2])
% subplot(712)
%     bar(t,swa,'EdgeColor','k')  %,'EdgeColor','none'
%     grid
%     ylabel('SWA')
%     xaxis([0 t(numepo)])
%     yaxis([0 max(swa(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
% %     yaxis([0 1000])
% subplot(713)
%     bar(t,the) 
%     grid
%     ylabel('Theta activity')
%     xaxis([0 t(numepo)])
%     yaxis([0 max(the(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
% subplot(714)
%     bar(t,alp)
%     grid
%     ylabel('Alpha activity')
%     xaxis([0 t(numepo)])
%     yaxis([0 max(alp(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
% subplot(715)
%     bar(t,sig)
%     grid
%     ylabel('Sigma activity')
%     xaxis([0 t(numepo)])
%     yaxis([0 max(sig(find(vissymb=='2' | vissymb=='3' | vissymb=='4')))])
% subplot(716)
%     plot(t,emg,'r')
%     grid
%     ylabel('log EMG')
%     xaxis([0 t(numepo)])
% subplot(717)
%     plot(t,eog)
%     grid
%     ylabel('log EOG')
%     xlabel('hours')
%     xaxis([0 t(numepo)])
