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

% we estimate here the the view of the camera 2 from the camera 1

clear all;
close all;
load paramBallet.mat
cfg.videoType = 1; % Who knows why...

camParam.MinZ = 43.0;
camParam.MaxZ = 130.0;

camParam.IntrRef = Intr(:,:,1);
camParam.ExtrRef = Extr(:,:,1);

camParam.IntrTar= Intr(:,:,2); 
camParam.ExtrTar = Extr(:,:,2);

Idepth = rgb2gray((imread('../../data/ballet/depth/cam0/depth-cam0-f000.bmp')));
%ImC = rgb2gray(im2double(imread('../../data/ballet/color/cam0/color-cam0-f000.bmp')));
ImC = im2double(Idepth);

[result_im mask dispt] = generateEstimation(cfg, ImC, Idepth, camParam);
imshow(result_im);