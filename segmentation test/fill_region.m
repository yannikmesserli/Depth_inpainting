function [ img_out ] = fill_region( fillRegion, img, closest_plan )
%FILL_REGION fills the hole with the value of the closest point
%   Detailed explanation goes here
fillRegion = im2double(fillRegion);
ind = find(fillRegion == 1);
for i = 1:length(ind);
    [x y]=ind2sub(size(img), ind(i));
    dx = x - closest_plan.center(1);
    dy = y- closest_plan.center(2);
    img(x,y) = fillWithGradient(closest_plan.meanValue, closest_plan.dx, closest_plan.dy, dx, dy) ;
end
img_out = img;
end

function p = fillWithGradient(value, d1x, d1y, dx, dy)
    
    % second deritative: mask.*img.*img.*d2
   
    
    p = value - d1x*dx - d1y*dy;
   

end