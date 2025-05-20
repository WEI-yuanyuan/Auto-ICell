function [] = show2d(U)
if isreal(U)
    figure;
    imagesc(U);colormap gray;axis image;
else
    figure;
    imagesc(abs(U));colormap gray;axis image;
end
end