function plotBar(x,barPos,barColor)

mx = nanmean(x);
stdx = nanstd(x);
sex = stdx / sqrt(sum(~isnan(x)));

barL = 0.3;
bar(barPos,mx,barColor);
plot([barPos barPos],mx+sex*[-1 1],'k','linewidth',2)
plot(barPos+[barL -barL],mx+sex*[1 1],'k','linewidth',2)
plot(barPos+[barL -barL],mx-sex*[1 1],'k','linewidth',2)