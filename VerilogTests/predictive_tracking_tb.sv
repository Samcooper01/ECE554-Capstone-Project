module predictive_tracking_tb();
    // DUT Signals
    logic                   clk;
    logic                   rst_n;
    logic                   is_tracking;
    logic unsigned [9:0]    raw_x;
    logic unsigned [8:0]    raw_y;
    logic                   coordinates_valid;
    logic unsigned [9:0]    predict_x;
    logic unsigned [8:0]    predict_y;

    // DUT
    predictive_tracking DUT (
        .clk(clk),
        .rst_n(rst_n),
        .is_tracking(is_tracking),
        .raw_x(raw_x),
        .raw_y(raw_y),
        .coordinates_valid(coordinates_valid),
        .predict_x(predict_x),
        .predict_y(predict_y)
    );

    // Clock generator
    always begin
        #5;
        clk = ~clk;
    end

    // Testing
    initial begin
        clk = 0;
        rst_n = 0;
        is_tracking = 0;
        raw_x = 0;
        raw_y = 0;
        coordinates_valid = 0;
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        // Test 1: test that there is no prediction change when the prediciton flops are empty
        raw_x = 320;
        raw_y = 240;
        #1;
        if (predict_x != 320 || predict_y != 240) begin
            $display("Test 1 failed: (x,y) is supposed to be (320,240) but was instead (%d,%d)", predict_x, predict_y);
            $stop();
        end

        // Test 2: test that there is some prediciton change when one past prediction is loaded
        @(negedge clk);
        is_tracking = 1;
        @(negedge clk);
        coordinates_valid = 1;
        @(negedge clk);
        coordinates_valid = 0;
        @(negedge clk);
        raw_x = 328;
        raw_y = 248;
        #1;
        if (predict_x != 336 || predict_y != 256) begin
            $display("Test 2 failed: (x,y) is supposed to be (332,252) but was instead (%d,%d)", predict_x, predict_y);
            $stop();
        end

        // Test 3: test that there is more of a prediciton change when two past predictions are loaded
        @(negedge clk);
        coordinates_valid = 1;
        @(negedge clk);
        coordinates_valid = 0;
        @(negedge clk);
        raw_x = 332;
        raw_y = 252;
        #1;
        if (predict_x != 340 || predict_y != 260) begin
            $display("Test 3 failed: (x,y) is supposed to be (340,260) but was instead (%d,%d)", predict_x, predict_y);
            $stop();
        end

        // Test 4: Try going back in the opposite direction
        @(negedge clk);
        coordinates_valid = 1;
        @(negedge clk);
        coordinates_valid = 0;
        @(negedge clk);
        raw_x = 330;
        raw_y = 250;
        #1;
        if (predict_x != 332 || predict_y != 252) begin
            $display("Test 4 failed: (x,y) is supposed to be (334,254) but was instead (%d,%d)", predict_x, predict_y);
            $stop();
        end

        // Test 5: End tracking to see if things go back to normal
        @(negedge clk);
        is_tracking = 0;
        @(negedge clk);
        raw_x = 330;
        raw_y = 250;
        #1;
        if (predict_x != 330 || predict_y != 250) begin
            $display("Test 5 failed: (x,y) is supposed to be (340,250) but was instead (%d,%d)", predict_x, predict_y);
            $stop();
        end
        
        $display("YAHOO!!! All tests passed");
        $stop();
    end
endmodule