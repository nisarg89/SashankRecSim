%% Plots results

confidence_level = 95;
resultsDir = '.';
load([resultsDir '\all_results']);
linespeclist = {'-*b','-or','-sr','-xk','-^c'};

if ~exist('plots', 'dir')
    mkdir('plots');
end

% ourmech = '$\textsc{Legit}^+$';
% rw = '$\textsc{RandomWalk}$';
% ourmech_rec = '$\textsc{Legit}^+_{\mathrm{Rec}}$';
% rw_rec = '$\textsc{RandomWalk}_{\mathrm{Rec}}$';
ourmech = '$\ourmech$';
rw = '$\rw$';
% ourmech_rec = 'LegitRec';
% rw_rec = 'RWRec';

% Running Time
runtime_avg = squeeze(mean(reshape(timeStats(:,:,:,:,[1 2]),numDatasets,[],2),2))';
[ratio_runtime_m,ratio_runtime_lo,ratio_runtime_hi] = calculate_bounds(reshape(timeStats(:,:,:,:,2)./timeStats(:,:,:,:,1),numDatasets,[]),2,confidence_level);
ratio_total_runtime = sum(reshape(timeStats(:,:,:,:,2),1,[]))/sum(reshape(timeStats(:,:,:,:,1),1,[]));

runtime_fb = squeeze(mean(reshape(timeStats(13,:,:,:,[1 2]),npVote,[],2),2))';
[ratio_runtime_fb_m,ratio_runtime_fb_lo,ratio_runtime_fb_hi] = calculate_bounds(reshape(timeStats(13,:,:,:,2)./timeStats(13,:,:,:,1),npVote,[]),2,confidence_level);

X = nList;
Y = runtime_avg; Ylo = []; Yhi = [];
hasErrorBar = false; baseline = false; baselineval = [];
locLegend = 'NorthWest'; legendList = {ourmech,rw};
XLabel = 'Dataset Size'; XRange = []; XTicks = []; XTickLabels = [];
YLabel = 'Running Time (s)'; YRange = []; YTicks = []; YTickLabels = [];
filename = 'plots\runtime-avg.tex';
logX = true; logY = true;
genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

% Discarded Nodes
perc_disc_avg = zeros(2,numDatasets);
perc_disc_avg(1,:) = mean(reshape((nodeStats(:,:,:,:,3,1)-nodeStats(:,:,:,:,1,1))./nodeStats(:,:,:,:,3,1)*100,numDatasets,[]),2);
perc_disc_avg(2,:) = mean(reshape((nodeStats(:,:,:,:,3,1)-nodeStats(:,:,:,:,2,1))./nodeStats(:,:,:,:,3,1)*100,numDatasets,[]),2);
diff_perc_disc = mean(perc_disc_avg(2,:))-mean(perc_disc_avg(1,:));

X = nList;
Y = perc_disc_avg(2,:)-perc_disc_avg(1,:); Ylo = []; Yhi = [];
hasErrorBar = false; baseline = true; baselineval = 0;
locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
XLabel = 'Dataset Size'; XRange = []; XTicks = []; XTickLabels = [];
YLabel = {'Difference in', '\% Voters Discarded'}; YRange = [-10,30]; YTicks = 0:10:50; YTickLabels = [];
filename = 'plots\disc-avg.tex'; 
logX = true; logY = false;
genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

perc_disc_fb = zeros(2,npVote);
perc_disc_fb(1,:) = mean(reshape((nodeStats(13,:,:,:,3,1)-nodeStats(13,:,:,:,1,1))./nodeStats(13,:,:,:,3,1)*100,npVote,[]),2);
perc_disc_fb(2,:) = mean(reshape((nodeStats(13,:,:,:,3,1)-nodeStats(13,:,:,:,2,1))./nodeStats(13,:,:,:,3,1)*100,npVote,[]),2);
diff_perc_disc_fb = mean(perc_disc_fb(2,:))-mean(perc_disc_fb(1,:));

% L2Norm
better_norm = mean(reshape((nodeStats(:,:,:,:,1,2)<nodeStats(:,:,:,:,2,2))+0.5*(nodeStats(:,:,:,:,1,2)==nodeStats(:,:,:,:,2,2)),numDatasets,[]),2)*100';
better_norm_fb = mean(reshape((nodeStats(13,:,:,:,1,2)<nodeStats(13,:,:,:,2,2))+0.5*(nodeStats(13,:,:,:,1,2)==nodeStats(13,:,:,:,2,2)),npVote,[]),2)*100';

X = nList;
Y = better_norm; Ylo = []; Yhi = [];
hasErrorBar = false; baseline = true; baselineval = 50;
locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
XLabel = 'Dataset Size'; XRange = []; XTicks = []; XTickLabels = [];
YLabel = '\% Simulations'; YRange = [50-50/3,100]; YTicks = [50,75,100]; YTickLabels = [];
filename = 'plots\l2-avg.tex'; 
logX = true; logY = false;
genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

% LeximinBetter

better_lex = mean(reshape(nodeStats(:,:,:,:,1,3),numDatasets,[]),2)*100';
better_lex_fb = mean(reshape(nodeStats(13,:,:,:,1,3),npVote,[]),2)*100';

X = nList;
Y = better_lex; Ylo = []; Yhi = [];
hasErrorBar = false; baseline = true; baselineval = 50;
locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
XLabel = 'Dataset Size'; XRange = []; XTicks = []; XTickLabels = [];
YLabel = '\% Simulations'; YRange = [50-50/3,100]; YTicks = [50,75,100]; YTickLabels = [];
filename = 'plots\lex-avg.tex'; 
logX = true; logY = false;
genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

% Accuracy

better_acc = mean(reshape((accStats(:,:,:,:,:,1)>accStats(:,:,:,:,:,2))+0.5*(accStats(:,:,:,:,:,1)==accStats(:,:,:,:,:,2)),numDatasets,[]),2)*100';
better_acc_fb = mean(reshape((accStats(13,:,:,:,:,1)>accStats(13,:,:,:,:,2))+0.5*(accStats(13,:,:,:,:,1)==accStats(13,:,:,:,:,2)),npVote,[]),2)*100';
actual_acc = squeeze(mean(reshape(accStats(13,:,1,:,:,:),npVote,[],numMech),2));

X = nList;
Y = better_acc; Ylo = []; Yhi = [];
hasErrorBar = false; baseline = true; baselineval = 50;
locLegend = 'SouthEast'; legendList = {[ourmech '>' rw]};
XLabel = 'Dataset Size'; XRange = []; XTicks = []; XTickLabels = [];
YLabel = '\% Simulations'; YRange = [50-50/3,100]; YTicks = [50,75,100]; YTickLabels = [];
filename = 'plots\acc-avg.tex'; 
logX = true; logY = false;
genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespeclist,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename);

copyfile('.\plots\*.tex','E:\Dropbox\Research\FNP Recommendation on Social Network\tex\images\');
