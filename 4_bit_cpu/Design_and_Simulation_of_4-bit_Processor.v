`timescale 1ns/1ps

module alu (
    input  [3:0] a, b,
    input  [2:0] alu_ctrl,
    output reg [3:0] result
);
always @(*) begin
    case (alu_ctrl)
        3'b000: result = a + b; 
        3'b001: result = a - b; 
        3'b010: result = a & b; 
        3'b011: result = a | b; 
        default: result = 4'b0000;
    endcase
end
endmodule

module reg_file (
    input clk, we,
    input [1:0] ra1, ra2, wa,
    input [3:0] wd,
    output [3:0] rd1, rd2
);
reg [3:0] regs [0:3];


initial begin
    regs[0] = 4'd1;
    regs[1] = 4'd2;
    regs[2] = 4'd3;
    regs[3] = 4'd4;
end

assign rd1 = regs[ra1];
assign rd2 = regs[ra2];

always @(posedge clk)
    if (we) regs[wa] <= wd;
endmodule


module instr_mem (
    input  [3:0] addr,
    output reg [7:0] instr
);
always @(*) begin
    case (addr)
        4'd0: instr = 8'b0000_0001; 
        4'd1: instr = 8'b0011_0010; 
        4'd2: instr = 8'b0001_0001; 
        4'd3: instr = 8'b1111_0000; 
        default: instr = 8'b1111_0000;
    endcase
end
endmodule


module control_unit (
    input  [3:0] opcode,
    output reg we,
    output reg [2:0] alu_ctrl
);
always @(*) begin
    we = 1'b1;
    case (opcode)
        4'b0000: alu_ctrl = 3'b000; 
        4'b0001: alu_ctrl = 3'b001; 
        4'b0010: alu_ctrl = 3'b010; 
        4'b0011: alu_ctrl = 3'b011; 
        default: begin
            alu_ctrl = 3'b000;
            we = 1'b0; 
        end
    endcase
end
endmodule


module cpu_4bit (
    input clk,
    input reset
);
reg  [3:0] pc;
wire [7:0] instr;
wire [3:0] a, b, alu_out;
wire we;
wire [2:0] alu_ctrl;


always @(posedge clk) begin
    if (reset)
        pc <= 4'b0000;
    else
        pc <= pc + 1;
end

instr_mem     IM (pc, instr);
control_unit  CU (instr[7:4], we, alu_ctrl);
reg_file      RF (clk, we, instr[3:2], instr[1:0],
                  instr[3:2], alu_out, a, b);
alu           ALU(a, b, alu_ctrl, alu_out);

endmodule