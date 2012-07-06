function final_img = inpainting(img, mask)
	
	
	fillRegion = ~mask; % green color
	img(fillRegion > 0) = 0.0;
	
	plans = find_region(img, fillRegion);
	ind_highest = find_closest(fillRegion, img, plans);
	final_img = fill_region(fillRegion, img, plans(ind_highest));
	figure; imshow(final_img);
	
end