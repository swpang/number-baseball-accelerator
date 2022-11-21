`timescale 1ns/1ps

module tb_nba;

  localparam NUM_ROUND = 1024;
  localparam period = 10;
  localparam delta = 0.001;

  reg clk;
  reg reset;
  reg [15:0] answer;

  wire [15:0] question, cnt;
  wire reply_ready, reply_valid, ask_ready, ask_valid, correct;
  wire [2:0] strike, ball;

  solver solver(
    .reset(reset),
    .clk(clk),
    .reply_ready(reply_ready),
    .reply_valid(reply_valid),
    .correct(correct),
    .cnt(cnt),
    .strike(strike),
    .ball(ball),
    .question(question),
    .ask_valid(ask_valid),
    .ask_ready(ask_ready)
    );

  grader grader(
    .reset(reset),
    .clk(clk),
    .answer(answer),
    .question(question),
    .ask_valid(ask_valid),
    .ask_ready(ask_ready),
    .strike(strike),
    .ball(ball),
    .cnt(cnt),
    .reply_ready(reply_ready),
    .reply_valid(reply_valid),
    .correct(correct)
    );

  reg [15:0]answers[NUM_ROUND-1:0];
  reg [63:0] ccnt[NUM_ROUND-1:0];
  real avg_ccnt;
  integer i;
  integer fd;

  initial clk = 1'b0;
  always  #(period/2) clk = ~clk;

  `define STUDENT_ID "2022-31086"
  `define LOG_PATH {"../logs/", `STUDENT_ID, ".log"}
  initial begin
    $timeformat(-9, 0, "ns", 0);
    fd = $fopen(`LOG_PATH, "w");
    $readmemh("../data/answers.txt", answers, 0, NUM_ROUND-1);

    for (i=0; i<NUM_ROUND; i=i+1) begin
      reset = 0;
      answer = answers[i];
      @(posedge clk);
      #(delta);
      reset = 1;
      @(posedge correct, (cnt == 200));
      #(delta);
      ccnt[i] = cnt;
      $fwrite(fd, "%4t round : %4d, answer : %4h, ccnt : %4d\n", $time, i, answers[i], ccnt[i]);
    end

    avg_ccnt = 0.0;
    for(i=0; i<NUM_ROUND; i=i+1) begin
      avg_ccnt = avg_ccnt + ccnt[i];
    end
    avg_ccnt = avg_ccnt / NUM_ROUND;
    $fwrite(fd, "avg ccnt : %f\n", avg_ccnt);

    #(period);
    $fclose(fd);
    $stop;
  end

endmodule
