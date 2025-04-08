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

// Intermediate Signals
logic 

// State Machine Signals
logic [2:0] {IDLE, RUN} state, state_next;

// State Machine Sequential Logic
always_ff @(posedge clk or negedge rst_n) begin
    state = state_next;
end

// State Machine implementation


endmodule