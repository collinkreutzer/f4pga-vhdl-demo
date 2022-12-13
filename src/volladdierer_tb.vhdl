library ieee;
use ieee.std_logic_1164.ALL;

entity volladdierer_tb is
end volladdierer_tb;

architecture behavioral of volladdierer_tb is
    component volladdierer
        port (
            A:  in  std_logic;
            B:  in  std_logic;
            CI: in std_logic;
            S:  out std_logic;
            CO: out std_logic
        );
    end component;

    signal A, B, CI, S, CO: std_logic;

begin

    add1: volladdierer port map (A, B, CI, S, CO);

    process
        type pattern is record
            A, B, CI, S, CO: std_logic;
        end record;
        
        type pattern_array is array (natural range <>) of pattern;

        constant patterns: pattern_array := (
            ('0', '0', '0', '0', '0'),
            ('0', '0', '1', '1', '0'),
            ('0', '1', '0', '1', '0'),
            ('0', '1', '1', '0', '1'),
            ('1', '0', '0', '1', '0'),
            ('1', '0', '1', '0', '1'),
            ('1', '1', '0', '0', '1'),
            ('1', '1', '1', '1', '1')
        );

    begin

        for i in patterns'range loop
            A  <= patterns(i).A;
            B  <= patterns(i).B;
            CI <= patterns(i).CI;
            
            wait for 1 ns;
            
            assert S = patterns(i).S
            report "bad sum S = " & std_logic'image(patterns(i).S) & " for pattern " & integer'image(i) severity error;

            assert CO = patterns(i).CO
            report "bad carry CO = " & std_logic'image(patterns(i).CO) & " for pattern " & integer'image(i) severity error;

        end loop;

        report "testbench finished." severity note;

        wait;

    end process;
end behavioral;