import java.util.Timer;
import java.util.TimerTask;

Timer wakeupTimer;
boolean wakeup = false;
volatile boolean transferThread = false;

//void stop() {
//  transferThread = false;
//}

void startWakeupTimer() {
  wakeupTimer = new Timer();
  // define a task to decrement the countdown digit every second
  TimerTask task = new TimerTask() {
    public void run() {
      wakeup = true;
      //println("wakeup");
      //wakeupTimer.cancel();
    }
  };
  // start the timer
  wakeupTimer.scheduleAtFixedRate(task, 0, 5000);  // 5 second interval
}


/**
 * Thread for background load of photos from server
 * This method runs as a thread launched by Processing thread("photoTransfer");
 */
void photoTransferThread() {
  transferThread = true;
  startWakeupTimer();
  while (transferThread) {
    if (wakeup && foundUrl != null) {
      wakeup = false;
      photoTransfer();
      //startWakeupTimer();
    }
  }
}


/**
 * Background transfer of photos from server for storage, unless it is already stored
 */
void photoTransfer() {
  PImage img;
  JSONArray fileList;
  String fileName;
  if (DEBUG) println("PhotoTransfer()");
  fileList = retrievePhotoList();
  if (fileList != null && fileList.size() > 0) {
    for (int fileIndex = 0; fileIndex< fileList.size(); fileIndex++) {
      JSONObject fileObject = fileList.getJSONObject(fileIndex);
      fileName = fileObject.getString("name");
      if (DEBUG) println("fileName="+fileName);
      //if ((fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".png")) &&
      if (fileName.toLowerCase().endsWith(fileType) || (fileName.startsWith(filePrefix)) &&
        (!fileName.toLowerCase().startsWith(".trash"))) {
        String fileUrl = baseUrl + "/" + fileName;
        String outputFileName = "";
        if (parallax > 0) {
          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax) + fileSuffix + fileType;
        } else {
          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + fileSuffix + fileType;
        }
        if (!fileExists(outputFolderPath + File.separator + outputFileName)) {
          img = loadImage(fileUrl);
          if (DEBUG) println("loading stored image "+fileUrl);
          if (img != null) {
            float ar = (float)img.width / (float) img.height;
            outputFileName = fileName.substring(0);
            boolean update = false;
            if (ar >= 2.0) {
              outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax) + fileSuffix + fileType;
              update = true;
            }
            String outputPath = outputFolderPath + File.separator + outputFileName;
            if (DEBUG) println("outputFileName="+outputFileName);
            if (DEBUG) println("outputPath="+outputPath);
            if (DEBUG) println("fileName="+fileName);

            // modify parallax from infinity background
            if (update) {
              img = updateParallax(img, parallax);
              // save parallax adjusted image
              img.save(outputPath);
              if (DEBUG) println("saved Image outputFilePath="+outputPath);
            }
          }
        }
      } else { // ignore image and remove from fileList
        fileList.remove(fileIndex);
        fileIndex--;
        if (fileIndex  < 0) fileIndex = 0;
      }
    } // for
  }
}

// ------------------------------------------------------------------
// NOT USED this is for archive reference only
void drawPhotoTransfer() {
  if (outputFolderPath.length()> 20)
    text("Image Save Folder: "+ outputFolderPath.substring(20), 20, 6*IGui.FONT_SIZE);
  else
    text("Image Save Folder: ", 20, 6*IGui.FONT_SIZE);

  String header = title + " - Version " + version + " - " + credits;
  if (!downloadStarted) {
    text(header, 20, IGui.FONT_SIZE/2, width, IGui.FONT_SIZE);
  }

  if (downloadStarted && !done) {
    if (fileList == null) fileList = retrievePhotoList();
    if (fileList != null && currentFileIndex < fileList.size()) {
      JSONObject fileObject = fileList.getJSONObject(currentFileIndex);
      fileName = fileObject.getString("name");
      if (DEBUG) println("fileName="+fileName);
      //  if (fileName.endsWith(".jpg") && (!fileName.startsWith(".trash"))) {
      //    valid = true;
      //  } else {
      //    currentFileIndex++;
      //    if (currentFileIndex >= fileList.size()) {
      //      return;
      //    }
      //  }
      //}
      String fileUrl = baseUrl + "/" + fileName;
      String outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+"_2x1.jpg";
      String outFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_2x1.jpg";
      if (!fileExists(outputFolderPath + File.separator + outFileName)) {
        try {
          saveImageFromUrl(fileUrl, outputFolderPath + File.separator +outFileName);
          if (DEBUG) println("Image downloaded and saved as " + outFileName);
        }
        catch (IOException e) {
          e.printStackTrace();
        }
      } else {
        if (DEBUG) println("Skipping existing file: " + outFileName);
      }
      if (!fileExists(outputFolderPath + File.separator + outputFileName)) {
        currentImage = loadImage(fileUrl);
        if (DEBUG) println("loading "+fileUrl);
      } else {
        if (DEBUG) println("Skipping existing file: " + fileName);
        currentFileIndex++;
        currentImage = null;
        return;
      }

      if (currentImage != null) {
        float ar = (float)currentImage.width / (float) currentImage.height;
        boolean update = false;
        if (ar >= 2.0) {
          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+"_2x1.jpg";
          update = true;
        }
        if (DEBUG) println("outputFileName="+outputFileName);
        String outputPath = outputFolderPath + File.separator + outputFileName;
        String cardOutputPath = outputFolderPath + File.separator + fileName.substring(0, fileName.lastIndexOf('.')) + "_c"+str(parallax)+"_2x1.jpg";
        // save original image
        if (DEBUG) println("not saved outputFilePath="+outputFolderPath + File.separator + fileName);
        text("Not 3D Image", width/2, 2*height/3);
        //currentImage.save(outputFolderPath + File.separator + fileName);
        // modify parallax from infinity background
        if (update) {
          currentImage = updateParallax(currentImage, parallax);
          // save parallax adjusted image
          if (DEBUG) println("saved outputFilePath="+outputPath);
          currentImage.save(outputPath);
          //PImage card = cropFor3DMaskPrint(currentImage, printAspectRatio, printPxWidth, printPxHeight);
          PImage card = cropFor3DMaskPrint(currentImage, printAspectRatio, int((((float)currentImage.height)*printAspectRatio)), currentImage.height);
          card.save(cardOutputPath);
        } else {
          if (DEBUG) println("Skipping existing file: "+outputFileName);
        }
        currentFileIndex++;
        fill(0, 0, 255);
        text("Downloading " + str(currentFileIndex) + " of " + str(fileList.size()), width/2, 9*IGui.FONT_SIZE);
      }
    } else {
      done = true;
      if (DEBUG) println("Done Photo Transfer............");
      downloadStarted = false;
    }
  }

  if (currentImage != null) {
    float ar = (float) currentImage.width / (float) currentImage.height;
    image(currentImage, 0, height/2, ar*(height/2), height/2);
    //image(currentImage, 0, height-(float)width/ar, width , (float)width/ar);
  }

  if (started && done) {
    fill(0);
    textSize(IGui.FONT_SIZE);
    if (outputFolderPath.length()> 20) {
      text("Done Saving in Directory: " + outputFolderPath.substring(20), 20, height/3);
      text("Last Filename: "+fileName, 20, height/3 + 2*IGui.FONT_SIZE);
    }
  }

  if (foundUrl == null) {
    showText("No HTTP Photo Server found", 3);
  } else {
    showText("Transfering Photos from http://"+foundUrl, 3);  // set full url
  }
}
