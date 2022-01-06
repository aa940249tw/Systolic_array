`timescale 1ns / 1ps

module pe #(parameter DWIDTH = 8)(
        input clk,
        input reset_n,
        input enable,
        input [DWIDTH-1:0] left_i,
        input [2*DWIDTH-1:0] up_i,
        input [DWIDTH-1:0] weight,
        output reg [DWIDTH-1:0] right_o,
        output reg [2*DWIDTH-1:0] down_o
    );
    
    reg [DWIDTH:0] out_n;
    
    always @(posedge clk) begin
        if(~reset_n || ~enable) begin
            out_n <= 0;
            right_o <= 0;
            down_o <= 0;
        end
        else begin
            right_o <= left_i;
            down_o <= out_n;
        end
    end
    
    always @(*) begin
        out_n = left_i * weight + up_i;
    end
endmodule
