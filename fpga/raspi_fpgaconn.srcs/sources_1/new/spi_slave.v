module spi_slave (
    input wire clk,
    input wire sclk,
    input wire cs,
    input wire mosi,
    input wire reset,
    output reg miso
);

    reg [7:0] data = 0;

    always @(posedge clk) begin
    data <= data + 1;
    end
    reg [2:0] bit_cnt = 7;

    // Synchronize SCLK
    reg sclk_d1, sclk_d2;

    always @(posedge clk) begin
        sclk_d1 <= sclk;
        sclk_d2 <= sclk_d1;
    end

    wire sclk_rising = (sclk_d1 & ~sclk_d2);

    always @(posedge clk) begin
        if (cs) begin
            bit_cnt <= 7;
            miso <= data[7];   // preload MSB
        end 
        else if (sclk_rising) begin
            miso <= data[bit_cnt];
            bit_cnt <= bit_cnt - 1;
        end
    end

endmodule