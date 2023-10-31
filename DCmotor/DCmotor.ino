#include "PCA9685.h"
#include <SparkFun_TB6612.h>
#include <Wire.h>

#define PWMA A4
#define AIN2 A5
#define AIN1 A6
#define STBY A7

Motor DCmotor = Motor(AIN1, AIN2, PWMA, 1, STBY);
int currCase = 0;

void setup() {
    Serial.begin(9600);  
    pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  if (Serial.available()) {

    currCase = Serial.read();
    Serial.println("Current Case: " + String(currCase));
  }

  if (currCase == 1 || currCase == 2 || currCase == 3) {
    switch (currCase) {
      case 1: 
        DCmotor.drive(255);
        digitalWrite(LED_BUILTIN, HIGH);
        break;
      case 2:
        DCmotor.drive(255, 1000);
        DCmotor.drive(0, 1000);
        DCmotor.drive(-255, 1000);
        DCmotor.drive(0, 1000);
        digitalWrite(LED_BUILTIN, LOW);
        break;
      case 3: 
        DCmotor.drive(0);
        digitalWrite(LED_BUILTIN, LOW);
        break;
    }
  }
}