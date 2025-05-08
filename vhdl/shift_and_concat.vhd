library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity defintion
entity shift_and_concat is
    port (
        ir_25 : in std_logic_vector(25 downto 0);
        pc_31 : in std_logic_vector(3 downto 0);
        shift_out : out std_logic_vector(31 downto 0)
    );
end shift_and_concat;

-- architectural implementation
architecture bhv of shift_and_concat is
    -- Signals to hold intermediate values
    signal shifted_ir : std_logic_vector(25 downto 0);

    begin
        -- shift ir_25 by 2
        shifted_ir <= std_logic_vector(shift_left(unsigned(ir_25), 2));
        -- assign shift out
        shift_out <= pc_31 & shifted_ir & "00";
end bhv;