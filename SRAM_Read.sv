//=======================================================
//  SDRAM Read
//=======================================================
module SDRAM_Read #(parameter N=13, M=16)
(
	input  logic			clk,
	output logic			WE_N,
	output logic [N-1:0]	adr,
	output logic [M-1:0] Pin_Out, 
	input  logic [M-1:0]	din,
	output logic [M-1:0]	dout,
	
	output logic			ColumnSelect_N,
	output logic			RowSelect_N,
	output logic			clk_enable,
	output logic			CS_N,
	output logic [1:0] 	BitMask,
	output logic			Bank,
	input 					KEY
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
typedef enum logic [1:0] {Idle, Row_Active, Read, PreCharge} statetype;
statetype state = Idle, nextState = Idle;

reg [N-1:0]	File_Word_Length = 8191;
reg [N-1:0] Clk_Counter = 0;
reg Read_Initiated = 0;
reg Count_Enable	 = 0;

//=======================================================
//  Combinational Logic
//=======================================================
always_comb
begin
	case(state)
	Idle:
	begin
		CS_N				= 0;
		RowSelect_N		= 0;
		ColumnSelect_N	= 1;
		WE_N				= 0;
		Pin_Out			= 0;
		Count_Enable	= 0;
		nextState = Idle;
		if(Read_Initiated)
			nextState = Row_Active;
	end
	
	Row_Active:
	begin
		CS_N				= 0;
		RowSelect_N		= 1;
		ColumnSelect_N	= 0;
		WE_N				= 1;
		Count_Enable	= 0;
		nextState = Read;
		Pin_Out			= 0;
	end
		
	Read:
	begin
		if(Clk_Counter == File_Word_Length)
		begin
			CS_N				= 0;
			RowSelect_N		= 0;
			ColumnSelect_N	= 1;
			WE_N				= 0;
			Count_Enable	= 0;
			nextState = PreCharge;
			Pin_Out			= 0;
		end
		else
		begin
			CS_N				= 0;
			RowSelect_N		= 1;
			ColumnSelect_N	= 1;
			WE_N				= 1;
			Pin_Out			= din;
			Count_Enable	= 1;
			nextState = Read;
		end
	end
	
	PreCharge:
	begin
		CS_N				= 0;
		RowSelect_N		= 0;
		ColumnSelect_N	= 1;
		WE_N				= 0;
		Pin_Out			= 0;
		Count_Enable	= 0;
		nextState = Idle;
	end
	endcase
end

//=======================================================
//  Counter and Value Calculations
//=======================================================

always_ff @(posedge clk)
begin
	if(Count_Enable)
		Clk_Counter <= Clk_Counter + 1;
	else
		Clk_Counter <= 0;
end

always_ff @(posedge clk, posedge KEY)
begin
	if(KEY)
	begin
		adr <= 0;
		Bank <= 0;
		BitMask <= 0;
		clk_enable <= 1;
		Read_Initiated <= 1;
	end
	else
	begin
		Read_Initiated = 0;
		state <= nextState;
	end
end

endmodule
