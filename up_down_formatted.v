timescale 1ns / 1ps
/ /* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** 
Up_down counter
/ /* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** 
module up_down
(parameter N = 10, 
parameter WIDTH = 7) (
input clk, reset, up_down, pause, output[WIDTH - 1 : 0] hex_out);
reg [3 : 0] tmp;
wire Clock_slow;
wire [3 : 0] count;
clock_divider dut(.clk(clk), .reset(reset), .sclk(Clock_slow));
always @(posedge Clock_slow OR negedge reset) BEGIN
IF (reset == 1'b0)
 tmp = 4'b0000;
 ELSE
	 IF (pause)
	 tmp = tmp;
	 ELSE IF (up_down)
		 IF (tmp == N - 1) tmp = 4'b0000;
		 ELSE
			 tmp = tmp + 1'b1;
		 ELSE IF (up_down == 1'b0) IF (tmp == 4'b0000)
			 tmp = N - 1;
		 ELSE
			 tmp = tmp - 1'b1;
			 4/12
		 END
		 assign count = tmp;
		 seven_segment_decoder uut (.bin_in(count), .hex_out(hex_out));
		 endmodule
		 / /* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** 
		 Clock Divider
		 / /* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** 
		 module clock_divider(
		 input clk, 
		 input reset, 
		 output reg sclk
		 );
		 reg [31 : 0] count;
		 always@(posedge clk OR negedge reset) BEGIN
		 IF (reset == 1'b0) BEGIN
		 count <= 32'd0;
		 sclk <= 1'b0;
		 END ELSE BEGIN
		 IF (count == 32'd50000000) BEGIN
		 //50000000
		 count <= 32'd0;
		 sclk <= ~sclk;
		 END ELSE BEGIN
		 count <= count + 1;
	 END
 END
 END endmodule
 / /* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** 
 Segement 7
 / /* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** 
 module seven_segment_decoder(
 input [3 : 0] bin_in, output reg [6 : 0] hex_out);
 reg [6 : 0] hex_out;
 always @(bin_in) BEGIN
 CASE (bin_in) //CASE statement 0 : hex_out = 7'b0000001;
	 1 : hex_out = 7'b1001111;
	 2 : hex_out = 7'b0010010;
	 3 : hex_out = 7'b0000110; 4 : hex_out = 7'b1001100;
	 5/12

	 5 : hex_out = 7'b0100100;
	 6 : hex_out = 7'b0100000;
	 7 : hex_out = 7'b0001111;
	 8 : hex_out = 7'b0000000;
	 9 : hex_out = 7'b0000100; //switch off 7 segment CHARACTER DEFAULT : hex_out = 7'b1111111;
	 endcase END
	 endmodule
