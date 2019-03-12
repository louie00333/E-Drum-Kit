//=======================================================
//  Frequency Mixer
//=======================================================
module Modular_Adder(
	output logic[15:0]	Output_Freq,

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
typedef enum logic [3:0] {Idle, Add_1, Add_2, Add_3, Add_4, Add_5, Divider, Output} statetype;
statetype state = Idle, nextState = Idle;

reg unsigned [15:0] Output_Buffer = 0;
reg unsigned [2:0]  Counter = 0;
reg unsigned [15:0] TotalVal = 0;
reg unsigned [4:0]  Current_Select = 0;
//=======================================================
//  Output MUX
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
			nextState = Add_1;
		end
		
		Add_1:
		begin
			nextState = Add_2;
		end
		
		Add_2:
		begin
			nextState = Add_3;
		end
		
		Add_3:
		begin
			nextState = Add_4;
		end
		
		Add_4:
		begin
			nextState = Add_5;
		end
		
		Add_5:
		begin
			nextState = Divider;
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
			Output_Buffer <= 0;
			Output_Freq <= 0;
			Current_Select <= select;
	end
	
	else if(state == Add_1)
	begin
		if(select[0] == 0)
		begin
			Counter <= Counter + 1'b1;
			TotalVal <= TotalVal + Value_1;
		end
	end
	
	else if(state == Add_2)
	begin
		if(select[1] == 0)
		begin
			Counter <= Counter + 1'b1;
			TotalVal <= TotalVal + Value_2;
		end
	end
	
	else if(state == Add_3)
	begin
		if(select[2] == 0)
		begin
			Counter <= Counter + 1'b1;
			TotalVal <= TotalVal + Value_3;
		end
	end
		
	else if(state == Add_4)
	begin
		if(select[3] == 0)
		begin
			Counter <= Counter + 1'b1;
			TotalVal <= TotalVal + Value_4;
		end
	end
		
	else if(state == Add_5)
	begin
		if(select[4] == 0)
		begin
			Counter <= Counter + 1'b1;
			TotalVal <= TotalVal + Value_5;
		end
	end
	
	else if(state == Divider)
		Output_Freq <= (TotalVal/Counter);

	else if(state == Output)
	begin
	
	end
end

endmodule

