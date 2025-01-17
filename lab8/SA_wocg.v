/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: SA_wocg.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Spring IC Lab / Exersise Lab08 / SA_wocg
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

module SA(
	// Input signals
	clk,
	rst_n,
	in_valid,
	T,
	in_data,
	w_Q,
	w_K,
	w_V,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input [3:0] T;
input signed [7:0] in_data;
input signed [7:0] w_Q;
input signed [7:0] w_K;
input signed [7:0] w_V;

output reg out_valid;
output reg signed [63:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter S_IDLE    =  'd0;
parameter S_READ      =  'd1;
parameter S_OUT      =  'd2;
parameter S_T8      =  'd3;

//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [2:0]cur_state,nxt_state;
reg signed[7:0]in_data_ff[0:63],in_data_nxt[0:63];
reg signed[7:0]Wq[0:63],Wq_nxt[0:63];
reg [7:0]cnt,cnt_nxt;
reg [6:0]cnt_in,cnt_in_nxt;
reg [2:0]row,row_nxt;
reg [2:0]col,col_nxt;
reg Read_Q,Read_Q_nxt;
reg Read_K,Read_K_nxt;
reg Read_V,Read_V_nxt;
reg in_valid_reg;
reg signed [7:0]w_Q_reg;
reg signed [7:0]w_K_reg;
reg signed [7:0]w_V_reg;
reg signed [7:0]in_data_reg;
reg signed [18:0]Q[0:7][0:7],Q_nxt[0:7][0:7];
reg signed [18:0]K[0:7][0:7],K_nxt[0:7][0:7];
reg signed [18:0]V[0:7][0:7],V_nxt[0:7][0:7];
reg signed [40:0]S[0:7][0:7],S_nxt[0:7][0:7];
//multiplier
reg signed [7:0]  mul_8B_a1[0:7];
reg signed [7:0]  mul_8B_b1[0:7];
reg signed [15:0] mul_8B_z1[0:7];
reg signed [18:0] mul_19B_a2[0:7];
reg signed [40:0] mul_41B_b2[0:7];
reg signed [59:0] mul_60B_z2[0:7];
//adders big
reg signed [59:0] add_60B_a1,add_60B_a2,add_60B_a3,add_60B_a4;
reg signed [59:0] add_60B_b1,add_60B_b2,add_60B_b3,add_60B_b4;
reg signed [60:0] add_60B_z1,add_60B_z2,add_60B_z3,add_60B_z4;

reg signed [60:0] add_61B_a1,add_61B_a2;
reg signed [60:0] add_61B_b1,add_61B_b2;
reg signed [61:0] add_61B_z1,add_61B_z2;

reg signed [61:0] add_62B_a1;
reg signed [61:0] add_62B_b1;
reg signed [63:0] add_62B_z1;
//adders small
reg signed [15:0] add_16B_a1,add_16B_a2,add_16B_a3,add_16B_a4;
reg signed [15:0] add_16B_b1,add_16B_b2,add_16B_b3,add_16B_b4;
reg signed [16:0] add_16B_z1,add_16B_z2,add_16B_z3,add_16B_z4;

reg signed [16:0] add_17B_a1,add_17B_a2;
reg signed [16:0] add_17B_b1,add_17B_b2;
reg signed [17:0] add_17B_z1,add_17B_z2;

reg signed [17:0] add_18B_a1;
reg signed [17:0] add_18B_b1;
reg signed [18:0] add_18B_z1;

reg [1:0]T_type,T_type_nxt;

//Relu scale
reg signed [40:0] Relu,Scale;
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
			if(in_valid)
				nxt_state = S_READ;
			else 
				nxt_state = cur_state;
        end
		S_READ:begin
			if(Read_V && cnt==63) nxt_state = S_OUT;
			else                  nxt_state = cur_state;
		end
		S_OUT:begin
			case (T_type)
				0: nxt_state = (cnt == 7)  ? S_IDLE : S_OUT;
				1: nxt_state = (cnt == 31) ? S_IDLE : S_OUT;
				2: nxt_state = (cnt == 63) ? S_IDLE : S_OUT;
				default: nxt_state = cur_state;
			endcase
		end
        default: nxt_state = cur_state;
    endcase
end
//================================================================//
//                             Input
//================================================================//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		w_Q_reg <= 0;
		w_K_reg <= 0;
		w_V_reg <= 0;
		in_data_reg <= 0;
		in_valid_reg <= 0;
	end
	else begin
		w_Q_reg <= w_Q;
		w_K_reg <= w_K;
		w_V_reg <= w_V;
		in_data_reg <= in_data;
		in_valid_reg <= in_valid;
	end	
end
always @(*) begin
	case (T_type)
		0: cnt_in = 8;
		1: cnt_in = 32;
		2: cnt_in = 64;
		default: cnt_in = 0;
	endcase
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		T_type <= 0;
	end
	else begin
		T_type <= T_type_nxt;
	end	
end
always @(*) begin
	if(in_valid && cur_state == S_IDLE)begin
		case (T)
			1: T_type_nxt = 0;
			4: T_type_nxt = 1;
			8: T_type_nxt = 2;
			default: T_type_nxt = 3;
		endcase
	end
	else
		T_type_nxt = T_type;
end
/*
after server open fix to this
generate
	for(i=0;i<64;i=i+1) begin
		always @(*) begin
			if(cnt == i && Read_Q)begin
				if(cnt < cnt_in) in_data_nxt[i] = in_data_reg;
				else             in_data_nxt[i] = 0;
			end
			else begin
				in_data_nxt[i] = in_data_ff[i];	
			end
				
		end
       
    end
endgenerate
*/
genvar i;
generate
	for(i=0;i<64;i=i+1) begin
		always @(*) begin
			if(cnt == i && Read_Q)begin
				if(cnt < cnt_in) in_data_nxt[i] = in_data_reg;
				else             in_data_nxt[i] = 0;
			end
			else begin
				in_data_nxt[i] = in_data_ff[i];	
			end
				
		end 
    end
endgenerate

genvar i;
generate
    for(i=0;i<64;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
			if(!rst_n)
            	in_data_ff[i] <= 0;
			else
				in_data_ff[i] <= in_data_nxt[i];
        end
    end
endgenerate
//================================================================//
//                            Cnt
//================================================================//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		cnt <= 0;
		row <= 0;
		col <= 0;
	end
		
	else begin
		cnt <= cnt_nxt;
		row <= row_nxt;
		col <= col_nxt;
	end
		
end
always @(*) begin
	case (cur_state)
		S_IDLE:cnt_nxt = 0;
		S_READ:begin
			if(cnt == 63) cnt_nxt = 0;
			else          cnt_nxt = cnt + 1 ;
		end 
		S_OUT: cnt_nxt = cnt + 1 ;
		default: cnt_nxt = cnt;
	endcase
end
always @(*) begin
	case (cur_state)
		S_IDLE: row_nxt = 0;
		S_READ:begin
			if(Read_K || Read_V)begin
				row_nxt = row + 1;
			end
			else begin
				row_nxt = row;
			end
		end 
		S_OUT:row_nxt = row + 1;
		default : row_nxt = row;
	endcase
end
always @(*) begin
	case (cur_state)
		S_IDLE: col_nxt = 0;
		S_READ:begin
			if(Read_K || Read_V)begin
				if(row == 7)
					col_nxt = col + 1;
				else
					col_nxt = col;
			end
			else begin
				col_nxt = col;
			end
		end 
		S_OUT:begin
			if(row == 7)
				col_nxt = col + 1;
			else
				col_nxt = col;
		end
		default:col_nxt = col;
	endcase
end
//================================================================//
//                          Read QKV
//================================================================//
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		Read_Q <= 0;
		Read_K <= 0;
		Read_V <= 0;
	end
	else begin
		Read_Q <= Read_Q_nxt;
		Read_K <= Read_K_nxt;
		Read_V <= Read_V_nxt;
	end
		
end
always @(*) begin
	if(cur_state == S_IDLE && in_valid)begin
		Read_Q_nxt = 1 ;
	end
	else begin
		if(Read_Q && cnt == 63) Read_Q_nxt = 0 ;
		else                    Read_Q_nxt = Read_Q ;
	end
end
always @(*) begin
	if(Read_Q && cnt == 63)begin
		Read_K_nxt =  1 ;
	end
	else begin
		if(Read_K && cnt==63)Read_K_nxt =  0;
		else                 Read_K_nxt =  Read_K;
	end
end
always @(*) begin
	if(Read_K && cnt == 63)begin
		Read_V_nxt =  1 ;
	end
	else begin
		if(Read_V && cnt==63)Read_V_nxt =  0;
		else                 Read_V_nxt =  Read_V;
	end
end
genvar i;
generate
	for(i=0;i<64;i=i+1) begin
        always @(*) begin
    		if(cnt == i && Read_Q)
    			Wq_nxt[i] = w_Q_reg;
    		else begin
				if(cur_state == S_IDLE) Wq_nxt[i] = 0;
				else                    Wq_nxt[i] = Wq[i];
			end
    				
        end
    end
endgenerate
genvar i;
generate
	for(i=0;i<64;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
			if(!rst_n)
    			Wq[i] <= 0;
    		else
    			Wq[i] <= Wq_nxt[i];	
        end
    end
endgenerate
//================================================================//
//                           CAL Q
//================================================================//
genvar i,j;
generate
	for(i=0;i<8;i=i+1) begin
		for(j=0;j<8;j=j+1) begin
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n)
					Q[i][j] <= 0;
				else
					Q[i][j] <= Q_nxt[i][j];	
			end
		end
	end
endgenerate
genvar i,j;
generate
	for(i=0;i<8;i=i+1) begin
		for(j=0;j<8;j=j+1) begin
			always @(*) begin
				if(i==col && j==row && Read_K)
					Q_nxt[i][j] = add_18B_z1;
				else begin
					if(cur_state == S_IDLE)Q_nxt[i][j] = 0;
					else                   Q_nxt[i][j] = Q[i][j];
				end
					
			end
		end
	end
endgenerate
//================================================================//
//                           CAL V
//================================================================//
genvar i,j;
generate
	for(i=0;i<8;i=i+1) begin
		for(j=0;j<8;j=j+1) begin
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n)
					V[i][j] <= 0;
				else
					V[i][j] <= V_nxt[i][j];	
			end
		end
	end
endgenerate
genvar j;
generate

	for(j=0;j<8;j=j+1) begin
		always @(*) begin
			if(j==row && Read_V)begin
				V_nxt[0][j] = mul_8B_z1[0] + V[0][j];
				V_nxt[1][j] = mul_8B_z1[1] + V[1][j];
				V_nxt[2][j] = mul_8B_z1[2] + V[2][j];
				V_nxt[3][j] = mul_8B_z1[3] + V[3][j];
				V_nxt[4][j] = mul_8B_z1[4] + V[4][j];
				V_nxt[5][j] = mul_8B_z1[5] + V[5][j];
				V_nxt[6][j] = mul_8B_z1[6] + V[6][j];
				V_nxt[7][j] = mul_8B_z1[7] + V[7][j];
			end
				
			else begin 
				if(cur_state == S_IDLE)begin
					V_nxt[0][j] = 0;
					V_nxt[1][j] = 0;
					V_nxt[2][j] = 0;
					V_nxt[3][j] = 0;
					V_nxt[4][j] = 0;
					V_nxt[5][j] = 0;
					V_nxt[6][j] = 0;
					V_nxt[7][j] = 0;
				end 
				else begin
					V_nxt[0][j] = V[0][j];
					V_nxt[1][j] = V[1][j];
					V_nxt[2][j] = V[2][j];
					V_nxt[3][j] = V[3][j];
					V_nxt[4][j] = V[4][j];
					V_nxt[5][j] = V[5][j];
					V_nxt[6][j] = V[6][j];
					V_nxt[7][j] = V[7][j];
				end                

				
			end
				
		end
	end

endgenerate
//================================================================//
//                           CAL K
//================================================================//
genvar i,j;
generate
	for(i=0;i<8;i=i+1) begin
		for(j=0;j<8;j=j+1) begin
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n)
					K[i][j] <= 0;
				else
					K[i][j] <= K_nxt[i][j];	
			end
		end
	end
endgenerate
genvar j;
generate
	for(j=0;j<8;j=j+1) begin
		always @(*) begin
			if(j==row && Read_K)begin
				K_nxt[0][j] = mul_60B_z2[0] + K[0][j];
				K_nxt[1][j] = mul_60B_z2[1] + K[1][j];
				K_nxt[2][j] = mul_60B_z2[2] + K[2][j];
				K_nxt[3][j] = mul_60B_z2[3] + K[3][j];
				K_nxt[4][j] = mul_60B_z2[4] + K[4][j];
				K_nxt[5][j] = mul_60B_z2[5] + K[5][j];
				K_nxt[6][j] = mul_60B_z2[6] + K[6][j];
				K_nxt[7][j] = mul_60B_z2[7] + K[7][j];
			end
			else begin
				if(cur_state == S_IDLE)begin
					K_nxt[0][j] = 0;
					K_nxt[1][j] = 0;
					K_nxt[2][j] = 0;
					K_nxt[3][j] = 0;
					K_nxt[4][j] = 0;
					K_nxt[5][j] = 0;
					K_nxt[6][j] = 0;
					K_nxt[7][j] = 0;
				end 
				else begin
					K_nxt[0][j] = K[0][j];
					K_nxt[1][j] = K[1][j];
					K_nxt[2][j] = K[2][j];
					K_nxt[3][j] = K[3][j];
					K_nxt[4][j] = K[4][j];
					K_nxt[5][j] = K[5][j];
					K_nxt[6][j] = K[6][j];
					K_nxt[7][j] = K[7][j];
				end     
			end	
		end
	end

endgenerate
//================================================================//
//                           CAL S
//================================================================//
genvar i,j;
generate
	for(i=0;i<8;i=i+1) begin
		for(j=0;j<8;j=j+1) begin
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n)
					S[i][j] <= 0;
				else
					S[i][j] <= S_nxt[i][j];	
			end
		end
	end
endgenerate
genvar i,j;
generate
	for(i=0;i<8;i=i+1) begin
		for(j=0;j<8;j=j+1) begin
			always @(*) begin
				if(i==col && j==row && Read_V)
					S_nxt[i][j] = Scale;
				else
					S_nxt[i][j] = S[i][j];
			end
		end
	end
endgenerate
//================================================================//
//                          MALTIPILER
//================================================================//
//8b * 8b
always @(*) begin
	if(Read_K)begin
		//cal Q
		case (col)
			0: begin
				mul_8B_a1[0] = in_data_ff[0];
				mul_8B_a1[1] = in_data_ff[1];
				mul_8B_a1[2] = in_data_ff[2];
				mul_8B_a1[3] = in_data_ff[3];
				mul_8B_a1[4] = in_data_ff[4];
				mul_8B_a1[5] = in_data_ff[5];
				mul_8B_a1[6] = in_data_ff[6];
				mul_8B_a1[7] = in_data_ff[7];
			end
			1: begin
				mul_8B_a1[0] = in_data_ff[8];
				mul_8B_a1[1] = in_data_ff[9];
				mul_8B_a1[2] = in_data_ff[10];
				mul_8B_a1[3] = in_data_ff[11];
				mul_8B_a1[4] = in_data_ff[12];
				mul_8B_a1[5] = in_data_ff[13];
				mul_8B_a1[6] = in_data_ff[14];
				mul_8B_a1[7] = in_data_ff[15];
			end
			2: begin
				mul_8B_a1[0] = in_data_ff[16];
				mul_8B_a1[1] = in_data_ff[17];
				mul_8B_a1[2] = in_data_ff[18];
				mul_8B_a1[3] = in_data_ff[19];
				mul_8B_a1[4] = in_data_ff[20];
				mul_8B_a1[5] = in_data_ff[21];
				mul_8B_a1[6] = in_data_ff[22];
				mul_8B_a1[7] = in_data_ff[23];
			end
			3: begin
				mul_8B_a1[0] = in_data_ff[24];
				mul_8B_a1[1] = in_data_ff[25];
				mul_8B_a1[2] = in_data_ff[26];
				mul_8B_a1[3] = in_data_ff[27];
				mul_8B_a1[4] = in_data_ff[28];
				mul_8B_a1[5] = in_data_ff[29];
				mul_8B_a1[6] = in_data_ff[30];
				mul_8B_a1[7] = in_data_ff[31];
			end
			4: begin
				mul_8B_a1[0] = in_data_ff[32];
				mul_8B_a1[1] = in_data_ff[33];
				mul_8B_a1[2] = in_data_ff[34];
				mul_8B_a1[3] = in_data_ff[35];
				mul_8B_a1[4] = in_data_ff[36];
				mul_8B_a1[5] = in_data_ff[37];
				mul_8B_a1[6] = in_data_ff[38];
				mul_8B_a1[7] = in_data_ff[39];
			end
			5: begin
				mul_8B_a1[0] = in_data_ff[40];
				mul_8B_a1[1] = in_data_ff[41];
				mul_8B_a1[2] = in_data_ff[42];
				mul_8B_a1[3] = in_data_ff[43];
				mul_8B_a1[4] = in_data_ff[44];
				mul_8B_a1[5] = in_data_ff[45];
				mul_8B_a1[6] = in_data_ff[46];
				mul_8B_a1[7] = in_data_ff[47];
			end
			6: begin
				mul_8B_a1[0] = in_data_ff[48];
				mul_8B_a1[1] = in_data_ff[49];
				mul_8B_a1[2] = in_data_ff[50];
				mul_8B_a1[3] = in_data_ff[51];
				mul_8B_a1[4] = in_data_ff[52];
				mul_8B_a1[5] = in_data_ff[53];
				mul_8B_a1[6] = in_data_ff[54];
				mul_8B_a1[7] = in_data_ff[55];
			end
			7: begin
				mul_8B_a1[0] = in_data_ff[56];
				mul_8B_a1[1] = in_data_ff[57];
				mul_8B_a1[2] = in_data_ff[58];
				mul_8B_a1[3] = in_data_ff[59];
				mul_8B_a1[4] = in_data_ff[60];
				mul_8B_a1[5] = in_data_ff[61];
				mul_8B_a1[6] = in_data_ff[62];
				mul_8B_a1[7] = in_data_ff[63];
			end
			default: begin
				mul_8B_a1[0] = 0;
				mul_8B_a1[1] = 0;
				mul_8B_a1[2] = 0;
				mul_8B_a1[3] = 0;
				mul_8B_a1[4] = 0;
				mul_8B_a1[5] = 0;
				mul_8B_a1[6] = 0;
				mul_8B_a1[7] = 0;
			end
		endcase
	end
	else begin
		//cal V
		case (col)
			0: begin
				mul_8B_a1[0] = in_data_ff[0 ];
				mul_8B_a1[1] = in_data_ff[8 ];
				mul_8B_a1[2] = in_data_ff[16];
				mul_8B_a1[3] = in_data_ff[24];
				mul_8B_a1[4] = in_data_ff[32];
				mul_8B_a1[5] = in_data_ff[40];
				mul_8B_a1[6] = in_data_ff[48];
				mul_8B_a1[7] = in_data_ff[56];
			end
			1: begin
				mul_8B_a1[0] = in_data_ff[1];
				mul_8B_a1[1] = in_data_ff[9];
				mul_8B_a1[2] = in_data_ff[17];
				mul_8B_a1[3] = in_data_ff[25];
				mul_8B_a1[4] = in_data_ff[33];
				mul_8B_a1[5] = in_data_ff[41];
				mul_8B_a1[6] = in_data_ff[49];
				mul_8B_a1[7] = in_data_ff[57];
			end
			2: begin
				mul_8B_a1[0] = in_data_ff[2];
				mul_8B_a1[1] = in_data_ff[10];
				mul_8B_a1[2] = in_data_ff[18];
				mul_8B_a1[3] = in_data_ff[26];
				mul_8B_a1[4] = in_data_ff[34];
				mul_8B_a1[5] = in_data_ff[42];
				mul_8B_a1[6] = in_data_ff[50];
				mul_8B_a1[7] = in_data_ff[58];
			end
			3: begin
				mul_8B_a1[0] = in_data_ff[3];
				mul_8B_a1[1] = in_data_ff[11];
				mul_8B_a1[2] = in_data_ff[19];
				mul_8B_a1[3] = in_data_ff[27];
				mul_8B_a1[4] = in_data_ff[35];
				mul_8B_a1[5] = in_data_ff[43];
				mul_8B_a1[6] = in_data_ff[51];
				mul_8B_a1[7] = in_data_ff[59];
			end
			4: begin
				mul_8B_a1[0] = in_data_ff[4];
				mul_8B_a1[1] = in_data_ff[12];
				mul_8B_a1[2] = in_data_ff[20];
				mul_8B_a1[3] = in_data_ff[28];
				mul_8B_a1[4] = in_data_ff[36];
				mul_8B_a1[5] = in_data_ff[44];
				mul_8B_a1[6] = in_data_ff[52];
				mul_8B_a1[7] = in_data_ff[60];
			end
			5: begin
				mul_8B_a1[0] = in_data_ff[5];
				mul_8B_a1[1] = in_data_ff[13];
				mul_8B_a1[2] = in_data_ff[21];
				mul_8B_a1[3] = in_data_ff[29];
				mul_8B_a1[4] = in_data_ff[37];
				mul_8B_a1[5] = in_data_ff[45];
				mul_8B_a1[6] = in_data_ff[53];
				mul_8B_a1[7] = in_data_ff[61];
			end
			6: begin
				mul_8B_a1[0] = in_data_ff[6];
				mul_8B_a1[1] = in_data_ff[14];
				mul_8B_a1[2] = in_data_ff[22];
				mul_8B_a1[3] = in_data_ff[30];
				mul_8B_a1[4] = in_data_ff[38];
				mul_8B_a1[5] = in_data_ff[46];
				mul_8B_a1[6] = in_data_ff[54];
				mul_8B_a1[7] = in_data_ff[62];
			end
			7: begin
				mul_8B_a1[0] = in_data_ff[7];
				mul_8B_a1[1] = in_data_ff[15];
				mul_8B_a1[2] = in_data_ff[23];
				mul_8B_a1[3] = in_data_ff[31];
				mul_8B_a1[4] = in_data_ff[39];
				mul_8B_a1[5] = in_data_ff[47];
				mul_8B_a1[6] = in_data_ff[55];
				mul_8B_a1[7] = in_data_ff[63];
			end
			default: begin
				mul_8B_a1[0] = 0;
				mul_8B_a1[1] = 0;
				mul_8B_a1[2] = 0;
				mul_8B_a1[3] = 0;
				mul_8B_a1[4] = 0;
				mul_8B_a1[5] = 0;
				mul_8B_a1[6] = 0;
				mul_8B_a1[7] = 0;
			end
		endcase
	end
end
always @(*) begin
	if(Read_K)begin
		// cal Q
		case (row)
			0: begin
				mul_8B_b1[0] = Wq[0 ];
				mul_8B_b1[1] = Wq[8 ];
				mul_8B_b1[2] = Wq[16];
				mul_8B_b1[3] = Wq[24];
				mul_8B_b1[4] = Wq[32];
				mul_8B_b1[5] = Wq[40];
				mul_8B_b1[6] = Wq[48];
				mul_8B_b1[7] = Wq[56];
			end
			1: begin
				mul_8B_b1[0] = Wq[1 ];
				mul_8B_b1[1] = Wq[9 ];
				mul_8B_b1[2] = Wq[17];
				mul_8B_b1[3] = Wq[25];
				mul_8B_b1[4] = Wq[33];
				mul_8B_b1[5] = Wq[41];
				mul_8B_b1[6] = Wq[49];
				mul_8B_b1[7] = Wq[57];
			end
			2: begin
				mul_8B_b1[0] = Wq[2];
				mul_8B_b1[1] = Wq[10];
				mul_8B_b1[2] = Wq[18];
				mul_8B_b1[3] = Wq[26];
				mul_8B_b1[4] = Wq[34];
				mul_8B_b1[5] = Wq[42];
				mul_8B_b1[6] = Wq[50];
				mul_8B_b1[7] = Wq[58];
			end	
			3: begin
				mul_8B_b1[0] = Wq[3];
				mul_8B_b1[1] = Wq[11];
				mul_8B_b1[2] = Wq[19];
				mul_8B_b1[3] = Wq[27];
				mul_8B_b1[4] = Wq[35];
				mul_8B_b1[5] = Wq[43];
				mul_8B_b1[6] = Wq[51];
				mul_8B_b1[7] = Wq[59];
			end
			4: begin
				mul_8B_b1[0] = Wq[4];
				mul_8B_b1[1] = Wq[12];
				mul_8B_b1[2] = Wq[20];
				mul_8B_b1[3] = Wq[28];
				mul_8B_b1[4] = Wq[36];
				mul_8B_b1[5] = Wq[44];
				mul_8B_b1[6] = Wq[52];
				mul_8B_b1[7] = Wq[60];
			end
			5: begin
				mul_8B_b1[0] = Wq[5];
				mul_8B_b1[1] = Wq[13];
				mul_8B_b1[2] = Wq[21];
				mul_8B_b1[3] = Wq[29];
				mul_8B_b1[4] = Wq[37];
				mul_8B_b1[5] = Wq[45];
				mul_8B_b1[6] = Wq[53];
				mul_8B_b1[7] = Wq[61];
			end
			6: begin
				mul_8B_b1[0] = Wq[6];
				mul_8B_b1[1] = Wq[14];
				mul_8B_b1[2] = Wq[22];
				mul_8B_b1[3] = Wq[30];
				mul_8B_b1[4] = Wq[38];
				mul_8B_b1[5] = Wq[46];
				mul_8B_b1[6] = Wq[54];
				mul_8B_b1[7] = Wq[62];
			end
			7: begin
				mul_8B_b1[0] = Wq[7];
				mul_8B_b1[1] = Wq[15];
				mul_8B_b1[2] = Wq[23];
				mul_8B_b1[3] = Wq[31];
				mul_8B_b1[4] = Wq[39];
				mul_8B_b1[5] = Wq[47];
				mul_8B_b1[6] = Wq[55];
				mul_8B_b1[7] = Wq[63];
			end
			default: begin
				mul_8B_b1[0] = 0;
				mul_8B_b1[1] = 0;
				mul_8B_b1[2] = 0;
				mul_8B_b1[3] = 0;
				mul_8B_b1[4] = 0;
				mul_8B_b1[5] = 0;
				mul_8B_b1[6] = 0;
				mul_8B_b1[7] = 0;
			end
		endcase
	end
	// cal V
	else begin
		mul_8B_b1[0] = w_V_reg;
		mul_8B_b1[1] = w_V_reg;
		mul_8B_b1[2] = w_V_reg;
		mul_8B_b1[3] = w_V_reg;
		mul_8B_b1[4] = w_V_reg;
		mul_8B_b1[5] = w_V_reg;
		mul_8B_b1[6] = w_V_reg;
		mul_8B_b1[7] = w_V_reg;
	end
end

//19b*40b
always @(*) begin
	if(Read_K)begin
		case (col)
			0: begin
				mul_19B_a2[0] = in_data_ff[0 ];
				mul_19B_a2[1] = in_data_ff[8 ];
				mul_19B_a2[2] = in_data_ff[16];
				mul_19B_a2[3] = in_data_ff[24];
				mul_19B_a2[4] = in_data_ff[32];
				mul_19B_a2[5] = in_data_ff[40];
				mul_19B_a2[6] = in_data_ff[48];
				mul_19B_a2[7] = in_data_ff[56];
			end
			1: begin
				mul_19B_a2[0] = in_data_ff[1];
				mul_19B_a2[1] = in_data_ff[9];
				mul_19B_a2[2] = in_data_ff[17];
				mul_19B_a2[3] = in_data_ff[25];
				mul_19B_a2[4] = in_data_ff[33];
				mul_19B_a2[5] = in_data_ff[41];
				mul_19B_a2[6] = in_data_ff[49];
				mul_19B_a2[7] = in_data_ff[57];
			end
			2: begin
				mul_19B_a2[0] = in_data_ff[2];
				mul_19B_a2[1] = in_data_ff[10];
				mul_19B_a2[2] = in_data_ff[18];
				mul_19B_a2[3] = in_data_ff[26];
				mul_19B_a2[4] = in_data_ff[34];
				mul_19B_a2[5] = in_data_ff[42];
				mul_19B_a2[6] = in_data_ff[50];
				mul_19B_a2[7] = in_data_ff[58];
			end
			3: begin
				mul_19B_a2[0] = in_data_ff[3];
				mul_19B_a2[1] = in_data_ff[11];
				mul_19B_a2[2] = in_data_ff[19];
				mul_19B_a2[3] = in_data_ff[27];
				mul_19B_a2[4] = in_data_ff[35];
				mul_19B_a2[5] = in_data_ff[43];
				mul_19B_a2[6] = in_data_ff[51];
				mul_19B_a2[7] = in_data_ff[59];
			end
			4: begin
				mul_19B_a2[0] = in_data_ff[4];
				mul_19B_a2[1] = in_data_ff[12];
				mul_19B_a2[2] = in_data_ff[20];
				mul_19B_a2[3] = in_data_ff[28];
				mul_19B_a2[4] = in_data_ff[36];
				mul_19B_a2[5] = in_data_ff[44];
				mul_19B_a2[6] = in_data_ff[52];
				mul_19B_a2[7] = in_data_ff[60];
			end
			5: begin
				mul_19B_a2[0] = in_data_ff[5];
				mul_19B_a2[1] = in_data_ff[13];
				mul_19B_a2[2] = in_data_ff[21];
				mul_19B_a2[3] = in_data_ff[29];
				mul_19B_a2[4] = in_data_ff[37];
				mul_19B_a2[5] = in_data_ff[45];
				mul_19B_a2[6] = in_data_ff[53];
				mul_19B_a2[7] = in_data_ff[61];
			end
			6: begin
				mul_19B_a2[0] = in_data_ff[6];
				mul_19B_a2[1] = in_data_ff[14];
				mul_19B_a2[2] = in_data_ff[22];
				mul_19B_a2[3] = in_data_ff[30];
				mul_19B_a2[4] = in_data_ff[38];
				mul_19B_a2[5] = in_data_ff[46];
				mul_19B_a2[6] = in_data_ff[54];
				mul_19B_a2[7] = in_data_ff[62];
			end
			7: begin
				mul_19B_a2[0] = in_data_ff[7];
				mul_19B_a2[1] = in_data_ff[15];
				mul_19B_a2[2] = in_data_ff[23];
				mul_19B_a2[3] = in_data_ff[31];
				mul_19B_a2[4] = in_data_ff[39];
				mul_19B_a2[5] = in_data_ff[47];
				mul_19B_a2[6] = in_data_ff[55];
				mul_19B_a2[7] = in_data_ff[63];
			end
			default: begin
				mul_19B_a2[0] = 0;
				mul_19B_a2[1] = 0;
				mul_19B_a2[2] = 0;
				mul_19B_a2[3] = 0;
				mul_19B_a2[4] = 0;
				mul_19B_a2[5] = 0;
				mul_19B_a2[6] = 0;
				mul_19B_a2[7] = 0;
			end
		endcase
	end
	else if(Read_V)begin
		case (col)
			0: begin
				mul_19B_a2[0] = Q[0][0];
				mul_19B_a2[1] = Q[0][1];
				mul_19B_a2[2] = Q[0][2];
				mul_19B_a2[3] = Q[0][3];
				mul_19B_a2[4] = Q[0][4];
				mul_19B_a2[5] = Q[0][5];
				mul_19B_a2[6] = Q[0][6];
				mul_19B_a2[7] = Q[0][7];
			end
			1: begin
				mul_19B_a2[0] = Q[1][0];
				mul_19B_a2[1] = Q[1][1];
				mul_19B_a2[2] = Q[1][2];
				mul_19B_a2[3] = Q[1][3];
				mul_19B_a2[4] = Q[1][4];
				mul_19B_a2[5] = Q[1][5];
				mul_19B_a2[6] = Q[1][6];
				mul_19B_a2[7] = Q[1][7];
			end
			2: begin
				mul_19B_a2[0] = Q[2][0];
				mul_19B_a2[1] = Q[2][1];
				mul_19B_a2[2] = Q[2][2];
				mul_19B_a2[3] = Q[2][3];
				mul_19B_a2[4] = Q[2][4];
				mul_19B_a2[5] = Q[2][5];
				mul_19B_a2[6] = Q[2][6];
				mul_19B_a2[7] = Q[2][7];
			end
			3: begin
				mul_19B_a2[0] = Q[3][0];
				mul_19B_a2[1] = Q[3][1];
				mul_19B_a2[2] = Q[3][2];
				mul_19B_a2[3] = Q[3][3];
				mul_19B_a2[4] = Q[3][4];
				mul_19B_a2[5] = Q[3][5];
				mul_19B_a2[6] = Q[3][6];
				mul_19B_a2[7] = Q[3][7];
			end
			4: begin
				mul_19B_a2[0] = Q[4][0];
				mul_19B_a2[1] = Q[4][1];
				mul_19B_a2[2] = Q[4][2];
				mul_19B_a2[3] = Q[4][3];
				mul_19B_a2[4] = Q[4][4];
				mul_19B_a2[5] = Q[4][5];
				mul_19B_a2[6] = Q[4][6];
				mul_19B_a2[7] = Q[4][7];
			end
			5: begin
				mul_19B_a2[0] = Q[5][0];
				mul_19B_a2[1] = Q[5][1];
				mul_19B_a2[2] = Q[5][2];
				mul_19B_a2[3] = Q[5][3];
				mul_19B_a2[4] = Q[5][4];
				mul_19B_a2[5] = Q[5][5];
				mul_19B_a2[6] = Q[5][6];
				mul_19B_a2[7] = Q[5][7];
			end
			6: begin
				mul_19B_a2[0] = Q[6][0];
				mul_19B_a2[1] = Q[6][1];
				mul_19B_a2[2] = Q[6][2];
				mul_19B_a2[3] = Q[6][3];
				mul_19B_a2[4] = Q[6][4];
				mul_19B_a2[5] = Q[6][5];
				mul_19B_a2[6] = Q[6][6];
				mul_19B_a2[7] = Q[6][7];
			end
			7: begin
				mul_19B_a2[0] = Q[7][0];
				mul_19B_a2[1] = Q[7][1];
				mul_19B_a2[2] = Q[7][2];
				mul_19B_a2[3] = Q[7][3];
				mul_19B_a2[4] = Q[7][4];
				mul_19B_a2[5] = Q[7][5];
				mul_19B_a2[6] = Q[7][6];
				mul_19B_a2[7] = Q[7][7];
			end
			default: begin
				mul_19B_a2[0] = 0;
				mul_19B_a2[1] = 0;
				mul_19B_a2[2] = 0;
				mul_19B_a2[3] = 0;
				mul_19B_a2[4] = 0;
				mul_19B_a2[5] = 0;
				mul_19B_a2[6] = 0;
				mul_19B_a2[7] = 0;
			end
		endcase
	end
	else begin
		case (row)
			0: begin
				mul_19B_a2[0] = V[0][0];
				mul_19B_a2[1] = V[1][0];
				mul_19B_a2[2] = V[2][0];
				mul_19B_a2[3] = V[3][0];
				mul_19B_a2[4] = V[4][0];
				mul_19B_a2[5] = V[5][0];
				mul_19B_a2[6] = V[6][0];
				mul_19B_a2[7] = V[7][0];
			end
			1: begin
				mul_19B_a2[0] = V[0][1];
				mul_19B_a2[1] = V[1][1];
				mul_19B_a2[2] = V[2][1];
				mul_19B_a2[3] = V[3][1];
				mul_19B_a2[4] = V[4][1];
				mul_19B_a2[5] = V[5][1];
				mul_19B_a2[6] = V[6][1];
				mul_19B_a2[7] = V[7][1];
			end
			2: begin
				mul_19B_a2[0] = V[0][2];
				mul_19B_a2[1] = V[1][2];
				mul_19B_a2[2] = V[2][2];
				mul_19B_a2[3] = V[3][2];
				mul_19B_a2[4] = V[4][2];
				mul_19B_a2[5] = V[5][2];
				mul_19B_a2[6] = V[6][2];
				mul_19B_a2[7] = V[7][2];
			end
			3: begin
				mul_19B_a2[0] = V[0][3];
				mul_19B_a2[1] = V[1][3];
				mul_19B_a2[2] = V[2][3];
				mul_19B_a2[3] = V[3][3];
				mul_19B_a2[4] = V[4][3];
				mul_19B_a2[5] = V[5][3];
				mul_19B_a2[6] = V[6][3];
				mul_19B_a2[7] = V[7][3];
			end
			4: begin
				mul_19B_a2[0] = V[0][4];
				mul_19B_a2[1] = V[1][4];
				mul_19B_a2[2] = V[2][4];
				mul_19B_a2[3] = V[3][4];
				mul_19B_a2[4] = V[4][4];
				mul_19B_a2[5] = V[5][4];
				mul_19B_a2[6] = V[6][4];
				mul_19B_a2[7] = V[7][4];
			end
			5: begin
				mul_19B_a2[0] = V[0][5];
				mul_19B_a2[1] = V[1][5];
				mul_19B_a2[2] = V[2][5];
				mul_19B_a2[3] = V[3][5];
				mul_19B_a2[4] = V[4][5];
				mul_19B_a2[5] = V[5][5];
				mul_19B_a2[6] = V[6][5];
				mul_19B_a2[7] = V[7][5];
			end
			6: begin
				mul_19B_a2[0] = V[0][6];
				mul_19B_a2[1] = V[1][6];
				mul_19B_a2[2] = V[2][6];
				mul_19B_a2[3] = V[3][6];
				mul_19B_a2[4] = V[4][6];
				mul_19B_a2[5] = V[5][6];
				mul_19B_a2[6] = V[6][6];
				mul_19B_a2[7] = V[7][6];
			end
			7: begin
				mul_19B_a2[0] = V[0][7];
				mul_19B_a2[1] = V[1][7];
				mul_19B_a2[2] = V[2][7];
				mul_19B_a2[3] = V[3][7];
				mul_19B_a2[4] = V[4][7];
				mul_19B_a2[5] = V[5][7];
				mul_19B_a2[6] = V[6][7];
				mul_19B_a2[7] = V[7][7];
			end
			default: begin
				mul_19B_a2[0] = 0;
				mul_19B_a2[1] = 0;
				mul_19B_a2[2] = 0;
				mul_19B_a2[3] = 0;
				mul_19B_a2[4] = 0;
				mul_19B_a2[5] = 0;
				mul_19B_a2[6] = 0;
				mul_19B_a2[7] = 0;
			end 

		endcase
	end
end
always @(*) begin
	if(Read_K)begin
		mul_41B_b2[0] = w_K_reg;
		mul_41B_b2[1] = w_K_reg;
		mul_41B_b2[2] = w_K_reg;
		mul_41B_b2[3] = w_K_reg;
		mul_41B_b2[4] = w_K_reg;
		mul_41B_b2[5] = w_K_reg;
		mul_41B_b2[6] = w_K_reg;
		mul_41B_b2[7] = w_K_reg;
	end
	else if(Read_V)begin
		case (row)
			0: begin
				mul_41B_b2[0] = K[0][0];
				mul_41B_b2[1] = K[0][1];
				mul_41B_b2[2] = K[0][2];
				mul_41B_b2[3] = K[0][3];
				mul_41B_b2[4] = K[0][4];
				mul_41B_b2[5] = K[0][5];
				mul_41B_b2[6] = K[0][6];
				mul_41B_b2[7] = K[0][7];
			end
			1: begin
				mul_41B_b2[0] = K[1][0];
				mul_41B_b2[1] = K[1][1];
				mul_41B_b2[2] = K[1][2];
				mul_41B_b2[3] = K[1][3];
				mul_41B_b2[4] = K[1][4];
				mul_41B_b2[5] = K[1][5];
				mul_41B_b2[6] = K[1][6];
				mul_41B_b2[7] = K[1][7];
			end
			2: begin
				mul_41B_b2[0] = K[2][0];
				mul_41B_b2[1] = K[2][1];
				mul_41B_b2[2] = K[2][2];
				mul_41B_b2[3] = K[2][3];
				mul_41B_b2[4] = K[2][4];
				mul_41B_b2[5] = K[2][5];
				mul_41B_b2[6] = K[2][6];
				mul_41B_b2[7] = K[2][7];
			end
			3: begin
				mul_41B_b2[0] = K[3][0];
				mul_41B_b2[1] = K[3][1];
				mul_41B_b2[2] = K[3][2];
				mul_41B_b2[3] = K[3][3];
				mul_41B_b2[4] = K[3][4];
				mul_41B_b2[5] = K[3][5];
				mul_41B_b2[6] = K[3][6];
				mul_41B_b2[7] = K[3][7];
			end
			4: begin
				mul_41B_b2[0] = K[4][0];
				mul_41B_b2[1] = K[4][1];
				mul_41B_b2[2] = K[4][2];
				mul_41B_b2[3] = K[4][3];
				mul_41B_b2[4] = K[4][4];
				mul_41B_b2[5] = K[4][5];
				mul_41B_b2[6] = K[4][6];
				mul_41B_b2[7] = K[4][7];
			end
			5: begin
				mul_41B_b2[0] = K[5][0];
				mul_41B_b2[1] = K[5][1];
				mul_41B_b2[2] = K[5][2];
				mul_41B_b2[3] = K[5][3];
				mul_41B_b2[4] = K[5][4];
				mul_41B_b2[5] = K[5][5];
				mul_41B_b2[6] = K[5][6];
				mul_41B_b2[7] = K[5][7];
			end
			6: begin
				mul_41B_b2[0] = K[6][0];
				mul_41B_b2[1] = K[6][1];
				mul_41B_b2[2] = K[6][2];
				mul_41B_b2[3] = K[6][3];
				mul_41B_b2[4] = K[6][4];
				mul_41B_b2[5] = K[6][5];
				mul_41B_b2[6] = K[6][6];
				mul_41B_b2[7] = K[6][7];
			end
			7: begin
				mul_41B_b2[0] = K[7][0];
				mul_41B_b2[1] = K[7][1];
				mul_41B_b2[2] = K[7][2];
				mul_41B_b2[3] = K[7][3];
				mul_41B_b2[4] = K[7][4];
				mul_41B_b2[5] = K[7][5];
				mul_41B_b2[6] = K[7][6];
				mul_41B_b2[7] = K[7][7];
			end
			default: begin
				mul_41B_b2[0] = 0;
				mul_41B_b2[1] = 0;
				mul_41B_b2[2] = 0;
				mul_41B_b2[3] = 0;
				mul_41B_b2[4] = 0;
				mul_41B_b2[5] = 0;
				mul_41B_b2[6] = 0;
				mul_41B_b2[7] = 0;
			end
		endcase
	end
	else begin
		case (col)
			0: begin
				mul_41B_b2[0] = S[0][0];
				mul_41B_b2[1] = S[0][1];
				mul_41B_b2[2] = S[0][2];
				mul_41B_b2[3] = S[0][3];
				mul_41B_b2[4] = S[0][4];
				mul_41B_b2[5] = S[0][5];
				mul_41B_b2[6] = S[0][6];
				mul_41B_b2[7] = S[0][7];
			end
			1: begin
				mul_41B_b2[0] = S[1][0];
				mul_41B_b2[1] = S[1][1];
				mul_41B_b2[2] = S[1][2];
				mul_41B_b2[3] = S[1][3];
				mul_41B_b2[4] = S[1][4];
				mul_41B_b2[5] = S[1][5];
				mul_41B_b2[6] = S[1][6];
				mul_41B_b2[7] = S[1][7];
			end
			2: begin
				mul_41B_b2[0] = S[2][0];
				mul_41B_b2[1] = S[2][1];
				mul_41B_b2[2] = S[2][2];
				mul_41B_b2[3] = S[2][3];
				mul_41B_b2[4] = S[2][4];
				mul_41B_b2[5] = S[2][5];
				mul_41B_b2[6] = S[2][6];
				mul_41B_b2[7] = S[2][7];
			end
			3: begin
				mul_41B_b2[0] = S[3][0];
				mul_41B_b2[1] = S[3][1];
				mul_41B_b2[2] = S[3][2];
				mul_41B_b2[3] = S[3][3];
				mul_41B_b2[4] = S[3][4];
				mul_41B_b2[5] = S[3][5];
				mul_41B_b2[6] = S[3][6];
				mul_41B_b2[7] = S[3][7];
			end
			4: begin
				mul_41B_b2[0] = S[4][0];
				mul_41B_b2[1] = S[4][1];
				mul_41B_b2[2] = S[4][2];
				mul_41B_b2[3] = S[4][3];
				mul_41B_b2[4] = S[4][4];
				mul_41B_b2[5] = S[4][5];
				mul_41B_b2[6] = S[4][6];
				mul_41B_b2[7] = S[4][7];
			end
			5: begin
				mul_41B_b2[0] = S[5][0];
				mul_41B_b2[1] = S[5][1];
				mul_41B_b2[2] = S[5][2];
				mul_41B_b2[3] = S[5][3];
				mul_41B_b2[4] = S[5][4];
				mul_41B_b2[5] = S[5][5];
				mul_41B_b2[6] = S[5][6];
				mul_41B_b2[7] = S[5][7];
			end
			6: begin
				mul_41B_b2[0] = S[6][0];
				mul_41B_b2[1] = S[6][1];
				mul_41B_b2[2] = S[6][2];
				mul_41B_b2[3] = S[6][3];
				mul_41B_b2[4] = S[6][4];
				mul_41B_b2[5] = S[6][5];
				mul_41B_b2[6] = S[6][6];
				mul_41B_b2[7] = S[6][7];
			end
			7: begin
				mul_41B_b2[0] = S[7][0];
				mul_41B_b2[1] = S[7][1];
				mul_41B_b2[2] = S[7][2];
				mul_41B_b2[3] = S[7][3];
				mul_41B_b2[4] = S[7][4];
				mul_41B_b2[5] = S[7][5];
				mul_41B_b2[6] = S[7][6];
				mul_41B_b2[7] = S[7][7];
			end
			default: begin
				mul_41B_b2[0] = 0;
				mul_41B_b2[1] = 0;
				mul_41B_b2[2] = 0;
				mul_41B_b2[3] = 0;
				mul_41B_b2[4] = 0;
				mul_41B_b2[5] = 0;
				mul_41B_b2[6] = 0;
				mul_41B_b2[7] = 0;
			end
		endcase
	end
end

assign mul_8B_z1[0] = mul_8B_a1[0] * mul_8B_b1[0];
assign mul_8B_z1[1] = mul_8B_a1[1] * mul_8B_b1[1];
assign mul_8B_z1[2] = mul_8B_a1[2] * mul_8B_b1[2];
assign mul_8B_z1[3] = mul_8B_a1[3] * mul_8B_b1[3];
assign mul_8B_z1[4] = mul_8B_a1[4] * mul_8B_b1[4];
assign mul_8B_z1[5] = mul_8B_a1[5] * mul_8B_b1[5];
assign mul_8B_z1[6] = mul_8B_a1[6] * mul_8B_b1[6];
assign mul_8B_z1[7] = mul_8B_a1[7] * mul_8B_b1[7];

assign mul_60B_z2[0] = mul_19B_a2[0] * mul_41B_b2[0];
assign mul_60B_z2[1] = mul_19B_a2[1] * mul_41B_b2[1];
assign mul_60B_z2[2] = mul_19B_a2[2] * mul_41B_b2[2];
assign mul_60B_z2[3] = mul_19B_a2[3] * mul_41B_b2[3];
assign mul_60B_z2[4] = mul_19B_a2[4] * mul_41B_b2[4];
assign mul_60B_z2[5] = mul_19B_a2[5] * mul_41B_b2[5];
assign mul_60B_z2[6] = mul_19B_a2[6] * mul_41B_b2[6];
assign mul_60B_z2[7] = mul_19B_a2[7] * mul_41B_b2[7];
//================================================================//
//                           ADDER
//================================================================//
//big
assign add_60B_a1 = mul_60B_z2[0];
assign add_60B_b1 = mul_60B_z2[1];
assign add_60B_a2 = mul_60B_z2[2];
assign add_60B_b2 = mul_60B_z2[3];
assign add_60B_a3 = mul_60B_z2[4];
assign add_60B_b3 = mul_60B_z2[5];
assign add_60B_a4 = mul_60B_z2[6];
assign add_60B_b4 = mul_60B_z2[7];

assign add_61B_a1 = add_60B_z1;
assign add_61B_b1 = add_60B_z2;
assign add_61B_a2 = add_60B_z3;
assign add_61B_b2 = add_60B_z4;

assign add_62B_a1 = add_61B_z1;
assign add_62B_b1 = add_61B_z2;

assign add_60B_z1 = add_60B_a1 + add_60B_b1;
assign add_60B_z2 = add_60B_a2 + add_60B_b2;
assign add_60B_z3 = add_60B_a3 + add_60B_b3;
assign add_60B_z4 = add_60B_a4 + add_60B_b4;

assign add_61B_z1 = add_61B_a1 + add_61B_b1;
assign add_61B_z2 = add_61B_a2 + add_61B_b2;

assign add_62B_z1 = add_62B_a1 + add_62B_b1;
//small
assign add_16B_a1 = mul_8B_z1[0];
assign add_16B_b1 = mul_8B_z1[1];
assign add_16B_a2 = mul_8B_z1[2];
assign add_16B_b2 = mul_8B_z1[3];
assign add_16B_a3 = mul_8B_z1[4];
assign add_16B_b3 = mul_8B_z1[5];
assign add_16B_a4 = mul_8B_z1[6];
assign add_16B_b4 = mul_8B_z1[7];

assign add_17B_a1 = add_16B_z1;
assign add_17B_b1 = add_16B_z2;
assign add_17B_a2 = add_16B_z3;
assign add_17B_b2 = add_16B_z4;

assign add_18B_a1 = add_17B_z1;
assign add_18B_b1 = add_17B_z2;

assign add_16B_z1 = add_16B_a1 + add_16B_b1;
assign add_16B_z2 = add_16B_a2 + add_16B_b2;
assign add_16B_z3 = add_16B_a3 + add_16B_b3;
assign add_16B_z4 = add_16B_a4 + add_16B_b4;

assign add_17B_z1 = add_17B_a1 + add_17B_b1;
assign add_17B_z2 = add_17B_a2 + add_17B_b2;

assign add_18B_z1 = add_18B_a1 + add_18B_b1;
//================================================================//
//                           RELU SCALE
//================================================================//
assign Relu = add_62B_z1 > 0 ? add_62B_z1 : 0;
assign Scale = Relu / 3;
//================================================================//
//                          OUT
//================================================================//
assign out_data = cur_state == S_OUT ? add_62B_z1 : 0;
assign out_valid = cur_state == S_OUT ? 1 : 0;
endmodule
