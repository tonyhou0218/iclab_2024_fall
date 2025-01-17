module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;

output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

//reg 
reg [WIDTH-1:0]data_tmp_nxt,data_tmp_ff;
reg [WIDTH-1:0]dout_nxt;
reg dvalid_nxt,dvalid_ff;
reg sreq_nxt;
reg dack_nxt;
reg dvalid_edge;



NDFF_syn NDFF_1(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n)) ;
NDFF_syn NDFF_2(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n)) ;
// sidle
assign sidle = (sreq || sack) ? 0 : 1;
//dout
always @(*) begin
    if(sready)
        data_tmp_nxt = din;
    else
        data_tmp_nxt = data_tmp_ff;
end
always @(posedge sclk or negedge rst_n) begin
    if(!rst_n) 
        data_tmp_ff <= 0;
    else
        data_tmp_ff <= data_tmp_nxt;
end

always @(*) begin
    if(dvalid_edge)
        dout_nxt = data_tmp_ff;
    else
        dout_nxt = 0;
end
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dout <= 0;
    else
        dout <= dout_nxt;
end
//dvalid
always @(*) begin
    if(dreq && !dbusy)
        dvalid_nxt = 1;
    else
        dvalid_nxt = 0;
end
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dvalid <= 0;
    else
        dvalid <= dvalid_edge;
end
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dvalid_ff <= 0;
    else
        dvalid_ff <= dvalid_nxt;
end
assign dvalid_edge = (dvalid_nxt && !dvalid_ff) ? 1 : 0;
// sreq
always @(posedge sclk or negedge rst_n) begin
    if(!rst_n) 
        sreq <= 0;
    else
        sreq <= sreq_nxt;
end

always @(*) begin
    if(sack)
        sreq_nxt = 0;
    else if(sready)
        sreq_nxt = 1;
    else
        sreq_nxt = sreq;
end
// dack
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) 
        dack <= 0;
    else
        dack <= dack_nxt;
end

assign dack_nxt = (dreq & (!dbusy));
endmodule