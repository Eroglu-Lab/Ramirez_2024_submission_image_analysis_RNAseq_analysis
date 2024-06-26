/*
 * This script is written to open images that were acquired using the Leica STED system and deconvolved using Huygens Professional using their STED deconvolution protocol.
 * The input is a folder containing three folders that must be named "Channel0", "Channel1", and "Channel2".
 * Within these subfolders should be output tiffs from Huygens of deconvolved STED images taken during a 3-channel STED experiment.
 * This script will process each channel separately using a function called "process_channel".
 * This function first max projects the image or makes a substack of z-plane 2 depending on the version of the function that is commented out.
 * Then it will apply a subtract background using a rolling ball radius of 12 pixels.
 * This is then followed with a rescaling of the contrast/brightness of the image using the default enhance contrast settings in ImageJ and applying the rescaled LUT.
 * Finally a gaussian blur of 2 pixels is applied to the image to smooth the puncta.
 * The final output of this processing is a 3-channel hyperstack with each channel in pseudocolored as red, green, or blue respective to their order. 

*/

dir = getDirectory("Choose folder containing channel folders");
combined = dir + File.separator + "Combined_Channels" + File.separator;
File.makeDirectory(combined);
//print(combined);
ch0 = dir + File.separator + "Channel0";
ch1 = dir + File.separator + "Channel1";
ch2 = dir + File.separator + "Channel2";

list = getFileList(ch0);

substack = true; //getBoolean("Do you want to process as substack?");

setBatchMode(true);
if(substack == false){
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], ".tif")){
			//print(ch0 + File.separator + list[i]);
			open(ch0 + File.separator + list[i]);
			name = getTitle();
			process_channel1(name, "0", 0, 105);
				
			chan_1 = substring(name,0,lengthOf(name)-5)+"1.tif";
			chan_2 = substring(name,0,lengthOf(name)-5)+"2.tif";
			
			open(ch1 + File.separator + chan_1);
			name1 = getTitle();
			process_channel1(name1, "1", 0, 105);
			
			open(ch2 + File.separator + chan_2);
			name2 = getTitle();
			process_channel1(name2, "2", 20, 105);
			
			run("Merge Channels...", "c1=MAX_0 c2=MAX_1 c3=MAX_2 create");
			
			
			new_name = substring(name, 0, lengthOf(name)-9);
			//print(new_name);
			rename(new_name);
			saveAs("tiff", combined + File.separator + new_name);
			
			run("Close All");
		}
	}
print("Done");
}

else{
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], ".tif")){
			//print(ch0 + File.separator + list[i]);
			open(ch0 + File.separator + list[i]);
			name = getTitle();
			process_channel2(name, "0", 0, 105);
				
			chan_1 = substring(name,0,lengthOf(name)-5)+"1.tif";
			chan_2 = substring(name,0,lengthOf(name)-5)+"2.tif";
			
			open(ch1 + File.separator + chan_1);
			name1 = getTitle();
			process_channel2(name1, "1", 0, 105);
			
			open(ch2 + File.separator + chan_2);
			name2 = getTitle();
			process_channel2(name2, "2", 20, 105);
			
			run("Merge Channels...", "c1=MAX_0 c2=MAX_1 c3=MAX_2 create");
			
			
			new_name = substring(name, 0, lengthOf(name)-9);
			//print(new_name);
			rename(new_name);
			saveAs("tiff", combined + File.separator + new_name);
			
			run("Close All");
		}
	}
print("Done");
}


function process_channel1(image, n, minimum, maximum){
	selectWindow(image);
	run("Z Project...", "projection=[Max Intensity]");
	max = "MAX_"+image;
	selectWindow(image);
	run("Close");
	selectWindow(max);
	run("Subtract Background...", "rolling=12");
	//run("Brightness/Contrast...");
	resetMinAndMax();
	//print(minimum);
	//print(maximum);
	setMinAndMax(minimum, maximum);
	call("ij.ImagePlus.setDefault16bitRange", 8);
	run("Apply LUT");
	run("Gaussian Blur...", "sigma=2");
	rename("MAX_"+n);
	//print("used max-projection");
}

function process_channel2(image, n, minimum, maximum){
	selectWindow(image);
	run("Make Substack...", "slices=2");
	rename("MAX_"+n);
	selectWindow(image);
	run("Close");
	selectWindow("MAX_"+n);
	run("Subtract Background...", "rolling=12");
	//run("Brightness/Contrast...");
	resetMinAndMax();
	setMinAndMax(minimum, maximum);
	call("ij.ImagePlus.setDefault16bitRange", 8);
	run("Apply LUT");
	run("Gaussian Blur...", "sigma=2");
	//print("used substack");
}

