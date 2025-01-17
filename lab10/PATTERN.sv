
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE=1000;
parameter PAT_NUM = 6000;

integer i,a;
integer i_pat;
integer total_latency, latency;
integer cnt;

Action _act;
Formula_Type _formula;
Mode _mode;
Date _date;
Data_No _data_no;
Index _index;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  
integer golden_TI[4];
integer golden_I[4];
integer golden_G[4];
integer golden_update_value[4];
integer R;
Month golden_month;
Day golden_day;
logic golden_date_fail_flag;
Warn_Msg golden_warn_msg ;
logic golden_complete;
//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    rand Action act;
    constraint range{
        act inside{Index_Check, Update, Check_Valid_Date};
    }
endclass

class random_formula;
	randc Formula_Type Formula;
	constraint range{
		Formula inside {Formula_A,
                        Formula_B,
                        Formula_C,
                        Formula_D,
                        Formula_E,
                        Formula_F,
                        Formula_G,
                        Formula_H
        };
	}
endclass

class random_mode;
	randc Mode mode;
	constraint range{
		mode inside {Insensitive, Normal, Sensitive};
	}
endclass

class random_date;
	randc Date date;
	constraint range{
		date.M inside {[1:12]};
		(date.M == 1)  -> date.D inside{[1:31]};    
        (date.M == 2)  -> date.D inside{[1:28]};
        (date.M == 3)  -> date.D inside{[1:31]};
        (date.M == 4)  -> date.D inside{[1:30]};    
        (date.M == 5)  -> date.D inside{[1:31]};
        (date.M == 6)  -> date.D inside{[1:30]};
        (date.M == 7)  -> date.D inside{[1:31]};    
        (date.M == 8)  -> date.D inside{[1:31]};
        (date.M == 9)  -> date.D inside{[1:30]};
        (date.M == 10) -> date.D inside{[1:31]};    
        (date.M == 11) -> date.D inside{[1:30]};
        (date.M == 12) -> date.D inside{[1:31]};
	}
endclass

class random_data_no;
	randc Data_No data_no;
	constraint range{
		data_no inside {[0:255]};
	}
endclass

class random_index;
	randc Index index;
	constraint range{
		index inside {[0:4095]};
	}
endclass
//================================================================
// initial
//===============================================================
random_act      r_act       = new();
random_formula  r_size      = new();
random_mode     r_type      = new();
random_date     r_date      = new();
random_data_no  r_data_no   = new();
random_index    r_index     = new();

initial $readmemh(DRAM_p_r, golden_DRAM);

initial begin
	reset_signal_task;
	for(i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task;
        total_latency = total_latency + latency;
        $display("\033[1;32mPASS PATTERN NO.%4d\033[m", i_pat);
    end
    YOU_PASS_task;
end
task input_task; begin
    a = r_act.randomize();
	if(i_pat < 3000)
		_act = Index_Check;
	else begin
		_act = r_act.act;
	end

    inf.sel_action_valid = 1'b1;
    inf.D.d_act[0] = _act;

    @(negedge clk);

    inf.sel_action_valid = 1'b0;
    inf.D = 'bx;

    case(_act)
    	Index_Check: index_ckeck_task;
    	Update: update_task;
    	Check_Valid_Date: check_date_task;
    endcase

end endtask 
task update_task;begin
    // date
    a = r_date.randomize();

    inf.date_valid = 1'b1;
    _date = r_date.date;
    inf.D.d_date[0] = _date;    
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D = 'bx;

    // data_no
    a = r_data_no.randomize();
	inf.data_no_valid = 1'b1;
    _data_no = r_data_no.data_no;
    inf.D.d_data_no[0] = _data_no;

    @(negedge clk);

    inf.data_no_valid = 1'b0;
    inf.D = 'bx;

    //index
    a = r_index.randomize();
    inf.index_valid = 1'b1;
    for(i=0;i<4;i++)begin
        inf.D.d_index[0] = r_index.index;
        golden_TI[i] = r_index.index;
        /*case (i)
            0: 
            1: golden_TIB = r_index.index;
            2: golden_TIC = r_index.index;
            3: golden_TID = r_index.index;
        endcase*/
        @(negedge clk);
        a = r_index.randomize();
    end
    inf.index_valid = 1'b0;
    inf.D = 'bx;

    golden_update_check_task;
end endtask 
logic signed[13:0]sum_a;
logic signed[13:0]sum_b;
logic signed[13:0]sum_c;
logic signed[13:0]sum_d;
logic signed[12:0]rdata_signed_a;
logic signed[12:0]rdata_signed_b;
logic signed[12:0]rdata_signed_c;
logic signed[12:0]rdata_signed_d;
logic signed[11:0]TI_signed_a;
logic signed[11:0]TI_signed_b;
logic signed[11:0]TI_signed_c;
logic signed[11:0]TI_signed_d;
// assign 
// assign 
// assign 
// assign 
// assign 
// assign 
// assign 
// assign 
task golden_update_check_task;begin
    //load dram data
    golden_I[0]    = {golden_DRAM[(65536+8*_data_no)+7], golden_DRAM[(65536+8*_data_no)+6][7:4]};
    golden_I[1]    = {golden_DRAM[(65536+8*_data_no)+6][3:0], golden_DRAM[(65536+8*_data_no)+5]};
    golden_month   = {golden_DRAM[(65536+8*_data_no)+4][3:0]};
    golden_I[2]    = {golden_DRAM[(65536+8*_data_no)+3], golden_DRAM[(65536+8*_data_no)+2][7:4]};
    golden_I[3]    = {golden_DRAM[(65536+8*_data_no)+2][3:0], golden_DRAM[(65536+8*_data_no)+1]};
    golden_day     = {golden_DRAM[(65536+8*_data_no)][4:0]};
    rdata_signed_a = golden_I[0];
    rdata_signed_b = golden_I[1];
    rdata_signed_c = golden_I[2];
    rdata_signed_d = golden_I[3];
    TI_signed_a    = golden_TI[0];
    TI_signed_b    = golden_TI[1];
    TI_signed_c    = golden_TI[2];
    TI_signed_d    = golden_TI[3];
    sum_a = TI_signed_a + rdata_signed_a;
    sum_b = TI_signed_b + rdata_signed_b;
    sum_c = TI_signed_c + rdata_signed_c;
    sum_d = TI_signed_d + rdata_signed_d;

    //warn_msg
    golden_warn_msg = No_Warn;
    golden_complete = 1;
    if(sum_a > 4095)begin
        golden_update_value[0] = 4095;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else if(sum_a < 0)begin
        golden_update_value[0] = 0;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else
        golden_update_value[0] = sum_a;

    if(sum_b > 4095)begin
        golden_update_value[1] = 4095;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else if(sum_b < 0)begin
        golden_update_value[1] = 0;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else
        golden_update_value[1] = sum_b;    

    if(sum_c > 4095)begin
        golden_update_value[2] = 4095;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else if(sum_c < 0)begin
        golden_update_value[2] = 0;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else
        golden_update_value[2] = sum_c;

    if(sum_d > 4095)begin
        golden_update_value[3] = 4095;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else if(sum_d < 0)begin
        golden_update_value[3] = 0;
        golden_warn_msg = Data_Warn;
        golden_complete = 0;
    end
    else
        golden_update_value[3] = sum_d;

    //updata data to dram
    {golden_DRAM[(65536+8*_data_no)+7], golden_DRAM[(65536+8*_data_no)+6][7:4]}    = golden_update_value[0];
    {golden_DRAM[(65536+8*_data_no)+6][3:0], golden_DRAM[(65536+8*_data_no)+5]}    = golden_update_value[1];
    {golden_DRAM[(65536+8*_data_no)+4][3:0]}                                       = _date.M;
    {golden_DRAM[(65536+8*_data_no)+3], golden_DRAM[(65536+8*_data_no)+2][7:4]}    = golden_update_value[2];
    {golden_DRAM[(65536+8*_data_no)+2][3:0], golden_DRAM[(65536+8*_data_no)+1]}    = golden_update_value[3];
    {golden_DRAM[(65536+8*_data_no)][4:0]}                                         = _date.D;


end endtask

task check_date_task;begin
    // date
    a = r_date.randomize();

    inf.date_valid = 1'b1;
    _date = r_date.date;
    inf.D.d_date[0] = _date;    
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D = 'bx;

    // data_no
    a = r_data_no.randomize();
	inf.data_no_valid = 1'b1;
    _data_no = r_data_no.data_no;
    inf.D.d_data_no[0] = _data_no;

    @(negedge clk);

    inf.data_no_valid = 1'b0;
    inf.D = 'bx;

    golden_date_check_task;
end endtask 

task golden_date_check_task;begin
    golden_month   = {golden_DRAM[(65536+8*_data_no)+4][3:0]};
    golden_day     = {golden_DRAM[(65536+8*_data_no)][4:0]};
    //check date valid
    golden_date_fail_flag = 0; 
    if( _date.M <= golden_month)begin
        if(_date.M == golden_month)begin
            if(_date.D < golden_day)begin
                golden_date_fail_flag = 1;
            end
            else begin
                golden_date_fail_flag = 0;    
            end
        end
        else begin
            golden_date_fail_flag = 1;
        end
    end
    else golden_date_fail_flag = 0;

    //warn_msg and complete
    golden_warn_msg = No_Warn;
    golden_complete = 1;
    if(golden_date_fail_flag)begin
        golden_warn_msg = Date_Warn;
        golden_complete = 0;
    end
end endtask 
task index_ckeck_task; begin

	// formula
    case(cnt % 8)
        0: _formula = Formula_A;
        1: _formula = Formula_B;
        2: _formula = Formula_C;
        3: _formula = Formula_D;
        4: _formula = Formula_E;
        5: _formula = Formula_F;
        6: _formula = Formula_G;
        7: _formula = Formula_H;
    endcase
    
	inf.formula_valid = 1'b1;
    inf.D.d_formula[0] = _formula;

    @(negedge clk);

    inf.formula_valid = 1'b0;
    inf.D = 'bx;

    // mode
    case(cnt % 3)
        0: _mode = Insensitive;            
        1: _mode = Normal;               
        2: _mode = Sensitive;      
    endcase

	inf.mode_valid = 1'b1;
    inf.D.d_mode[0] = _mode;

    @(negedge clk);

    inf.mode_valid = 1'b0;
    inf.D = 'bx;

    // date
    a = r_date.randomize();

    inf.date_valid = 1'b1;
    _date = r_date.date;
    inf.D.d_date[0] = _date;    
    @(negedge clk);

    inf.date_valid = 1'b0;
    inf.D = 'bx;

    // data_no
    a = r_data_no.randomize();
	inf.data_no_valid = 1'b1;
    _data_no = r_data_no.data_no;
    inf.D.d_data_no[0] = _data_no;

    @(negedge clk);

    inf.data_no_valid = 1'b0;
    inf.D = 'bx;

    //index
    a = r_index.randomize();
    inf.index_valid = 1'b1;
    for(i=0;i<4;i++)begin
        inf.D.d_index[0] = r_index.index;
        golden_TI[i] = r_index.index;
        /*case (i)
            0: 
            1: golden_TIB = r_index.index;
            2: golden_TIC = r_index.index;
            3: golden_TID = r_index.index;
        endcase*/
        @(negedge clk);
        a = r_index.randomize();
    end
    inf.index_valid = 1'b0;
    inf.D = 'bx;
    golden_index_check_task;

    cnt = cnt + 1;

end endtask

task golden_index_check_task;begin
    golden_I[0]    = {golden_DRAM[(65536+8*_data_no)+7], golden_DRAM[(65536+8*_data_no)+6][7:4]};
    golden_I[1]    = {golden_DRAM[(65536+8*_data_no)+6][3:0], golden_DRAM[(65536+8*_data_no)+5]};
    golden_month   = {golden_DRAM[(65536+8*_data_no)+4][3:0]};
    golden_I[2]    = {golden_DRAM[(65536+8*_data_no)+3], golden_DRAM[(65536+8*_data_no)+2][7:4]};
    golden_I[3]    = {golden_DRAM[(65536+8*_data_no)+2][3:0], golden_DRAM[(65536+8*_data_no)+1]};
    golden_day     = {golden_DRAM[(65536+8*_data_no)][4:0]};

    //check date valid
    golden_date_fail_flag = 0; 
    if( _date.M <= golden_month)begin
        if(_date.M == golden_month)begin
            if(_date.D < golden_day)begin
                golden_date_fail_flag = 1;
            end
            else begin
                golden_date_fail_flag = 0;    
            end
        end
        else begin
            golden_date_fail_flag = 1;
        end
    end
    else golden_date_fail_flag = 0;

    //cal golden_G
    golden_G[0] = (golden_I[0] - golden_TI[0]) < 0 ? -(golden_I[0] - golden_TI[0]) : (golden_I[0] - golden_TI[0]);
    golden_G[1] = (golden_I[1] - golden_TI[1]) < 0 ? -(golden_I[1] - golden_TI[1]) : (golden_I[1] - golden_TI[1]);
    golden_G[2] = (golden_I[2] - golden_TI[2]) < 0 ? -(golden_I[2] - golden_TI[2]) : (golden_I[2] - golden_TI[2]);
    golden_G[3] = (golden_I[3] - golden_TI[3]) < 0 ? -(golden_I[3] - golden_TI[3]) : (golden_I[3] - golden_TI[3]);

    if(_formula <= 3)
        golden_I.sort();
    if(_formula >= 5)
        golden_G.sort();

    //cal R
    case (_formula)
        0: R = (golden_I[0] + golden_I[1] + golden_I[2] + golden_I[3]) >> 2;
        1: R = golden_I[3] - golden_I[0];
        2: R = golden_I[0];
        3: R = (golden_I[0] >= 2047) + (golden_I[1] >= 2047) + (golden_I[2] >= 2047) + (golden_I[3] >= 2047) ;
        4: R = (golden_I[0] >= golden_TI[0]) + (golden_I[1] >= golden_TI[1]) + (golden_I[2] >= golden_TI[2]) + (golden_I[3] >= golden_TI[3]) ;
        5: R = (golden_G[0] + golden_G[1] + golden_G[2])/3;
        6: R = (golden_G[0]>>1) +( golden_G[1]>>2) + (golden_G[2]>>2);
        7: R = (golden_G[0] + golden_G[1] + golden_G[2] + golden_G[3])>>2;
    endcase

    //warn_msg and complete
    golden_warn_msg = No_Warn;
    golden_complete = 1;
    if(golden_date_fail_flag)begin
        golden_warn_msg = Date_Warn;
        golden_complete = 0;
    end
    else begin
        case (_formula)
            0,2:begin
                case (_mode)
                    0: begin
                        if(R>=2047)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                    1: begin
                        if(R>=1023)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                    3: begin
                        if(R>=511)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                endcase
            end
            1,5,6,7:begin
                case (_mode)
                    0: begin
                        if(R>=800)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                    1: begin
                        if(R>=400)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                    3: begin
                        if(R>=200)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                endcase
            end
            3,4:begin
                case (_mode)
                    0: begin
                        if(R>=3)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                    1: begin
                        if(R>=2)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                    3: begin
                        if(R>=1)begin
                            golden_warn_msg = Risk_Warn;
                            golden_complete = 0;
                        end
                    end
                  
                endcase
            end
        endcase
    end
    
end endtask 
task reset_signal_task; begin 
    inf.rst_n            = 1'b1;
    inf.sel_action_valid = 'b0;
    inf.formula_valid    = 'b0;
    inf.mode_valid       = 'b0;
    inf.date_valid       = 'b0;
    inf.data_no_valid    = 'b0;
    inf.index_valid      = 'b0;
    inf.D                = 'bx;

    total_latency = 0;
    cnt = 0;

    #1; inf.rst_n = 1'b0; 
    #29; inf.rst_n = 1'b1;
    
    if(inf.out_valid !== 'b0 || inf.warn_msg !== 'b0 || inf.complete !== 'b0) begin
        $display("\033[m---------------------------------------------------------------------------------------\033[m");
        $display("\033[m     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                                    \033[m");
        $display("\033[m    ▄▀            ▀▄      ▄▄                                                           \033[m");
        $display("\033[m    █  ▀   ▀       ▀▄▄   █  █      FAIL !                                              \033[m");
        $display("\033[m    █   ▀▀            ▀▀▀   ▀▄  ╭  All output signal should be reset after RESET at %8t PS\033[m", $time);
        $display("\033[m    █  ▄▀▀▀▄                 █  ╭                                                      \033[m");
        $display("\033[m    ▀▄                       █                                                         \033[m");
        $display("\033[m     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                                          \033[m");
        $display("\033[m     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                                           \033[m");
        $display("\033[m---------------------------------------------------------------------------------------\033[m");
        $finish;
    end

    //@(negedge clk);

end endtask
task wait_out_valid_task; begin
    latency = 0;
    while(inf.out_valid !== 1'b1) begin
        latency = latency + 1;
        if(latency == MAX_CYCLE) begin
            $display("\033[m-----------------------------------------------------------------------------\033[m");
            $display("\033[m     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                          \033[m");
            $display("\033[m    ▄▀            ▀▄      ▄▄                                                 \033[m");
            $display("\033[m    █  ▀   ▀       ▀▄▄   █  █      FAIL !                                    \033[m");
            $display("\033[m    █   ▀▀            ▀▀▀   ▀▄  ╭  The execution latency is over cycles  %3d\033[m", MAX_CYCLE);
            $display("\033[m    █  ▄▀▀▀▄                 █  ╭                                            \033[m");
            $display("\033[m    ▀▄                       █                                               \033[m");
            $display("\033[m     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                                \033[m");
            $display("\033[m     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                                 \033[m");
            $display("\033[m-----------------------------------------------------------------------------\033[m");
            $finish;
        end
        @(negedge clk);
    end
end endtask
task check_ans_task; begin
    while (inf.out_valid === 1'b1) begin   
        if(inf.warn_msg !== golden_warn_msg || inf.complete !== golden_complete) begin
            $display("\033[0;32;31mWrong Answer\033[m");
            $display("\033[m--------------------------------------------------------------------\033[m");
            $display("\033[m     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                 \033[m");
            $display("\033[m    ▄▀            ▀▄      ▄▄       \033[0;32;31mFAIL at %8t PS\033[m", $time);
            $display("\033[m    █  ▀   ▀       ▀▄▄   █  █      \033[0;32;31mAction = %d \033[m", _act);
            $display("\033[m    █   ▀▀            ▀▀▀   ▀▄  ╭  \033[0;32;31mYour   warn_msg = %b, complete = %b  \033[m", inf.warn_msg, inf.complete);
            $display("\033[m    █  ▄▀▀▀▄                 █  ╭  \033[0;32;31mGolden warn_msg = %b, complete = %b  \033[m", golden_warn_msg, golden_complete);
            $display("\033[m    ▀▄                       █                                      \033[m");
            $display("\033[m     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                       \033[m");
            $display("\033[m     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                        \033[m");
            $display("\033[m--------------------------------------------------------------------\033[m");
            $finish;   
        end     
        @(negedge clk);
    end 
end endtask
task YOU_PASS_task; begin
    $display("\033[0;35mCongratulations\033[m");
    $display("\033[m------------------------------------------------------------------------\033[m");
    $display("\033[m     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                     \033[m");
    $display("\033[m    ▄▀            ▀▄      ▄▄                                            \033[m");
    $display("\033[m    █  ▀   ▀       ▀▄▄   █  █      \033[0;35mCongratulations !                    \033[m");
    $display("\033[m    █   ▀▀            ▀▀▀   ▀▄  ╭  \033[0;35mYou have passed all patterns !       \033[m");
    $display("\033[m    █ ▀▄▀▄▄▀                 █  ╭  \033[0;35mYour execution cycles = %5d cycles   \033[m", total_latency);
    $display("\033[m    ▀▄                       █                                          \033[m");
    $display("\033[m     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           \033[m");
    $display("\033[m     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            \033[m");
    $display("\033[m------------------------------------------------------------------------\033[m");  
    $finish;
end endtask
endprogram
