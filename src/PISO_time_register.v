/*
clk : clock for shif and load operations
parallel_in : output of the MUX, data to be send
SL : '1' => load, '0' => shift
serial_out : data serialization
*/

module PISO_time_register(
  input wire clk, reset,
  input wire [31:0] parallel_in,
  input wire SL, 
  output reg serial_out
  
);
  
reg [30:0] register;
	
always @(posedge clk or posedge reset) begin

    if(reset == 1) begin
	serial_out <= 0;
	register <= 31'b0;
    end
    else begin 
    	if(SL==1) begin
	
	    register[30:0] <= parallel_in[31:1]; // Load 
	    serial_out <= parallel_in[0];  // Output the least significant bit
	       
    	end
    	else if (SL==0) begin
	
	serial_out <= register[0]; // Output the least significant bit
        register <= register >>> 1; //shift
	
    	end
    end
end

endmodule
