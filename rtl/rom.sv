`timescale 1ns / 1ps

module rom #(
    parameter AW = 16,
    parameter DW = 8,
    parameter memfile = ""
) (
    input  wire          clock,
    input  wire          ce,
    output reg  [DW-1:0] q,
    input  wire [AW-1:0] address
);
  initial begin
    $display("Loading rom. %s", memfile);
    $display(memfile);
    if (memfile > 0) $readmemh(memfile, d);
  end

  reg [DW-1:0] d[(2**AW)-1:0];

  always @(posedge clock) if (ce) q <= d[address];
endmodule

