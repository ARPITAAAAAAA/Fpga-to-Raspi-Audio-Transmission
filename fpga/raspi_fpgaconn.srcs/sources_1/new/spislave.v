`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2026 20:41:38
// Design Name: 
// Module Name: spislave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spislave #(
    parameter N = 64
)(
    input wire clk,
    input wire rst,

    // SPI interface
    input wire sclk,
    input wire mosi,
    output reg miso,
    input wire ss,   // active LOW

    // Interface to FFT / processing block
    output reg [7:0] data_in,
    output reg data_valid,
    input wire [7:0] data_out,
    input wire data_out_valid,

    output reg frame_done   // 64 samples received
);

    // ========================
    // Internal registers
    // ========================
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;

    reg [6:0] sample_cnt;

    reg sclk_d;
    wire sclk_rise = (sclk == 1 && sclk_d == 0);
    wire sclk_fall = (sclk == 0 && sclk_d == 1);

    // TX buffer
    reg [7:0] tx_reg;

    // ========================
    // Edge detect
    // ========================
    always @(posedge clk)
        sclk_d <= sclk;

    // ========================
    // SPI logic
    // ========================
    always @(posedge clk) begin
        if (rst) begin
            bit_cnt <= 0;
            sample_cnt <= 0;
            data_valid <= 0;
            frame_done <= 0;
            miso <= 0;
        end else begin

            data_valid <= 0;
            frame_done <= 0;

            if (ss == 0) begin

                // --------------------
                // RECEIVE (MOSI)
                // --------------------
                if (sclk_rise) begin
                    shift_reg <= {shift_reg[6:0], mosi};
                    bit_cnt <= bit_cnt + 1;

                    if (bit_cnt == 7) begin
                        data_in <= {shift_reg[6:0], mosi};
                        data_valid <= 1;

                        sample_cnt <= sample_cnt + 1;
                        bit_cnt <= 0;

                        if (sample_cnt == N-1) begin
                            frame_done <= 1;
                            sample_cnt <= 0;
                        end
                    end
                end

                // --------------------
                // TRANSMIT (MISO)
                // --------------------
                if (data_out_valid) begin
                    tx_reg <= data_out;
                end

                if (sclk_fall) begin
                    miso <= tx_reg[7 - bit_cnt];
                end

            end else begin
                bit_cnt <= 0;
                sample_cnt <= 0;
            end
        end
    end

endmodule