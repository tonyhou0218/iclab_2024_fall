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
reg signed [21:0]ma1,ma3,ma5,ma6;
reg signed [21:0]mb1,mb3,mb5,mb6;
reg signed [43:0]mz1,mz3,mz5,mz6;

reg signed [10:0]ma2,ma4,ma7,ma8;
reg signed [33:0]mb2,mb4,mb7,mb8;
reg signed [44:0]mz2,mz4,mz7,mz8;
reg [14:0]in_data_reg;

reg signed [10:0]matrix[0:15],matrix_nxt[0:15];
wire [10:0]OUT_code;
wire [14:0]IN_code;
wire [4:0]OUT_mode;
wire [8:0]IN_mode;
reg in_valid_reg;
reg [1:0]mode_ff,mode_nxt;
reg [4:0]cnt,cnt_nxt;
reg signed[33:0]temp_det[0:3],temp_det_nxt[0:3];
reg [206:0]out_ff,out_nxt;
reg signed[45:0]add1,add2;
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
        CS_INDATA: nxt_state = (cnt == 17) ? CS_IDLE : cur_state;

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
        CS_IDLE: matrix_nxt[0] = OUT_code;
        CS_INDATA:begin
            matrix_nxt[cnt] = OUT_code;
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
    if(in_valid && !in_valid_reg && cnt == 1)begin
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
            cnt_nxt = 1;
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
//=================================================
//              Determinant  
//=================================================
always @(*) begin
    out_nxt = out_ff;
    temp_det_nxt = temp_det;
    ma1 = 0;mb1 = 0;
    ma2 = 0;mb2 = 0;
    ma3 = 0;mb3 = 0;
    ma4 = 0;mb4 = 0;
    ma5 = 0;mb5 = 0;
    ma6 = 0;mb6 = 0;
    ma7 = 0;mb7 = 0;
    ma8 = 0;mb8 = 0;
    case (mode_ff)
        1: begin
            case (cnt)
                14: begin
                    ma1 = matrix[0];ma2 = matrix[1]; ma3 = matrix[1];ma4 = matrix[2]; ma5 = matrix[2];ma6 = matrix[3];
                    mb1 = matrix[5];mb2 = matrix[4]; mb3 = matrix[6];mb4 = matrix[5]; mb5 = matrix[7];mb6 = matrix[6];

                    out_nxt[206:184] = mz1 - mz2;
                    out_nxt[183:161] = mz3 - mz4;
                    out_nxt[160:138] = mz5 - mz6;
                end
                15: begin
                    ma1 = matrix[4];ma2 = matrix[5]; ma3 = matrix[5 ];ma4 = matrix[6]; ma5 = matrix[6 ];ma6 = matrix[7 ];
                    mb1 = matrix[9];mb2 = matrix[8]; mb3 = matrix[10];mb4 = matrix[9]; mb5 = matrix[11];mb6 = matrix[10];

                    out_nxt[137:115] = mz1 - mz2;
                    out_nxt[114:92]  = mz3 - mz4;
                    out_nxt[91:69]   = mz5 - mz6;
                end
                16: begin
                    ma1 = matrix[8 ];ma2 = matrix[9 ]; ma3 = matrix[9 ];ma4 = matrix[10]; ma5 = matrix[10];ma6 = matrix[11];
                    mb1 = matrix[13];mb2 = matrix[12]; mb3 = matrix[14];mb4 = matrix[13]; mb5 = matrix[15];mb6 = matrix[14];

                    out_nxt[68:46] = mz1 - mz2;
                    out_nxt[45:23] = mz3 - mz4;
                    out_nxt[22:0]  = mz5 - mz6;
                end
                default: begin
                    
                end
            endcase
        end
        2:begin
            out_nxt[206:204] = 3'b000;
            case (cnt)
                //D1 (1.6.8)(2.5.8)
                9:begin
                    //add                                 minus
                    ma1 = matrix[1];mb1 = matrix[6];     ma3 = matrix[2];mb3 = matrix[5];     
                    ma2 = matrix[8];mb2 = mz1;           ma4 = matrix[8];mb4 = mz3;
                    
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[203:153] = mz2 - mz4;
                end 
                10:begin
                    //add                                 minus
                    ma1 = matrix[2];mb1 = matrix[4];     ma3 = matrix[0];mb3 = matrix[6];     
                    ma2 = matrix[9];mb2 = mz1;           ma4 = matrix[9];mb4 = mz3;
                    
                    ma5 = matrix[2];mb5 = matrix[7];     ma6 = matrix[3];mb6 = matrix[6];     
                    ma7 = matrix[9];mb7 = mz5;           ma8 = matrix[9];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[203:153] = mz2 - mz4 + $signed(out_ff[203:153]);
                    out_nxt[152:102] = mz7 - mz8;
                end 
                11:begin
                    ma1 = matrix[0];mb1 = matrix[5];     ma3 = matrix[1] ;mb3 = matrix[4];     
                    ma2 = matrix[10];mb2 = mz1;          ma4 = matrix[10];mb4 = mz3;
                    
                    ma5 = matrix[3]; mb5 = matrix[5];    ma6 = matrix[1]; mb6 = matrix[7];     
                    ma7 = matrix[10];mb7 = mz5;          ma8 = matrix[10];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[203:153] = mz2 - mz4 + $signed(out_ff[203:153]);
                    out_nxt[152:102] = mz7 - mz8 + $signed(out_ff[152:102]);
                end
                12:begin
                    ma5 = matrix[1]; mb5 = matrix[6];    ma6 = matrix[2]; mb6 = matrix[5];     
                    ma7 = matrix[11];mb7 = mz5;          ma8 = matrix[11];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[152:102] = mz7 - mz8 + $signed(out_ff[152:102]);
                end
                13:begin
                    ma1 = matrix[5];mb1 = matrix[10];    ma3 = matrix[6] ;mb3 = matrix[9];     
                    ma2 = matrix[12];mb2 = mz1;          ma4 = matrix[12];mb4 = mz3;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[101:51] = mz2 - mz4;
                end
                14:begin
                    ma1 = matrix[6];mb1 = matrix[8];     ma3 = matrix[4] ;mb3 = matrix[10];     
                    ma2 = matrix[13];mb2 = mz1;          ma4 = matrix[13];mb4 = mz3;
                    
                    ma5 = matrix[6]; mb5 = matrix[11];   ma6 = matrix[7]; mb6 = matrix[10];     
                    ma7 = matrix[13];mb7 = mz5;          ma8 = matrix[13];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[101:51] = mz2 - mz4 + $signed(out_ff[101:51]);
                    out_nxt[50:0]   = mz7 - mz8 ;
                end
                15:begin
                    ma1 = matrix[4];mb1 = matrix[9];     ma3 = matrix[5] ;mb3 = matrix[8];     
                    ma2 = matrix[14];mb2 = mz1;          ma4 = matrix[14];mb4 = mz3;
                    
                    ma5 = matrix[7]; mb5 = matrix[9];    ma6 = matrix[5]; mb6 = matrix[11];     
                    ma7 = matrix[14];mb7 = mz5;          ma8 = matrix[14];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[101:51] = mz2 - mz4 + $signed(out_ff[101:51]);
                    out_nxt[50:0]   = mz7 - mz8 + $signed(out_ff[50:0]);
                end
                16:begin
                    ma5 = matrix[5]; mb5 = matrix[10];   ma6 = matrix[6]; mb6 = matrix[9];     
                    ma7 = matrix[15];mb7 = mz5;          ma8 = matrix[15];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    out_nxt[50:0] = mz7 - mz8 + $signed(out_ff[50:0]);
                end
                //default: 
            endcase
        end
        3: begin
            case (cnt)
                //D1 (1.6.8)(2.5.8)
                9:begin
                    //add                                 minus
                    ma1 = matrix[1];mb1 = matrix[6];     ma3 = matrix[2];mb3 = matrix[5];     
                    ma2 = matrix[8];mb2 = mz1;           ma4 = matrix[8];mb4 = mz3;
                    
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    temp_det_nxt[0] = mz2 - mz4;
                end 
                10:begin
                    //add                                 minus
                    ma1 = matrix[2];mb1 = matrix[4];     ma3 = matrix[0];mb3 = matrix[6];     
                    ma2 = matrix[9];mb2 = mz1;           ma4 = matrix[9];mb4 = mz3;
                    
                    ma5 = matrix[1];mb5 = matrix[7];     ma6 = matrix[3];mb6 = matrix[5];     
                    ma7 = matrix[8];mb7 = mz5;           ma8 = matrix[8];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    temp_det_nxt[0] = mz2 - mz4 + temp_det[0];
                    temp_det_nxt[1] = mz7 - mz8;
                end 
                11:begin
                    ma1 = matrix[0];mb1 = matrix[5];     ma3 = matrix[1] ;mb3 = matrix[4];     
                    ma2 = matrix[10];mb2 = mz1;          ma4 = matrix[10];mb4 = mz3;
                    
                    ma5 = matrix[3]; mb5 = matrix[4];    ma6 = matrix[0]; mb6 = matrix[7];     
                    ma7 = matrix[9];mb7 = mz5;           ma8 = matrix[9];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    temp_det_nxt[0] = mz2 - mz4 + temp_det[0];
                    temp_det_nxt[1] = mz7 - mz8 + temp_det[1];
                end
                12:begin
                    ma1 = matrix[0];mb1 = matrix[5];     ma3 = matrix[1] ;mb3 = matrix[4];     
                    ma2 = matrix[11];mb2 = mz1;          ma4 = matrix[11];mb4 = mz3;
                    
                    ma5 = matrix[2]; mb5 = matrix[7];    ma6 = matrix[3]; mb6 = matrix[6];     
                    ma7 = matrix[8];mb7 = mz5;           ma8 = matrix[8];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    temp_det_nxt[1] = mz2 - mz4 + temp_det[1];
                    temp_det_nxt[2] = mz7 - mz8 ;
                end
                13:begin
                    ma1 = matrix[3];mb1 = matrix[4];     ma3 = matrix[0] ;mb3 = matrix[7];     
                    ma2 = matrix[10];mb2 = mz1;          ma4 = matrix[10];mb4 = mz3;
                    
                    ma5 = matrix[2]; mb5 = matrix[7];    ma6 = matrix[3]; mb6 = matrix[6];     
                    ma7 = matrix[9];mb7 = mz5;           ma8 = matrix[9];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    temp_det_nxt[2] = mz2 - mz4 + temp_det[2];
                    temp_det_nxt[3] = mz7 - mz8 ;
                end
                14:begin
                    ma1 = matrix[0];mb1 = matrix[6];     ma3 = matrix[2] ;mb3 = matrix[4];     
                    ma2 = matrix[11];mb2 = mz1;          ma4 = matrix[11];mb4 = mz3;
                    
                    ma5 = matrix[3]; mb5 = matrix[5];    ma6 = matrix[1]; mb6 = matrix[7];     
                    ma7 = matrix[10];mb7 = mz5;          ma8 = matrix[10];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/
                    temp_det_nxt[2] = mz2 - mz4 + temp_det[2];
                    temp_det_nxt[3] = mz7 - mz8 + temp_det[3];
                end
                15:begin    
                    ma5 = matrix[1]; mb5 = matrix[6];    ma6 = matrix[2]; mb6 = matrix[5];     
                    ma7 = matrix[11];mb7 = mz5;          ma8 = matrix[11];mb8 = mz6;
                    /*out_nxt[50:0]
                    out_nxt[101:51]
                    out_nxt[152:102]*/

                    temp_det_nxt[3] = mz7 - mz8 + temp_det[3];
                    out_nxt = 0;
                end
                16:begin
                    ma2 = matrix[12]; mb2 = temp_det[3];
                    ma4 = matrix[13]; mb4 = temp_det[2];
                    ma7 = matrix[14]; mb7 = temp_det[1];
                    ma8 = matrix[15]; mb8 = temp_det[0];

                    add1 = mz2 + mz7;
                    add2 = mz4 + mz8;
                    out_nxt = add2-add1;
                end
                //default: 
            endcase
        end
     
    endcase
end
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
    if(cnt == 17) out_data = out_ff;
    else          out_data = 0;
end
always @(*) begin
    if(cnt == 17) out_valid = 1;
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
generate
    for(i=0;i<4;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                temp_det[i] <= 0;
            else 
                temp_det[i] <= temp_det_nxt[i];
        end
    end
endgenerate
endmodule