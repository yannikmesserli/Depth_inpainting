function plans = findplan3(image, nbPlan)


    %Function that find plan of an image

    %Define number of plan we want

    [nCol nRow] = size(image);

    %nbPlan = 4; %starting by distinguish background to front

    h=fspecial('disk',4);

    image = filter2(h,image);

    se = strel('disk',2);

    image = imerode(image,se);

   

    % First Deritative

    [Ix Iy] = gradient(image);

    G = sqrt(Ix.^2+Iy.^2);

    

    % Second Deritative

    G2 = del2(image);

    h=fspecial('disk',4);

    G2 = filter2(h,G2);

    imagevector = reshape(image,nCol*nRow,1);

    Gvector = reshape(G,nCol*nRow,1);

    G2vector = reshape(G2,nCol*nRow,1);

    

    % Il faut encore mettre ici la distance euclidienne du centre pour trouver 

    % que les points qui sont localement au m?me endroit.

    Gvector2 = Gvector;

    findDerivsmall = find(abs(Gvector)<0.00025);

    findDerivBig = find(abs(Gvector)>max(max(Gvector))/10);

    Gvector2 = 1000*Gvector2;

    Gvector2(findDerivBig) = 0;

    Gvector2(findDerivsmall) = 0;

    %imagevector2(findDeriv) = 0;

    

    pointDeriv = [3*imagevector Gvector2 500*G2vector];

    

    

    [cluster_idx cluster_center] = kmeans(pointDeriv,nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');

    

 

    pixel_labels = reshape(cluster_idx,nCol,nRow);

    

 

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
    

    


 

end


