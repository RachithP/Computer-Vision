CANNY EDGE DETECTOR...

Hey there folks! 

This is my interpretation and implementation of canny edge detector. Hope you enjoy it!
NOTE: One must know how this algorithm works theoretically before trying to understand this code!!

There are 4 matlab files.

1. cannyEdgeDetector.m
2. computeAngle.m
3. nonMaximalSupression.m
4. hystericalThresholding.m

The details on the usage and understanding of the first 3 files is provided within the code.

That being said, the main idea behind the 4th file is to link pixels which are considered weak i.e gradient-magnitude < upper-threshold and gradient-magnitude > lower-threshold, and connect them to a strong pixel i.e. pixel whose gradient-magnitude > upper-threshold in the vicinity along the direction of the edge. This connection happens if and only if ( iff ), the strong pixel and the weak pixel are neighbours and both of them have the same gradient direction. The loop is repeated until all the changes are done i.e. all the linking is done. This is marked by a tracker 'iter'. 

For detailed understanding, refer http://aishack.in/tutorials/implementing-canny-edges-scratch/.


