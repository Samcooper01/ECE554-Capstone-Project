module STORE_FRAME_EVEN(iCLK, iRST, iDVAL, iDATA, iFrame_Cont, iX_Cont, iY_Cont, oObjectDetected, oRed, oGreen, oBlue, oDVAL);
    // Input / Outputs
    input iCLK;
    input iRST; 
    input iDVAL;
    input [11:0] iDATA;
    input [31:0] iFrame_Cont;                  // Current frame to write to 
    input [9:0] iX_Cont;
    input [8:0] iY_Cont;               
    output oObjectDetected;             // Object detected flag
    output [11:0] oRed;                 // Pixel value at the location (detected or not)
    output [11:0] oGreen;               // Pixel value at the location (detected or not) 
    output [11:0] oBlue;                // Pixel value at the location (detected or not)
    output oDVAL;                       // Data valid signal

    // When an object is detected, turn it red. 
    assign oRed = oObjectDetected ? 12'hFFF : iDATA;
    assign oGreen = oObjectDetected ? 12'hFFF : iDATA;
    assign oBlue = oObjectDetected ? 12'hFFF : iDATA;

    assign oDVAL = iDVAL;

    // Internal signals
    logic [11:0] oDATA, iDATA_ff;
    logic empty;
    logic wrreq, rdreq, rdreq_ff;
    logic [11:0] threshold;
    logic [11:0] counter;
    logic oObjectDetected_thresh;

    assign threshold = 12'd700;

    assign oObjectDetected = ((counter >= 30) & oObjectDetected_thresh) ? oObjectDetected_thresh : 1'b0;

    always_ff @(posedge iCLK) begin
        rdreq_ff <= rdreq;
        iDATA_ff <= iDATA;
    end

    // Buffer the entire frame, every 4 pixels
    FIFO_FRAME_RED_SMALL frame_buffer_even (
                    .aclr(~iRST),
                    .clock(iCLK),
                    .data(iDATA),
                    .rdreq(rdreq),
                    .wrreq(wrreq),
                    .empty(empty),
                    .q(oDATA)
    );
                   //even frame    valid pixel     every other red pixel
    assign wrreq = ~iFrame_Cont[0] & iDVAL & ({((iX_Cont - 10'd1) % 4 == 0),iY_Cont[0]} == 2'b10);

                    //odd frame
    assign rdreq = iFrame_Cont[0] & iDVAL & ({((iX_Cont - 10'd1) % 4 == 0),iY_Cont[0]} == 2'b10);

    always_ff @(posedge iCLK or negedge iRST) begin
        if(~iRST) 
            counter <= '0;
        else if(~iFrame_Cont[0]) begin
            counter <= '0; 
        end
        else if(oObjectDetected_thresh) 
            counter <= counter + 1'b1;
    end


    //  abs(iDATA - oDATA) > threshold ? object detected : no object detected
    // if oDATA > iDATA then oDATA - iDATA = oDVAL
    // if oDATA < iDATA then iDATA - oDATA = oDVAL
    assign oObjectDetected_thresh = (rdreq_ff) ? ((oDATA > iDATA_ff) ? (oDATA - iDATA_ff) > threshold : (iDATA_ff - oDATA) > threshold)  
                            : 1'b0;
    

    // Object detection logic

endmodule