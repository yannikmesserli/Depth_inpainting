%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%											%
%	IMAGE COMMUNICATION - EPFL COURSE		%
%				June 2012					%
%		Inpaiting of depth image			%
%											%
% Yannik Messerli: yannik.messerli@epfl.ch	%
% 	Nicolas Jorns: nicolas.jorns@epfl.ch	%
%											%
% 		Supervised by Thomas Maugey			%
%											%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

addpath('../multi-plan');

patch_size = 5;

% Estimation done. Load it:
mask = rgb2gray(im2double(imread('mask.png')));
imholes = zeros(size(mask));
im = rgb2gray(im2double(imread('result.png')));
[nCol nRow] = size(im);

pointToFill = find(mask > 0);

for i=1:length(pointToFill)
	Hp = getpatch([nCol nRow], pointToFill(i), patch_size);
	Hp = Hp( mask(Hp) < 1 );
	if length(Hp) > (patch_size^2)*0.7
		im(pointToFill(i)) = mean(im(Hp));
	else
		imholes(pointToFill(i)) = 1.0;
	end
end
%figure; imshow(im);
imfinal = im;
[components nbComp] = bwlabeln(imholes);
nbComp
figure; imagesc(components);
cord_points_region = find(components == 5);
mask = ones(size(im));
mask(cord_points_region) = 0.0;
fillRegion = ~mask;

plans(1) = load_plan(im, 'plan4-1.png');
plans(2) = load_plan(im, 'plan4-2.png');

[regions nb_regions] = sep_region(im, fillRegion, plans);
%tmp(:,:,1) = im+regions/2;
%tmp(:,:,2) = im;
%tmp(:,:,3) = im;
%figure; imshow(tmp);

ind1 = find(regions == 1);
fillRegion = zeros(size(im)); fillRegion(ind1) = 1.0;
filled1 = fill_region(fillRegion, im, plans(2));

ind2 = find(regions == 2);
fillRegion = zeros(size(im)); fillRegion(ind2) = 1.0;
filled2 = fill_region(fillRegion, im, plans(1));

im(ind1) = filled1(ind1);
im(ind2) = filled2(ind2);


cord_points_region = find(components == 3);
mask = ones(size(im));
mask(cord_points_region) = 0.0;
fillRegion = ~mask;

plans(1) = load_plan(im, 'plan3-2.png');
plans(2) = load_plan(im, 'plan3-1.png');

[regions nb_regions] = sep_region(im, fillRegion, plans);
%tmp(:,:,1) = im+regions/2;
%tmp(:,:,2) = im;
%tmp(:,:,3) = im;
%figure; imshow(tmp);

ind1 = find(regions == 1);
fillRegion = zeros(size(im)); fillRegion(ind1) = 1.0;
filled1 = fill_region(fillRegion, im, plans(2));

ind2 = find(regions == 2);
fillRegion = zeros(size(im)); fillRegion(ind2) = 1.0;
filled2 = fill_region(fillRegion, im, plans(1));

im(ind1) = filled1(ind1);
im(ind2) = filled2(ind2);

figure; imshow(im);


