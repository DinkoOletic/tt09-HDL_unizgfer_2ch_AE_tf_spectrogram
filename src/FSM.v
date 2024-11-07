module FSM(
	input clk, reset, bank0_full, bank1_full, memorization_completed, 
	input [7:0] idx_final, 
	output [8:0] addr_out, 
	output reg SL_ch, SL_time, selection_bit, re, serial_readout, sending_data,
	output reg [2:0] state_reg
	);


  
  reg [7:0] idx, reg_idx_final;
  reg [2:0] state_next;
  reg [4:0] cpt;
  reg signal_duration, sending_pending, read_bank, sending_started;
  localparam [2:0]
  s0 = 0,
  s1 = 1,
  s2 = 2,
  s3 = 3,
  s4 = 4,
  s5 = 5,
  s6 = 6,
  s7 = 7;	

  //reg signal_duration; //0 => short signal (<200 us), 1 => long signal (>200us)
  //reg[2:0] state_reg, state_next;
  //reg sending_pending, sending_started;

  
  assign addr_out[7:0] = idx[7:0];
  assign addr_out[8] = read_bank;


// change state process
always @(posedge clk or posedge reset) begin
	if (reset) begin
		state_reg <= s0;
      	end 
	else begin        
      state_reg <=  state_next; 
    end
end


// sequential outputs of the state machine
// idx => counter for read address in memory
// re => read_enable
// cpt => counter for number of bits sent
// sending_data => '1' when bits are sent (RTC or memory)
always @(posedge clk or posedge reset) begin
	if(reset) begin
		re <= 0;
		cpt <= 0;
		idx <= 0;
		sending_data <= 0;
		 read_bank <= 0;
	end
	else begin
	case (state_reg)
		s0 : begin //wait for a emission
			re <= 0;
			cpt <= 0;
			idx <= 0;
			sending_data <= 0;
		end
		s1 : begin //load of RTC
			
			cpt <= 0;
			idx <= 0;
			sending_data <= 1;
		end
		s2 : begin //shift of RTC
			idx <= 0;
			cpt <= cpt + 1;//counter increment
			
			if(cpt == 5'b11101) begin //all bits of RTC have been sent => enable reading of memories
				re <= 1; 
			end
			
		end
		s3 : begin //load of memory data (in case of reading full memory)
			cpt <= 0;
			sending_data <= 1;
			
			idx <= idx + 1; //reading address increment
			if(idx == 199 && cpt == 2) begin // if the memory has been completely read => disable reading
				re <= 0;
			end
			else begin
				re <= 1;
			end
			
		end	
		s4 : begin //shift of memory data (in case of reading full memory)
			cpt <= cpt + 1; //counter increment
			
			if(idx == 200 && cpt == 1) begin //reset of idx counter when memory has been completely read 
				idx <= 0;
			end
			
			if(state_next == s5) begin
				read_bank <= ~read_bank;
			end
			
			// if memory has been completely read => disable reading
			if((idx==200 && sending_pending == 1 && cpt == 0) || (idx==200 && sending_pending == 0)) begin
				re <= 0;
			end
			else begin
				re <= 1;
			end
			
		end
		s5 : begin //waiting for sending next bank
			cpt <= 0;
			idx <= 0;
			sending_data <= 0;
			
			//memorization ended => enable reading
			if(bank0_full == 1 || bank1_full == 1 || sending_pending) begin
				re <= 1;
			end
			else begin
				re <= 0;
			end
			
		end 
		s6 : begin //load of memory data (in case of reading part of memory)
			cpt <= 0;
			idx <= idx + 1; //reading address increment
			sending_data <= 1;
		end
		s7 : begin//shift of memory data (in case of reading part of memory)
			cpt <= cpt + 1; //counter increment
			
			if(state_next == s0) begin
				read_bank <= ~read_bank;
			end
			
			//reset idx counter when the reading address reaches the final address
			if(idx == reg_idx_final  && cpt == 2) begin
				idx <= 0;
				sending_data <= 0;
				
			end
			
			if(idx == reg_idx_final) begin //when reaching final address => disable reading
				re <= 0;
			end
			
		end
		 endcase
	end                                                                              
end


// asynchronous process, when a memorization end => register final address
always @(posedge memorization_completed or posedge reset) begin

	if(reset) begin   
		reg_idx_final <= 0; 
	end
	else begin
		reg_idx_final <= idx_final;						
	end                                                                   
end
 
// sequential outputs which do not depend on the state
// signal_duration => when '1', a bank has been completely filled (AE last longer than 200 us)
// sending_pending => '1' when the acquisition ended but readout is still in progress 
always @(posedge clk or posedge reset) begin

	if(reset) begin
		signal_duration <= 0; 
      sending_pending <= 0;  
	end
	else begin
		if(sending_started) begin
			sending_pending <= 0;
		end
		else if(memorization_completed) begin
			sending_pending <= 1; 
			signal_duration <= 0; //short signal
		end
		else if(bank0_full || bank1_full) begin
			signal_duration <= 1; //long signal	
		end
	end                                                                   
end
/*
//asynchonous process for changing bank, when a sending starts => changing the bank to read into
always @(posedge sending_started or posedge reset) begin
	if(reset) begin
      read_bank <= 1;  
	end
	else begin
		read_bank <= ~read_bank;
	end
end
*/

//combinatory outputs of the state machine
//sending_started => pulse when we start to read memory 
//serial_readout => '1' when datas of an AE are sent
always @(*) begin 

	//Default
   state_next = state_reg;
	SL_ch = 0;
	SL_time = 0;
	selection_bit = 0;
	serial_readout = 0;
	sending_started = 0;

        case (state_reg)
            s0 : begin
					SL_ch = 0;
					SL_time = 0;
					selection_bit = 0;
					serial_readout = 0;
					sending_started = 0;

					//a acquisition ended => start sate machine
					if (sending_pending == 1 || bank0_full== 1 || bank1_full== 1) begin 
                    	state_next = s1;
					end
					else begin
                    	state_next = s0;
					end	
					
				end
				
            s1: begin//load of RTC

					SL_ch = 0;
					SL_time = 1;
					serial_readout = 0;
					selection_bit = 0;
					sending_started = 0;
					state_next = s2;

				end	  
				
            s2: begin //shift of RTC

					serial_readout = 1;
					SL_ch = 0;
					SL_time = 0;
					selection_bit = 0;
					
					//when all the bits of RTC have been sent => sending of memory
					if (cpt == 5'b11110) begin    
						sending_started = 1;
						if(signal_duration) begin	
							state_next = s3; //full memory must be read
						end
						else begin
							state_next = s6; //part of memory must be read
						end
					end
					else begin
						sending_started = 0;
                  state_next = s2;
					end
				end
            s3: begin //load of memory data (in case of reading full memory)

					selection_bit = 1;
					serial_readout = 1;
					SL_ch = 1;
					SL_time = 0;
					sending_started = 0;
               state_next = s4;

				end
				
            s4: begin//shift of channel memory (in case of reading full memory)

					selection_bit = 1;
					serial_readout = 1;
					SL_ch = 0;
					SL_time = 0;
					sending_started = 0;
	
					if (idx == 200 && cpt == 1) begin //all memory has been read => wait for next sending     
						state_next = s5;
					end
					else if (cpt == 1) begin 
						state_next = s3;
					end
					else begin
						state_next = s4;
					end
				end

            s5: begin//waiting for sending next bank
				
					selection_bit = 1;
					SL_ch = 0;
					SL_time = 0;
					serial_readout = 1;
		

					if (sending_pending == 1) begin //part of a bank must be sent  
						sending_started = 1;
						if(re == 1) begin //check that reading has been enable
							state_next = s6;	
						end
						else begin 
							state_next = s5;
						end
					end
					else if(bank0_full == 1 || bank1_full == 1) begin //full bank must be sent 
						
						if(re == 1) begin //check that reading has been enable
							sending_started = 1;
							state_next = s3;
						end
						else begin
							sending_started = 0;
							state_next = s5;
						end
				
					end
					else begin
						sending_started = 0;
						state_next = s5;
					end
				end

            s6: begin //load of channel memory (in case of reading part of memory)

					selection_bit = 1;
					SL_ch = 1;
					SL_time = 0;
					serial_readout = 1;
					sending_started = 0;
               state_next = s7;

				end

				s7: begin//shift of channel memory (in case of reading part of memory)

					selection_bit = 1;
					serial_readout = 1;
					SL_ch = 0;
					SL_time = 0;
					sending_started = 0;

					//all the datas of an AE have been sent => return to state S0
					if (idx == reg_idx_final && cpt == 2) begin 
						state_next = s0;
					end
					else if (idx != reg_idx_final && cpt == 1) begin
						state_next = s6;
					end
					else begin
						state_next = s7;
					end
				end    
        endcase
 
end


endmodule

