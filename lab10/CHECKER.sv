`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//==============================================//
//                   COVERAGE                   //
//==============================================//
Action golden_act;
Index index;
class Formula_and_mode;
    Formula_Type f_type;
    Mode f_mode;
endclass

Formula_and_mode fm_info = new();
always_comb begin

    if(inf.sel_action_valid)
        golden_act = inf.D.d_act[0];

    if(inf.formula_valid)
        fm_info.f_type = inf.D.d_formula[0];

    if(inf.mode_valid)
        fm_info.f_mode = inf.D.d_mode[0];

    if(inf.index_valid && golden_act == Update)
        index = inf.D.d_index[0];

end
covergroup Spec1 @(posedge clk iff(inf.formula_valid));
    option.per_instance = 1;
    option.at_least = 150;
    coverpoint fm_info.f_type{
        bins d_f_formula [] = {[Formula_A:Formula_H]};
    }
endgroup
Spec1 conv_inst_1 = new();

covergroup Spec2 @(posedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;
    coverpoint fm_info.f_mode{
        bins d_f_mode [] = {[Insensitive:Sensitive]};
    }
endgroup
Spec2 conv_inst_2 = new();

covergroup Spec3 @(posedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;
    cross fm_info.f_mode, fm_info.f_type;
endgroup
Spec3 conv_inst_3 = new();

covergroup Spec4 @(posedge clk iff(inf.out_valid));
    option.per_instance = 1;
    option.at_least = 50;
    coverpoint inf.warn_msg{
        bins d_warn_msg [] = {[No_Warn:Data_Warn]};
    }
endgroup
Spec4 conv_inst_4 = new();

covergroup Spec5 @(posedge clk iff(inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 300;
    coverpoint golden_act{
        bins d_act [] = ([Index_Check:Check_Valid_Date] => [Index_Check:Check_Valid_Date]);
    }
endgroup
Spec5 conv_inst_5 = new();

covergroup Spec6 @(posedge clk iff(inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 1;
    coverpoint index{
        option.auto_bin_max = 32;
    }
endgroup
Spec6 conv_inst_6 = new();
//==============================================//
//                  ASSERTION                   //
//==============================================//

// 1. All outputs signals should be zero after reset.

logic check_rst;
assign check_rst = (inf.out_valid === 'b0) && (inf.warn_msg === 'b0) && (inf.complete === 'b0) && (inf.AR_VALID === 'b0) && (inf.AR_ADDR === 'b0) && 
                   (inf.R_READY === 'b0) && (inf.B_READY === 'b0) && (inf.AW_ADDR === 'b0) && 
                   (inf.W_VALID === 'b0) && (inf.W_DATA === 'b0) && (inf.AW_VALID === 'b0)
                   ;

always @(negedge inf.rst_n) begin
    @(posedge inf.rst_n)
    assert_1: assert (check_rst)
    else $fatal(0, "Assertion 1 is violated");
end

// 2. Latency less than 1000 cycles for each operation.

logic check_INDEX_CHECK ;
logic check_UPDATE ;
logic check_VALID_CHECK;

assign check_INDEX_CHECK = (golden_act == Index_Check) && (inf.index_valid);
assert_2_1: assert property(over_1)
else $fatal(0, "Assertion 2 is violated");

property over_1;
    @(negedge clk) check_INDEX_CHECK |=> ##[4:1003] inf.out_valid;
endproperty: over_1


assign check_UPDATE = (golden_act == Update) && (inf.index_valid);
assert_2_2: assert property(over_2)
else $fatal(0, "Assertion 2 is violated");

property over_2;
    @(negedge clk) check_UPDATE |=> ##[4:1003] inf.out_valid;
endproperty: over_2


assign check_VALID_CHECK = (golden_act == Check_Valid_Date) && (inf.data_no_valid);
assert_2_3: assert property(over_3)
else begin
    # (0.2);
    $display("Assertion 2 is violated");
    $fatal;
end

property over_3;
    @(negedge clk) check_VALID_CHECK |=> ##[1:1000] inf.out_valid;
endproperty: over_3

// 3. If out_valid does not pull up, complete should be 0.

assert_3: assert property(complete)
else begin
    $fatal(0, "Assertion 3 is violated");
end

property complete;
    @(negedge clk) inf.complete |-> inf.warn_msg === 'b0;
endproperty: complete

// 4. Next input valid will be valid 1-4 cycles after previous input valid fall.
logic [2:0] cnt_index;
always @(negedge clk) begin
    cnt_index = 0;
    if(inf.index_valid === 1'b1) begin
        cnt_index = 0;
        while(cnt_index !== 4) begin
            if(inf.index_valid === 1'b1) begin
                cnt_index = cnt_index + 1;
            end
            @(negedge clk);
        end
        cnt_index = 0;
    end
end
//act = INDEX_CHECK
assert_4_1: assert property(sel_index)
else $fatal(0, "Assertion 4 is violated");

property sel_index;
    @(posedge clk) (inf.sel_action_valid && golden_act === Index_Check) |-> ##[1:4] inf.formula_valid;
endproperty: sel_index

assert_4_2: assert property(mode_index)
else $fatal(0, "Assertion 4 is violated");

property mode_index;
    @(posedge clk) (inf.formula_valid && golden_act === Index_Check) |-> ##[1:4] inf.mode_valid;
endproperty: mode_index

assert_4_3: assert property(today_index)
else $fatal(0, "Assertion 4 is violated");

property today_index;
    @(posedge clk) (inf.mode_valid && golden_act === Index_Check) |-> ##[1:4] inf.date_valid;
endproperty: today_index

assert_4_4: assert property(data_no_index)
else $fatal(0, "Assertion 4 is violated");

property data_no_index;
    @(posedge clk) (inf.date_valid && golden_act === Index_Check) |-> ##[1:4] inf.data_no_valid;
endproperty: data_no_index

assert_4_5: assert property(index_index)
else $fatal(0, "Assertion 4 is violated");

property index_index;
    @(posedge clk) (inf.data_no_valid && golden_act === Index_Check) |-> ##[1:4] inf.index_valid;
endproperty: index_index

assert_4_5_1: assert property(index_index_1)
else $fatal(0, "Assertion 4 is violated");

property index_index_1;
    @(posedge clk) (inf.index_valid && golden_act === Index_Check && cnt_index!==3) |-> ##[1:4] inf.index_valid;
endproperty: index_index_1
//act = UPDATE
assert_4_6: assert property(sel_update)
else $fatal(0, "Assertion 4 is violated");

property sel_update;
    @(posedge clk) (inf.sel_action_valid && golden_act === Update) |-> ##[1:4] inf.date_valid;
endproperty: sel_update

assert_4_7: assert property(data_no_update)
else $fatal(0, "Assertion 4 is violated");

property data_no_update;
    @(posedge clk) (inf.date_valid && golden_act === Update) |-> ##[1:4] inf.data_no_valid;
endproperty: data_no_update

assert_4_8: assert property(index_update)
else $fatal(0, "Assertion 4 is violated");

property index_update;
    @(posedge clk) (inf.data_no_valid && golden_act === Update) |-> ##[1:4] inf.index_valid;
endproperty: index_update

assert_4_8_1: assert property(index_update_1)
else $fatal(0, "Assertion 4 is violated");

property index_update_1;
    @(posedge clk) (inf.index_valid && golden_act === Update && cnt_index!==3) |-> ##[1:4] inf.index_valid;
endproperty: index_update_1


//act = Check Valid Date
assert_4_9: assert property(sel_Valid_Date)
else $fatal(0, "Assertion 4 is violated");

property sel_Valid_Date;
    @(posedge clk) (inf.sel_action_valid && golden_act === Check_Valid_Date) |-> ##[1:4] inf.date_valid;
endproperty: sel_Valid_Date

assert_4_10: assert property(data_no_Valid_Date)
else $fatal(0, "Assertion 4 is violated");

property data_no_Valid_Date;
    @(posedge clk) (inf.date_valid && golden_act === Check_Valid_Date) |-> ##[1:4] inf.data_no_valid;
endproperty: data_no_Valid_Date

// 5. All input valid signals won't overlap with each other.
assert_5: assert property (
    @(posedge clk) 
    $onehot({inf.sel_action_valid, inf.mode_valid, inf.data_no_valid, inf.date_valid, inf.formula_valid, inf.index_valid}) || ({inf.sel_action_valid, inf.mode_valid, inf.data_no_valid, inf.date_valid, inf.formula_valid, inf.index_valid} === 0))
else $fatal(0, "Assertion 5 is violated");

// 6. Out_valid can only be high for exactly one cycle.

assert_6: assert property(out_for_one)
else begin
    # (0.2);
    $display("Assertion 6 is violated");
    $fatal;
end

property out_for_one;
    @(negedge clk) inf.out_valid |=> !inf.out_valid;
endproperty: out_for_one

// 7. Next operation will be valid 1-4 cycles after out_valid fall.

asert_7 : assert property(@(posedge clk) (inf.out_valid===1) |-> ##[1:4] (inf.sel_action_valid===1))
else begin
    #(0.8);
    $display("Assertion 7 is violated");
    $fatal;
end

logic date_fail;
always_comb begin 
    if(inf.date_valid)begin
        if(inf.D.d_date[0].M == 2)begin
            if((inf.D.d_date[0].D > 28 || inf.D.d_date[0].D < 1))
                date_fail = 1;
            else 
                date_fail = 0;
        end
        else if(inf.D.d_date[0].M == 4 || inf.D.d_date[0].M == 6 ||inf.D.d_date[0].M == 9 ||inf.D.d_date[0].M == 11)begin
            if(inf.D.d_date[0].D > 30 || inf.D.d_date[0].D < 1)begin
                date_fail = 1;
            end
            else begin
                date_fail = 0;
            end
        end
        else if(inf.D.d_date[0].M == 1 || inf.D.d_date[0].M == 3 ||inf.D.d_date[0].M == 5 ||inf.D.d_date[0].M == 7 || inf.D.d_date[0].M ==8 || inf.D.d_date[0].M == 10 ||inf.D.d_date[0].M == 12)begin
            if(inf.D.d_date[0].D > 31 || inf.D.d_date[0].D < 1)begin
                date_fail = 1;
            end
            else begin
                date_fail = 0;
            end
        end
        else date_fail = 1;
    end
end
assert_8: assert property(real_date)
else $fatal(0, "Assertion 8 is violated");

property real_date;
    @(posedge clk) inf.date_valid |-> !date_fail;
endproperty: real_date

assert_9: assert property(AR_VALID_overlap)
else begin
    # (0.2);
    $display("Assertion 9 is violated");
    $fatal;
end

property AR_VALID_overlap;
    @(posedge clk) inf.AR_VALID |-> !inf.AW_VALID;
endproperty: AR_VALID_overlap

endmodule