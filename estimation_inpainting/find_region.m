function plans = find_region(img, fillRegion)
    % Find_region finds ergions around the fill region with the k-means
    % and split the fill region with respect to the region found. 

    %---------------------------------------------------------------------
    % COMMENTS
    %
    % To have accurate results, we must play with the number of regions
    % we want to find (warning, heavily time consuming)
    % And the size of the element strel for the dilatation and
    % erosion.
    % Thus we could have small homogenous regions
    % 
    %---------------------------------------------------------------------
    %    PARAMETERS TO TUNE
    
    gradient_stregth = 20;
    gradient_stregth2 = 10;
    region_search_sz = 50; % The size of the window we are looking around 
                           % the region to be filled, to find region
    erosion_stregth = 4; % By tuning this parameter, we keep more or less regions
    %---------------------------------------------------------------------
    
    
    %Define number of plan we want
    %nbPlan = 4; %starting by distinguish background to front
    
    [nCol nRow] = size(img);
    fillRegion = im2double(fillRegion);
    % Degrade image by removing values of the fill Region.
    img(fillRegion > 0) = 0;
    
    
    % Register all point we already have in our cluster
    % Starting with point inside the fillRegion because
    % We don't want them.
    patches_added = fillRegion;
    
    
    
    

    % First Deritative
    [Ix Iy] = gradient(img);
    Ix(Ix == 0) = 1.0;
    Iy(Iy == 0) = 1.0;
    Ix = abs(log(abs(Ix))).*sign(Iy);
    Iy = abs(log(abs(Iy))).*sign(Ix);
    % Second Deritative
    G2 = del2(img);
    % Our border:
    dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);
    
    % The cluster from which we will find the region. 
    points = zeros(3,4); % stupid initialisation
    % stupid iterator variable
    i = 1;
    % Cordonnee des points trouves
    cord_points = zeros(1,1);
    
    for k=dR'
        
        Hp = getpatch([nCol nRow],k,region_search_sz);
        Hp = Hp(~(patches_added(Hp))); %take all the point around the fill region which are not yet in the cluster
        
        [sz1 sz2] = size(Hp);
        imgvect = reshape(img(Hp),sz1*sz2,1);
        dxvect= reshape(Ix(Hp),sz1*sz2,1);
        dyvect = reshape(Iy(Hp),sz1*sz2,1);
        
        gvect = reshape(G2(Hp),sz1*sz2,1);
        [cx cy ] = ind2sub([nCol nRow], Hp);
        %points(i:(i-1)+sz1*sz2, 1:6) = [imgvect 20*dxvect 20*dyvect 5*gvect cx cy];
        points(i:(i-1)+sz1*sz2, 1:4) = [10*imgvect dxvect dyvect gvect];
        cord_points(i:(i-1)+sz1*sz2) = Hp;
        %Update the patch added
        patches_added(Hp) = 1;
        % Update iterator
        i = i+(sz1*sz2);
    end
    
    
    % Estimate the number of plan
    
    variance = var( points(:,1))+var( points(:,2));
    nbPlan = 3
    
    % Find the region amoung those point
    [pixel_labels cluster_center] = kmeans(points, nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
    [cordx cordy] = ind2sub(size(img), cord_points);
    [pixel_labels cluster_center] = kmeans([500*pixel_labels cordx' cordy'], 2, 'emptyaction', 'drop', 'onlinephase', 'on');
    %pixel_labels = reshape(cluster_idx,nCol,nRow);

     % For test puropose
    colors = [  1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0; 1.0 1.0 0.0;
                0.0 1.0 1.0; 1.0 0.0 1.0; 1.0 0.5 0.0; 0.5 1.0 0.0;
                0.5 0.0 0.0; 0.0 0.5 0.0; 0.0 0.0 0.5; 0.5 0.5 0.0;
                0.0 1.0 1.0; 1.0 0.0 1.0; 1.0 0.5 0.0; 0.5 1.0 0.0; ];
    
    %mask = patches_added-fillRegion;
    
    
    all_cord = zeros(1);
    tmp1 = zeros(size(img));
    tmp2 = zeros(size(img));
    tmp3 = zeros(size(img));
    
    nbPlan_find = 0;
    currSz = 0;
    
    [Ix Iy] = gradient(img);
        
    for i = 1:nbPlan;
        
        
        
        cord_of_region = find(pixel_labels == i);
        %[cordx cordy] = ind2sub([nCol nRow], cord_points(cord_of_region));
        region = zeros(size(img));
        region(cord_points(cord_of_region)) = 1.0;
        %se = strel('disk',3);    
        %region = imerode(region,se);
        region =im2double(region);
  
        if find(region > 0.0)
                nbPlan_find = nbPlan_find+1;
                cord_points_region = find(region > 0.0);

                all_cord(currSz+1:currSz+length(cord_points_region)) = cord_points_region;
                currSz = currSz+length(cord_points_region);
                
                
                % Cordonnee of our center of our plan. 
                [x_ind, y_ind] = ind2sub([nCol nRow], cord_points_region);

                centerx = round(median(x_ind));
                centery =  round(median(y_ind));
                                
                z_value = img(cord_points_region) - Ix(cord_points_region).*(x_ind-centerx) - Iy(cord_points_region).*(y_ind-centery);
                
                a_value = Ix(cord_points_region);
                
                b_value = Iy(cord_points_region);
                
                tmp1(cord_points_region) = colors(nbPlan_find,1);
                tmp2(cord_points_region) = colors(nbPlan_find,2);
                tmp3(cord_points_region) = colors(nbPlan_find,3);
                
                plans(nbPlan_find).center = [centerx centery];
                plans(nbPlan_find).meanValue = mean((z_value));
                plans(nbPlan_find).dx = median((a_value));
                plans(nbPlan_find).dy = median((b_value));
                plans(nbPlan_find).points = cord_points_region;
                
                
                
                
       end
   end
       
       %img(ind) = plans(i).meanValue;
           
    tmp = img;
    tmp(all_cord) = 0.0;
    img2(:,:,1) = tmp+tmp1; img2(:,:,2) = tmp+tmp2; img2(:,:,3)= tmp + tmp3;
    figure; imshow(img2);
    
 end
