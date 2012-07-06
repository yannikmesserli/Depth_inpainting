function img = crimi_modif(imgFilename,fillFilename,fillColor)

    
[img,fillRegion] = loadimgs(imgFilename,fillFilename,fillColor);


sz = [size(img,1) size(img,2)];
sourceRegion = ~fillRegion;

% Priorities is computed by looking if we are in the
% first plan or second plan.
% 
% We know that high value means near plan

C = zeros(sz);

% Compute the gradient of our image
[Ix Iy] = gradient(img);
I2 = del2(img(:,:));
%temp = Ix; Ix = -Iy; Iy = temp;  % Rotate gradient 90 degrees

img = img.*sourceRegion;


D = repmat(-.1,sz);
%ind =  find(fillRegion(:) == 1 );
while any(fillRegion(:))
  % Find contour & normalized gradients of fill region
    fillRegion = im2double(fillRegion);
    
    dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);

    % Find priorities along the border:
     
     
     [Nx,Ny] = gradient(fillRegion);
     N = [Nx(dR(:)) Ny(dR(:))];
     N = normr(N);  
     N(~isfinite(N))=0;
     
     for k=dR'
       %if C(k) == 0
            Hp = getpatch(sz,k,5);
            q = Hp(~(fillRegion(Hp)));
            C(k) = (C(k)/2 + confident(img(q)));
            forground_color = 0.9;
            if ( numel(find(img(q) > forground_color)) ) > 0
                C(k) = confident(img(q));
            end
        %end
      end
    
    D(dR) = Ix(dR).*N(:,1)+Iy(dR).*N(:,2) + 0.0001;
    
    priorities = C(dR).* D(dR);
    
    
    [unused,ndx] = max(priorities(:));
    p = dR(ndx(1));
    
    
  %p = [rows, cols, 1];
    [indPatch,rows,cols] = getpatch(sz,p,4);
    indPatch = indPatch(~(fillRegion(indPatch)));
    [indPatch2,rows,cols] = getpatch(sz,p,1);
    indPatch2 = indPatch2(~(sourceRegion(indPatch2)));
    
  %value_p = fillWithGradient(sourceRegion(indPatch), img(indPatch), Ix(indPatch), Iy(indPatch), I2(indPatch));
  
  % Update fill region
  [nx,ny] = gradient(fillRegion);
  q = indPatch2(1);
  %[q dx dy] = newPoint(p, nx(p), ny(p), sz, sourceRegion)
  value_p = fillWithGradient(sourceRegion(p), img(p), Ix(p), Iy(p), 1, 1);
  fillRegion(q) = 0;
  sourceRegion(q) = 1;
    
  C(q) = (exp(-value_p^2) * C(p));
  %figure(1); imshow(fillRegion);
  % Copy image data from Hq to Hp
  
  img(q) = value_p;
  
  tmp = img; tmp(p) = 1; imt(:,:,1) = tmp;
  tmp = img; tmp(q) = 1; imt(:,:,2) = tmp;
  imt(:,:,3) = img;
  figure(1); imshow(imt)
 

end

 
 %figure; imshow(Iy)
 %figure; imshow(I2)
end

function [q dx dy] = newPoint(p, nx, ny, sz, mask)
    p=p-1;y=floor(p/sz(1))+1; p=rem(p,sz(1)); x=floor(p)+1;
    if sign(ny)== 0 && sign(nx)==0
        [indPatch, rows, cols] = getpatch(sz, p, 1);
        q = indPatch(~(mask(indPatch)));
        %q = indPatch(1);
        d=q-1;y1=floor(d/sz(1))+1; d=rem(d,sz(1)); x1=floor(d)+1;
        dy = y1 - y;
        dx = x1 - x;
       
    else
         y1 = y + sign(ny);
        x1 = x + sign(nx);
        dy = y1 - y;
         dx = x1 - x;
        q = y1*sz(1) + x1;
    end
   
    
    
end

function p = fillWithGradient(mask, img, d1x, d1y, dx, dy)
    
    % second deritative: mask.*img.*img.*d2
   
    
    p = img -   d1x*dx - d1y*dy;
   

end


function p = confident(patch)

    % the confident interval is based
    % on a distinction between first plan
    % and last plan, so the grayscale


    p = exp( -mean( patch ));


end



%---------------------------------------------------------------------
% Loads the an image and it's fill region, using 'fillColor' as a marker
% value for knowing which pixels are to be filled.
%---------------------------------------------------------------------
function [img,fillRegion] = loadimgs(imgFilename,fillFilename,fillColor)
img = im2double(rgb2gray(imread(imgFilename))); fillImg = im2double(imread(fillFilename));
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