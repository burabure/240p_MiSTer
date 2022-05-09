
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

    input layer_1_enable,

    output reg ce_pix,
    output wire h_blank,
    output wire h_sync,
    output wire v_blank,
    output wire v_sync,
    output wire de,
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

  // --- Clock divider (clk / 4 = 6.3 Mhz)
  always @(posedge clk) begin
    reg [1:0] div;

    div <= div + 1'd1;
    ce_pix <= div == 2'd0;
  end

  // --- Counters
  always @(posedge clk) begin
    if (reset) begin
      hc <= 0;
      vc <= 0;
    end else if (ce_pix) begin
      if (hc == HTOTAL) begin
        hc <= 0;

        if (vc == VTOTAL) vc <= 0;
        else vc <= vc + 1'd1;

      end else hc <= hc + 1'd1;
    end
  end

  // --- Blanking
  always @(posedge clk) begin
    if (ce_pix) begin
      if (hc == H - 1) h_blank <= 1;
      else if (hc == HTOTAL) h_blank <= 0;

      if (hc == H + HFP) begin
        h_sync <= 0;

        if (vc == V + VFP) v_sync <= 1;
        else if (vc == V + VFP + VS) v_sync <= 0;

        if (vc == V - 1) v_blank <= 1;
        else if (vc == VTOTAL) v_blank <= 0;
      end

      if (hc == H + HFP + HS) h_sync <= 1;
    end
  end


  // --- VRAM
  reg  [16:0] video_counter;
  reg  [ 7:0] pixel;
  wire [ 7:0] layer_1;
  wire [ 7:0] layer_2;

  rom #(
      .AW(17),
      .DW(8),
      .memfile("monoscope_1.hex")
  ) monoscope_1 (
      .clock(clk),
      .ce(1'b1),
      .address(video_counter),
      .q(layer_1)
  );

  rom #(
      .AW(17),
      .DW(8),
      .memfile("monoscope_2.hex")
  ) monoscope_2 (
      .clock(clk),
      .ce(1'b1),
      .address(video_counter),
      .q(layer_2)
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

  // layer rendering
  always @(negedge clk) begin
    if (layer_2 == 8'd0) begin
      if (layer_1 == 8'hFF && layer_1_enable) pixel <= 8'hFF;
      else pixel <= 8'h00;

    end else pixel <= layer_2;
  end

  // seperate 8 bits into three colors (332)
  assign r  = {pixel[7:5], pixel[7:5], pixel[7:6]};
  assign g  = {pixel[4:2], pixel[4:2], pixel[4:3]};
  assign b  = {pixel[1:0], pixel[1:0], pixel[1:0], pixel[1:0]};

  assign de = ~(h_blank | v_blank);

  // --- Logging
  always @(posedge clk) begin
    if (ce_pix) begin
      if ((hc < 4 || hc > H - 4 && hc < H + 2) && (vc < 4 || vc > V - 4 && vc < V + 2)) begin
        $display("HC: %d - VC: %d - VidC: %d - DE: %d - Pixel: %h", hc, vc, video_counter, de,
                 pixel);
      end
    end
  end

endmodule
