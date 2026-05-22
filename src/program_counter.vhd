library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port(
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        pc_inc  : in  std_logic;
        pc_load : in  std_logic;
        addr_in : in  std_logic_vector(7 downto 0);
        pc_out  : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of program_counter is
    signal pc_reg : unsigned(7 downto 0);
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if pc_load = '1' then
                pc_reg <= unsigned(addr_in);
            elsif pc_inc = '1' then
                pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;

    pc_out <= std_logic_vector(pc_reg);
end architecture;
