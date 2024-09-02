
`timescale 1ns/1ps

module SYS_TOP_TB ();

//parameters
parameter DATA_WIDTH  = 8 ;

//Testbench Signals
reg                                RST_N;
reg                                UART_CLK;
reg                                REF_CLK;
reg                                UART_RX_IN;
wire                               UART_TX_O;

// seperating the data assigned by '_' for each start, stop, parirty, and each 4 data bits
reg   [32:0]       WR_CMD     = 'b10_0111_0111_0_10_0000_0101_0_10_1010_1010_0 ; // write 0x77 in addres with (0x05) (3 frames)
reg   [21:0]       RD_CMD     = 'b11_0000_0010_0_10_1011_1011_0 ; // reading UART configration register from RF (2 frames)
reg   [43:0]       ALU_WP_CMD = 'b11_0000_0001_0_10_0000_0011_0_10_0000_0101_0_10_1100_1100_0 ; // substractiong 3 from 5 = 2 (4 frames)
reg   [21:0]       ALU_NP_CMD = 'b11_0000_0000_0_10_1101_1101_0 ; // adding the reserved operants (A & B)(2 frames)

reg                         RD_TEST_EN;
reg   [5:0]                 count = 6'b0 ;


always #(10) REF_CLK = ~REF_CLK ;

always #(50) UART_CLK = ~UART_CLK ;

// Design Under test without framing and parity error check
SYS_TOP DUT (
.UART_CLK(UART_CLK),
.REF_CLK(REF_CLK),
.RST_N(RST_N),
.UART_RX_IN(UART_RX_IN),
.UART_TX_O(UART_TX_O)
);

//Initial 
initial
 begin

//initial values
UART_CLK          = 1'b0   ;
REF_CLK           = 1'b0   ;
RST_N             = 1'b1   ;    // rst is deactivated
UART_RX_IN        = 1'b1   ;

//Reset the design
#5
RST_N = 1'b0;    // rst is activated
#5
RST_N = 1'b1;    // rst is deactivated

#20 
RD_TEST_EN = 1'b1 ;
#400000

$stop ;

end

always @ (posedge DUT.U0_ClkDiv.o_div_clk)
 begin
   if(RD_TEST_EN && count < 6'd22 )
   begin
      UART_RX_IN <=  RD_CMD[count] ;
      count <= count + 6'b1 ;
   end
  else
      UART_RX_IN <= 1'b1 ;  

 end
 
 







endmodule