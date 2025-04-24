// Scan Local WiFi network for Simple HTTP server containing camera photos

volatile String foundUrl = null;
volatile boolean scanCompleted = false;
String host = "127.0.0.1";
String searchHost = "0.0.0.0";
volatile int hostlsb = 0;
volatile boolean searchThread = false;

void startSearch() {
  host = readSavedHost(configFile);
  hostlsb = 0;
  //searchThread = false;  // stop previous search thread
  //delay(500);
  foundUrl = null;
  searchThread = true; // allow search thread
  thread("searchForServer");
}

void stopSearch() {
  searchThread = false;  // stop previous search thread
  delay(500);
}

/**
 * Search for HTTP photo server on the local WiFi network
 * This method runs on a thread, called using thread("searchForServer");
 */
void searchForServer() {
  // Get the local IP address during output folder selection
  if (DEBUG) println("Thread searchForServer()");
  String found = null;
  scanCompleted = false;
  String localIp = getLocalIpAddress();
  if (DEBUG) println("Local IP: " + localIp +" host="+host + " hostlsb="+hostlsb);
  // Scan the network
  if (hostlsb != 0 && searchThread) {
    found = scanNetwork(localIp, port, hostlsb, hostlsb, timeout);  // inclusive ip range for port
  }

  if (found == null && searchThread) found = scanNetwork(localIp, port, 100, 199, timeout);  // inclusive port range
  if (found == null && searchThread) found = scanNetwork(localIp, port, 1, 99, timeout); // inclusive port range
  if (found == null && searchThread) found = scanNetwork(localIp, port, 200, 254, timeout); // inclusive port range
  if (found == null) scanCompleted = true;
  foundUrl = found;
  writeSavedHost(configFile, foundUrl);
  gui.toggleScanTextKey();  // change menu label
  if (DEBUG) println("Done Server search Found: "+foundUrl);
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
    if (!searchThread) {
      return null;
    }
    searchHost = subnet + "." + i;
    //if (DEBUG) println("try "+searchHost);
    try {
      InetAddress inetAddress = InetAddress.getByName(searchHost);
      if (isPortOpen(inetAddress, port, timeout)) {
        String hostName = inetAddress.getHostName();
        if (DEBUG) println("Host: " + hostName + " port " + port + " IP: " + searchHost);
        searchThread = false;
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
