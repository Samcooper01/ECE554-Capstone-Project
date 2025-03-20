# Servo Driver Documentation and Helpful Links

## Description

This project utilized servo motors to control the position of the laser in relative space. As a guide for myself, and others who may look at this project, the following README includes information on links, formulas, and other research done to develop servo motor drivers for the DE1-SOC FPGA platform.

## Table of Contents

- [Servo Background](#servo-background)
- [Increasing Servo Frequency](#increasing-servo-frequency)
- [Contact](#contact)

## Servo Background
A servos position can be changed by altering the duty cycle in which the waveform is 'high' within the given frequency. Typical hobby servos such as the [SG90](https://www.digikey.com/en/products/detail/adafruit-industries-llc/2442/5774227?gclsrc=aw.ds&&utm_adgroup=&utm_source=google&utm_medium=cpc&utm_campaign=PMax%20Shopping_Product_Low%20ROAS%20Categories&utm_term=&utm_content=&utm_id=go_cmp-20243063506_adg-_ad-__dev-c_ext-_prd-5774227_sig-Cj0KCQjwhMq-BhCFARIsAGvo0Kc7ixLch38v1EJsi52IYp3FfPRyB6fOx_S5mStgw-6WBdehHv7GicQaAvgWEALw_wcB&gad_source=1&gclid=Cj0KCQjwhMq-BhCFARIsAGvo0Kc7ixLch38v1EJsi52IYp3FfPRyB6fOx_S5mStgw-6WBdehHv7GicQaAvgWEALw_wcB&gclsrc=aw.ds) which is being used for this project operate at a frequency of 50Hz. The duty cycle can range from 1ms to 2ms indicating the position the servo should move to. The diagram below represents these three finite positions of the servo and their corresponding positions. <br>

![PWM Diagram](documentation/pwm-diagram-2.jpg)

Now, there are essentially an infinite number of positions the servo can assume considering the duty cycle. Thus, we want to break the 1ms window for the equivalent degree positions of 0 to 180 into 'slices' with the appropriate duty cycle (in us so we don't lose accuracy). We can accomplish this by using the following formula. 

#### Duty Cycle = 1000 + ( (degree_val * 1000.00) / 180) 

The duty cycle will yield an integer indicating the duty cycle in microseconds. An important note to this formula is that it only gives us 180 positions, one for each degree for the range of movement of the servo, if you want more, simply increase 180 to improve the number of positions you'd like to acheive. 

## Increasing Servo Frequency
Increasing the frequency at which the servo operates is possible. There is nothing wrong with sending a PWM signal twice or three times as often. The consideration here is that you are trading off accuracy for speed. The website [here](https://blog.wokwi.com/learn-servo-motor-using-wokwi-logic-analyzer/) has some helpful information on this.

We took the time to explore this option using Arduino. The following Arduino code snipped gives insight to what we did to accomplish this. You can also find the full Arduino prototype in its respective folder of this project. 

```
void writepos(int deg, int pin) { 
    int duty = (1000 + ((deg * 1000.0)/180.00));
    int period = (1/FREQ) * 1000000;
    int low_duty = period - duty;

    digitalWrite(pin, HIGH);
    delayMicroseconds(duty); 
    digitalWrite(pin, LOW);
    delayMicroseconds(low_duty); 
}
```

This was also a helpful exercise to further understand how communication with a servo actually works without using the dumbed down version Arduino affords you with the ```Servo.h``` library. In fact, there will likely be a similar implementation to our Verilog implementation of this driver.

This [Arduino Forum](https://forum.arduino.cc/t/how-can-i-change-the-frequency-of-servo-library/148099/3) also has useful information that guided our solution above. 


## Contact

Nathan Woolf <br>
Email: nathanwoolf38@outlook.com <br>
[LinkedIn](https://www.linkedin.com/in/nathanwoolf002/) <br>

