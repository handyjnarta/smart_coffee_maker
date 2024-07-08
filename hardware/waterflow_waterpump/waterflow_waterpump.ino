/*
 * This is Arduino Sketch for Tutorial video 
 * explaining why resistor is needed to be used with push button
 * with Arduino to connect the pin to Ground (GND)
 * 
 * Written by Ahmad Shamshiri on July 18, 2018 at 17:36 in Ajax, Ontario, Canada
 * For Robojax.com
 * Watch instruction video for this code: https://youtu.be/tCJ2Q-CT6Q8
 * This code is "AS IS" without warranty or liability. Free to be used as long as you keep this note intact.
 */

// Motor control variables
int motorPin = 14;  // Pin to connect to motor module
int mSpeed = 200;   // Variable to hold speed value
int mStep = 15;     // Increment/decrement step for PWM motor speed

// Water flow sensor variables
#define SENSOR  27
unsigned long currentMillis_wf = 0;
unsigned long previousMillis_wf = 0;
int interval = 1000;  // 1 second interval
float calibrationFactor = 500.0;  // For every 500 pulses, 1 liter of water passes through the sensor per minute.
volatile byte pulseCount;
float flowRate;
float flowMilliLitres;
float totalMilliLitres;

// Interrupt service routine for pulse counting
void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

void setup() {
  // Motor setup
  pinMode(motorPin, OUTPUT);  // Set motorPin as output
  Serial.begin(9600);  // Initialize serial communication
  Serial.println("Robojax Demo");

  // Water flow sensor setup
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SENSOR, INPUT_PULLUP);
  pulseCount = 0;
  flowRate = 0.0;
  flowMilliLitres = 0.0;
  totalMilliLitres = 0.0;
  previousMillis_wf = 0;
  attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);
}

void loop() {
  // Motor control
  analogWrite(motorPin, mSpeed);  // Send mSpeed value to motor
  Serial.print("Speed: ");
  Serial.println(mSpeed);  // Print mSpeed value on Serial monitor
  delay(200);

  // Water flow sensor
  currentMillis_wf = millis();
  if (currentMillis_wf - previousMillis_wf >= interval) {
    // Disable the interrupt to accurately calculate the pulse count
    detachInterrupt(digitalPinToInterrupt(SENSOR));
    byte pulses = pulseCount;
    pulseCount = 0;
    // Enable the interrupt again
    attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);

    // Calculate the flow rate in liters per minute (L/min)
    flowRate = ((float)pulses / calibrationFactor);
    // Convert the flow rate to milliliters per second (mL/s)
    flowMilliLitres = (flowRate / 60.0) * 1000.0;
    // Add the milliliters passed in this second to the cumulative total
    totalMilliLitres += flowMilliLitres;

    // Print the flow rate for this second in milliliters / second
    Serial.print("Flow rate: ");
    Serial.print(flowMilliLitres, 2);  // Print the flow rate in mL/s with 2 decimal places
    Serial.print(" mL/s");
    Serial.print("\t");  // Print tab space

    // Print the cumulative total of milliliters flowed since starting
    Serial.print("Output Liquid Quantity: ");
    Serial.print(totalMilliLitres, 2);  // Print the total in mL with 2 decimal places
    Serial.println(" mL");

    previousMillis_wf = currentMillis_wf;
  }
}
