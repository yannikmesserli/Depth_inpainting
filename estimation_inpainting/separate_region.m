function separate_region(im, fillRegion)
	fillRegion = im2double(fillRegion);
	dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);
	
	[Ix Iy] = gradient(im, 10);
	
	[Nx Ny] = gradient(fillRegion);
	%N = [Nx(dR) Ny(dR)];
	%N = normr(N);  
	%N(~isfinite(N))=0;
	
	D = abs(Ix(dR).*Nx(dR)+Iy(dR).*Ny(dR));

	[maxd indm] = max(D)
	
	[cordx cordy]= ind2sub(size(im), dR(indm));
	im(cordx-2:cordx+2, cordy-2:cordy+2) = 0.0;
	im(dR) = 0.0;
	test(:,:,3) = im; 	im(dR) = 1.0; test(:,:,2) = im;
	im(dR) = 0.0;
	im(cordx-2:cordx+2, cordy-2:cordy+2) = 1.0;
	test(:,:,1) = im;
	figure; imshow(test);
	
	
	
end