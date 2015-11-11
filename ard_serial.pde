//Notes : https://www.freesound.org/people/pinkyfinger/
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import processing.serial.*;
Minim minim;
AudioSample[] notes = new AudioSample[12];
Serial port;

void setup() { 
  
  size(200, 200); 
  frameRate(60);
  minim = new Minim(this);
  for(int i = 0; i <= 11; i++) {
    notes[i] = minim.loadSample("note_" + i + ".wav");
  }
  port = new Serial(this, Serial.list()[0], 9600);
}

void draw() { 
  background(255);
 
  int key_int = readBytesFromSerial(); //simulateBytesFromSerial(); 
  if (key_int >= 0) { //While the number given from readBytesFromSerial is > 0 (finished subtracting)
    for (int j = 11; j >= 0; j--) { //Iterate down with j
      int b = (int) Math.pow(2,j);  //Raise 2 to the jth power
      if (key_int >= b) { //If the Raised number is less than the Bytes from serial num (and start subtracting) 
        key_int -= b; //Subtract them and create the new key_int
        notes[j].trigger(); //Play the sounds in the current iteration
      }
    }
  }
}

// Simulates readBytesFromSerial sending the integers in pattern at 1000 ms intervals
int[] pattern = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 3, 5, 6, 7}; // multi press pattern {3, 5, 6, 7, 9, 10, 11, 12, 1
int stage = 0, t = millis(), delay = 1000;
int simulateBytesFromSerial() {
  int data;
  if (millis() - t > delay) { // if delay has passed
    data = pattern[stage++]; // select next sound from pattern
    if (stage == pattern.length) stage = 0;
    t = millis();
  } else {
    data = -1; // otherwise simulate no data
  }
  return(data);
}

// Reads up to four bytes from the serial port and returns them as a single integer; Returns -1 if serial port has no data
int readBytesFromSerial() {
  byte[] data = port.readBytes();
  if (data != null) {    
    return(byteArrayToInt(data, data.length));
  }
  return(-1);
  
}

// Converts an array of N bytes to an integer
int byteArrayToInt(byte[] b, int size) {
  int result = 0;
  for (int i=size-1; i>=0; i--) {
    result |= (b[i] & 0xff) << 8*i;
  }
  return(result);
}