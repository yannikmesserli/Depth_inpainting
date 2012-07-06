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

function  find_region_patch(img, fillRegion)
	% Find_region finds ergions around the fill region with the k-means
	% and split the fill region with respect to the region found. 

	%---------------------------------------------------------------------
	% COMMENTS
	%
	% To have accurate results, we must play with the number of regions
	% we want to find (warning, heavily time consuming)
	% And the size of the element strel for the dilatation and
	% erosion.
	% Thus we could have small homogenous regions
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

	% The cluster from which we will find the region. 
	points = zeros(3,4); % stupid initialisation
	% stupid iterator variable
	i = 1;
	% Cordonnee des points trouves
	cord_points = zeros(1,1);
	

	for k=dR'

		Hp = getpatch([nCol nRow],k,30);
		Hp = Hp(~(patches_added(Hp))); %take all the point around the fill region which are not yet in the cluster

		[sz1 sz2] = size(Hp);
		
		h = fspecial('gaussian', [5 5], 2);
		imgvect = conv2(img(Hp), h, 'same');
		imgvect = reshape(img(Hp),sz1*sz2,1);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Looking for the normal vector at each point
		normalVect = zeros(1);
		for j=1:sz1*sz2
			[x_center y_center] = ind2sub(size(img),Hp(j));
			coord_center = [x_center y_center img(Hp(j))]';
			Hps = getpatch([nCol nRow],Hp(j),1);
			%subCenter = sub2ind(size(Hps),x_center,y_center);
	
			Hps = Hps(~(fillRegion(Hps)));
			Hps = Hps(find(Hps ~= Hp(j)));
			[psz1 psz2] = size(Hps);
	
		    Hps = reshape(Hps,psz1*psz2,1);
		    [x y] = ind2sub(size(img),Hps);
		    normals = cross([x y img(Hps) ], repmat(coord_center, 1, length(Hps))');
		    normals = normr(normals);
		    normalVect(1:3,j) = mean(normals);
		    d = normalVect(1:3,j)'*coord_center;
		    normalVect(4,j) = -d;
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
		points(i:(i-1)+sz1*sz2, 1:4) = normalVect';
		cord_points(i:(i-1)+sz1*sz2) = Hp;
		%Update the patch added
		patches_added(Hp) = 1;
		% Update iterator
		i = i+(sz1*sz2);
	end


	% Estimate the number of plan
	variance = var( points(:,1))+var( points(:,2));
	nbPlan = 8;

	% Find the region amoung those points
	[pixel_labels cluster_center] = kmeans(points, nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
	plan_label = zeros(nCol, nRow);
	cluster_center = cluster_center(~isnan(cluster_center));
	cluster_center = reshape(cluster_center, length(cluster_center)/4, 4);
	
	% x y z of all points
	[x y] = ind2sub(size(img), cord_points);

	point2(1, 1:length(cord_points)) = x;
	point2(2, 1:length(cord_points)) = y;
	point2(3, 1:length(cord_points)) = img(cord_points);
	point2(4, 1:length(cord_points)) = ones(1, length(cord_points));
	for i = 1:length(cluster_center);
		labels(i,:) = cluster_center(i,:)*point2;
	end
	[mindd ind_min] = min(abs(labels));
	plan_label(cord_points) = ind_min;
	
	figure; imagesc(plan_label);

 end

