library ieee;
use ieee.std_logic_1164.ALL;

entity top is
    port (
        sw0:  in  std_logic;
        sw1:  in  std_logic;
        sw2: in  std_logic;

        led0:  out std_logic;
        led1: out std_logic
    );
end top;

architecture structural of top is

    component volladdierer
    port (
         A : IN  std_logic;
         B : IN  std_logic;
         CI : IN  std_logic;
         CO : OUT  std_logic;
         S : OUT  std_logic
    );
    end component;

begin

    volladd1: volladdierer PORT MAP (
        A => sw0,
        B => sw1,
        CI => sw2,
        S => led0,
        CO => led1
    );

end structural;