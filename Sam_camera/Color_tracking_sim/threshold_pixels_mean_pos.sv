module threshold_pixels_mean_pos(
    input logic         iCLK,
    input logic         iRST_N,
    input logic         iEN,
    input logic         iFVAL,
    input logic [15:0]  iX_Cont,
    input logic [15:0]  iY_Cont,
    input logic         iOBJ_VAL,
    output logic        oMeas_VAL,
    output logic [15:0] oX_mean,
    output logic [15:0] oY_mean
);


logic [31:0]    X_pos_sum;
logic [31:0]    Y_pos_sum;

logic [31:0]    num_valid_pixels;

logic           start_calc;

assign oX_mean = (start_calc) ? (X_pos_sum / num_valid_pixels) : oX_mean;
assign oY_mean = (start_calc) ? (Y_pos_sum / num_valid_pixels) : oY_mean;

always_ff @(posedge iCLK or negedge iRST_N) begin
    if(!iRST_N) begin
        X_pos_sum <= '0;
        Y_pos_sum <= '0
        num_valid_pixels <= '0;
    end
    else if (iOBJ_VAL) begin
        X_pos_sum <= X_pos_sum + iX_Cont;
        Y_pos_sum <= Y_pos_sum + iY_Cont;
        num_valid_pixels <= num_valid_pixels + 1;
    end
    else if (!iFVAL) begin
        num_valid_pixels <= '0;
    end
end

always_ff @(posedge iFVAL or negedge iFVAL or negedge iRST_N) begin
    if(!iRST_N) begin
        start_calc <= 0;
        oMeas_VAL <= 0;
    end
    else if (!iFVAL) begin  //end of frame N
        start_calc <= 1;
        oMeas_VAL <= 0;
    end
    else if (iFVAL) begin   //start of new frame N + 1
        start_calc <= 0;
        oMeas_VAL <= 1;
    end
end

endmodule