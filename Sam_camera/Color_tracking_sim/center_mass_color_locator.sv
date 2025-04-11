module center_mass_color_locator(
    input           iClk,
    input           iRST_N,
    input           iEN,
    input           iDATA_VAL,
    input [11:0]    iDATA,
    input [15:0]    iX_Cont,
    input [15:0]    iY_Cont,
    input           iFVAL,
    input           iCOLOR_SW,
    input [31:0]    iFrame_Cont,
    output          oOBJ_VAL,
    output [15:0]   oX_POS,
    output [15:0]   oY_POS
);

//Top level module for finding center mass of color in single frame
    //performs color calibration 
    //identifies color center using...
        //centroid identification
        //pixel color threshold checking
    //on valid obj found the two methods should match coordinates

//Used to find the mean color of the object
color_mean_calibration iCalibrate(
    .iClk(),
    .iRST_N(), 
    .iDATA_VAL(),              
    .iDATA(),                  
    .iX_Cont(),                
    .iY_Cont(),                
    .iFVAL(),
    .iCOLOR_SW(),
    .iCAL_SW(),
    .oMEAN_VAL(),
    .oMEAN()
);

//Used to find the color centroid for a whole frmae
frame_color_centroid iFrame_Centroid(
    .iCLK(),
    .iRST_N(),
    .iEN(),           
    .iX_Cont(),             
    .iY_Cont(),             
    .iDATA(),
    .iDATA_VAL(),
    .iFVAL(),
    .iFrame_Cont(),
    .oCORD_VAL(),
    .oX_centroid(),        
    .oY_centroid()           
);

//Average threshold pixels for a whole frame
threshold_pixels_mean_pos iFrame_threshold_mean(
    .iCLK(),
    .iRST_N(),
    .iEN(),
    .iFVAL(),
    .iX_Cont(),
    .iY_Cont(),
    .iOBJ_VAL(),
    .oMeas_VAL(),
    .oX_mean(),
    .oY_mean()
);

//Individual pixel color threshold check
pixel_color_threshold_check iPixel_Check(
    .iCLK(),
    .iRST_N(),
    .iEN(),                
    .iDATA_VAL(),         
    .iDATA(),          
    .iX_Cont(),      
    .iY_Cont(),     
    .iCALIBRATE_SW_COLOR(),    
    .iMEAN(),
    .iSET_THRESH(),
    .iSET_MEAN_AND_THRESH(),
    .oOBJ_VAL()                
);



endmodule