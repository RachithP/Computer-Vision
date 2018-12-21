# Panaroma Stitching

Author: Rachith Prakash
Version: MATLAB 2018a.

This project is a MATLAB implementation of 2-D Panaroma Stitching. This is part of CMSC426 course at University of Maryland, College Park. 

Detailed explanation of this project is included in report.pdf. 

Project contains following files:

1. MyPanaroma.m -> Main file
2. ANMS.m -> Adaptive Non-Maximal Suppression algorithm to filter out non-maximal corner points.
3. featureDescriptor.m -> Generate features for each corners.
4. featureMatching.m -> Match extracted features between images.
5. applyRANSAC.m -> RANSAC algorithm to obtain matches that are large in number and similar to each other.
6. est_homography.m -> Homopgraphy estimation from matched features coordinates.
7. apply_homography.m -> apply homography obtained after RANSAC.
8. showMatchedFeatures.m -> Display matched features in impair 'montage' mode.



