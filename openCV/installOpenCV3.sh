#!/bin/sh

## Installing OpenCV 3.4.0

version=3.4.0

# sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove

# This is for compilers
echo "Install compiler dependent packages"
sudo apt-get install build-essential
sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev

# Extra packages - can choose what to install depending on need. I would suggest to install all
echo "Installing all of the below packages by default. Abort and modify for custom installation."
echo "1. sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
2. sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
3. sudo apt-get install libxvidcore-dev libx264-dev
4. sudo apt-get install libgtk-3-dev
5. sudo apt-get install libatlas-base-dev gfortran"

read -p "Do you want to continue? [y/n]" str
if [ "$str" = "n" ]; then
exit 
elif [! "$str" = "n" || "$str" = "y" ]; then
echo "Invalid Input"
exit
fi


sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install libxvidcore-dev libx264-dev
sudo apt-get install libgtk-3-dev
sudo apt-get install libatlas-base-dev gfortran
sudo apt-get install python2.7-dev
sudo apt-get install python3.5-dev

echo "Removing any pre-installed ffmpeg and x264"
sudo apt-get -qq remove ffmpeg x264 libx264-dev

echo -e "Downloading OpenCV $version \n"
wget -O OpenCV-$version.zip https://astuteinternet.dl.sourceforge.net/project/opencvlibrary/opencv-unix/3.4.0/opencv-3.4.0.zip
echo "Installing OpenCV" $version
unzip OpenCV-$version.zip

# echo -e "Downloading opencv contribution packages\n"
# wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.4.0.zip
# unzip opencv_contrib.zip

echo -e "Installing pip \n"
sudo apt-get install python-pip && pip install --upgrade pip

pip install numpy

maxThreads=$(grep -c ^processor /proc/cpuinfo)
echo Enter the number of CPU threads you want to use. FYI: You have $maxThreads CPU Threads.
read nThreads

cd opencv-$version
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D CUDA_GENERATION=Kepler ..
make -j$nThreads
sudo make install
sudo ldconfig

echo "Installation done"
echo ""
echo "Test by running python/python3"
echo "import cv2"
echo "cv2.__version__"








