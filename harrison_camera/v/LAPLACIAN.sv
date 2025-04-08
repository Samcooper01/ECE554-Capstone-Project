module LAPLACIAN(iCLK, iRST, iGray, iDVAL, oLap, oDVAL);
    // Inputs
    input iCLK;
    input iRST;
    input [11:0] iGray;
    input iDVAL;
    // Outputs
    output [11:0] oLap;
    output oDVAL;

    // Internal Signals
    logic [11:0] convolution [0:2][0:2];
    logic signed [14:0] G_signed;
    logic [13:0] G_bottom, G_abs;

    assign convolution[2][2] = iGray;
    assign G_bottom = G_signed[13:0];
    assign G_abs = G_signed[14] ? (~G_bottom) + 1 : G_bottom;
    assign oLap = G_abs[11:0];
    assign oDVAL = iDVAL;

    Line_Buffer3 u1 (
        // Inputs
        .clken(iDVAL),
        .clock(iCLK),
        .shiftin(convolution[2][2]),
        // Outputs
        .taps(convolution[1][2])
    );

    Line_Buffer3 u2 (
        // Inputs
        .clken(iDVAL),
        .clock(iCLK),
        .shiftin(convolution[1][2]),
        // Outputs
        .taps(convolution[0][2])
    );

    always_ff @(posedge iCLK, negedge iRST) begin
        if (!iRST) begin
            convolution[0][1]	<=	0;
            convolution[0][0]	<=	0;
            convolution[1][1]	<=	0;
            convolution[1][0]	<=	0;
            convolution[2][1]	<=	0;
            convolution[2][0]	<=	0;
        end
        else begin
            convolution[0][1]	<=	convolution[0][2];
            convolution[0][0]	<=	convolution[0][1];
            convolution[1][1]	<=	convolution[1][2];
            convolution[1][0]	<=	convolution[1][1];
            convolution[2][1]	<=	convolution[2][2];
            convolution[2][0]	<=	convolution[2][1];
        end
    end

    always_comb begin
        G_signed = (convolution[0][1] + convolution[1][0] + convolution[1][2] + convolution[2][1])
               - 4 * convolution[1][1];
    end

endmodule