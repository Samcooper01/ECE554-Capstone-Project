module EDGE_DETECT(iCLK, iRST, iGray, iDVAL, oEdge);
    input iCLK;
    input iRST;
    input [11:0] iGray;
    input iDVAL;
    output [11:0] oEdge;

    // Internal signals
    logic [11:0] convolution [0:2][0:2];
    logic signed [14:0] Gx_signed, Gy_signed;
    logic [13:0] Gx_bottom, Gy_bottom;
    logic [13:0] Gx_abs, Gy_abs;

    // First pixel input comes from the top right
    assign convolution[2][2] = iGray;

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
        Gx_signed   = convolution[2][0] + 2 * convolution[2][1] + convolution[2][2]
			        - convolution[0][0] - 2 * convolution[0][1] - convolution[0][2];
        Gy_signed   = convolution[0][2] + 2 * convolution[1][2] + convolution[2][2]
			        - convolution[0][0] - 2 * convolution[1][0] - convolution[2][0];

        Gx_bottom   = Gx_signed[13:0];
        Gy_bottom   = Gy_signed[13:0];

        Gx_abs      = Gx_signed[14] ? (~Gx_bottom) + 1 : Gx_bottom;
        Gy_abs      = Gy_signed[14] ? (~Gy_bottom) + 1 : Gy_bottom;

        oEdge       = Gx_abs + Gy_abs;
    end

endmodule