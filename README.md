# Inpaiting of depth image
<center> IMAGE COMMUNICATION - EPFL COURSE </center>
<center> June 2012 </center>

---
## Author
* Yannik Messerli: yannik.messerli@epfl.ch
* Nicolas Jorns: nicolas.jorns@epfl.ch
* Supervised by Thomas Maugey

## Introduction

When estimating a camera view point
from a first camera, we offen use a depth map
for a better scene understanding.
Naturally occlusions occur
in both depth map and texture.

You'll find Matlab code lines produced during the mini-project during the course of Image communication done in EPFL. There is a lot of different tests and no final algorithm has been written but there is a lot of comments inside the files. 

## Files
The project is separated into different part with different tests

### Estimation of the view

The first thing is to estimate the view from the second camera. Everything is inside the 'estimation' folder

### Search for the different plane in the image

Then we must find the different plane around the holes. There is a lot of different tests for this part. Some comments and final tests can be found in the folder 'search for plane'.

### Find and split the region

Then we must split the hole with respect of the regions. 
It's 'multi-plan' folder.

### Test on specific image

'test_ball' is a artificial test on an image.

'test_baller' is a test on real depth images. 