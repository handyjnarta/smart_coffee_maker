#include <RBDdimmer.h>
#include "max6675.h"
#include <PID_v1.h>
#include <HX711_ADC.h>

//#define Serial  SerialUSB //Serial for boards with USB serial port
#define outputPin  12 
#define zerocross  5 // for boards with CHANGEBLE input pins

dimmerLamp dimmer(outputPin, zerocross); // Initialize port for dimmer for ESP8266, ESP32, Arduino due boards

int thermoSO = 19;
int thermoCS = 23;
int thermoCLK = 13;

MAX6675 thermocouple(thermoCLK, thermoCS, thermoSO);

// Define PID variables
double Setpoint, NilaiSuhu, Output;
double Kp = 1.0, Ki = 0.5, Kd = 0.1; // Tune these values as needed
PID myPID(&NilaiSuhu, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);

unsigned long previousMillis = 0;
const long interval = 500; // Interval for temperature update
unsigned long setpointReachedMillis = 0;
const long setpointDelay = 10000; // 10 second delay

bool dimmerSetTo10 = false; // Flag to track if the dimmer power was set to 10%

const int HX711_dout = 15; //mcu > HX711 dout pin
const int HX711_sck = 26; //mcu > HX711 sck pin
float sum = 0.0;
//HX711 constructor:
HX711_ADC LoadCell(HX711_dout, HX711_sck);

unsigned long t = 0;
//PUMP
int motorPin = 14; // pin to connect to motor module

int volwater = 0;
float average = 0.0;


// Function to read a double value from the serial monitor
double readDoubleFromSerial() {
  while (true) {
    if (Serial.available() > 0) {
      double value = Serial.parseFloat();
      if (Serial.read() == '\n') { // Ensure the input is complete
        return value;
      }
    }
  }
}

// Function to read an integer value from the serial monitor
int readIntFromSerial() {
  while (true) {
    if (Serial.available() > 0) {
      int value = Serial.parseInt();
      if (Serial.read() == '\n') { // Ensure the input is complete
        return value;
      }
    }
  }
}

void setup() {
  Serial.begin(9600); 
  dimmer.begin(NORMAL_MODE, ON); // Dimmer initialization: name.begin(MODE, STATE) 
  Serial.println("Dimmer Program is starting...");
  
  // Initialize the PID controller
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(0, 80); // Output limits for the dimmer (0-80%)

  LoadCell.begin();
  float calibrationValue = -802.12; // calibration value
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

  // Ask user for initial values
  Serial.println("Enter desired temperature setpoint: ");
  Setpoint = readDoubleFromSerial();
  Serial.print(Setpoint);
  Serial.println("\t");
  Serial.println("Enter desired water volume: ");
  volwater = readIntFromSerial();
  Serial.print(volwater);
}



void updateLoadCell() {
  static boolean newDataReady = 0;

  if (LoadCell.update()) newDataReady = true;

  if (newDataReady) {
      for (int k = 1; k <= 80; k++) {
        float i = LoadCell.getData();
        sum += i;
      }
      average = sum / 80;
      newDataReady = 0;
      t = millis();
      sum = 0;
    }
}

void controlMotor(int speed) {
  analogWrite(motorPin, speed);
  delay(20); // Necessary delay
  Serial.print("Motor Speed :");
  Serial.println(speed);
}

void loop() {
  unsigned long currentMillis = millis();
  // Check if it's time to update temperature and dimmer
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    NilaiSuhu = thermocouple.readCelsius();

      static boolean newDataReady = 0;

    if (LoadCell.update()) newDataReady = true;

    if (newDataReady) {
        for (int k = 1; k <= 80; k++) {
          float i = LoadCell.getData();
          sum += i;
        }
        average = sum / 80;
        newDataReady = 0;
        t = millis();
        sum = 0;
    }


    myPID.Compute(); // Compute the PID output

    int preVal = dimmer.getPower();
    int newVal;


    // Check if the temperature is within 2 degrees of the setpoint
    if (abs(NilaiSuhu - Setpoint) <= 2) {
      // If setpoint reached for the first time, record the time
      if (setpointReachedMillis == 0) {
        setpointReachedMillis = currentMillis;
      }
      updateLoadCell();


      // Check if 10 seconds have passed since reaching the setpoint
      if (currentMillis - setpointReachedMillis >= setpointDelay  && average >= (volwater)) {
        newVal = 10; // Set the dimmer power to 10 if the temperature is close to the setpoint for 10 seconds
        Output = 10;
        controlMotor(0);
        Serial.println("Air sudah dikeluarkan");
        dimmerSetTo10 = true; // Set the flag to true when dimmer power is set to 10%
      } else {
        newVal = (int)Output; // Otherwise, use the PID output
        dimmerSetTo10 = false; // Reset the flag if not set to 10%
        controlMotor(100);

      }
    } else {
      // Reset the setpointReachedMillis if the temperature is out of range
      setpointReachedMillis = 0;
      newVal = (int)Output; // Use the PID output
      dimmerSetTo10 = false; // Reset the flag if not set to 10%
    }
    // Ensure the dimmer power is set smoothly
    dimmer.setPower(newVal); // setPower(0-80%)

    if (preVal != newVal) {
      Serial.print("TempValue -> ");
      Serial.print(newVal);
      Serial.println("%");
    }

    Serial.print("C = ");
    Serial.println(NilaiSuhu);
    Serial.println("\t");

    Serial.print("Load_cell output val: ");
    Serial.println(average);
    Serial.println("\t");


    // Handle flag reset logic
    if (dimmerSetTo10 && newVal != 10) {
      dimmerSetTo10 = false; // Reset the flag if dimmer power changes from 10
    }
  }
}



