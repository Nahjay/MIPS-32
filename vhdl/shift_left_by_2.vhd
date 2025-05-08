library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity definition
entity shift_left_by_2 is 
    -- port interface
    port (
        shift_in : in std_logic_vector(31 downto 0);
        shift_out : out std_logic_vector(31 downto 0)
    );
end shift_left_by_2;

-- Architectural implementation
architecture bhv of shift_left_by_2 is
    begin
        -- Shift input left by 2
        shift_out <= std_logic_vector(shift_left(unsigned(shift_in), 2));
end bhv;