module memory_controller(
    input clk, reset, signal_detected,               
    output reg [7:0] idx_final,
	 output  [8:0] addr_in,
	 output reg [1:0] state_reg,
    output reg we, bank0_full, bank1_full, memorization_completed   
);


  localparam [1:0]
  s0 = 0,
  s1 = 1,
  s2 = 2;

  reg [1:0]  state_next;
  reg [7:0] idx;
  reg bank;
  assign addr_in[7:0] = idx[7:0];
  assign addr_in[8] = bank;

  // changing state process
always @(posedge clk or posedge reset) begin
	if (reset) begin
		state_reg <= s0;
   end 
	else begin        
        state_reg <=  state_next; 
    end
end

// synchronous outputs
always @(posedge clk or posedge reset) begin
		if(reset) begin
			idx <= 0;
			bank <= 0;
			bank0_full <= 0;
			bank1_full <= 0;
			idx_final <= 0;
			
		end
		else begin
      	if (state_reg == s0) begin 
       		idx <= 0;
				bank0_full <= 0;
				bank1_full <= 0;
      	end  
			else if (state_reg == s2) begin 
       		idx <= 0;
				bank0_full <= 0;
				bank1_full <= 0;
				bank <= ~bank; //changing bank
      	end 
			else if(state_reg == s1 && idx == 199) begin //bank full
				idx <= 0;
				bank <= ~bank; //changing bank
				if(bank == 0) begin
					bank0_full <= 1;
				end
				else begin //bank == 1
					bank1_full <= 1;
				end
			end
			else begin //state_reg == s1 && idx != 199
				idx <= idx + 1;
				if(!signal_detected) begin //if no more signal => register idx_final
					idx_final <= idx;
				end
				bank0_full <= 0;
				bank1_full <= 0;
      	end     
		end
end

// combinatory outputs 			
always @(state_reg, signal_detected, idx, bank) begin
	
	//default state_next
	state_next = state_reg;
	//default outputs
	we = 0;
	memorization_completed = 0;
	

        case (state_reg)

            s0 : begin	
		we = 0;
		memorization_completed = 0;   

		if(signal_detected ) begin
				state_next  = s1;
		end
			
		end	

            s1: begin

		we = 1;
		memorization_completed = 0;
		
		
		
		if(!signal_detected) begin //no more signal => stop memorization
			state_next = s2;
		end
		else begin
			state_next = s1;
		end

	     end	                    


            s2: begin 
		memorization_completed = 1;
		we = 0;
		state_next = s0;
	
	     end


        endcase
   
end

endmodule 
