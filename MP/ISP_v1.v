module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input       in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output reg out_valid,
    output reg [7:0] out_data,
    
    // DRAM Signals
    // axi write address channel
    // src master
    output reg[3:0]  awid_s_inf,
    output reg[31:0] awaddr_s_inf,
    output reg[2:0]  awsize_s_inf,
    output reg[1:0]  awburst_s_inf,
    output reg[7:0]  awlen_s_inf,
    output reg       awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
  
    // axi write data channel 
    // src master
    output reg[127:0] wdata_s_inf,
    output reg        wlast_s_inf,
    output reg        wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output reg     bready_s_inf,
    // -----------------------------
  
    // axi read address channel 
    // src master
    output reg[3:0]   arid_s_inf,
    output reg[31:0]  araddr_s_inf,
    output reg[7:0]   arlen_s_inf,
    output reg[2:0]   arsize_s_inf,
    output reg[1:0]   arburst_s_inf,
    output reg        arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output reg     rready_s_inf
    
);
//================================================================//
//                      Parameter & Integer
//================================================================//
parameter S_IDLE        =  'd0;
parameter S_AF_read     =  'd1;
parameter S_AE          =  'd2;
parameter S_AF_cal      =  'd3;
//================================================================//
//                             Reg
//================================================================//

reg [1:0]cur_state,nxt_state;
reg [1:0]in_ratio_mode_reg,in_ratio_mode_nxt;
reg rvalid_reg;
//ae
reg [127:0]ae_out_ff,ae_out_nxt;
reg [17:0] pixel_sum,pixel_sum_nxt;
reg [7:0]I_tmp[0:15],I_tmp_nxt[0:15];
reg [1:0]right_shift_times;
reg [127:0]adj_pic_reg1,adj_pic_reg1_nxt;
reg [127:0]rdata_reg;
//af
reg R_read;
reg G_read;
reg B_read;
reg R_read_reg;
reg G_read_reg;
reg B_read_reg;
reg [7:0]af_gray[0:5][0:5],af_gray_nxt[0:5][0:5];
reg [9:0] diff_2x2_sum,diff_2x2_sum_nxt;
reg [12:0]diff_4x4_sum,diff_4x4_sum_nxt;
reg [14:0]diff_6x6_sum,diff_6x6_sum_nxt;
//reg [7:0]R[0:5][0:5],R_nxt[0:5][0:5];
//out
reg [7:0]out_data_nxt;
reg out_valid_nxt;
//cnt
reg [7:0]cnt,cnt_nxt;
//read signal
reg ar_valid_nxt;
reg rready_nxt;
reg [31:0]araddr_s_inf_nxt;
reg [7:0]ar_len_nxt;
//write signal
reg [31:0]awaddr_s_inf_nxt;
reg aw_valid_nxt;
reg wlast_nxt;
reg wvalid_nxt;
reg [127:0]wdata_nxt;
reg bready_nxt;
//adder
reg signed[8:0]add_8B_a1,add_8B_a2,add_8B_a3,add_8B_a4,add_8B_a5,add_8B_a6,add_8B_a7,add_8B_a8;
reg signed[8:0]add_8B_b1,add_8B_b2,add_8B_b3,add_8B_b4,add_8B_b5,add_8B_b6,add_8B_b7,add_8B_b8;
reg signed[9:0]add_8B_z1,add_8B_z2,add_8B_z3,add_8B_z4,add_8B_z5,add_8B_z6,add_8B_z7,add_8B_z8;

reg [8:0]add_9B_a1,add_9B_a2,add_9B_a3,add_9B_a4;
reg [8:0]add_9B_b1,add_9B_b2,add_9B_b3,add_9B_b4;
reg [9:0]add_9B_z1,add_9B_z2,add_9B_z3,add_9B_z4;

reg [9:0] add_10B_a1,add_10B_a2;
reg [9:0] add_10B_b1,add_10B_b2;
reg [10:0]add_10B_z1,add_10B_z2;

reg [11:0]add_11B_z1;
reg [11:0]add_11B_reg;
//steal cycle
reg [3:0]img_data_zero[0:15],img_data_zero_nxt[0:15];
reg zreo_flag,zreo_flag_nxt;
//================================================================//
//                         INPUT REG
//================================================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_ratio_mode_reg <= 0;
        rvalid_reg <= 0;
        rdata_reg <= 0;
        add_11B_reg <= 0;
    end
    else begin
        in_ratio_mode_reg <= in_ratio_mode_nxt;
        rvalid_reg <= rvalid_s_inf;
        rdata_reg <= rdata_s_inf;
        add_11B_reg <= add_11B_z1;
    end
end
always @(*) begin
    if(in_valid)begin
        if(in_mode)begin
            in_ratio_mode_nxt = in_ratio_mode;
        end
        else begin
            in_ratio_mode_nxt = in_ratio_mode_reg;
        end
    end
    else in_ratio_mode_nxt = in_ratio_mode_reg;
end
//================================================================//
//                             FSM
//================================================================//
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
        S_IDLE: begin
            if(in_valid)begin
                nxt_state = in_mode ? S_AE : S_AF_read;
            end
            else nxt_state = cur_state;
        end
        S_AF_read: nxt_state = zreo_flag ? S_IDLE : ((cnt == 139)?  S_AF_cal : cur_state);
        S_AF_cal:  nxt_state = out_valid   ?  S_IDLE   : cur_state;
        S_AE:      nxt_state = (cnt == 195 || zreo_flag)?  S_IDLE   : cur_state;
        default: nxt_state = cur_state;
    endcase
end

//================================================================//
//                       Read Control
//================================================================//
//arid
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arid_s_inf <= 0;
    end
    else begin
        arid_s_inf <= 0;
    end
end
//arsize
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arsize_s_inf <= 0;
    end
    else begin
        arsize_s_inf <= 4;
    end
end
//arburst
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arburst_s_inf <= 0;
    end
    else begin
        arburst_s_inf <= 1;
    end
end
//araddr
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        araddr_s_inf <= 0;

    end
    else begin
        araddr_s_inf <= araddr_s_inf_nxt ;

    end
end


always @(*) begin
    if(in_valid)begin
        if(in_mode)begin
            araddr_s_inf_nxt = 32'h10000 + ((in_pic_no*3)<<10);
        end
        else begin
            araddr_s_inf_nxt = 32'h10000 + ((in_pic_no*3)<<10) + 416;
        end
    end
    else araddr_s_inf_nxt = araddr_s_inf;
end

//arlen
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arlen_s_inf <= 0;
    end
    else begin
        arlen_s_inf <= ar_len_nxt;
    end
end
always @(*) begin
    if(in_valid)begin
        if(in_mode)begin
            ar_len_nxt = 191;
        end
        else begin
            ar_len_nxt = 140;
        end
    end
    else ar_len_nxt = arlen_s_inf;
end
//arvalid
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arvalid_s_inf <= 0;
    end
    else begin
        arvalid_s_inf <= ar_valid_nxt;
    end
end
always @(*) begin
    if(cur_state == S_IDLE && nxt_state!=cur_state && !zreo_flag_nxt) 
        ar_valid_nxt = 1;
    else begin
        ar_valid_nxt = (arready_s_inf) ? 0 : arvalid_s_inf;
    end
end
//rready
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rready_s_inf <= 0;
    end
    else begin
        rready_s_inf <= rready_nxt;
    end
end
always @(*) begin
    if(arready_s_inf && arvalid_s_inf)begin
        rready_nxt = 1;
    end
    else begin
        rready_nxt = rready_s_inf;
    end
end
//================================================================//
//                       Read data
//================================================================//
genvar i,j;

generate
	for(i=0;i<6;i=i+1) begin
		for(j=0;j<6;j=j+1) begin
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n)
					af_gray[i][j] <= 0;
				else
					af_gray[i][j] <= af_gray_nxt[i][j];	
			end
		end
	end
endgenerate
always @(*) begin
    case (cur_state)
        S_AF_read:begin
            R_read = cnt < 12 ? 1 : 0;
            G_read = (cnt >= 64 && cnt <= 75) ? 1 : 0;
            B_read = (cnt >= 128 && cnt <= 139) ? 1 : 0;
        end 
        S_AE:begin
            R_read = (cnt >=  1  && cnt <= 64 ) ? 1 : 0;
            G_read = (cnt >= 65  && cnt <= 128) ? 1 : 0;
            B_read = (cnt >= 129 && cnt <= 192) ? 1 : 0;
        end
        default: begin
            R_read = 0;
            G_read = 0;
            B_read = 0;
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        R_read_reg <= 0;
        G_read_reg <= 0;
        B_read_reg <= 0;
    end
        
    else begin
        R_read_reg <= R_read;
        G_read_reg <= G_read;
        B_read_reg <= B_read;
    end
   	
end
always @(*) begin
    case (cur_state)
        S_IDLE:begin
            af_gray_nxt[0][0] = 0;af_gray_nxt[0][1] = 0;af_gray_nxt[0][2] = 0;af_gray_nxt[0][3] = 0;af_gray_nxt[0][4] = 0;af_gray_nxt[0][5] = 0;
            af_gray_nxt[1][0] = 0;af_gray_nxt[1][1] = 0;af_gray_nxt[1][2] = 0;af_gray_nxt[1][3] = 0;af_gray_nxt[1][4] = 0;af_gray_nxt[1][5] = 0;
            af_gray_nxt[2][0] = 0;af_gray_nxt[2][1] = 0;af_gray_nxt[2][2] = 0;af_gray_nxt[2][3] = 0;af_gray_nxt[2][4] = 0;af_gray_nxt[2][5] = 0;
            af_gray_nxt[3][0] = 0;af_gray_nxt[3][1] = 0;af_gray_nxt[3][2] = 0;af_gray_nxt[3][3] = 0;af_gray_nxt[3][4] = 0;af_gray_nxt[3][5] = 0;
            af_gray_nxt[4][0] = 0;af_gray_nxt[4][1] = 0;af_gray_nxt[4][2] = 0;af_gray_nxt[4][3] = 0;af_gray_nxt[4][4] = 0;af_gray_nxt[4][5] = 0;
            af_gray_nxt[5][0] = 0;af_gray_nxt[5][1] = 0;af_gray_nxt[5][2] = 0;af_gray_nxt[5][3] = 0;af_gray_nxt[5][4] = 0;af_gray_nxt[5][5] = 0;
        end
        S_AF_read:begin
            if(R_read)begin
                af_gray_nxt[0][0] = af_gray[0][3];af_gray_nxt[0][1] = af_gray[0][4];af_gray_nxt[0][2] = af_gray[0][5];af_gray_nxt[0][3] = af_gray[1][0];af_gray_nxt[0][4] = af_gray[1][1];af_gray_nxt[0][5] = af_gray[1][2];
                af_gray_nxt[1][0] = af_gray[1][3];af_gray_nxt[1][1] = af_gray[1][4];af_gray_nxt[1][2] = af_gray[1][5];af_gray_nxt[1][3] = af_gray[2][0];af_gray_nxt[1][4] = af_gray[2][1];af_gray_nxt[1][5] = af_gray[2][2];
                af_gray_nxt[2][0] = af_gray[2][3];af_gray_nxt[2][1] = af_gray[2][4];af_gray_nxt[2][2] = af_gray[2][5];af_gray_nxt[2][3] = af_gray[3][0];af_gray_nxt[2][4] = af_gray[3][1];af_gray_nxt[2][5] = af_gray[3][2];
                af_gray_nxt[3][0] = af_gray[3][3];af_gray_nxt[3][1] = af_gray[3][4];af_gray_nxt[3][2] = af_gray[3][5];af_gray_nxt[3][3] = af_gray[4][0];af_gray_nxt[3][4] = af_gray[4][1];af_gray_nxt[3][5] = af_gray[4][2];
                af_gray_nxt[4][0] = af_gray[4][3];af_gray_nxt[4][1] = af_gray[4][4];af_gray_nxt[4][2] = af_gray[4][5];af_gray_nxt[4][3] = af_gray[5][0];af_gray_nxt[4][4] = af_gray[5][1];af_gray_nxt[4][5] = af_gray[5][2];
                af_gray_nxt[5][0] = af_gray[5][3];af_gray_nxt[5][1] = af_gray[5][4];af_gray_nxt[5][2] = af_gray[5][5];
                if(cnt[0]==0)begin
                    af_gray_nxt[5][3] = rdata_s_inf[111:104] >> 2;af_gray_nxt[5][4] = rdata_s_inf[119:112]>> 2;af_gray_nxt[5][5] = rdata_s_inf[127:120]>> 2; 
                end
                else begin
                    af_gray_nxt[5][3] = rdata_s_inf[7:0]>> 2;    af_gray_nxt[5][4] = rdata_s_inf[15:8]>> 2;   af_gray_nxt[5][5] = rdata_s_inf[23:16]>> 2;
                end
            end
            else if(G_read || B_read)begin
                af_gray_nxt[0][0] = af_gray[0][3];af_gray_nxt[0][1] = af_gray[0][4];af_gray_nxt[0][2] = af_gray[0][5];af_gray_nxt[0][3] = af_gray[1][0];af_gray_nxt[0][4] = af_gray[1][1];af_gray_nxt[0][5] = af_gray[1][2];
                af_gray_nxt[1][0] = af_gray[1][3];af_gray_nxt[1][1] = af_gray[1][4];af_gray_nxt[1][2] = af_gray[1][5];af_gray_nxt[1][3] = af_gray[2][0];af_gray_nxt[1][4] = af_gray[2][1];af_gray_nxt[1][5] = af_gray[2][2];
                af_gray_nxt[2][0] = af_gray[2][3];af_gray_nxt[2][1] = af_gray[2][4];af_gray_nxt[2][2] = af_gray[2][5];af_gray_nxt[2][3] = af_gray[3][0];af_gray_nxt[2][4] = af_gray[3][1];af_gray_nxt[2][5] = af_gray[3][2];
                af_gray_nxt[3][0] = af_gray[3][3];af_gray_nxt[3][1] = af_gray[3][4];af_gray_nxt[3][2] = af_gray[3][5];af_gray_nxt[3][3] = af_gray[4][0];af_gray_nxt[3][4] = af_gray[4][1];af_gray_nxt[3][5] = af_gray[4][2];
                af_gray_nxt[4][0] = af_gray[4][3];af_gray_nxt[4][1] = af_gray[4][4];af_gray_nxt[4][2] = af_gray[4][5];af_gray_nxt[4][3] = af_gray[5][0];af_gray_nxt[4][4] = af_gray[5][1];af_gray_nxt[4][5] = af_gray[5][2];
                af_gray_nxt[5][0] = af_gray[5][3];af_gray_nxt[5][1] = af_gray[5][4];af_gray_nxt[5][2] = af_gray[5][5];
                
                if(G_read)begin
                    if(cnt[0]==0)begin
                        af_gray_nxt[5][3] = af_gray[0][0] + (rdata_s_inf[111:104] >> 1);af_gray_nxt[5][4] = af_gray[0][1] + (rdata_s_inf[119:112]>> 1);af_gray_nxt[5][5] = af_gray[0][2] + (rdata_s_inf[127:120]>> 1); 
                    end
                    else begin
                        af_gray_nxt[5][3] = af_gray[0][0] + (rdata_s_inf[7:0]>> 1);     af_gray_nxt[5][4] = af_gray[0][1] + (rdata_s_inf[15:8]>> 1);   af_gray_nxt[5][5] = af_gray[0][2] + (rdata_s_inf[23:16]>> 1);
                    end
                end
                else begin
                    if(cnt[0]==0)begin
                        af_gray_nxt[5][3] = af_gray[0][0] + (rdata_s_inf[111:104] >> 2);af_gray_nxt[5][4] = af_gray[0][1] + (rdata_s_inf[119:112]>> 2);af_gray_nxt[5][5] = af_gray[0][2] + (rdata_s_inf[127:120]>> 2); 
                    end
                    else begin
                        af_gray_nxt[5][3] = af_gray[0][0] + (rdata_s_inf[7:0]>> 2);     af_gray_nxt[5][4] = af_gray[0][1] + (rdata_s_inf[15:8]>> 2);   af_gray_nxt[5][5] = af_gray[0][2] + (rdata_s_inf[23:16]>> 2);
                    end
                end

            end
            else begin
                af_gray_nxt[0][0] = af_gray[0][0];af_gray_nxt[0][1] = af_gray[0][1];af_gray_nxt[0][2] = af_gray[0][2];af_gray_nxt[0][3] = af_gray[0][3];af_gray_nxt[0][4] = af_gray[0][4];af_gray_nxt[0][5] = af_gray[0][5];
                af_gray_nxt[1][0] = af_gray[1][0];af_gray_nxt[1][1] = af_gray[1][1];af_gray_nxt[1][2] = af_gray[1][2];af_gray_nxt[1][3] = af_gray[1][3];af_gray_nxt[1][4] = af_gray[1][4];af_gray_nxt[1][5] = af_gray[1][5];
                af_gray_nxt[2][0] = af_gray[2][0];af_gray_nxt[2][1] = af_gray[2][1];af_gray_nxt[2][2] = af_gray[2][2];af_gray_nxt[2][3] = af_gray[2][3];af_gray_nxt[2][4] = af_gray[2][4];af_gray_nxt[2][5] = af_gray[2][5];
                af_gray_nxt[3][0] = af_gray[3][0];af_gray_nxt[3][1] = af_gray[3][1];af_gray_nxt[3][2] = af_gray[3][2];af_gray_nxt[3][3] = af_gray[3][3];af_gray_nxt[3][4] = af_gray[3][4];af_gray_nxt[3][5] = af_gray[3][5];
                af_gray_nxt[4][0] = af_gray[4][0];af_gray_nxt[4][1] = af_gray[4][1];af_gray_nxt[4][2] = af_gray[4][2];af_gray_nxt[4][3] = af_gray[4][3];af_gray_nxt[4][4] = af_gray[4][4];af_gray_nxt[4][5] = af_gray[4][5];
                af_gray_nxt[5][0] = af_gray[5][0];af_gray_nxt[5][1] = af_gray[5][1];af_gray_nxt[5][2] = af_gray[5][2];af_gray_nxt[5][3] = af_gray[5][3];af_gray_nxt[5][4] = af_gray[5][4];af_gray_nxt[5][5] = af_gray[5][5];
            end
        end 
        S_AF_cal:begin
            if(cnt[2:0]==5)begin
                af_gray_nxt[0][0] = af_gray[0][1];af_gray_nxt[0][1] = af_gray[1][1];af_gray_nxt[0][2] = af_gray[2][1];af_gray_nxt[0][3] = af_gray[3][1];af_gray_nxt[0][4] = af_gray[4][1];af_gray_nxt[0][5] = af_gray[5][1];
                af_gray_nxt[1][0] = af_gray[0][2];af_gray_nxt[1][1] = af_gray[1][2];af_gray_nxt[1][2] = af_gray[2][2];af_gray_nxt[1][3] = af_gray[3][2];af_gray_nxt[1][4] = af_gray[4][2];af_gray_nxt[1][5] = af_gray[5][2];
                af_gray_nxt[2][0] = af_gray[0][3];af_gray_nxt[2][1] = af_gray[1][3];af_gray_nxt[2][2] = af_gray[2][3];af_gray_nxt[2][3] = af_gray[3][3];af_gray_nxt[2][4] = af_gray[4][3];af_gray_nxt[2][5] = af_gray[5][3];
                af_gray_nxt[3][0] = af_gray[0][4];af_gray_nxt[3][1] = af_gray[1][4];af_gray_nxt[3][2] = af_gray[2][4];af_gray_nxt[3][3] = af_gray[3][4];af_gray_nxt[3][4] = af_gray[4][4];af_gray_nxt[3][5] = af_gray[5][4];
                af_gray_nxt[4][0] = af_gray[0][5];af_gray_nxt[4][1] = af_gray[1][5];af_gray_nxt[4][2] = af_gray[2][5];af_gray_nxt[4][3] = af_gray[3][5];af_gray_nxt[4][4] = af_gray[4][5];af_gray_nxt[4][5] = af_gray[5][5];
                af_gray_nxt[5][0] = af_gray[0][0];af_gray_nxt[5][1] = af_gray[1][0];af_gray_nxt[5][2] = af_gray[2][0];af_gray_nxt[5][3] = af_gray[3][0];af_gray_nxt[5][4] = af_gray[4][0];af_gray_nxt[5][5] = af_gray[5][0];
            end
            else begin
                af_gray_nxt[0][0] = af_gray[0][1];af_gray_nxt[0][1] = af_gray[0][2];af_gray_nxt[0][2] = af_gray[0][3];af_gray_nxt[0][3] = af_gray[0][4];af_gray_nxt[0][4] = af_gray[0][5];af_gray_nxt[0][5] = af_gray[0][0];
                af_gray_nxt[1][0] = af_gray[1][1];af_gray_nxt[1][1] = af_gray[1][2];af_gray_nxt[1][2] = af_gray[1][3];af_gray_nxt[1][3] = af_gray[1][4];af_gray_nxt[1][4] = af_gray[1][5];af_gray_nxt[1][5] = af_gray[1][0];
                af_gray_nxt[2][0] = af_gray[2][1];af_gray_nxt[2][1] = af_gray[2][2];af_gray_nxt[2][2] = af_gray[2][3];af_gray_nxt[2][3] = af_gray[2][4];af_gray_nxt[2][4] = af_gray[2][5];af_gray_nxt[2][5] = af_gray[2][0];
                af_gray_nxt[3][0] = af_gray[3][1];af_gray_nxt[3][1] = af_gray[3][2];af_gray_nxt[3][2] = af_gray[3][3];af_gray_nxt[3][3] = af_gray[3][4];af_gray_nxt[3][4] = af_gray[3][5];af_gray_nxt[3][5] = af_gray[3][0];
                af_gray_nxt[4][0] = af_gray[4][1];af_gray_nxt[4][1] = af_gray[4][2];af_gray_nxt[4][2] = af_gray[4][3];af_gray_nxt[4][3] = af_gray[4][4];af_gray_nxt[4][4] = af_gray[4][5];af_gray_nxt[4][5] = af_gray[4][0];
                af_gray_nxt[5][0] = af_gray[5][1];af_gray_nxt[5][1] = af_gray[5][2];af_gray_nxt[5][2] = af_gray[5][3];af_gray_nxt[5][3] = af_gray[5][4];af_gray_nxt[5][4] = af_gray[5][5];af_gray_nxt[5][5] = af_gray[5][0];
            end
        end
        S_AE:begin
            af_gray_nxt[0][0] = af_gray[3][0]; af_gray_nxt[0][1] = af_gray[3][1]; af_gray_nxt[0][2] = af_gray[3][2]; af_gray_nxt[0][3] = af_gray[3][3];af_gray_nxt[0][4] = af_gray[3][4];af_gray_nxt[0][5] = af_gray[3][5];
            af_gray_nxt[1][0] = af_gray[4][0]; af_gray_nxt[1][1] = af_gray[4][1]; af_gray_nxt[1][2] = af_gray[4][2]; af_gray_nxt[1][3] = af_gray[4][3];af_gray_nxt[1][4] = af_gray[4][4];af_gray_nxt[1][5] = af_gray[4][5];
            af_gray_nxt[2][0] = af_gray[5][0]; af_gray_nxt[2][1] = af_gray[5][1]; af_gray_nxt[2][2] = af_gray[5][2]; af_gray_nxt[2][3] = af_gray[5][3];af_gray_nxt[2][4] = af_gray[5][4];af_gray_nxt[2][5] = af_gray[5][5];

            af_gray_nxt[3][0] = I_tmp[0];      af_gray_nxt[3][1] = I_tmp[1];      af_gray_nxt[3][2] = I_tmp[2];      af_gray_nxt[3][3] = I_tmp[3];     af_gray_nxt[3][4] = I_tmp[4];     af_gray_nxt[3][5] = I_tmp[5];
            af_gray_nxt[4][0] = I_tmp[6];      af_gray_nxt[4][1] = I_tmp[7];      af_gray_nxt[4][2] = I_tmp[8];      af_gray_nxt[4][3] = I_tmp[9];     af_gray_nxt[4][4] = I_tmp[10];    af_gray_nxt[4][5] = I_tmp[11];
            af_gray_nxt[5][0] = I_tmp[12];     af_gray_nxt[5][1] = I_tmp[13];     af_gray_nxt[5][2] = I_tmp[14];     af_gray_nxt[5][3] = I_tmp[15];    af_gray_nxt[5][4] = 0;            af_gray_nxt[5][5] = 0;
        end
        default :begin
            af_gray_nxt[0][0] = af_gray[0][0];af_gray_nxt[0][1] = af_gray[0][1];af_gray_nxt[0][2] = af_gray[0][2];af_gray_nxt[0][3] = af_gray[0][3];af_gray_nxt[0][4] = af_gray[0][4];af_gray_nxt[0][5] = af_gray[0][5];
            af_gray_nxt[1][0] = af_gray[1][0];af_gray_nxt[1][1] = af_gray[1][1];af_gray_nxt[1][2] = af_gray[1][2];af_gray_nxt[1][3] = af_gray[1][3];af_gray_nxt[1][4] = af_gray[1][4];af_gray_nxt[1][5] = af_gray[1][5];
            af_gray_nxt[2][0] = af_gray[2][0];af_gray_nxt[2][1] = af_gray[2][1];af_gray_nxt[2][2] = af_gray[2][2];af_gray_nxt[2][3] = af_gray[2][3];af_gray_nxt[2][4] = af_gray[2][4];af_gray_nxt[2][5] = af_gray[2][5];
            af_gray_nxt[3][0] = af_gray[3][0];af_gray_nxt[3][1] = af_gray[3][1];af_gray_nxt[3][2] = af_gray[3][2];af_gray_nxt[3][3] = af_gray[3][3];af_gray_nxt[3][4] = af_gray[3][4];af_gray_nxt[3][5] = af_gray[3][5];
            af_gray_nxt[4][0] = af_gray[4][0];af_gray_nxt[4][1] = af_gray[4][1];af_gray_nxt[4][2] = af_gray[4][2];af_gray_nxt[4][3] = af_gray[4][3];af_gray_nxt[4][4] = af_gray[4][4];af_gray_nxt[4][5] = af_gray[4][5];
            af_gray_nxt[5][0] = af_gray[5][0];af_gray_nxt[5][1] = af_gray[5][1];af_gray_nxt[5][2] = af_gray[5][2];af_gray_nxt[5][3] = af_gray[5][3];af_gray_nxt[5][4] = af_gray[5][4];af_gray_nxt[5][5] = af_gray[5][5];
        end
    endcase
end

/*always @(*) begin
    R_nxt = R;
    case (cur_state)
        S_AF_read:begin
            if(R_read)begin
                R_nxt[0][0] = R[0][3];R_nxt[0][1] = R[0][4];R_nxt[0][2] = R[0][5];R_nxt[0][3] = R[1][0];R_nxt[0][4] = R[1][1];R_nxt[0][5] = R[1][2];
                R_nxt[1][0] = R[1][3];R_nxt[1][1] = R[1][4];R_nxt[1][2] = R[1][5];R_nxt[1][3] = R[2][0];R_nxt[1][4] = R[2][1];R_nxt[1][5] = R[2][2];
                R_nxt[2][0] = R[2][3];R_nxt[2][1] = R[2][4];R_nxt[2][2] = R[2][5];R_nxt[2][3] = R[3][0];R_nxt[2][4] = R[3][1];R_nxt[2][5] = R[3][2];
                R_nxt[3][0] = R[3][3];R_nxt[3][1] = R[3][4];R_nxt[3][2] = R[3][5];R_nxt[3][3] = R[4][0];R_nxt[3][4] = R[4][1];R_nxt[3][5] = R[4][2];
                R_nxt[4][0] = R[4][3];R_nxt[4][1] = R[4][4];R_nxt[4][2] = R[4][5];R_nxt[4][3] = R[5][0];R_nxt[4][4] = R[5][1];R_nxt[4][5] = R[5][2];
                R_nxt[5][0] = R[5][3];R_nxt[5][1] = R[5][4];R_nxt[5][2] = R[5][5];
                if(cnt[0]==0)begin
                    R_nxt[5][3] = rdata_s_inf[111:104] ;R_nxt[5][4] = rdata_s_inf[119:112];R_nxt[5][5] = rdata_s_inf[127:120]; 
                end
                else begin
                    R_nxt[5][3] = rdata_s_inf[7:0];     R_nxt[5][4] = rdata_s_inf[15:8];   R_nxt[5][5] = rdata_s_inf[23:16];
                end
            end
        end 
        
    endcase
end
generate
	for(i=0;i<6;i=i+1) begin
		for(j=0;j<6;j=j+1) begin
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n)
					R[i][j] <= 0;
				else
					R[i][j] <= R_nxt[i][j];	
			end
		end
	end
endgenerate*/
//================================================================//
//                            AF CAL
//================================================================//
reg signed[8:0]sub_af_z1;
reg signed[8:0]sub_af_z2;
reg signed[8:0]sub_af_z3;
reg signed[8:0]sub_af_z4;
reg signed[8:0]sub_af_z5;

reg [8:0]pos_value_z1;
reg [8:0]pos_value_z2;
reg [8:0]pos_value_z3;
reg [8:0]pos_value_z4;
reg [8:0]pos_value_z5;
reg [9:0] af_8b_z1;
reg [9:0] af_8b_z2;
reg [9:0] af_8b_z3;
reg [10:0]af_9b_z1;
reg [10:0]af_9b_z2;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        diff_2x2_sum <= 0;
        diff_4x4_sum <= 0;
        diff_6x6_sum <= 0;
    end
    else begin
        diff_2x2_sum <= diff_2x2_sum_nxt;
        diff_4x4_sum <= diff_4x4_sum_nxt;
        diff_6x6_sum <= diff_6x6_sum_nxt;
    end 
end

always @(*) begin
    case (cur_state)
        /*S_AF_cal:begin
            if(af_gray[0][0] > af_gray[1][0])begin
                add_8B_a1 =  af_gray[0][0];
                add_8B_b1 = -af_gray[1][0];
            end
            else begin
                add_8B_a1 = -af_gray[0][0];
                add_8B_b1 =  af_gray[1][0];
            end
            if(af_gray[1][0] > af_gray[2][0])begin
                add_8B_a2 =  af_gray[1][0];
                add_8B_b2 = -af_gray[2][0];
            end
            else begin
                add_8B_a2 = -af_gray[1][0];
                add_8B_b2 =  af_gray[2][0];
            end
            if(af_gray[2][0] > af_gray[3][0])begin
                add_8B_a3 =  af_gray[2][0];
                add_8B_b3 = -af_gray[3][0];
            end
            else begin
                add_8B_a3 = -af_gray[2][0];
                add_8B_b3 =  af_gray[3][0];
            end
            if(af_gray[3][0] > af_gray[4][0])begin
                add_8B_a4 =  af_gray[3][0];
                add_8B_b4 = -af_gray[4][0];
            end
            else begin
                add_8B_a4 = -af_gray[3][0];
                add_8B_b4 =  af_gray[4][0];
            end
            if(af_gray[4][0] > af_gray[5][0])begin
                add_8B_a5 =  af_gray[4][0];
                add_8B_b5 = -af_gray[5][0];
            end
            else begin
                add_8B_a5 = -af_gray[4][0];
                add_8B_b5 =  af_gray[5][0];
            end
            add_8B_a6 = 0;
            add_8B_b6 = 0;
            add_8B_a7 = 0;
            add_8B_b7 = 0;
            add_8B_a8 = 0;
            add_8B_b8 = 0;
        end*/
        S_AE:begin
            if(G_read_reg)begin
                add_8B_a1 = I_tmp[0 ] >> 1;
                add_8B_b1 = I_tmp[1 ] >> 1;
                add_8B_a2 = I_tmp[2 ] >> 1;
                add_8B_b2 = I_tmp[3 ] >> 1;
                add_8B_a3 = I_tmp[4 ] >> 1;
                add_8B_b3 = I_tmp[5 ] >> 1;
                add_8B_a4 = I_tmp[6 ] >> 1;
                add_8B_b4 = I_tmp[7 ] >> 1;
                add_8B_a5 = I_tmp[8 ] >> 1;
                add_8B_b5 = I_tmp[9 ] >> 1;
                add_8B_a6 = I_tmp[10] >> 1;
                add_8B_b6 = I_tmp[11] >> 1;
                add_8B_a7 = I_tmp[12] >> 1;
                add_8B_b7 = I_tmp[13] >> 1;
                add_8B_a8 = I_tmp[14] >> 1;
                add_8B_b8 = I_tmp[15] >> 1;
            end
            else begin
                add_8B_a1 = I_tmp[0 ] >> 2;
                add_8B_b1 = I_tmp[1 ] >> 2;
                add_8B_a2 = I_tmp[2 ] >> 2;
                add_8B_b2 = I_tmp[3 ] >> 2;
                add_8B_a3 = I_tmp[4 ] >> 2;
                add_8B_b3 = I_tmp[5 ] >> 2;
                add_8B_a4 = I_tmp[6 ] >> 2;
                add_8B_b4 = I_tmp[7 ] >> 2;
                add_8B_a5 = I_tmp[8 ] >> 2;
                add_8B_b5 = I_tmp[9 ] >> 2;
                add_8B_a6 = I_tmp[10] >> 2;
                add_8B_b6 = I_tmp[11] >> 2;
                add_8B_a7 = I_tmp[12] >> 2;
                add_8B_b7 = I_tmp[13] >> 2;
                add_8B_a8 = I_tmp[14] >> 2;
                add_8B_b8 = I_tmp[15] >> 2;
            end
        end
        default:begin
            add_8B_a1 = 0;
            add_8B_b1 = 0;
            add_8B_a2 = 0;
            add_8B_b2 = 0;
            add_8B_a3 = 0;
            add_8B_b3 = 0;
            add_8B_a4 = 0;
            add_8B_b4 = 0;
            add_8B_a5 = 0;
            add_8B_b5 = 0;
            add_8B_a6 = 0;
            add_8B_b6 = 0;
            add_8B_a7 = 0;
            add_8B_b7 = 0;
            add_8B_a8 = 0;
            add_8B_b8 = 0;
        end
    endcase
end
assign sub_af_z1 = af_gray[0][0] - af_gray[1][0];
assign sub_af_z2 = af_gray[1][0] - af_gray[2][0];
assign sub_af_z3 = af_gray[2][0] - af_gray[3][0];
assign sub_af_z4 = af_gray[3][0] - af_gray[4][0];
assign sub_af_z5 = af_gray[4][0] - af_gray[5][0];
assign pos_value_z1 = sub_af_z1[8] ? -sub_af_z1 : sub_af_z1;
assign pos_value_z2 = sub_af_z2[8] ? -sub_af_z2 : sub_af_z2;
assign pos_value_z3 = sub_af_z3[8] ? -sub_af_z3 : sub_af_z3;
assign pos_value_z4 = sub_af_z4[8] ? -sub_af_z4 : sub_af_z4;
assign pos_value_z5 = sub_af_z5[8] ? -sub_af_z5 : sub_af_z5;
assign af_8b_z1 = pos_value_z2 + pos_value_z3;
assign af_8b_z2 = pos_value_z1 + pos_value_z4;
assign af_8b_z3 = af_8b_z1     + pos_value_z4;

assign af_9b_z1 = af_8b_z1 + af_8b_z2;
assign af_9b_z2 = af_9b_z1 + pos_value_z5;
always @(*) begin
    if(!(|cnt[3:0]))begin
        diff_6x6_sum_nxt = af_9b_z2;
        //diff_6x6_sum_nxt = add_10B_z2;
    end
    else if(cnt[3]&&cnt[2])begin
        diff_6x6_sum_nxt = (diff_6x6_sum >> 2) / 9;
    end
    else
        diff_6x6_sum_nxt = diff_6x6_sum + af_9b_z2;
        //diff_6x6_sum_nxt = diff_6x6_sum + add_10B_z2;
end
always @(*) begin
    diff_2x2_sum_nxt = diff_2x2_sum;
    diff_4x4_sum_nxt = diff_4x4_sum;
    //diff_6x6_sum_nxt = diff_6x6_sum;
    case (cnt[3:0])
        //0:diff_6x6_sum_nxt = add_10B_z2;
        1:begin
            diff_4x4_sum_nxt = af_8b_z3;
            //diff_4x4_sum_nxt = add_9B_z3;
            //diff_6x6_sum_nxt = diff_6x6_sum + add_10B_z2;
        end
        2:begin
            diff_2x2_sum_nxt = pos_value_z3;
            //diff_2x2_sum_nxt = add_8B_z3;
            diff_4x4_sum_nxt = diff_4x4_sum + af_8b_z3;
            //diff_4x4_sum_nxt = diff_4x4_sum + add_9B_z3;
            //diff_6x6_sum_nxt = diff_6x6_sum + add_10B_z2;
        end
        3,8,9: begin
            diff_2x2_sum_nxt = diff_2x2_sum + pos_value_z3;
            //diff_2x2_sum_nxt = diff_2x2_sum + add_8B_z3;
            diff_4x4_sum_nxt = diff_4x4_sum + af_8b_z3;
            //diff_4x4_sum_nxt = diff_4x4_sum + add_9B_z3;
            //diff_6x6_sum_nxt = diff_6x6_sum + add_10B_z2;
        end
        4,7,10:begin
            diff_2x2_sum_nxt = diff_2x2_sum;
            diff_4x4_sum_nxt = diff_4x4_sum + af_8b_z3;
            //diff_4x4_sum_nxt = diff_4x4_sum + add_9B_z3;
            //diff_6x6_sum_nxt = diff_6x6_sum + add_10B_z2;
        end
        5,6,11:begin
            diff_2x2_sum_nxt = diff_2x2_sum;
            diff_4x4_sum_nxt = diff_4x4_sum;
            //diff_6x6_sum_nxt = diff_6x6_sum + add_10B_z2;
        end
        12:begin
            diff_2x2_sum_nxt = diff_2x2_sum >> 2;
            diff_4x4_sum_nxt = diff_4x4_sum >> 4;
            //diff_6x6_sum_nxt = (diff_6x6_sum >> 2) / 9;
        end
    endcase    
end

//================================================================//
//                            AE CAL
//================================================================//

always @(*) begin
    case (in_ratio_mode_reg)
        0: right_shift_times = 2;
        1: right_shift_times = 1;
        2: right_shift_times = 0;
        default: right_shift_times = 0;
    endcase
end
always @(*) begin
    case (cur_state)
        S_AE: begin
            if(&in_ratio_mode_reg)begin
                I_tmp_nxt[0 ] = rdata_reg[127] ? 255 : rdata_reg[127:120] << 1;             
                I_tmp_nxt[1 ] = rdata_reg[119] ? 255 : rdata_reg[119:112] << 1;             
                I_tmp_nxt[2 ] = rdata_reg[111] ? 255 : rdata_reg[111:104] << 1;             
                I_tmp_nxt[3 ] = rdata_reg[103] ? 255 : rdata_reg[103:96]  << 1;             
                I_tmp_nxt[4 ] = rdata_reg[95]  ? 255 : rdata_reg[95:88]   << 1;             
                I_tmp_nxt[5 ] = rdata_reg[87]  ? 255 : rdata_reg[87:80]   << 1;             
                I_tmp_nxt[6 ] = rdata_reg[79]  ? 255 : rdata_reg[79:72]   << 1;             
                I_tmp_nxt[7 ] = rdata_reg[71]  ? 255 : rdata_reg[71:64]   << 1;             
                I_tmp_nxt[8 ] = rdata_reg[63]  ? 255 : rdata_reg[63:56]   << 1;
                I_tmp_nxt[9 ] = rdata_reg[55]  ? 255 : rdata_reg[55:48]   << 1;
                I_tmp_nxt[10] = rdata_reg[47]  ? 255 : rdata_reg[47:40]   << 1;
                I_tmp_nxt[11] = rdata_reg[39]  ? 255 : rdata_reg[39:32]   << 1;
                I_tmp_nxt[12] = rdata_reg[31]  ? 255 : rdata_reg[31:24]   << 1;
                I_tmp_nxt[13] = rdata_reg[23]  ? 255 : rdata_reg[23:16]   << 1;
                I_tmp_nxt[14] = rdata_reg[15]  ? 255 : rdata_reg[15:8]    << 1;
                I_tmp_nxt[15] = rdata_reg[7 ]  ? 255 : rdata_reg[7 :0]    << 1;
            end
            else begin
                I_tmp_nxt[0 ] = rdata_reg[127:120] >> right_shift_times;
                I_tmp_nxt[1 ] = rdata_reg[119:112] >> right_shift_times;
                I_tmp_nxt[2 ] = rdata_reg[111:104] >> right_shift_times;
                I_tmp_nxt[3 ] = rdata_reg[103:96]  >> right_shift_times;
                I_tmp_nxt[4 ] = rdata_reg[95:88]   >> right_shift_times;
                I_tmp_nxt[5 ] = rdata_reg[87:80]   >> right_shift_times;
                I_tmp_nxt[6 ] = rdata_reg[79:72]   >> right_shift_times;
                I_tmp_nxt[7 ] = rdata_reg[71:64]   >> right_shift_times;
                I_tmp_nxt[8 ] = rdata_reg[63:56]   >> right_shift_times;
                I_tmp_nxt[9 ] = rdata_reg[55:48]   >> right_shift_times;
                I_tmp_nxt[10] = rdata_reg[47:40]   >> right_shift_times;
                I_tmp_nxt[11] = rdata_reg[39:32]   >> right_shift_times;
                I_tmp_nxt[12] = rdata_reg[31:24]   >> right_shift_times;
                I_tmp_nxt[13] = rdata_reg[23:16]   >> right_shift_times;
                I_tmp_nxt[14] = rdata_reg[15:8]    >> right_shift_times;
                I_tmp_nxt[15] = rdata_reg[7 :0]    >> right_shift_times;
            end
            
        end
        default:begin
            I_tmp_nxt[0 ] = 0;
            I_tmp_nxt[1 ] = 0;
            I_tmp_nxt[2 ] = 0;
            I_tmp_nxt[3 ] = 0;
            I_tmp_nxt[4 ] = 0;
            I_tmp_nxt[5 ] = 0;
            I_tmp_nxt[6 ] = 0;
            I_tmp_nxt[7 ] = 0;
            I_tmp_nxt[8 ] = 0;
            I_tmp_nxt[9 ] = 0;
            I_tmp_nxt[10] = 0;
            I_tmp_nxt[11] = 0;
            I_tmp_nxt[12] = 0;
            I_tmp_nxt[13] = 0;
            I_tmp_nxt[14] = 0;
            I_tmp_nxt[15] = 0;
        end 
    endcase
end
generate
	for(i=0;i<16;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                I_tmp[i] <= 0;
            else
                I_tmp[i] <= I_tmp_nxt[i];
        end
	end
endgenerate
always @(*) begin
    case (cur_state)
        S_IDLE:pixel_sum_nxt = 0;
        S_AE:  pixel_sum_nxt = wvalid_s_inf ? pixel_sum + add_11B_reg : pixel_sum;
        default: pixel_sum_nxt = 0;
    endcase
    
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        pixel_sum <= 0;
    end
    else begin
        pixel_sum <= pixel_sum_nxt;
    end
end
/*always @(*) begin
    case (cur_state)
        S_IDLE:begin
            adj_pic_reg1_nxt = 0;
        end
        S_AE:begin
            adj_pic_reg1_nxt = {af_gray[0][0],af_gray[0][1],af_gray[0][2],af_gray[0][3],af_gray[0][4],af_gray[0][5],
                                af_gray[1][0],af_gray[1][1],af_gray[1][2],af_gray[1][3],af_gray[1][4],af_gray[1][5],
                                af_gray[2][0],af_gray[2][1],af_gray[2][2],af_gray[2][3]
                                };
        end 
        default: begin
            adj_pic_reg1_nxt = 0;
        end 
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        adj_pic_reg1 <= 0;
    end
    else begin
        adj_pic_reg1 <= adj_pic_reg1_nxt;
    end
end*/
//================================================================//
//                            ADDER
//================================================================//
always @(*) begin
    case (cur_state)
        /*S_AF_cal:begin
            add_9B_a1 = add_8B_z2;
            add_9B_b1 = add_8B_z3;
            add_9B_a2 = add_8B_z1;
            add_9B_b2 = add_8B_z4;
            //for 4x4 extra adder
            add_9B_a3 = add_9B_z1;
            add_9B_b3 = add_8B_z4;
            add_9B_a4 = 0;
            add_9B_b4 = 0;
        end */
        S_AE:begin
            add_9B_a1 = add_8B_z1;
            add_9B_b1 = add_8B_z2;
            add_9B_a2 = add_8B_z3;
            add_9B_b2 = add_8B_z4;
            add_9B_a3 = add_8B_z5;
            add_9B_b3 = add_8B_z6;
            add_9B_a4 = add_8B_z7;
            add_9B_b4 = add_8B_z8;
        end
        default:begin
            add_9B_a1 = 0;
            add_9B_b1 = 0;
            add_9B_a2 = 0;
            add_9B_b2 = 0;
            add_9B_a3 = 0;
            add_9B_b3 = 0;
            add_9B_a4 = 0;
            add_9B_b4 = 0;
        end
    endcase
end
always @(*) begin
    case (cur_state)
        /*S_AF_cal:begin
            add_10B_a1 = add_9B_z1;
            add_10B_b1 = add_9B_z2;
            add_10B_a2 = add_10B_z1;
            add_10B_b2 = add_8B_z5;
        end */
        S_AE:begin
            add_10B_a1 = add_9B_z1;
            add_10B_b1 = add_9B_z2;
            add_10B_a2 = add_9B_z3;
            add_10B_b2 = add_9B_z4;
        end
        default:begin
            add_10B_a1 = 0;
            add_10B_b1 = 0;
            add_10B_a2 = 0;
            add_10B_b2 = 0;
        end
    endcase
end
//adder
assign add_8B_z1 = add_8B_a1 + add_8B_b1;
assign add_8B_z2 = add_8B_a2 + add_8B_b2;
assign add_8B_z3 = add_8B_a3 + add_8B_b3;
assign add_8B_z4 = add_8B_a4 + add_8B_b4;
assign add_8B_z5 = add_8B_a5 + add_8B_b5;
assign add_8B_z6 = add_8B_a6 + add_8B_b6;
assign add_8B_z7 = add_8B_a7 + add_8B_b7;
assign add_8B_z8 = add_8B_a8 + add_8B_b8;

assign add_9B_z1 = add_9B_a1 + add_9B_b1;
assign add_9B_z2 = add_9B_a2 + add_9B_b2;
assign add_9B_z3 = add_9B_a3 + add_9B_b3;
assign add_9B_z4 = add_9B_a4 + add_9B_b4;

assign add_10B_z1 = add_10B_a1 + add_10B_b1;
assign add_10B_z2 = add_10B_a2 + add_10B_b2;

assign add_11B_z1 = add_10B_z1 + add_10B_z2;
//================================================================//
//                             Cnt
//================================================================//
always @(*) begin
    case (cur_state)
        S_IDLE:cnt_nxt = 0;
        S_AF_read:begin
            if(cnt==139)begin
                cnt_nxt = 0;
            end
            else begin
                cnt_nxt = rvalid_s_inf ? cnt + 1 : cnt;
            end
        end

        S_AF_cal:begin
            cnt_nxt = cnt + 1;
        end
        S_AE:begin
            if(cnt==195)begin
                cnt_nxt = 0;
            end
            else begin
                cnt_nxt = (rvalid_s_inf || wready_s_inf) ? cnt + 1 : cnt;
            end
        end
        default: cnt_nxt = 0;
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_nxt;
    end
end
//================================================================//
//                       Write Control
//================================================================//
//awid
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awid_s_inf <= 0;
    end
    else begin
        awid_s_inf <= 0;
    end
end
//awaddr
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awaddr_s_inf <= 0;
   
    end
    else begin
        awaddr_s_inf <= awaddr_s_inf_nxt ;

    end
end
always @(*) begin
    if(in_valid)begin
        awaddr_s_inf_nxt = 32'h10000 + ((in_pic_no*3)<<10);
    end
    else awaddr_s_inf_nxt = awaddr_s_inf;
end
//awlen
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awlen_s_inf <= 0;
    end
    else begin
        awlen_s_inf <= 191;
    end
end
//awsize
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awsize_s_inf <= 0;
    end
    else begin
        awsize_s_inf <= 4;
    end
end
//awburst
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awburst_s_inf <= 0;
    end
    else begin
        awburst_s_inf <= 1;
    end
end
//awvalid
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        awvalid_s_inf <= 0;
    end
    else begin
        awvalid_s_inf <= aw_valid_nxt;
    end
end
always @(*) begin
    if(cur_state == S_IDLE && nxt_state == S_AE && !zreo_flag_nxt) 
        aw_valid_nxt = 1;
    else begin
        aw_valid_nxt = (awready_s_inf) ? 0 : awvalid_s_inf;
    end
end

//wdata
/*always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wdata_s_inf <= 0;
    end
    else begin
        wdata_s_inf <= wdata_nxt;
    end
end*/
always @(*) begin 
    if(!rst_n)begin
        wdata_s_inf = 0;
    end
    else begin
        wdata_s_inf = (cnt>=4 && cnt <= 195) ? {af_gray[0][0],af_gray[0][1],af_gray[0][2],af_gray[0][3],af_gray[0][4],af_gray[0][5],
                                af_gray[1][0],af_gray[1][1],af_gray[1][2],af_gray[1][3],af_gray[1][4],af_gray[1][5],
                                af_gray[2][0],af_gray[2][1],af_gray[2][2],af_gray[2][3]
                                } : 0;
    end
    
end
//wlast
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wlast_s_inf <= 0;
    end
    else begin
        wlast_s_inf <= wlast_nxt;
    end
end
always @(*) begin 
    wlast_nxt = (cnt == 194 && cur_state == S_AE) ? 1 : 0;
end
//wvalid
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wvalid_s_inf <= 0;
    end
    else begin
        wvalid_s_inf <= wvalid_nxt;
    end
end
always @(*) begin 
    if(rvalid_s_inf && !rvalid_reg && cur_state == S_AE)begin
        wvalid_nxt = 1;
    end
    else begin
        if(wlast_s_inf) wvalid_nxt = 0;
        else            wvalid_nxt = wvalid_s_inf;
    end
end
//bready
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bready_s_inf <= 0;
    end
    else begin
        bready_s_inf <= bready_nxt;
    end
end
always @(*) begin 
    if(rvalid_s_inf && !rvalid_reg && cur_state == S_AE)begin
        bready_nxt = 1;
    end
    else begin
        if(bvalid_s_inf) bready_nxt = 0;
        else             bready_nxt = bready_s_inf;
    end
end
//================================================================//
//                         STEAL CYCLE
//================================================================//
generate
	for(i=0;i<16;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                img_data_zero[i] <= 8;
            else
                img_data_zero[i] <= img_data_zero_nxt[i];
        end
	end
endgenerate
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        zreo_flag <= 0;
    else
        zreo_flag <= zreo_flag_nxt;
end
always @(*) begin
    img_data_zero_nxt = img_data_zero;
    zreo_flag_nxt = zreo_flag;
    if(in_valid)begin
        if(img_data_zero[in_pic_no] > 0)begin
            if(in_mode)begin
                case (in_ratio_mode)
                    0: img_data_zero_nxt[in_pic_no] = img_data_zero[in_pic_no] - 2 ;
                    1: img_data_zero_nxt[in_pic_no] = img_data_zero[in_pic_no] - 1 ;
                    2: img_data_zero_nxt[in_pic_no] = img_data_zero[in_pic_no]     ;
                    3: img_data_zero_nxt[in_pic_no] = img_data_zero[in_pic_no] + 1 ;
                    default: img_data_zero_nxt[in_pic_no] = img_data_zero[in_pic_no];
                endcase
            end 
            zreo_flag_nxt = 0;
        end
        else begin
            img_data_zero_nxt[in_pic_no] = 0;
            zreo_flag_nxt = 1;
        end  
    end
end


//================================================================//
//                            Out
//================================================================//
always @(*) begin
    case (cur_state)
        S_AF_cal: begin
            if(cnt == 13)begin
                if(diff_2x2_sum >= diff_4x4_sum && diff_2x2_sum >= diff_6x6_sum)
                    out_data_nxt = 0;
                else if(diff_4x4_sum > diff_2x2_sum && diff_4x4_sum >= diff_6x6_sum)
                    out_data_nxt = 1;
                else
                    out_data_nxt = 2;
            end
            else out_data_nxt = 0;
        end
        S_AE:begin
            if(cnt==194)begin
                out_data_nxt = pixel_sum >> 10 ;
            end
            else
                out_data_nxt = 0;
        end
        default:  out_data_nxt = 0;
    endcase
    
end
always @(*) begin
    case (cur_state)
        S_AF_cal:begin
            out_valid_nxt = (cnt == 13) ? 1 : 0;
        end 
        S_AE:begin
            out_valid_nxt = (cnt == 194 || zreo_flag) ? 1 : 0;
        end
        S_AF_read:begin
            out_valid_nxt = (zreo_flag) ? 1 : 0;
        end
        default: out_valid_nxt =  0;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_data <= 0;
    end
    else begin
        out_data <= out_data_nxt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_nxt;
    end
end

endmodule
