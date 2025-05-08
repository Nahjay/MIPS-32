library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity def
entity memory is
    port (
        clk : in std_logic;
        rst : in std_logic;
        reg_b_data : in std_logic_vector(31 downto 0);
        addr : in std_logic_vector(31 downto 0);
        inport0 : in std_logic_vector(31 downto 0);
        inport1 : in std_logic_vector(31 downto 0);
        inport0_en : in std_logic;
        inport1_en : in std_logic;
        mem_write : in std_logic;
        mem_out : out std_logic_vector(31 downto 0);
        outport_out : out std_logic_vector(31 downto 0)
    );
end memory;

-- architectectural implementationnn (goin for structural this time around to match diagram given to us)
architecture struct of memory is
    -- Signals to connect components

    -- internal enables
    signal ram_wren : std_logic;
    signal outport_wren :  std_logic;

    -- Output signals from ram and register
    signal ram_out : std_logic_vector(31 downto 0);
    signal inport0_out : std_logic_vector(31 downto 0);
    signal inport1_out : std_logic_vector(31 downto 0);

    -- select signal
    signal mem_select : std_logic_vector(1 downto 0);

    -- Begin
    begin
        -- Process for mem write comb logic
        process(mem_write, addr)
            begin
                -- set defaults to prevent latches and establish default behavior
                mem_select <= "00";
                outport_wren <= '0';
                ram_wren <= '0';

                -- determine where we are writing to and what to enable based on address from pc
					 if (to_integer(unsigned(addr)) < 1024) then
						  -- Address is in the RAM range (0 to 1023)
						  mem_select <= "00";
						  -- Check for write enable
						  if (mem_write = '1') then
								ram_wren <= '1';
						  end if;

					 elsif (addr = X"0000FFF8") then
						  -- Address is inport0
						  -- Disable writing, can only read
						  mem_select <= "01";
						  -- ram_wren and outport_wren remain '0' due to defaults

					 elsif (addr = X"0000FFFC") then
						  -- Address is inport1 / outport0
						  -- Set mux for this peripheral
						  mem_select <= "10";
						  -- check if we are writing to the output port part
						  if (mem_write = '1') then
								outport_wren <= '1';
							end if;
					end if;
        end process;

        -- Instantiate and connect components based on memory diagram

        -- ram
        ram : entity work.ram
            port map (
                clock => clk,
                address => addr(9 downto 2),
                data => reg_b_data,
                wren => ram_wren,
                q => ram_out
            );
        
        -- mux
        memory_mux : entity work.mux3x1
            port map (
                input_a => ram_out,
                input_b => inport0_out,
                input_c => inport1_out,
                sel => mem_select,
                mux_out => mem_out -- read data
            );

        -- Registers

        -- inport0
        inport0_reg : entity work.reg
            port map (
                clk => clk,
                rst => '0', -- dont reset inport
                data_in => inport0,
                data_out => inport0_out,
                enable => inport0_en
            );

        -- inport1
        inport1_reg : entity work.reg
        port map (
            clk => clk,
            rst => '0', -- dont reset inport
            data_in => inport1,
            data_out => inport1_out,
            enable => inport1_en
        );

        -- outport
        outport_reg : entity work.reg
        port map (
            clk => clk,
            rst => rst,
            data_in => reg_b_data,
            data_out => outport_out,
            enable => outport_wren
        );

end struct;