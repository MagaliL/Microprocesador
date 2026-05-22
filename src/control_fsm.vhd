library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FSM de control: Fetch -> Decode -> Execute -> Writeback
-- Recibe el OPCODE (bits 15-12 de la instruccion) y la zero_flag de la ALU.
-- Genera todas las senales de control del datapath.
-- La logica de estados completa se implementa en Semana 3.

entity control_fsm is
    port(
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        opcode      : in  std_logic_vector(3 downto 0);
        zero_flag   : in  std_logic;
        -- Senales de control hacia el datapath
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
    -- Registro de estado (patron P5/P6/P8)
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= FETCH;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Stub Semana 1: transicion lineal por los 4 estados.
    -- La logica real de decodificacion y saltos va en Semana 3.
    process(state)
    begin
        case state is
            when FETCH     => next_state <= DECODE;
            when DECODE    => next_state <= EXECUTE;
            when EXECUTE   => next_state <= WRITEBACK;
            when WRITEBACK => next_state <= FETCH;
        end case;
    end process;

    -- Salidas inactivas en Semana 1 (se generan en Semana 3).
    pc_inc      <= '0';
    pc_load     <= '0';
    ir_load     <= '0';
    acc_we      <= '0';
    ram_we      <= '0';
    alu_op      <= "100";  -- pass-A
    mux_alu_src <= '0';
end architecture;
