module servo_tb(); 

    reg clk; 
    reg rst_n;
    reg [7:0] angle;
    wire pwm_pin;

    //init dut
    servo DUT (
        .clk(clk),
        .rst_n(rst_n),
        .angle(angle),
        .pwm_pin(pwm_pin)
    );

    initial begin 
        clk = 1'b0;
        rst_n = 1'b0;
        angle = 8'b0;

        @(negedge clk) rst_n = 1'b1;

        // verify initial angle of 0 has a duty cycle of 1000us
        $display("Test: initial angle of 0 has a duty cycle of 1000us");
        @(posedge clk) begin 
            if (DUT.pulse_width != 1000) begin 
                $display("Test failed: initial angle of 0 has a duty cycle of %d", DUT.pulse_width);
            end
            else $display("PASSED");
        end

        fork
            begin : to1
                repeat (150000) @(posedge clk);
                $dislay("ERR: timeout waiting for counter to go back to zero")
            end :to1
            begin
                if (DUT.CLOCK_GEN.counter == 0) begin 
                    disable to1;
                end 
            end
        join

        // test known angle values and duty cycles
        $dislay("Test: angle of 90 has a duty cycle of 1500us");
        angle = 90;
        @(posedge clk) begin
            if (DUT.pulse_width != 1500) begin 
                $display("Test failed: angle of 90 has a duty cycle of %d", DUT.pulse_width);
            end
            else $display("PASSED");
        end

        fork
            begin : to2
                repeat (150000) @(posedge clk);
                $dislay("ERR: timeout waiting for counter to go back to zero")
            end :to2
            begin
                if (DUT.CLOCK_GEN.counter == 0) begin 
                    disable to2;
                end 
            end
        join

        $dislay("Test: angle of 180 has a duty cycle of 2000us");
        angle = 180;
        @(posedge clk) begin
            if (DUT.pulse_width != 1500) begin 
                $display("Test failed: initial angle of 180 has a duty cycle of %d", DUT.pulse_width);
            end
            else $display("PASSED");
        end

        fork
            begin : to3
                repeat (150000) @(posedge clk);
                $dislay("ERR: timeout waiting for counter to go back to zero")
            end : to3
            begin
                if (DUT.CLOCK_GEN.counter == 0) begin 
                    disable to3;
                end 
            end
        join
    end

    always #5 clk = ~clk;

endmodule