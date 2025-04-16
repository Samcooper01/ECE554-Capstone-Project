module test_all_cords(
    input                       iCLK,
    input                       iRST,
    input	        [31:0]	    Frame_Cont,
    input                       iFVAL,
    output logic    [9:0]       oX_Cent,
    output logic    [8:0]       oY_Cent,
    output logic                oCent_Val 
);

localparam LAST_COL_INDEX   =       10'd639;
localparam LAST_ROW_INDEX   =       9'd479;
localparam REST_FRAMES      =       32'd20;

logic iFVAL_ff;
logic falling_iFVAL;
logic start;

assign start = (Frame_Cont > REST_FRAMES);

always_ff @(posedge iCLK)
    iFVAL_ff <= iFVAL;

//X Y Counter 
//  inc once every new frame then reset col at end of row and reset row at 479
always_ff @(posedge iCLK or negedge iRST) begin
    if(!iRST) begin
        oX_Cent     <= '0;
        oY_Cent     <= '0;
        oCent_Val   <=  0;
    end
    else if (start & falling_iFVAL) begin
        oCent_Val <= 1;
        if(oX_Cent >= LAST_COL_INDEX) begin
            oX_Cent <= '0;
            if(oY_Cent >= LAST_ROW_INDEX) begin
                oY_Cent <= '0;
            end
            else begin
                oY_Cent <= oY_Cent + 16;
            end
        end
        else begin
            oX_Cent <= oX_Cent + 16;
        end
    end
    else begin
        oCent_Val <= 0;
    end
end

//negedge iFVAL
always_ff @(posedge iCLK or negedge iRST) begin
    if(!iRST) begin
            falling_iFVAL   <= 0;
    end 
    else if(start) begin
        if({iFVAL_ff,iFVAL} == 2'b10) begin //falling edge
            falling_iFVAL <= 1;     
        end         //falling edge signal only high for one clock after falling edge
        else begin
            falling_iFVAL <= 0;
        end
    end
end

endmodule