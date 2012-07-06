clear all;
close all;


patch_size = 5;

% We load the different image and mask
mask = im2double(imread('mask.png'));
imholes = zeros(size(mask));

% result.png is the estimation of the camera view of the second camera
% with the provided code:

im = im2double(imread('result.png'));
[nCol nRow] = size(im);

% The region to be filled
pointToFill = find(mask > 0);

% We remove the pixel artifact by a simple average
%
% (This could be improved, but was not the subject, so 
% we let a simple average to remove artifact. )
for i=1:length(pointToFill)
	Hp = getpatch([nCol nRow], pointToFill(i), patch_size);
	Hp = Hp( mask(Hp) < 1 );
	
	% If the hole is smaller that 10% of the patch, then
	% we assume it is a pixel artifact. 
	% (It may remove small holes)
	if length(Hp) > (patch_size^2)*0.9
		im(pointToFill(i)) = mean(im(Hp));
	else
		imholes(pointToFill(i)) = 1.0;
	end
end

% Prepare our final image
imfinal = im;
% Label all different holes to be filled
[components nbComp] = bwlabeln(imholes);
nbComp
cord_points_region = find(components == 2);
mask = ones(size(im));
mask(cord_points_region) = 0.0;
fillRegion = ~mask;

% Since we do not have a good segmentation algorithm
% We label the region around each hole manually.
% We load here the region for the middle.
plans(1) = load_plan(im, 'plan_milieu1-2.png');
%plans(3) = load_plan('plan2.png');
plans(2) = load_plan(im, 'plan_milieu2-2.png');

% We separate the region with respect to the region around it
[regions nb_regions] = sep_region(im, fillRegion, plans);
%tmp(:,:,1) = im+regions/2;
%tmp(:,:,2) = im;
%tmp(:,:,3) = im;
%figure; imshow(tmp);

% We got two regions (Manually found):
% We then fill them as usual.
ind1 = find(regions == 1);
fillRegion = zeros(size(im)); fillRegion(ind1) = 1.0;
filled1 = fill_region(fillRegion, im, plans(2));

ind2 = find(regions == 2);
fillRegion = zeros(size(im)); fillRegion(ind2) = 1.0;
filled2 = fill_region(fillRegion, im, plans(1));

im(ind1) = filled1(ind1);
im(ind2) = filled2(ind2);

figure; imshow(im);

% Save the region
cord_points_region = find(components == 1);
fillRegion = zeros(size(im));
fillRegion(cord_points_region) = 1.0;

% Since we do not have a good segmentation algorithm
% We label the region around each hole manually.
% We load here the region for the top hole.
plans(1) = load_plan(im, 'plan1.png');
%plans(3) = load_plan('plan2.png');
plans(2) = load_plan(im, 'plan2-2.png');

% Separate it again
[regions nb_regions] = sep_region(im, fillRegion, plans);

% We got two regions (Manually found):
ind1 = find(regions == 1);
fillRegion = zeros(size(im)); fillRegion(ind1) = 1.0;
filled1 = fill_region(fillRegion, im, plans(2));

ind2 = find(regions == 2);
fillRegion = zeros(size(im)); fillRegion(ind2) = 1.0;
filled2 = fill_region(fillRegion, im, plans(1));

im(ind1) = filled1(ind1);
im(ind2) = filled2(ind2);

figure; imshow(im);

cord_points_region = find(components == 4);
fillRegion = zeros(size(im));
fillRegion(cord_points_region) = 1.0;

% Since we do not have a good segmentation algorithm
% We label the region around each hole manually.
% We load here the region for the bottom right hole.
plan = load_plan(im, 'plan3-3.png');
% We have only one plan, so no need to separate the region, fill it
filled3 = fill_region(fillRegion, im, plan);
im(cord_points_region) = filled3(cord_points_region);

cord_points_region = find(components == 5);
fillRegion = zeros(size(im));
fillRegion(cord_points_region) = 1.0;


% Idem for the right region
plan = load_plan(im, 'plan4.png');
filled4 = fill_region(fillRegion, im, plan);
im(cord_points_region) = filled4(cord_points_region);

figure; imshow(im);

