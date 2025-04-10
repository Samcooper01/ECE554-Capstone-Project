module STORE_FRAME(iCLK, iRST, iDVAL, iDATA, iFrame_Cont, iX_Cont, iY_Cont, oObjectDetected, oRed, oGreen, oBlue, oDVAL);
    // Input / Outputs
    input iCLK;
    input iRST; 
    input iDVAL;
    input [11:0] iDATA;
    input iFrame_Cont;                  // Current frame to write to 
    input [9:0] iX_Cont;
    input [8:0] iY_Cont;               
    output oObjectDetected;             // Object detected flag
    output [11:0] oRed;                 // Pixel value at the location (detected or not)
    output [11:0] oGreen;               // Pixel value at the location (detected or not) 
    output [11:0] oBlue;                // Pixel value at the location (detected or not)
    output oDVAL;                       // Data valid signal

    // When an object is detected, turn it red. 
    assign oRed = oObjectDetected ? 12'hFFF : iDATA;
    assign oGreen = oObjectDetected ? 12'h000 : iDATA;
    assign oBlue = oObjectDetected ? 12'h000 : iDATA;
    assign oDVAL = iDVAL;

    // Internal signals
    logic [11:0] oDATA;
    logic empty;

    // Buffer the entire frame, every 4 pixels
    FIFO frame_buffer (
        .aclr(iRST),
        .clock(iCLK),
        .data(iDATA),
        .rdreq(iFrame_Cont & iDVAL),
        .wrreq(~iFrame_Cont & iDVAL),
        .empty(empty),
        .q(oDATA)
    );

    //  abs(iDATA - oDATA) > threshold ? object detected : no object detected

    // Object detection logic


endmodule