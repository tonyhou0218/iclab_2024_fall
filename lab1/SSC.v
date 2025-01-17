//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab01 Exercise		: Snack Shopping Calculator
//   Author     		  : Yu-Hsiang Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SSC.v
//   Module Name : SSC
//   Release version : V1.0 (Release Date: 2024-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SSC(
    // Input signals
    card_num,
    input_money,
    snack_num,
    price, 
    // Output signals
    out_valid,
    out_change
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [63:0] card_num;
input [8:0] input_money;
input [31:0] snack_num;
input [31:0] price;
output out_valid;
output [8:0] out_change;    

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment
reg out_valid_temp;
reg [8:0]out_change_temp;





reg [7:0] total_money [0:7];
reg [3:0] check_key_0;
reg [3:0] check_key_1;
reg [3:0] check_key_2;
reg [3:0] check_key_3;
reg [3:0] check_key_4;
reg [3:0] check_key_5;
reg [3:0] check_key_6;
reg [3:0] check_key_7;

reg signed [8:0]sort_layer1[0:7];
reg signed [8:0]sort_layer2[0:7];
reg signed [8:0]sort_layer3[0:7];
reg signed [8:0]sort_layer4[0:7];
reg signed [8:0]sort_layer5[0:7];
reg signed [8:0]sort_layer6[0:7];
reg signed [8:0]sort_layer7[0:7];

wire [4:0] sum_odd_1_1;
wire [4:0] sum_odd_1_2;
wire [4:0] sum_odd_1_3;
wire [4:0] sum_odd_1_4;
wire [5:0] sum_odd_2_1;
wire [5:0] sum_odd_2_2;
wire [6:0] sum_odd_3;
wire [4:0] sum_even_1_1;
wire [4:0] sum_even_1_2;
wire [4:0] sum_even_1_3;
wire [4:0] sum_even_1_4;
wire [5:0] sum_even_2_1;
wire [5:0] sum_even_2_2;
wire [6:0] sum_even_3;
wire [7:0] sum_total;
wire valid_num;

reg signed[9:0] remain_money1;
reg signed[9:0] remain_money2;
reg signed[9:0] remain_money3;
reg signed[9:0] remain_money4;
reg signed[9:0] remain_money5;
reg signed[9:0] remain_money6;
reg signed[9:0] remain_money7;
reg signed[9:0] remain_money8;
//================================================================
//    DESIGN
//================================================================

//Map check key
/*reg [4:0]temp_card1;
reg [4:0]temp_card2;
reg [4:0]temp_card3;
reg [4:0]temp_card4;
reg [4:0]temp_card5;
reg [4:0]temp_card6;
reg [4:0]temp_card7;
reg [4:0]temp_card8;
assign temp_card1 = card_num[63:60] << 1;
assign temp_card2 = card_num[55:52] << 1;
assign temp_card3 = card_num[47:44] << 1;
assign temp_card4 = card_num[39:36] << 1;
assign temp_card5 = card_num[31:28] << 1;
assign temp_card6 = card_num[23:20] << 1;
assign temp_card7 = card_num[15:12] << 1;
assign temp_card8 = card_num[7:4]   << 1;
assign check_key_0 = (card_num [63:60]) >=5 ? (temp_card1 - 9) : temp_card1;
assign check_key_1 = (card_num [55:52]) >=5 ? (temp_card2 - 9) : temp_card2;
assign check_key_2 = (card_num [47:44]) >=5 ? (temp_card3 - 9) : temp_card3;
assign check_key_3 = (card_num [39:36]) >=5 ? (temp_card4 - 9) : temp_card4;
assign check_key_4 = (card_num [31:28]) >=5 ? (temp_card5 - 9) : temp_card5;
assign check_key_5 = (card_num [23:20]) >=5 ? (temp_card6 - 9) : temp_card6;
assign check_key_6 = (card_num [15:12]) >=5 ? (temp_card7 - 9) : temp_card7;
assign check_key_7 = (card_num [7:4]  ) >=5 ? (temp_card8 - 9) : temp_card8;*/
assign out_change = out_change_temp;
assign out_valid = out_valid_temp;
assign check_key_0 = (card_num [63:60]) >=5 ? ((card_num [63:60]<<1) - 9) : card_num [63:60]<<1;
assign check_key_1 = (card_num [55:52]) >=5 ? ((card_num [55:52]<<1) - 9) : card_num [55:52]<<1;
assign check_key_2 = (card_num [47:44]) >=5 ? ((card_num [47:44]<<1) - 9) : card_num [47:44]<<1;
assign check_key_3 = (card_num [39:36]) >=5 ? ((card_num [39:36]<<1) - 9) : card_num [39:36]<<1;
assign check_key_4 = (card_num [31:28]) >=5 ? ((card_num [31:28]<<1) - 9) : card_num [31:28]<<1;
assign check_key_5 = (card_num [23:20]) >=5 ? ((card_num [23:20]<<1) - 9) : card_num [23:20]<<1;
assign check_key_6 = (card_num [15:12]) >=5 ? ((card_num [15:12]<<1) - 9) : card_num [15:12]<<1;
assign check_key_7 = (card_num [7:4]  ) >=5 ? ((card_num [7:4]  <<1) - 9) : card_num [7:4]  <<1;

/*always @(*) begin 
    case (card_num [63:60])
        0:  check_key_0 = 0;
        1:  check_key_0 = 2;
        2:  check_key_0 = 4;
        3:  check_key_0 = 6;
        4:  check_key_0 = 8;
        5:  check_key_0 = 1;
        6:  check_key_0 = 3;
        7:  check_key_0 = 5;
        8:  check_key_0 = 7;
        9:  check_key_0 = 9;
    endcase
    case (card_num [55:52])
        0:  check_key_1 = 0;
        1:  check_key_1 = 2;
        2:  check_key_1 = 4;
        3:  check_key_1 = 6;
        4:  check_key_1 = 8;
        5:  check_key_1 = 1;
        6:  check_key_1 = 3;
        7:  check_key_1 = 5;
        8:  check_key_1 = 7;
        9:  check_key_1 = 9;
    endcase
    case (card_num [47:44])
        0:  check_key_2 = 0;
        1:  check_key_2 = 2;
        2:  check_key_2 = 4;
        3:  check_key_2 = 6;
        4:  check_key_2 = 8;
        5:  check_key_2 = 1;
        6:  check_key_2 = 3;
        7:  check_key_2 = 5;
        8:  check_key_2 = 7;
        9:  check_key_2 = 9;
    endcase
    case (card_num [39:36])
        0:  check_key_3 = 0;
        1:  check_key_3 = 2;
        2:  check_key_3 = 4;
        3:  check_key_3 = 6;
        4:  check_key_3 = 8;
        5:  check_key_3 = 1;
        6:  check_key_3 = 3;
        7:  check_key_3 = 5;
        8:  check_key_3 = 7;
        9:  check_key_3 = 9;
    endcase
    case (card_num [31:28])
        0:  check_key_4 = 0;
        1:  check_key_4 = 2;
        2:  check_key_4 = 4;
        3:  check_key_4 = 6;
        4:  check_key_4 = 8;
        5:  check_key_4 = 1;
        6:  check_key_4 = 3;
        7:  check_key_4 = 5;
        8:  check_key_4 = 7;
        9:  check_key_4 = 9;

    endcase
    case (card_num [23:20])
        0,14:  check_key_5 = 0;
        1,10:  check_key_5 = 2;
        2,11:  check_key_5 = 4;
        3,12:  check_key_5 = 6;
        4,13:  check_key_5 = 8;
        5:     check_key_5 = 1;
        6,15:  check_key_5 = 3;
        7:     check_key_5 = 5;
        8:     check_key_5 = 7;
        9:     check_key_5 = 9;

    endcase
    case (card_num [15:12])
        0,14:  check_key_6 = 0;
        1,10:  check_key_6 = 2;
        2,11:  check_key_6 = 4;
        3,12:  check_key_6 = 6;
        4,13:  check_key_6 = 8;
        5:     check_key_6 = 1;
        6,15:  check_key_6 = 3;
        7:     check_key_6 = 5;
        8:     check_key_6 = 7;
        9:     check_key_6 = 9;
    endcase
    case (card_num [7:4])
        0,14:  check_key_7 = 0;
        1,10:  check_key_7 = 2;
        2,11:  check_key_7 = 4;
        3,12:  check_key_7 = 6;
        4,13:  check_key_7 = 8;
        5:     check_key_7 = 1;
        6,15:  check_key_7 = 3;
        7:     check_key_7 = 5;
        8:     check_key_7 = 7;
        9:     check_key_7 = 9;
    endcase
end*/

//ADD 8 number (odd)
assign sum_odd_1_1 = check_key_0 + check_key_1;
assign sum_odd_1_2 = check_key_2 + check_key_3;
assign sum_odd_1_3 = check_key_4 + check_key_5;
assign sum_odd_1_4 = check_key_6 + check_key_7;
assign sum_odd_2_1 = sum_odd_1_1 + sum_odd_1_2;
assign sum_odd_2_2 = sum_odd_1_3 + sum_odd_1_4;
assign sum_odd_3   = sum_odd_2_1 + sum_odd_2_2;
//ADD 8 number (even)
assign sum_even_1_1 = card_num[3:0]   + card_num[11:8];
assign sum_even_1_2 = card_num[19:16] + card_num[27:24];
assign sum_even_1_3 = card_num[35:32] + card_num[43:40];
assign sum_even_1_4 = card_num[51:48] + card_num[59:56];
assign sum_even_2_1 = sum_even_1_1 + sum_even_1_2;
assign sum_even_2_2 = sum_even_1_3 + sum_even_1_4;
assign sum_even_3   = sum_even_2_1 + sum_even_2_2;
assign sum_total = sum_even_3 + sum_odd_3;//max196


//out_valid : Decide if multiples of 10
always @(*) begin
    case (sum_total)
        10,20,30,40,50,60,70,80,90,100,110,120,130,140:  
        begin
            out_valid_temp = 1;
        end
        
        default: out_valid_temp= 0;
    endcase
end
//muti (LUT)
/*
always @(*) begin
    case (snack_num[31:28])
        0: 
        begin
            total_money[0] = 0;
        end
        1: 
        begin
            total_money[0] = price[31:28];
        end
        2: 
        begin
            total_money[0] = price[31:28] << 1;

        end
        3: 
        begin
            case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 3;
                2:  total_money[0] = 6;
                3:  total_money[0] = 9;
                4:  total_money[0] = 12;
                5:  total_money[0] = 15;
                6:  total_money[0] = 18;
                7:  total_money[0] = 21;
                8:  total_money[0] = 24;
                9:  total_money[0] = 27;
                10: total_money[0] = 30;
                11: total_money[0] = 33;
                12: total_money[0] = 36;
                13: total_money[0] = 39;
                14: total_money[0] = 42;
                15: total_money[0] = 45;
            endcase
        end
        4: 
        begin
            case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 4;
                2:  total_money[0] = 8;
                3:  total_money[0] = 12;
                4:  total_money[0] = 16;
                5:  total_money[0] = 20;
                6:  total_money[0] = 24;
                7:  total_money[0] = 28;
                8:  total_money[0] = 32;
                9:  total_money[0] = 36;
                10: total_money[0] = 40;
                11: total_money[0] = 44;
                12: total_money[0] = 48;
                13: total_money[0] = 52;
                14: total_money[0] = 56;
                15: total_money[0] = 60;
            endcase
        end
        5: 
        begin
            case (price[31:28])
                0:  total_money [0] = 0 ;
                1:  total_money [0] = 5 ;
                2:  total_money [0] = 10;
                3:  total_money [0] = 15;
                4:  total_money [0] = 20;
                5:  total_money [0] = 25;
                6:  total_money [0] = 30;
                7:  total_money [0] = 35;
                8:  total_money [0] = 40;
                9:  total_money [0] = 45;
                10: total_money [0] = 50;
                11: total_money [0] = 55;
                12: total_money [0] = 60;
                13: total_money [0] = 65;
                14: total_money [0] = 70;
                15: total_money [0] = 75;
            endcase
        end
        6: 
        begin
            case (price[31:28])
                0:  total_money[0] = 0 ;
                1:  total_money[0] = 6 ;
                2:  total_money[0] = 12;
                3:  total_money[0] = 18;
                4:  total_money[0] = 24;
                5:  total_money[0] = 30;
                6:  total_money[0] = 36;
                7:  total_money[0] = 42;
                8:  total_money[0] = 48;
                9:  total_money[0] = 54;
                10: total_money[0] = 60;
                11: total_money[0] = 66;
                12: total_money[0] = 72;
                13: total_money[0] = 78;
                14: total_money[0] = 84;
                15: total_money[0] = 90;
            endcase
        end
        7: 
        begin
            case (price[31:28])
                0: total_money[0] = 0;
                1: total_money[0] = 7;
                2: total_money[0] = 14;
                3: total_money[0] = 21;
                4: total_money[0] = 28;
                5: total_money[0] = 35;
                6: total_money[0] = 42;
                7: total_money[0] = 49;
                8: total_money[0] = 56;
                9: total_money[0] = 63;
                10:total_money[0] = 70;
                11:total_money[0] = 77;
                12:total_money[0] = 84;
                13:total_money[0] = 91;
                14:total_money[0] = 98;
                15:total_money[0] = 105;
            endcase
        end
        8: 
        begin
            case (price[31:28])
                0:  total_money[0] = 0 ;
                1:  total_money[0] = 8 ;
                2:  total_money[0] = 16;
                3:  total_money[0] = 24;
                4:  total_money[0] = 32;
                5:  total_money[0] = 40;
                6:  total_money[0] = 48;
                7:  total_money[0] = 56;
                8:  total_money[0] = 64;
                9:  total_money[0] = 72;
                10: total_money[0] = 80;
                11: total_money[0] = 88;
                12: total_money[0] = 96;
                13: total_money[0] = 104;
                14: total_money[0] = 112;
                15: total_money[0] = 120;
            endcase
        end
        9: 
        begin
            case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 9;
                2:  total_money[0] = 18;
                3:  total_money[0] = 27;
                4:  total_money[0] = 36;
                5:  total_money[0] = 45;
                6:  total_money[0] = 54;
                7:  total_money[0] = 63;
                8:  total_money[0] = 72;
                9:  total_money[0] = 81;
                10: total_money[0] = 90;
                11: total_money[0] = 99;
                12: total_money[0] = 108;
                13: total_money[0] = 117;
                14: total_money[0] = 126;
                15: total_money[0] = 135;
            endcase
        end
        10:
        begin
            case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 10;
                2:  total_money[0] = 20;
                3:  total_money[0] = 30;
                4:  total_money[0] = 40;
                5:  total_money[0] = 50;
                6:  total_money[0] = 60;
                7:  total_money[0] = 70;
                8:  total_money[0] = 80;
                9:  total_money[0] = 90;
                10: total_money[0] = 100;
                11: total_money[0] = 110;
                12: total_money[0] = 120;
                13: total_money[0] = 130;
                14: total_money[0] = 140;
                15: total_money[0] = 150; 
            endcase
        end
        11:
        begin
            case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 11;
                2:  total_money[0] = 22;
                3:  total_money[0] = 33;
                4:  total_money[0] = 44;
                5:  total_money[0] = 55;
                6:  total_money[0] = 66;
                7:  total_money[0] = 77;
                8:  total_money[0] = 88;
                9:  total_money[0] = 99;
                10: total_money[0] = 110;
                11: total_money[0] = 121;
                12: total_money[0] = 132;
                13: total_money[0] = 143;
                14: total_money[0] = 154;
                15: total_money[0] = 165;
            endcase
        end
        12:
        begin
            case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 12;
                2:  total_money[0] = 24;
                3:  total_money[0] = 36;
                4:  total_money[0] = 48;
                5:  total_money[0] = 60;
                6:  total_money[0] = 72;
                7:  total_money[0] = 84;
                8:  total_money[0] = 96;
                9:  total_money[0] = 108;
                10: total_money[0] = 120;
                11: total_money[0] = 132;
                12: total_money[0] = 144;
                13: total_money[0] = 156;
                14: total_money[0] = 168;
                15: total_money[0] = 180;
                
            endcase
        end
        13:
        begin
           case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 13;
                2:  total_money[0] = 26;
                3:  total_money[0] = 39;
                4:  total_money[0] = 52;
                5:  total_money[0] = 65;
                6:  total_money[0] = 78;
                7:  total_money[0] = 91;
                8:  total_money[0] = 104;
                9:  total_money[0] = 117;
                10: total_money[0] = 130;
                11: total_money[0] = 143;
                12: total_money[0] = 156;
                13: total_money[0] = 169;
                14: total_money[0] = 182;
                15: total_money[0] = 195;
            endcase 
        end
        14:
        begin
           case (price[31:28])
                0:  total_money[0] = 0;
                1:  total_money[0] = 14;
                2:  total_money[0] = 28;
                3:  total_money[0] = 42;
                4:  total_money[0] = 56;
                5:  total_money[0] = 70;
                6:  total_money[0] = 84;
                7:  total_money[0] = 98;
                8:  total_money[0] = 112;
                9:  total_money[0] = 126;
                10: total_money[0] = 140;
                11: total_money[0] = 154;
                12: total_money[0] = 168;
                13: total_money[0] = 182;
                14: total_money[0] = 196;
                15: total_money[0] = 210;
            endcase 
        end
        15:
        begin
           case (price[31:28])
                0: total_money[0] = 0;
                1: total_money[0] = 15;
                2: total_money[0] = 30;
                3: total_money[0] = 45;
                4: total_money[0] = 60;
                5: total_money[0] = 75;
                6: total_money[0] = 90;
                7: total_money[0] = 105;
                8: total_money[0] = 120;
                9: total_money[0] = 135;
                10:total_money[0] = 150;
                11:total_money[0] = 165;
                12:total_money[0] = 180;
                13:total_money[0] = 195;
                14:total_money[0] = 210;
                15:total_money[0] = 225;
            endcase 
        end
    endcase 
    case (snack_num[27:24])
        0: 
        begin
            total_money[1] = 0;
        end
        1: 
        begin
            total_money[1] = price[27:24];
        end
        2: 
        begin
            total_money[1] = price[27:24] << 1;
        end
        3: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 3;
                2:  total_money[1] = 6;
                3:  total_money[1] = 9;
                4:  total_money[1] = 12;
                5:  total_money[1] = 15;
                6:  total_money[1] = 18;
                7:  total_money[1] = 21;
                8:  total_money[1] = 24;
                9:  total_money[1] = 27;
                10: total_money[1] = 30;
                11: total_money[1] = 33;
                12: total_money[1] = 36;
                13: total_money[1] = 39;
                14: total_money[1] = 42;
                15: total_money[1] = 45;
            endcase
        end
        4: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 4;
                2:  total_money[1] = 8;
                3:  total_money[1] = 12;
                4:  total_money[1] = 16;
                5:  total_money[1] = 20;
                6:  total_money[1] = 24;
                7:  total_money[1] = 28;
                8:  total_money[1] = 32;
                9:  total_money[1] = 36;
                10: total_money[1] = 40;
                11: total_money[1] = 44;
                12: total_money[1] = 48;
                13: total_money[1] = 52;
                14: total_money[1] = 56;
                15: total_money[1] = 60;

            endcase
        end
        5: 
        begin
            case (price[27:24])
                0:  total_money [1] = 0 ;
                1:  total_money [1] = 5 ;
                2:  total_money [1] = 10;
                3:  total_money [1] = 15;
                4:  total_money [1] = 20;
                5:  total_money [1] = 25;
                6:  total_money [1] = 30;
                7:  total_money [1] = 35;
                8:  total_money [1] = 40;
                9:  total_money [1] = 45;
                10: total_money [1] = 50;
                11: total_money [1] = 55;
                12: total_money [1] = 60;
                13: total_money [1] = 65;
                14: total_money [1] = 70;
                15: total_money [1] = 75;
            endcase
        end
        6: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0 ;
                1:  total_money[1] = 6 ;
                2:  total_money[1] = 12;
                3:  total_money[1] = 18;
                4:  total_money[1] = 24;
                5:  total_money[1] = 30;
                6:  total_money[1] = 36;
                7:  total_money[1] = 42;
                8:  total_money[1] = 48;
                9:  total_money[1] = 54;
                10: total_money[1] = 60;
                11: total_money[1] = 66;
                12: total_money[1] = 72;
                13: total_money[1] = 78;
                14: total_money[1] = 84;
                15: total_money[1] = 90;
            endcase
        end
        7: 
        begin
            case (price[27:24])
                0: total_money[1] = 0;
                1: total_money[1] = 7;
                2: total_money[1] = 14;
                3: total_money[1] = 21;
                4: total_money[1] = 28;
                5: total_money[1] = 35;
                6: total_money[1] = 42;
                7: total_money[1] = 49;
                8: total_money[1] = 56;
                9: total_money[1] = 63;
                10:total_money[1] = 70;
                11:total_money[1] = 77;
                12:total_money[1] = 84;
                13:total_money[1] = 91;
                14:total_money[1] = 98;
                15:total_money[1] = 105;
            endcase
        end
        8: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0 ;
                1:  total_money[1] = 8 ;
                2:  total_money[1] = 16;
                3:  total_money[1] = 24;
                4:  total_money[1] = 32;
                5:  total_money[1] = 40;
                6:  total_money[1] = 48;
                7:  total_money[1] = 56;
                8:  total_money[1] = 64;
                9:  total_money[1] = 72;
                10: total_money[1] = 80;
                11: total_money[1] = 88;
                12: total_money[1] = 96;
                13: total_money[1] = 104;
                14: total_money[1] = 112;
                15: total_money[1] = 120;
            endcase
        end
        9: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 9;
                2:  total_money[1] = 18;
                3:  total_money[1] = 27;
                4:  total_money[1] = 36;
                5:  total_money[1] = 45;
                6:  total_money[1] = 54;
                7:  total_money[1] = 63;
                8:  total_money[1] = 72;
                9:  total_money[1] = 81;
                10: total_money[1] = 90;
                11: total_money[1] = 99;
                12: total_money[1] = 108;
                13: total_money[1] = 117;
                14: total_money[1] = 126;
                15: total_money[1] = 135;
            endcase
        end
        10:
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 10;
                2:  total_money[1] = 20;
                3:  total_money[1] = 30;
                4:  total_money[1] = 40;
                5:  total_money[1] = 50;
                6:  total_money[1] = 60;
                7:  total_money[1] = 70;
                8:  total_money[1] = 80;
                9:  total_money[1] = 90;
                10: total_money[1] = 100;
                11: total_money[1] = 110;
                12: total_money[1] = 120;
                13: total_money[1] = 130;
                14: total_money[1] = 140;
                15: total_money[1] = 150;
            endcase
        end
        11: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 11;
                2:  total_money[1] = 22;
                3:  total_money[1] = 33;
                4:  total_money[1] = 44;
                5:  total_money[1] = 55;
                6:  total_money[1] = 66;
                7:  total_money[1] = 77;
                8:  total_money[1] = 88;
                9:  total_money[1] = 99;
                10: total_money[1] = 110;
                11: total_money[1] = 121;
                12: total_money[1] = 132;
                13: total_money[1] = 143;
                14: total_money[1] = 154;
                15: total_money[1] = 165;
            endcase
        end
        12: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 12;
                2:  total_money[1] = 24;
                3:  total_money[1] = 36;
                4:  total_money[1] = 48;
                5:  total_money[1] = 60;
                6:  total_money[1] = 72;
                7:  total_money[1] = 84;
                8:  total_money[1] = 96;
                9:  total_money[1] = 108;
                10: total_money[1] = 120;
                11: total_money[1] = 132;
                12: total_money[1] = 144;
                13: total_money[1] = 156;
                14: total_money[1] = 168;
                15: total_money[1] = 180;
            endcase
        end
        13: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 13;
                2:  total_money[1] = 26;
                3:  total_money[1] = 39;
                4:  total_money[1] = 52;
                5:  total_money[1] = 65;
                6:  total_money[1] = 78;
                7:  total_money[1] = 91;
                8:  total_money[1] = 104;
                9:  total_money[1] = 117;
                10: total_money[1] = 130;
                11: total_money[1] = 143;
                12: total_money[1] = 156;
                13: total_money[1] = 169;
                14: total_money[1] = 182;
                15: total_money[1] = 195;
            endcase
        end
        14: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 14;
                2:  total_money[1] = 28;
                3:  total_money[1] = 42;
                4:  total_money[1] = 56;
                5:  total_money[1] = 70;
                6:  total_money[1] = 84;
                7:  total_money[1] = 98;
                8:  total_money[1] = 112;
                9:  total_money[1] = 126;
                10: total_money[1] = 140;
                11: total_money[1] = 154;
                12: total_money[1] = 168;
                13: total_money[1] = 182;
                14: total_money[1] = 196;
                15: total_money[1] = 210;
            endcase
        end
        15: 
        begin
            case (price[27:24])
                0:  total_money[1] = 0;
                1:  total_money[1] = 15;
                2:  total_money[1] = 30;
                3:  total_money[1] = 45;
                4:  total_money[1] = 60;
                5:  total_money[1] = 75;
                6:  total_money[1] = 90;
                7:  total_money[1] = 105;
                8:  total_money[1] = 120;
                9:  total_money[1] = 135;
                10: total_money[1] = 150;
                11: total_money[1] = 165;
                12: total_money[1] = 180;
                13: total_money[1] = 195;
                14: total_money[1] = 210;
                15: total_money[1] = 225;
            endcase
        end
    endcase
    case (snack_num[23:20])
        0: 
        begin
            total_money[2] = 0;
        end
        1: 
        begin
            total_money[2] = price[23:20];
        end
        2: 
        begin
            total_money[2] = price[23:20] << 1;

        end
        3: 
        begin
            case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 3;
                2:  total_money[2] = 6;
                3:  total_money[2] = 9;
                4:  total_money[2] = 12;
                5:  total_money[2] = 15;
                6:  total_money[2] = 18;
                7:  total_money[2] = 21;
                8:  total_money[2] = 24;
                9:  total_money[2] = 27;
                10: total_money[2] = 30;
                11: total_money[2] = 33;
                12: total_money[2] = 36;
                13: total_money[2] = 39;
                14: total_money[2] = 42;
                15: total_money[2] = 45;

            endcase
        end
        4: 
        begin
            case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 4;
                2:  total_money[2] = 8;
                3:  total_money[2] = 12;
                4:  total_money[2] = 16;
                5:  total_money[2] = 20;
                6:  total_money[2] = 24;
                7:  total_money[2] = 28;
                8:  total_money[2] = 32;
                9:  total_money[2] = 36;
                10: total_money[2] = 40;
                11: total_money[2] = 44;
                12: total_money[2] = 48;
                13: total_money[2] = 52;
                14: total_money[2] = 56;
                15: total_money[2] = 60;
            endcase
        end
        5: 
        begin
            case (price[23:20])
                0:  total_money [2] = 0 ;
                1:  total_money [2] = 5 ;
                2:  total_money [2] = 10;
                3:  total_money [2] = 15;
                4:  total_money [2] = 20;
                5:  total_money [2] = 25;
                6:  total_money [2] = 30;
                7:  total_money [2] = 35;
                8:  total_money [2] = 40;
                9:  total_money [2] = 45;
                10: total_money [2] = 50;
                11: total_money [2] = 55;
                12: total_money [2] = 60;
                13: total_money [2] = 65;
                14: total_money [2] = 70;
                15: total_money [2] = 75;
            endcase
        end
        6: 
        begin
            case (price[23:20])
                0:  total_money[2] = 0 ;
                1:  total_money[2] = 6 ;
                2:  total_money[2] = 12;
                3:  total_money[2] = 18;
                4:  total_money[2] = 24;
                5:  total_money[2] = 30;
                6:  total_money[2] = 36;
                7:  total_money[2] = 42;
                8:  total_money[2] = 48;
                9:  total_money[2] = 54;
                10: total_money[2] = 60;
                11: total_money[2] = 66;
                12: total_money[2] = 72;
                13: total_money[2] = 78;
                14: total_money[2] = 84;
                15: total_money[2] = 90;
            endcase
        end
        7: 
        begin
            case (price[23:20])
                0: total_money[2] = 0;
                1: total_money[2] = 7;
                2: total_money[2] = 14;
                3: total_money[2] = 21;
                4: total_money[2] = 28;
                5: total_money[2] = 35;
                6: total_money[2] = 42;
                7: total_money[2] = 49;
                8: total_money[2] = 56;
                9: total_money[2] = 63;
                10:total_money[2] = 70;
                11:total_money[2] = 77;
                12:total_money[2] = 84;
                13:total_money[2] = 91;
                14:total_money[2] = 98;
                15:total_money[2] = 105;
            endcase
        end
        8: 
        begin
            case (price[23:20])
                0:  total_money[2] = 0 ;
                1:  total_money[2] = 8 ;
                2:  total_money[2] = 16;
                3:  total_money[2] = 24;
                4:  total_money[2] = 32;
                5:  total_money[2] = 40;
                6:  total_money[2] = 48;
                7:  total_money[2] = 56;
                8:  total_money[2] = 64;
                9:  total_money[2] = 72;
                10: total_money[2] = 80;
                11: total_money[2] = 88;
                12: total_money[2] = 96;
                13: total_money[2] = 104;
                14: total_money[2] = 112;
                15: total_money[2] = 120;
            endcase
        end
        9: 
        begin
            case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 9;
                2:  total_money[2] = 18;
                3:  total_money[2] = 27;
                4:  total_money[2] = 36;
                5:  total_money[2] = 45;
                6:  total_money[2] = 54;
                7:  total_money[2] = 63;
                8:  total_money[2] = 72;
                9:  total_money[2] = 81;
                10: total_money[2] = 90;
                11: total_money[2] = 99;
                12: total_money[2] = 108;
                13: total_money[2] = 117;
                14: total_money[2] = 126;
                15: total_money[2] = 135;
            endcase
        end
        10:
        begin
            case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 10;
                2:  total_money[2] = 20;
                3:  total_money[2] = 30;
                4:  total_money[2] = 40;
                5:  total_money[2] = 50;
                6:  total_money[2] = 60;
                7:  total_money[2] = 70;
                8:  total_money[2] = 80;
                9:  total_money[2] = 90;
                10: total_money[2] = 100;
                11: total_money[2] = 110;
                12: total_money[2] = 120;
                13: total_money[2] = 130;
                14: total_money[2] = 140;
                15: total_money[2] = 150; 
            endcase
        end
        11:
        begin
            case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 11;
                2:  total_money[2] = 22;
                3:  total_money[2] = 33;
                4:  total_money[2] = 44;
                5:  total_money[2] = 55;
                6:  total_money[2] = 66;
                7:  total_money[2] = 77;
                8:  total_money[2] = 88;
                9:  total_money[2] = 99;
                10: total_money[2] = 110;
                11: total_money[2] = 121;
                12: total_money[2] = 132;
                13: total_money[2] = 143;
                14: total_money[2] = 154;
                15: total_money[2] = 165;
            endcase
        end
        12:
        begin
            case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 12;
                2:  total_money[2] = 24;
                3:  total_money[2] = 36;
                4:  total_money[2] = 48;
                5:  total_money[2] = 60;
                6:  total_money[2] = 72;
                7:  total_money[2] = 84;
                8:  total_money[2] = 96;
                9:  total_money[2] = 108;
                10: total_money[2] = 120;
                11: total_money[2] = 132;
                12: total_money[2] = 144;
                13: total_money[2] = 156;
                14: total_money[2] = 168;
                15: total_money[2] = 180;
                
            endcase
        end
        13:
        begin
           case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 13;
                2:  total_money[2] = 26;
                3:  total_money[2] = 39;
                4:  total_money[2] = 52;
                5:  total_money[2] = 65;
                6:  total_money[2] = 78;
                7:  total_money[2] = 91;
                8:  total_money[2] = 104;
                9:  total_money[2] = 117;
                10: total_money[2] = 130;
                11: total_money[2] = 143;
                12: total_money[2] = 156;
                13: total_money[2] = 169;
                14: total_money[2] = 182;
                15: total_money[2] = 195;
            endcase 
        end
        14:
        begin
           case (price[23:20])
                0:  total_money[2] = 0;
                1:  total_money[2] = 14;
                2:  total_money[2] = 28;
                3:  total_money[2] = 42;
                4:  total_money[2] = 56;
                5:  total_money[2] = 70;
                6:  total_money[2] = 84;
                7:  total_money[2] = 98;
                8:  total_money[2] = 112;
                9:  total_money[2] = 126;
                10: total_money[2] = 140;
                11: total_money[2] = 154;
                12: total_money[2] = 168;
                13: total_money[2] = 182;
                14: total_money[2] = 196;
                15: total_money[2] = 210;
            endcase 
        end
        15:
        begin
           case (price[23:20])
                0: total_money[2] = 0;
                1: total_money[2] = 15;
                2: total_money[2] = 30;
                3: total_money[2] = 45;
                4: total_money[2] = 60;
                5: total_money[2] = 75;
                6: total_money[2] = 90;
                7: total_money[2] = 105;
                8: total_money[2] = 120;
                9: total_money[2] = 135;
                10:total_money[2] = 150;
                11:total_money[2] = 165;
                12:total_money[2] = 180;
                13:total_money[2] = 195;
                14:total_money[2] = 210;
                15:total_money[2] = 225;
            endcase 
        end
    endcase
    case (snack_num[19:16])
        0: 
        begin
            total_money[3] = 0;
        end
        1: 
        begin
            total_money[3] = price[19:16];
        end
        2: 
        begin
            total_money[3] = price[19:16] << 1;

        end
        3: 
        begin
            case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 3;
                2:  total_money[3] = 6;
                3:  total_money[3] = 9;
                4:  total_money[3] = 12;
                5:  total_money[3] = 15;
                6:  total_money[3] = 18;
                7:  total_money[3] = 21;
                8:  total_money[3] = 24;
                9:  total_money[3] = 27;
                10: total_money[3] = 30;
                11: total_money[3] = 33;
                12: total_money[3] = 36;
                13: total_money[3] = 39;
                14: total_money[3] = 42;
                15: total_money[3] = 45;

            endcase
        end
        4: 
        begin
            case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 4;
                2:  total_money[3] = 8;
                3:  total_money[3] = 12;
                4:  total_money[3] = 16;
                5:  total_money[3] = 20;
                6:  total_money[3] = 24;
                7:  total_money[3] = 28;
                8:  total_money[3] = 32;
                9:  total_money[3] = 36;
                10: total_money[3] = 40;
                11: total_money[3] = 44;
                12: total_money[3] = 48;
                13: total_money[3] = 52;
                14: total_money[3] = 56;
                15: total_money[3] = 60;
            endcase
        end
        5: 
        begin
            case (price[19:16])
                0:  total_money [3] = 0 ;
                1:  total_money [3] = 5 ;
                2:  total_money [3] = 10;
                3:  total_money [3] = 15;
                4:  total_money [3] = 20;
                5:  total_money [3] = 25;
                6:  total_money [3] = 30;
                7:  total_money [3] = 35;
                8:  total_money [3] = 40;
                9:  total_money [3] = 45;
                10: total_money [3] = 50;
                11: total_money [3] = 55;
                12: total_money [3] = 60;
                13: total_money [3] = 65;
                14: total_money [3] = 70;
                15: total_money [3] = 75;
            endcase
        end
        6: 
        begin
            case (price[19:16])
                0:  total_money[3] = 0 ;
                1:  total_money[3] = 6 ;
                2:  total_money[3] = 12;
                3:  total_money[3] = 18;
                4:  total_money[3] = 24;
                5:  total_money[3] = 30;
                6:  total_money[3] = 36;
                7:  total_money[3] = 42;
                8:  total_money[3] = 48;
                9:  total_money[3] = 54;
                10: total_money[3] = 60;
                11: total_money[3] = 66;
                12: total_money[3] = 72;
                13: total_money[3] = 78;
                14: total_money[3] = 84;
                15: total_money[3] = 90;
            endcase
        end
        7: 
        begin
            case (price[19:16])
                0: total_money[3] = 0;
                1: total_money[3] = 7;
                2: total_money[3] = 14;
                3: total_money[3] = 21;
                4: total_money[3] = 28;
                5: total_money[3] = 35;
                6: total_money[3] = 42;
                7: total_money[3] = 49;
                8: total_money[3] = 56;
                9: total_money[3] = 63;
                10:total_money[3] = 70;
                11:total_money[3] = 77;
                12:total_money[3] = 84;
                13:total_money[3] = 91;
                14:total_money[3] = 98;
                15:total_money[3] = 105;
            endcase
        end
        8: 
        begin
            case (price[19:16])
                0:  total_money[3] = 0 ;
                1:  total_money[3] = 8 ;
                2:  total_money[3] = 16;
                3:  total_money[3] = 24;
                4:  total_money[3] = 32;
                5:  total_money[3] = 40;
                6:  total_money[3] = 48;
                7:  total_money[3] = 56;
                8:  total_money[3] = 64;
                9:  total_money[3] = 72;
                10: total_money[3] = 80;
                11: total_money[3] = 88;
                12: total_money[3] = 96;
                13: total_money[3] = 104;
                14: total_money[3] = 112;
                15: total_money[3] = 120;
            endcase
        end
        9: 
        begin
            case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 9;
                2:  total_money[3] = 18;
                3:  total_money[3] = 27;
                4:  total_money[3] = 36;
                5:  total_money[3] = 45;
                6:  total_money[3] = 54;
                7:  total_money[3] = 63;
                8:  total_money[3] = 72;
                9:  total_money[3] = 81;
                10: total_money[3] = 90;
                11: total_money[3] = 99;
                12: total_money[3] = 108;
                13: total_money[3] = 117;
                14: total_money[3] = 126;
                15: total_money[3] = 135;
            endcase
        end
        10:
        begin
            case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 10;
                2:  total_money[3] = 20;
                3:  total_money[3] = 30;
                4:  total_money[3] = 40;
                5:  total_money[3] = 50;
                6:  total_money[3] = 60;
                7:  total_money[3] = 70;
                8:  total_money[3] = 80;
                9:  total_money[3] = 90;
                10: total_money[3] = 100;
                11: total_money[3] = 110;
                12: total_money[3] = 120;
                13: total_money[3] = 130;
                14: total_money[3] = 140;
                15: total_money[3] = 150; 
            endcase
        end
        11:
        begin
            case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 11;
                2:  total_money[3] = 22;
                3:  total_money[3] = 33;
                4:  total_money[3] = 44;
                5:  total_money[3] = 55;
                6:  total_money[3] = 66;
                7:  total_money[3] = 77;
                8:  total_money[3] = 88;
                9:  total_money[3] = 99;
                10: total_money[3] = 110;
                11: total_money[3] = 121;
                12: total_money[3] = 132;
                13: total_money[3] = 143;
                14: total_money[3] = 154;
                15: total_money[3] = 165;
            endcase
        end
        12:
        begin
            case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 12;
                2:  total_money[3] = 24;
                3:  total_money[3] = 36;
                4:  total_money[3] = 48;
                5:  total_money[3] = 60;
                6:  total_money[3] = 72;
                7:  total_money[3] = 84;
                8:  total_money[3] = 96;
                9:  total_money[3] = 108;
                10: total_money[3] = 120;
                11: total_money[3] = 132;
                12: total_money[3] = 144;
                13: total_money[3] = 156;
                14: total_money[3] = 168;
                15: total_money[3] = 180;
                
            endcase
        end
        13:
        begin
           case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 13;
                2:  total_money[3] = 26;
                3:  total_money[3] = 39;
                4:  total_money[3] = 52;
                5:  total_money[3] = 65;
                6:  total_money[3] = 78;
                7:  total_money[3] = 91;
                8:  total_money[3] = 104;
                9:  total_money[3] = 117;
                10: total_money[3] = 130;
                11: total_money[3] = 143;
                12: total_money[3] = 156;
                13: total_money[3] = 169;
                14: total_money[3] = 182;
                15: total_money[3] = 195;
            endcase 
        end
        14:
        begin
           case (price[19:16])
                0:  total_money[3] = 0;
                1:  total_money[3] = 14;
                2:  total_money[3] = 28;
                3:  total_money[3] = 42;
                4:  total_money[3] = 56;
                5:  total_money[3] = 70;
                6:  total_money[3] = 84;
                7:  total_money[3] = 98;
                8:  total_money[3] = 112;
                9:  total_money[3] = 126;
                10: total_money[3] = 140;
                11: total_money[3] = 154;
                12: total_money[3] = 168;
                13: total_money[3] = 182;
                14: total_money[3] = 196;
                15: total_money[3] = 210;
            endcase 
        end
        15:
        begin
           case (price[19:16])
                0: total_money[3] = 0;
                1: total_money[3] = 15;
                2: total_money[3] = 30;
                3: total_money[3] = 45;
                4: total_money[3] = 60;
                5: total_money[3] = 75;
                6: total_money[3] = 90;
                7: total_money[3] = 105;
                8: total_money[3] = 120;
                9: total_money[3] = 135;
                10:total_money[3] = 150;
                11:total_money[3] = 165;
                12:total_money[3] = 180;
                13:total_money[3] = 195;
                14:total_money[3] = 210;
                15:total_money[3] = 225;
            endcase 
        end
    endcase         
    case (snack_num[11:8])
        0: 
        begin
            total_money[5] = 0;
        end
        1: 
        begin
            total_money[5] = price[11:8];
        end
        2: 
        begin
            total_money[5] = price[11:8] << 1;
  
        end
        3: 
        begin
            case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 3;
                2:  total_money[5] = 6;
                3:  total_money[5] = 9;
                4:  total_money[5] = 12;
                5:  total_money[5] = 15;
                6:  total_money[5] = 18;
                7:  total_money[5] = 21;
                8:  total_money[5] = 24;
                9:  total_money[5] = 27;
                10: total_money[5] = 30;
                11: total_money[5] = 33;
                12: total_money[5] = 36;
                13: total_money[5] = 39;
                14: total_money[5] = 42;
                15: total_money[5] = 45;

            endcase
        end
        4: 
        begin
            case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 4;
                2:  total_money[5] = 8;
                3:  total_money[5] = 12;
                4:  total_money[5] = 16;
                5:  total_money[5] = 20;
                6:  total_money[5] = 24;
                7:  total_money[5] = 28;
                8:  total_money[5] = 32;
                9:  total_money[5] = 36;
                10: total_money[5] = 40;
                11: total_money[5] = 44;
                12: total_money[5] = 48;
                13: total_money[5] = 52;
                14: total_money[5] = 56;
                15: total_money[5] = 60;
            endcase
        end
        5: 
        begin
            case (price[11:8])
                0:  total_money [5] = 0 ;
                1:  total_money [5] = 5 ;
                2:  total_money [5] = 10;
                3:  total_money [5] = 15;
                4:  total_money [5] = 20;
                5:  total_money [5] = 25;
                6:  total_money [5] = 30;
                7:  total_money [5] = 35;
                8:  total_money [5] = 40;
                9:  total_money [5] = 45;
                10: total_money [5] = 50;
                11: total_money [5] = 55;
                12: total_money [5] = 60;
                13: total_money [5] = 65;
                14: total_money [5] = 70;
                15: total_money [5] = 75;
            endcase
        end
        6: 
        begin
            case (price[11:8])
                0: total_money[5] = 0 ;
                1: total_money[5] = 6 ;
                2: total_money[5] = 12;
                3: total_money[5] = 18;
                4: total_money[5] = 24;
                5: total_money[5] = 30;
                6: total_money[5] = 36;
                7: total_money[5] = 42;
                8: total_money[5] = 48;
                9: total_money[5] = 54;
                10:total_money[5] = 60;
                11:total_money[5] = 66;
                12:total_money[5] = 72;
                13:total_money[5] = 78;
                14:total_money[5] = 84;
                15:total_money[5] = 90;
            endcase
        end
        7: 
        begin
            case (price[11:8])
                0: total_money[5] = 0;
                1: total_money[5] = 7;
                2: total_money[5] = 14;
                3: total_money[5] = 21;
                4: total_money[5] = 28;
                5: total_money[5] = 35;
                6: total_money[5] = 42;
                7: total_money[5] = 49;
                8: total_money[5] = 56;
                9: total_money[5] = 63;
                10:total_money[5] = 70;
                11:total_money[5] = 77;
                12:total_money[5] = 84;
                13:total_money[5] = 91;
                14:total_money[5] = 98;
                15:total_money[5] = 105;
            endcase
        end
        8: 
        begin
            case (price[11:8])
                0:  total_money[5] = 0 ;
                1:  total_money[5] = 8 ;
                2:  total_money[5] = 16;
                3:  total_money[5] = 24;
                4:  total_money[5] = 32;
                5:  total_money[5] = 40;
                6:  total_money[5] = 48;
                7:  total_money[5] = 56;
                8:  total_money[5] = 64;
                9:  total_money[5] = 72;
                10: total_money[5] = 80;
                11: total_money[5] = 88;
                12: total_money[5] = 96;
                13: total_money[5] = 104;
                14: total_money[5] = 112;
                15: total_money[5] = 120;
            endcase
        end
        9: 
        begin
            case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 9;
                2:  total_money[5] = 18;
                3:  total_money[5] = 27;
                4:  total_money[5] = 36;
                5:  total_money[5] = 45;
                6:  total_money[5] = 54;
                7:  total_money[5] = 63;
                8:  total_money[5] = 72;
                9:  total_money[5] = 81;
                10: total_money[5] = 90;
                11: total_money[5] = 99;
                12: total_money[5] = 108;
                13: total_money[5] = 117;
                14: total_money[5] = 126;
                15: total_money[5] = 135;
            endcase
        end
        10:
        begin
            case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 10;
                2:  total_money[5] = 20;
                3:  total_money[5] = 30;
                4:  total_money[5] = 40;
                5:  total_money[5] = 50;
                6:  total_money[5] = 60;
                7:  total_money[5] = 70;
                8:  total_money[5] = 80;
                9:  total_money[5] = 90;
                10: total_money[5] = 100;
                11: total_money[5] = 110;
                12: total_money[5] = 120;
                13: total_money[5] = 130;
                14: total_money[5] = 140;
                15: total_money[5] = 150; 
            endcase
        end
        11:
        begin
            case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 11;
                2:  total_money[5] = 22;
                3:  total_money[5] = 33;
                4:  total_money[5] = 44;
                5:  total_money[5] = 55;
                6:  total_money[5] = 66;
                7:  total_money[5] = 77;
                8:  total_money[5] = 88;
                9:  total_money[5] = 99;
                10: total_money[5] = 110;
                11: total_money[5] = 121;
                12: total_money[5] = 132;
                13: total_money[5] = 143;
                14: total_money[5] = 154;
                15: total_money[5] = 165;
            endcase
        end
        12:
        begin
            case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 12;
                2:  total_money[5] = 24;
                3:  total_money[5] = 36;
                4:  total_money[5] = 48;
                5:  total_money[5] = 60;
                6:  total_money[5] = 72;
                7:  total_money[5] = 84;
                8:  total_money[5] = 96;
                9:  total_money[5] = 108;
                10: total_money[5] = 120;
                11: total_money[5] = 132;
                12: total_money[5] = 144;
                13: total_money[5] = 156;
                14: total_money[5] = 168;
                15: total_money[5] = 180;
                
            endcase
        end
        13:
        begin
           case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 13;
                2:  total_money[5] = 26;
                3:  total_money[5] = 39;
                4:  total_money[5] = 52;
                5:  total_money[5] = 65;
                6:  total_money[5] = 78;
                7:  total_money[5] = 91;
                8:  total_money[5] = 104;
                9:  total_money[5] = 117;
                10: total_money[5] = 130;
                11: total_money[5] = 143;
                12: total_money[5] = 156;
                13: total_money[5] = 169;
                14: total_money[5] = 182;
                15: total_money[5] = 195;
            endcase 
        end
        14:
        begin
           case (price[11:8])
                0:  total_money[5] = 0;
                1:  total_money[5] = 14;
                2:  total_money[5] = 28;
                3:  total_money[5] = 42;
                4:  total_money[5] = 56;
                5:  total_money[5] = 70;
                6:  total_money[5] = 84;
                7:  total_money[5] = 98;
                8:  total_money[5] = 112;
                9:  total_money[5] = 126;
                10: total_money[5] = 140;
                11: total_money[5] = 154;
                12: total_money[5] = 168;
                13: total_money[5] = 182;
                14: total_money[5] = 196;
                15: total_money[5] = 210;
            endcase 
        end
        15:
        begin
           case (price[11:8])
                0: total_money[5] = 0;
                1: total_money[5] = 15;
                2: total_money[5] = 30;
                3: total_money[5] = 45;
                4: total_money[5] = 60;
                5: total_money[5] = 75;
                6: total_money[5] = 90;
                7: total_money[5] = 105;
                8: total_money[5] = 120;
                9: total_money[5] = 135;
                10:total_money[5] = 150;
                11:total_money[5] = 165;
                12:total_money[5] = 180;
                13:total_money[5] = 195;
                14:total_money[5] = 210;
                15:total_money[5] = 225;
            endcase 
        end
    endcase
    case (snack_num[15:12])
        0: 
        begin
            total_money[4] = 0;
        end
        1: 
        begin
            total_money[4] = price[15:12];
        end
        2: 
        begin
            total_money[4] = price[15:12] << 1;

        end
        3: 
        begin
            case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 3;
                2:  total_money[4] = 6;
                3:  total_money[4] = 9;
                4:  total_money[4] = 12;
                5:  total_money[4] = 15;
                6:  total_money[4] = 18;
                7:  total_money[4] = 21;
                8:  total_money[4] = 24;
                9:  total_money[4] = 27;
                10: total_money[4] = 30;
                11: total_money[4] = 33;
                12: total_money[4] = 36;
                13: total_money[4] = 39;
                14: total_money[4] = 42;
                15: total_money[4] = 45;

            endcase
        end
        4: 
        begin
            case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 4;
                2:  total_money[4] = 8;
                3:  total_money[4] = 12;
                4:  total_money[4] = 16;
                5:  total_money[4] = 20;
                6:  total_money[4] = 24;
                7:  total_money[4] = 28;
                8:  total_money[4] = 32;
                9:  total_money[4] = 36;
                10: total_money[4] = 40;
                11: total_money[4] = 44;
                12: total_money[4] = 48;
                13: total_money[4] = 52;
                14: total_money[4] = 56;
                15: total_money[4] = 60;
            endcase
        end
        5: 
        begin
            case (price[15:12])
                0:  total_money [4] = 0 ;
                1:  total_money [4] = 5 ;
                2:  total_money [4] = 10;
                3:  total_money [4] = 15;
                4:  total_money [4] = 20;
                5:  total_money [4] = 25;
                6:  total_money [4] = 30;
                7:  total_money [4] = 35;
                8:  total_money [4] = 40;
                9:  total_money [4] = 45;
                10: total_money [4] = 50;
                11: total_money [4] = 55;
                12: total_money [4] = 60;
                13: total_money [4] = 65;
                14: total_money [4] = 70;
                15: total_money [4] = 75;
            endcase
        end
        6: 
        begin
            case (price[15:12])
                0:  total_money[4] = 0 ;
                1:  total_money[4] = 6 ;
                2:  total_money[4] = 12;
                3:  total_money[4] = 18;
                4:  total_money[4] = 24;
                5:  total_money[4] = 30;
                6:  total_money[4] = 36;
                7:  total_money[4] = 42;
                8:  total_money[4] = 48;
                9:  total_money[4] = 54;
                10: total_money[4] = 60;
                11: total_money[4] = 66;
                12: total_money[4] = 72;
                13: total_money[4] = 78;
                14: total_money[4] = 84;
                15: total_money[4] = 90;
            endcase
        end
        7: 
        begin
            case (price[15:12])
                0: total_money[4] = 0;
                1: total_money[4] = 7;
                2: total_money[4] = 14;
                3: total_money[4] = 21;
                4: total_money[4] = 28;
                5: total_money[4] = 35;
                6: total_money[4] = 42;
                7: total_money[4] = 49;
                8: total_money[4] = 56;
                9: total_money[4] = 63;
                10:total_money[4] = 70;
                11:total_money[4] = 77;
                12:total_money[4] = 84;
                13:total_money[4] = 91;
                14:total_money[4] = 98;
                15:total_money[4] = 105;
            endcase
        end
        8: 
        begin
            case (price[15:12])
                0:  total_money[4] = 0 ;
                1:  total_money[4] = 8 ;
                2:  total_money[4] = 16;
                3:  total_money[4] = 24;
                4:  total_money[4] = 32;
                5:  total_money[4] = 40;
                6:  total_money[4] = 48;
                7:  total_money[4] = 56;
                8:  total_money[4] = 64;
                9:  total_money[4] = 72;
                10: total_money[4] = 80;
                11: total_money[4] = 88;
                12: total_money[4] = 96;
                13: total_money[4] = 104;
                14: total_money[4] = 112;
                15: total_money[4] = 120;
            endcase
        end
        9: 
        begin
            case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 9;
                2:  total_money[4] = 18;
                3:  total_money[4] = 27;
                4:  total_money[4] = 36;
                5:  total_money[4] = 45;
                6:  total_money[4] = 54;
                7:  total_money[4] = 63;
                8:  total_money[4] = 72;
                9:  total_money[4] = 81;
                10: total_money[4] = 90;
                11: total_money[4] = 99;
                12: total_money[4] = 108;
                13: total_money[4] = 117;
                14: total_money[4] = 126;
                15: total_money[4] = 135;
            endcase
        end
        10:
        begin
            case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 10;
                2:  total_money[4] = 20;
                3:  total_money[4] = 30;
                4:  total_money[4] = 40;
                5:  total_money[4] = 50;
                6:  total_money[4] = 60;
                7:  total_money[4] = 70;
                8:  total_money[4] = 80;
                9:  total_money[4] = 90;
                10: total_money[4] = 100;
                11: total_money[4] = 110;
                12: total_money[4] = 120;
                13: total_money[4] = 130;
                14: total_money[4] = 140;
                15: total_money[4] = 150; 
            endcase
        end
        11:
        begin
            case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 11;
                2:  total_money[4] = 22;
                3:  total_money[4] = 33;
                4:  total_money[4] = 44;
                5:  total_money[4] = 55;
                6:  total_money[4] = 66;
                7:  total_money[4] = 77;
                8:  total_money[4] = 88;
                9:  total_money[4] = 99;
                10: total_money[4] = 110;
                11: total_money[4] = 121;
                12: total_money[4] = 132;
                13: total_money[4] = 143;
                14: total_money[4] = 154;
                15: total_money[4] = 165;
            endcase
        end
        12:
        begin
            case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 12;
                2:  total_money[4] = 24;
                3:  total_money[4] = 36;
                4:  total_money[4] = 48;
                5:  total_money[4] = 60;
                6:  total_money[4] = 72;
                7:  total_money[4] = 84;
                8:  total_money[4] = 96;
                9:  total_money[4] = 108;
                10: total_money[4] = 120;
                11: total_money[4] = 132;
                12: total_money[4] = 144;
                13: total_money[4] = 156;
                14: total_money[4] = 168;
                15: total_money[4] = 180;
                
            endcase
        end
        13:
        begin
           case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 13;
                2:  total_money[4] = 26;
                3:  total_money[4] = 39;
                4:  total_money[4] = 52;
                5:  total_money[4] = 65;
                6:  total_money[4] = 78;
                7:  total_money[4] = 91;
                8:  total_money[4] = 104;
                9:  total_money[4] = 117;
                10: total_money[4] = 130;
                11: total_money[4] = 143;
                12: total_money[4] = 156;
                13: total_money[4] = 169;
                14: total_money[4] = 182;
                15: total_money[4] = 195;
            endcase 
        end
        14:
        begin
           case (price[15:12])
                0:  total_money[4] = 0;
                1:  total_money[4] = 14;
                2:  total_money[4] = 28;
                3:  total_money[4] = 42;
                4:  total_money[4] = 56;
                5:  total_money[4] = 70;
                6:  total_money[4] = 84;
                7:  total_money[4] = 98;
                8:  total_money[4] = 112;
                9:  total_money[4] = 126;
                10: total_money[4] = 140;
                11: total_money[4] = 154;
                12: total_money[4] = 168;
                13: total_money[4] = 182;
                14: total_money[4] = 196;
                15: total_money[4] = 210;
            endcase 
        end
        15:
        begin
           case (price[15:12])
                0: total_money[4] = 0;
                1: total_money[4] = 15;
                2: total_money[4] = 30;
                3: total_money[4] = 45;
                4: total_money[4] = 60;
                5: total_money[4] = 75;
                6: total_money[4] = 90;
                7: total_money[4] = 105;
                8: total_money[4] = 120;
                9: total_money[4] = 135;
                10:total_money[4] = 150;
                11:total_money[4] = 165;
                12:total_money[4] = 180;
                13:total_money[4] = 195;
                14:total_money[4] = 210;
                15:total_money[4] = 225;
            endcase 
        end
    endcase
    case (snack_num[7:4])
        0: 
        begin
            total_money[6] = 0;
        end
        1: 
        begin
            total_money[6] = price[7:4];
        end
        2: 
        begin
            total_money[6] = price[7:4] << 1;

        end
        3: 
        begin
            case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 3;
                2:  total_money[6] = 6;
                3:  total_money[6] = 9;
                4:  total_money[6] = 12;
                5:  total_money[6] = 15;
                6:  total_money[6] = 18;
                7:  total_money[6] = 21;
                8:  total_money[6] = 24;
                9:  total_money[6] = 27;
                10: total_money[6] = 30;
                11: total_money[6] = 33;
                12: total_money[6] = 36;
                13: total_money[6] = 39;
                14: total_money[6] = 42;
                15: total_money[6] = 45;

            endcase
        end
        4: 
        begin
            case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 4;
                2:  total_money[6] = 8;
                3:  total_money[6] = 12;
                4:  total_money[6] = 16;
                5:  total_money[6] = 20;
                6:  total_money[6] = 24;
                7:  total_money[6] = 28;
                8:  total_money[6] = 32;
                9:  total_money[6] = 36;
                10: total_money[6] = 40;
                11: total_money[6] = 44;
                12: total_money[6] = 48;
                13: total_money[6] = 52;
                14: total_money[6] = 56;
                15: total_money[6] = 60;
            endcase
        end
        5: 
        begin
            case (price[7:4])
                0:  total_money [6] = 0 ;
                1:  total_money [6] = 5 ;
                2:  total_money [6] = 10;
                3:  total_money [6] = 15;
                4:  total_money [6] = 20;
                5:  total_money [6] = 25;
                6:  total_money [6] = 30;
                7:  total_money [6] = 35;
                8:  total_money [6] = 40;
                9:  total_money [6] = 45;
                10: total_money [6] = 50;
                11: total_money [6] = 55;
                12: total_money [6] = 60;
                13: total_money [6] = 65;
                14: total_money [6] = 70;
                15: total_money [6] = 75;
            endcase
        end
        6: 
        begin
            case (price[7:4])
                0:  total_money[6] = 0 ;
                1:  total_money[6] = 6 ;
                2:  total_money[6] = 12;
                3:  total_money[6] = 18;
                4:  total_money[6] = 24;
                5:  total_money[6] = 30;
                6:  total_money[6] = 36;
                7:  total_money[6] = 42;
                8:  total_money[6] = 48;
                9:  total_money[6] = 54;
                10: total_money[6] = 60;
                11: total_money[6] = 66;
                12: total_money[6] = 72;
                13: total_money[6] = 78;
                14: total_money[6] = 84;
                15: total_money[6] = 90;
            endcase
        end
        7: 
        begin
            case (price[7:4])
                0: total_money[6] = 0;
                1: total_money[6] = 7;
                2: total_money[6] = 14;
                3: total_money[6] = 21;
                4: total_money[6] = 28;
                5: total_money[6] = 35;
                6: total_money[6] = 42;
                7: total_money[6] = 49;
                8: total_money[6] = 56;
                9: total_money[6] = 63;
                10:total_money[6] = 70;
                11:total_money[6] = 77;
                12:total_money[6] = 84;
                13:total_money[6] = 91;
                14:total_money[6] = 98;
                15:total_money[6] = 105;
            endcase
        end
        8: 
        begin
            case (price[7:4])
                0:  total_money[6] = 0 ;
                1:  total_money[6] = 8 ;
                2:  total_money[6] = 16;
                3:  total_money[6] = 24;
                4:  total_money[6] = 32;
                5:  total_money[6] = 40;
                6:  total_money[6] = 48;
                7:  total_money[6] = 56;
                8:  total_money[6] = 64;
                9:  total_money[6] = 72;
                10: total_money[6] = 80;
                11: total_money[6] = 88;
                12: total_money[6] = 96;
                13: total_money[6] = 104;
                14: total_money[6] = 112;
                15: total_money[6] = 120;
            endcase
        end
        9: 
        begin
            case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 9;
                2:  total_money[6] = 18;
                3:  total_money[6] = 27;
                4:  total_money[6] = 36;
                5:  total_money[6] = 45;
                6:  total_money[6] = 54;
                7:  total_money[6] = 63;
                8:  total_money[6] = 72;
                9:  total_money[6] = 81;
                10: total_money[6] = 90;
                11: total_money[6] = 99;
                12: total_money[6] = 108;
                13: total_money[6] = 117;
                14: total_money[6] = 126;
                15: total_money[6] = 135;
            endcase
        end
        10:
        begin
            case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 10;
                2:  total_money[6] = 20;
                3:  total_money[6] = 30;
                4:  total_money[6] = 40;
                5:  total_money[6] = 50;
                6:  total_money[6] = 60;
                7:  total_money[6] = 70;
                8:  total_money[6] = 80;
                9:  total_money[6] = 90;
                10: total_money[6] = 100;
                11: total_money[6] = 110;
                12: total_money[6] = 120;
                13: total_money[6] = 130;
                14: total_money[6] = 140;
                15: total_money[6] = 150; 
            endcase
        end
        11:
        begin
            case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 11;
                2:  total_money[6] = 22;
                3:  total_money[6] = 33;
                4:  total_money[6] = 44;
                5:  total_money[6] = 55;
                6:  total_money[6] = 66;
                7:  total_money[6] = 77;
                8:  total_money[6] = 88;
                9:  total_money[6] = 99;
                10: total_money[6] = 110;
                11: total_money[6] = 121;
                12: total_money[6] = 132;
                13: total_money[6] = 143;
                14: total_money[6] = 154;
                15: total_money[6] = 165;
            endcase
        end
        12:
        begin
            case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 12;
                2:  total_money[6] = 24;
                3:  total_money[6] = 36;
                4:  total_money[6] = 48;
                5:  total_money[6] = 60;
                6:  total_money[6] = 72;
                7:  total_money[6] = 84;
                8:  total_money[6] = 96;
                9:  total_money[6] = 108;
                10: total_money[6] = 120;
                11: total_money[6] = 132;
                12: total_money[6] = 144;
                13: total_money[6] = 156;
                14: total_money[6] = 168;
                15: total_money[6] = 180;
                
            endcase
        end
        13:
        begin
           case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 13;
                2:  total_money[6] = 26;
                3:  total_money[6] = 39;
                4:  total_money[6] = 52;
                5:  total_money[6] = 65;
                6:  total_money[6] = 78;
                7:  total_money[6] = 91;
                8:  total_money[6] = 104;
                9:  total_money[6] = 117;
                10: total_money[6] = 130;
                11: total_money[6] = 143;
                12: total_money[6] = 156;
                13: total_money[6] = 169;
                14: total_money[6] = 182;
                15: total_money[6] = 195;
            endcase 
        end
        14:
        begin
           case (price[7:4])
                0:  total_money[6] = 0;
                1:  total_money[6] = 14;
                2:  total_money[6] = 28;
                3:  total_money[6] = 42;
                4:  total_money[6] = 56;
                5:  total_money[6] = 70;
                6:  total_money[6] = 84;
                7:  total_money[6] = 98;
                8:  total_money[6] = 112;
                9:  total_money[6] = 126;
                10: total_money[6] = 140;
                11: total_money[6] = 154;
                12: total_money[6] = 168;
                13: total_money[6] = 182;
                14: total_money[6] = 196;
                15: total_money[6] = 210;
            endcase 
        end
        15:
        begin
           case (price[7:4])
                0: total_money[6] = 0;
                1: total_money[6] = 15;
                2: total_money[6] = 30;
                3: total_money[6] = 45;
                4: total_money[6] = 60;
                5: total_money[6] = 75;
                6: total_money[6] = 90;
                7: total_money[6] = 105;
                8: total_money[6] = 120;
                9: total_money[6] = 135;
                10:total_money[6] = 150;
                11:total_money[6] = 165;
                12:total_money[6] = 180;
                13:total_money[6] = 195;
                14:total_money[6] = 210;
                15:total_money[6] = 225;
            endcase 
        end
    endcase
    case (snack_num[3:0])
        0: 
        begin
            total_money[7] = 0;
        end
        1: 
        begin
            total_money[7] = price[3:0];
        end
        2: 
        begin
            total_money[7] = price[3:0] << 1;

        end
        3: 
        begin
            case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 3;
                2:  total_money[7] = 6;
                3:  total_money[7] = 9;
                4:  total_money[7] = 12;
                5:  total_money[7] = 15;
                6:  total_money[7] = 18;
                7:  total_money[7] = 21;
                8:  total_money[7] = 24;
                9:  total_money[7] = 27;
                10: total_money[7] = 30;
                11: total_money[7] = 33;
                12: total_money[7] = 36;
                13: total_money[7] = 39;
                14: total_money[7] = 42;
                15: total_money[7] = 45;

            endcase
        end
        4: 
        begin
            case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 4;
                2:  total_money[7] = 8;
                3:  total_money[7] = 12;
                4:  total_money[7] = 16;
                5:  total_money[7] = 20;
                6:  total_money[7] = 24;
                7:  total_money[7] = 28;
                8:  total_money[7] = 32;
                9:  total_money[7] = 36;
                10: total_money[7] = 40;
                11: total_money[7] = 44;
                12: total_money[7] = 48;
                13: total_money[7] = 52;
                14: total_money[7] = 56;
                15: total_money[7] = 60;
            endcase
        end
        5: 
        begin
            case (price[3:0])
                0:  total_money[7] = 0 ;
                1:  total_money[7] = 5 ;
                2:  total_money[7] = 10;
                3:  total_money[7] = 15;
                4:  total_money[7] = 20;
                5:  total_money[7] = 25;
                6:  total_money[7] = 30;
                7:  total_money[7] = 35;
                8:  total_money[7] = 40;
                9:  total_money[7] = 45;
                10: total_money[7] = 50;
                11: total_money[7] = 55;
                12: total_money[7] = 60;
                13: total_money[7] = 65;
                14: total_money[7] = 70;
                15: total_money[7] = 75;
            endcase
        end
        6: 
        begin
            case (price[3:0])
                0:  total_money[7] = 0 ;
                1:  total_money[7] = 6 ;
                2:  total_money[7] = 12;
                3:  total_money[7] = 18;
                4:  total_money[7] = 24;
                5:  total_money[7] = 30;
                6:  total_money[7] = 36;
                7:  total_money[7] = 42;
                8:  total_money[7] = 48;
                9:  total_money[7] = 54;
                10: total_money[7] = 60;
                11: total_money[7] = 66;
                12: total_money[7] = 72;
                13: total_money[7] = 78;
                14: total_money[7] = 84;
                15: total_money[7] = 90;
            endcase
        end
        7: 
        begin
            case (price[3:0])
                0: total_money[7] = 0;
                1: total_money[7] = 7;
                2: total_money[7] = 14;
                3: total_money[7] = 21;
                4: total_money[7] = 28;
                5: total_money[7] = 35;
                6: total_money[7] = 42;
                7: total_money[7] = 49;
                8: total_money[7] = 56;
                9: total_money[7] = 63;
                10:total_money[7] = 70;
                11:total_money[7] = 77;
                12:total_money[7] = 84;
                13:total_money[7] = 91;
                14:total_money[7] = 98;
                15:total_money[7] = 105;
            endcase
        end
        8: 
        begin
            case (price[3:0])
                0:  total_money[7] = 0 ;
                1:  total_money[7] = 8 ;
                2:  total_money[7] = 16;
                3:  total_money[7] = 24;
                4:  total_money[7] = 32;
                5:  total_money[7] = 40;
                6:  total_money[7] = 48;
                7:  total_money[7] = 56;
                8:  total_money[7] = 64;
                9:  total_money[7] = 72;
                10: total_money[7] = 80;
                11: total_money[7] = 88;
                12: total_money[7] = 96;
                13: total_money[7] = 104;
                14: total_money[7] = 112;
                15: total_money[7] = 120;
            endcase
        end
        9: 
        begin
            case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 9;
                2:  total_money[7] = 18;
                3:  total_money[7] = 27;
                4:  total_money[7] = 36;
                5:  total_money[7] = 45;
                6:  total_money[7] = 54;
                7:  total_money[7] = 63;
                8:  total_money[7] = 72;
                9:  total_money[7] = 81;
                10: total_money[7] = 90;
                11: total_money[7] = 99;
                12: total_money[7] = 108;
                13: total_money[7] = 117;
                14: total_money[7] = 126;
                15: total_money[7] = 135;
            endcase
        end
        10:
        begin
            case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 10;
                2:  total_money[7] = 20;
                3:  total_money[7] = 30;
                4:  total_money[7] = 40;
                5:  total_money[7] = 50;
                6:  total_money[7] = 60;
                7:  total_money[7] = 70;
                8:  total_money[7] = 80;
                9:  total_money[7] = 90;
                10: total_money[7] = 100;
                11: total_money[7] = 110;
                12: total_money[7] = 120;
                13: total_money[7] = 130;
                14: total_money[7] = 140;
                15: total_money[7] = 150; 
            endcase
        end
        11:
        begin
            case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 11;
                2:  total_money[7] = 22;
                3:  total_money[7] = 33;
                4:  total_money[7] = 44;
                5:  total_money[7] = 55;
                6:  total_money[7] = 66;
                7:  total_money[7] = 77;
                8:  total_money[7] = 88;
                9:  total_money[7] = 99;
                10: total_money[7] = 110;
                11: total_money[7] = 121;
                12: total_money[7] = 132;
                13: total_money[7] = 143;
                14: total_money[7] = 154;
                15: total_money[7] = 165;
            endcase
        end
        12:
        begin
            case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 12;
                2:  total_money[7] = 24;
                3:  total_money[7] = 36;
                4:  total_money[7] = 48;
                5:  total_money[7] = 60;
                6:  total_money[7] = 72;
                7:  total_money[7] = 84;
                8:  total_money[7] = 96;
                9:  total_money[7] = 108;
                10: total_money[7] = 120;
                11: total_money[7] = 132;
                12: total_money[7] = 144;
                13: total_money[7] = 156;
                14: total_money[7] = 168;
                15: total_money[7] = 180;
                
            endcase
        end
        13:
        begin
           case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 13;
                2:  total_money[7] = 26;
                3:  total_money[7] = 39;
                4:  total_money[7] = 52;
                5:  total_money[7] = 65;
                6:  total_money[7] = 78;
                7:  total_money[7] = 91;
                8:  total_money[7] = 104;
                9:  total_money[7] = 117;
                10: total_money[7] = 130;
                11: total_money[7] = 143;
                12: total_money[7] = 156;
                13: total_money[7] = 169;
                14: total_money[7] = 182;
                15: total_money[7] = 195;
            endcase 
        end
        14:
        begin
           case (price[3:0])
                0:  total_money[7] = 0;
                1:  total_money[7] = 14;
                2:  total_money[7] = 28;
                3:  total_money[7] = 42;
                4:  total_money[7] = 56;
                5:  total_money[7] = 70;
                6:  total_money[7] = 84;
                7:  total_money[7] = 98;
                8:  total_money[7] = 112;
                9:  total_money[7] = 126;
                10: total_money[7] = 140;
                11: total_money[7] = 154;
                12: total_money[7] = 168;
                13: total_money[7] = 182;
                14: total_money[7] = 196;
                15: total_money[7] = 210;
            endcase 
        end
        15:
        begin
           case (price[3:0])
                0: total_money[7] = 0;
                1: total_money[7] = 15;
                2: total_money[7] = 30;
                3: total_money[7] = 45;
                4: total_money[7] = 60;
                5: total_money[7] = 75;
                6: total_money[7] = 90;
                7: total_money[7] = 105;
                8: total_money[7] = 120;
                9: total_money[7] = 135;
                10:total_money[7] = 150;
                11:total_money[7] = 165;
                12:total_money[7] = 180;
                13:total_money[7] = 195;
                14:total_money[7] = 210;
                15:total_money[7] = 225;
            endcase 
        end
    endcase
end*/
//muti (unLUT)
always @(*) begin
    total_money[0] = price[31:28]*snack_num[31:28];
    total_money[1] = price[27:24]*snack_num[27:24];
    total_money[2] = price[23:20]*snack_num[23:20];
    total_money[3] = price[19:16]*snack_num[19:16];
    total_money[4] = price[15:12]*snack_num[15:12];
    total_money[5] = price[11:8] *snack_num[11:8] ;
    total_money[6] = price[7:4]  *snack_num[7:4]  ;
    total_money[7] = price[3:0]  *snack_num[3:0]  ;
end
//sort
always @(*) begin
    if(total_money[0]<total_money[1])begin
        sort_layer1[0]=total_money[1];
        sort_layer1[1]=total_money[0];
    end
    else begin
        sort_layer1[0]=total_money[0];
        sort_layer1[1]=total_money[1];
    end
    if(total_money[2]<total_money[3])begin
        sort_layer1[2]=total_money[3];
        sort_layer1[3]=total_money[2];
    end
    else begin
        sort_layer1[2]=total_money[2];
        sort_layer1[3]=total_money[3];
    end
    if(total_money[4]<total_money[5])begin
        sort_layer1[4]=total_money[5];
        sort_layer1[5]=total_money[4];
    end
    else begin
        sort_layer1[4]=total_money[4];
        sort_layer1[5]=total_money[5];
    end
    if(total_money[6]<total_money[7])begin
        sort_layer1[6]=total_money[7];
        sort_layer1[7]=total_money[6];
    end
    else begin
        sort_layer1[6]=total_money[6];
        sort_layer1[7]=total_money[7];
    end
end
always @(*) begin
    if(sort_layer1[0]<sort_layer1[2])begin
        sort_layer2[0]=sort_layer1[2];
        sort_layer2[1]=sort_layer1[0];
    end
    else begin
        sort_layer2[0]=sort_layer1[0];
        sort_layer2[1]=sort_layer1[2];
    end
    if(sort_layer1[1]<sort_layer1[3])begin
        sort_layer2[2]=sort_layer1[3];
        sort_layer2[3]=sort_layer1[1];
    end
    else begin
        sort_layer2[2]=sort_layer1[1];
        sort_layer2[3]=sort_layer1[3];
    end
    if(sort_layer1[4]<sort_layer1[6])begin
        sort_layer2[4]=sort_layer1[6];
        sort_layer2[5]=sort_layer1[4];
    end
    else begin
        sort_layer2[4]=sort_layer1[4];
        sort_layer2[5]=sort_layer1[6];
    end
    if(sort_layer1[5]<sort_layer1[7])begin
        sort_layer2[6]=sort_layer1[7];
        sort_layer2[7]=sort_layer1[5];
    end
    else begin
        sort_layer2[6]=sort_layer1[5];
        sort_layer2[7]=sort_layer1[7];
    end
end
always @(*) begin
    sort_layer3[0]=sort_layer2[0];
    sort_layer3[3]=sort_layer2[3];
    sort_layer3[4]=sort_layer2[4];
    sort_layer3[7]=sort_layer2[7];
    if(sort_layer2[1]<sort_layer2[2])begin
        sort_layer3[1]=sort_layer2[2];
        sort_layer3[2]=sort_layer2[1];
    end
    else begin
        sort_layer3[1]=sort_layer2[1];
        sort_layer3[2]=sort_layer2[2];
    end

    if(sort_layer2[5]<sort_layer2[6])begin
        sort_layer3[5]=sort_layer2[6];
        sort_layer3[6]=sort_layer2[5];
    end
    else begin
        sort_layer3[5]=sort_layer2[5];
        sort_layer3[6]=sort_layer2[6];
    end
end
always @(*) begin
    if(sort_layer3[0]<sort_layer3[4])begin
        sort_layer4[0]=sort_layer3[4];
        sort_layer4[1]=sort_layer3[0];
    end
    else begin
        sort_layer4[0]=sort_layer3[0];
        sort_layer4[1]=sort_layer3[4];
    end
    if(sort_layer3[1]<sort_layer3[5])begin
        sort_layer4[2]=sort_layer3[5];
        sort_layer4[3]=sort_layer3[1];
    end
    else begin
        sort_layer4[2]=sort_layer3[1];
        sort_layer4[3]=sort_layer3[5];
    end
    if(sort_layer3[2]<sort_layer3[6])begin
        sort_layer4[4]=sort_layer3[6];
        sort_layer4[5]=sort_layer3[2];
    end
    else begin
        sort_layer4[4]=sort_layer3[2];
        sort_layer4[5]=sort_layer3[6];
    end
    if(sort_layer3[3]<sort_layer3[7])begin
        sort_layer4[6]=sort_layer3[7];
        sort_layer4[7]=sort_layer3[3];
    end
    else begin
        sort_layer4[6]=sort_layer3[3];
        sort_layer4[7]=sort_layer3[7];
    end
end
always @(*) begin
    sort_layer5[0]=sort_layer4[0];
    sort_layer5[7]=sort_layer4[7];
    if(sort_layer4[1]<sort_layer4[2])begin
        sort_layer5[1]=sort_layer4[2];
        sort_layer5[2]=sort_layer4[1];
    end
    else begin
        sort_layer5[1]=sort_layer4[1];
        sort_layer5[2]=sort_layer4[2];
    end
    if(sort_layer4[3]<sort_layer4[4])begin
        sort_layer5[3]=sort_layer4[4];
        sort_layer5[4]=sort_layer4[3];
    end
    else begin
        sort_layer5[3]=sort_layer4[3];
        sort_layer5[4]=sort_layer4[4];
    end
    if(sort_layer4[5]<sort_layer4[6])begin
        sort_layer5[5]=sort_layer4[6];
        sort_layer5[6]=sort_layer4[5];
    end
    else begin
        sort_layer5[5]=sort_layer4[5];
        sort_layer5[6]=sort_layer4[6];
    end
end
always @(*) begin
    sort_layer6[0]=sort_layer5[0];
    sort_layer6[1]=sort_layer5[1];
    sort_layer6[6]=sort_layer5[6];
    sort_layer6[7]=sort_layer5[7];
    if(sort_layer5[2]<sort_layer5[3])begin
        sort_layer6[2]=sort_layer5[3];
        sort_layer6[3]=sort_layer5[2];
    end
    else begin
        sort_layer6[2]=sort_layer5[2];
        sort_layer6[3]=sort_layer5[3];
    end
    if(sort_layer5[4]<sort_layer5[5])begin
        sort_layer6[4]=sort_layer5[5];
        sort_layer6[5]=sort_layer5[4];
    end
    else begin
        sort_layer6[4]=sort_layer5[4];
        sort_layer6[5]=sort_layer5[5];
    end
end
always @(*) begin
    sort_layer7[0]=sort_layer6[0];
    sort_layer7[1]=sort_layer6[1];
    sort_layer7[2]=sort_layer6[2];
    sort_layer7[5]=sort_layer6[5];
    sort_layer7[6]=sort_layer6[6];
    sort_layer7[7]=sort_layer6[7];
    if(sort_layer6[3]<sort_layer6[4])begin
        sort_layer7[3]=sort_layer6[4];
        sort_layer7[4]=sort_layer6[3];
    end
    else begin
        sort_layer7[3]=sort_layer6[3];
        sort_layer7[4]=sort_layer6[4];
    end
end
always @(*) begin
    remain_money1 = input_money - sort_layer7[0];
    remain_money2 = remain_money1 - sort_layer7[1];
    remain_money3 = remain_money2 - sort_layer7[2];
    remain_money4 = remain_money3 - sort_layer7[3];
    remain_money5 = remain_money4 - sort_layer7[4];
    remain_money6 = remain_money5 - sort_layer7[5];
    remain_money7 = remain_money6 - sort_layer7[6];
    remain_money8 = remain_money7 - sort_layer7[7];

    if(out_valid_temp)begin
        if(remain_money1 >= 0)begin  
            if(remain_money2 >= 0)begin
                if(remain_money3  >= 0)begin
                    if(remain_money4 >= 0)begin
                        if(remain_money5  >= 0)begin
                            if(remain_money6  >= 0)begin
                                if(remain_money7  >= 0)begin
                                    if(remain_money8  >= 0)begin
                                        out_change_temp = remain_money8;
                                    end
                                    else
                                        out_change_temp = remain_money7;
                                end
                                else
                                    out_change_temp = remain_money6;
                            end
                            else 
                                out_change_temp = remain_money5;
                        end
                        else
                            out_change_temp = remain_money4;
                    end
                    else
                        out_change_temp = remain_money3;
                end
                else
                    out_change_temp = remain_money2;
            end
            else
                out_change_temp = remain_money1;
        end
        else
            out_change_temp = input_money;
    end
    else
        out_change_temp = input_money;
end
endmodule