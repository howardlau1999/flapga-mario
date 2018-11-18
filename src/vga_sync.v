`timescale 1 ns / 1 ns
module vga_sync(
  input wire clk, clr,
  output wire hsync, vsync, video_on, p_tick, f_tick,
  output wire [9:0] x, y
);
parameter DISPLAY_H = 640;
parameter DISPLAY_V = 480;

parameter BORDER_LEFT = 48;
parameter BORDER_RIGHT = 16;

parameter BORDER_TOP = 10;
parameter BORDER_BOTTOM = 33;

parameter RETRACE_H = 96;
parameter RETRACE_V = 2;

parameter H_MAX = DISPLAY_H + BORDER_LEFT + BORDER_RIGHT + RETRACE_H - 1;
parameter V_MAX = DISPLAY_V + BORDER_TOP + BORDER_BOTTOM + RETRACE_V - 1;

parameter H_RETRACE_START = DISPLAY_H + BORDER_RIGHT;
parameter H_RETRACE_END = H_RETRACE_START + RETRACE_H - 1;

parameter V_RETRACE_START = DISPLAY_V + BORDER_BOTTOM;
parameter V_RETRACE_END = V_RETRACE_START + RETRACE_V - 1;

reg [1:0] pixel_reg;
wire [1:0] pixel_next;
wire pixel_tick;

always @(posedge clk, posedge clr)
		if (clr)
		  pixel_reg <= 0;
		else
		  pixel_reg <= pixel_next;
	
	assign pixel_next = pixel_reg + 1; // increment pixel_reg 
	
	assign pixel_tick = (pixel_reg == 0); // assert tick 1/4 of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg, h_count_next, v_count_reg, v_count_next;
    reg vsync_reg, hsync_reg;
    wire vsync_next, hsync_next;
always @ (posedge clk, posedge clr)
		if (clr)
		    begin
                    v_count_reg <= 0;
                    h_count_reg <= 0;
                    vsync_reg   <= 0;
                    hsync_reg   <= 0;
		    end
		else
		    begin
                    v_count_reg <= v_count_next;
                    h_count_reg <= h_count_next;
                    vsync_reg   <= vsync_next;
                    hsync_reg   <= hsync_next;
		    end

always @ (*)
		begin
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			       : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			       : v_count_reg;
		end
		
        // hsync and vsync are active low signals
        // hsync signal asserted during horizontal retrace
        assign hsync_next = h_count_reg >= H_RETRACE_START
                            && h_count_reg <= H_RETRACE_END;
   
        // vsync signal asserted during vertical retrace
        assign vsync_next = v_count_reg >= V_RETRACE_START
                            && v_count_reg <= V_RETRACE_END;

        // video only on when pixels are in both horizontal and vertical display region
        assign video_on = (h_count_reg < DISPLAY_H) 
                          && (v_count_reg < DISPLAY_V);

        // output signals
        assign hsync  = hsync_reg;
        assign vsync  = vsync_reg;
        assign x      = h_count_reg;
        assign y      = v_count_reg;
        assign p_tick = pixel_tick;
        assign f_tick = x == 0 && y == 0;
endmodule // 