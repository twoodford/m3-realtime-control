`timescale 1ns / 1ps

module CmodA7_ctrl_top
  (
   
   input 	GCLK,
   input 	BTN0,
   input 	BTN1,
   input    usrp_trigger,

   //LEDS
   output [1:0] LED,
   output 	LED0_B,
   output 	LED0_G,
   output 	LED0_R,

   //UART
   input 	UART_TXD_IN,
   output 	UART_RXD_OUT,

   //GPIO
   output 	PIO1,
   output 	PIO2,
   output 	PIO3,
   output 	PIO4,
   output 	PIO5,
   output 	PIO6,
   output 	PIO7,
   output 	PIO8,
   output 	clk_out,
   
   // Connect to ground
   output gnd_pins_1,
   output gnd_pins_2,
   output gnd_pins_3,
   output gnd_pins_4,
   output gnd_pins_5,
   output gnd_pins_6,
   output gnd_pins_7,
   output gnd_pins_8
   );

assign gnd_pins = 8'd0;

localparam SEQ_LENGTH = 58;//Manchester Encoder seq length
   
wire 	sys_clkg;
wire 	uart_clkg;

wire 	reset;
wire 	locked;

wire 	btn0;
wire 	btn1;
wire 	btn0_int;
wire 	btn1_int;

wire 	test_seq;
   
reg [SEQ_LENGTH-1:0] din_1;
reg [SEQ_LENGTH-1:0] din_2;
reg [SEQ_LENGTH-1:0] din_3;
reg [SEQ_LENGTH-1:0] din_4;
reg [SEQ_LENGTH-1:0] din_5;
reg [SEQ_LENGTH-1:0] din_6;
reg [SEQ_LENGTH-1:0] din_7;
reg [SEQ_LENGTH-1:0] din_8;
   
wire 		dout_1;
wire 		dout_2;
wire 		dout_3;
wire 		dout_4;
wire 		dout_5;
wire 		dout_6;
wire 		dout_7;
wire 		dout_8;

wire 		dout_on_1;
wire 		dout_on_2;
wire 		dout_on_3;
wire 		dout_on_4;
wire 		dout_on_5;
wire 		dout_on_6;
wire 		dout_on_7;
wire 		dout_on_8;

wire [11:0] 		memout_1;
wire [11:0] 		memout_2;
wire [11:0] 		memout_3;
wire [11:0] 		memout_4;
wire [11:0] 		memout_5;
wire [11:0] 		memout_6;
wire [11:0] 		memout_7;
wire [11:0] 		memout_8;

 


//register space
wire [6:0] 		   reg_end_seq_addr;
wire [15:0] 		reg_time_gap_1;
wire [15:0] 		reg_time_gap_2;
wire [15:0] 		reg_time_gap_3;
wire [15:0] 		reg_time_gap_4;
wire [15:0] 		reg_time_gap_5;
wire [15:0] 		reg_time_gap_6;
wire [15:0] 		reg_time_gap_7;
wire [15:0] 		reg_time_gap_8;


IBUF i_IBUF_BTN0(.I (BTN0),.O (btn0));
IBUF i_IBUF_BTN1(.I (BTN1),.O (btn1));
IBUF i_IBUF_UART_TXD_IN(.I (UART_TXD_IN),.O (uart_txd));

OBUFT i_OBUF_UART_RXD_OUT(.I (1'b0),.O (UART_RXD_OUT));
OBUFT i_OBUFT_PIO1(.I(dout_1),.O(PIO1),.T(~dout_on_1));
OBUFT i_OBUFT_PIO2(.I(dout_2),.O(PIO2),.T(~dout_on_2));
OBUFT i_OBUFT_PIO3(.I(dout_3),.O(PIO3),.T(~dout_on_3));
OBUFT i_OBUFT_PIO4(.I(dout_4),.O(PIO4),.T(~dout_on_4));
OBUFT i_OBUFT_PIO5(.I(dout_5),.O(PIO5),.T(~dout_on_5));
OBUFT i_OBUFT_PIO6(.I(dout_6),.O(PIO6),.T(~dout_on_6));
OBUFT i_OBUFT_PIO7(.I(dout_7),.O(PIO7),.T(~dout_on_7));
OBUFT i_OBUFT_PIO8(.I(dout_8),.O(PIO8),.T(~dout_on_8));

OBUF i_OBUF_LED0(.I(1'b1),.O(LED[0]));
OBUF i_OBUF_LED1(.I(1'b1),.O(LED[1]));
OBUF i_OBUF_LED0_B(.I(1'b1),.O(LED0_B));
OBUF i_OBUF_LED0_R(.I(1'b1),.O(LED0_R));
OBUF i_OBUF_LED0_G(.I(1'b1),.O(LED0_G));

OBUF i_OBUF_GND_1(.I(1'b0),.O(gnd_pins_1));
OBUF i_OBUF_GND_2(.I(1'b0),.O(gnd_pins_2));
OBUF i_OBUF_GND_3(.I(1'b0),.O(gnd_pins_3));
OBUF i_OBUF_GND_4(.I(1'b0),.O(gnd_pins_4));
OBUF i_OBUF_GND_5(.I(1'b0),.O(gnd_pins_5));
OBUF i_OBUF_GND_6(.I(1'b0),.O(gnd_pins_6));
OBUF i_OBUF_GND_7(.I(1'b0),.O(gnd_pins_7));
OBUF i_OBUF_GND_8(.I(1'b0),.O(gnd_pins_8));

reg 			debug_clkg = 1'b0;

assign clk_out = debug_clkg;

always@(posedge uart_clkg)
   debug_clkg <= ~debug_clkg;

debounce_switch #(.WIDTH(2),.N(4),.RATE(2)) debounce_switch_inst 
   (
   .clk(uart_clkg),
   .rst(1'b0),
   .in({btn0,btn1}),
   .out({btn0_int,btn1_int})
   );
assign reset = btn0_int;
assign test_seq = btn1_int || usrp_trigger;

clk_gen u_clk_gen
   (
   .sys_clkg(sys_clkg),    
   .uart_clkg(uart_clkg),     
   // Status and control signals
   .reset(reset), 
   .locked(locked),       
   // Clock in ports
   .gclk(GCLK));    

wire 		uart_rx_wr_en;
wire [7:0] 		uart_rx_data;

//CLKS_PER_BIT =  uart_clkg/baud_rate
uart_rx #(.CLKS_PER_BIT(104)) u_uart_rx
   (/**/
   // Outputs
   .o_RX_DV				(uart_rx_wr_en),
   .o_RX_Byte			(uart_rx_data[7:0]),
   // Inputs
   .i_Clock				(uart_clkg), //12MHz
   .i_RX_Serial			(uart_txd));

reg [15:0] 	crcarray [0:4095];

initial begin
   $readmemh("crc.mem",crcarray);
end

wire [22:0] pre_1;
wire [5:0]  pre_2;
assign pre_1 = {{7{1'b0}},{3{1'b1}},{3{1'b0}},1'b1,1'b0,{3{1'b1}},1'b0,1'b1,{2{1'b0}},1'b1};
assign pre_2 = {1'b0,1'b1,{4{1'b0}}};

//command = {pre_1[22:0],tx[1:0]/rx[1:0],pre_2[5:0],sector[6:0],gain[3:0]}

//THINGS TO DO:
//Finish creating memory space (logic and physical memory)
//state machine for sequencing through memory address and manchester output

//memout has 1 clock delay from seq_addr
//need to use memout to get data from crc ram
//memout bit 11 = tx/rx 1 for tx, 0 for rx
//memout bit 10:4 = sector
//memout bit 3:0 = gain
//sector and gain must output LSB first
wire [3:0]  gain_1,gain_2,gain_3,gain_4,gain_5,gain_6,gain_7,gain_8;
wire [6:0]  sector_1,sector_2,sector_3,sector_4,sector_5,sector_6,sector_7,sector_8;

assign gain_1 = {memout_1[0],memout_1[1],memout_1[2],memout_1[3]};
assign gain_2 = {memout_2[0],memout_2[1],memout_2[2],memout_2[3]};
assign gain_3 = {memout_3[0],memout_3[1],memout_3[2],memout_3[3]};
assign gain_4 = {memout_4[0],memout_4[1],memout_4[2],memout_4[3]};
assign gain_5 = {memout_5[0],memout_5[1],memout_5[2],memout_5[3]};
assign gain_6 = {memout_6[0],memout_6[1],memout_6[2],memout_6[3]};
assign gain_7 = {memout_7[0],memout_7[1],memout_7[2],memout_7[3]};
assign gain_8 = {memout_8[0],memout_8[1],memout_8[2],memout_8[3]};

assign sector_1 = {memout_1[4],memout_1[5],memout_1[6],memout_1[7],memout_1[8],memout_1[9],memout_1[10]};
assign sector_2 = {memout_2[4],memout_2[5],memout_2[6],memout_2[7],memout_2[8],memout_2[9],memout_2[10]};
assign sector_3 = {memout_3[4],memout_3[5],memout_3[6],memout_3[7],memout_3[8],memout_3[9],memout_3[10]};
assign sector_4 = {memout_4[4],memout_4[5],memout_4[6],memout_4[7],memout_4[8],memout_4[9],memout_4[10]};
assign sector_5 = {memout_5[4],memout_5[5],memout_5[6],memout_5[7],memout_5[8],memout_5[9],memout_5[10]};
assign sector_6 = {memout_6[4],memout_6[5],memout_6[6],memout_6[7],memout_6[8],memout_6[9],memout_6[10]};
assign sector_7 = {memout_7[4],memout_7[5],memout_7[6],memout_7[7],memout_7[8],memout_7[9],memout_7[10]};
assign sector_8 = {memout_8[4],memout_8[5],memout_8[6],memout_8[7],memout_8[8],memout_8[9],memout_8[10]};

//need to work on the seq_addr logic and the start of mancheter encoder
//need to align din values with trig_1 of manchester encoder
always@(posedge uart_clkg)begin
   din_1 <= {pre_1,~memout_1[11],memout_1[11],pre_2,sector_1[6:0],gain_1[3:0],crcarray[memout_1]}; //figure out timing here
   din_2 <= {pre_1,~memout_2[11],memout_2[11],pre_2,sector_2[6:0],gain_2[3:0],crcarray[memout_2]}; //figure out timing here
   din_3 <= {pre_1,~memout_3[11],memout_3[11],pre_2,sector_3[6:0],gain_3[3:0],crcarray[memout_3]}; //figure out timing here
   din_4 <= {pre_1,~memout_4[11],memout_4[11],pre_2,sector_4[6:0],gain_4[3:0],crcarray[memout_4]}; //figure out timing here
   din_5 <= {pre_1,~memout_5[11],memout_5[11],pre_2,sector_5[6:0],gain_5[3:0],crcarray[memout_5]}; //figure out timing here
   din_6 <= {pre_1,~memout_6[11],memout_6[11],pre_2,sector_6[6:0],gain_6[3:0],crcarray[memout_6]}; //figure out timing here
   din_7 <= {pre_1,~memout_7[11],memout_7[11],pre_2,sector_7[6:0],gain_7[3:0],crcarray[memout_7]}; //figure out timing here
   din_8 <= {pre_1,~memout_8[11],memout_8[11],pre_2,sector_8[6:0],gain_8[3:0],crcarray[memout_8]}; //figure out timing here
end

wire trig_1, trig_2, trig_3, trig_4, trig_5, trig_6, trig_7, trig_8;
wire [6:0] seq_addr_1, seq_addr_2, seq_addr_3, seq_addr_4, seq_addr_5, seq_addr_6, seq_addr_7, seq_addr_8;

sequence_ctr u_seq_ctr_1
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_1),
   .seq_addr         (seq_addr_1),
   .manchester_wren  (trig_1)
);

sequence_ctr u_seq_ctr_2
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_2),
   .seq_addr         (seq_addr_2),
   .manchester_wren  (trig_2)
);

sequence_ctr u_seq_ctr_3
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_3),
   .seq_addr         (seq_addr_3),
   .manchester_wren  (trig_3)
);
      
sequence_ctr u_seq_ctr_4
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_4),
   .seq_addr         (seq_addr_4),
   .manchester_wren  (trig_4)
);

sequence_ctr u_seq_ctr_5
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_5),
   .seq_addr         (seq_addr_5),
   .manchester_wren  (trig_5)
);
 
sequence_ctr u_seq_ctr_6
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_6),
   .seq_addr         (seq_addr_6),
   .manchester_wren  (trig_6)
);
  
sequence_ctr u_seq_ctr_7
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_7),
   .seq_addr         (seq_addr_7),
   .manchester_wren  (trig_7)
);
  
sequence_ctr u_seq_ctr_8
(
   .ctr_en           (test_seq),
   .clk              (uart_clkg),
   .seq_end_addr     (reg_end_seq_addr),
   .time_gap         (reg_time_gap_8),
   .seq_addr         (seq_addr_8),
   .manchester_wren  (trig_8)
);
 
memory_space u_memory_space
(
   // Outputs
   .memout_1			(memout_1[11:0]),
   .memout_2			(memout_2[11:0]),
   .memout_3			(memout_3[11:0]),
   .memout_4			(memout_4[11:0]),
   .memout_5			(memout_5[11:0]),
   .memout_6			(memout_6[11:0]),
   .memout_7			(memout_7[11:0]),
   .memout_8			(memout_8[11:0]),
   .reg_time_gap_1      (reg_time_gap_1[15:0]),
   .reg_time_gap_2      (reg_time_gap_2[15:0]),
   .reg_time_gap_3      (reg_time_gap_3[15:0]),
   .reg_time_gap_4      (reg_time_gap_4[15:0]),
   .reg_time_gap_5      (reg_time_gap_5[15:0]),
   .reg_time_gap_6      (reg_time_gap_6[15:0]),
   .reg_time_gap_7      (reg_time_gap_7[15:0]),
   .reg_time_gap_8      (reg_time_gap_8[15:0]),
   .reg_end_seq_addr    (reg_end_seq_addr[6:0]),
   // Inputs
   .clk				    (uart_clkg),
   .reset				(reset),
   .uart_rx_wr_en	    (uart_rx_wr_en),
   .uart_rx_data	    (uart_rx_data[7:0]),
   .seq_addr_1  		(seq_addr_1[6:0]),
   .seq_addr_2  		(seq_addr_2[6:0]),
   .seq_addr_3  		(seq_addr_3[6:0]),
   .seq_addr_4  		(seq_addr_4[6:0]),
   .seq_addr_5  		(seq_addr_5[6:0]),
   .seq_addr_6  		(seq_addr_6[6:0]),
   .seq_addr_7  		(seq_addr_7[6:0]),
   .seq_addr_8  		(seq_addr_8[6:0])
);



manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_1
   (/**/
   // Outputs
   .dout_on       (dout_on_1),
   .dout				(dout_1),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_1),
   .din				(din_1[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_2
   (/**/
   // Outputs
   .dout_on       (dout_on_2),
   .dout				(dout_2),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_2),
   .din				(din_2[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_3
   (/**/
   // Outputs
   .dout_on       (dout_on_3),
   .dout				(dout_3),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_3),
   .din				(din_3[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_4
   (
   // Outputs
   .dout_on       (dout_on_4),
   .dout				(dout_4),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_4),
   .din				(din_4[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_5
   (
   // Outputs
   .dout_on       (dout_on_5),
   .dout				(dout_5),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_5),
   .din				(din_5[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_6
   (
   // Outputs
   .dout_on       (dout_on_6),
   .dout				(dout_6),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_6),
   .din				(din_6[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_7
   (
   // Outputs
   .dout_on       (dout_on_7),
   .dout				(dout_7),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_7),
   .din				(din_7[SEQ_LENGTH-1:0]));

manchester_encoder #(.SEQ_LENGTH(SEQ_LENGTH)) u_me_8
   (
   // Outputs
   .dout_on       (dout_on_8),
   .dout				(dout_8),
   // Inputs
   .clk2x			(sys_clkg),
   .wrn				(trig_8),
   .din				(din_8[SEQ_LENGTH-1:0]));

endmodule // CmodA7_ctrl_top
