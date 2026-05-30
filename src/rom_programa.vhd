library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM 256 x 16 bits
-- Formato de instruccion:
--   bits 15-12 : OPCODE
--   bits 11-4  : OPERANDO/ADDR
--   bits 3-0   : padding (siempre 0000)
--
-- OPCODES (ISA Semana 1):
--   0000 LDA  0001 STA  0010 ADD  0011 SUB
--   0100 AND  0101 OR   0110 JMP  0111 JZ

entity rom_programa is
    port(
        addr : in  std_logic_vector(7 downto 0);
        dout : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of rom_programa is
    type rom_t is array (0 to 255) of std_logic_vector(15 downto 0);

    -- Programa de prueba perifericos (Semana 5):
    -- Lee SW[7:0] y muestra en LEDR y HEX0 en loop continuo
    --
    -- 0x00: LDA 0xF1  ; ACC = SW[7:0]
    -- 0x01: STA 0xF0  ; LEDR = ACC
    -- 0x02: STA 0xF2  ; HEX0 = nibble bajo de ACC
    -- 0x03: JMP 0x00  ; loop infinito
    constant ROM : rom_t := (
        0      => x"0F10",  -- LDA 0xF1
        1      => x"1F00",  -- STA 0xF0
        2      => x"1F20",  -- STA 0xF2
        3      => x"6000",  -- JMP 0x00
        others => x"0000"
    );
begin
    dout <= ROM(to_integer(unsigned(addr)));
end architecture;
