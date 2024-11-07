module RTC(input clk, input reset, output reg [5:0] sec, output reg [9:0] millisec,
               output reg [5:0] min, output reg [4:0] hour, output reg [4:0] day);



//-- Sensitive to rising edge
  always @(posedge clk or posedge reset) begin
  //-- Incrementar el registro
    if(reset == 1) begin
  	millisec <= 10'b0;
  	sec <= 6'b0;
  	min <= 6'b0;
  	hour <= 5'b0;
  	day <= 5'b0;
    end
    else begin

    	millisec <= millisec + 1;
    	if(millisec == 999) begin
    		millisec <= 0;
      		sec <= sec + 1;
    	end
    	if(sec == 59 && millisec == 999) begin
		millisec <= 0;
    		sec <= 0;
      		min <= min + 1;
    	end
    	if(sec == 59 & min == 59 && millisec == 999) begin
		millisec <= 0;
      		sec <= 6'b0;
  		min <= 6'b0;
		hour <= hour + 1;
    	end
    	if(hour == 23 && sec == 59 & min == 59 && millisec == 999) begin
		millisec <= 0;
      		sec <= 6'b0;
  		min <= 6'b0;
		hour <= 5'b0;	
		day <= day + 1;
    	end
    	if(day == 30 && hour == 23 && sec == 59 & min == 59 && millisec == 999) begin
		millisec <= 0;
      		sec <= 6'b0;
  		min <= 6'b0;
		hour <= 5'b0;	
		day <= 0;
    	end
	
     end
  end
  
  
endmodule
