module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_row,
    in_kernel,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_data,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk;
input rst_n;
input in_valid;
input [17:0] in_row;
input [11:0] in_kernel;
input out_idle;
output reg handshake_sready;
output reg [29:0] handshake_din;
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [7:0] out_data;
// You can use the the custom flag ports for your design
output flag_clk1_to_fifo;
input flag_fifo_to_clk1;

//=======================================================
//                 Reg & Parameter
//=======================================================
parameter S_IDLE = 0;
parameter S_INPUT = 1;
parameter S_TO_CLK2 = 2;
parameter S_OUT  = 3;

reg [1:0] nxt_state,cur_state;
reg [17:0]in_row_ff[0:5],in_row_nxt[0:5];
reg [11:0]in_kernel_ff[0:5],in_kernel_nxt[0:5];
reg [7:0]cnt,cnt_nxt;
reg empty_reg,empty_reg_reg;
reg out_valid_nxt;
reg [7:0]out_data_nxt;
//=======================================================
//                       FSM
//=======================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= S_IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always @(*) begin
    case (cur_state)
        S_IDLE:begin
            if(in_valid) nxt_state = S_INPUT;
            else         nxt_state = cur_state;
        end 
        S_INPUT:begin
            if(!in_valid)nxt_state = S_TO_CLK2;
            else         nxt_state = cur_state;
        end
        S_TO_CLK2:begin
            if(cnt == 6)nxt_state = S_OUT;
            else        nxt_state = cur_state;
        end
        S_OUT:begin
            if(cnt == 149 && out_valid)begin
                nxt_state = S_IDLE;
            end
            else nxt_state = cur_state;
        end
        default:nxt_state = cur_state;
    endcase
end
//=======================================================
//                      Input
//=======================================================
always @(*) begin
    in_row_nxt = in_row_ff;
    case (cur_state)
        S_IDLE:begin
            if(in_valid) in_row_nxt[5] = in_row;
            else         in_row_nxt[5] = in_row_ff[5];
        end 
        S_INPUT:begin
            if(in_valid)begin
                in_row_nxt[0] = in_row_ff[1];
                in_row_nxt[1] = in_row_ff[2];
                in_row_nxt[2] = in_row_ff[3];
                in_row_nxt[3] = in_row_ff[4];
                in_row_nxt[4] = in_row_ff[5];
                in_row_nxt[5] = in_row; 
            end
            else begin
                in_row_nxt[0] = in_row_ff[0];
                in_row_nxt[1] = in_row_ff[1];
                in_row_nxt[2] = in_row_ff[2];
                in_row_nxt[3] = in_row_ff[3];
                in_row_nxt[4] = in_row_ff[4];
                in_row_nxt[5] = in_row_ff[5];
            end
        end
        S_TO_CLK2:begin
            if(out_idle)begin
                in_row_nxt[0] = in_row_ff[1];
                in_row_nxt[1] = in_row_ff[2];
                in_row_nxt[2] = in_row_ff[3];
                in_row_nxt[3] = in_row_ff[4];
                in_row_nxt[4] = in_row_ff[5];
                in_row_nxt[5] = in_row_ff[0];
            end
            else begin
                in_row_nxt[0] = in_row_ff[0];
                in_row_nxt[1] = in_row_ff[1];
                in_row_nxt[2] = in_row_ff[2];
                in_row_nxt[3] = in_row_ff[3];
                in_row_nxt[4] = in_row_ff[4];
                in_row_nxt[5] = in_row_ff[5];
            end
        end
    endcase
end
always @(*) begin
    in_kernel_nxt = in_kernel_ff;
    case (cur_state)
        S_IDLE:begin
            if(in_valid) in_kernel_nxt[5] = in_kernel;
            else         in_kernel_nxt[5] = in_kernel_ff[5];
        end 
        S_INPUT:begin
            if(in_valid)begin
                in_kernel_nxt[0] = in_kernel_ff[1];
                in_kernel_nxt[1] = in_kernel_ff[2];
                in_kernel_nxt[2] = in_kernel_ff[3];
                in_kernel_nxt[3] = in_kernel_ff[4];
                in_kernel_nxt[4] = in_kernel_ff[5];
                in_kernel_nxt[5] = in_kernel;
            end
            else begin
                in_kernel_nxt[0] = in_kernel_ff[0];
                in_kernel_nxt[1] = in_kernel_ff[1];
                in_kernel_nxt[2] = in_kernel_ff[2];
                in_kernel_nxt[3] = in_kernel_ff[3];
                in_kernel_nxt[4] = in_kernel_ff[4];
                in_kernel_nxt[5] = in_kernel_ff[5];
            end
        end
        S_TO_CLK2:begin
            if(out_idle)begin
                in_kernel_nxt[0] = in_kernel_ff[1];
                in_kernel_nxt[1] = in_kernel_ff[2];
                in_kernel_nxt[2] = in_kernel_ff[3];
                in_kernel_nxt[3] = in_kernel_ff[4];
                in_kernel_nxt[4] = in_kernel_ff[5];
                in_kernel_nxt[5] = in_kernel_ff[0];
            end
            else begin
                in_kernel_nxt[0] = in_kernel_ff[0];
                in_kernel_nxt[1] = in_kernel_ff[1];
                in_kernel_nxt[2] = in_kernel_ff[2];
                in_kernel_nxt[3] = in_kernel_ff[3];
                in_kernel_nxt[4] = in_kernel_ff[4];
                in_kernel_nxt[5] = in_kernel_ff[5];
            end
        end
    endcase
end
genvar i;
generate
    for ( i= 0;i<6 ;i=i+1 ) begin
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                in_row_ff[i] <= 0;
            end
            else begin
                in_row_ff[i] <= in_row_nxt[i];
            end
        end
    end
endgenerate
generate
    for ( i= 0;i<6 ;i=i+1 ) begin
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                in_kernel_ff[i] <= 0;
            end
            else begin
                in_kernel_ff[i] <= in_kernel_nxt[i];
            end
        end
    end
endgenerate
//handshake_sready
always@* begin
    if(cur_state==S_TO_CLK2 && out_idle)
        handshake_sready = 1;
    else
        handshake_sready = 0;
end
//handshake_din
always@* begin
    if(cur_state==S_TO_CLK2 && out_idle)
        handshake_din = {in_row_ff[0], in_kernel_ff[0]};
    else
        handshake_din = 0;
end
//=======================================================
//                    Cnt control
//=======================================================
always @(*) begin
    case (cur_state)
        S_IDLE: cnt_nxt = 0;
        S_TO_CLK2:begin
            if(out_idle) cnt_nxt = cnt + 1;
            else begin
                if(cnt == 6)cnt_nxt = 0;
                else        cnt_nxt = cnt;
            end      
            
        end 
        S_OUT: cnt_nxt = out_valid ?  cnt + 1 : cnt;
        default: cnt_nxt = cnt;
    endcase
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_nxt;
    end
end
//=======================================================
//                      Output
//=======================================================
assign fifo_rinc = ~fifo_empty;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        empty_reg <= 1;
        empty_reg_reg <= 1;
    end
        
    else begin
        empty_reg <= fifo_empty;
        empty_reg_reg <= empty_reg;
    end
        
end
assign out_valid_nxt = (cur_state == S_OUT && !empty_reg_reg) ? 1 : 0;
assign out_data_nxt = (cur_state == S_OUT && !empty_reg_reg) ? fifo_rdata : 0;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_data  <= 0;
        out_valid <= 0;
    end
    else begin
        out_data  <= out_data_nxt;
        out_valid <= out_valid_nxt;
    end
end

endmodule






module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    in_data,
    out_valid,
    out_data,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [29:0] in_data;
output reg out_valid;
output reg [7:0] out_data;
output reg busy;

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;

//=======================================================
//                 Reg & Parameter
//=======================================================

parameter S_IDLE = 0;
parameter S_INPUT = 1;
parameter S_CAL_OUT = 2;


reg [1:0] nxt_state,cur_state;
reg [2:0]row_ff[0:5][0:5],row_nxt[0:5][0:5];
reg [11:0]kernel_ff[0:5],kernel_nxt[0:5];
reg [7:0]cnt,cnt_nxt;
reg [2:0]row_cnt,row_cnt_nxt;
reg [2:0]col_cnt,col_cnt_nxt;
reg [7:0]out_data_nxt;
reg out_valid_nxt;
reg [5:0]add1,add2,add3,add4;
reg [6:0]add1_1,add1_2;
//=======================================================
//                       FSM
//=======================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= S_IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always @(*) begin
    case (cur_state)
        S_IDLE:begin
            if(in_valid) nxt_state = S_INPUT;
            else         nxt_state = cur_state;
        end 
        S_INPUT:begin
            if(cnt == 5 && in_valid) nxt_state = S_CAL_OUT;
            else                     nxt_state = cur_state;
        end
        S_CAL_OUT:begin
            if(cnt == 150)nxt_state = S_IDLE;
            else          nxt_state = cur_state;
        end
        default:nxt_state = cur_state;
    endcase
end
//=======================================================
//                    Cnt control
//=======================================================
always @(*) begin
    case (cur_state)
        S_IDLE:begin
            if(in_valid) cnt_nxt = cnt + 1;
            else         cnt_nxt = cnt;
        end 
        S_INPUT:begin
            if(in_valid) begin
                if(cnt == 5)cnt_nxt = 0;
                else        cnt_nxt = cnt + 1;
            end
            else  cnt_nxt = cnt;
        end
        S_CAL_OUT:begin
            if(cnt == 150) cnt_nxt = 0;
            else begin
                if(out_valid)cnt_nxt = cnt + 1;
                else         cnt_nxt = cnt;
            end
            
        end
        default: cnt_nxt = cnt;
    endcase
end
always @(*) begin
    case (cur_state)
        S_IDLE: row_cnt_nxt = 0;
        S_CAL_OUT:begin
            if(fifo_full)begin
                row_cnt_nxt = row_cnt;
            end
            else begin
                if(row_cnt == 4)row_cnt_nxt = 0;
                else            row_cnt_nxt = row_cnt + 1;
            end
            
        end 
        default: row_cnt_nxt = row_cnt;
    endcase
end
always @(*) begin
    case (cur_state)
        S_IDLE : col_cnt_nxt = 0;
        S_CAL_OUT:begin
            if(fifo_full)begin
                col_cnt_nxt = col_cnt ;
            end
            else begin
                if(row_cnt == 4)begin
                    if(col_cnt == 4) col_cnt_nxt = 0;
                    else             col_cnt_nxt = col_cnt + 1;
                end
                else            col_cnt_nxt = col_cnt ;
            end
            
        end 
        default: col_cnt_nxt = col_cnt;
    endcase
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
        row_cnt<=0;
        col_cnt<=0;
    end
    else begin
        cnt <= cnt_nxt;
        row_cnt<=row_cnt_nxt;
        col_cnt<=col_cnt_nxt;
    end
end
//=======================================================
//                      Input
//=======================================================
always @(*) begin
    row_nxt = row_ff;
    case (cur_state)
        S_IDLE,S_INPUT:begin
            if(in_valid)begin
                row_nxt[0][0]=  row_ff[1][0];row_nxt[0][1]=  row_ff[1][1];row_nxt[0][2]=  row_ff[1][2];row_nxt[0][3]=  row_ff[1][3];row_nxt[0][4]=  row_ff[1][4];row_nxt[0][5]=  row_ff[1][5];
                row_nxt[1][0]=  row_ff[2][0];row_nxt[1][1]=  row_ff[2][1];row_nxt[1][2]=  row_ff[2][2];row_nxt[1][3]=  row_ff[2][3];row_nxt[1][4]=  row_ff[2][4];row_nxt[1][5]=  row_ff[2][5];
                row_nxt[2][0]=  row_ff[3][0];row_nxt[2][1]=  row_ff[3][1];row_nxt[2][2]=  row_ff[3][2];row_nxt[2][3]=  row_ff[3][3];row_nxt[2][4]=  row_ff[3][4];row_nxt[2][5]=  row_ff[3][5];
                row_nxt[3][0]=  row_ff[4][0];row_nxt[3][1]=  row_ff[4][1];row_nxt[3][2]=  row_ff[4][2];row_nxt[3][3]=  row_ff[4][3];row_nxt[3][4]=  row_ff[4][4];row_nxt[3][5]=  row_ff[4][5];
                row_nxt[4][0]=  row_ff[5][0];row_nxt[4][1]=  row_ff[5][1];row_nxt[4][2]=  row_ff[5][2];row_nxt[4][3]=  row_ff[5][3];row_nxt[4][4]=  row_ff[5][4];row_nxt[4][5]=  row_ff[5][5];
                row_nxt[5][0]=in_data[14:12];row_nxt[5][1]=in_data[17:15];row_nxt[5][2]=in_data[20:18];row_nxt[5][3]=in_data[23:21];row_nxt[5][4]=in_data[26:24];row_nxt[5][5]=in_data[29:27];
            end
        end 
        S_CAL_OUT:begin
            if(!fifo_full)begin
                if(row_cnt == 4 && col_cnt == 4)begin
                    row_nxt[0][0] = row_ff[2][2];row_nxt[0][1] = row_ff[2][3];row_nxt[0][2] = row_ff[2][4];row_nxt[0][3] = row_ff[2][5];row_nxt[0][4] = row_ff[2][0];row_nxt[0][5] = row_ff[2][1];
                    row_nxt[1][0] = row_ff[3][2];row_nxt[1][1] = row_ff[3][3];row_nxt[1][2] = row_ff[3][4];row_nxt[1][3] = row_ff[3][5];row_nxt[1][4] = row_ff[3][0];row_nxt[1][5] = row_ff[3][1];
                    row_nxt[2][0] = row_ff[4][2];row_nxt[2][1] = row_ff[4][3];row_nxt[2][2] = row_ff[4][4];row_nxt[2][3] = row_ff[4][5];row_nxt[2][4] = row_ff[4][0];row_nxt[2][5] = row_ff[4][1];
                    row_nxt[3][0] = row_ff[5][2];row_nxt[3][1] = row_ff[5][3];row_nxt[3][2] = row_ff[5][4];row_nxt[3][3] = row_ff[5][5];row_nxt[3][4] = row_ff[5][0];row_nxt[3][5] = row_ff[5][1];
                    row_nxt[4][0] = row_ff[0][2];row_nxt[4][1] = row_ff[0][3];row_nxt[4][2] = row_ff[0][4];row_nxt[4][3] = row_ff[0][5];row_nxt[4][4] = row_ff[0][0];row_nxt[4][5] = row_ff[0][1];
                    row_nxt[5][0] = row_ff[1][2];row_nxt[5][1] = row_ff[1][3];row_nxt[5][2] = row_ff[1][4];row_nxt[5][3] = row_ff[1][5];row_nxt[5][4] = row_ff[1][0];row_nxt[5][5] = row_ff[1][1];
                end
                else if(row_cnt == 4)begin
                    row_nxt[0][0] = row_ff[1][2];row_nxt[0][1] = row_ff[1][3];row_nxt[0][2] = row_ff[1][4];row_nxt[0][3] = row_ff[1][5];row_nxt[0][4] = row_ff[1][0];row_nxt[0][5] = row_ff[1][1];
                    row_nxt[1][0] = row_ff[2][2];row_nxt[1][1] = row_ff[2][3];row_nxt[1][2] = row_ff[2][4];row_nxt[1][3] = row_ff[2][5];row_nxt[1][4] = row_ff[2][0];row_nxt[1][5] = row_ff[2][1];
                    row_nxt[2][0] = row_ff[3][2];row_nxt[2][1] = row_ff[3][3];row_nxt[2][2] = row_ff[3][4];row_nxt[2][3] = row_ff[3][5];row_nxt[2][4] = row_ff[3][0];row_nxt[2][5] = row_ff[3][1];
                    row_nxt[3][0] = row_ff[4][2];row_nxt[3][1] = row_ff[4][3];row_nxt[3][2] = row_ff[4][4];row_nxt[3][3] = row_ff[4][5];row_nxt[3][4] = row_ff[4][0];row_nxt[3][5] = row_ff[4][1];
                    row_nxt[4][0] = row_ff[5][2];row_nxt[4][1] = row_ff[5][3];row_nxt[4][2] = row_ff[5][4];row_nxt[4][3] = row_ff[5][5];row_nxt[4][4] = row_ff[5][0];row_nxt[4][5] = row_ff[5][1];
                    row_nxt[5][0] = row_ff[0][2];row_nxt[5][1] = row_ff[0][3];row_nxt[5][2] = row_ff[0][4];row_nxt[5][3] = row_ff[0][5];row_nxt[5][4] = row_ff[0][0];row_nxt[5][5] = row_ff[0][1];
                end
                else begin
                    row_nxt[0][0] = row_ff[0][1];row_nxt[0][1] = row_ff[0][2];row_nxt[0][2] = row_ff[0][3];row_nxt[0][3] = row_ff[0][4];row_nxt[0][4] = row_ff[0][5];row_nxt[0][5] = row_ff[0][0];
                    row_nxt[1][0] = row_ff[1][1];row_nxt[1][1] = row_ff[1][2];row_nxt[1][2] = row_ff[1][3];row_nxt[1][3] = row_ff[1][4];row_nxt[1][4] = row_ff[1][5];row_nxt[1][5] = row_ff[1][0];
                    row_nxt[2][0] = row_ff[2][1];row_nxt[2][1] = row_ff[2][2];row_nxt[2][2] = row_ff[2][3];row_nxt[2][3] = row_ff[2][4];row_nxt[2][4] = row_ff[2][5];row_nxt[2][5] = row_ff[2][0];
                    row_nxt[3][0] = row_ff[3][1];row_nxt[3][1] = row_ff[3][2];row_nxt[3][2] = row_ff[3][3];row_nxt[3][3] = row_ff[3][4];row_nxt[3][4] = row_ff[3][5];row_nxt[3][5] = row_ff[3][0];
                    row_nxt[4][0] = row_ff[4][1];row_nxt[4][1] = row_ff[4][2];row_nxt[4][2] = row_ff[4][3];row_nxt[4][3] = row_ff[4][4];row_nxt[4][4] = row_ff[4][5];row_nxt[4][5] = row_ff[4][0];
                    row_nxt[5][0] = row_ff[5][1];row_nxt[5][1] = row_ff[5][2];row_nxt[5][2] = row_ff[5][3];row_nxt[5][3] = row_ff[5][4];row_nxt[5][4] = row_ff[5][5];row_nxt[5][5] = row_ff[5][0];
                end
            end
            
        end
    endcase
end
always @(*) begin
    kernel_nxt =  kernel_ff;
    case (cur_state)
        S_IDLE,S_INPUT:begin
            if(in_valid)begin
                kernel_nxt[0] =  kernel_ff[1];
                kernel_nxt[1] =  kernel_ff[2];
                kernel_nxt[2] =  kernel_ff[3];
                kernel_nxt[3] =  kernel_ff[4];
                kernel_nxt[4] =  kernel_ff[5];
                kernel_nxt[5] = in_data[11:0];
            end
        end 
        S_CAL_OUT:begin
            if(!fifo_full)begin
                if(row_cnt == 4 && col_cnt == 4)begin
                    kernel_nxt[0] =  kernel_ff[1];
                    kernel_nxt[1] =  kernel_ff[2];
                    kernel_nxt[2] =  kernel_ff[3];
                    kernel_nxt[3] =  kernel_ff[4];
                    kernel_nxt[4] =  kernel_ff[5];
                    kernel_nxt[5] =  kernel_ff[0];
                end
            end
            
        end
    endcase
end
genvar i,j;
generate
    for ( i= 0;i<6 ;i=i+1 ) begin
        for (j= 0;j<6 ;j=j+1 ) begin
            always@(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    row_ff[i][j] <= 0;
                end
                else begin
                    row_ff[i][j] <= row_nxt[i][j];
                end
            end
        end
    end
endgenerate
generate
    for ( i= 0;i<6 ;i=i+1 ) begin
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                kernel_ff[i] <= 0;
            end
            else begin
                kernel_ff[i] <= kernel_nxt[i];
            end
        end
    end
endgenerate
//=======================================================
//                        Conv
//=======================================================
assign add1 = row_ff[0][0] * kernel_ff[0][2:0];
assign add2 = row_ff[0][1] * kernel_ff[0][5:3];
assign add3 = row_ff[1][0] * kernel_ff[0][8:6];
assign add4 = row_ff[1][1] * kernel_ff[0][11:9];

assign add1_1 = add1 + add2;
assign add1_2 = add3 + add4;
assign out_data = add1_1 + add1_2;
//=======================================================
//                       Output
//=======================================================
/*always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_data <= 0;
    end
    else begin
        out_data <= out_data_nxt;
    end
end*/

assign out_valid = (cur_state == S_CAL_OUT && cnt < 150 && fifo_full==0) ? 1 : 0;
/*always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_nxt;
    end
end*/
assign busy = 0;
endmodule