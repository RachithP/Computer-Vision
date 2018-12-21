# SLAM using GTSAM

**Author**: Rachith Prakash

__Contributor__ & __Maintainer__: Rachith Prakash

This project is an implementation of **SLAM**-*Simultaneous Localization and Mapping*, using GTSAM. It is done as part of CMSC426 course at University of Maryland, College Park.

## GTSAM toolbox installation instructions

I have already downloaded and unzipped folder of GTSAM toolbox. However, one can follow the following instructions to download and install on their own.

1. Download and unzip MATLAB precompiled gtsam-toolbox-3.2.0-win64.zip from [Borg Lab](https://borg.cc.gatech.edu/download.html).
2. Make sure you can run example files from the toolbox.
3. Make sure to add the toolbox home path along with subfolders while running any script that uses the toolbox.

## Code details

There are two datasets [here] (https://github.com/RachithP/Computer-Vision/tree/test/SLAM/implementation/code/data), one being a spiral path taken by the camera capturing [AprilTags](https://april.eecs.umich.edu/software/apriltag) and second being a square path. Details about the datasets and objective of the project can be found [here](https://cmsc426.github.io/2018/proj/p4).

The project includes the following files:

1. [Wrapper.m](https://github.com/RachithP/Computer-Vision/blob/test/SLAM/implementation/code/Wrapper.m)
2. [SLAMusingGTSAM.m](https://github.com/RachithP/Computer-Vision/blob/test/SLAM/implementation/code/SLAMusingGTSAM.m)
3. [estimateTransformations.m](https://github.com/RachithP/Computer-Vision/blob/test/SLAM/implementation/code/estimateTransformations.m)
4. [converToWorldCoordinates.m](https://github.com/RachithP/Computer-Vision/blob/test/SLAM/implementation/code/convertToWorldCoordinates.m)
5. [getX](https://github.com/RachithP/Computer-Vision/blob/test/SLAM/implementation/code/getX.m)


References: 
1. https://cmsc426.github.io/sfm
2. https://cmsc426.github.io/gtsam
3. https://smartech.gatech.edu/handle/1853/45226
