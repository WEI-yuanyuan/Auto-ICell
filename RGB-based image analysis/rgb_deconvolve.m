function outIm = rgb_deconvolve(rgbIm, color1, color2, color3)

% Performs color deconvolution on an RGB image using user-defined stain color vectors. 
% This helps in separating overlapping color signals (e.g., red and blue) in biological or histological images. 
%
% The process includes:
% Normalizing the RGB image
% Applying a logarithmic transformation
% Projecting the image into a new color space defined by the input vectors

addpath('mtimesx');

rgbIm = single(rgbIm)/255;
tform = cat(1, color1, color2, color3);
tform = 255 - tform;
tform = tform/255;
% tform_hed2rgb = [0.65, 0.70, 0.29; 0.07, 0.99, 0.11; 0.27, 0.57, 0.78];

rgbIm = single(rgbIm);
rgbIm(rgbIm<1e-6) = 1e-6;
imSizex = size(rgbIm, 1);
logAdjust = log(1e-6);

adjustedIm = log(rgbIm)/logAdjust;
adjustedIm = squeeze(reshape(adjustedIm, 1, [], 3));

% hedIm = adjustedIm*tform_rgb2hed;
outIm = adjustedIm/tform;
% hedIm(hedIm<0)=0;
outIm = reshape(outIm, imSizex, [], 3);

end