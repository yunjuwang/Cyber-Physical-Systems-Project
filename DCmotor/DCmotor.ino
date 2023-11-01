#include "PCA9685.h"
#include <SparkFun_TB6612.h>
#include <Wire.h>

// #define PWMA A4
#define PWMA 10
#define AIN2 A5
#define AIN1 A6
#define STBY A7

#define LED_1 3
#define LED_2 5
#define LED_3 6
#define LED_4 9

Motor DCmotor = Motor(AIN1, AIN2, PWMA, 1, STBY);
int currCase = 0;
int value = 0;

void setup() {
    Serial.begin(9600);  

    pinMode(LED_1, OUTPUT);
    pinMode(LED_2, OUTPUT);
    pinMode(LED_3, OUTPUT);
    pinMode(LED_4, OUTPUT);
}

void loop() {
  if (Serial.available()) {

    value = Serial.read(); // 0-100

    controlMotor();
    controlLED();
  }
}

void controlMotor(){
  int speed = map(value, 0, 70, 255, 0);  
  DCmotor.drive(speed);
}

void controlLED(){
  int brightness = map(value, 10, 70, 255, 0);
  analogWrite(LED_1, brightness);
  analogWrite(LED_2, brightness);
  analogWrite(LED_3, brightness);
  analogWrite(LED_4, brightness);
}