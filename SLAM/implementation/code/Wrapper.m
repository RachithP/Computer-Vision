%% Wrapper for the CMSC426Course final project at University of Maryland, College Park

clc
clear
tic
%% Add ToolBox to Path
addpath('D:\UMD\Semester-I\CMSC426\Computer-Vision\SLAM\gtsam-toolbox-3.2.0-win64\gtsam_toolbox');
%% Load DataR

% Download data from the following link: 
% https://drive.google.com/open?id=1ZFXZEv4yWgaVDE1JD6-oYL2KQDypnEUU
load('data/DataSquareNew.mat');
load('data/CalibParams.mat');

%% SLAM Using GTSAM
SLAMusingGTSAM;
toc