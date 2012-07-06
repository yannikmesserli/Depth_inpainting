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

function [ img_out ] = fill_region( fillRegion, img, plan )
    %FILL_REGION fills the hole with the value of the closest point
    %
    %  	Parameters:
	%	
	%	img: the image texture
	%	fillRegion: the hole of the image
	%	plans: a plane is caracterize by its normal: plans.n
	% 			(plan comes from french, sorry!)
	
    fillRegion = im2double(fillRegion);
    img_out = img;

    ind = find(fillRegion == 1);
    [x y]=ind2sub(size(img), ind);

    % fill with the closest point
    img_out(ind) = fillWithGradient(plan.n,x,y);
    
    
end
    
function p = fillWithGradient(n,x,y)
     %  normal of the plane is n.  
        p = -(n(1).*y+n(2).*x+n(4))./n(3);
end