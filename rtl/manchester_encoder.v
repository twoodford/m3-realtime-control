`timescale 1ns / 1ps


module manchester_encoder #(parameter SEQ_LENGTH = 8)
   (
    input 		   clk2x,
    input 		   wrn, //must be 1 clock cycle pulse
    input [SEQ_LENGTH-1:0] din,

    output reg dout_on = 1'b0,
    //output 		   dout_on,
    output reg 		   dout

     );
   function integer clogb2;
      input [31:0] 	   value;
      reg [31:0] 	   value2; 
      begin
         value2 = value - 1;
         for (clogb2 = 0; value2 > 0; clogb2 = clogb2 + 1) begin
            value2 = value2 >> 1;
         end
      end
   endfunction
   parameter BITS = clogb2(SEQ_LENGTH);
   

   wire dout_int;
   
   
   reg 			   clk1x = 1'b0;
   reg 			   clk1x_enable = 1'b0; 
   //reg clk1x_enable_d = 1'b0;
   
   reg [BITS:0] 	   num_bits_sent = 'd0;

   reg [SEQ_LENGTH-1:0]    tbr = 'd0;
   reg [1:0] 		   wrn_d = 2'd0;

   wire 		   wrn_r;
   
   
   //Create div2 clock
   always@(posedge clk2x) begin
      if(clk1x_enable)
	clk1x <= ~clk1x;
      else
	clk1x <= 1'b1;
   end

   
   //Pulse Detect
   always@(posedge clk2x)begin
      wrn_d <= {wrn_d[0],wrn};
   end

   assign wrn_r = wrn_d[0] & ~wrn_d[1];
   

   //clk1x_enable logic
   always@(posedge clk2x)begin
      if (~clk1x && num_bits_sent == SEQ_LENGTH)
	clk1x_enable <= 1'b0;
      else if(wrn_r)
	clk1x_enable <= 1'b1;
   end

   //Latch + shifr register 
   always@(posedge clk2x)
     if(~clk1x && clk1x_enable)
       tbr <= {tbr[SEQ_LENGTH-2:0],1'b0};
     else if (wrn_r)
       tbr <= din;
   

   //Number of bits sent
   always@(posedge clk2x)begin
      if(~clk1x && num_bits_sent == SEQ_LENGTH)
	num_bits_sent <= 'd0;
      else if(~clk1x && clk1x_enable)
	num_bits_sent <= num_bits_sent + 1'b1;
      else if(wrn_r)
	num_bits_sent <= 1'b1;
   end
    

   // Generate Manchester data from NRZ
   
   assign dout_int =  clk1x_enable ? ~(tbr[SEQ_LENGTH-1'b1] ^ clk1x) : 1'b0;

   
   always@(posedge clk2x)begin
      dout <= dout_int;
      //clk1x_enable_d <= clk1x_enable;
      dout_on <= clk1x_enable;
   end

   //To accomadate trigger, trisate buffer is turned on 1 clock cycle earlier 
   //assign dout_on =  clk1x_enable_d | clk1x_enable;
   
   
endmodule


















