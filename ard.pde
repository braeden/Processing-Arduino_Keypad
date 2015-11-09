//Notes : https://www.freesound.org/people/pinkyfinger/
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import processing.serial.*;
Minim minim;
AudioPlayer song;
Serial port;

void setup() { 
 
  size(200, 200); 
  frameRate(60);
  minim = new Minim(this);
  //port = new Serial(this, Serial.list()[0], 9600);
}

void draw() { 
  background(255);
 
  int key_int = simulateBytesFromSerial(); // readBytesFromSerial();
  if (key_int >= 0) {
    for(int i = 0; i <= 11; i++) { //2^11 = 2048 which is the limit
      int a = (int) Math.pow(2,i); //Raises 2 to the i th power and makes ints instead of doubles
      if (key_int == a) { //Checks if the 2^i is the same as the keyboard generated number
        String name = "note_" + i; //Generates file names starting with "note_0"
        song = minim.loadFile(name + ".wav"); //Loads it and appends .wav extension
        song.play(); //Plays the note
      }
    }
    //Error:
    /*
    ==== JavaSound Minim Error ====
    ==== Couldn't open the line: line with format PCM_SIGNED 44100.0 Hz, 16 bit, stereo, 4 bytes/frame, little-endian not supported.
    
    === Minim Error ===
    === Couldn't load the file note_4.wav
    */
  }
}

// Simulates readBytesFromSerial sending the integers in pattern at 1000 ms intervals
int[] pattern = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048}; // multi press pattern {3, 5, 6, 7, 9, 10, 11, 12, 1
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