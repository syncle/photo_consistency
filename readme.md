This is the source code used for the following paper 
Efficient and Robust Color Consistency for Community Photo Collections
Jaesik Park, Yu-Wing Tai, Sudipta N. Sinha, and In So Kweon,
IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), 2016

Note: This code is academic purpose only. Some part of code is not matured and has many experimental trials
if you encounter any weird problems or bugs, please let me know.
2016.03 written by Jaesik Park (www.jaesik.info)

NOTE: this code is for demonstrating photo consistency on the human photo collections. 
In order to handle sfm dataset, you'll need to substitute the observation matrix 
corresponding to the sfm results.

This code is tested under windows 8.1 with matlab 2014a environment. The code contains a windows binary located in 'bin/mace'. 
This binary is used for finding maxmum clique. Non-windows users will need to complie the binary. See 'bin/readme.txt'.


%%%%%%%%%%
How to use
%%%%%%%%%%
0. download this package.
1. You will need to download vlfeat toolbox used for feature extraction and matching. Go to http://www.vlfeat.org/ and get the lastest version
2. Uncompress vlfeat.
3. Copy only 'toolbox' foler in vlfeat package to the working folder. The working folder should have following subfolders.

bin
dataset
toolbox
and m files.

4. run 'execute_match.m'
5. Check the outputs generated in 'dataset\yuna_kim' folder.