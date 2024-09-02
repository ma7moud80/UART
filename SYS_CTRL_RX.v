module SYS_CTRL_RX  # ( parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 ) (

 input   wire                     CLK,
 input   wire                     RST,

 output  reg                      RF_WrEn,
 output  reg                      RF_RdEn,
 output  reg  [RF_ADDR-1:0]       RF_Address,
 output  reg  [DATA_WIDTH-1:0]    RF_WrData,
 input   wire                     RF_RdData_VLD,

 output  reg                      CLKG_EN,
 output  reg                      CLKDIV_EN,

 input   wire [DATA_WIDTH*2-1:0]  ALU_OUT,
 input   wire                     ALU_OUT_VLD, 
 output  reg  [3:0]               ALU_FUN, 
 output  reg                      ALU_EN,

 input   wire [DATA_WIDTH-1:0]    UART_RX_DATA,
 input   wire                     UART_RX_VLD
);


// gray state encoding
localparam  [3:0]      IDLE           = 4'b000 ,
                       RF_WR_ADDR     = 4'b001 ,
                       RF_WR_DATA     = 4'b010 ,
                       RF_WR_EN       = 4'b011 ,
					   RF_RD_ADDR     = 4'b100 ,
                       RF_RD_EN       = 4'b101 ,
					   ALU_FN_OP_A    = 4'b110 ,
                       ALU_FN_OP_A_EN = 4'b111 ,
					   ALU_FN_OP_B    = 4'b1000 ,
                       ALU_FN_OP_B_EN = 4'b1001 ,
					   ALU_FN         = 4'b1010 ,
                       ALU_FN_EN      = 4'b1011 ;

reg  [3:0]            current_state , next_state ;
reg  [RF_ADDR-1:0]    Stored_WR_ADDR;
reg  [1:0]			  wait_counter= 2'b00;

//state transiton 
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    current_state <= IDLE ;
    Stored_WR_ADDR <= 'b0;
   end
  else
   begin
    current_state <= next_state ;
    if (next_state == RF_WR_DATA) Stored_WR_ADDR <= UART_RX_DATA;
   end
   
 end
 

// next state logic
always @ (*)
 begin
  case(current_state)
  IDLE        : begin
                    if(UART_RX_VLD)
                    begin
                    case (UART_RX_DATA)
                            'hAA    : next_state = RF_WR_ADDR ; // Register File Write Command
                            'hBB    : next_state = RF_RD_ADDR ; // Register File Read Command
                            'hCC    : next_state = ALU_FN_OP_A ; // Alu Command with Operands
                            'hDD    : next_state = ALU_FN ; // Alu Command without Operands
                            default : next_state = IDLE ;
                    endcase
                    end
                    else
                    next_state = IDLE ; 			
                 end
  RF_WR_ADDR  : begin
                    if(UART_RX_VLD)
                        next_state = RF_WR_DATA;
                    else
                        next_state = RF_WR_ADDR ; 
                end
  RF_WR_DATA  : begin
                    if(UART_RX_VLD)
                        next_state = RF_WR_EN;
                    else
                        next_state = RF_WR_ADDR ; 
                end
  RF_WR_EN    : begin
                    wait_counter = wait_counter + 1;
                    if (wait_counter == 2'b11)
                    begin
                    wait_counter = 2'b00;
                    next_state = IDLE;
                    end
                end
  RF_RD_ADDR  : begin
                    if(UART_RX_VLD)
                        next_state = RF_RD_EN;
                    else
                        next_state = RF_RD_ADDR ; 
                end
  RF_RD_EN    : begin
                    wait_counter = wait_counter + 1;
                    if(RF_RdData_VLD && wait_counter == 2'b11)
                    begin
                        wait_counter = 2'b00;
                        next_state = IDLE;
                    end
                    else
                        next_state = RF_RD_EN ; 	
                end
  ALU_FN_OP_A : begin
                    if(UART_RX_VLD)
                        next_state = ALU_FN_OP_A_EN;
                    else
                        next_state = ALU_FN_OP_A ; 
                end
  ALU_FN_OP_A_EN: begin
                    next_state = ALU_FN_OP_B;
                end
  ALU_FN_OP_B : begin
                    if(UART_RX_VLD)
                        next_state = ALU_FN_OP_B_EN;
                    else
                        next_state = ALU_FN_OP_B ; 
                end
  ALU_FN_OP_B_EN:begin
                    next_state = ALU_FN;
                end
  ALU_FN      : begin
                    if(UART_RX_VLD)
                        next_state = ALU_FN_EN;
                    else
                        next_state = ALU_FN ; 
                end	
  ALU_FN_EN      : begin
                    wait_counter = wait_counter + 1;
                    if(ALU_OUT_VLD && wait_counter == 2'b11)
                    begin
                        wait_counter = 2'b00;
                        next_state = IDLE;
                    end
                    else
                        next_state = ALU_FN_EN ; 	
                end	
  default     : begin
			        next_state = IDLE ; 
                end	
  endcase                 	   
 end 

 
// output logic
always @ (*)
 begin
    CLKG_EN       = 1'b0;
    CLKDIV_EN     = 1'b1;
  case(current_state)
  IDLE        : begin
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b0;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;	
                 end
  RF_WR_ADDR  : begin
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = Stored_WR_ADDR;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  RF_WR_DATA  : begin
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = Stored_WR_ADDR;
                    RF_WrData     = UART_RX_DATA;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  RF_WR_EN  : begin
                    RF_WrEn       = 1'b1;
                    RF_Address    = Stored_WR_ADDR;
                    RF_WrData     = UART_RX_DATA;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  RF_RD_ADDR  : begin
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = UART_RX_DATA;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  RF_RD_EN  : begin
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b1;
                    RF_Address    = UART_RX_DATA;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  ALU_FN_OP_A  : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b0;
                    RF_WrData     = UART_RX_DATA;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  ALU_FN_OP_A_EN  : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b1;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b0;
                    RF_WrData     = UART_RX_DATA;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  ALU_FN_OP_B : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b1;
                    RF_WrData     = UART_RX_DATA;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  ALU_FN_OP_B_EN : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b1;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b1;
                    RF_WrData     = UART_RX_DATA;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end
  ALU_FN      : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b0;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b0;
                    if(UART_RX_VLD)
                        ALU_FUN   = UART_RX_DATA;
                    else
                        ALU_FUN   = 'b0;
                end
  ALU_FN_EN   : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b0;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b1;
                    ALU_FUN       = UART_RX_DATA;
                end			  		   
  default     : begin
                    CLKG_EN       = 1'b1;
                    RF_WrEn       = 1'b0;
                    RF_RdEn       = 1'b0;
                    RF_Address    = 'b0;
                    RF_WrData     = 'b0;
                    ALU_EN        = 1'b0;
                    ALU_FUN       = 'b0;
                end	
  endcase                	   
 end 

endmodule
 
