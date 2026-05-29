library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FSM de control: Fetch -> Decode -> Execute -> Writeback
-- OPCODE 0000=LDA 0001=STA 0010=ADD 0011=SUB 0100=AND 0101=OR 0110=JMP 0111=JZ

entity control_fsm is
    port(
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        opcode      : in  std_logic_vector(3 downto 0);
        zero_flag   : in  std_logic;
        pc_inc      : out std_logic;
        pc_load     : out std_logic;
        ir_load     : out std_logic;
        acc_we      : out std_logic;
        ram_we      : out std_logic;
        alu_op      : out std_logic_vector(2 downto 0);
        mux_alu_src : out std_logic
    );
end entity;

architecture rtl of control_fsm is
    type state_t is (FETCH, DECODE, EXECUTE, WRITEBACK);
    signal state, next_state : state_t;
begin
    -- Registro de estado
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= FETCH;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Logica de proximo estado
    process(state, opcode, zero_flag)
    begin
        case state is
            when FETCH     => next_state <= DECODE;
            when DECODE    => next_state <= EXECUTE;
            when EXECUTE   =>
                case opcode is
                    when "0000" => next_state <= WRITEBACK;  -- LDA
                    when "0010" => next_state <= WRITEBACK;  -- ADD
                    when "0011" => next_state <= WRITEBACK;  -- SUB
                    when "0100" => next_state <= WRITEBACK;  -- AND
                    when "0101" => next_state <= WRITEBACK;  -- OR
                    when others => next_state <= FETCH;      -- STA, JMP, JZ: sin writeback
                end case;
            when WRITEBACK => next_state <= FETCH;
        end case;
    end process;

    -- Logica de salidas (Moore + Mealy en EXECUTE para saltos)
    process(state, opcode, zero_flag)
    begin
        -- Valores por defecto: todo inactivo
        pc_inc      <= '0';
        pc_load     <= '0';
        ir_load     <= '0';
        acc_we      <= '0';
        ram_we      <= '0';
        alu_op      <= "100";  -- pass-A
        mux_alu_src <= '0';

        case state is
            when FETCH =>
                ir_load <= '1';   -- cargar instruccion en IR
                pc_inc  <= '1';   -- avanzar PC

            when DECODE =>
                null;             -- decodificacion implicita en opcode

            when EXECUTE =>
                case opcode is
                    when "0000" =>          -- LDA: ALU pass-A desde RAM
                        alu_op <= "100";
                    when "0001" =>          -- STA: escribir ACC en RAM
                        ram_we <= '1';
                    when "0010" =>          -- ADD
                        alu_op <= "000";
                    when "0011" =>          -- SUB
                        alu_op <= "001";
                    when "0100" =>          -- AND
                        alu_op <= "010";
                    when "0101" =>          -- OR
                        alu_op <= "011";
                    when "0110" =>          -- JMP: salto incondicional
                        pc_load <= '1';
                    when "0111" =>          -- JZ: salto si ACC = 0
                        if zero_flag = '1' then
                            pc_load <= '1';
                        end if;
                    when others => null;
                end case;

            when WRITEBACK =>
                acc_we <= '1';    -- escribir resultado de ALU en ACC
        end case;
    end process;
end architecture;
