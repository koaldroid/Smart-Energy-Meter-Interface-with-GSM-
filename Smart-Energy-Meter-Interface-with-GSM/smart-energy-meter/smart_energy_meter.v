`timescale 1ns/1ps


module energy_meter_ic (
    input clk,
    input load_on,
    output reg pulse
);

initial pulse = 0;

always @(posedge clk) begin
    if (load_on)
        pulse <= ~pulse;   
    else
        pulse <= 0;
end
endmodule


module energy_dsp (
    input clk,
    input pulse,
    output reg [15:0] energy_units
);

initial energy_units = 0;

always @(posedge clk) begin
    if (pulse)
        energy_units <= energy_units + 1;
end
endmodule


module mcu_controller (
    input clk,
    input [15:0] energy_units,
    output reg send_gsm
);

initial send_gsm = 0;

always @(posedge clk) begin
    if (energy_units >= 10)
        send_gsm <= 1;
    else
        send_gsm <= 0;
end
endmodule


module gsm_module (
    input clk,
    input send,
    input [15:0] data
);

always @(posedge clk) begin
    if (send)
        $display("GSM SMS SENT -> Energy Units = %d", data);
end
endmodule

// optional billing part that had been mentioned in the guidelines has been added
module billing_unit (
    input [15:0] energy_units,
    output reg [31:0] bill_amount
);

initial bill_amount = 0;

always @(*) begin
    bill_amount = energy_units * 5; 
end
endmodule


module smart_energy_meter (
    input clk,
    input load_on
);

wire pulse;
wire [15:0] energy_units;
wire send_gsm;
wire [31:0] bill_amount;

energy_meter_ic EM   (clk, load_on, pulse);
energy_dsp       DSP (clk, pulse, energy_units);
mcu_controller   MCU (clk, energy_units, send_gsm);
gsm_module       GSM (clk, send_gsm, energy_units);
billing_unit     BILL(energy_units, bill_amount);

endmodule