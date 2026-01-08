`timescale 1ns/1ps

module tb_cpu_4bit;

reg clk = 0;
reg reset = 1;

cpu_4bit DUT (
    .clk(clk),
    .reset(reset)
);


always #5 clk = ~clk;

initial begin
    $dumpfile("cpu_4bit.vcd");
    $dumpvars(0, tb_cpu_4bit);

    #10 reset = 0;   
    #100 $finish;
end

endmodule