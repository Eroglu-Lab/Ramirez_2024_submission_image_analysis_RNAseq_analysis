/*
 * This script assumes that you are working with Tiffs not raw output from the confocal.
 * It also assumes a 3 channel image where two of the channels are cell markers and the
 * third channel is a protein of interest to be measured within the respective cell markers.
 * 
 * The first part of this script can be used to subdivide an image into 4 non-overlapping rectangular ROIs.
 * 
 * The second part of this script assumes the first part was run producing 5 subfolders within the main directory.
 * This part of the script is split by a boolean whether the whole cropped ROI needs to be analyzed or not. 
 * 
 * The final output of this script is a results table recording the cropped image dimensions and the Y coordinates for each 
 * layer ROI.
 * Additionally, each subfolder will have a results table recording the threshold values for each channel, intensity for each channel,
 * and area measurements for each channel.
 * 
 */
 
dir = getDirectory("Select folder with Tiffs to process");
list = getFileList(dir);

cropped = dir + File.separator + "Cropped";
layer1 = dir + File.separator + "Layer1";
layer2_3 = dir + File.separator + "Layer2_3";
layer4 = dir + File.separator + "Layer4";
layer5_6 = dir + File.separator + "Layer5_6";

run("Set Measurements...", "area mean standard centroid center bounding integrated area_fraction display redirect=None decimal=3");
setBatchMode(false);


Dialog.create("Microglia layer specific analysis");
Dialog.addCheckbox("Crop and Segment image?", true);
Dialog.addCheckbox("Process layers?", true);
Dialog.addCheckbox("Process whole ROI?", true);
Dialog.show();

crop_bool = Dialog.getCheckbox();
layers_bool = Dialog.getCheckbox();
roi_bool = Dialog.getCheckbox();


if(crop_bool == true){
	crop_and_segment(dir, list);
	//print("Testing: Done running crop and segment.");
}

if(layers_bool == true){
	threshold_images(layer1, "Layer1", "1", "3", "2");
	threshold_images(layer2_3, "Layer2_3", "1", "3", "2");
	threshold_images(layer4, "Layer4", "1", "3", "2");
	threshold_images(layer5_6, "Layer5_6", "1", "3", "2");
	//print("Testing: Process all layer images.");
}
if(roi_bool == true){
	threshold_images(cropped, "Cropped", "1", "3", "2");
	//print("Testing: Process whole cropped ROI images.");
}
if(crop_bool==false && layers_bool==false && roi_bool==false){
	print("Error: Please select an option.");
}


function crop_and_segment(dir, list) {
	cropped = dir + File.separator + "Cropped";
	layer1 = dir + File.separator + "Layer1";
	layer2_3 = dir + File.separator + "Layer2_3";
	layer4 = dir + File.separator + "Layer4";
	layer5_6 = dir + File.separator + "Layer5_6";
	
	File.makeDirectory(cropped);
	File.makeDirectory(layer1);
	File.makeDirectory(layer2_3);
	File.makeDirectory(layer4);
	File.makeDirectory(layer5_6);

	image_array = newArray(0);
	roi_x = newArray(0);
	roi_y = newArray(0);
	angle_array = newArray(0);
	layer1_array = newArray(0);
	layer2_3_array = newArray(0);
	layer4_array = newArray(0);
	layer5_6_array = newArray(0);

	
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], ".tif")){
			open(dir +File.separator+ list[i]);
			name = getTitle();
			image_array = Array.concat(image_array,name);
			
			//print(name);
			getVoxelSize(width, height, depth, unit);
			x_res = width;
			y_res = height;
			z_res = depth;
			unit = unit;
			Image.removeScale();
	
			setTool("line");
			waitForUser("Draw a line along the pia or corpus callosum.");
			run("Measure");
			angle = getResult("Angle", 0);
			angle_array = Array.concat(angle_array, angle);
			//print(angle);
	
			run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear enlarge");
			setTool("rectangle");
			makeRectangle(0, 0, 1024, 2048);
	
			waitForUser("Draw rectangle ROI over region of cortex you want to process.");
			run("Clear Results");
			run("Measure");
			x_orig = getResult("BX", 0);
			y_orig = getResult("BY", 0);
			roi_x = Array.concat(roi_x,x_orig);
			roi_y = Array.concat(roi_y,y_orig);
			run("Crop");
	
			run("Clear Results");
	
			layer1_name = "Layer1-"+name;
			setTool("rectangle");
			selectWindow(name);
			makeRectangle(0, 0, 1024, 50);
			layer1_array = Array.concat(layer1_array,0);
			
			waitForUser("Draw a rectangle ROI at layer 1.");
			run("Measure");
			
			run("Duplicate...", "duplicate");
			rename(layer1_name);
			saveAs("tiff", layer1 + File.separator + layer1_name);
			selectWindow(layer1_name);
			run("Close"); 
			
			layer_2_3_Y_start = getResult("BY", 0) + getResult("Height", 0);
			print("Just in case you need this...");
			print(name,": ");
			print("Layer2/3 start: ", layer_2_3_Y_start);
			run("Clear Results");
	
			layer2_3_name = "Layer2_3-"+name;
			setTool("rectangle");
			selectWindow(name);
			makeRectangle(0, layer_2_3_Y_start, 1024, 50);
			layer2_3_array = Array.concat(layer2_3_array,layer_2_3_Y_start);
			
			waitForUser("Draw a rectangle ROI at layer 2/3.");
			run("Measure");
			
			run("Duplicate...", "duplicate");
			rename(layer2_3_name);
			saveAs("tiff", layer2_3 + File.separator + layer2_3_name);
			selectWindow(layer2_3_name);
			run("Close"); 
	
			layer_4_Y_start = getResult("BY", 0) + getResult("Height", 0);
			print("Layer4 start: ", layer_4_Y_start);
			run("Clear Results");
	
			layer4_name = "Layer4-"+name;
			setTool("rectangle");
			selectWindow(name);
			makeRectangle(0, layer_4_Y_start, 1024, 50);
			layer4_array = Array.concat(layer4_array,layer_4_Y_start);
			
			waitForUser("Draw a rectangle ROI at layer 4.");
			run("Measure");
			
			run("Duplicate...", "duplicate");
			rename(layer4_name);
			saveAs("tiff", layer4 + File.separator + layer4_name);
			selectWindow(layer4_name);
			run("Close"); 
	
			layer_5_6_Y_start = getResult("BY", 0) + getResult("Height", 0);
			print("Layer5_6 start: ", layer_5_6_Y_start);
			run("Clear Results");
	
			layer5_6_name = "Layer5_6-"+name;
			setTool("rectangle");
			selectWindow(name);
			makeRectangle(0, layer_5_6_Y_start, 1024, 50);
			layer5_6_array = Array.concat(layer5_6_array,layer_5_6_Y_start);
			
			waitForUser("Draw a rectangle ROI at layer 5/6.");
			run("Measure");
			
			run("Duplicate...", "duplicate");
			rename(layer5_6_name);
			saveAs("tiff", layer5_6 + File.separator + layer5_6_name);
			selectWindow(layer5_6_name);
			run("Close"); 
	
			cropped_name = "Cropped-" + name;
			selectWindow(name);	
			run("Set Scale...", "distance=1 known="+x_res+" pixel=1.000 unit=micron");
			run("Properties...", "channels=3 slices=11 frames=1 pixel_width="+x_res+" pixel_height="+y_res+" voxel_depth="+z_res+"");
			saveAs("tiff", cropped + File.separator + cropped_name);
	
			run("Close All");
			run("Clear Results");
		}
	}
	
	Table.create("Image_cropping_information");
	Table.setColumn("Image name", image_array);
	Table.setColumn("Angle to rotate original image", angle_array);
	Table.setColumn("X coordinate for upper left corner of ROI box", roi_x);
	Table.setColumn("Y coordinate for upper left corner of ROI box", roi_y);
	Table.setColumn("Starting Y coordinate of Layer 1 ROI", layer1_array);
	Table.setColumn("Starting Y coordinate of Layer 2/3 ROI", layer2_3_array);
	Table.setColumn("Starting Y coordinate of Layer 4 ROI", layer4_array);
	Table.setColumn("Starting Y coordinate of Layer 5/6 ROI", layer5_6_array);
	Table.save(dir + File.separator + "Image_cropping_information.csv");
	print("Done cropping images.");
		 
}

function threshold_images(path, layer_num_string, p2y12_chan, iba1_chan, cd68_chan) {
// p2y12_chan, iba1_chan, and cd68_chan need to be input as "1", "2", or "3".
//layer_num_string needs to input as as "Layer#" or "Cropped".

	max_folder = "Max_Projections_"+layer_num_string;
	max = path + File.separator + max_folder;
	p2y12_folder = "P2y12_mask_"+layer_num_string;
	p2y12 = path + File.separator + p2y12_folder;
	iba1_folder = "Iba1_mask_"+layer_num_string;
	iba1 = path + File.separator + iba1_folder;
	cd68_folder = "CD68_mask_"+layer_num_string;
	cd68 = path + File.separator + cd68_folder;

	File.makeDirectory(max);
	File.makeDirectory(p2y12);
	File.makeDirectory(iba1);
	File.makeDirectory(cd68);

	p2y12_channel = "C"+p2y12_chan+"-";
	iba1_channel = "C"+iba1_chan+"-";
	cd68_channel = "C"+cd68_chan+"-";

	path_list = getFileList(path);

	image_name_array = newArray(0);//
	p2y12_thresh_array = newArray(0);//
	iba1_thresh_array = newArray(0);//
	cd68_thresh_array = newArray(0);
	p2y12_area_array = newArray(0);//
	iba1_area_array = newArray(0);//
	cd68_area_array = newArray(0);
	p2y12_int_array = newArray(0);//
	iba1_int_array = newArray(0);//
	cd68_int_p2y12_array = newArray(0);//
	cd68_int_iba1_array = newArray(0);//
	roi_area_array = newArray(0);//
	

	for (n = 0; n < path_list.length; n++) {
		if(endsWith(path_list[n],".tif")){
			open(path + File.separator + path_list[n]);
			Image.removeScale();
			image = getTitle();
			image_name_array = Array.concat(image_name_array,image);
			
			max_name = "MAX_"+image;
			p2y12_img = p2y12_channel+max_name;
			iba1_img = iba1_channel+max_name;
			cd68_img = cd68_channel+max_name;

			p2y12_mask = "P2y12_mask_"+max_name;
			iba1_mask = "Iba1_mask_"+max_name;
			cd68_mask = "CD68_mask_"+max_name;

			selectWindow(image);
			run("Select All");
			run("Measure");
			roi_area = getResult("Area", 0);
			roi_area_array = Array.concat(roi_area_array,roi_area);
			run("Clear Results");
			run("Select None");
			selectWindow(image);
			
			run("Z Project...", "projection=[Max Intensity]");
			selectWindow(image);
			run("Close");
			selectWindow(max_name);
			run("Subtract Background...", "rolling=50");
			saveAs("tiff", max + File.separator + max_name);
			selectWindow(max_name);

			run("Split Channels");
			selectWindow(p2y12_img);
			run("Grays");
			selectWindow(iba1_img);
			run("Grays");
			selectWindow(cd68_img);
			run("Grays");
			
//process the p2y12 image
			selectWindow(p2y12_img);
			run("Select All");
			run("Measure");
			p2y12_int = getResult("IntDen", 0);
			p2y12_int_array = Array.concat(p2y12_int_array,p2y12_int);
			run("Select None");
			run("Clear Results");

			selectWindow(p2y12_img);
			run("Threshold...");
			waitForUser("Threshold P2y12 channel");
			getThreshold(lower, upper);
			p2y12_thresh = lower;
			p2y12_thresh_array = Array.concat(p2y12_thresh_array,p2y12_thresh);
			
			run("Create Selection");
			run("Measure");
			p2y12_area = getResult("Area", 0);
			p2y12_area_array = Array.concat(p2y12_area_array,p2y12_area);
			run("Clear Results");
			run("Convert to Mask");
			selectWindow(p2y12_img);
			saveAs("tiff", p2y12 + File.separator + p2y12_mask);

			selectWindow(cd68_img);
			run("Restore Selection");
			run("Measure");
			cd68_int_p2y12 = getResult("IntDen",0);
			cd68_int_p2y12_array = Array.concat(cd68_int_p2y12_array,cd68_int_p2y12);
			run("Clear Results");
			run("Select None");

//process the iba1 image 
			selectWindow(iba1_img);
			run("Select All");
			run("Measure");
			iba1_int = getResult("IntDen", 0);
			iba1_int_array = Array.concat(iba1_int_array,iba1_int);
			run("Select None");
			run("Clear Results");

			selectWindow(iba1_img);
			run("Threshold...");
			waitForUser("Threshold Iba1 channel");
			getThreshold(lower, upper);
			iba1_thresh = lower;
			iba1_thresh_array = Array.concat(iba1_thresh_array,iba1_thresh);
			
			run("Create Selection");
			run("Measure");
			iba1_area = getResult("Area", 0);
			iba1_area_array = Array.concat(iba1_area_array,iba1_area);
			run("Clear Results");
			run("Convert to Mask");
			selectWindow(iba1_img);
			saveAs("tiff", iba1 + File.separator + iba1_mask);

			selectWindow(cd68_img);
			run("Restore Selection");
			run("Measure");
			cd68_int_iba1 = getResult("IntDen",0);
			cd68_int_iba1_array = Array.concat(cd68_int_iba1_array,cd68_int_iba1);
			run("Clear Results");
			run("Select None");
			
//process the cd68 image 
			selectWindow(cd68_img);
			run("Threshold...");
			waitForUser("Threshold CD68 channel");
			getThreshold(lower, upper);
			cd68_thresh = lower;
			cd68_thresh_array = Array.concat(cd68_thresh_array,cd68_thresh);
			
			run("Create Selection");
			run("Measure");
			cd68_area = getResult("Area", 0);
			cd68_area_array = Array.concat(cd68_area_array,cd68_area);
			run("Clear Results");
			run("Convert to Mask");
			selectWindow(cd68_img);
			saveAs("tiff", cd68 + File.separator + cd68_mask);			

			run("Close All");
			run("Clear Results");
		}
	}

	table_name = layer_num_string +" "+ "thresholding data";
	Table.create(table_name);
	Table.setColumn("Image name", image_name_array);
	Table.setColumn("P2y12 threshold", p2y12_thresh_array);
	Table.setColumn("Iba1 threshold", iba1_thresh_array);
	Table.setColumn("CD68 threshold", cd68_thresh_array);
	Table.setColumn("P2y12 area", p2y12_area_array);
	Table.setColumn("Iba1 area", iba1_area_array);
	Table.setColumn("CD68 area", cd68_area_array);
	Table.setColumn("P2y12 intensity", p2y12_int_array);
	Table.setColumn("Iba1 intensity", iba1_int_array);
	Table.setColumn("CD68 intensity within P2y12", cd68_int_p2y12_array);
	Table.setColumn("CD68 intensity within Iba1", cd68_int_iba1_array);
	Table.setColumn("ROI area (pxls)", roi_area_array);

	Table.save(path + File.separator + table_name + ".csv");

	print("Done thresholding images in folder.");
	
}





/*
 * 
 * Could be useful to add results table that saves the ROI locations for each layer relative to the cropped ROI of cortex.
 * 
 * 
 * Next step of analysis is going through each image and thresholding for P2Y12, Iba1, and CD68.
 * First step will be to make a function that takes a folder path and channel information as inputs.
 * This function needs to:
 * 1. Max project image being processed.
 * 2. Apply subtract background with rolling ball radius of 50.
 * 3. Save Max projected and subtract background image to a subfolder called "Layer#_MaxProjections".
 * 4. Produce 3 subfolders for binary masks of each channel, i.e. P2y12-mask, Iba1-mask, and CD68-mask.
 * 5. Split max projected image and set each channel to Grays LUT.
 * 6. Threshold each cell marker, i.e. P2y12 and Iba1.
 * 7. Generate a mask for each cell marker.
 * 8. Save each of those masks in their respective subfolders.
 * 9. Measure the area coverage for each cell marker.
 * 10. Apply each of those masks to the CD68 channel and measure the intensity.
 * 11. Finally, Threshold the CD68 channel and get a measurement for CD68 area.
 * 12. This function needs to make and export a results table with Image Name, P2y12 threshold value, Iba1 threshold value, 
 *     CD68 threshold value, P2y12 area, Iba1 area, CD68 area, P2y12 intensity in the whole ROI, Iba1 intensity in the whole ROI,
 *     CD68 intensity in P2y12, and CD68 intensity in Iba1.
 * This function will then be applied to a list of folders
 */

