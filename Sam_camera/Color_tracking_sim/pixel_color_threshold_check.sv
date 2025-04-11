module pixel_color_threshold_check(
    input   logic           iCLK,
    input   logic           iRST_N,
    input   logic           iEN,                    //Master enable for module
    input   logic           iDATA_VAL,              //Valid pixel
    input   logic [11:0]    iDATA,                  //Bayer color pixel
    input   logic [15:0]    iX_Cont,                //X (column index) position of pixel
    input   logic [15:0]    iY_Cont,                //Y (row index) posiiton of pixel
    input   logic           iCALIBRATE_SW_COLOR,    //Select color of object
    input   logic [11:0]    iMEAN,
    input   logic [11:0]    iSET_THRESH,
    input   logic           iSET_MEAN_AND_THRESH,
    output  logic           oOBJ_VAL                //High when pixel is likely the object (is greater than calibration threshold)
);

//iCALIBRATE_SW -> on rising edge of switch start calibrating
// to calibrate object hold in front of the camera so object takes up entire position of the camera.
//iCALIBRATE_SW_COLOR == 0 means the object is blue 
//iCALIBRATE_SW_COLOR == 1 means the object is red
//We assume the background is always green.

//Calibration takes the average pixel color of an entire frame

//Color centroid calculation and color threshold calculation then make sure both match for valid pair to be

logic           obj_color; // if 1 then obj is blue if 0 then obj is red
logic [11:0]    color_threshold; //minimum value to determine if object is present
logic [11:0]    mean;

logic           valid_thresh_mean;

assign obj_color = iCALIBRATE_SW_COLOR;

assign thresh_diff = (iDATA > iMEAN) ? (iDATA - iMEAN) : (iMEAN - iDATA); //calculate abs difference

//Set color threshold
always_ff @(posedge iCLK or negedge iRST_N) begin
   if(!iRST_N) begin
        color_threshold <= '0;
        mean            <= '0
        valid_thresh_mean    <= 0;
   end 
   else if (iSET_MEAN_AND_THRESH & iEN) begin
        color_threshold <= iSET_THRESH;
        mean            <= iMEAN;
        valid_thresh_mean    <= 1;
   end
end

//Check color threshold
always_ff @(posedge iCLK or negedge iRST_N) begin
    if(!iRST_N) begin
        oOBJ_VAL <= 0;
    end
    else if(iEN & iDATA_VAL & valid_thresh_mean) begin
        if((thresh_diff) < color_threshold) begin //if abs difference between data and mean is within a thresh then val
            oOBJ_VAL <= 1;
        end
        else begin
            oOBJ_VAL <= 0;
        end
    end
    else begin
        oOBJ_VAL <= 0;
    end
end 

endmodule
