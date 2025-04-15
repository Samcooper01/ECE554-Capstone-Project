
module Coordinate_transform_v2 #(
    parameter pan_FOV = 40,
    parameter tilt_FOV = 30
	//assumes 640 x 480, hardcoded
    //parameter x_res = 640,
    //parameter y_res = 480
    )
	(input signed [9:0] x,
	 input signed [8:0] y,
     input clk, rst_n,
     output reg [10:0] pan, tilt);

    logic [9:0] x_adj = x >>> 4;
    logic [8:0] y_adj = y >>> 4;


    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin 
            pan <= 11'd0;
            tilt <= 11'd0;
        end
        else begin 
            pan = 1389 + ( (x_adj * 1000) / 180);
            tilt = 1417 + ( (x_adj * 1000) / 180);
        end
    end
endmodule
