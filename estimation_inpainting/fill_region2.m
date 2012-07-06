function [ img_out ] = fill_region( fillRegion, img, plan )
    %FILL_REGION fills the hole with the value of the closest point
    %   Detailed explanation goes here
    fillRegion = im2double(fillRegion);
    [Dx Dy] = gradient(img);


    img_out = img;

    ind = find(fillRegion == 1);
    [x y]=ind2sub(size(img), ind);
    cx = plan.center(1);
    cy = plan.center(2);
    % fill with the closest point
    img_out(ind) = fillWithGradient(plan.meanValue, plan.dx,plan.dy,  x-cx, y-cy);


end

function p = fillWithGradient(value, d1x, d1y, dy, dx)

    % second deritative: mask.*img.*img.*d2
    p = value + d1x.*dx + d1y.*dy;


end

function p = fillWithGradient2(value, d1x, d1y, dxx, dyy, dy, dx)

    % second deritative: mask.*img.*img.*d2
    p = value + d1x.*dx + d1y.*dy + dxx/2.*dx.^2 + dyy/2.*dy.^2;


end