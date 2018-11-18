`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2018 09:21:40 PM
// Design Name: 
// Module Name: seg_mux
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


module seg_mux(
input wire [1:0] s,
input wire [15:0] nums,
output wire [6:0] seg,
output wire [3:0] ano
    );
    reg [3:0] digit;
    always @ (*)
    begin
    case(s)
    2'b00: 
    digit = nums[3:0];
    2'b01: 
    digit = nums[7:4];
    2'b10: 
    digit = nums[11:8];
    2'b11: 
    digit = nums[15:12];
    default: digit = nums[3:0];
    endcase
    end
    assign ano[0] = s[0] | s[1];
    assign ano[1] = ~s[0] | s[1];
    assign ano[2] = s[0] | ~s[1];
    assign ano[3] = ~(s[0] & s[1]);
    bcd_7seg_anode bcd_7seg(.seg(seg), .bcd(digit));
endmodule
