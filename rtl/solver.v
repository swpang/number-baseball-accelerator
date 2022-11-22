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

  localparam INITIAL_QUESTION = 15'd0123;
  localparam S0 = 3'b000,
             S1 = 3'b001,
             S2 = 3'b010,
             S3 = 3'b011,
             S4 = 3'b100,
             S5 = 3'b101;

  reg [2:0] state;
  reg [4:0] comb_state;
  wire [2:0] sum;
  reg [2:0] ref_sum;
  reg [3:0] counter;

  reg integer ref_question[3:0];
  
  reg av;
  reg ar;
  reg [15:0] temp_question;

  assign sum = strike + ball;
  assign question = temp_question;

  assign ask_valid = av;
  assign ask_ready = ar;
  
  always @(temp_question) $display("question : %d", temp_question);

  always @(posedge clk) begin
    if (!reset) begin
      temp_question <= 15'd0;
      av <= 1'b0;
      ar <= 1'b1;

      counter <= 0;
      ref_sum <= 0;
      state <= S0;
      comb_state <= 5'd1;
      temp_question <= 15'd0;
      ref_question[0] <= 0;
      ref_question[1] <= 0;
      ref_question[2] <= 0;
      ref_question[3] <= 0;
    end
    else begin
      case (state)
        S0 : begin
          // send initial question (0123) to the grader
          if (reply_ready & !reply_valid) begin
            av <= 1'b1;
            ar <= 1'b0;

            temp_question <= INITIAL_QUESTION;
          end
          // if reply is valid, check the response from the grader
          else if (reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;

            ref_sum <= sum;
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];

            state <= S1;
          end

          if (sum == 3'd4)            state <= S5;
        end

        S1 : begin
          // change the first position number and find the change of sum
          if (reply_ready & !reply_valid) begin
            if (counter < 4'd10) begin
              counter <= counter + 1;
              if ((counter == question[15:12] - 1) || (counter == question[11:8] - 1) || (counter == question[7:4] - 1) || (counter == question[3:0] - 1))
                counter <= counter + 1;
              else begin
                av <= 1'b1;
                ar <= 1'b0;
                temp_question[15:12] <= counter;
              end
            end
          end
          else if (reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          // Conditions for changing state
          // when sum == 4, immediately move to step 6
          if (sum == 3'd4) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S5;
            ref_sum <= sum;
            counter <= 0;
          end
          // when the sum improves compared to the reference sum, fix the question and move to next step
          else if (sum > ref_sum) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S2;
            ref_sum <= sum;
            counter <= 0;
          end
          else if (sum < ref_sum) begin
            state <= S1;
          end
          // when the counter reaches the end of all possible digits and nothing has changed
          // keep the original question and move to next state
          else if (counter == 4'd9) begin
            temp_question[15:12] <= ref_question[3];
            temp_question[11:8] <= ref_question[2];
            temp_question[7:4] <= ref_question[1];
            temp_question[3:0] <= ref_question[0];
            state <= S2;
            counter <= 0;
          end
        end

        S2 : begin
          // change second position number and find the change of sum
          if (reply_ready & !reply_valid) begin
            if (counter < 4'd10) begin
              counter <= counter + 1;
              if ((counter == question[15:12] - 1) || (counter == question[11:8] - 1) || (counter == question[7:4] - 1) || (counter == question[3:0] - 1))
                counter <= counter + 1;
              else begin
                av <= 1'b1;
                ar <= 1'b0;
                temp_question[11:8] <= counter;
              end
            end
          end
          else if (reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          // Conditions for changing state
          // when sum == 4, immediately move to step 6
          if (sum == 3'd4) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S5;
            ref_sum <= sum;
            counter <= 0;
          end
          // when the sum improves compared to the reference sum, fix the question and move to next step
          else if (sum > ref_sum) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S3;
            ref_sum <= sum;
            counter <= 0;
          end
          else if (sum < ref_sum) begin
            state <= S2;
          end
          // when the counter reaches the end of all possible digits and nothing has changed
          // keep the original question and move to next state
          else if (counter == 4'd9) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S3;
            counter <= 0;
          end
        end

        S3 : begin
          // change second position number and find the change of sum
          if (reply_ready & !reply_valid) begin
            if (counter < 4'd10) begin
              counter <= counter + 1;
              if ((counter == question[15:12] - 1) || (counter == question[11:8] - 1) || (counter == question[7:4] - 1) || (counter == question[3:0] - 1))
                counter <= counter + 1;
              else begin
                av <= 1'b1;
                ar <= 1'b0;
                temp_question[7:4] <= counter;
              end
            end
          end
          else if (reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          // Conditions for changing state
          // when sum == 4, immediately move to step 6
          if (sum == 3'd4) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S5;
            ref_sum <= sum;
            counter <= 0;
          end
          // when the sum improves compared to the reference sum, fix the question and move to next step
          else if (sum > ref_sum) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S4;
            ref_sum <= sum;
            counter <= 0;
          end
          else if (sum < ref_sum) begin
            state <= S3;
          end
          // when the counter reaches the end of all possible digits and nothing has changed
          // keep the original question and move to next state
          else if (counter == 4'd9) begin
            temp_question[15:12] <= ref_question[3];
            temp_question[11:8] <= ref_question[2];
            temp_question[7:4] <= ref_question[1];
            temp_question[3:0] <= ref_question[0];
            state <= S4;
            counter <= 0;
          end
        end

        S4 : begin
          // change second position number and find the change of sum
          if (reply_ready & !reply_valid) begin
            if (counter < 4'd10) begin
              counter <= counter + 1;
              if ((counter == question[15:12] - 1) || (counter == question[11:8] - 1) || (counter == question[7:4] - 1) || (counter == question[3:0] - 1))
                counter <= counter + 1;
              else begin
                av <= 1'b1;
                ar <= 1'b0;
                temp_question[3:0] <= counter;
              end
            end
          end
          else if (reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          // Conditions for changing state
          // when sum == 4, move to step 6
          if (sum == 3'd4) begin
            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];
            state <= S5;
            ref_sum <= sum;
            counter <= 0;
          end
        end

        S5 : begin
          if (reply_ready & !reply_valid) begin
            av <= 1'b1;
            ar <= 1'b0;

            case (comb_state) 
              5'd1 : begin
                temp_question[15:12] <= ref_question[3];
                temp_question[11:8]  <= ref_question[2];
                temp_question[7:4]   <= ref_question[1];
                temp_question[3:0]   <= ref_question[0];
              end

              5'd2 : begin
                temp_question[15:12] <= ref_question[3];
                temp_question[11:8]  <= ref_question[2];
                temp_question[7:4]   <= ref_question[0];
                temp_question[3:0]   <= ref_question[1];
              end

              5'd3 : begin
                temp_question[15:12] <= ref_question[3];
                temp_question[11:8]  <= ref_question[1];
                temp_question[7:4]   <= ref_question[2];
                temp_question[3:0]   <= ref_question[0];
              end

              5'd4 : begin
                temp_question[15:12] <= ref_question[3];
                temp_question[11:8]  <= ref_question[1];
                temp_question[7:4]   <= ref_question[0];
                temp_question[3:0]   <= ref_question[2];
              end

              5'd5 : begin
                temp_question[15:12] <= ref_question[3];
                temp_question[11:8]  <= ref_question[0];
                temp_question[7:4]   <= ref_question[2];
                temp_question[3:0]   <= ref_question[1];
              end

              5'd6 : begin
                temp_question[15:12] <= ref_question[3];
                temp_question[11:8]  <= ref_question[0];
                temp_question[7:4]   <= ref_question[1];
                temp_question[3:0]   <= ref_question[2];
              end

              5'd7 : begin
                temp_question[15:12] <= ref_question[2];
                temp_question[11:8]  <= ref_question[3];
                temp_question[7:4]   <= ref_question[1];
                temp_question[3:0]   <= ref_question[0];
              end

              5'd8 : begin
                temp_question[15:12] <= ref_question[2];
                temp_question[11:8]  <= ref_question[3];
                temp_question[7:4]   <= ref_question[0];
                temp_question[3:0]   <= ref_question[1];
              end

              5'd9 : begin
                temp_question[15:12] <= ref_question[2];
                temp_question[11:8]  <= ref_question[1];
                temp_question[7:4]   <= ref_question[3];
                temp_question[3:0]   <= ref_question[0];
              end

              5'd10 : begin
                temp_question[15:12] <= ref_question[2];
                temp_question[11:8]  <= ref_question[1];
                temp_question[7:4]   <= ref_question[0];
                temp_question[3:0]   <= ref_question[3];
              end

              5'd11 : begin
                temp_question[15:12] <= ref_question[2];
                temp_question[11:8]  <= ref_question[0];
                temp_question[7:4]   <= ref_question[3];
                temp_question[3:0]   <= ref_question[1];
              end

              5'd12 : begin
                temp_question[15:12] <= ref_question[2];
                temp_question[11:8]  <= ref_question[0];
                temp_question[7:4]   <= ref_question[1];
                temp_question[3:0]   <= ref_question[3];
              end

              5'd13 : begin
                temp_question[15:12] <= ref_question[1];
                temp_question[11:8]  <= ref_question[3];
                temp_question[7:4]   <= ref_question[2];
                temp_question[3:0]   <= ref_question[0];
              end

              5'd14 : begin
                temp_question[15:12] <= ref_question[1];
                temp_question[11:8]  <= ref_question[3];
                temp_question[7:4]   <= ref_question[0];
                temp_question[3:0]   <= ref_question[2];
              end

              5'd15 : begin
                temp_question[15:12] <= ref_question[1];
                temp_question[11:8]  <= ref_question[2];
                temp_question[7:4]   <= ref_question[3];
                temp_question[3:0]   <= ref_question[0];
              end

              5'd16 : begin
                temp_question[15:12] <= ref_question[1];
                temp_question[11:8]  <= ref_question[2];
                temp_question[7:4]   <= ref_question[0];
                temp_question[3:0]   <= ref_question[3];
              end

              5'd17 : begin
                temp_question[15:12] <= ref_question[1];
                temp_question[11:8]  <= ref_question[0];
                temp_question[7:4]   <= ref_question[3];
                temp_question[3:0]   <= ref_question[2];
              end

              5'd18 : begin
                temp_question[15:12] <= ref_question[1];
                temp_question[11:8]  <= ref_question[0];
                temp_question[7:4]   <= ref_question[2];
                temp_question[3:0]   <= ref_question[3];
              end

              5'd19 : begin
                temp_question[15:12] <= ref_question[0];
                temp_question[11:8]  <= ref_question[3];
                temp_question[7:4]   <= ref_question[2];
                temp_question[3:0]   <= ref_question[1];
              end

              5'd20 : begin
                temp_question[15:12] <= ref_question[0];
                temp_question[11:8]  <= ref_question[3];
                temp_question[7:4]   <= ref_question[1];
                temp_question[3:0]   <= ref_question[2];
              end

              5'd21 : begin
                temp_question[15:12] <= ref_question[0];
                temp_question[11:8]  <= ref_question[2];
                temp_question[7:4]   <= ref_question[3];
                temp_question[3:0]   <= ref_question[1];
              end

              5'd22 : begin
                temp_question[15:12] <= ref_question[0];
                temp_question[11:8]  <= ref_question[2];
                temp_question[7:4]   <= ref_question[1];
                temp_question[3:0]   <= ref_question[3];
              end

              5'd23 : begin
                temp_question[15:12] <= ref_question[0];
                temp_question[11:8]  <= ref_question[1];
                temp_question[7:4]   <= ref_question[3];
                temp_question[3:0]   <= ref_question[2];
              end

              5'd24 : begin
                temp_question[15:12] <= ref_question[0];
                temp_question[11:8]  <= ref_question[1];
                temp_question[7:4]   <= ref_question[2];
                temp_question[3:0]   <= ref_question[3];
              end
            endcase
          end
          else if (reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (!(sum == 4)) 
            if (comb_state < 24)
              comb_state <= comb_state + 1;
        end
      endcase
    end
  end



endmodule



