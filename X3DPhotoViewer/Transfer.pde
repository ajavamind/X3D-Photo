// Automatic background transfer of photos from XREAL Beam Pro camera

import java.util.Timer;
import java.util.TimerTask;

Timer wakeupTimer;
volatile boolean wakeup = false;
volatile boolean transferThread = false;
volatile boolean transferRunning = false;

void startWakeupTimer() {
  wakeupTimer = new Timer();
  // define a task to decrement the countdown digit every second
  TimerTask task = new TimerTask() {
    public void run() {
      wakeup = true;
      if (DEBUG) println("===Wakeup timer=============");
      //wakeupTimer.cancel();
    }
  };
  // start the timer
  wakeupTimer.scheduleAtFixedRate(task, 0, 5000);  // 5 second interval
}

void startTransfer() {
  thread("photoTransferThread");
}

void stopTransfer() {
  wakeupTimer.cancel();
  transferThread = false;
  transferRunning = false;
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
      if (!transferRunning) {
        photoTransfer();
      }
    }
  }
}

// set up options selected for converting stereo photo
void setupTransferOptions() {
  int options = 0;
  options = gui.optionDropDownList.getItemValue();
  if ((options & OPTION_NONE) != 0) {
    fileSuffix = "";
  } else if ((options & OPTION_2x1) != 0) {
    fileSuffix = "_2x1";
  } else if ((options & OPTION_ANAGLYPH) != 0) {
    fileSuffix = "_ana";
  } else if ((options & OPTION_CARD) != 0) {
    fileSuffix = "_card";
  }
  options = gui.prefixDropDownList.getItemValue();
  if ((options & PREFIX_ANY) != 0) {
    filePrefix = "";
  } else if ((options & PREFIX_SV) != 0) {
    filePrefix = STEREO_PREFIX;
  } else if ((options & PREFIX_IMG) != 0) {
    filePrefix = MONO_PREFIX;
  } else if ((options & PREFIX_DATE) != 0) {
    filePrefix = prefixNames[2];
  }
  if (DEBUG) println("set options filePrefix="+filePrefix+ " fileSuffix="+fileSuffix);
}

/**
 * Background transfer of photos from server for storage, unless it is already stored
 */
void photoTransfer() {
  PImage img=null;
  JSONArray tfileList;
  String fileName;
  String outputFileName = "";
  transferRunning = true;
  if (DEBUG) println("PhotoTransfer()");

  setupTransferOptions();

  tfileList = retrievePhotoList();
  if (tfileList != null && tfileList.size() > 0) {
    for (int fileIndex = 0; fileIndex< tfileList.size(); fileIndex++) {
      JSONObject fileObject = tfileList.getJSONObject(fileIndex);
      fileName = fileObject.getString("name");
      if (DEBUG) println("Transfer fileName="+fileName+" prefix="+filePrefix+ " suffix="+fileSuffix);

      if ((!fileName.toLowerCase().startsWith(".trash")) && (fileName.toLowerCase().endsWith(fileType))) {
        if (fileName.startsWith(filePrefix) || filePrefix.equals("") ) {
          String fileUrl = baseUrl + "/" + fileName;
          String sParallax = "";
          if (parallax != 0 && filePrefix.equals(STEREO_PREFIX)) {
            sParallax = "_p"+str(parallax);
          }
          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + sParallax + fileSuffix + fileType;
          if (DEBUG) println("Transfer outputFileName="+outputFileName);
          if (DEBUG) println("Transfer outputFolderPath=" +outputFolderPath + File.separator+outputFileName);
          if (!fileExists(outputFolderPath + File.separator + outputFileName)) {
            img = loadImage(fileUrl);
            if (DEBUG) println("loading stored image "+fileUrl);
            if (img != null) {
              outputFileName = fileName.substring(0);
              boolean update = false;
              if (filePrefix.equals(STEREO_PREFIX)) {
                outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + sParallax + fileSuffix + fileType;
                update = true;
              }
              String outputPath = outputFolderPath + File.separator + outputFileName;
              if (DEBUG) println("outputFileName="+outputFileName);
              if (DEBUG) println("outputPath="+outputPath);
              if (DEBUG) println("fileName="+fileName);

              // modify parallax from infinity background
              if (update) {
                img = updateParallax(img, parallax);
                // parallax adjusted image
              }
              img.save(outputPath);
              if (DEBUG) println("saved Image outputFilePath="+outputPath);
            }
          }
        }
      } else { // ignore image and remove from tfileList
        tfileList.remove(fileIndex);
        fileIndex--;
        if (fileIndex  < 0) fileIndex = 0;
      }
      fileList = tfileList;
    } // for
  }
    
  // update screen with last image
  if ((tfileList.size() -1) > currentFileIndex) {
    if (img != null) {
      currentFileIndex = tfileList.size() -1;
      currentImage = img;
      fileName = outputFileName;
    }
  }
  transferRunning = false;
  if (DEBUG) println("Transfer Finished");
}

/**
 * Retrieve Photo list JSON file from HTTP photo server
 * Assumes Android app "Simple HTTP Server PLUS" is running on an Android camera device connected to same network as this app.
 *
 */
JSONArray retrievePhotoList() {
  int before = 0;
  int after = 0;
  JSONArray fileList = null;
  if (foundUrl == null) return null;
  baseUrl = "http://" + foundUrl + ":" + str(port);
  String jsonUrl = baseUrl + "/api/file/list?path=/";
  if (DEBUG) println("jsonUrl="+jsonUrl);
  try {
    fileList = loadJSONArray(jsonUrl);
  }
  catch (Exception e) {
    fileList = null;
    return fileList;
  }
  // remove files from list that are not viewable
  before = fileList.size();
  for (int i=0; i<fileList.size(); i++) {
    JSONObject fileObject = fileList.getJSONObject(i);
    String fileName = fileObject.getString("name");
    if ((fileName.toLowerCase().endsWith(".jpg") ||
      fileName.toLowerCase().endsWith(".png") ||
      fileName.toLowerCase().endsWith(".jps")
      ) && (!fileName.startsWith(".trash")) && fileName.startsWith(filePrefix)) {
    } else {
      if (DEBUG) println("removed fileName="+fileName);
      fileList.remove(i);
      i--;
    }
  }
  after = fileList.size();
  if (fileList != null && currentFileIndex >= fileList.size()) {
    currentFileIndex = fileList.size() - 1;
  }
  if (DEBUG) println("before="+before + " after="+after);
  return fileList;
}

// ------------------------------------------------------------------
// NOT USED - this is for archive reference only
//void drawPhotoTransfer() {
//  if (outputFolderPath.length()> 20)
//    text("Image Save Folder: "+ outputFolderPath.substring(20), 20, 6*IGui.FONT_SIZE);
//  else
//    text("Image Save Folder: ", 20, 6*IGui.FONT_SIZE);

//  String header = title + " - Version " + version + " - " + credits;
//  if (!downloadStarted) {
//    text(header, 20, IGui.FONT_SIZE/2, width, IGui.FONT_SIZE);
//  }

//  if (downloadStarted && !done) {
//    if (fileList == null) fileList = retrievePhotoList();
//    if (fileList != null && currentFileIndex < fileList.size()) {
//      JSONObject fileObject = fileList.getJSONObject(currentFileIndex);
//      fileName = fileObject.getString("name");
//      if (DEBUG) println("fileName="+fileName);
//      //  if (fileName.endsWith(".jpg") && (!fileName.startsWith(".trash"))) {
//      //    valid = true;
//      //  } else {
//      //    currentFileIndex++;
//      //    if (currentFileIndex >= fileList.size()) {
//      //      return;
//      //    }
//      //  }
//      //}
//      String fileUrl = baseUrl + "/" + fileName;
//      String outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+"_2x1.jpg";
//      String outFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_2x1.jpg";
//      if (!fileExists(outputFolderPath + File.separator + outFileName)) {
//        try {
//          saveImageFromUrl(fileUrl, outputFolderPath + File.separator +outFileName);
//          if (DEBUG) println("Image downloaded and saved as " + outFileName);
//        }
//        catch (IOException e) {
//          e.printStackTrace();
//        }
//      } else {
//        if (DEBUG) println("Skipping existing file: " + outFileName);
//      }
//      if (!fileExists(outputFolderPath + File.separator + outputFileName)) {
//        currentImage = loadImage(fileUrl);
//        if (DEBUG) println("loading "+fileUrl);
//      } else {
//        if (DEBUG) println("Skipping existing file: " + fileName);
//        currentFileIndex++;
//        currentImage = null;
//        return;
//      }

//      if (currentImage != null) {
//        float ar = (float)currentImage.width / (float) currentImage.height;
//        boolean update = false;
//        if (ar >= 2.0) {
//          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+"_2x1.jpg";
//          update = true;
//        }
//        if (DEBUG) println("outputFileName="+outputFileName);
//        String outputPath = outputFolderPath + File.separator + outputFileName;
//        String cardOutputPath = outputFolderPath + File.separator + fileName.substring(0, fileName.lastIndexOf('.')) + "_c"+str(parallax)+"_2x1.jpg";
//        // save original image
//        if (DEBUG) println("not saved outputFilePath="+outputFolderPath + File.separator + fileName);
//        text("Not 3D Image", width/2, 2*height/3);
//        //currentImage.save(outputFolderPath + File.separator + fileName);
//        // modify parallax from infinity background
//        if (update) {
//          currentImage = updateParallax(currentImage, parallax);
//          // save parallax adjusted image
//          if (DEBUG) println("saved outputFilePath="+outputPath);
//          currentImage.save(outputPath);
//          //PImage card = cropFor3DMaskPrint(currentImage, printAspectRatio, printPxWidth, printPxHeight);
//          PImage card = cropFor3DMaskPrint(currentImage, printAspectRatio, int((((float)currentImage.height)*printAspectRatio)), currentImage.height);
//          card.save(cardOutputPath);
//        } else {
//          if (DEBUG) println("Skipping existing file: "+outputFileName);
//        }
//        currentFileIndex++;
//        fill(0, 0, 255);
//        text("Downloading " + str(currentFileIndex) + " of " + str(fileList.size()), width/2, 9*IGui.FONT_SIZE);
//      }
//    } else {
//      done = true;
//      if (DEBUG) println("Done Photo Transfer............");
//      downloadStarted = false;
//    }
//  }

//  if (currentImage != null) {
//    float ar = (float) currentImage.width / (float) currentImage.height;
//    image(currentImage, 0, height/2, ar*(height/2), height/2);
//    //image(currentImage, 0, height-(float)width/ar, width , (float)width/ar);
//  }

//  if (started && done) {
//    fill(0);
//    textSize(IGui.FONT_SIZE);
//    if (outputFolderPath.length()> 20) {
//      text("Done Saving in Directory: " + outputFolderPath.substring(20), 20, height/3);
//      text("Last Filename: "+fileName, 20, height/3 + 2*IGui.FONT_SIZE);
//    }
//  }

//  if (foundUrl == null) {
//    showText("No HTTP Photo Server found", 3);
//  } else {
//    showText("Transfering Photos from http://"+foundUrl, 3);  // set full url
//  }
//}
