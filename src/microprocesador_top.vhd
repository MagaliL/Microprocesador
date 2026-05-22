library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Top-level del mini microprocesador
-- Tarjeta: Intel DE10-Lite (MAX 10, 10M50DAF484C7G)
-- Reloj: MAX10_CLK1_50 = 50 MHz
-- Reset: KEY[1] activo-bajo

entity microprocesador_top is
    port(
        MAX10_CLK1_50 : in  std_logic;
        KEY           : in  std_logic_vector(1 downto 0);
        SW            : in  std_logic_vector(7 downto 0);
        LEDR          : out std_logic_vector(7 downto 0);
        HEX0          : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Structural of microprocesador_top is
    -- Reset y reloj
    signal clk    : std_logic;
    signal rst_n  : std_logic;

    -- Program counter / fetch
    signal pc_out      : std_logic_vector(7 downto 0);
    signal instruction : std_logic_vector(15 downto 0);
    signal ir_reg      : std_logic_vector(15 downto 0) := (others => '0');
    signal opcode      : std_logic_vector(3 downto 0);
    signal operand     : std_logic_vector(7 downto 0);

    -- Datapath
    signal acc_reg    : std_logic_vector(7 downto 0) := (others => '0');
    signal alu_result : std_logic_vector(7 downto 0);
    signal zero_flag  : std_logic;
    signal ram_dout   : std_logic_vector(7 downto 0);

    -- Senales de control desde la FSM
    signal pc_inc_s      : std_logic;
    signal pc_load_s     : std_logic;
    signal ir_load_s     : std_logic;
    signal acc_we_s      : std_logic;
    signal ram_we_s      : std_logic;
    signal alu_op_s      : std_logic_vector(2 downto 0);
    signal mux_alu_src_s : std_logic;

    -- Periferico HEX0
    signal hex_data_s : std_logic_vector(7 downto 0);
begin
    clk     <= MAX10_CLK1_50;
    rst_n   <= KEY(1);
    opcode  <= ir_reg(15 downto 12);
    operand <= ir_reg(11 downto 4);

    U_PC : entity work.program_counter
        port map(
            clk     => clk,
            rst_n   => rst_n,
            pc_inc  => pc_inc_s,
            pc_load => pc_load_s,
            addr_in => operand,
            pc_out  => pc_out
        );

    U_ROM : entity work.rom_programa
        port map(
            addr => pc_out,
            dout => instruction
        );

    U_RAM : entity work.ram_datos
        port map(
            clk      => clk,
            rst_n    => rst_n,
            we       => ram_we_s,
            addr     => operand,
            din      => acc_reg,
            dout     => ram_dout,
            sw_in    => SW,
            led_out  => LEDR,
            hex_data => hex_data_s
        );

    U_ALU : entity work.alu
        port map(
            op_a      => acc_reg,
            op_b      => ram_dout,
            alu_op    => alu_op_s,
            result    => alu_result,
            zero_flag => zero_flag
        );

    U_FSM : entity work.control_fsm
        port map(
            clk         => clk,
            rst_n       => rst_n,
            opcode      => opcode,
            zero_flag   => zero_flag,
            pc_inc      => pc_inc_s,
            pc_load     => pc_load_s,
            ir_load     => ir_load_s,
            acc_we      => acc_we_s,
            ram_we      => ram_we_s,
            alu_op      => alu_op_s,
            mux_alu_src => mux_alu_src_s
        );

    -- HEX0 muestra el nibble bajo del registro de periferico 0xF2
    U_HEX : entity work.sevenseg_decoder
        port map(
            digit => hex_data_s(3 downto 0),
            seg   => HEX0
        );

    -- Registros IR y ACC controlados por la FSM (logica completa Semana 3-4)
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            ir_reg  <= (others => '0');
            acc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if ir_load_s = '1' then
                ir_reg <= instruction;
            end if;
            if acc_we_s = '1' then
                acc_reg <= alu_result;
            end if;
        end if;
    end process;
end architecture;
