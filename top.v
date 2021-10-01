module top(
  number,
  control,
  sysclk,
  push_button,
  rs,
  rw,
  e,
  d,
  lcd_on
);

input [4:0]number;
input control;

input sysclk;
output push_button;
output rs;
output rw;
output e;
output [7:0] d;
output lcd_on;

assign lcd_on = 1;
wire data_ready;
wire lcd_busy;

wire [8:0] d_in;

wire [5:0] rom_in;

virtual_input INPUT(.number(number), .control(control), .button3(push_button));

lcd LCD(
  .clock(sysclk),
  .internal_reset(push_button),
  .d_in(d_in),
  .data_ready(data_ready),
  .rs(rs),
  .rw(rw),
  .e(e),
  .d(d),
  .busy_flag(lcd_busy)
  );


rom ROM(
.rom_in(rom_in),
.rom_out(d_in)
);

controller CONTROLLER(
  .clock(sysclk),
  .lcd_busy(lcd_busy),
  .internal_reset(push_button),
  .rom_address(rom_in),
  .data_ready(data_ready)
);

endmodule

//-------------------------------------------------------