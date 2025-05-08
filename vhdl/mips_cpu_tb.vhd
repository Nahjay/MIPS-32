library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_cpu_tb is 
end mips_cpu_tb;

architecture tb of mips_cpu_tb is
	
	constant width : positive := 32;
	signal inport0_en : std_logic := '0';
	signal inport0    : std_logic_vector(31 downto 0) := x"0000011F";
    signal clk         : std_logic := '1';
	signal rst         : std_logic := '0';
	signal inport1_en : std_logic := '0';
	signal inport1    : std_logic_vector(31 downto 0) := x"0000005B";
	signal outport    : std_logic_vector(31 downto 0);
	
begin 
	
	UUT : entity work.mips_cpu 
		port map (
			clk => clk,
			rst => rst,
			inport0 => inport0,
			inport1 => inport1,
			inport0_en => inport0_en,
			inport1_en => inport1_en,
			outport => outport
		);
	
        -- implement clock period
		clk <= not clk after 10 ns;
		
	process 
	begin 
		
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		
		inport0_en <= '1';
        inport1_en <= '1';
        inport0 <= x"00000006";
        inport1 <= x"00000008";
        wait until rising_edge(clk);
		inport0_en <= '0';
        inport1_en <= '0';
		
		for i in 0 to 1000 loop 
			wait until rising_edge(clk);
		end loop;
		
		wait;
	end process;
end tb;