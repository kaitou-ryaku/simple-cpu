`define MEMSIZE 64

// テスト
module cpu;
  logic CLOCK;
  logic RESET;
  logic [7:0] OUT;

  // メモリの宣言/*{{{*/
  logic [7:0] memory [`MEMSIZE-1:0];/*}}}*/
  // レジスタの宣言/*{{{*/
  logic [7:0] a; // reg
  logic [7:0] b; // reg
  logic [7:0] c; // reg
  logic [7:0] d; // reg
  logic [7:0] sp; // reg
  logic [7:0] ip; // reg
  logic zf;        // reg
  /*}}}*/
  // メモリ直前のワイヤの宣言/*{{{*/
  logic                write_flag;
  logic [`MEMSIZE-1:0] write_addr;
  logic [7:0]          write_value;/*}}}*/
  // レジスタ直前のワイヤの宣言/*{{{*/
  logic [7:0] next_a; // wire
  logic [7:0] next_b; // wire
  logic [7:0] next_c; // wire
  logic [7:0] next_d; // wire
  logic [7:0] next_sp; // wire
  logic [7:0] next_ip; // wire
  logic       next_zf; // wire/*}}}*/
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
        $readmemb("test.txt", memory);/*}}}*/
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

  // テスト/*{{{*/
  initial begin
    CLOCK = 1'b0;
    forever begin
      #5;
      CLOCK = ~ CLOCK;
    end
  end

  initial begin

    RESET = 1'b1;
    # 5;
    # 1;
    RESET = 1'b0;

    #8;

    #10;$display("0100 00 00 00000001 // mov  a, imm -- a=01");          assert(a === 1);
    #10;$display("0101 00 00 00000001 // add  a, imm -- a=10");          assert(a === 2);
    #10;$display("0110 00 00 00000001 // sub  a, imm -- a=01");          assert(a === 1);
    #10;$display("0111 00 00 00000001 // cmp  a, imm -- zf=1");          assert(zf  === 1);
    #10;$display("0111 00 00 00000010 // cmp  a, imm -- zf=0");          assert(zf  === 0);
    #10;$display("0000 01 00          // mov  b, a   -- a=01 b=01");     assert(a === 1 & b === 1);
    #10;$display("0001 00 01          // add  a, b   -- a=10 b=01");     assert(a === 2 & b === 1);
    #10;$display("0010 00 11          // sub  a, b   -- a=01 b=01");     assert(a === 1 & b === 1);
    #10;$display("0011 00 01          // cmp  a, b   -- jz=1");          assert(zf  === 1);
    #10;$display("1000 00 00          // push a      -- push 01");       assert(sp === `MEMSIZE-1 & memory[sp] === a);
    #10;$display("1001 10 00          // pop  c      -- pop  c");        assert(sp === `MEMSIZE   & c          === a);

    assert(ip + 3 === next_ip);
    #10;$display("1100 00 00 00000001 // jmp  imm    -- goto jz");

    assert(ip + 3 === next_ip & zf === 1);
    #10;$display("1101 00 00 00000001 // jz   imm    -- goto jz, zf=1");

    #10;$display("0111 00 00 00000000 // cmp  a, imm -- zf=0");
    assert(ip + 2 === next_ip & zf === 0);
    #10;$display("1101 00 00 00000001 // jz   imm    -- goto jz, zf=0");

    #10;$display("0100 00 00 11111111 // mov  a, imm -- a=-1");          assert(a === 8'b11111111);
    #10;$display("1100 00 00          // hlt");                          assert(a === 8'b11111111);
    #10;$display("0100 00 00 00000000 // mov  a, imm -- not executed");  assert(a === 8'b11111111);

    $stop;
  end/*}}}*/

endmodule
