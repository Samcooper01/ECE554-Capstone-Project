// --------------------------------------------------------------------
// Copyright (c) 20057 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	RAW2RGB
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| 		Changes Made:
//   V1.0 :| Johnny Fan        :| 07/08/01  :|      Initial Revision
// --------------------------------------------------------------------

module RAW2RGB_bilinear(oRed,
                        oGreen,
                        oBlue,
                        oDVAL,
                        iX_Cont,
                        iY_Cont,
                        iDATA,
                        iDVAL,
                        iCLK,
                        iRST
                        );

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;
reg		[11:0]	mCCD_R;
reg		[12:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg				mDVAL;

assign	oRed	=	mCCD_R[11:0];
assign	oGreen	=	mCCD_G[11:0];
assign	oBlue	=	mCCD_B[11:0];
assign	oDVAL	=	mDVAL;

Line_Buffer4 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_R	<=	0;
		mCCD_G	<=	0;
		mCCD_B	<=	0;
		mDATAd_0<=	0;
		mDATAd_1<=	0;
		mDVAL	<=	0;
	end
	else
	begin
		mDATAd_0	<=	mDATA_0;
		mDATAd_1	<=	mDATA_1;
		mDVAL		<=	iDVAL;

        // Invert iX_Cont[0] so that the case ordering matches the right-to-left stream.
        case ({iY_Cont[0], ~iX_Cont[0]})
            2'b00: begin // Even row, red pixel (actual: iX[0]==1)
                mCCD_R <= mDATA_0;
                // For green, take an average of adjacent horizontal/vertical neighbors
                mCCD_G <= (mDATA_1 + mDATAd_0) >> 1;
                // For blue, use a diagonal neighbor as an approximation
                mCCD_B <= mDATAd_1;
            end
            2'b01: begin // Even row, green pixel (G1) (actual: iX[0]==0)
                // Red is interpolated from horizontal neighbors
                mCCD_R <= (mDATA_0 + mDATAd_0) >> 1;
                mCCD_G <= mDATA_0;  // direct green sample
                // Blue interpolated vertically
                mCCD_B <= (mDATA_1 + mDATAd_1) >> 1;
            end
            2'b10: begin // Odd row, blue pixel (actual: iX[0]==1)
                // Red from horizontal neighbors
                mCCD_R <= (mDATA_0 + mDATAd_0) >> 1;
                // Green from vertical/horizontal interpolation
                mCCD_G <= (mDATA_1 + mDATAd_0) >> 1;
                mCCD_B <= mDATA_1;  // direct blue sample
            end
            2'b11: begin // Odd row, green pixel (G2) (actual: iX[0]==0)
                // Red from horizontal interpolation
                mCCD_R <= (mDATA_0 + mDATAd_0) >> 1;
                mCCD_G <= mDATA_0;  // direct green sample
                // Blue from vertical interpolation
                mCCD_B <= (mDATA_1 + mDATAd_1) >> 1;
            end
        endcase
	end
end
endmodule


