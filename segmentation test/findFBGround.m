function mask = findFBGround(image)
%Function that find front and background of an image
%Define threshold
if(length(size(image))==3)
image = rgb2gray(image);
end
[sizeX sizeY] = size(image);
maxValue = max(max(image));
%Find frontground
threshold = 50;
meanValue = mean(mean(image));

indices = find(image>maxValue-threshold);
mask1 = zeros(sizeX,sizeY);
mask1(indices) = 1;
%mask = Nonlinear_Diffusion(double(mask1),1,1e-2,1,20,0, 0);
mask = mask1;




end
