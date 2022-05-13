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
resultsDir = path+"Cell elongation_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Fiji Macro: Cell elongation quantifier - Created by Tevin Chau 2020");
print("Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("Working Directory Location: "+path);

//Input for measurement parameters
ext = ".tiff"
Dialog.create("Quantification parameter");
	Dialog.addString("Choose your file extension:", ext);
Dialog.show(); 
ext = Dialog.getString();

//Arrays to store measurements;
setOption("ExpandableArrays", true);
FileName = newArray();
ROI = newArray();
Cell = newArray();
Major = newArray();
Minor = newArray();
Elongation = newArray();

//Preset variables
rowcounter= -1;
measurementcounter = -1;
ROICounter = -1;
	
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
			cellcounter = 0;
//Third level while loop, repeat as required by user
			while (i==0){			
				setTool("freehand");
 				waitForUser("Please around a cell. Click to Proceed, Shift+Click to end quantifying this image.");
//Determine whether measurement is required, or exit while loop
				if (isKeyDown("Shift") == true) {
					i=1;
					setKeyDown("none");
					}
				else{
				i=0;
				rowcounter = rowcounter+1;
//Add and measure ROI
				roiManager("Add");
				ROICounter = ROICounter+1;
				roiManager("Select", ROICounter);
				roiManager("Rename", windowtitlenoext+"_cell-"+(ROICounter+1));
				run("Measure");
				measurementcounter = measurementcounter+1;
//Store measurements and ROI information
				FileName[rowcounter] = windowtitlenoext;
				ROI[rowcounter] = windowtitlenoext+"_cell-"+(ROICounter+1);
				Cell[rowcounter] = cellcounter;
				Major[rowcounter] = getResult("Major", measurementcounter);
				Minor[rowcounter] = getResult("Minor", measurementcounter);
				Elongation[rowcounter] = Major[rowcounter]/Minor[rowcounter];
				run("Select None");
			}
			}
			close();
//Save all ROIs
			if (roiManager("count")==0){}
			else{
			roiManager("Save", resultsDir+windowtitlenoext+".zip");
			roiManager("reset");
			ROICounter= -1;
			cellcounter= -1;
			print(windowtitlenoext+" ROIs saved");
			Array.show("Current Measurements", FileName, ROI, Cell, Major, Minor, Elongation);
			saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
			selectWindow(windowtitlenoext+"_measurements.txt");
			run("Close");}		
//Save all current measurements			
			Array.show("Current Measurements", FileName, ROI, Cell, Major, Minor, Elongation);
			saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
			selectWindow(windowtitlenoext+"_measurements.txt");
			run("Close");
			}}
	
Table.create("Cell elongation measurement");
Table.setColumn("File Name", FileName);
Table.setColumn("ROI", ROI);
Table.setColumn("Cell", Cell);
Table.setColumn("Major", Major);
Table.setColumn("Minor", Minor);
Table.setColumn("Elongation", Elongation);
Table.save(resultsDir+"Cell elongation.csv");
selectWindow("Cell elongation measurement");
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