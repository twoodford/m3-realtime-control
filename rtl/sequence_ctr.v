module sequence_ctr
    (
        input ctr_en,
        input clk,
        input [6:0] seq_end_addr,
        input [11:0] time_gap,
        output reg [6:0] seq_addr=7'd0,
        output reg manchester_wren=1'b0
    );

reg [11:0] gap_cnt = 12'd0;

reg ctr_en_d = 1'b0;
wire ctr_en_end, ctr_en_begin;
always@(posedge clk)
    ctr_en_d <= ctr_en;
assign ctr_en_end = ~ctr_en && ctr_en_d;
assign ctr_en_begin = ctr_en && ~ctr_en_d;

always@(posedge clk) begin
    // If we're only sending 1 PA command, this module just needs to 
    // send a trigger signal to the manchester encoder module when 
    // the txrx input goes high
    if (seq_end_addr == 12'd0)
        manchester_wren <= ctr_en_begin;
    else if (ctr_en && gap_cnt == 12'd0) begin
        manchester_wren <= 1'b1;
        gap_cnt <= 12'd1;
        // We advance to the 2nd address here, since data is latched and 
        // it takes 1 clock cycle to fetch new data from memory
        seq_addr <= 7'd1;
    end
    else if (ctr_en && gap_cnt == time_gap) begin
        // Reached end of counter, increment seq_addr
        manchester_wren <= 1'b1;
        gap_cnt <= 12'd1;
        if (seq_addr == seq_end_addr)
            seq_addr <= 7'd0;
        else
            seq_addr <= seq_addr + 1'b1;
    end
    else if (ctr_en) begin
        // Increment counter
        manchester_wren <= 1'b0;
        gap_cnt <= gap_cnt + 1'b1;
    end
    else if (ctr_en_end) begin
        manchester_wren <= 1'b0;
        gap_cnt <= 12'd0;
        seq_addr <= 7'd0;
    end
end
endmodule