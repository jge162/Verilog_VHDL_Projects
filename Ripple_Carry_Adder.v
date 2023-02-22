//Ripple Carry Adder
`timescale 1ns / 1ps

module half_adder(
    input A,
    input B,
    output Carry,
    output Sum
    );
    assign Carry = A & B;
    assign Sum = A ^ B; 
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
    
    half_adder HA1 (.A(A), .B(B), .Carry(HA1_Carry), .Sum(HA1_Sum));
    half_adder HA2 (.A(HA1_Sum), .B(Cin), .Carry(HA2_Carry), .Sum(HA2_Sum));
      
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
    
    FullAdder FA1 (
       .A(A[0]), 
       .B(B[0]),
       .Cin(Cin),
       .Sum(Sum[0]),
       .Cout(C0)
     );
     
     FullAdder FA2 (
       .A(A[1]),
       .B(B[1]),
       .Cin(C0),
       .Sum(Sum[1]),
       .Cout(C1)
     );
     
     FullAdder FA3 (
       .A(A[2]),
       .B(B[2]),
       .Cin(C1),
       .Sum(Sum[2]),
       .Cout(C2)
        
     );
     
     FullAdder FA4 (
       .A(A[3]),
       .B(B[3]),
       .Cin(C2),
       .Sum(Sum[3]),
       .Cout(Cout)
     );
