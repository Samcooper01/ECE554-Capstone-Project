module Frame_capture(
    input logic CLK,
    input logic D5M_PIXLCLK,
    input logic RST_N,
    input logic [11:0] iDATA,
    input logic iDATA_VAL,
    input logic rxd,
    output logic rdempty,
    output logic txd
);

localparam WORDS_PER_FRAME =    20'd0500; //102,400 words per (640X480) frame
localparam FIFO_WORD_SIZE =     16'd36;
localparam PIXEL_DATA_SIZE =    16'd12;
localparam FIVE_MS_DELAY =      25'd25000000;

localparam br_cfg =                     2'b11; //SETS BAUD TO 38400
localparam RESET =                      4'b0000;
localparam IDLE =                       4'b0001;
localparam TRANSMIT_7_0 =               4'b0011; //36 bits to transmit and we do 8 at a time w UART
localparam TRANSMIT_15_8 =              4'b0100; //need 5 8 bit transfers ceil(36/8) == 5 to get transfer 
localparam TRANSMIT_23_16 =             4'b0101; //full word
localparam TRANSMIT_31_24 =             4'b0110;
localparam TRANSMIT_39_32 =             4'b0111;
localparam PREREAD_7_0  =               4'b1000;
localparam PREREAD_15_8  =              4'b1001;
localparam PREREAD_23_16 =              4'b1010;
localparam PREREAD_31_24  =             4'b1011;
localparam PREREAD_39_32  =             4'b1100;

logic fill_fifo, empty_fifo;
logic [FIFO_WORD_SIZE-1:0] FIFO_word;
logic [2:0] word_index;
logic       word_ready;
logic       wrreq;
logic [19:0] word_counter;

logic rdreq;
logic [FIFO_WORD_SIZE-1:0] FIFO_data;

logic spart_rdy;
logic iocs, iorw, rda, tbr;
logic [1:0] ioaddr;
wire [7:0] databus;
logic [7:0] config_data_low, config_data_high, next_data;
logic [3:0] next_state, state;
logic rst_done;
logic db_select_low, db_select_high, transmit_select;

logic timer_disabled, timer_complete;
logic [24:0] delay_counter;

HalfFrame_FIFO iFIFO(	
                    .wrclk(~D5M_PIXLCLK),
                    .rdclk(~CLK),
                    .data(FIFO_word),
                    .rdreq(rdreq),
                    .wrreq(wrreq),
                    .q(FIFO_data),
                    .rdempty(rdempty)
                );

spart iSpart(
                .clk(CLK), //should be clock 50MHZ for proper values
                .rst(RST_N),
                .iocs(iocs),
                .iorw(iorw),
                .ioaddr(ioaddr),
                .rxd(rxd),
                .txd(txd),
                .rda(rda),
                .tbr(tbr),
                .databus(databus)
            );


assign wrreq = iDATA_VAL & fill_fifo & word_ready;

assign rdreq = empty_fifo & spart_rdy;

// //read mode until we get 640X480 pixels of data
// always_ff @(posedge CLK or negedge RST_N) begin
//     if(!RST_N) begin
//         fill_fifo <= 1;
//     end    
//     else if (usedw == WORDS_PER_FRAME) begin
//         fill_fifo <= 0;
//     end
// end

always_ff @(negedge D5M_PIXLCLK or negedge RST_N) begin
    if(!RST_N) begin
        FIFO_word <= '0;
    end
    else if(iDATA_VAL) begin
        FIFO_word <= {iDATA, FIFO_word[FIFO_WORD_SIZE-1:PIXEL_DATA_SIZE]};
    end
end
//build a word with 3 pixels
always_ff @(posedge D5M_PIXLCLK or negedge RST_N) begin
    if(!RST_N) begin
        word_index <= '0;
        word_ready <= 0;
    end
    else if (word_index == 3'b010) begin
        word_index <= '0;
        word_ready <= 1;
    end
    else if (iDATA_VAL) begin
        word_index <= word_index + 1'b1;
        word_ready <= 0;
    end
end

always_ff @(posedge D5M_PIXLCLK or negedge RST_N) begin
    if(!RST_N) begin
        word_counter <= '0;
        fill_fifo <= 1;
        empty_fifo <= 0;
    end
    else if(word_counter == WORDS_PER_FRAME) begin
        fill_fifo <= 0;
        empty_fifo <= 1;
    end
    else if(word_ready) begin
        word_counter = word_counter + 1;
    end
end

//SPART WRITEBACK

assign databus =    (db_select_low) ? config_data_low : 
                    (db_select_high ? config_data_high :
                    (transmit_select ? next_data : 8'bz));

//SPART SETUP
//DB write
always_ff @(posedge CLK or negedge RST_N) begin
    if(!RST_N) begin
        delay_counter <= '0;
        timer_complete <= 0;
    end
    else if (timer_disabled) begin
        delay_counter <= '0;
        timer_complete <= 0;
    end
    else if (delay_counter == FIVE_MS_DELAY) begin
        timer_complete <= 1;
        delay_counter <= '0;
    end
    else begin
        delay_counter <= delay_counter + 1;
        timer_complete <= 0;
    end
end

always_ff @(posedge CLK or negedge RST_N) begin
    if(!RST_N) begin
        rst_done <= 1'b0;
    end
    else if(state == RESET && ~rst_done) begin
        rst_done <= 1'b1;
    end
    else if(rst_done) begin
        rst_done <= 1'b0;
    end
end
always @ (posedge CLK or negedge RST_N) begin
    if(!RST_N) begin
        state <= RESET;
    end
    else begin
        state <= next_state;
    end
end
always @(*) begin
    next_state = IDLE;
    iocs = 1'b1;
    iorw = 1'b1;
    db_select_low = 1'b0;
    db_select_high = 1'b0;
    transmit_select = 1'b0;
    ioaddr = 2'b00;
    spart_rdy = 1'b0;
    timer_disabled = 1;

    case (state)
        RESET : begin
            if(~rst_done) begin
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
                next_state = RESET;
            end
            else begin
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
        end
        IDLE : begin
            /*
            if(data_ready) begin
                next_state = TRANSMIT;
            end
            */
            if(rdempty) begin
                next_state = IDLE;
            end
            else if (empty_fifo) begin
                next_state = PREREAD_7_0;
            end
        end
        PREREAD_7_0 : begin
            if(timer_complete & tbr) begin
                spart_rdy = 1'b1;
                timer_disabled = 1;
                next_state = TRANSMIT_7_0;
            end
            else begin
                timer_disabled = 0;
                next_state = PREREAD_7_0;
            end
        end
        TRANSMIT_7_0 : begin
            iorw = 1'b0;
            ioaddr = 2'b00;
            next_data = FIFO_data[7:0];
            transmit_select = 1'b1;
            next_state = PREREAD_15_8;
        end
        PREREAD_15_8 : begin
            if(timer_complete & tbr) begin
                timer_disabled = 1;
                next_state = TRANSMIT_15_8;
            end
            else begin
                timer_disabled = 0;
                next_state = PREREAD_15_8;
            end
        end
        TRANSMIT_15_8 : begin
            iorw = 1'b0;
            ioaddr = 2'b00;
            next_data = FIFO_data[15:8];
            transmit_select = 1'b1;
            next_state = PREREAD_23_16;
        end
        PREREAD_23_16 : begin
            if(timer_complete & tbr) begin
                timer_disabled = 1;
                next_state = TRANSMIT_23_16;
            end
            else begin
                timer_disabled = 0;
                next_state = PREREAD_23_16;
            end
        end
        TRANSMIT_23_16 : begin
            iorw = 1'b0;
            ioaddr = 2'b00;
            next_data = FIFO_data[23:16];
            transmit_select = 1'b1;
            next_state = PREREAD_31_24;
        end
        PREREAD_31_24 : begin
            if(timer_complete & tbr) begin
                timer_disabled = 1;
                next_state = TRANSMIT_31_24;
            end
            else begin
                timer_disabled = 0;
                next_state = PREREAD_31_24;
            end
        end
        TRANSMIT_31_24 : begin
            iorw = 1'b0;
            ioaddr = 2'b00;
            next_data = FIFO_data[31:24];
            transmit_select = 1'b1;
            next_state = PREREAD_39_32;
        end
        PREREAD_39_32 : begin
            if(timer_complete & tbr) begin
                timer_disabled = 1;
                next_state = TRANSMIT_39_32;
            end
            else begin
                timer_disabled = 0;
                next_state = PREREAD_39_32;
            end
        end
        TRANSMIT_39_32 : begin
            iorw = 1'b0;
            ioaddr = 2'b00;
            next_data = FIFO_data[35:32];
            transmit_select = 1'b1;
            next_state = IDLE;
        end
    endcase
end



endmodule
