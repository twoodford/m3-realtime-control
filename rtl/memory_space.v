`timescale 1ns / 1ps
//memory space
//needs 3 consecutive UART writes before writing is actually triggered

//1st UART WRITE:[1bit regspace/BRAM select, 3bit BRAM select, 4bit address MSB]
//2nd UART WRITE:[3bit address LSB, 5bit data MSB]
//3rd UART WRITE:[7bit data LSB, 1bit unused]
module memory_space
  (
   input 	     clk,
   input 	     reset,
   input 	     uart_rx_wr_en,
   input [7:0] 	     uart_rx_data,


   input [6:0] 	     seq_addr_1, //all memory has shared address at 2nd port
   input [6:0] 	     seq_addr_2,
   input [6:0] 	     seq_addr_3,
   input [6:0] 	     seq_addr_4,
   input [6:0] 	     seq_addr_5,
   input [6:0] 	     seq_addr_6,
   input [6:0] 	     seq_addr_7,
   input [6:0] 	     seq_addr_8,
   
   output reg [11:0] memout_1,
   output reg [11:0] memout_2,
   output reg [11:0] memout_3,
   output reg [11:0] memout_4,
   output reg [11:0] memout_5,
   output reg [11:0] memout_6,
   output reg [11:0] memout_7,
   output reg [11:0] memout_8,

   //register space

   output reg [15:0] reg_end_seq_addr = 12'd0,
   output reg [15:0] reg_time_gap_1 = 12'd10,
   output reg [15:0] reg_time_gap_2 = 12'd10,
   output reg [15:0] reg_time_gap_3 = 12'd10,
   output reg [15:0] reg_time_gap_4 = 12'd10,
   output reg [15:0] reg_time_gap_5 = 12'd10,
   output reg [15:0] reg_time_gap_6 = 12'd10,
   output reg [15:0] reg_time_gap_7 = 12'd10,
   output reg [15:0] reg_time_gap_8 = 12'd10
   

  );

reg [11:0] 	 memarray_1[0:127];
reg [11:0] 	 memarray_2[0:127];
reg [11:0] 	 memarray_3[0:127];
reg [11:0] 	 memarray_4[0:127];
reg [11:0] 	 memarray_5[0:127];
reg [11:0] 	 memarray_6[0:127];
reg [11:0] 	 memarray_7[0:127];
reg [11:0] 	 memarray_8[0:127];

reg [1:0] 	 uart_rx_cnt = 2'b00;
  
reg 		 wr_data = 1'b0;
  
//reg 		     reg_space_sel = 1'b0;
//reg [2:0] 	 mem_sel = 3'd0;
//reg [6:0] 	 addr = 7'd0;
//reg [11:0]  data = 12'd0;
reg 		     uart_rx_wr_en_d = 1'b0;
reg [7:0]       input_bytes[0:3];

// For BRAM:
//1+3+7+12 = 23
//1st UART WRITE:[1bit regspace/BRAM select, 3bit BRAM select, 4bit address MSB]
//2nd UART WRITE:[3bit address LSB, 5bit data MSB]
//3rd UART WRITE:[7bit data LSB, 1bit unused]
// For registers:
// 1+3+4+16 = 24
//1st UART WRITE:[1bit regspace/BRAM select, 3bit BRAM select(unused), 4bit address MSB]
//2nd UART WRITE:[8bit data MSB]
//3rd UART WRITE:[8bit data LSB]
always@(posedge clk)
  wr_data <= &uart_rx_cnt;
  
// Write counter FSM - tracks what part of the UART write we're receiving
always@(posedge clk or posedge reset)
  if(reset)
    uart_rx_cnt <= 2'b00;	
  else if(&uart_rx_cnt)
    uart_rx_cnt <= 2'b00;	
  else if(uart_rx_wr_en)
    uart_rx_cnt <= uart_rx_cnt + 1'b1;

always@(posedge clk)
  uart_rx_wr_en_d <= uart_rx_wr_en;
  

// Input data processing - puts UART data into appropriate registers
always@(posedge clk)
    if(uart_rx_wr_en_d)
        input_bytes[uart_rx_cnt] <= uart_rx_data;

wire [2:0]  mem_sel;
assign mem_sel = input_bytes[1][6:4];
wire        reg_space_sel;
assign reg_space_sel = input_bytes[1][7];
wire [6:0]  addr_bram;
assign addr_bram = {input_bytes[1][3:0], input_bytes[2][7:5]};
wire [11:0] data_bram;
assign data_bram = {input_bytes[2][4:0], input_bytes[3][7:1]};
wire [4:0]  addr_reg;
assign addr_reg = input_bytes[1][3:0];
wire [15:0] data_reg;
assign data_reg = {input_bytes[2], input_bytes[3]};
  
// memupdate - move UART input registers to block RAM or register space
always@(posedge clk) begin
  if(wr_data) begin
	 case({reg_space_sel,mem_sel})
	   4'b0000:begin memarray_1[addr_bram] <= data_bram; end
	   4'b0001:begin memarray_2[addr_bram] <= data_bram; end 
	   4'b0010:begin memarray_3[addr_bram] <= data_bram; end
	   4'b0011:begin memarray_4[addr_bram] <= data_bram; end
	   4'b0100:begin memarray_5[addr_bram] <= data_bram; end	 
	   4'b0101:begin memarray_6[addr_bram] <= data_bram; end	   
	   4'b0110:begin memarray_7[addr_bram] <= data_bram; end	   
	   4'b0111:begin memarray_8[addr_bram] <= data_bram; end

	   //register space
	   default:begin   
	      case(addr_reg)
          7'd0: reg_end_seq_addr <= data_reg;
          7'd1: reg_time_gap_1     <= data_reg; //must be greater than 5 with current clock settings
          7'd2: reg_time_gap_2     <= data_reg;
          7'd3: reg_time_gap_3     <= data_reg;
          7'd4: reg_time_gap_4     <= data_reg;
          7'd5: reg_time_gap_5     <= data_reg;
          7'd6: reg_time_gap_6     <= data_reg;
          7'd7: reg_time_gap_7     <= data_reg;
          7'd8: reg_time_gap_8     <= data_reg;
          default: begin end
	      endcase // case (mem_addr)
	   end
	   
    endcase // case ({reg_space_sel,mem_sel})
  end // if (wr_data)

  memout_1 <= memarray_1[seq_addr_1]; 
  memout_2 <= memarray_2[seq_addr_2]; 
  memout_3 <= memarray_3[seq_addr_3]; 
  memout_4 <= memarray_4[seq_addr_4]; 
  memout_5 <= memarray_5[seq_addr_5]; 
  memout_6 <= memarray_6[seq_addr_6]; 
  memout_7 <= memarray_7[seq_addr_7]; 
  memout_8 <= memarray_8[seq_addr_8]; 
end // always@ (posedge clk) - memupdate

endmodule // memory_space
