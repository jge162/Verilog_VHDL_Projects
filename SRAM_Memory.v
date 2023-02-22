//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 11/10/2021 05:13:19 PM
//// Design Name: 
//// Module Name: SRAM
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////
////********module*********
//module SRAM( 
//DataIn,
//DataOut,
//Addr, 
//CS, 
//WE, 
//RD, 
//CLK
//);   
////// parameters for the width 
////parameter ADR   = 8;
////parameter Data  = 8;
////parameter Depth = 255;

//input      [7:0]  DataIn;
//output reg [7:0]  DataOut;
//input      [7:0]  Addr;
//input CS, WE, RD, CLK;  

////**********MEMORY DECLARATION***********
//reg [7:0] my_memory [255:0];

//always @ (posedge CLK)
//begin
//    if (CS == 1'b1) begin
//        if (WE == 1'b1 && RD == 1'b0) begin //comparison done here
//   my_memory [Addr] = DataIn; //Write       // pass array values equal to DataIn
//  end

//  else if (RD == 1'b1 && WE == 1'b0) begin//comparison is done here
//   DataOut = my_memory [Addr]; //read operation // pass array values equal to DataIn
//  end

//  else;

// end

// else;

//end

//endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2021 05:13:19 PM
// Design Name: 
// Module Name: SRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SRAM( DataIn,
                DataOut,
                Addr, 
                CS, 
                WE, 
                RD, 
                CLK
              );

     
// parameters for the width 

parameter ADR   = 8;
parameter Data  = 8;
parameter Depth = 256;


input   [Data-1:0]  DataIn;
output reg [Data-1:0]  DataOut;
input   [ADR-1:0]  Addr;
input CS, WE, RD, CLK;  
//MEMORY DECLARATION
reg [Data-1:0] my_memory [Depth-1:0];
always @ (posedge CLK)
begin
 if (CS == 1'b1) begin
  if (WE == 1'b1 && RD == 1'b0) begin
   my_memory [Addr] = DataIn; //Write
  end

  else if (RD == 1'b1 && WE == 1'b0) begin
   DataOut = my_memory [Addr]; //read operation 
  end

  else;

 end

 else;

end

endmodule



