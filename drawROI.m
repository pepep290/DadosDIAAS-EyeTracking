function drawROI(ROI)

plot([ROI.x(1) ROI.x(1)],[ROI.y(1) ROI.y(2)],'r-','linewidth',2);
plot([ROI.x(1) ROI.x(2)],[ROI.y(1) ROI.y(1)],'r-','linewidth',2);
plot([ROI.x(2) ROI.x(2)],[ROI.y(1) ROI.y(2)],'r-','linewidth',2);
plot([ROI.x(1) ROI.x(2)],[ROI.y(2) ROI.y(2)],'r-','linewidth',2);