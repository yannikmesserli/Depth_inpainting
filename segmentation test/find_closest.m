function ind_closest = find_closest(fillRegion, img, plans)
    fillRegion = im2double(fillRegion);
    img(fillRegion > 0) = 0;
    sz = size(img);
    dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);
    %[dRx dRy] = ind2sub(sz, dR);
    score = zeros(length(plans),1);
 
    
    for i=1:length(plans)
%      is_in = false;
%        for j = 1:length(dR)
%            is_in = is_in || ~isempty( find( plans(i).point == dR(i)));
%        end
%       if(is_in) score(i) = 1/plans(i).meanValue
%       end
       [dRx dRy] = ind2sub(sz, dR);
       centerx = plans(i).center(1).*ones(length(dR),1);
       centery = plans(i).center(2).*ones(length(dR),1);
       
       score(i) = 1/mean( abs(dRx-centerx) + abs(dRy-centery));
       %score(i) = score(i);
    end
    ind_closest = find(score == max(score));
end