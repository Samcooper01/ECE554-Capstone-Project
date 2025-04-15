
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

    // Find # of us that is in the FOV (~FOV*11.111...)
    logic signed[9:0]available_pan, available_tilt;
    assign available_pan = (pan_FOV * 14'd11111) / 10'd1000; 
    assign available_tilt = (tilt_FOV * 14'd11111) / 10'd1000;

	// Center x, y on grid for calculations (assumes top left is 0,0), accounts for servo install
    logic signed [10:0] x_adj;
    logic signed [10:0] y_adj;
    logic signed [20:0] x_mult, y_mult;
    logic signed [31:0] x_div, y_div;
  always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		 x_adj 	<= '0;
		 y_adj 	<= '0;
		 x_mult 	<= '0;
		 y_mult 	<= '0;
		 x_div 	<= '0;
		 y_div 	<= '0;	
	end
	else begin
		 x_adj 	<= 10'd320 - x;
		 y_adj 	<= y - 10'd240;
		 x_mult 	<= x_adj * available_pan;
		 y_mult 	<= y_adj * available_tilt;
		 x_div 	<= (x_mult * 205) >>> 17;
		 y_div 	<= (y_mult * 546) >>> 17; // was 21
			 
		 if(pan_ready)begin 
			pan <=  x_div + 500;
		 end
		 if(tilt_ready)begin
			tilt <= y_div + 590;
		 end
	end
  end
endmodule
