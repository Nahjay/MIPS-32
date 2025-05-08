library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x1 is
    -- Port interface
    generic (
        data_width : integer := 32
    );
    port (
        input_a : in std_logic_vector(data_width-1 downto 0);
        input_b : in std_logic_vector(data_width-1 downto 0);
        input_c : in std_logic_vector(data_width-1 downto 0);
        input_d : in std_logic_vector(data_width-1 downto 0);
        sel : in std_logic_vector(1 downto 0);
        mux_out : out std_logic_vector(data_width-1 downto 0)
    );
end mux4x1;

-- Architecture
architecture bhv of mux4x1 is
    begin
        -- Use with select
        with sel select mux_out <=
            input_a when "00",
            input_b when "01",
            input_c when "10",
            input_d when "11",
            (others => '0') when others;
end bhv;