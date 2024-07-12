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

const int HX711_dout = 15; //mcu > HX711 dout pin
const int HX711_sck = 26; //mcu > HX711 sck pin
float sum = 0.0;
//HX711 constructor:
HX711_ADC LoadCell(HX711_dout, HX711_sck);

unsigned long t = 0;
//PUMP
int motorPin = 14; // pin to connect to motor module

float average = 0.0;
int totalVolume = 0;
int numSteps = 0;
int pouringVolumes[10]; // Assuming a maximum of 10 pouring steps
int pouringDurations[10];    // Array to store pouring durations
int pouringIntervals[10]; // Array to store interval times between pouring steps

// Define program states
enum ProgramState {
  WAITING_FOR_INPUT,
  POURING,
  COMPLETED
};

ProgramState currentState = WAITING_FOR_INPUT;

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

  // Initial state is WAITING_FOR_INPUT
  currentState = WAITING_FOR_INPUT;
}

void askForInputs() {
  totalVolume = 0;
  
  // Ask for initial values
  Serial.println("Enter desired temperature setpoint: ");
  Setpoint = readDoubleFromSerial();
  Serial.print(Setpoint);
  Serial.println("\t");

  // Ask for number of pouring steps
  Serial.println("Enter number of pouring steps: ");
  numSteps = readIntFromSerial();

  // Loop through each step
  for (int step = 1; step <= numSteps; ++step) {
    Serial.print("Enter desired water volume for step ");
    Serial.print(step);
    Serial.println(": ");
    int volwater = readIntFromSerial(); // Read volume for current step

    pouringVolumes[step - 1] = volwater; // Store volume in array

    // Output the entered volume for verification
    Serial.print("Volume for step ");
    Serial.print(step);
    Serial.print(": ");
    Serial.println(pouringVolumes[step - 1]);
    // Optionally, you can accumulate total volume here if needed
    totalVolume += volwater;

    // Prompt user to enter duration for current step
    Serial.print("Enter duration (in seconds) for pouring step ");
    Serial.print(step);
    Serial.println(": ");
    pouringDurations[step - 1] = readIntFromSerial(); // Read duration for current step

    Serial.print("Duration for step ");
    Serial.print(step);
    Serial.print(": ");
    Serial.print(pouringDurations[step - 1]);
    Serial.println(" seconds");

    // Prompt user to enter interval time between steps
    Serial.print("Enter interval time (in seconds) between pouring step ");
    Serial.print(step);
    Serial.println(": ");
    pouringIntervals[step - 1] = readIntFromSerial(); // Read interval time between steps

    // Print the entered interval time for the current step
    Serial.print("Interval time for step ");
    Serial.print(step);
    Serial.print(": ");
    Serial.print(pouringIntervals[step - 1]);
    Serial.println(" seconds");
  }

  // Output total volume if accumulated
  Serial.print("Total water volume: ");
  Serial.println(totalVolume);

  // After input is done, change state to POURING
  currentState = POURING;
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

  switch (currentState) {
    case WAITING_FOR_INPUT:
      askForInputs();
      break;

    case POURING:
      // Check if it's time to update temperature and dimmer
      if (currentMillis - previousMillis >= interval) {
        previousMillis = currentMillis;

        NilaiSuhu = thermocouple.readCelsius();
        myPID.Compute(); // Compute the PID output

        int preVal = dimmer.getPower();
        int newVal;
        updateLoadCell();

        // Store the value of average in a new variable
        float volumeLoadCells = average;

        // Check if the temperature is within 2 degrees of the setpoint
        if (abs(NilaiSuhu - Setpoint) <= 2) {
          newVal = 10; // Set the dimmer power to 10 if the temperature is close to the setpoint for 10 seconds
          Output = 10;

          // Perform pouring steps if conditions are met
          static int step = 0; // Static variable to track current step
          static unsigned long stepStartTime = 0; // Variable to store start time of current step
          static bool pouring = false; // Flag to indicate if pouring is in progress

          // Check if it's time to perform the next pouring step
          if (step < numSteps) {
            int volwater = pouringVolumes[step]; // Get volume to pour for current step
            int pourDuration = pouringDurations[step]; // Get pouring duration for current step
            int pourInterval = pouringIntervals[step]; // Get interval time between steps for current step

            // Check the state of the pouring process
            if (!pouring) {
              // Start pouring
              Serial.print("Starting Step ");
              Serial.println(step + 1);
              controlMotor(100); // Start pouring

              Serial.println("Pouring water...");
              stepStartTime = millis(); // Record start time of current step
              pouring = true; // Set pouring flag
            } else {
              // Check if pouring duration has elapsed
              if (millis() - stepStartTime >= pourDuration * 1000 && volumeLoadCells >= volwater) {
                controlMotor(0); // Stop pouring
                Serial.println("Water poured.");
                volumeLoadCells = 0;

                // Move to next step after pouring
                step++;
                pouring = false; // Reset pouring flag

                // If there's an interval time, wait before proceeding to the next step
                if (step < numSteps) {
                  Serial.print("Waiting for ");
                  Serial.print(pourInterval);
                  Serial.println(" seconds before next step...");
                  delay(pourInterval * 1000); // Wait for the interval time before proceeding to the next step
                }
              }
            }
          } else {
            // All pouring steps completed
            Serial.println("All pouring steps completed.");
            step = 0; // Reset step counter
            newVal = 0; // Set dimmer to 0 after all steps are completed
            controlMotor(0); // Ensure motor is off

            // Change state to WAITING_FOR_INPUT after completion
            currentState = COMPLETED;
          }
        } else {
          // Reset the setpointReachedMillis if the temperature is out of range
          setpointReachedMillis = 0;
          newVal = (int)Output; // Use the PID output
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
        Serial.print("Load_cell output val: ");
        Serial.println(volumeLoadCells);
        Serial.println("\t");
      }
      break;

    case COMPLETED:
      // Wait for user to restart the process
      Serial.println("Pouring session completed. Enter new values to restart.");
      currentState = WAITING_FOR_INPUT;
      break;
  }
}
