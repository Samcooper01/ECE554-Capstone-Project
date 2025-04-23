module predictive_tracking # (
    parameter realitve_multiply = 2, // How much to lead the target by. 1 means by 1 predicted difference
    parameter x_bits = 10,
    parameter y_bits = 9
)
(
    input   logic                               clk,
    input   logic                               rst_n,
    input   logic                               is_tracking,
    input   logic unsigned [(x_bits - 1):0]     raw_x,
    input   logic unsigned [(y_bits - 1):0]     raw_y,
    input   logic                               coordinates_valid,
    output  logic unsigned [(x_bits - 1):0]     predict_x,
    output  logic unsigned [(y_bits - 1):0]     predict_y
);

// This is because the weighted sum adds up to 2 cycles of differencing (it is already multiplied by 2)
parameter raw_multiply = realitve_multiply / 2;

// Intermediate Signals
logic unsigned  [(x_bits - 1):0]    raw_x_ff;
logic signed    [(x_bits):0]        x_difference;
logic signed    [(x_bits):0]        x_difference_ff1;
logic signed    [(x_bits):0]        x_difference_ff2;
logic signed    [(x_bits):0]        x_difference_ff3;
logic signed    [(x_bits + 1):0]    x_weighted_difference;
logic signed    [(x_bits + 2):0]    predict_x_signed;
logic unsigned  [(x_bits - 1):0]    predict_x_tracked;
logic unsigned  [(y_bits - 1):0]    raw_y_ff;
logic signed    [(y_bits):0]        y_difference;
logic signed    [(y_bits):0]        y_difference_ff1;
logic signed    [(y_bits):0]        y_difference_ff2;
logic signed    [(y_bits):0]        y_difference_ff3;
logic signed    [(y_bits + 1):0]    y_weighted_difference;
logic signed    [(y_bits + 2):0]    predict_y_signed;
logic unsigned  [(x_bits - 1):0]    predict_y_tracked;


// We need to flip-flop this one because the difference will only be meaningful
// on the second valid coordiante reading
logic                               is_tracking_ff;

// Set the difference for the current cycle
always_comb begin
    if(!is_tracking_ff) begin
        x_difference = 0;
        y_difference = 0;
    end
    else begin
        x_difference = raw_x - raw_x_ff;
        y_difference = raw_y - raw_y_ff;
    end
end

// Set the weighted difference
// 1 of current difference + 1/2 last cycle + 1/4 second to last cycle + 1/4 third to last cycle
assign x_weighted_difference = x_difference + x_difference_ff1 / 2 + x_difference_ff2 / 4 + x_difference_ff3 / 4;
assign y_weighted_difference = y_difference + y_difference_ff1 / 2 + y_difference_ff2 / 4 + y_difference_ff3 / 4;

// Set the output based of the weighted difference
assign predict_x_signed = raw_x + x_weighted_difference * raw_multiply;
assign predict_y_signed = raw_y + y_weighted_difference * raw_multiply;
assign predict_x_tracked = (predict_x_signed >= 0) ? predict_x_signed[(x_bits - 1):0] : 0;
assign predict_y_tracked = (predict_y_signed >= 0) ? predict_y_signed[(y_bits - 1):0] : 0;
assign predict_x = (is_tracking) ? predict_x_tracked : raw_x;
assign predict_y = (is_tracking) ? predict_y_tracked : raw_y;

// Propagate coordinate values on a valid coordinate reading
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        raw_x_ff <= 0;
        x_difference_ff1 <= 0;
        x_difference_ff2 <= 0;
        x_difference_ff3 <= 0;
        raw_y_ff <= 0;
        y_difference_ff1 <= 0;
        y_difference_ff2 <= 0;
        y_difference_ff3 <= 0;
        is_tracking_ff <= 0;
    end
    else if (coordinates_valid) begin
        raw_x_ff <= raw_x;
        x_difference_ff1 <= x_difference;
        x_difference_ff2 <= x_difference_ff1;
        x_difference_ff3 <= x_difference_ff2;
        raw_y_ff <= raw_y;
        y_difference_ff1 <= y_difference;
        y_difference_ff2 <= y_difference_ff1;
        y_difference_ff3 <= y_difference_ff2;
        is_tracking_ff <= is_tracking;
    end

end

endmodule
