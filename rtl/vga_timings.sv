
module vga_timings (
    input wire clk,
    input wire reset,

    // TODO: Maybe later
    // input pal,
    // input scandouble,

    output reg ce_pix,
    output wire de,
    output wire h_blank,
    output wire h_sync,
    output wire v_blank,
    output wire v_sync,
    output reg [9:0] h_count,
    output reg [9:0] v_count,
    output wire [9:0] h_visible_dots,
    output wire [9:0] v_visible_lines,
    output wire [5:0] h_front_porch_dots,
    output wire [5:0] v_front_porch_lines
);

  // --- Custom VGA Timings
  // 6.3 Mhz Pixel Clock
  // 4:3 - Square Pixel Ratio
  // H Sync Polarity - / V Sync Polarity +
  // H Freq = 16.03 kHz
  // V Freq = 60 Hz
  parameter H = 320;  // Horizontal Active Area (pixels)
  parameter HFP = 8;  // Horizontal Fron Porch (pixels)
  parameter HS = 32;  // H Sync Pulse Width (pixels)
  parameter HBP = 32;  // Horizontal Back Porch (pixels)
  parameter HTOTAL = H + HFP + HS + HBP;  // 392 pixels

  parameter V = 240;  // Vertical Active Area (lines)
  parameter VFP = 6;  // Vertical Front Porch (lines)
  parameter VS = 8;  // V Sync Pulse Width (lines)
  parameter VBP = 12;  // Vertical Back Porch (lines)
  parameter VTOTAL = V + VFP + VS + VBP;  // 266 lines

  assign h_visible_dots = H;
  assign v_visible_lines = V;
  assign h_front_porch_dots = HFP;
  assign v_front_porch_lines = VFP;

  // --- Clock divider (clk / 4 = 6.3 Mhz)
  always @(posedge clk) begin
    reg [1:0] div;

    div <= div + 1'd1;
    ce_pix <= div == 2'd0;
  end

  // --- Counters
  always @(posedge clk) begin
    if (reset) begin
      h_count <= 0;
      v_count <= 0;
    end else if (ce_pix) begin
      if (h_count == HTOTAL) begin
        h_count <= 0;

        if (v_count == VTOTAL) v_count <= 0;
        else v_count <= v_count + 1'd1;

      end else h_count <= h_count + 1'd1;
    end
  end

  // --- Blanking
  always @(posedge clk) begin
    if (ce_pix) begin
      if (h_count == H - 1) h_blank <= 1;
      else if (h_count == HTOTAL) h_blank <= 0;

      if (h_count == H + HFP) begin
        h_sync <= 0;

        if (v_count == V + VFP) v_sync <= 1;
        else if (v_count == V + VFP + VS) v_sync <= 0;

        if (v_count == V - 1) v_blank <= 1;
        else if (v_count == VTOTAL) v_blank <= 0;
      end

      if (h_count == H + HFP + HS) h_sync <= 1;
    end
  end

  assign de = ~(h_blank | v_blank);

  // --- Logging
  // always @(posedge clk) begin
  //   if (ce_pix) begin
  //     if ((h_count < 4 || h_count > H - 4 && h_count < H + 2) && (v_count < 4 || v_count > V - 4 && v_count < V + 2)) begin
  //       $display("h_count: %d - v_count: %d - DE: %d - Pixel: %h", h_count, v_count, de, pixel);
  //     end

  //     if (v_count === VTOTAL) begin
  //       $display("r: %h - g: %h - b: %h", r, g, b);
  //     end
  //   end
  // end
endmodule
