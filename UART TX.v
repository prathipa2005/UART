module uart_prat (
    input wire clk,          
    input wire rst,          
    input wire tx_start,     
    input wire [7:0] tx_data, 
    output reg tx,           
    output reg tx_done       
);

    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 50000000;
    parameter BAUD_TICK = CLOCK_FREQ / BAUD_RATE; 

    reg [3:0] bit_index = 0; 
    reg [15:0] baud_count = 0;
    reg [9:0] shift_reg;  
    reg tx_busy = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;
            tx_busy <= 0;
            baud_count <= 0;
            bit_index <= 0;
            tx_done <= 0;
        end else if (tx_start && !tx_busy) begin
            tx_busy <= 1;
            shift_reg <= {1'b1, tx_data, 1'b0}; 
            bit_index <= 0;
            baud_count <= 0;
        end else if (tx_busy) begin
            if (baud_count < BAUD_TICK - 1)
                baud_count <= baud_count + 1;
            else begin
                baud_count <= 0;
                tx <= shift_reg[bit_index];
                bit_index <= bit_index + 1;
                if (bit_index == 9) begin
                    tx_busy <= 0;
                    tx_done <= 1;
                end
            end
        end else begin
            tx_done <= 0;
        end
    end

endmodule

