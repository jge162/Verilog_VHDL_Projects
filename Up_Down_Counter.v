
`timescale 1ns / 1ps 
//*************************************** 
// Up_down counter 
//*************************************** 
module up_down
#(parameter N = 10,
parameter WIDTH = 7) (
input clk, reset,up_down,pause, output[WIDTH-1:0] hex_out); reg [3:0] tmp;
wire Clock_slow;
wire [3:0] count;
clock_divider dut(.clk(clk),.reset(reset),.sclk(Clock_slow));
always @(posedge Clock_slow or negedge reset) begin
if(reset == 1'b0)
tmp = 4'b0000; else if (pause)
tmp = tmp;
else if(up_down)
if( tmp == N-1) tmp = 4'b0000;
else
tmp = tmp + 1'b1;
else if (up_down == 1'b0) if ( tmp == 4'b0000)
tmp = N-1; else
 tmp = tmp - 1'b1;
4/12
end
assign count = tmp;
seven_segment_decoder uut (.bin_in(count),.hex_out(hex_out)); endmodule
//***************************************
// Clock Divider 
//*************************************** 
module clock_divider(
input clk,
input reset,
output reg sclk
);
reg [31:0] count;
always@(posedge clk or negedge reset) begin
if(reset == 1'b0) begin
count <= 32'd0;
sclk <= 1'b0;
end else begin
if(count == 32'd50000000) begin //50000000
count <= 32'd0; sclk <= ~sclk;
end else begin
count <= count + 1; end
end
end endmodule
//*************************************** 
// Segement 7 
//*************************************** 
module seven_segment_decoder(
input [3:0] bin_in, output reg [6:0] hex_out );
// reg [6:0] hex_out;
always @(bin_in) begin
case (bin_in) //case statement 0 : hex_out = 7'b0000001;
1 : hex_out = 7'b1001111;
2 : hex_out = 7'b0010010;
3 : hex_out = 7'b0000110; 4 : hex_out = 7'b1001100;
5/12

5 : hex_out = 7'b0100100;
6 : hex_out = 7'b0100000;
7 : hex_out = 7'b0001111;
8 : hex_out = 7'b0000000;
9 : hex_out = 7'b0000100; //switch off 7 segment character default : hex_out = 7'b1111111;
endcase end
endmodule
