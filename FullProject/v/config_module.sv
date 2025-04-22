module config_module (
    input   logic iCLK,
    input   logic iRST,
    //UART
    output  logic txd,
    input   logic rxd,
    //Parameters to config (just add one here)
    output logic [11:0] min_objects_detected,
    output logic [11:0] min_object_threshold,
    output logic [15:0] default_exposure,
    output logic [15:0] green_1_gain,
    output logic [15:0] green_2_gain,
    output logic [15:0] blue_gain,
    output logic [15:0] red_gain,
    //Option to send a signal that can be used as reset once param write complete
    output              oReset_n
);

localparam MAX_DATA_WIDTH   = 128;
localparam br_cfg           = 2'b11;

localparam RESET0 =     3'b000;
localparam RESET1 =     3'b001;
localparam IDLE =       3'b010;
localparam NUM_WRITES = 3'b011;
localparam PARAM_DATA = 3'b100;
localparam WRITE_DATA = 3'b101;
localparam PRE_RESET =  3'b110;
localparam RESET_OPT =  3'b111;

// PARAMETER INDEX TABLE (DO NOT MODIFY) (ONLY ADD TO THIS)
// INDEX    NAME
// 1        min_objects_detected
// 2        min_object_threshold
// 3        default_exposure
// 4        green_1_gain
// 5        green_2_gain
// 6        blue_gain
// 7        red_gain

//DEFAULT VALUES
localparam MIN_OBJECTS_DETECTED_PARAM = 12'd30;
localparam MIN_OBJECT_THRESHOLD_PARAM = 12'd700;
localparam DEFAULT_EXPOSURE_PARAM     = 16'h0400;
localparam GREEN_1_GAIN               = 16'h0013;
localparam GREEN_2_GAIN               = 16'h0013;
localparam BLUE_GAIN                  = 16'h007F;
localparam RED_GAIN                   = 16'h007F;

//Internal signals
//Uart gives these values
logic [5:0] new_val_index_en;
logic [MAX_DATA_WIDTH-1:0] new_data;
logic [3:0] num_of_data_transfer;
logic       reset_on_write; 

//state signals
logic [3:0]     state, next_state, state_ff;
logic [7:0]     recieved_data;
logic           rx_data_rdy;
logic           new_data_rdy;

//spart signals
logic [7:0] config_data_low, config_data_high;
logic db_select_low, db_select_high, rst_done, transmit_select;
logic iorw, rda, tbr;
logic [1:0] ioaddr;
wire [7:0] databus;

assign databus =    (db_select_low) ? config_data_low : 
                    (db_select_high ? config_data_high :
                    (transmit_select ? recieved_data : 8'bz));

assign oReset_n = ~(state == RESET_OPT);

spart spart0(   .clk(iCLK),
                .rst(iRST),
                .iocs(1'b1),
                .iorw(iorw),
                .rda(rda),
                .tbr(tbr),
                .ioaddr(ioaddr),
                .databus(databus),
                .txd(txd),
                .rxd(rxd)
            );

//Configurable Parameter Registers
always_ff @( negedge iCLK or negedge iRST ) begin
    if(!iRST) 
        min_objects_detected <= MIN_OBJECTS_DETECTED_PARAM;
    else if (new_val_index_en == 6'd1 && new_data_rdy) //there shouldnt be a 0 index (new_val_index_en is 0 by default)
        min_objects_detected <= new_data[11:0];
end

always_ff @( posedge iCLK or negedge iRST ) begin
    if(!iRST) 
        min_object_threshold <= MIN_OBJECT_THRESHOLD_PARAM;
    else if (new_val_index_en == 6'd2 && new_data_rdy) 
        min_object_threshold <= new_data[11:0];
end

always_ff @( posedge iCLK or negedge iRST ) begin
    if(!iRST) 
        default_exposure <= DEFAULT_EXPOSURE_PARAM;
    else if (new_val_index_en == 6'd3 && new_data_rdy) begin
        default_exposure <= new_data[15:0];
    end
end

always_ff @( posedge iCLK or negedge iRST ) begin
    if(!iRST) 
        green_1_gain <= GREEN_1_GAIN;
    else if (new_val_index_en == 6'd4 && new_data_rdy) 
        green_1_gain <= new_data[15:0];
end

always_ff @( posedge iCLK or negedge iRST ) begin
    if(!iRST) 
        green_2_gain <= GREEN_2_GAIN;
    else if (new_val_index_en == 6'd5 && new_data_rdy) 
        green_2_gain <= new_data[15:0];
end

always_ff @( posedge iCLK or negedge iRST ) begin
    if(!iRST) 
        blue_gain <= BLUE_GAIN;
    else if (new_val_index_en == 6'd6 && new_data_rdy) 
        blue_gain <= new_data[15:0];
end

always_ff @( posedge iCLK or negedge iRST ) begin
    if(!iRST) 
        red_gain <= RED_GAIN;
    else if (new_val_index_en == 6'd7 && new_data_rdy) 
        red_gain <= new_data[15:0];
end

//New data logic
always_ff @(posedge iCLK or negedge iRST) begin
    if(!iRST) begin
        new_data <= '0;
    end
    else if(rx_data_rdy) begin
        new_data <= {new_data[MAX_DATA_WIDTH-9:0],databus};
    end
end

//State Machine
always_ff @(posedge iCLK or negedge iRST) begin
    if(!iRST)
        state <= RESET0;
    else 
        state <= next_state;
end

always @(*) begin : state_machine
    transmit_select = 0;
    db_select_low = 0;
    db_select_high = 0;
    ioaddr = 2'b00;
    iorw = 1;
    rx_data_rdy = 0;
    new_data_rdy = 0;

    case (state)
        RESET0 : begin
            db_select_low = 1'b1;
            ioaddr = 2'b10;
            if(br_cfg == 2'b00) begin
                config_data_low = 8'hB1;
            end
            else if(br_cfg == 2'b01) begin
                config_data_low = 8'h58;
            end
            else if(br_cfg == 2'b10) begin
                config_data_low = 8'h2C;
            end
            else if(br_cfg == 2'b11) begin
                config_data_low = 8'h16;
            end
            iorw = 1'b0;
            next_state = RESET1;
        end
        RESET1 : begin
                ioaddr = 2'b11;
                db_select_high = 1'b1;
                if(br_cfg == 2'b00) begin
                    config_data_high = 8'h28;
                end
                else if(br_cfg == 2'b01) begin
                    config_data_high = 8'h14;
                end
                else if(br_cfg == 2'b10) begin
                    config_data_high = 8'h0A;
                end
                else if(br_cfg == 2'b11) begin
                    config_data_high = 8'h05;
                end
                iorw = 1'b0;
                next_state = IDLE;
        end
        IDLE : begin
            if(rda) begin
                //First transaction is ready here
                if(databus[7]) begin
                    reset_on_write = databus[6];
                    new_val_index_en = databus[5:0];
                    next_state = NUM_WRITES;
                end
                else begin
                    next_state = IDLE;
                end
            end
            else begin
                reset_on_write = 0;
                next_state = IDLE;
            end
        end
        NUM_WRITES : begin
            if(rda) begin
                num_of_data_transfer = databus[3:0];
                next_state = PARAM_DATA;
            end
            else begin
                next_state = NUM_WRITES;
            end
        end
        PARAM_DATA : begin
            if ((num_of_data_transfer == 4'b0)) begin
                next_state = WRITE_DATA;
            end
            else if (rda) begin
                rx_data_rdy = 1;
                num_of_data_transfer = num_of_data_transfer - 1'b1;
                next_state = PARAM_DATA;
            end
            else begin
                next_state = PARAM_DATA;
            end
        end
        WRITE_DATA : begin
            new_data_rdy = 1;
            if (reset_on_write) 
                next_state = PRE_RESET;
            else
                next_state = IDLE;
        end
        PRE_RESET : begin
            next_state = RESET_OPT;
        end
        RESET_OPT : begin
            next_state = IDLE;
        end
    endcase
end

endmodule