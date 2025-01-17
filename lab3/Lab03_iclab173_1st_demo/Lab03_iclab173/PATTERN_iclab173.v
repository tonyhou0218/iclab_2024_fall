/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: PATTERN
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

`ifdef RTL
    `define CYCLE_TIME 6.8
`endif
`ifdef GATE
    `define CYCLE_TIME 6.8
`endif

module PATTERN(
	//OUTPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//INPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output reg			rst_n, clk, in_valid;
output reg	[2:0]	tetrominoes;
output reg  [2:0]	position;
input 				tetris_valid, score_valid, fail;
input 		[3:0]	score;
input		[71:0]	tetris;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer total_latency;
integer latency;
integer pattern_num;
integer file_in;
integer a;
integer i_patternnum;
integer pat_serialnum;
integer cnt1_1;
integer cnt1_2;
integer sub_pat;
integer i,j,k,idx;
integer collision_i;    
integer clear_times;                       ///////////////                   03:18
real CYCLE = `CYCLE_TIME;
			
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [1:0]map[0:11][0:5];
reg [1:0]figure[0:3][0:5];
reg [2:0]figure_type;
reg [2:0]figure_position;
reg collision,stop_shift;
reg golden_fail;
reg golden_tetris[71:0];
reg eat_unneed_pat1,eat_unneed_pat2;
reg [3:0]golden_score;
//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------
initial begin
    file_in = $fopen("../00_TESTBED/Input.txt", "r"); 

    rst_n = 1'b1;
    reset_task;

	a = $fscanf(file_in,"%d",pattern_num);
    //i_pat = 0;
    //
    total_latency = 0;
	
    for (i_patternnum = 1; i_patternnum <= pattern_num; i_patternnum = i_patternnum + 1) begin
        reset_map;
        a = $fscanf(file_in, "%d",pat_serialnum);
		for(sub_pat=0;sub_pat<16;sub_pat++)begin
            if(golden_fail == 0)begin
                input_task;
                cal_task;
                wait_score_valid_task;
                check_ans_task;
            end
            else begin
                a = $fscanf(file_in, "%d %d",eat_unneed_pat1,eat_unneed_pat2);
            end

            total_latency = total_latency + latency;
		end
        
        //wait_out_valid_task;
        //check_ans_task;

        
        $display("PASS PATTERN NO.%4d", i_patternnum-1);
    end
    //$fclose(pat_read);
//
    //$writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM); //Write down your DRAM Final State
    //$writememh("../00_TESTBED/SD_final.dat", u_SD.SD);		 //Write down your SD CARD Final State
    YOU_PASS_task;
	$finish;
end
task reset_task; begin 
    rst_n      = 'b1;
    in_valid   = 'b0;
    tetrominoes  = 3'bxxx;
	position =3'bxxx;
    total_latency = 0;

    force clk = 0;

    #CYCLE;       rst_n = 0; 
    #(CYCLE * 2); rst_n = 1;
    
    if( score_valid !== 0 || score!==0 ||tetris_valid!==0|| tetris!==0 || fail!==0 ) begin
		$display("                    SPEC-4 FAIL                   ");
		$display("               need to reset output signal                   ");
        repeat(2) #CYCLE;
        $finish;
    end
	#CYCLE; release clk;
end endtask
task reset_map; begin 

    golden_fail = 0;
    golden_score = 0;
    
    for(i=0;i<12;i++)begin
        for(j=0;j<6;j++)begin
            map[i][j]=0;
        end
    end
    for(i=0;i<4;i++)begin
        for(j=0;j<6;j++)begin
            figure[i][j]=0;
        end
    end
end endtask
task input_task; begin

    //repeat(($random()) % 3 +2) @(negedge clk);
	@(negedge clk);
	if(sub_pat==0)begin
		in_valid = 1'b1;
		
		a = $fscanf(file_in, "%d %d",tetrominoes,position);
		
	end
	else begin
	
		repeat(($random()) % 4 + 1) @(negedge clk);
		in_valid = 1'b1;
		a = $fscanf(file_in, "%d %d",tetrominoes,position);
		
	end
    @(negedge clk);
    figure_position = position;
    figure_type = tetrominoes;
    in_valid = 1'b0;
	tetrominoes = 3'bxxx;
	position = 3'bxxx;

end endtask
task cal_task;begin
    for(i=0;i<4;i++)begin
        for(j=0;j<6;j++)begin
            figure[i][j]=0;
        end
    end
    case (figure_type)
        0:begin
            figure[2][0+figure_position]=1; figure[2][1+figure_position]=1;
            figure[3][0+figure_position]=1; figure[3][1+figure_position]=1;
        end 
        1:begin
            figure[0][figure_position]=1;
            figure[1][figure_position]=1;
            figure[2][figure_position]=1;
            figure[3][figure_position]=1;
        end 
        2:begin
            for(j=0;j<4;j++)begin
                figure[3][j+figure_position]=1;
            end
        end         
        3:begin 
            figure[1][0+figure_position]=1;figure[1][1+figure_position]=1;
                                           figure[2][1+figure_position]=1;
                                           figure[3][1+figure_position]=1;
        end         
        4:begin
            figure[2][0+figure_position]=1;figure[2][1+figure_position]=1;figure[2][2+figure_position]=1;
            figure[3][0+figure_position]=1;
        end
        5:begin
            figure[1][0+figure_position]=1;
            figure[2][0+figure_position]=1;
            figure[3][0+figure_position]=1;figure[3][1+figure_position]=1;
        end
        6:begin
            figure[1][0+figure_position]=1;
            figure[2][0+figure_position]=1;figure[2][1+figure_position]=1;
                                           figure[3][1+figure_position]=1;
        end
        7:begin
                                           figure[2][1+figure_position]=1;figure[2][2+figure_position]=1;
            figure[3][0+figure_position]=1;figure[3][1+figure_position]=1;
        end
    endcase


    stop_shift=0;
    collision=0;
    //check if collision and updatemap
    for(i=0;i<12;i++)begin
        //check if collision
        if(i==0 && collision==0)begin
            for(j=0;j<6;j++)begin
                if(map[i][j] && figure[3][j]) collision=1;
                
            end
        end
        if(i==1 && collision==0)begin
            for(j=0;j<6;j++)begin
                if(map[0][j] && figure[2][j]) collision=1;
                
            end
            for(j=0;j<6;j++)begin
                if(map[1][j] && figure[3][j]) collision=1;
               
            end
        end
        if(i==2 && collision==0)begin
            for(j=0;j<6;j++)begin
                if(map[0][j] && figure[1][j]) collision=1;
                
            end
            for(j=0;j<6;j++)begin
                if(map[1][j] && figure[2][j]) collision=1;
                
            end
            for(j=0;j<6;j++)begin
                if(map[2][j] && figure[3][j]) collision=1;
               
            end
        end
        if(i>=3 && collision==0)begin
            for(k=0;k<4;k++)begin
                for(j=0;j<6;j++)begin
                    if(map[i-3+k][j] && figure[k][j]) collision=1;
                    
                end
            end
        end

        //touch the ground
        if(i==11 && collision==0)begin
            for(k=0;k<4;k++)begin
                for(j=0;j<6;j++)begin
                    map[i-3+k][j] = map[i-3+k][j]  + figure[k][j];

                end
            end
        end

        //update the map
        if(!stop_shift)begin
            if(collision)begin
                stop_shift = 1;
                collision_i = i;
                case (figure_type)
                    0,4,7:begin
                        for(k=0;k<2;k++)begin
                            for(j=0;j<6;j++)begin
                                if((i-2+k)>=0)begin
                                    map[i-2+k][j] = map[i-2+k][j]  + figure[k+2][j];
                                end
                            end
                        end
                    end 
                    3,5,6:begin
                        for(k=0;k<3;k++)begin
                            for(j=0;j<6;j++)begin
                                if((i-3+k)>=0)begin
                                    map[i-3+k][j] = map[i-3+k][j]  + figure[k+1][j];
                                end
                            end
                        end
                    end
                    2:begin
                        for(j=0;j<6;j++)begin
                            map[i-1][j] = map[i-1][j]  + figure[3][j];
                        end
                    end
                    1:begin
                        
                        for(k=0;k<4;k++)begin
                            for(j=0;j<6;j++)begin
                                if((i-4+k)>=0)begin
                                    map[i-4+k][j] = map[i-4+k][j]  + figure[k][j];
                                end
                            end
                        end
                        
    
                    end
                endcase
            end  
        end
    end

    

    //cal golden score and shift
    clear_times = 0;
    for(i=0;i<12;i++)begin
        if(map[i][0]==1 && map[i][1]==1 && map[i][2]==1 && map[i][3]==1 && map[i][4]==1 && map[i][5]==1)begin
            golden_score = golden_score + 1;
            //$display("fuck");
            for(j=i;j>0;j--)begin
                map[j][0] = map[j-1][0];
                map[j][1] = map[j-1][1];
                map[j][2] = map[j-1][2];
                map[j][3] = map[j-1][3];
                map[j][4] = map[j-1][4];
                map[j][5] = map[j-1][5];
                //$display(j);
            end
            if(collision_i<=3 && collision)begin
                if(3-collision_i-clear_times >= 0)begin
                    map[0][0] = figure[3-collision_i-clear_times][0];
                    map[0][1] = figure[3-collision_i-clear_times][1];
                    map[0][2] = figure[3-collision_i-clear_times][2];
                    map[0][3] = figure[3-collision_i-clear_times][3];
                    map[0][4] = figure[3-collision_i-clear_times][4];
                    map[0][5] = figure[3-collision_i-clear_times][5];
                end
                else begin
                    map[0][0] = 0;
                    map[0][1] = 0;
                    map[0][2] = 0;
                    map[0][3] = 0;
                    map[0][4] = 0;
                    map[0][5] = 0;
                end
            end
            else begin
                map[0][0] = 0;
                map[0][1] = 0;
                map[0][2] = 0;
                map[0][3] = 0;
                map[0][4] = 0;
                map[0][5] = 0;
            end
            clear_times = clear_times + 1;
            i=i-1;
        end
    end

    //cal golden fail
    for(j=0;j<6;j++)begin
        case (figure_type)
            2:begin
                if(collision && collision_i==0)
                    golden_fail = 1;
            end
            0,4,7:begin
                if(collision && collision_i<=1 && clear_times<1)
                    golden_fail = 1;
            end
            3,5,6:begin
                if(collision && (collision_i<2 || (collision_i==2 && clear_times==0)))
                    golden_fail = 1;
            end
            1:begin
                if(collision && collision_i<=3 && clear_times<2)
                    golden_fail = 1;
            end
            
        endcase
        
    end
    //cal golden tetris
    idx=0;
    for(i=11;i>=0;i--)begin
        for(j=0;j<6;j++)begin
            golden_tetris[idx]=map[i][j];
            idx = idx + 1;
        end
    end

end endtask
task wait_score_valid_task; begin
	latency = 1;
	while(score_valid === 0)begin
        latency = latency + 1;
        if(latency >=1000)begin
            $display("--------------------------------------------------------------------------------");
            $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
            $display("    ▄▀            ▀▄      ▄▄                                          ");
            $display("    █  ▀   ▀       ▀▄▄   █  █      FAIL !                            ");
            $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  Latency are over 1000 cycles");
            $display("    █  ▄▀▀▀▄                 █  ╭     SPEC-6 FAIL                                ");
            $display("    ▀▄                       █                                           ");
            $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
            $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
            $display("--------------------------------------------------------------------------------");  
            $finish;
        end
        @(negedge clk);
		
        //$display(latency);
    end

end endtask
task check_ans_task; begin
    
    //$display("--------------------------------------------------------------------------------");
    //$display(figure_type,figure_position);
    //$display(collision,collision_i);
    //for(i=0;i<12;i++)begin
    //    
    //    $display(map[i][0],map[i][1],map[i][2],map[i][3],map[i][4],map[i][5]);
    //    
    //end
    //
    if(score !== golden_score)begin
        $display("--------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █       FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   score not correct                   ");
        $display("    █  ▄▀▀▀▄                 █  ╭     SPEC-7 FAIL                                ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("                                your: ",score," golden:",golden_score);
        $display("--------------------------------------------------------------------------------");  
        $finish;
    end
    //$display("1");
    if(score_valid && (fail !== golden_fail))begin
        $display("--------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █       FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   fail != golden_fail                    ");
        $display("    █  ▄▀▀▀▄                 █  ╭     SPEC-7 FAIL                                ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("--------------------------------------------------------------------------------");  
        $finish;
    end
    //$display("2");
    if((sub_pat === 15 && tetris_valid === 0) )begin//|| (fail ==1 && tetris_valid == 0) || (fail ==0 && tetris_valid == 1)
        $display("--------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █       FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   tetris_valid not correct                   ");
        $display("    █  ▄▀▀▀▄                 █  ╭     SPEC-7 FAIL                                ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("--------------------------------------------------------------------------------");  
        $finish;
    end
    //$display("3");
    if(tetris_valid)begin
        for(idx=0;idx<72;idx++)begin
            if(tetris[idx] !== golden_tetris[idx])begin
                $display("--------------------------------------------------------------------------------");
                $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
                $display("    ▄▀            ▀▄      ▄▄                                          ");
                $display("    █  ▀   ▀       ▀▄▄   █  █       FAIL !                            ");
                $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   tetris not correct                   ");
                $display("    █  ▄▀▀▀▄                 █  ╭     SPEC-7 FAIL                                ");
                $display("    ▀▄                       █                                           ");
                $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
                $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
                $display("                your: ",tetris,"              golden: ",golden_tetris);
                $display("--------------------------------------------------------------------------------");  
                for(i=66;i>=0;i=i-6)begin
                    $display(golden_tetris[i],golden_tetris[i+1],golden_tetris[i+2],golden_tetris[i+3],golden_tetris[i+4],golden_tetris[i+5]);
                end
                $finish;
            end
        end
    end
    //$display("4");



end endtask
always@(*)begin
    @(negedge clk);
	if(score_valid === 0 && (fail !== 0 || score !== 0 || tetris_valid !== 0))begin
			$display("                    SPEC-5 FAIL                   ");	
            $display("             Output signal should be 0         ");
            $display("             when the score_valid is pulled down ");
            repeat(5) #(CYCLE);
            $finish;
		//repeat(9)@(negedge clk);
		$finish;			
	end	
end

always@(*)begin
    @(negedge clk);
	if(tetris_valid === 0 && tetris !== 0)begin
			$display("                    SPEC-5 FAIL                   ");	
            $display("             Output signal should be 0         ");
            $display("             when the tetris_valid is pulled down ");
            repeat(5) #(CYCLE);
            $finish;
		//repeat(9)@(negedge clk);
		$finish;			
	end	
end
always@(*)begin
    


	@(negedge clk);
	if(tetris_valid === 1)begin
		
		
		@(negedge clk);
		if(tetris_valid === 1)begin
			$display("                    SPEC-8 FAIL                   ");	
            $display("             score_valid high for more than 1 cycle       ");
            $display("               ");
            repeat(5) #(CYCLE);
            $finish;
		end

		
	end	
end
always@(*)begin
    
	@(negedge clk);
	if(score_valid === 1)begin
		
		
		@(negedge clk);
		if(score_valid === 1)begin
			$display("                    SPEC-8 FAIL                   ");	
            $display("             score_valid high for more than 1 cycle       ");
            $display("               ");
            repeat(5) #(CYCLE);
            $finish;
		end

		
	end	

end
task YOU_PASS_task;begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
end endtask
endmodule


// for spec check


// $display("                    SPEC-6 FAIL                   ");
// $display("                    SPEC-7 FAIL                   ");
// $display("                    SPEC-8 FAIL                   ");
// for successful design
// 
// $display("              execution cycles = %7d", total_latency);
// $display("              clock period = %4fns", CYCLE);
