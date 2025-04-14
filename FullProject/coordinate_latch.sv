module coordinate_latch(
    input rst_n,
    input oCent_Val,
    input [9:0] oX_Cent,
    input [8:0] oY_Cent,
    output [9:0] tracked_coordinates_x,
    output [8:0] tracked_coordinates_y
);

// Intermediate Signals
logic [9:0] intermediate_x;
logic [8:0] intermediate_y;

// Latch Logic
assign tracked_coordinates_x = intermediate_x;
assign tracked_coordinates_y = intermediate_y;
always @(oCent_Val, oX_Cent, oY_Cent, rst_n) begin
    if (!rst_n) begin
        intermediate_x = 320;
        intermediate_y = 240;
    end
    else if (oCent_Val) begin
        intermediate_x = oX_Cent;
        intermediate_y = oY_Cent;
    end
end

endmodule