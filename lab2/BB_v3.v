module BB(
    //Input Ports
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] inning,   // Current inning number
    input half,           // 0: top of the inning, 1: bottom of the inning
    input [2:0] action,   // Action code

    //Output Ports
    output reg out_valid,  // Result output valid
    output reg [3:0] score_A,  // Score of team A (guest team)
    output reg [2:0] score_B,  // Score of team B (home team)
    output reg [1:0] result    // 0: Team A wins, 1: Team B wins, 2: Darw
);

//==============================================//
//             Action Memo for Students         //
// Action code interpretation:
// 3’d0: Walk (BB)
// 3’d1: 1H (single hit)
// 3’d2: 2H (double hit)
// 3’d3: 3H (triple hit)
// 3’d4: HR (home run)
// 3’d5: Bunt (short hit)
// 3’d6: Ground ball
// 3’d7: Fly ball
//==============================================//

//==============================================//
//             Parameter and Integer            //
//==============================================//
// State declaration for FSM
// Example: parameter IDLE = 3'b000;



//==============================================//
//                 reg declaration              //
//==============================================//
//INPUT
reg half_reg;
reg in_valid_reg;
reg [2:0]action_reg;


//OUTPUT
reg out_valid_nxt;
reg [3:0] score_A_nxt;
reg [2:0] score_B_nxt;
reg [2:0] score_tmp;
reg [3:0] add_component;
reg [4:0] score_addtmp;
reg [1:0]result_tmp;
//COMPUTE
reg [2:0]base_state,base_state_nxt;
reg [1:0]out_cnt,out_cnt_nxt;
reg [2:0]p_controlkey;
reg [1:0]pre_cal_point1;
reg [1:0]pre_cal_point2;
reg [1:0]pre_cal_point3;
wire [1:0]out_cntadd1;
reg [2:0]p_addcopment;
reg endflag,endflag_nxt;
wire [7:0]integrate;
//==============================================//
//             Current State Block              //
//==============================================//



//==============================================//
//              Next State Block                //
//==============================================//



//==============================================//
//             Base and Score Logic             //
//==============================================//

//I/O
always @(posedge clk ) begin
    if(!rst_n)begin
        half_reg<=0;
        action_reg<=0;
        in_valid_reg<=0;

    end   
    else begin
        half_reg<=half;
        action_reg<=action;
        in_valid_reg<=in_valid;

    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_valid <= 0;
        score_A   <= 0;
        score_B   <= 0;

    end   
    else begin
        out_valid <= out_valid_nxt;
        score_A   <= score_A_nxt;
        score_B   <= score_B_nxt;
 
    end
end
//CMOPUTE
always @(posedge clk ) begin
    if(!rst_n)begin
        base_state<=0;
        out_cnt<=0;
        //endflag<=0;
    end   
    else begin
        base_state<=base_state_nxt;
        out_cnt<=out_cnt_nxt;
        //endflag<=endflag_nxt;
    end
end

//base_state
always @(*) begin
    if(in_valid_reg)begin
        if(half_reg == half)begin
            case (action_reg)
                0: 
                begin
                    if(base_state[0]==0)begin
                        base_state_nxt = base_state + 1;
                    end
                    else begin
                        if(pre_cal_point3 == 1) base_state_nxt = 3;
                        else                    base_state_nxt = 7;
                    end

                end
                1:
                begin
                    base_state_nxt = (base_state << (out_cnt[1] + 1)) | 1'b1;//& 001
                end
                2:
                begin
                    base_state_nxt = {(!out_cnt[1]) & base_state[0],2'b10};//&010
                end
                3:
                begin
                    base_state_nxt = 3'b100;
                end
                4:
                begin
                    base_state_nxt = 0;
                end
                5:
                begin
                    base_state_nxt = base_state << 1;
                end
                6:
                begin
                    base_state_nxt = base_state[1]==1 ? 4 : 0;
                end
                7:
                begin
                    base_state_nxt = base_state >3 ?  { 1'b0 , base_state[1],base_state[0]} : base_state;
                end
            endcase
        end
        else
            base_state_nxt = 0;
    end
    else
    begin
        base_state_nxt = 0;
    end
end

//outplayer control
//assign out_cntadd1 = out_cnt + 1;
always @(*) begin
    if(in_valid_reg)begin
        if(half_reg == half)begin
            /*if(action_reg > 4)begin
                if(action_reg[0]) out_cnt_nxt = out_cnt + 1;
                else              out_cnt_nxt = out_cnt + 1 + base_state[0];
            end
            else
                out_cnt_nxt = out_cnt;*/
            if(out_cnt < 3)begin
                case (action_reg)
                5,7:out_cnt_nxt = out_cnt ? 2 : 1;
                6  :out_cnt_nxt = base_state[0] ? 2 : (out_cnt ? 2 : 1);
                default: out_cnt_nxt = out_cnt;
            endcase
            end
            else    out_cnt_nxt = out_cnt;
        end
        else begin
            if(inning == 3 && result_tmp==1 && half) out_cnt_nxt = 3;
            else                                     out_cnt_nxt = 0;
        end
            
                
    end
    else
    begin
        out_cnt_nxt = 0;
    end
end

//point control
assign pre_cal_point1 = base_state[2];                  
assign pre_cal_point2 = {base_state[2] & base_state[1] , base_state[2] ^ base_state[1]};
//assign pre_cal_point3 = base_state[2] + base_state[1] + base_state[0];
always @(*) begin
    case (base_state)
        0: pre_cal_point3 = 0;
        1,2,4: pre_cal_point3 = 1;
        3,5,6: pre_cal_point3 = 2;
        default: pre_cal_point3 = 3;
    endcase
end
always @(*) begin
    if(in_valid_reg)begin
        
        case (action_reg)
            0: score_tmp = base_state==7 ?  1 : 0;
            1,2,3:
            begin
                case (p_controlkey)
                    0,1: score_tmp = pre_cal_point1;
                    2,3: score_tmp = pre_cal_point2;
                    4,5,6: score_tmp = pre_cal_point3;
                    
                endcase
            end
            4: score_tmp = pre_cal_point3 + 1;
            5: score_tmp = base_state[2] ?  1 : 0;
            6: score_tmp = ((out_cnt[1]==0) && (!(out_cnt[0]&base_state[0]))) ? (base_state[2] ?  1 : 0) : 0;
            7: score_tmp = (base_state[2] && !out_cnt[1]) ?  1 : 0;
            default: score_tmp = 0;
        endcase
    end
    else
    begin
        score_tmp = 0;
    end
end
always @(*) begin
    add_component = half_reg ? score_B : score_A;
    score_addtmp = add_component + score_tmp ;
end
always @(*) begin
    if(in_valid_reg)begin
        if(half_reg )begin
            score_A_nxt = score_A;
            score_B_nxt = out_cnt == 3 ? score_B : score_addtmp;
        end
        else 
        begin
            score_A_nxt = score_addtmp;
            score_B_nxt = score_B;
        end
    end
    else
    begin
        score_A_nxt = 0;
        score_B_nxt = 0;
    end
end
//endflag
/*always @(*) begin
    if(in_valid_reg)begin
        if(half && !half_reg)begin
            endflag_nxt = inning == 3 ? (score_A_nxt < score_B_nxt ? 1 : 0 ): 0;
        end
        else
            endflag_nxt = endflag;
        
    end
    else
    begin
        endflag_nxt = 0;
    end
end*/
//point_controlkey

always @(*) begin
    if(in_valid_reg)begin
        
        p_controlkey = ((action_reg -1) << 1) + out_cnt;
    end    
    else
        p_controlkey = 0;
end
//out_valid
always @(*) begin
    if(!in_valid && in_valid_reg) out_valid_nxt = 1;
    else                          out_valid_nxt = 0; 

end

//result
always @(*) begin
    if(score_A > score_B)begin
        result_tmp = 0;
    end
    else if(score_A < score_B)begin
        result_tmp =  1 ;
    end
    else
        result_tmp =  2 ;
end
assign result = out_valid ? result_tmp : 0;
/*always @(*) begin
    if(score_A > score_B)begin
        result = 0;
    end
    else if(score_A < score_B)begin
        result = out_valid ? 1 : 0;
    end
    else
        result = out_valid ? 2 : 0;
end*/
endmodule
