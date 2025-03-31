`timescale 1 ps / 1 ps
module ROM_SPART_TB();
    logic CLK, D5M_PIXLCLK;
    logic RST_N;

    logic [9:0]     SW;
    logic [3:0]     KEY;
    logic [11:0]    iDATA;
    logic           iDATA_VAL, rdempty, rxd, txd;
    integer i;
    logic [35:0] GPIO_0;

    assign GPIO_0[3] = txd;
    assign rxd = GPIO_0[5];
    Frame_capture iDUT(   
                .CLK(CLK), 
                .D5M_PIXLCLK(D5M_PIXLCLK),
                .RST_N(RST_N),
                .iDATA(iDATA),
                .iDATA_VAL(iDATA_VAL),
                .rdempty(rdempty),
                .rxd(rxd),
                .txd(txd)
            );

    initial begin
        $display("BEGIN SIM");
        RST_N = 0;
        CLK = 0;
        D5M_PIXLCLK = 0;
        iDATA = 0;
        iDATA_VAL = 0;
        i = 0;

        repeat (5) @(posedge CLK);
        RST_N = 1;

        //307206
        repeat (15) begin 
            @(posedge D5M_PIXLCLK);
            iDATA_VAL = 1;
            iDATA = i;
            i = i + 1;
        end
        iDATA_VAL = 0;
        @(posedge rdempty);
        #500;
        $stop();
    end

    always begin
        #5 CLK = ~CLK;
    end

    always begin    
        #20 D5M_PIXLCLK = ~D5M_PIXLCLK;
    end

endmodule