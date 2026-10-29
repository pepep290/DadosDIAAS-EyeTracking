function [Z ZC] = analyzeFixationDensity_Compute(XX,YY,imgW,imgH)

Z = zeros(imgH,imgW);

for i = 1:length(XX)
    if ~isnan(YY(i)) && ~isnan(XX(i)) && round(YY(i))>0 && round(XX(i))>0 && round(YY(i))<=imgH && round(XX(i))<=imgW
        Z(round(YY(i)),round(XX(i))) = Z(round(YY(i)),round(XX(i))) + 1;
    end
end

%% check density (individual)

if 0
    figure(6),clf
    plot(XX(:),YY(:),'.')
    axis ij
end

%% convolution

Z = sum(Z,3);

kernel = gausskernel([40 40],10);

ZC = conv2(Z,kernel,'same');

%% check density (group)

if 0
    figure(18),clf
    
    subplot(1,3,1)
    imagesc(Z);
    colorbar
%     title(sessions(iSess).ID)
    
    subplot(1,3,2)
    imagesc(ZC);
    colorbar
%     title(vSub,'interpret','none');
    
    subplot(1,3,3)
    imagesc(kernel);
    colorbar
end
