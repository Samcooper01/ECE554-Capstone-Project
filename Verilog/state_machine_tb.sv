module state_machine_tb ();

// signals
logic           clk;
logic           rst_n;
logic           on_screen;
logic  [10:0]   tracked_coordinates_x,
logic  [10:0]   tracked_coordinates_y,
logic  [10:0]   driven_coordinates_x,
logic  [10:0]   driven_coordinates_y,
logic           fire

// DUT
state_machine #(
    parameter clock_frequency_mhz       = 50,
    parameter fire_time_milliseconds    = 200
)

(
    input           clk,
    input           rst_n,
    input           on_screen,              // set when the paper airplaine is on screen calculated by the object tracker
    input   [10:0]  tracked_coordinates_x,  // coordinates of the tracked paper airplane
    input   [10:0]  tracked_coordinates_y,
    output  [10:0]  driven_coordinates_x,   // coordinates given to the servo pipeline
    output  [10:0]  driven_coordinates_y,
    output          fire                    // turn this on to fire laser
);

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