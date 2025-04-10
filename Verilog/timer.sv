module timer 
# (
    parameter clock_frequency_mhz   = 50,
    parameter time_milliseconds     = 1000
) (
    input clk,
    input rst_n,
    input stop,
    input start,
    output done
);

parameter done_count = (clock_frequency_mhz * time_milliseconds * 1000) - 1;

// Intermediate Signals
logic [$clog2(done_count)-1:0] counter, counter_next;

// State Machine Signals
enum logic [1:0] {IDLE, RUN} state, state_next;

// State Machine Sequential Logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state = IDLE;
        counter = 0;
    end
    else begin
        state = state_next;
        counter = counter_next;
    end
end

// State Machine implementation
assign done = (counter == done_count);
always_comb begin
    state_next = state;
    counter_next = counter;
    case(state)
        IDLE: begin
            if (start) begin
                state_next = RUN;
            end
        end
        RUN: begin
            counter_next = counter + 1;
            if (stop) begin
                counter_next = 0;
                state_next = IDLE;
            end
            else if (done) begin
                counter_next = 0;
                state_next = IDLE;
            end
        end
    endcase
end

endmodule