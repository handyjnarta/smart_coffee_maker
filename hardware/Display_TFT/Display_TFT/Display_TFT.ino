#include <QorexLibrary.h>
#include <HardwareSerial.h>

HardwareSerial mySerial(2); // Using UART2

String receivedTemp;
String receivedVol;
String receivedFlag;
const char* receivedTempConvert;
const char* receivedVolConvert;
String clearance = "";  // Initialize an empty string

void setup() {
  initDisplay(3, TFT_BLUE);
  Serial.begin(115200);
  mySerial.begin(115200, SERIAL_8N1, 17, 16); // TX=17, RX=16 (ensure the pins match your connections)
  initBME();
}

void loop() {
  displayMessage("Qohuahh", 3, 30, 0, TFT_WHITE);

  static unsigned long previousMillisPrint = 0;  // Make previousMillisPrint static to retain value across function calls
  unsigned long currentMillisPrint = millis();   // Get current time
  unsigned long intervalPrint = 1000;

  if (currentMillisPrint - previousMillisPrint >= intervalPrint) {
    previousMillisPrint = currentMillisPrint;

    if (mySerial.available()) {
      receivedFlag = mySerial.readStringUntil('\n');  // Read data until newline
      
      if (receivedFlag == "h") {
        receivedTemp = mySerial.readStringUntil('\n');
        receivedTempConvert = receivedTemp.c_str();
        
        fillRectangle(0, 0, 320, 240, 0,TFT_BLUE);  // Clear the screen before updating the display
        
        displayMessage("\t Temperature = ", 2, 0, 30, TFT_WHITE);
        displayMessage(receivedTempConvert, 2, 190, 30, TFT_WHITE);
        displayMessage(" C", 2, 260, 30, TFT_WHITE);
      } 
      else if (receivedFlag == "p") {
        receivedTemp = mySerial.readStringUntil('\n');
        receivedVol = mySerial.readStringUntil('\n');
        receivedTempConvert = receivedTemp.c_str();
        receivedVolConvert = receivedVol.c_str();
        
        fillRectangle(0, 0, 320, 240, 0,TFT_BLUE);  // Clear the screen before updating the display
        
        displayMessage("\t Temperature = ", 2, 0, 30, TFT_WHITE);
        displayMessage(receivedTempConvert, 2, 190, 30, TFT_WHITE);
        displayMessage(" C", 2, 260, 30, TFT_WHITE);
        
        displayMessage("\t Volume water = ", 2, 0, 70, TFT_WHITE);
        displayMessage(receivedVolConvert, 2, 190, 70, TFT_WHITE);
        displayMessage(" mL", 2, 260, 70, TFT_WHITE);
      }
    }
  }
}
