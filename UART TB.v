
module uart_prat_tb;
    reg clk, rst, tx_start;
    reg [7:0] tx_data;
    wire tx, rx;
    wire [7:0] rx_data;
    wire tx_done, rx_done;
	 
assign rx = tx;  
    uart_prat transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );

    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx), 
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #10 clk = ~clk; 
    initial begin
        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 8'h00;
		  
        #100 rst = 0;
		  
		  #100 tx_data = 8'hA5;
tx_start = 1;
#40 tx_start = 0;  

wait (tx_done);
wait (rx_done);

#100;
$display("Received Data: %h", rx_data);


        
        $finish;
    end
endmodule
