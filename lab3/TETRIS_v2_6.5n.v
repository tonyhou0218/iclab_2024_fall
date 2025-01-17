/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TETRIS
// FILE NAME: TETRIS.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TETRIS
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module TETRIS (
	//INPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//OUTPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[2:0]	tetrominoes;
input		[2:0]	position;

output reg			tetris_valid, score_valid, fail;
output reg	[3:0]	score;
output reg 	[71:0]	tetris;


//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer j,idx;
parameter S_idel = 'd0;
parameter S_put_figure = 'd1;
parameter S_eliminate_and_shift= 'd2;
parameter S_out= 'd3;
parameter S_hold= 'd4;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
//I/O
reg	in_valid_reg;
reg	[2:0] tetrominoes_reg,position_reg,position_reg_reg;
reg	[2:0] tetrominoes_reg_reg,tetrominoes_nxt,position_nxt;
reg tetris_valid_nxt;
reg score_valid_nxt,fail_nxt;
reg	[3:0]	score_nxt;
reg	[3:0]	score_temp;
//COMPUTE
reg [3:0] column_high[0:5],column_high_nxt[0:5];
reg [3:0] y[0:5];
reg [3:0] highest_col_num,highest_col_num_reg;
reg map[0:11][0:5] , map_nxt[0:11][0:5];
reg [7:0]data_8[0:5];
reg [3:0]data_4[0:5];
reg [1:0]data_2[0:5];
reg [15:0]group[0:5];
reg [3:0]cmp1,cmp2,cmp3,cmp4,cmp4_1,cmp6,cmp7,cmp_1and2;
reg score_tmp1,score_tmp2,score_tmp3,score_tmp4;
reg elimin1,elimin2,elimin3,elimin4;
reg [2:0]add1,add2,add3,add4;
reg [2:0]elimin_times,elimin_times_nxt;
reg [2:0]elimin_cnt,elimin_cnt_nxt;
reg [3:0]clear_row;
reg [4:0]pattern_num,pattern_num_nxt;
reg figure[0:3][0:5];
reg signed [4:0]i;
//state
reg [2:0] cur_state;
reg [2:0] nxt_state;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
//I/O
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        tetrominoes_reg<=0;
		tetrominoes_reg_reg<=0;
        position_reg<=0;
        position_reg_reg<=0;
        in_valid_reg<=0;

    end   
    else begin
		tetrominoes_reg<=tetrominoes;
		tetrominoes_reg_reg<=tetrominoes_nxt;
        position_reg<=position;
        position_reg_reg<=position_nxt;
        in_valid_reg<=in_valid;
    end
end
assign tetrominoes_nxt=in_valid ? tetrominoes : tetrominoes_reg_reg;
assign position_nxt   =in_valid ? position    : position_reg_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		//tetris_valid<=0;
		//score_valid<=0;
		fail<=0;
		score_temp<=0;
    end   
    else begin
        //tetris_valid<=tetris_valid_nxt;
		//score_valid<=score_valid_nxt;
		fail<= fail_nxt;
 		score_temp<= score_nxt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state<=S_idel;
    end
    else begin 
        cur_state<=nxt_state;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        elimin_times<=0;
        elimin_cnt<=0;
		highest_col_num_reg<=0;
		pattern_num<=0;
    end
    else begin 
        elimin_times<=elimin_times_nxt;
        elimin_cnt<=elimin_cnt_nxt;
		highest_col_num_reg<=highest_col_num;
		pattern_num<=pattern_num_nxt;
    end
end
/*always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		for(i=0;i<72;i++)begin
			tetris[i] <= 0;
		end
    end   
    else begin
		idx=0;
		for(i=12;i<=0;i--)begin
			for(j=0;j<5;j++)begin
				tetris[idx] <= map[i][j];	
				idx=idx+1;
			end
		end
    end
end*/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		map[0 ][0]=0;	map[0 ][1]=0;	map[0 ][2]=0;	map[0 ][3]=0;	map[0 ][4]=0;	map[0 ][5]=0;
		map[1 ][0]=0;	map[1 ][1]=0;	map[1 ][2]=0;	map[1 ][3]=0;	map[1 ][4]=0;	map[1 ][5]=0;
		map[2 ][0]=0;	map[2 ][1]=0;	map[2 ][2]=0;	map[2 ][3]=0;	map[2 ][4]=0;	map[2 ][5]=0;
		map[3 ][0]=0;	map[3 ][1]=0;	map[3 ][2]=0;	map[3 ][3]=0;	map[3 ][4]=0;	map[3 ][5]=0;
		map[4 ][0]=0;	map[4 ][1]=0;	map[4 ][2]=0;	map[4 ][3]=0;	map[4 ][4]=0;	map[4 ][5]=0;
		map[5 ][0]=0;	map[5 ][1]=0;	map[5 ][2]=0;	map[5 ][3]=0;	map[5 ][4]=0;	map[5 ][5]=0;
		map[6 ][0]=0;	map[6 ][1]=0;	map[6 ][2]=0;	map[6 ][3]=0;	map[6 ][4]=0;	map[6 ][5]=0;
		map[7 ][0]=0;	map[7 ][1]=0;	map[7 ][2]=0;	map[7 ][3]=0;	map[7 ][4]=0;	map[7 ][5]=0;
		map[8 ][0]=0;	map[8 ][1]=0;	map[8 ][2]=0;	map[8 ][3]=0;	map[8 ][4]=0;	map[8 ][5]=0;
		map[9 ][0]=0;	map[9 ][1]=0;	map[9 ][2]=0;	map[9 ][3]=0;	map[9 ][4]=0;	map[9 ][5]=0;
		map[10][0]=0;	map[10][1]=0;	map[10][2]=0;	map[10][3]=0;	map[10][4]=0;	map[10][5]=0;
		map[11][0]=0;	map[11][1]=0;	map[11][2]=0;	map[11][3]=0;	map[11][4]=0;	map[11][5]=0;
    end   
    else begin
		map[0 ][0]=map_nxt[0 ][0];	map[0 ][1]=map_nxt[0 ][1];	map[0 ][2]=map_nxt[0 ][2];	map[0 ][3]=map_nxt[0 ][3];	map[0 ][4]=map_nxt[0 ][4];	map[0 ][5]=map_nxt[0 ][5];
		map[1 ][0]=map_nxt[1 ][0];	map[1 ][1]=map_nxt[1 ][1];	map[1 ][2]=map_nxt[1 ][2];	map[1 ][3]=map_nxt[1 ][3];	map[1 ][4]=map_nxt[1 ][4];	map[1 ][5]=map_nxt[1 ][5];
		map[2 ][0]=map_nxt[2 ][0];	map[2 ][1]=map_nxt[2 ][1];	map[2 ][2]=map_nxt[2 ][2];	map[2 ][3]=map_nxt[2 ][3];	map[2 ][4]=map_nxt[2 ][4];	map[2 ][5]=map_nxt[2 ][5];
		map[3 ][0]=map_nxt[3 ][0];	map[3 ][1]=map_nxt[3 ][1];	map[3 ][2]=map_nxt[3 ][2];	map[3 ][3]=map_nxt[3 ][3];	map[3 ][4]=map_nxt[3 ][4];	map[3 ][5]=map_nxt[3 ][5];
		map[4 ][0]=map_nxt[4 ][0];	map[4 ][1]=map_nxt[4 ][1];	map[4 ][2]=map_nxt[4 ][2];	map[4 ][3]=map_nxt[4 ][3];	map[4 ][4]=map_nxt[4 ][4];	map[4 ][5]=map_nxt[4 ][5];
		map[5 ][0]=map_nxt[5 ][0];	map[5 ][1]=map_nxt[5 ][1];	map[5 ][2]=map_nxt[5 ][2];	map[5 ][3]=map_nxt[5 ][3];	map[5 ][4]=map_nxt[5 ][4];	map[5 ][5]=map_nxt[5 ][5];
		map[6 ][0]=map_nxt[6 ][0];	map[6 ][1]=map_nxt[6 ][1];	map[6 ][2]=map_nxt[6 ][2];	map[6 ][3]=map_nxt[6 ][3];	map[6 ][4]=map_nxt[6 ][4];	map[6 ][5]=map_nxt[6 ][5];
		map[7 ][0]=map_nxt[7 ][0];	map[7 ][1]=map_nxt[7 ][1];	map[7 ][2]=map_nxt[7 ][2];	map[7 ][3]=map_nxt[7 ][3];	map[7 ][4]=map_nxt[7 ][4];	map[7 ][5]=map_nxt[7 ][5];
		map[8 ][0]=map_nxt[8 ][0];	map[8 ][1]=map_nxt[8 ][1];	map[8 ][2]=map_nxt[8 ][2];	map[8 ][3]=map_nxt[8 ][3];	map[8 ][4]=map_nxt[8 ][4];	map[8 ][5]=map_nxt[8 ][5];
		map[9 ][0]=map_nxt[9 ][0];	map[9 ][1]=map_nxt[9 ][1];	map[9 ][2]=map_nxt[9 ][2];	map[9 ][3]=map_nxt[9 ][3];	map[9 ][4]=map_nxt[9 ][4];	map[9 ][5]=map_nxt[9 ][5];
		map[10][0]=map_nxt[10][0];	map[10][1]=map_nxt[10][1];	map[10][2]=map_nxt[10][2];	map[10][3]=map_nxt[10][3];	map[10][4]=map_nxt[10][4];	map[10][5]=map_nxt[10][5];
		map[11][0]=map_nxt[11][0];	map[11][1]=map_nxt[11][1];	map[11][2]=map_nxt[11][2];	map[11][3]=map_nxt[11][3];	map[11][4]=map_nxt[11][4];	map[11][5]=map_nxt[11][5];
    end
end

/*always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		column_high[0] <= 0;
		column_high[1] <= 0;
		column_high[2] <= 0;
		column_high[3] <= 0;
		column_high[4] <= 0;
		column_high[5] <= 0;
    end   
    else begin
		column_high[0] <= column_high_nxt[0];
		column_high[1] <= column_high_nxt[1];
		column_high[2] <= column_high_nxt[2];
		column_high[3] <= column_high_nxt[3];
		column_high[4] <= column_high_nxt[4];
		column_high[5] <= column_high_nxt[5];
    end
end*/
//state
always @(*) begin
	case (cur_state)
		S_idel:begin
			if(in_valid) nxt_state = S_put_figure;
			else         nxt_state = S_idel;
		end
		S_put_figure: begin
			if(add3 == 0 || highest_col_num == 12)begin
				nxt_state = S_out;
			end
			else begin
				nxt_state = S_eliminate_and_shift;
				/*if(elimin_times_nxt >= 1)
					
				else
					nxt_state = S_out;*/
			end
		end

		S_eliminate_and_shift:begin
			if(elimin_times==elimin_cnt) nxt_state = S_out;
			else                         nxt_state = S_eliminate_and_shift;
		end
		S_out:begin
			if(fail || pattern_num==16) nxt_state = S_idel;
			else                        nxt_state = S_hold;
		end
		
		S_hold : begin
			if(in_valid) nxt_state = S_put_figure;
			else         nxt_state = S_hold;
		end
		default: nxt_state = S_idel;
	endcase
end
always @(*) begin
		case (cur_state)

		S_put_figure: begin
			elimin_times_nxt = add3;
			elimin_cnt_nxt = 1;
		end

		S_eliminate_and_shift:begin
			elimin_times_nxt = elimin_times ;
			elimin_cnt_nxt = elimin_cnt + 1;
		end

		default: begin
			elimin_times_nxt = 0;
			elimin_cnt_nxt = 0;
		end
		
	endcase
end
always @(*) begin
	case (cur_state)

		S_put_figure: begin
			pattern_num_nxt = pattern_num + 1;
		end
		S_out:begin
			if(fail || pattern_num==16) pattern_num_nxt = 0;
			else                        pattern_num_nxt = pattern_num;
		end
		default: pattern_num_nxt = pattern_num;
	endcase
end
//map control
always @(*) begin

	map_nxt[0 ][0]=map[0 ][0];	map_nxt[0 ][1]=map[0 ][1];	map_nxt[0 ][2]=map[0 ][2];	map_nxt[0 ][3]=map[0 ][3];	map_nxt[0 ][4]=map[0 ][4];	map_nxt[0 ][5]=map[0 ][5];
	map_nxt[1 ][0]=map[1 ][0];	map_nxt[1 ][1]=map[1 ][1];	map_nxt[1 ][2]=map[1 ][2];	map_nxt[1 ][3]=map[1 ][3];	map_nxt[1 ][4]=map[1 ][4];	map_nxt[1 ][5]=map[1 ][5];
	map_nxt[2 ][0]=map[2 ][0];	map_nxt[2 ][1]=map[2 ][1];	map_nxt[2 ][2]=map[2 ][2];	map_nxt[2 ][3]=map[2 ][3];	map_nxt[2 ][4]=map[2 ][4];	map_nxt[2 ][5]=map[2 ][5];
	map_nxt[3 ][0]=map[3 ][0];	map_nxt[3 ][1]=map[3 ][1];	map_nxt[3 ][2]=map[3 ][2];	map_nxt[3 ][3]=map[3 ][3];	map_nxt[3 ][4]=map[3 ][4];	map_nxt[3 ][5]=map[3 ][5];
	map_nxt[4 ][0]=map[4 ][0];	map_nxt[4 ][1]=map[4 ][1];	map_nxt[4 ][2]=map[4 ][2];	map_nxt[4 ][3]=map[4 ][3];	map_nxt[4 ][4]=map[4 ][4];	map_nxt[4 ][5]=map[4 ][5];
	map_nxt[5 ][0]=map[5 ][0];	map_nxt[5 ][1]=map[5 ][1];	map_nxt[5 ][2]=map[5 ][2];	map_nxt[5 ][3]=map[5 ][3];	map_nxt[5 ][4]=map[5 ][4];	map_nxt[5 ][5]=map[5 ][5];
	map_nxt[6 ][0]=map[6 ][0];	map_nxt[6 ][1]=map[6 ][1];	map_nxt[6 ][2]=map[6 ][2];	map_nxt[6 ][3]=map[6 ][3];	map_nxt[6 ][4]=map[6 ][4];	map_nxt[6 ][5]=map[6 ][5];
	map_nxt[7 ][0]=map[7 ][0];	map_nxt[7 ][1]=map[7 ][1];	map_nxt[7 ][2]=map[7 ][2];	map_nxt[7 ][3]=map[7 ][3];	map_nxt[7 ][4]=map[7 ][4];	map_nxt[7 ][5]=map[7 ][5];
	map_nxt[8 ][0]=map[8 ][0];	map_nxt[8 ][1]=map[8 ][1];	map_nxt[8 ][2]=map[8 ][2];	map_nxt[8 ][3]=map[8 ][3];	map_nxt[8 ][4]=map[8 ][4];	map_nxt[8 ][5]=map[8 ][5];
	map_nxt[9 ][0]=map[9 ][0];	map_nxt[9 ][1]=map[9 ][1];	map_nxt[9 ][2]=map[9 ][2];	map_nxt[9 ][3]=map[9 ][3];	map_nxt[9 ][4]=map[9 ][4];	map_nxt[9 ][5]=map[9 ][5];
	map_nxt[10][0]=map[10][0];	map_nxt[10][1]=map[10][1];	map_nxt[10][2]=map[10][2];	map_nxt[10][3]=map[10][3];	map_nxt[10][4]=map[10][4];	map_nxt[10][5]=map[10][5];
	map_nxt[11][0]=map[11][0];	map_nxt[11][1]=map[11][1];	map_nxt[11][2]=map[11][2];	map_nxt[11][3]=map[11][3];	map_nxt[11][4]=map[11][4];	map_nxt[11][5]=map[11][5];
	highest_col_num = 0;
	case (cur_state)
	S_idel:
	begin
		highest_col_num=0;
		map_nxt[0 ][0]=0;	map_nxt[0 ][1]=0;	map_nxt[0 ][2]=0;	map_nxt[0 ][3]=0;	map_nxt[0 ][4]=0;	map_nxt[0 ][5]=0;
		map_nxt[1 ][0]=0;	map_nxt[1 ][1]=0;	map_nxt[1 ][2]=0;	map_nxt[1 ][3]=0;	map_nxt[1 ][4]=0;	map_nxt[1 ][5]=0;
		map_nxt[2 ][0]=0;	map_nxt[2 ][1]=0;	map_nxt[2 ][2]=0;	map_nxt[2 ][3]=0;	map_nxt[2 ][4]=0;	map_nxt[2 ][5]=0;
		map_nxt[3 ][0]=0;	map_nxt[3 ][1]=0;	map_nxt[3 ][2]=0;	map_nxt[3 ][3]=0;	map_nxt[3 ][4]=0;	map_nxt[3 ][5]=0;
		map_nxt[4 ][0]=0;	map_nxt[4 ][1]=0;	map_nxt[4 ][2]=0;	map_nxt[4 ][3]=0;	map_nxt[4 ][4]=0;	map_nxt[4 ][5]=0;
		map_nxt[5 ][0]=0;	map_nxt[5 ][1]=0;	map_nxt[5 ][2]=0;	map_nxt[5 ][3]=0;	map_nxt[5 ][4]=0;	map_nxt[5 ][5]=0;
		map_nxt[6 ][0]=0;	map_nxt[6 ][1]=0;	map_nxt[6 ][2]=0;	map_nxt[6 ][3]=0;	map_nxt[6 ][4]=0;	map_nxt[6 ][5]=0;
		map_nxt[7 ][0]=0;	map_nxt[7 ][1]=0;	map_nxt[7 ][2]=0;	map_nxt[7 ][3]=0;	map_nxt[7 ][4]=0;	map_nxt[7 ][5]=0;
		map_nxt[8 ][0]=0;	map_nxt[8 ][1]=0;	map_nxt[8 ][2]=0;	map_nxt[8 ][3]=0;	map_nxt[8 ][4]=0;	map_nxt[8 ][5]=0;
		map_nxt[9 ][0]=0;	map_nxt[9 ][1]=0;	map_nxt[9 ][2]=0;	map_nxt[9 ][3]=0;	map_nxt[9 ][4]=0;	map_nxt[9 ][5]=0;
		map_nxt[10][0]=0;	map_nxt[10][1]=0;	map_nxt[10][2]=0;	map_nxt[10][3]=0;	map_nxt[10][4]=0;	map_nxt[10][5]=0;
		map_nxt[11][0]=0;	map_nxt[11][1]=0;	map_nxt[11][2]=0;	map_nxt[11][3]=0;	map_nxt[11][4]=0;	map_nxt[11][5]=0;
	end
	S_put_figure: begin
		case (tetrominoes_reg)
			0:begin
				if(column_high[position_reg] > column_high[position_reg + 1]) highest_col_num = column_high[position_reg];
				else                                                          highest_col_num = column_high[position_reg + 1];
				map_nxt [10-highest_col_num][position_reg]=1;map_nxt [10-highest_col_num][position_reg+1]=1;
				map_nxt [11-highest_col_num][position_reg]=1;map_nxt [11-highest_col_num][position_reg+1]=1;
			end 
			1:begin
				highest_col_num = column_high[position_reg];
				map_nxt [8- highest_col_num][position_reg]=1;
				map_nxt [9- highest_col_num][position_reg]=1;
				map_nxt [10-highest_col_num][position_reg]=1;
				map_nxt [11-highest_col_num][position_reg]=1;
			end
			2:begin
				highest_col_num = cmp_1and2;
				map_nxt [11-highest_col_num][position_reg]=1;map_nxt [11-highest_col_num][position_reg+1]=1;map_nxt [11-highest_col_num][position_reg+2]=1;map_nxt [11-highest_col_num][position_reg+3]=1;
			end
			3:begin
				highest_col_num = cmp3;
				map_nxt [9- highest_col_num][position_reg]=1;map_nxt [9-  highest_col_num][position_reg+1]=1;
															 map_nxt [10- highest_col_num][position_reg+1]=1;
															 map_nxt [11- highest_col_num][position_reg+1]=1;
			end
			4:begin
				highest_col_num = cmp4_1;
				map_nxt [10- highest_col_num][position_reg]=1;map_nxt [10- highest_col_num][position_reg+1]=1;map_nxt [10- highest_col_num][position_reg+2]=1;
				map_nxt [11- highest_col_num][position_reg]=1;
			end
			5:begin
				highest_col_num = cmp1;
				map_nxt [9-  highest_col_num][position_reg]=1;
				map_nxt [10- highest_col_num][position_reg]=1;
				map_nxt [11- highest_col_num][position_reg]=1;map_nxt [11- highest_col_num][position_reg+1]=1;
			end
			6:begin
				highest_col_num = cmp6;
				map_nxt [9-  highest_col_num][position_reg]=1;
				map_nxt [10- highest_col_num][position_reg]=1;map_nxt [10-  highest_col_num][position_reg+1]=1;
															  map_nxt [11-  highest_col_num][position_reg+1]=1;
			end
			7:begin
				highest_col_num = cmp7;
															   map_nxt [10-  highest_col_num][position_reg+1]=1;map_nxt [10-  highest_col_num][position_reg+2]=1;
				map_nxt [11-  highest_col_num][position_reg]=1;map_nxt [11-  highest_col_num][position_reg+1]=1;
			end
			
		endcase
	end
	S_eliminate_and_shift:
	begin
		highest_col_num = highest_col_num_reg;
		if(elimin1)begin
			clear_row =12- highest_col_num_reg - 1;
		end
		else if(elimin2)begin
			clear_row =12- highest_col_num_reg - 2;
		end
		else if( elimin3)begin
			clear_row =12- highest_col_num_reg - 3;
		end
		else clear_row =12- highest_col_num_reg - 4;

		/*for(i=clear_row;i>=1;i=i-1)begin
			map_nxt[i]=map[i-1];

		end*/
		case (clear_row)
			1:begin
				map_nxt[1]=map[0];
			end 
			2:begin
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			3:begin
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			4:begin
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			5:begin
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			6:begin
				map_nxt[6]=map[5];
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			7:begin
				map_nxt[7]=map[6];
				map_nxt[6]=map[5];
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			8:begin
				map_nxt[8]=map[7];
				map_nxt[7]=map[6];
				map_nxt[6]=map[5];
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			9:begin
				map_nxt[9]=map[8];
				map_nxt[8]=map[7];
				map_nxt[7]=map[6];
				map_nxt[6]=map[5];
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			10:begin
				map_nxt[10]=map[9];
				map_nxt[9]=map[8];
				map_nxt[8]=map[7];
				map_nxt[7]=map[6];
				map_nxt[6]=map[5];
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			11:begin
				map_nxt[11]=map[10];
				map_nxt[10]=map[9];
				map_nxt[9]=map[8];
				map_nxt[8]=map[7];
				map_nxt[7]=map[6];
				map_nxt[6]=map[5];
				map_nxt[5]=map[4];
				map_nxt[4]=map[3];
				map_nxt[3]=map[2];
				map_nxt[2]=map[1];
				map_nxt[1]=map[0];
			end
			default: begin
				map_nxt[11]=map[11];
				map_nxt[10]=map[10];
				map_nxt[9 ]=map[9 ];
				map_nxt[8 ]=map[8 ];
				map_nxt[7 ]=map[7 ];
				map_nxt[6 ]=map[6 ];
				map_nxt[5 ]=map[5 ];
				map_nxt[4 ]=map[4 ];
				map_nxt[3 ]=map[3 ];
				map_nxt[2 ]=map[2 ];
				map_nxt[1 ]=map[1 ];
				map_nxt[0 ]=map[0 ];
			end
		endcase
		map_nxt[0][0]=0;
		map_nxt[0][1]=0;
		map_nxt[0][2]=0;
		map_nxt[0][3]=0;
		map_nxt[0][4]=0;
		map_nxt[0][5]=0;
		case (tetrominoes_reg_reg)
			0,4,7:begin
				if(highest_col_num_reg>=11)begin
					map_nxt[0][0]=figure[2][0];
					map_nxt[0][1]=figure[2][1];
					map_nxt[0][2]=figure[2][2];
					map_nxt[0][3]=figure[2][3];
					map_nxt[0][4]=figure[2][4];
					map_nxt[0][5]=figure[2][5];
				end
			end 
			3,5,6:begin
				if(clear_row<=1 && highest_col_num_reg>=10)begin
					map_nxt[0][0]=figure[2-elimin_cnt][0];
					map_nxt[0][1]=figure[2-elimin_cnt][1];
					map_nxt[0][2]=figure[2-elimin_cnt][2];
					map_nxt[0][3]=figure[2-elimin_cnt][3];
					map_nxt[0][4]=figure[2-elimin_cnt][4];
					map_nxt[0][5]=figure[2-elimin_cnt][5];
				end
			end
			1:begin
				if(clear_row<=2 && highest_col_num_reg>=9)begin
					map_nxt[0][0]=figure[3][0];
					map_nxt[0][1]=figure[3][1];
					map_nxt[0][2]=figure[3][2];
					map_nxt[0][3]=figure[3][3];
					map_nxt[0][4]=figure[3][4];
					map_nxt[0][5]=figure[3][5];
				end
			end
			
		endcase

	end
	endcase
end	
//pre compare
//包invalid reg
assign cmp1 = (column_high[position_reg]   > column_high[position_reg + 1]) ? column_high[position_reg]   : column_high[position_reg + 1];
assign cmp2 = (column_high[position_reg+2] > column_high[position_reg + 3]) ? column_high[position_reg+2] : column_high[position_reg + 3];
assign cmp_1and2 = cmp1 > cmp2 ? cmp1 : cmp2 ;
assign cmp3 = ((cmp1 == column_high[position_reg]) && (column_high[position_reg]-column_high[position_reg+1] > 2)) ? cmp1 - 2 :column_high[position_reg + 1] ;//ex.for type3 (left higher right 2) ? ground =left + 2 : ground = right
assign cmp4 = cmp1 > column_high[position_reg + 2] ? cmp1 : column_high[position_reg + 2];// highest of 3 rows, ex. type4,7
assign cmp4_1 = (cmp4 - column_high[position_reg]) >= 1 ? cmp4 - 1 : column_high[position_reg];
assign cmp6 = (cmp1 - column_high[position_reg+1]) >= 1? cmp1 - 1 : column_high[position_reg+1];
assign cmp7 = (cmp4== column_high[position_reg ] || cmp4== column_high[position_reg+1]) ? cmp4 : column_high[position_reg+2]-1;

//column high
/*
always @(*) begin
	case (cur_state)
		S_idel:begin
			column_high_nxt[0] = 0;
			column_high_nxt[1] = 0;
			column_high_nxt[2] = 0;
			column_high_nxt[3] = 0;
			column_high_nxt[4] = 0;
			column_high_nxt[5] = 0;
		end 
		S_put_figure:
		begin
			column_high_nxt[0] = column_high[0];
			column_high_nxt[1] = column_high[1];
			column_high_nxt[2] = column_high[2];
			column_high_nxt[3] = column_high[3];
			column_high_nxt[4] = column_high[4];
			column_high_nxt[5] = column_high[5];
			case (tetrominoes_reg)
				0:begin
					column_high_nxt[position_reg  ]=cmp1+2;
					column_high_nxt[position_reg+1]=cmp1+2;
				end 
				1:begin
					column_high_nxt[position_reg]=column_high_nxt[position_reg]+4;
				end
				2:begin
					column_high_nxt[position_reg  ]=cmp_1and2+1;
					column_high_nxt[position_reg+1]=cmp_1and2+1;
					column_high_nxt[position_reg+2]=cmp_1and2+1;
					column_high_nxt[position_reg+3]=cmp_1and2+1;
				end
				3:begin
					column_high_nxt[position_reg  ]=cmp3+3;
					column_high_nxt[position_reg+1]=cmp3+3;
				end
				4:begin
					column_high_nxt[position_reg  ]=cmp4_1+2;
					column_high_nxt[position_reg+1]=cmp4_1+2;
					column_high_nxt[position_reg+2]=cmp4_1+2;
				end
				5:begin
					column_high_nxt[position_reg  ]=cmp1+3;
					column_high_nxt[position_reg+1]=cmp1+1;

				end
				6:begin
					column_high_nxt[position_reg  ]=cmp6+3;
					column_high_nxt[position_reg+1]=cmp6+2;
				end
				7:begin
					column_high_nxt[position_reg  ]=cmp7+1;
					column_high_nxt[position_reg+1]=cmp7+2;
					column_high_nxt[position_reg+2]=cmp7+2;
				end

			endcase
		end
		S_eliminate_and_shift:
		begin
			column_high_nxt[0] = column_high[0] - 1;
			column_high_nxt[1] = column_high[1] - 1;
			column_high_nxt[2] = column_high[2] - 1;
			column_high_nxt[3] = column_high[3] - 1;
			column_high_nxt[4] = column_high[4] - 1;
			column_high_nxt[5] = column_high[5] - 1;
		end
		default :begin
			column_high_nxt[0] = column_high[0];
			column_high_nxt[1] = column_high[1];
			column_high_nxt[2] = column_high[2];
			column_high_nxt[3] = column_high[3];
			column_high_nxt[4] = column_high[4];
			column_high_nxt[5] = column_high[5];
		end
	endcase
end*/

//score compute
always @(*) begin
	if(11 >= highest_col_num  ) elimin1 = map[12-highest_col_num_reg-1][0] & map[12-highest_col_num_reg-1][1] & map[12-highest_col_num_reg-1][2] & map[12-highest_col_num_reg-1][3] & map[12-highest_col_num_reg-1][4] & map[12-highest_col_num_reg-1][5] ;
	else                        elimin1 = 0;
	if(10 >= highest_col_num  ) elimin2 = map[12-highest_col_num_reg-2][0] & map[12-highest_col_num_reg-2][1] & map[12-highest_col_num_reg-2][2] & map[12-highest_col_num_reg-2][3] & map[12-highest_col_num_reg-2][4] & map[12-highest_col_num_reg-2][5] ;
	else                        elimin2 = 0;
	if(9  >= highest_col_num  ) elimin3 = map[12-highest_col_num_reg-3][0] & map[12-highest_col_num_reg-3][1] & map[12-highest_col_num_reg-3][2] & map[12-highest_col_num_reg-3][3] & map[12-highest_col_num_reg-3][4] & map[12-highest_col_num_reg-3][5] ;
	else                        elimin3 = 0;
	if(8  >= highest_col_num  ) elimin4 = map[12-highest_col_num_reg-4][0] & map[12-highest_col_num_reg-4][1] & map[12-highest_col_num_reg-4][2] & map[12-highest_col_num_reg-4][3] & map[12-highest_col_num_reg-4][4] & map[12-highest_col_num_reg-4][5] ;
	else                        elimin4 = 0;

end
always @(*) begin
	if(11 >= highest_col_num) score_tmp1 = map_nxt[12-highest_col_num-1][0] & map_nxt[12-highest_col_num-1][1] & map_nxt[12-highest_col_num-1][2] & map_nxt[12-highest_col_num-1][3] & map_nxt[12-highest_col_num-1][4] & map_nxt[12-highest_col_num-1][5] ;
	else                     score_tmp1 = 0;
	if(10 >= highest_col_num) score_tmp2 = map_nxt[12-highest_col_num-2][0] & map_nxt[12-highest_col_num-2][1] & map_nxt[12-highest_col_num-2][2] & map_nxt[12-highest_col_num-2][3] & map_nxt[12-highest_col_num-2][4] & map_nxt[12-highest_col_num-2][5] ;
	else                     score_tmp2 = 0;
	if(9  >= highest_col_num)score_tmp3 = map_nxt[12-highest_col_num-3][0] & map_nxt[12-highest_col_num-3][1] & map_nxt[12-highest_col_num-3][2] & map_nxt[12-highest_col_num-3][3] & map_nxt[12-highest_col_num-3][4] & map_nxt[12-highest_col_num-3][5] ;
	else                     score_tmp3 = 0;
	if(8  >= highest_col_num)score_tmp4 = map_nxt[12-highest_col_num-4][0] & map_nxt[12-highest_col_num-4][1] & map_nxt[12-highest_col_num-4][2] & map_nxt[12-highest_col_num-4][3] & map_nxt[12-highest_col_num-4][4] & map_nxt[12-highest_col_num-4][5] ;
	else                     score_tmp4 = 0;
	add1 = score_tmp1 + score_tmp2;
	add2 = score_tmp3 + score_tmp4;
	add3 = add1 + add2;
end
always @(*) begin
	case (cur_state)
		S_put_figure: begin
			score_nxt = score_temp + add3;
		end
		S_out:begin
			if(fail || pattern_num==16)score_nxt = 0;
			else                       score_nxt = score_temp;
		end
		default:
		begin
			score_nxt = score_temp;
		end

	endcase

end
//OUTPUT
always @(*) begin
	case (cur_state)
		S_out:begin
			if(tetris_valid)begin
				tetris[66]=map[0 ][0];	tetris[67]=map[0 ][1];	tetris[68]=map[0 ][2];	tetris[69]=map[0 ][3];	tetris[70]=map[0 ][4];	tetris[71]=map[0 ][5];
				tetris[60]=map[1 ][0];	tetris[61]=map[1 ][1];	tetris[62]=map[1 ][2];	tetris[63]=map[1 ][3];	tetris[64]=map[1 ][4];	tetris[65]=map[1 ][5];
				tetris[54]=map[2 ][0];	tetris[55]=map[2 ][1];	tetris[56]=map[2 ][2];	tetris[57]=map[2 ][3];	tetris[58]=map[2 ][4];	tetris[59]=map[2 ][5];
				tetris[48]=map[3 ][0];	tetris[49]=map[3 ][1];	tetris[50]=map[3 ][2];	tetris[51]=map[3 ][3];	tetris[52]=map[3 ][4];	tetris[53]=map[3 ][5];
				tetris[42]=map[4 ][0];	tetris[43]=map[4 ][1];	tetris[44]=map[4 ][2];	tetris[45]=map[4 ][3];	tetris[46]=map[4 ][4];	tetris[47]=map[4 ][5];
				tetris[36]=map[5 ][0];	tetris[37]=map[5 ][1];	tetris[38]=map[5 ][2];	tetris[39]=map[5 ][3];	tetris[40]=map[5 ][4];	tetris[41]=map[5 ][5];
				tetris[30]=map[6 ][0];	tetris[31]=map[6 ][1];	tetris[32]=map[6 ][2];	tetris[33]=map[6 ][3];	tetris[34]=map[6 ][4];	tetris[35]=map[6 ][5];
				tetris[24]=map[7 ][0];	tetris[25]=map[7 ][1];	tetris[26]=map[7 ][2];	tetris[27]=map[7 ][3];	tetris[28]=map[7 ][4];	tetris[29]=map[7 ][5];
				tetris[18]=map[8 ][0];	tetris[19]=map[8 ][1];	tetris[20]=map[8 ][2];	tetris[21]=map[8 ][3];	tetris[22]=map[8 ][4];	tetris[23]=map[8 ][5];
				tetris[12]=map[9 ][0];	tetris[13]=map[9 ][1];	tetris[14]=map[9 ][2];	tetris[15]=map[9 ][3];	tetris[16]=map[9 ][4];	tetris[17]=map[9 ][5];
				tetris[6 ]=map[10][0];	tetris[7 ]=map[10][1];	tetris[8 ]=map[10][2];	tetris[9 ]=map[10][3];	tetris[10]=map[10][4];	tetris[11]=map[10][5];
				tetris[0 ]=map[11][0];	tetris[1 ]=map[11][1];	tetris[2 ]=map[11][2];	tetris[3 ]=map[11][3];	tetris[4 ]=map[11][4];	tetris[5 ]=map[11][5];
			end
			else begin
				tetris[66]=0;	tetris[67]=0;	tetris[68]=0;	tetris[69]=0;	tetris[70]=0;	tetris[71]=0;
				tetris[60]=0;	tetris[61]=0;	tetris[62]=0;	tetris[63]=0;	tetris[64]=0;	tetris[65]=0;
				tetris[54]=0;	tetris[55]=0;	tetris[56]=0;	tetris[57]=0;	tetris[58]=0;	tetris[59]=0;
				tetris[48]=0;	tetris[49]=0;	tetris[50]=0;	tetris[51]=0;	tetris[52]=0;	tetris[53]=0;
				tetris[42]=0;	tetris[43]=0;	tetris[44]=0;	tetris[45]=0;	tetris[46]=0;	tetris[47]=0;
				tetris[36]=0;	tetris[37]=0;	tetris[38]=0;	tetris[39]=0;	tetris[40]=0;	tetris[41]=0;
				tetris[30]=0;	tetris[31]=0;	tetris[32]=0;	tetris[33]=0;	tetris[34]=0;	tetris[35]=0;
				tetris[24]=0;	tetris[25]=0;	tetris[26]=0;	tetris[27]=0;	tetris[28]=0;	tetris[29]=0;
				tetris[18]=0;	tetris[19]=0;	tetris[20]=0;	tetris[21]=0;	tetris[22]=0;	tetris[23]=0;
				tetris[12]=0;	tetris[13]=0;	tetris[14]=0;	tetris[15]=0;	tetris[16]=0;	tetris[17]=0;
				tetris[6 ]=0;	tetris[7 ]=0;	tetris[8 ]=0;	tetris[9 ]=0;	tetris[10]=0;	tetris[11]=0;
				tetris[0 ]=0;	tetris[1 ]=0;	tetris[2 ]=0;	tetris[3 ]=0;	tetris[4 ]=0;	tetris[5 ]=0;
			end
		end 
		default: begin
			tetris[66]=0;	tetris[67]=0;	tetris[68]=0;	tetris[69]=0;	tetris[70]=0;	tetris[71]=0;
			tetris[60]=0;	tetris[61]=0;	tetris[62]=0;	tetris[63]=0;	tetris[64]=0;	tetris[65]=0;
			tetris[54]=0;	tetris[55]=0;	tetris[56]=0;	tetris[57]=0;	tetris[58]=0;	tetris[59]=0;
			tetris[48]=0;	tetris[49]=0;	tetris[50]=0;	tetris[51]=0;	tetris[52]=0;	tetris[53]=0;
			tetris[42]=0;	tetris[43]=0;	tetris[44]=0;	tetris[45]=0;	tetris[46]=0;	tetris[47]=0;
			tetris[36]=0;	tetris[37]=0;	tetris[38]=0;	tetris[39]=0;	tetris[40]=0;	tetris[41]=0;
			tetris[30]=0;	tetris[31]=0;	tetris[32]=0;	tetris[33]=0;	tetris[34]=0;	tetris[35]=0;
			tetris[24]=0;	tetris[25]=0;	tetris[26]=0;	tetris[27]=0;	tetris[28]=0;	tetris[29]=0;
			tetris[18]=0;	tetris[19]=0;	tetris[20]=0;	tetris[21]=0;	tetris[22]=0;	tetris[23]=0;
			tetris[12]=0;	tetris[13]=0;	tetris[14]=0;	tetris[15]=0;	tetris[16]=0;	tetris[17]=0;
			tetris[6 ]=0;	tetris[7 ]=0;	tetris[8 ]=0;	tetris[9 ]=0;	tetris[10]=0;	tetris[11]=0;
			tetris[0 ]=0;	tetris[1 ]=0;	tetris[2 ]=0;	tetris[3 ]=0;	tetris[4 ]=0;	tetris[5 ]=0;
		end
	endcase
end
always @(*) begin
	case (cur_state)
		S_out: begin
			score_valid = 1;
			score = score_temp;
		end
		default:
		begin
			score = 0;
			score_valid = 0;
		end

	endcase
end
always @(*) begin
	case (cur_state)
		S_put_figure: begin
			//fail= 0;
			if(highest_col_num == 12)begin
				fail_nxt = 1;
			end
			else begin
				if(add3 == 0)begin
					case (tetrominoes_reg)
						0,4,7: begin
							if(highest_col_num>=11) fail_nxt = 1;
							else                    fail_nxt = 0;
						end
						3,5,6:begin
							if(highest_col_num>=10) fail_nxt = 1;
							else                    fail_nxt = 0;
						end
						1: begin
							if(highest_col_num>=9)  fail_nxt = 1;
							else                    fail_nxt = 0;
						end
						default: fail_nxt = 0;
					endcase
				end
				else fail_nxt = 0;
				
			end
			/*if(highest_col_num == 12)begin
				fail_nxt = 1;
			end
			else begin
				
			end*/
		end
		S_out:begin
			
			fail_nxt = 0;
			/*if(highest_col_num_reg == 12)begin
				fail = 1;
			end
			else begin
				case (tetrominoes_reg_reg)
					0,4,7: begin
						if(highest_col_num_reg>=11) fail = 1;
						else                        fail = 0;
					end
					3,5,6:begin
						if(highest_col_num_reg>=10) fail = 1;
						else                        fail = 0;
					end
					1: begin
						if(highest_col_num_reg>=9)  fail = 1;
						else                        fail = 0;
					end
					default: fail = 0;
				endcase
				
			end*/
		end
		S_eliminate_and_shift:begin
			//next need output so set fail signal
			if(elimin_cnt == elimin_times)begin
				case (tetrominoes_reg_reg)
					0,4,7: begin
						fail_nxt = 0;// because in (S_eliminate_and_shift) must elimin 1 line                   
					end
					3,5,6:begin
						if((highest_col_num + 3 - elimin_times) >= 13) fail_nxt = 1;
						else                                           fail_nxt = 0;
					end
					1: begin
						if((highest_col_num + 4 - elimin_times) >= 13) fail_nxt = 1;
						else                                           fail_nxt = 0;
					end
					default: fail_nxt = 0;
				endcase
			end
			else fail_nxt = 0;
		end
		default:
		begin
			fail_nxt = 0;
		end
	endcase
end
//outvalid cntrol
/*always @(*) begin
	case (cur_state)
		S_put_figure: begin
			if(add3 == 0)begin
				score_valid_nxt = 1;
			end
			else begin
				score_valid_nxt = 0;
			end
		end
		default:
		begin
			score_valid_nxt = 0;
		end
	endcase

end*/

always @(*) begin
	case (cur_state)
		S_out:
		begin
			if(fail || pattern_num==16)tetris_valid = 1;
			else                       tetris_valid = 0;
		end
		default:
		begin
			tetris_valid = 0;
		end

	endcase
end
always @(*) begin
	figure[0][0]=0;figure[0][1]=0;figure[0][2]=0;figure[0][3]=0;figure[0][4]=0;figure[0][5]=0;
	figure[1][0]=0;figure[1][1]=0;figure[1][2]=0;figure[1][3]=0;figure[1][4]=0;figure[1][5]=0;
	figure[2][0]=0;figure[2][1]=0;figure[2][2]=0;figure[2][3]=0;figure[2][4]=0;figure[2][5]=0;
	figure[3][0]=0;figure[3][1]=0;figure[3][2]=0;figure[3][3]=0;figure[3][4]=0;figure[3][5]=0;
	case (tetrominoes_reg_reg)
		0:begin
            figure[2][0+position_reg_reg]=1; figure[2][1+position_reg_reg]=1;
            figure[3][0+position_reg_reg]=1; figure[3][1+position_reg_reg]=1;
        end 
        1:begin
            figure[0][position_reg_reg]=1;
            figure[1][position_reg_reg]=1;
            figure[2][position_reg_reg]=1;
            figure[3][position_reg_reg]=1;
        end 
        2:begin
			figure[3][0+position_reg_reg]=1;
			figure[3][1+position_reg_reg]=1;
			figure[3][2+position_reg_reg]=1;
			figure[3][3+position_reg_reg]=1;
        end         
        3:begin 
            figure[1][0+position_reg_reg]=1;figure[1][1+position_reg_reg]=1;
                                            figure[2][1+position_reg_reg]=1;
                                            figure[3][1+position_reg_reg]=1;
        end         
        4:begin
            figure[2][0+position_reg_reg]=1;figure[2][1+position_reg_reg]=1;figure[2][2+position_reg_reg]=1;
            figure[3][0+position_reg_reg]=1;
        end
        5:begin
            figure[1][0+position_reg_reg]=1;
            figure[2][0+position_reg_reg]=1;
            figure[3][0+position_reg_reg]=1;figure[3][1+position_reg_reg]=1;
        end
        6:begin
            figure[1][0+position_reg_reg]=1;
            figure[2][0+position_reg_reg]=1;figure[2][1+position_reg_reg]=1;
                                            figure[3][1+position_reg_reg]=1;
        end
        7:begin
                                            figure[2][1+position_reg_reg]=1;figure[2][2+position_reg_reg]=1;
            figure[3][0+position_reg_reg]=1;figure[3][1+position_reg_reg]=1;
        end
		default: begin
			figure[0][0]=0;figure[0][1]=0;figure[0][2]=0;figure[0][3]=0;figure[0][4]=0;figure[0][5]=0;
            figure[1][0]=0;figure[1][1]=0;figure[1][2]=0;figure[1][3]=0;figure[1][4]=0;figure[1][5]=0;
            figure[2][0]=0;figure[2][1]=0;figure[2][2]=0;figure[2][3]=0;figure[2][4]=0;figure[2][5]=0;
            figure[3][0]=0;figure[3][1]=0;figure[3][2]=0;figure[3][3]=0;figure[3][4]=0;figure[3][5]=0;
		end
	endcase	
end

//find the highest point
assign group[0] = {4'b0 , map[0][0], map[1][0], map[2][0], map[3][0], map[4][0], map[5][0], map[6][0], map[7][0], map[8][0], map[9][0], map[10][0], map[11][0]};
assign group[1] = {4'b0 , map[0][1], map[1][1], map[2][1], map[3][1], map[4][1], map[5][1], map[6][1], map[7][1], map[8][1], map[9][1], map[10][1], map[11][1]};
assign group[2] = {4'b0 , map[0][2], map[1][2], map[2][2], map[3][2], map[4][2], map[5][2], map[6][2], map[7][2], map[8][2], map[9][2], map[10][2], map[11][2]};
assign group[3] = {4'b0 , map[0][3], map[1][3], map[2][3], map[3][3], map[4][3], map[5][3], map[6][3], map[7][3], map[8][3], map[9][3], map[10][3], map[11][3]};
assign group[4] = {4'b0 , map[0][4], map[1][4], map[2][4], map[3][4], map[4][4], map[5][4], map[6][4], map[7][4], map[8][4], map[9][4], map[10][4], map[11][4]};
assign group[5] = {4'b0 , map[0][5], map[1][5], map[2][5], map[3][5], map[4][5], map[5][5], map[6][5], map[7][5], map[8][5], map[9][5], map[10][5], map[11][5]};

assign y[0][3] = | group[0][15:8];
assign data_8[0] = y[0][3] ? group[0][15:8] : group[0][7:0];
assign y[0][2] = | data_8[0][7:4];
assign data_4[0] = y[0][2] ? data_8[0][7:4] : data_8[0][3:0]; 
assign y[0][1] = | data_4[0][3:2]; 
assign data_2[0] = y[0][1] ? data_4[0][3:2] : data_4[0][1:0]; 
assign y[0][0] = data_2[0][1];
assign column_high[0] = | group[0][15:0] ? y[0] + 1 : 0;

assign y[1][3] = | group[1][15:8];
assign data_8[1] = y[1][3] ? group[1][15:8] : group[1][7:0];
assign y[1][2] = | data_8[1][7:4];
assign data_4[1] = y[1][2] ? data_8[1][7:4] : data_8[1][3:0]; 
assign y[1][1] = | data_4[1][3:2]; 
assign data_2[1] = y[1][1] ? data_4[1][3:2] : data_4[1][1:0]; 
assign y[1][0] = data_2[1][1];
assign column_high[1] = | group[1][15:0] ? y[1] + 1 : 0;

assign y[2][3] = | group[2][15:8];
assign data_8[2] = y[2][3] ? group[2][15:8] : group[2][7:0];
assign y[2][2] = | data_8[2][7:4];
assign data_4[2] = y[2][2] ? data_8[2][7:4] : data_8[2][3:0]; 
assign y[2][1] = | data_4[2][3:2]; 
assign data_2[2] = y[2][1] ? data_4[2][3:2] : data_4[2][1:0]; 
assign y[2][0] = data_2[2][1];
assign column_high[2] = | group[2][15:0] ? y[2] + 1 : 0;

assign y[3][3] = | group[3][15:8];
assign data_8[3] = y[3][3] ? group[3][15:8] : group[3][7:0];
assign y[3][2] = | data_8[3][7:4];
assign data_4[3] = y[3][2] ? data_8[3][7:4] : data_8[3][3:0]; 
assign y[3][1] = | data_4[3][3:2]; 
assign data_2[3] = y[3][1] ? data_4[3][3:2] : data_4[3][1:0]; 
assign y[3][0] = data_2[3][1];
assign column_high[3] = | group[3][15:0] ? y[3] + 1 : 0;

assign y[4][3] = | group[4][15:8];
assign data_8[4] = y[4][3] ? group[4][15:8] : group[4][7:0];
assign y[4][2] = | data_8[4][7:4];
assign data_4[4] = y[4][2] ? data_8[4][7:4] : data_8[4][3:0]; 
assign y[4][1] = | data_4[4][3:2]; 
assign data_2[4] = y[4][1] ? data_4[4][3:2] : data_4[4][1:0]; 
assign y[4][0] = data_2[4][1];
assign column_high[4] = | group[4][15:0] ? y[4] + 1 : 0;

assign y[5][3] = | group[5][15:8];
assign data_8[5] = y[5][3] ? group[5][15:8] : group[5][7:0];
assign y[5][2] = | data_8[5][7:4];
assign data_4[5] = y[5][2] ? data_8[5][7:4] : data_8[5][3:0]; 
assign y[5][1] = | data_4[5][3:2]; 
assign data_2[5] = y[5][1] ? data_4[5][3:2] : data_4[5][1:0]; 
assign y[5][0] = data_2[5][1];
assign column_high[5] = | group[5][15:0] ? y[5] + 1 : 0;


endmodule