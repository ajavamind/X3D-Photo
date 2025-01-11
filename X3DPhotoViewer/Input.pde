private static final int NOP = 0;
private static final int EXIT = 1;

// lastKey and lastKeyCode are handled in the draw loop
private int lastKey;
private int lastKeyCode;

void mousePressed() {
  lastKeyCode = gui.menuBar.mousePressed(mouseX, mouseY);
  if (lastKeyCode == 0) {
    mousePressedAdvance();
  }
  lastKey = 0;
}

void mousePressedAdvance() {
  if (fileList == null || fileList.size() == 0) return;
  if (mouseX > width/2 && mouseY > 3*IGui.FONT_SIZE) {
    lastKeyCode = IGui.KEYCODE_F;
  } else if (mouseX <width/2 && mouseY > 3*IGui.FONT_SIZE) {
    lastKeyCode = IGui.KEYCODE_G;
  }
  //if (DEBUG) println("mousePressed currentFileIndex="+currentFileIndex);
}


void mouseReleased() {
}

void keyReleased() {
}

void keyPressed() {
  if (DEBUG) println("key="+key + " keydecimal=" + int(key) + " keyCode="+keyCode);
  //if (DEBUG) Log.d(TAG, "key=" + key + " keyCode=" + keyCode);  // Android
  if (key==ESC) {
    key = 0;
    keyCode = IGui.KEYCODE_ESC;
  } else if (key == 65535 && keyCode == 0) { // special case all other keys
    // ignore key
    key = 0;
    keyCode = 0;
  }
  lastKey = key;
  lastKeyCode = keyCode;
}

// Process key from main loop not in keyPressed()
// returns NOP command when no key processed
// returns command when a key requests another operation, otherwise NOP
int keyUpdate() {
  int cmd = NOP;  // return code
  if (lastKey == 0 && lastKeyCode == 0) {
    return cmd;
  }

  switch(lastKeyCode) {
  case IGui.KEYCODE_BACK:
    break;
  case IGui.KEYCODE_A: // reset HTTP server search
      writeSavedHost(configFile, "0.0.0.0");
      host = readSavedHost(configFile);
      hostlsb = 0;
      stopThread = true;
      delay(500);
      foundUrl = null;
      stopThread = false;
      thread("searchForServer");
    break;
  case IGui.KEYCODE_B: // show first photo
    currentFileIndex = 0;
    first = true;
    break;
  case IGui.KEYCODE_C:  // get list of photos available on the HTTP server
    first = true;
    break;
  case IGui.KEYCODE_D: // show last photo
    currentFileIndex = fileList.size()-1;
    first = true;
    break;
  case IGui.KEYCODE_E: // select save folder for photos
    selectSaveFolder();
    break;
  case IGui.KEYCODE_F:  // show next photo
    currentFileIndex++;
    if (currentFileIndex >= fileList.size()) {
      //currentFileIndex--;
      first = true;
    }
    done = false;

    break;
  case IGui.KEYCODE_G:// show previous photo
    currentFileIndex--;
    if (currentFileIndex < 0 || currentFileIndex >= fileList.size()) {
      currentFileIndex = fileList.size() -1;
    }
    done = false;

    break;
  default:
    break;
  } // switch

  lastKey = 0;
  lastKeyCode = 0;
  return cmd;
}
