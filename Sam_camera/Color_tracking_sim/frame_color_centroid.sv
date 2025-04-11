module frame_color_centroid(
    input   logic           iCLK,
    input   logic           iRST_N,
    input   logic           iEN,                    //Master enable for module
    input   logic [15:0]    iX_Cont,                //X (column index) position of pixel
    input   logic [15:0]    iY_Cont,                //Y (row index) posiiton of pixel
    input   logic [11:0]    iDATA,
    input   logic           iDATA_VAL,
    input   logic           iFVAL,
    input   logic [31:0]    iFrame_Cont,
    output  logic           oCORD_VAL,
    output  logic [15:0]    oX_centroid,            //Complete at end of each frame
    output  logic [15:0]    oY_centroid             //Complete at end of each frame
);

// Xcentroid = ( Sumation(0->(640*480)[(Xi*Wi)] / Sumation(0->(640*480)[Wi] )
// Ycentroid = ( Sumation(0->(640*480)[(Yi*Wi)] / Sumation(0->(640*480)[Wi] )

// i goes from pixel 0,0 to pixel 639,479 (307,200 positions)
// Wi represents the weight of each pixel at (Xi,Yi)

//at the end of a frame we calculate the centroid as (X,Y)

logic [47:0] X_weighted_pixel_pos_sum;
logic [47:0] X_weighted_pixel_sum;
logic [23:0] X_Xi_times_Wi;

logic [47:0] Y_weighted_pixel_pos_sum;
logic [47:0] Y_weighted_pixel_sum;
logic [23:0] Y_Yi_times_Wi;

logic       iDATA_VAL_ff;
logic       iFVAL_ff;

logic       start_division;
logic       division_ready;

assign oX_centroid = start_division ? (X_weighted_pixel_pos_sum / X_weighted_pixel_sum) : oX_centroid;
assign oY_centroid = start_division ? (Y_weighted_pixel_pos_sum / Y_weighted_pixel_sum) : oY_centroid;

always_ff @(posedge iClk or negedge iRST_N) begin
    if(!iRST_N) begin
        X_Xi_times_Wi               <= '0;
        Y_Yi_times_Wi               <= '0;

        X_weighted_pixel_sum        <= '0;
        Y_weighted_pixel_sum        <= '0;

        iDATA_VAL_ff                <=  0;
        iFVAL_ff                    <=  0;
    end
    else if(iEN & iDATA_VAL) begin
        X_Xi_times_Wi <= iX_Cont * iDATA;
        Y_Yi_times_Wi <= iY_Cont * iDATA;

        X_weighted_pixel_sum <= X_weighted_pixel_sum + iX_Cont;
        Y_weighted_pixel_sum <= Y_weighted_pixel_sum + iY_Cont;

        iDATA_VAL_ff <= iDATA_VAL;
        iFVAL_ff     <= iFVAL;
    end

end

//pipeline the summation
always_ff @(posedge iClk or negedge iRST_N) begin
    if(!iRST_N) begin
        X_weighted_pixel_pos_sum    <= '0;
        Y_weighted_pixel_pos_sum    <= '0;
    end
    else if(iEN & iDATA_VAL_ff) begin
        X_weighted_pixel_pos_sum <= X_weighted_pixel_pos_sum + X_Xi_times_Wi;
        Y_weighted_pixel_pos_sum <= Y_weighted_pixel_pos_sum + Y_Yi_times_Wi;
    end
end

always_ff @(negedge iFVAL_ff or posedge iFVAL_ff or negedge iRST_N) begin
    if(!iRST_N) begin
        start_division  <= 0;
        oCORD_VAL       <= 0;
    end
    else if (!iFVAL_ff) begin                       //start of vertical banking and end of frame N
        //at the end of a frame we have the two neccessary 
        //summation we just need to do a 48 bit / 48 bit operation which takes
        //many clock cycles so we give the operation the full time of veritcal banking
        start_division  <= 1;
        oCORD_VAL       <= 0;
    end
    else if (iFVAL_ff & (iFrame_Cont != 32'd0)) begin //end of vertical banking and start of frame N + 1
        start_division  <= 0;
        oCORD_VAL       <= 1;
    end
end

endmodule
