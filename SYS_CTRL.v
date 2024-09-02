
module SYS_CTRL  # ( parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 ) (

 input   wire                     CLK,
 input   wire                     RST,

 output  wire                     RF_WrEn,
 output  wire                     RF_RdEn,
 output  wire [RF_ADDR-1:0]       RF_Address,
 output  wire [DATA_WIDTH-1:0]    RF_WrData,
 input   wire [DATA_WIDTH-1:0]    RF_RdData,
 input   wire                     RF_RdData_VLD,

 output  wire                     CLKG_EN,
 output  wire                     CLKDIV_EN,

 output  wire [3:0]               ALU_FUN, 
 output  wire                     ALU_EN,
 input   wire [DATA_WIDTH*2-1:0]  ALU_OUT,
 input   wire                     ALU_OUT_VLD,

 input   wire [DATA_WIDTH-1:0]    UART_RX_DATA,
 input   wire                     UART_RX_VLD,

 input   wire        			  UART_TX_Busy,
 output  wire [DATA_WIDTH-1:0]    UART_TX_DATA,
 output  wire        			  UART_TX_VLD
);


SYS_CTRL_RX  SYS_CTRL_RX_U0 (
.CLK(CLK),
.RST(RST),
.RF_RdData_VLD(RF_RdData_VLD),
.RF_WrEn(RF_WrEn),
.RF_RdEn(RF_RdEn),
.RF_Address(RF_Address),
.RF_WrData(RF_WrData),
.ALU_EN(ALU_EN),
.ALU_FUN(ALU_FUN), 
.ALU_OUT(ALU_OUT),
.ALU_OUT_VLD(ALU_OUT_VLD),  
.CLKG_EN(CLKG_EN), 
.CLKDIV_EN(CLKDIV_EN),
.UART_RX_DATA(UART_RX_DATA), 
.UART_RX_VLD(UART_RX_VLD)
);
 
 
SYS_CTRL_TX  SYS_CTRL_TX_U0 (
.CLK(CLK),
.RST(RST),
.RF_RdData(RF_RdData),
.RF_RdData_VLD(RF_RdData_VLD),
.ALU_OUT(ALU_OUT),
.ALU_OUT_VLD(ALU_OUT_VLD),  
.UART_TX_Busy(UART_TX_Busy),
.UART_TX_DATA(UART_TX_DATA), 
.UART_TX_VLD(UART_TX_VLD)
);
 



endmodule
 
