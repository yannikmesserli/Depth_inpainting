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
%	Code freely taken from Sooraj Bhat		%
%				and modified				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  find_region(img, fillRegion)
	% Find_region finds ergions around the fill region with the k-means
	% and split the fill region with respect to the region found. 

	%---------------------------------------------------------------------
	% COMMENTS
	%
	% 
	%---------------------------------------------------------------------

	% Parameters:
	[nCol nRow] = size(img);
	fillRegion = im2double(fillRegion);
	% Degrade image by removing values of the fill Region.
	img(fillRegion > 0) = 0;


	% Register all point we already have in our cluster
	% Starting with point inside the fillRegion because
	% We don't want them.
	patches_added = fillRegion;


	% Our border:
	dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);

	% stupid iterator variable
	i = 1;
	% Cordonnee des points trouves
	cord_points = zeros(1,1);
	
	% deritatives
	[dx dy] = gradient(img);
	%dx(dx == 0) = 1.0;
	%dy(dy == 0) = 1.0;
	%dx = abs(log(abs(dx))).*sign(dx);
	%dy = abs(log(abs(dy))).*sign(dy);

	for k=dR'
		Hp = getpatch([nCol nRow],k,30);
		Hp = Hp(~(patches_added(Hp))); %take all the point around the fill region which are not yet in the cluster
		[sz1 sz2] = size(Hp);
		cord_points(i:(i-1)+sz1*sz2) = Hp;
		%Update the patch added
		patches_added(Hp) = 1;
		% Update iterator
		i = i+(sz1*sz2);
	end
	

	% Looking for the normal vector at each point
	vector_size = length(cord_points)
	[x y] = ind2sub(size(img), cord_points);
	% Computing the value of d
	d = dx(cord_points).*x + dy(cord_points).*y - img(cord_points);
	points = [-dx(cord_points); -dy(cord_points); d];

	% Estimate the number of plan
	variance = var( points(:,1))+var( points(:,2));
	nbPlan = 12;

	% Find the region amoung those points
	[pixel_labels cluster_center] = kmeans(points', nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
	plan_label = zeros(nCol, nRow);
	cluster_center
	%cluster_center = cluster_center(~isnan(cluster_center));
	%cluster_center = reshape(cluster_center, length(cluster_center)/4, 4);
	plan_label(cord_points) = pixel_labels;
	
	
	figure; imagesc(plan_label);

 end

