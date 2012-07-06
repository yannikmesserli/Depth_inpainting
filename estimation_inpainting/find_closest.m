function plan_no = find_closest(fillRegion, img, plans)
	fillRegion = im2double(fillRegion);

	ind = find(fillRegion > 0);
	img(ind) = 0;
	sz = size(img);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	score = zeros(length(plans),1);
	[Rx Ry] = ind2sub(sz, ind);

	% Take some samples inside the fill region:
	random_ind1 = randperm(length(ind));
	random_ind1 = random_ind1(1:30);

	for i=1:length(plans)


	   % Take some samples inside the region:
	   random_ind2 = randperm(length(plans(i).points));
	   random_ind2 = random_ind2(1:30);
	   [cordx cordy] = ind2sub(sz, plans(i).points(random_ind2 ));
	   % For each point in the fill region, find the closest points in the plan
	   k = dsearchn([cordx cordy], [Rx(random_ind1) Ry(random_ind1) ]);

	   score(i) = mean(  1./sqrt( (Rx(random_ind1)-cordx(k)).^2 + (Ry(random_ind1)-cordy(k)).^2)...
	   	 .* exp(-img( plans(i).points(random_ind2 ) ) )  );

	end
	[maxV indM] = max(score);
	plan_no = indM;
end