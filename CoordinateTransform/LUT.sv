module LUT #(
	parameter x_res = 640,
	parameter y_res = 480
    )
    (x, y, pan, tilt, pan_in, pan_we, tilt_in, tilt_we, clk);

    input signed[10:0]x;
    input signed[9:0]y;
    output reg[10:0] pan, tilt;

    input pan_we, tilt_we;
    input[10:0] tilt_in, pan_in;
    input clk;


    reg[10:0] pan_data [0:x_res-1];
    reg[10:0] tilt_data [0:y_res-1];


    always_ff @(posedge clk) begin
      if(pan_we)
            pan_data[x] <= pan_in;
    end

    

    always_ff @(posedge clk) begin
        if(tilt_we)
            tilt_data[y] <= tilt_in;
    end

    always_ff @(posedge clk) begin
      tilt <= tilt_data[y] + 10'd1000;
      pan <= pan_data[x] + 10'd1000;
    end
endmodule