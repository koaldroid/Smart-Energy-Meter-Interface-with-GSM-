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
    input reset,
    output reg [15:0] energy_units
);
reg pulse_prev;
initial begin
    energy_units = 0;
    pulse_prev = 0;
end
always @(posedge clk) begin
    if (reset) begin
        energy_units <= 0;
        pulse_prev <= 0;
    end
    else begin
        pulse_prev <= pulse;
        if (pulse && !pulse_prev)
            energy_units <= energy_units + 1;
    end
end
endmodule

module mcu_controller (
    input clk,
    input reset,
    input [15:0] energy_units,
    output reg send_gsm,
    output reg [1:0] alert_level
);
parameter THRESHOLD_LOW = 10;
parameter THRESHOLD_MED = 50;
parameter THRESHOLD_HIGH = 100;

reg [15:0] last_threshold;
initial begin
    send_gsm = 0;
    alert_level = 0;
    last_threshold = 0;
end

always @(posedge clk) begin
    if (reset) begin
        send_gsm <= 0;
        alert_level <= 0;
        last_threshold <= 0;
    end
    else begin
        if (energy_units >= THRESHOLD_HIGH)
            alert_level <= 2;
        else if (energy_units >= THRESHOLD_MED)
            alert_level <= 1;
        else
            alert_level <= 0;
        
        if ((energy_units >= THRESHOLD_LOW && last_threshold < THRESHOLD_LOW) ||
            (energy_units >= THRESHOLD_MED && last_threshold < THRESHOLD_MED) ||
            (energy_units >= THRESHOLD_HIGH && last_threshold < THRESHOLD_HIGH)) begin
            send_gsm <= 1;
            last_threshold <= energy_units;
        end
        else
            send_gsm <= 0;
    end
end
endmodule

module gsm_module (
    input clk,
    input send,
    input [15:0] data,
    input [1:0] alert_level
);
always @(posedge clk) begin
    if (send) begin
        case (alert_level)
            0: $display("GSM SMS: Energy=%0d units [NORMAL]", data);
            1: $display("GSM SMS: Energy=%0d units [WARNING]", data);
            2: $display("GSM SMS: Energy=%0d units [CRITICAL]", data);
        endcase
    end
end
endmodule

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
    input load_on,
    input reset
);
wire pulse;
wire [15:0] energy_units;
wire send_gsm;
wire [31:0] bill_amount;
wire [1:0] alert_level;

energy_meter_ic EM   (clk, load_on, pulse);
energy_dsp       DSP (clk, pulse, reset, energy_units);
mcu_controller   MCU (clk, reset, energy_units, send_gsm, alert_level);
gsm_module       GSM (clk, send_gsm, energy_units, alert_level);
billing_unit     BILL(energy_units, bill_amount);
endmodule
