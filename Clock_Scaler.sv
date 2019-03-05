//=======================================================
//  50Mhz --> 48Khz Clock Scaling
//=======================================================
module Clock_Scaler(
	input reg[15:0] clk_prescale,
	input				CLOCK_50,
	
	output reg		CLOCK_NEW = 0
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg	[15:0] clk_counter = 0;
typedef enum logic [1:0] {s0, s1, s2, s3} statetype;
statetype clk_state = s0;

//=======================================================
//  Combinational Logic
//=======================================================
always_comb
begin
	if(clk_counter == clk_prescale)
		clk_state <= s1;
	else
		clk_state <= s0;
end

//=======================================================
//  Counter and Logic
//=======================================================
always_ff @(posedge CLOCK_50)
begin	
	case(clk_state)
		s0:
			clk_counter = clk_counter + 1;
		s1:
		begin
			CLOCK_NEW	= ~CLOCK_NEW;		
			clk_counter	= 0;
		end
	endcase
end

endmodule 