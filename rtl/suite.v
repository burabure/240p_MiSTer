
module suite (
    input clk,
    input reset,

    // TODO: Maybe later
    // input pal,
    // input scandouble,

    output reg ce_pix,

    output reg HBlank,
    output reg HSync,
    output reg VBlank,
    output reg VSync,

    output [7:0] video
);

  reg [9:0] hc;  // horizontal pixel counter
  reg [9:0] vc;  // vertical line counter

  parameter H = 360;  // width of visible area (pixels)
  parameter HFP = 8;  // unused time before hsync (pixels)
  parameter HS = 32;  // width of hsync (pixels)
  parameter HBP = 29;  // unused time after hsync (pixels)
  parameter HTOTAL = H + HFP + HS + HBP;

  parameter V = 240;  // height of visible area (lines)
  parameter VFP = 3;  // unused time before vsync (lines)
  parameter VS = 3;  // width of vsync (lines)
  parameter VBP = 17;  // unused time after vsync (lines)
  parameter VTOTAL = V + VFP + VS + VBP;

  // --- Clock divider
  always @(posedge clk) begin
    reg [1:0] div;

    div <= div + 1'd1;
    ce_pix <= !div;
  end

  // --- Counters
  always @(posedge clk) begin
    if (reset) begin
      hc <= 0;
      vc <= 0;
    end else if (ce_pix) begin
      if (hc == HTOTAL) begin
        hc <= 0;
        if (vc == VTOTAL) begin
          vc <= 0;
        end else begin
          vc <= vc + 1'd1;
        end
      end else begin
        hc <= hc + 1'd1;
      end
    end
  end

  // --- Blanking
  always @(posedge clk) begin
    if (hc == H) HBlank <= 1;
    else if (hc == 0) HBlank <= 0;

    if (hc == H + HFP) begin
      HSync <= 1;

      if (vc == V + VFP) VSync <= 1;
      else if (vc == V + VFP + VS) VSync <= 0;

      if (vc == V) VBlank <= 1;
      else if (vc == 0) VBlank <= 0;
    end

    if (hc == H + HFP + HS) HSync <= 0;
  end

  // --- Video
  always @(posedge clk) begin
    if (hc < H && vc < V) begin
      video <= 8'd255;

      if (hc > 0 && hc < H - 1 && vc > 1 && vc < V - 1) video <= 8'd0;
    end else video <= 8'd0;
  end

endmodule
