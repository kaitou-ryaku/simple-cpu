`define MEMSIZE 64

`define PAR_CLOCK 20_000_000
module top( input CLK100MHZ, input RESET, output reg [7:0] OUT);

  logic [26:0] counter;
  logic CLOCK;

  always_comb begin
    if (counter < `PAR_CLOCK / 2) CLOCK = 0;
    else                          CLOCK = 1;
  end

  always @(posedge CLK100MHZ) begin
    if (RESET | counter < `PAR_CLOCK) counter <= counter + 1;
    else                              counter <= 0;
  end

  cpu cpu_0(CLOCK, RESET, OUT);

endmodule

// テスト
module cpu( input CLOCK, input RESET, output reg [7:0] OUT);

  // メモリの宣言/*{{{*/
  logic [7:0] memory [`MEMSIZE-1:0];/*}}}*/
  // レジスタの宣言/*{{{*/
  logic [7:0] a;  // reg
  logic [7:0] b;  // reg
  logic [7:0] c;  // reg
  logic [7:0] d;  // reg
  logic [7:0] sp; // reg
  logic [7:0] ip; // reg
  logic zf;       // reg
  /*}}}*/
  // メモリ直前のワイヤの宣言/*{{{*/
  logic                write_flag;
  logic [`MEMSIZE-1:0] write_addr;
  logic [7:0]          write_value;/*}}}*/
  // レジスタ直前のワイヤの宣言/*{{{*/
  logic [7:0] next_a;   // wire
  logic [7:0] next_b;   // wire
  logic [7:0] next_c;   // wire
  logic [7:0] next_d;   // wire
  logic [7:0] next_sp;  // wire
  logic [7:0] next_ip;  // wire
  logic next_zf;        // wire/*}}}*/
  // ワイヤを更新/*{{{*/
  make_next_reg make_next_reg_0(
    memory, write_flag, write_addr, write_value
    ,      a,      b,      c,      d,      sp,      ip,      zf
    , next_a, next_b, next_c, next_d, next_sp, next_ip, next_zf
  );/*}}}*/
  // フリップフロップを更新/*{{{*/
  always @(posedge CLOCK) begin
    case(RESET)
      // リセットOFFで通常更新
      1'b0: begin
        // メモリの更新/*{{{*/
        case(write_flag)
          1'b1: begin
            memory[write_addr] <= write_value[7:0];
          end
          default:;
        endcase/*}}}*/
        // レジスタの更新/*{{{*/
        OUT <= next_a;
        a   <= next_a;
        b   <= next_b;
        c   <= next_c;
        d   <= next_d;
        sp  <= next_sp;
        ip  <= next_ip;
        zf  <= next_zf;/*}}}*/
      end

      // リセットONの場合
      1'b1: begin $display("RESET ON");
        // メモリの初期化/*{{{*/
        // フィボナッチ数の計算
        memory[ 0] <= 8'b01000000; // mov a, 1
        memory[ 1] <= 8'b00000001;
        memory[ 2] <= 8'b01000100; // mov b, 1
        memory[ 3] <= 8'b00000001;
        memory[ 4] <= 8'b01001000; // mov c, 0
        memory[ 5] <= 8'b00000000;
        memory[ 6] <= 8'b01001100; // mov d, 1
        memory[ 7] <= 8'b00000001;
        memory[ 8] <= 8'b00001001; // mov c, b
        memory[ 9] <= 8'b00000100; // mov b, a
        memory[10] <= 8'b00010010; // add a, c
        memory[11] <= 8'b01011100; // add d, 1
        memory[12] <= 8'b00000001;
        memory[13] <= 8'b01111100; // cmp d 0x9
        memory[14] <= 8'b00001001;
        memory[15] <= 8'b11100000; // jnz  LOOPBEGIN
        memory[16] <= 8'b11110111;
        memory[17] <= 8'b11110000; // hlt
        /*}}}*/
        // レジスタの初期化/*{{{*/
        OUT <= 8'h00;
        a   <= 8'h00;
        b   <= 8'h00;
        c   <= 8'h00;
        d   <= 8'h00;
        sp  <= `MEMSIZE;
        ip  <= 8'h00;
        zf  <= 1'b0; /*}}}*/
      end

      default: $display("Undefined Reset Button");
    endcase
  end/*}}}*/

endmodule
