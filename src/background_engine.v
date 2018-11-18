`timescale 1ns / 1ns

module background_engine(
    input wire clk,
    input wire video_on,
    input wire [3:0] x_offset,
    input wire [9:0] x, y,
    input wire [15:0] ram_data,
    output reg [15:0] ram_addr,
    output wire pixel_on,
    output wire [11:0] color
);
    reg [13:0] rom_addr;
    reg [6:0] rom_x, rom_y;
    wire [11:0] rom_data;
    parameter TILE_WIDTH = 16;
    parameter TILE_HEIGHT = 16;
    parameter TILE_COLS = 640 / TILE_WIDTH;
    parameter TILE_ROWS = 480 / TILE_HEIGHT;

    `define TILE_COL ram_data[2:0]
    `define TILE_ROW ram_data[5:3]
    `define X_FILP ram_data[6:6]
    `define Y_FLIP ram_data[7:7]
    `define ENABLE ram_data[8:8]
    `define POS_X ((x + x_offset) / TILE_WIDTH)
    `define POS_Y (y / TILE_HEIGHT)

    bg_rom bg_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(rom_data));

    always @ * begin
      ram_addr = `POS_X + `POS_Y  * TILE_COLS;
      if (`X_FILP == 0)
        rom_x = `TILE_COL * TILE_WIDTH + ((x + x_offset) % TILE_WIDTH);
      else
        rom_x = `TILE_COL * TILE_WIDTH + (TILE_WIDTH - 1 - ((x + x_offset) % TILE_WIDTH));
      
      if (`Y_FLIP == 0)
        rom_y = `TILE_ROW * TILE_HEIGHT + (y % TILE_HEIGHT);
      else
        rom_y = `TILE_ROW * TILE_HEIGHT + TILE_HEIGHT - 1 - (y % TILE_HEIGHT);
    end

    assign pixel_on = ~(rom_data == 12'h00f | `ENABLE == 0);
    assign color = (rom_data == 12'h00f | `ENABLE == 0) ? 12'b0 : rom_data;

endmodule // background_engine
