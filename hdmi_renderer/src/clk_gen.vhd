library ieee;
use ieee.std_logic_1164.all;

entity clk_gen is
    port (
        clk_27MHz_in  : in  std_logic;
        rst_n          : in  std_logic;
        clk_126MHz_out : out std_logic;
        clk_pixel_out : out std_logic; --126/5 = 25.2MHz
        rst_pixel_out : out std_logic;
        rpll_lock : out std_logic

    );
end entity clk_gen;

architecture rtl of clk_gen is

    component Gowin_CLKDIV
    port (
        clkout: out std_logic;
        hclkin: in std_logic;
        resetn: in std_logic
        );
    end component;

    component Gowin_rPLL
    port (
        clkout: out std_logic;
        lock: out std_logic;
        clkin: in std_logic
        );
    end component;

    signal clk_126MHz : std_logic;
    signal clk_pixel : std_logic;
    signal rst_pixel : std_logic;
    signal lock : std_logic;
    signal reset_async : std_logic;
    signal rst_sync : std_logic_vector(1 downto 0);

begin
    rpll: Gowin_rPLL
    port map (
        clkout => clk_126MHz,
        lock => lock,
        clkin => clk_27MHz_in
    );

    clkdiv: Gowin_CLKDIV
    port map (
        clkout => clk_pixel,
        hclkin => clk_126MHz,
        resetn => lock
    );

    clk_126MHz_out <= clk_126MHz;
    clk_pixel_out <= clk_pixel;
    rpll_lock <= lock;

    reset_async <= not lock or not rst_n;
    
    sync_reset : process (clk_pixel, reset_async) 
    begin
        if reset_async = '1' then
            rst_sync <= (others => '1');
        elsif rising_edge(clk_pixel) then
            rst_sync <= rst_sync(0) & '0';
        end if;
    end process;
    rst_pixel_out <= rst_sync(1);
end rtl;