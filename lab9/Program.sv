module Program(input clk, INF.Program_inf inf);
import usertype::*;


//==============================================//
//               PORT DECLARATION               //
//==============================================//
typedef enum logic[2:0] {IDLE,INDEX_CHECK,UPDATE,VALID_DATE,OUT} STATE;
STATE cur_state , nxt_state;
//input
logic [4:0]day,day_nxt;
logic [3:0]month,month_nxt;
logic [4:0]dram_day,dram_day_nxt;
logic [3:0]dram_month,dram_month_nxt;
logic [7:0]data_no,data_no_nxt;
logic [2:0]formula,formula_nxt;
logic [1:0]mode_reg,mode_nxt;
logic index_valid_reg;
logic R_VALID_reg;
//AXI
logic AR_VALID_nxt;
logic AW_VALID_nxt;
logic [16:0]AR_ADDR_nxt;
logic [16:0]AW_ADDR_nxt;
logic R_READY_nxt;
logic W_VALID_nxt;
logic B_READY_nxt;
//cnt
logic [1:0]cnt_axi,cnt_axi_nxt;
logic [1:0]cnt_index,cnt_index_nxt;
logic [1:0]cnt_cal,cnt_cal_nxt;
//index
//updata_act:use I to store I + var
logic [11:0]IA,IA_nxt;
logic [11:0]IB,IB_nxt;
logic [11:0]IC,IC_nxt;
logic [11:0]ID,ID_nxt;

//index_ckeck_act: formula FGH need use |I-TI|(G), no need TI ,so G coverge TI 
logic [11:0]TIA,TIA_nxt;
logic [11:0]TIB,TIB_nxt;
logic [11:0]TIC,TIC_nxt;
logic [11:0]TID,TID_nxt;
//output
logic [1:0]warn_msg_reg,warn_msg_nxt;
logic out_valid_nxt;
logic [11:0]R,R_nxt;
//flag
logic pat_in_finish,pat_in_finish_nxt;
logic dram_in_finish,dram_in_finish_nxt;
logic date_warn_flag,date_warn_flag_nxt;
//sub
logic signed[12:0]sub_z1;
logic signed[12:0]sub_z2;
logic signed[12:0]sub_z3;
logic signed[12:0]sub_z4;
//sort
logic [11:0]sort_lay1_a[0:3];
logic [11:0]sort_lay2_a[0:3];
logic [11:0]sort_lay3_a[0:3];
logic [11:0]sort_lay1_b[0:3];
logic [11:0]sort_lay2_b[0:3];
logic [11:0]sort_lay3_b[0:3];
//threshold
logic [11:0]threshold;
//================================================================//
//                           INPUR REG
//================================================================//
always@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        R_VALID_reg <= 0;
    end
    else begin
        R_VALID_reg <= inf.R_VALID;
    end
end
//================================================================//
//                             FSM
//================================================================//
always@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always_comb begin
    case (cur_state)
        IDLE: begin
            if(inf.sel_action_valid)begin
                case (inf.D.d_act[0])
                    0: nxt_state = INDEX_CHECK;
                    1: nxt_state = UPDATE;
                    2: nxt_state = VALID_DATE;
                    default: nxt_state = cur_state;
                endcase
            end
            else nxt_state = cur_state;
        end
        UPDATE:      nxt_state = inf.out_valid ? IDLE : cur_state;
        INDEX_CHECK: nxt_state = inf.out_valid ? IDLE : cur_state;
        VALID_DATE:  nxt_state = inf.out_valid ? IDLE : cur_state;
        default : nxt_state = cur_state ;
    endcase
end
//================================================================//
//                        READ INPUT
//================================================================//
//from pattern
always_comb begin
    if(inf.date_valid)begin
        day_nxt   = inf.D.d_date[0][4:0];
        month_nxt = inf.D.d_date[0][8:5];
    end
    else begin
        day_nxt   = day;
        month_nxt = month;
    end
    /*case (cur_state)
        UPDATE,INDEX_CHECK:begin
            
        end 
        default: begin
            day_nxt   = day;
            month_nxt = month;
        end
    endcase*/
end
always_comb begin
    case (cur_state)
        UPDATE,INDEX_CHECK:begin
            if(inf.data_no_valid)begin
                data_no_nxt = inf.D.d_data_no[0];
            end
            else begin
                data_no_nxt = data_no;
            end
        end 
        default: begin
            data_no_nxt = data_no;
        end
    endcase
end
always_comb begin
    case (cur_state)
        UPDATE,INDEX_CHECK:begin
            if(inf.formula_valid)begin
                formula_nxt = inf.D.d_formula[0];
            end
            else begin
               formula_nxt = formula;
            end
        end 
        default: begin
            formula_nxt = formula;
        end
    endcase
end
always_comb begin
    if(inf.mode_valid)begin
        mode_nxt = inf.D.d_mode[0];
    end
    else
        mode_nxt = mode_reg; 
end
always_comb begin
    sub_z1 = IA - TIA;
    sub_z2 = IB - TIB;
    sub_z3 = IC - TIC;
    sub_z4 = ID - TID;
end
always_comb begin
    TIA_nxt = TIA;
    TIB_nxt = TIB;
    TIC_nxt = TIC;
    TID_nxt = TID;
    if(inf.index_valid)begin
        TIA_nxt = TIB;
        TIB_nxt = TIC;
        TIC_nxt = TID;
        TID_nxt = inf.D.d_index[0];
    end
    else begin
        //formula FGH need use |I-TI|(G), no need TI ,so G coverge TI 
        if(formula > 4 && dram_in_finish && pat_in_finish)begin
            case (cnt_cal)
                0: begin
                    TIA_nxt = (sub_z1[12]) ? -sub_z1 : sub_z1; 
                    TIB_nxt = (sub_z2[12]) ? -sub_z2 : sub_z2; 
                    TIC_nxt = (sub_z3[12]) ? -sub_z3 : sub_z3; 
                    TID_nxt = (sub_z4[12]) ? -sub_z4 : sub_z4; 
                end
                1: begin
                    TIA_nxt = sort_lay3_b[0];
                    TIB_nxt = sort_lay3_b[1];
                    TIC_nxt = sort_lay3_b[2];
                    TID_nxt = sort_lay3_b[3];
                end
            endcase
        end
    end
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        formula <= 0;
        data_no <= 0;
        day <= 0;
        month <= 0;
        mode_reg <= 0;
    end
    else begin
        formula <= formula_nxt;
        data_no <= data_no_nxt;
        day <= day_nxt;
        month <= month_nxt;
        mode_reg <= mode_nxt;
    end
end

always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        TIA <= 0;
        TIB <= 0;
        TIC <= 0;
        TID <= 0;
    end
    else begin
        TIA <= TIA_nxt;
        TIB <= TIB_nxt;
        TIC <= TIC_nxt;
        TID <= TID_nxt;
    end
end
//from dram
logic signed[13:0]sum_a;
logic signed[13:0]sum_b;
logic signed[13:0]sum_c;
logic signed[13:0]sum_d;
logic signed[12:0]rdata_signed_a;
logic signed[12:0]rdata_signed_b;
logic signed[12:0]rdata_signed_c;
logic signed[12:0]rdata_signed_d;
assign rdata_signed_a = inf.R_DATA[63:52];
assign rdata_signed_b = inf.R_DATA[51:40];
assign rdata_signed_c = inf.R_DATA[31:20];
assign rdata_signed_d = inf.R_DATA[19:8] ;
always_comb begin
    warn_msg_nxt = No_Warn;
    IA_nxt = IA;
    IB_nxt = IB;
    IC_nxt = IC;
    ID_nxt = ID;
    case (cur_state)
        //CAL UPDATE DATA
        UPDATE:begin
            if(inf.R_VALID)begin
                sum_a = $signed(TIA) + rdata_signed_a;
                sum_b = $signed(TIB) + rdata_signed_b;
                sum_c = $signed(TIC) + rdata_signed_c;
                sum_d = $signed(TID) + rdata_signed_d;
                if(sum_a > 4095)begin
                    IA_nxt = 4095;
                    warn_msg_nxt = Data_Warn;
                end
                else if(sum_a < 0)begin
                    IA_nxt = 0;
                    warn_msg_nxt = Data_Warn;
                end
                else
                    IA_nxt = sum_a;

                if(sum_b > 4095)begin
                    IB_nxt = 4095;
                    warn_msg_nxt = Data_Warn;
                end
                else if(sum_b < 0)begin
                    IB_nxt = 0;
                    warn_msg_nxt = Data_Warn;
                end
                else
                    IB_nxt = sum_b;

                if(sum_c > 4095)begin
                    IC_nxt = 4095;
                    warn_msg_nxt = Data_Warn;
                end
                else if(sum_c < 0)begin
                    IC_nxt = 0;
                    warn_msg_nxt = Data_Warn;
                end
                else
                    IC_nxt = sum_c;

                if(sum_d > 4095)begin
                    ID_nxt = 4095;
                    warn_msg_nxt = Data_Warn;
                end
                else if(sum_d < 0)begin
                    ID_nxt = 0;
                    warn_msg_nxt = Data_Warn;
                end
                else
                    ID_nxt = sum_d;
            end
            else warn_msg_nxt = warn_msg_reg;
        end 
        //READ INDEX_CHECK DATA
        VALID_DATE:begin
            warn_msg_nxt = date_warn_flag ? Date_Warn : No_Warn;
            if(inf.R_VALID)begin
                IA_nxt = inf.R_DATA[63:52];
                IB_nxt = inf.R_DATA[51:40];
                IC_nxt = inf.R_DATA[31:20];
                ID_nxt = inf.R_DATA[19:8];
            end
        end
        INDEX_CHECK:begin
            if(date_warn_flag)begin
                warn_msg_nxt = Date_Warn;
            end
            else begin
                warn_msg_nxt = R >= threshold ? Risk_Warn : No_Warn;
            end
            if(inf.R_VALID)begin
                IA_nxt = inf.R_DATA[63:52];
                IB_nxt = inf.R_DATA[51:40];
                IC_nxt = inf.R_DATA[31:20];
                ID_nxt = inf.R_DATA[19:8];
            end
            else if(formula < 4)begin
                IA_nxt = sort_lay3_a[0];
                IB_nxt = sort_lay3_a[1];
                IC_nxt = sort_lay3_a[2];
                ID_nxt = sort_lay3_a[3];
            end
            else begin
                IA_nxt = IA;
                IB_nxt = IB;
                IC_nxt = IC;
                ID_nxt = ID;
            end 
        end
        default: begin
            IA_nxt = IA;
            IB_nxt = IB;
            IC_nxt = IC;
            ID_nxt = ID;
        end
    endcase 
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        IA  <= 0;
        IB  <= 0;
        IC  <= 0;
        ID  <= 0;
    end
    else begin
        IA  <= IA_nxt;
        IB  <= IB_nxt;
        IC  <= IC_nxt;
        ID  <= ID_nxt;
    end
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        dram_day <= 0;
        dram_month <= 0;
    end
    else begin
        dram_day <= dram_day_nxt;
        dram_month <= dram_month_nxt;
    end
end
//================================================================//
//                            SORT
//================================================================//
always_comb begin
    if(IA > IB)begin
        sort_lay1_a[0] = IA;
        sort_lay1_a[1] = IB;
    end
    else begin
        sort_lay1_a[0] = IB;
        sort_lay1_a[1] = IA;
    end
    if(IC > ID)begin
        sort_lay1_a[2] = IC;
        sort_lay1_a[3] = ID;
    end
    else begin
        sort_lay1_a[2] = ID;
        sort_lay1_a[3] = IC;
    end

    if(sort_lay1_a[0] > sort_lay1_a[2])begin
        sort_lay2_a[0] = sort_lay1_a[0];
        sort_lay2_a[1] = sort_lay1_a[2];
    end
    else begin
        sort_lay2_a[0] = sort_lay1_a[2];
        sort_lay2_a[1] = sort_lay1_a[0];
    end
    if(sort_lay1_a[1] > sort_lay1_a[3])begin
        sort_lay2_a[2] = sort_lay1_a[1];
        sort_lay2_a[3] = sort_lay1_a[3];
    end
    else begin
        sort_lay2_a[2] = sort_lay1_a[3];
        sort_lay2_a[3] = sort_lay1_a[1];
    end  


    sort_lay3_a[0] = sort_lay2_a[0];
    sort_lay3_a[3] = sort_lay2_a[3];
    if(sort_lay2_a[1] > sort_lay2_a[2])begin
        sort_lay3_a[1] = sort_lay2_a[1];
        sort_lay3_a[2] = sort_lay2_a[2];
    end
    else begin
        sort_lay3_a[1] = sort_lay2_a[2];
        sort_lay3_a[2] = sort_lay2_a[1];
    end     
end
always_comb begin
    if(TIA > TIB)begin
        sort_lay1_b[0] = TIA;
        sort_lay1_b[1] = TIB;
    end
    else begin
        sort_lay1_b[0] = TIB;
        sort_lay1_b[1] = TIA;
    end
    if(TIC > TID)begin
        sort_lay1_b[2] = TIC;
        sort_lay1_b[3] = TID;
    end
    else begin
        sort_lay1_b[2] = TID;
        sort_lay1_b[3] = TIC;
    end

    if(sort_lay1_b[0] > sort_lay1_b[2])begin
        sort_lay2_b[0] = sort_lay1_b[0];
        sort_lay2_b[1] = sort_lay1_b[2];
    end
    else begin
        sort_lay2_b[0] = sort_lay1_b[2];
        sort_lay2_b[1] = sort_lay1_b[0];
    end
    if(sort_lay1_b[1] > sort_lay1_b[3])begin
        sort_lay2_b[2] = sort_lay1_b[1];
        sort_lay2_b[3] = sort_lay1_b[3];
    end
    else begin
        sort_lay2_b[2] = sort_lay1_b[3];
        sort_lay2_b[3] = sort_lay1_b[1];
    end  


    sort_lay3_b[0] = sort_lay2_b[0];
    sort_lay3_b[3] = sort_lay2_b[3];
    if(sort_lay2_b[1] > sort_lay2_b[2])begin
        sort_lay3_b[1] = sort_lay2_b[1];
        sort_lay3_b[2] = sort_lay2_b[2];
    end
    else begin
        sort_lay3_b[1] = sort_lay2_b[2];
        sort_lay3_b[2] = sort_lay2_b[1];
    end   
end
//================================================================//
//                         THRESHOLD
//================================================================//
always_comb begin 
    case (formula)
        0,2: begin
            case (mode_reg)
                0: threshold = 2047;
                1: threshold = 1023;
                3: threshold = 511;
                default: threshold = 0;
            endcase
        end
        1,5,6,7: begin
            case (mode_reg)
                0: threshold = 800;
                1: threshold = 400;
                3: threshold = 200;
                default: threshold = 0;
            endcase
        end
        3,4: begin
            case (mode_reg)
                0: threshold = 3;
                1: threshold = 2;
                3: threshold = 1;
                default: threshold = 0;
            endcase
        end
        default: begin
            threshold = 0;
        end
    endcase
end
//================================================================//
//                        CAL RESULT
//================================================================//
logic [12:0]add1,add2;
logic [13:0]add3;
always_comb begin
    if(!(|formula))begin
        add1 = IA + IB;
        add2 = IC + ID;
        add3 = add1 + add2;
    end
    else if(&formula)begin
        add1 = TIA + TIB;
        add2 = TIC + TID;
        add3 = add1 + add2;
    end
    else begin
        add1 = 0;
        add2 = 0;
        add3 = 0;
    end
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        R <= 0;
    end
    else begin
        R <= R_nxt;
    end
end
always_comb begin
    case (formula)
        0: begin
            R_nxt = add3 >> 2;
        end
        1: begin
            R_nxt = IA - ID;
        end
        2: begin
            R_nxt = ID;
        end
        3: begin
            R_nxt = (IA >= 2047) + (IB >= 2047) + (IC >= 2047) + (ID >= 2047) ;
        end
        4: begin
            R_nxt = (IA >= TIA) + (IB >= TIB) + (IC >= TIC) + (ID >= TID) ;
        end
        5: begin
            R_nxt = (TIB + TIC + TID) / 3;
        end
        6: begin
            R_nxt = (TID >> 1) + (TIC >> 2) + (TIB >> 2);
        end
        7: begin
            R_nxt = add3 >> 2;
        end
        default: R_nxt = 0;
    endcase
end

//================================================================//
//                            CNT
//================================================================//
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        cnt_cal <= 0;
        cnt_index <= 0;
    end
    else begin
         //cnt_axi <= cnt_axi_nxt;
         cnt_cal <= cnt_cal_nxt;
         cnt_index <= cnt_index_nxt;
    end
end
always_comb begin
    if(inf.index_valid) begin
        cnt_index_nxt = cnt_index + 1;
    end
    else begin
        cnt_index_nxt = 0;
    end
end
always_comb begin
    if(dram_in_finish && pat_in_finish)begin
        cnt_cal_nxt = cnt_cal + 1;
    end
    else
        cnt_cal_nxt = 0;
end

//================================================================//
//                           FLAG
//================================================================//
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        pat_in_finish  <= 0;
        dram_in_finish <= 0;
        date_warn_flag <= 0;
    end
    else begin
        pat_in_finish  <= pat_in_finish_nxt ;
        dram_in_finish <= dram_in_finish_nxt;
        date_warn_flag <= date_warn_flag_nxt;
    end
end
always_comb begin
    if(inf.R_VALID)begin
        dram_in_finish_nxt = 1;
    end
    else begin
        dram_in_finish_nxt = inf.out_valid ? 0 : dram_in_finish;
    end
end
always_comb begin
    if(cnt_index == 3)begin
        pat_in_finish_nxt = 1;
    end
    else begin
        pat_in_finish_nxt = inf.out_valid ? 0 : pat_in_finish;
    end
end
//================================================================//
//                            AXI
//================================================================//
//arvalid
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AR_VALID <= 0;
    end
    else begin
        
        inf.AR_VALID <= AR_VALID_nxt;
    end
end
always_comb begin
    if(inf.data_no_valid)begin
        AR_VALID_nxt = 1;
    end
    else begin
        AR_VALID_nxt = inf.AR_READY ? 0 : inf.AR_VALID;
    end
end
//araddr
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AR_ADDR <= 0;
    end
    else begin
        inf.AR_ADDR <= AR_ADDR_nxt;
    end
end
always_comb begin
    if(inf.data_no_valid)begin
        AR_ADDR_nxt = (inf.D.d_data_no[0]<<3) + 32'h10000;
    end
    else begin
        AR_ADDR_nxt = inf.AR_ADDR;
    end
end
//rready
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.R_READY <= 0;
    end
    else begin
        inf.R_READY <= R_READY_nxt;
    end
end
always_comb begin
    if(inf.AR_VALID && inf.AR_READY)begin
        R_READY_nxt = 1;
    end
    else begin
        R_READY_nxt = inf.R_VALID ? 0 : inf.R_READY;
    end
end
//awaddr
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AW_ADDR <= 0;
    end
    else begin
        inf.AW_ADDR <= AW_ADDR_nxt;
    end
end
always_comb begin
    if(inf.data_no_valid)begin
        AW_ADDR_nxt = (inf.D.d_data_no[0]<<3) + 32'h10000;
    end
    else begin
        AW_ADDR_nxt = inf.AW_ADDR;
    end
end
//awvalid
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.AW_VALID <= 0;
    end
    else begin
        
        inf.AW_VALID <= AW_VALID_nxt;
    end
end
always_comb begin
    if(inf.R_VALID && cur_state == UPDATE)begin
        AW_VALID_nxt = 1;
    end
    else begin
        AW_VALID_nxt = inf.AW_READY ? 0 : inf.AW_VALID;
    end
end
//wvalid
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.W_VALID <= 0;
    end
    else begin
        
        inf.W_VALID <= W_VALID_nxt;
    end
end
always_comb begin
    if(inf.AW_VALID && inf.AW_READY)begin
        W_VALID_nxt = 1;
    end
    else begin
        W_VALID_nxt = inf.W_READY ? 0 : inf.W_VALID;
    end
end
//bready
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.B_READY <= 0;
    end
    else begin
        
        inf.B_READY <= B_READY_nxt;
    end
end
always_comb begin
    if(inf.AW_VALID && inf.AW_READY)begin
        B_READY_nxt = 1;
    end
    else begin
        B_READY_nxt = inf.B_VALID ? 0 : inf.B_READY;
    end
end
//wdata
assign inf.W_DATA = (inf.W_VALID) ? {IA,IB,4'b0000,month,IC,ID,3'b000,day} : 0;
//================================================================//
//                           DATE WARN
//================================================================//
logic [7:0]m,d;
assign m = inf.R_DATA[39:32];
assign d = inf.R_DATA[7:0];
always_comb begin
    if(inf.R_VALID)begin
        if(month <= inf.R_DATA[39:32])begin
            if(month == inf.R_DATA[39:32])begin
                if(day < inf.R_DATA[7:0])begin
                    date_warn_flag_nxt = 1;
                end
                else begin
                    date_warn_flag_nxt = 0;
                end
            end
            else begin
                date_warn_flag_nxt = 1;
            end  
        end
        else date_warn_flag_nxt = 0;
    end
    else date_warn_flag_nxt = 0;
end
//================================================================//
//                            OUT
//================================================================//
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        inf.out_valid <= 0;
        warn_msg_reg <= 0;
    end
    else begin
        inf.out_valid <= out_valid_nxt;
        warn_msg_reg <= warn_msg_nxt;
    end
end
always_comb begin
    case (cur_state)
        UPDATE:begin
            out_valid_nxt = inf.B_VALID;
        end 
        VALID_DATE:begin
            out_valid_nxt = R_VALID_reg ? 1 : 0;
        end
        INDEX_CHECK:begin
            if(date_warn_flag)begin
                out_valid_nxt = 1;
            end
            else begin
                if(cnt_cal == 3)begin
                    out_valid_nxt = 1;
                end
                else    
                    out_valid_nxt = 0;
            end
        end
        default: out_valid_nxt = 0;
    endcase
end
assign inf.complete = (inf.out_valid && warn_msg_reg==0) ? 1 : 0;
assign inf.warn_msg = inf.out_valid ? warn_msg_reg : 0;
endmodule
