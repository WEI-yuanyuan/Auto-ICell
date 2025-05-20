function [y, x, v]  = getMaxByCentroid(ip)
% 10/11/2018, created by Hongda Wang, hdwang@ucla.edu
% Input Variables:
%   ip       - input real image for peak finding

% Check input
[h, w] = size(ip);
if min(h, w)<11
    warning('Wrong matrix size. Input matrix should be numerical MxN type.');
    [~,ind] = max(ip(:));
    [yMax,xMax]=ind2sub([h,w],ind);
    y = yMax;
    x = xMax;
    v = 0;
    return;
end

% Find global maximum and extract 25-point neighbourship
[v,ind] = max(ip(:));
[yMax,xMax]=ind2sub([h,w],ind);
if (xMax<6)||(xMax>w-5)||(yMax<6)||(yMax>h-5)
    %     warning('Maximum position at matrix border. No subsample approximation possible.');
    y = yMax;
    x = xMax;
    v = 0;
    return;
end


% Peak approximation using 2D polynomial fit within 9 point neighbourship
% neighbour25 = ip(mod([yMax-5:yMax+5]-1,h)+1,mod([xMax-5:xMax+5]-1,w)+1);
neighbour25 = ip(yMax-5:yMax+5,xMax-5:xMax+5);

[x2, y2] = meshgrid(-5:5, -5:5);

centroidV = sum(sum(neighbour25.*y2))/sum(neighbour25(:));
centroidH = sum(sum(neighbour25.*x2))/sum(neighbour25(:));

x = xMax + centroidH;
y = yMax + centroidV;

end