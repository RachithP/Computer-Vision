#!/bin/sh

#echo "Making Python 3.5 as default"
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2
#sudo update-alternatives --config python

## Installing OpenCV 3.4.0

version=3.4.0

sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove

echo "NOTE: Uninstallating ffmpeg and x264. They have issues with OpenCV."
read -p "Press <ENTER> to continue"
echo "Removing any pre-installed ffmpeg and x264"
sudo apt-get -qq remove ffmpeg x264 libx264-dev

# This is for compilers
echo "Install compiler dependent packages"
sudo apt-get -y install build-essential
sudo apt-get -y install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev

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
elif ! [ "$str" = "n" || "$str" = "y" ]; then
echo "Invalid Input"
exit
fi

sudo apt-get -y install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get -y install libxvidcore-dev libx264-dev
sudo apt-get -y install libgtk-3-dev
sudo apt-get -y install libatlas-base-dev gfortran
sudo apt-get -y install python2.7-dev
sudo apt-get -y install python3.5-dev

echo -e "Downloading OpenCV $version \n"
wget -O OpenCV-$version.zip https://astuteinternet.dl.sourceforge.net/project/opencvlibrary/opencv-unix/3.4.0/opencv-3.4.0.zip
echo "Installing OpenCV" $version
unzip OpenCV-$version.zip

#echo -e "Downloading opencv contribution packages\n"
#wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.4.0.zip
#unzip opencv_contrib.zip

#echo -e "Installing numpy \n"
sudo pip3 install numpy

maxThreads=$(grep -c ^processor /proc/cpuinfo)
echo Enter the number of CPU threads you want to use. FYI: You have $maxThreads CPU Threads.
read nThreads

echo "Using Virtual environment for installating Opencv...Setting up Virtual Environment now..."
sudo pip3 install virtualenv virtualenvwrapper
echo "# Virtual Environment Wrapper"  >> ~/.bashrc
export WORKON_HOME=$HOME/.virtualenvs
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
source ~/.bashrc

echo "Creating virtual environment named 'cv'"
mkvirtualenv cv -p python3
workon cv
pip3 install numpy scipy matplotlib scikit-image scikit-learn ipython
deactivate

cd opencv-$version
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D CUDA_GENERATION=Kepler ..
make -j$nThreads
sudo make install
sudo sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig

# echo "Creating symbolic link for virtual env..."
# find /usr/local/lib/ -type f -name "cv2*.so"
# read -p "Assuming python3.5 and proceeding....Press [ENTER] to continue..."
# cd /usr/local/lib/python3.5/dist-packages/
# sudo mv cv2.cpython-35m-x86_64-linux-gnu.so cv2.so
# cd ~/.virtualenvs/cv/lib/python3.5/site-packages
# ln -s /usr/local/lib/python3.5/dist-packages/cv2.so cv2.so

echo "Installation done"
echo ""
echo "Test by running python/python3"
echo "import cv2"
echo "cv2.__version__"

## Installting Cuda 9.0 for nvidia 396/384 -- cudnn 7.4 works with this
# https://medium.com/@zhanwenchen/install-cuda-and-cudnn-for-tensorflow-gpu-on-ubuntu-79306e4ac04e
# or
# system setup installation by cmsc733