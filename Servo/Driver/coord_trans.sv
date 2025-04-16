
module Coordinate_transform_v2 #(
    parameter pan_FOV = 80,
    parameter tilt_FOV = 80
	//assumes 640 x 480, hardcoded
    //parameter x_res = 640,
    //parameter y_res = 480
    )
	(input signed [9:0] x,
	 input signed [8:0] y,
     input clk, rst_n,
     output reg [10:0] pan, tilt);

    logic [10:0] x_adj;
	logic [10:0] y_adj;

	logic [6:0] x_factor;
	logic [6:0] y_factor;

    always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin 
			x_factor <= 111;
			y_factor <= 83;
		end
		else begin
			x_factor = ( (x << 6) / 180);
			y_factor = ( (y << 6) / 180);
 
			pan <= 611 - x_factor;
			tilt <= 0;
		end
    end
endmodule
