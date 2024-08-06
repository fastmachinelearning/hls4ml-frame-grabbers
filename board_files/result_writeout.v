`timescale 1ns / 1ps

///////////////////////////////
// Author: Ryan Forelli
// Date: 07/24/2023
///////////////////////////////

module result_writeout(
    input clk,
    input[11:0] Request,
    input Request_vld,
    output[1:0] UserOutput
);

  reg[15:0] request_reg = 16'b1101000000000000;
  reg Request_write_en = 0;

  reg[4:0] Request_write_counter = 5'd15;
  reg[4:0] Request_delay_counter = 0;

  reg[1:0] UO = 0;
  assign UserOutput[1:0] = UO;

  always @(posedge clk) begin
    if (Request_vld == 1'b1) begin
      Request_write_en <= 1;
      request_reg[11:0] <= Request[11:0];
    end

    if (Request_write_en == 1'b1) begin
      Request_delay_counter <= Request_delay_counter + 1;
      if (Request_delay_counter == 24) begin
        Request_delay_counter <= 0;
        Request_write_counter <= Request_write_counter - 1;
        if(Request_write_counter == 0) begin
          Request_write_counter <= 15;
          Request_write_en <= 0;
        end
      end
    end
  end

  always @(posedge clk) begin
    if (Request_write_en == 1) begin
      case (request_reg[Request_write_counter])
        1'b1 : UO <= 2'b01;
        1'b0 : UO <= 2'b10;
      endcase
    end
  end

endmodule
