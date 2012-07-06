function plan = load_plan(img, i)
	
	
	[nCol nRow] = size(img);
	[Ix Iy] = gradient(img);
	[Ixx Iyx] = gradient(Ix);
	[Ixy Iyy] = gradient(Iy);
	
	region_img = im2double(imread(['plan' int2str(i) '.png']));
	cord_points_region = find(region_img(:,:,2) > 0.0);
	
	[x_ind, y_ind] = ind2sub([nCol nRow], cord_points_region);
	
	centerx = round(median(x_ind));
	centery =  round(median(y_ind));
					
	z_value = img(cord_points_region) - Ix(cord_points_region).*(x_ind-centerx) - Iy(cord_points_region).*(y_ind-centery);
	
	a_value = Ix(cord_points_region);
	
	b_value = Iy(cord_points_region);
	
	dxx_value = Ixx(cord_points_region);
	
	dyy_value = Iyy(cord_points_region);
	
	plan.center = [centerx centery];
	plan.meanValue = mean((z_value));
	plan.dx = mean((a_value));
	plan.dy = mean((b_value));
	plan.dxx = mean((dxx_value));
	plan.dyy = mean((dyy_value));
	plan.points = cord_points_region;
	
end