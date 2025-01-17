module TMIP(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    
    image,
    template,
    image_size,
	action,
	
    // output signals
    out_valid,
    out_value
    );

input            clk, rst_n;
input            in_valid, in_valid2;

input      [7:0] image;
input      [7:0] template;
input      [1:0] image_size;
input      [2:0] action;

output reg       out_valid;
output reg       out_value;

//==================================================================
//    SRAM
//==================================================================
reg [6:0] addr_1;
reg [5:0] addr_2;
reg signed [7:0] r1_data [0:7] ;
reg signed [7:0] w1_data [0:7] ;

reg W_R_1;
reg W_R_2;

SUMA180_128X64X1BM1 mem1 (.A0(addr_1[0]),.A1(addr_1[1]),.A2(addr_1[2]),.A3(addr_1[3]),.A4(addr_1[4]),.A5(addr_1[5]),.A6(addr_1[6]),

.DO0(r1_data[0][0]),.DO1(r1_data[0][1]),.DO2(r1_data[0][2]),.DO3(r1_data[0][3]),.DO4(r1_data[0][4]),.DO5(r1_data[0][5]),.DO6(r1_data[0][6]),.DO7(r1_data[0][7]),
.DO8(r1_data[1][0]),.DO9(r1_data[1][1]),.DO10(r1_data[1][2]),.DO11(r1_data[1][3]),.DO12(r1_data[1][4]),.DO13(r1_data[1][5]),.DO14(r1_data[1][6]),.DO15(r1_data[1][7]),
.DO16(r1_data[2][0]),.DO17(r1_data[2][1]),.DO18(r1_data[2][2]),.DO19(r1_data[2][3]),.DO20(r1_data[2][4]),.DO21(r1_data[2][5]),.DO22(r1_data[2][6]),.DO23(r1_data[2][7]),
.DO24(r1_data[3][0]),.DO25(r1_data[3][1]),.DO26(r1_data[3][2]),.DO27(r1_data[3][3]),.DO28(r1_data[3][4]),.DO29(r1_data[3][5]),.DO30(r1_data[3][6]),.DO31(r1_data[3][7]),
.DO32(r1_data[4][0]),.DO33(r1_data[4][1]),.DO34(r1_data[4][2]),.DO35(r1_data[4][3]),.DO36(r1_data[4][4]),.DO37(r1_data[4][5]),.DO38(r1_data[4][6]),.DO39(r1_data[4][7]),
.DO40(r1_data[5][0]),.DO41(r1_data[5][1]),.DO42(r1_data[5][2]),.DO43(r1_data[5][3]),.DO44(r1_data[5][4]),.DO45(r1_data[5][5]),.DO46(r1_data[5][6]),.DO47(r1_data[5][7]),
.DO48(r1_data[6][0]),.DO49(r1_data[6][1]),.DO50(r1_data[6][2]),.DO51(r1_data[6][3]),.DO52(r1_data[6][4]),.DO53(r1_data[6][5]),.DO54(r1_data[6][6]),.DO55(r1_data[6][7]),
.DO56(r1_data[7][0]),.DO57(r1_data[7][1]),.DO58(r1_data[7][2]),.DO59(r1_data[7][3]),.DO60(r1_data[7][4]),.DO61(r1_data[7][5]),.DO62(r1_data[7][6]),.DO63(r1_data[7][7]),
.DI0(w1_data[0][0]),.DI1(w1_data[0][1]),.DI2(w1_data[0][2]),.DI3(w1_data[0][3]),.DI4(w1_data[0][4]),.DI5(w1_data[0][5]),.DI6(w1_data[0][6]),.DI7(w1_data[0][7]),
.DI8(w1_data[1][0]),.DI9(w1_data[1][1]),.DI10(w1_data[1][2]),.DI11(w1_data[1][3]),.DI12(w1_data[1][4]),.DI13(w1_data[1][5]),.DI14(w1_data[1][6]),.DI15(w1_data[1][7]),
.DI16(w1_data[2][0]),.DI17(w1_data[2][1]),.DI18(w1_data[2][2]),.DI19(w1_data[2][3]),.DI20(w1_data[2][4]),.DI21(w1_data[2][5]),.DI22(w1_data[2][6]),.DI23(w1_data[2][7]),
.DI24(w1_data[3][0]),.DI25(w1_data[3][1]),.DI26(w1_data[3][2]),.DI27(w1_data[3][3]),.DI28(w1_data[3][4]),.DI29(w1_data[3][5]),.DI30(w1_data[3][6]),.DI31(w1_data[3][7]),
.DI32(w1_data[4][0]),.DI33(w1_data[4][1]),.DI34(w1_data[4][2]),.DI35(w1_data[4][3]),.DI36(w1_data[4][4]),.DI37(w1_data[4][5]),.DI38(w1_data[4][6]),.DI39(w1_data[4][7]),
.DI40(w1_data[5][0]),.DI41(w1_data[5][1]),.DI42(w1_data[5][2]),.DI43(w1_data[5][3]),.DI44(w1_data[5][4]),.DI45(w1_data[5][5]),.DI46(w1_data[5][6]),.DI47(w1_data[5][7]),
.DI48(w1_data[6][0]),.DI49(w1_data[6][1]),.DI50(w1_data[6][2]),.DI51(w1_data[6][3]),.DI52(w1_data[6][4]),.DI53(w1_data[6][5]),.DI54(w1_data[6][6]),.DI55(w1_data[6][7]),
.DI56(w1_data[7][0]),.DI57(w1_data[7][1]),.DI58(w1_data[7][2]),.DI59(w1_data[7][3]),.DI60(w1_data[7][4]),.DI61(w1_data[7][5]),.DI62(w1_data[7][6]),.DI63(w1_data[7][7]),

.CK(clk),.WEB(W_R_1),.OE(1'd1), .CS(1'd1));

//==================================================================
// parameter & integer
//==================================================================
parameter CS_IDLE        =  'd0;
parameter CS_GRSCALE     =  'd1;
parameter CS_WAIT_ACT    =  'd2;
parameter CS_MAX16       =  'd3;
parameter CS_MAX8        =  'd4;
parameter CS_MAX4        =  'd5;
parameter CS_READ_GRAY16 =  'd6;
parameter CS_READ_GRAY8  =  'd7;
parameter CS_READ_GRAY4  =  'd8;
parameter CS_IM_FILTER16 =  'd9;
parameter CS_IM_FILTER8  =  'd10;
parameter CS_IM_FILTER4  =  'd11;
parameter CS_NEG         =  'd12;
parameter CS_CON16       =  'd13;
parameter CS_CON8        =  'd14;
parameter CS_CON4        =  'd15;
parameter CS_FLIP16      =  'd16;
parameter CS_FLIP8       =  'd17;
parameter CS_FLIP4       =  'd18;
integer y,q;

//==================================================================
// reg & wire
//==================================================================
reg Flip_flag;
reg [2:0]action_reg;
reg [3:0]action_num,action_num_nxt;
reg [1:0]gray_mode_reg,gray_mode_nxt;
reg [20:0]action_store,action_store_nxt;
reg [4:0]cur_state,nxt_state;
reg [1:0]img_size_key,img_size_key_nxt;
reg [1:0]cur_img_size_key,cur_img_size_key_nxt;

reg [7:0]Img_ff[0:15][0:15],Img_ff_nxt[0:15][0:15];


reg out_valid_nxt;
reg [19:0]out_value_nxt;
reg [7:0]RGB_ff[0:2],RGB_ff_nxt[0:2];
reg in_valid_reg;
reg in_valid_reg_reg;
reg in_valid2_reg;
reg out_valid_reg;
reg [6:0]AC0_start_addr;
reg [6:0]AC1_start_addr;
reg [6:0]AC2_start_addr;
reg [7:0]gray_ff[0:2][0:7],gray_ff_nxt[0:2][0:7];
reg [7:0]sort_in_ff[0:8],sort_in_nxt[0:8],sort_out[0:8];
reg [7:0]sort_layer1[0:8];
reg [7:0]sort_layer2[0:8];
reg [7:0]sort_layer3[0:8];
reg [7:0]sort_layer4[0:8];
reg [7:0]sort_layer5[0:8];
reg [7:0]sort_layer6[0:8];
reg [7:0]sort_layer7[0:8];
reg [7:0]sort_layer8[0:8];
reg [7:0]sort_layer9[0:8];
reg [7:0]sort_layer10[0:8];
reg [7:0]sort_layer11[0:8];
reg [7:0]sort_layer12[0:8];
reg [7:0]sort_ff[0:8],sort_nxt[0:8];
reg [7:0]Fliter_ff[0:14],Fliter_ff_nxt[0:14];

reg [1:0]cnt_3,cnt_3_nxt;
reg [5:0]cnt,cnt_nxt;
reg [3:0]cnt_8,cnt_8_nxt;
reg [4:0]out_cnt,out_cnt_nxt;
reg [4:0]row,row_nxt;
reg [3:0]tmplt_cnt;
reg [3:0]row_Filter,row_Filter_nxt;
reg [1:0]row_3,row_3_nxt;
reg [8:0]out_times,out_times_nxt;

reg [19:0]conv_ff,conv_nxt;
reg [19:0]out_ff,out_nxt;

reg [7:0]tmplt_reg[0:8],tmplt_nxt[0:8];

assign AC0_start_addr  = 'd32;
assign AC1_start_addr  = 'd64;
assign AC2_start_addr  = 'd96;
assign COM1_start_addr = 0;
assign COM2_start_addr = 0;

reg [7:0]cmp_a[0:7][0:3], cmp_b[0:7][0:3], cmp_z[0:7][0:3];
reg [7:0]cmp_a2[0:3][0:3],cmp_b2[0:3][0:3],cmp_z2[0:3][0:3];
reg [7:0]ma,mb;
reg [15:0]mz;
//==================================================================
//                   design
//==================================================================
/**  I/O  **/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_valid_reg <= 0;
        in_valid_reg_reg <= 0;
        in_valid2_reg <= 0;
        action_reg <=0;
        out_valid_reg<=0;
    end
    else begin
        in_valid_reg <= in_valid;
        in_valid_reg_reg <= in_valid_reg;
        in_valid2_reg <= in_valid2;
        action_reg <= action;
        out_valid_reg<=out_valid;
    end
end
//==============================================//
//                      FSM
//==============================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= CS_IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always @(*) begin
    nxt_state = cur_state;
    case (cur_state)
        CS_IDLE: begin
            if(in_valid) nxt_state = CS_GRSCALE;
            else         nxt_state = cur_state;
        end
        CS_GRSCALE:begin
            if(in_valid) nxt_state = cur_state;
            else         nxt_state = CS_WAIT_ACT;
        end
        CS_WAIT_ACT:begin
            if(in_valid2)begin
                case (img_size_key)
                    0: nxt_state = CS_READ_GRAY4;
                    1: nxt_state = CS_READ_GRAY8;
                    2: nxt_state = CS_READ_GRAY16;
                    default: nxt_state = cur_state;
                endcase
            end
           else begin
                if(out_valid_reg && !out_valid && action_num==8) nxt_state = CS_IDLE;
                else                                             nxt_state = cur_state;
           end
           
        end
        CS_READ_GRAY16:begin
            if(cnt == 32)begin
                case (action_store[20:18])
                    3: nxt_state = CS_MAX16;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER16;
                    7: nxt_state = Flip_flag ? CS_FLIP16 : CS_CON16;
                    default: nxt_state = cur_state;
                endcase
            end
        end
        CS_READ_GRAY8:begin
            if(cnt == 8)begin
                case (action_store[20:18])
                    3: nxt_state = CS_MAX8;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER8;
                    7: nxt_state = Flip_flag ? CS_FLIP8 : CS_CON8;
                    default: nxt_state = cur_state;
                endcase
            end
        end
        CS_READ_GRAY4:begin
            if(in_valid2_reg == 0)begin
                case (action_store[20:18])
                    3: nxt_state = CS_MAX4;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER4;
                    7: nxt_state = Flip_flag ? CS_FLIP4 : CS_CON4;
                    default: nxt_state = cur_state;
                endcase
            end
        end
        CS_MAX16:begin
            if(cnt == 3)begin
                case (action_store[20:18])
                    3: nxt_state = CS_MAX8;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER8;
                    7: nxt_state = Flip_flag ? CS_FLIP8 : CS_CON8;
                    default: nxt_state = cur_state;
                endcase
            end
            
        end
        CS_MAX8:begin
            case (action_store[20:18])
                3: nxt_state = CS_MAX4;
                4: nxt_state = CS_NEG;
                6: nxt_state = CS_IM_FILTER4;
                7: nxt_state = Flip_flag ? CS_FLIP4 : CS_CON4;
                default: nxt_state = cur_state;
            endcase
        end
        CS_MAX4:begin
            case (action_store[20:18])
                3: nxt_state = CS_MAX4;
                4: nxt_state = CS_NEG;
                6: nxt_state = CS_IM_FILTER4;
                7: nxt_state = Flip_flag ? CS_FLIP4 : CS_CON4;
                default: nxt_state = cur_state;
            endcase
        end
        CS_IM_FILTER16:begin
            if(row_Filter==15 && cnt_8 == 1)begin
                case (action_store[20:18]) 
                    3: nxt_state = CS_MAX16;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER16;
                    7: nxt_state = Flip_flag ? CS_FLIP16 : CS_CON16;
                    default: nxt_state = cur_state;
                endcase
            end
        end
        CS_IM_FILTER8:begin
            if(row_Filter==7 && cnt_8 == 1)begin
                case (action_store[20:18]) 
                    3: nxt_state = CS_MAX8;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER8;
                    7: nxt_state = Flip_flag ? CS_FLIP8 : CS_CON8;
                    default: nxt_state = cur_state;
                endcase
            end
        end
        CS_IM_FILTER4:begin
            if(row_Filter==3 && cnt_8 == 1)begin
                case (action_store[20:18]) 
                    3: nxt_state = CS_MAX4;
                    4: nxt_state = CS_NEG;
                    6: nxt_state = CS_IM_FILTER4;
                    7: nxt_state = Flip_flag ? CS_FLIP4 :CS_CON4;
                    default: nxt_state = cur_state;
                endcase
            end
        end
        CS_FLIP16: nxt_state = CS_CON16;
        CS_FLIP8 : nxt_state = CS_CON8;
        CS_FLIP4 : nxt_state = CS_CON4;
        CS_CON16:begin
            if(out_times == 256 && out_cnt == 19) nxt_state = CS_WAIT_ACT;
            else                                  nxt_state = cur_state;
        end
        CS_CON8:begin
            if(out_times == 64 && out_cnt == 19) nxt_state = CS_WAIT_ACT;
            else                                 nxt_state = cur_state;
        end
        CS_CON4:begin
            if(out_times == 16 && out_cnt == 19) nxt_state = CS_WAIT_ACT;
            else                                 nxt_state = cur_state;
        end
        CS_NEG:begin
            case (cur_img_size_key)
                0: begin
                    case (action_store[20:18]) 
                        3: nxt_state = CS_MAX4;
                        4: nxt_state = CS_NEG;
                        6: nxt_state = CS_IM_FILTER4;
                        7: nxt_state = Flip_flag ? CS_FLIP4 :CS_CON4;
                        default: nxt_state = cur_state;
                    endcase
                end
                1: begin
                    case (action_store[20:18]) 
                        3: nxt_state = CS_MAX8;
                        4: nxt_state = CS_NEG;
                        6: nxt_state = CS_IM_FILTER8;
                        7: nxt_state = Flip_flag ? CS_FLIP8 :CS_CON8;
                        default: nxt_state = cur_state;
                    endcase
                end
                2: 
                begin
                    case (action_store[20:18]) 
                        3: nxt_state = CS_MAX16;
                        4: nxt_state = CS_NEG;
                        6: nxt_state = CS_IM_FILTER16;
                        7: nxt_state = Flip_flag ? CS_FLIP16 :CS_CON16;
                        default: nxt_state = cur_state;
                    endcase
                end
                
                default: nxt_state = cur_state;
            endcase
            
        end
        default: nxt_state = cur_state;
    endcase
end
//==============================================//
//                      KEY
//==============================================//
assign img_size_key_nxt = (in_valid && !in_valid_reg) ? image_size : img_size_key;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_size_key <= 0;
        cur_img_size_key <= 0;
    end
    else begin
        img_size_key <= img_size_key_nxt;
        cur_img_size_key <= cur_img_size_key_nxt;
    end
end
always @(*) begin
    case (cur_state)
        CS_IDLE: cur_img_size_key_nxt = img_size_key;
        CS_READ_GRAY16,CS_READ_GRAY8,CS_READ_GRAY4:cur_img_size_key_nxt = img_size_key;
        CS_MAX16: cur_img_size_key_nxt = 1;
        CS_MAX8: cur_img_size_key_nxt = 0;
        default: cur_img_size_key_nxt = cur_img_size_key;
    endcase
end
//==============================================//
//                    GrayScale
//==============================================//
always @(*) begin
    case (cur_state)
        CS_IDLE:begin
            if(in_valid) begin RGB_ff_nxt[0] = image;RGB_ff_nxt[1] = 0;RGB_ff_nxt[2] = 0;end
            else         begin RGB_ff_nxt[0] = 0;    RGB_ff_nxt[1] = 0;RGB_ff_nxt[2] = 0;end
        end 
        CS_GRSCALE:begin
            RGB_ff_nxt[0] = image;  RGB_ff_nxt[1] = RGB_ff[0];RGB_ff_nxt[2] = RGB_ff[1];
        end
        default: begin RGB_ff_nxt[0] = RGB_ff[0];RGB_ff_nxt[1] = RGB_ff[1];RGB_ff_nxt[2] = RGB_ff[2];end
    endcase
end
always @(*) begin
    gray_ff_nxt = gray_ff;
    case (cur_state)
        CS_GRSCALE: begin
            if(cnt_3 == 3)begin
                gray_ff_nxt[0][cnt] = (RGB_ff_nxt[0]>RGB_ff_nxt[1]) ? (RGB_ff_nxt[0] > RGB_ff_nxt[2] ? RGB_ff_nxt[0] : RGB_ff_nxt[2]) : (RGB_ff_nxt[1] > RGB_ff_nxt[2] ? RGB_ff_nxt[1] : RGB_ff_nxt[2]);
                gray_ff_nxt[1][cnt] = (RGB_ff_nxt[0]+RGB_ff_nxt[1]+RGB_ff_nxt[2]) >= 511 ? ((RGB_ff_nxt[0]+RGB_ff_nxt[1]+RGB_ff_nxt[2] -1 )*171) >> 9 : ((RGB_ff_nxt[0]+RGB_ff_nxt[1]+RGB_ff_nxt[2])*171) >> 9;
                gray_ff_nxt[2][cnt] = (RGB_ff_nxt[0]>>2)+(RGB_ff_nxt[1]>>1)+(RGB_ff_nxt[2]>>2);
            end
        end
    endcase
end
//==============================================//
//              IMG_FF CONTROL
//==============================================//
always @(*) begin
    Img_ff_nxt = Img_ff;
    case (cur_state)
        CS_READ_GRAY16:begin
            if(cnt[0]==1)begin
                Img_ff_nxt[(cnt-1)>>1][0] = r1_data[0];
                Img_ff_nxt[(cnt-1)>>1][1] = r1_data[1];
                Img_ff_nxt[(cnt-1)>>1][2] = r1_data[2];
                Img_ff_nxt[(cnt-1)>>1][3] = r1_data[3];
                Img_ff_nxt[(cnt-1)>>1][4] = r1_data[4];
                Img_ff_nxt[(cnt-1)>>1][5] = r1_data[5];
                Img_ff_nxt[(cnt-1)>>1][6] = r1_data[6];
                Img_ff_nxt[(cnt-1)>>1][7] = r1_data[7];
            end
            else begin
                Img_ff_nxt[(cnt-1)>>1][8]  = r1_data[0];
                Img_ff_nxt[(cnt-1)>>1][9]  = r1_data[1];
                Img_ff_nxt[(cnt-1)>>1][10] = r1_data[2];
                Img_ff_nxt[(cnt-1)>>1][11] = r1_data[3];
                Img_ff_nxt[(cnt-1)>>1][12] = r1_data[4];
                Img_ff_nxt[(cnt-1)>>1][13] = r1_data[5];
                Img_ff_nxt[(cnt-1)>>1][14] = r1_data[6];
                Img_ff_nxt[(cnt-1)>>1][15] = r1_data[7];
            end
        end 
        CS_READ_GRAY8:begin
            Img_ff_nxt[cnt-1][0] = r1_data[0];
            Img_ff_nxt[cnt-1][1] = r1_data[1];
            Img_ff_nxt[cnt-1][2] = r1_data[2];
            Img_ff_nxt[cnt-1][3] = r1_data[3];
            Img_ff_nxt[cnt-1][4] = r1_data[4];
            Img_ff_nxt[cnt-1][5] = r1_data[5];
            Img_ff_nxt[cnt-1][6] = r1_data[6];
            Img_ff_nxt[cnt-1][7] = r1_data[7];
        end 
        CS_READ_GRAY4:begin
            if(cnt==1)begin
                Img_ff_nxt[0][0] = r1_data[0];
                Img_ff_nxt[0][1] = r1_data[1];
                Img_ff_nxt[0][2] = r1_data[2];
                Img_ff_nxt[0][3] = r1_data[3];

                Img_ff_nxt[1][0] = r1_data[4];
                Img_ff_nxt[1][1] = r1_data[5];
                Img_ff_nxt[1][2] = r1_data[6];
                Img_ff_nxt[1][3] = r1_data[7];
            end
            else if(cnt==2) begin
                Img_ff_nxt[2][0] = r1_data[0];
                Img_ff_nxt[2][1] = r1_data[1];
                Img_ff_nxt[2][2] = r1_data[2];
                Img_ff_nxt[2][3] = r1_data[3];

                Img_ff_nxt[3][0] = r1_data[4];
                Img_ff_nxt[3][1] = r1_data[5];
                Img_ff_nxt[3][2] = r1_data[6];
                Img_ff_nxt[3][3] = r1_data[7];
            end

            
        end 
        CS_MAX16:begin
            case (cnt)
                0: begin
                    Img_ff_nxt[0][0] = cmp_z2[0][0]; Img_ff_nxt[0][1] = cmp_z2[0][1]; Img_ff_nxt[0][2] = cmp_z2[0][2]; Img_ff_nxt[0][3] = cmp_z2[0][3];
                    Img_ff_nxt[1][0] = cmp_z2[1][0]; Img_ff_nxt[1][1] = cmp_z2[1][1]; Img_ff_nxt[1][2] = cmp_z2[1][2]; Img_ff_nxt[1][3] = cmp_z2[1][3];
                    Img_ff_nxt[2][0] = cmp_z2[2][0]; Img_ff_nxt[2][1] = cmp_z2[2][1]; Img_ff_nxt[2][2] = cmp_z2[2][2]; Img_ff_nxt[2][3] = cmp_z2[2][3];
                    Img_ff_nxt[3][0] = cmp_z2[3][0]; Img_ff_nxt[3][1] = cmp_z2[3][1]; Img_ff_nxt[3][2] = cmp_z2[3][2]; Img_ff_nxt[3][3] = cmp_z2[3][3];
                end
                1: begin
                    Img_ff_nxt[0][4] = cmp_z2[0][0]; Img_ff_nxt[0][5] = cmp_z2[0][1]; Img_ff_nxt[0][6] = cmp_z2[0][2]; Img_ff_nxt[0][7] = cmp_z2[0][3];
                    Img_ff_nxt[1][4] = cmp_z2[1][0]; Img_ff_nxt[1][5] = cmp_z2[1][1]; Img_ff_nxt[1][6] = cmp_z2[1][2]; Img_ff_nxt[1][7] = cmp_z2[1][3];
                    Img_ff_nxt[2][4] = cmp_z2[2][0]; Img_ff_nxt[2][5] = cmp_z2[2][1]; Img_ff_nxt[2][6] = cmp_z2[2][2]; Img_ff_nxt[2][7] = cmp_z2[2][3];
                    Img_ff_nxt[3][4] = cmp_z2[3][0]; Img_ff_nxt[3][5] = cmp_z2[3][1]; Img_ff_nxt[3][6] = cmp_z2[3][2]; Img_ff_nxt[3][7] = cmp_z2[3][3];
                end
                2: begin
                    Img_ff_nxt[4][0] = cmp_z2[0][0]; Img_ff_nxt[4][1] = cmp_z2[0][1]; Img_ff_nxt[4][2] = cmp_z2[0][2]; Img_ff_nxt[4][3] = cmp_z2[0][3];
                    Img_ff_nxt[5][0] = cmp_z2[1][0]; Img_ff_nxt[5][1] = cmp_z2[1][1]; Img_ff_nxt[5][2] = cmp_z2[1][2]; Img_ff_nxt[5][3] = cmp_z2[1][3];
                    Img_ff_nxt[6][0] = cmp_z2[2][0]; Img_ff_nxt[6][1] = cmp_z2[2][1]; Img_ff_nxt[6][2] = cmp_z2[2][2]; Img_ff_nxt[6][3] = cmp_z2[2][3];
                    Img_ff_nxt[7][0] = cmp_z2[3][0]; Img_ff_nxt[7][1] = cmp_z2[3][1]; Img_ff_nxt[7][2] = cmp_z2[3][2]; Img_ff_nxt[7][3] = cmp_z2[3][3];
                end
                3: begin
                    Img_ff_nxt[4][4] = cmp_z2[0][0]; Img_ff_nxt[4][5] = cmp_z2[0][1]; Img_ff_nxt[4][6] = cmp_z2[0][2]; Img_ff_nxt[4][7] = cmp_z2[0][3];
                    Img_ff_nxt[5][4] = cmp_z2[1][0]; Img_ff_nxt[5][5] = cmp_z2[1][1]; Img_ff_nxt[5][6] = cmp_z2[1][2]; Img_ff_nxt[5][7] = cmp_z2[1][3];
                    Img_ff_nxt[6][4] = cmp_z2[2][0]; Img_ff_nxt[6][5] = cmp_z2[2][1]; Img_ff_nxt[6][6] = cmp_z2[2][2]; Img_ff_nxt[6][7] = cmp_z2[2][3];
                    Img_ff_nxt[7][4] = cmp_z2[3][0]; Img_ff_nxt[7][5] = cmp_z2[3][1]; Img_ff_nxt[7][6] = cmp_z2[3][2]; Img_ff_nxt[7][7] = cmp_z2[3][3];
                end
                
            endcase
        end
        CS_MAX8:begin
            Img_ff_nxt[0][0] = cmp_z2[0][0]; Img_ff_nxt[0][1] = cmp_z2[0][1]; Img_ff_nxt[0][2] = cmp_z2[0][2]; Img_ff_nxt[0][3] = cmp_z2[0][3];
            Img_ff_nxt[1][0] = cmp_z2[1][0]; Img_ff_nxt[1][1] = cmp_z2[1][1]; Img_ff_nxt[1][2] = cmp_z2[1][2]; Img_ff_nxt[1][3] = cmp_z2[1][3];
            Img_ff_nxt[2][0] = cmp_z2[2][0]; Img_ff_nxt[2][1] = cmp_z2[2][1]; Img_ff_nxt[2][2] = cmp_z2[2][2]; Img_ff_nxt[2][3] = cmp_z2[2][3];
            Img_ff_nxt[3][0] = cmp_z2[3][0]; Img_ff_nxt[3][1] = cmp_z2[3][1]; Img_ff_nxt[3][2] = cmp_z2[3][2]; Img_ff_nxt[3][3] = cmp_z2[3][3];

        end
        CS_IM_FILTER16:begin
            if(row_Filter == 15 && cnt_8 == 1)begin
                
                Img_ff_nxt[15][1 ] = Fliter_ff[0 ];
                Img_ff_nxt[15][2 ] = Fliter_ff[1 ];
                Img_ff_nxt[15][3 ] = Fliter_ff[2 ];
                Img_ff_nxt[15][4 ] = Fliter_ff[3 ];
                Img_ff_nxt[15][5 ] = Fliter_ff[4 ];
                Img_ff_nxt[15][6 ] = Fliter_ff[5 ];
                Img_ff_nxt[15][7 ] = Fliter_ff[6 ];
                Img_ff_nxt[15][8 ] = Fliter_ff[7 ];
                Img_ff_nxt[15][9 ] = Fliter_ff[8 ];
                Img_ff_nxt[15][10] = Fliter_ff[9 ];
                Img_ff_nxt[15][11] = Fliter_ff[10];
                Img_ff_nxt[15][12] = Fliter_ff[11];
                Img_ff_nxt[15][13] = Fliter_ff[12];
                Img_ff_nxt[15][14] = Fliter_ff[13];
                Img_ff_nxt[15][15] = Fliter_ff[14];
            end
            else if(row >= 2 || (row == 1 && cnt > 0))Img_ff_nxt[row_Filter][cnt_8] = Fliter_ff[0];
            
        end
        CS_IM_FILTER8:begin
            if(row_Filter == 7 && cnt_8 == 1)begin
                Img_ff_nxt[7][0] = Fliter_ff[7];
                Img_ff_nxt[7][1] = Fliter_ff[8];
                Img_ff_nxt[7][2] = Fliter_ff[9];
                Img_ff_nxt[7][3] = Fliter_ff[10];
                Img_ff_nxt[7][4] = Fliter_ff[11];
                Img_ff_nxt[7][5] = Fliter_ff[12];
                Img_ff_nxt[7][6] = Fliter_ff[13];
                Img_ff_nxt[7][7] = Fliter_ff[14];
            end
            else if(row >= 2 || (row == 1 && cnt > 0))Img_ff_nxt[row_Filter][cnt_8] = Fliter_ff[8];
            
        end
        CS_IM_FILTER4:begin
            if(row_Filter == 3 && cnt_8 == 1)begin
                Img_ff_nxt[3][0] = Fliter_ff[11];
                Img_ff_nxt[3][1] = Fliter_ff[12];
                Img_ff_nxt[3][2] = Fliter_ff[13];
                Img_ff_nxt[3][3] = Fliter_ff[14];

            end
            else if(row >= 2 || (row == 1 && cnt > 0))Img_ff_nxt[row_Filter][cnt_8] = Fliter_ff[12];
        end
        CS_NEG:begin
            for(y = 0; y<16;y+=1)begin
                for(q=0;q<16;q+=1)begin
                    Img_ff_nxt [y][q]= ~Img_ff[y][q];
                end
            end 
        end
        CS_FLIP16:begin
            for(y = 0; y<16;y+=1)begin
                for(q=0;q<16;q+=1)begin
                    Img_ff_nxt [y][q]= Img_ff[y][15-q];
                end
            end 
        end
        CS_FLIP8:begin
            for(y = 0; y<16;y+=1)begin
                for(q=0;q<8;q+=1)begin
                    Img_ff_nxt [y][q]= Img_ff[y][7-q];
                end
            end 
        end
        CS_FLIP4:begin
            for(y = 0; y<16;y+=1)begin
                for(q=0;q<4;q+=1)begin
                    Img_ff_nxt [y][q]= Img_ff[y][3-q];
                end
            end 
        end
    endcase
end
//==============================================//
//                SRAM CONTROL                  //
//==============================================//
always @(*) begin
    addr_1 = 0;
    case (cur_state)
        CS_GRSCALE:begin
            case (cnt_3)
                1: addr_1 = AC0_start_addr + row ;
                2: addr_1 = AC1_start_addr + row ;
                3: addr_1 = AC2_start_addr + row ;
                //default: 
            endcase
        end 
        CS_WAIT_ACT:begin
            case (img_size_key)
                0: begin
                    case (cnt_3)
                        1: addr_1 = AC0_start_addr + 1;
                        2: addr_1 = AC1_start_addr + 1;
                        3: addr_1 = AC2_start_addr + 1;
                        //default: 
                    endcase
                end
                1: begin
                    case (cnt_3)
                        1: addr_1 = AC0_start_addr + 7;
                        2: addr_1 = AC1_start_addr + 7;
                        3: addr_1 = AC2_start_addr + 7;
                        //default: 
                    endcase
                end
                2: begin
                    case (cnt_3)
                        1: addr_1 = AC0_start_addr + 31;
                        2: addr_1 = AC1_start_addr + 31;
                        3: addr_1 = AC2_start_addr + 31;
                            //default: 
                    endcase
                    
                end
                
            endcase
        
        end
        CS_READ_GRAY16,CS_READ_GRAY8,CS_READ_GRAY4:begin
            case (gray_mode_reg)
                0: addr_1 = AC0_start_addr + cnt ;
                1: addr_1 = AC1_start_addr + cnt ;
                2: addr_1 = AC2_start_addr + cnt ;
                //default: 
            endcase
        end
        default :addr_1 = 0;
    endcase
end
always @(*) begin
    case (cur_state)
        CS_GRSCALE: W_R_1 = 0;
        CS_WAIT_ACT: W_R_1 = (cnt_3 == 2|| cnt_3 == 3) ? 0:  1;
        CS_READ_GRAY16,CS_READ_GRAY8,CS_READ_GRAY4: W_R_1 = 1;
        default: W_R_1 = 1; 
    endcase
end
always @(*) begin
    case (cur_state)
        CS_GRSCALE:begin
            w1_data[0] = gray_ff[cnt_3-1][0];
            w1_data[1] = gray_ff[cnt_3-1][1];
            w1_data[2] = gray_ff[cnt_3-1][2];
            w1_data[3] = gray_ff[cnt_3-1][3];
            w1_data[4] = gray_ff[cnt_3-1][4];
            w1_data[5] = gray_ff[cnt_3-1][5];
            w1_data[6] = gray_ff[cnt_3-1][6];
            w1_data[7] = gray_ff[cnt_3-1][7];
        end 
        CS_WAIT_ACT:begin
            w1_data[0] = gray_ff[cnt_3-1][0];
            w1_data[1] = gray_ff[cnt_3-1][1];
            w1_data[2] = gray_ff[cnt_3-1][2];
            w1_data[3] = gray_ff[cnt_3-1][3];
            w1_data[4] = gray_ff[cnt_3-1][4];
            w1_data[5] = gray_ff[cnt_3-1][5];
            w1_data[6] = gray_ff[cnt_3-1][6];
            w1_data[7] = gray_ff[cnt_3-1][7];
        end
        default: begin
            w1_data[0] = 0;
            w1_data[1] = 0;
            w1_data[2] = 0;
            w1_data[3] = 0;
            w1_data[4] = 0;
            w1_data[5] = 0;
            w1_data[6] = 0;
            w1_data[7] = 0;
        end
    endcase
    
end
//==============================================//
//                 IM_FLITER
//==============================================//
always @(*) begin
    sort_in_nxt [0] = 0; sort_in_nxt [1] = 0; sort_in_nxt [2] = 0;
    sort_in_nxt [3] = 0; sort_in_nxt [4] = 0; sort_in_nxt [5] = 0;
    sort_in_nxt [6] = 0; sort_in_nxt [7] = 0; sort_in_nxt [8] = 0;
    case (cur_state)
        CS_IM_FILTER16:begin
            case (row)
                0: begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[0][0]; sort_in_nxt [1] = Img_ff[0][0]; sort_in_nxt [2] = Img_ff[0][1];
                            sort_in_nxt [3] = Img_ff[0][0]; sort_in_nxt [4] = Img_ff[0][0]; sort_in_nxt [5] = Img_ff[0][1];
                            sort_in_nxt [6] = Img_ff[1][0]; sort_in_nxt [7] = Img_ff[1][0]; sort_in_nxt [8] = Img_ff[1][1];
                        end
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
                            sort_in_nxt [0] = Img_ff[0][cnt-1]; sort_in_nxt [1] = Img_ff[0][cnt]; sort_in_nxt [2] = Img_ff[0][cnt+1];
                            sort_in_nxt [3] = Img_ff[0][cnt-1]; sort_in_nxt [4] = Img_ff[0][cnt]; sort_in_nxt [5] = Img_ff[0][cnt+1];
                            sort_in_nxt [6] = Img_ff[1][cnt-1]; sort_in_nxt [7] = Img_ff[1][cnt]; sort_in_nxt [8] = Img_ff[1][cnt+1];
                        end
                        15: begin
                            sort_in_nxt [0] = Img_ff[0][14]; sort_in_nxt [1] = Img_ff[0][15]; sort_in_nxt [2] = Img_ff[0][15];
                            sort_in_nxt [3] = Img_ff[0][14]; sort_in_nxt [4] = Img_ff[0][15]; sort_in_nxt [5] = Img_ff[0][15];
                            sort_in_nxt [6] = Img_ff[1][14]; sort_in_nxt [7] = Img_ff[1][15]; sort_in_nxt [8] = Img_ff[1][15];
                        end
                    endcase 
                end
                1,2,3,4,5,6,7,8,9,10,11,12,13,14:begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[row-1][0]; sort_in_nxt [1] = Img_ff[row-1][0]; sort_in_nxt [2] = Img_ff[row-1][1];
                            sort_in_nxt [3] = Img_ff[row  ][0]; sort_in_nxt [4] = Img_ff[row  ][0]; sort_in_nxt [5] = Img_ff[row  ][1];
                            sort_in_nxt [6] = Img_ff[row+1][0]; sort_in_nxt [7] = Img_ff[row+1][0]; sort_in_nxt [8] = Img_ff[row+1][1];
                        end
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
                            sort_in_nxt [0] = Img_ff[row-1][cnt-1]; sort_in_nxt [1] = Img_ff[row-1][cnt]; sort_in_nxt [2] = Img_ff[row-1][cnt+1];
                            sort_in_nxt [3] = Img_ff[row  ][cnt-1]; sort_in_nxt [4] = Img_ff[row  ][cnt]; sort_in_nxt [5] = Img_ff[row  ][cnt+1];
                            sort_in_nxt [6] = Img_ff[row+1][cnt-1]; sort_in_nxt [7] = Img_ff[row+1][cnt]; sort_in_nxt [8] = Img_ff[row+1][cnt+1];
                        end
                        15: begin
                            sort_in_nxt [0] = Img_ff[row-1][14]; sort_in_nxt [1] = Img_ff[row-1][15]; sort_in_nxt [2] = Img_ff[row-1][15];
                            sort_in_nxt [3] = Img_ff[row  ][14]; sort_in_nxt [4] = Img_ff[row  ][15]; sort_in_nxt [5] = Img_ff[row  ][15];
                            sort_in_nxt [6] = Img_ff[row+1][14]; sort_in_nxt [7] = Img_ff[row+1][15]; sort_in_nxt [8] = Img_ff[row+1][15];
                        end
                    endcase 
                end
                15:begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[14][0]; sort_in_nxt [1] = Img_ff[14][0]; sort_in_nxt [2] = Img_ff[14][1];
                            sort_in_nxt [3] = Img_ff[15][0]; sort_in_nxt [4] = Img_ff[15][0]; sort_in_nxt [5] = Img_ff[15][1];
                            sort_in_nxt [6] = Img_ff[15][0]; sort_in_nxt [7] = Img_ff[15][0]; sort_in_nxt [8] = Img_ff[15][1];
                        end
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
                            sort_in_nxt [0] = Img_ff[14][cnt-1]; sort_in_nxt [1] = Img_ff[14][cnt]; sort_in_nxt [2] = Img_ff[14][cnt+1];
                            sort_in_nxt [3] = Img_ff[15][cnt-1]; sort_in_nxt [4] = Img_ff[15][cnt]; sort_in_nxt [5] = Img_ff[15][cnt+1];
                            sort_in_nxt [6] = Img_ff[15][cnt-1]; sort_in_nxt [7] = Img_ff[15][cnt]; sort_in_nxt [8] = Img_ff[15][cnt+1];
                        end
                        15: begin
                            sort_in_nxt [0] = Img_ff[14][14]; sort_in_nxt [1] = Img_ff[14][15]; sort_in_nxt [2] = Img_ff[14][15];
                            sort_in_nxt [3] = Img_ff[15][14]; sort_in_nxt [4] = Img_ff[15][15]; sort_in_nxt [5] = Img_ff[15][15];
                            sort_in_nxt [6] = Img_ff[15][14]; sort_in_nxt [7] = Img_ff[15][15]; sort_in_nxt [8] = Img_ff[15][15];
                        end
                    endcase 
                end
               
            endcase
        end 
        CS_IM_FILTER8:begin

            case (row)
                0: begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[0][0]; sort_in_nxt [1] = Img_ff[0][0]; sort_in_nxt [2] = Img_ff[0][1];
                            sort_in_nxt [3] = Img_ff[0][0]; sort_in_nxt [4] = Img_ff[0][0]; sort_in_nxt [5] = Img_ff[0][1];
                            sort_in_nxt [6] = Img_ff[1][0]; sort_in_nxt [7] = Img_ff[1][0]; sort_in_nxt [8] = Img_ff[1][1];
                        end
                        1,2,3,4,5,6: begin
                            sort_in_nxt [0] = Img_ff[0][cnt-1]; sort_in_nxt [1] = Img_ff[0][cnt]; sort_in_nxt [2] = Img_ff[0][cnt+1];
                            sort_in_nxt [3] = Img_ff[0][cnt-1]; sort_in_nxt [4] = Img_ff[0][cnt]; sort_in_nxt [5] = Img_ff[0][cnt+1];
                            sort_in_nxt [6] = Img_ff[1][cnt-1]; sort_in_nxt [7] = Img_ff[1][cnt]; sort_in_nxt [8] = Img_ff[1][cnt+1];
                        end
                        7: begin
                            sort_in_nxt [0] = Img_ff[0][6]; sort_in_nxt [1] = Img_ff[0][7]; sort_in_nxt [2] = Img_ff[0][7];
                            sort_in_nxt [3] = Img_ff[0][6]; sort_in_nxt [4] = Img_ff[0][7]; sort_in_nxt [5] = Img_ff[0][7];
                            sort_in_nxt [6] = Img_ff[1][6]; sort_in_nxt [7] = Img_ff[1][7]; sort_in_nxt [8] = Img_ff[1][7];
                        end
                    endcase 
                end
                1,2,3,4,5,6:begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[row-1][0]; sort_in_nxt [1] = Img_ff[row-1][0]; sort_in_nxt [2] = Img_ff[row-1][1];
                            sort_in_nxt [3] = Img_ff[row  ][0]; sort_in_nxt [4] = Img_ff[row  ][0]; sort_in_nxt [5] = Img_ff[row  ][1];
                            sort_in_nxt [6] = Img_ff[row+1][0]; sort_in_nxt [7] = Img_ff[row+1][0]; sort_in_nxt [8] = Img_ff[row+1][1];
                        end
                        1,2,3,4,5,6: begin
                            sort_in_nxt [0] = Img_ff[row-1][cnt-1]; sort_in_nxt [1] = Img_ff[row-1][cnt]; sort_in_nxt [2] = Img_ff[row-1][cnt+1];
                            sort_in_nxt [3] = Img_ff[row  ][cnt-1]; sort_in_nxt [4] = Img_ff[row  ][cnt]; sort_in_nxt [5] = Img_ff[row  ][cnt+1];
                            sort_in_nxt [6] = Img_ff[row+1][cnt-1]; sort_in_nxt [7] = Img_ff[row+1][cnt]; sort_in_nxt [8] = Img_ff[row+1][cnt+1];
                        end
                        7: begin
                            sort_in_nxt [0] = Img_ff[row-1][6]; sort_in_nxt [1] = Img_ff[row-1][7]; sort_in_nxt [2] = Img_ff[row-1][7];
                            sort_in_nxt [3] = Img_ff[row  ][6]; sort_in_nxt [4] = Img_ff[row  ][7]; sort_in_nxt [5] = Img_ff[row  ][7];
                            sort_in_nxt [6] = Img_ff[row+1][6]; sort_in_nxt [7] = Img_ff[row+1][7]; sort_in_nxt [8] = Img_ff[row+1][7];
                        end
                    endcase 
                end
                7:begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[6][0]; sort_in_nxt [1] = Img_ff[6][0]; sort_in_nxt [2] = Img_ff[6][1];
                            sort_in_nxt [3] = Img_ff[7][0]; sort_in_nxt [4] = Img_ff[7][0]; sort_in_nxt [5] = Img_ff[7][1];
                            sort_in_nxt [6] = Img_ff[7][0]; sort_in_nxt [7] = Img_ff[7][0]; sort_in_nxt [8] = Img_ff[7][1];
                        end
                        1,2,3,4,5,6: begin
                            sort_in_nxt [0] = Img_ff[6][cnt-1]; sort_in_nxt [1] = Img_ff[6][cnt]; sort_in_nxt [2] = Img_ff[6][cnt+1];
                            sort_in_nxt [3] = Img_ff[7][cnt-1]; sort_in_nxt [4] = Img_ff[7][cnt]; sort_in_nxt [5] = Img_ff[7][cnt+1];
                            sort_in_nxt [6] = Img_ff[7][cnt-1]; sort_in_nxt [7] = Img_ff[7][cnt]; sort_in_nxt [8] = Img_ff[7][cnt+1];
                        end
                        7: begin
                            sort_in_nxt [0] = Img_ff[6][6]; sort_in_nxt [1] = Img_ff[6][7]; sort_in_nxt [2] = Img_ff[6][7];
                            sort_in_nxt [3] = Img_ff[7][6]; sort_in_nxt [4] = Img_ff[7][7]; sort_in_nxt [5] = Img_ff[7][7];
                            sort_in_nxt [6] = Img_ff[7][6]; sort_in_nxt [7] = Img_ff[7][7]; sort_in_nxt [8] = Img_ff[7][7];
                        end
                    endcase 
                end
               
            endcase
        end 
        CS_IM_FILTER4:begin
            case (row)
                0: begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[0][0]; sort_in_nxt [1] = Img_ff[0][0]; sort_in_nxt [2] = Img_ff[0][1];
                            sort_in_nxt [3] = Img_ff[0][0]; sort_in_nxt [4] = Img_ff[0][0]; sort_in_nxt [5] = Img_ff[0][1];
                            sort_in_nxt [6] = Img_ff[1][0]; sort_in_nxt [7] = Img_ff[1][0]; sort_in_nxt [8] = Img_ff[1][1];
                        end
                        1,2: begin
                            sort_in_nxt [0] = Img_ff[0][cnt-1]; sort_in_nxt [1] = Img_ff[0][cnt]; sort_in_nxt [2] = Img_ff[0][cnt+1];
                            sort_in_nxt [3] = Img_ff[0][cnt-1]; sort_in_nxt [4] = Img_ff[0][cnt]; sort_in_nxt [5] = Img_ff[0][cnt+1];
                            sort_in_nxt [6] = Img_ff[1][cnt-1]; sort_in_nxt [7] = Img_ff[1][cnt]; sort_in_nxt [8] = Img_ff[1][cnt+1];
                        end
                        3: begin
                            sort_in_nxt [0] = Img_ff[0][2]; sort_in_nxt [1] = Img_ff[0][3]; sort_in_nxt [2] = Img_ff[0][3];
                            sort_in_nxt [3] = Img_ff[0][2]; sort_in_nxt [4] = Img_ff[0][3]; sort_in_nxt [5] = Img_ff[0][3];
                            sort_in_nxt [6] = Img_ff[1][2]; sort_in_nxt [7] = Img_ff[1][3]; sort_in_nxt [8] = Img_ff[1][3];
                        end
                    endcase 
                end
                1,2:begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[row-1][0]; sort_in_nxt [1] = Img_ff[row-1][0]; sort_in_nxt [2] = Img_ff[row-1][1];
                            sort_in_nxt [3] = Img_ff[row  ][0]; sort_in_nxt [4] = Img_ff[row  ][0]; sort_in_nxt [5] = Img_ff[row  ][1];
                            sort_in_nxt [6] = Img_ff[row+1][0]; sort_in_nxt [7] = Img_ff[row+1][0]; sort_in_nxt [8] = Img_ff[row+1][1];
                        end
                        1,2: begin
                            sort_in_nxt [0] = Img_ff[row-1][cnt-1]; sort_in_nxt [1] = Img_ff[row-1][cnt]; sort_in_nxt [2] = Img_ff[row-1][cnt+1];
                            sort_in_nxt [3] = Img_ff[row  ][cnt-1]; sort_in_nxt [4] = Img_ff[row  ][cnt]; sort_in_nxt [5] = Img_ff[row  ][cnt+1];
                            sort_in_nxt [6] = Img_ff[row+1][cnt-1]; sort_in_nxt [7] = Img_ff[row+1][cnt]; sort_in_nxt [8] = Img_ff[row+1][cnt+1];
                        end
                        3: begin
                            sort_in_nxt [0] = Img_ff[row-1][2]; sort_in_nxt [1] = Img_ff[row-1][3]; sort_in_nxt [2] = Img_ff[row-1][3];
                            sort_in_nxt [3] = Img_ff[row  ][2]; sort_in_nxt [4] = Img_ff[row  ][3]; sort_in_nxt [5] = Img_ff[row  ][3];
                            sort_in_nxt [6] = Img_ff[row+1][2]; sort_in_nxt [7] = Img_ff[row+1][3]; sort_in_nxt [8] = Img_ff[row+1][3];
                        end
                    endcase 
                end
                3:begin
                    case (cnt)
                        0: begin
                            sort_in_nxt [0] = Img_ff[2][0]; sort_in_nxt [1] = Img_ff[2][0]; sort_in_nxt [2] = Img_ff[2][1];
                            sort_in_nxt [3] = Img_ff[3][0]; sort_in_nxt [4] = Img_ff[3][0]; sort_in_nxt [5] = Img_ff[3][1];
                            sort_in_nxt [6] = Img_ff[3][0]; sort_in_nxt [7] = Img_ff[3][0]; sort_in_nxt [8] = Img_ff[3][1];
                        end
                        1,2: begin
                            sort_in_nxt [0] = Img_ff[2][cnt-1]; sort_in_nxt [1] = Img_ff[2][cnt]; sort_in_nxt [2] = Img_ff[2][cnt+1];
                            sort_in_nxt [3] = Img_ff[3][cnt-1]; sort_in_nxt [4] = Img_ff[3][cnt]; sort_in_nxt [5] = Img_ff[3][cnt+1];
                            sort_in_nxt [6] = Img_ff[3][cnt-1]; sort_in_nxt [7] = Img_ff[3][cnt]; sort_in_nxt [8] = Img_ff[3][cnt+1];
                        end
                        3: begin
                            sort_in_nxt [0] = Img_ff[2][2]; sort_in_nxt [1] = Img_ff[2][3]; sort_in_nxt [2] = Img_ff[2][3];
                            sort_in_nxt [3] = Img_ff[3][2]; sort_in_nxt [4] = Img_ff[3][3]; sort_in_nxt [5] = Img_ff[3][3];
                            sort_in_nxt [6] = Img_ff[3][2]; sort_in_nxt [7] = Img_ff[3][3]; sort_in_nxt [8] = Img_ff[3][3];
                        end
                    endcase 
                end
               
            endcase
        end
    endcase
end


always @(*) begin
    case (cur_state)
        CS_IM_FILTER16:begin
            if(row == 0 && cnt < 2)begin
                Fliter_ff_nxt[0] = 0;Fliter_ff_nxt[8 ] = 0;
                Fliter_ff_nxt[1] = 0;Fliter_ff_nxt[9 ] = 0;
                Fliter_ff_nxt[2] = 0;Fliter_ff_nxt[10] = 0;
                Fliter_ff_nxt[3] = 0;Fliter_ff_nxt[11] = 0;
                Fliter_ff_nxt[4] = 0;Fliter_ff_nxt[12] = 0;
                Fliter_ff_nxt[5] = 0;Fliter_ff_nxt[13] = 0;
                Fliter_ff_nxt[6] = 0;Fliter_ff_nxt[14] = 0;
                Fliter_ff_nxt[7] = 0;
            end
            else begin
                Fliter_ff_nxt[0] = Fliter_ff[1];Fliter_ff_nxt[8 ] = Fliter_ff[9 ];
                Fliter_ff_nxt[1] = Fliter_ff[2];Fliter_ff_nxt[9 ] = Fliter_ff[10];
                Fliter_ff_nxt[2] = Fliter_ff[3];Fliter_ff_nxt[10] = Fliter_ff[11];
                Fliter_ff_nxt[3] = Fliter_ff[4];Fliter_ff_nxt[11] = Fliter_ff[12];
                Fliter_ff_nxt[4] = Fliter_ff[5];Fliter_ff_nxt[12] = Fliter_ff[13];
                Fliter_ff_nxt[5] = Fliter_ff[6];Fliter_ff_nxt[13] = Fliter_ff[14];
                Fliter_ff_nxt[6] = Fliter_ff[7];Fliter_ff_nxt[14] = sort_out[4];
                Fliter_ff_nxt[7] = Fliter_ff[8];
            end
            
        end
        CS_IM_FILTER8:begin
            if(row == 0 && cnt < 2)begin
                Fliter_ff_nxt[0] = 0;Fliter_ff_nxt[8 ] = 0;
                Fliter_ff_nxt[1] = 0;Fliter_ff_nxt[9 ] = 0;
                Fliter_ff_nxt[2] = 0;Fliter_ff_nxt[10] = 0;
                Fliter_ff_nxt[3] = 0;Fliter_ff_nxt[11] = 0;
                Fliter_ff_nxt[4] = 0;Fliter_ff_nxt[12] = 0;
                Fliter_ff_nxt[5] = 0;Fliter_ff_nxt[13] = 0;
                Fliter_ff_nxt[6] = 0;Fliter_ff_nxt[14] = 0;
                Fliter_ff_nxt[7] = 0;
            end
            else begin
                Fliter_ff_nxt[0] = Fliter_ff[1];Fliter_ff_nxt[8 ] = Fliter_ff[9 ];
                Fliter_ff_nxt[1] = Fliter_ff[2];Fliter_ff_nxt[9 ] = Fliter_ff[10];
                Fliter_ff_nxt[2] = Fliter_ff[3];Fliter_ff_nxt[10] = Fliter_ff[11];
                Fliter_ff_nxt[3] = Fliter_ff[4];Fliter_ff_nxt[11] = Fliter_ff[12];
                Fliter_ff_nxt[4] = Fliter_ff[5];Fliter_ff_nxt[12] = Fliter_ff[13];
                Fliter_ff_nxt[5] = Fliter_ff[6];Fliter_ff_nxt[13] = Fliter_ff[14];
                Fliter_ff_nxt[6] = Fliter_ff[7];Fliter_ff_nxt[14] = sort_out[4];
                Fliter_ff_nxt[7] = Fliter_ff[8];
            end
            
        end 
        CS_IM_FILTER4:begin
            if(row == 0 && cnt < 2)begin
                Fliter_ff_nxt[0] = 0;Fliter_ff_nxt[8 ] = 0;
                Fliter_ff_nxt[1] = 0;Fliter_ff_nxt[9 ] = 0;
                Fliter_ff_nxt[2] = 0;Fliter_ff_nxt[10] = 0;
                Fliter_ff_nxt[3] = 0;Fliter_ff_nxt[11] = 0;
                Fliter_ff_nxt[4] = 0;Fliter_ff_nxt[12] = 0;
                Fliter_ff_nxt[5] = 0;Fliter_ff_nxt[13] = 0;
                Fliter_ff_nxt[6] = 0;Fliter_ff_nxt[14] = 0;
                Fliter_ff_nxt[7] = 0;
            end
            else begin
                Fliter_ff_nxt[0] = Fliter_ff[1];Fliter_ff_nxt[8 ] = Fliter_ff[9 ];
                Fliter_ff_nxt[1] = Fliter_ff[2];Fliter_ff_nxt[9 ] = Fliter_ff[10];
                Fliter_ff_nxt[2] = Fliter_ff[3];Fliter_ff_nxt[10] = Fliter_ff[11];
                Fliter_ff_nxt[3] = Fliter_ff[4];Fliter_ff_nxt[11] = Fliter_ff[12];
                Fliter_ff_nxt[4] = Fliter_ff[5];Fliter_ff_nxt[12] = Fliter_ff[13];
                Fliter_ff_nxt[5] = Fliter_ff[6];Fliter_ff_nxt[13] = Fliter_ff[14];
                Fliter_ff_nxt[6] = Fliter_ff[7];Fliter_ff_nxt[14] = sort_out[4];
                Fliter_ff_nxt[7] = Fliter_ff[8];
            end
        end
        default: 
        begin
            Fliter_ff_nxt[0] = 0;Fliter_ff_nxt[8 ] = 0;
            Fliter_ff_nxt[1] = 0;Fliter_ff_nxt[9 ] = 0;
            Fliter_ff_nxt[2] = 0;Fliter_ff_nxt[10] = 0;
            Fliter_ff_nxt[3] = 0;Fliter_ff_nxt[11] = 0;
            Fliter_ff_nxt[4] = 0;Fliter_ff_nxt[12] = 0;
            Fliter_ff_nxt[5] = 0;Fliter_ff_nxt[13] = 0;
            Fliter_ff_nxt[6] = 0;Fliter_ff_nxt[14] = 0;
            Fliter_ff_nxt[7] = 0;
        end
    endcase
end
//==============================================//
//                    SORT
//==============================================//
always @(*) begin
    //sort in
    sort_layer1[2] = sort_in_ff[2];
    sort_layer1[5] = sort_in_ff[5];
    sort_layer1[8] = sort_in_ff[8];
    if(sort_in_ff[0] > sort_in_ff[1])begin
        sort_layer1[0] = sort_in_ff[0];
        sort_layer1[1] = sort_in_ff[1];
    end else begin
        sort_layer1[0] = sort_in_ff[1];
        sort_layer1[1] = sort_in_ff[0];
    end
    if(sort_in_ff[3] > sort_in_ff[4])begin
        sort_layer1[3] = sort_in_ff[3];
        sort_layer1[4] = sort_in_ff[4];
    end else begin
        sort_layer1[3] = sort_in_ff[4];
        sort_layer1[4] = sort_in_ff[3];
    end
    if(sort_in_ff[6] > sort_in_ff[7])begin
        sort_layer1[6] = sort_in_ff[6];
        sort_layer1[7] = sort_in_ff[7];
    end else begin
        sort_layer1[6] = sort_in_ff[7];
        sort_layer1[7] = sort_in_ff[6];
    end
    //lay1
    sort_layer2[0] = sort_layer1[0];
    sort_layer2[3] = sort_layer1[3];
    sort_layer2[6] = sort_layer1[6];
    if(sort_layer1[1] > sort_layer1[2])begin
        sort_layer2[1] = sort_layer1[1];
        sort_layer2[2] = sort_layer1[2];
    end else begin
        sort_layer2[1] = sort_layer1[2];
        sort_layer2[2] = sort_layer1[1];
    end
    if(sort_layer1[4] > sort_layer1[5])begin
        sort_layer2[4] = sort_layer1[4];
        sort_layer2[5] = sort_layer1[5];
    end else begin
        sort_layer2[4] = sort_layer1[5];
        sort_layer2[5] = sort_layer1[4];
    end
    if(sort_layer1[7] > sort_layer1[8])begin
        sort_layer2[7] = sort_layer1[7];
        sort_layer2[8] = sort_layer1[8];
    end else begin
        sort_layer2[7] = sort_layer1[8];
        sort_layer2[8] = sort_layer1[7];
    end
        
    //lay3
    sort_layer3[2] = sort_layer2[2];
    sort_layer3[5] = sort_layer2[5];
    sort_layer3[8] = sort_layer2[8];
    if(sort_layer2[0] > sort_layer2[1])begin
        sort_layer3[0] = sort_layer2[0];
        sort_layer3[1] = sort_layer2[1];
    end else begin
        sort_layer3[0] = sort_layer2[1];
        sort_layer3[1] = sort_layer2[0];
    end
    if(sort_layer2[3] > sort_layer2[4])begin
        sort_layer3[3] = sort_layer2[3];
        sort_layer3[4] = sort_layer2[4];
    end else begin
        sort_layer3[3] = sort_layer2[4];
        sort_layer3[4] = sort_layer2[3];
    end
    if(sort_layer2[6] > sort_layer2[7])begin
        sort_layer3[6] = sort_layer2[6];
        sort_layer3[7] = sort_layer2[7];
    end else begin
        sort_layer3[6] = sort_layer2[7];
        sort_layer3[7] = sort_layer2[6];
    end

    //lay4
    sort_layer4[1] = sort_layer3[1];
    sort_layer4[2] = sort_layer3[2];
    sort_layer4[4] = sort_layer3[4];
    sort_layer4[5] = sort_layer3[5];
    sort_layer4[6] = sort_layer3[6];
    sort_layer4[7] = sort_layer3[7];
    sort_layer4[8] = sort_layer3[8];
    if(sort_layer3[0] > sort_layer3[3])begin
        sort_layer4[0] = sort_layer3[0];
        sort_layer4[3] = sort_layer3[3];
    end else begin
        sort_layer4[0] = sort_layer3[3];
        sort_layer4[3] = sort_layer3[0];
    end
    //lay nxt
    sort_nxt[0] = sort_layer4[0];
    sort_nxt[1] = sort_layer4[1];
    sort_nxt[2] = sort_layer4[2];
    sort_nxt[4] = sort_layer4[4];
    sort_nxt[5] = sort_layer4[5];
    sort_nxt[7] = sort_layer4[7];
    sort_nxt[8] = sort_layer4[8];
    if(sort_layer4[3] > sort_layer4[6])begin
        sort_nxt[3] = sort_layer4[3];
        sort_nxt[6] = sort_layer4[6];
    end else begin
        sort_nxt[3] = sort_layer4[6];
        sort_nxt[6] = sort_layer4[3];
    end
end

always @(*) begin
    //lay5
    sort_layer5[0] = sort_ff[0];
    sort_layer5[2] = sort_ff[2];
    sort_layer5[3] = sort_ff[3];
    sort_layer5[5] = sort_ff[5];
    sort_layer5[6] = sort_ff[6];
    sort_layer5[7] = sort_ff[7];
    sort_layer5[8] = sort_ff[8];
    if(sort_ff[1] > sort_ff[4])begin
        sort_layer5[1] = sort_ff[1];
        sort_layer5[4] = sort_ff[4];
    end else begin
        sort_layer5[1] = sort_ff[4];
        sort_layer5[4] = sort_ff[1];
    end
 
    //lay6
    sort_layer6[0] = sort_layer5[0];
    sort_layer6[1] = sort_layer5[1];
    sort_layer6[2] = sort_layer5[2];
    sort_layer6[3] = sort_layer5[3];
    sort_layer6[5] = sort_layer5[5];
    sort_layer6[6] = sort_layer5[6];
    sort_layer6[8] = sort_layer5[8];
    if(sort_layer5[4] > sort_layer5[7])begin
        sort_layer6[4] = sort_layer5[4];
        sort_layer6[7] = sort_layer5[7];
    end else begin
        sort_layer6[4] = sort_layer5[7];
        sort_layer6[7] = sort_layer5[4];
    end
    //lay7
    sort_layer7[0] = sort_layer6[0];
    sort_layer7[2] = sort_layer6[2];
    sort_layer7[3] = sort_layer6[3];
    sort_layer7[5] = sort_layer6[5];
    sort_layer7[6] = sort_layer6[6];
    sort_layer7[7] = sort_layer6[7];
    sort_layer7[8] = sort_layer6[8];
    if(sort_layer6[1] > sort_layer6[4])begin
        sort_layer7[1] = sort_layer6[1];
        sort_layer7[4] = sort_layer6[4];
    end else begin
        sort_layer7[1] = sort_layer6[4];
        sort_layer7[4] = sort_layer6[1];
    end
    //lay8
    sort_layer8[0] = sort_layer7[0];
    sort_layer8[1] = sort_layer7[1];
    sort_layer8[3] = sort_layer7[3];
    sort_layer8[4] = sort_layer7[4];
    sort_layer8[6] = sort_layer7[6];
    sort_layer8[7] = sort_layer7[7];
    sort_layer8[8] = sort_layer7[8];
    if(sort_layer7[2] > sort_layer7[5])begin
        sort_layer8[2] = sort_layer7[2];
        sort_layer8[5] = sort_layer7[5];
    end else begin
        sort_layer8[2] = sort_layer7[5];
        sort_layer8[5] = sort_layer7[2];
    end
    //lay9
    sort_layer9[0] = sort_layer8[0];
    sort_layer9[1] = sort_layer8[1];
    sort_layer9[2] = sort_layer8[2];
    sort_layer9[3] = sort_layer8[3];
    sort_layer9[4] = sort_layer8[4];
    sort_layer9[6] = sort_layer8[6];
    sort_layer9[7] = sort_layer8[7];
    if(sort_layer8[5] > sort_layer8[8])begin
        sort_layer9[5] = sort_layer8[5];
        sort_layer9[8] = sort_layer8[8];
    end else begin
        sort_layer9[5] = sort_layer8[8];
        sort_layer9[8] = sort_layer8[5];
    end
    //lay8
    sort_layer10[0] = sort_layer9[0];
    sort_layer10[1] = sort_layer9[1];
    sort_layer10[3] = sort_layer9[3];
    sort_layer10[4] = sort_layer9[4];
    sort_layer10[6] = sort_layer9[6];
    sort_layer10[7] = sort_layer9[7];
    sort_layer10[8] = sort_layer9[8];
    if(sort_layer9[2] > sort_layer9[5])begin
        sort_layer10[2] = sort_layer9[2];
        sort_layer10[5] = sort_layer9[5];
    end else begin
        sort_layer10[2] = sort_layer9[5];
        sort_layer10[5] = sort_layer9[2];
    end

    //lay101
    sort_layer11[0] = sort_layer10[0];
    sort_layer11[1] = sort_layer10[1];
    sort_layer11[3] = sort_layer10[3];
    sort_layer11[4] = sort_layer10[4];
    sort_layer11[5] = sort_layer10[5];
    sort_layer11[7] = sort_layer10[7];
    sort_layer11[8] = sort_layer10[8];
    if(sort_layer10[2] > sort_layer10[6])begin
        sort_layer11[2] = sort_layer10[2];
        sort_layer11[6] = sort_layer10[6];
    end else begin
        sort_layer11[2] = sort_layer10[6];
        sort_layer11[6] = sort_layer10[2];
    end

    //lay11
    sort_layer12[0] = sort_layer11[0];
    sort_layer12[1] = sort_layer11[1];
    sort_layer12[2] = sort_layer11[2];
    sort_layer12[3] = sort_layer11[3];
    sort_layer12[5] = sort_layer11[5];
    sort_layer12[7] = sort_layer11[7];
    sort_layer12[8] = sort_layer11[8];
    if(sort_layer11[4] > sort_layer11[6])begin
        sort_layer12[4] = sort_layer11[4];
        sort_layer12[6] = sort_layer11[6];
    end else begin
        sort_layer12[4] = sort_layer11[6];
        sort_layer12[6] = sort_layer11[4];
    end

    //lay last
    sort_out[0] = sort_layer12[0];
    sort_out[1] = sort_layer12[1];
    sort_out[3] = sort_layer12[3];
    sort_out[5] = sort_layer12[5];
    sort_out[6] = sort_layer12[6];
    sort_out[7] = sort_layer12[7];
    sort_out[8] = sort_layer12[8];
    if(sort_layer12[2] > sort_layer12[4])begin
        sort_out[2] = sort_layer12[2];
        sort_out[4] = sort_layer12[4];
    end else begin
        sort_out[2] = sort_layer12[4];
        sort_out[4] = sort_layer12[2];
    end
end
//==============================================//
//                 MAXPOOLING
//==============================================//
always @(*) begin

    case (cur_state)
        CS_MAX16:begin
            case (cnt)
                0: begin
                    cmp_a[0][0] = Img_ff[0][0]; cmp_b[0][0] = Img_ff[0][1]; cmp_a[0][1] = Img_ff[0][2]; cmp_b[0][1] = Img_ff[0][3]; cmp_a[0][2] = Img_ff[0][4]; cmp_b[0][2] = Img_ff[0][5]; cmp_a[0][3] = Img_ff[0][6]; cmp_b[0][3] = Img_ff[0][7];
                    cmp_a[1][0] = Img_ff[1][0]; cmp_b[1][0] = Img_ff[1][1]; cmp_a[1][1] = Img_ff[1][2]; cmp_b[1][1] = Img_ff[1][3]; cmp_a[1][2] = Img_ff[1][4]; cmp_b[1][2] = Img_ff[1][5]; cmp_a[1][3] = Img_ff[1][6]; cmp_b[1][3] = Img_ff[1][7];
                    cmp_a[2][0] = Img_ff[2][0]; cmp_b[2][0] = Img_ff[2][1]; cmp_a[2][1] = Img_ff[2][2]; cmp_b[2][1] = Img_ff[2][3]; cmp_a[2][2] = Img_ff[2][4]; cmp_b[2][2] = Img_ff[2][5]; cmp_a[2][3] = Img_ff[2][6]; cmp_b[2][3] = Img_ff[2][7];
                    cmp_a[3][0] = Img_ff[3][0]; cmp_b[3][0] = Img_ff[3][1]; cmp_a[3][1] = Img_ff[3][2]; cmp_b[3][1] = Img_ff[3][3]; cmp_a[3][2] = Img_ff[3][4]; cmp_b[3][2] = Img_ff[3][5]; cmp_a[3][3] = Img_ff[3][6]; cmp_b[3][3] = Img_ff[3][7];
                    cmp_a[4][0] = Img_ff[4][0]; cmp_b[4][0] = Img_ff[4][1]; cmp_a[4][1] = Img_ff[4][2]; cmp_b[4][1] = Img_ff[4][3]; cmp_a[4][2] = Img_ff[4][4]; cmp_b[4][2] = Img_ff[4][5]; cmp_a[4][3] = Img_ff[4][6]; cmp_b[4][3] = Img_ff[4][7];
                    cmp_a[5][0] = Img_ff[5][0]; cmp_b[5][0] = Img_ff[5][1]; cmp_a[5][1] = Img_ff[5][2]; cmp_b[5][1] = Img_ff[5][3]; cmp_a[5][2] = Img_ff[5][4]; cmp_b[5][2] = Img_ff[5][5]; cmp_a[5][3] = Img_ff[5][6]; cmp_b[5][3] = Img_ff[5][7];
                    cmp_a[6][0] = Img_ff[6][0]; cmp_b[6][0] = Img_ff[6][1]; cmp_a[6][1] = Img_ff[6][2]; cmp_b[6][1] = Img_ff[6][3]; cmp_a[6][2] = Img_ff[6][4]; cmp_b[6][2] = Img_ff[6][5]; cmp_a[6][3] = Img_ff[6][6]; cmp_b[6][3] = Img_ff[6][7];
                    cmp_a[7][0] = Img_ff[7][0]; cmp_b[7][0] = Img_ff[7][1]; cmp_a[7][1] = Img_ff[7][2]; cmp_b[7][1] = Img_ff[7][3]; cmp_a[7][2] = Img_ff[7][4]; cmp_b[7][2] = Img_ff[7][5]; cmp_a[7][3] = Img_ff[7][6]; cmp_b[7][3] = Img_ff[7][7];
                end
                1: begin
                    cmp_a[0][0] = Img_ff[0][8]; cmp_b[0][0] = Img_ff[0][9]; cmp_a[0][1] = Img_ff[0][10]; cmp_b[0][1] = Img_ff[0][11]; cmp_a[0][2] = Img_ff[0][12]; cmp_b[0][2] = Img_ff[0][13]; cmp_a[0][3] = Img_ff[0][14]; cmp_b[0][3] = Img_ff[0][15];
                    cmp_a[1][0] = Img_ff[1][8]; cmp_b[1][0] = Img_ff[1][9]; cmp_a[1][1] = Img_ff[1][10]; cmp_b[1][1] = Img_ff[1][11]; cmp_a[1][2] = Img_ff[1][12]; cmp_b[1][2] = Img_ff[1][13]; cmp_a[1][3] = Img_ff[1][14]; cmp_b[1][3] = Img_ff[1][15];
                    cmp_a[2][0] = Img_ff[2][8]; cmp_b[2][0] = Img_ff[2][9]; cmp_a[2][1] = Img_ff[2][10]; cmp_b[2][1] = Img_ff[2][11]; cmp_a[2][2] = Img_ff[2][12]; cmp_b[2][2] = Img_ff[2][13]; cmp_a[2][3] = Img_ff[2][14]; cmp_b[2][3] = Img_ff[2][15];
                    cmp_a[3][0] = Img_ff[3][8]; cmp_b[3][0] = Img_ff[3][9]; cmp_a[3][1] = Img_ff[3][10]; cmp_b[3][1] = Img_ff[3][11]; cmp_a[3][2] = Img_ff[3][12]; cmp_b[3][2] = Img_ff[3][13]; cmp_a[3][3] = Img_ff[3][14]; cmp_b[3][3] = Img_ff[3][15];
                    cmp_a[4][0] = Img_ff[4][8]; cmp_b[4][0] = Img_ff[4][9]; cmp_a[4][1] = Img_ff[4][10]; cmp_b[4][1] = Img_ff[4][11]; cmp_a[4][2] = Img_ff[4][12]; cmp_b[4][2] = Img_ff[4][13]; cmp_a[4][3] = Img_ff[4][14]; cmp_b[4][3] = Img_ff[4][15];
                    cmp_a[5][0] = Img_ff[5][8]; cmp_b[5][0] = Img_ff[5][9]; cmp_a[5][1] = Img_ff[5][10]; cmp_b[5][1] = Img_ff[5][11]; cmp_a[5][2] = Img_ff[5][12]; cmp_b[5][2] = Img_ff[5][13]; cmp_a[5][3] = Img_ff[5][14]; cmp_b[5][3] = Img_ff[5][15];
                    cmp_a[6][0] = Img_ff[6][8]; cmp_b[6][0] = Img_ff[6][9]; cmp_a[6][1] = Img_ff[6][10]; cmp_b[6][1] = Img_ff[6][11]; cmp_a[6][2] = Img_ff[6][12]; cmp_b[6][2] = Img_ff[6][13]; cmp_a[6][3] = Img_ff[6][14]; cmp_b[6][3] = Img_ff[6][15];
                    cmp_a[7][0] = Img_ff[7][8]; cmp_b[7][0] = Img_ff[7][9]; cmp_a[7][1] = Img_ff[7][10]; cmp_b[7][1] = Img_ff[7][11]; cmp_a[7][2] = Img_ff[7][12]; cmp_b[7][2] = Img_ff[7][13]; cmp_a[7][3] = Img_ff[7][14]; cmp_b[7][3] = Img_ff[7][15];
                end
                2: 
                begin
                    cmp_a[0][0] = Img_ff[8 ][0]; cmp_b[0][0] = Img_ff[8 ][1]; cmp_a[0][1] = Img_ff[8 ][2]; cmp_b[0][1] = Img_ff[8 ][3]; cmp_a[0][2] = Img_ff[8 ][4]; cmp_b[0][2] = Img_ff[8 ][5]; cmp_a[0][3] = Img_ff[8 ][6]; cmp_b[0][3] = Img_ff[8 ][7];
                    cmp_a[1][0] = Img_ff[9 ][0]; cmp_b[1][0] = Img_ff[9 ][1]; cmp_a[1][1] = Img_ff[9 ][2]; cmp_b[1][1] = Img_ff[9 ][3]; cmp_a[1][2] = Img_ff[9 ][4]; cmp_b[1][2] = Img_ff[9 ][5]; cmp_a[1][3] = Img_ff[9 ][6]; cmp_b[1][3] = Img_ff[9 ][7];
                    cmp_a[2][0] = Img_ff[10][0]; cmp_b[2][0] = Img_ff[10][1]; cmp_a[2][1] = Img_ff[10][2]; cmp_b[2][1] = Img_ff[10][3]; cmp_a[2][2] = Img_ff[10][4]; cmp_b[2][2] = Img_ff[10][5]; cmp_a[2][3] = Img_ff[10][6]; cmp_b[2][3] = Img_ff[10][7];
                    cmp_a[3][0] = Img_ff[11][0]; cmp_b[3][0] = Img_ff[11][1]; cmp_a[3][1] = Img_ff[11][2]; cmp_b[3][1] = Img_ff[11][3]; cmp_a[3][2] = Img_ff[11][4]; cmp_b[3][2] = Img_ff[11][5]; cmp_a[3][3] = Img_ff[11][6]; cmp_b[3][3] = Img_ff[11][7];
                    cmp_a[4][0] = Img_ff[12][0]; cmp_b[4][0] = Img_ff[12][1]; cmp_a[4][1] = Img_ff[12][2]; cmp_b[4][1] = Img_ff[12][3]; cmp_a[4][2] = Img_ff[12][4]; cmp_b[4][2] = Img_ff[12][5]; cmp_a[4][3] = Img_ff[12][6]; cmp_b[4][3] = Img_ff[12][7];
                    cmp_a[5][0] = Img_ff[13][0]; cmp_b[5][0] = Img_ff[13][1]; cmp_a[5][1] = Img_ff[13][2]; cmp_b[5][1] = Img_ff[13][3]; cmp_a[5][2] = Img_ff[13][4]; cmp_b[5][2] = Img_ff[13][5]; cmp_a[5][3] = Img_ff[13][6]; cmp_b[5][3] = Img_ff[13][7];
                    cmp_a[6][0] = Img_ff[14][0]; cmp_b[6][0] = Img_ff[14][1]; cmp_a[6][1] = Img_ff[14][2]; cmp_b[6][1] = Img_ff[14][3]; cmp_a[6][2] = Img_ff[14][4]; cmp_b[6][2] = Img_ff[14][5]; cmp_a[6][3] = Img_ff[14][6]; cmp_b[6][3] = Img_ff[14][7];
                    cmp_a[7][0] = Img_ff[15][0]; cmp_b[7][0] = Img_ff[15][1]; cmp_a[7][1] = Img_ff[15][2]; cmp_b[7][1] = Img_ff[15][3]; cmp_a[7][2] = Img_ff[15][4]; cmp_b[7][2] = Img_ff[15][5]; cmp_a[7][3] = Img_ff[15][6]; cmp_b[7][3] = Img_ff[15][7];
                end
                3: 
                begin
                    cmp_a[0][0] = Img_ff[8 ][8]; cmp_b[0][0] = Img_ff[8 ][9]; cmp_a[0][1] = Img_ff[8 ][10]; cmp_b[0][1] = Img_ff[8 ][11]; cmp_a[0][2] = Img_ff[8 ][12]; cmp_b[0][2] = Img_ff[8 ][13]; cmp_a[0][3] = Img_ff[8 ][14]; cmp_b[0][3] = Img_ff[8 ][15];
                    cmp_a[1][0] = Img_ff[9 ][8]; cmp_b[1][0] = Img_ff[9 ][9]; cmp_a[1][1] = Img_ff[9 ][10]; cmp_b[1][1] = Img_ff[9 ][11]; cmp_a[1][2] = Img_ff[9 ][12]; cmp_b[1][2] = Img_ff[9 ][13]; cmp_a[1][3] = Img_ff[9 ][14]; cmp_b[1][3] = Img_ff[9 ][15];
                    cmp_a[2][0] = Img_ff[10][8]; cmp_b[2][0] = Img_ff[10][9]; cmp_a[2][1] = Img_ff[10][10]; cmp_b[2][1] = Img_ff[10][11]; cmp_a[2][2] = Img_ff[10][12]; cmp_b[2][2] = Img_ff[10][13]; cmp_a[2][3] = Img_ff[10][14]; cmp_b[2][3] = Img_ff[10][15];
                    cmp_a[3][0] = Img_ff[11][8]; cmp_b[3][0] = Img_ff[11][9]; cmp_a[3][1] = Img_ff[11][10]; cmp_b[3][1] = Img_ff[11][11]; cmp_a[3][2] = Img_ff[11][12]; cmp_b[3][2] = Img_ff[11][13]; cmp_a[3][3] = Img_ff[11][14]; cmp_b[3][3] = Img_ff[11][15];
                    cmp_a[4][0] = Img_ff[12][8]; cmp_b[4][0] = Img_ff[12][9]; cmp_a[4][1] = Img_ff[12][10]; cmp_b[4][1] = Img_ff[12][11]; cmp_a[4][2] = Img_ff[12][12]; cmp_b[4][2] = Img_ff[12][13]; cmp_a[4][3] = Img_ff[12][14]; cmp_b[4][3] = Img_ff[12][15];
                    cmp_a[5][0] = Img_ff[13][8]; cmp_b[5][0] = Img_ff[13][9]; cmp_a[5][1] = Img_ff[13][10]; cmp_b[5][1] = Img_ff[13][11]; cmp_a[5][2] = Img_ff[13][12]; cmp_b[5][2] = Img_ff[13][13]; cmp_a[5][3] = Img_ff[13][14]; cmp_b[5][3] = Img_ff[13][15];
                    cmp_a[6][0] = Img_ff[14][8]; cmp_b[6][0] = Img_ff[14][9]; cmp_a[6][1] = Img_ff[14][10]; cmp_b[6][1] = Img_ff[14][11]; cmp_a[6][2] = Img_ff[14][12]; cmp_b[6][2] = Img_ff[14][13]; cmp_a[6][3] = Img_ff[14][14]; cmp_b[6][3] = Img_ff[14][15];
                    cmp_a[7][0] = Img_ff[15][8]; cmp_b[7][0] = Img_ff[15][9]; cmp_a[7][1] = Img_ff[15][10]; cmp_b[7][1] = Img_ff[15][11]; cmp_a[7][2] = Img_ff[15][12]; cmp_b[7][2] = Img_ff[15][13]; cmp_a[7][3] = Img_ff[15][14]; cmp_b[7][3] = Img_ff[15][15];
                end
                default: 
                begin
                    cmp_a[0][0] = 0; cmp_b[0][0] = 0; cmp_a[0][1] = 0; cmp_b[0][1] = 0; cmp_a[0][2] = 0; cmp_b[0][2] = 0; cmp_a[0][3] = 0; cmp_b[0][3] = 0;
                    cmp_a[1][0] = 0; cmp_b[1][0] = 0; cmp_a[1][1] = 0; cmp_b[1][1] = 0; cmp_a[1][2] = 0; cmp_b[1][2] = 0; cmp_a[1][3] = 0; cmp_b[1][3] = 0;
                    cmp_a[2][0] = 0; cmp_b[2][0] = 0; cmp_a[2][1] = 0; cmp_b[2][1] = 0; cmp_a[2][2] = 0; cmp_b[2][2] = 0; cmp_a[2][3] = 0; cmp_b[2][3] = 0;
                    cmp_a[3][0] = 0; cmp_b[3][0] = 0; cmp_a[3][1] = 0; cmp_b[3][1] = 0; cmp_a[3][2] = 0; cmp_b[3][2] = 0; cmp_a[3][3] = 0; cmp_b[3][3] = 0;
                    cmp_a[4][0] = 0; cmp_b[4][0] = 0; cmp_a[4][1] = 0; cmp_b[4][1] = 0; cmp_a[4][2] = 0; cmp_b[4][2] = 0; cmp_a[4][3] = 0; cmp_b[4][3] = 0;
                    cmp_a[5][0] = 0; cmp_b[5][0] = 0; cmp_a[5][1] = 0; cmp_b[5][1] = 0; cmp_a[5][2] = 0; cmp_b[5][2] = 0; cmp_a[5][3] = 0; cmp_b[5][3] = 0;
                    cmp_a[6][0] = 0; cmp_b[6][0] = 0; cmp_a[6][1] = 0; cmp_b[6][1] = 0; cmp_a[6][2] = 0; cmp_b[6][2] = 0; cmp_a[6][3] = 0; cmp_b[6][3] = 0;
                    cmp_a[7][0] = 0; cmp_b[7][0] = 0; cmp_a[7][1] = 0; cmp_b[7][1] = 0; cmp_a[7][2] = 0; cmp_b[7][2] = 0; cmp_a[7][3] = 0; cmp_b[7][3] = 0;
                end
            endcase
            
        end
        CS_MAX8:begin
            cmp_a[0][0] = Img_ff[0][0]; cmp_b[0][0] = Img_ff[0][1]; cmp_a[0][1] = Img_ff[0][2]; cmp_b[0][1] = Img_ff[0][3]; cmp_a[0][2] = Img_ff[0][4]; cmp_b[0][2] = Img_ff[0][5]; cmp_a[0][3] = Img_ff[0][6]; cmp_b[0][3] = Img_ff[0][7];
            cmp_a[1][0] = Img_ff[1][0]; cmp_b[1][0] = Img_ff[1][1]; cmp_a[1][1] = Img_ff[1][2]; cmp_b[1][1] = Img_ff[1][3]; cmp_a[1][2] = Img_ff[1][4]; cmp_b[1][2] = Img_ff[1][5]; cmp_a[1][3] = Img_ff[1][6]; cmp_b[1][3] = Img_ff[1][7];
            cmp_a[2][0] = Img_ff[2][0]; cmp_b[2][0] = Img_ff[2][1]; cmp_a[2][1] = Img_ff[2][2]; cmp_b[2][1] = Img_ff[2][3]; cmp_a[2][2] = Img_ff[2][4]; cmp_b[2][2] = Img_ff[2][5]; cmp_a[2][3] = Img_ff[2][6]; cmp_b[2][3] = Img_ff[2][7];
            cmp_a[3][0] = Img_ff[3][0]; cmp_b[3][0] = Img_ff[3][1]; cmp_a[3][1] = Img_ff[3][2]; cmp_b[3][1] = Img_ff[3][3]; cmp_a[3][2] = Img_ff[3][4]; cmp_b[3][2] = Img_ff[3][5]; cmp_a[3][3] = Img_ff[3][6]; cmp_b[3][3] = Img_ff[3][7];
            cmp_a[4][0] = Img_ff[4][0]; cmp_b[4][0] = Img_ff[4][1]; cmp_a[4][1] = Img_ff[4][2]; cmp_b[4][1] = Img_ff[4][3]; cmp_a[4][2] = Img_ff[4][4]; cmp_b[4][2] = Img_ff[4][5]; cmp_a[4][3] = Img_ff[4][6]; cmp_b[4][3] = Img_ff[4][7];
            cmp_a[5][0] = Img_ff[5][0]; cmp_b[5][0] = Img_ff[5][1]; cmp_a[5][1] = Img_ff[5][2]; cmp_b[5][1] = Img_ff[5][3]; cmp_a[5][2] = Img_ff[5][4]; cmp_b[5][2] = Img_ff[5][5]; cmp_a[5][3] = Img_ff[5][6]; cmp_b[5][3] = Img_ff[5][7];
            cmp_a[6][0] = Img_ff[6][0]; cmp_b[6][0] = Img_ff[6][1]; cmp_a[6][1] = Img_ff[6][2]; cmp_b[6][1] = Img_ff[6][3]; cmp_a[6][2] = Img_ff[6][4]; cmp_b[6][2] = Img_ff[6][5]; cmp_a[6][3] = Img_ff[6][6]; cmp_b[6][3] = Img_ff[6][7];
            cmp_a[7][0] = Img_ff[7][0]; cmp_b[7][0] = Img_ff[7][1]; cmp_a[7][1] = Img_ff[7][2]; cmp_b[7][1] = Img_ff[7][3]; cmp_a[7][2] = Img_ff[7][4]; cmp_b[7][2] = Img_ff[7][5]; cmp_a[7][3] = Img_ff[7][6]; cmp_b[7][3] = Img_ff[7][7];
        end 
        default:begin
            cmp_a[0][0] = 0; cmp_b[0][0] = 0; cmp_a[0][1] = 0; cmp_b[0][1] = 0; cmp_a[0][2] = 0; cmp_b[0][2] = 0; cmp_a[0][3] = 0; cmp_b[0][3] = 0;
            cmp_a[1][0] = 0; cmp_b[1][0] = 0; cmp_a[1][1] = 0; cmp_b[1][1] = 0; cmp_a[1][2] = 0; cmp_b[1][2] = 0; cmp_a[1][3] = 0; cmp_b[1][3] = 0;
            cmp_a[2][0] = 0; cmp_b[2][0] = 0; cmp_a[2][1] = 0; cmp_b[2][1] = 0; cmp_a[2][2] = 0; cmp_b[2][2] = 0; cmp_a[2][3] = 0; cmp_b[2][3] = 0;
            cmp_a[3][0] = 0; cmp_b[3][0] = 0; cmp_a[3][1] = 0; cmp_b[3][1] = 0; cmp_a[3][2] = 0; cmp_b[3][2] = 0; cmp_a[3][3] = 0; cmp_b[3][3] = 0;
            cmp_a[4][0] = 0; cmp_b[4][0] = 0; cmp_a[4][1] = 0; cmp_b[4][1] = 0; cmp_a[4][2] = 0; cmp_b[4][2] = 0; cmp_a[4][3] = 0; cmp_b[4][3] = 0;
            cmp_a[5][0] = 0; cmp_b[5][0] = 0; cmp_a[5][1] = 0; cmp_b[5][1] = 0; cmp_a[5][2] = 0; cmp_b[5][2] = 0; cmp_a[5][3] = 0; cmp_b[5][3] = 0;
            cmp_a[6][0] = 0; cmp_b[6][0] = 0; cmp_a[6][1] = 0; cmp_b[6][1] = 0; cmp_a[6][2] = 0; cmp_b[6][2] = 0; cmp_a[6][3] = 0; cmp_b[6][3] = 0;
            cmp_a[7][0] = 0; cmp_b[7][0] = 0; cmp_a[7][1] = 0; cmp_b[7][1] = 0; cmp_a[7][2] = 0; cmp_b[7][2] = 0; cmp_a[7][3] = 0; cmp_b[7][3] = 0;
        end
    endcase
end
always @(*) begin
    cmp_z[0][0] = (cmp_a[0][0] > cmp_b[0][0]) ? cmp_a[0][0] : cmp_b[0][0]; cmp_z[0][1] = (cmp_a[0][1] > cmp_b[0][1]) ? cmp_a[0][1] : cmp_b[0][1]; cmp_z[0][2] = (cmp_a[0][2] > cmp_b[0][2]) ? cmp_a[0][2] : cmp_b[0][2]; cmp_z[0][3] = (cmp_a[0][3] > cmp_b[0][3]) ? cmp_a[0][3] : cmp_b[0][3];
    cmp_z[1][0] = (cmp_a[1][0] > cmp_b[1][0]) ? cmp_a[1][0] : cmp_b[1][0]; cmp_z[1][1] = (cmp_a[1][1] > cmp_b[1][1]) ? cmp_a[1][1] : cmp_b[1][1]; cmp_z[1][2] = (cmp_a[1][2] > cmp_b[1][2]) ? cmp_a[1][2] : cmp_b[1][2]; cmp_z[1][3] = (cmp_a[1][3] > cmp_b[1][3]) ? cmp_a[1][3] : cmp_b[1][3];
    cmp_z[2][0] = (cmp_a[2][0] > cmp_b[2][0]) ? cmp_a[2][0] : cmp_b[2][0]; cmp_z[2][1] = (cmp_a[2][1] > cmp_b[2][1]) ? cmp_a[2][1] : cmp_b[2][1]; cmp_z[2][2] = (cmp_a[2][2] > cmp_b[2][2]) ? cmp_a[2][2] : cmp_b[2][2]; cmp_z[2][3] = (cmp_a[2][3] > cmp_b[2][3]) ? cmp_a[2][3] : cmp_b[2][3];
    cmp_z[3][0] = (cmp_a[3][0] > cmp_b[3][0]) ? cmp_a[3][0] : cmp_b[3][0]; cmp_z[3][1] = (cmp_a[3][1] > cmp_b[3][1]) ? cmp_a[3][1] : cmp_b[3][1]; cmp_z[3][2] = (cmp_a[3][2] > cmp_b[3][2]) ? cmp_a[3][2] : cmp_b[3][2]; cmp_z[3][3] = (cmp_a[3][3] > cmp_b[3][3]) ? cmp_a[3][3] : cmp_b[3][3];
    cmp_z[4][0] = (cmp_a[4][0] > cmp_b[4][0]) ? cmp_a[4][0] : cmp_b[4][0]; cmp_z[4][1] = (cmp_a[4][1] > cmp_b[4][1]) ? cmp_a[4][1] : cmp_b[4][1]; cmp_z[4][2] = (cmp_a[4][2] > cmp_b[4][2]) ? cmp_a[4][2] : cmp_b[4][2]; cmp_z[4][3] = (cmp_a[4][3] > cmp_b[4][3]) ? cmp_a[4][3] : cmp_b[4][3];
    cmp_z[5][0] = (cmp_a[5][0] > cmp_b[5][0]) ? cmp_a[5][0] : cmp_b[5][0]; cmp_z[5][1] = (cmp_a[5][1] > cmp_b[5][1]) ? cmp_a[5][1] : cmp_b[5][1]; cmp_z[5][2] = (cmp_a[5][2] > cmp_b[5][2]) ? cmp_a[5][2] : cmp_b[5][2]; cmp_z[5][3] = (cmp_a[5][3] > cmp_b[5][3]) ? cmp_a[5][3] : cmp_b[5][3];
    cmp_z[6][0] = (cmp_a[6][0] > cmp_b[6][0]) ? cmp_a[6][0] : cmp_b[6][0]; cmp_z[6][1] = (cmp_a[6][1] > cmp_b[6][1]) ? cmp_a[6][1] : cmp_b[6][1]; cmp_z[6][2] = (cmp_a[6][2] > cmp_b[6][2]) ? cmp_a[6][2] : cmp_b[6][2]; cmp_z[6][3] = (cmp_a[6][3] > cmp_b[6][3]) ? cmp_a[6][3] : cmp_b[6][3];
    cmp_z[7][0] = (cmp_a[7][0] > cmp_b[7][0]) ? cmp_a[7][0] : cmp_b[7][0]; cmp_z[7][1] = (cmp_a[7][1] > cmp_b[7][1]) ? cmp_a[7][1] : cmp_b[7][1]; cmp_z[7][2] = (cmp_a[7][2] > cmp_b[7][2]) ? cmp_a[7][2] : cmp_b[7][2]; cmp_z[7][3] = (cmp_a[7][3] > cmp_b[7][3]) ? cmp_a[7][3] : cmp_b[7][3];

    cmp_z2[0][0] = (cmp_z[0][0] > cmp_z[1][0])? cmp_z[0][0] : cmp_z[1][0]; cmp_z2[0][1] = (cmp_z[0][1] > cmp_z[1][1])? cmp_z[0][1] : cmp_z[1][1]; cmp_z2[0][2] = (cmp_z[0][2] > cmp_z[1][2])? cmp_z[0][2] : cmp_z[1][2]; cmp_z2[0][3] = (cmp_z[0][3] > cmp_z[1][3])? cmp_z[0][3] : cmp_z[1][3];
    cmp_z2[1][0] = (cmp_z[2][0] > cmp_z[3][0])? cmp_z[2][0] : cmp_z[3][0]; cmp_z2[1][1] = (cmp_z[2][1] > cmp_z[3][1])? cmp_z[2][1] : cmp_z[3][1]; cmp_z2[1][2] = (cmp_z[2][2] > cmp_z[3][2])? cmp_z[2][2] : cmp_z[3][2]; cmp_z2[1][3] = (cmp_z[2][3] > cmp_z[3][3])? cmp_z[2][3] : cmp_z[3][3];
    cmp_z2[2][0] = (cmp_z[4][0] > cmp_z[5][0])? cmp_z[4][0] : cmp_z[5][0]; cmp_z2[2][1] = (cmp_z[4][1] > cmp_z[5][1])? cmp_z[4][1] : cmp_z[5][1]; cmp_z2[2][2] = (cmp_z[4][2] > cmp_z[5][2])? cmp_z[4][2] : cmp_z[5][2]; cmp_z2[2][3] = (cmp_z[4][3] > cmp_z[5][3])? cmp_z[4][3] : cmp_z[5][3];
    cmp_z2[3][0] = (cmp_z[6][0] > cmp_z[7][0])? cmp_z[6][0] : cmp_z[7][0]; cmp_z2[3][1] = (cmp_z[6][1] > cmp_z[7][1])? cmp_z[6][1] : cmp_z[7][1]; cmp_z2[3][2] = (cmp_z[6][2] > cmp_z[7][2])? cmp_z[6][2] : cmp_z[7][2]; cmp_z2[3][3] = (cmp_z[6][3] > cmp_z[7][3])? cmp_z[6][3] : cmp_z[7][3];

end
//==============================================//
//                    CONV
//==============================================//

always @(*) begin
    ma = 0;
    case (cur_state)
        CS_CON16:begin
            case (row)
                0: begin
                    case (cnt)
                        0: begin
                            if(row_3 == 0 || cnt_3 ==0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row_3-1][cnt_3-1]; 
                            end
                             
                        end
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
                            if(row_3 == 0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                        15: begin
                            if(row_3 == 0 || cnt_3 == 2)begin
                                ma = 0;
                            end 
                            else begin
                                ma = Img_ff[row_3-1][cnt+cnt_3-1];
                            end
                        end
                    endcase 
                end
                1,2,3,4,5,6,7,8,9,10,11,12,13,14:begin
                    case (cnt)
                        0: begin
                            if(cnt_3 == 0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                        end
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
                            ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                        end
                        15: begin
                            if(cnt_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                    endcase 
                end
                15:begin
                    case (cnt)
                        0: begin
                            if(cnt_3 == 0 || row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
        
                        end
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
                            if(row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                        end
                        15: begin
                            if(cnt_3 == 2 || row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                    endcase 
                end
               
            endcase
        end 
        CS_CON8:begin
            case (row)
                0: begin
                    case (cnt)
                        0: begin
                            if(row_3 == 0 || cnt_3 ==0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row_3-1][cnt_3-1]; 
                            end
                             
                        end
                        1,2,3,4,5,6: begin
                            if(row_3 == 0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                        7: begin
                            if(row_3 == 0 || cnt_3 == 2)begin
                                ma = 0;
                            end 
                            else begin
                                ma = Img_ff[row_3-1][cnt+cnt_3-1];
                            end
                        end
                    endcase 
                end
                1,2,3,4,5,6:begin
                    case (cnt)
                        0: begin
                            if(cnt_3 == 0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                        end
                        1,2,3,4,5,6: begin
                            ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                        end
                        7: begin
                            if(cnt_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                    endcase 
                end
                7:begin
                    case (cnt)
                        0: begin
                            if(cnt_3 == 0 || row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
        
                        end
                        1,2,3,4,5,6: begin
                            if(row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                        end
                        7: begin
                            if(cnt_3 == 2 || row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                    endcase 
                end
               
            endcase
        end 
        CS_CON4:begin
            case (row)
                0: begin
                    case (cnt)
                        0: begin
                            if(row_3 == 0 || cnt_3 ==0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row_3-1][cnt_3-1]; 
                            end
                             
                        end
                        1,2: begin
                            if(row_3 == 0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                        3: begin
                            if(row_3 == 0 || cnt_3 == 2)begin
                                ma = 0;
                            end 
                            else begin
                                ma = Img_ff[row_3-1][cnt+cnt_3-1];
                            end
                        end
                    endcase 
                end
                1,2:begin
                    case (cnt)
                        0: begin
                            if(cnt_3 == 0)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                        end
                        1,2: begin
                            ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                        end
                        3: begin
                            if(cnt_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                    endcase 
                end
                3:begin
                    case (cnt)
                        0: begin
                            if(cnt_3 == 0 || row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
        
                        end
                        1,2: begin
                            if(row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                        end
                        3: begin
                            if(cnt_3 == 2 || row_3 == 2)begin
                                ma = 0;
                            end
                            else begin
                                ma = Img_ff[row+row_3-1][cnt+cnt_3-1];
                            end
                            
                        end
                    endcase 
                end
               
            endcase
        end
    endcase
end
always @(*) begin
    case (cur_state)
        CS_CON8,CS_CON4,CS_CON16:begin
            case (row_3)
                0: begin
                    case (cnt_3)
                        0: mb = tmplt_reg[0];
                        1: mb = tmplt_reg[1];
                        2: mb = tmplt_reg[2];
                        default: mb = 0;
                    endcase
                end
                1: begin
                    case (cnt_3)
                        0: mb = tmplt_reg[3];
                        1: mb = tmplt_reg[4];
                        2: mb = tmplt_reg[5];
                        default: mb = 0;
                    endcase
                end
                
                2: begin
                    case (cnt_3)
                        0: mb = tmplt_reg[6];
                        1: mb = tmplt_reg[7];
                        2: mb = tmplt_reg[8];
                        default: mb = 0;
                    endcase
                end
                default: mb = 0;
            endcase
        end 
        default: mb = 0;
    endcase
end
assign mz = ma * mb;
always @(*) begin
    case (cur_state)
        CS_CON16,CS_CON8,CS_CON4: begin
            if(out_times == 0)begin
                if(out_cnt == 11) conv_nxt = 0;
                else              conv_nxt = conv_ff + mz;
            end
            else begin
                
                if(out_cnt == 19) conv_nxt = 0;
                else begin
                    if(out_cnt < 9)conv_nxt = conv_ff + mz;
                    else           conv_nxt = conv_ff;
                end           
                
            end
            
            
        end

        default: conv_nxt = 0;
    endcase
end
//==============================================//
//                   OUT
//==============================================//
always @(*) begin
    case (cur_state)
        CS_CON16,CS_CON8,CS_CON4: begin
            if(out_times == 0)begin
                if(out_cnt == 11) out_nxt = conv_ff;
                else begin
                    if(out_valid_nxt) out_nxt = out_ff << 1;
                    else          out_nxt = out_ff ;
                end
            end
            else begin
                if(out_cnt == 19) out_nxt = conv_ff;
                else begin
                    if(out_valid_nxt) out_nxt = out_ff << 1;
                    else          out_nxt = out_ff ;
                end
            end
            

        end

        default:  out_nxt =  0;
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 'd0;
        out_value <= 0;
    end
    else begin
        out_valid <= out_valid_nxt;
        out_value <= out_value_nxt;
    end
end
always @(*) begin
    case (cur_state)
        CS_CON16:begin
            out_valid_nxt = (out_times >= 1 && out_times <= 256) ? 1 : 0;
        end 
        CS_CON8:begin
            out_valid_nxt = (out_times >= 1 && out_times <= 64) ? 1 : 0;
        end 
        CS_CON4:begin
            out_valid_nxt = (out_times >= 1 && out_times <= 16) ? 1 : 0;
        end 
        default: out_valid_nxt  = 0;
    endcase
end
assign out_value_nxt = out_valid_nxt ? out_ff[19] : 0;
//==============================================//
//                      CNT
//==============================================//
always @(*) begin
    if(cur_state != nxt_state)begin
        row_3_nxt = 0;
    end
    else begin
        case (cur_state)
            CS_CON16,CS_CON8,CS_CON4:begin
                if(out_cnt < 9)begin
                    if(cnt_3==2)  row_3_nxt = row_3 + 1;
                    else          row_3_nxt = row_3; 
                end
                else row_3_nxt = 0;
                
            end
            default:row_3_nxt = 0;
        endcase
    end
    
end
always @(*) begin
    if(cur_state != nxt_state)begin
        if(in_valid ||cur_state==CS_GRSCALE) cnt_3_nxt = 2;
        else                                 cnt_3_nxt = 0;                            
    end
    else begin
        case (cur_state)
            CS_IDLE:begin
                if(in_valid) cnt_3_nxt = 2;
                else         cnt_3_nxt = 0;
            end 
            CS_WAIT_ACT:begin
                if(cnt_3 > 0) cnt_3_nxt = cnt_3 + 1;
                else          cnt_3_nxt = 0;
            end
            CS_GRSCALE:begin
                
                if(cnt_3==3)  cnt_3_nxt = 1;
                else          cnt_3_nxt = cnt_3 + 1; 
                
            end
            CS_CON16,CS_CON8,CS_CON4:begin
                if(out_cnt < 9)begin
                    if(cnt_3==2)  cnt_3_nxt = 0;
                    else          cnt_3_nxt = cnt_3 + 1;
                end
                else cnt_3_nxt = 0;
                
                
            end
            default:cnt_3_nxt = 0;
        endcase
    end
    
end
always @(*) begin
    if(cur_state != nxt_state)begin
        cnt_nxt = 0;
    end
    else begin
        case (cur_state)
            CS_GRSCALE:begin
                if(cnt_3==3) begin
                    if(cnt==7)  cnt_nxt = 0;
                    else        cnt_nxt = cnt + 1;
                end 
                else begin
                    cnt_nxt = cnt ;
                end         
                
            end
            CS_MAX16:begin
                cnt_nxt = cnt + 1;
            end
            CS_READ_GRAY16:begin
                if(cnt==32) cnt_nxt = 0;
                else       cnt_nxt = cnt + 1;
            end
            CS_READ_GRAY8:begin
                if(cnt==8) cnt_nxt = 0;
                else       cnt_nxt = cnt + 1;
            end
            CS_READ_GRAY4:begin
                cnt_nxt = cnt + 1;
         
            end
            CS_IM_FILTER16:begin
                if(cnt==15)  cnt_nxt = 0;
                else  begin
                    if(row_Filter == 15 && cnt_8 == 1)cnt_nxt = 0;
                    else                              cnt_nxt = cnt + 1;
                end    
                
            end
            CS_IM_FILTER8:begin
                if(cnt==7)  cnt_nxt = 0;
                else  begin
                    if(row_Filter == 7 && cnt_8 == 1)cnt_nxt = 0;
                    else                             cnt_nxt = cnt + 1;
                end    
                
            end
            CS_IM_FILTER4:begin
                if(cnt==3)  cnt_nxt = 0;
                else  begin
                    if(row_Filter == 3 && cnt_8 == 1)cnt_nxt = 0;
                    else                             cnt_nxt = cnt + 1;
                end  
            end
            CS_CON16:begin
                if(cnt_3 == 2 && row_3 ==2) begin
                    if(cnt == 15) begin
                        cnt_nxt = 0;
                    end
                    else cnt_nxt = cnt + 1;
                end
                else  cnt_nxt = cnt;
            end
            CS_CON8:begin
                if(cnt_3 == 2 && row_3 ==2) begin
                    if(cnt == 7) begin
                        cnt_nxt = 0;
                    end
                    else cnt_nxt = cnt + 1;
                end
                else  cnt_nxt = cnt;
            end    
            CS_CON4:begin
                if(cnt_3 == 2 && row_3 ==2) begin
                    if(cnt == 3) begin
                        cnt_nxt = 0;
                    end
                    else cnt_nxt = cnt + 1;
                end
                else  cnt_nxt = cnt;
            end
         
            
            default:cnt_nxt = 0;
        endcase 
    end
end
always @(*) begin
    if(cur_state != nxt_state)begin
        out_cnt_nxt = 0;
    end
    else begin
        case (cur_state)
            CS_CON16,CS_CON8,CS_CON4:begin
                if(out_times == 0)begin
                    if(out_cnt == 11) out_cnt_nxt = 0;
                    else              out_cnt_nxt = out_cnt + 1;
                end
                else begin
                    if(out_cnt == 19) out_cnt_nxt = 0;
                    else              out_cnt_nxt = out_cnt + 1;
                end
                
            end
            default :out_cnt_nxt = 0;
        endcase
    end
end
always @(*) begin
    if(cur_state != nxt_state)begin
        row_nxt = 0;
    end
    else begin
        case (cur_state)
            CS_GRSCALE:begin
                if(cnt_3==3 && cnt_8==8)  row_nxt = row + 1;
                else                      row_nxt = row;
            end
            CS_IM_FILTER16:begin
                if(row_Filter==15 && cnt_8 == 1)begin
                    row_nxt = 0;
                end
                else begin
                    if(cnt==15)  row_nxt = row + 1;
                    else         row_nxt = row;
                end
                
            end
            CS_IM_FILTER8:begin
                if(row_Filter==7 && cnt_8 == 1)begin
                    row_nxt = 0;
                end
                else begin
                    if(cnt==7)  row_nxt = row + 1;
                    else        row_nxt = row;
                end
                
            end
            CS_IM_FILTER4:begin
                if(row_Filter==3 && cnt_8 == 1)begin
                    row_nxt = 0;
                end
                else begin
                    if(cnt==3)  row_nxt = row + 1;
                    else        row_nxt = row;
                end
                
            end
            CS_CON16:begin
                if(cnt_3 == 2 && row_3 == 2 && cnt==15)row_nxt = row + 1;
                else                                  row_nxt = row;
            end
            CS_CON8:begin
                if(cnt_3 == 2 && row_3 == 2 && cnt==7)row_nxt = row + 1;
                else                                  row_nxt = row;
            end
            CS_CON4:begin
                if(cnt_3 == 2 && row_3 == 2 && cnt==3)row_nxt = row + 1;
                else                                  row_nxt = row;
            end
            default:row_nxt = 0;
        endcase
    end
    
end
always @(*) begin
    if(cur_state != nxt_state)begin
        cnt_8_nxt = 1;
    end
    else begin
        case (cur_state)
            CS_GRSCALE:begin
                if(cnt_3==3) begin
                    if(cnt>0) cnt_8_nxt = cnt_8 + 1;
                    else      cnt_8_nxt = 1;
                
                end 
                else begin

                    cnt_8_nxt = cnt_8 ;
                end                    
            end
            CS_WAIT_ACT: cnt_8_nxt = 0;
            CS_READ_GRAY16,CS_READ_GRAY8,CS_READ_GRAY4:begin
                if(action_reg > 2)begin
                    if(action_reg == 5)  cnt_8_nxt = cnt_8;
                    else                 cnt_8_nxt = cnt_8 + 1;
                end
                else cnt_8_nxt = 0; 
            end
            CS_IM_FILTER16:begin
                if(cnt>0) cnt_8_nxt = cnt_8 + 1;
                else      cnt_8_nxt = 0;
            end
            CS_IM_FILTER8:begin
                if(cnt>0) cnt_8_nxt = cnt_8 + 1;
                else      cnt_8_nxt = 0;
            end
            CS_IM_FILTER4:begin
                if(cnt>0) cnt_8_nxt = cnt_8 + 1;
                else      cnt_8_nxt = 0;
            end
            default:cnt_8_nxt = 1;
        endcase
    end
    
end
always @(*) begin
    if(cur_state != nxt_state)begin
        row_Filter_nxt = 0;
    end
    else begin
        case (cur_state)
            CS_IM_FILTER16:begin
                if(row_Filter==15 && cnt_8 == 1)begin
                    row_Filter_nxt = 0;
                end
                else begin
                    if(cnt_8==15 && row>=2)  row_Filter_nxt = row_Filter + 1;
                    else                     row_Filter_nxt = row_Filter;
                end
                
            end
            CS_IM_FILTER8:begin
                if(row_Filter==7 && cnt_8 == 1)begin
                    row_Filter_nxt = 0;
                end
                else begin
                    if(cnt_8==7 && row>=2)  row_Filter_nxt = row_Filter + 1;
                    else                    row_Filter_nxt = row_Filter;
                end
                
            end
            CS_IM_FILTER4:begin
                if(row_Filter==3 && cnt_8 == 1)begin
                    row_Filter_nxt = 0;
                end
                else begin
                    if(cnt_8==3 && row>=2)  row_Filter_nxt = row_Filter + 1;
                    else                    row_Filter_nxt = row_Filter;
                end
                
            end
            default:row_Filter_nxt = 0;
        endcase
    end
    
end
always @(*) begin
    case (cur_state)
        CS_CON16,CS_CON8,CS_CON4:begin
            if(out_times == 0)begin
                if(out_cnt == 11) out_times_nxt = out_times + 1;
                else              out_times_nxt = out_times;
            end
            else begin
                if(out_cnt == 19) out_times_nxt = out_times + 1;
                else              out_times_nxt = out_times;
            end
            
        end 
        default: out_times_nxt = 0;
    endcase
end
always @(*) begin
    if(in_valid2 && !in_valid2_reg) action_num_nxt = action_num + 1;
    else begin
        if(in_valid) action_num_nxt = 0;
        else         action_num_nxt = action_num;
    end               
    
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_3     <= 0;
        cnt       <= 0;
        out_cnt   <= 0;
        cnt_8     <= 0;
        row       <= 0;
        row_3     <= 0;
        row_Filter<= 0;
        out_times <= 0;
        action_num<= 0;
    end
    else begin
        cnt_3     <= cnt_3_nxt;
        cnt       <= cnt_nxt;
        out_cnt   <= out_cnt_nxt;
        cnt_8     <= cnt_8_nxt;
        row       <= row_nxt;
        row_3     <= row_3_nxt;
        row_Filter<= row_Filter_nxt;
        out_times <= out_times_nxt;
        action_num<= action_num_nxt;
    end
end

genvar i;
generate
    for(i=0;i<3;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                RGB_ff[i] <= 0;
            else 
                RGB_ff[i] <= RGB_ff_nxt[i];
        end
    end
endgenerate
generate
    for(i=0;i<15;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                Fliter_ff[i] <= 0;
            else 
                Fliter_ff[i] <= Fliter_ff_nxt[i];
        end
    end
endgenerate
generate
    for(i=0;i<9;i=i+1) begin
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                sort_ff[i] <= 0;
            else 
                sort_ff[i] <= sort_nxt[i];
        end
    end
endgenerate
genvar i,j;
generate
    for(i=0;i<3;i=i+1) begin
        for(j=0;j<8;j=j+1)begin
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n) 
                    gray_ff[i][j] <= 0;
                else 
                    gray_ff[i][j] <= gray_ff_nxt[i][j];
            end  
        end
        
    end
endgenerate
generate
    for(i=0;i<9;i=i+1) begin
        
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                sort_in_ff[i] <= 0;
            else 
                sort_in_ff[i] <= sort_in_nxt[i];
        end  
      
        
    end
endgenerate
genvar i,j;
generate
    for(i=0;i<16;i=i+1) begin
        for(j=0;j<16;j=j+1)begin
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n) 
                    Img_ff[i][j] <= 0;
                else 
                    Img_ff[i][j] <= Img_ff_nxt[i][j];
            end  
        end
        
    end
endgenerate
//==============================================//
//    CALCULATE ACTION NUM & STORE ACTION
//==============================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Flip_flag <= 'd0;
    end
    else if (CS_IDLE || out_valid) begin
        Flip_flag <= 'd0;
    end
    else if (in_valid2 && action == 'd5) begin
        Flip_flag <= !Flip_flag;
    end
end

always @(*) begin

    if(in_valid2_reg)begin
        if(action_reg > 2  && action_reg != 'd5)begin
            action_store_nxt = action_store | ({action_reg,18'b0}>>(cnt_8*3));
        end
        else action_store_nxt = action_store;
    end
    else begin
        if(cur_state != nxt_state)begin
            action_store_nxt = action_store<<3;
        end
        else begin
            case (cur_state)
                CS_IM_FILTER16:begin
                    if(row_Filter==15 && cnt_8 == 1)
                        action_store_nxt = action_store<<3;
                    else    
                        action_store_nxt = action_store;
                
                end
                CS_IM_FILTER8: begin
                    if(row_Filter==7 && cnt_8 == 1)
                        action_store_nxt = action_store<<3;
                    else    
                        action_store_nxt = action_store;
                    
                end
                CS_IM_FILTER4: begin
                    if(row_Filter==3 && cnt_8 == 1)
                        action_store_nxt = action_store<<3;
                    else    
                        action_store_nxt = action_store;
                   
                end
                CS_MAX4:begin
                    action_store_nxt = action_store<<3;
                end
                CS_NEG:begin
                    action_store_nxt = action_store<<3;
                end
                default: action_store_nxt = action_store;
            endcase
            
        end
    end  

end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        action_store <= 0;
    end
    else begin
        action_store <= action_store_nxt;
    end
end
assign gray_mode_nxt = (in_valid2 && !in_valid2_reg) ? action : gray_mode_reg;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        gray_mode_reg <= 0;
    end
    else begin
        gray_mode_reg <= gray_mode_nxt;
    end
end
//==============================================//
//                  TEMPLATE
//==============================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        conv_ff <= 0;
        out_ff  <= 0;
    end
    else begin
        conv_ff <= conv_nxt;
        out_ff  <= out_nxt;
    end
end
always @(*) begin
    if(in_valid && tmplt_cnt <= 'd8) begin
        tmplt_nxt[0] = tmplt_reg[1];
        tmplt_nxt[1] = tmplt_reg[2];
        tmplt_nxt[2] = tmplt_reg[3];
        tmplt_nxt[3] = tmplt_reg[4];
        tmplt_nxt[4] = tmplt_reg[5];
        tmplt_nxt[5] = tmplt_reg[6];
        tmplt_nxt[6] = tmplt_reg[7];
        tmplt_nxt[7] = tmplt_reg[8];
        tmplt_nxt[8] = template;
    end
    else begin
        tmplt_nxt[0] = tmplt_reg[0];
        tmplt_nxt[1] = tmplt_reg[1];
        tmplt_nxt[2] = tmplt_reg[2];
        tmplt_nxt[3] = tmplt_reg[3];
        tmplt_nxt[4] = tmplt_reg[4];
        tmplt_nxt[5] = tmplt_reg[5];
        tmplt_nxt[6] = tmplt_reg[6];
        tmplt_nxt[7] = tmplt_reg[7];
        tmplt_nxt[8] = tmplt_reg[8];
    end
end
generate
    for(i=0;i<9;i=i+1) begin
        
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) 
                tmplt_reg[i] <= 0;
            else 
                tmplt_reg[i] <= tmplt_nxt[i];
        end  
      
        
    end
endgenerate
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tmplt_cnt <= 'd0;
    end
    else if (in_valid2) begin
        tmplt_cnt <= 'd0;
    end
    else if (tmplt_cnt == 'd9) begin
        tmplt_cnt <= tmplt_cnt;
    end
    else if (in_valid) begin
        tmplt_cnt <= tmplt_cnt + 'd1;
    end
end

endmodule