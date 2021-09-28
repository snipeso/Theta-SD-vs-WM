%%% run this after M2S topographies

Pres = nan(nParticipants, nSessions, 3, 4);


for Indx_P = 1:nParticipants
    for Indx_S = 1:nSessions
        Data = squeeze(AllTrials.level(Indx_P, Indx_S, :));
        for Indx_L = 1:3
            L = Levels(Indx_L);
            Indx = find(Data == L)-1;
            if any(Indx == 0)
                Indx(Indx==0) = [];
                Pres(Indx_P, Indx_S, Indx_L, end) = 1;
            end
            P = Data(Indx);
            T = tabulate(P);
            Pres(Indx_P, Indx_S, Indx_L, 1:3) = T([1 3 6], 2);
        end
    end
end

A = squeeze(nanmean(Pres(:, 3, :, :), 1));

%%
  figure('units','normalized','outerposition',[0 0 .5 .5])
for Indx_S = 1:3
    subplot(1, 3, Indx_S)
   
    A = squeeze(nansum(Pres(:, Indx_S, :, :), 1));
    imagesc(A(:, 1:3))
     title([Sessions.Labels{Indx_S}])
    colorbar
    colormap(Format.Colormap.Linear)
    ylabel('Prior to trial type...')
    xlabel('...n of trial type')
    axis square
    xticks(1:3)
    yticks(1:3)
    xticklabels([1 3 6])
    yticklabels([1 3 6])
%     set('gca', 'FontName', Format.FontName, 'FontSize', Format.FontSize)
   set(gca, 'FontName', Format.FontName, 'FontSize', 18)
end
setLims(1, 3, 'c')



%% post-trial check

for Indx_S = 1:3
     Data = squeeze(bData(:, Indx_S, :, end, :, 4));
                
N13 =  averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) ~= 6);
N6 =  averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == 6);
figure
plotTopoDiff(N13, N6, Chanlocs, CLims_Diff, StatsP, Format);
end
