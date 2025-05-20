function ipCCM = calculateCrossCorrelationMap(ip1, ip2, maxShiftV, maxShiftH, tf_normalized)
% Calculate the CrossCorrelationMap of two input images
% 08/10/2017, created by Hongda Wang, hdwang@ucla.edu
%
% Input Variables:
%   ip1         - reference image to be matched
%   ip2         - shifted image to be corrected

[h1, w1] = size(ip1);
[h2, w2] = size(ip2);
maxShiftV = round(maxShiftV);
maxShiftH = round(maxShiftH);

if (w1 ~= w2) || (h1 ~= h2)
    error('input images must have the same size!');
else
    if ~isEvenSquare(ip1)
        
        sizeCrop = getClosestEvenSquareSize(ip1);
        
        Roi = [floor((w1-sizeCrop)/2)+1, floor((h1-sizeCrop)/2)+1, sizeCrop, sizeCrop];
        ip1 = ip1(Roi(2):(Roi(2)+Roi(4)-1), Roi(1):(Roi(1)+Roi(3)-1));
        ip2 = ip2((Roi(2):Roi(2)+Roi(4)-1), Roi(1):(Roi(1)+Roi(3)-1));
    end

    ipCCM = real(ifft2(fft2(single(ip1)).*conj(fft2(single(ip2)))));
    ipCCM = fftshift(ipCCM);
    ipCCM = flip(flip(ipCCM,1),2);
    
    if tf_normalized
        ipCCM = normalizeCrossCorrelationMap(ip1, ip2, ipCCM);
    end
    
end

[hCCM, wCCM] = size(ipCCM);
RoiCCM = [wCCM/2 - maxShiftH, hCCM/2 - maxShiftV, maxShiftH * 2 + 1, maxShiftV * 2 + 1];
ipCCM = ipCCM(RoiCCM(2):(RoiCCM(2)+RoiCCM(4)-1), RoiCCM(1):(RoiCCM(1)+RoiCCM(3)-1));

end



function ipCCM = normalizeCrossCorrelationMap(ip1, ip2, ipCCM)

ccmPixels = ipCCM(:);

[h, w] = size(ipCCM);

[vMax, pMax] = max(ccmPixels);
[vMin, pMin] = min(ccmPixels);

[shiftYMax, shiftXMax] = ind2sub([h, w], pMax);
[shiftYMin, shiftXMin] = ind2sub([h, w], pMin);
shiftYMax = shiftYMax - h/2 - 1;
shiftXMax = shiftXMax - w/2 - 1;
shiftYMin = shiftYMin - h/2 - 1;
shiftXMin = shiftXMin - w/2 - 1;

% calculate max and min Pearson product-moment correlation coefficient
maxPPMCC = calculatePPMCC(ip1, ip2, shiftXMax, shiftYMax);
minPPMCC = calculatePPMCC(ip1, ip2, shiftXMin, shiftYMin);

deltaV = vMax - vMin;
deltaP = maxPPMCC - minPPMCC;
v = (ipCCM - vMin) / deltaV;
ipCCM = (v * deltaP) + minPPMCC;

end

function PPMCC = calculatePPMCC(ip1, ip2, shiftX, shiftY)
[h, w] = size(ip1);

newW = w - abs(shiftX);
newH = h - abs(shiftY);

% shift ips and crop as needed
x0 = max(1, -shiftX+1);
y0 = max(1, -shiftY+1);
x1 = x0 + shiftX;
y1 = y0 + shiftY;
Roi1 = [x0, y0, newW, newH];
Roi2 = [x1, y1, newW, newH];
ip1 = ip1(Roi1(2):(Roi1(2)+Roi1(4)-1), Roi1(1):(Roi1(1)+Roi1(3)-1));
ip2 = ip2(Roi2(2):(Roi2(2)+Roi2(4)-1), Roi2(1):(Roi2(1)+Roi2(3)-1));

pixels1 = double(ip1(:));
pixels2 = double(ip2(:));

% calculate means
meanp1 = mean(pixels1);
meanp2 = mean(pixels2);

% calculate correlation

v1 = double(pixels1 - meanp1);
v2 = double(pixels2 - meanp2);

covariance = sum(v1.*v2);
squareSum1 = sum(v1.*v1);
squareSum2 = sum(v2.*v2);

if (squareSum1 == 0 || squareSum2 == 0)
    PPMCC = 0;
else
    PPMCC = single(covariance / sqrt(squareSum1 * squareSum2));
end
end

function tf = isEvenSquare(ip)
[h, w] = size(ip);

if (w ~= h)
    tf = false;
    return;
end
if (mod(w,2) ~= 0)
    tf = false;
    return;
end
tf = true;

end

function n = getClosestEvenSquareSize(ip)
[h, w] = size(ip);
sizeMin = min(w, h);
if mod(sizeMin,2) == 0
    n = sizeMin;
else
    n = sizeMin - 1;
end

end
