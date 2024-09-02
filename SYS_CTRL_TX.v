module SYS_CTRL_TX  # ( parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 ) (

 input   wire                     CLK,
 input   wire                     RST,

 input   wire [DATA_WIDTH-1:0]    RF_RdData,
 input   wire                     RF_RdData_VLD,

 input   wire [DATA_WIDTH*2-1:0]  ALU_OUT,
 input   wire                     ALU_OUT_VLD, 

 input   wire        			  UART_TX_Busy,
 output  reg  [DATA_WIDTH-1:0]    UART_TX_DATA,
 output  reg         			  UART_TX_VLD
);

// gray state encoding
localparam          IDLE           = 1'b0 ,
                    TRANSMIT       = 1'b1 ;

reg                   current_state , next_state ;
reg     [DATA_WIDTH-1:0]    Stored_Data;
			

//state transiton 
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    current_state <= IDLE ;
   end
  else
   begin
    current_state <= next_state ;
   end
 end

// next state logic
always @ (*)
 begin
  case(current_state)
  IDLE    : begin
                if (RF_RdData_VLD)
                begin
                    Stored_Data = RF_RdData;
                    next_state = TRANSMIT;	
                end
                else
                if (ALU_OUT_VLD)
                begin
                    Stored_Data = ALU_OUT;
                    next_state = TRANSMIT;	
                end
                else
                    next_state = IDLE;
            end
  TRANSMIT  : begin
                if (!UART_TX_Busy)begin
                    UART_TX_VLD  = 1'b1;
                    UART_TX_DATA = Stored_Data;
                    next_state = IDLE;
                end
                else
                begin
                    UART_TX_VLD  = 1'b0;
                    next_state = TRANSMIT;
                end
            end
  default : begin
                next_state = IDLE ; 
            end	
  endcase                 	   
 end 

endmodule
 
