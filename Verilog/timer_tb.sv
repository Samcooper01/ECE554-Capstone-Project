module timer_tb ();

// signals
logic clk;
logic rst_n;
logic start;
logic stop;
logic done;

// DUT
timer #(.clock_frequency_mhz(50), .time_milliseconds(1000)) DUT (.clk(clk), .rst_n(rst_n), .start(start), .stop(stop), .done(done))

initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    stop = 0;
    @(negedge clk);
    rst_n = 1;
    @(negedge clk);
    start = 1;
    @(posedge done);
    $display("Timer Finished");
    $stop()
end

always begin
    #1;
    clk = ~clk;
end

endmodule