module servo (
    input clk, 
    input rst_n, 
    //input logic [7:0] angle,
    input logic [10:0] pulse_width,
    output logic pwm_pin,
	 output logic open
); 

    //determine how many 50MHz clock cycles are needed to generate a 1us pulse
    // 50MHz = 50,000,000 Hz -> 20ns per clock cycle
    // 1us = 1,000 ns = 1,000 clock cycles
    // 1us / 20ns = 50 FPGA clock cycles for 1us tick

    // Constants -> declared in counter module
    // localparam FREQ = 50; // 50Hz
    // localparam PERIOD = 20000; // 20ms
    // 
    // localparam TICKS_PER_US = 50;       // need us granularity to ensure we can get as many servo pos as possible 
    localparam MIN_PULSE = 1000;        // has units of us

    // Variables
    reg [15:0] counter;
    
    counter CLOCK_GEN (
        .clk(clk),
        .rst_n(rst_n),
        .counter(counter)
    );

    //calculate pulse width based on angle input
    /*reg [15:0] pulse_width;             // units of us
    logic [7:0] logical_angle;

    always_comb begin
        if (angle > 180) begin
            logical_angle = 180;
        end else if (angle < 0) begin
            logical_angle = 0;
        end else begin
            logical_angle = angle;
        end

        pulse_width = MIN_PULSE + ((logical_angle * 1000) / 180);
    end*/

    //generate PWM signal
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            pwm_pin <= 1'b0;
				open <= 1'b0;
        end else begin 
            if (counter <= pulse_width + MIN_PULSE) begin
                pwm_pin <= 1'b1;
					 open <= 1'b0;
            end else begin 
                pwm_pin <= 1'b0;
					 open <= 1'b1;
            end
        end
    end
    

endmodule