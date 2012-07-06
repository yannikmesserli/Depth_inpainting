function filledImage = fillImage(imgFilename,fillFilename,fillColor)
close all;

[img,fillRegion] = loadimgs(imgFilename,fillFilename,fillColor);
nbValue = length(find(fillRegion>0));
fillRegion = im2double(fillRegion);
sourceRegion = ~fillRegion;
frontmask = findFBGround(img);
img = im2double(img);
figure;imshow(frontmask);
[Gx Gy] = gradient(img);
img=img.*sourceRegion;
imshow(img);


while any(fillRegion(:))
outsideBorder = getClosest(img,frontmask,fillRegion,1,0);
insideBorder = getClosest(img,frontmask,fillRegion,0,1);
figure(1); imshow(outsideBorder);
figure(2);imshow(insideBorder);
maskborderOut = find(outsideBorder == 0);
maskborderIn = find(insideBorder == 0);

[img fillRegion] = fillInsideBorder(maskborderOut,maskborderIn,Gx,Gy,img,fillRegion);
figure(5); imshow(img);
% image = im2double(image);
% sourceRegion =~fillRegion;
end


end





%---------------------------------------------------------------------
% Loads the an image and it's fill region, using 'fillColor' as a marker
% value for knowing which pixels are to be filled.
%---------------------------------------------------------------------
function [img,fillRegion] = loadimgs(imgFilename,fillFilename,fillColor)
img = rgb2gray(imread(imgFilename)); fillImg = im2double(imread(fillFilename));
fillRegion = fillImg(:,:,1)==fillColor(1) & ...
    fillImg(:,:,2)==fillColor(2) & ...
    fillImg(:,:,3)==fillColor(3);

end

%---------------------------------------------------------------------
% Returns the indices for a 2w+1x2w+1 patch centered at pixel p.
%---------------------------------------------------------------------
function [Hp,rows,cols] = getpatch(sz,p, w)
% [x,y] = ind2sub(sz,p);  % 2*w+1 == the patch size
p = p-1; y=floor(p/sz(1))+1; p=rem(p,sz(1)); x=floor(p)+1;
rows = max(x-w,1):min(x+w,sz(1));
cols = (max(y-w,1):min(y+w,sz(2)))';
Hp = sub2ndx(rows,cols,sz(1));
end

%---------------------------------------------------------------------
% Converts the (rows,cols) subscript-style indices to Matlab index-style
% indices.  Unforunately, 'sub2ind' cannot be used for this.
%---------------------------------------------------------------------
function N = sub2ndx(rows,cols,nTotalRows)
X = rows(ones(length(cols),1),:);
Y = cols(:,ones(1,length(rows)));
N = X+(Y-1)*nTotalRows;
end

function [img fillRegion] = fillInsideBorder(maskborderOut,maskborderIn,Gx,Gy,img,fillRegion)
%fill the inside border
sz = size(img);
sizeOutside = length(maskborderOut);
sizeInside = length(maskborderIn);
for j=1:sizeInside
    [patch] = getpatch(sz,j,5);
    [row col] = size(patch);
    a=1;
%     for k=1:row*col
%     findPoint = find(maskborderOut == patch(k));
%  
%     if(length(findPoint)>0)
%         findPoint(a) = patch(k);
%         a=a+1;
%     end
%     end
    for k =1:size(maskborderOut);
         z(k)=abs(maskborderOut(k)-maskborderIn(j));
         end
     minV = min(z);
     findV = find(z==minV);
    consideredPoint = maskborderOut(findV(1))
    p_value = fillWithGradient('', img(consideredPoint), Gx(consideredPoint), Gy(consideredPoint),1, 1);
    p_value
    img(maskborderIn(j)) = p_value;
    fillRegion(maskborderIn(j)) = 0;
    figure(10);imshow(img);
end


end

function p = fillWithGradient(mask, img, d1x, d1y, dx, dy)
    
    % second deritative: mask.*img.*img.*d2
   
    
    p = img + d1x*dx + d1y*dy;
   

end