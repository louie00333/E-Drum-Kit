//=======================================================
//  PWM Generation
//=======================================================
module PWM_Generator(
	output logic		GPIO_2,
	
	input  reg [15:0]	Top,		
	input	 logic		clk,
	output LED
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [15:0] PWM_Counter = 0;
reg [15:0] Compare;
assign	Compare = Top/16'h2;  

typedef enum logic [1:0] {CountUpBefore, CompareMatch, CountUpAfter} statetype;
statetype state = CountUpBefore, nextState = CountUpBefore;

//=======================================================
//  Pre-Assignments
//=======================================================

assign LED = 1;
//=======================================================
//  Output MUX
//=======================================================

//=======================================================
//  Combinational Logic
//=======================================================
always_comb
begin
	case(state)
		CountUpBefore:
		begin
			if(PWM_Counter == Compare)
			begin
				GPIO_2 = 0;
				nextState = CountUpAfter;
			end
			else
			begin
				GPIO_2 = 0;
				nextState = CountUpBefore;
			end
		end
		CountUpAfter:
		begin
			if(PWM_Counter == 0)
			begin
			GPIO_2 = 1;
			nextState = CountUpBefore;
			end
			else
			begin
			GPIO_2 = 1;
			nextState = CountUpAfter;
			end
		end
	endcase
end

//=======================================================
//  Counter and Value Calculations
//=======================================================

always_ff @(posedge clk)
begin
	state <= nextState;
	if(PWM_Counter == Top)
		PWM_Counter <= 0;
	else
		PWM_Counter <= PWM_Counter + 1'b1;
end
endmodule

