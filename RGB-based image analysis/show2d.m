function [] = show2d(U)
% A simple utility function to display either real or complex 2D matrix data as grayscale images.
% If the input is complex, it visualizes the magnitude.
if isreal(U)
    figure;
    imagesc(U);colormap gray;axis image;
else
    figure;
    imagesc(abs(U));colormap gray;axis image;
end
end