clear all;
close all;
addpath('../estimation');


patch_size = 5;

% Estimation done. Load it:
mask = im2double(imread('mask.png'));
imholes = zeros(size(mask));
im = im2double(imread('result.png'));
[nCol nRow] = size(im);

pointToFill = find(mask > 0);

for i=1:length(pointToFill)
	Hp = getpatch([nCol nRow], pointToFill(i), patch_size);
	Hp = Hp( mask(Hp) < 1 );
	if length(Hp) > (patch_size^2)*0.9
		im(pointToFill(i)) = mean(im(Hp));
	else
		imholes(pointToFill(i)) = 1.0;
	end
end
%figure; imshow(im);
imfinal = im;
[components nbComp] = bwlabeln(imholes);
 for j = 1:nbComp;
 	cord_points_region = find(components == j);
 	mask = ones(size(im));
 	mask(cord_points_region) = 0.0;
 	fillRegion = ~mask;
 	%tmp = inpainting(im, mask);
 	plan = load_plan(im, j);
 	tmp = fill_region(fillRegion, im, plan);
 	%tmp2(:,:,1) = tmp; tmp2(:,:,2) = tmp; tmp2(:,:,3) = tmp;
 	%tmp2(plan.center(1)-2:plan.center(1)+2, plan.center(2)-2:plan.center(2)+2,1) = 1.0;
 	%figure; imshow(tmp2);
 	
 	
 	imfinal(cord_points_region) = tmp(cord_points_region);
end

figure; imshow(imfinal);