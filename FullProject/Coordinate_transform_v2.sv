
module Coordinate_transform_v2 #(
    parameter pan_FOV = 80,//20
    parameter tilt_FOV = 60//15
	//assumes 640 x 480, hardcoded
    //parameter x_res = 640,
    //parameter y_res = 480
    )
	(input[9:0] x,
	 input[8:0] y,
     input clk, rst_n, pan_ready, tilt_ready,
     output logic [10:0] pan, tilt);

	// logic [10:0] x_adj;
	// logic [10:0] y_adj;

	// logic [6:0] x_factor;
	// logic [6:0] y_factor;

	// assign x_factor = ( (x << 6) / 180);
	// assign y_factor = ( (y << 6) / 180);

    // always_ff @(posedge clk) begin
	// 	pan <= 611 - x_factor;
	// 	tilt <= 417 + y_factor;
	// end

    // Find # of us that is in the FOV
    logic [9:0]available_pan, available_tilt;
    assign available_pan = (pan_FOV * 1000) / 180;
    assign available_tilt = (tilt_FOV * 1000) / 180;

	// Find 0,0 in duty cycle
	logic [10:0]pan_zero, tilt_zero;
	assign pan_zero = 500 + (available_pan >> 1);
	assign tilt_zero = 500 - (available_tilt >> 1);

	// Find duty cycle of one pixel (scaled by 32 to maintain decimals)
	logic [20:0] pan_pixel, tilt_pixel;
	assign pan_pixel = (available_pan << 6) / 640;
	assign tilt_pixel = (available_tilt << 6) / 480;

	// Calculate total duty cycle and wait for servo ready
    logic [10:0] pan_calc;
    logic [10:0] tilt_calc;

  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		 pan_calc 	<= '0;
		 tilt_calc 	<= '0;	
	end
	else begin
		 pan_calc <=  pan_zero - ((pan_pixel * x) / 64); 
		 tilt_calc <= tilt_zero + ((tilt_pixel * y) / 64); 
			 
		 if(pan_ready)begin 
			pan <=  pan_calc;
		 end
		 if(tilt_ready)begin
			tilt <= tilt_calc;
		 end
	end
  end

	// always_ff @(posedge clk, negedge rst_n) begin
	// 	pan <= (pan_ff / 180) + 1389;
	// 	tilt <= (tilt_ff /180) + 1417;
	// end

//     // Find # of us that is in the FOV (~FOV*11.111...)
//     logic signed[9:0]available_pan, available_tilt;
//     assign available_pan = (pan_FOV * 1000) / 180; 
//     assign available_tilt = (tilt_FOV * 1000) / 180;

// 	// Center x, y on grid for calculations (assumes top left is 0,0), accounts for servo install
//     logic signed [10:0] x_adj;
//     logic signed [10:0] y_adj;
//     logic signed [20:0] x_mult, y_mult;
//     logic signed [31:0] x_div, y_div;
//   always_ff @(posedge clk, negedge rst_n) begin
// 	if (!rst_n) begin
// 		 x_adj 	<= '0;
// 		 y_adj 	<= '0;
// 		 x_mult 	<= '0;
// 		 y_mult 	<= '0;
// 		 x_div 	<= '0;
// 		 y_div 	<= '0;	
// 	end
// 	else begin
// 		 x_adj 	<= 320 - x;
// 		 y_adj 	<= y - 240;
// 		 x_mult 	<= x_adj * available_pan;
// 		 y_mult 	<= y_adj * available_tilt;
// 		 x_div 	<= (x_mult * 205) >>> 17;
// 		 y_div 	<= (y_mult * 273) >>> 17; // was 21
			 
// 		 if(pan_ready)begin 
// 			pan <=  x_div + 500;
// 		 end
// 		 if(tilt_ready)begin
// 			tilt <= y_div + 590;
// 		 end
// 	end
//   end
endmodule
