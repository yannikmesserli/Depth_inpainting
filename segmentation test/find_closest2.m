function score = find_closest(fillRegion, img, plans)
	fillRegion = im2double(fillRegion);
	img(fillRegion > 0) = 0;
	sz = size(img);
	%dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);
	%[dRx dRy] = ind2sub(sz, dR);
	ind = find(fillRegion > 0);
	score_pix = zeros(length(ind), length(plans));
	[dRx dRy] = ind2sub(sz, ind);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% PARAMETERS TO TUNE:
	distStrength = 1.0; % The strength of the distance
	sizeMatter = 1/2.6; % The influence of the size of a region
	background_limiter = 0.9; % To avoid to take into an account the first plans
	transition_treshold = 0.76; % limit of the influence of a region and another
								% determine the overlap region ( = 0.0 no overlap, 
								% 1.0 always taken into acount)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% For Test
	colors = [  1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0; 1.0 1.0 0.0;
	    		0.0 1.0 1.0; 1.0 0.0 1.0; 1.0 0.5 0.0; 0.5 1.0 0.0;
	    		0.5 0.0 0.0; 0.0 0.5 0.0; 0.0 0.0 0.5; 0.5 0.5 0.0;
    			0.0 1.0 1.0; 1.0 0.0 1.0; 1.0 0.5 0.0; 0.5 1.0 0.0; ];
    
    tmp1 = zeros(size(img));
    tmp2 = zeros(size(img));
    tmp3 = zeros(size(img));
    maxval = 0.0;
    minval = 1000000;
    for i=1:length(plans)
	    if maxval < plans(i).meanValue
	    	maxval =plans(i).meanValue;
	    end
	    if minval > plans(i).meanValue
	      	minval =plans(i).meanValue;
	    end 
	end
	    
	for i=1:length(plans)
	   
	   centerx = plans(i).center(1).*ones(length(ind),1);
	   centery = plans(i).center(2).*ones(length(ind),1);

	    if (plans(i).meanValue - minval)/(maxval-minval) < background_limiter
	   		score(:,i) = ((1./( abs(dRx-centerx) + abs(dRy-centery)).^distStrength) + plans(i).size.*sizeMatter);
	    else
		   	score(:,i) = zeros(length(ind),1);
		end
	   %score(:,i) = ( exp(-(plans(i).meanValue))).* (1./( abs(dRx-centerx) + abs(dRy-centery)));
	   
	   
	   
	   %score(i) = score(i);
	end
	
	score = score./repmat(sum(score')', 1, length(plans));
	[maxV indM] = max(score, [], 2);
	indM2 = find(maxV > transition_treshold);
	score(indM2, :) = 0.0;
	score(indM2, indM(indM2) ) = 1.0;
	%score(score < 0.3) = 0.0;
	%score(score > 0.7) = 1.0;
	%score = score./repmat(sum(score')', 1, length(plans));
	
	for i=1:length(plans)
		tmp1(ind) = tmp1(ind)+colors(i,1)*score(:,i);
		tmp2(ind) = tmp2(ind)+colors(i,2)*score(:,i);
		tmp3(ind) = tmp3(ind)+colors(i,3)*score(:,i);
	end
	
	img2(:,:,1) = img+tmp1; img2(:,:,2) = img+tmp2; img2(:,:,3)= img + tmp3;
	figure; imshow(img2);
end