//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/10
//		Version		: v1.0
//   	File Name   : HAMMING_IP.v
//   	Module Name : HAMMING_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module HAMMING_IP #(parameter IP_BIT = 11) (
    // Input signals
    IN_code,
    // Output signals
    OUT_code
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_BIT+4-1:0]  IN_code;

output reg [IP_BIT-1:0] OUT_code;

reg [3:0]postion_key[0:15];
reg [IP_BIT-1:0]correct_value;
reg [10:0]temp_value;
reg [IP_BIT+4-1:0]fixed_value;
reg [3:0]w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15;
// ===============================================================
// Design
// ===============================================================
integer i;
always @(*) begin
    for (i = 1; i <= IP_BIT+4; i = i + 1) begin
        postion_key[i] = (IN_code[IP_BIT+4-i]) ? i : 0;
    end
    for (i = IP_BIT+5; i <= 15; i = i + 1) begin
        postion_key[i] = 0;
    end
end
always @(*) begin
    w1 = postion_key[1 ] ^ postion_key [2 ];
    w2 = postion_key[3 ] ^ postion_key [4 ];
    w3 = postion_key[5 ] ^ postion_key [6 ];
    w4 = postion_key[7 ] ^ postion_key [8 ];
    w5 = postion_key[9 ] ^ postion_key [10];
    w6 = postion_key[11] ^ postion_key [12];
    w7 = postion_key[13] ^ postion_key [14];

    w8  = w1 ^ postion_key [15];
    w9  = w2 ^ w3;
    w10 = w4 ^ w5;
    w11 = w6 ^ w7;
    
    w12 = w8 ^ w9;
    w13 = w10 ^ w11;

    w14 = w12 ^ w13;
end
always @(*) begin

    fixed_value = IN_code;
    if(w14 != 0)begin
        fixed_value [IP_BIT +4-w14 ] = !IN_code[IP_BIT +4-w14 ];
    end


    temp_value = {fixed_value[IP_BIT + 1],fixed_value[IP_BIT -1 : IP_BIT -3],fixed_value[IP_BIT -5 : 0]};
    OUT_code = temp_value[IP_BIT -1:0];
    /*fixed_value = correct_value;
    fixed_value [IP_BIT -w14 +1] = !correct_value [IP_BIT -w14 +1];
    if(w14 == 0)begin
        
    end
    else begin
        OUT_code = fixed_value;
    end*/
end

endmodule