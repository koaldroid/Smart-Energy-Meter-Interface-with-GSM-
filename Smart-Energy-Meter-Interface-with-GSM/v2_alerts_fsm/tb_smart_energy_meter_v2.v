`timescale 1ns/1ps

module tb_smart_energy_meter;
    reg clk = 0;
    reg load_on = 0;
    reg reset = 0;
    
    smart_energy_meter DUT (
        .clk(clk),
        .load_on(load_on),
        .reset(reset)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $monitor("Time=%0t | Load=%b Reset=%b | Energy=%0d | Bill=%0d | Alert=%0d | GSM=%b", 
                 $time, load_on, reset,
                 DUT.energy_units, DUT.bill_amount, 
                 DUT.alert_level, DUT.send_gsm);
    end
    
    initial begin
        $dumpfile("energy_meter.vcd");
        $dumpvars(0, tb_smart_energy_meter);
        
        $display("=== Starting Smart Energy Meter Test ===\n");
        
        #50;
        $display("\nTest: Load ON - accumulating energy");
        load_on = 1;
        #300;
        
        $display("\nTest: RESET - clearing energy");
        reset = 1;
        #20;
        reset = 0;
        #20;
        
        $display("\nTest: Resume operation");
        load_on = 1;
        #400;
        
        $display("\nTest: Load OFF");
        load_on = 0;
        #50;
        
        $display("\n=== Test Complete ===");
        $display("Final Energy: %0d units", DUT.energy_units);
        $display("Final Bill: Rs.%0d", DUT.bill_amount);
        
        $finish;
    end
    
    always @(posedge DUT.send_gsm) begin
        $display(">>> GSM SMS SENT at time %0t <<<", $time);
    end
    
    initial #2000 $finish;
    
endmodule
