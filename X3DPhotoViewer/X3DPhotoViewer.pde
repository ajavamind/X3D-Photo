// java sketch that downloads image files from a web server using a base url,
// looks for photo server example: http://[xxx.xxx.xxx.xxx]:8333 default WiFi network for the device running this app
// The expected format of the images is a stereoscopic side by side left/right images in the file.
// call a function named updateParallax that converts the sbs Pimage into left/right PImages and
// change the vertical offset and horizontal parallax offset and returning the cropped converted sbs image.
// Add a suffix "_2x1" to the original image filename, for example, image.jpg becomes image_2x1.jpg
// save the updated image with the filename suffix addition in the output folder.
// Repeat for all files parsed from the json file array list, one for each draw() cycle.
// uses loadImage processing function to download.
// show the images in draw while reading from the server
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

//static final boolean  DEBUG = false;
static final boolean  DEBUG = true;
String title="X3D Photo Transfer";
String version = "1.10";
String credits = "Andy Modla";

String baseUrl = null;
String outputFolderPath = "";
String configFile = "X3DPhotoViewer.txt";
volatile boolean downloadStarted = false;
volatile JSONArray fileList;
volatile int currentFileIndex = 0;
volatile PImage currentImage;
boolean done = false;
String urlSearch;
int port = 8333;  // expected port for HTTP image server
int timeout = 500; // 0.5 second
boolean ready = false;

String fileName="";
final static String STEREO_PREFIX = "SV_";
final static String MONO_PREFIX = "IMG_";
final static String STEREO_SUFFIX = "_2x1";
final static String MONO_SUFFIX = "";
final static String ANAGLYPH_SUFFIX = "_ana";
final static String JPG_FILETYPE = ".jpg";
final static String PNG_FILETYPE = ".png";
String filePrefix = STEREO_PREFIX;
String fileSuffix = STEREO_SUFFIX;
String fileType   = JPG_FILETYPE;

static final int PARALLAX = 237; // standard parallax adjustment for Xreal Beam Pro stereo window
int parallax = PARALLAX;  // parallax adjustment

float printAspectRatio = 6.0/4.0;  // default aspect ratio 6x4 inch print landscape orientation
int printPxWidth = 1800;
int printPxHeight = 1200;

volatile boolean started = false;
volatile boolean first = false;
boolean getFolder = false;

void settings() {
  //fullScreen();
  size(1920, 1080); // size chosen to free view SBS image on a phone
}

void setup() {
  background(200);
  frameRate(60);
  orientation(LANDSCAPE);

  openFileSystem();
  
  //writeSavedHost(configFile, "0.0.0.0");  // for debug only, reset saved server ip address

  host = readSavedHost(configFile);
  if (DEBUG) println("Saved host="+host+ " hostlsb="+hostlsb);
  if (DEBUG) println("outputFolderPath="+outputFolderPath);

  initGui();

  urlSearch = "Searching for HTTP Photo Server";

}

// stop threads before exit
void exit() {
  stopSearch();
  stopTransfer();
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
    textAlign(CENTER, CENTER);
    String header = title + " - Version " + version + " - " + credits;
    text(header, 0, IGui.FONT_SIZE/3, width, IGui.FONT_SIZE);
    drawPhotoViewer();

    if (foundUrl == null) {
      if (scanCompleted) {
      } else {
        showText("Checking For Server At: " + searchHost, 1);
      }
    } else {
      showText("Server Found At: " + foundUrl, 1);
    }
    gui.displayMenuBar();
    gui.dropDownList.display();
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
      if (fileName.toLowerCase().endsWith(fileType) && fileName.startsWith(filePrefix)
        && (!fileName.toLowerCase().startsWith(".trash"))) {
      } else {
        fileList.remove(currentFileIndex);
        currentFileIndex--;
        if (currentFileIndex  < 0) currentFileIndex = 0;
        if (currentFileIndex >= fileList.size()) {
          return;
        }
      }
      String fileUrl = baseUrl + "/" + fileName;
      String outputFileName = "";
      boolean filePresent = false;
      if (parallax > 0) {
        outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax) + fileSuffix + fileType;
      } else {
        outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + fileSuffix + fileType;
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
          outputFileName = fileName.substring(0, fileName.lastIndexOf('.')) + "_p"+str(parallax)+ fileSuffix + fileType;
          update = true;
        }
        String outputPath = outputFolderPath + File.separator + outputFileName;
        if (DEBUG) println("outputFileName="+outputFileName);
        if (DEBUG) println("outputPath="+outputPath);
        if (DEBUG) println("fileName="+fileName);
        String cardOutputPath = outputFolderPath + File.separator + fileName.substring(0, fileName.lastIndexOf('.')) + "_c"+str(parallax) + fileSuffix + fileType;
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
    if (!scanCompleted) showText("Searching for HTTP Photo Server.", 2);
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
    fileList = null;
    currentFileIndex = 0;
    first = true;
  }
  getFolder = false;
}
