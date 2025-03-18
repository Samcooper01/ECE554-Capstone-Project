module counter
# (
    parameter TICKS_PER_US = 'd50,   // 50 FPGA clock cycles for 1us tick
    parameter PERIOD = 'd10000        // units of us, equal to 20ms      
) (
    input clk, 
    input rst_n, 
    output logic [15:0] counter
); 

// signal to indicate a us has passed 
logic tick;
logic [5:0] tick_counter;

// generate a tick every 50 clock cycles
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        tick <= 1'b0;
        tick_counter <= 6'b0; 
    end else begin
        if (tick_counter == TICKS_PER_US) begin
            tick <= 1'b1;
            tick_counter <= 6'b0;
        end else begin 
            tick <= 1'b0;
            tick_counter <= tick_counter + 1;
        end
    end
end

// counter to keep track of the number of us that have passed
always_ff @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        counter <= 16'b0;
    end else begin 
        if (counter == PERIOD) begin
            counter <= 16'b0;
        end else if (tick) begin 
            counter <= counter + 1;
        end 
    end
end

endmodule