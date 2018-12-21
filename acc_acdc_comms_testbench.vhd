library IEEE; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- ACC defs
library workacc;
use workacc.defs.all;
-- ACDC defs
library workacdc;
use workacdc.Definition_Pool.all;

-- to simulate arriav_lcell_comb in the 8b10b libraries
library arriav_ver;
library arriav;

entity testbench is
end entity testbench;

architecture BENCH of testbench is

  COMPONENT lvds_com is -- ACDC
	port(
			xSTART		 		: in   	std_logic_vector(4 downto 0);
			xDONE		 			: out   	std_logic_vector(4 downto 0);
			xCLR_ALL	 			: in   	std_logic;
			xALIGN_SUCCESS		: out		std_logic;
			 
			xADC					: in   ChipData_array;
			xINFO1				: in   ChipData_array;
			xINFO2				: in   ChipData_array;
			xINFO3				: in   ChipData_array;
			xINFO4				: in   ChipData_array;
			xINFO5				: in   ChipData_array;
			xINFO6				: in   ChipData_array;
			xINFO7				: in   ChipData_array;
			xINFO8				: in   ChipData_array;
			xINFO9				: in   ChipData_array;
			xINFO10				: in   ChipData_array;
			xINFO11				: in   ChipData_array;
			xINFO12				: in   ChipData_array;
			xINFO13				: in 	 ChipData_array;
			
			xEVT_CNT				: in   EvtCnt_array;
			
				
			xCLK_40MHz			: in		std_logic;
			 
			xRX_LVDS_DATA	 	: in		std_logic;
			xRX_LVDS_CLK	 	: in		std_logic;
			xINSTRUCTION		: out		std_logic_vector(31 downto 0);
			xINSTRUCT_READY	: out		std_logic;
			xPSEC_MASK			: in 		std_logic_vector(4 downto 0);
			xFPGA_PLL_LOCK		: in		std_logic;
			xEXTERNAL_DONE		:		in	std_logic;
			
			xREAD_ADC_DATA		: in		std_logic;
			
			xREAD_TRIG_RATE_ONLY  	: in	std_logic;
			xSELF_TRIG_RATE_COUNT 	: in rate_count_array;
				
			xSYSTEM_IS_CLEAR			: in	std_logic;
			xPULL_RAM_DATA				: in  std_logic;
			xCLK_COMS					: in  std_logic;
			
			xTX_LVDS_DATA		: out		std_logic_vector(1 downto 0);
			xTX_LVDS_CLK		: out		std_logic;

			xRADDR				: out  	std_logic_vector (RAM_ADR_SIZE-1 downto 0);
			xRAM_READ_EN		: out		std_logic_vector(4 downto 0);
			xDC_XFER_DONE		: out		std_logic_vector(4 downto 0);
			xTX_BUSY				: out 	std_logic;
			xRX_BUSY				: out		std_logic);
			
end COMPONENT;

COMPONENT transceivers is -- ACC
	port(
		xCLR_ALL				: in	std_logic;	--global reset
		xALIGN_SUCCESS 	: out	std_logic;  --successfully aligned
		
		xCLK					: in	std_logic;	--system clock
		xCLK_COMs			: in  std_logic;  --clock for communications
		
		xRX_LVDS_DATA		: in	std_logic_vector(1 downto 0); --serdes data received (2x)
		xRX_LVDS_CLK		: in	std_logic;  --bytealigned clk for serdes data received
		xTX_LVDS_DATA		: out	std_logic;                    --serdes data transmitted
		xTX_LVDS_CLK	 	: out		std_logic;                  --bytealigned clk for serdes data transmitted
		
		xCC_INSTRUCTION	: in	std_logic_vector(instruction_size-1 downto 0);	--front-end 
		xCC_INSTRUCT_RDY	: in	std_logic;	--intruction ready to send to front-end
		xTRIGGER				: in	std_logic;	--trigger in
		xCC_SEND_TRIGGER	: out	std_logic;	--trigger out to front-end
		 
		xRAM_RD_EN			: in	std_logic; 	--enable reading from RAM block
		xRAM_ADDRESS		: in	std_logic_vector(transceiver_mem_depth-1 downto 0);--ram address
		xRAM_CLK				: in	std_logic;	--slwr from USB	
		xRAM_FULL_FLAG		: out	std_logic_vector(num_rx_rams-1 downto 0);	--event in RAM
		xRAM_DATA			: out	std_logic_vector(transceiver_mem_width-1 downto 0);--data out
		xRAM_SELECT_WR		: in	std_logic_vector(num_rx_rams-1 downto 0); --select ram block, write
		xRAM_SELECT_RD		: in	std_logic_vector(num_rx_rams-1 downto 0); --select ram block, read

		xALIGN_INFO			: out std_logic_vector(2 downto 0); --3 bit, alignment indicator of 3 SERDES links
		xCATCH_PKT			: out std_logic;	--flag that a data packet from front-end was received
		
		xDONE					: in	std_logic;	--done reading from USB/etc (firmware done)
		xDC_MASK				: in	std_logic;	--mask bit for address
		xPLL_LOCKED			: in	std_logic;  --FPGA pll locked
		xSOFT_RESET			: in	std_logic);	--software reset, done reading to cpu (software done)
		
end COMPONENT;

  signal Stop                       : BOOLEAN;
  -- ACC side
  signal reset_global               : STD_LOGIC;
  signal xalign_good                : STD_LOGIC;
  signal clock_sys, clocks_rx       : STD_LOGIC;
  signal clock_sys4x                : STD_LOGIC;
  signal rx_serdes                  : STD_LOGIC_VECTOR(1 downto 0);
  signal rx_serdes_clk              : STD_LOGIC;
  signal tx_serdes                  : STD_LOGIC;
  signal tx_serdes_clk              : STD_LOGIC;
  signal xInstruction               : STD_LOGIC_VECTOR(31 downto 0);
  signal xInstruct_Rdy              : STD_LOGIC;
  signal xtrig                      : STD_LOGIC;
  signal trigger_to_fe              : STD_LOGIC;
  signal packet_from_fe_rec         : STD_LOGIC;
  signal xdone, xfe_mask            : STD_LOGIC;
  signal clock_FPGA_PLLlock         : STD_LOGIC;
  signal lvds_aligned_tx            : STD_LOGIC;
  signal xready                     : STD_LOGIC;

  -- ACDC side
  signal acdc_xstart                : std_logic_vector(4 downto 0);
  --signal acdc_xdone                 : std_logic_vector(4 downto 0);
  signal acdc_instruction_out       : STD_LOGIC_VECTOR(31 downto 0);
  signal acdc_instruction_ready     : STD_LOGIC;
  signal acdc_txbusy                : STD_LOGIC;
  signal acdc_rxbusy                : STD_LOGIC;
  signal acdc_dummycda              : ChipData_array;
  signal acdc_dummyevtcnt           : EvtCnt_array;
  signal acdc_dummyrca              : rate_count_array;
  
  
begin
  Stop <= FALSE;
  -- ACC side
  xtrig <= '0';
  xdone <= '1';
  xfe_mask <= '1';  -- we're sending commands to this port
  clock_FPGA_PLLlock <= '1';
  xready <= '1';
  
  acdc_xstart <= (others => '0');
  
  reset_gen: process
  begin
    reset_global <= '0';
    wait for 1 NS;
    reset_global <= '1';
    wait for 50 NS;
    reset_global <= '0';
    wait;
  end process;
  
  clocksys_gen: process -- 40mhz
  begin
    while not Stop loop
      clock_sys <= '0';
      wait for 12.5 NS;
      clock_sys <= '1';
      wait for 12.5 NS;
    end loop;
    wait;
  end process;
  clocksys4x_gen: process -- 40mhz
  begin
    while not Stop loop
      clock_sys4x <= '0';
      wait for 3.125 NS;
      clock_sys4x <= '1';
      wait for 3.125 NS;
    end loop;
    wait;
  end process;
  clocksrx_gen: process -- 25mhz
  begin
    while not Stop loop
      clocks_rx <= '0';
      wait for 20 NS;
      clocks_rx <= '1';
      wait for 20 NS;
    end loop;
    wait;
  end process;

  instruct_gen: process -- send a few instructions
  begin
    xInstruction <= (others => '0');
    xInstruct_Rdy <= '0';
    wait for 5000 NS;
    xInstruction <= X"FAB4FAB4";
    xInstruct_Rdy <= '1';
    wait for 250 ns;
    xInstruction <= X"00000000";
    xInstruct_Rdy <= '0';
    wait;
  end process;
  
  
acdc_lvds_com : lvds_com
  port map(
  xStart            => acdc_xstart,
  xDONE             => open,
  xCLR_ALL          => reset_global,
  xRX_LVDS_CLK      => tx_serdes_clk,
  xALIGN_SUCCESS    => lvds_aligned_tx, -- lvds_line
  
  xADC              => acdc_dummycda,
  xINFO1            => acdc_dummycda,
  xINFO2            => acdc_dummycda,
  xINFO3            => acdc_dummycda,
  xINFO4            => acdc_dummycda,
  xINFO5            => acdc_dummycda,
  xINFO6            => acdc_dummycda,
  xINFO7            => acdc_dummycda,
  xINFO8            => acdc_dummycda,
  xINFO9            => acdc_dummycda,
  xINFO10           => acdc_dummycda,
  xINFO11           => acdc_dummycda,
  xINFO12           => acdc_dummycda,
  xINFO13           => acdc_dummycda,
  xEVT_CNT          => acdc_dummyevtcnt,
  
  xCLK_40MHz        => clock_sys,
  xRX_LVDS_DATA     => tx_serdes, -- lvds_line
  xINSTRUCTION      => acdc_instruction_out,
  xINSTRUCT_READY   => acdc_instruction_ready,
  xPSEC_MASK        => (others => '1'),  -- check this
  xFPGA_PLL_LOCK    => '1',
  xEXTERNAL_DONE => '1',
  xREAD_ADC_DATA    => '0',
  xREAD_TRIG_RATE_ONLY => '0',
  xSELF_TRIG_RATE_COUNT => acdc_dummyrca,
  xSYSTEM_IS_CLEAR  => '0',
  xPULL_RAM_DATA    => '1',
	xCLK_COMS         => clock_sys4x,
  xTX_LVDS_DATA     => rx_serdes,
  xRADDR            => open,
  xRAM_READ_EN      => open,
  xDC_XFER_DONE     => open,
  xTX_BUSY          => acdc_txbusy,
  xRX_BUSY          => acdc_rxbusy,
  xTX_LVDS_CLK      => rx_serdes_clk
  );

	acc_TRANSCEIVERS : transceivers
	port map(
	  xCLR_ALL          => reset_global,
	  xALIGN_SUCCESS    => xalign_good,

	  xCLK              => clock_sys,
	  xCLK_COMS         => clock_sys4x, 
	  xRX_LVDS_DATA     => rx_serdes,
		xRX_LVDS_CLK      => rx_serdes_clk,
	  xTX_LVDS_DATA     => tx_serdes,
		xTX_LVDS_CLK      => tx_serdes_clk,

	  xCC_INSTRUCTION   => xInstruction,
	  xCC_INSTRUCT_RDY  => xInstruct_Rdy,
	  xTRIGGER          => xtrig,
	  xCC_SEND_TRIGGER  => trigger_to_fe,

	  xRAM_RD_EN        => '0',
	  xRAM_ADDRESS      => (others => '0'),
	  xRAM_CLK          => '0',
	  xRAM_FULL_FLAG    => open,
	  xRAM_DATA         => open,
	  xRAM_SELECT_WR    => (others => '0'),
	  xRAM_SELECT_RD    => (others => '0'),

	  xALIGN_INFO       => open,
	  xCATCH_PKT        => packet_from_fe_rec,

	  xDONE             => xdone,
	  xDC_MASK          => xfe_mask,
	  xPLL_LOCKED       => clock_FPGA_PLLlock,
	  xSOFT_RESET       => xready);

end architecture BENCH;