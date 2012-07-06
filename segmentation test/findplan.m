function plans = findplan(image)
    %Function that find plan of an image
    %Define number of plan we want
    [nCol nRow] = size(image);
    nbPlan = 5; %starting by distinguish background to front
    
    % First Deritative
    blur_h = fspecial('gaussian', [10 10], 1);
    blurredI = conv2(image, blur_h, 'same');
    [Ix Iy] = gradient(blurredI, 10);
    G = sqrt(Ix.^2+Iy.^2);
    ind = find(G > max(max(G))/2  );
    G(ind) = 0;
    G = (G./max(max(G)))*2;
    %blur_h = fspecial('gaussian', [10 10], 10);
    %G = conv2(G, blur_h, 'same');
%     imshow(G);
%     pause;
%     close;
    
    % Each point is the 3x3 patch values around the point
    %
    size_of_patch = 1;
    patchsize = (2*size_of_patch+1);
    nbofpoint = (2*size_of_patch+1)^2;
    imagevector = zeros(nCol*nRow, nbofpoint);
    Gvector = zeros(nCol*nRow, nbofpoint);
    for i = 1:nCol*nRow
        indPatch = getpatch([nCol nRow], i, 1);
        patchI = zeros(patchsize,patchsize);
        patchG = zeros(patchsize,patchsize);
        patchI(1:size(indPatch,1), 1:size(indPatch,2)) = image(indPatch);
        patchG(1:size(indPatch,1), 1:size(indPatch,2)) = G(indPatch);
        imagevector(i,:) = reshape(patchI, nbofpoint, 1);
        Gvector(i,:) = reshape(patchG, nbofpoint, 1);        
    end
    
    
    % Second Deritative
    G2 = del2(image);
    %ind = find(G2 > 0.1);
    %G2(ind) = 0;
    G2 = G2./max(max(G2));
    
    %imagevector = reshape(image,nCol*nRow,1);
    %Gvector = reshape(G,nCol*nRow,1);
    G2vector = reshape(G2,nCol*nRow,1);
    
    % Il faut encore mettre ici la distance euclidienne du centre pour trouver 
    % que les points qui sont localement au m?me endroit.
    
    point = [imagevector Gvector G2vector];
    
    
    [cluster_idx cluster_center] = kmeans(point,nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
    pixel_labels = reshape(cluster_idx,nCol,nRow);
    
    pixel_labels = pixel_labels./max(max(pixel_labels));
    %image(pixel_labels ~= 1) = 0;
    figure; imshow(pixel_labels, []);
    
    
    
    
%     indP = find(G < 0.2 & G > 0);
%     indW = find(G== 0);
%     image(indW) = 0.5;
%     image(indP) = 1;
%     
%     figure, imshow(image);
    
%     
%     [junk threshold] = edge(image, 'sobel');
%     fudgeFactor = .5;
%     BWs = edge(image,'sobel', threshold * fudgeFactor);
%     
%     %se90 = strel('line', 3, 90);
%     %se0 = strel('line', 3, 0);
%     %BWsdil = imdilate(BWs, [se90 se0]);
%     
%     BWnobord = imclearborder(BWs, 4);
%     
%     
%     
%     bwtot = imfill(BWnobord)
%     
%     
%     figure, imshow(bwtot);
%     fprintf('ok')
    
    %image = reshape(image,nCol*nRow,1);
    
    %plans = bwtot;
    
    %[cluster_idx cluster_center] = kmeans(image,nbPlan);
    
    %pixel_labels = reshape(cluster_idx,nCol,nRow);
    
    %figure(2); imshow(pixel_labels,[])

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
