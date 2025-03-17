#define FREQ 400

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(12, OUTPUT); 
  pinMode(13, OUTPUT);  
}

int pan = 12; 
int tilt = 13;

void loop() {
  //  write_pos(75, 75);
  //  write_pos(75, 105);
  //  write_pos(105, 105); 
  //  write_pos(105, 75);

  // //pos1
  // writepos(15, pan); 
  // writepos(90, tilt); 

  // //pos2
  // writepos(45, pan); 
  // writepos(90, tilt); 

  // //pos3
  // writepos(135, pan); 
  // writepos(90, tilt); 

  // //pos4
  // writepos(135, pan); 
  // writepos(90, tilt);

  writepos(90, tilt);
  for (int i = 0; i <= 180; i += 5) { 
    writepos(i, pan);
  }

  delay(500); 
  writepos(0, pan); 
  delay(500);
}

void write90() { 
  for (int i = 0; i < 20; i += 1) 
  {
    digitalWrite(12, HIGH);
    delayMicroseconds(1500); // The range of the pulse is between 1000µs till 2000µs (from 0 till 180degrees)
    digitalWrite(12, LOW);
    delayMicroseconds(8500); // This will result into a period. NOTE: 18500+1500=20000µs=20ms which is the period
  }
}

void write75(int pin) { 
  for (int i = 0; i < 12; i += 1) 
  {
    digitalWrite(pin, HIGH);
    delayMicroseconds(1416); 
    digitalWrite(pin, LOW);
    delayMicroseconds(3584); 
  }
}

void write105(int pin) { 
  for (int i = 0; i < 12; i += 1) 
  {
    digitalWrite(pin, HIGH);
    delayMicroseconds(1584); 
    digitalWrite(pin, LOW);
    delayMicroseconds(3416); 
  }
}

void writepos(int deg, int pin) { 
  int duty = (1000 + ((deg * 1000.0)/180.00));
  int period = (1/FREQ) * 1000000;
  int low_duty = period - duty;

    digitalWrite(pin, HIGH);
    delayMicroseconds(duty); 
    digitalWrite(pin, LOW);
    delayMicroseconds(low_duty); 
}