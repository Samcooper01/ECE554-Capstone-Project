module Coordinate_tb();
    logic signed [10:0] x;
    logic signed [9:0] y;
    logic fill_LUT, clk, rst_n;
    logic ready;
    logic [10:0] pan, tilt;

    Coordinate_Transform iTrans(.*);
initial begin
  clk = 0;
  rst_n = 0;
  fill_LUT = 0;
  x = 0;
  y = 0;
  repeat(2)@(posedge clk);
  @(negedge clk) rst_n = 1;
  @(negedge clk) fill_LUT = 1;
  @(negedge clk) fill_LUT = 0;

  @(posedge ready) $display("LUT full");
	$stop();
end

always
  #5 clk = ~clk;
  



endmodule
