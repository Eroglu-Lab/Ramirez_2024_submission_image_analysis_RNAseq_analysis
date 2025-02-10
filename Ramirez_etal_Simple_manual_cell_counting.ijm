dir = getDirectory("Choose folder of images to process for cell counting");
list = getFileList(dir);

output = dir + File.separator + "Output";
File.makeDirectory(output);

setBatchMode(false);
run("Set Measurements...", "area mean standard modal min bounding integrated area_fraction display redirect=None decimal=3");

cell_label = newArray(0);
x_coord = newArray(0);
y_coord = newArray(0);


for (i = 0; i < list.length; i++) {
	if(endsWith(list[i], ".tif")){
		open(dir + list[i]);
		name = getTitle();
		
		setTool("multipoint");
		Stack.setChannel(3);
		Stack.setDisplayMode("composite");
		
		waitForUser("Draw a point ROI on every cell you wish to count. Press 'OK' when completed. (Hint: holding space allows you to move the image without selecting adding a point ROI.");
		run("Measure");
		run("Add Selection...");
		
		BX_array = Table.getColumn("BX");
		BY_array = Table.getColumn("BY");
		cell_label_array = Table.getColumn("Label");
		
		cell_label = Array.concat(cell_label,cell_label_array);
		x_coord = Array.concat(x_coord, BX_array);
		y_coord = Array.concat(y_coord, BY_array);
		
		export_image = "Count_"+ name;
		saveAs("tiff", output + File.separator + export_image);
		run("Close All");
		run("Clear Results");
		
	}
}

Table.create("Cell_Counts");
Table.setColumn("Image name", cell_label);
Table.setColumn("X-Coordinate", x_coord);
Table.setColumn("Y-Coordinate", y_coord);
Table.save(output + File.separator + "Cell_counts.csv");

print("Done");