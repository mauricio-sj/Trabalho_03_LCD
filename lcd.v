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

debounce debounce(
  .clk (sysclk),
  .in  (push_button),
  .out (clean_signal)
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

module lcd(
  clock,
  internal_reset,
  d_in,
  data_ready,
  rs,
  e,
  d,
  busy_flag
);

parameter CLK_FREQ = 100000000;

parameter integer D_50ns  = 0.000000050 * CLK_FREQ;
parameter integer D_250ns = 0.000000250 * CLK_FREQ;

parameter integer D_40us  = 0.000040000 * CLK_FREQ;
parameter integer D_60us  = 0.000060000 * CLK_FREQ;
parameter integer D_200us = 0.000200000 * CLK_FREQ;

parameter integer D_2ms   = 0.002000000 * CLK_FREQ;
parameter integer D_5ms   = 0.005000000 * CLK_FREQ;
parameter integer D_100ms = 0.100000000 * CLK_FREQ;

parameter STATE00 = 5'b00000;
parameter STATE01 = 5'b00001;
parameter STATE02 = 5'b00010;
parameter STATE03 = 5'b00011;
parameter STATE04 = 5'b00100;
parameter STATE05 = 5'b00101;
parameter STATE06 = 5'b00110;
parameter STATE07 = 5'b00111;
parameter STATE08 = 5'b01000;
parameter STATE09 = 5'b01001;
parameter STATE10 = 5'b01010;
parameter STATE11 = 5'b01011;
parameter STATE12 = 5'b01100;
parameter STATE13 = 5'b01101;
parameter STATE14 = 5'b01110;
parameter STATE15 = 5'b01111;
parameter STATE16 = 5'b10000;
parameter STATE17 = 5'b10001;
parameter STATE18 = 5'b10010;
parameter STATE19 = 5'b10011;
parameter STATE20 = 5'b10100;
parameter STATE21 = 5'b10101;
parameter STATE22 = 5'b10110;
parameter STATE23 = 5'b10111;
parameter STATE24 = 5'b11000;
parameter STATE25 = 5'b11001;

input clock;
input internal_reset;
input [8:0] d_in;
input data_ready;
output rs;
output e;
output [7:0] d;
output busy_flag;

reg rs = 1'b0;
reg e = 1'b0;
reg [7:0] d = 8'b00000000;
reg busy_flag = 1'b0;

reg [4:0] state = 5'b00000;
reg start = 1'b0;


reg [23:0] count = 24'h000000;
reg counter_clear = 1'b0;
reg flag_50ns  = 1'b0;
reg flag_250ns = 1'b0;
reg flag_40us  = 1'b0;
reg flag_60us  = 1'b0;
reg flag_200us = 1'b0;
reg flag_2ms   = 1'b0;
reg flag_5ms   = 1'b0;
reg flag_100ms = 1'b0;

always @(posedge clock) begin
  if (data_ready) begin
    start <= 1'b1;
  end
  if (internal_reset) begin
    state <= 5'b00000;
    counter_clear <= 1'b1;
    start <= 1'b0;
    busy_flag <= 1'b0;
  end

// contador

  if (counter_clear) begin
    count <= 24'h000000;
    counter_clear <= 1'b0;  
    flag_50ns  <= 1'b0;
    flag_250ns <= 1'b0;
    flag_40us  <= 1'b0;
    flag_60us  <= 1'b0;
    flag_200us <= 1'b0;
    flag_2ms   <= 1'b0;
    flag_5ms   <= 1'b0;
    flag_100ms <= 1'b0;
  end

  if (!counter_clear) begin
    count <= count + 1;
    if (count == D_50ns) begin
      flag_50ns  <= 1'b1;
    end
    if (count == D_250ns) begin
      flag_250ns <= 1'b1;
    end
    if (count == D_40us) begin
      flag_40us  <= 1'b1;
    end
    if (count == D_60us) begin
      flag_60us  <= 1'b1;
    end
    if (count == D_200us) begin
      flag_200us <= 1'b1;
    end
    if (count == D_2ms) begin
      flag_2ms   <= 1'b1;
    end
    if (count == D_5ms) begin
      flag_5ms   <= 1'b1;
    end
    if (count == D_100ms) begin
      flag_100ms <= 1'b1;
    end
  end

case (state)

   // Passo 1 - atraso de 100 ms após ligar o 
  STATE00: begin                        
    busy_flag <= 1'b1;                  // diz a outros módulos que o LCD está processando 
    if (flag_100ms) begin               // se 100ms tiverem decorrido 
      rs <= 1'b0;                       // puxa RS para baixo para indicar a instrução 
      d  <= 8'b00110000;                // define os dados para a instrução de Conjunto de Funções
      counter_clear <= 1'b1;            // limpa o contador
      state <= STATE01;                 // avança para o próximo estado 
    end
  end

  // As etapas 2 a 4 aumenta e diminui o pino de habilitação três vezes para inserir a 
  // instrução do conjunto de funções que foi carregada no barramento de dados no STATE00 acima

  // Passo 2 - primeira instrução de conjunto de funções
  STATE01: begin                        
    if (flag_50ns) begin                // if 50ns have elapsed (lets RS and D settle)
      e <= 1'b1;                        // bring E high to initiate data write    
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE02;                 // advance to the next state
    end
  end
  STATE02: begin                         
    if (flag_250ns) begin               // if 250ns have elapsed
      e <= 1'b0;                        // bring E low   
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE03;                 // advance to the next state
    end
  end
  STATE03: begin
    if (flag_5ms) begin                 // if 5ms have elapsed
      e <= 1'b1;                        // bring E high to initiate data write   
      counter_clear <= 1'b1;            // clear the counter      
      state <= STATE04;                 // advance to the next state               
    end
  end

 // Step 3 - second Function Set instruction
  STATE04: begin
    if (flag_250ns) begin               // if 250ns have elapsed
      e <= 1'b0;                        // bring E low    
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE05;                 // advance to the next state  
    end
  end
  STATE05: begin
    if (flag_200us) begin 
      e <= 1'b1;                           
      counter_clear <= 1'b1;
      state <= STATE06;
      end
    end

  // Step 4 - third and final Function Set instruction
  STATE06: begin
    if (flag_250ns) begin
      e <= 1'b0;      
      counter_clear <= 1'b1;
      state <= STATE07;                          
    end
  end
  STATE07: begin
    if (flag_200us) begin
      d  <= 8'b00111000;                // configuration cmd = 8-bit mode, 2 lines, 5x7 font 
      counter_clear <= 1'b1;
      state <= STATE08;
    end
  end

  // Step 5 - enter the Configuration command
  STATE08: begin                        
    if (flag_50ns) begin 
      e <= 1'b1; 
      counter_clear <= 1'b1; 
      state <= STATE09;
    end
  end
  STATE09: begin                        
    if (flag_250ns) begin
      e <= 1'b0; 
      counter_clear <= 1'b1; 
      state <= STATE10;
    end
  end
  STATE10: begin
    if (flag_60us) begin
      d  <= 8'b00001000;                // display off 
      counter_clear <= 1'b1;
      state <= STATE11;
    end
  end

  // Step 6 - enter the Display Off command
  STATE11: begin                        
    if (flag_50ns) begin 
      e <= 1'b1;                       
      counter_clear <= 1'b1;
      state <= STATE12;
    end
  end
  STATE12: begin                        
    if (flag_250ns) begin
      e <= 1'b0;
      counter_clear <= 1'b1;
      state <= STATE13;
    
    end
  end
  STATE13: begin
    if (flag_60us) begin
      d  <= 8'b00000001;                // limpa o comando
      counter_clear <= 1'b1;
      state <= STATE14;
     end
  end

  // Step 7 - enter the Clear command
  STATE14: begin                        
    if (flag_50ns) begin
      e <= 1'b1;
      counter_clear <= 1'b1;
      state <= STATE15;   
    end
  end
  STATE15: begin                        
    if (flag_250ns) begin
      e <= 1'b0;
      counter_clear <= 1'b1;
      state <= STATE16;     
    end
  end
  STATE16: begin
    if (flag_5ms) begin                 // 5ms (clear command has a long cycle time)
      d  <= 8'b00000110;                // entry mode  
      counter_clear <= 1'b1;
      state <= STATE17;
     end
  end

  //Step 8 - Set the Entry Mode to: cursor moves, display stands still
  STATE17: begin                        
    if (flag_50ns) begin
      e <= 1'b1;   
      counter_clear <= 1'b1;
      state <= STATE18;
    end
  end
  STATE18: begin                        
    if (flag_250ns) begin 
      e <= 1'b0;  
      counter_clear <= 1'b1;
      state <= STATE19;    
    end
  end
  STATE19: begin
    if (flag_60us) begin
      d  <= 8'b00001100;                // Display On
      counter_clear <= 1'b1;
      state <= STATE20;
    end
  end

  // Step 9 - enter the Display On command
  STATE20: begin                        
    if (flag_50ns) begin
      e <= 1'b1;
      counter_clear <= 1'b1;
      state <= STATE21;
    end
  end
  STATE21: begin                        
    if (flag_250ns) begin
      e <= 1'b0;
      counter_clear <= 1'b1;
      state <= STATE22;
    end
  end
  STATE22: begin
    if (flag_60us) begin
      busy_flag <= 1'b0;                // clear the busy flag
      counter_clear <= 1'b1;
      state <= STATE23;  

    end
  end

// End Initialization - Start entering data.

  STATE23: begin
    if (start && !busy_flag) begin      // wait for data  
      start <= 1'b0;                    // clear the start flag
      counter_clear <= 1'b1;
      rs <= d_in[8];                    // read the RS value from input       
      d  <= d_in[7:0];                  // read the data value input 
      busy_flag <= 1'b1;                // set the busy flag
      end  
    if (flag_50ns && busy_flag) begin   // if 50ns have elapsed
       counter_clear <= 1'b1;           // clear the counter
       state <= STATE24;                // advance to the next state
       end
  end

  STATE24: begin   
    if (counter_clear) begin            // if this is the first iteration of STATE24
      e <= 1'b1;                        // Bring E high to initiate data write
    end
    else if (flag_250ns) begin          // if 250ns have elapsed
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE25;                 // advance to the next state

    end
  end

  STATE25: begin
    if (counter_clear) begin            // if this is the first iteration of STATE25
      e <= 1'b0;                        // Bring E low
    end
    else if (flag_40us == 1'b1 && rs == 1'b1) begin  // if data is a character and 40us has elapsed
      busy_flag <= 1'b0;                // clear the busy flag
      counter_clear <= 1'b1;            // clear the counter 
      state <= STATE23;                 // go back to STATE23 and wait for next data
    end
    else if (flag_2ms == 1'b1 && rs == 1'b0) begin // if data is a command and 2ms has elapsed
      busy_flag <= 1'b0;                // clear the busy flag
      counter_clear <= 1'b1;            // clear the counter 
      state <= STATE23;                 // go back to STATE23 and wait for next data
    end
  end
  default: ;
endcase

end

endmodule

//------------------------------------
module controller (
  clock,
  lcd_busy,
  internal_reset,
  rom_address,
  data_ready
);

input clock;
input lcd_busy;
input internal_reset;
output [3:0] rom_address;
output data_ready;

reg [3:0] rom_address = 4'b0000;
reg data_ready = 1'b0;
reg current_lcd_state = 1'b0;
reg halt = 1'b0;

reg old_reset = 1'b0;

always @ (posedge clock) begin

  // resets the demo on the push button
  if (internal_reset) begin 
     rom_address <= 4'b0000;
     data_ready <= 1'b0;            
     current_lcd_state <= 1'b0;
     halt <= 1'b0;
  end

// prepara para a reinicialização lançando a parada quando o push button
// é pressionado (o reset será executado quando o botão é liberado)

  if (old_reset != internal_reset) begin
    old_reset <= internal_reset;
     if (internal_reset == 1'b0) begin
       halt <= 1'b0;
     end
  end
   

  // para a demonstração, após uma execução na ROM
  if (rom_address == 4'b1111) begin    
    halt <= 1'b1;
    data_ready <= 1'b0;
  end


	// esta lógica monitora o sinalizador de ocupado do módulo LCD
   // quando o LCD passa de ocupado para livre, o controlador aumenta o
   // sinalizador de dados prontos e a saída da ROM é apresentada ao módulo LCD
   // quando o LCD passa de livre para ocupado, o controlador incrementa o
   // Endereço ROM para estar pronto para o próximo ciclo
        
                   
  if (halt == 1'b0) begin                        
    if (current_lcd_state != lcd_busy) begin   
      current_lcd_state <= lcd_busy;
      if (lcd_busy == 1'b0) begin
        data_ready <= 1'b1;
      end
      else if (lcd_busy == 1'b1 && data_ready == 1'b1) begin
        rom_address <= rom_address + 4'b0001;
        data_ready <= 1'b0;
      end
    end
  end



end



endmodule



//------------------------------------

module debounce (
  clk,
  in,
  out
  );

input clk;
input in;
output out;

reg out;

wire delta;
reg [19:0] timer;

initial timer = 20'b0;
initial out = 1'b0;

assign delta = ~in ^ out;     //negative logic on pushbutton 

always @(posedge clk) begin
  if (timer[19]) begin
    out <= ~in;               
    timer <= 20'b0;
  end
  else if (delta) begin
    timer <= timer + 20'b1;
  end
  else begin
    timer <= 20'b0;
  end
end


endmodule
//--------------------------------------
module rom (
rom_in   , // Address input
rom_out    // Data output
);
input [3:0] rom_in;
output [8:0] rom_out;

reg [8:0] rom_out;
     
always @*
begin
  case (rom_in) // hello world
   4'h0: rom_out = 9'b101001000;
   4'h1: rom_out = 9'b101100101;
   4'h2: rom_out = 9'b101101100;
   4'h3: rom_out = 9'b101101100;
   4'h4: rom_out = 9'b101101111;
   4'h5: rom_out = 9'b011000000;
   4'h6: rom_out = 9'b101010111;
   4'h7: rom_out = 9'b101101111;
   4'h8: rom_out = 9'b101110010;
   4'h9: rom_out = 9'b101101100;
   4'ha: rom_out = 9'b101100100;
   4'hb: rom_out = 9'b100100000;
   4'hc: rom_out = 9'b100100000;
   4'hd: rom_out = 9'b100100000;
   4'he: rom_out = 9'b100100000;
   4'hf: rom_out = 9'b100100000;
   default: rom_out = 9'hXXX;
  endcase
end



endmodule
