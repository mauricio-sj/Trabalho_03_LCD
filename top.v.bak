module top(
  sysclk,
  push_button,
  rs,
  e,
  d
);

input sysclk;
input push_button;
output rs;
output e;
output [7:0] d;

reg internal_reset = 1'b0;
reg last_signal = 1'b0;
wire clean_signal;
wire data_ready;
wire lcd_busy;

wire [8:0] d_in;

wire [3:0] rom_in;

lcd lcd(
  .clock(sysclk),
  .internal_reset(internal_reset),
  .d_in(d_in),
  .data_ready(data_ready),
  .rs(rs),
  .e(e),
  .d(d),
  .busy_flag(lcd_busy)
  );

rom rom(
.rom_in(rom_in),
.rom_out(d_in)
);

controller controller (
  .clock(sysclk),
  .lcd_busy(lcd_busy),
  .internal_reset(internal_reset),
  .rom_address(rom_in),
  .data_ready(data_ready)
);

always @ (posedge sysclk) begin
  if (last_signal != clean_signal) begin
    last_signal <= clean_signal;
    if (clean_signal == 1'b0) begin
      internal_reset <= 1'b1;
    end
  end
  else begin
    internal_reset <= 1'b0;
  end
end

endmodule

//-------------------------------------------------------