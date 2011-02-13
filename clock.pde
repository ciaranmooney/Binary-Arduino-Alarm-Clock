/*
Put serial monitor in setup look so it sets time at start,
use while nothing is read on serial line. It should wait until
time inputted, then move into main loop.

Main loop should update every second.
*/

#include <TimerOne.h>

char buffer[18];

int latchPin = 8; //Pin connected to Pin 12 of 74HC595 (Latch)
int clockPin = 12; //Pin connected to Pin 11 of 74HC595 (Clock)
int dataPin = 11; //Pin connected to Pin 14 of 74HC595 (Data)

int sec = 0;
byte minute = 35;
byte hour = 4;

void setup() {
        //set pins to output 
        Serial.begin(115200);
        Serial.flush();
        pinMode(latchPin, OUTPUT);
        pinMode(clockPin, OUTPUT);
        pinMode(dataPin, OUTPUT);
        
        while (!Serial.available()) {
        }
        
  if (Serial.available() > 0) {
    		int index=0;
    		delay(100); // let the buffer fill up
    		int numChar = Serial.available();
    		if (numChar>15) {
      			numChar=15;
   		 }
    		while (numChar--) {
      			buffer[index++] = Serial.read();
    		}
                //Serial.println(buffer);
    		splitString(buffer);
  	}   
       Timer1.initialize(1000000);
       Timer1.attachInterrupt(updateTime);  
        
}

void loop() {
}

void splitString(char* data) {
  	Serial.print("Data entered: ");
  	Serial.println(data);
  	char* parameter; 
	parameter = strtok (data, " ,");
        setTime(parameter);
  	while (parameter != NULL) {
    		setTime(parameter);
    		parameter = strtok (NULL, " ,");
}

 	 // Clear the text and serial buffers
  	for (int x=0; x<16; x++) {
    		buffer[x]='\0';
 	 }
  	Serial.flush();
}

void setTime(char* data) {
        digitalWrite(latchPin, LOW);
  	if ((data[0] == 'h') || (data[0] == 'H')) {
    		int Ans = strtol(data+1, NULL, 10);
    		hour = constrain(Ans,0,11);
    		Serial.print("hour: ");
    		Serial.println(hour);
                shiftOut(dataPin, clockPin, LSBFIRST, hour);
  	}
  	if ((data[0] == 'm') || (data[0] == 'M')) {
    		int Ans = strtol(data+1, NULL, 10);
    		minute = constrain(Ans,0,59);
    		Serial.print("minute: ");
    		Serial.println(minute);
                shiftOut(dataPin, clockPin, LSBFIRST, minute);
  	}
        digitalWrite(latchPin, HIGH);
        sec = (minute * 60) + (hour *3600);
        
}

void updateTime () {
  sec = sec + 1;
  minute = (sec / 60) % 60;
  hour = (sec / 3600) % 12;
  //Serial.println(sec);
  //Serial.println(minute);
  //Serial.println(hour);
  digitalWrite(latchPin, LOW);
  shiftOut(dataPin, clockPin, LSBFIRST, hour);
  shiftOut(dataPin, clockPin, LSBFIRST, minute);
  digitalWrite(latchPin, HIGH);

}
