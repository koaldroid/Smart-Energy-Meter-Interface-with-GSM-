`timescale 1ns/1ps

module tb_smart_energy_meter;

reg clk = 0;
reg load_on = 1;

smart_energy_meter DUT (
    .clk(clk),
    .load_on(load_on)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("energy_meter.vcd");
    $dumpvars(0, tb_smart_energy_meter);

    #200;
    load_on = 0;   
    #50;

    $finish;
end

endmodule