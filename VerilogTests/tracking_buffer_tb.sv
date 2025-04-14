module tracking_buffer_tb();

// Signals
logic clk;
logic rst_n;
logic oCent_Val;
logic on_screen;

// DUT
tracking_buffer # (
    .clock_frequency_mhz(1),
    .buffer_time_milliseconds(1)
) DUT (
    .clk(clk),
    .rst_n(rst_n),
    .oCent_Val(oCent_Val),
    .on_screen(on_screen)
);

initial begin
    clk = 0;
    rst_n = 0;
    oCent_Val = 0;
    @(negedge clk);
    rst_n = 1;
    @(negedge clk);
    
    oCent_Val = 1;
    repeat(100) @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 1: the object should always be on screen while detected");
        $stop();
    end
    @(negedge clk);
    oCent_Val = 0;
    @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 2: the object is not on screen 1 cycle after being seen");
        $stop();
    end
    repeat(500) @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 3: the object is not on screen halfway though the first timer");
        $stop();
    end
    @(negedge clk);
    oCent_Val = 1;
    repeat(1000) @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 4: the timer did not stop");
        $stop();
    end
    @(negedge clk);
    oCent_Val = 0;
    repeat(600) @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 5: the object is not on screen halfway though the second timer");
        $stop();
    end
    repeat(1000) @(negedge clk);
    if (on_screen !== 0) begin
        $display("Error 6: the object is on screen after the timer ended");
        $stop();
    end
    @(negedge clk);
    oCent_Val = 1;
    @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 7: the object should be back on the screen");
        $stop();
    end
    @(negedge clk);
    oCent_Val = 0;
    @(negedge clk);
    repeat(600) @(negedge clk);
    if (on_screen !== 1) begin
        $display("Error 8: the object is not on screen halfway though the third timer");
        $stop();
    end
    repeat(1000) @(negedge clk);
    if (on_screen !== 0) begin
        $display("Error 9: the object is on screen after the timer ended");
        $stop();
    end

    $display("YAHOO!!! All tests passed!");
    $stop();
end

always begin
    #5;
    clk = ~clk;
end

endmodule