module lastTwo(active, number, reset, clk, switches, last, secondLast, resetActive, lastStatus, secondLastStatus);

// uma fsm maior que guarda as saidas dos outros dois blocos, salvando os ultimos que seriam adicionados
// e disponibilizando eles estaticamente na saida


input [5:0] number;
input active, reset, clk;
input [17:0] switches

output reg [5:0] last;
output reg [5:0] secondLast;
output reg lastStatus;
output reg secondLastStatus;
output reg resetActive;

reg [1:0] state;
reg [1:0] next_state;

always @ (posedge clk)
begin
	if (reset)
		state <= 0;
	else
		state <= next_state;
end

always @ (number, active, state)
begin
	resetActive = 0;
	case (state)
		0:
		begin
			if (active)
				next_state = 1;
			else
				next_state = 0;
		end
		1:
		begin
			secondLast = last;
			secondLastStatus = lastStatus;
			next_state = 2;
		end
		2:
		begin
			last = number - 1;
			lastStatus = switches[number-1];
			next_state = 3;
		end
		3:
		begin
			resetActive = 1;
			next_state = 0;
		end
		default:
		begin
			resetActive = 0;
			next_state = 0;
		end
	endcase
end

endmodule