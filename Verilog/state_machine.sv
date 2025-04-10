module state_machine # (
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

// Intermediate Signals
logic timer_start;
logic timer_stop;
logic timer_done;

// Instantiated Modules
timer #(.clock_frequency_mhz(clock_frequency_mhz), .time_milliseconds(fire_time_milliseconds)) 
    DUT (.clk(clk), .rst_n(rst_n), .start(timer_start), .stop(timer_stop), .done(timer_done));

// State Machine Signals
enum logic [2:0] {IDLE, TRACKING, LOCKED} state, state_next;

// State Machine Sequential Logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state = IDLE;
    end
    else begin
        state = state_next;
    end
end

// State Machine implementation
always_comb begin
    state_next = state;
    case (state)
        IDLE: begin
            if (on_screen) begin
                state_next = TRACKING;
            end
        end
        TRACKING: begin
            if (!on_screen) begin
                state_next = IDLE;
            end
            else if (timer_done) begin
                state_next = LOCKED;
            end
        end
        LOCKED: begin
            if (!on_screen) begin
                state_next = IDLE;
            end
        end
        default: begin
            state_next = IDLE;
        end

    endcase
end

// State machine outputs
assign driven_coordinates_x = (state == IDLE) ? 320 : tracked_coordinates_x;
assign driven_coordinates_y = (state == IDLE) ? 240 : tracked_coordinates_y;
assign fire = (state == LOCKED) ? 1 : 0;
assign timer_start = (state == TRACKING) ? 1 : 0;
assign timer_stop = !on_screen;

endmodule