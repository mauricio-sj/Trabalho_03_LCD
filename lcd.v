module lcd(
  clock,
  internal_reset,
  d_in,
  data_ready,
  rw,
  rs,
  e,
  d,
  busy_flag
);

input clock;
input internal_reset;
input [8:0] d_in;
input data_ready;
output rs;
output rw;
output e;
output [7:0] d;
output busy_flag;

assign rw = 1'b0;

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
reg flag_15ms = 1'b0;


parameter CLK_FREQ = 50000000;

parameter integer D_50ns  = 0.000000050 * CLK_FREQ;
parameter integer D_250ns = 0.000000250 * CLK_FREQ;

parameter integer D_40us  = 0.000040000 * CLK_FREQ;
parameter integer D_60us  = 0.000060000 * CLK_FREQ;
parameter integer D_200us = 0.000200000 * CLK_FREQ;

parameter integer D_2ms   = 0.002000000 * CLK_FREQ;
parameter integer D_5ms   = 0.005000000 * CLK_FREQ;
parameter integer D_15ms  = 0.015000000 * CLK_FREQ;

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

always @(posedge clock) begin
	if (internal_reset) begin
		 state <= 5'b00000;
		 counter_clear <= 1'b1;
		 start <= 1'b1;
		 busy_flag <= 1'b0;
		 rs <= 1'b0;
	end 

// contador

	else if (counter_clear) begin
		 count <= 24'h000000;
		 counter_clear <= 1'b0;  
		 flag_50ns  <= 1'b0;
		 flag_250ns <= 1'b0;
		 flag_40us  <= 1'b0;
		 flag_60us  <= 1'b0;
		 flag_200us <= 1'b0;
		 flag_2ms   <= 1'b0;
		 flag_5ms   <= 1'b0;
		 flag_15ms <= 1'b0;
	end

	else if (!counter_clear) begin
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
		 if (count == D_15ms) begin
			flag_15ms <= 1'b1;
		 end
	end

case (state)

   // Passo 1 - atraso de 100 ms após ligar o 
  STATE00: begin                        
    busy_flag <= 1'b1;                  // diz a outros módulos que o LCD está processando 
    if (flag_15ms) begin               // se 100ms tiverem decorrido 
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
    if (flag_50ns && !counter_clear) begin                // if 50ns have elapsed (lets RS and D settle)
      e <= 1'b1;                        // bring E high to initiate data write    
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE02;                 // advance to the next state
    end
  end
  STATE02: begin                         
    if (flag_250ns && !counter_clear) begin               // if 250ns have elapsed
      e <= 1'b0;                        // bring E low   
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE03;                 // advance to the next state
    end
  end
  STATE03: begin
    if (flag_5ms && !counter_clear) begin                 // if 5ms have elapsed
      e <= 1'b1;                        // bring E high to initiate data write   
      counter_clear <= 1'b1;            // clear the counter      
      state <= STATE04;                 // advance to the next state               
    end
  end

 // Step 3 - second Function Set instruction
  STATE04: begin
    if (flag_250ns && !counter_clear) begin               // if 250ns have elapsed
      e <= 1'b0;                        // bring E low    
      counter_clear <= 1'b1;            // clear the counter
      state <= STATE05;                 // advance to the next state  
    end
  end
  STATE05: begin
    if (flag_200us && !counter_clear) begin 
      e <= 1'b1;                           
      counter_clear <= 1'b1;
      state <= STATE06;
      end
    end

  // Step 4 - third and final Function Set instruction
  STATE06: begin
    if (flag_250ns && !counter_clear) begin
      e <= 1'b0;      
      counter_clear <= 1'b1;
      state <= STATE07;                          
    end
  end
  STATE07: begin
    if (flag_200us && !counter_clear) begin
      d  <= 8'b00111000;                // configuration cmd = 8-bit mode, 2 lines, 5x7 font 
      counter_clear <= 1'b1;
      state <= STATE08;
    end
  end

  // Step 5 - enter the Configuration command
  STATE08: begin                        
    if (flag_50ns && !counter_clear) begin 
      e <= 1'b1; 
      counter_clear <= 1'b1; 
      state <= STATE09;
    end
  end
  STATE09: begin                        
    if (flag_250ns && !counter_clear) begin
      e <= 1'b0; 
      counter_clear <= 1'b1; 
      state <= STATE10;
    end
  end
  STATE10: begin
    if (flag_60us && !counter_clear) begin
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
    if (flag_250ns && !counter_clear) begin
      e <= 1'b0;
      counter_clear <= 1'b1;
      state <= STATE13;
    
    end
  end
  STATE13: begin
    if (flag_60us && !counter_clear) begin
      d  <= 8'b00000001;                // limpa o comando
      counter_clear <= 1'b1;
      state <= STATE14;
     end
  end

  // Step 7 - enter the Clear command
  STATE14: begin                        
    if (flag_50ns && !counter_clear) begin
      e <= 1'b1;
      counter_clear <= 1'b1;
      state <= STATE15;   
    end
  end
  STATE15: begin                        
    if (flag_250ns && !counter_clear) begin
      e <= 1'b0;
      counter_clear <= 1'b1;
      state <= STATE16;     
    end
  end
  STATE16: begin
    if (flag_5ms && !counter_clear) begin                 // 5ms (clear command has a long cycle time)
      d  <= 8'b00000110;                // entry mode  
      counter_clear <= 1'b1;
      state <= STATE17;
     end
  end

  //Step 8 - Set the Entry Mode to: cursor moves, display stands still
  STATE17: begin                        
    if (flag_50ns && !counter_clear) begin
      e <= 1'b1;   
      counter_clear <= 1'b1;
      state <= STATE18;
    end
  end
  STATE18: begin                        
    if (flag_250ns && !counter_clear) begin 
      e <= 1'b0;  
      counter_clear <= 1'b1;
      state <= STATE19;    
    end
  end
  STATE19: begin
    if (flag_60us && !counter_clear) begin
      d  <= 8'b00001100;                // Display On
      counter_clear <= 1'b1;
      state <= STATE20;
    end
  end

  // Step 9 - enter the Display On command
  STATE20: begin                        
    if (flag_50ns && !counter_clear) begin
      e <= 1'b1;
      counter_clear <= 1'b1;
      state <= STATE21;
    end
  end
  STATE21: begin                        
    if (flag_250ns && !counter_clear) begin
      e <= 1'b0;
      counter_clear <= 1'b1;
      state <= STATE22;
    end
  end
  STATE22: begin
    if (flag_60us && !counter_clear) begin
      busy_flag <= 1'b0;                // clear the busy flag
      counter_clear <= 1'b1;
      state <= STATE23;  

    end
  end

// End Initialization - Start entering data.

  STATE23: begin
    if (counter_clear) 
    begin      // wait for data  
      start <= 1'b0;                    // clear the start flag
      rs <= d_in[8];                    // read the RS value from input       
      d  <= d_in[7:0];                  // read the data value input 
    end  
    else if (flag_50ns && !counter_clear) 
    begin	 // if 50ns have elapsed
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
    if (counter_clear) 
    begin            // if this is the first iteration of STATE25
      busy_flag <= 1'b1;
      e <= 1'b0; 		// Bring E low
    end
    else if (flag_40us && !counter_clear && rs) 
    begin  // if data is a character and 40us has elapsed
      busy_flag <= 1'b0;                // clear the busy flag
      counter_clear <= 1'b1;            // clear the counter 
      state <= STATE23;                 // go back to STATE23 and wait for next data
    end
    else if (flag_2ms && !counter_clear) 
    begin // if data is a command and 2ms has elapsed
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




//--------------------------------------
