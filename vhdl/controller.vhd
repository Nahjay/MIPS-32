library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity def (as requested)
entity controller is
    -- port interface
	port (
        ir_31 : in std_logic_vector(5 downto 0);
		ir_20 : in std_logic_vector(4 downto 0);
		ir_15 : in std_logic_vector(15 downto 0);
		clk : in std_logic;
		rst : in std_logic;
        multiplied: in std_logic; 
		pcwritecond : out std_logic;
		pcwrite : out std_logic;
        memwrite : out std_logic;
		memtoreg : out std_logic;
		iord : out std_logic;
		irwrite : out std_logic;
		jumpandlink : out std_logic;
        regwrite : out std_logic;
        alu_opcode : out std_logic_vector(5 downto 0); 
		alusrc_a : out std_logic; 
		alusrc_b : out std_logic_vector(1 downto 0); 
		is_signed : out std_logic; 
		pcsource : out std_logic_vector(1 downto 0);
		regdst : out std_logic
	);
end controller;

architecture bhv of controller is

    -- Define Constants for instructions (using requested names, mapped to original values)

    -- R TYPE OPCODE 
    constant R_TYPE   : std_logic_vector(5 downto 0) := "000000"; -- X"00"

    -- R-Type Instructions (funct field )
    constant ADD      : std_logic_vector(5 downto 0) := "100001"; -- X"21" 
    constant SUB      : std_logic_vector(5 downto 0) := "100011"; -- X"23" 
    constant MULT     : std_logic_vector(5 downto 0) := "011000"; -- X"18" 
    constant MULTU    : std_logic_vector(5 downto 0) := "011001"; -- X"19" 
    constant AND_OP   : std_logic_vector(5 downto 0) := "100100"; -- X"24" 
    constant OR_OP    : std_logic_vector(5 downto 0) := "100101"; -- X"25" 
    constant XOR_OP   : std_logic_vector(5 downto 0) := "100110"; -- X"26" 
    constant SRL_OP   : std_logic_vector(5 downto 0) := "000010"; -- X"02" 
    constant SLL_OP   : std_logic_vector(5 downto 0) := "000000"; -- X"00" 
    constant SRA_OP   : std_logic_vector(5 downto 0) := "000011"; -- X"03" 
    constant SLTS     : std_logic_vector(5 downto 0) := "101010"; -- X"2A" 
    constant SLTU     : std_logic_vector(5 downto 0) := "101011"; -- X"2B" 
    constant MFHI     : std_logic_vector(5 downto 0) := "010000"; -- X"10" 
    constant MFLO     : std_logic_vector(5 downto 0) := "010010"; -- X"12" 
    constant JR       : std_logic_vector(5 downto 0) := "001000"; -- X"08" 
    constant BYPASS   : std_logic_vector(5 downto 0) := "110000"; -- X"30" 

     -- Load/Store Instructions 
    constant LW       : std_logic_vector(5 downto 0) := "100011"; -- X"23" 
    constant SW       : std_logic_vector(5 downto 0) := "101011"; -- X"2B" 
 

    -- Branch Instructions 
    constant BEQ      : std_logic_vector(5 downto 0) := "000100"; -- X"04" 
    constant BNE      : std_logic_vector(5 downto 0) := "000101"; -- X"05" 
    constant BLEZ     : std_logic_vector(5 downto 0) := "000110"; -- X"06" 
    constant BGTZ     : std_logic_vector(5 downto 0) := "000111"; -- X"07" 
    constant BLTZ     : std_logic_vector(5 downto 0) := "000001"; -- X"01" 
    constant BGEZ     : std_logic_vector(5 downto 0) := "001111"; -- X"0F" 

    -- I-Type Instructions 
    constant ADDIU    : std_logic_vector(5 downto 0) := "001001"; -- X"09" 
    constant ANDI     : std_logic_vector(5 downto 0) := "001100"; -- X"0C" 
    constant ORI      : std_logic_vector(5 downto 0) := "001101"; -- X"0D" 
    constant XORI     : std_logic_vector(5 downto 0) := "001110"; -- X"0E" 
    constant SLTSI    : std_logic_vector(5 downto 0) := "001010"; -- X"0A" 
    constant SLTUI    : std_logic_vector(5 downto 0) := "001011"; -- X"0B" 

    -- Jump Instructions 
    constant JA       : std_logic_vector(5 downto 0) := "000010"; -- X"02" 
    constant JL       : std_logic_vector(5 downto 0) := "000011"; -- X"03" 
    constant MOVE     : std_logic_vector(5 downto 0) := "110100"; -- X"34" 
    constant BRANCH   : std_logic_vector(5 downto 0) := "110110"; -- X"36" 


    -- Define States for 2 Process FSM
    type state_type is (
        -- Init Stage
        IF_INIT,

        -- Fetch Stage
        IF_FETCH, IF_DELAY,

        -- Decode Stage
        ID_DECODE, ID_UNRECOGNIZED, ID_HALT,

        -- Execute Stage
        EX_REG, EX_LS, EX_IMM, EX_JUMP, EX_JR, EX_JAL, EX_BRANCH, EX_BRANCH_COND,

        -- Memory Stage
        MEM_LW, MEM_LW_DELAY, MEM_SW, MEM_SW_DELAY,

        -- Write Back Stage
        WB_REG, WB_LW, WB_IMM, WB_JAL
    );
    
    -- Define state signals 
    signal state, next_state : state_type;

begin
    -- State Register Process 
    process(clk, rst)
    begin
        if (rst = '1') then
            -- Move to inital state
            state <= IF_INIT; 
        elsif (rising_edge(clk)) then
            -- handle state transition
            state <= next_state;
        end if;
    end process;

    -- Combinational Logic Process to determine state transitions
    process(state, ir_31, ir_20, ir_15, multiplied)
    begin

        -- modeling 5 stage fetch decode execute mem and wb mips pipeline

        -- Default values for outputs to avoid latches for control signals
        -- default add to increment pc
        next_state <= state; 
        alu_opcode <= ADD; 
        alusrc_a <= '0';   
        alusrc_b <= "00";  
        pcwritecond <= '0';
        pcwrite <= '0';
        iord <= '0';
        is_signed <= '0';
        pcsource <= "00";
        memwrite <= '0';
        memtoreg <= '0';
        irwrite <= '0';
        jumpandlink <= '0';
        regwrite <= '0';
        regdst <= '0';

        -- Case statement logic for state management
        case(state) is 

            when IF_INIT =>
                -- set control signal to fetch instruction form iord mux
                iord <= '0';
                next_state <= IF_DELAY; 

            when IF_DELAY =>
                -- fetch delay, 2 cycle delay to read from mem
                next_state <= IF_FETCH; 

            when IF_FETCH => 
                -- actually fetching instruction
                -- write to instruction reg
                irwrite <= '1';
                -- get current pc 
                alusrc_a <= '0';
                alusrc_b <= "01";
                -- increment by 4
                alu_opcode <= ADD;
                -- update pc reg
                pcwrite <= '1';
                -- decode obtained instruction
                next_state <= ID_DECODE; 

            when ID_DECODE =>
                -- use a case statement to determine which execute stage we will move to after
                -- da decoding is done
                
                -- Decode the read instruction 
                case ir_31 is
                    -- R-type instructions (Opcode = 000000)
                    when R_TYPE =>
                        alu_opcode <= R_TYPE;  -- Set ALU operation type
                        next_state <= EX_REG;  -- Default next state for R-type

                        -- Nested check for JR instruction based on function code (ir_15)
                        if (ir_15(5 downto 0) = JR) then
                            next_state <= EX_JR;  -- Override next state for JR
                            pcsource <= "00";     -- Set PC source for JR
                        end if;

                    -- Immediate instructions (ADDIU, ANDI, ORI, XORI, SLTSI, SLTUI opcodes)
                    when ADDIU | ANDI | ORI | XORI | SLTSI | SLTUI =>
                        next_state <= EX_IMM;

                    -- Load/Store instructions (LW or SW opcodes)
                    when LW | SW =>            
                        next_state <= EX_LS;

                    -- Jump instructions (JA or JL opcodes)
                    when JA | JL =>
                        next_state <= EX_JUMP;

                    -- Branch instructions (BEQ, BNE, BLEZ, BGTZ, BLTZ, BGEZ opcodes)
                    when BEQ | BNE | BLEZ | BGTZ | BLTZ | BGEZ =>
                        next_state <= EX_BRANCH;

                    -- Handle any other opcode value not explicitly listed above
                    when others =>             -- Equivalent to the final 'else' [4, 7]
                        next_state <= ID_UNRECOGNIZED;

                end case;

            when EX_REG =>
                -- execute r type instruction

                -- send signal to alu control
                alu_opcode <= R_TYPE; 
                -- set correct muxes
                alusrc_a <= '1';
                alusrc_b <= "00";
                -- check if we multiplied
                if (multiplied = '1') then
                    -- set correct enables
                    regdst <= '1';
                    regwrite <= '1';
                end if;
                -- need to write value back to memory
                next_state <= WB_REG; 

            when EX_LS => 
                -- handle adding of offset to get correct addr
                alu_opcode <= ADD; 
                -- set default signed value
                is_signed <= '0'; 
                -- set correct alu sources
                alusrc_b <= "10";
                alusrc_a <= '1';
                -- check if opcode is a lw or sw to determine mem stage
                if (ir_31 = LW) then 
                    next_state <= MEM_LW; 
                else -- SW case
                    next_state <= MEM_SW; 
                end if;

            when EX_IMM =>
                -- executing an immediate instruction

                -- choose data from register file and immediate value
                alusrc_a <= '1';
                alusrc_b <= "10";

                -- Pass the original immediate opcode directly to alu ctrl for further decoding
                alu_opcode <= ir_31;  

                -- Set is_signed flag only for SLTSI, as ALU needs sign extension info
                if ir_31 = SLTSI then
                    is_signed <= '1';
                else
                    is_signed <= '0'; -- Default for other immediate instructions
                end if;
                -- transition to wb to store data in reg file
                next_state <= WB_IMM; 

            when EX_JUMP =>
                -- executing jump instruction (evaluate all types)
                pcwrite <= '1';
                pcsource <= "10";

                -- check  opcode to determine type of jump
                if (ir_31 = JL) then 
                    -- jump and link
                    next_state <= EX_JAL; 
                elsif (ir_31 = JA) then 
                    -- reset process 
                    next_state <= IF_INIT;
                else
                    -- catch all
                    next_state <= IF_INIT; 
                end if;

            when EX_JR =>
                -- jumping to destination

                -- choose computing val from alu
                pcsource <= "00";
                pcwrite <= '1';
                -- set correct selects
                alusrc_a <= '1';
                -- update opcode
                alu_opcode <= R_TYPE; 
                -- reset process (loop to original state)
                next_state <= IF_INIT; 

            when EX_JAL =>
                -- opcode used to handle jump logic in alu ctrl
                alu_opcode <= MOVE;
                -- enable pc and take output of alu
                pcsource <= "10"; 
                pcwrite <= '1'; 
                -- obtain pc address (newly computed ofc)
                alusrc_a <= '0';
                -- write new value to mem
                regwrite <= '1';
                -- set ctrl sig
                jumpandlink <= '1';
                -- transition to write
                next_state <= WB_JAL; 

            when EX_BRANCH => 
                -- executing a branch instruction
                
                -- take sign extended value and val from pc
                alusrc_b <= "11";
                alusrc_a <= '0';
                -- set signed extension
                is_signed <= '1';
					-- compute the new address
                alu_opcode <= ADD; 
                -- stage 2 of branch compution
                next_state <= EX_BRANCH_COND;

            when EX_BRANCH_COND =>
                -- pass opcode directly to controller to determine what typa branch like beq, bne, etc..
                alu_opcode <= ir_31; 
                -- update pc wit new address computed from alyu
                pcwritecond <= '1';
                pcsource <= "01";
                -- set select signals for alu (to compute and dictace branch)
                alusrc_a <= '1';
                alusrc_b <= "00";
                -- done looping back to beginning
                next_state <= IF_INIT; 

            when MEM_LW => 
                -- reading data
                iord <= '1';

                -- check for inport or outport loading
                -- only 1 cycle delay for inport or outport loading
                if ((ir_15 = x"FFFC") or (ir_15 = x"FFF8")) then
                    next_state <= WB_LW; 
                else
                    -- account for delay if we are just writing to memory
                    next_state <= MEM_LW_DELAY;
                end if;

            when MEM_LW_DELAY =>
                -- account for 2 cycle delay to ram (read/writes) with delay state
                next_state <= WB_LW;

            when MEM_SW => 
                -- enable writing of data to memory
                memwrite <= '1';
                -- select data
                iord <= '1';
                -- move to delay to account for 2 cycle shenanigans
                next_state <= MEM_SW_DELAY; 

            when MEM_SW_DELAY => 
                -- account for delay with memory
                next_state <= IF_INIT; 

            when WB_LW => 
                -- enable writing to reg file
                regwrite <= '1';
                memtoreg <= '1';
                -- wb completed, reset process
                next_state <= IF_INIT; 
                
            when WB_REG =>
                -- setting correct enables
                regdst <= '1';
                regwrite <= '1';
                -- using bypass functionality iomplemented in alu ctrl
                alu_opcode <= BYPASS;
                -- reset state process, wb completed
                next_state <= IF_INIT;

            when WB_IMM =>
                -- enable writing to reg file
                regwrite <= '1';
                -- loop back after successful completion for next instruction
                next_state <= IF_INIT;

            when WB_JAL =>
                -- complete wb successfully, reseting state
                next_state <= IF_INIT;

            when ID_HALT =>
                -- Loop back to decode when we run into a halt instruction (will be in some of the test mifs)
                next_state <= ID_DECODE; 

            when ID_UNRECOGNIZED => 
                -- default if we run into an instruction we dont recognize
                next_state <= state;

            when others => 
                -- handle edge cases and maintain state
                null; 
                next_state <= state;
        end case;
    end process;

end bhv;
