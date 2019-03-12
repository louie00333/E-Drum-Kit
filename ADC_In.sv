//=======================================================
//  PWM Generation
//=======================================================
module ADC_In(	
	output logic [7:0]  LED,
	output logic [11:0] ADC_Val,
	output logic	CS_N = 0,
	output logic	ADC_SADDR,
	output logic	ADC_SCLK,

	input logic 	clk,
	input logic		ADC_SDAT
	
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
typedef enum logic [2:0] {NOP, Address_Assert3,Address_Assert2, Address_Assert1, Data_Collect} statetype;
statetype state = NOP, nextState = NOP;

//=======================================================
//  Pre-Assignments
//=======================================================
reg [2:0] ADC_Address 	 = 'b000;
reg [5:0] Counter			 = 16;
reg [11:0] ADC_Val_Temp  = 0;
reg Counter_Flag = 0;
reg Data = 0;

//=======================================================
//  Counter and Value Calculations
//=======================================================
always_ff @(posedge clk)
begin
   state <= nextState;
	Counter <= Counter - 1;
	if(Counter == 0)
		Counter <= 16;
end

always_ff @(*)
begin
	if(Counter_Flag)
	begin
		ADC_Val_Temp[Counter] <= Data;
	end
end

always_ff @(negedge Counter_Flag)
begin
	ADC_Val <= ADC_Val_Temp;
	LED[7:0] <= ADC_Val_Temp[11:4];
end
//=======================================================
//  Combinational Logic
//=======================================================
always_comb
begin
	ADC_SCLK = clk;
end

always_comb
begin
	case(state)
	NOP:
	begin
		Counter_Flag = 0;
		ADC_SADDR = 0;
		Data = 0;
		if(Counter == 15)
			nextState = Address_Assert3;
		else
			nextState = NOP;
	end
	
	Address_Assert3:
	begin
		Counter_Flag = 0;
		ADC_SADDR = ADC_Address[2];
		Data = 0;
		nextState = Address_Assert2;
	end
	
	Address_Assert2:
	begin
		Counter_Flag = 0;
		ADC_SADDR = ADC_Address[1];
		Data = 0;
		nextState = Address_Assert1;
	end
	
	Address_Assert1:
	begin
		Counter_Flag = 0;
		ADC_SADDR = ADC_Address[0];
		Data = ADC_SDAT;
		nextState = Data_Collect;
	end
	
	Data_Collect:
	begin
		if(Counter == 0)
		begin
			Counter_Flag = 0;
			ADC_SADDR = 0;
			Data = ADC_SDAT;
			nextState = NOP;
		end
		else
		begin
			Counter_Flag = 1;
			ADC_SADDR = 0;
			Data = ADC_SDAT;
			nextState = Data_Collect;
		end
	end
	
	endcase
end
endmodule

