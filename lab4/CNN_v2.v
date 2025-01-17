//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
parameter inst_rnd = 3'b000;
parameter inst_zctr = 1'b0;

parameter IDLE = 3'd0;
parameter IN = 3'd1;
parameter CAL = 3'd2;
parameter OUT = 3'd3;

integer i,j;
input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------

//I/0
reg opt_r,opt_nxt,opt_reg;
reg in_valid_reg;
reg [7:0]cnt,cnt_nxt;

reg [31:0]img[0:2][0:4],img_nxt[0:2][0:4];

reg [31:0]ker_ch1_1[0:1][0:1],ker_ch1_1_nxt[0:1][0:1];
reg [31:0]ker_ch2_1[0:1][0:1],ker_ch2_1_nxt[0:1][0:1];
reg [31:0]ker_ch1_2[0:1][0:1],ker_ch1_2_nxt[0:1][0:1];
reg [31:0]ker_ch2_2[0:1][0:1],ker_ch2_2_nxt[0:1][0:1];
reg [31:0]ker_ch1_3[0:1][0:1],ker_ch1_3_nxt[0:1][0:1];
reg [31:0]ker_ch2_3[0:1][0:1],ker_ch2_3_nxt[0:1][0:1];

reg [31:0]weigh_1[0:7],weigh_1_nxt[0:7];
reg [31:0]weigh_2[0:7],weigh_2_nxt[0:7];
reg [31:0]weigh_3[0:7],weigh_3_nxt[0:7];

reg [31:0]feature_map_1[0:5][0:5],feature_map_1_nxt[0:5][0:5];
reg [31:0]feature_map_2[0:5][0:5],feature_map_2_nxt[0:5][0:5];
reg [2:0]idx,jdy;

reg [31:0]_kernel_1[0:1][0:1];
reg [31:0]_kernel_2[0:1][0:1];
//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
reg [31:0] inst_a1,inst_a2,inst_a3, inst_a4, inst_a5, inst_a6 ,inst_a7 ,inst_a8 ,inst_a9 ,inst_a10 ,inst_a11 ,inst_a12 ,inst_add_a1 ,inst_add_a2 ,inst_add_a3,inst_add_a4,inst_add_a5,inst_add_a6;
reg [31:0] inst_b1,inst_b2,inst_b3, inst_b4, inst_b5, inst_b6 ,inst_b7 ,inst_b8 ,inst_b9 ,inst_b10 ,inst_b11 ,inst_b12 ,inst_add_b1 ,inst_add_b2 ,inst_add_b3,inst_add_b4,inst_add_b5,inst_add_b6;
reg [31:0] inst_c1,inst_c2,inst_c3, inst_c4, inst_c5, inst_c6 ,inst_c7 ,inst_c8 ,inst_c9 ,inst_c10 ,inst_c11 ,inst_c12;
reg [31:0] z_inst1,z_inst2,z_inst3,z_inst4,z_inst5,z_inst6,z_inst7,z_inst8,z_inst9,z_inst10,z_inst11,z_inst12,z_inst_add1,z_inst_add2,z_inst_add3,z_inst_add4,z_inst_add5,z_inst_add6;
reg [31:0] inst_a1_cmp, inst_a2_cmp, inst_a3_cmp, inst_a4_cmp, inst_a5_cmp, inst_a6_cmp, inst_a7_cmp, inst_a8_cmp,inst_a9_cmp, inst_a10_cmp, inst_a11_cmp, inst_a12_cmp, inst_a13_cmp, inst_a14_cmp, inst_a15_cmp, inst_a16_cmp;
reg [31:0] inst_b1_cmp, inst_b2_cmp, inst_b3_cmp, inst_b4_cmp, inst_b5_cmp, inst_b6_cmp, inst_b7_cmp, inst_b8_cmp,inst_b9_cmp, inst_b10_cmp, inst_b11_cmp, inst_b12_cmp, inst_b13_cmp, inst_b14_cmp, inst_b15_cmp, inst_b16_cmp;
reg [31:0] z_inst1_cmp_min, z_inst2_cmp_min, z_inst3_cmp_min, z_inst4_cmp_min, z_inst5_cmp_min, z_inst6_cmp_min, z_inst7_cmp_min, z_inst8_cmp_min,z_inst9_cmp_min, z_inst10_cmp_min, z_inst11_cmp_min, z_inst12_cmp_min, z_inst13_cmp_min, z_inst14_cmp_min, z_inst15_cmp_min, z_inst16_cmp_min;
reg [31:0] z_inst1_cmp_max, z_inst2_cmp_max, z_inst3_cmp_max, z_inst4_cmp_max, z_inst5_cmp_max, z_inst6_cmp_max, z_inst7_cmp_max, z_inst8_cmp_max,z_inst9_cmp_max, z_inst10_cmp_max, z_inst11_cmp_max, z_inst12_cmp_max, z_inst13_cmp_max, z_inst14_cmp_max, z_inst15_cmp_max, z_inst16_cmp_max;
reg [31:0] inst_a_exp_1,inst_a_exp_2,inst_a_exp_3;
reg [31:0] z_inst_exp_1,z_inst_exp_2,z_inst_exp_3;
reg [31:0] inst_add_a7,inst_add_a8;
reg [31:0] inst_add_b7,inst_add_b8;
reg [31:0] z_inst_add7,z_inst_add8;
reg [31:0] inst_add_aAF1,inst_add_bAF1,z_inst_addAF1;
reg [31:0] inst_add_aAF2,inst_add_bAF2,z_inst_addAF2;
reg [31:0] inst_add_aAF3,inst_add_bAF3,z_inst_addAF3;
reg [31:0] inst_add_aAF4,inst_add_bAF4,z_inst_addAF4;
reg [31:0] inst_a_div,inst_b_div,z_inst_div;
reg [31:0] MaxPool[0:7],MaxPool_nxt[0:7];
reg [31:0] Divisor[0:7],Dividend[0:7],Divisor_nxt[0:7],Dividend_nxt[0:7];
reg [31:0] FC[0:7],FC_nxt[0:7];

reg [31:0] FC_result[0:2],FC_result_nxt[0:2];
reg [31:0] Softmax  [0:3],Softmax_nxt[0:3];
//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        opt_reg<=0;
        opt_r<=0;
        in_valid_reg<=0;
    end
    else begin 
        opt_reg<=opt_nxt;
        opt_r<=Opt;
        in_valid_reg<=in_valid;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt<=0;
    end
    else begin 
        cnt<=cnt_nxt;
    end
end
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<3 ; i=i+1) begin
            for (j = 0;j<5 ; j=j+1) begin
                img[i][j] <= img_nxt[i][j];
            end
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<8 ; i=i+1) begin  
            FC_result[i] <= FC_result_nxt[i];
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<8 ; i=i+1) begin  
            MaxPool[i] <= MaxPool_nxt[i];
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<8 ; i=i+1) begin  
            Dividend[i] <=Dividend_nxt[i];
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<8 ; i=i+1) begin  
            Divisor[i] <= Divisor_nxt[i];
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<8 ; i=i+1) begin  
            FC[i] <= FC_nxt[i];
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<4 ; i=i+1) begin  
            Softmax[i] <= Softmax_nxt[i];
        end
    end
endgenerate
generate
    
    always @(posedge clk) begin
        for (i=0 ; i<2 ; i=i+1) begin
            for (j = 0;j<2 ; j=j+1) begin
                ker_ch1_1[i][j] <= ker_ch1_1_nxt[i][j];
                ker_ch2_1[i][j] <= ker_ch2_1_nxt[i][j];
                ker_ch1_2[i][j] <= ker_ch1_2_nxt[i][j];
                ker_ch2_2[i][j] <= ker_ch2_2_nxt[i][j];
                ker_ch1_3[i][j] <= ker_ch1_3_nxt[i][j];
                ker_ch2_3[i][j] <= ker_ch2_3_nxt[i][j];

            end
        end
    end
endgenerate
generate

    always @(posedge clk) begin
        for (i=0 ; i<8 ; i=i+1) begin
            weigh_1[i]<=weigh_1_nxt[i];
            weigh_2[i]<=weigh_2_nxt[i];
            weigh_3[i]<=weigh_3_nxt[i];
        end
    end
endgenerate
generate
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            for (i=0 ; i<6 ; i=i+1) begin
                for (j = 0;j<6 ; j=j+1) begin
                    feature_map_1[i][j] <= 0;
                end
            end
        end
        else begin
            for (i=0 ; i<6 ; i=i+1) begin
                for (j = 0;j<6 ; j=j+1) begin
                    feature_map_1[i][j] <= feature_map_1_nxt[i][j];
                end
            end 
        end
        
    end
endgenerate
generate
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            for (i=0 ; i<6 ; i=i+1) begin
                for (j = 0;j<6 ; j=j+1) begin
                    feature_map_2[i][j] <= 0;
                end
            end
        end
        else begin
            for (i=0 ; i<6 ; i=i+1) begin
                for (j = 0;j<6 ; j=j+1) begin
                    feature_map_2[i][j] <= feature_map_2_nxt[i][j];
                end
            end 
        end
        
    end
endgenerate
always @(*) begin
    if(in_valid==1 && in_valid_reg==0)begin
        opt_nxt=Opt;
    end
    else begin
        opt_nxt=opt_reg;
    end
    
end

//Cnt
always @(*) begin
    if(in_valid==1 && in_valid_reg==0)begin
        cnt_nxt = 1;
    end
    else begin
        if(cnt > 0 && cnt < 88) cnt_nxt = cnt + 1;
        else                    cnt_nxt = 0;
                      
    end
end
//----------------------------------------------------
//                  READ DATA
//----------------------------------------------------
//Weight
always @(*) begin
    if(cnt<24 && in_valid)begin
        weigh_1_nxt [0] = weigh_1 [1];  weigh_2_nxt [0] = weigh_2 [1]; weigh_3_nxt [0] = weigh_3 [1];
        weigh_1_nxt [1] = weigh_1 [2];  weigh_2_nxt [1] = weigh_2 [2]; weigh_3_nxt [1] = weigh_3 [2];
        weigh_1_nxt [2] = weigh_1 [3];  weigh_2_nxt [2] = weigh_2 [3]; weigh_3_nxt [2] = weigh_3 [3];
        weigh_1_nxt [3] = weigh_1 [4];  weigh_2_nxt [3] = weigh_2 [4]; weigh_3_nxt [3] = weigh_3 [4];
        weigh_1_nxt [4] = weigh_1 [5];  weigh_2_nxt [4] = weigh_2 [5]; weigh_3_nxt [4] = weigh_3 [5];
        weigh_1_nxt [5] = weigh_1 [6];  weigh_2_nxt [5] = weigh_2 [6]; weigh_3_nxt [5] = weigh_3 [6];
        weigh_1_nxt [6] = weigh_1 [7];  weigh_2_nxt [6] = weigh_2 [7]; weigh_3_nxt [6] = weigh_3 [7];
        weigh_1_nxt [7] = weigh_2 [0];  weigh_2_nxt [7] = weigh_3 [0]; weigh_3_nxt [7] = Weight;
    end
    else begin
        weigh_1_nxt [0] = weigh_1 [0];  weigh_2_nxt [0] = weigh_2 [0]; weigh_3_nxt [0] = weigh_3 [0];
        weigh_1_nxt [1] = weigh_1 [1];  weigh_2_nxt [1] = weigh_2 [1]; weigh_3_nxt [1] = weigh_3 [1];
        weigh_1_nxt [2] = weigh_1 [2];  weigh_2_nxt [2] = weigh_2 [2]; weigh_3_nxt [2] = weigh_3 [2];
        weigh_1_nxt [3] = weigh_1 [3];  weigh_2_nxt [3] = weigh_2 [3]; weigh_3_nxt [3] = weigh_3 [3];
        weigh_1_nxt [4] = weigh_1 [4];  weigh_2_nxt [4] = weigh_2 [4]; weigh_3_nxt [4] = weigh_3 [4];
        weigh_1_nxt [5] = weigh_1 [5];  weigh_2_nxt [5] = weigh_2 [5]; weigh_3_nxt [5] = weigh_3 [5];
        weigh_1_nxt [6] = weigh_1 [6];  weigh_2_nxt [6] = weigh_2 [6]; weigh_3_nxt [6] = weigh_3 [6];
        weigh_1_nxt [7] = weigh_1 [7];  weigh_2_nxt [7] = weigh_2 [7]; weigh_3_nxt [7] = weigh_3 [7];
    end
end
//Kernel_ch1
always @(*) begin
    //use shift register
    if(cnt < 4 && in_valid)begin
        ker_ch1_1_nxt[0][0] = ker_ch1_1[0][1]; ker_ch1_2_nxt[0][0] = ker_ch1_2[0][0]; ker_ch1_3_nxt[0][0] = ker_ch1_3[0][0];
        ker_ch1_1_nxt[0][1] = ker_ch1_1[1][0]; ker_ch1_2_nxt[0][1] = ker_ch1_2[0][1]; ker_ch1_3_nxt[0][1] = ker_ch1_3[0][1];
        ker_ch1_1_nxt[1][0] = ker_ch1_1[1][1]; ker_ch1_2_nxt[1][0] = ker_ch1_2[1][0]; ker_ch1_3_nxt[1][0] = ker_ch1_3[1][0];
        ker_ch1_1_nxt[1][1] = Kernel_ch1;      ker_ch1_2_nxt[1][1] = ker_ch1_2[1][1]; ker_ch1_3_nxt[1][1] = ker_ch1_3[1][1];
    end
    else if(cnt >= 4 && cnt <= 7)begin
        ker_ch1_1_nxt[0][0] = ker_ch1_1[0][0]; ker_ch1_2_nxt[0][0] = ker_ch1_2[0][1]; ker_ch1_3_nxt[0][0] = ker_ch1_3[0][0];
        ker_ch1_1_nxt[0][1] = ker_ch1_1[0][1]; ker_ch1_2_nxt[0][1] = ker_ch1_2[1][0]; ker_ch1_3_nxt[0][1] = ker_ch1_3[0][1];
        ker_ch1_1_nxt[1][0] = ker_ch1_1[1][0]; ker_ch1_2_nxt[1][0] = ker_ch1_2[1][1]; ker_ch1_3_nxt[1][0] = ker_ch1_3[1][0];
        ker_ch1_1_nxt[1][1] = ker_ch1_1[1][1]; ker_ch1_2_nxt[1][1] = Kernel_ch1;      ker_ch1_3_nxt[1][1] = ker_ch1_3[1][1];
    end
    else if(cnt >= 8 && cnt <= 11)begin
        ker_ch1_1_nxt[0][0] = ker_ch1_1[0][0]; ker_ch1_2_nxt[0][0] = ker_ch1_2[0][0]; ker_ch1_3_nxt[0][0] = ker_ch1_3[0][1];
        ker_ch1_1_nxt[0][1] = ker_ch1_1[0][1]; ker_ch1_2_nxt[0][1] = ker_ch1_2[0][1]; ker_ch1_3_nxt[0][1] = ker_ch1_3[1][0];
        ker_ch1_1_nxt[1][0] = ker_ch1_1[1][0]; ker_ch1_2_nxt[1][0] = ker_ch1_2[1][0]; ker_ch1_3_nxt[1][0] = ker_ch1_3[1][1];
        ker_ch1_1_nxt[1][1] = ker_ch1_1[1][1]; ker_ch1_2_nxt[1][1] = ker_ch1_2[1][1]; ker_ch1_3_nxt[1][1] = Kernel_ch1;
    end
    else begin
        ker_ch1_1_nxt[0][0] = ker_ch1_1[0][0]; ker_ch1_2_nxt[0][0] = ker_ch1_2[0][0]; ker_ch1_3_nxt[0][0] = ker_ch1_3[0][0];
        ker_ch1_1_nxt[0][1] = ker_ch1_1[0][1]; ker_ch1_2_nxt[0][1] = ker_ch1_2[0][1]; ker_ch1_3_nxt[0][1] = ker_ch1_3[0][1];
        ker_ch1_1_nxt[1][0] = ker_ch1_1[1][0]; ker_ch1_2_nxt[1][0] = ker_ch1_2[1][0]; ker_ch1_3_nxt[1][0] = ker_ch1_3[1][0];
        ker_ch1_1_nxt[1][1] = ker_ch1_1[1][1]; ker_ch1_2_nxt[1][1] = ker_ch1_2[1][1]; ker_ch1_3_nxt[1][1] = ker_ch1_3[1][1];
    end
end
//Kernel_ch2
always @(*) begin
    //use shift register
    if(cnt < 4 && in_valid)begin
        ker_ch2_1_nxt[0][0] = ker_ch2_1[0][1]; ker_ch2_2_nxt[0][0] = ker_ch2_2[0][0]; ker_ch2_3_nxt[0][0] = ker_ch2_3[0][0];
        ker_ch2_1_nxt[0][1] = ker_ch2_1[1][0]; ker_ch2_2_nxt[0][1] = ker_ch2_2[0][1]; ker_ch2_3_nxt[0][1] = ker_ch2_3[0][1];
        ker_ch2_1_nxt[1][0] = ker_ch2_1[1][1]; ker_ch2_2_nxt[1][0] = ker_ch2_2[1][0]; ker_ch2_3_nxt[1][0] = ker_ch2_3[1][0];
        ker_ch2_1_nxt[1][1] = Kernel_ch2;      ker_ch2_2_nxt[1][1] = ker_ch2_2[1][1]; ker_ch2_3_nxt[1][1] = ker_ch2_3[1][1];
    end
    else if(cnt >= 4 && cnt <= 7)begin
        ker_ch2_1_nxt[0][0] = ker_ch2_1[0][0]; ker_ch2_2_nxt[0][0] = ker_ch2_2[0][1]; ker_ch2_3_nxt[0][0] = ker_ch2_3[0][0];
        ker_ch2_1_nxt[0][1] = ker_ch2_1[0][1]; ker_ch2_2_nxt[0][1] = ker_ch2_2[1][0]; ker_ch2_3_nxt[0][1] = ker_ch2_3[0][1];
        ker_ch2_1_nxt[1][0] = ker_ch2_1[1][0]; ker_ch2_2_nxt[1][0] = ker_ch2_2[1][1]; ker_ch2_3_nxt[1][0] = ker_ch2_3[1][0];
        ker_ch2_1_nxt[1][1] = ker_ch2_1[1][1]; ker_ch2_2_nxt[1][1] = Kernel_ch2;      ker_ch2_3_nxt[1][1] = ker_ch2_3[1][1];
    end
    else if(cnt >= 8 && cnt <= 11)begin
        ker_ch2_1_nxt[0][0] = ker_ch2_1[0][0]; ker_ch2_2_nxt[0][0] = ker_ch2_2[0][0]; ker_ch2_3_nxt[0][0] = ker_ch2_3[0][1];
        ker_ch2_1_nxt[0][1] = ker_ch2_1[0][1]; ker_ch2_2_nxt[0][1] = ker_ch2_2[0][1]; ker_ch2_3_nxt[0][1] = ker_ch2_3[1][0];
        ker_ch2_1_nxt[1][0] = ker_ch2_1[1][0]; ker_ch2_2_nxt[1][0] = ker_ch2_2[1][0]; ker_ch2_3_nxt[1][0] = ker_ch2_3[1][1];
        ker_ch2_1_nxt[1][1] = ker_ch2_1[1][1]; ker_ch2_2_nxt[1][1] = ker_ch2_2[1][1]; ker_ch2_3_nxt[1][1] = Kernel_ch2;
    end
    else begin
        ker_ch2_1_nxt[0][0] = ker_ch2_1[0][0]; ker_ch2_2_nxt[0][0] = ker_ch2_2[0][0]; ker_ch2_3_nxt[0][0] = ker_ch2_3[0][0];
        ker_ch2_1_nxt[0][1] = ker_ch2_1[0][1]; ker_ch2_2_nxt[0][1] = ker_ch2_2[0][1]; ker_ch2_3_nxt[0][1] = ker_ch2_3[0][1];
        ker_ch2_1_nxt[1][0] = ker_ch2_1[1][0]; ker_ch2_2_nxt[1][0] = ker_ch2_2[1][0]; ker_ch2_3_nxt[1][0] = ker_ch2_3[1][0];
        ker_ch2_1_nxt[1][1] = ker_ch2_1[1][1]; ker_ch2_2_nxt[1][1] = ker_ch2_2[1][1]; ker_ch2_3_nxt[1][1] = ker_ch2_3[1][1];
    end
end
//IMG
always @(*) begin
    img_nxt = img;
    case (cnt)
        0,25,50:  img_nxt[0][0] = Img;
        1:        img_nxt[0][1] = Img;
        2,27,52:  img_nxt[0][2] = Img;
        3,28,53:  img_nxt[0][3] = Img;
        4,29,54:  img_nxt[0][4] = Img;
        5,30,55:  img_nxt[1][0] = Img;
        6,16,21,31,36,41,46,56,61,66,71:  img_nxt[1][1] = Img;
        7,12,17,22,32,37,42,47,57,62,67,72:  img_nxt[1][2] = Img;
        8,13,18,23,33,38,43,48,58,63,68,73:  img_nxt[1][3] = Img;
        9,14,19,24,34,39,44,49,59,64,69,74:  img_nxt[1][4] = Img;
        10: img_nxt[2][0] = Img;
        11: begin
            img_nxt[0][0] = img_nxt[1][0]; img_nxt[0][1] = img_nxt[1][1];img_nxt[0][2] = img_nxt[1][2];img_nxt[0][3] = img_nxt[1][3];img_nxt[0][4] = img_nxt[1][4];
            img_nxt[1][0] = img_nxt[2][0]; img_nxt[1][1] = img_nxt[2][1];img_nxt[1][2] = img_nxt[2][2];img_nxt[1][3] = img_nxt[2][3];img_nxt[1][4] = img_nxt[2][4];

            img_nxt[1][1] = Img;
        end
        15,20,35,40,45,60,65,70: begin
            img_nxt[0][0] = img_nxt[1][0]; img_nxt[0][1] = img_nxt[1][1];img_nxt[0][2] = img_nxt[1][2];img_nxt[0][3] = img_nxt[1][3];img_nxt[0][4] = img_nxt[1][4];
            img_nxt[1][0] = img_nxt[2][0]; img_nxt[1][1] = img_nxt[2][1];img_nxt[1][2] = img_nxt[2][2];img_nxt[1][3] = img_nxt[2][3];img_nxt[1][4] = img_nxt[2][4];

            img_nxt[1][0] = Img;
        end
        //finish img pad1
        26,51:
        begin
                                 img_nxt[0][1] = Img;img_nxt[0][2] = 0;img_nxt[0][3] = 0;img_nxt[0][4] = 0;
            img_nxt[1][0] = 0;   img_nxt[1][1] = 0;  img_nxt[1][2] = 0;img_nxt[1][3] = 0;img_nxt[1][4] = 0;
        end
  

    endcase
end


//upper left corner
always @(*) begin
    case (cnt)
        17,22,32,37,42,47,57,62,67,72: idx = 0;
        5,9,13,18,23,28,33,38,43,48,53,58,63,68,73: idx = 1;
        6,10,14,19,24,29,34,39,44,49,54,59,64,69,74: idx = 2;
        25,50,75:idx = 3;
        //25:idx = 4;
        default: idx = 0;
    endcase
end
always @(*) begin
    case (cnt)
    
        8,9,10,11      ,31,32,33,34,35,56,57,58,59,60: jdy = 1;
        12,13,14,15    ,36,37,38,39,40,61,62,63,64,65: jdy = 2;
        16,17,18,19,20 ,41,42,43,44,45,66,67,68,69,70: jdy = 3;
        default: jdy = 0;
    endcase
end

//channel 1
always @(*) begin
    if(cnt>=4 && cnt<27)begin
        _kernel_1[0][0] = ker_ch1_1[0][0];
        _kernel_1[1][0] = ker_ch1_1[1][0];
        _kernel_1[0][1] = ker_ch1_1[0][1];
        _kernel_1[1][1] = ker_ch1_1[1][1];
    end
    else if(cnt>=27 && cnt<=51 )begin
        _kernel_1[0][0] = ker_ch1_2[0][0];
        _kernel_1[1][0] = ker_ch1_2[1][0];
        _kernel_1[0][1] = ker_ch1_2[0][1];
        _kernel_1[1][1] = ker_ch1_2[1][1];
    end
    else begin
        _kernel_1[0][0] = ker_ch1_3[0][0];
        _kernel_1[1][0] = ker_ch1_3[1][0];
        _kernel_1[0][1] = ker_ch1_3[0][1];
        _kernel_1[1][1] = ker_ch1_3[1][1];
    end
end
//channel 2
always @(*) begin
    if(cnt>=4 && cnt<27)begin
        _kernel_2[0][0] = ker_ch2_1[0][0];
        _kernel_2[1][0] = ker_ch2_1[1][0];
        _kernel_2[0][1] = ker_ch2_1[0][1];
        _kernel_2[1][1] = ker_ch2_1[1][1];
    end
    else if(cnt>=27 && cnt<=51 )begin
        _kernel_2[0][0] = ker_ch2_2[0][0];
        _kernel_2[1][0] = ker_ch2_2[1][0];
        _kernel_2[0][1] = ker_ch2_2[0][1];
        _kernel_2[1][1] = ker_ch2_2[1][1];
    end
    else begin
        _kernel_2[0][0] = ker_ch2_3[0][0];
        _kernel_2[1][0] = ker_ch2_3[1][0];
        _kernel_2[0][1] = ker_ch2_3[0][1];
        _kernel_2[1][1] = ker_ch2_3[1][1];
    end
end
always @(*) begin
//----------------------------------------------------
//                    CONV
//----------------------------------------------------
    feature_map_1_nxt = feature_map_1;
    feature_map_2_nxt = feature_map_2;
    FC_result_nxt = FC_result;
    inst_a1     = 0; inst_b1     = 0;inst_c1     = 0;
    inst_a2     = 0; inst_b2     = 0;inst_c2     = 0;
    inst_a3     = 0; inst_b3     = 0;inst_c3     = 0;
    inst_a4     = 0; inst_b4     = 0;inst_c4     = 0;
    inst_a5     = 0; inst_b5     = 0;inst_c5     = 0;
    inst_a6     = 0; inst_b6     = 0;inst_c6     = 0;
    inst_a7     = 0; inst_b7     = 0;inst_c7     = 0;
    inst_a8     = 0; inst_b8     = 0;inst_c8     = 0;
    inst_a9     = 0; inst_b9     = 0;inst_c9     = 0;
    inst_a10    = 0; inst_b10    = 0;inst_c10    = 0;
    inst_a11    = 0; inst_b11    = 0;inst_c11    = 0;
    inst_a12    = 0; inst_b12    = 0;inst_c12    = 0;
    inst_add_a1 = 0; inst_add_b1 = 0;                
    inst_add_a2 = 0; inst_add_b2 = 0;                
    inst_add_a3 = 0; inst_add_b3 = 0;                
    inst_add_a4 = 0; inst_add_b4 = 0;                
    inst_add_a5 = 0; inst_add_b5 = 0; 
    inst_add_a6 = 0; inst_add_b6 = 0; 

    //--------------
    // CHANNEL 1
    //--------------
    case (cnt)
        0:begin
            feature_map_1_nxt[0][0] = 0;feature_map_1_nxt[0][1] = 0;feature_map_1_nxt[0][2] = 0;feature_map_1_nxt[0][3] = 0;feature_map_1_nxt[0][4] = 0;feature_map_1_nxt[0][5] = 0;
            feature_map_1_nxt[1][0] = 0;feature_map_1_nxt[1][1] = 0;feature_map_1_nxt[1][2] = 0;feature_map_1_nxt[1][3] = 0;feature_map_1_nxt[1][4] = 0;feature_map_1_nxt[1][5] = 0;
            feature_map_1_nxt[2][0] = 0;feature_map_1_nxt[2][1] = 0;feature_map_1_nxt[2][2] = 0;feature_map_1_nxt[2][3] = 0;feature_map_1_nxt[2][4] = 0;feature_map_1_nxt[2][5] = 0;
            feature_map_1_nxt[3][0] = 0;feature_map_1_nxt[3][1] = 0;feature_map_1_nxt[3][2] = 0;feature_map_1_nxt[3][3] = 0;feature_map_1_nxt[3][4] = 0;feature_map_1_nxt[3][5] = 0;
            feature_map_1_nxt[4][0] = 0;feature_map_1_nxt[4][1] = 0;feature_map_1_nxt[4][2] = 0;feature_map_1_nxt[4][3] = 0;feature_map_1_nxt[4][4] = 0;feature_map_1_nxt[4][5] = 0;
            feature_map_1_nxt[5][0] = 0;feature_map_1_nxt[5][1] = 0;feature_map_1_nxt[5][2] = 0;feature_map_1_nxt[5][3] = 0;feature_map_1_nxt[5][4] = 0;feature_map_1_nxt[5][5] = 0;
        
            feature_map_2_nxt[0][0] = 0;feature_map_2_nxt[0][1] = 0;feature_map_2_nxt[0][2] = 0;feature_map_2_nxt[0][3] = 0;feature_map_2_nxt[0][4] = 0;feature_map_2_nxt[0][5] = 0;
            feature_map_2_nxt[1][0] = 0;feature_map_2_nxt[1][1] = 0;feature_map_2_nxt[1][2] = 0;feature_map_2_nxt[1][3] = 0;feature_map_2_nxt[1][4] = 0;feature_map_2_nxt[1][5] = 0;
            feature_map_2_nxt[2][0] = 0;feature_map_2_nxt[2][1] = 0;feature_map_2_nxt[2][2] = 0;feature_map_2_nxt[2][3] = 0;feature_map_2_nxt[2][4] = 0;feature_map_2_nxt[2][5] = 0;
            feature_map_2_nxt[3][0] = 0;feature_map_2_nxt[3][1] = 0;feature_map_2_nxt[3][2] = 0;feature_map_2_nxt[3][3] = 0;feature_map_2_nxt[3][4] = 0;feature_map_2_nxt[3][5] = 0;
            feature_map_2_nxt[4][0] = 0;feature_map_2_nxt[4][1] = 0;feature_map_2_nxt[4][2] = 0;feature_map_2_nxt[4][3] = 0;feature_map_2_nxt[4][4] = 0;feature_map_2_nxt[4][5] = 0;
            feature_map_2_nxt[5][0] = 0;feature_map_2_nxt[5][1] = 0;feature_map_2_nxt[5][2] = 0;feature_map_2_nxt[5][3] = 0;feature_map_2_nxt[5][4] = 0;feature_map_2_nxt[5][5] = 0;
        end
        //top row
        4,27,52: 
        begin
            //4 MAC
            inst_a1 = opt_reg ? img[0][0] : 0 ;        inst_b1 = _kernel_1[0][0]; inst_c1 = 0;                // sequ. 1 2    1+3+2+4
            inst_a2 = img[0][0] ;                      inst_b2 = _kernel_1[1][0]; inst_c2 = z_inst1;          //       3 4 
            inst_a3 = opt_reg ? img[0][1] : 0;         inst_b3 = _kernel_1[0][1]; inst_c3 = z_inst2;
            inst_a4 = img[0][1];                       inst_b4 = _kernel_1[1][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                     inst_add_b2 = feature_map_1[0][1];
            feature_map_1_nxt[0][1] = z_inst_add2;
            //2 MAC 1 ADD

            inst_a5 = opt_reg ? img[0][0] : 0 ;       inst_b5 = _kernel_1[0][1]; inst_c5 = 0;
            inst_a6 = img[0][0];                      inst_b6 = _kernel_1[1][1]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;      inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                inst_add_b3 = feature_map_1[0][0];
            feature_map_1_nxt[0][0] = z_inst_add3;
        end
        5,6,28,29,53,54:
        begin
            inst_a1 = opt_reg ? img[0][idx  ] : 0 ;   inst_b1 = _kernel_1[0][0]; inst_c1 = 0;
            inst_a2 = img[0][idx  ] ;                 inst_b2 = _kernel_1[1][0]; inst_c2 = z_inst1;          
            inst_a3 = opt_reg ? img[0][idx+1] : 0;    inst_b3 = _kernel_1[0][1]; inst_c3 = z_inst2;
            inst_a4 = img[0][idx+1];                  inst_b4 = _kernel_1[1][1]; inst_c4 = z_inst3;

            inst_add_a2 = z_inst4;                    inst_add_b2 = feature_map_1[0][idx+1];
            feature_map_1_nxt[0][idx+1] = z_inst_add2;
        end
        7,30,55:
        begin
            //4 MAC
            inst_a1 = opt_reg ? img[0][4] : 0 ;       inst_b1 = _kernel_1[0][1]; inst_c1 = 0;                //  1 2   sequ. 2+4+1+3
            inst_a2 = img[0][4] ;                     inst_b2 = _kernel_1[1][1]; inst_c2 = z_inst1;          //  3 4 
            inst_a3 = opt_reg ? img[0][3] : 0;        inst_b3 = _kernel_1[0][0]; inst_c3 = z_inst2;
            inst_a4 = img[0][3];                      inst_b4 = _kernel_1[1][0]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                    inst_add_b2 = feature_map_1[0][4];
            feature_map_1_nxt[0][4] = z_inst_add2;
            
            //2 MAC 1 ADD

            inst_a5 = opt_reg ? img[0][4] : 0 ;       inst_b5 = _kernel_1[0][0]; inst_c5 = 0;
            inst_a6 = img[0][4];                      inst_b6 = _kernel_1[1][0]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;      inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                inst_add_b3 = feature_map_1[0][5];
            feature_map_1_nxt[0][5] = z_inst_add3;
        end
        //begin of row (6 muti) not top row 
        8,12:
        begin
            //4 MAC
            inst_a1 = img[0][0];                      inst_b1 = _kernel_1[0][0]; inst_c1 = 0;                //  1 2   sequ. 1+3+2+4
            inst_a2 = img[1][0];                      inst_b2 = _kernel_1[1][0]; inst_c2 = z_inst1;            //  3 4 
            inst_a3 = img[0][1];                      inst_b3 = _kernel_1[0][1]; inst_c3 = z_inst2;
            inst_a4 = img[1][1];                      inst_b4 = _kernel_1[1][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                    inst_add_b2 = feature_map_1[jdy][1];
            feature_map_1_nxt[jdy][1] = z_inst_add2;
            //2 MAC 1 ADD

            inst_a5 = img[0][0];                      inst_b5 = _kernel_1[0][1]; inst_c5 = 0;
            inst_a6 = img[1][0];                      inst_b6 = _kernel_1[1][1]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;      inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                inst_add_b3 = feature_map_1[jdy][0];
            feature_map_1_nxt[jdy][0] = z_inst_add3;
        end
        //normal type
        9,10,13,14,17,18,19,32,33,34,37,38,39,42,43,44,57,58,59,62,63,64,67,68,69:
        begin
            inst_a1 = img[0][idx  ];                  inst_b1 = _kernel_1[0][0]; inst_c1 = 0;                      //  1 2   sequ. 1+2+3+4
            inst_a2 = img[0][idx+1];                  inst_b2 = _kernel_1[0][1]; inst_c2 = z_inst1;                //  3 4 
            inst_a3 = img[1][idx  ];                  inst_b3 = _kernel_1[1][0]; inst_c3 = z_inst2;
            inst_a4 = img[1][idx+1];                  inst_b4 = _kernel_1[1][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                    inst_add_b2 = feature_map_1[jdy][idx+1];
            feature_map_1_nxt[jdy][idx+1] = z_inst_add2;

        end
        //end of row (6 muti) not top row 
        11,15,20,35,40,45,60,65,70:
        begin
            //4 MAC
            inst_a1 = img[0][4];                      inst_b1 = _kernel_1[0][1]; inst_c1 = 0;                   //  1 2   sequ. 2+4+1+3
            inst_a2 = img[1][4];                      inst_b2 = _kernel_1[1][1]; inst_c2 = z_inst1;             //  3 4 
            inst_a3 = img[0][3];                      inst_b3 = _kernel_1[0][0]; inst_c3 = z_inst2;
            inst_a4 = img[1][3];                      inst_b4 = _kernel_1[1][0]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                    inst_add_b2 = feature_map_1[jdy][4];
            feature_map_1_nxt[jdy][4] = z_inst_add2;
            //2 MAC 1 ADD

            inst_a5 = img[0][4];                      inst_b5 = _kernel_1[0][0]; inst_c5 = 0;
            inst_a6 = img[1][4];                      inst_b6 = _kernel_1[1][0]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;      inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                inst_add_b3 = feature_map_1[jdy][5];
            feature_map_1_nxt[jdy][5] = z_inst_add3;
           
        end
        //begin of row (4 muti) not top row
        16,31,36,41,56,61,66:
        begin
            inst_a1 = opt_reg ? img[0][0] : 0 ;       inst_b1 = _kernel_1[0][0]; inst_c1 = 0;                   //  1 2   sequ. 1+2+3+4
            inst_a2 = img[0][0];                      inst_b2 = _kernel_1[0][1]; inst_c2 = z_inst1;             //  3 4 
            inst_a3 = opt_reg ? img[1][0] : 0 ;       inst_b3 = _kernel_1[1][0]; inst_c3 = z_inst2;
            inst_a4 = img[1][0];                      inst_b4 = _kernel_1[1][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                    inst_add_b2 = feature_map_1[jdy][0];
            feature_map_1_nxt[jdy][0] = z_inst_add2;
            
        end 
        //buttom row (6 muti) : Head 
        21,46,71: 
        begin 
            //4 MAC 
            inst_a1 = opt_reg ? img[1][0] : 0 ;        inst_b1 = _kernel_1[1][0]; inst_c1 = 0;                 //  1 2   sequ. 3+4+1+2
            inst_a2 = img[1][0];                       inst_b2 = _kernel_1[1][1]; inst_c2 = z_inst1;           //  3 4 
            inst_a3 = opt_reg ? img[0][0] : 0 ;        inst_b3 = _kernel_1[0][0]; inst_c3 = z_inst2;
            inst_a4 = img[0][0];                       inst_b4 = _kernel_1[0][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                     inst_add_b2 = feature_map_1[4][0];
            feature_map_1_nxt[4][0] = z_inst_add2;
          
            //2 MAC 1 ADD

            inst_a5 = opt_reg ? img[1][0] : 0 ;       inst_b5 = _kernel_1[0][0]; inst_c5 = 0;
            inst_a6 = img[1][0];                      inst_b6 = _kernel_1[0][1]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;      inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                inst_add_b3 = feature_map_1[5][0];
            feature_map_1_nxt[5][0] = z_inst_add3;
   
        end
        //buttom row (6 muti) : mid
        22,23,24,25,47,48,49,50,72,73,74,75:
        begin
            //4 MAC
            inst_a1 = img[1][idx] ;                    inst_b1 = _kernel_1[1][0]; inst_c1 = 0;                      //  1 2   sequ. 3+4+1+2
            inst_a2 = img[1][idx+1];                   inst_b2 = _kernel_1[1][1]; inst_c2 = z_inst1;                //  3 4 
            inst_a3 = img[0][idx] ;                    inst_b3 = _kernel_1[0][0]; inst_c3 = z_inst2;
            inst_a4 = img[0][idx+1];                   inst_b4 = _kernel_1[0][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                     inst_add_b2 = feature_map_1[4][idx+1];
            feature_map_1_nxt[4][idx+1] = z_inst_add2;
            //2 MAC 1 ADD

            inst_a5 = img[1][idx];                     inst_b5 = _kernel_1[0][0]; inst_c5 = 0;
            inst_a6 = img[1][idx+1];                   inst_b6 = _kernel_1[0][1]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;       inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                 inst_add_b3 = feature_map_1[5][idx+1];
            feature_map_1_nxt[5][idx+1] = z_inst_add3;
        end
        //buttom row (6 muti) : end
        26,51,76:
        begin
            //4 MAC
            inst_a1 = img[1][4];                       inst_b1 = _kernel_1[1][0]; inst_c1 = 0;                      //  1 2   sequ. 3+4+1+2
            inst_a2 = opt_reg ? img[1][4] : 0;         inst_b2 = _kernel_1[1][1]; inst_c2 = z_inst1;                //  3 4 
            inst_a3 = img[0][4] ;                      inst_b3 = _kernel_1[0][0]; inst_c3 = z_inst2;
            inst_a4 = opt_reg ? img[0][4] : 0;         inst_b4 = _kernel_1[0][1]; inst_c4 = z_inst3;
            inst_add_a2 = z_inst4;                     inst_add_b2 = feature_map_1[4][5];
            feature_map_1_nxt[4][5] = z_inst_add2;

            //2 MAC 1 ADD

            inst_a5 = img[1][4];                       inst_b5 = _kernel_1[0][0]; inst_c5 = 0;
            inst_a6 = opt_reg ? img[1][4] : 0;         inst_b6 = _kernel_1[0][1]; inst_c6 = z_inst5;
            inst_add_a1 = opt_reg ? z_inst2 : 0;       inst_add_b1 = z_inst6 ;
            inst_add_a3 = z_inst_add1;                 inst_add_b3 = feature_map_1[5][5];
            feature_map_1_nxt[5][5] = z_inst_add3;
        end
    endcase
    //--------------
    // CHANNEL 2
    //--------------
    case (cnt)
        //top row
        4,27,52: 
        begin
            //4 MAC
            inst_a7 = opt_reg ? img[0][0] : 0 ;        inst_b7 = _kernel_2[0][0]; inst_c7 = 0;                // sequ. 1 2    1+3+2+4
            inst_a8 = img[0][0] ;                      inst_b8 = _kernel_2[1][0]; inst_c8 = z_inst7;          //       3 4 
            inst_a9 = opt_reg ? img[0][1] : 0;         inst_b9 = _kernel_2[0][1]; inst_c9 = z_inst8;
            inst_a10 = img[0][1];                       inst_b10 = _kernel_2[1][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                     inst_add_b5 = feature_map_2[0][1];
            feature_map_2_nxt[0][1] = z_inst_add5;
            //2 MAC 1 ADD

            inst_a11 = opt_reg ? img[0][0] : 0 ;       inst_b11 = _kernel_2[0][1]; inst_c11 = 0;
            inst_a12 = img[0][0];                      inst_b12 = _kernel_2[1][1]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;      inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                inst_add_b6 = feature_map_2[0][0];
            feature_map_2_nxt[0][0] = z_inst_add6;
        end
        5,6,28,29,53,54:
        begin
            inst_a7 = opt_reg ? img[0][idx  ] : 0 ;   inst_b7 = _kernel_2[0][0]; inst_c7 = 0;
            inst_a8 = img[0][idx  ] ;                 inst_b8 = _kernel_2[1][0]; inst_c8 = z_inst7;          
            inst_a9 = opt_reg ? img[0][idx+1] : 0;    inst_b9 = _kernel_2[0][1]; inst_c9 = z_inst8;
            inst_a10 = img[0][idx+1];                  inst_b10 = _kernel_2[1][1]; inst_c10 = z_inst9;

            inst_add_a5 = z_inst10;                    inst_add_b5 = feature_map_2[0][idx+1];
            feature_map_2_nxt[0][idx+1] = z_inst_add5;
        end
        7,30,55:
        begin
            //4 MAC
            inst_a7 = opt_reg ? img[0][4] : 0 ;       inst_b7 = _kernel_2[0][1]; inst_c7 = 0;                //  1 2   sequ. 2+4+1+3
            inst_a8 = img[0][4] ;                     inst_b8 = _kernel_2[1][1]; inst_c8 = z_inst7;          //  3 4 
            inst_a9 = opt_reg ? img[0][3] : 0;        inst_b9 = _kernel_2[0][0]; inst_c9 = z_inst8;
            inst_a10 = img[0][3];                      inst_b10 = _kernel_2[1][0]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                    inst_add_b5 = feature_map_2[0][4];
            feature_map_2_nxt[0][4] = z_inst_add5;
            
            //2 MAC 1 ADD

            inst_a11 = opt_reg ? img[0][4] : 0 ;       inst_b11 = _kernel_2[0][0]; inst_c11 = 0;
            inst_a12 = img[0][4];                      inst_b12 = _kernel_2[1][0]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;      inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                inst_add_b6 = feature_map_2[0][5];
            feature_map_2_nxt[0][5] = z_inst_add6;
        end
        //begin of row (6 muti) not top row 
        8,12:
        begin
            //4 MAC
            inst_a7 = img[0][0];                      inst_b7 = _kernel_2[0][0]; inst_c7 = 0;                //  1 2   sequ. 1+3+2+4
            inst_a8 = img[1][0];                      inst_b8 = _kernel_2[1][0]; inst_c8 = z_inst7;            //  3 4 
            inst_a9 = img[0][1];                      inst_b9 = _kernel_2[0][1]; inst_c9 = z_inst8;
            inst_a10 = img[1][1];                      inst_b10 = _kernel_2[1][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                    inst_add_b5 = feature_map_2[jdy][1];
            feature_map_2_nxt[jdy][1] = z_inst_add5;
            //2 MAC 1 ADD

            inst_a11 = img[0][0];                      inst_b11 = _kernel_2[0][1]; inst_c11 = 0;
            inst_a12 = img[1][0];                      inst_b12 = _kernel_2[1][1]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;      inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                inst_add_b6 = feature_map_2[jdy][0];
            feature_map_2_nxt[jdy][0] = z_inst_add6;
        end
        //normal type
        9,10,13,14,17,18,19,32,33,34,37,38,39,42,43,44,57,58,59,62,63,64,67,68,69:
        begin
            inst_a7 = img[0][idx  ];                  inst_b7 = _kernel_2[0][0]; inst_c7 = 0;                      //  1 2   sequ. 1+2+3+4
            inst_a8 = img[0][idx+1];                  inst_b8 = _kernel_2[0][1]; inst_c8 = z_inst7;                //  3 4 
            inst_a9 = img[1][idx  ];                  inst_b9 = _kernel_2[1][0]; inst_c9 = z_inst8;
            inst_a10 = img[1][idx+1];                  inst_b10 = _kernel_2[1][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                    inst_add_b5 = feature_map_2[jdy][idx+1];
            feature_map_2_nxt[jdy][idx+1] = z_inst_add5;

        end
        //end of row (6 muti) not top row 
        11,15,20,35,40,45,60,65,70:
        begin
            //4 MAC
            inst_a7 = img[0][4];                       inst_b7 = _kernel_2[0][1]; inst_c7 = 0;                   //  1 2   sequ. 2+4+1+3
            inst_a8 = img[1][4];                       inst_b8 = _kernel_2[1][1]; inst_c8 = z_inst7;             //  3 4 
            inst_a9 = img[0][3];                       inst_b9 = _kernel_2[0][0]; inst_c9 = z_inst8;
            inst_a10 = img[1][3];                      inst_b10 = _kernel_2[1][0]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                    inst_add_b5 = feature_map_2[jdy][4];
            feature_map_2_nxt[jdy][4] = z_inst_add5;
            //2 MAC 1 ADD

            inst_a11 = img[0][4];                      inst_b11 = _kernel_2[0][0]; inst_c11 = 0;
            inst_a12 = img[1][4];                      inst_b12 = _kernel_2[1][0]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;       inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                 inst_add_b6 = feature_map_2[jdy][5];
            feature_map_2_nxt[jdy][5] = z_inst_add6;
           
        end
        //begin of row (4 muti) not top row
        16,31,36,41,56,61,66:
        begin
            inst_a7 = opt_reg ? img[0][0] : 0 ;        inst_b7 = _kernel_2[0][0]; inst_c7 = 0;                   //  1 2   sequ. 1+2+3+4
            inst_a8 = img[0][0];                       inst_b8 = _kernel_2[0][1]; inst_c8 = z_inst7;             //  3 4 
            inst_a9 = opt_reg ? img[1][0] : 0 ;        inst_b9 = _kernel_2[1][0]; inst_c9 = z_inst8;
            inst_a10 = img[1][0];                      inst_b10 = _kernel_2[1][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                    inst_add_b5 = feature_map_2[jdy][0];
            feature_map_2_nxt[jdy][0] = z_inst_add5;
            
        end 
        //buttom row (6 muti) : Head 
        21,46,71: 
        begin 
            //4 MAC 
            inst_a7 = opt_reg ? img[1][0] : 0 ;        inst_b7 = _kernel_2[1][0]; inst_c7 = 0;                 //  1 2   sequ. 3+4+1+2
            inst_a8 = img[1][0];                       inst_b8 = _kernel_2[1][1]; inst_c8 = z_inst7;           //  3 4 
            inst_a9 = opt_reg ? img[0][0] : 0 ;        inst_b9 = _kernel_2[0][0]; inst_c9 = z_inst8;
            inst_a10 = img[0][0];                       inst_b10 = _kernel_2[0][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                     inst_add_b5 = feature_map_2[4][0];
            feature_map_2_nxt[4][0] = z_inst_add5;
          
            //2 MAC 1 ADD

            inst_a11 = opt_reg ? img[1][0] : 0 ;       inst_b11 = _kernel_2[0][0]; inst_c11 = 0;
            inst_a12 = img[1][0];                      inst_b12 = _kernel_2[0][1]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;      inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                inst_add_b6 = feature_map_2[5][0];
            feature_map_2_nxt[5][0] = z_inst_add6;
   
        end
        //buttom row (6 muti) : mid
        22,23,24,25,47,48,49,50,72,73,74,75:
        begin
            //4 MAC
            inst_a7 = img[1][idx] ;                    inst_b7 = _kernel_2[1][0]; inst_c7 = 0;                      //  1 2   sequ. 3+4+1+2
            inst_a8 = img[1][idx+1];                   inst_b8 = _kernel_2[1][1]; inst_c8 = z_inst7;                //  3 4 
            inst_a9 = img[0][idx] ;                    inst_b9 = _kernel_2[0][0]; inst_c9 = z_inst8;
            inst_a10 = img[0][idx+1];                   inst_b10 = _kernel_2[0][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                     inst_add_b5 = feature_map_2[4][idx+1];
            feature_map_2_nxt[4][idx+1] = z_inst_add5;
            //2 MAC 1 ADD

            inst_a11 = img[1][idx];                     inst_b11 = _kernel_2[0][0]; inst_c11 = 0;
            inst_a12 = img[1][idx+1];                   inst_b12 = _kernel_2[0][1]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;       inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                 inst_add_b6 = feature_map_2[5][idx+1];
            feature_map_2_nxt[5][idx+1] = z_inst_add6;
        end
        //buttom row (6 muti) : end
        26,51,76:
        begin
            //4 MAC
            inst_a7 = img[1][4];                       inst_b7 = _kernel_2[1][0]; inst_c7 = 0;                      //  1 2   sequ. 3+4+1+2
            inst_a8 = opt_reg ? img[1][4] : 0;         inst_b8 = _kernel_2[1][1]; inst_c8 = z_inst7;                //  3 4 
            inst_a9 = img[0][4] ;                      inst_b9 = _kernel_2[0][0]; inst_c9 = z_inst8;
            inst_a10 = opt_reg ? img[0][4] : 0;         inst_b10 = _kernel_2[0][1]; inst_c10 = z_inst9;
            inst_add_a5 = z_inst10;                     inst_add_b5 = feature_map_2[4][5];
            feature_map_2_nxt[4][5] = z_inst_add5;

            //2 MAC 1 ADD

            inst_a11 = img[1][4];                       inst_b11 = _kernel_2[0][0]; inst_c11 = 0;
            inst_a12 = opt_reg ? img[1][4] : 0;         inst_b12 = _kernel_2[0][1]; inst_c12 = z_inst11;
            inst_add_a4 = opt_reg ? z_inst8 : 0;       inst_add_b4 = z_inst12 ;
            inst_add_a6 = z_inst_add4;                 inst_add_b6 = feature_map_2[5][5];
            feature_map_2_nxt[5][5] = z_inst_add6;
        end
    endcase
//----------------------------------------------------
//                   Fully connect
//----------------------------------------------------
    case (cnt)
        81:begin
            inst_a1  = FC[0];  inst_b1  = weigh_1[0]; inst_c1 = 0;
            inst_a2  = FC[1];  inst_b2  = weigh_1[1]; inst_c2 = 0;
            inst_a3  = FC[2];  inst_b3  = weigh_1[2]; inst_c3 = 0;
            inst_a4  = FC[3];  inst_b4  = weigh_1[3]; inst_c4 = 0;
            inst_a5  = FC[4];  inst_b5  = weigh_1[4]; inst_c5 = z_inst1;
            inst_a6  = FC[5];  inst_b6  = weigh_1[5]; inst_c6 = z_inst2;
            inst_a7  = FC[6];  inst_b7  = weigh_1[6]; inst_c7 = z_inst3;
            inst_a8  = FC[7];  inst_b8  = weigh_1[7]; inst_c8 = z_inst4;

            inst_a9  = z_inst5;  inst_b9  = 32'b00111111100000000000000000000000; inst_c9  = z_inst6;
            inst_a10 = z_inst7;  inst_b10 = 32'b00111111100000000000000000000000; inst_c10 = z_inst8;
            inst_a11 = z_inst9;  inst_b11 = 32'b00111111100000000000000000000000; inst_c11 = z_inst10;
            //inst_a12 = z_inst8;  inst_b12 = 32'b00111111100000000000000000000000; inst_c12 = z_inst11;

            FC_result_nxt[0] =  z_inst11;
            //FC_result_nxt[1] =  z_inst12;
        end 
        82:begin
            inst_a1  = FC[0];  inst_b1  = weigh_2[0]; inst_c1 = 0;
            inst_a2  = FC[1];  inst_b2  = weigh_2[1]; inst_c2 = 0;
            inst_a3  = FC[2];  inst_b3  = weigh_2[2]; inst_c3 = 0;
            inst_a4  = FC[3];  inst_b4  = weigh_2[3]; inst_c4 = 0;
            inst_a5  = FC[4];  inst_b5  = weigh_2[4]; inst_c5 = z_inst1;
            inst_a6  = FC[5];  inst_b6  = weigh_2[5]; inst_c6 = z_inst2;
            inst_a7  = FC[6];  inst_b7  = weigh_2[6]; inst_c7 = z_inst3;
            inst_a8  = FC[7];  inst_b8  = weigh_2[7]; inst_c8 = z_inst4;

            inst_a9  = z_inst5;  inst_b9  = 32'b00111111100000000000000000000000; inst_c9  = z_inst6;
            inst_a10 = z_inst7;  inst_b10 = 32'b00111111100000000000000000000000; inst_c10 = z_inst8;
            inst_a11 = z_inst9;  inst_b11 = 32'b00111111100000000000000000000000; inst_c11 = z_inst10;
            //inst_a12 = z_inst8;  inst_b12 = 32'b00111111100000000000000000000000; inst_c12 = z_inst11;

            FC_result_nxt[1] =  z_inst11;
        end 
        83:begin
            inst_a1  = FC[0];  inst_b1  = weigh_3[0]; inst_c1 = 0;
            inst_a2  = FC[1];  inst_b2  = weigh_3[1]; inst_c2 = 0;
            inst_a3  = FC[2];  inst_b3  = weigh_3[2]; inst_c3 = 0;
            inst_a4  = FC[3];  inst_b4  = weigh_3[3]; inst_c4 = 0;
            inst_a5  = FC[4];  inst_b5  = weigh_3[4]; inst_c5 = z_inst1;
            inst_a6  = FC[5];  inst_b6  = weigh_3[5]; inst_c6 = z_inst2;
            inst_a7  = FC[6];  inst_b7  = weigh_3[6]; inst_c7 = z_inst3;
            inst_a8  = FC[7];  inst_b8  = weigh_3[7]; inst_c8 = z_inst4;

            inst_a9  = z_inst5;  inst_b9  = 32'b00111111100000000000000000000000; inst_c9  = z_inst6;
            inst_a10 = z_inst7;  inst_b10 = 32'b00111111100000000000000000000000; inst_c10 = z_inst8;
            inst_a11 = z_inst9;  inst_b11 = 32'b00111111100000000000000000000000; inst_c11 = z_inst10;
            //inst_a12 = z_inst8;  inst_b12 = 32'b00111111100000000000000000000000; inst_c12 = z_inst11;

            FC_result_nxt[2] =  z_inst11;
        end 
    endcase



end
//----------------------------------------------------
//                   MAX POOLING
//----------------------------------------------------
//
//Max-Pooling result store in feature map [0][0],[0][3],[3][0],[3][3]
//  
always @(*) begin
    MaxPool_nxt = MaxPool;
    inst_a1_cmp  = 0;inst_b1_cmp  = 0;
    inst_a2_cmp  = 0;inst_b2_cmp  = 0;
    inst_a3_cmp  = 0;inst_b3_cmp  = 0;
    inst_a4_cmp  = 0;inst_b4_cmp  = 0;
    inst_a5_cmp  = 0;inst_b5_cmp  = 0;
    inst_a6_cmp  = 0;inst_b6_cmp  = 0;
    inst_a7_cmp  = 0;inst_b7_cmp  = 0;
    inst_a8_cmp  = 0;inst_b8_cmp  = 0;
    inst_a9_cmp  = 0;inst_b9_cmp  = 0;
    inst_a10_cmp = 0;inst_b10_cmp = 0;
    inst_a11_cmp = 0;inst_b11_cmp = 0;
    inst_a12_cmp = 0;inst_b12_cmp = 0;
    inst_a13_cmp = 0;inst_b13_cmp = 0;
    inst_a14_cmp = 0;inst_b14_cmp = 0;
    inst_a15_cmp = 0;inst_b15_cmp = 0;
    inst_a16_cmp = 0;inst_b16_cmp = 0;
    case (cnt)
        64: begin
            inst_a1_cmp = feature_map_1[0][0]; inst_b1_cmp = feature_map_1[0][1];
            inst_a2_cmp = feature_map_1[0][2]; inst_b2_cmp = feature_map_1[1][0];
            inst_a3_cmp = feature_map_1[1][1]; inst_b3_cmp = feature_map_1[1][2];
            inst_a4_cmp = feature_map_1[2][0]; inst_b4_cmp = feature_map_1[2][1];
            inst_a5_cmp = z_inst1_cmp_max; inst_b5_cmp = z_inst2_cmp_max;
            inst_a6_cmp = z_inst3_cmp_max; inst_b6_cmp = z_inst4_cmp_max;
            inst_a7_cmp = z_inst5_cmp_max; inst_b7_cmp = z_inst6_cmp_max;
            inst_a8_cmp = z_inst7_cmp_max; inst_b8_cmp = feature_map_1[2][2];

            
            inst_a9_cmp  = feature_map_2[0][0]; inst_b9_cmp = feature_map_2[0][1];
            inst_a10_cmp = feature_map_2[0][2]; inst_b10_cmp = feature_map_2[1][0];
            inst_a11_cmp = feature_map_2[1][1]; inst_b11_cmp = feature_map_2[1][2];
            inst_a12_cmp = feature_map_2[2][0]; inst_b12_cmp = feature_map_2[2][1];
            inst_a13_cmp = z_inst9_cmp_max;     inst_b13_cmp = z_inst10_cmp_max;
            inst_a14_cmp = z_inst11_cmp_max;    inst_b14_cmp = z_inst12_cmp_max;
            inst_a15_cmp = z_inst13_cmp_max;    inst_b15_cmp = z_inst14_cmp_max;
            inst_a16_cmp = z_inst15_cmp_max;    inst_b16_cmp = feature_map_2[2][2];

            MaxPool_nxt [0] = z_inst8_cmp_max;
            MaxPool_nxt [4] = z_inst16_cmp_max;
        end

        66: begin
            inst_a1_cmp = feature_map_1[0][3]; inst_b1_cmp = feature_map_1[0][4];
            inst_a2_cmp = feature_map_1[0][5]; inst_b2_cmp = feature_map_1[1][3];
            inst_a3_cmp = feature_map_1[1][4]; inst_b3_cmp = feature_map_1[1][5];
            inst_a4_cmp = feature_map_1[2][3]; inst_b4_cmp = feature_map_1[2][4];
            inst_a5_cmp = z_inst1_cmp_max; inst_b5_cmp = z_inst2_cmp_max;
            inst_a6_cmp = z_inst3_cmp_max; inst_b6_cmp = z_inst4_cmp_max;
            inst_a7_cmp = z_inst5_cmp_max; inst_b7_cmp = z_inst6_cmp_max;
            inst_a8_cmp = z_inst7_cmp_max; inst_b8_cmp = feature_map_1[2][5];

            
            inst_a9_cmp  = feature_map_2[0][3]; inst_b9_cmp =  feature_map_2[0][4];
            inst_a10_cmp = feature_map_2[0][5]; inst_b10_cmp = feature_map_2[1][3];
            inst_a11_cmp = feature_map_2[1][4]; inst_b11_cmp = feature_map_2[1][5];
            inst_a12_cmp = feature_map_2[2][3]; inst_b12_cmp = feature_map_2[2][4];
            inst_a13_cmp = z_inst9_cmp_max;     inst_b13_cmp = z_inst10_cmp_max;
            inst_a14_cmp = z_inst11_cmp_max;    inst_b14_cmp = z_inst12_cmp_max;
            inst_a15_cmp = z_inst13_cmp_max;    inst_b15_cmp = z_inst14_cmp_max;
            inst_a16_cmp = z_inst15_cmp_max;    inst_b16_cmp = feature_map_2[2][5];

            MaxPool_nxt [1] = z_inst8_cmp_max;
            MaxPool_nxt [5] = z_inst16_cmp_max;
        end

        74: begin

            inst_a1_cmp = feature_map_1[3][0]; inst_b1_cmp = feature_map_1[3][1];
            inst_a2_cmp = feature_map_1[3][2]; inst_b2_cmp = feature_map_1[4][0];
            inst_a3_cmp = feature_map_1[4][1]; inst_b3_cmp = feature_map_1[4][2];
            inst_a4_cmp = feature_map_1[5][0]; inst_b4_cmp = feature_map_1[5][1];
            inst_a5_cmp = z_inst1_cmp_max; inst_b5_cmp = z_inst2_cmp_max;
            inst_a6_cmp = z_inst3_cmp_max; inst_b6_cmp = z_inst4_cmp_max;
            inst_a7_cmp = z_inst5_cmp_max; inst_b7_cmp = z_inst6_cmp_max;
            inst_a8_cmp = z_inst7_cmp_max; inst_b8_cmp = feature_map_1[5][2];

            
            inst_a9_cmp  = feature_map_2[3][0]; inst_b9_cmp =  feature_map_2[3][1];
            inst_a10_cmp = feature_map_2[3][2]; inst_b10_cmp = feature_map_2[4][0];
            inst_a11_cmp = feature_map_2[4][1]; inst_b11_cmp = feature_map_2[4][2];
            inst_a12_cmp = feature_map_2[5][0]; inst_b12_cmp = feature_map_2[5][1];
            inst_a13_cmp = z_inst9_cmp_max;     inst_b13_cmp = z_inst10_cmp_max;
            inst_a14_cmp = z_inst11_cmp_max;    inst_b14_cmp = z_inst12_cmp_max;
            inst_a15_cmp = z_inst13_cmp_max;    inst_b15_cmp = z_inst14_cmp_max;
            inst_a16_cmp = z_inst15_cmp_max;    inst_b16_cmp = feature_map_2[5][2];

            MaxPool_nxt [2] = z_inst8_cmp_max;
            MaxPool_nxt [6] = z_inst16_cmp_max;
            
        end

        77: begin
            inst_a1_cmp = feature_map_1[3][3]; inst_b1_cmp = feature_map_1[3][4];
            inst_a2_cmp = feature_map_1[3][5]; inst_b2_cmp = feature_map_1[4][3];
            inst_a3_cmp = feature_map_1[4][4]; inst_b3_cmp = feature_map_1[4][5];
            inst_a4_cmp = feature_map_1[5][3]; inst_b4_cmp = feature_map_1[5][4];
            inst_a5_cmp = z_inst1_cmp_max; inst_b5_cmp = z_inst2_cmp_max;
            inst_a6_cmp = z_inst3_cmp_max; inst_b6_cmp = z_inst4_cmp_max;
            inst_a7_cmp = z_inst5_cmp_max; inst_b7_cmp = z_inst6_cmp_max;
            inst_a8_cmp = z_inst7_cmp_max; inst_b8_cmp = feature_map_1[5][5];

            
            inst_a9_cmp  = feature_map_2[3][3]; inst_b9_cmp =  feature_map_2[3][4];
            inst_a10_cmp = feature_map_2[3][5]; inst_b10_cmp = feature_map_2[4][3];
            inst_a11_cmp = feature_map_2[4][4]; inst_b11_cmp = feature_map_2[4][5];
            inst_a12_cmp = feature_map_2[5][3]; inst_b12_cmp = feature_map_2[5][4];
            inst_a13_cmp = z_inst9_cmp_max;     inst_b13_cmp = z_inst10_cmp_max;
            inst_a14_cmp = z_inst11_cmp_max;    inst_b14_cmp = z_inst12_cmp_max;
            inst_a15_cmp = z_inst13_cmp_max;    inst_b15_cmp = z_inst14_cmp_max;
            inst_a16_cmp = z_inst15_cmp_max;    inst_b16_cmp = feature_map_2[5][5];

            MaxPool_nxt [3] = z_inst8_cmp_max;
            MaxPool_nxt [7] = z_inst16_cmp_max;
        end

    endcase 
end
//----------------------------------------------------
//                   ACTIVE FUNCTION
//----------------------------------------------------
//
//active fucntion Numerator and denominator store in feature[0][1],feature[0][2]      feature[0][4],feature[0][5]
//                                                   feature[3][1],feature[3][2]      feature[3][4],feature[3][5]
//
//active fucntion result store in feature[1][0],feature[1][3]
//                                feature[4][0],feature[4][3]
always @(*) begin
    Dividend_nxt = Dividend;
    Divisor_nxt  = Divisor;
    Softmax_nxt = Softmax;
    inst_add_a7 = 0; inst_add_b7 = 0; 
    inst_add_a8 = 0; inst_add_b8 = 0; 
    inst_add_aAF1 = 0;inst_add_bAF1 = 0;
    inst_add_aAF2 = 0;inst_add_bAF2 = 0;
    inst_add_aAF3 = 0;inst_add_bAF3 = 0;
    inst_add_aAF4 = 0;inst_add_bAF4 = 0;
    inst_a_exp_1 = 0;
    inst_a_exp_2 = 0;
    case (cnt)
        65: begin
            if(opt_reg)begin
                //ch1
                inst_add_a7 = MaxPool[0]; inst_add_b7 = MaxPool[0];
                inst_a_exp_1 = z_inst_add7;
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b10111111100000000000000000000000;
                inst_add_aAF2 = z_inst_exp_1; inst_add_bAF2 = 32'b00111111100000000000000000000000;
                Dividend_nxt[0] = z_inst_addAF1;
                Divisor_nxt [0] = z_inst_addAF2;
                //ch2
                inst_add_a8 = MaxPool[4]; inst_add_b8 = MaxPool[4];
                inst_a_exp_2 = z_inst_add8;
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b10111111100000000000000000000000;
                inst_add_aAF4 = z_inst_exp_2; inst_add_bAF4 = 32'b00111111100000000000000000000000;
                Dividend_nxt[4] = z_inst_addAF3;
                Divisor_nxt [4] = z_inst_addAF4;
            end
            else begin
                //ch1
                inst_a_exp_1 = MaxPool[0];
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b00111111100000000000000000000000;
                Dividend_nxt[0] = z_inst_exp_1;
                Divisor_nxt [0] = z_inst_addAF1;
                //ch2
                inst_a_exp_2 = MaxPool[4];
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b00111111100000000000000000000000;
                Dividend_nxt[4] = z_inst_exp_2;
                Divisor_nxt [4] = z_inst_addAF3;
            end
        end
        67:begin
            if(opt_reg)begin
                //ch1
                inst_add_a7 = MaxPool[1]; inst_add_b7 = MaxPool[1];
                inst_a_exp_1 = z_inst_add7;
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b10111111100000000000000000000000;
                inst_add_aAF2 = z_inst_exp_1; inst_add_bAF2 = 32'b00111111100000000000000000000000;
                Dividend_nxt[1] = z_inst_addAF1;
                Divisor_nxt [1] = z_inst_addAF2;
                //ch2
                inst_add_a8 = MaxPool[5]; inst_add_b8 = MaxPool[5];
                inst_a_exp_2 = z_inst_add8;
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b10111111100000000000000000000000;
                inst_add_aAF4 = z_inst_exp_2; inst_add_bAF4 = 32'b00111111100000000000000000000000;
                Dividend_nxt[5] = z_inst_addAF3;
                Divisor_nxt [5] = z_inst_addAF4;
            end
            else begin
                //ch1
                inst_a_exp_1 = MaxPool[1];
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b00111111100000000000000000000000;
                Dividend_nxt[1] = z_inst_exp_1;
                Divisor_nxt [1] = z_inst_addAF1;
                //ch2
                inst_a_exp_2 = MaxPool[5];
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b00111111100000000000000000000000;
                Dividend_nxt[5] = z_inst_exp_2;
                Divisor_nxt [5] = z_inst_addAF3;
            end
        end
        75:begin
            if(opt_reg)begin
                //ch1
                inst_add_a7 = MaxPool[2]; inst_add_b7 = MaxPool[2];
                inst_a_exp_1 = z_inst_add7;
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b10111111100000000000000000000000;
                inst_add_aAF2 = z_inst_exp_1; inst_add_bAF2 = 32'b00111111100000000000000000000000;
                Dividend_nxt[2] = z_inst_addAF1;
                Divisor_nxt [2] = z_inst_addAF2;
                //ch2
                inst_add_a8 = MaxPool[6]; inst_add_b8 = MaxPool[6];
                inst_a_exp_2 = z_inst_add8;
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b10111111100000000000000000000000;
                inst_add_aAF4 = z_inst_exp_2; inst_add_bAF4 = 32'b00111111100000000000000000000000;
                Dividend_nxt[6] = z_inst_addAF3;
                Divisor_nxt [6] = z_inst_addAF4;
            end
            else begin
                //ch1
                inst_a_exp_1 = MaxPool[2];
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b00111111100000000000000000000000;
                Dividend_nxt[2] = z_inst_exp_1;
                Divisor_nxt [2] = z_inst_addAF1;
                //ch2
                inst_a_exp_2 = MaxPool[6];
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b00111111100000000000000000000000;
                Dividend_nxt[6] = z_inst_exp_2;
                Divisor_nxt [6] = z_inst_addAF3;
            end
        end
        78:begin
            if(opt_reg)begin
                //ch1
                inst_add_a7 = MaxPool[3]; inst_add_b7 = MaxPool[3];
                inst_a_exp_1 = z_inst_add7;
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b10111111100000000000000000000000;
                inst_add_aAF2 = z_inst_exp_1; inst_add_bAF2 = 32'b00111111100000000000000000000000;
                Dividend_nxt[3] = z_inst_addAF1;
                Divisor_nxt [3] = z_inst_addAF2;
                //ch2
                inst_add_a8 = MaxPool[7]; inst_add_b8 = MaxPool[7];
                inst_a_exp_2 = z_inst_add8;
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b10111111100000000000000000000000;
                inst_add_aAF4 = z_inst_exp_2; inst_add_bAF4 = 32'b00111111100000000000000000000000;
                Dividend_nxt[7] = z_inst_addAF3;
                Divisor_nxt [7] = z_inst_addAF4;
            end
            else begin
                //ch1
                inst_a_exp_1 = MaxPool[3];
                inst_add_aAF1 = z_inst_exp_1; inst_add_bAF1 = 32'b00111111100000000000000000000000;
                Dividend_nxt[3] = z_inst_exp_1;
                Divisor_nxt [3] = z_inst_addAF1;
                //ch2
                inst_a_exp_2 = MaxPool[7];
                inst_add_aAF3 = z_inst_exp_2; inst_add_bAF3 = 32'b00111111100000000000000000000000;
                Dividend_nxt[7] = z_inst_exp_2;
                Divisor_nxt [7] = z_inst_addAF3;
            end
        end


//----------------------------------------------------
//                   Softmax 1 EXP and SUM (cnt 82 83)
//----------------------------------------------------
        82:
        begin
            inst_a_exp_1 = FC_result[0];
            Softmax_nxt[1] = z_inst_exp_1;
        end
            
        //end 
        83:
        begin
            inst_a_exp_1 = FC_result[1];  
            Softmax_nxt[2] = z_inst_exp_1;
            
            
        end
        84:begin
            inst_a_exp_1 = FC_result[2];
            Softmax_nxt[3] = z_inst_exp_1;

            inst_add_a7 = Softmax[1]; inst_add_b7 = Softmax[2];
            inst_add_a8 = z_inst_add7;  inst_add_b8 = z_inst_exp_1;
            Softmax_nxt[0] = z_inst_add8;
        end
    endcase
    
end
    ///////////////
    //DIV
    //////////////
//prob store in FC 0 1 2
always @(*) begin
   FC_nxt = FC;
   inst_a_div = 0;
    inst_b_div = 1;
    case (cnt)
        0:begin
            FC_nxt [0] = 0;
            FC_nxt [1] = 0;
            FC_nxt [2] = 0;
            FC_nxt [3] = 0;
            FC_nxt [4] = 0;
            FC_nxt [5] = 0;
            FC_nxt [6] = 0;
            FC_nxt [7] = 0;
        end
        66:begin
            inst_a_div = Dividend[0]; 
            inst_b_div = Divisor [0];
            FC_nxt [0] = z_inst_div;
        end 
        67:begin
            inst_a_div = Dividend[4]; 
            inst_b_div = Divisor [4];
            FC_nxt [4] = z_inst_div;
        end 
        68:begin
            inst_a_div = Dividend[1]; 
            inst_b_div = Divisor [1];
            FC_nxt [1] = z_inst_div;
        end 
        69:begin
            inst_a_div = Dividend[5]; 
            inst_b_div = Divisor [5];
            FC_nxt [5] = z_inst_div;
        end 
        76:begin
            inst_a_div = Dividend[2]; 
            inst_b_div = Divisor [2];
            FC_nxt [2] = z_inst_div;
        end 
        77:begin
            inst_a_div = Dividend[6]; 
            inst_b_div = Divisor [6];
            FC_nxt [6] = z_inst_div;
        end
        79:begin
            inst_a_div = Dividend[3];
            inst_b_div = Divisor [3];
            FC_nxt [3] = z_inst_div;
        end 
        80:begin
            inst_a_div = Dividend[7]; 
            inst_b_div = Divisor [7];
            FC_nxt [7] = z_inst_div;
        end 
        85:
        begin
            inst_a_div = Softmax[1]; inst_b_div = Softmax[0];
            FC_nxt[0] = z_inst_div;
        end
        86:
        begin
            inst_a_div = Softmax[2]; inst_b_div = Softmax[0];
            FC_nxt[1] = z_inst_div;
        end
        87:
        begin
            inst_a_div = Softmax[3]; inst_b_div = Softmax[0];
            FC_nxt[2] = z_inst_div;
        end
    endcase
end

//Fully connect result store in feature[5][3],feature[5][4],feature[5][5]
//      
/*always @(*) begin
    
    case (cnt)
        0:begin
            Softmax_nxt[0] = 0;
            Softmax_nxt[1] = 0;
            Softmax_nxt[2] = 0;
            Softmax_nxt[3] = 0;
        end
        
        
    endcase
end      */                    
//----------------------------------------------------
//                   Softmax
//----------------------------------------------------
//        Softmax result store in feature[5][3],feature[5][4],feature[5][5]
//               e^z sum stoer in feature[5][2]
  
//----------------------------------------------------
//                   OUTPUT
//----------------------------------------------------
always @(*) begin
    if(cnt>=86 && cnt<=88) out_valid = 1;
    else                   out_valid = 0;
    
end
always @(*) begin
    case (cnt)
        86: out = FC[0];
        87: out = FC[1];
        88: out = FC[2];
        default: out = 0;
    endcase
end

//IP
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (
    .a(inst_a1),
    .b(inst_b1),
    .c(inst_c1),
    .rnd(inst_rnd),
    .z(z_inst1) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U2 (
    .a(inst_a2),
    .b(inst_b2),
    .c(inst_c2),
    .rnd(inst_rnd),
    .z(z_inst2) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U3 (
    .a(inst_a3),
    .b(inst_b3),
    .c(inst_c3),
    .rnd(inst_rnd),
    .z(z_inst3));
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U4 (
    .a(inst_a4),
    .b(inst_b4),
    .c(inst_c4),
    .rnd(inst_rnd),
    .z(z_inst4) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U5 (
    .a(inst_a5),
    .b(inst_b5),
    .c(inst_c5),
    .rnd(inst_rnd),
    .z(z_inst5) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U6 (
    .a(inst_a6),
    .b(inst_b6),
    .c(inst_c6),
    .rnd(inst_rnd),
    .z(z_inst6) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U7 (
    .a(inst_a7),
    .b(inst_b7),
    .c(inst_c7),
    .rnd(inst_rnd),
    .z(z_inst7));
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U8 (
    .a(inst_a8),
    .b(inst_b8),
    .c(inst_c8),
    .rnd(inst_rnd),
    .z(z_inst8));
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U9 (
    .a(inst_a9),
    .b(inst_b9),
    .c(inst_c9),
    .rnd(inst_rnd),
    .z(z_inst9));
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U10 (
    .a(inst_a10),
    .b(inst_b10),
    .c(inst_c10),
    .rnd(inst_rnd),
    .z(z_inst10) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U11 (
    .a(inst_a11),
    .b(inst_b11),
    .c(inst_c11),
    .rnd(inst_rnd),
    .z(z_inst11) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U12 (
    .a(inst_a12),
    .b(inst_b12),
    .c(inst_c12),
    .rnd(inst_rnd),
    .z(z_inst12) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U13 ( 
    .a(inst_add_a1), 
    .b(inst_add_b1), 
    .rnd(inst_rnd), 
    .z(z_inst_add1), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U14 ( 
    .a(inst_add_a2), 
    .b(inst_add_b2), 
    .rnd(inst_rnd), 
    .z(z_inst_add2), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U15 ( 
    .a(inst_add_a3), 
    .b(inst_add_b3), 
    .rnd(inst_rnd), 
    .z(z_inst_add3), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U16 ( 
    .a(inst_add_a4), 
    .b(inst_add_b4), 
    .rnd(inst_rnd), 
    .z(z_inst_add4), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U17 ( 
    .a(inst_add_a5), 
    .b(inst_add_b5), 
    .rnd(inst_rnd), 
    .z(z_inst_add5), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U18 ( 
    .a(inst_add_a6), 
    .b(inst_add_b6), 
    .rnd(inst_rnd), 
    .z(z_inst_add6), 
    .status() );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U19 ( 
    .a(inst_a1_cmp), 
    .b(inst_b1_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst1_cmp_min), 
    .z1(z_inst1_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U20 ( 
    .a(inst_a2_cmp), 
    .b(inst_b2_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst2_cmp_min), 
    .z1(z_inst2_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U21 ( 
    .a(inst_a3_cmp), 
    .b(inst_b3_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst3_cmp_min), 
    .z1(z_inst3_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U22 ( 
    .a(inst_a4_cmp), 
    .b(inst_b4_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst4_cmp_min), 
    .z1(z_inst4_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U23 ( 
    .a(inst_a5_cmp), 
    .b(inst_b5_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst5_cmp_min), 
    .z1(z_inst5_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U24 ( 
    .a(inst_a6_cmp), 
    .b(inst_b6_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst6_cmp_min), 
    .z1(z_inst6_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U25 ( 
    .a(inst_a7_cmp), 
    .b(inst_b7_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst7_cmp_min), 
    .z1(z_inst7_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U26 ( 
    .a(inst_a8_cmp), 
    .b(inst_b8_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst8_cmp_min), 
    .z1(z_inst8_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U27 ( 
    .a(inst_a9_cmp), 
    .b(inst_b9_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst9_cmp_min), 
    .z1(z_inst9_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U28 ( 
    .a(inst_a10_cmp), 
    .b(inst_b10_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst10_cmp_min), 
    .z1(z_inst10_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U29 ( 
    .a(inst_a11_cmp), 
    .b(inst_b11_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst11_cmp_min), 
    .z1(z_inst11_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U30 ( 
    .a(inst_a12_cmp), 
    .b(inst_b12_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst12_cmp_min), 
    .z1(z_inst12_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U31 ( 
    .a(inst_a13_cmp), 
    .b(inst_b13_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst13_cmp_min), 
    .z1(z_inst13_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U32 ( 
    .a(inst_a14_cmp), 
    .b(inst_b14_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst14_cmp_min), 
    .z1(z_inst14_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U33 ( 
    .a(inst_a15_cmp), 
    .b(inst_b15_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst15_cmp_min), 
    .z1(z_inst15_cmp_max));
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U34 ( 
    .a(inst_a16_cmp), 
    .b(inst_b16_cmp), 
    .zctr(inst_zctr), 
    .aeqb(aeqb_inst), 
    .altb(altb_inst), 
    .agtb(agtb_inst), 
    .unordered(unordered_inst), 
    .z0(z_inst16_cmp_min), 
    .z1(z_inst16_cmp_max));
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U35 (
    .a(inst_a_exp_1),
    .z(z_inst_exp_1));
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U36 (
    .a(inst_a_exp_2),
    .z(z_inst_exp_2));
/*DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U37 (
    .a(inst_a_exp_3),
    .z(z_inst_exp_3));*/
DW_fp_add #(inst_sig_width,inst_exp_width, inst_ieee_compliance) U38 ( 
    .a(inst_add_a7), 
    .b(inst_add_b7), 
    .rnd(inst_rnd), 
    .z(z_inst_add7), 
    .status() );
DW_fp_add #(inst_sig_width,inst_exp_width, inst_ieee_compliance) U39 ( 
    .a(inst_add_a8), 
    .b(inst_add_b8), 
    .rnd(inst_rnd), 
    .z(z_inst_add8), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U40 ( 
    .a(inst_add_aAF1), 
    .b(inst_add_bAF1), 
    .rnd(inst_rnd), 
    .z(z_inst_addAF1), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U41 ( 
    .a(inst_add_aAF2), 
    .b(inst_add_bAF2), 
    .rnd(inst_rnd), 
    .z(z_inst_addAF2), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U42 ( 
    .a(inst_add_aAF3), 
    .b(inst_add_bAF3), 
    .rnd(inst_rnd), 
    .z(z_inst_addAF3), 
    .status() );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U43 ( 
    .a(inst_add_aAF4), 
    .b(inst_add_bAF4), 
    .rnd(inst_rnd), 
    .z(z_inst_addAF4), 
    .status() );
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) U44 ( 
    .a(inst_a_div), 
    .b(inst_b_div), 
    .rnd(inst_rnd), 
    .z(z_inst_div), 
    .status() 
);
endmodule
