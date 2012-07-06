clear all;
close all;

img = rgb2gray(im2double(imread('test1.jpg')));
mask = im2double(imread('mask.png'));
fillRegion = mask(:,:,2)==1; % green color
img(fillRegion > 0) = 0.0;

%plans = findplan(img);
plans = find_region(img, fillRegion, 5);
score = find_closest2(fillRegion, img, plans);
%closest_ind = find_closest(fillRegion, img, plans);
%test2 = img;
%test2(plans(closest_ind).point) = 1;
%figure; imshow(test2);

final_img = fill_region2(fillRegion, img, score, plans);
figure; imshow(final_img);