function [ img_out ] = fill_region( fillRegion, img, plan )
    %FILL_REGION fills the hole with the value of the closest point
    %   Detailed explanation goes here
    fillRegion = im2double(fillRegion);
    [Dx Dy] = gradient(img);


    img_out = img;

    ind = find(fillRegion == 1);
    [x y]=ind2sub(size(img), ind);
    
    region2 = zeros(size(img));
    region2(plan.points) = 1.0;
    se = strel('disk', 14);
    region2 = imerode(region2, se);
    
    region2 = find(region2 > 0.0);
    
    ind_rand = randperm(length(region2));
    ref = region2(ind_rand(1:round(length(region2)/5)));
    
    [cx cy]=ind2sub(size(img), ref);
    
    k = dsearchn([cx cy], [x y]);
    % fill with the closest point
    
    img_out(ind) = fillWithGradient(img(ref(k)), Dx(ref(k)), Dy(ref(k)),  x-cx(k), y-cy(k));


end

function p = fillWithGradient(value, d1x, d1y, dy, dx)

    % second deritative: mask.*img.*img.*d2
    p = value + d1x.*dx + d1y.*dy;


end

function p = fillWithGradient2(value, d1x, d1y, dxx, dyy, dy, dx)

    % second deritative: mask.*img.*img.*d2
    p = value + d1x.*dx + d1y.*dy + dxx/2.*dx.^2 + dyy/2.*dy.^2;


end