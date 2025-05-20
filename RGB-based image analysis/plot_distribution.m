% This is the main script used to perform the following tasks:
% 
% Background Correction
% Computes an averaged background image across all input frames and applies a Gaussian filter to even out noise.
% 
% Channel Region Detection
% Identifies regions with significant red signal deviation and constructs a binary mask to define the channel area.
% 
% Color Deconvolution & ROI Extraction For each frame
% 
% Performs background normalization.
% Identifies red and blue regions based on contrast thresholding.
% Applies morphological operations to refine the masks.
% Excludes the inlet region based on a fixed boundary.
% Extracts the ROI and saves the processed region.
% Plotting Intensity Distributions
% Uses the plot_intensity() function to plot the average intensity distribution of red and blue signals along the x-axis of the channel and saves the figures.

imgDir = 'C:\Users\Yuanyuan\OneDrive - The Chinese University of Hong Kong\Collaboration_cell deformation\香港中文大学_合作项目_学习资料\重点_Matlab图像处理codes\基于RGB的图像分割\Sample2';
saveDir = 'C:\Users\Yuanyuan\OneDrive - The Chinese University of Hong Kong\Collaboration_cell deformation\香港中文大学_合作项目_学习资料\重点_Matlab图像处理codes\基于RGB的图像分割\Output';
mkdir(saveDir);

files = dir(fullfile(imgDir, '*.tif'));
averagingFunction = @(x) mean(x.data(:));

%% find the bg
bg = 0;
for ii = 1:numel(files)
    im = single(imread(fullfile(imgDir, files(ii).name)));
    bg = bg + mean(im, 3);
end

bg = bg./(mean(bg(:)));
bg = imgaussfilt(bg, [51,51]);
save(fullfile(saveDir, 'parameters.mat'), 'bg');

%% find the channel region by binary masking
tot_region = 0;
im_contrast_threshold = 5;

for ii = 1:numel(files)
    im = single(imread(fullfile(imgDir, files(ii).name)))./bg;
    im_contrastRed = im(:,:,1) - mean(im, 3);
    im_contrastRed = medfilt2(im_contrastRed, [11, 11]);
    channel_regionRed = im_contrastRed>im_contrast_threshold;
    channel_regionRed = bwareaopen(channel_regionRed, 10000);

    tot_region = tot_region|channel_regionRed;
    tot_region = bwconvhull(tot_region);
end
save(fullfile(saveDir, 'parameters.mat'), 'tot_region', '-append');
imwrite(uint8(tot_region)*255, fullfile(saveDir, 'channel_region.tif'));


%% color deconvlution, plot distribution
thresholdRed = 5;
thresholdBlue = 8;
inlet_left_corr = 680; %left coordinate of the inlet

color1 = [187, 162, 131]; % Red color
color2 = [101, 150, 129]; % Blue color
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
    plot_intensity(deconvIm(:,:,1), deconvIm(:,:,2), fileID, saveDir); % Red, Blue channel
end


function plot_intensity(imgR, imgB, fileID, saveDir)
sumR = sum(imgR, 1);
elementR = sum((imgR~=0), 1);
sumR(elementR~=0) = sumR(elementR~=0)./elementR(elementR~=0);

sumB = sum(imgB, 1);
elementB = sum((imgB~=0), 1);
sumB(elementB~=0) = sumB(elementB~=0)./elementB(elementB~=0);

plot(sumR, 'r-', 'LineWidth', 1); hold on
plot(sumB, 'b--', 'LineWidth', 1);

legend('Red distribution','Blue distribution');
ylim([0 0.3]);

set(gcf, 'Position', [0, 0, 800, 400]);
saveas(gcf, fullfile(saveDir, ['Distribution-', fileID, '.tif']));
close
end
