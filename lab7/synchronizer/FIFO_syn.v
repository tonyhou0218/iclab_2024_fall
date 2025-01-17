module FIFO_syn #(parameter WIDTH=8, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

    flag_fifo_to_clk1,
	flag_clk1_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output  flag_fifo_to_clk2;
input flag_clk2_to_fifo;

output flag_fifo_to_clk1;
input flag_clk1_to_fifo;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;

reg [$clog2(WORDS):0] wptr_rDomain;
reg [$clog2(WORDS):0] rptr_wDomain;
reg [6:0] waddr, raddr;
reg [6:0] waddr_nxt, raddr_nxt;

//==============================================//
//                  Write                       //
//==============================================//
//waddr
always @(*) begin
    if(winc && !wfull) waddr_nxt = waddr + 1;
    else               waddr_nxt = waddr;
end
always @(posedge wclk, negedge rst_n) begin
    if (!rst_n)
        waddr <= 0;
    else 
        waddr <= waddr_nxt;
end
assign wptr = {1'b0, waddr[6:1]} ^ waddr;


//wfull
NDFF_BUS_syn #(.WIDTH(7)) NDFF_BUS_2(.D(rptr), .Q(rptr_wDomain), .clk(wclk), .rst_n(rst_n)) ;

assign wfull = {~wptr[6:5],wptr[4:0]} == rptr_wDomain ? 1 : 0;
assign wen = !(!wfull & winc);

//==============================================//
//                  Read                        //
//==============================================//
//raddr
always @(*) begin
    if(rinc && !rempty) raddr_nxt = raddr + 1;
    else                raddr_nxt = raddr;
end
always @(posedge rclk, negedge rst_n) begin
    if (!rst_n)
        raddr <= 0;
    else
        raddr <= raddr_nxt;
end
assign rptr = {1'b0, raddr[6:1]} ^ raddr;


//rempty
NDFF_BUS_syn #(.WIDTH(7)) NDFF_BUS_1(.D(wptr), .Q(wptr_rDomain), .clk(rclk), .rst_n(rst_n)) ;
assign rempty = (wptr_rDomain == rptr) ? 1 : 0;

// rdata
always @(posedge rclk, negedge rst_n) begin
    if (!rst_n) begin
        rdata <= 0;
    end
    else begin
		rdata <= rdata_q;
    end
end

//==============================================//
//                   Sram                       //
//==============================================//
DUAL_64X8X1BM1 u_dual_sram (
    .CKA(wclk),
    .CKB(rclk),
    .WEAN(wen),
    .WEBN(1'b1),
    .CSA(1'b1),
    .CSB(1'b1),
    .OEA(1'b1),
    .OEB(1'b1),
    .A0(waddr[0]),
    .A1(waddr[1]),
    .A2(waddr[2]),
    .A3(waddr[3]),
    .A4(waddr[4]),
    .A5(waddr[5]),
    .B0(raddr[0]),
    .B1(raddr[1]),
    .B2(raddr[2]),
    .B3(raddr[3]),
    .B4(raddr[4]),
    .B5(raddr[5]),
    .DIA0(wdata[0]),
    .DIA1(wdata[1]),
    .DIA2(wdata[2]),
    .DIA3(wdata[3]),
    .DIA4(wdata[4]),
    .DIA5(wdata[5]),
    .DIA6(wdata[6]),
    .DIA7(wdata[7]),
    .DIB0(1'b0),
    .DIB1(1'b0),
    .DIB2(1'b0),
    .DIB3(1'b0),
    .DIB4(1'b0),
    .DIB5(1'b0),
    .DIB6(1'b0),
    .DIB7(1'b0),
    .DOB0(rdata_q[0]),
    .DOB1(rdata_q[1]),
    .DOB2(rdata_q[2]),
    .DOB3(rdata_q[3]),
    .DOB4(rdata_q[4]),
    .DOB5(rdata_q[5]),
    .DOB6(rdata_q[6]),
    .DOB7(rdata_q[7])
);
endmodule
