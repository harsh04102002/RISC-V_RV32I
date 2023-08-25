`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.08.2023 18:57:24
// Design Name: 
// Module Name: test
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


module test();

reg clk, rst;
wire [31:0] Result;
wire zero,overload,hlt;

RV32I rv(.clk(clk),.rst(rst),.Result(Result),.zero(zero),.overload(overload),.hlt(hlt));


initial
begin
 clk = 0;
 rst = 1;
end

always
 #5 clk = ~clk;
 
 initial
 begin
 #7.5 rst = 0;
 #100 $finish;  
 end
endmodule
