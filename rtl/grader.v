module grader(
  input reset,
  input clk,
  input [15:0] answer,
  input [15:0] question,
  input ask_valid,
  input ask_ready,
  output [2:0] strike,
  output [2:0] ball,
  output reg [15:0] cnt,
  output wire reply_ready,
  output wire reply_valid,
  output correct
  );

reg [3:0] strike_reg, ball_reg;

reg reply_valid_int;
reg reply_ready_int;
reg [15:0] cnt_deadlock;

always @(*) begin
  if(ask_valid & reply_ready) begin
    $display("quest : %h", question);
  end
end

assign strike = (strike_reg[3] + strike_reg[2] + strike_reg[1] + strike_reg[0]);
assign ball = (ball_reg[3] + ball_reg[2] + ball_reg[1] + ball_reg[0]);
assign correct = (strike_reg[3] & strike_reg[2] & strike_reg[1] & strike_reg[0]);
assign reply_ready = reply_ready_int;
assign reply_valid = reply_valid_int;

// read channel
always @(posedge clk) begin
  if(!reset) begin
    reply_ready_int <= 1'b0;
  end else if(reply_valid & ~ask_ready) begin
    reply_ready_int <= 1'b0;
  end else if(ask_valid) begin
    reply_ready_int <= 1'b1;
  end else begin
    reply_ready_int <= 1'b0;
  end
end

// write channel
always @(posedge clk) begin
  if(!reset) begin
    reply_valid_int <= 1'b0;
  end else if(ask_valid & reply_ready) begin
    reply_valid_int <= 1'b1;
  end else if(ask_ready & reply_valid) begin
    reply_valid_int <= 1'b0;
  end
end

always @(posedge clk) begin
  if(!reset) begin
    cnt <= 16'd0;
  end else if(ask_valid & reply_ready) begin
    cnt <= cnt + 16'd1;
  end else if(cnt_deadlock == 200) begin
    cnt <= 200;
  end
end    

always @(posedge clk) begin
  if(!reset) begin
    cnt_deadlock <= 16'd0;
  end else if((ask_valid & reply_ready) | (ask_ready & reply_valid)) begin
    cnt_deadlock <= 16'd0;
  end else begin
    cnt_deadlock <= cnt_deadlock + 1;
  end
end    

always @(posedge clk) begin
    if(!reset) begin
      cnt <= 16'd0;
      strike_reg <= 4'b0;
      ball_reg <= 4'b0;
    end else begin
      if(ask_valid & reply_ready) begin
        // Check strike and ball //
        if(answer[15:12] == question[15:12]) begin
          strike_reg[0] <= 1'b1;
          ball_reg[0] <= 1'b0;
        end
        else if(answer[11:8] == question[15:12]) begin
          strike_reg[0] <= 1'b0;
          ball_reg[0] <= 1'b1;
        end 
        else if(answer[7:4] == question[15:12]) begin
          strike_reg[0] <= 1'b0;
          ball_reg[0] <= 1'b1;
        end 
        else if(answer[3:0] == question[15:12]) begin
          strike_reg[0] <= 1'b0;
          ball_reg[0] <= 1'b1;
        end 
        else begin
          strike_reg[0] <= 1'b0;
          ball_reg[0] <= 1'b0;
        end

        if(answer[11:8] == question[11:8]) begin
          strike_reg[1] <= 1'b1;
          ball_reg[1] <= 1'b0;
        end
        else if(answer[15:12] == question[11:8]) begin
          strike_reg[1] <= 1'b0;
          ball_reg[1] <= 1'b1;
        end 
        else if(answer[7:4] == question[11:8]) begin
          strike_reg[1] <= 1'b0;
          ball_reg[1] <= 1'b1;
        end 
        else if(answer[3:0] == question[11:8]) begin
          strike_reg[1] <= 1'b0;
          ball_reg[1] <= 1'b1;
        end 
        else begin
          strike_reg[1] <= 1'b0;
          ball_reg[1] <= 1'b0;
        end
  
        if(answer[7:4] == question[7:4]) begin
          strike_reg[2] <= 1'b1;
          ball_reg[2] <= 1'b0;
        end
        else if(answer[15:12] == question[7:4]) begin
          strike_reg[2] <= 1'b0;
          ball_reg[2] <= 1'b1;
        end 
        else if(answer[11:8] == question[7:4]) begin
          strike_reg[2] <= 1'b0;
          ball_reg[2] <= 1'b1;
        end 
        else if(answer[3:0] == question[7:4]) begin
          strike_reg[2] <= 1'b0;
          ball_reg[2] <= 1'b1;
        end 
        else begin
          strike_reg[2] <= 1'b0;
          ball_reg[2] <= 1'b0;
        end
  
        if(answer[3:0] == question[3:0]) begin
          strike_reg[3] <= 1'b1;
          ball_reg[3] <= 1'b0;
        end
        else if(answer[15:12] == question[3:0]) begin
          strike_reg[3] <= 1'b0;
          ball_reg[3] <= 1'b1;
        end 
        else if(answer[11:8] == question[3:0]) begin
          strike_reg[3] <= 1'b0;
          ball_reg[3] <= 1'b1;
        end 
        else if(answer[7:4] == question[3:0]) begin
          strike_reg[3] <= 1'b0;
          ball_reg[3] <= 1'b1;
        end 
        else begin
          strike_reg[3] <= 1'b0;
          ball_reg[3] <= 1'b0;
        end
      end
    end
  end    
endmodule
