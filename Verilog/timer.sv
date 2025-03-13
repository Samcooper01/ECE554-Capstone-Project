module timer 
# (
    parameter clock_frequency_mhz   = 50;
    parameter time_milliseconds     = 1000;
    parameter is_oneshot            = 1;
    parameter is_autostart          = 0;
) (
    input clk,
    input rst_n,
    input stop,
    input start,
    output 
);

endmodule