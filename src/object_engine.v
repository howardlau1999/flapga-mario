`timescale 1ns / 1ns

module object_engine #(
  parameter OAM_WIDTH = 32, 
  parameter OAM_DEPTH = 8,
  parameter TILE_WIDTH = 32,
  parameter TILE_HEIGHT = 32,
  parameter OAM_CACHE_DEPTH = 8
) (
    input wire clk,
    input wire video_on,
    input wire [9:0] x, y,
    input wire [31:0] oam_data,
    output reg [2:0] oam_addr,
    output wire sprite_on,
    output wire [11:0] color
);

    reg [11:0] color_reg;
    reg [6:0] rom_x, rom_y;
    reg evaluating;
    wire [11:0] rom_data;

    integer i;
    reg [OAM_WIDTH - 1:0] oam_cache [OAM_CACHE_DEPTH - 1:0];
    reg [3:0] len;
    reg [7:0] in_range, display_something;
    `define SPRITE_ENABLE oam_cache[i][31:31]
    `define X_FLIP oam_cache[i][26:26]
    `define OBJ_POS_X oam_cache[i][25:16]
    `define OBJ_POS_Y oam_cache[i][15:6]
    `define SPRITE_COL oam_cache[i][2:0]
    `define SPRITE_ROW oam_cache[i][5:3]

    mario_rom mario_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(rom_data));

    always @ (posedge clk) begin
        oam_addr <= oam_addr + 1;
        oam_cache[oam_addr] <= oam_data;
        for (i = 0; i < OAM_CACHE_DEPTH; i = i + 1) begin
        if (`SPRITE_ENABLE)
            if (x >= `OBJ_POS_X & x < `OBJ_POS_X + TILE_WIDTH & y >= `OBJ_POS_Y & y < `OBJ_POS_Y + TILE_HEIGHT) begin
                if (`X_FLIP) 
                    rom_x <= `SPRITE_COL * TILE_WIDTH + TILE_WIDTH - 1 - (x - `OBJ_POS_X);
                else
                    rom_x <= `SPRITE_COL * TILE_WIDTH + (x - `OBJ_POS_X);
                rom_y <= `SPRITE_ROW * TILE_HEIGHT + (y - `OBJ_POS_Y);
                color_reg <= rom_data;
                in_range[i] <= 1;
            end else in_range[i] <= 0;
        end 
    // object evaluation
    /*    if (video_on == 0) begin
            if (evaluating) begin
                if (len < 8) begin
                    oam_addr <= oam_addr + 1;
                    if (y >= oam_data[oam_addr][19:10] & y < oam_data[oam_addr][19:10] + TILE_HEIGHT) begin
                        oam_cache[len] <= oam_data;
                        len <= len + 1;
                    end
                end else begin
                    evaluating <= 0;
                end
        end else begin
            evaluating <= 1;
        end
    */
    end
    assign sprite_on = (rom_data == 12'h00f | ~(|in_range) ) ? 0 : 1;
    assign color = color_reg;
endmodule 
