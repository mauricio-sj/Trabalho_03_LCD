module edgeDetector(in, reset, clk, active);

parameter number = 5'b00000;

// Toda vez que ocorre uma alteraçao de in
// o bloco seta active como 1 e aguarda um reset do sistema

input in, reset, clk;
output reg active;


reg [1:0] state;
reg [1:0] next_state;

always @ (posedge clk)
begin
	if (reset)
	begin
		if (in)
		begin
			state <= 0;
		end
		else
		begin
			state <= 1;
		end
	end
	else
		state <= next_state;
end

always @ (state, in)
begin
	active = 0;
	next_state = state;
	case (state)
		0:
		begin
			if (in)
				next_state = 2;
		end
		1:
		begin
			if (!in)
				next_state = 2;
		end
		2:
		begin
			active = 1;
			next_state = state;
		end
		default:
		begin
			active = 0;
			next_state = 0;
		end
		endcase
end



endmodule