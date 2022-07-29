--
-- Simple Testbench
-- YM-2149 / AY-3-8910 Complex Sound Generator
-- Matthew Hagerty
-- June 2020
-- https://dnotq.io
--

library ieee;
use ieee.std_logic_1164.all;


entity tb_ym2149 is
end tb_ym2149;

architecture behavior of tb_ym2149 is

   -- Unit Under Test (UUT)
   component ym2149_audio
   port
   ( clk_i        : in     std_logic
   ; en_clk_io_i  : in     std_logic
   ; en_clk_psg_i : in     std_logic
   ; reset_n_i    : in     std_logic
   ; bc_i         : in     std_logic
   ; bdir_i       : in     std_logic
   ; data_i       : in     std_logic_vector(7 downto 0)
   ; data_r_o     : out    std_logic_vector(7 downto 0)
   );
   end component;


   -- Inputs
   signal clk_i         : std_logic := '0';
   signal en_clk_io_i   : std_logic := '0';
   signal en_clk_psg_i  : std_logic := '0';
   signal reset_n_i     : std_logic := '0';
   signal bc_i          : std_logic := '0';
   signal bdir_i        : std_logic := '0';
   signal data_i        : std_logic_vector(7 downto 0) := (others => '0');

   -- Outputs
   signal data_r_o : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 46.560852 ns;

   signal clk_psg : std_logic := '0';

begin

   -- Instantiate the Unit Under Test (UUT)
   uut: ym2149_audio
   port map
   ( clk_i        => clk_i
   , en_clk_io_i  => en_clk_io_i
   , en_clk_psg_i => en_clk_psg_i
   , reset_n_i    => reset_n_i
   , bc_i         => bc_i
   , bdir_i       => bdir_i
   , data_i       => data_i
   , data_r_o     => data_r_o
   );

   -- Clock process definitions
   clk_i_process :process
   begin
      clk_i <= '1';
      wait for clk_i_period/2;
      clk_i <= '0';
      wait for clk_i_period/2;
   end process;

   en_clk_io_i_process :process
   begin
      en_clk_io_i <= '1';
      wait for clk_i_period;
      en_clk_io_i <= '0';
      wait for clk_i_period*5;
   end process;

   en_clk_psg_i_process :process
   begin
      en_clk_psg_i <= '0';
      wait for clk_i_period*6;
      en_clk_psg_i <= '1';
      wait for clk_i_period;
      en_clk_psg_i <= '0';
      wait for clk_i_period*5;
   end process;

   clk_psg_process :process
   begin
      clk_psg <= '0';
      wait for clk_i_period*6;
      clk_psg <= '1';
      wait for clk_i_period*6;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      reset_n_i <= '0';
      bc_i      <= '0';
      bdir_i    <= '0';
      wait for clk_i_period*6*12;
      reset_n_i <= '1';
      wait for clk_i_period*2*12;

      wait for clk_i_period*32*12;

      -- Latch the address of R0.
      wait for 150 ns;
      bc_i   <= '1';
      bdir_i <= '1';
      data_i <= x"0D"; -- R6 noise period, Rd envelope shape
      wait for 300 ns;
      bc_i   <= '0';
      bdir_i <= '0';
      wait for 150 ns;

      -- Write a value to tone counter A.
      wait for 150 ns;
      bc_i   <= '0';
      bdir_i <= '1';
      data_i <= "00000111"; -- reg value
      wait for 300 ns;
      bc_i   <= '0';
      bdir_i <= '0';
      wait for 150 ns;

      wait;
   end process;

end;
