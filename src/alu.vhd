library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ALU combinacional
-- alu_op:
--   000 ADD
--   001 SUB
--   010 AND
--   011 OR
--   100 pass-A (LDA)
-- La logica completa se implementa en Semana 2.

entity alu is
    port(
        op_a      : in  std_logic_vector(7 downto 0);
        op_b      : in  std_logic_vector(7 downto 0);
        alu_op    : in  std_logic_vector(2 downto 0);
        result    : out std_logic_vector(7 downto 0);
        zero_flag : out std_logic
    );
end entity;

architecture rtl of alu is
    signal r : std_logic_vector(7 downto 0);
begin
    -- Stub Semana 1: pass-A para que la sintesis sea limpia.
    r <= op_a;

    result    <= r;
    zero_flag <= '1' when r = x"00" else '0';
end architecture;
