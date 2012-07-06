function plans = findplan2(image)
    %Function that find plan of an image
    %Define number of plan we want
    [nCol nRow] = size(image);
    nbPlan = 5; %starting by distinguish background to front
    
    % First Deritative
    blur_h = fspecial('gaussian', [10 10], 10);
    blurredI = conv2(image, blur_h, 'same');
    [Ix Iy] = gradient(blurredI, 10);
    %G = sqrt(Ix.^2+Iy.^2);
    %ind = find(G > max(max(G))/2  );
    %G(ind) = 0;
    %G = (G./max(max(G)))*2;
    
    imagevector = reshape(image,nCol*nRow,1);
    Gxvector = reshape(Ix,nCol*nRow,1);
    Gyvector = reshape(Iy,nCol*nRow,1);
    point = [imagevector Gxvector Gyvector];
    
    
    [cluster_idx cluster_center] = kmeans(point,nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
    pixel_labels = reshape(cluster_idx,nCol,nRow);
    
    %pixel_labels = pixel_labels./max(max(pixel_labels));
    %image(pixel_labels ~= 1) = 0;
    %figure; imshow(pixel_labels, []);
    
    
    for i = 1:1:nbPlan;
       plans(i).meanValue = mean(mean(image(find(pixel_labels == i) )));
       plans(i).dx = mean(mean(Ix(find(pixel_labels == i) )));
       plans(i).dy = mean(mean(Iy(find(pixel_labels == i) )));
       ind = find(pixel_labels == i);
       [x_ind, y_ind] = ind2sub([nCol nRow], ind);
       plans(i).center = [round(mean(x_ind)) round(mean(y_ind))];
       plans(i).point = ind;
       %image(ind) = plans(i).meanValue;
       
    end
    
    %figure; imshow(image);
end