module color_mean_calibration(
    input   logic           D5M_PXCLK,
    input   logic           iRST_N, 
    input   logic           iEN,
    input   logic           iDATA_VAL,              //Valid pixel
    input   logic [11:0]    iDATA,                  //Bayer color pixel
    input   logic [15:0]    iX_Cont,                //X (column index) position of pixel
    input   logic [15:0]    iY_Cont,                //Y (row index) posiiton of pixel
    input   logic           iFVAL,
    input   logic           iCOLOR_SW,
    input   logic           iCAL_SW,
    output  logic           oMEAN_VAL,
    output  logic [11:0]    oMEAN
);

logic obj_color; //1 if blue 0 if red
logic cal_en;
logic start_calc;
logic frame_captured;
logic frame_begin;
logic [2:0] state, next_state;
logic iFVAL_ff;

always @(posedge D5M_PXCLK) begin
    iFVAL_ff <= iFVAL;
end

localparam NUM_BLUE_OR_RED_PIXELS_PER_FRAME = 32'd76800;
localparam LAST_ROW_INDEX = 16'd479;
localparam LAST_COL_INDEX = 16'd639;

localparam IDLE         = 3'b000;
localparam FRAME_BEGIN  = 3'b001;
localparam START_CAL    = 3'b010;
localparam CALC_DONE    = 3'b011;

//MAX COLOR SUM: 314,496,000 so 32 bits needed
logic [31:0] color_sum;

assign oMEAN = (start_calc) ? (color_sum / NUM_BLUE_OR_RED_PIXELS_PER_FRAME) : oMEAN;

//First (once)
//  starts on posedge of iCAL_SW
//  IMPORTANT: we assume that the user keeps the iCAL_SW high for multiple frames
//  ends on negedge iCAL_SW
always_ff @(posedge iCAL_SW or negedge iRST_N) begin
    if(!iRST_N) begin
        obj_color   <= 0;
        cal_en      <= 0;
    end
    else if(iCAL_SW & iEN) begin //start calibration
        obj_color   <= iCOLOR_SW;
        cal_en      <= 1;
    end
end

//As many pixels as in a frame 
//   starts when iCAL_SW is enabled and on rising edge of iFVAL
//   ends at end of frame (76800 valid pixels)
always_ff @(posedge D5M_PXCLK or negedge iRST_N) begin
    if(!iRST_N) begin
        color_sum       <= 0;
        frame_captured  <= 0;
    end
    else if (cal_en & iDATA_VAL & frame_begin)  begin
        if(obj_color) begin //BLUE
		    if({iY_Cont[0],iX_Cont[0]}==2'b10)     	//even col odd row
		    begin
                color_sum <= color_sum + iDATA;
            end
        end
        else begin          //RED
		    if({iY_Cont[0],iX_Cont[0]}==2'b01)     	//odd col even row
		    begin
                color_sum <= color_sum + iDATA;
            end
        end
        //check if stop calculating
        if((iY_Cont == LAST_ROW_INDEX) && (iX_Cont == LAST_COL_INDEX-1) && frame_begin) begin
            frame_captured <= 1;
        end
    end
end

always_ff @(posedge D5M_PXCLK or negedge iRST_N) begin
    if(!iRST_N) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
    start_calc  = 0;
    frame_begin = 0;
    oMEAN_VAL   = 0;

    case(state) 
        IDLE : begin
            if(cal_en && ({iFVAL_ff,iFVAL} == 2'b01)) begin
                frame_begin = 1;
                next_state = FRAME_BEGIN;
            end
            else begin
                next_state = IDLE;
            end
        end
        FRAME_BEGIN : begin
            frame_begin = 1;
            if(frame_captured) begin
                next_state = START_CAL;
            end
            else begin
                next_state = FRAME_BEGIN;
            end
        end
        START_CAL : begin
            start_calc = 1;
            if({iFVAL_ff,iFVAL} == 2'b01) begin
                next_state = CALC_DONE;
            end
            else begin
                next_state = START_CAL;
            end
        end
        CALC_DONE : begin
            oMEAN_VAL = 1;
            next_state = CALC_DONE;
        end
    endcase
end


endmodule
