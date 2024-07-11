#include <RBDdimmer.h>
#include "max6675.h"
#include <PID_v1.h>

//#define Serial  SerialUSB //Serial for boards with USB serial port

#define outputPin  12 
#define zerocross  5 // for boards with CHANGEBLE input pins

dimmerLamp dimmer(outputPin, zerocross); // Initialize port for dimmer for ESP8266, ESP32, Arduino due boards
//dimmerLamp dimmer(outputPin); // Initialize port for dimmer for MEGA, Leonardo, UNO, Arduino M0, Arduino Zero

int thermoSO = 19;
int thermoCS = 23;
int thermoCLK = 13;

MAX6675 thermocouple(thermoCLK, thermoCS, thermoSO);

// Define PID variables
double Setpoint, Input, Output;
double Kp = 1.0, Ki = 0.5, Kd = 0.1; // Tune these values as needed
PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);

unsigned long previousMillis = 0;
const long interval = 500; // Interval for temperature update
unsigned long setpointReachedMillis = 0;
const long setpointDelay = 10000; // 10 second delay

bool dimmerSetTo10 = false; // Flag to track if the dimmer power was set to 10%

void setup() {
  Serial.begin(9600); 
  dimmer.begin(NORMAL_MODE, ON); // Dimmer initialization: name.begin(MODE, STATE) 
  Serial.println("Dimmer Program is starting...");
  Serial.println("Set value");

  // Initialize the PID controller
  Setpoint = 60; // Set the desired temperature
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(0, 80); // Output limits for the dimmer (0-80%)

  // Wait for MAX chip to stabilize
  //delay(500);
}

void printSpace(int val) {
  if ((val / 100) == 0) Serial.print(" ");
  if ((val / 10) == 0) Serial.print(" ");
}

void loop() {
  unsigned long currentMillis = millis();

  // Check if it's time to update temperature and dimmer
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    Input = thermocouple.readCelsius();
    myPID.Compute(); // Compute the PID output

    int preVal = dimmer.getPower();
    int newVal;

    // Check if the temperature is within 2 degrees of the setpoint
    if (abs(Input - Setpoint) <= 2) {
      // If setpoint reached for the first time, record the time
      if (setpointReachedMillis == 0) {
        setpointReachedMillis = currentMillis;
      }

      // Check if 10 seconds have passed since reaching the setpoint
      if (currentMillis - setpointReachedMillis >= setpointDelay) {
        newVal = 10; // Set the dimmer power to 10 if the temperature is close to the setpoint for 10 seconds
        Output = 10;
        dimmerSetTo10 = true; // Set the flag to true when dimmer power is set to 10%
      } else {
        newVal = (int)Output; // Otherwise, use the PID output
        dimmerSetTo10 = false; // Reset the flag if not set to 10%
      }
    } else {
      // Reset the setpointReachedMillis if the temperature is out of range
      setpointReachedMillis = 0;
      newVal = (int)Output; // Use the PID output
      dimmerSetTo10 = false; // Reset the flag if not set to 10%
    }

    // Ensure the dimmer power is set smoothly
    dimmer.setPower(newVal); // setPower(0-100%)

    if (preVal != newVal) {
      Serial.print("TempValue -> ");
      printSpace(newVal);
      Serial.print(newVal);
      Serial.println("%");
    }
    Serial.print("C = ");
    Serial.println(Input);

    // Handle flag reset logic
    if (dimmerSetTo10 && newVal != 10) {
      dimmerSetTo10 = false; // Reset the flag if dimmer power changes from 10
    }
  }
}