`timescale 1ns / 1ps

///////////////////////////////
// Author: Ryan Forelli
// Date: 07/21/2023
///////////////////////////////

module signal_inference(
    input clk,
    input HlsPixTh_tvalid,
    input Result_vld,
    output[1:0] UserOutput
);

  reg[1:0] UO = 0;
  assign UserOutput[1:0] = UO;

  always @(posedge clk) begin
    if (HlsPixTh_tvalid == 1'b1) begin
      UO <= 2'b01;
    end
    else if (Result_vld == 1'b1) begin
      UO <= 2'b10;
    end
  end
endmodule
