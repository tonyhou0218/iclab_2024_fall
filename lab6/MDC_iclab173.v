//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/9
//		Version		: v1.0
//   	File Name   : MDC.v
//   	Module Name : MDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "HAMMING_IP.v"
//synopsys translate_on

module MDC(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Output signals
    out_valid, 
	out_data
);

// ===============================================================//
// Input & Output Declaration
// ===============================================================//
input clk, rst_n, in_valid;
input [8:0] in_mode;
input [14:0] in_data;

output reg out_valid;
output reg [206:0] out_data;
//==================================================================
// parameter & integer
//==================================================================
parameter CS_IDLE        =  'd0;
parameter CS_INDATA      =  'd1;
parameter CS_CALCU       =  'd2;

// ===============================================================//
//                             Reg
// ===============================================================//

reg [1:0]cur_state,nxt_state;
reg signed [10:0]ma1,ma3,ma5,ma6;
reg signed [10:0]mb1,mb3,mb5,mb6;
reg signed [21:0]mz1,mz3,mz5,mz6;

reg signed [10:0]ma2,ma4,ma7,ma8;
reg signed [35:0]mb2,mb4,mb7,mb8;
reg signed [46:0]mz2,mz4,mz7,mz8;
reg [14:0]in_data_reg;

reg signed [10:0]matrix[0:15],matrix_nxt[0:15];
wire [10:0]OUT_code;
wire [14:0]IN_code;
wire [4:0]OUT_mode;
wire [8:0]IN_mode;
reg in_valid_reg;
reg [1:0]mode_ff,mode_nxt;
reg [4:0]cnt,cnt_nxt;
reg [1:0]cnt_3,cnt_3_nxt;
//reg signed[33:0]temp_det[0:3],temp_det_nxt[0:3];
reg [206:0]out_ff,out_nxt;
reg signed[45:0]add1,add2;

reg signed[21:0]add_22_a1,add_22_b1;
reg signed[21:0]add_22_a2,add_22_b2;
reg signed[21:0]add_22_a3,add_22_b3;
reg signed[46:0]add_50_a1,add_50_a2,add_50_a3,add_50_a4;
reg signed[50:0]add_50_b1,add_50_b2,add_50_b3,add_50_b4;

reg signed[22:0]add_22_z1;
reg signed[22:0]add_22_z2;
reg signed[22:0]add_22_z3;
reg signed[50:0]add_50_z1,add_50_z2,add_50_z3,add_50_z4;
HAMMING_IP #(.IP_BIT(11)) I_HAMMING_IP(.IN_code(in_data), .OUT_code(OUT_code)); 
HAMMING_IP #(.IP_BIT(5) ) HAMMING_IP_MODE(.IN_code(in_mode), .OUT_code(OUT_mode)); 

//==================================================================
//                   design
//==================================================================
//=================================================
//                  FSM
//=================================================
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= CS_IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always @(*) begin
    case (cur_state)
        CS_IDLE: begin
            if(in_valid && !in_valid_reg) nxt_state = CS_INDATA;
            else nxt_state = cur_state;
        end
        CS_INDATA: nxt_state = (out_valid) ? CS_IDLE : cur_state;

        default: nxt_state = cur_state;
    endcase
end
//=================================================
//                  I/O
//=================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        in_data_reg <= 0;

        in_valid_reg <= 0;
        mode_ff <= 0;
        out_ff <= 0;
    end
    else begin
        in_data_reg <= in_data;

        in_valid_reg<=in_valid;
        mode_ff <= mode_nxt;
        out_ff <= out_nxt;
    end
end

always @(*) begin
    matrix_nxt = matrix;
    case (cur_state)
        CS_IDLE: matrix_nxt[15] = OUT_code;
        CS_INDATA:begin
            matrix_nxt[0 ] = matrix[1 ];
            matrix_nxt[1 ] = matrix[2 ];
            matrix_nxt[2 ] = matrix[3 ];
            matrix_nxt[3 ] = matrix[4 ];
            matrix_nxt[4 ] = matrix[5 ];
            matrix_nxt[5 ] = matrix[6 ];
            matrix_nxt[6 ] = matrix[7 ];
            matrix_nxt[7 ] = matrix[8 ];
            matrix_nxt[8 ] = matrix[9 ];
            matrix_nxt[9 ] = matrix[10];
            matrix_nxt[10] = matrix[11];
            matrix_nxt[11] = matrix[12];
            matrix_nxt[12] = matrix[13];
            matrix_nxt[13] = matrix[14];
            matrix_nxt[14] = matrix[15];
            matrix_nxt[15] = OUT_code;
            
        end
        default: begin
            matrix_nxt[0 ] = matrix[0 ];
            matrix_nxt[1 ] = matrix[1 ];
            matrix_nxt[2 ] = matrix[2 ];
            matrix_nxt[3 ] = matrix[3 ];
            matrix_nxt[4 ] = matrix[4 ];
            matrix_nxt[5 ] = matrix[5 ];
            matrix_nxt[6 ] = matrix[6 ];
            matrix_nxt[7 ] = matrix[7 ];
            matrix_nxt[8 ] = matrix[8 ];
            matrix_nxt[9 ] = matrix[9 ];
            matrix_nxt[10] = matrix[10];
            matrix_nxt[11] = matrix[11];
            matrix_nxt[12] = matrix[12];
            matrix_nxt[13] = matrix[13];
            matrix_nxt[14] = matrix[14];
            matrix_nxt[15] = matrix[15];
        end
    endcase
end
always @(*) begin
    if(in_valid && !in_valid_reg && cnt == 0)begin
        case (OUT_mode)
            5'b00100: mode_nxt = 1;
            5'b00110: mode_nxt = 2;
            5'b10110: mode_nxt = 3;
            default: mode_nxt = 0;
        endcase
    end
    else begin
        mode_nxt = mode_ff;
    end
end
//=================================================
//                 CNT
//=================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_nxt;
    end
end
always @(*) begin
    case (cur_state)
        CS_IDLE:begin
            cnt_nxt = 0;
        end 
        CS_INDATA:begin
            cnt_nxt =  cnt + 1;
        end
        default:cnt_nxt =  cnt + 1;
    endcase
    /*if(in_valid && !in_valid_reg)begin
        cnt_nxt = 1;
    end
    else if(in_valid || in_valid_reg)begin
        cnt_nxt = cnt + 1;
    end
    else begin
        cnt_nxt = out_valid ? 0 : cnt + 1;
    end*/
end
always @(*) begin
    if(cnt >=8 && cnt <=16)begin
        if(cnt == 12) cnt_3_nxt =0;
        else          cnt_3_nxt = cnt_3 + 1;
    end
    else begin
        cnt_3_nxt = 0;
    end
end
//=================================================
//              Determinant  
//=================================================
always @(*) begin

    //temp_det_nxt = temp_det;
    ma1 = 0;mb1 = 0;
    ma2 = 0;mb2 = 0;
    ma3 = 0;mb3 = 0;
    ma4 = 0;mb4 = 0;
    ma5 = 0;mb5 = 0;
    ma6 = 0;mb6 = 0;
    ma7 = 0;mb7 = 0;
    ma8 = 0;mb8 = 0;
    add1 = 0;
    add2 = 0;
    case (mode_ff)
        1: begin
            ma1 = matrix[10];ma2 = matrix[11];
            mb1 = matrix[15];mb2 = matrix[14];
        end
        2:begin
         
            case (cnt[1:0])
                //D1 (1.6.8)(2.5.8)
                0:begin
                    //add                                 minus
                    ma1 = matrix[8]; mb1 = matrix[13];    ma3 = matrix[9]; mb3 = matrix[12];     
                    ma2 = matrix[15];mb2 = mz1;           ma4 = matrix[15];mb4 = mz3;
                    
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                end 
                1:begin
                    //add                                 minus
                    ma1 = matrix[8];mb1 = matrix[10];     ma3 = matrix[6]; mb3 = matrix[12];     
                    ma2 = matrix[15];mb2 = mz1;           ma4 = matrix[15];mb4 = mz3;
                    
                    ma5 = matrix[8];mb5 = matrix[13];     ma6 = matrix[9]; mb6 = matrix[12];     
                    ma7 = matrix[15];mb7 = mz5;           ma8 = matrix[15];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
   
                end 
                2:begin
                    ma1 = matrix[5];mb1 = matrix[10];     ma3 = matrix[6] ;mb3 = matrix[9];     
                    ma2 = matrix[15];mb2 = mz1;           ma4 = matrix[15];mb4 = mz3;
                    
                    ma5 = matrix[8]; mb5 = matrix[10];    ma6 = matrix[6]; mb6 = matrix[12];     
                    ma7 = matrix[15];mb7 = mz5;           ma8 = matrix[15];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                end
                3:begin
                    ma5 = matrix[5]; mb5 = matrix[10];    ma6 = matrix[6]; mb6 = matrix[9];     
                    ma7 = matrix[15];mb7 = mz5;           ma8 = matrix[15];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                end
           
            endcase
        end
        3: begin
            case (cnt)
                //D1 (1.6.8)(2.5.8)
                8:begin
                    //add                                 minus
                    ma1 = matrix[8]; mb1 = matrix[13];    ma3 = matrix[9]; mb3 = matrix[12];     
                    ma2 = matrix[15];mb2 = mz1;           ma4 = matrix[15];mb4 = mz3;
                    
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                end 
                9:begin
                    //add                                 minus
                    ma1 = matrix[8];mb1 = matrix[10];     ma3 = matrix[6]; mb3 = matrix[12];     
                    ma2 = matrix[15];mb2 = mz1;           ma4 = matrix[15];mb4 = mz3;
                    
                    ma5 = matrix[7];mb5 = matrix[13];     ma6 = matrix[9]; mb6 = matrix[11];     
                    ma7 = matrix[14];mb7 = mz5;           ma8 = matrix[14];mb8 = mz6;

   
                end 
                10:begin
                    ma1 = matrix[5];mb1 = matrix[10];     ma3 = matrix[6] ;mb3 = matrix[9];     
                    ma2 = matrix[15];mb2 = mz1;           ma4 = matrix[15];mb4 = mz3;
                    
                    ma5 = matrix[8]; mb5 = matrix[9];     ma6 = matrix[5]; mb6 = matrix[12];     
                    ma7 = matrix[14];mb7 = mz5;           ma8 = matrix[14];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                end
                11:begin
                    ma1 = matrix[6];mb1 = matrix[11];     ma3 = matrix[7] ;mb3 = matrix[10];     
                    ma2 = matrix[12];mb2 = mz1;           ma4 = matrix[12];mb4 = mz3;

                    ma5 = matrix[4]; mb5 = matrix[9];     ma6 = matrix[5]; mb6 = matrix[8];     
                    ma7 = matrix[15];mb7 = mz5;           ma8 = matrix[15];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                end
                12:begin
                    ma1 = matrix[6];mb1 = matrix[7];     ma3 = matrix[3] ;mb3 = matrix[10];     
                    ma2 = matrix[13];mb2 = mz1;          ma4 = matrix[13];mb4 = mz3;
                    
                    ma5 = matrix[5]; mb5 = matrix[10];   ma6 = matrix[6]; mb6 = matrix[9];     
                    ma7 = matrix[12];mb7 = mz5;          ma8 = matrix[12];mb8 = mz6;
                 

                end
                13:begin
                    ma1 = matrix[2];mb1 = matrix[8];     ma3 = matrix[4] ;mb3 = matrix[6];     
                    ma2 = matrix[13];mb2 = mz1;          ma4 = matrix[13];mb4 = mz3;
                    
                    ma5 = matrix[5]; mb5 = matrix[7];    ma6 = matrix[3]; mb6 = matrix[9];     
                    ma7 = matrix[12];mb7 = mz5;          ma8 = matrix[12];mb8 = mz6;

                end
                14:begin    
                    ma5 = matrix[2]; mb5 = matrix[7];    ma6 = matrix[3]; mb6 = matrix[6];     
                    ma7 = matrix[12];mb7 = mz5;          ma8 = matrix[12];mb8 = mz6;

                    
                end
                15:begin
                    ma2 = matrix[12]; mb2 = $signed (out_ff[143:108]);
                    ma4 = matrix[13]; mb4 = $signed (out_ff[107:72 ]);
                    ma7 = matrix[14]; mb7 = $signed (out_ff[71:36 ]);
                    ma8 = matrix[15]; mb8 = $signed (out_ff[35:0]);

                    add1 = mz2 + mz7;
                    add2 = mz4 + mz8;
                end
                //default: 
            endcase
        end
     
    endcase
end
always @(*) begin
    out_nxt = out_ff;
    case (mode_ff)
        1: out_nxt = (cnt[1:0] == 2'b00) ? out_ff : {out_ff[183:0], add_22_z1};
        2:begin
            if(cnt > 7 && cnt <16)begin
                out_nxt[206:204] = 3'b000;
                case (cnt[1:0])
                    0: begin
                        out_nxt[152:102] = out_ff[50:0];
                        out_nxt[101:51]  = add_50_z1;
                    end
                    1: begin
                        out_nxt[101:51]  = add_50_z2;
                        out_nxt[50:0]    = add_50_z3;
                    end
                    2: begin
                        out_nxt[101:51]  = add_50_z2;
                        out_nxt[50:0]    = add_50_z4;
                    end
                    3: begin
                        //cnt == 15
                        if(cnt[2]==1)begin
                            out_nxt[50:0] = add_50_z4;
                        end
                        else begin
                            out_nxt[203:153] = out_ff[101:51];
                            out_nxt[50:0] = add_50_z4;
                        end
                    end
                endcase
            end
            else out_nxt = out_ff;
            
           
        end
        3:begin
                case (cnt)
                8:begin
                    out_nxt[35:0] = add_50_z1;
                end 
                9:begin
                    out_nxt[35:0 ] = add_50_z2;
                    out_nxt[71:36] = add_50_z3;
                end 
                10:begin
                    out_nxt[35:0 ] = add_50_z2;
                    out_nxt[71:36] = add_50_z4;
                end
                11:begin
                    out_nxt[71:36 ] = add_50_z4;
                    out_nxt[107:72] = add_50_z1;
                end
                12:begin

                    out_nxt[107:72 ] = add_50_z2;
                    out_nxt[143:108] = add_50_z3;
                end
                13:begin
                    out_nxt[107:72 ] = add_50_z2;
                    out_nxt[143:108] = add_50_z4;
                end
                14:begin    
                    out_nxt[143:108] = add_50_z4;   
                end
                15:begin
                    out_nxt = add2-add1;
                end
            endcase
        end
    endcase
end
always @(*) begin
    add_22_a1 = 0; add_22_b1 = 0;
    add_22_a2 = 0; add_22_b2 = 0;
    add_22_a3 = 0; add_22_b3 = 0;
    add_50_a1 = 0; add_50_b1 = 0;
    add_50_a2 = 0; add_50_b2 = 0;
    add_50_a3 = 0; add_50_b3 = 0;
    add_50_a4 = 0; add_50_b4 = 0;
    case (mode_ff)
        1: begin
            add_22_a1 = mz1; add_22_b1 = -mz2;
        end 
        2:begin
            case (cnt[1:0])
                0:begin
                    add_50_a1 = mz2; add_50_b1 = -mz4;
                end 
                1:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;
                    add_50_a2 = add_50_z1; add_50_b2 = $signed(out_ff[101:51]);

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                end
                2:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;
                    add_50_a2 = add_50_z1; add_50_b2 = $signed(out_ff[101:51]);

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                    add_50_a4 = add_50_z3; add_50_b4 = $signed(out_ff[50:0]);
                end
                3:begin
                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                    add_50_a4 = add_50_z3; add_50_b4 = $signed(out_ff[50:0]);
                end
            endcase
        end
        3:begin
            case (cnt)
                8:begin
                    add_50_a1 = mz2; add_50_b1 = -mz4;
                end 
                9:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;
                    add_50_a2 = add_50_z1; add_50_b2 = out_ff[35:0];

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                end
                10:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;
                    add_50_a2 = add_50_z1; add_50_b2 = out_ff[35:0];

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                    add_50_a4 = add_50_z3; add_50_b4 = out_ff[71:36 ];
                end
                11:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                    add_50_a4 = add_50_z3; add_50_b4 = out_ff[71:36 ];
                end
                12:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;
                    add_50_a2 = add_50_z1; add_50_b2 = out_ff[107:72 ];

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                end
                13:begin
                    add_50_a1 = mz2;       add_50_b1 = -mz4;
                    add_50_a2 = add_50_z1; add_50_b2 = out_ff[107:72 ];

                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                    add_50_a4 = add_50_z3; add_50_b4 = out_ff[143:108];
                end
                14:begin
                    add_50_a3 = mz7;       add_50_b3 = -mz8;
                    add_50_a4 = add_50_z3; add_50_b4 = out_ff[143:108];
                end

            endcase
        end
    endcase
end
//ADD
assign add_22_z1 = add_22_a1 + add_22_b1;
assign add_22_z2 = add_22_a2 + add_22_b2;
assign add_22_z3 = add_22_a3 + add_22_b3;

assign add_50_z1 = add_50_a1 + add_50_b1;
assign add_50_z2 = add_50_a2 + add_50_b2;
assign add_50_z3 = add_50_a3 + add_50_b3;
assign add_50_z4 = add_50_a4 + add_50_b4;
// MULTIPLEXER
assign mz1 = ma1 * mb1;
assign mz2 = ma2 * mb2;
assign mz3 = ma3 * mb3;
assign mz4 = ma4 * mb4;
assign mz5 = ma5 * mb5;
assign mz6 = ma6 * mb6;
assign mz7 = ma7 * mb7;
assign mz8 = ma8 * mb8;
//=================================================
//                  OUT 
//=================================================
always @(*) begin
    if(cnt == 16) out_data = out_ff;
    else          out_data = 0;
end
always @(*) begin
    if(cnt == 16) out_valid = 1;
    else          out_valid = 0;
end



genvar i;
generate
    for(i=0;i<16;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                matrix[i] <= 0;
            else 
                matrix[i] <= matrix_nxt[i];
        end
    end
endgenerate
/*generate
    for(i=0;i<4;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                temp_det[i] <= 0;
            else 
                temp_det[i] <= temp_det_nxt[i];
        end
    end
endgenerate*/
endmodule