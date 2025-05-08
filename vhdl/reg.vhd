library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define generic register entity
entity reg is
    -- Define port interface with generic for size of data in register
    generic (
        data_width : integer := 32
    );
    port (
        data_in : in std_logic_vector(data_width-1 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        data_out : out std_logic_vector(data_width-1 downto 0)
    );
end reg;

-- Architecture of reg
architecture bhv of reg is
    -- Begin
    begin
        -- Process def
        process(clk, rst) 
            begin
                -- Support async reset
                if (rst = '1') then
                    -- Set data to 0
                    data_out <= (others => '0');
                elsif (rising_edge(clk)) then
                    -- Check enable
                    if (enable = '1') then
                        data_out <= data_in;
                    end if;
                end if;
        end process;
end bhv;
