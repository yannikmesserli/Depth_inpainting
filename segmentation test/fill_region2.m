function [ img_out ] = fill_region( fillRegion, img, score, plans )
%FILL_REGION fills the hole with the value of the closest point
%   Detailed explanation goes here
fillRegion = im2double(fillRegion);
ind = find(fillRegion == 1);
[x y]=ind2sub(size(img), ind);
img_out = zeros(size(img));
for i=1:length(plans);
    dx = x - plans(i).center(1);
    dy = y - plans(i).center(2);
    img_out(ind) = img_out(ind)+ score(:,i).* fillWithGradient(plans(i).meanValue, plans(i).dx, plans(i).dy, dx, dy) ;
    
end
img_out = img_out+img;

% Walk around the border and smooth where there is difference... 
%%%%%%%%%%%%%%% SMOOTHING %%%%%%%%%%%%%%%
dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);
[Rx Ry]=ind2sub(size(img), ind);

for i=1:length(plans);
for j=1:length(dR);
        
        %dRx = Rx(j) - plans(i).center(1);
        %dRy = Ry(j) - plans(i).center(2);
        %dx = x - dRx;
        %dy = y - dRy;
        %smooth_map = zeros(size(score(:,i)));
        %smooth_map = score(:,i) ;
        %img_out(ind) = (1-smooth_map).*img_out(ind)   +    smooth_map.*img(Rx(j), Ry(j));
        blurSize = 6;
        h = fspecial('disk',blurSize);
        p = getpatch(size(img), dR(j), 2*blurSize+1);
        p2 = getpatch(size(img), dR(j), blurSize);
        ind_inside = p2((fillRegion(p2))>0);
        
        blurredP = conv2(img_out(p), h, 'valid');
        
        dRx = Rx(j) - plans(i).center(1);
        dRy = Ry(j) - plans(i).center(2);
        delta = mean(mean(score(:,i)))./(abs(dRx)+abs(dRy));
        
        img_out(ind_inside) = (1-delta).*img_out(ind_inside)+delta.*blurredP((fillRegion(p2))>0);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

function p = fillWithGradient(value, d1x, d1y, dx, dy)
    
    % second deritative: mask.*img.*img.*d2
    p = value - d1x.*dx - d1y*dy;
   

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