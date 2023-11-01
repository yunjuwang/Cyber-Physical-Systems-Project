//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

//Parameters of sketch
float value;
PFont myFont; 

//Arduino Connection
import processing.serial.*;
Serial port;

//classifier classes
int currCase=1;
int prevCase=1;

// timer for reset currCase
// if not receiving OSC data for a while, set current case to Not Looking
float resetTimer;
float timeToResetCase = 500;

// timer for cold down time for moving motor
float coldDownTimer;
float timeToColdDown = 1000;

void setup() {
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",8338);
  
  colorMode(HSB);
  size(400,400, P3D);
  smooth();
  background(255);

  // Initialize appearance
  value = 0;
  myFont = createFont("Arial", 14);
  
  // Connect to Arduino
  println(Serial.list());  // This lists all your comm ports. Look for the one that matches in Arduino IDE. Remember that lists start from position 0 in programming :)
  String portName = Serial.list()[2];  // YOU WILL NEED TO CHANGE THE NUMBER IN THIS TO THE CORRECT INDEX FOR YOUR COMM PORT
  port = new Serial(this, portName, 9600);
  
  // Timer
  resetTimer = millis();
  coldDownTimer = millis();
}

void draw() {
  background(0, 0, 0);
  setResetTimer();
  drawText();
  moveMotor();
}

void setResetTimer(){
  if(millis() - resetTimer >= timeToResetCase){
    prevCase=currCase;
    currCase=1;
    value=0;
    
    resetTimer = millis(); // reset timer
  }
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("f")) { // looking for 1 control value
         float receivedValue = theOscMessage.get(0).floatValue();
         value = map(receivedValue, 0, 1, 0, 100);
         classify(value);
                  
         // if recieve OSC event, reset the timer
         resetTimer = millis();
     } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
     }
 }
}

void drawText() {
    // Write instructions
    stroke(0);
    textFont(myFont);
    textAlign(LEFT, TOP); 
    fill(0, 0, 255); 
    text("Receiving 1 continuous parameter, in range 0-1", 10, 10);
    text("Listening for /wek/outputs on port 12000", 10, 40);
    
    // Write regressor value
    textSize(32);
    textAlign(CENTER, CENTER); 
    text("Face on: "+value+" %", 200, 180);
    if(currCase==1){
      text("not looking at all", 200, 230);
    }
    else if(currCase==2){
      text("looking a little bit", 200, 230);
    }
    else if(currCase==3){
      text("looking face-on", 200, 230);
    }
}

void classify(float value){
    prevCase = currCase;
    if(value<20){
      currCase=1; // not looking at all
    }
    else if(value<70){
      currCase=2; // looking a little bit
    }
    else{
      currCase=3; // looking face-on
    }
}

void moveMotor(){
  if(currCase==prevCase)
    return; // Do nothing if the case doesn't change
    
  if(millis() - coldDownTimer >= timeToColdDown){
    //println("Sent serial message: " + currCase);
    //port.write(currCase);
    println("Sent serial message: " + value);
    port.write((int)value);
  
    coldDownTimer = millis();    
  }
}
