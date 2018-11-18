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


module game_over_text(
input wire clk,
input wire enable,
output wire [15:0] addr,
output wire [15:0] dina
    );

	reg [5:0] glyph;
	reg [2:0] writing_text;
	reg [2:0] writing_text_next;

    always @ (posedge clk)
    begin
    if (enable) begin
        case (writing_text_next)
            3'b000: glyph <= 6'b011100;
            3'b001: glyph <= 6'b010111;
            3'b010: glyph <= 6'b010111;
            3'b011: glyph <= 6'b100101;
            3'b100: glyph <= 6'b001011;
            3'b101: glyph <= 6'b001010;
            3'b110: glyph <= 6'b001101;
            3'b111: glyph <= 6'b100011;
        endcase
        
        writing_text <= writing_text_next;
                if (writing_text == 7)
                    writing_text_next <= 0;
                else
                    writing_text_next <= writing_text + 1;
                end
   end

    assign dina = {enable, 2'b00, glyph};
    assign addr = writing_text + 55;    
    
            
endmodule
