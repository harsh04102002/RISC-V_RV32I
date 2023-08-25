`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2023 14:53:16
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module controller(  output reg [2:0] immsrc, 
                    output reg [3:0] alu_op, 
                    output reg [2:0] br_type, readcontrol, writecontrol,
                    output reg reg_wr, sel_A, sel_B, hlt,
                    output reg [1:0] wb_sel,
                    input[6:0] opcode,      
                    input [14:12] funct3,      
                    input [31:25] funct7,            
                    input rst);
                    
        
        reg R,Ii,S,L,B,auipc,lui,jal,jalr,halt;
        
        `define Type {R,Ii,S,L,B,auipc,lui,jal,jalr,halt}
        `define Control {immsrc,sel_A, sel_B,wb_sel,reg_wr,hlt}
        
        //instruction type determination
    always@(*)begin    
        if (rst)
        begin
            `Type <= 0;
        end    
        else 
        begin
            case(opcode)//Type {R,Ii,S,L,B,auipc,lui,jal,jalr,halt}  Type     Description             ALU     sel_A   sel_B  wb_sel  imm_gen    br_type   alu_op  reg_wr      d_wr
                3:  `Type<=  'b0001000000;                         //L-Type   Load                    yes     1       1       2       0           none      0       1           0
                19: `Type<=  'b0100000000;                         //I-Type   immediate operation     yes     1       1       1       0           none      xxxx    1           0
                23: `Type<=  'b0000010000;                         //U-Type   auipc                   yes     0       1       1       3(u)        none      0       1           0
                35: `Type<=  'b0010000000;                         //S-Type   Store                   yes     1       1       z       1           none      0       0           1
                51: `Type<=  'b1000000000;                         //R-Type   register operation      yes     1       0       1       z           none      xxxx    1           0
                55: `Type<=  'b0000001000;                         //U-Type   lui                     yes     1       1       1       4(u)        none      copy    1           0
                93: `Type<=  'b0000000001;			               //HALT     HALT
		        99: `Type<=  'b0000100000;                         //B-Type   conditional branch      yes     0       1       z       2           xxx       0       0           0
                103:`Type<=  'b0000000010;                          //I-Type   jalr                   yes     1       1       0       0           uncond    0       1           0
                111:`Type<=  'b0000000100;                          //J-Type   jal                    yes     0       1       0       3           uncond    0       1           0
                default:`Type<= 'b0000000000;
            endcase    
        end
    end
    
     //alu control signals
        always@(*)begin
        if(R||Ii) begin
            casex({R,funct7[30],funct7[25],funct3})//does not? cater for some Immediate instructions with fulty opcode
                6'b100000:  alu_op <= 0;  //add
                6'b110000:  alu_op <= 1;  //sub
                6'b000000:  alu_op <= 0;  //addi
                6'b100001:  alu_op <= 5;  //sll
                6'b000001:  alu_op <= 5;  //slli
                6'b100010:  alu_op <= 9;  //slt
                6'b000010:  alu_op <= 9;  //slti
                6'b100011:  alu_op <= 8;  //sltu
                6'b000011:  alu_op <= 8;  //sltiu
                6'b100100:  alu_op <= 2;  //xor
                6'b000100:  alu_op <= 2;  //xori
                6'b100101:  alu_op <= 6;  //srl
                6'b000101:  alu_op <= 6;  //srli
                6'b110101:  alu_op <= 7;  //sra
                6'b010101:  alu_op <= 7;  //srai
                6'b100110:  alu_op <= 3;//or
                6'b000110:  alu_op <= 3;//ori
                6'b100111:  alu_op <= 4;//and
                6'b000111:  alu_op <= 4;//andi
                default:    alu_op <= 0;
            endcase    
        end
        else if(lui)begin
            alu_op <= 10;   //aluop for result=B
        end
        else begin
            alu_op <= 0;    //all other instructions use operation A+B of ALU
        end            
    end
   
   
   //data memory operation
    always @(*) begin     //for WriteControl
        case ({S})
            1: writecontrol <= funct3;
            default: writecontrol <= 7;  //retain current value
        endcase
    end

    always @(*) begin//for ReadControl
        case ({L})
            1: readcontrol <= funct3;
            default: readcontrol <= 7; //output 0
        endcase
    end
   
   
   //branch instruction
       always @(*) begin    //for br_type
        casex({jal,jalr,B})
            3'b100: br_type <= 3 ;
            3'b010: br_type <= 3 ;//jal,jalr
            3'b001: br_type <= funct3 ;
            default: br_type <= 2; //no jump
        endcase
    end
    
    //vontrol signals
    
     always@(*)begin
        case(`Type)     //Type {R,Ii,S,L,B,auipc,lui,jal,jalr,hlt}
                        //Control {ImmSrc,sel_A, sel_B,wb_sel,reg_wr,hlt}
            10'b1000000000: `Control <= 9'b000100110;//R
            10'b0100000000: `Control <= 9'b000110110;//Ii
            10'b0010000000: `Control <= 9'b001110000;//S
            10'b0001000000: `Control <= 9'b000111010;//L
            10'b0000100000: `Control <= 9'b010010000;//B
            10'b0000010000: `Control <= 9'b011010110;//auipc
            10'b0000001000: `Control <= 9'b011110110;//lui
            10'b0000000100: `Control <= 9'b100010010;//jal
            10'b0000000010: `Control <= 9'b000110010;//jalr
	        10'b0000000001: `Control <= 9'b000000001;//HALT
            default: `Control<=0;
        endcase
    end
endmodule

