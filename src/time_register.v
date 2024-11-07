module time_register(input clk, reset, input [31:0] event_time, output reg [31:0] event_time_out );

  always @(posedge clk or posedge reset) begin
	if(reset == 1) begin
		event_time_out <= 32'b0;
	end
	else begin
		event_time_out <= event_time;
	end
  end 

endmodule 
