module encoder( input wire [6:0] channel,
           output reg [2:0] channel_decode
           );

	always @(*) begin

			if(channel[6] == 1) begin
				channel_decode = 3'b111;
			end
			else if(channel[5] == 1) begin
				channel_decode = 3'b110;
			end
			else if(channel[4] == 1) begin
				channel_decode = 3'b101;
			end
			else if(channel[3] == 1) begin
				channel_decode = 3'b100;
			end
			else if(channel[2] == 1) begin
				channel_decode = 3'b011;
			end
			else if(channel[1] == 1) begin
				channel_decode = 3'b010;
			end
			else if(channel[0] == 1) begin
				channel_decode = 3'b001;
			end
			else begin
				channel_decode = 3'b0;
			end
				
	end

endmodule
