`timescale 1ns / 1ps

module Systolic_array #(parameter DWIDTH = 8, array_size = 16)(
        input clk,
        input reset_n,
        input enable,
        input [array_size*array_size*DWIDTH-1:0] weight_i,
        input [array_size*DWIDTH-1:0] input_i,
        output [2*array_size*DWIDTH-1:0] result_o
    );
    
    wire [array_size*array_size*DWIDTH-1:0] pe_left;
    wire [array_size*array_size*DWIDTH-1:0] pe_right;
    wire [2*array_size*array_size*DWIDTH-1:0] pe_up;
    wire [2*array_size*array_size*DWIDTH-1:0] pe_down;
    
    generate 
        genvar i;
        for(i = 0; i < array_size*array_size; i = i+1) begin
            pe #(.DWIDTH(DWIDTH)) pe_array (
                .clk(clk),
                .reset_n(reset_n),
                .enable(enable),
                .up_i(pe_up[2*DWIDTH*i+:2*DWIDTH]),
                .left_i(pe_left[DWIDTH*i+:DWIDTH]),
                .right_o(pe_right[DWIDTH*i+:DWIDTH]),
                .down_o(pe_down[2*DWIDTH*i+:2*DWIDTH]),
                .weight(weight_i[DWIDTH*i+:DWIDTH])
            );
        end  
    endgenerate
    
    generate 
        genvar j;
        for(j = 0; j < array_size*array_size; j = j+1) begin
            //up + down
            if(j < 16) assign pe_up[2*j*DWIDTH+:2*DWIDTH] = 0;
            else assign pe_up[j*2*DWIDTH+:2*DWIDTH] = pe_down[(j-array_size)*2*DWIDTH+:2*DWIDTH];
            if(j > 239) assign result_o[2*DWIDTH*(j-16*15)+:2*DWIDTH] = pe_down[2*j*DWIDTH+:2*DWIDTH];
            //left + right
            if(j%16 == 0) assign pe_left[j*DWIDTH+:DWIDTH] = input_i[j/16*DWIDTH+:DWIDTH];
            else assign pe_left[j*DWIDTH+:DWIDTH] = pe_right[(j-1)*DWIDTH+:DWIDTH];
            if(j%16 == 15) assign pe_right[j*DWIDTH+:DWIDTH] = 0;
        end
    endgenerate
endmodule
