
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

  // --- Custom VESA Timings
  // 6.4 Mhz Pixel Clock
  // 4:3 - Square Pixel Ratio
  // H Sync Polarity - / V Sync Polarity +
  // H Freq = 15.96 kHz
  // V Freq = 58.9 Hz
  parameter H = 320;  // Horizontal Active Area (pixels)
  parameter HFP = 13;  // Horizontal Fron Porch (pixels)
  parameter HS = 32;  // HSync Pulse Width (pixels)
  parameter HBP = 35;  // Horizontal Back Porch (pixels)
  parameter HTOTAL = H + HFP + HS + HBP;  // 400 pixels

  parameter V = 240;  // Vertical Active Area (lines)
  parameter VFP = 9;  // Vertical Front Porch (lines)
  parameter VS = 8;  // VSync Pulse Width (lines)
  parameter VBP = 13;  // Vertical Back Porch (lines)
  parameter VTOTAL = V + VFP + VS + VBP;  // 270 lines

  parameter HHALF = H / 2;  // center of visible Horizontal raster
  parameter VHALF = V / 2;  // center of visible Vertical raster

  // --- Clock divider (clk / 4 = 6.4 Mhz)
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
      HSync <= 0;

      if (vc == V + VFP) VSync <= 1;
      else if (vc == V + VFP + VS) VSync <= 0;

      if (vc == V) VBlank <= 1;
      else if (vc == 0) VBlank <= 0;
    end

    if (hc == H + HFP + HS) HSync <= 1;
  end

  // --- Video
  always @(posedge clk) begin
    video <= 8'd00;

    if (hc <= H && vc <= V) begin
      video <= 8'd77;  // 30 IRE

      // --- Visible raster square (320x240)
      // Top and Bottom line
      if ((vc == 1 || vc == V) && hc >= 0 && hc <= H) video <= 8'd255;
      // Left and Right line
      if ((hc == 0 || hc == H - 1) && vc >= 0 && vc <= V) video <= 8'd255;

      // --- Center Lines (double)
      // H Center lines
      if ((vc == VHALF || vc == VHALF + 1) && hc >= 0 && hc <= H) video <= 8'd255;
      // V Center lines
      if ((hc == HHALF || hc == HHALF + 1) && vc >= 0 && vc <= V) video <= 8'd255;

      // --- Center Square (100x100)
      // Center square top and bottom lines
      if ((vc == VHALF - 50 || vc == VHALF + 50) && hc >= HHALF - 50 && hc <= HHALF + 50)
        video <= 8'd255;
      // Center square left and right lines
      if ((hc == HHALF - 50 || hc == HHALF + 50) && vc >= VHALF - 50 && vc <= VHALF + 50)
        video <= 8'd255;

      // --- ACTION SAFE (288x216)
      // Center square top and bottom lines
      if ((vc == 13 || vc == V - 13) && hc >= 16 && hc <= H - 16) video <= 8'd255;
      // Center square left and right lines
      if ((hc == 16 || hc == H - 16) && vc >= 13 && vc <= V - 13) video <= 8'd255;

      // --- TITLE SAFE (256x192)
      // Center square top and bottom lines
      if ((vc == 25 || vc == V - 25) && hc >= 32 && hc <= H - 32) video <= 8'd127;
      // Center square left and right lines
      if ((hc == 32 || hc == H - 32) && vc >= 25 && vc <= V - 25) video <= 8'd127;
    end
  end

endmodule
