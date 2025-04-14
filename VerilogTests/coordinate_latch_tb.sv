module coordinate_latch_tb();

// Signals
logic rst_n;
logic oCent_Val;
logic [9:0] oX_Cent;
logic [8:0] oY_Cent;
logic [9:0] tracked_coordinates_x;
logic [8:0] tracked_coordinates_y;

// DUT
coordinate_latch DUT (
    .rst_n(rst_n),
    .oCent_Val(oCent_Val),
    .oX_Cent(oX_Cent),
    .oY_Cent(oY_Cent),
    .tracked_coordinates_x(tracked_coordinates_x),
    .tracked_coordinates_y(tracked_coordinates_y)
);

// Tests
initial begin
    rst_n = 0;
    oCent_Val = 0;
    oX_Cent = 0;
    oY_Cent = 0;
    #5;
    rst_n = 1;
    #5;
    oCent_Val = 1;
    oX_Cent = 1;
    oY_Cent = 2;
    #5;
    if (tracked_coordinates_x !== 1 || tracked_coordinates_y !== 2) begin
        $display("Test 1 failed: coordinates failed to change when valid is high");
        $stop();
    end
    #5;
    oCent_Val = 0;
    #5;
    oX_Cent = 3;
    oY_Cent = 4;
    #5;
    if (tracked_coordinates_x !== 1 || tracked_coordinates_y !== 2) begin
        $display("Test 2 failed: coordinates changed when valid was low");
        $stop();
    end
    #5;
    oCent_Val = 1;
    #5;
    if (tracked_coordinates_x !== 3 || tracked_coordinates_y !== 4) begin
        $display("Test 3 failed: coordinates did not change when valid went back high");
        $stop();
    end
    #5;

    $display("YAHOO!!! All tests passed!");
    $stop();

end

endmodule