module color_mean_calibration_tb();
    logic           D5M_PXCLK;
    logic           iRST_N; 
    logic           iEN;            
    logic [11:0]    iDATA;                 
    logic [15:0]    iX_Cont;               
    logic [15:0]    iY_Cont;       
    logic           iFVAL;
    logic           iDATA_VAL;
    logic           iCOLOR_SW;
    logic           iCAL_SW;
    logic           oMEAN_VAL;
    logic [11:0]    oMEAN;

    color_mean_calibration iDUT(
        .D5M_PXCLK(D5M_PXCLK),
        .iRST_N(iRST_N),
        .iEN(iEN),
        .iDATA_VAL(iDATA_VAL),  
        .iDATA(iDATA),
        .iX_Cont(iX_Cont),
        .iY_Cont(iY_Cont),
        .iFVAL(iFVAL),
        .iCOLOR_SW(iCOLOR_SW),
        .iCAL_SW(iCAL_SW),
        .oMEAN_VAL(oMEAN_VAL),
        .oMEAN(oMEAN)
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
    iCOLOR_SW = 0;
    iCAL_SW = 0;
    iDATA_VAL = 0;

    repeat (2) @(posedge D5M_PXCLK);
    iRST_N = 1;

    @(posedge D5M_PXCLK);
    //Reset over

    iCOLOR_SW = 1;  //set calibration to blue
    //iCOLOR_SW = 0;  //set calibration to red

    //iDATA = 12'd47;

    repeat (2000000) begin

        if(iter % 16 == 0) begin
            iDATA = 12'd67;
        end
        else if(iter % 18 == 0)begin
            iDATA = 12'd197;
        end
        else if(iter % 20 == 0) begin
            iDATA = 12'd100;
        end
        else begin
            iDATA = 12'd82;
        end

        if(iter == 250000) begin
            iCAL_SW = 1;
        end
        else if(iter == 1750000) begin
            iCAL_SW = 0;
        end

        if(counter > 327199) begin //iFVAL only high for 307200 cycles
            iFVAL = 0;  //end of frame
            iDATA_VAL = 0;
            iX_Cont = 0;
            iY_Cont = 0;
            counter = 0; //Restart for new frame
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