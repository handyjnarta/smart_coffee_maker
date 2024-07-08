/*
  Application:
  - Interface water flow sensor with ESP32 board.
  
  Board:
  - ESP32 Dev Module
    https://my.cytron.io/p-node32-lite-wifi-and-bluetooth-development-kit
  Sensor:
  - G 1/2 Water Flow Sensor
    https://my.cytron.io/p-g-1-2-water-flow-sensor
 */

#define SENSOR  27

unsigned long currentMillis_wf = 0;
unsigned long previousMillis_wf = 0;
int interval = 1000; // 1 second interval
float calibrationFactor = 500.0; // For every 500 pulses, 1 liter of water passes through the sensor per minute.
volatile byte pulseCount;
float flowRate;
float flowMilliLitres;
float totalMilliLitres;

void IRAM_ATTR pulseCounter()
{
  pulseCount++;
}

void setup()
{
  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SENSOR, INPUT_PULLUP);

  pulseCount = 0;
  flowRate = 0.0;
  flowMilliLitres = 0.0;
  totalMilliLitres = 0.0;
  previousMillis_wf = 0;

  attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);
}

void loop()
{
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
    Serial.print("\t");       // Print tab space

    // Print the cumulative total of milliliters flowed since starting
    Serial.print("Output Liquid Quantity: ");
    Serial.print(totalMilliLitres, 2);  // Print the total in mL with 2 decimal places
    Serial.println(" mL");

    previousMillis_wf = currentMillis_wf;
  }
}
