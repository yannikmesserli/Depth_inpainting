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


function [region_labels nb_region_found] = sep_region(im, fillRegion, plans)
	% Separate the fill Region into multi parts using plans 
	% We do not check if there is an overlap...
	%
	%	Parameters:
	%	
	%	im: the image texture
	%	fillRegion: the hole of the image
	%	plans: a plane is caracterize by its normal: plans.n
	% 			(plan comes from french, sorry!)
	
	
	nb_plans = length(plans);
	[nCol nRow] = size(im);
	
	
	points_in_region = find(fillRegion > 0.0);
	[region_x region_y] = ind2sub(size(im), points_in_region);
	
	nb_region_found = 1;
	region_labels = zeros(size(im));

	labels = zeros(2,1);
	region_label = zeros(size(points_in_region));
	region_label_prev = zeros(size(points_in_region));
	
	region_labels(points_in_region) = 1.0;
	
	for i=1:nb_plans
		
		for j=1:nb_plans
		% Test all possibilities
		if i < j
			
			ind1 = randperm(length(plans(i).points));
			%ind2 = randn(1, length(plans(j).points));
			[x1 y1] = ind2sub(size(im),plans(i).points(ind1(1:30)));
			%[x2 y2] = ind2sub(plans(j).points(ind1(1:30)));
			
			
			% Ok, this is not the best technic, but is work as follow:
			
			% 1) we take some random points in the the first region.
			% 2) we find the closest points in the second region of those points
			% 3) we find the closest points in the first region of the points found in 2)
			% 4) then, we speparate with the line that is closer to the computed point
			
			[all_x1 all_y1] = ind2sub(size(im), plans(i).points);
			[all_x2 all_y2] = ind2sub(size(im),plans(j).points);
			
			% 1)
			closest1 = dsearchn([all_x2 all_y2], [x1 y1]);
			x2 = all_x2(closest1);
			y2 = all_y2(closest1);
			% 2) 
			closest2 = dsearchn([all_x1 all_y1], [x2 y2]);
			x1 = all_x1(closest2);
			y1 = all_y1(closest2);
			% 3) 
			dx = (x1 -x2);
			dy = (y1 -y2);

			if abs(dx) < 10 & abs(dy) < 10
				nb_region_found = nb_region_found+1;
				x = x1 + dx/2;
				y = y1 + dy/2;
				droite = [x ones(length(x),1)]\y;
				x = [1:nCol];
				y = round(droite(1).*x+droite(2));
				ind_point = find(y > 0 & y < nRow);
				x = x(ind_point);
				y = y(ind_point);
				% 4) 
				points_Droite = sub2ind(size(im), x,y);
				region_label = ceil((1+sign(droite(1).*region_x - region_y + droite(2)))/2); % region
				
				%intersection = ismember(points_in_region(region_label>0), region(k));
				
				%if mean(intersection) == 1.0 | mean(intersection) == 0.0 % intersection is somewhere outside
					%intersection = ismember(points_in_region(region_label>0), region_label_prev(region_label<1.0));
				
				% Label the points
				labels(:,nb_region_found) = [i j];
				region_labels(points_in_region) = region_labels(points_in_region) + region_label;
				
				
				
				% Show line
				if 0
					tmp = im;
					tmp(points_Droite) = 0.0;
					img2(:,:,3) = tmp;
					img2(:,:,2) = tmp;
					tmp(points_Droite) = 1.0; 
					img2(:,:,1)= tmp;
					figure; imshow(img2);
				end
					
			end
			
						
			
			
		end
		end
		
		
	end
	
	
	
end