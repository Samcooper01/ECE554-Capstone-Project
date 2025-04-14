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

module RAW2RGB_640X480(	oRed,
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
reg		[11:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg				mDVAL;

/*
assign	oRed	=	mCCD_R[11:0];
assign	oGreen	=	mCCD_G[11:0];
assign	oBlue	=	mCCD_B[11:0];
assign	oDVAL	=	mDVAL;
*/

assign oRed 	= 	({iY_Cont[0], iX_Cont[0]} == 2'b10) ? iDATA : '0;
assign oGreen 	= 	({iY_Cont[0], iX_Cont[0]} == 2'b00) ? iDATA : ({iY_Cont[0], iX_Cont[0]} == 2'b11) ? iDATA : '0;
assign oBlue	= 	({iY_Cont[0], iX_Cont[0]} == 2'b01) ? iDATA : '0;
assign oDVAL 	= 	iDVAL;

// Even row even col = G1
// Even row odd col = R
// Odd row even col = B
// Odd row odd col = G2
/*
always_ff @(posedge iCLK, negedge iRST) begin
	if (!iRST) begin
		oRed 	<= '0;
		oGreen 	<= '0;
		oBlue 	<= '0;
		oDVAL	<= '0;
	end
	else begin
		oDVAL <= iDVAL;
		case({iY_Cont[0], iX_Cont[0]}) 
			2'b00 | 2'b11: begin
				oGreen	<= iDATA;
				oRed 	<= '0;
				oBlue	<= '0;
			end
			2'b01: begin
				oGreen	<= 0;
				oRed 	<= iDATA;
				oBlue	<= '0;
			end
			2'b10: begin
				oGreen	<= 0;
				oRed 	<= '0;
				oBlue	<= iDATA;
			end
		endcase
	end
end
*/


/*
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
		if({iY_Cont[0],iX_Cont[0]}==2'b10)     	//even col odd row
		begin
			mCCD_R	<=	'0;
			mCCD_G	<=	'0;
			mCCD_B	<=	iDATA;
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)	//odd col odd row
		begin
			mCCD_R	<=	'0;
			mCCD_G	<=	iDATA;
			mCCD_B	<=	'0;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)	//even col even row
		begin
			mCCD_R	<=	'0;
			mCCD_G	<=	iDATA;
			mCCD_B	<=	'0;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b01)	//odd col even row
		begin
			mCCD_R	<=	iDATA;
			mCCD_G	<=	'0;
			mCCD_B	<=	'0;
		end
	end
end
*/

endmodule


