library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- RAM 256 x 8 bits + stub de memoria mapeada
-- Direcciones mapeadas (logica completa en Semana 5):
--   0xF0 escritura -> LEDR[7:0]
--   0xF1 lectura   -> SW[7:0]
--   0xF2 escritura -> HEX0 (via sevenseg_decoder)

entity ram_datos is
    port(
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        we       : in  std_logic;
        addr     : in  std_logic_vector(7 downto 0);
        din      : in  std_logic_vector(7 downto 0);
        dout     : out std_logic_vector(7 downto 0);
        -- Puertos de periferico (stub Semana 1, conectados en Semana 5)
        sw_in    : in  std_logic_vector(7 downto 0);
        led_out  : out std_logic_vector(7 downto 0);
        hex_data : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of ram_datos is
    type mem_t is array (0 to 255) of std_logic_vector(7 downto 0);
    signal mem      : mem_t := (
        16#20# => x"0F",
        16#21# => x"05",
        others => (others => '0')
    );
    signal led_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal hex_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal addr_int : integer range 0 to 255;
begin
    addr_int <= to_integer(unsigned(addr));

    -- Escritura sincronica: a RAM o a registros de periferico
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            led_reg <= (others => '0');
            hex_reg <= (others => '0');
        elsif rising_edge(clk) then
            if we = '1' then
                case addr is
                    when x"F0"  => led_reg <= din;
                    when x"F2"  => hex_reg <= din;
                    when others => mem(addr_int) <= din;
                end case;
            end if;
        end if;
    end process;

    -- Lectura combinacional: de RAM o de switches
    dout <= sw_in when addr = x"F1" else mem(addr_int);

    led_out  <= led_reg;
    hex_data <= hex_reg;
end architecture;
