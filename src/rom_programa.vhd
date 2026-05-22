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

    -- Programa de prueba minimo:
    --   0: LDA 0x10   ; ACC <- MEM[0x10]
    --   1: ADD 0x11   ; ACC <- ACC + MEM[0x11]
    --   2: STA 0xF0   ; LEDR <- ACC
    --   3: JMP 0x00   ; loop
    constant ROM : rom_t := (
        0      => x"0100",  -- LDA 0x10
        1      => x"2110",  -- ADD 0x11
        2      => x"1F00",  -- STA 0xF0
        3      => x"6000",  -- JMP 0x00
        others => x"0000"
    );
begin
    dout <= ROM(to_integer(unsigned(addr)));
end architecture;
