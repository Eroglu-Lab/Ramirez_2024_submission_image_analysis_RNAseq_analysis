
/* Note that if the file is bigger than 16 GB it is possible you will need to convert to 8-bit manually before running this script.*/
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
crop = dir + "Cropped/";
File.makeDirectory(crop);


for (i = 0; i < list.length; i++) {
	if(endsWith(list[i],".tif")){
		open(dir+list[i]);
		name = getTitle();
		setTool("line");
		waitForUser("Measure angle for image rotation. Press 'Ok' when you are done.");
		run("Measure");
		run("Select None");
		angle = getResult("Angle",i);
		run("Rotate... ", "angle=["+angle+"] grid=1 interpolation=Bilinear enlarge stack");
		setTool("rectangle");
		run("Select All");
		if(i == 0){
			waitForUser("Draw box to crop image. Press 'Ok' when you are done.");
			
			run("ROI Manager...");
			roiManager("Add");
			run("Crop");
			//run("16-bit");
			saveAs("tiff", crop + name);
			run("Close All");
		}
		else{
			run("ROI Manager...");
			roiManager("Select", 0);
			
			waitForUser("Draw box to crop image. Press 'Ok' when you are done.");
			run("Crop");
			//run("16-bit");
			saveAs("tiff", crop + name);
			run("Close All");
		}
		
	}
}
print("Done.");

