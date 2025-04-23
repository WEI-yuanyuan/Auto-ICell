%% Configuration
clear;
clc;

imgDir = 'sample2';
saveDir = 'Output\4';
% mkdir(saveDir);

files = dir(fullfile(imgDir, '*.tif'));
% averagingFunction = @(x) mean(x.data(:));

%% find the bg
bg = 0;
%% find the channel region by binary masking
tot_region = 0;
im_contrast_threshold = 5;
differential_values = [];

for ii = 1:numel(files)
    im = imread(fullfile(imgDir, files(ii).name));

    gray_img = rgb2gray(im);
    RBC_mask = gray_img < 70;
    RBC_mask = bwareafilt(RBC_mask, [1000, 100000]);
    RBC_mask = bwconvhull(RBC_mask);
    
    AreaNum = nnz(RBC_mask);
%    props = regionprops(RBC_mask, 'Area');
    
    plot_mask = single(RBC_mask);
    plot_mask(plot_mask==0)=0.2;
    img11 = single(im).*plot_mask;
    show2d(uint8(img11))
    pause (0.1);

    bg = bg + mean(img11, 3);
    tot_region =  RBC_mask;

    intensityR = sum(img11(:,:,1),'all');
    differential_value = intensityR / AreaNum; 
    differential_values(end+1) = differential_value;
    disp(differential_value)
    
end

bg = bg./(mean(bg(:)));
bg = imgaussfilt(bg, [51,51]);
save(fullfile(saveDir, 'parameters.mat'), 'bg');
save(fullfile(saveDir, 'parameters.mat'), 'tot_region', '-append');
imwrite(uint8(tot_region)*255, fullfile(saveDir, 'channel_region.tif'));


%% color deconvlution, plot distribution
thresholdRed = 5;
thresholdBlue = 8;
inlet_left_corr = 480; %left coordinate of the inlet

color1 = [32, 5, 13]; % Red Blood Cell color
color2 = [255, 255, 173]; % Plasma color

% color1 = [210, 158, 173]; % Red color
% color2 = [90, 124, 161]; % Blue color
color3 = [0, 0, 0]; % Set as zero if there's not 3rd color

for ii = 1:numel(files)
    fileName = files(ii).name;
    fileID = fileName(1:end-4);

    im = single(imread(fullfile(imgDir, fileName)))./bg;
    im_contrastRed = im(:,:,1) - mean(im, 3);
    im_contrastRed = medfilt2(im_contrastRed, [11, 11]);
    channel_regionRed = im_contrastRed>thresholdRed;
    channel_regionRed = bwareaopen(channel_regionRed, 10000);
    channel_regionRed = imerode(channel_regionRed, strel('disk', 10));

    inlet_region = im_contrastRed>max(im_contrastRed(:) - 10);
    inlet_region = bwareafilt(inlet_region, [2000, 6000]);

%     blobMeasurements = regionprops(inlet_region, 'BoundingBox');
%     bbs = blobMeasurements.BoundingBox;
%     inlet_left_corr = min(bbs(1:4:end)); %left coordinate of the inlet

    im_contrastBlue= im(:,:,3) - mean(im, 3);
    im_contrastBlue = medfilt2(im_contrastBlue, [11, 11]);
    channel_regionBlue = im_contrastBlue>thresholdBlue;
    channel_regionBlue = bwareaopen(channel_regionBlue, 3000);
    channel_regionBlue = imerode(channel_regionBlue, strel('disk', 10));

    analyze_region = channel_regionRed|channel_regionBlue;
    analyze_region = bwconvhull(analyze_region);
    analyze_region = analyze_region & tot_region;
    analyze_region = imerode(analyze_region, strel('disk', 10));

    % extract the image region to process
    analyze_region(:, inlet_left_corr:end) = 0; %ignore the regions at the right side of inle
    im_to_analyze = single(analyze_region).*im;
    imwrite(uint8(im_to_analyze), fullfile(saveDir, ['ROI-', fileID, '.tif']))

    % color deconv to seperate red/blue color
    deconvIm = rgb_deconvolve(im_to_analyze, color1, color2, color3);



    %plot
    plot_intensity(deconvIm(:,:,1), deconvIm(:,:,2), fileID, saveDir, AreaNum); % Red, Blue channel

end


figure;
plot(differential_values, 'b','LineWidth', 1.5);
xlabel('Index');
ylabel('Differential Value');
title('Differential Value');

function [sumR, sumB] = plot_intensity(imgR, imgB, fileID, saveDir, AreaNum)

sumR = sum(imgR, 1);
elementR = sum((imgR~=0), 1);
sumR(elementR~=0) = sumR(elementR~=0)./elementR(elementR~=0);

% intensityR = sum(imgR(:));
% differential_value = intensityR / AreaNum; 

sumB = sum(imgB, 1);
elementB = sum((imgB~=0), 1);
sumB(elementB~=0) = sumB(elementB~=0)./elementB(elementB~=0);

%{
plot(normalize(sumR,'range'), 'r-', 'LineWidth', 2);


 %plot(normalize(sumR,'range'), 'r-', 'LineWidth', 2); hold on
 %plot(normalize(sumB,'range'), 'b-', 'LineWidth', 2);

legend('Red blood cell distribution','Plasma distribution');


%{
plot(sumR, 'r-', 'LineWidth', 1); hold on
plot(sumB, 'b--', 'LineWidth', 1);

legend('Red distribution','Blue distribution');
ylim([0 0.3]);
%}

set(gcf, 'Position', [0, 0, 800, 400]);
% saveas(gcf, fullfile(saveDir, ['Distribution-', fileID, '.tif']));
% saveas(gcf, fullfile(saveDir, ['Distribution-', fileID, '-R-','-B-','-Diff','.tif']));
[maxValueR, maxIndexR] = max(sumR);
[maxValueB, maxIndexB] = max(sumB);
diffIndex = abs(maxIndexR - maxIndexB);

% 修改文件名以包含横坐标和差值
% saveas(gcf, fullfile(saveDir, ['Distribution-', fileID, '-R-', num2str(maxIndexR), '-B-', num2str(maxIndexB), '-Diff-', num2str(diffIndex), '.tif']));
saveas(gcf, fullfile(saveDir, [fileID, '-', num2str(diffIndex), '.tif']));
%}


close all
end
