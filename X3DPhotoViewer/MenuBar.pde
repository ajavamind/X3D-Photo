class MenuBar implements IGui {
  PApplet base;
  MenuKey refreshListKey;
  MenuKey resetServerKey;
  MenuKey firstPhotoKey;
  MenuKey lastPhotoKey;
  MenuKey saveFolderKey;
  MenuKey[] menuKey;
  int numKeys = 5;
  float menuBase;
  float inset;
  float x, y, w, h;
  float iY;
  color keyColor = black;

  public MenuBar(PApplet base) {
    this.base = base;
    resetServerKey = new MenuKey(base, KEYCODE_A, "Reset Server", FONT_SIZE, black);
    firstPhotoKey = new MenuKey(base, KEYCODE_B, "Show First", FONT_SIZE, black);
    refreshListKey = new MenuKey(base, KEYCODE_C, "Get List", FONT_SIZE, black);
    lastPhotoKey = new MenuKey(base, KEYCODE_D, "Show Last", FONT_SIZE, black);
    saveFolderKey = new MenuKey(base, KEYCODE_E, "Save Folder", FONT_SIZE, black);
    menuKey = new MenuKey[numKeys];
    menuKey[0] = resetServerKey;
    menuKey[1] = firstPhotoKey;
    menuKey[2] = refreshListKey;
    menuKey[3] = lastPhotoKey;
    menuKey[4] = saveFolderKey;
    x = 0;
    iY = base.height/16;
    y = base.height - iY;
    w = base.width / ((float) numKeys);
    h = iY-4;
    inset = 40;
    menuBase = FONT_SIZE+ FONT_SIZE/2;;
    for (int i = 0; i < numKeys; i++) {
      menuKey[i].setPosition(((float) i) * w + inset, menuBase, w - 2 * inset, h, inset);
    }
  }

  public void setVisible(boolean visible) {
    for (int i = 0; i < menuKey.length; i++) {
      menuKey[i].setVisible(visible);
    }
  }

  void setActive(boolean active) {
    for (int i = 0; i < menuKey.length; i++) {
      menuKey[i].setActive(active);
    }
  }

  void display() {
    fill(128);
    noStroke();
    rect(0, menuBase, base.width, iY);

    for (int i = 0; i < menuKey.length; i++) {
      menuKey[i].draw();
      menuKey[i].setHighlight(false);
    }
  }

  int mousePressed(int x, int y) {
    int mkeyCode = 0;
    int mkey = 0;
    if (DEBUG) println("menubar mouse x="+x + " y="+y + " menuBase="+menuBase);
    if (y > menuBase ) {
      // menu touch control area at bottom of screen or sides
      for (int i = 0; i < numKeys; i++) {
        if (menuKey[i].visible && menuKey[i].active) {
          if (x >= menuKey[i].x && x<= (menuKey[i].x + menuKey[i].w) &&
            y >= menuKey[i].y && y <= (menuKey[i].y +menuKey[i].h)) {
            mkeyCode = menuKey[i].keyCode;
            menuKey[i].setHighlight(true);
            break;
          }
        }
      }
    }
    return mkeyCode;
  }
}
