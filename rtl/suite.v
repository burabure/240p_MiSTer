
module suite (
    input clk,
    input reset,

    // CPU interface (write only!)
    input ioctl_wr,
    input [16:0] ioctl_addr,
    input [7:0] ioctl_data,

    // TODO: Maybe later
    // input pal,
    // input scandouble,

    output reg ce_pix,
    output reg h_blank,
    output reg h_sync,
    output reg v_blank,
    output reg v_sync,
    output reg de,
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


  // --- VRAM
  reg  [16:0] video_counter;
  wire [ 7:0] pixel;

  dpram #(
      .init_file("monoscope.hex"),
      .widthad_a(17),
      .width_a  (8)
  ) vmem (
      .clock_a(clk),
      .address_a(video_counter),
      .wren_a(1'b0),
      .q_a(pixel),

      .clock_b(clk),
      .wren_b(ioctl_wr),
      .address_b(ioctl_addr),
      .data_b(ioctl_data)
  );


  // --- Video
  always @(posedge clk) begin
    if (ce_pix) begin
      if (hc < H && vc < V) begin
        video_counter <= video_counter + 17'd1;
      end else begin
        if (hc == H + HFP) begin
          if (vc == V + VFP) video_counter <= 17'd0;
        end
      end
    end
  end

  // seperate 8 bits into three colors (332)
  assign r  = {pixel[7:5], pixel[7:5], pixel[7:6]};
  assign g  = {pixel[4:2], pixel[4:2], pixel[4:3]};
  assign b  = {pixel[1:0], pixel[1:0], pixel[1:0], pixel[1:0]};

  assign de = ~(h_blank | v_blank);
endmodule
