module state_machine(
    input           clk
    input           rst_n,
    input           on_screen,              // set when the paper airplaine is on screen calculated by the object tracker
    input   [11:0]  tracked_coordinates_x,  // coordinates of the tracked paper airplane
    input   [11:0]  tracked_coordinates_y,
    output  [11:0]  driven_coordinates_x,   // coordinates given to the servo pipeline
    output  [11:0]  driven_coordinates_y,
    output          fire,                   // turn this on to fire laser
);

// Intermediate Signals

// State Machine Signals
logic [2:0] {IDLE, TRACKING, LOCKED}

// State Machine Sequential Logic

// State Machine implementation

endmodule