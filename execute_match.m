%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This is the source code used for the following paper 
%%% Efficient and Robust Color Consistency for Community Photo Collections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Jaesik Park, Yu-Wing Tai, Sudipta N. Sinha, and In So Kweon,
%%% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), 2016
%%% Note: This code is academic purpose only and has many experimental trials
%%% if you encounter any weird problems or bugs, please let me know.
%%% 2016.03 written by Jaesik Park (www.jaesik.info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% NOTE: this code is for demonstrating photo consistency on the human photo collections. 
%%% In order to handle sfm dataset, you'll need to substitute the observation matrix 
%%% corresponding to the sfm results.

clear all;
close all;

filepath = 'dataset\Yuna_Kim\';
nclique = 2;

fileextension = '*.png';
colorchannel = 'RGB';


% used for patch augmentation in function 'fn_extract_color'
augmentation = 1;
augratio = 5;    
patchsize = 30;

batchsift = 1;
batchmatch = 1;
findgroup = 1;
extractpatch = 1;
extractcolor = 1;
estimation = 1;
apply = 1;

names = fn_get_filenames(filepath,fileextension);

if(batchsift)
    fn_extract_feature_batch(filepath,names);
end

% todo: this module can be improved!
if(batchmatch)
    fn_match_features(filepath,names);
end

% todo: this module can be improved!
if(findgroup)
    fn_find_group(filepath,names,nclique);
end

if(extractpatch)
    fn_extract_patches_batch(filepath,names,colorchannel);
end

if(extractcolor)
    fn_extract_color(filepath,names,augmentation,augratio,patchsize);
end

if(estimation)
   fn_estimation(filepath,10);
end

if(apply)
    fn_apply(filepath,names,colorchannel);
end







