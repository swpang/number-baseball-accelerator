module solver(
  input wire reset,
  input wire clk,
  input wire reply_valid,
  input wire reply_ready,
  input wire correct,
  input wire [15:0] cnt,
  input wire [2:0] strike,
  input wire [2:0] ball,
  output wire [15:0] question,
  output wire ask_valid,
  output wire ask_ready
  );

  localparam S0 = 3'b000,
             S1 = 3'b001,
             S2 = 3'b010,
             S3 = 3'b011,
             S4 = 3'b100,
             S5 = 3'b101;

  wire [2:0] state;
  reg [2:0] sum;
  reg [2:0] ref_sum;
  wire [3:0] counter;

  always @(posedge clk) cnt <= cnt + 1;

  assign sum = strike + ball;

  always @(posedge clk) begin
    if (!reset) begin
      question <= 15'd0;
      ask_valid <= 1'b0;
      ask_ready <= 1'b1;

      counter <= 1;
      sum <= 0;
      ref_sum <= 0;
      state <= S0;
    end
    else begin
      case (state)
        S0 : begin
          // send initial question (0123) to the grader
          if (reply_ready & !reply_valid) begin
            ask_valid <= 1'b1;
            ask_ready <= 1'b0;

            question <= 15'd0123;
          end
          // if reply is valid, check the response from the grader
          else if (reply_valid) begin
            ask_valid <= 1'b0;
            ask_ready <= 1'b1;

            ref_sum <= sum;
          end

          if (sum == 3'd4)            state <= S5;
          else                        state <= S1;
        end

        S1 : begin
          // change the first position number and find the change of sum
          if (reply_ready & !reply_valid) begin
            if (counter < 4'd10) begin
              counter <= counter + 1;
              if ((counter == question[15:12] - 1) || (counter == question[11:8] - 1) || (counter == question[7:4] - 1) || (counter == question[3:0] - 1))
                counter <= counter + 1;
              else begin
                ask_valid <= 1'b1;
                ask_ready <= 1'b0;
                question[15:12] <= counter;
              end
          end

          else if (reply_valid) begin
            ask_valid <= 1'b0;
            ask_ready <= 1'b1;
          end

          if (sum == 3'd4) begin
            state <= S5;
            counter <= 0;
          end
          else if (sum > ref_sum) begin
            state <= S2;
            ref_sum <= sum;
            counter <= 0;
          end
          else if (sum <= ref_sum)       state <= S1;
        end

        S2 : begin
          // change second position number and find the change of sum
          if (reply_ready && !reply_valid) begin
            ask_valid <= 1'b1;
            ask_ready <= 1'b0;

            // ask question - change the second position

          end

          if (sum == 3'd4) begin
            state <= S5;

            

        end
      endcase
    end
  end



endmodule



