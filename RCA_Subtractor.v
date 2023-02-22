
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2021 06:24:07 PM
// Design Name: 
// Module Name: FullAdder
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


module half_adder(
    input A,
    input B,
    output Carry,
    output Sum
    );
    assign Carry = A & B;
    assign Sum   = A ^ B; 
endmodule


module FullAdder(
    input A,
    input B,
    input Cin,
    output Cout, 
    output Sum
    );
    
    wire HA1_Carry;
    wire HA1_Sum;
    wire HA2_Carry;
    wire HA2_Sum;
    
    half_adder HA1(
        .A(A),
        .B(B),
        .Carry(HA1_Carry),
        .Sum(HA1_Sum)
        );
    
    half_adder HA2 (
        .A(HA1_Sum),
        .B(Cin),
        .Carry(HA2_Carry),
        .Sum(HA2_Sum)
        );
      
     assign Cout = HA1_Carry | HA2_Carry;
     assign Sum = HA2_Sum;
endmodule
    
module RCA (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
 );
    wire C0;
    wire C1;
    wire C2;
    FullAdder FA1 ( A[0], B[0],Cin,Sum[0],C0);
    FullAdder FA2 ( A[1], B[1],C0,Sum[1],C1);
    FullAdder FA3 ( A[2], B[2],C1,Sum[2],C2);
    FullAdder FA4 ( A[3], B[3],C2,Sum[3],Cout);
endmodule


module RCAS (
    input [3:0] A,
    input [3:0] B,
    input Cin, 
    input sel,
    output [3:0] Sum,
    output Cout
 );
    //bit [3:0]Bint;
    //assign Bint = (sel)? B : (B' + 4'b0001);
    RCA u_RCA ( A, Bint, Cin,Sum,Cout);
 endmodule

