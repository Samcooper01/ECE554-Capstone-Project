module ROM_SPART_TB();
    logic CLK, D5M_PIXLCLK;
    logic RST_N;

    logic [9:0]     SW;
    logic [3:0]     KEY;
    logic [11:0]    D5M_D;
    logic           D5M_FVAL;
    logic           D5M_LVAL;



    initial begin
        $display("BEGIN SIM");
        RST_N = 0;
        CLK = 0;
        D5M_PIXLCLK = 0;
        SW = '0;
        KEY = '0;
        D5M_D = '0;
        D5M_FVAL = 0;
        D5M_LVAL = 0;

        repeat (5) @(posedge CLK);
        RST_N = 1;


    end

    always begin
        #5 CLK = ~CLK;
        #20 D5M_PIXLCLK = ~D5M_PIXLCLK;
    end

endmodule