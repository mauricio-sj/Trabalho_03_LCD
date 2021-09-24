module ativ2(in, out);
	input [17:0] in;
	
	output reg [4:0] out;
	reg [5:0] i;
	
	// um bloco estatico de 18 bits para identificar um padrao one hot
	// da entrada, ou seja, se dois blocos de entrada ficarem um ele nao ativara,
	// serve somente para entradas que dependem do usuario, ou seja, um clock rapido demais
	// para qeu o usuario consiga ativar mais de um switch antes da resposta do sistema
	
	always @ (in)
	begin
//		for (i=0; i<18; i= i+ 1)
//		begin
//			if (in[i] == 1'b1)
//			begin
//				number = i;
//				sum = sum+1;
//			end
//		end
		out = 0;
		if (in == 1) out = 1;
		if (in == 2) out = 2;
		if (in == 4) out = 3;
		if (in == 8) out = 4;
		if (in == 16) out = 5;
		if (in == 32) out = 6;
		if (in == 64) out = 7;
		if (in == 128) out = 8;
		if (in == 256) out = 9;
		if (in == 1024) out = 10;
		if (in == 2048) out = 11;
		if (in == 4096) out = 12;
		if (in == 8192) out = 13;
		if (in == 16384) out = 14;
		if (in == 32768) out = 15;
		if (in == 65536) out = 16;
		if (in == 131072) out = 17;
		if (in == 262144) out = 18;
	end
endmodule