module state_machine_tb ();

// signals
logic           clk;
logic           rst_n;
logic           on_screen;
logic  [10:0]   tracked_coordinates_x;
logic  [10:0]   tracked_coordinates_y;
logic  [10:0]   driven_coordinates_x;
logic  [10:0]   driven_coordinates_y;
logic           fire;

// DUT
state_machine #(
    .clock_frequency_mhz(1),
    .fire_time_milliseconds(1)
) DUT (
    .clk(clk),
    .rst_n(rst_n),
    .on_screen(on_screen),
    .tracked_coordinates_x(tracked_coordinates_x),
    .tracked_coordinates_y(tracked_coordinates_y),
    .driven_coordinates_x(driven_coordinates_x),
    .driven_coordinates_y(driven_coordinates_y),
    .fire(fire)
);

initial begin
    clk = 0;
    rst_n = 0;
    on_screen = 0;
    tracked_coordinates_x = 0;
    tracked_coordinates_y = 0;
    @(negedge clk);
    rst_n = 1;
    @(negedge clk);
    on_screen = 1;
    repeat(1010) @(negedge clk);
    if (fire !== 1) begin
        $display("Error: fire signal failed to go high after timer should have ended");
        $stop();
    end
    on_screen = 0;
    repeat(10) @(negedge clk);

    on_screen = 1;
    repeat(505) @(negedge clk);
    if (fire !== 0) begin
        $display("Error: fire signal went high too early");
        $stop();
    end
    on_screen = 0;
    repeat(10) @(negedge clk);

    $display("YAHOO!!! All tests passed!");
    $stop();
end

always begin
    #5;
    clk = ~clk;
end

endmodule