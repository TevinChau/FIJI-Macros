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
resultsDir = path+"ISV-length-results_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Fiji Macro: ISV length quantifier - Created by Tevin Chau 2020");
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
ISV = newArray();
ROI = newArray();
Length = newArray();
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
//Second level loop, repeat as the required number of measurement per image
			i=0;
			ROICounter = 0;
//Third level loop, repeat as the number of timepoint in the image
			while (i==0){			
//Set to appropriate tool and allow user to draw junction shape
				setTool("freeline");
 				waitForUser("Please draw along the ISV. Click OK to measure, Shift+Click to move to next image.");
				if (isKeyDown("Shift") == true) {
					i=1;
					setKeyDown("none");
					}
				else{
				rowcounter = rowcounter+1;
				i=0;
//Add the junction shape into ROI Manager
				roiManager("Add");
				ROICounter = ROICounter+1;
//Renaming the ROI according to the image name, junction and slice number
				roiManager("Select", ROICounter-1);
				roiManager("Rename", windowtitlenoext+"_ISV"+ROICounter);
				run("Measure");
				measurementcounter = measurementcounter+1;
//Store measurements and ROI information
				FileName[rowcounter-1] = windowtitlenoext;
				ISV[rowcounter-1] = ROICounter;
				ROI[rowcounter-1] = windowtitlenoext+"_ISV"+ROICounter;
				Length[rowcounter-1] = getResult("Length", measurementcounter-1);
				run("Select None");
			}
			}
//Save all ROIs
		if (ROICounter != 0) {
			roiManager("Save", resultsDir+windowtitlenoext+".zip");
			print(windowtitlenoext+" ROIs saved");
			roiManager("reset");
			ROICounter = 0;
			close();
		}
		else{close();}}
		Array.show("Current Measurements", FileName, ISV, ROI, Length);
		saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
		selectWindow(windowtitlenoext+"_measurements.txt");
		run("Close");
	}
Table.create("ISV length measurement");
Table.setColumn("File Name", FileName);
Table.setColumn("ISV", ISV);
Table.setColumn("ROI", ROI);
Table.setColumn("Length", Length);
Table.save(resultsDir+"ISV Length.csv");
selectWindow("ISV length measurement");
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