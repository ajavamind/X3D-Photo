// java sketch that downloads image files from a web server using a base url,
// for example: http://[xxx.xxx.xxx.xxx]:8333 default WiFi network for the device running this app
// The sketch has a text entry line for changing the base url.
// The sketch has a text entry line for the output folder path where to store the downloaded images.
// The sketch has a button that starts the download and image processing.
// These GUI items are shown in draw()
// Use the url: baseUrl/api/file/list?path=/ to load a json file that lists the files to download.
// The json file is a json array as in this example:
// [{"name":"SV_20240904_152557.jpg","length":"3.5 MB","modified":1725477958,"directory":false}]
// Use the processing json array and object functions to work with json data.
// The expected format of the images is a stereoscopic side by side left/right images in the file.
// call a function named updateParallax that converts the sbs Pimage into left/right PImages and
// change the vertical offset and horizontal parallax offset and returning the cropped converted sbs image.
// do not code this function just call it.
// Add a suffix "_2x1" to the original image filename, for example, image.jpg becomes image_2x1.jpg
// save the updated image with the filename suffix addition in the output folder.
// Repeat for all files parsed from the json file array list, one for each draw() cycle.
// The image files are downloaded from the server as in this example url:
// baseUrl/SV_20240904_152557.jpg
// use loadImage processing function to download.
// show the images in draw while reading from the server
// When finished write "Done" + output folder path and wait for user to exit.
//
// This sketch includes a text entry for the base URL, a text entry for the output folder path,
// and a button to start the download and image processing. It uses Processing's JSON functions
// to parse the JSON file and download the images.

// Processing imports
import select.files.*;
import processing.core.PImage;
import processing.data.JSONArray;
import processing.data.JSONObject;

// Java imports
import java.io.File;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.Socket;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.io.*;
import java.net.*;

// ANDROID imports
import android.content.Context;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
import android.view.inputmethod.InputMethodManager;
import android.app.Activity;
import android.os.Build;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;

boolean DEBUG = true;
String title="X3D Photo Viewer";
String version = "1.03";
String credits = "Andy Modla";

String host = "127.0.0.1";
String searchHost = "0.0.0.0";
volatile int hostlsb = 0;
volatile boolean stopThread = false;
String baseUrl = "http://192.168.1.101";  // default example
String outputFolderPath = "";
String configFile = "X3DPhotoViewer.txt";
volatile boolean downloadStarted = false;
JSONArray fileList;
int currentFileIndex = 0;
volatile PImage currentImage;
boolean done = false;
String urlSearch;
Gui gui;
int port = 8333;  // expected port for HTTP image server
int timeout = 500; // 0.5 second
boolean ready = false;
volatile String foundUrl = null;
String fileName="";
int parallax = 237;  // 0; // standard adjustment for Xreal Beam Pro stereo window
float printAspectRatio = 6.0/4.0;  // default aspect ratio 6x4 inch print landscape orientation
int printPxWidth = 1800;
int printPxHeight = 1200;

volatile boolean started = false;
volatile boolean first = false;
boolean getFolder = false;

void settings() {
  //fullScreen();
  size(1920, 1080);
}

void setup() {
  background(200);
  fill(IGui.black); // black text and graphics
  frameRate(30);
  orientation(LANDSCAPE);

  // Clear the cache of any files from previous run
  //clearCache();
  outputFolderPath = File.separator + "storage" + File.separator + "emulated" + File.separator + "0"
    + File.separator + "Pictures" + File.separator + "X3D";
  openFileSystem();
  //writeSavedHost(configFile, "0.0.0.0");  // for debug only, reset saved server ip address

  host = readSavedHost(configFile);
  if (DEBUG) println("Saved host="+host+ " hostlsb="+hostlsb);
  PFont font = createFont("arial", IGui.FONT_SIZE);
  textFont(font);
  textSize(IGui.FONT_SIZE);
  textAlign(CENTER, CENTER);

  gui = new Gui();
  gui.create(this);
  gui.createGui();

  urlSearch = "Searching for HTTP Photo Server";

  // Ensure we are on the main thread
  getActivity().runOnUiThread(new Runnable() {
    @Override
      public void run() {
      hideSystemUI();
    }
  }
  );

  // find server IP address
  thread("searchForServer");
} // setup()

void hideSystemUI() {
  Activity activity = getActivity();
  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
    WindowInsetsController insetsController = activity.getWindow().getInsetsController();
    if (insetsController != null) {
      insetsController.hide(WindowInsets.Type.systemBars());
      insetsController.setSystemBarsBehavior(
        WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
    }
  } else {
    activity.getWindow().getDecorView().setSystemUiVisibility(
      View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
      | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
      | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
      | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
      | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
      | View.SYSTEM_UI_FLAG_FULLSCREEN);
  }
}

String readSavedHost(String filename) {
  String result = "0.0.0.0";
  String[] lines = loadStrings(filename);
  if (lines != null) {
    result = lines[0];
  }
  try {
    hostlsb = int(result.substring(result.lastIndexOf(".")+1));
  }
  catch (Exception e) {
    hostlsb = 0;
  }

  return result;
}

void writeSavedHost(String filename, String url) {
  String[] lines = new String[4];
  lines[0] = url;
  lines[1] = str(port);
  lines[2] = outputFolderPath;
  lines[3] = "";
  saveStrings(filename, lines);
}

void searchForServer() {
  // Get the local IP address during output folder selection
  if (DEBUG) println("Thread searchForServer()");
  String found = null;
  String localIp = getLocalIpAddress();
  if (DEBUG) println("Local IP: " + localIp +" host="+host + " hostlsb="+hostlsb);
  // Scan the network
  if (hostlsb != 0) {
    found = scanNetwork(localIp, port, hostlsb, hostlsb, timeout);  // inclusive ip range for port
  }
  if (found == null && !stopThread) found = scanNetwork(localIp, port, 1, 99, timeout); // inclusive port range
  if (found == null && !stopThread) found = scanNetwork(localIp, port, 100, 199, timeout);  // inclusive port range
  if (found == null && !stopThread) found = scanNetwork(localIp, port, 200, 254, timeout); // inclusive port range
  foundUrl = found;
  writeSavedHost(configFile, foundUrl);
  if (DEBUG) println("Done Server search Found: "+foundUrl);
}

void startDownload() {
  done = false;
  fileList = null;
  downloadStarted = true;
  started = true;
  first = false;
  if (DEBUG) println("startDownload ......");
}

void draw() {
  if (getFolder) {
    selectSaveFolder();
    getFolder = false;
  } else {
    background(200);
    String header = title + " - Version " + version + " - " + credits;
    text(header, 0, IGui.FONT_SIZE/3, width, IGui.FONT_SIZE);
    //drawPhotoTransfer();
    drawPhotoViewer();
    if (foundUrl == null) {
      showText("Checking For Server At: " + searchHost, 1);
    } else {
      showText("Server Found At: " + foundUrl, 1);
    }
    gui.displayMenuBar();
  }

  // process key and mouse inputs on this main sketch loop
  lastKeyCode = keyUpdate();
} // draw()

void drawPhotoViewer() {
  if (first) {
    startDownload();
  }

  if (downloadStarted && !done) {
    if (fileList == null) fileList = retrievePhotoList();
    if (fileList != null && currentFileIndex < fileList.size()) {
      JSONObject fileObject = fileList.getJSONObject(currentFileIndex);
      fileName = fileObject.getString("name");
      if (DEBUG) println("fileName="+fileName);
      //  if ((fileName.toLowerCase().endsWith(".jpg") ||
      //    fileName.toLowerCase().endsWith(".png") ||
      //    fileName.toLowerCase().endsWith(".jps")
      //    ) && (!fileName.startsWith(".trash"))) {
      //    valid = true;
      //  } else {
      //    fileList.remove(currentFileIndex);
      //    currentFileIndex--;
      //    if (currentFileIndex  < 0) currentFileIndex = 0;
      //    if (currentFileIndex >= fileList.size()) {
      //      return;
      //    }
      //    return;
      //  }
      //}
      String fileUrl = baseUrl + "/" + fileName;
      String outputFileName = "";
      boolean filePresent = false;
      if (parallax > 0) {
        outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+"_2x1.jpg";
      } else {
        outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_2x1.jpg";
      }
      if (!fileExists(outputFolderPath + File.separator + outputFileName)) {
        //try {
        //  saveImageFromUrl(fileUrl, outputFolderPath + File.separator +outputFileName);
        //  if (DEBUG) println("Image downloaded and saved as " + outputFileName);
        //}
        //catch (IOException e) {
        //  e.printStackTrace();
        //}
      } else {
        if (DEBUG) println("Skip write existing file: " + outputFileName);
        filePresent = true;
      }

      try {
        URL url = new URL(fileUrl);
        InputStream inputStream = url.openStream();
        inputStream.close();
      }
      catch (Exception fnf) {
        // File not found exception
        if (DEBUG) println("Stream not opening: "+fnf.toString());
        first = true; // force reload
        return;
      }
      if (filePresent) {
        if (DEBUG) println("loading stored image "+ outputFolderPath + File.separator +outputFileName);
        currentImage = loadImage(outputFolderPath + File.separator +outputFileName);
      } else {
        currentImage = loadImage(fileUrl);
        if (DEBUG) println("loading stored image "+fileUrl);
      }
      //} else {
      //  if (DEBUG) println("Skipping existing file: " + fileName);
      //  currentFileIndex++;
      //  if (currentFileIndex >= fileList.size()) {
      //    currentFileIndex = 0;
      //  }
      //  currentImage = null;
      //  return;
      //}

      if (currentImage != null) {
        float ar = (float)currentImage.width / (float) currentImage.height;
        outputFileName = fileName.substring(0);
        boolean update = false;
        if (ar >= 2.0) {
          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+"_2x1.jpg";
          update = true;
        }
        String outputPath = outputFolderPath + File.separator + outputFileName;
        if (DEBUG) println("outputFileName="+outputFileName);
        if (DEBUG) println("outputPath="+outputPath);
        if (DEBUG) println("fileName="+fileName);
        String cardOutputPath = outputFolderPath + File.separator + fileName.substring(0, fileName.lastIndexOf('.')) + "_c"+str(parallax)+"_2x1.jpg";
        // save original image
        //if (DEBUG) println("not saved outputFilePath="+outputFolderPath + File.separator + fileName);
        //text("Not 3D Image", width/2, 2*height/3);
        //currentImage.save(outputFolderPath + File.separator + fileName);
        // modify parallax from infinity background
        if (update && !filePresent) {
          currentImage = updateParallax(currentImage, parallax);
          // save parallax adjusted image
          currentImage.save(outputPath);
          if (DEBUG) println("saved outputFilePath="+outputPath);
          //PImage card = cropFor3DMaskPrint(currentImage, printAspectRatio, printPxWidth, printPxHeight);
          //PImage card = cropFor3DMaskPrint(currentImage, printAspectRatio, int((((float)currentImage.height)*printAspectRatio)), currentImage.height);
          //card.save(cardOutputPath);
        } else {
          if (DEBUG) println("Skipping output of existing file: "+outputFileName);
        }
        showText("Downloading " + str(currentFileIndex) + " of " + str(fileList.size()), 9);
      }
      done = true;
    }
  }
  if (currentImage != null) {
    float ar = (float) currentImage.width / (float) currentImage.height;
    image(currentImage, 0, (height-(float)width/ar)/2, width, (float)width/ar);
    //image(currentImage, 0, height-(float)width/ar, width , (float)width/ar);
  }

  if (foundUrl == null) {
    showText("Searching for HTTP Photo Server.", 2);
  } else {
    if (fileList != null && fileList.size() > 0) {
      String fText = str(currentFileIndex+1) + " of " +fileList.size() + " " + fileName;
      show3DText(fText, 2);
    }
  }
}

void showText(String message, int row) {
  fill(0);
  textSize(IGui.FONT_SIZE);
  text(message, 0, height - (row)*IGui.FONT_SIZE, width, IGui.FONT_SIZE);
}

void show3DText(String message, int row) {
  fill(0, 0, 255);
  textSize(IGui.FONT_SIZE);
  text(message, 0, height- (row)*IGui.FONT_SIZE, width/2, IGui.FONT_SIZE);
  text(message, -10 +width/2, height- (row)*IGui.FONT_SIZE, width/2, IGui.FONT_SIZE);
}

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
      ) && (!fileName.startsWith(".trash"))) {
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

/**
 * Change SBS stereo photo image parallax (displacement shift)
 */
PImage updateParallax(PImage sbsImage, int parallax) {
  // Placeholder for the actual implementation of the updateParallax function
  float ar = (float)sbsImage.width / (float) sbsImage.height;
  if (ar >= 2.0) {
    PImage result = alignSBS(sbsImage, parallax, 0, false);
    if (DEBUG) println("updateParallax" + " w="+sbsImage.width +" h="+sbsImage.height + " rw="+result.width +" rh="+result.height);
    return result;
  }
  return sbsImage;
}

/**
 * Align side-by-side LR image by moving right image using offsets.
 * Fill unused area with black (0)
 * PImage img Input image with left and right SBS eye views
 * horzOffset camera alignment horizontally to adjust stereo window placement
 * vertOffset adjust camera misalignment vertically for stereo
 * boolean mirror Swap image left and right eye pixel sources
 */
public PImage alignSBS(PImage img, int horzOffset, int vertOffset, boolean mirror) {
  int vert = vertOffset;
  int horz = horzOffset;
  //horz = 0; // test
  //vert = 0;
  int w2 = img.width;
  int w = img.width/2;
  int h = img.height;
  int dw = w -abs(horz);
  int dw2 = 2*dw;
  int dh = h-abs(vert);
  int topd = dw2*dh;
  int tops = w2 *h;
  PImage temp = createImage(dw2, dh, RGB);
  img.loadPixels();
  temp.loadPixels();
  int idl = 0; // computed left destination index into pixel array of image
  int idr = 0; // computed right destination index into pixel array of image
  int isl = 0; // computed left source index into pixel array of image
  int isr = 0; // computed right source index into pixel array of image
  for (int j=0; j<dh; j++) {  // j vertical scan rows
    for (int i=0; i<dw; i++) { // i horizontal scan columns
      if (mirror) {
        isl = (j)*w2 + i + horz;
        isr = (j-vert)*w2 + i + w;
      } else {
        isl = (j-vert)*w2 + i + horz;
        isr = (j)*w2 + i + w ;
      }
      idl = j*dw2 + i;  // adjust index for horzizonal and vertical offsets
      idr = j*dw2 + i + dw;  // adjust index for horzizonal and vertical offsets
      if (isl > tops || isl < 0) {
        if (DEBUG) println(" out of bounds tops= "+i+" "+j);
      } else {
        temp.pixels[idl] = img.pixels[isl]; // when in bounds of pixel array, store color
        temp.pixels[idr] = img.pixels[isr]; // when in bounds of pixel array, store color
      }
    }
  }
  temp.updatePixels();
  return temp;
}

// crop for 3D mask printing stereoscope 6x4
PImage cropFor3DMaskPrint(PImage src, float printAspectRatio, int printPxWidth, int printPxHeight) {
  if (DEBUG) println("cropFor3DMaskPrint print AR="+printAspectRatio);
  if (DEBUG) println("cropFor3DMaskPrint image width="+src.width + " height="+src.height);
  // create a new PImage
  float bw = (printPxWidth); // pixel width for printer at 300 dpi
  if (DEBUG) println("bw="+bw);
  int iw = int(bw/2);
  int sx = ((src.width/2)-iw)/2;
  int sy = 0;
  int sw = iw;
  int sh = src.height;
  int dx = 0;
  int dy = 0;
  int dw = sw;
  int dh = src.height;
  int dd = (printPxHeight-dh)/2;
  PImage img;
  PGraphics pg = createGraphics(printPxWidth, printPxHeight);
  if (DEBUG) println(" sx="+sx+" sy="+sy+" sw="+sw+" sh="+sh +" dx="+dx+" dy="+dy+" dw="+dw+" dh="+dh);
  //img.copy(src, sx, sy, sw, sh, dx, dy, dw, dh);  // cropped left eye copy
  pg.beginDraw();
  pg.background(255); // white
  pg.copy(src, sx, sy, sw, sh, dx, dy+dd, dw, dh);  // cropped left eye copy
  sx = sx + src.width/2;
  dx = dx + iw;
  if (DEBUG) println(" sx="+sx+" sy="+sy+" sw="+sw+" sh="+sh +" dx="+dx+" dy="+dy+" dw="+dw+" dh="+dh);
  pg.copy(src, sx, sy, sw, sh, dx, dy+dd, dw, dh);  // cropped right eye copy

  // draw header and footer text

  // header
  //pg.fill(0);  // black text
  //pg.textSize(fontSize);
  //String headerText = eventText;
  //float hw = round(((printPxWidth/2)-pg.textWidth(headerText))/2.0);
  //if (DEBUG) println("headerText width="+hw+" "+headerText);
  //pg.text(headerText, hw+printParallax, fontSize );
  //pg.text(headerText, dx + hw, fontSize );

  //// footer
  //pg.fill(0);  // black text
  //pg.textSize(fontSize);
  //if (DEBUG) println("eventInfoText="+eventInfoText);
  //String footerText = eventInfoText;
  //float fw = round(((printPxWidth/2)-pg.textWidth(footerText))/2.0);
  //if (DEBUG) println("footerText width="+fw + " "+footerText);
  //pg.text(footerText, fw+printParallax, dh + dd + fontSize );
  //pg.text(footerText, dx + fw, dh + dd + fontSize );
  pg.endDraw();

  img = pg.copy();
  return img;
}

//void saveImageFromUrl(String imageUrl, String destinationFile) throws IOException {
//  if (DEBUG) println("saveImageFromUrl url="+imageUrl + " destination="+destinationFile);
//  URL url = new URL(imageUrl);
//  InputStream inputStream = url.openStream();
//  OutputStream outputStream = new FileOutputStream(destinationFile);

//  byte[] buffer = new byte[2048];
//  int bytesRead;

//  while ((bytesRead = inputStream.read(buffer)) != -1) {
//    outputStream.write(buffer, 0, bytesRead);
//  }

//  inputStream.close();
//  outputStream.close();
//}

void saveImageFromUrl(String imageUrl, String outputFile) throws IOException {
  if (DEBUG) println("saveImageFromUrl url="+imageUrl + " destination="+outputFile);

  try (InputStream inputStream = new URL(imageUrl).openStream();
  FileOutputStream outputStream = new FileOutputStream(outputFile)) {

    byte[] buffer = new byte[8192];
    int bytesRead;
    while ((bytesRead = inputStream.read(buffer)) != -1) {
      outputStream.write(buffer, 0, bytesRead);
    }
    inputStream.close();
    outputStream.close();
  }
}

boolean fileExists(String fileNamePath) {
  boolean present = false;
  File file = new File(fileNamePath);
  if (file.isFile()) present = true;
  return present;
}

// ANDROID

boolean grantedRead = false;
boolean grantedWrite = false;

SelectLibrary files;

void openFileSystem() {
  requestPermissions();
  files = new SelectLibrary(this);
}

//void showSoftKeyboard() {
//  Activity activity = (Activity) this.getActivity();
//  activity.runOnUiThread(new Runnable() {
//    public void run() {
//      // Get the InputMethodManager
//      InputMethodManager imm = (InputMethodManager) activity.getSystemService(Context.INPUT_METHOD_SERVICE);

//      // Show the soft keyboard
//      imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
//    }
//  }
//  );
//}

public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
  if (DEBUG) println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
  for (int i=0; i<permissions.length; i++) {
    if (DEBUG) println(permissions[i]);
  }
}

void requestPermissions() {
  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
  }
  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
  }
}

void handleRead(boolean granted) {
  if (granted) {
    grantedRead = granted;
    if (DEBUG) println("Granted read permissions.");
  } else {
    if (DEBUG) println("Does not have permission to read external storage.");
  }
}

void handleWrite(boolean granted) {
  if (granted) {
    grantedWrite = granted;
    if (DEBUG) println("Granted write permissions.");
  } else {
    if (DEBUG) println("Does not have permission to write external storage.");
  }
}

void selectSaveFolder() {
  files.selectFolder("Select Save Folder", "folderSelected");
}

// Code common to Android and Java platforms
// do not comment out

void folderSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("Window closed or canceled.");
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    outputFolderPath = selection.getAbsolutePath();
  }
  getFolder = false;
}

String getLocalIpAddress() {
  try {
    for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
      NetworkInterface intf = en.nextElement();
      for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
        InetAddress inetAddress = enumIpAddr.nextElement();
        if (!inetAddress.isLoopbackAddress() && inetAddress instanceof java.net.Inet4Address) {
          return inetAddress.getHostAddress();
        }
      }
    }
  }
  catch (Exception ex) {
    ex.printStackTrace();
  }
  return null;
}

String scanNetwork(String localIp, int port, int low, int high, int timeout) {
  searchHost = "127.0.0.1";
  //try {
  //  InetAddress inetAddress = InetAddress.getByName(host);
  //  if (isPortOpen(inetAddress, port, timeout)) {
  //    String hostName = inetAddress.getHostName();
  //    if (DEBUG) println("Host: " + hostName + " port " + port + " IP: " + host);
  //    return host;
  //  }
  //}
  //catch (Exception ex) {
  //  ex.printStackTrace();
  //}

  if (low < 1 || high >=255) {
    if (DEBUG) println("error range should be 1 to 254");
    return null;
  }

  if (localIp == null) {
    if (DEBUG) println("Unable to get local IP address");
    return null;
  }

  String subnet = localIp.substring(0, localIp.lastIndexOf('.'));
  // look for Android server at port
  for (int i = low; i <= high; i++) {
    searchHost = subnet + "." + i;
    if (DEBUG) println("try "+searchHost);
    try {
      InetAddress inetAddress = InetAddress.getByName(searchHost);
      if (isPortOpen(inetAddress, port, timeout)) {
        String hostName = inetAddress.getHostName();
        if (DEBUG) println("Host: " + hostName + " port " + port + " IP: " + searchHost);
        stopThread = true;
        return searchHost;
      }
    }
    catch (Exception ex) {
      ex.printStackTrace();
    }
  }
  return null;
}

boolean isPortOpen(InetAddress inetAddress, int port, int timeout) {
  try (Socket socket = new Socket()) {
    socket.connect(new java.net.InetSocketAddress(inetAddress, port), timeout);
    socket.close();
    return true;
  }
  catch (Exception ex) {
    return false;
  }
}

//void clearCache() {
//  // Get the cache directory
//  File cacheDir = getCacheDir();

//  // Check if the cache directory exists
//  if (cacheDir != null && cacheDir.isDirectory()) {
//    // Get all files in the cache directory
//    File[] files = cacheDir.listFiles();

//    // Iterate through the files and delete them
//    for (File file : files) {
//      file.delete();
//    }

//    if (DEBUG) println("Cache cleared!");
//  } else {
//    if (DEBUG) println("Cache directory not found.");
//  }
//}
//// Helper method to get the cache directory
//File getCacheDir() {
//  Context context = getActivity().getApplicationContext();
//  return context.getCacheDir();
//}
