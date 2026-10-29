
clear; clc;

dimensionID = 1;
resp = 'Both'; % 'Both' 'Fearful' 'Happy'

analysisCode = 'Number'; % Number TotalFixDuration FirstLatency MeanFixDuration

vSubCat = {'ASD','ASD_Ctrl'}; % categories of subjects for analysis
% ASD vs. ASD_Ctrl: described in Wang and Adolphs (Neuropsychologia 2017)
% Big vs. Small: described in Wang (Scientific Reports 2018)

nCat = length(vSubCat);

%% plot options

PLOT.BarStimulusAll = 1;
PLOT.BarStimulusLevels = 1;
PLOT.BarAmbiguityLevels = 1;

%% load data

load('ET_Data_All');

%% compute fixation property in each ROI

for iSess = 1:length(EM)
    vTrialType = EM{iSess}(:,7);
    vFixOrder = EM{iSess}(:,2);
    vTrial = EM{iSess}(:,end);
    vROIOrder = EM{iSess}(:,9);
    
    codeL = beh(iSess).codeL;
    vResp = beh(iSess).vResp;
    
    for iLevel = 1:nLevel+1
        if iLevel == nLevel+1
            switch resp
                case 'Both'
                    ind = 1:length(codeL);
                case 'Fearful'
                    ind = find(vResp==1);
                case 'Happy'
                    ind = find(vResp==2);
            end
        else
            switch resp
                case 'Both'
                    ind = find(codeL==iLevel);
                case 'Fearful'
                    ind = find(codeL==iLevel & vResp==1);
                case 'Happy'
                    ind = find(codeL==iLevel & vResp==2);
            end
        end
        
        X = []; Y = []; Z = [];
        for i = 1:length(ind)
            
            switch analysisCode
                case 'Number'
                    X = [X; EM{iSess}(vTrialType==dimensionID & vTrial==ind(i),8)];
                case 'FirstLatency'
                    X = [X; EM{iSess}(vTrialType==dimensionID & vTrial==ind(i) & vROIOrder==1,8)];
                    Y = [Y; EM{iSess}(vTrialType==dimensionID & vTrial==ind(i) & vROIOrder==1,5)];
                case {'MeanFixDuration','TotalFixDuration'}
                    X = [X; EM{iSess}(vTrialType==dimensionID & vTrial==ind(i),8)];
                    Z = [Z; EM{iSess}(vTrialType==dimensionID & vTrial==ind(i),end)];
                    Y = [Y; EM{iSess}(vTrialType==dimensionID & vTrial==ind(i),12)]; % FD
            end
        end
        
        switch analysisCode
            case 'Number'
                sE(iSess,iLevel) = nansum(X==1) / length(X);
                sM(iSess,iLevel) = nansum(X==2) / length(X);
                sC(iSess,iLevel) = nansum(X==3) / length(X);
                sN(iSess,iLevel) = nansum(X==0) / length(X);
            case {'FirstLatency','MeanFixDuration'}
                sE(iSess,iLevel) = nanmean(Y(X==1));
                sM(iSess,iLevel) = nanmean(Y(X==2));
                sC(iSess,iLevel) = nanmean(Y(X==3));
                sN(iSess,iLevel) = nanmean(Y(X==0));
            case 'TotalFixDuration'
                uZ = unique(Z); clear vE vM vC vN;
                vE = NaN; vM = NaN; vC = NaN; vN = NaN;
                for i = 1:length(uZ)
                    vE(i) = nansum(Y(Z==uZ(i) & X==1));
                    vM(i) = nansum(Y(Z==uZ(i) & X==2));
                    vC(i) = nansum(Y(Z==uZ(i) & X==3));
                    vN(i) = nansum(Y(Z==uZ(i) & X==0));
                    
                    nn(i) = length(Y(Z==uZ(i)));
                end
                
                sE(iSess,iLevel) = nanmean(vE);
                sM(iSess,iLevel) = nanmean(vM);
                sC(iSess,iLevel) = nanmean(vC);
                sN(iSess,iLevel) = nanmean(vN);
                
                NN(iSess,iLevel) = nanmean(nn);
        end
    end
    
    sE(iSess,9) = (sE(iSess,1)+sE(iSess,7))/2;
    sE(iSess,10) = (sE(iSess,2)+sE(iSess,6))/2;
    sE(iSess,11) = (sE(iSess,3)+sE(iSess,4)+sE(iSess,5))/3;
    
    sM(iSess,9) = (sM(iSess,1)+sM(iSess,7))/2;
    sM(iSess,10) = (sM(iSess,2)+sM(iSess,6))/2;
    sM(iSess,11) = (sM(iSess,3)+sM(iSess,4)+sM(iSess,5))/3;
    
    sC(iSess,9) = (sC(iSess,1)+sC(iSess,7))/2;
    sC(iSess,10) = (sC(iSess,2)+sC(iSess,6))/2;
    sC(iSess,11) = (sC(iSess,3)+sC(iSess,4)+sC(iSess,5))/3;
    
    sN(iSess,9) = (sN(iSess,1)+sN(iSess,7))/2;
    sN(iSess,10) = (sN(iSess,2)+sN(iSess,6))/2;
    sN(iSess,11) = (sN(iSess,3)+sN(iSess,4)+sN(iSess,5))/3;
end

%% compute mean for each category

for iCat = 1:length(vSubCat)
    for iLevel = 1:nLevel+4
        ssE(iCat,iLevel) = nanmean(sE(strcmp(vSub,vSubCat{iCat}),iLevel));
        ssM(iCat,iLevel) = nanmean(sM(strcmp(vSub,vSubCat{iCat}),iLevel));
        ssC(iCat,iLevel) = nanmean(sC(strcmp(vSub,vSubCat{iCat}),iLevel));
        ssN(iCat,iLevel) = nanmean(sN(strcmp(vSub,vSubCat{iCat}),iLevel));
    end
end

%% plotting parameters

switch analysisCode
    case 'Number'
        sF = 100; yRange = [0 100]; yLabel = '% Number of Fixations';      
    case 'FirstLatency'
        sF = 1; yRange = [0 600]; yLabel = 'First Fixation Latency [ms]';
    case 'MeanFixDuration'
        sF = 1; yRange = [0 600]; yLabel = 'Average Fixation Duration [ms]';
    case 'TotalFixDuration'
        sF = 1; yRange = [0 600]; yLabel = 'Total Fixation Duration [ms]';
end

figNameBarAll = ['Fixation ' analysisCode ' Bar_All Levels_' resp];
figNameBarLevel = ['Fixation ' analysisCode ' Bar_Stimulus Levels_' resp];
figNameBarAmbiguity = ['Fixation ' analysisCode ' Bar_Ambiguity Levels_' resp];

%% plot bars for overall 

if PLOT.BarStimulusAll
    figure(78),clf; hold on;
    
    levelToPlot = 8; % 8 for all, 9: anchor, 10: intermediate, 11: high
    
    bar(1,sF*ssE(1,levelToPlot),'r'); bar((nCat+1)+1,sF*ssM(1,levelToPlot),'b'); bar((nCat+1)*2+1,sF*ssC(1,levelToPlot),'m'); bar((nCat+1)*3+1,sF*ssN(1,levelToPlot),'k');
    
    for iCat = 1:length(vSubCat)
        plotBar(sF*sE(strcmp(vSub,vSubCat{iCat}),levelToPlot),iCat,'r');
        plotBar(sF*sM(strcmp(vSub,vSubCat{iCat}),levelToPlot),iCat+(nCat+1),'b');
        plotBar(sF*sC(strcmp(vSub,vSubCat{iCat}),levelToPlot),iCat+(nCat+1)*2,'m');
        plotBar(sF*sN(strcmp(vSub,vSubCat{iCat}),levelToPlot),iCat+(nCat+1)*3,'k');
    end
    
    legend('Eye','Mouth','Center','Other');
    
    set(gca,'ylim',yRange);
    
    ylabel(yLabel);
    set(gca,'xtick',[1:nCat (nCat+1)+(1:nCat) (nCat+1)*2+(1:nCat) (nCat+1)*3+(1:nCat)],'xticklabel',repmat(vSubCat,[1 4]),'TickLabelInterpreter','none');
    title([vSubCat],'interpret','none');
end

%% plot bars for each stimulus level

if PLOT.BarStimulusLevels
    nRow = 7; nCol = 1;
    
    figure(79),clf
    
    for iLevel = 1:nLevel
        subplot(nRow,nCol,iLevel); hold on;
        
        bar(1,sF*ssE(1,iLevel),'r'); bar((nCat+1)+1,sF*ssM(1,iLevel),'b'); bar((nCat+1)*2+1,sF*ssC(1,iLevel),'m'); bar((nCat+1)*3+1,sF*ssN(1,iLevel),'k');
        
        for iCat = 1:length(vSubCat)
            plotBar(sF*sE(strcmp(vSub,vSubCat{iCat}),iLevel),iCat,'r');
            plotBar(sF*sM(strcmp(vSub,vSubCat{iCat}),iLevel),iCat+(nCat+1),'b');
            plotBar(sF*sC(strcmp(vSub,vSubCat{iCat}),iLevel),iCat+(nCat+1)*2,'m');
            plotBar(sF*sN(strcmp(vSub,vSubCat{iCat}),iLevel),iCat+(nCat+1)*3,'k');
        end
        
        legend('Eye','Mouth','Center','Other','location','eastoutside');
        
        set(gca,'ylim',yRange);
        
        ylabel(yLabel);
        set(gca,'xtick',[1:nCat (nCat+1)+(1:nCat) (nCat+1)*2+(1:nCat) (nCat+1)*3+(1:nCat)],'xticklabel',repmat(vSubCat,[1 4]),'TickLabelInterpreter','none');
        title([num2str(levels(iLevel)) '% Fear ']);
    end
end

%% plot bars for each ambiguity level

if PLOT.BarAmbiguityLevels
    
    figure(80),clf;
    
    for iCat = 1:length(vSubCat)
        subplot(length(vSubCat),1,iCat); hold on;

        for iLevel = 1:3
            bar(iLevel,sF*ssE(iCat,iLevel+8),'r');
            bar(iLevel+4,sF*ssM(iCat,iLevel+8),'b');
            bar(iLevel+8,sF*ssC(iCat,iLevel+8),'m');
            bar(iLevel+12,sF*ssN(iCat,iLevel+8),'k');
            
            plotBar(sF*sE(strcmp(vSub,vSubCat{iCat}),iLevel+8),iLevel,'r');
            plotBar(sF*sM(strcmp(vSub,vSubCat{iCat}),iLevel+8),iLevel+4,'b');
            plotBar(sF*sC(strcmp(vSub,vSubCat{iCat}),iLevel+8),iLevel+8,'m');
            plotBar(sF*sN(strcmp(vSub,vSubCat{iCat}),iLevel+8),iLevel+12,'k');
        end
        
        legend('Eye','Mouth','Center','Other','location','northeast');

        set(gca,'ylim',yRange);
        
        set(gca,'xtick',[1 2 3 5 6 7 9 10 11 13 14 15],'xticklabel',repmat({'Anchor','30,70','40-60'},[1 4]));
        
        ylabel(yLabel);
        
        title(['Ambiguity   ' vSubCat{iCat}],'interpret','none');
    end
end
