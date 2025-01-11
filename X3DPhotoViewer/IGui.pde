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
  static final int lightblue = #FF404080; //color(64, 64, 128);
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
