module GRAYSCALE(iCLK, iRST, iDVAL, iDATA, iX_Cont, iY_Cont, oGray, oDVAL);
    input iCLK;
    input iRST;
    input iDVAL;
    input [11:0] iDATA;
    input [10:0] iX_Cont;
    input [10:0] iY_Cont;
    output [11:0] oGray;
    output oDVAL;

    // Internal signals
    logic [11:0] mDATA, mDATA_ff, iDATA_ff;

    // Shift register with enough capacity for a full row from the camera
    Line_Buffer2 u0 (
	    //Inputs
        .clken(iDVAL),
        .clock(iCLK),
        .shiftin(iDATA),
        .taps(mDATA)
    );

    always_ff @(posedge iCLK, negedge iRST) begin
        if (!iRST) begin
            mDATA_ff <= '0;
            iDATA_ff <= '0;
            oDVAL <= '0;
            oGray <= '0;
        end
        else begin
            mDATA_ff <= mDATA;
            iDATA_ff <= iDATA_ff;

            oDVAL <= {iY_Cont[0]|iX_Cont[0]} ? 1'b0 : iDVAL;
            oGray <= (mDATA + mDATA_ff + iDATA + iDATA_ff) / 4;
        end
    end

    


endmodule