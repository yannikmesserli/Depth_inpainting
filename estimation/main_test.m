%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%											%
%	IMAGE COMMUNICATION - EPFL COURSE		%
%				June 2012					%
%		Inpaiting of depth image			%
%											%
% Yannik Messerli: yannik.messerli@epfl.ch	%
% 	Nicolas Jorns: nicolas.jorns@epfl.ch	%
%											%
% 		Supervised by Thomas Maugey			%
%											%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here we want to estimate the point of view of a camera
% From the view point of a artificial scene done in
% Cinema 4D with different parameters
%
% For the seek of simplicity we used the parameter 
% of the camera of the ballet data 


clear all;
close all;

%

load paramBallet.mat 

cfg.videoType = 1; % Who knows why...

cfg.videoType = 1; % Who knows why...

camParam.MinZ = 43.0;
camParam.MaxZ = 400.0;

camParam.IntrRef = Intr(:,:,1);
camParam.ExtrRef = Extr(:,:,1);

camParam.IntrTar= Intr(:,:,2); 
camParam.ExtrTar = Extr(:,:,2);

Idepth = rgb2gray(imread('depth3_c4d.png'));
ImC = im2double(Idepth);

[result_im mask dispt] = generateEstimation(cfg, ImC, Idepth, camParam);

result_im(mask > 0) = 0.0;
imshow(result_im);