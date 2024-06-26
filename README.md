Python scripts:

Bin_Synapse_Data*

Each script requires an output folder from synbot including the .csv files that record the synapse counts and positions in the image. 
The scripts assume that the image was analyzed with the pia at the top of the image. Therefore, only the y coordinate for each synapse is used to bin them.

Denoise_restore and Denoise_train*

Script for running UNet denoising using weight files trained to convert 60X resonant scanner images to galvano quality images on the Olympus FV3000 microscope.

R-markdown:

InVitro_RNAseq_analysis_withBatch
Reads and counts can be downloaded from the GEO submission: GSE259420

Ramirez_etal_Stratified_RRHO_Analysis
CSVs with the ranked gene lists can be downloaded from CSV_Stratified_RRHO.zip

Ramirez_etal_KEGG_analysis
CSV out of differential expression analysis needed to run script 230302_WT_Invitro_RNAseq_DEA.csv


ImageJ macros:

Process_STED_Images:

Processes images acquired using STED in a uniform way before using as input for SynBot triple colocalization analysis.

Crop_Tile_Images_for_Synapse_Count:

Opens tiff format images to prompt the user to rotate the image and crop to an ROI. Will save the first ROI drawn to use as a basis for subsequent ROIs. 
