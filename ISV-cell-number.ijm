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
resultsDir = path+"ISV-cell-number-results_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Fiji Macro: ISV cell number quantifier - Created by Tevin Chau 2022");
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
CellNum = newArray();
ISVNum = newArray();
CellperISV = newArray();
rowcounter = 0;
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
		FileName[rowcounter] = windowtitlenoext;
//DA Length measurement
			setTool("multipoint");
 				waitForUser("Please click on all ISVs. Click OK to Proceed.");
				if (selectionType() == -1) {
					CellNum[rowcounter] = 0;}
				else{
					run("Measure");
					roiManager("Add");
					roiManager("Select", ROICounter);
					roiManager("Rename", windowtitlenoext+"_ISVNum");
					ISVNum[rowcounter] = nResults;
					ROICounter = ROICounter+1;
					run("Clear Results");
					run("Select None");}
					
//Cell number measurement
				setTool("multipoint");
 				waitForUser("Please click on all ISV cells. Click OK to Proceed.");
				if (selectionType() == -1) {
					CellNum[rowcounter] = 0;}
				else{
					run("Measure");
					roiManager("Add");
					roiManager("Select", ROICounter);
					roiManager("Rename", windowtitlenoext+"_DACellNum");
					CellNum[rowcounter] = nResults;
					CellperISV[rowcounter] = CellNum[rowcounter]/ISVNum[rowcounter];
					ROICounter = ROICounter+1;
					run("Clear Results");
					run("Select None");}
rowcounter = rowcounter +1;
//Save all ROIs
		if (ROICounter != 0) {
			roiManager("Save", resultsDir+windowtitlenoext+".zip");
			print(windowtitlenoext+" ROIs saved");
			roiManager("reset");
			ROICounter = 0;
			close();
		}
		else{close();}}	
		Array.show("Current Measurements", FileName, DALength, CellNum, CellperLength);
		saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
		selectWindow(windowtitlenoext+"_measurements.txt");
		run("Close");
		run("Close");
	}
	
//Generating CSV file
Table.create("ISV cell number measurement");
Table.setColumn("File Name", FileName);
Table.setColumn("Number of ISV", ISVNum);
Table.setColumn("Number of Cells in all ISVs", CellNum);
Table.setColumn("Number of cell per ISV", CellperISV);
Table.save(resultsDir+"ISV-cell-number.csv");

//Clean up
selectWindow("ISV cell number measurement");
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