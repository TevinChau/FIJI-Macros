//Clean up
run("Clear Results");
roiManager("reset");

//Navigate directory
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Please select the folder containing your dataset.");
 Dialog.show(); 
path = getDirectory("Choose Source Directory ");
list = getFileList(path);

//Creates Directory for output images/logs/results table
getDateAndTime(year, month, week, day, hour, min, sec, msec);
resultsDir = path+"filopodia analysis results_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Fiji Macro: filopodia analyser - Created by Tevin Chau 2021");
print("Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("Working Directory Location: "+path);

//Input for measurement parameters
ext = ".tif"
Dialog.create("Quantification parameter");
	Dialog.addString("Choose your file extension:", ext);
Dialog.show(); 
//Update parameters as user input
ext = Dialog.getString();

//Arrays to store measurements;
setOption("ExpandableArrays", true);
FileName = newArray();
Filopodia = newArray();
Slice = newArray();
Length = newArray();
A2B = newArray();
Angle = newArray();
Type = newArray();
Linearity = newArray();
rowcounter = 0;
measurementcounter = 0;

	
//This is the first level loop, if more than one file continue until all files are completed. 
for (z=0; z<list.length; z++) {
//Condition to only open files with the required extension
	if (endsWith(list[z],ext)){
//Opening file and obtaining information
  		open(path+list[z]);
		windowtitle = getTitle();
		windowtitlenoext = replace(windowtitle, ext, "");
		print("Opening File: "+(z+1)+" of "+list.length+"  Filename: "+windowtitle);
		getDimensions(width, height, channels, slices, frames);
		i=0;
		x=0;
		ROICounter = 0;
//Crop image for tip quantification
		setTool("Line");
		waitForUser("Define ROI", "Please draw a 10um line from the tip of the sprout.");
		getLine(x1, y1, x2, y2, lineWidth);	
		makeRectangle(0, 0, width, (y1+y2)/2);
		run("Duplicate...", "");
//Measurement of tip filopodia
       for (w=0; w<3; w++) {
			while (i==0){			
				setTool("freeline");
 				waitForUser("Please draw along the tip filopodia. Click to Proceed, Shift+Click to end.");
				if (isKeyDown("Shift") == true) {
					i=1;
					setKeyDown("none");
					}
				else{
				rowcounter = rowcounter+1;
				i=0;
				if (selectionType() != -1) {
				roiManager("Add");
				ROICounter = ROICounter+1;
				roiManager("Select", ROICounter-1);
				roiManager("Rename", windowtitlenoext+"_filopodia"+w+1);
				run("Measure");
				measurementcounter = measurementcounter+1;
//Store measurements and ROI information
				FileName[rowcounter] = windowtitlenoext;
				Filopodia[rowcounter] = "tip "+(w+1);
				Slice[rowcounter] = getSliceNumber();
				Length[rowcounter] = getResult("Length", measurementcounter-1);
				Type[rowcounter] = "tip";
				print("File: "+FileName[rowcounter]+", Filopodia: "+Filopodia[rowcounter]+", Length: "+Length[rowcounter]+", Type: "+Type[rowcounter]);
				run("Line to Area");
				run("Measure");
				measurementcounter = measurementcounter+1;
				A2B[rowcounter] = getResult("Major", measurementcounter-1);
				Angle[rowcounter] = getResult("Angle", measurementcounter-1);
				Linearity[rowcounter] = A2B[rowcounter]/Length[rowcounter];
				print("A to B: "+A2B[rowcounter]+", Angle: "+Angle[rowcounter]+", Linearity: "+Linearity[rowcounter]);
				run("Select None");
				setKeyDown("none");}
				else {print(rowcounter+", none selected.");}}}
				i=0;}
				close();
//Crop image for stalk quantification
		selectWindow(windowtitle);
		makeRectangle(0, (y1+y2)/2, width, y2-((y1+y2)/2));
		run("Duplicate...", "");
//Measurement of stalk filopodia
		for (y=0; y<3; y++){
			while (x==0){			
				setTool("freeline");
 				waitForUser("Please draw along the stalk filopodia. Click to Proceed, Shift+Click to end.");
				if (isKeyDown("Shift") == true) {
					x=1;
					setKeyDown("none");
					}
				else{
				rowcounter = rowcounter+1;
				x=0;
				if (selectionType() != -1){
				roiManager("Add");
				ROICounter = ROICounter+1;
				roiManager("Select", ROICounter-1);
				roiManager("Rename", windowtitlenoext+"_stalk filopodia"+(y+1));
				run("Measure");
				measurementcounter = measurementcounter+1;
//Store measurements and ROI information
				Filopodia[rowcounter] = "stalk "+(y+1);
				Slice[rowcounter] = getSliceNumber();
				Length[rowcounter] = getResult("Length", measurementcounter-1);
				Type[rowcounter] = "stalk";
				print("Filopodia: "+Filopodia[rowcounter]+", Length: "+Length[rowcounter]+", Type: "+Type[rowcounter]);
				run("Line to Area");
				run("Measure");
				measurementcounter = measurementcounter+1;
				A2B[rowcounter] = getResult("Major", measurementcounter-1);
				Angle[rowcounter] = getResult("Angle", measurementcounter-1);
				Linearity[rowcounter] = A2B[rowcounter]/Length[rowcounter];
				print("A to B: "+A2B[rowcounter]+", Angle: "+Angle[rowcounter]+", Linearity: "+Linearity[rowcounter]);
				run("Select None");
				setKeyDown("none");}
				else {print(rowcounter+", none selected.");}}}
				x=0;}
				close();
//Save all ROIs
		if (ROICounter != 0) {
			roiManager("Save", resultsDir+windowtitlenoext+".zip");
			print(windowtitlenoext+" ROIs saved");
			roiManager("reset");
			ROICounter = 0;
			close();
		}
		else{close("*");}
		Array.show("Current Measurements", FileName, Filopodia, Slice, Type, Length, A2B, Linearity, Angle);
		saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
		selectWindow(windowtitlenoext+"_measurements.txt");
		run("Close");
	}}
Table.create("Filopodia measurement");
Table.setColumn("File Name", FileName);
Table.setColumn("Filopodia", Filopodia);
Table.setColumn("Slice", Slice);
Table.setColumn("Type", Type);
Table.setColumn("Length", Length);
Table.setColumn("A2B", A2B);
Table.setColumn("Linearity", Linearity);
Table.setColumn("Angle", Angle);
Table.save(resultsDir+"filopodia.csv");
selectWindow("Filopodia measurement");
run("Close");
selectWindow("Log");								
saveAs("Text", resultsDir+"Log.txt");
selectWindow("Log"); 
run("Close");
run("Clear Results");
roiManager("reset");

//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "yo done";
waitForUser(title, msg);   