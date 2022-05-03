
module suite (
    input clk,
    input reset,

    // TODO: Maybe later
    // input pal,
    // input scandouble,

    output reg ce_pix,
    output reg h_blank,
    output reg h_sync,
    output reg v_blank,
    output reg v_sync,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b
);

  reg [9:0] hc;  // horizontal pixel counter
  reg [9:0] vc;  // vertical line counter

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

  parameter HHALF = H / 2;  // center of visible Horizontal raster
  parameter VHALF = V / 2;  // center of visible Vertical raster

  // --- Clock divider (clk / 4 = 6.3 Mhz)
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
    if (hc == H) h_blank <= 1;
    else if (hc == 0) h_blank <= 0;

    if (hc == H + HFP) begin
      h_sync <= 0;

      if (vc == V + VFP) v_sync <= 1;
      else if (vc == V + VFP + VS) v_sync <= 0;

      if (vc == V) v_blank <= 1;
      else if (vc == 0) v_blank <= 0;
    end

    if (hc == H + HFP + HS) h_sync <= 1;
  end

  // --- Video
  reg [7:0] pixel;

  always @(posedge clk) begin
    pixel <= 8'd00;

    if (hc <= H && vc <= V) begin
      pixel <= 8'd77;  // 30 IRE

      // --- Visible raster square (320x240)
      // Top and Bottom line
      if ((vc == 1 || vc == V) && hc >= 0 && hc <= H) pixel <= 8'd255;
      // Left and Right line
      if ((hc == 0 || hc == H - 1) && vc >= 0 && vc <= V) pixel <= 8'd255;

      // --- Center Lines (double)
      // H Center lines
      if ((vc == VHALF || vc == VHALF + 1) && hc >= 0 && hc <= H) pixel <= 8'd255;
      // V Center lines
      if ((hc == HHALF || hc == HHALF + 1) && vc >= 0 && vc <= V) pixel <= 8'd255;

      // --- Center Square (100x100)
      // Center square top and bottom lines
      if ((vc == VHALF - 50 || vc == VHALF + 50) && hc >= HHALF - 50 && hc <= HHALF + 50)
        pixel <= 8'd255;
      // Center square left and right lines
      if ((hc == HHALF - 50 || hc == HHALF + 50) && vc >= VHALF - 50 && vc <= VHALF + 50)
        pixel <= 8'd255;

      // --- ACTION SAFE (288x216)
      // Center square top and bottom lines
      if ((vc == 13 || vc == V - 13) && hc >= 16 && hc <= H - 16) pixel <= 8'd255;
      // Center square left and right lines
      if ((hc == 16 || hc == H - 16) && vc >= 13 && vc <= V - 13) pixel <= 8'd255;

      // --- TITLE SAFE (256x192)
      // Center square top and bottom lines
      if ((vc == 25 || vc == V - 25) && hc >= 32 && hc <= H - 32) pixel <= 8'd127;
      // Center square left and right lines
      if ((hc == 32 || hc == H - 32) && vc >= 25 && vc <= V - 25) pixel <= 8'd127;
    end
  end

  assign r = pixel;
  assign g = pixel;
  assign b = pixel;

endmodule
