library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ALU combinacional
-- alu_op: 000=ADD  001=SUB  010=AND  011=OR  1xx=pass-A (LDA/STA)

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
    process(op_a, op_b, alu_op)
        variable a, b, sum : unsigned(8 downto 0);
    begin
        a := '0' & unsigned(op_a);
        b := '0' & unsigned(op_b);
        case alu_op is
            when "000"  => sum := a + b;                          -- ADD
            when "001"  => sum := a - b;                          -- SUB
            when "010"  => sum := '0' & (unsigned(op_a) and unsigned(op_b));  -- AND
            when "011"  => sum := '0' & (unsigned(op_a) or  unsigned(op_b));  -- OR
            when "100"  => sum := b;                               -- pass-B (LDA: ACC <- MEM[addr])
            when others => sum := a;                               -- pass-A
        end case;
        r <= std_logic_vector(sum(7 downto 0));
    end process;

    result    <= r;
    zero_flag <= '1' when r = x"00" else '0';
end architecture;
