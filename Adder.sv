//=======================================================
//  Frequency Mixer
//=======================================================
module Adder #(parameter N=4)
(
	output logic unsigned [15:0]	Output_Freq,

	input [15:0]	Value_1,
	input [15:0]	Value_2,
	input [15:0]	Value_3,
	input [15:0]	Value_4,
	input [15:0]	Value_5,
	input [4:0]		select,
	input clk
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
typedef enum logic [3:0] {Idle, Add, Divider, Output} statetype;
statetype state = Idle, nextState = Idle;

reg unsigned [15:0] Output_Buffer;
reg unsigned [3:0]  Addition_Counter = 0;
reg unsigned [3:0]  Counter = 0;
reg unsigned [15:0] TotalVal = 0;
reg unsigned [4:0]  Current_Select;
//=======================================================
//  Assignments
//=======================================================

//=======================================================
//  Combinational Logic
//=======================================================
always_comb
begin
	case(state)
		Idle:
		begin
			if(select == 5'b11110 ||
				select == 5'b11101 ||
				select == 5'b11011 ||
				select == 5'b10111 ||
				select == 5'b01111 ||
				select == 5'b11111 ||
				select == 5'bz)
			nextState = Idle;
			else
			nextState = Add;
		end
		
		Add:
		begin
			if(Addition_Counter == N)
				nextState = Divider;
			else
				nextState = Add;
		end
				
		Divider:
		begin
			nextState = Output;
		end
		
		Output:
		begin
			if(select == Current_Select)
				nextState = Output;
			else
				nextState = Idle;
		end
		
	endcase
end
//=======================================================
//  Counter and Value Calculations
//=======================================================
always_ff @(posedge clk)
begin
	state <= nextState;

	if(state == Idle)
	begin
			Counter <= 0;
			TotalVal <= 0;
			Addition_Counter <= 0;
			Current_Select <= select;
	end
	
	else if(state == Add)
	begin
		if(select[Addition_Counter] == 0)
		begin
			if(Addition_Counter == 0)
				TotalVal <= TotalVal + Value_1;
			if(Addition_Counter == 1)
				TotalVal <= TotalVal + Value_2;
			if(Addition_Counter == 2)
				TotalVal <= TotalVal + Value_3;
			if(Addition_Counter == 3)
				TotalVal <= TotalVal + Value_4;
			if(Addition_Counter == 4)
				TotalVal <= TotalVal + Value_5;
			Counter <= Counter + 1'b1;
		end
			Addition_Counter = Addition_Counter + 1'b1;
		
	end
	
	else if(state == Divider)
		Output_Freq <= (TotalVal/Counter);

	else if(state == Output)
	begin
	end
end

endmodule

