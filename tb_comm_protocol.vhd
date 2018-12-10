library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_comm_protocol is
end tb_comm_protocol;

architecture tb_comm_protocol of tb_comm_protocol is
  signal rst_n     : std_logic;
  signal clk       : std_logic;
  signal send_i    : std_logic;
  signal data_32_i : std_logic_vector(31 downto 0);
  signal msg_o     : std_logic;
  signal busy_o    : std_logic;
  signal valid_o   : std_logic;
  signal data_8_o  : std_logic_vector(7 downto 0);
begin

  DUV: entity work.comm_protocol
       port map (rst_n => rst_n, clk => clk, send_i => send_i, data_32_i => data_32_i,
                 msg_o => msg_o, busy_o => busy_o, valid_o => valid_o, data_8_o => data_8_o );

  process
  begin
    clk <= '1', '0' after 5 ns;
    wait for 10 ns;
  end process;

  rst_n  <= '0','1' after 50 ns;

  send_i <= '0', '1' after  100 ns, '0' after  110 ns, 
                 '1' after  200 ns, '0' after  210 ns, 
                 '1' after  300 ns, '0' after  310 ns, 
                 '1' after  400 ns, '0' after  410 ns, 
                 '1' after  500 ns, '0' after  510 ns,
                 '1' after  650 ns, '0' after  660 ns,
                 '1' after  800 ns, '0' after  810 ns,
                 '1' after  900 ns, '0' after  910 ns,
                 '1' after 1000 ns, '0' after 1010 ns,
                 '1' after 1100 ns, '0' after 1110 ns,
                 '1' after 1200 ns, '0' after 1210 ns,
                 '1' after 1300 ns, '0' after 1310 ns,
                 '1' after 1400 ns, '0' after 1410 ns,
                 '1' after 1650 ns, '0' after 1660 ns,
                 '1' after 1800 ns, '0' after 1810 ns,
                 '1' after 1900 ns, '0' after 1910 ns;
           
  data_32_i <= (others => '0'),
               -- addr_src & addr_dst & service & payload size
               x"00" & x"0A" & x"01" & x"04" after 100 ns,
               x"44332211" after 200 ns, -- Msg 1 - pck 1
               x"88776655" after 300 ns, -- Msg 1 - pck 2
               x"44332211" after 400 ns, -- Msg 1 - pck 3
               x"88776655" after 500 ns, -- Msg 1 - pck 4

               -- addr_src & addr_dst & service & payload size
               x"00" & x"10" & x"02" & x"00" after 650 ns,

               -- addr_src & addr_dst & service & payload size
               x"00" & x"04" & x"01" & x"06" after 800 ns,
               x"44332211" after  900 ns, -- Msg 2 - pck 1
               x"88776655" after 1000 ns, -- Msg 2 - pck 2
               x"44332211" after 1100 ns, -- Msg 2 - pck 3
               x"88776655" after 1200 ns, -- Msg 2 - pck 4
               x"44332211" after 1300 ns, -- Msg 2 - pck 5
               x"88776655" after 1400 ns, -- Msg 2 - pck 6

               -- addr_src & addr_dst & service & payload size
               x"00" & x"11" & x"02" & x"00" after 1650 ns,

               -- addr_src & addr_dst & service & payload size
               x"00" & x"0B" & x"01" & x"01" after 1800 ns,
               x"44332211" after 1900 ns; -- Msg 3 - pck 1

end tb_comm_protocol;
