%% Plots results

confidence_level = 95;
resultsDir = '.';
load([resultsDir '\all_results']);
linespeclist = {'-*b','-or','-sk','-xk','-^c'};

if ~exist('plots', 'dir')
    mkdir('plots');
end

ourmech = '$\ourmech$';
rw = '$\rw$';
XTicks = [1 4 7 10];

for datasetID = [13 14]

    % Running Time
    runtime_fb = squeeze(mean(reshape(timeStats(datasetID,:,:,:,[1 2]),npVote,[],2),2))';
    [ratio_runtime_fb_m,ratio_runtime_fb_lo,ratio_runtime_fb_hi] = calculate_bounds(reshape(timeStats(datasetID,:,:,:,2)./timeStats(datasetID,:,:,:,1),npVote,[]),2,confidence_level);

    X = 1:npVote; 
    Y = runtime_fb; Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = false; baselineval = [];
    locLegend = 'NorthWest'; legendList = {ourmech,rw};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = 'Running Time (s)'; YRange = []; YTicks = []; YTickLabels = [];
    filename = ['plots\runtime-' num2str(datasetID) '.tex'];
    logX = false; logY = true;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

    % Discarded Nodes
    perc_disc_fb = zeros(2,npVote);
    perc_disc_fb(1,:) = mean(reshape((nodeStats(datasetID,:,:,:,3,1)-nodeStats(datasetID,:,:,:,1,1))./nodeStats(datasetID,:,:,:,3,1)*100,npVote,[]),2);
    perc_disc_fb(2,:) = mean(reshape((nodeStats(datasetID,:,:,:,3,1)-nodeStats(datasetID,:,:,:,2,1))./nodeStats(datasetID,:,:,:,3,1)*100,npVote,[]),2);
    diff_perc_disc_fb = mean(perc_disc_fb(2,:))-mean(perc_disc_fb(1,:));

    X = 1:npVote; 
    Y = perc_disc_fb(2,:)-perc_disc_fb(1,:); Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = true; baselineval = 0;
    locLegend = 'SouthEast'; legendList = {ourmech,rw};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = {'Difference in', '\% Voters Discarded'}; YRange = [-10,70]; YTicks = 0:20:60; YTickLabels = [];
    filename = ['plots\disc-' num2str(datasetID) '.tex'];
    logX = false; logY = false;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

    % L2Norm
    better_norm_fb = mean(reshape((nodeStats(datasetID,:,:,:,1,2)<nodeStats(datasetID,:,:,:,2,2))+0.5*(nodeStats(datasetID,:,:,:,1,2)==nodeStats(datasetID,:,:,:,2,2)),npVote,[]),2)*100';
    actual_norm_fb = squeeze(mean(reshape(nodeStats(datasetID,:,:,:,[1 2],2),npVote,[],2),2))';

    X = 1:npVote; 
    Y = better_norm_fb; Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = true; baselineval = 50;
    locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = '\% Simulations'; YRange = [50-50/7,100]; YTicks = [50,75,100]; YTickLabels = [];
    filename = ['plots\l2-' num2str(datasetID) '.tex'];
    logX = false; logY = false;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

    X = 1:npVote; 
    Y = actual_norm_fb; Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = false; baselineval = [];
    locLegend = 'NorthEast'; legendList = {ourmech,rw};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = 'Variance'; YRange = []; YTicks = []; YTickLabels = [];
    filename = ['plots\actual-l2-' num2str(datasetID) '.tex'];
    logX = false; logY = false;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

    % LeximinBetter

    better_lex_fb = mean(reshape(nodeStats(datasetID,:,:,:,1,3),npVote,[]),2)*100';

    X = 1:npVote; 
    Y = better_lex_fb; Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = true; baselineval = 50;
    locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = '\% Simulations'; YRange = [50-50/7,100]; YTicks = [50,75,100]; YTickLabels = [];
    filename = ['plots\lex-' num2str(datasetID) '.tex'];
    logX = false; logY = false;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

    % Accuracy

    better_acc_fb = mean(reshape((accStats(datasetID,:,:,:,:,1)>accStats(datasetID,:,:,:,:,2))+0.5*(accStats(datasetID,:,:,:,:,1)==accStats(datasetID,:,:,:,:,2)),npVote,[]),2)*100';
    actual_acc_fb = squeeze(mean(reshape(accStats(datasetID,:,1,:,:,:),npVote,[],numMech),2))';

    X = 1:npVote; 
    Y = better_acc_fb; Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = true; baselineval = 50;
    locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = '\% Simulations'; YRange = [50-50/7,100]; YTicks = [50,75,100]; YTickLabels = [];
    filename = ['plots\acc-' num2str(datasetID) '.tex'];
    logX = false; logY = false;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

    X = 1:npVote; 
    Y = actual_acc_fb; Ylo = []; Yhi = [];
    hasErrorBar = false; baseline = true; baselineval = 50;
    locLegend = 'SouthEast'; legendList = {ourmech,rw,'Uniform'};
    XLabel = '$p_{\text{vote}}$'; XRange = [0,npVote]; XTickLabels = p_vote_list(XTicks);
    YLabel = 'Accuracy'; YRange = [0,1]; YTicks = []; YTickLabels = [];
    filename = ['plots\actual-acc-' num2str(datasetID) '.tex'];
    logX = false; logY = false;
    genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

end

copyfile('.\plots\*.tex','E:\Dropbox\Research\FNP Recommendation on Social Network\tex\images\');
%copyfile('.\plots\*.tex','C:\Users\Nisarg\Desktop\tex\images\');