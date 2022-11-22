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

  localparam INITIAL_QUESTION = 16'b0000_0001_0010_0011;
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
  reg [3:0] ref_question[3:0];

  reg av;
  reg ar;
  reg [15:0] temp_question;

  assign sum = ball + strike;
  assign question = temp_question;
  assign ask_valid = av;
  assign ask_ready = ar;
  
  // always @(ref_question[3], ref_question[2], ref_question[1], ref_question[0])
  //   $display("question : %d%d%d%d", ref_question[3], ref_question[2], ref_question[1], ref_question[0]);
  always @(sum)       $display("sum : %d", sum);
  always @(ref_sum)   $display("ref_sum : %d", ref_sum);
  always @(state)     $display("state : %d", state);
  always @(ref_question[3], ref_question[2], ref_question[1], ref_question[0])
                      $display("ref_q : %d%d%d%d", ref_question[3], ref_question[2], ref_question[1], ref_question[0]);
  always @(question)  $display("quest : %h", question);

  always @(posedge clk) begin
    if (!reset) begin
      temp_question <= 15'd0;
      av <= 1'b0;
      ar <= 1'b1;

      counter <= 0;
      ref_sum <= 0;
      state <= S0;
      comb_state <= 5'd1;
      temp_question <= 0;
      ref_question[0] <= 0;
      ref_question[1] <= 0;
      ref_question[2] <= 0;
      ref_question[3] <= 0;
    end
    else begin
      case (state)
        // send initial question (0123) to the grader
        S0 : begin
          if (!reply_valid && !ask_valid) begin
            av <= 1'b1;
            ar <= 1'b0;
            temp_question <= INITIAL_QUESTION;
          end
          
          if (reply_ready && !reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (reply_valid) begin
            ref_sum <= sum;

            ref_question[3] <= question[15:12];
            ref_question[2] <= question[11:8];
            ref_question[1] <= question[7:4];
            ref_question[0] <= question[3:0];

            if (sum == 3'd4)
              state <= S5;
            else
              state <= S1;
          end
        end

        // change the first position number and find the change of sum
        S1 : begin
          if (!reply_valid && !ask_valid) begin
            if (counter < 4'd10) begin
              counter = counter + 1;
              while ((counter == ref_question[3]) || (counter == ref_question[2]) 
                    || (counter == ref_question[1]) || (counter == ref_question[0])
                    && (counter+1 < 4'd10))
                counter = counter + 1;
              av <= 1'b1;
              ar <= 1'b0;
              temp_question <= {counter, ref_question[2], ref_question[1], ref_question[0]};
            end
          end  
          
          if (reply_ready && !reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (reply_valid) begin
            if (sum == 3'd4) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S5;
              ref_sum <= sum;
              counter <= 0;
            end
            else if (sum > ref_sum) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S2;
              ref_sum <= sum;
              counter <= 0;
            end
            else if (counter == 4'd9) begin
              state <= S2;
              counter <= 0;
            end
            else state <= S1;
          end
        end

        // change the second position number and find the change of sum
        S2 : begin
          if (!reply_valid && !ask_valid) begin
            if (counter < 4'd10) begin
              counter = counter + 1;
              while ((counter == ref_question[3]) || (counter == ref_question[2]) 
                    || (counter == ref_question[1]) || (counter == ref_question[0])
                    && (counter+1 < 4'd10))
                counter = counter + 1;
              av <= 1'b1;
              ar <= 1'b0;
              temp_question <= {ref_question[3], counter, ref_question[1], ref_question[0]};
            end
          end  
          
          if (reply_ready && !reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (reply_valid) begin
            if (sum == 3'd4) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S5;
              ref_sum <= sum;
              counter <= 0;
            end
            else if (sum > ref_sum) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S3;
              ref_sum <= sum;
              counter <= 0;
            end
            else if (counter == 4'd9) begin
              state <= S3;
              counter <= 0;
            end
            else state <= S2;
          end
        end

        // change the third position number and find the change of sum
        S3 : begin
          if (!reply_valid && !ask_valid) begin
            if (counter < 4'd10) begin
              counter = counter + 1;
              while ((counter == ref_question[3]) || (counter == ref_question[2]) 
                    || (counter == ref_question[1]) || (counter == ref_question[0])
                    && (counter+1 < 4'd10))
                counter = counter + 1;
              av <= 1'b1;
              ar <= 1'b0;
              temp_question <= {ref_question[3], ref_question[2], counter, ref_question[0]};
            end
          end  
          
          if (reply_ready && !reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (reply_valid) begin
            if (sum == 3'd4) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S5;
              ref_sum <= sum;
              counter <= 0;
            end
            else if (sum > ref_sum) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S4;
              ref_sum <= sum;
              counter <= 0;
            end
            else if (counter == 4'd9) begin
              state <= S4;
              counter <= 0;
            end
            else state <= S3;
          end
        end

        S4 : begin
          if (!reply_valid && !ask_valid) begin
            if (counter <= 4'd10) begin
              counter = counter + 1;
              while ((counter == ref_question[3]) || (counter == ref_question[2]) 
                    || (counter == ref_question[1]) || (counter == ref_question[0])
                    && (counter+1 < 4'd10))
                counter = counter + 1;
              av <= 1'b1;
              ar <= 1'b0;
              temp_question <= {ref_question[3], ref_question[2], ref_question[1], counter};
            end
          end  
          
          if (reply_ready && !reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (reply_valid) begin
            if (sum == 3'd4) begin
              ref_question[3] <= question[15:12];
              ref_question[2] <= question[11:8];
              ref_question[1] <= question[7:4];
              ref_question[0] <= question[3:0];

              state <= S5;
              ref_sum <= sum;
              counter <= 0;
            end
            else state <= S4;
          end
        end

        S5 : begin
          if (!reply_valid && !ask_valid) begin
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

          if (reply_ready && !reply_valid) begin
            av <= 1'b0;
            ar <= 1'b1;
          end

          if (reply_valid)
            if (!(correct)) 
              if (comb_state < 24)
                comb_state <= comb_state + 1;
        end
      endcase
    end
  end
endmodule



