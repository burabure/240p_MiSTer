module monoscope (
    input wire clk,
    input wire ce_pix,
    input wire ioctl_wr,
    input wire [16:0] ioctl_addr,
    input wire [7:0] ioctl_data,
    input wire [31:0] joy,
    input wire [9:0] h_count,
    input wire [9:0] v_count,
    input wire [9:0] h_visible_dots,
    input wire [9:0] v_visible_lines,
    input wire [5:0] h_front_porch_dots,
    input wire [5:0] v_front_porch_lines,

    output reg [7:0] r,
    output reg [7:0] g,
    output reg [7:0] b
);

  // --- VRAM
  reg  [16:0] video_counter;
  wire [ 7:0] layer_1;
  wire [ 7:0] layer_2;

  rom #(
      .AW(17),
      .DW(8),
      .memfile("tests/monoscope/monoscope_1.hex")
  ) monoscope_1 (
      .clock(clk),
      .ce(1'b1),
      .address(video_counter),
      .q(layer_1)
  );

  rom #(
      .AW(17),
      .DW(8),
      .memfile("tests/monoscope/monoscope_2.hex")
  ) monoscope_2 (
      .clock(clk),
      .ce(1'b1),
      .address(video_counter),
      .q(layer_2)
  );

  // --- Monoscope Layer Level
  reg [3:0] layer_1_level = 4'd10;

  always @(posedge joy[4]) begin
    if (layer_1_level === 10) layer_1_level = 4'd0;
    else layer_1_level = layer_1_level + 4'd1;
  end

  // --- Video
  always @(posedge clk) begin
    if (ce_pix) begin
      if (h_count < h_visible_dots && v_count < v_visible_lines) begin
        video_counter <= video_counter + 17'd1;
      end else begin
        if (h_count == h_visible_dots + 10'(h_front_porch_dots)) begin
          if (v_count == v_visible_lines + 10'(v_front_porch_lines)) video_counter <= 17'd0;
        end
      end
    end
  end

  // Layer Rendering
  // negedge sys clk edge so layer compositing can keep up with the video clock
  always @(negedge clk) begin
    if (layer_2 == 8'd0) begin
      if (layer_1 == 8'hFF) begin
        case (layer_1_level)
          4'd0: {r, g, b} <= {8'd0, 8'd0, 8'd0};
          4'd1: {r, g, b} <= {8'd25, 8'd25, 8'd25};
          4'd2: {r, g, b} <= {8'd51, 8'd51, 8'd51};
          4'd3: {r, g, b} <= {8'd76, 8'd76, 8'd76};
          4'd4: {r, g, b} <= {8'd102, 8'd102, 8'd102};
          4'd5: {r, g, b} <= {8'd127, 8'd127, 8'd127};
          4'd6: {r, g, b} <= {8'd153, 8'd153, 8'd153};
          4'd7: {r, g, b} <= {8'd178, 8'd178, 8'd178};
          4'd8: {r, g, b} <= {8'd204, 8'd204, 8'd204};
          4'd9: {r, g, b} <= {8'd229, 8'd229, 8'd229};
          4'd10: {r, g, b} <= {8'd255, 8'd255, 8'd255};
          default: {r, g, b} <= {8'd0, 8'd0, 8'd0};
        endcase
      end else begin
        {r, g, b} <= {8'h00, 8'h00, 8'h00};
      end
    end else begin
      // separate 8 bits (332) into 8bpp (888)
      r <= {layer_2[7:5], layer_2[7:5], layer_2[7:6]};
      g <= {layer_2[4:2], layer_2[4:2], layer_2[4:3]};
      b <= {layer_2[1:0], layer_2[1:0], layer_2[1:0], layer_2[1:0]};
    end
  end
endmodule
