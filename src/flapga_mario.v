module flapga_mario
	(
		input wire clk, clr,
		input wire [15:0] sw,
		input wire up, down, left, right, 
		output wire hsync, vsync,
		output wire [11:0] rgb,
		output wire [6:0] seg,
        output wire [3:0] ano,
        output wire dp,
        output wire out
	);
	integer z_index;
	parameter LAYERS = 3;
	reg [11:0] rgb_reg;
	reg [11:0] ctrl;
	wire bg_wea;
	wire wlk;

	wire [11:0] rgb_pic[0:LAYERS - 1];
	wire layer_on[0:LAYERS - 1];
	wire video_on, f_tick, clock_clk, walk_clk;
	wire [9:0] x, y;
	wire [15:0] nums;
	wire [38:0] dina[0:1];
	wire [38:0] data;
    wire [15:0] addr[0:1];
    wire [15:0] bg_data;
    wire [15:0] bg_ram_addr;
    wire [15:0] splash_data;
    wire [15:0] splash_addr;
    wire [31:0] oam_data;
    wire [2:0] oam_addr;
    wire [15:0] bam_data;
    wire [3:0] bg_x_offset;
    reg [9:0] cloud_x_offset;
    
    parameter GAME_BEGIN_DELAY = 500_000_000;
    reg [31:0] splash_timer;
    reg game_begin = 0;
	    clock_normal clock_normal(.clk(clk), .clr(0), .out_clk(clock_clk), .clock(nums));
        vga_sync vga_sync_unit (.clk(clk), .clr(0), .hsync(hsync), .vsync(vsync),
                                .video_on(video_on), .p_tick(), .f_tick(f_tick), .x(x), .y(y));

        display display(.basys3_clk(clk), .seg(seg), .ano(ano), .nums(nums));
        audio_output audio(clk, out);
            ram #(
                    .RAM_WIDTH(9), 
                    .RAM_DEPTH(1208), 
                    .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
                    .INIT_FILE("splash.bin")
                  ) splash_ram (
                    .addra(0),
                    .addrb(bg_ram_addr),
                    .dina(0), 
                    .clka(clk),     
                    .wea(0),    
                    .enb(1), .rstb(0),    
                    .regceb(1), .doutb(splash_data)
                  );
        ram #(
            .RAM_WIDTH(9), 
            .RAM_DEPTH(1208), 
            .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
            .INIT_FILE("")
          ) bg_ram (
            .addra(addr[0]),
            .addrb(bg_ram_addr),
            .dina(dina[0]), 
            .clka(clk),     
            .wea(bg_wea),    
            .enb(1), .rstb(0),    
            .regceb(1), .doutb(bg_data)
          );
          
          ram #(.RAM_WIDTH(32), .RAM_DEPTH(8), .RAM_PERFORMANCE("HIGH_PERFORMANCE"),.INIT_FILE()) oam (
              .addra(addr[1]),
              .addrb(oam_addr),
              .dina(dina[1]), 
              .clka(clk),     
              .wea(bg_wea),    
              .enb(1), .rstb(0),    
              .regceb(1), .doutb(oam_data)
            );
        cloud_bg cloud_bg(clk, video_on, ((x + cloud_x_offset) / 3) % 213, y / 3, rgb_pic[0]);
        background_engine bg_engine(clk, video_on, bg_x_offset, x, y, bam_data, bg_ram_addr, layer_on[1], rgb_pic[1]);
        object_engine obj_eng (clk, video_on, x, y, oam_data, oam_addr, layer_on[2], rgb_pic[2]);
        game_engine game_eng (clk, clr, video_on, game_begin, up, down, left, right, f_tick, x, y, bg_x_offset, addr[1], addr[0], bg_wea, dina[1], dina[0]);
        
        assign bam_data = game_begin ? bg_data : splash_data;
        assign layer_on[0] = y > 32 & game_begin;
        always @ (posedge clk)
        if (clr) begin
            game_begin <= 0;
            splash_timer <= 0;
        end else
        begin
            if (~game_begin & splash_timer < GAME_BEGIN_DELAY)
                splash_timer <= splash_timer + 1;
            else if (splash_timer == GAME_BEGIN_DELAY) game_begin <= 1;
            for (z_index = 0; z_index < LAYERS; z_index = z_index + 1) begin
                if (layer_on[z_index])
                    rgb_reg <= rgb_pic[z_index];
            end
        end
        always @ (posedge bg_x_offset[0]) begin
            if (cloud_x_offset == 639) cloud_x_offset <= 0;
            else cloud_x_offset <= cloud_x_offset + 1;
        end
        assign dp = 1;
        assign rgb = (video_on & (layer_on[0] | layer_on[1] | layer_on[2])) ? rgb_reg : 12'b0;
   
endmodule