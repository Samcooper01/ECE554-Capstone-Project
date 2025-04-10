module timer_tb ();

// signals
logic clk;
logic rst_n;
logic start;
logic stop;
logic done;

// DUT
timer #(.clock_frequency_mhz(1), .time_milliseconds(1)) DUT (.clk(clk), .rst_n(rst_n), .start(start), .stop(stop), .done(done));

initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    stop = 0;
    @(negedge clk);
    rst_n = 1;
    @(negedge clk);

    $display("Test 1: Ensure time stops and done goes low one cycle after end of timer");
    start = 1;
    @(negedge clk);
    start = 0;
    @(posedge done);
    repeat (2) @(negedge clk);
    if (done !== 0) begin
        $display("Done did not go low");
        $stop();
    end

    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;
    @(negedge clk);
    stop = 1;
    @(negedge clk);
    stop = 0;
    repeat (1000) @(negedge clk);

    $display("YAHOO!!! All tests passed!");
    $stop();
end

always begin
    #5;
    clk = ~clk;
end

endmodule