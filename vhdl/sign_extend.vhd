library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity def
entity sign_extend is
    -- port interface
    port (
        is_signed : in std_logic;
        imm16 : in std_logic_vector(15 downto 0);
        imm32 : out std_logic_vector(31 downto 0)
    );
end sign_extend;

-- Architecture Implementation
architecture bhv of sign_extend is

    begin
        -- Process to extend sign based on is_signed value
        process(imm16, is_signed)
            begin
                -- Check is_signed
                if (is_signed = '1') then
                    -- Resize with signed values
                    imm32 <= std_logic_vector(resize(signed(imm16), 32));
                else
                    -- zero exention
                    imm32 <= std_logic_vector(resize(unsigned(imm16), 32));
                end if;
        end process;
end bhv;