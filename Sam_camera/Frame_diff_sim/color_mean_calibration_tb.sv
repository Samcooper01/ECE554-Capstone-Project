`timescale 1 ps / 1 ps
module color_mean_calibration_tb();
    logic           D5M_PXCLK;
    logic           iRST_N; 
    logic           iEN;            
    logic [11:0]    iDATA;                 
    logic [15:0]    iX_Cont;               
    logic [15:0]    iY_Cont;    
    logic [31:0]    iFrame_Cont;
    logic           iFVAL;
    logic           iDATA_VAL;
    logic           oObjectDetected;
    logic [11:0]    oRed;
    logic [11:0]    oGreen;
    logic [11:0]    oBlue;
    logic [9:0]     oX_Cent;
    logic [8:0]     oY_Cent;
    logic           oCent_Val;

    STORE_FRAME iDUT(
        .iCLK(D5M_PXCLK),
        .iRST(iRST_N), 
        .iDVAL(iDATA_VAL),
        .iDATA(iDATA),
        .iFrame_Cont(iFrame_Cont),                  // Current frame to write to 
        .iX_Cont(iX_Cont),
        .iY_Cont(iY_Cont),               
        .oObjectDetected(oObjectDetected),             // Object detected flag
        .oRed(oRed),                 // Pixel value at the location (detected or not)
        .oGreen(oGreen),               // Pixel value at the location (detected or not) 
        .oBlue(oBlue),                // Pixel value at the location (detected or not)
        .oDVAL()                       // Data valid signal
    );

    MEAN_COORDS iCORDS(
        .iCLK(D5M_PXCLK),
        .iRST(iRST_N),
        .iFVAL(iFVAL),
        .iX_Cont(iX_Cont),
        .iY_Cont(iY_Cont),
        .iObjectDetected(oObjectDetected),
        .oX_Cent(oX_Cent),
        .oY_Cent(oY_Cent),
        .oCent_Val(oCent_Val)
    );

integer counter = 0;
integer iter    = 0;

initial begin
    //Init signals
    D5M_PXCLK = 0;
    iRST_N = 0;
    iEN = 1; //start enabled
    iDATA = '0;
    iX_Cont = '0;
    iY_Cont = '0;
    iFVAL = 0;
    iDATA_VAL = 0;
    iFrame_Cont  = '0;

    repeat (2) @(posedge D5M_PXCLK);
    iRST_N = 1;

    @(posedge D5M_PXCLK);
    //Reset over

    //iCOLOR_SW = 0;  //set calibration to red

    //iDATA = 12'd47;

    repeat (2000000) begin

        if(iFrame_Cont == 0)
            iDATA = counter;
        else if(iFrame_Cont == 1)
            iDATA = 0;
        else if(iFrame_Cont == 2)
            iDATA = 160;
        else if(iFrame_Cont == 3)
            iDATA = 90;


        if(counter > 327199) begin //iFVAL only high for 307200 cycles
            iFVAL = 0;  //end of frame
            iDATA_VAL = 0;
            iX_Cont = 0;
            iY_Cont = 0;
            counter = 0; //Restart for new frame
            iFrame_Cont = iFrame_Cont + 1;
        end
        else if(counter > 20000) begin
            if(iX_Cont == 16'd639) begin
                iX_Cont = 0;
                iY_Cont = iY_Cont + 1;
            end
            else begin
                iX_Cont = iX_Cont + 1;
            end
        end
        else if(counter == 19000) begin
            iFVAL = 1; //frame start
        end
        else if(counter == 20000) begin
            iDATA_VAL = 1;
        end

        @(posedge D5M_PXCLK);
        counter = counter + 1;
        iter = iter + 1;
    end

    //End test
    repeat (100) @(posedge D5M_PXCLK);
    $stop();

end

always begin
    #5 D5M_PXCLK <= ~D5M_PXCLK;
end
endmodule