`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2022 06:08:43 PM
// Design Name: 
// Module Name: memory_tb
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



module memory_tb();
//test bench for Memory SRAM

reg [7:0] DataIn;
reg [7:0] Addr; 
reg CS;
reg WE; 
reg RD; 
reg CLK;
wire [7:0] DataOut;
//Now, change the memory size to 256X8
reg  [7:0] my_memory [255:0];

SRAM dut ( //calling SRAM file
.DataIn(DataIn),
.DataOut(DataOut),
.Addr(Addr), 
.CS(CS), 
.WE(WE), 
.RD(RD), 
.CLK(CLK)
);

initial begin
//initialize at 0
DataIn = 8'h0;
Addr   = 8'h0;
CS     = 8'h0;
WE     = 8'h0;
RD     = 8'h0;
CLK    = 8'h0;#10;//ms
//---------------------------
//set Control Signal and WE - write operation
DataIn = 8'h0;
Addr   = 8'h0;
CS     = 8'h1;//cs is 1
WE     = 8'h1;//write is 1
RD     = 8'h0;#30;//read is zero 
//---------------------------
DataIn = 8'h1;
Addr   = 8'h1;#30;
//first write data 10,20,30,40 (hex data) 
DataIn = 8'hA;   //10
Addr   = 8'h2;#30;

DataIn = 8'h14;  //20
Addr   = 8'h3;#30;

DataIn = 8'h1E;  //30
Addr   = 8'h4;#30;

DataIn = 8'h28;  //40
Addr   = 8'h5;#30;
//---------------------------
//read the data here RD =1 
Addr   = 8'h0;
WE     = 8'h0;#50;
RD     = 8'h1;#20;
//---------------------------
//fill memory
Addr   = 8'h1;#20;

Addr   = 8'h2;#20;

Addr   = 8'h3;#20;

Addr   = 8'h4;#20;

Addr   = 8'h5;#20;
//---------------------------
end  
always #10 CLK = ~CLK;  
//Now, change the memory size to 256X8, 
//first write data 10,20,30,40 (hex data) 
// to memory location 10,20,30, 40 resp, 
//and then read the data on output databus, 
// first data byte (10), which should be 
//read first, followed by rest of the bytes.  
endmodule
