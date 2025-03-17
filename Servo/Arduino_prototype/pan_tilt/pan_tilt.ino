#include <Servo.h>

Servo pan; 
Servo tilt;

bool start;
int val; 
int potpin = 0;
bool dir = false;
int pos;

int x; 
int y;

int delta = 15;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  tilt.attach(5);
  pan.attach(6);
  x = 45; 
  y = 45;

  start = true;
}

void loop() {

  if (init) { 
    pan.write(x);
    delay(15); 
    tilt.write(y);
    delay(15);
    start = false;
  }

   write_pos(75, 75);
   write_pos(75, 105);
   write_pos(105, 105); 
   write_pos(105, 75);
  

  // if (dir) {
  //   for (pos = 0; pos <= 180; pos += 5) { // goes from 0 degrees to 180 degrees
  //     // in steps of 1 degree
  //     pan.write(pos);      
  //     val = analogRead(potpin);           
  //     val = map(val, 0, 1023, 0, 180);    
  //     tilt.write(val);                       
  //     delay(20);                   
  //   }
  //   dir = !dir;
  //    delay(50);
  // }
  // else {
  //   for (pos = 180; pos >= 0; pos -= 5) { 
  //     pan.write(pos);          
  //     val = analogRead(potpin);            
  //     val = map(val, 0, 1023, 0, 180);    
  //     tilt.write(val);                 
  //     delay(20);                    
  //   }
  //   delay(50);
  //   dir = !dir;
  // }
}

void write_pos(int p, int t) {
  while (p != x || t != y) { 
    if (p < x) { //p is less than curr pos, sub
      x -= delta;
    } else if (p > x) {   //p is greater than curr pos, add
      x += delta;
    } 

    if (t < y) { 
      y -= delta;
    } else if (t > y) { 
      y += delta;
    }
    pan.write(x);
    tilt.write(y); 
    delay(15);
  } 

  delay(200);
}
