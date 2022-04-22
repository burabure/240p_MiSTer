
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

  parameter H = 320;  // width of visible area (pixels)
  parameter HFP = 8;  // unused time before hsync (pixels)
  parameter HS = 32;  // width of hsync (pixels)
  parameter HBP = 40;  // unused time after hsync (pixels)
  parameter HTOTAL = H + HFP + HS + HBP;  // 400

  parameter V = 240;  // height of visible area (lines)
  parameter VFP = 1;  // unused time before vsync (lines)
  parameter VS = 8;  // width of vsync (lines)
  parameter VBP = 6;  // unused time after vsync (lines)
  parameter VTOTAL = V + VFP + VS + VBP;  // 255

  parameter HHALF = H / 2;  // center of visible Horizontal raster
  parameter VHALF = V / 2;  // center of visible Vertical raster

  // --- Clock divider (clk / 4 = 6.1363 Mhz)
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
    video <= 8'd0;

    if (hc < H && vc < V) begin
      // --- Visible raster square (320x240)
      // Top and Bottom line
      if ((vc == 0 || vc == V - 1) && hc >= 0 && hc < H) video <= 8'd255;
      // Left and Right line
      if ((hc == 0 || hc == H - 1) && vc >= 0 && vc < V) video <= 8'd255;

      // --- Center Lines (double)
      // H Center lines
      if ((vc == VHALF || vc == VHALF + 1) && hc >= 0 && hc < H) video <= 8'd255;
      // V Center lines
      if ((hc == HHALF || hc == HHALF + 1) && vc >= 0 && vc < V) video <= 8'd255;

      // --- Center Square (100x100)
      // Center square top and bottom lines
      if ((vc == VHALF - 50 || vc == VHALF + 50) && hc >= HHALF - 50 && hc < HHALF + 50)
        video <= 8'd255;
      // Center square left and right lines
      if ((hc == HHALF - 50 || hc == HHALF + 50) && vc >= VHALF - 50 && vc < VHALF + 50)
        video <= 8'd255;
    end
  end

endmodule
