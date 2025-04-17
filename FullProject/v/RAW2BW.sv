module RAW2BW		(	
					oRed,
					oGreen,
					oBlue,
					oDVAL,
					iX_Cont,
					iY_Cont,
					iDATA,
					iDVAL,
					iCLK,
					iRST,
					driven_coordinates_x,
					driven_coordinates_y
					);

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
input   [9:0]   driven_coordinates_x;
input   [8:0]   driven_coordinates_y;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;

logic	[11:0]	iDATA_ff;
logic	[11:0]	mDATA;
logic	[11:0]	mDATA_ff;
logic			mDVAL;

logic			[11:0]	grayscale_pixel_value;
logic					isWithinThreshold;

parameter pixel_box_width = 5;
assign isWithinThreshold = ((iX_Cont >= driven_coordinates_x - pixel_box_width && iX_Cont <= driven_coordinates_x + pixel_box_width) &&
	(iY_Cont >= driven_coordinates_y - pixel_box_width && iY_Cont <= driven_coordinates_y + pixel_box_width));

assign	oRed	=	(isWithinThreshold) ? 12'hFFF : grayscale_pixel_value;
assign	oGreen	=	(isWithinThreshold) ? 12'hFFF : grayscale_pixel_value;
assign	oBlue	=	(isWithinThreshold) ? 12'hFFF : grayscale_pixel_value;
assign	oDVAL	=	mDVAL;

// Line buffer used for grayscale conversion
Line_Buffer2 u0 (
	//Inputs
	.clken(iDVAL),
	.clock(iCLK),
	.shiftin(iDATA),
	.taps(mDATA)
);

// Update pixel values every cycle
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		iDATA_ff	<=	0;
		mDATA_ff 	<= 	0;
		mDVAL		<=  0;
		grayscale_pixel_value <=  0;
	end
	else
	begin
		mDATA_ff <= mDATA;
		iDATA_ff <= iDATA;
		// Set valid signal high at the same time as the RGB module or else we get distortions when switching
		mDVAL <= {iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;

		grayscale_pixel_value <= (mDATA_ff + mDATA + iDATA_ff + iDATA) / 4;	// Average pixels in a 2x2 square to get the grayscale value
	end
end


endmodule


