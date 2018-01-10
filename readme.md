# Color Consistency for Community Photo Collections

![thumbnail](thumbnail.png)

This is the source code used for the following paper
```
@inproceedings{Park2016,
    author    = {Jaesik Park, Yu-Wing Tai, Sudipta N. Sinha, and In So Kweon},
    title     = {Efficient and Robust Color Consistency for Community Photo Collections},
    booktitle = {IEEE International Conference on Computer Vision and Pattern Recognition (CVPR)},
    year      = {2016},
}
```

## Disclaimer

Note: This code is academic purpose only. Some part of code is not matured and has many experimental trials.
This code demonstrates photo consistency on the human photo collections.
In order to handle SfM dataset, you'll need to substitute the observation matrix
corresponding to the SfM results.

If you encounter any weird problems, please let me know.
This code is written by Jaesik Park (www.jaesik.info) while he were at KAIST.


## Compiling

This code is tested under windows 8.1 with Matlab 2014a environment.
The code contains a windows binary located in `bin/mace`.
This binary is used for finding maximum clique.

Non-windows users will need to compile the binary. See `bin/readme.txt`.


## How to use
1. download this package.
2. You will need to download vlfeat toolbox used for feature extraction and matching. Go to http://www.vlfeat.org/ and get the lastest version
3. Uncompress vlfeat.
4. Copy only 'toolbox' foler in vlfeat package to the working folder. The working folder should have following subfolders.

```
bin\
dataset\
toolbox\
and m files.
```

4. run 'execute_match.m'
5. Check the outputs generated in 'dataset\yuna_kim' folder.
