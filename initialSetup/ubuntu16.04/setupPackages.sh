#!/bin/sh

echo "Installing git..."
sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install git

restart

echo "Cloning Computer-Vision github repo..."
mkdir -p ~/git
cd ~/git
git clone https://github.com/RachithP/Computer-Vision.git

cd ~
echo "Installing sublime-text 3..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt-get -y install sublime-text

# Skipping this due to issues
#echo "Installing nvidia driver 410 (Latest as of Feb-03-2019)..."
#sudo apt-get purge nvidia*
#sudo add-apt-repository ppa:graphics-drivers/ppa
#sudo apt update
#sudo apt-get -y install nvidia-410

echo "Installing python2.7-dev, python3.5dev and pip"
sudo apt-get -y install python2.7-dev
sudo apt-get -y install python3.5-dev
sudo apt-get -y install python3-pip
pip3 install --upgrade pip










