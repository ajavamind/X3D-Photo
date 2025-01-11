# X3D-Photo
XReal Beam Pro 3D Camera Photo View and Transfer Android app

This app is written as a Processing Java Android sketch app. It runs on a client 3D display device like the LumePad 2, and is not intended to run on the Xreal Beam Pro serving device. 
It views and transfers photos over WiFi from the XReal Beam Pro camera folder using the Google Play Store "Simple HTTP Server Plus" app as a photo server.
Transfered photos have the jpg photo filename changed to the suffix "_2x1.jpg" and it adjust the parallax of the SBS photos to a foreground stereo window using a fixed displacement.
The app automatically searches for the photo server on a local WiFi network where both devices should be connected. The HTTP server port is set to 8333.

The configuration of the Simple HTTP Server Plus app as it appears from its configuration screen:

![Configuration Screen](images/configScreenshot.png)

![X3D Viewer and Transfer Screenshot](images/X3D_ViewerScreenshot.jpg)

The app stores transferred photos to the default Pictures/X3D album. This can be changed by pressing the "Save Folder" menu button and select the new folder.
