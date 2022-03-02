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
resultsDir = path+"Junciton-Width_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Fiji Macro: Junction width quantifier - Created by Tevin Chau 2022");
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
ROI = newArray();
Junction = newArray();
Area = newArray();
Length = newArray();
A2B = newArray();
Width = newArray();
Linearity = newArray();
Angle = newArray();
rowcounter=0;
measurementcounter = 0;
ROICounter = 0;
	
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
//Second level loop, repeat as the required number of measurement per image
			i=0;
			junctioncounter = 0;
//Third level loop, repeat as the number of timepoint in the image
			while (i==0){			
//Set to appropriate tool and allow user to draw junction shape
				setTool("freehand");
 				waitForUser("Please around a junction. Click to Proceed, Shift+Click to end quantifying this image.");
				if (isKeyDown("Shift") == true) {
					i=1;
					junctioncounter=0;
					setKeyDown("none");
					}
				else{
				i=0;
				FileName[rowcounter] = windowtitlenoext;
//Add the junction shape into ROI Manager
				roiManager("Add");
				junctioncounter = junctioncounter+1;
				ROI[rowcounter] = windowtitlenoext+"_junction"+ROICounter;
				Junction[rowcounter] = junctioncounter;
				roiManager("Select", ROICounter);
				roiManager("Rename", windowtitlenoext+"_junction"+ROICounter);
				ROICounter = ROICounter+1;
//Junction thickness measurement
				run("Duplicate...", " ");
				run("Make Inverse");
				run("Clear", "slice");
				run("Select None");
				run("Gaussian Blur...", "sigma=3");
				run("Threshold...");
				setAutoThreshold("Mean dark");
				run("Convert to Mask");
				run("Create Selection");
				run("Measure");
				Area[rowcounter] = getResult("Area", measurementcounter);
				measurementcounter = measurementcounter+1;
//JUnction length and Linearity measurment
				run("Skeletonize (2D/3D)");
				run("Create Selection");
				run("Measure");
				Length[rowcounter] = getResult("Area", measurementcounter);
				Width[rowcounter] = Area[rowcounter]/Length[rowcounter];
				run("Select None");
				measurementcounter = measurementcounter+1;
				rowcounter = rowcounter+1;
				close();
			}
			}
			close();
			
//Save all ROIs
			if (roiManager("count")==0){close("*");}
			else{
			roiManager("Save", resultsDir+windowtitlenoext+".zip");
			roiManager("reset");
			ROICounter=0;
			junctioncounter=0;
			print(windowtitlenoext+" ROIs saved");
			Array.show("Current Measurements", FileName, ROI, Junction, Area, Length, Width);
			saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
			selectWindow(windowtitlenoext+"_measurements.txt");
			close("*");}}}

//Generating CSV	
Table.create("Junction width measurement");
Table.setColumn("File Name", FileName);
Table.setColumn("ROI", ROI);
Table.setColumn("Junction", Junction);
Table.setColumn("Area", Area);
Table.setColumn("Length", Length);
Table.setColumn("Width", Width);
Table.save(resultsDir+"Junction-Width.csv");
selectWindow("Junction width measurement");
run("Close");
selectWindow("Log");								
saveAs("Text", resultsDir+"Log.txt");
selectWindow("Log"); 
run("Close");
run("Clear Results");
roiManager("reset");
close("*");

//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "yo done";
waitForUser(title, msg);   