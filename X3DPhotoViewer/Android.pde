// ANDROID version of this app

import android.content.Context;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
import android.view.inputmethod.InputMethodManager;
import android.app.Activity;
import android.os.Build;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;

boolean grantedRead = false;
boolean grantedWrite = false;

SelectLibrary files;

void openFileSystem() {
  // Clear the cache of any files from previous run
  //clearCache();
    // Ensure we are on the main thread
  runOnUIThread();

  outputFolderPath = File.separator + "storage" + File.separator + "emulated" + File.separator + "0"
    + File.separator + "Pictures" + File.separator + "X3D";
  requestPermissions();
  files = new SelectLibrary(this);
  // TODO check for outputFolderPath X3D exists, otherwise make directory
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

// ensure we run on main UI thread
void runOnUIThread() {
    getActivity().runOnUiThread(new Runnable() {
      @Override
        public void run() {
        hideSystemUI();
      }
    }
    );
}

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
