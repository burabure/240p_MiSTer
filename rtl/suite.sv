
module suite (
    input wire clk,
    input wire reset,
    input wire ioctl_wr,
    input wire [16:0] ioctl_addr,
    input wire [7:0] ioctl_data,
    input wire [31:0] joy,

    output wire ce_pix,
    output wire h_blank,
    output wire h_sync,
    output wire v_blank,
    output wire v_sync,
    output wire de,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

  wire [9:0] h_count;
  wire [9:0] v_count;
  wire [9:0] h_visible_dots;
  wire [9:0] v_visible_lines;
  wire [5:0] h_front_porch_dots;
  wire [5:0] v_front_porch_lines;

  vga_timings vga (
      .clk  (clk),
      .reset(reset),

      .ce_pix(ce_pix),
      .de(de),
      .h_sync(h_sync),
      .v_sync(v_sync),
      .h_blank(h_blank),
      .v_blank(v_blank),
      .h_count(h_count),
      .v_count(v_count),
      .h_visible_dots(h_visible_dots),
      .v_visible_lines(v_visible_lines),
      .h_front_porch_dots(h_front_porch_dots),
      .v_front_porch_lines(v_front_porch_lines)
  );

  monoscope monoscope (
      .clk(clk),
      .ce_pix(ce_pix),
      .ioctl_wr(ioctl_wr),
      .ioctl_addr(ioctl_addr),
      .ioctl_data(ioctl_data),
      .joy(joy),
      .h_count(h_count),
      .v_count(v_count),
      .h_visible_dots(h_visible_dots),
      .v_visible_lines(v_visible_lines),
      .h_front_porch_dots(h_front_porch_dots),
      .v_front_porch_lines(v_front_porch_lines),

      .r(r),
      .g(g),
      .b(b)
  );
endmodule
