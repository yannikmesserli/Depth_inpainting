function plan = load_plan(img, file_name)
	% Load a plan from a file: a black image with a green region.
	% 
	% it return a plane structure which is caracterize by 
	% a normal vector and a constant d
	
	
	% The computation is done by observing that n =  a x b
	% where a and b are two vectors in the plane
	% there is a simple way to get a and b; vectors
	% [1 0 dx] and [1 0 dy] are two vectors orthogonal in the plane
	
	
	region_img = im2double(imread(file_name));
	cord_points_region = find(region_img(:,:,2) > 0.0); % Green channel
	plan.points = cord_points_region;
	
	[x y]=ind2sub(size(img), cord_points_region);
	
	% The z cordinate is simply the gray level of the image
	z = reshape(img(cord_points_region),length(cord_points_region),1);
	
	% Compute the gradient to get dx and dy
	[Ix Iy] = gradient(img);
	dx = Ix(cord_points_region);
	dy = Iy(cord_points_region);
	% Computation of the constant d
	d = dx.*y + dy.*x - z;
			
	
	% Concatenate everything in a nice vector. 		
	plan.n = [-mean(dx) -mean(dy) 1 mean(d)];	
	
	
end