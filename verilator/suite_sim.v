`timescale 1ns / 1ns
// top end ff for verilator

module top (

    input clk_sys  /*verilator public_flat*/,
    input reset  /*verilator public_flat*/,
    input [11:0] inputs  /*verilator public_flat*/,

    output [7:0] VGA_R  /*verilator public_flat*/,
    output [7:0] VGA_G  /*verilator public_flat*/,
    output [7:0] VGA_B  /*verilator public_flat*/,

    output CE_PIXEL,
    output VGA_HS,
    output VGA_VS,
    output VGA_HB,
    output VGA_VB,

    output [15:0] AUDIO_L,
    output [15:0] AUDIO_R,

    input             ioctl_download,
    input             ioctl_upload,
    input             ioctl_wr,
    input      [24:0] ioctl_addr,
    input      [ 7:0] ioctl_dout,
    input      [ 7:0] ioctl_din,
    input      [ 7:0] ioctl_index,
    output reg        ioctl_wait = 1'b0

);

  // Core inputs/outputs
  wire       pause;
  wire [7:0] audio;
  wire [3:0] led  /*verilator public_flat*/;
  reg  [7:0] trakball  /*verilator public_flat*/;
  reg  [7:0] joystick  /*verilator public_flat*/;
  reg  [9:0] playerinput  /*verilator public_flat*/;


  // MAP INPUTS FROM SIM
  // -------------------
  assign playerinput[9] = ~inputs[10];  // coin r
  assign playerinput[8] = ~inputs[9];  // coin m
  assign playerinput[7] = ~inputs[8];  // coin l
  assign playerinput[6] = 1'b1;  // self-test
  assign playerinput[5] = 1'b0;  // cocktail
  assign playerinput[4] = 1'b1;  // slam
  assign playerinput[3] = ~inputs[7];  // start 2
  assign playerinput[2] = ~inputs[6];  // start 1
  assign playerinput[1] = ~inputs[5];  // fire 2
  assign playerinput[0] = ~inputs[4];  // fire 1
  assign pause = inputs[11];  // pause
  // right, left, down, up 1
  assign joystick[7:4] = {~inputs[0], ~inputs[1], ~inputs[2], ~inputs[3]};
  // right, left, down, up 2
  assign joystick[3:0] = {~inputs[0], ~inputs[1], ~inputs[2], ~inputs[3]};


  // MAP OUTPUTS
  assign AUDIO_L = {audio, audio};
  assign AUDIO_R = AUDIO_L;

  suite suite (
      .clk  (clk_sys),
      .reset(reset),

      .ioctl_wr  (ioctl_wr & ioctl_download),
      .ioctl_addr(ioctl_addr[16:0]),
      .ioctl_data(ioctl_dout),

      .layer_1_enable(playerinput[0]),

      .ce_pix(CE_PIXEL),
      .h_blank(VGA_HB),
      .v_blank(VGA_VB),
      .h_sync(VGA_HS),
      .v_sync(VGA_VS),
      .de(),  // VGA_DE
      .r(VGA_R),
      .g(VGA_G),
      .b(VGA_B)
  );

endmodule
