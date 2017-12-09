`define MEMSIZE 64

module make_next_reg(

  input    reg  [7:0] memory [`MEMSIZE-1:0]
  , output wire                write_flag
  , output wire [`MEMSIZE-1:0] write_addr
  , output wire [7:0]          write_value
  , input  reg  [7:0] a
  , input  reg  [7:0] b
  , input  reg  [7:0] c
  , input  reg  [7:0] d
  , input  reg  [7:0] sp
  , input  reg  [7:0] ip
  , input  reg        zf
  , output wire [7:0] next_a
  , output wire [7:0] next_b
  , output wire [7:0] next_c
  , output wire [7:0] next_d
  , output wire [7:0] next_sp
  , output wire [7:0] next_ip
  , output wire       next_zf
);

  // 出力をendのワイヤーに変換/*{{{*/
  logic [7:0] end_a;
  logic [7:0] end_c;
  logic [7:0] end_d;
  logic [7:0] end_b;
  logic [7:0] end_sp;
  logic [7:0] end_ip;
  logic       end_zf;

  assign next_a  = end_a;
  assign next_c  = end_c;
  assign next_d  = end_d;
  assign next_b  = end_b;
  assign next_sp = end_sp;
  assign next_ip = end_ip;
  assign next_zf = end_zf ;

  logic                 end_write_flag ;
  logic [`MEMSIZE-1:0]  end_write_addr ;
  logic [7:0]           end_write_value;

  assign write_flag   = end_write_flag ;
  assign write_addr   = end_write_addr ;
  assign write_value  = end_write_value;
  /*}}}*/

  // オペコードのワイヤーをあらかじめ定義
  logic [7:0] ope;
  assign ope [7:0] = memory[ip];

  // 即値のワイヤーをあらかじめ定義
  logic [7:0] imm;
  assign imm [7:0] = memory[ip+1];

  // スタックのワイヤーをあらかじめ定義
  logic  [7:0] stack;
  assign stack = memory[sp];

  // オペランドのワイヤー
  logic [7:0] y;

  // endのワイヤーを作る
  always_comb begin

    // yをあらかじめ定義/*{{{*/
    case (ope[1:0])
      2'b00: y = a;
      2'b01: y = b;
      2'b10: y = c;
      2'b11: y = d;
    endcase/*}}}*/

    // endワイヤーを作る
    case (ope[7])
      1'b0: begin                     // 計算関係命令   mov,  add, sub, cmp/*{{{*/
        end_sp          = sp;
        end_write_flag  = 0;
        end_write_addr  = 0;
        end_write_value = 0;

        case (ope[6])
          1'b0: begin                 // ope x, y
            end_ip = ip + 1;
            case (ope[5:4])
              2'b00: begin            // mov x, y/*{{{*/
                end_zf = zf;
                case (ope[3:2])
                  2'b00: begin        // mov a, y
                    end_a = y;
                    end_b = b;
                    end_c = c;
                    end_d = d;
                  end

                  2'b01: begin        // mov b, y
                    end_a = a;
                    end_b = y;
                    end_c = c;
                    end_d = d;
                  end

                  2'b10: begin        // mov c, y
                    end_a = a;
                    end_b = b;
                    end_c = y;
                    end_d = d;
                  end

                  2'b11: begin        // mov d, y
                    end_a = a;
                    end_b = b;
                    end_c = c;
                    end_d = y;
                  end
                endcase
              end/*}}}*/
              2'b01: begin            // add x, y/*{{{*/
                end_zf = zf;
                case (ope[3:2])
                  2'b00: begin        // add a, y
                    end_a = a + y;
                    end_b = b;
                    end_c = c;
                    end_d = d;
                  end

                  2'b01: begin        // add b, y
                    end_a = a;
                    end_b = b + y;
                    end_c = c;
                    end_d = d;
                  end

                  2'b10: begin        // add c, y
                    end_a = a;
                    end_b = b;
                    end_c = c + y;
                    end_d = d;
                  end

                  2'b11: begin        // add d, y
                    end_a = a;
                    end_b = b;
                    end_c = c;
                    end_d = d + y;
                  end
                endcase
              end/*}}}*/
              2'b10: begin            // sub x, y/*{{{*/
                end_zf = zf;
                case (ope[3:2])
                  2'b00: begin        // sub a, y
                    end_a = a - y;
                    end_b = b;
                    end_c = c;
                    end_d = d;
                  end

                  2'b01: begin        // sub b, y
                    end_a = a;
                    end_b = b - y;
                    end_c = c;
                    end_d = d;
                  end

                  2'b10: begin        // sub c, y
                    end_a = a;
                    end_b = b;
                    end_c = c - y;
                    end_d = d;
                  end

                  2'b11: begin        // sub d, y
                    end_a = a;
                    end_b = b;
                    end_c = c;
                    end_d = d - y;
                  end
                endcase
              end/*}}}*/
              2'b11: begin            // cmp x, y/*{{{*/
                end_a = a;
                end_b = b;
                end_c = c;
                end_d = d;
                case (ope[3:2])
                  2'b00: end_zf = a-y ? 0 : 1; // cmp a, y
                  2'b01: end_zf = b-y ? 0 : 1; // cmp b, y
                  2'b10: end_zf = c-y ? 0 : 1; // cmp c, y
                  2'b11: end_zf = d-y ? 0 : 1; // cmp d, y
                endcase
              end/*}}}*/
            endcase
          end

          1'b1: begin                 // ope x, imm
            end_ip = ip + 2;
            case (ope[5:4])
              2'b00: begin            // mov x, imm/*{{{*/
                end_zf = zf;
                case (ope[3:2])
                  2'b00: begin        // mov a, imm
                    end_a = imm;
                    end_b = b;
                    end_c = c;
                    end_d = d;
                  end

                  2'b01: begin        // mov b, imm
                    end_a = a;
                    end_b = imm;
                    end_c = c;
                    end_d = d;
                  end

                  2'b10: begin        // mov c, imm
                    end_a = a;
                    end_b = b;
                    end_c = imm;
                    end_d = d;
                  end

                  2'b11: begin        // mov d, imm
                    end_a = a;
                    end_b = b;
                    end_c = c;
                    end_d = imm;
                  end
                endcase
              end/*}}}*/
              2'b01: begin            // add x, imm/*{{{*/
                end_zf = zf;
                case (ope[3:2])
                  2'b00: begin        // add a, imm
                    end_a = a + imm;
                    end_b = b;
                    end_c = c;
                    end_d = d;
                  end

                  2'b01: begin        // add b, imm
                    end_a = a;
                    end_b = b + imm;
                    end_c = c;
                    end_d = d;
                  end

                  2'b10: begin        // add c, imm
                    end_a = a;
                    end_b = b;
                    end_c = c + imm;
                    end_d = d;
                  end

                  2'b11: begin        // add d, imm
                    end_a = a;
                    end_b = b;
                    end_c = c;
                    end_d = d + imm;
                  end
                endcase
              end/*}}}*/
              2'b10: begin            // sub x, imm/*{{{*/
                end_zf = zf;
                case (ope[3:2])
                  2'b00: begin        // sub a, imm
                    end_a = a - imm;
                    end_b = b;
                    end_c = c;
                    end_d = d;
                  end

                  2'b01: begin        // sub b, imm
                    end_a = a;
                    end_b = b - imm;
                    end_c = c;
                    end_d = d;
                  end

                  2'b10: begin        // sub c, imm
                    end_a = a;
                    end_b = b;
                    end_c = c - imm;
                    end_d = d;
                  end

                  2'b11: begin        // sub d, imm
                    end_a = a;
                    end_b = b;
                    end_c = c;
                    end_d = d - imm;
                  end
                endcase
              end/*}}}*/
              2'b11: begin            // cmp x, imm/*{{{*/
                end_a = a;
                end_b = b;
                end_c = c;
                end_d = d;
                case (ope[3:2])
                  2'b00: end_zf = a-imm ? 0 : 1;       // cmp a, imm
                  2'b01: end_zf = b-imm ? 0 : 1;       // cmp b, imm
                  2'b10: end_zf = c-imm ? 0 : 1;       // cmp c, imm
                  2'b11: end_zf = d-imm ? 0 : 1;       // cmp d, imm
                endcase
              end/*}}}*/
            endcase
          end
        endcase

      end/*}}}*/
      1'b1: begin                     // メモリ関連の命令 push, pop, jmp, hlt/*{{{*/
        end_zf = zf;
        case (ope[6:4])
          3'b000: begin               // push/*{{{*/
            end_a  = a;
            end_b  = b;
            end_c  = c;
            end_d  = d;
            end_ip = ip + 1;
            end_sp = sp - 1;
            end_write_flag = 1;
            end_write_addr = sp-1;

            case (ope[3:2])
              2'b00: end_write_value = a; // push a
              2'b01: end_write_value = b; // push b
              2'b10: end_write_value = c; // push c
              2'b11: end_write_value = d; // push d
            endcase
          end/*}}}*/
          3'b001: begin               // pop/*{{{*/
            end_ip = ip + 1;
            end_sp = sp + 1;
            end_write_flag = 0;
            end_write_addr = 0;

            case (ope[3:2])
              2'b00: begin
                end_a = stack; // pop a
                end_b = b;
                end_c = c;
                end_d = d;
              end
              2'b01: begin
                end_a = a;
                end_b = stack; // pop b
                end_c = c;
                end_d = d;
              end
              2'b10: begin
                end_a = a;
                end_b = b;
                end_c = stack; // pop c
                end_d = d;
              end
              2'b11: begin
                end_a = a;
                end_b = b;
                end_c = c;
                end_d = stack; // pop d
              end
            endcase
          end/*}}}*/
          3'b100: begin               // jmp imm/*{{{*/
            end_a  = a;
            end_b  = b;
            end_c  = c;
            end_d  = d;
            end_sp = sp;
            end_ip = (ip + 2) + imm;
            end_write_flag  = 0;
            end_write_addr  = 0;
            end_write_value = 0;
          end/*}}}*/
          3'b101: begin               // jz imm/*{{{*/
            end_a  = a;
            end_b  = b;
            end_c  = c;
            end_d  = d;
            end_sp = sp;
            end_ip = zf ? ip+2+imm : ip+2;
            end_write_flag  = 0;
            end_write_addr  = 0;
            end_write_value = 0;
          end/*}}}*/
          3'b110: begin               // jnz imm/*{{{*/
            end_a  = a;
            end_b  = b;
            end_c  = c;
            end_d  = d;
            end_sp = sp;
            end_ip = zf ? ip+2 : ip+2+imm;
            end_write_flag  = 0;
            end_write_addr  = 0;
            end_write_value = 0;
          end/*}}}*/
          default: begin              // hlt imm/*{{{*/
            end_a  = a;
            end_b  = b;
            end_c  = c;
            end_d  = d;
            end_sp = sp;
            end_ip = ip;
            end_write_flag  = 0;
            end_write_addr  = 0;
            end_write_value = 0;
          end/*}}}*/
        endcase
      end/*}}}*/
    endcase
  end
endmodule

