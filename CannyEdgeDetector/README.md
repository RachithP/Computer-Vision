Hey there folks! 

This is my interpretation and implementation of canny edge detector.

There are 4 matlab files.

1. cannyEdgeDetector.m
2. computeAngle.m
3. nonMaximalSupression.m
4. hystericalThresholding.m

The details on the usage and understanding is provided with the code in first 3 files.

For fourth file, one can refer to reference given below for detailed understanding. The code in the reference is in openCV.
That being said, the main idea behind the 4th file is to link pixels which are considered weak i.e gradient-magnitude < upper-threshold and gradient-magnitude > lower-threshold, and connect them to a strong pixel i.e. pixel whose gradient-magnitude > upper-threshold in the vicinity along the direction of the edge. This connection happens if and only if ( iff ), the strong pixel and the weak pixel are neighbours and both of them have the same gradient direction.




Reference:
http://aishack.in/tutorials/implementing-canny-edges-scratch/ for detailed understanding.
