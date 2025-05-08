library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Register File

-- Entity declaration
entity register_file is
    port (
        clk : in std_logic;
        rst : in std_logic;
        rd_addr0 : in std_logic_vector(4 downto 0); --read reg 1
        rd_addr1 : in std_logic_vector(4 downto 0); --read reg 2
        wr_addr : in std_logic_vector(4 downto 0); --write register
        wr_en : in std_logic;
        wr_data : in std_logic_vector(31 downto 0); --write data
        rd_data0 : out std_logic_vector(31 downto 0); --read data 1
        rd_data1 : out std_logic_vector(31 downto 0); --read data 2--JAL
        JumpAndLink : in std_logic
    );
end register_file;

-- Architecture Def
architecture bhv of register_file is
    
    -- Declare array of 32 bit vectors to contain all registers
    type regarray is array(0 to 31) of std_logic_vector(31 downto 0);
    -- Declare signal composing register array
	signal regs : regarray;

    begin
        -- Sequential Process to allow writes and reads to registers
        process(clk, rst)
            begin
                -- Check for async reset
                if (rst = '1') then
                    -- Set all regs in array to 0
                    for i in regs'range loop
                        -- Set values to 0
                        regs(i) <= (others => '0');
                    end loop;
                elsif (rising_edge(clk)) then
                    -- Check if wr_en is high
                    if (wr_en = '1') then
                        -- Check if we are writing to return address of JAL
                        if (JumpAndLink = '1') then
                            -- Write to reg 31
                            regs(31) <= wr_data;
                        -- Else we are writing to any reg except zero register, check wr_addr to ensure it is not 0
                        elsif(unsigned(wr_addr) /= 0) then
                            -- Write to reg
                            regs(to_integer(unsigned(wr_addr))) <= wr_data;
                        end if;
                    end if;

                     -- Handle Reads outside of write logic
                    rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
                    rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
                end if;
        end process;

end bhv;