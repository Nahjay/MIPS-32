library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity def
entity datapath is
    -- port interface
    port (
        clk : in std_logic;
		rst : in std_logic;
		pcwritecond : in std_logic;
		pcwrite : in std_logic;
		iord : in std_logic;
		memwrite : in std_logic;
        alusrc_a : in std_logic;
		alusrc_b : in std_logic_vector(1 downto 0);
		regwrite : in std_logic;
		regdst : in std_logic;
		memtoreg : in std_logic;
		alu_opcode : in std_logic_vector(5 downto 0);
		inport0_en : in std_logic;
        irwrite : in std_logic;
		jumpandlink : in std_logic;
		is_signed : in std_logic;
		pcsource : in std_logic_vector(1 downto 0);
		inport1_en : in std_logic;
		inport0 : in std_logic_vector(31 downto 0);
		inport1 : in std_logic_vector(31 downto 0);
		outport : out std_logic_vector(31 downto 0);
        ir_31 : out std_logic_vector(5 downto 0);
		ir_20 : out std_logic_vector(4 downto 0);
        multiplied : out std_logic;
		ir_15 : out std_logic_vector(15 downto 0)
	);
end datapath;

-- architectrual  implementation
architecture struct of datapath is
    -- Define Signals to hold itermediate computed values
    signal shift_left_by_2 : std_logic_vector(31 downto 0);
    signal shift_and_concat : std_logic_vector(31 downto 0);
    signal shifted_ir : std_logic_vector(25 downto 0);

    -- Define Signals to interconnect components according to diagram
    signal pc_out : std_logic_vector(31 downto 0);
	signal write_reg_mux_out : std_logic_vector(4 downto 0);
	signal write_data_mux_out : std_logic_vector(31 downto 0);
    signal alu_out : std_logic_vector(31 downto 0);
	signal memory_out : std_logic_vector(31 downto 0);
	signal rega : std_logic_vector(31 downto 0);
    signal pc_in : std_logic_vector(31 downto 0);
	signal pc_enable : std_logic;
	signal pc_mux_out : std_logic_vector(31 downto 0);
	signal memory_data_out : std_logic_vector(31 downto 0);
	signal regb : std_logic_vector(31 downto 0);
	signal ir_out : std_logic_vector(31 downto 0);
	signal alu_hi_lo_mux_out : std_logic_vector(31 downto 0);
	signal alu_rega_mux_out : std_logic_vector(31 downto 0);
    signal alu_output_hi : std_logic_vector(31 downto 0);
	signal concat_out : std_logic_vector(31 downto 0);
	signal alu_lo_reg : std_logic_vector(31 downto 0);
	signal alu_hi_reg : std_logic_vector(31 downto 0);
	signal alu_lo_hi : std_logic_vector(1 downto 0);
	signal alu_regb_mux_out : std_logic_vector(31 downto 0);
	signal sign_extend_out : std_logic_vector(31 downto 0);
    signal branch_taken : std_logic;
	 signal ir_25 : std_logic_vector(25 downto 0);
	 signal pc_31 : std_logic_vector(5 downto 0);
	signal alu_output : std_logic_vector(31 downto 0);
	signal hi_en, lo_en : std_logic;
	signal multiply : std_logic;
	signal shift_left_2_alu_out : std_logic_vector(31 downto 0);
	signal opselect : std_logic_vector(5 downto 0);
	signal alu_out_reg : std_logic_vector(31 downto 0);

    -- begin
    begin
        -- connect multiplied output to multiply internal signal
        multiplied <= multiply;

        -- assign fields from ir
        ir_31 <= ir_out(31 downto 26);
		  ir_15 <= ir_out(15 downto 0);
        ir_20 <= ir_out(20 downto 16);
		  ir_25 <= ir_out(25 downto 0);
		  
		  -- assign pc out used for shift and concat
		  pc_31 <= pc_out(31 downto 26);

        -- Compute itermediate signals
        shift_left_by_2 <= std_logic_vector(shift_left(unsigned(sign_extend_out), 2));
        -- shift ir_25 by 2
        shifted_ir <= std_logic_vector(shift_left(unsigned(ir_25), 2));
        -- assign shift and concat
        shift_and_concat <= pc_31 & shifted_ir;

        -- compute pc enable
        pc_enable <= pcwrite or (pcwritecond and branch_taken);

        -- instantiate and map components together using work instatiation
        pc : entity work.reg
        generic map (
            data_width => 32
        )
        port map (
            data_in => pc_in,
            data_out => pc_out,
            clk => clk,
            rst => rst,
            enable => pc_enable
        );

        pc_mux : entity work.mux2x1
            generic map (
                data_width => 32
            )
            port map (
                input_a => pc_out,
                input_b => alu_out,
                sel => iord,
                mux_out => pc_mux_out
            );

        memory_inst : entity work.memory
            port map (
                clk => clk,
                rst => rst,
                reg_b_data => regb,
                addr => pc_mux_out,
                inport0 => inport0,
                inport1 => inport1,
                inport0_en => inport0_en,
                inport1_en => inport1_en,
                mem_write => memwrite,
                mem_out => memory_out,
                outport_out => outport
            );

        instruction_reg : entity work.reg
            generic map (
                data_width => 32
            )
            port map (
                data_in => memory_out,
                data_out => ir_out,
                clk => clk,
                rst => rst,
                enable => irwrite
            );

        memory_data_reg : entity work.reg
            generic map (
                data_width => 32
            )
            port map (
                data_in => memory_out,
                data_out => memory_data_out,
                clk => clk,
                rst => rst,
                enable => '1'
            );

        register_file_inst : entity work.register_file
            port map (
                clk => clk,
                rst => rst,
                rd_addr0 => ir_out(25 downto 21),
                rd_addr1 => ir_out(20 downto 16),
                wr_addr => write_reg_mux_out,
                wr_en => regwrite,
                wr_data => write_data_mux_out,
                rd_data0 => rega,
                rd_data1 => regb,
                JumpAndLink => jumpandlink
            );
				
			        alu_out_r : entity work.reg
            generic map (
                data_width => 32
            )
            port map (
                data_in => alu_output,
                data_out => alu_out_reg,
                clk => clk,
                rst => rst,
                enable => '1'
            );

        alu_lo_r : entity work.reg
            generic map (
                data_width => 32
            )
            port map (
                data_in => alu_output,
                data_out => alu_lo_reg,
                clk => clk,
                rst => rst,
                enable => lo_en
            );

        alu_hi_r : entity work.reg
            generic map (
                data_width => 32
            )
            port map (
                data_in => alu_output_hi,
                data_out => alu_hi_reg,
                clk => clk,
                rst => rst,
                enable => hi_en
            );

        alu_out_3x1mux : entity work.mux3x1
            generic map (
                data_width => 32
            )
            port map (
                input_a => alu_out_reg,
                input_b => alu_lo_reg,
                input_c => alu_hi_reg,
                sel => alu_lo_hi,
                mux_out => alu_out
            );

        alu_ctrl : entity work.alu_ctrl
            port map (
                funct => ir_out(5 downto 0),
                alu_opcode => alu_opcode,
                alu_lo_hi => alu_lo_hi,
                lo_en => lo_en,
                hi_en => hi_en,
                multiplied => multiply,
                op_sel => opselect
            );

        alu_rega_mux : entity work.mux2x1
            generic map (
                data_width => 32
            )
            port map (
                input_a => pc_out,
                input_b => rega,
                sel => alusrc_a,
                mux_out => alu_rega_mux_out
            );

        sign_extend_inst : entity work.sign_extend
            port map (
                is_signed => is_signed,
                imm16 => ir_out(15 downto 0),
                imm32 => sign_extend_out
            );

        alu_regb_mux : entity work.mux4x1
            generic map (
                data_width => 32
            )
            port map (
                input_a => regb,
                input_b => std_logic_vector(to_unsigned(4, 32)),
                input_c => sign_extend_out,
                input_d => shift_left_by_2,
                sel => alusrc_b,
                mux_out => alu_regb_mux_out
            );

        alu_inst : entity work.alu
            port map (
                alu_a => alu_rega_mux_out,
                alu_b => alu_regb_mux_out,
                op_sel => opselect,
                shamt => ir_out(10 downto 6),
                branch_taken => branch_taken,
                result => alu_output,
                result_high => alu_output_hi
            );

        pc_3x1_mux : entity work.mux3x1
            generic map (
                data_width => 32
            )
            port map (
                input_a => alu_output,
                input_b => alu_out_reg,
                input_c => shift_and_concat,
                sel => pcsource,
                mux_out => pc_in
            );
				
			
        wr_reg_mux : entity work.mux2x1
            generic map (
                data_width => 5
            )
            port map (
                input_a => ir_out(20 downto 16),
                input_b => ir_out(15 downto 11),
                sel => regdst,
                mux_out => write_reg_mux_out
            );

        wr_data_mux : entity work.mux2x1
            generic map (
                data_width => 32
            )
            port map (
                input_a => alu_out,
                input_b => memory_data_out,
                sel => memtoreg,
                mux_out => write_data_mux_out
            );

end struct;

