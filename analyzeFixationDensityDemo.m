clear; clc;

%% parameters

dimensionID = 1; % for fearful-happy morphs (other types of stimuli were used in different studies)
fixN = 0; % ordinal order of the fixation for analysis; 0 for all fixations
resp = 'Both'; % Response type: 'Both' 'Fearful' 'Happy'
isUsingFixDuration = 0; % weighted by fixation duration

vSubCat = {'ASD','ASD_Ctrl','Big','Small'}; % categories of subjects for analysis
% ASD vs. ASD_Ctrl: described in Wang and Adolphs (Neuropsychologia 2017)
% Big vs. Small: described in Wang (Scientific Reports 2018)

%% load data

load('ET_Data_All');

%% compute density maps

for iSess = 1:length(EM)
    vTrialType = EM{iSess}(:,7);
    vFixOrder = EM{iSess}(:,2);
    vTrial = EM{iSess}(:,end);
    vDur = EM{iSess}(:,12);
    
    vDur = round(vDur);
    
    codeL = beh(iSess).codeL;
    vResp = beh(iSess).vResp;
    
    for iLevel = 1:nLevel+1 % level 8 is for all levels
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
        
        XX = []; YY = [];
        for i = 1:length(ind)
            if fixN == 0
                tmpXX = EM{iSess}(vTrialType==dimensionID & vTrial==ind(i),3);
                tmpYY = EM{iSess}(vTrialType==dimensionID & vTrial==ind(i),4);
                
                tmpD = vDur(vTrialType==dimensionID & vTrial==ind(i));
            else
                tmpXX = EM{iSess}(vTrialType==dimensionID & vFixOrder==fixN & vTrial==ind(i),3);
                tmpYY = EM{iSess}(vTrialType==dimensionID & vFixOrder==fixN & vTrial==ind(i),4);
                
                tmpD = vDur(vTrialType==dimensionID & vFixOrder==fixN & vTrial==ind(i));
            end
            
            % take fixation duration into account
            if isUsingFixDuration
                tmpXXX = []; tmpYYY = [];
                for j = 1:length(tmpXX)
                    tmpXXX = [tmpXXX; repmat(tmpXX(j),[tmpD(j) 1])];
                    tmpYYY = [tmpYYY; repmat(tmpYY(j),[tmpD(j) 1])];
                end
                tmpXX = tmpXXX; tmpYY = tmpYYY;
            end
            
            XX = [XX; tmpXX];
            YY = [YY; tmpYY];
        end
        
        [Z{iSess,iLevel} ZC{iSess,iLevel}] = analyzeFixationDensity_Compute(XX,YY,imgW,imgH);
    end
end

%% normalize and compute group average

ZCAll = nan*ones(length(sessions),nLevel+1,imgH,imgW);

for iSess = 1:length(sessions)
    for iLevel = 1:nLevel+1
        ZCAll(iSess,iLevel,:,:) = ZC{iSess,iLevel} / sum(ZC{iSess,iLevel}(:));
    end
end

for iCat = 1:length(vSubCat)
    for iLevel = 1:nLevel+1
        M = ZCAll(strcmp(vSub,vSubCat{iCat}),iLevel,:,:);
        ZCCat{iCat,iLevel} = squeeze(nanmean(M,1));
        maxZCCat(iCat,iLevel) = max(ZCCat{iCat,iLevel}(:));
    end
    
    ZCCat{iCat,9} = (ZCCat{iCat,1}+ZCCat{iCat,7})/2;
    ZCCat{iCat,10} = (ZCCat{iCat,2}+ZCCat{iCat,6})/2;
    ZCCat{iCat,11} = (ZCCat{iCat,3}+ZCCat{iCat,4}+ZCCat{iCat,5})/3;
    
    maxZCCat(iCat,9) = max(ZCCat{iCat,9}(:));
    maxZCCat(iCat,10) = max(ZCCat{iCat,10}(:));
    maxZCCat(iCat,11) = max(ZCCat{iCat,11}(:));
end

% sFactor = 1/max(ZCAll(:))*255;
sFactor = 1/max(maxZCCat(:));
sFactor1 = 1/max(maxZCCat(:,8));
sFactor2 = 1/max(max(maxZCCat(:,1:7)));
sFactor3 = 1/max(max(maxZCCat(:,9:11)));

M = colormap; close(figure(1));

%% plot collapsing all stimulus levels

nRow = 2; nCol = 2;
figure(11),clf

for iCat = 1:length(vSubCat)
    subplot(nRow,nCol,iCat), hold on;
    
    S2 = floor(ZCCat{iCat,8}*sFactor1*size(M,1));
    S = label2rgb(S2,M,[1 1 1]*0);
    
    P = faceImg{3}/255*0.6 + double(S)/255*0.4;
    imagesc(P,[0 1]); colorbar;
    
    drawROI(ROI_E);
    drawROI(ROI_M);
    drawROI(ROI_C);
    
    axis ij; axis tight; axis off; axis equal; %axis square;
    title([vSubCat{iCat} '   n=' num2str(sum(strcmp(vSub,vSubCat{iCat}))) ' '],'interpret','none');
end

%% plot according to stimulus levels

nRow = length(vSubCat); nCol = length(levels);
figure(12),clf

for iCat = 1:length(vSubCat)
    for iLevel = 1:nLevel
        subplot(nRow,nCol,iLevel+(iCat-1)*nLevel), hold on;
        
        S2 = floor(ZCCat{iCat,iLevel}*sFactor2*size(M,1));
        if all(isnan(S2(:)))
            S = repmat(S2,[1 1 3]);
        else
            S = label2rgb(S2,M,[1 1 1]*0);
        end
        
        P = faceImg{iLevel}/255*0.6 + double(S)/255*0.4;
        imagesc(P,[0 1]); % colorbar;
        
        axis ij; axis tight; axis off; axis equal; axis square;
        
        title([vSubCat{iCat} ' n=' num2str(sum(strcmp(vSub,vSubCat{iCat}))) ' ' num2str(levels(iLevel)) '%Fear '],'interpret','none');
    end
end

%% plot according to ambiguity levels

nRow = length(vSubCat); nCol = 3;
titleMsg = {'Anchor','30,70','40-60'};
figure(13),clf

for iCat = 1:length(vSubCat)
    for iLevel = 1:3
        subplot(nRow,nCol,iLevel+(iCat-1)*3), hold on;
        
        S2 = floor(ZCCat{iCat,iLevel+8}*sFactor3*size(M,1));
        if all(isnan(S2(:)))
            S = repmat(S2,[1 1 3]);
        else
            S = label2rgb(S2,M,[1 1 1]*0);
        end
        
        P = faceImg{iLevel}/255*0.6 + double(S)/255*0.4;
        imagesc(P,[0 1]); % colorbar;
        
        drawROI(ROI_E);
        drawROI(ROI_M);
        drawROI(ROI_C);
        
        axis ij; axis tight; axis off; axis equal; axis square;
        
        title([vSubCat{iCat} ' n=' num2str(sum(strcmp(vSub,vSubCat{iCat}))) ' ' titleMsg{iLevel} ' '],'interpret','none');
    end
end
