function [ img_out ] = fill_region( fillRegion, img, plan )
    %FILL_REGION fills the hole with the value of the closest point
    %   Detailed explanation goes here
    fillRegion = im2double(fillRegion);


    img_out = img;

    ind = find(fillRegion == 1);
    [x y]=ind2sub(size(img), ind);
    img_out(ind) = fillWithGradient(plan.n,x,y);


end

function p = fillWithGradient(n,x,y)
    
        
        p = -(n(1).*x+n(2).*y+n(4))./n(3);


end