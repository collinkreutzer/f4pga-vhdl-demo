library ieee;
use ieee.std_logic_1164.ALL;

entity volladdierer is
    port (
        A:  in  std_logic;
        B:  in  std_logic;
        CI: in  std_logic;

        S:  out std_logic;
        CO: out std_logic
    );
end volladdierer;

architecture behavioral of volladdierer is
begin
    S  <= A xor B xor CI;
    CO <= (A and B) or ((A xor B) and CI);
end behavioral;