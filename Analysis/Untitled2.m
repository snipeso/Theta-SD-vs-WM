
figure('units','centimeters','position',[0 4 Pixels.W Pixels.H])

% all tasks

figure
plotExcelTable(tValues(:, Keep)', Sig(:, Keep)', Areas(Keep), ...
    Labels,  't values', Pixels)

plotSpaghettiOs



%%

Maps = struct();
for Indx_C = 1:9
    Map = interpolateSources(stat_all.(['contrast', num2str(Indx_C)]));
        
    Maps(Indx_C).left = Map.left;
    Maps(Indx_C).right = Map.right;
end

save('C:\Users\colas\Downloads\stat_addcontrasts.mat', 'stat_all', 'Maps')


for Indx_C = 1:9
    Map = Maps(Indx_C);
   save(['C:\Users\colas\Downloads\stat_addcontrasts', num2str(Indx_C), '.mat'], 'Map') 
    
end


%%

CLims = [-7 7];

for Indx_C = 1:9
    figure
    subplot(2, 2, 1)
    plotBalloonBrain(Maps(Indx_C), 'left-outside', CLims, false, P.Format)
    title(cond1{Indx_C})
    
        subplot(2, 2, 2)
    plotBalloonBrain(Maps(Indx_C), 'right-outside', CLims, false, P.Format)
    title(cond2{Indx_C})
    
    
        subplot(2, 2, 3)
    plotBalloonBrain(Maps(Indx_C), 'left-inside', CLims, false, P.Format)
    
        subplot(2, 2, 4)
    plotBalloonBrain(Maps(Indx_C), 'right-inside', CLims, false, P.Format)
end