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


function  find_region_all(img, fillRegion)
	% Find_region finds ergions around the fill region with the k-means
	% and split the fill region with respect to the region found. 

	%---------------------------------------------------------------------
	% COMMENTS
	%	We did a lot of different test for a good segmentation  and here
	%  	a simple version without anything else
	%---------------------------------------------------------------------

	% Parameters:
	[nCol nRow] = size(img);
	fillRegion = im2double(fillRegion);
	% Degrade image by removing values of the fill Region.
	img(fillRegion > 0) = 0;



	% Cordonnee des points trouves
	cord_points = find(fillRegion < 1.0);
	% deritatives
	[dx dy] = gradient(img);
	%dx(dx == 0) = 1.0;
	%dy(dy == 0) = 1.0;
	%dx = abs(log(abs(dx))).*sign(dx);
	%dy = abs(log(abs(dy))).*sign(dy);


	% Looking for the normal vector at each point
	[x y] = ind2sub(size(img), cord_points);
	% Computing the value of d
	d = dx(cord_points).*y + dy(cord_points).*x - img(cord_points);
	points = [-dx(cord_points) -dy(cord_points) d x/(nCol*nRow) y/(nCol*nRow)]; %

	% Estimate the number of plan
	%variance = var( points(:,1))+var( points(:,2));
	nbPlan = 10;

	% Find the region amoung those points
	[pixel_labels cluster_center] = kmeans(points, nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
	plan_label = zeros(nCol, nRow);
	cluster_center
	%cluster_center = cluster_center(~isnan(cluster_center));
	%cluster_center = reshape(cluster_center, length(cluster_center)/4, 4);
	plan_label(cord_points) = pixel_labels;


	figure; imagesc(plan_label);

 end

