library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity def
entity alu_ctrl is
    -- port interface
    port (
        funct : in std_logic_vector(5 downto 0);
        alu_opcode : in std_logic_vector(5 downto 0);
        alu_lo_hi : out std_logic_vector(1 downto 0);
        lo_en : out std_logic;
        hi_en : out std_logic;
        multiplied : out std_logic;
        op_sel : out std_logic_vector(5 downto 0)
    );
end alu_ctrl;

-- architectural implementation
architecture bhv of alu_ctrl is
    -- Define Constants for instructions

    -- I-Type Instructions (Opcode Field - 6 bits)
    constant ADDIU    : std_logic_vector(5 downto 0) := "001001"; -- X"09"
    constant ANDI : std_logic_vector(5 downto 0) := "001100"; -- X"0C"
    constant ORI  : std_logic_vector(5 downto 0) := "001101"; -- X"0D"
    constant XORI : std_logic_vector(5 downto 0) := "001110"; -- X"0E"
    constant SLTSI   : std_logic_vector(5 downto 0) := "001010"; -- X"0A"
    constant SLTUI   : std_logic_vector(5 downto 0) := "001011"; -- X"0B"
    

    -- R-Type Instructions (funct field - 6 bits)
    constant BYPASS : std_logic_vector(5 downto 0) := "110000"; -- X"30" -- custom
    constant ADD    : std_logic_vector(5 downto 0) := "100001"; -- X"21"
    constant SUB    : std_logic_vector(5 downto 0) := "100011"; -- X"23"
    constant MULT   : std_logic_vector(5 downto 0) := "011000"; -- X"18"
    constant MULTU  : std_logic_vector(5 downto 0) := "011001"; -- X"19"
    constant AND_OP : std_logic_vector(5 downto 0) := "100100"; -- X"24"
    constant OR_OP  : std_logic_vector(5 downto 0) := "100101"; -- X"25"
    constant XOR_OP : std_logic_vector(5 downto 0) := "100110"; -- X"26"
    constant SLL_OP    : std_logic_vector(5 downto 0) := "000000"; -- X"00"
    constant SRL_OP    : std_logic_vector(5 downto 0) := "000010"; -- X"02"
    constant SRA_OP    : std_logic_vector(5 downto 0) := "000011"; -- X"03"
    constant SLTS    : std_logic_vector(5 downto 0) := "101010"; -- X"2A"
    constant SLTU   : std_logic_vector(5 downto 0) := "101011"; -- X"2B"
    constant MFHI   : std_logic_vector(5 downto 0) := "010000"; -- X"10"
    constant MFLO   : std_logic_vector(5 downto 0) := "010010"; -- X"12"
    constant JR     : std_logic_vector(5 downto 0) := "001000"; -- X"08"
    constant BEQ    : std_logic_vector(5 downto 0) := "000100"; -- X"04"
    constant BNE    : std_logic_vector(5 downto 0) := "000101"; -- X"05"
    constant BLEZ   : std_logic_vector(5 downto 0) := "000110"; -- X"06"
    constant BGTZ   : std_logic_vector(5 downto 0) := "000111"; -- X"07"
    constant BLTZ   : std_logic_vector(5 downto 0) := "000001"; -- X"01"
    constant BGEZ   : std_logic_vector(5 downto 0) := "001111"; -- X"0F" 

    -- Load/Store Instructions (opcodes)
    constant LW      : std_logic_vector(5 downto 0) := "100011"; -- X"23"
    constant SW      : std_logic_vector(5 downto 0) := "101011"; -- X"2B"

    -- Jump Instructions (opcodes)
    constant JA   : std_logic_vector(5 downto 0) := "000010"; -- X"02"
    constant JL   : std_logic_vector(5 downto 0) := "000011"; -- X"03"
    constant MOVE : std_logic_vector(5 downto 0) := "110100"; 
    constant BRANCH   : std_logic_vector(5 downto 0) := "110110"; 
  

    -- R TYPE OPCODE
    constant R_TYPE : std_logic_vector(5 downto 0) := "000000";


    begin
        -- Process to compute the correct op_sel based on opcode and funct field
        process(funct, alu_opcode)
            begin
                -- Set defaults to avoid latches
                lo_en <= '0';
                hi_en <= '0';
                alu_lo_hi <= "00";
                op_sel <= alu_opcode;
                multiplied <= '0';
                
                -- Case statement to handle opcode from controlelr
                case alu_opcode is
                    when BYPASS =>
                        op_sel <= funct; -- MFHI/MFLO
                        if (funct = mfhi) then
                            -- using high reg 
                            alu_lo_hi <= "10";
                        elsif (funct = mflo) then 
                            -- low reg
                            alu_lo_hi <= "01";
                        end if;
                    -- Process R type
                    when R_TYPE =>
                        -- Use funct field to specify operation
                        op_sel <= funct;
                        -- Check if we are multiplying to set enables and signify controller
                        if ((funct = MULTU) or (funct = MULT)) then
                            hi_en <= '1';
                            lo_en <= '1';
                            multiplied <= '1';
                        end if;
                    when ADD =>
                        op_sel <= add; -- ADDU for fetch, LW/SW, ADDIU
                    when MOVE =>
                        -- jump
                        op_sel <= JR;
                    when ADDIU | LW | SW =>
                        op_sel <= add; -- Map ADDIU, LW, SW to ADDU
                    when ANDI =>
                        op_sel <= AND_OP; -- Map ANDI to AND
                    when ORI =>
                        op_sel <= OR_OP; -- Map ORI to OR
                    when XORI =>
                        op_sel <= XOR_OP; -- Map XORI to XOR
                    when SLTSI =>
                        op_sel <= SLTS; -- Map SLTI to SLT
                    when SLTUI =>
                        op_sel <= SLTU; -- Map SLTIU to SLTU
                    when BEQ | BNE | BLEZ | BGTZ | BLTZ | BGEZ =>
                        op_sel <= alu_opcode; -- Branch opcodes passed directly
                    when others =>
                        op_sel <= alu_opcode; -- Default for unhandled cases
                end case;
        end process;
end bhv;