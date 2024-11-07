module mux_2to1(input wire PISO_time, PISO_ch1,
                input wire select,
           output reg data_out
          );


  always @(*) begin
  data_out = 0;
    casez (select)  
      0 : data_out = PISO_time; 
      1 : data_out = PISO_ch1; 

     endcase  
   end  
  
endmodule 
