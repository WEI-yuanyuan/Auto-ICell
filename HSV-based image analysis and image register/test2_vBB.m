% 15/06/2023, created by Bijie Bai, baibijie@g.ucla.edu

%% Configuration
clear;
clc;

imgDir = 'sample2';
saveDir = 'Output';
mkdir(saveDir);

files = dir(fullfile(imgDir, '*.tif'));

%% Step1: image align and channel region defination
refImages = -1; %use last images for registration and background correction
saveDirAligned = 'Output\Aligned'; mkdir(saveDirAligned);
maxShiftV = 100;
maxShiftH = 100;
scale = 0.2;

refIm = imread(fullfile(imgDir, files(end + refImages).name));
% refImGray = single(rgb2gray(refIm))/255;
% refImRegROI = 1-refImGray(1:550, 550:end);  %select the regions without temporal variantion
%
% refImRegROI = refImRegROI./imgaussfilt(refImRegROI, [41, 41]);
% refImRegROI = (refImRegROI - min(refImRegROI(:)))/(max(refImRegROI(:))-min(refImRegROI(:)));
% refImRegROI = imgaussfilt(refImRegROI, [5,5]);
% refImRegROI = imadjust(refImRegROI);
%
% for ii = 1:numel(files)
%     curIm = imread(fullfile(imgDir, files(ii).name));
%     curImGray = single(rgb2gray(curIm))/255;
%     curImRegROI = 1-curImGray(1:550, 550:end);
%     curImRegROI = curImRegROI./imgaussfilt(curImRegROI, [41, 41]);
%     curImRegROI = (curImRegROI - min(curImRegROI(:)))/(max(curImRegROI(:))-min(curImRegROI(:)));
%     curImRegROI = imgaussfilt(curImRegROI, [5,5]);
%     curImRegROI = imadjust(curImRegROI);
%
%     [vShift, hShift, correff] = register(imgaussfilt(refImRegROI, [3,3]), ...
%         imgaussfilt(curImRegROI, [3,3]), maxShiftV, maxShiftH, scale);
%
%     for kk = 1:3
%         curIm(:,:,kk) = circshift(curIm(:,:,kk), ...
%             round([vShift, hShift]));
%     end
%
%     imwrite(curIm, fullfile(saveDirAligned, files(ii).name));
% end


%% Step2: find the channel region by by getting the overlap area (use HSV -- S space)
% Here I only selected first 10-frames (after alignment) for defining regions
% you can run this and fix the region for pre-experimental measurements
saveDirSegmented = 'Output\Segmented'; mkdir(saveDirSegmented);

channelRegion = zeros(size(refIm, 1), size(refIm, 2), 'logical');
for ii = 1:10
    curIm = imread(fullfile(saveDirAligned, files(ii).name));
    curImHSV = rgb2hsv(curIm);
    curImSatu = imgaussfilt(curImHSV(:,:,2), [5, 5]);

    curImRegion = imbinarize(curImSatu);
    curImRegion = bwareaopen(curImRegion, 60000);
    %     show2d(curImRegion);
    channelRegion = channelRegion|curImRegion;
end

channelRegion = imerode(channelRegion, strel('disk', 10));  %shink the size to avoid the boundary
channelRegion = bwconvhull(channelRegion);
% 
% save(fullfile(saveDirSegmented, 'channelRegion.mat'), 'channelRegion');
% 
% % save segmented images just for reference/visualization
% for ii = 1:numel(files)
%     curIm = imread(fullfile(saveDirAligned, files(ii).name));
%     curImSeg = curIm.*uint8(channelRegion)*1.2 + curIm.*uint8(1-channelRegion)*0.2;
% 
%     imwrite(curImSeg, fullfile(saveDirSegmented, files(ii).name));
% end

%% find the RBC region by thresholding/gradient
RBC_Segmented_dir = 'Output\Segmented_RBC'; mkdir(RBC_Segmented_dir);
plasma_Segmented = 'Output\Segmented_Plasma'; mkdir(plasma_Segmented);

RBC_s_Threshold = 0.35;
plasma_s_Threshold = 0.13;

RBC_area_log = [];
Plasma_area_log = [];

for ii = 1:numel(files)
    curIm = imread(fullfile(saveDirAligned, files(ii).name));
    curImHSV = rgb2hsv(curIm);
    curImSatu = imgaussfilt(curImHSV(:,:,2), [9, 9]);

    RBCRegion = curImSatu >= RBC_s_Threshold;
    RBCRegion = RBCRegion.*channelRegion;
    RBCRegion = bwareaopen(RBCRegion, 100);

    plasmaRegion = curImSatu<RBC_s_Threshold&curImSatu>plasma_s_Threshold;
    plasmaRegion = plasmaRegion.*channelRegion;
    plasmaRegion = bwareaopen(plasmaRegion, 50);
    plasmaRegion = imopen(plasmaRegion, strel('disk', 5));
    plasmaRegion = bwconvhull(plasmaRegion);
    
    RBCProp = regionprops(RBCRegion, 'Area');
    PlasmaProp = regionprops(plasmaRegion, 'Area');

    if isempty(PlasmaProp)
        PlasmaArea = 0;
    else
        PlasmaArea = PlasmaProp.Area;
    end

    if isempty(RBCProp)
        RBCArea = 0;
    else
        RBCArea = RBCProp.Area;
    end

    RBCHighlight = curIm.*uint8(RBCRegion)*1.2 + curIm.*uint8(1-RBCRegion)*0.2;
    imwrite(RBCHighlight, fullfile(RBC_Segmented_dir, files(ii).name));
    PlasmaHighlight = curIm.*uint8(plasmaRegion)*1.2 + curIm.*uint8(1-plasmaRegion)*0.2;
    imwrite(PlasmaHighlight, fullfile(plasma_Segmented, files(ii).name));

    RBC_area_log = [RBC_area_log, RBCArea];
    Plasma_area_log = [Plasma_area_log, PlasmaArea];
end

%% define your own plotting and evalution functions!
% save(fullfile(saveDir, 'AreaLog.mat'), 'RBC_area_log', Plasma_area_log);

figure; plot(RBC_area_log,'Color', [0.6350 0.0780 0.1840], 'LineWidth', 2);
hold on
plot(Plasma_area_log, 'Color', [.8, .3, 0], 'LineWidth', 2);
xlabel('Time','Fontsize', 12);
ylabel('Intensity/Area', 'Fontsize', 12); 

figure(2); 
plot(Plasma_area_log./RBC_area_log, 'mo', 'MarkerSize', 3, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2);
xlabel('Position','Fontsize', 12);
ylabel('Intensity', 'Fontsize', 12); 

%%
function [vShift, hShift, correff] = register(imRef, imReg, maxShiftV, maxShiftH, register)
imRef = imresize(imRef, scale);
imReg = imresize(imReg, scale);

ip = calculateCrossCorrelationMap(imRef, imReg, maxShiftV*scale, maxShiftH*scale, 1);
[hCCM, wCCM] = size(ip);
[y, x, correff] = getMaxByCentroid(ip);
vShift = -(y - ceil((hCCM+1)/2))/scale;
hShift = -(x - ceil((wCCM+1)/2))/scale;
end