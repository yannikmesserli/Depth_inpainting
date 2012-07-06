function plan = load_plan(img, i)
	
	
	[nCol nRow] = size(img);
	
	
	region_img = im2double(imread(['plan' int2str(i) '.png']));
	cord_points_region = find(region_img(:,:,2) > 0.0);
	
	[x y]=ind2sub(size(img), cord_points_region);
	
	z = reshape(img(cord_points_region),length(cord_points_region),1);
	[dx dy] = gradient(img);
	dx = dx(cord_points_region);
	dy = dy(cord_points_region);
	points = [z ones(length(cord_points_region), 1)];
	n_parse = points\(-dx.*x-dy.*y);
	
	n_parse
	
	plan.n = [mean(dx) mean(dy) n_parse(1) n_parse(2)];
	plan.points = cord_points_region;
					
					
	
end