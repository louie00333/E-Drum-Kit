//=======================================================
//  PWM Generation
//=======================================================
module PWM_Test(
	output reg			GPIO_2 = 0,
	input reg [15:0]	Top,		
	input					clk_enabled,
	input reg		 	KEY
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [15:0]	PWM_Counter = 0;
reg [15:0]	Compare;
reg			PWM_Output = 0;
reg			disconnect = 0;
reg			clk_enable;

typedef enum logic [1:0] {s0, s1, s2, s3} statetype;
statetype state = s1;

//=======================================================
//  Pre-Assignments
//=======================================================
assign				Compare = Top/2; 

//=======================================================
//  Output MUX
//=======================================================
assign clk = (KEY) ? clk_enable : disconnect;

//=======================================================
//  Combinational Logic
//=======================================================
always_comb
begin
	if(PWM_Counter == Top)
		state <= s0;
		
	else if(PWM_Counter == Compare)
		state <= s2;
		
	else
		state <= s1;
end

//=======================================================
//  Counter and Value Calculations
//=======================================================
always_ff @(posedge clk)
begin
	case(state)
		s0:
		begin
			PWM_Counter <= 0;
			PWM_Output <= 0;
		end
		s1:
		begin
			PWM_Counter = PWM_Counter + 1;
		end
		s2:
		begin
			PWM_Counter = PWM_Counter + 1;
			PWM_Output <= 1;
		end	
	endcase
end

endmodule

