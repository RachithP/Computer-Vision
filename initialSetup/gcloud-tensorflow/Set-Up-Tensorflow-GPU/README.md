# Set-Up-Tensorflow-GPU
## CuDNN and Cuda version are tested with Tesla K80 GPU only!

In this guide, I will show a 4-steps process of quickly setting up and running the Tensorflow GPU on google cloud instance. The same 4-steps process is also applicable for any other virtual machine instances deployed on any other cloud computing platform such as AWS, Paperspace, Digitial Ocean etc.

Step-1. Start your VM instance and log-in to it using your terminal. Simply clone this github repository in your "home" directory. It can be easily done by the running this command in terminal of your home directory:

>>> git clone this folder.

This will download a folder named Set-Up-Tensorflow-GPU in your VM home directory.

Step-2. From your "home" directory, run the LINUX shell file "script_1.sh" using bash command as shown below.

`bash ~/Set-Up-Tensorflow-GPU/script_1.sh`

Step-3. Download https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v7.0.5/prod/9.0_20171129/cudnn-9.0-linux-x64-v7 by logging into your nvidia-developer account(if you don't have one, create one! - it's free!!)  
Make sure you have the file in your `~/Set-Up-Tensorflow-GPU/` folder.

Step-4. From your home directory (inside your terminal), run the following command:

`bash ~/Set-Up-Tensorflow-GPU/script_2.sh`
