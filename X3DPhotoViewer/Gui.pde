// Graphical User Interface

// The GUI assumes the camera screen image is at (0,0)
class Gui {
  PApplet base;  // base sketch reference
  MenuBar menuBar;

  // information zone touch coordinates
  // screen boundaries for click zone use
  float WIDTH;
  float HEIGHT;
  float iX;
  float iY;
  float mX;
  float mY;

  Gui() {
  }

  void create(PApplet base) {
    this.base = base;
    WIDTH = base.width;
    HEIGHT = base.height;
    iX = WIDTH / 8;
    iY = HEIGHT / 10;
    mX = WIDTH / 2;
    mY = HEIGHT / 2;
  }

  void createGui() {
    if (DEBUG) println("createGui()");
    menuBar = new MenuBar(base);
    menuBar.setVisible(true);
    menuBar.setActive(true);
  }

  void displayMenuBar() {
    menuBar.display();
  }
}
