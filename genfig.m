function [] = genfig(X,Y,hasErrorBar,Ylo,Yhi,baseline,baselineval,linespecs,locLegend,legendList,XLabel,XRange,XTicks,XTickLabels,YLabel,YRange,YTicks,YTickLabels,logX,logY,filename)

set(0,'defaulttextinterpreter','latex');
MYFONTSIZE = 25;
set(0,'DefaultAxesFontSize',MYFONTSIZE);
set(0,'DefaultTextFontSize',MYFONTSIZE);
set(0,'DefaultLineMarkerSize',6);

fig = figure('NumberTitle','off','visible','off');
xmin = Inf;
xmax = -Inf;
hold('on');
assert(iscell(linespecs));
if min(size(Y,1),size(Y,2))==1
    if hasErrorBar
        errorbar(X,Y,Y-Ylo,Yhi-Y,linespecs{1});
        xmin = min(xmin,min(X));
        xmax = max(xmax,max(X));
    else
        plot(X,Y,linespecs{1});
        xmin = min(xmin,min(X));
        xmax = max(xmax,max(X));
    end
else
    if hasErrorBar
        for i = 1:size(Y,1)
            errorbar(X,Y(i,:),Y(i,:)-Ylo(i,:),Yhi(i,:)-Y(i,:),linespecs{i});
            xmin = min(xmin,min(X));
            xmax = max(xmax,max(X));
        end
    else
        for i = 1:size(Y,1)
            plot(X,Y(i,:),linespecs{i});
            xmin = min(xmin,min(X));
            xmax = max(xmax,max(X));
        end
    end
end
if baseline
    plot([xmin,xmax],[baselineval baselineval],'-k');
    legendList{end+1} = 'Baseline';
end
legend(legendList,'Location',locLegend);
ax = gca;
xlabel(XLabel);
ylabel(YLabel);
if ~isempty(XRange)
    xlim(XRange);
else
    xlim([xmin,xmax]);
end
if ~isempty(YRange)
    ylim(YRange);
end
if ~isempty(XTicks)
    ax.XTick = XTicks;
end
if ~isempty(XTickLabels)
    if isnumeric(XTickLabels)
        XTickLabels = cellstr(num2str(reshape(XTickLabels,length(XTickLabels),1)));
    end
    ax.XTickLabel = XTickLabels;
%    xticklabel_rotate([],45);
end
if ~isempty(YTicks)
    ax.YTick = YTicks;
end
if ~isempty(YTickLabels)
    if isnumeric(YTickLabels)
        YTickLabels = cellstr(num2str(reshape(YTickLabels,length(YTickLabels),1)));
    end
    ax.YTickLabel = YTickLabels;
end
if logX
    set(ax,'XScale','log');
end
if logY
    set(ax,'YScale','log');
end
hold('off');
cleanfigure;
if ~isempty(filename) && isequal(filename(end-2:end),'tex')
    matlab2tikz(filename,'figurehandle',fig,'showInfo',false,'parseStrings',false,'width','\figurewidth','height','\figureheight','extraAxisOptions','ylabel shift={-3pt}');
elseif ~isempty(filename) && isequal(filename(end-2:end),'eps')
    print(fig,'-depsc2',filename);
end

end