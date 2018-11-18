`timescale 1ns / 1ps
module mario(
    input wire clk, reset,
    input wire up, down, left, right, 
    input wire game_over,
    output reg [9:0] pos_x_reg = 80,
    output reg [9:0] pos_y_reg = 64,
    output wire [31:0] dina,
    output wire [2:0] addr
);

    reg [2:0] rom_col, rom_row;
    reg [9:0] pos_x_next, pos_y_next;
    
    assign dina = {5'b10000, 1'b0, pos_x_reg, pos_y_reg, rom_row, rom_col};
    assign addr = 0;           
    
    localparam TIME_START_Y      =   100000;  
    localparam TIME_STEP_Y       =    10000; 
    localparam TIME_MAX_Y        =   800000;  
    localparam TIME_TERM_Y       =   250000; 
    
    localparam [2:0]     jump_down    = 3'b000, 
                         jump_up  = 3'b100;
   
    reg [2:0] state_reg_y, state_next_y;  
   
    reg [19:0] jump_t_reg, jump_t_next; 
    reg [19:0] start_reg_y, start_next_y; 
    reg [25:0] extra_up_reg, extra_up_next;    
   
    // signals for up-button positive edge signal
    reg [7:0] up_reg;
    wire up_edge;
    assign up_edge = ~(&up_reg) & up;
    parameter MIN_Y = 32;

    always @(posedge clk)
    begin
    if (reset) begin
            pos_y_reg <= 64;
        end else begin
            state_reg_y  <= state_next_y;
            jump_t_reg   <= jump_t_next;
            start_reg_y  <= start_next_y;
            extra_up_reg <= extra_up_next;
            pos_y_reg    <= pos_y_next;
            up_reg     <= {up_reg[6:0], up};
        end
    end

    always @ * begin
        if (game_over) begin
            rom_row <= 1;
            rom_col <= 0;
        end else
        if (state_next_y == jump_up) begin
            rom_row <= start_next_y > 100000 & start_next_y < 600000;
            rom_col <= 3'b001;
        end else begin
            rom_row <= start_next_y > 550000 & start_next_y <= 800000;
            rom_col <= start_next_y > 550000 & start_next_y <= 800000;
        end
    end       

    always @ * begin
        state_next_y  = state_reg_y;
        jump_t_next   = jump_t_reg;
        start_next_y  = start_reg_y;
        extra_up_next = extra_up_reg;
        pos_y_next    = pos_y_reg;

        if(up_edge & ~game_over) begin
            state_next_y = jump_up;             
            start_next_y = TIME_START_Y;        
            jump_t_next = TIME_START_Y;         
            extra_up_next = 0;                  
        end

        case (state_reg_y)
            jump_up: begin

                if(jump_t_reg > 0) begin
                    jump_t_next = jump_t_reg - 1; 
                end
                       
                if(jump_t_reg == 0) begin
                        
    		        if( pos_y_next > MIN_Y)                 	
    			        pos_y_next = pos_y_reg - 1; 
    						
        		    if(start_reg_y <= TIME_MAX_Y) begin
                            start_next_y = start_reg_y + TIME_STEP_Y; 
                            jump_t_next = start_reg_y + TIME_STEP_Y;  
                        end
                    else                                          
                        begin
                            state_next_y = jump_down;
                            start_next_y = TIME_MAX_Y;                
                            jump_t_next  = TIME_MAX_Y;                
                        end
                    end

                end

            jump_down: begin                 
                if(jump_t_reg > 0)                                    
                    begin
                        jump_t_next = jump_t_reg - 1;                     
                    end
                if(jump_t_reg == 0)                                   
                    begin
                        begin
                        if (pos_y_next <= 480)
                            pos_y_next = pos_y_reg + 1;                       
                        if(start_reg_y > TIME_TERM_Y)                 
                            begin
                                start_next_y = start_reg_y - TIME_STEP_Y; 
                                jump_t_next = start_reg_y - TIME_STEP_Y;  
                            end
                        else
                            begin  
                                jump_t_next = TIME_TERM_Y;
                            end
                        end                 
                    end
                end
            endcase
        end
endmodule
