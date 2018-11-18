`timescale 1ns / 1ps
module clock_div(
    input wire clk, 
    input wire clr,
    output wire out_clk,
    output reg[1:0] s
);
    parameter MAX_COUNT = 50_000 - 1;
    reg [31:0] counter;
    initial begin
        counter <= 0;
        s <= 2'b00;
        end
        always @ (posedge clk or posedge clr)
        begin
        if (clr == 1)
        counter <= 0;
        else if (counter == MAX_COUNT) begin
            counter <= 0;
            s <= s + 1;
        end
        else
        counter <= counter + 1;
    end
    assign out_clk = counter == 0;
endmodule

module clock_normal(
input wire clk, 
input wire clr,
output wire out_clk,
output reg[15:0] clock
    );
parameter MAX_COUNT = 100_000_000 - 1;
        reg [31:0] counter;
      
        always @ (posedge clk or posedge clr)
        begin
        if (clr == 1)
        counter <= 0;
        else if (counter == MAX_COUNT) begin
            counter <= 0;
            if (clock[3:0] < 9)
                clock[3:0] = clock[3:0] + 1;
            else begin
                clock[3:0] = 0;
                if (clock[7:4] < 5)
                    clock[7:4] = clock[7:4] + 1;
                else begin
                    clock[7:4] = 0;
                    if (clock[11:8] < 9)
                                clock[11:8] = clock[11:8] + 1;
                            else begin
                                clock[11:8] = 0;
                                if (clock[15:12] < 5)
                                    clock[15:12] = clock[15:12] + 1;
                                else begin
                                    clock[15:12] = 0;
                                end
                            end
                end
            end
            
        end
        else
        counter <= counter + 1;
        end
        assign out_clk = counter == 0;
endmodule

module clock_div_n #(
parameter MAX_COUNT = 15 - 1
)(
input wire clk, 
input wire clr,
output wire out_clk,
output reg wlk
    );

        reg [31:0] counter;
        initial begin
        counter <= 0;
        end
        always @ (posedge clk or posedge clr)
        begin
        if (clr == 1)
        counter <= 0;
        else if (counter == MAX_COUNT) begin
            counter <= 0;
            wlk <= ~wlk;
        end
        else
        counter <= counter + 1;
        
        end
        assign out_clk = counter == 0;
endmodule
