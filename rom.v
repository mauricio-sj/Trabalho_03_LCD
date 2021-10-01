module rom (
rom_in   , // Address input
rom_out    // Data output
);
input [5:0] rom_in;
output [8:0] rom_out;

reg [8:0] rom_out;
     
always @*
begin
  case (rom_in) // hello world
   6'b000000: rom_out = {3'b001, rom_in};
   6'b000001: rom_out = 9'b101001000;   
   6'b000010: rom_out = {3'b001, rom_in};
   6'b000011: rom_out = 9'b101100101;
   6'b000100: rom_out = {3'b001, rom_in};
   6'b000101: rom_out = 9'b101101100;
   6'b000110: rom_out = {3'b001, rom_in};
   6'b000111: rom_out = 9'b101101100;
   6'b001000: rom_out = {3'b001, rom_in};
   6'b001001: rom_out = 9'b101101111;
   6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b100100000;
   6'b001110: rom_out = {3'b001, rom_in};
   6'b001111: rom_out = 9'b101010111;
	6'b001000: rom_out = {3'b001, rom_in};
   6'b001001: rom_out = 9'b101101111;
   6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b101110010;
   6'b001100: rom_out = {3'b001, rom_in};
   6'b001101: rom_out = 9'b101101100;
   6'b001110: rom_out = {3'b001, rom_in};
   6'b001111: rom_out = 9'b101100100;
	6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b100100000;
	6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b100100000;
	6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b100100000;
	6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b100100000;
	6'b001010: rom_out = {3'b001, rom_in};
   6'b001011: rom_out = 9'b100100000;
   default: rom_out = 9'bZZZ;
  endcase
end

//module rom (
//last_switch_1_unidade ,
//last_switch_1_dezena ,
//rom_in   , // Address input
//rom_out    // Data output
//);
//
//parameter BITS_WIDTH;
//input last_switch_1_unidade, last_switch_1_dezena;
//input [5:0] rom_in;
//output [8:0] rom_out;
//
//reg [8:0] rom_out;
//     
//always @*
//begin
//  case (rom_in) // hello world
//   6'b000000: rom_out = {3'b001, rom_in};
//   6'b000001: rom_out = 9'b101100101;
//   6'b000010: rom_out = {3'b001, rom_in};
//   6'b000011: rom_out = 9'b101101100;
//   6'b000100: rom_out = {3'b001, rom_in};
//   6'b000101: rom_out = 9'b101101100;
//   6'b000110: rom_out = {3'b001, rom_in};
//   6'b000111: rom_out = 9'b101101111;
//   6'b001000: rom_out = {3'b001, rom_in};
//   6'b001001: rom_out = 9'b101101100;
//   6'b001010: rom_out = {3'b001, rom_in};
//   6'b001011: rom_out = 9'b100100000;
//   6'b001100: rom_out = {3'b001, rom_in};
//   6'b001101: rom_out = last_switch_1_unidade;
//   6'b001110: rom_out = {3'b001, rom_in};
//   6'b001111: rom_out = {1'b1, last_switch_1_dezena};
//   default: rom_out = 9'hXXX;
//  endcase
//end

//   6'b000000: rom_out = 9'b101001000;
//   6'b1: rom_out = 9'b101100101;
//   6'b2: rom_out = 9'b101101100;
//   6'b3: rom_out = 9'b101101100;
//   6'b4: rom_out = 9'b101101111;
//   6'b5: rom_out = 9'b111000000;
//   6'b6: rom_out = 9'b101010111;
//   6'b7: rom_out = 9'b101101111;
//   6'b8: rom_out = 9'b101110010;
//   6'b9: rom_out = 9'b101101100;
//   6'ba: rom_out = 9'b101100100;
//   6'bb: rom_out = 9'b100100000;
//   6'bc: rom_out = 9'b100100000;
//   6'bd: rom_out = 9'b100100000;
//   6'be: rom_out = 9'b100100000;
//   6'bf: rom_out = 9'b100100000;

endmodule
