// Graphical User Interface

Gui gui;

interface IGui {
  // Android key codes (not implemented) differ for some keys brlow
  static final int KEYCODE_NOP = 0;
  static final int KEYCODE_BACK = 4;
  static final int KEYCODE_BACKSPACE = 8;
  static final int KEYCODE_TAB = 9;
  static final int KEYCODE_ENTER = 10;
  static final int KEYCODE_ESC = 27;
  static final int KEYCODE_SPACE = 32;
  static final int KEYCODE_COMMA = 44;
  static final int KEYCODE_MINUS = 45;
  static final int KEYCODE_PERIOD = 46;
  static final int KEYCODE_SLASH = 47;
  static final int KEYCODE_QUESTION_MARK = 47;
  static final int KEYCODE_0 = 48;
  static final int KEYCODE_1 = 49;
  static final int KEYCODE_2 = 50;
  static final int KEYCODE_3 = 51;
  static final int KEYCODE_4 = 52;
  static final int KEYCODE_5 = 53;
  static final int KEYCODE_6 = 54;
  static final int KEYCODE_7 = 55;
  static final int KEYCODE_8 = 56;
  static final int KEYCODE_9 = 57;
  static final int KEYCODE_SEMICOLON = 59;
  static final int KEYCODE_PLUS = 61;
  static final int KEYCODE_EQUAL = 61;
  static final int KEYCODE_A = 65;
  static final int KEYCODE_B = 66;
  static final int KEYCODE_C = 67;
  static final int KEYCODE_D = 68;
  static final int KEYCODE_E = 69;
  static final int KEYCODE_F = 70;
  static final int KEYCODE_G = 71;
  static final int KEYCODE_H = 72;
  static final int KEYCODE_I = 73;
  static final int KEYCODE_J = 74;
  static final int KEYCODE_K = 75;
  static final int KEYCODE_L = 76;
  static final int KEYCODE_M = 77;
  static final int KEYCODE_N = 78;
  static final int KEYCODE_O = 79;
  static final int KEYCODE_P = 80;
  static final int KEYCODE_Q = 81;
  static final int KEYCODE_R = 82;
  static final int KEYCODE_S = 83;
  static final int KEYCODE_T = 84;
  static final int KEYCODE_U = 85;
  static final int KEYCODE_V = 86;
  static final int KEYCODE_W = 87;
  static final int KEYCODE_X = 88;
  static final int KEYCODE_Y = 89;
  static final int KEYCODE_Z = 90;
  static final int KEYCODE_LEFT_BRACKET = 91;
  static final int KEYCODE_BACK_SLASH = 92;
  static final int KEYCODE_RIGHT_BRACKET = 93;
  static final int KEYCODE_DEL = 127;
  //static final int KEYCODE_MEDIA_NEXT = 87;
  //static final int KEYCODE_MEDIA_PLAY_PAUSE = 85;
  //static final int KEYCODE_MEDIA_PREVIOUS = 88;
  static final int KEYCODE_PAGE_DOWN = 93;
  static final int KEYCODE_PAGE_UP = 92;
  static final int KEYCODE_PLAY = 126;
  static final int KEYCODE_MEDIA_STOP = 86;
  static final int KEYCODE_MEDIA_REWIND = 89;
  static final int KEYCODE_MEDIA_RECORD = 130;
  static final int KEYCODE_MEDIA_PAUSE = 127;
  static final int KEYCODE_VOLUME_UP = 0;  // TODO
  static final int KEYCODE_VOLUME_DOWN = 0; // TODO
  static final int KEYCODE_MOVE_HOME = 122;
  static final int KEYCODE_MOVE_END  = 123;
  static final int KEYCODE_TILDE_QUOTE = 192;
  static final int KEYCODE_SINGLE_QUOTE = 222;

  static final float SMALL_FONT_SIZE = 24;
  static final float FONT_SIZE = 48.0;
  static final float MEDIUM_FONT_SIZE =  72;
  static final float LARGE_FONT_SIZE = 96;
  static final float GIANT_FONT_SIZE = 128;

  // color is ARGB bytes - Alpha, Red, Blue, Green
  static final int black = #FF000000;   // black
  static final int gray = #FF808080;
  static final int graytransparent = #80808080;
  static final int darktransparent = #80202020; //color(32, 32, 32, 128);
  static final int white = #FFFFFFFF; // white
  static final int red = #FFFF0000; //color(255, 0, 0);
  static final int aqua = #FF800080; //color(128, 0, 128);
  static final int lightblue = #FF8080FF;// #FF404080;
  static final int darkblue = #FF202040; //color(32, 32, 64);
  static final int yellow = #FFFFCC00; //color(255, 204, 0);
  //static final int silver = color(193, 194, 186);
  //static final int brown = color(69, 66, 61);
  //static final int bague = color(183, 180, 139);

  static final String INFO_SYMBOL = "\u24D8";
  static final String CIRCLE_PLUS = "\u2295";
  static final String CIRCLE_MINUS = "\u2296";
  static final String CIRCLE_LT = "\u29c0";
  static final String CIRCLE_GT = "\u29c1";
  //static final String LEFT_TRIANGLE = "\u22B2";  // Android
  //static final String RIGHT_TRIANGLE = "\u22B3"; // Android
  static final String LEFT_TRIANGLE = "<";
  static final String RIGHT_TRIANGLE = ">";
  static final String BIG_TRIANGLE_UP = "\u25B3";
  //  ↑ U+2191 Up Arrow

  //↓ U+2193 Down Arrow

  //→ U+2192 Right Arrow

  //← U+2190 Left Arrow
  static final String UP_ARROW = "\u2191";
  static final String DOWN_ARROW = "\u2193";
  static final String LEFT_ARROW = "\u2190";
  static final String RIGHT_ARROW = "\u2192";
  static final String PLAY = "\u25BA";
  static final String STOP = "\u25AA";
  static final String PLUS_MINUS = "||"; //"\u00B1";  //  alternate plus minus 2213
  static final String RESET = "\u21BB";  // loop
  static final String LEFT_ARROW_EXIT = "\u2190";  // Left arrow for exit
  static final String LEFT_ARROWHEAD = "\u02C2";
  static final String RIGHT_ARROWHEAD = "\u02C3";
  static final String CHECK_MARK = "\u2713";
  static final String LEFT_RIGHT_ARROW = "\u2194";
}

// Drop Down List Option items
String[] items = {"SV_", "_2x1", "Anaglyph", "Card", "_L _R", "Parallax", "IMG_"};
static final int OPTION_SV =  1;
static final int OPTION_2x1 = 2;
static final int OPTION_ANAGLYPH = 4;
static final int OPTION_CARD = 8;
static final int OPTION_L_R = 16;
static final int OPTION_PARALLAX = 32;
static final int OPTION_IMG = 64;
int[] itemValues = {OPTION_SV, OPTION_2x1, OPTION_ANAGLYPH, OPTION_CARD, OPTION_L_R, OPTION_PARALLAX, OPTION_IMG};
static final int OPTION_DEFAULT = OPTION_2x1 + OPTION_PARALLAX;
int optionValue = OPTION_DEFAULT;

void initGui() {
  PFont font = createFont("arial", IGui.FONT_SIZE);
  textFont(font);
  textSize(IGui.FONT_SIZE);
  textAlign(CENTER, CENTER);
  fill(IGui.black); // black text and graphics
  gui = new Gui(this);
  gui.create();
}

// The GUI assumes the camera screen image is at (0,0)
class Gui {
  PApplet base;  // base sketch reference
  MenuBar menuBar;
  DropDownList dropDownList;

  // information zone touch coordinates
  // screen boundaries for click zone use
  float WIDTH;
  float HEIGHT;
  float iX;
  float iY;
  float mX;
  float mY;

  /**
  * Constructor
  */
  Gui(PApplet base) {
    this.base = base;
  }

  void create() {
    if (DEBUG) println("create Gui");
    WIDTH = base.width;
    HEIGHT = base.height;
    iX = WIDTH / 8;
    iY = HEIGHT / 10;
    mX = WIDTH / 2;
    mY = HEIGHT / 2;
    menuBar = new MenuBar(base);
    menuBar.setVisible(true);
    menuBar.setActive(true);

    // Place drop down list below the new menu key
    float ddX = gui.menuBar.menuKey[5].x;
    float ddY = gui.menuBar.menuKey[5].y + gui.menuBar.menuKey[5].h + 4;
    float ddW = gui.menuBar.menuKey[5].w;
    dropDownList = new DropDownList(base, items, itemValues, optionValue, ddX, ddY, ddW, IGui.FONT_SIZE);
  }

  void displayMenuBar() {
    menuBar.display();
  }
}

class MenuBar implements IGui {
  PApplet base;
  MenuKey refreshListKey;
  MenuKey resetServerKey;
  MenuKey firstPhotoKey;
  MenuKey lastPhotoKey;
  MenuKey saveFolderKey;
  MenuKey dropDownKey;

  MenuKey[] menuKey;
  int numKeys = 6;

  float menuBase;
  float inset;
  float x, y, w, h;
  float iY;
  color keyColor = black;

  /**
  * Constructor
  */
  public MenuBar(PApplet base) {
    this.base = base;
    resetServerKey = new MenuKey(base, KEYCODE_A, "Reset Server", FONT_SIZE, black);
    firstPhotoKey = new MenuKey(base, KEYCODE_B, "Show First", FONT_SIZE, black);
    refreshListKey = new MenuKey(base, KEYCODE_C, "Get List", FONT_SIZE, black);
    lastPhotoKey = new MenuKey(base, KEYCODE_D, "Show Last", FONT_SIZE, black);
    saveFolderKey = new MenuKey(base, KEYCODE_E, "Save Folder", FONT_SIZE, black);
    dropDownKey = new MenuKey(base, KEYCODE_F, "Options", FONT_SIZE, black);
    menuKey = new MenuKey[numKeys];
    menuKey[0] = resetServerKey;
    menuKey[1] = firstPhotoKey;
    menuKey[2] = refreshListKey;
    menuKey[3] = lastPhotoKey;
    menuKey[4] = saveFolderKey;
    menuKey[5] = dropDownKey;
    x = 0;
    iY = base.height/16;
    y = base.height - iY;
    w = base.width / ((float) numKeys);
    h = iY-4;
    inset = 40;
    menuBase = FONT_SIZE+ FONT_SIZE/2;
    ;
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
    //if (DEBUG) println("menubar mouse x="+x + " y="+y + " menuBase="+menuBase);
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
      if (mkeyCode == 0) {
        gui.dropDownList.mousePressed(mouseX, mouseY);
      }
    }
    return mkeyCode;
  }
}

class MenuKey implements IGui {
  float x, y, w, h; // location
  float inset;
  String cap;     // caption
  PImage img;
  int keyColor;
  int keyCode;
  float fontSize;
  boolean visible = false;
  boolean highlight = false;
  boolean active = true;
  boolean corner = true;
  boolean textOnly = false;
  int value;
  PApplet base;

  /**
  * Constructor
  */
  MenuKey() {
  }

  MenuKey(PApplet base, int keyCode, String cap, float fontSize, int keyColor) {
    this.base = base;
    this.keyCode = keyCode;
    this.cap = cap;
    this.keyColor = keyColor;
    this.fontSize = fontSize;
    this.img = null;
  }

  MenuKey(PApplet base, int keyCode, PImage img, int keyColor) {
    this.base = base;
    this.keyCode = keyCode;
    this.img = img;
    this.keyColor = keyColor;
  }

  void setBase(PApplet base) {
    this.base = base;
  }

  void setPosition(float x, float y, float w, float h, float inset) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.inset = inset;
  }

  void setValue(int value) {
    this.value = value;
  }

  int getValue() {
    return value;
  }

  void setHighlight(boolean highlight) {
    this.highlight = highlight;
  }

  void setVisible(boolean visible) {
    this.visible = visible;
  }

  void setActive(boolean active) {
    this.active = active;
  }

  void setCorner(boolean corner) {
    this.corner = corner;
  }

  void setTextOnly(boolean value) {
    this.textOnly = value;
  }

  void draw() {
    if (visible) {
      base.stroke(gray);
      base.strokeWeight(4);
      base.rectMode(base.CORNER);
      if (img != null) {
        if (active) {
          base.fill(white);
        } else {
          base.fill(gray);
        }
        base.rect(x, y, w, h, inset);
        float ar = (float) img.width/ (float) img.height;
        float ah = h*0.8f;
        base.image(img, x- (ah*ar)/2+w/2, y+ah/8, ah*ar, ah);
        //base.noFill();
        base.stroke(keyColor);
        if (highlight) {
          base.stroke(255, 255, 0);
          base.strokeWeight(12);
          base.noFill();
          //base.fill(255, 128, 0);
          base.rect(x, y, w, h);
        }
      } else if (cap != null) {
        if (active) {
          if (highlight) {
            base.fill(0, 255, 255);
          } else {
            base.fill(white);
          }
        } else {
          base.fill(gray);
        }
        if (corner) {
          base.rect(x, y, w, h, inset);
        }
        base.textSize(fontSize);
        base.noStroke();
        base.noFill();
        if (corner) {
          base.fill(black);
        } else {
          base.fill(graytransparent);
        }
        base.textAlign(base.CENTER, base.CENTER);
        base.fill(keyColor);
        base.text(cap, x, y, w, h);
      }
    }
  }

  /**
   * @param mx mouse x coordinate
   * @param my mouse y coordinate
   * @return boolean true if mouse in key area
   */
  boolean isPressed(int mx, int my) {
    boolean hit = false;
    if (my >= y && my <= (y + h)
      && mx >= x && mx <= (x + w)) {
      hit = true;
    }
    return hit;
  }

  int getPressed(int mx, int my, int n) {
    int area = 0;
    if (my >= y && my <= (y + h)) {
      for (int i = 1; i <= n; i++) {
        if (mx >= x && mx <= (x + i * w / n)) {
          area = i;
          break;
        }
      }
    }
    return area;
  }

  void setCap(String cap) {
    this.cap = cap;
  }

  void setKeyCode(int keyCode) {
    this.keyCode = keyCode;
  }

  int getKeyCode() {
    return keyCode;
  }

  public void setImage(PImage img) {
    this.img = img;
  }
}


// DropDownList class
class DropDownList implements IGui {
  PApplet base;
  String[] items;
  int[] itemValues;
  int optionsValue;
  float x, y, w, h;
  boolean visible = false;
  int highlight = -1;
  float itemHeight;
  int keyColor;
  int bgColor;
  int textColor;
  int borderColor;
  float fontSize;

  /**
  * Constructor
  */
  DropDownList(PApplet base, String[] items, int[] itemValues, int optionsValue, float x, float y, float w, float fontSize) {
    this.base = base;
    this.items = items;
    this.itemValues = itemValues;
    this.optionsValue = optionsValue;
    this.x = x;
    this.y = y;
    this.w = w;
    this.fontSize = fontSize;
    this.itemHeight = fontSize * 1.2;
    this.h = items.length * itemHeight;
    this.keyColor = black;
    this.bgColor = white;
    this.textColor = black;
    this.borderColor = gray;
  }

  void show() {
    visible = true;
  }
  void hide() {
    visible = false;
  }
  void display() {
    if (!visible) return;
    base.stroke(borderColor);
    base.fill(bgColor);
    base.rect(x, y, w, h, 8);
    for (int i = 0; i < items.length; i++) {
      float iy = y + i * itemHeight;
      int value = itemValues[i];
      if ((optionsValue & value) != 0) {
        base.fill(lightblue);
        base.rect(x, iy, w, itemHeight);
      }
      base.fill(textColor);
      base.textAlign(base.LEFT, base.CENTER);
      base.textSize(fontSize);
      base.text(items[i], x + 10, iy + itemHeight/2);
    }
  }

  // Returns index if selected, -1 otherwise
  // sets option values
  int mousePressed(int mx, int my) {
    if (!visible) return -1;
    if (mx >= x && mx <= x + w && my >= y && my <= y + h) {
      int idx = int((my - y) / itemHeight);
      if (idx >= 0 && idx < items.length) {
        optionsValue = optionsValue ^ itemValues[idx];
        return idx;
      }
    }
    return -1;
  }
  
  int getOptionsValue() {
    return optionsValue;
  }
  
}
