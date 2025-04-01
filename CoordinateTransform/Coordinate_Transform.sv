module Coordinate_Transform #(
    parameter pan_FOV = 45,
    parameter tilt_FOV = 30,
    parameter x_res = 640,
    parameter y_res = 480
    )
    (input signed [10:0] x,
     input signed [9:0] y,
     input fill_LUT, clk, rst_n,
     output reg ready,
     output [10:0] pan, tilt);

    // Center x, y on grid for calculations (assumes bottom right is 0,0)
    logic signed [10:0] x_adj;
    logic signed [9:0] y_adj;
    assign x_adj = x_res/2 - x;
    assign y_adj = y - y_res/2;

    // LUT write control signals
    logic [10:0] pan_in;
    logic [10:0] tilt_in;
    logic pan_we, tilt_we;
    reg [10:0] x_idx;
    reg [9:0] y_idx;
    reg filling;
    // LUT instantiation
    LUT #(x_res, y_res) iLUT(
        .x(filling ? x_idx : x),
        .y(filling ? y_idx : y),
        .tilt(tilt),
        .pan(pan),
        .pan_in(pan_in),
        .tilt_in(tilt_in),
        .pan_we(pan_we),
        .tilt_we(tilt_we),
        .clk(clk)
    );

    // LUT filling logic

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready <= 1;
            filling <= 0;
            x_idx <= 0;
            y_idx <= 0;
        end else if (fill_LUT && !filling) begin
            ready <= 0;
            filling <= 1;
            x_idx <= 0;
            y_idx <= 0;
        end else if (filling) begin
            if (y_idx < y_res) begin
                if (x_idx < x_res) begin
                    // Perform LUT computation and write
                    pan_we <= 1;
                    tilt_we <= 1;
                    pan_in <= (x_idx * pan_FOV) / x_res - (pan_FOV / 2);
                    tilt_in <= (y_idx * tilt_FOV) / y_res - (tilt_FOV / 2);
                    x_idx <= x_idx + 1;
                end else begin
                    x_idx <= 0;
                    y_idx <= y_idx + 1;
                end
            end else begin
                filling <= 0;
                ready <= 1;
            end
        end else begin
            pan_we <= 0;
            tilt_we <= 0;
        end
    end
endmodule

