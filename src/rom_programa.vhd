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

    -- Programa de prueba completo (ejercita las 8 instrucciones ISA):
    -- Datos en RAM: MEM[0x20]=0x0F, MEM[0x21]=0x05
    --
    -- 0x00: LDA 0x20  ; ACC = 0x0F
    -- 0x01: ADD 0x21  ; ACC = 0x0F + 0x05 = 0x14  -> LEDR muestra 0x14
    -- 0x02: STA 0xF0  ; LEDR = 0x14
    -- 0x03: LDA 0x20  ; ACC = 0x0F
    -- 0x04: SUB 0x21  ; ACC = 0x0F - 0x05 = 0x0A  -> LEDR muestra 0x0A
    -- 0x05: STA 0xF0  ; LEDR = 0x0A
    -- 0x06: LDA 0x20  ; ACC = 0x0F
    -- 0x07: AND 0x21  ; ACC = 0x0F & 0x05 = 0x05  -> LEDR muestra 0x05
    -- 0x08: STA 0xF0  ; LEDR = 0x05
    -- 0x09: LDA 0x20  ; ACC = 0x0F
    -- 0x0A: OR  0x21  ; ACC = 0x0F | 0x05 = 0x0F  -> LEDR muestra 0x0F
    -- 0x0B: STA 0xF0  ; LEDR = 0x0F
    -- 0x0C: LDA 0x20  ; ACC = 0x0F
    -- 0x0D: SUB 0x20  ; ACC = 0x0F - 0x0F = 0x00  (zero_flag=1)
    -- 0x0E: JZ  0x00  ; ACC=0 -> salta a 0x00 (loop)
    -- 0x0F: JMP 0x00  ; seguridad (no debe alcanzarse)
    constant ROM : rom_t := (
        0      => x"0200",  -- LDA 0x20
        1      => x"2210",  -- ADD 0x21
        2      => x"1F00",  -- STA 0xF0
        3      => x"0200",  -- LDA 0x20
        4      => x"3210",  -- SUB 0x21
        5      => x"1F00",  -- STA 0xF0
        6      => x"0200",  -- LDA 0x20
        7      => x"4210",  -- AND 0x21
        8      => x"1F00",  -- STA 0xF0
        9      => x"0200",  -- LDA 0x20
        10     => x"5210",  -- OR  0x21
        11     => x"1F00",  -- STA 0xF0
        12     => x"0200",  -- LDA 0x20
        13     => x"3200",  -- SUB 0x20  (ACC = 0)
        14     => x"7000",  -- JZ  0x00
        15     => x"6000",  -- JMP 0x00
        others => x"0000"
    );
begin
    dout <= ROM(to_integer(unsigned(addr)));
end architecture;
