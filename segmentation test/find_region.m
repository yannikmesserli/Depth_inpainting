function plans = find_region(img, fillRegion, nbPlan)
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
    
    gradient_stregth = 10;
    gradient_stregth2 = 10;
    region_search_sz = 30; % The size of the window we are looking around 
                           % the region to be filled, to find region
    erosion_stregth = 10; % By tuning this parameter, we keep more or less regions
    dilation_stregnth = 6;
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
    [Ix Iy] = gradient(img,gradient_stregth);
    % Second Deritative
    G2 = del2(img, gradient_stregth2);
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
        points(i:(i-1)+sz1*sz2, 1:4) = [imgvect 10*dxvect 10*dyvect 5*gvect];
        cord_points(i:(i-1)+sz1*sz2) = Hp;
        %Update the patch added
        patches_added(Hp) = 1;
        % Update iterator
        i = i+(sz1*sz2);
    end
    
    % Show region found:
    tmp = img;
    tmp(cord_points) = 1.0;
    test(:,:,1) = tmp; test(:,:,2) = img; test(:,:,3) = img;
    figure; imshow(test);
    
    % Find the region amoung those point
    [pixel_labels cluster_center] = kmeans(points, nbPlan, 'emptyaction', 'drop', 'onlinephase', 'on');
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
    
    for i = 1:1:nbPlan;
        
        
        
        cord_of_region = find(pixel_labels == i);
        %[cordx cordy] = ind2sub([nCol nRow], cord_points(cord_of_region));
        region = zeros(size(img));
        region(cord_points(cord_of_region)) = 1.0;
        se = strel('disk',erosion_stregth);    
        region = imerode(region,se);

        
        if find(region > 0.0)
            se = strel('disk',dilation_stregnth); 
            region = imdilate(region, se);
            
            % Find closed component
            [components nbComp] = bwlabeln(region);
            
            for j = 1:nbComp;
                cord_points_region = find(components == j);
                
                nbPlan_find = nbPlan_find+1;
                all_cord(currSz+1:currSz+length(cord_points_region)) = cord_points_region;
                currSz = currSz+length(cord_points_region);
                
                tmp1(cord_points_region) = colors(nbPlan_find,1);
                tmp2(cord_points_region) = colors(nbPlan_find,2);
                tmp3(cord_points_region) = colors(nbPlan_find,3);
                           
               
                plans(nbPlan_find).meanValue = mean(mean(img(cord_points_region)));
                plans(nbPlan_find).dx = mean(mean(Ix(cord_points_region)));
                plans(nbPlan_find).dy = mean(mean(Iy(cord_points_region)));
                plans(nbPlan_find).size = bwarea(region)./length(cord_points);
                [x_ind, y_ind] = ind2sub([nCol nRow], cord_points_region);
                plans(nbPlan_find).center = [round(mean(x_ind)) round(mean(y_ind))];
                plans(nbPlan_find).point = cord_points_region;
            end
       end
       
       
       %img(ind) = plans(i).meanValue;
       
    end
    
    tmp = img;
    tmp(all_cord) = 0.0;
    img2(:,:,1) = tmp+tmp1; img2(:,:,2) = tmp+tmp2; img2(:,:,3)= tmp + tmp3;
    figure; imshow(img2);

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
