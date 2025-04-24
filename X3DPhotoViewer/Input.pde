private static final int NOP = 0;
private static final int EXIT = 1;

// lastKey and lastKeyCode are handled in the draw loop
private int lastKey;
private int lastKeyCode;

void mousePressed() {
  int x = mouseX;
  int y = mouseY;
  lastKeyCode = gui.menuBar.isPressed(x, y);
  if (lastKeyCode == 0) {
    mousePressedAdvance(x, y);
  }
  lastKey = 0;
}

void mousePressedAdvance(int x, int y) {
  if (fileList == null || fileList.size() == 0) return;
  if (x > width/2 && y > 3*IGui.FONT_SIZE) {
    lastKeyCode = IGui.KEYCODE_G;
  } else if (x <width/2 && y > 3*IGui.FONT_SIZE) {
    lastKeyCode = IGui.KEYCODE_H;
  }
  //if (DEBUG) println("mousePressed currentFileIndex="+currentFileIndex);
}


void mouseReleased() {
}

void keyReleased() {
}

void keyPressed() {
  //if (DEBUG) println("key="+key + " keydecimal=" + int(key) + " keyCode="+keyCode);
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
  case IGui.KEYCODE_A: // start HTTP server search
    writeConfiguration(configFile, "0.0.0.0");
    if (gui.toggleScanTextKey()) {
      startSearch();
    } else {
      stopSearch();
    }
    break;
  case IGui.KEYCODE_B: // show first photo
    currentFileIndex = 0;
    first = true;
    break;
  case IGui.KEYCODE_C:  // get list of photos available on the HTTP server
    if (gui.toggleStartTransferKey()) {
      startTransfer();
      first = true;
    } else {
      first = false;
      stopTransfer();
    }
    break;
  case IGui.KEYCODE_D: // show last photo
    currentFileIndex = fileList.size()-1;
    first = true;
    break;
  case IGui.KEYCODE_E: // select save folder for photos
    selectSaveFolder();
    break;
  case IGui.KEYCODE_F:
    //if (DEBUG) println("KEYCODE_F");
    if (!gui.optionDropDownList.visible) gui.optionDropDownList.show();
    else gui.optionDropDownList.hide();
    break;
  case IGui.KEYCODE_P:
    //if (DEBUG) println("KEYCODE_P");
    if (!gui.prefixDropDownList.visible) gui.prefixDropDownList.show();
    else gui.prefixDropDownList.hide();
    break;
  case IGui.KEYCODE_G:  // show next photo
    currentFileIndex++;
    if (currentFileIndex >= fileList.size()) {
      currentFileIndex--;
      first = true;
    }
    done = false;
    break;
  case IGui.KEYCODE_H:// show previous photo
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
