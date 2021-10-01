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
output [5:0] rom_address;
output data_ready;

reg [5:0] rom_address = 6'b000000;
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
      if (!lcd_busy) begin
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