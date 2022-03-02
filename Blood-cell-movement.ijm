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
resultsDir = path+"blood-cell-movement-results_"+year+"-"+(month+1)+"-"+day+"_at_"+hour+"."+min+"/";
File.makeDirectory(resultsDir);
print("Fiji Macro: Blood cell movement quantifier - Created by Tevin Chau 2022");
print("Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("Working Directory Location: "+path);

//Input for measurement parameters
ext = ".czi";
Dialog.create("Quantification parameter");
	Dialog.addString("Choose your file extension:", ext);
	Dialog.addNumber("Image Scale(um/pixel): ", 3.08);
	Dialog.addNumber("Timepoint interval (ms): ", 30);
Dialog.show(); 
//Update parameters as user input
ext = Dialog.getString();
Scale = Dialog.getNumber();
Interval = Dialog.getNumber();

//Arrays to store measurements;
setOption("ExpandableArrays", true);
FileName = newArray();
Cell1TotalDis = newArray();
Cell1time = newArray();
Cell1Spd = newArray();
Cell1AvgSpd = newArray();
Cell2TotalDis = newArray();
Cell2time = newArray();
Cell2Spd = newArray();
Cell2AvgSpd = newArray();
Cell3TotalDis = newArray();
Cell3time = newArray();
Cell3Spd = newArray();
Cell3AvgSpd = newArray();
Distance = newArray();
Time = newArray();
Speed = newArray();
rowcounter = 0;
ROICounter = 0;
numTimePoint = 0;
	
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
		
//Blood cell 1 measurement
			setTool("multipoint");
 				waitForUser("Please click on blood cell No. 1 over the time series. Click OK to Proceed.");
				if (selectionType() == -1) {
					}
				else{
					run("Measure");
					roiManager("Add");
					roiManager("Select", ROICounter);
					roiManager("Rename", windowtitlenoext+"_ISVNum");
					Cell1time[rowcounter] = Interval*(getResult("Slice", nResults-1)-getResult("Slice", 0));
					Cell1TotalDis[rowcounter] = Scale*sqrt(((getResult("X", 0)-getResult("X", nResults-1))*(getResult("X", 0)-getResult("X", nResults-1)))+((getResult("Y", 0)-getResult("Y", nResults-1))*(getResult("Y", 0)-getResult("Y", nResults-1))));
					Cell1AvgSpd[rowcounter] = Cell1TotalDis[rowcounter]/Cell1time[rowcounter];
					//loop to calculate individual distance between timepoints
						numTimePoint = nResults;
						for (i = 0; i < nResults-1; i++) {
							Distance[i] = Scale*(sqrt(((getResult("X", i)-getResult("X", i+1))*(getResult("X", i)-getResult("X", i+1)))+((getResult("Y", i)-getResult("Y", i+1))*(getResult("Y", i)-getResult("Y", i+1)))));;
							Time[i] = Interval*(getResult("Slice", i+1)-getResult("Slice", i));
							Speed[i] = Distance[i]/Time[i];
							print("Distance: "+i+", "+Distance[i]+"; Time: "+i+", "+Time[i]+"; Speed: "+i+", "+Speed[i]);
							}
						Array.getStatistics(Speed, min, max, mean, stdDev);
						Cell1Spd[rowcounter] = mean;
					ROICounter = ROICounter+1;
					Array.deleteIndex(Distance, i-1);
					Array.deleteIndex(Time, i-1);
					Array.deleteIndex(Speed, i-1);
					run("Clear Results");
					run("Select None");}

//Blood cell 2 measurement
			setTool("multipoint");
 				waitForUser("Please click on blood cell No. 1 over the time series. Click OK to Proceed.");
				if (selectionType() == -1) {
					}
				else{
					run("Measure");
					roiManager("Add");
					roiManager("Select", ROICounter);
					roiManager("Rename", windowtitlenoext+"_ISVNum");
					Cell2time[rowcounter] = Interval*(getResult("Slice", nResults-1)-getResult("Slice", 0));
					Cell2TotalDis[rowcounter] = Scale*sqrt(((getResult("X", 0)-getResult("X", nResults-1))*(getResult("X", 0)-getResult("X", nResults-1)))+((getResult("Y", 0)-getResult("Y", nResults-1))*(getResult("Y", 0)-getResult("Y", nResults-1))));
					Cell2AvgSpd[rowcounter] = Cell2TotalDis[rowcounter]/Cell2time[rowcounter];
					//loop to calculate individual distance between timepoints
						numTimePoint = nResults;
						for (i = 0; i < nResults-1; i++) {
							Distance[i] = Scale*(sqrt(((getResult("X", i)-getResult("X", i+1))*(getResult("X", i)-getResult("X", i+1)))+((getResult("Y", i)-getResult("Y", i+1))*(getResult("Y", i)-getResult("Y", i+1)))));;
							Time[i] = Interval*(getResult("Slice", i+1)-getResult("Slice", i));
							Speed[i] = Distance[i]/Time[i];
							print("Distance: "+i+", "+Distance[i]+"; Time: "+i+", "+Time[i]+"; Speed: "+i+", "+Speed[i]);
							}
						Array.getStatistics(Speed, min, max, mean, stdDev);
						Cell2Spd[rowcounter] = mean;
					ROICounter = ROICounter+1;
					Array.deleteIndex(Distance, i-1);
					Array.deleteIndex(Time, i-1);
					Array.deleteIndex(Speed, i-1);
					run("Clear Results");
					run("Select None");}

//Blood cell 3 measurement
			setTool("multipoint");
 				waitForUser("Please click on blood cell No. 1 over the time series. Click OK to Proceed.");
				if (selectionType() == -1) {
					}
				else{
					run("Measure");
					roiManager("Add");
					roiManager("Select", ROICounter);
					roiManager("Rename", windowtitlenoext+"_ISVNum");
					Cell3time[rowcounter] = Interval*(getResult("Slice", nResults-1)-getResult("Slice", 0));
					Cell3TotalDis[rowcounter] = Scale*sqrt(((getResult("X", 0)-getResult("X", nResults-1))*(getResult("X", 0)-getResult("X", nResults-1)))+((getResult("Y", 0)-getResult("Y", nResults-1))*(getResult("Y", 0)-getResult("Y", nResults-1))));
					Cell3AvgSpd[rowcounter] = Cell3TotalDis[rowcounter]/Cell3time[rowcounter];
					//loop to calculate individual distance between timepoints
						numTimePoint = nResults;
						for (i = 0; i < nResults-1; i++) {
							Distance[i] = Scale*(sqrt(((getResult("X", i)-getResult("X", i+1))*(getResult("X", i)-getResult("X", i+1)))+((getResult("Y", i)-getResult("Y", i+1))*(getResult("Y", i)-getResult("Y", i+1)))));;
							Time[i] = Interval*(getResult("Slice", i+1)-getResult("Slice", i));
							Speed[i] = Distance[i]/Time[i];
							print("Distance: "+i+", "+Distance[i]+"; Time: "+i+", "+Time[i]+"; Speed: "+i+", "+Speed[i]);
							}
						Array.getStatistics(Speed, min, max, mean, stdDev);
						Cell3Spd[rowcounter] = mean;
					ROICounter = ROICounter+1;
					Array.deleteIndex(Distance, i-1);
					Array.deleteIndex(Time, i-1);
					Array.deleteIndex(Speed, i-1);
					run("Clear Results");
					run("Select None");}					

//Save all ROIs
rowcounter = rowcounter +1;
		if (ROICounter != 0) {
			roiManager("Save", resultsDir+windowtitlenoext+".zip");
			print(windowtitlenoext+" ROIs saved");
			roiManager("reset");
			ROICounter = 0;
			close();
		}
		else{close();}}	
		Array.show("Current Measurements", FileName, Cell1TotalDis, Cell1time, Cell1Spd, Cell1AvgSpd, Cell2TotalDis, Cell2time, Cell2Spd, Cell2AvgSpd, Cell3TotalDis, Cell3time, Cell3Spd, Cell3AvgSpd);
		saveAs(resultsDir+windowtitlenoext+"_measurements.txt");
		selectWindow(windowtitlenoext+"_measurements.txt");
		run("Close");
	}

//Generating CSV file
Table.create("Blood cell movement measurement");
Table.setColumn("File Name", FileName);
Table.setColumn("Cell1 - Total distance travelled (um)", Cell1TotalDis);
Table.setColumn("Cell1 - Total time imaged (ms)", Cell1time);
Table.setColumn("Cell1 - Average speed per timepoint (um/ms)", Cell1Spd);
Table.setColumn("Cell1 - Average speed across timelapse (um/ms)", Cell1AvgSpd);
Table.setColumn("Cell2 - Total distance travelled (um)", Cell2TotalDis);
Table.setColumn("Cell2 - Total time imaged (ms)", Cell2time);
Table.setColumn("Cell2 - Average speed per timepoint (um/ms)", Cell2Spd);
Table.setColumn("Cell2 - Average speed across timelapse (um/ms)", Cell2AvgSpd);
Table.setColumn("Cell3 - Total distance travelled (um)", Cell3TotalDis);
Table.setColumn("Cell3 - Total time imaged (ms)", Cell3time);
Table.setColumn("Cell3 - Average speed per timepoint (um/ms)", Cell3Spd);
Table.setColumn("Cell3 - Average speed across timelapse (um/ms)", Cell3AvgSpd);
Table.save(resultsDir+"blood-cell-movement.csv");
selectWindow("Blood cell movement measurement");
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