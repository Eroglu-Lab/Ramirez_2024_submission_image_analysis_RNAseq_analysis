Python scripts:

Bin_Synapse_Data*

Each script requires an output folder from synbot including the .csv files that record the synapse counts and positions in the image. 
The scripts assume that the image was analyzed with the pia at the top of the image. Therefore, only the y coordinate for each synapse is used to bin them.

Denoise_restore*

Script for running UNet denoising using weight files trained to convert 60X resonant scanner images to galvano quality images on the Olympus FV3000 microscope.

R-markdown:
Reads and counts can be downloaded from the GEO submission: GSE259420

ImageJ macros:

Process_STED_Images:

Processes images acquired using STED in a uniform way before using as input for SynBot triple colocalization analysis.

Crop_Tile_Images_for_Synapse_Count:

Opens tiff format images to prompt the user to rotate the image and crop to an ROI. Will save the first ROI drawn to use as a basis for subsequent ROIs. 
