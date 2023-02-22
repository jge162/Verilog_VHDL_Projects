//ADDER SUBTRACTOR
module RCAs (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Cout
);
    wire [3:0] B_comp;
    wire C0;
    wire C1;
    wire C2;
    
xor (B_comp[0], B[0], Cin);
xor (B_comp[1], B[1], Cin);
xor (B_comp[2], B[2], Cin);
xor (B_comp[3], B[3], Cin);

FullAdder FA1(.A(A[0]), .B(B_comp[0]),.Cin(Cin),.Sum(S[0]),.Cout(C0));
FullAdder FA2(.A(A[1]), .B(B_comp[1]),.Cin(C0), .Sum(S[1]),.Cout(C1));
FullAdder FA3(.A(A[2]), .B(B_comp[2]),.Cin(C1), .Sum(S[2]),.Cout(C2));
FullAdder FA4(.A(A[3]), .B(B_comp[3]),.Cin(C2), .Sum(S[3]),.Cout(Cout));
endmodule
