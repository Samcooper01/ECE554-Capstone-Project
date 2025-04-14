module MEAN_COORDS(
    input logic         iCLK,
    input logic         iRST,
    input logic         iFVAL,
    input logic [9:0]   iX_Cont,
    input logic [8:0]   iY_Cont,
    input logic         iObjectDetected,
    output logic [9:0]   oX_Cent,
    output logic [8:0]   oY_Cent,
    output logic         oCent_Val
);

    localparam IDLE         = 3'b000;
    localparam FRAME_BEGIN  = 3'b001;
    localparam CALC         = 3'b010;

    logic [31:0] X_cord_sum, Y_cord_sum;
    logic [15:0] counter;
    logic [3:0] state, next_state;
    logic       iFVAL_ff;
    logic       start_calc;
    logic       clear_counter;
    
    always_ff @(posedge iCLK)
        iFVAL_ff <= iFVAL;

    assign oX_Cent = (start_calc) ? (X_cord_sum / counter) : oX_Cent;
    assign oY_Cent = (start_calc) ? (Y_cord_sum / counter) : oY_Cent;


    always_ff @(posedge iCLK or negedge iRST) begin
        if(!iRST) begin
            X_cord_sum  <=   '0;
            Y_cord_sum  <=   '0;
            counter     <=   '0;
        end
        else if(clear_counter) begin
            X_cord_sum  <=  '0;
            Y_cord_sum  <=  '0;
            counter     <=  '0;
        end
        else if (iObjectDetected) begin
            X_cord_sum <= iX_Cont + X_cord_sum;
            Y_cord_sum <= iY_Cont + Y_cord_sum;
            counter <= counter + 1'b1;
        end
    end
    

    always_ff @(posedge iCLK or negedge iRST) begin
        if(!iRST) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin 
        start_calc = 0;
        clear_counter = '0;
        oCent_Val = 0;

        case (state) 
            IDLE : begin
                if({iFVAL,iFVAL_ff} == 2'b10) begin //start of a frame
                    clear_counter = 1;
                    next_state = FRAME_BEGIN; 
                end
                else begin
                    next_state = IDLE;
                end
            end
            FRAME_BEGIN : begin
                if ({iFVAL,iFVAL_ff} == 2'b01) begin //end of a frame
                    if(counter == 16'd0) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = CALC;
                    end
                end
                else begin
                    next_state = FRAME_BEGIN;
                end
            end
            CALC : begin
                start_calc = 1;
                if({iFVAL,iFVAL_ff} == 2'b10) begin //between end of frame and start of next frame
                    oCent_Val = 1;
                    next_state = IDLE;
                end
                else begin
                    next_state = CALC;
                end
            end
        endcase   
    end

endmodule