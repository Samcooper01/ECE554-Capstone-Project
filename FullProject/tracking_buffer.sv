module tracking_buffer # (
    parameter clock_frequency_mhz       = 50,
    parameter buffer_time_milliseconds    = 1000
)
(
    input           clk,
    input           rst_n,
    input           oCent_Val,
    output          on_screen
);

// Intermediate Signals
logic timer_done;
logic on_screen_intermediate;

// Instantiated Modules
timer #(.clock_frequency_mhz(clock_frequency_mhz), .time_milliseconds(buffer_time_milliseconds)) 
    fire_timer (.clk(clk), .rst_n(rst_n), .start(!oCent_Val), .stop(oCent_Val), .done(timer_done));

// Logic
assign on_screen = on_screen_intermediate;
always @(oCent_Val, timer_done, rst_n) begin
    if (oCent_Val) begin
        on_screen_intermediate = 1;
    end
    else if (timer_done || !rst_n) begin
        on_screen_intermediate = 0;
    end
end

endmodule