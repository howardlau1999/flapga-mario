`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2018 07:25:03 PM
// Design Name: 
// Module Name: vga_clock
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


module vga_num(
input wire clk,
input wire enable,
input wire [15:0] nums,
output wire [15:0] addr,
output wire [15:0] dina
    );

    reg [3:0] num;
	wire [2:0] num_row, num_col;
	reg [2:0] writing_digit;
	reg [2:0] writing_digit_next;

    always @ (posedge clk)
    begin
    if (enable) begin
        case (writing_digit_next)
            3'b000: num <= (nums / 1000) % 10;
            3'b001: num <= (nums / 100) % 10;
            3'b010: num <= (nums / 10) % 10;
            3'b011: num <= nums % 10; 
        endcase
        
        writing_digit <= writing_digit_next;
        if (writing_digit == 3)
            writing_digit_next <= 0;
        else
            writing_digit_next <= writing_digit + 1;
        end
    end

    assign num_col = num % 8;
    assign num_row = num / 8;
    assign dina = {3'b100, num_row, num_col};
    assign addr = writing_digit + 17;    

            
endmodule
