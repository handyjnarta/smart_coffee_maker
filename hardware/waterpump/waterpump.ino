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
int motorPin =14;// pin to connect to motor module
int mSpeed = 200;// variable to hold speed value
int mStep = 15;// increment/decrement step for PWM motor speed
  
void setup() {
  // Robojax.com demo
  pinMode(motorPin,OUTPUT);// set mtorPin as output
  Serial.begin(9600);// initialize serial motor
  Serial.println("Robojax Demo");
  

}

void loop() {
  // Robojax.com  tutorial

analogWrite(motorPin, mSpeed);// send mSpeed value to motor
    Serial.print("Speed: ");
    Serial.println(mSpeed);// print mSpeed value on Serial monitor (click on Tools->Serial Monitor)
  
  
delay(200);
}
