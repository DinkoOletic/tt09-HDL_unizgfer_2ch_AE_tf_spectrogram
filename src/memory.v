module memory(
    input wire clk_write,  
    input wire clk_read,                 
    input wire write_enable,
    input wire read_enable,           
    input wire [8:0] address_in,
    input wire [8:0] address_out,        
    input wire [2:0] data_in,       
    output reg [2:0] data_out
	 //output  [2:0] mem1_test,
	 //output  [2:0] mem2_test
);

initial begin

	data_out = 3'b0;
end
	//assign mem1_test = mem1[0];
	//assign mem2_test = mem2[0];
    // two blocs of 200 box of 8 
    reg [2:0] mem1 [199:0];
    reg [2:0] mem2 [199:0];

    // Processus de lecture/ecriture
    always @(posedge clk_write) begin
        if (write_enable) begin
		if(address_in[8] == 0) begin
      mem1[address_in[7:0]] <= data_in; // ecrire dans la memoire
		end
		else if(address_in[8] == 1) begin
			mem2[address_in[7:0]] <= data_in;
		end
        end
    end

    always @(posedge clk_read) begin
	if (read_enable) begin
		if(address_out[8] == 0) begin
      data_out <= mem1[address_out[7:0]]; // Lire de la memoire
		end
		else if(address_out[8] == 1) begin
      data_out <= mem2[address_out[7:0]]; // Lire de la memoire
		end

        end
    end
endmodule
