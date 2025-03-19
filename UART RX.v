module uart_rx (
    input wire clk,        
    input wire rst,        
    input wire rx,         
    output reg [7:0] rx_data, 
    output reg rx_done     
);

    parameter BAUD_RATE = 115200;
    parameter CLOCK_FREQ = 50000000;
    parameter BAUD_TICK = CLOCK_FREQ / BAUD_RATE;
	 

    reg [3:0] bit_index = 0;
    reg [15:0] baud_count = 0;
    reg [9:0] shift_reg = 10'b1111111111;
    reg rx_busy = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_done <= 0;
            bit_index <= 0;
            rx_busy <= 0;
            shift_reg <= 10'b1111111111;
        end else begin
            shift_reg <= {rx, shift_reg[9:1]}; 

            if (!rx_busy && shift_reg[1:0] == 2'b10) begin 
                rx_busy <= 1;
                baud_count <= 0;
                bit_index <= 0;
            end else if (rx_busy) begin
                if (baud_count < BAUD_TICK - 1)
                    baud_count <= baud_count + 1;
                else begin
                    baud_count <= 0;
                    bit_index <= bit_index + 1;
                    if (bit_index < 8)
                        rx_data[bit_index] <= shift_reg[0];
                    else begin
                        rx_busy <= 0;
                        rx_done <= 1;
                    end
                end
            end else
                rx_done <= 0;
        end
    end
endmodule
