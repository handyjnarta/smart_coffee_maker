#include <HX711_ADC.h>
#include <PID_v1.h>

const int HX711_dout = 15; // mcu > HX711 dout pin
const int HX711_sck = 26;  // mcu > HX711 sck pin
float sum = 0;
// HX711 constructor:
HX711_ADC LoadCell(HX711_dout, HX711_sck);

// PID parameters
double Setpoint, Input, Output;
double Kp = 1.0, Ki = 0.5, Kd = 0.1;
PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);

const int calVal_eepromAdress = 0;
unsigned long t = 0;
// PUMP
int motorPin = 14; // pin to connect to motor module
//int mSpeed = 100;  // variable to hold speed value

void setup() {
  Serial.begin(9600);

  Serial.println();
  Serial.println("Starting...");

  LoadCell.begin();

  float calibrationValue; // calibration value (see example file "Calibration.ino")
  calibrationValue = 747.73; // uncomment this if you want to set the calibration value in the sketch
  unsigned long stabilizingtime = 2000; // precision right after power-up can be improved by adding a few seconds of stabilizing time
  boolean _tare = true; // set this to false if you don't want tare to be performed in the next step
  LoadCell.start(stabilizingtime, _tare);
  if (LoadCell.getTareTimeoutFlag()) {
    Serial.println("Timeout, check MCU>HX711 wiring and pin designations");
    while (1);
  } else {
    LoadCell.setCalFactor(calibrationValue); // set calibration value (float)
    Serial.println("Startup is complete");
    pinMode(motorPin, OUTPUT);
  }

  // Initialize PID
  Setpoint = 200; // Example setpoint for load cell value
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(100, 110); // PWM range
}

void loop() {
  static boolean newDataReady = 0;
  const int serialPrintInterval = 500; // increase value to slow down serial print activity
  // Check for new data/start next conversion:
  if (LoadCell.update()) newDataReady = true;

  // Get smoothed value from the dataset:
  if (newDataReady) {
    if (millis() > t + serialPrintInterval) {
      for (int k = 1; k <= 80; k++) {
        float i = LoadCell.getData();
        sum += i; // Add value i to sum
      }
      float average = sum / 80;
      Input = average;

      // Compute PID output
      myPID.Compute();
      int mSpeed = Output;
      Serial.printf("mSpeed, %d", mSpeed);
      

      if (average >= 200) {
        mSpeed = 0; // Turn off motor when load is too much
      }
      analogWrite(motorPin, mSpeed);

      Serial.print("Load_cell output val: ");
      Serial.println(average);
      Serial.print("\t");
      Serial.print("Motor speed: ");
      Serial.println(mSpeed);

      newDataReady = 0;
      t = millis(); //
      sum = 0;
    }
  }

  // Receive command from serial terminal, send 't' to initiate tare operation:
  if (Serial.available() > 0) {
    char inByte = Serial.read();
    if (inByte == 't') LoadCell.tareNoDelay();
  }

  // Check if last tare operation is complete:
  if (LoadCell.getTareStatus() == true) {
    Serial.println("Tare complete");
  }
}
