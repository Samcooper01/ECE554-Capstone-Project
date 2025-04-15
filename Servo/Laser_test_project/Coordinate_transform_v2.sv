
module Coordinate_transform_v2 #(
    parameter pan_FOV = 40,//20
    parameter tilt_FOV = 30//15
	//assumes 640 x 480, hardcoded
    //parameter x_res = 640,
    //parameter y_res = 480
    )
	(input[9:0] x,
	 input[8:0] y,
     input clk, rst_n, pan_ready, tilt_ready,
     output logic [10:0] pan, tilt);

    // Find # of us that is in the FOV
    logic signed[9:0]available_pan, available_tilt;
    assign available_pan = (pan_FOV * 1000) / 180;
    assign available_tilt = (tilt_FOV * 1000) / 180;

	// Find 0,0 in duty cycle
	logic [10:0]pan_zero, tilt_zero;
	assign pan_zero = 500 - available_pan;
	assign tilt_zero = 500 - available_tilt;

	// Find duty cycle of one pixel (scaled by 32 to maintain decimals)
	logic [20:0] pan_pixel, tilt_pixel;
	assign pan_pixel = available_pan * 32 / 640;
	assign tilt_pixel = available_tilt * 32 / 480;

	// Calculate total duty cycle and wait for servo ready
    logic signed [10:0] pan_calc;
    logic signed [10:0] tilt_calc;

  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		 pan_calc 	<= '0;
		 tilt_calc 	<= '0;	
	end
	else begin
		 pan_calc <=  pan_zero + (pan_pixel * x) / 32;
		 tilt_calc <= tilt_zero + (tilt_pixel * y) / 32;
			 
		 if(pan_ready)begin 
			pan <=  pan_calc;
		 end
		 if(tilt_ready)begin
			tilt <= tilt_calc;
		 end
	end
  end
endmodule
