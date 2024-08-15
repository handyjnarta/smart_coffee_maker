#include <QorexLibrary.h>
#include <HardwareSerial.h>

HardwareSerial mySerial(2); // Using UART2

String receivedTemp;
String receivedVol;
String receivedFlag;
String flagP = "p";
String flagH = "h";
const char* receivedFlagConvert;
const char* receivedTempConvert;
const char* receivedVolConvert;
String clearance = "";  // Initialize an empty string

void setup() {
  initDisplay(3, TFT_BLUE);
  Serial.begin(115200);
  mySerial.begin(115200, SERIAL_8N1, 17, 16); // TX=17, RX=16 (ensure the pins match your connections)
}

void loop() {
  displayMessage("Qohuahh", 3, 30, 0, TFT_WHITE);

  if (mySerial.available()) {
    receivedFlag = mySerial.readStringUntil('\n');
    receivedTemp = mySerial.readStringUntil('\n');  // Read flag until newline
    receivedVol = mySerial.readStringUntil('\n');
    Serial.print("Data flag: ");
    Serial.println(receivedFlag);
    Serial.print("\n");
    Serial.print("Data Data: ");
    Serial.println(receivedTemp);
    Serial.print("\n");
    Serial.print("Data Volume: ");
    Serial.println(receivedVol);
    Serial.print("\n");
    receivedFlagConvert = receivedFlag.c_str();
    receivedTempConvert = receivedTemp.c_str();
    receivedVolConvert = receivedVol.c_str();
    // displayMessage("\t Temperature = ", 2, 0, 30, TFT_WHITE);
    // displayMessage(receivedFlagConvert, 2, 190, 30, TFT_WHITE);
    // displayMessage("\t Humidity = ", 2, 0, 60, TFT_DARKCYAN);
    // displayMessage(receivedTempConvert, 2, 150, 60, TFT_DARKCYAN);
    // displayMessage(" %", 2, 220, 60, TFT_DARKCYAN);
    // displayMessage("\t Volume   = ", 2, 0, 90, TFT_DARKCYAN);
    // displayMessage(receivedVolConvert, 2, 150, 90, TFT_DARKCYAN);
    // displayMessage(" %", 2, 220, 90, TFT_DARKCYAN);
    // displayMessage("\t Sudah adakah yang gantikanku ", 2, 0, 120, TFT_DARKCYAN);
    // if (receivedFlag = flagH) {
    //   Serial.print("Yeah");
    //   displayMessage("\t Sudah adakah yang gantikanku ", 2, 0, 120, TFT_PINK);
    // }
    if (receivedFlag = flagH) {
      //receivedTemp = mySerial.readStringUntil('\n');  // Read temperature until newline
      Serial.print("Data temp: ");
      Serial.println(receivedTemp);
      Serial.print("\n");
      
      receivedTempConvert = receivedTemp.c_str();
      
      displayMessage("\t Temperature = ", 2, 0, 30, TFT_WHITE);
      displayMessage(receivedTempConvert, 2, 190, 30, TFT_WHITE);
      displayMessage(" C", 2, 260, 30, TFT_WHITE);
    } 
    else if (receivedFlag = flagP) {
      //receivedTemp = mySerial.readStringUntil('\n');  // Read temperature until newline
      //receivedVol = mySerial.readStringUntil('\n');   // Read volume until newline
      Serial.print("Data temp: ");
      Serial.println(receivedTemp);
      Serial.print("Data vol: ");
      Serial.println(receivedVol);
      
      receivedTempConvert = receivedTemp.c_str();
      receivedVolConvert = receivedVol.c_str();
      
      displayMessage("\t Temperature = ", 2, 0, 30, TFT_WHITE);
      displayMessage(receivedTempConvert, 2, 190, 30, TFT_WHITE);
      displayMessage(" C", 2, 260, 30, TFT_WHITE);
      
      displayMessage("\t Volume water = ", 2, 0, 70, TFT_WHITE);
      displayMessage(receivedVolConvert, 2, 190, 70, TFT_WHITE);
      displayMessage(" mL", 2, 260, 70, TFT_WHITE);
    } 
    else {
      Serial.print("No matching flag\n");
      displayMessage("\t Data not received ", 2, 0, 70, TFT_WHITE);
    }
  } 
  else {
    Serial.print("No serial data available\n");
    displayMessage("\t No serial data ", 2, 0, 70, TFT_WHITE);
  }
  delay(2000);
  fillRectangle(0, 0, 320, 240, 0, TFT_BLACK);  // Clear the screen after a delay
}
