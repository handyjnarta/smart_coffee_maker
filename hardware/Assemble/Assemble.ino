#include <RBDdimmer.h>
#include "max6675.h"
#include <PID_v1.h>
#include <HX711_ADC.h>
#include "BluetoothSerial.h"

BluetoothSerial ESP_BT;
#define outputPin  12 
#define zerocross  5

dimmerLamp dimmer(outputPin, zerocross);

int thermoSO = 19;
int thermoCS = 23;
int thermoCLK = 13;

MAX6675 thermocouple(thermoCLK, thermoCS, thermoSO);

double Setpoint, NilaiSuhu, Output;
double Kp = 1.0, Ki = 0.5, Kd = 0.1;
PID myPID(&NilaiSuhu, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);


unsigned long previousMillis = 0;
const long interval = 500;
// unsigned long setpointReachedMillis = 0;
const long setpointDelay = 10000;
unsigned long previousMillis_print = 0;

const int HX711_dout = 15;
const int HX711_sck = 26;
float sum = 0.0;
HX711_ADC LoadCell(HX711_dout, HX711_sck);

unsigned long t = 0;
int motorPin = 14;
int motorSpeed = 0;  

float average = 0.0;
int totalVolume = 0;
int numSteps = 0;
int pouringVolumes[100];
int pouringDurations[100];
int pouringIntervals[100];
enum ProgramState {
  WAITING_FOR_INPUT,
  POURING,
  COMPLETED
};
ProgramState currentState = WAITING_FOR_INPUT;
double readDoubleFromSerial() {
  String input = "";
  while (true) {
    if (ESP_BT.available() > 0) {
      char c = ESP_BT.read();
      if (c == '\n') {
        return input.toDouble();
      } else {
        input += c;
      }
    }
  }
}
int readIntFromSerial() {
  String input = "";
  while (true) {
    if (ESP_BT.available() > 0) {
      char c = ESP_BT.read();
      if (c == '\n') {
        return input.toInt();
      } else {
        input += c;
      }
    }
  }
}

char readSingleCharFromSerial() {
  while (true) {
    if (ESP_BT.available() > 0) {
      return ESP_BT.read();
    }
  }
}



void setup() {
  Serial.begin(9600);
  ESP_BT.begin("ESP32-BT-Slave-Qorexf");// jangan dipake ESP32_Coffee_Control, 
  Serial.println("Bluetooth Device is Ready to Pair");
  dimmer.begin(NORMAL_MODE, ON);
  Serial.println("Dimmer Program is starting...");
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(0, 80);
  LoadCell.begin();
  float calibrationValue = -802.12;
  unsigned long stabilizingtime = 2000;
  boolean _tare = true;
  LoadCell.start(stabilizingtime, _tare);
  
  if (LoadCell.getTareTimeoutFlag()) {
    ESP_BT.println("Timeout, check MCU>HX711 wiring and pin designations");
    while (1);
  } else {
    LoadCell.setCalFactor(calibrationValue);
    ESP_BT.println("Startup is complete");
    pinMode(motorPin, OUTPUT);
  }

  //currentState = WAITING_FOR_INPUT;
  Serial.println("Mulai bang");
  //ESP_BT.println("Mulai Bangk");

}

void askForInputs() {
  totalVolume = 0;
  //ESP_BT.println("Enter desired temperature setpoint: ");
  if (ESP_BT.available()) {
    char incoming = ESP_BT.read();//char incoming = 's';
    if (incoming == 'a'){
      //delay(1000);
      //ESP_BT.println("Enter desired temperature setpoint: ");
      Setpoint = readDoubleFromSerial();
      while (Setpoint < 30.00 || Setpoint > 94.00) {
        //ESP_BT.println("Input is wrong");
        ESP_BT.println("Enter desired temperature setpoint: ");
        Setpoint = readDoubleFromSerial();
        //delay(1000);
      }
      ESP_BT.printf("Setpoint accepted: %.2f", Setpoint);
      ESP_BT.println('\n');
      ESP_BT.println("Enter number of pouring steps: ");
      numSteps = readIntFromSerial();
      while (numSteps < 1) {
        ESP_BT.println("Input is wrong");
        ESP_BT.println("Enter again number of pouring steps: ");
        numSteps = readIntFromSerial();
      }
      for (int step = 1; step <= numSteps; ++step) {
        ESP_BT.print("Enter desired water volume for step ");
        ESP_BT.print(step);
        ESP_BT.println(": ");
        int volwater = readIntFromSerial();
        pouringVolumes[step - 1] = volwater;
        totalVolume += volwater;
        ESP_BT.print("Enter duration (in seconds) for pouring step ");
        ESP_BT.print(step);
        ESP_BT.println(": ");
        pouringDurations[step - 1] = readIntFromSerial();
        ESP_BT.print("Enter interval time (in seconds) between pouring step ");
        ESP_BT.print(step);
        ESP_BT.println(": ");
        pouringIntervals[step - 1] = readIntFromSerial();
      }

      //ESP_BT.print("Total water volume: ");
      //ESP_BT.println(totalVolume);

      currentState = POURING;
    }
    else if (incoming == 'r') {
        Setpoint = readDoubleFromSerial();
        while (Setpoint < 30.00 || Setpoint > 94.00) {
          //ESP_BT.println("Input is wrong");
          ESP_BT.println("Desired temperature setpoint from recipe: ");
          Setpoint = readDoubleFromSerial();
          //delay(1000);
        }
        ESP_BT.printf("Setpoint accepted: %.2f", Setpoint);
        ESP_BT.println('\n');
        ESP_BT.println("Number of pouring steps from recipe: ");
        numSteps = readIntFromSerial();
        for (int step = 1; step <= numSteps; ++step) {
          ESP_BT.print("Desired water volume for step from recipe: ");
          ESP_BT.print(step);
          ESP_BT.println(": ");
          int volwater = readIntFromSerial();
          pouringVolumes[step - 1] = volwater;
          totalVolume += volwater;
          ESP_BT.print("Duration (in seconds) from recipe for pouring step  ");
          ESP_BT.print(step);
          ESP_BT.println(": ");
          pouringDurations[step - 1] = readIntFromSerial();
          ESP_BT.print("Interval time (in seconds) from recipe between pouring step ");
          ESP_BT.print(step);
          ESP_BT.println(": ");
          pouringIntervals[step - 1] = readIntFromSerial();
        }

        currentState = POURING;
    } else {
      ESP_BT.print("kalau gamau running resep ini refresh aja ya ");
    }
    }
    dimmer.setPower(0);
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
  motorSpeed = speed;            // Update global motor speed variable
  analogWrite(motorPin, speed);  // Set motor speed
  delay(20);                     // Short delay
}

void loop() {
  unsigned long currentMillis = millis();
  switch (currentState) {
    case WAITING_FOR_INPUT: {
      askForInputs();
      break;
    }

    case POURING: {
      int newVal;


      if (currentMillis - previousMillis >= interval) {
        previousMillis = currentMillis;

        NilaiSuhu = thermocouple.readCelsius();
        ESP_BT.printf("C -OL = %.2f", NilaiSuhu);
        myPID.Compute();

        int preVal = dimmer.getPower();


        if (abs(NilaiSuhu - Setpoint) <= 1 || (NilaiSuhu > Setpoint) ) {
          newVal = 0;
          Output = 0;

          static int step = 0;
          static unsigned long stepStartTime = 0;
          static bool pouring = false;

          for (step = 0; step < numSteps; step++) {
            int volwater = pouringVolumes[step];
            int pourDuration = pouringDurations[step];
            int pourInterval = pouringIntervals[step];
            updateLoadCell();
              controlMotor(100);
              ESP_BT.println("mengalir bang");
              stepStartTime = millis();
              pouring = true;

            while (pouring) {
              dimmer.setPower(newVal);
              float volumeLoadCells = average;
              unsigned long currentMillis_print = millis(); // Get current time
              unsigned long interval_print = 500; // Print interval
              if (currentMillis_print - previousMillis_print >= interval_print) {
                previousMillis_print = currentMillis_print;
                ESP_BT.printf("C = %.2f", NilaiSuhu);
                ESP_BT.println('\n');
                //delay(100);
                updateLoadCell();
                ESP_BT.printf("total water weight: %.2f", volumeLoadCells);
                //ESP_BT.println();
              }
              if (millis() - stepStartTime >= pourDuration * 1000 && (volumeLoadCells+20) >= volwater )  {
                //ESP_BT.print("udah berhenti");
                ESP_BT.println('\n');
                ESP_BT.printf("total water weight: %.2f", (volumeLoadCells+10));
                ESP_BT.printf("total water weight: %.2f", (volumeLoadCells+10));
                //ESP_BT.printf("total water weight: %d", (volumeLoadCells+10));
                controlMotor(0);
                volumeLoadCells = 0;
                pouring = false;
                if (step < numSteps - 1) {
                  delay(pourInterval * 1000);
                }


              }

            }

          }

          ESP_BT.println("All pouring steps completed.");
          newVal = 0;
          controlMotor(0);
          step = 0;
          currentState = COMPLETED;
        } else {
          // setpointReachedMillis = 0;
          newVal = (int)Output;
        }

        dimmer.setPower(newVal);

        /*if (preVal != newVal) {
          Serial.print("TempValue -> ");
          Serial.print(newVal);
          Serial.println("%");
        }*/


      }
      break;
    }

    case COMPLETED: {
      ESP_BT.println("Pouring session completed. Enter new values to restart.");

      currentState = WAITING_FOR_INPUT;
      break;
    }
  }
}