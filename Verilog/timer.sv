module timer 
# (
    parameter clock_frequency_mhz   = 50;
    parameter time_milliseconds     = 1000;
) (
    input clk,
    input rst_n,
    input stop,
    input start,
    output done
);

parameter done_count = (clock_frequency_mhz * time_milliseconds * 1000) - 1

// Intermediate Signals
logic [$clog2(done_count)-1:0] counter, counter_next;

// State Machine Signals
logic [2:0] {IDLE, RUN} state, state_next;

// State Machine Sequential Logic
always_ff @(posedge clk or negedge rst_n) begin
    state = state_next;
    counter = counter_next;
end

// State Machine implementation
always_comb begin
    state_next = state;
    done = 0;
    counter_next = 0;
    case(state)
        IDLE: begin
            counter_next = 0;
            if (start) begin
                state_next = RUN;
            end
        end
        RUN: begin
            counter_next = counter + 1;
            if (stop) begin
                state_next = IDLE
            end
            else if (counter == done_count) begin
                state_next = IDLE
                done = 1;
            end
        end
    endcase
end

endmodule