library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2x1 is
    -- Port interface
    generic (
        data_width : integer := 32
    );
    port (
        input_a : in std_logic_vector(data_width-1 downto 0);
        input_b : in std_logic_vector(data_width-1 downto 0);
        sel : in std_logic;
        mux_out : out std_logic_vector(data_width-1 downto 0)
    );
end mux2x1;

-- Architecture
architecture bhv of mux2x1 is
    begin
        -- Use with select
        with sel select mux_out <=
            input_a when '0',
            input_b when '1',
            (others => '0') when others;
end bhv;