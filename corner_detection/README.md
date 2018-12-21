HARRIS CORNER DETECTION

Corner detection is a crucial process in Computer Vision. The corners are regions of large variations in intensity in the neighborhood of the point(pixel) in all directions. Thus, these are very good features to match between similar images.

This code is an example of Harris corner detection algorithm. I have included the code to compare the results with MATLAB's inbuilt harris corner detection algorithm.

NOTE: Remember to smoothen the image using a Gaussian filter before preocessing it.
The alogithm consists of following steps:
1. Smoothen image using a Gaussian filter.
2. Define Filters to take derivatives (Prewitt, or Sobel).
3. Compute Gradient (derivatives) along x,y direction.
4. Compute the corner response measure for each pixel and compare it with a threshold value to categorize it as a corner/not a corner.
5. In order to get a clear output image, local maxima supression is implemented. In a 8-link window around each pixel classfied as corner in previous step, only the pixel with highest pixel intensity is chosen as a corner, others are suppressed to zero intensity.




