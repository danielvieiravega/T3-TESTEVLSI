library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity comm_protocol is
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    send_i    : in  std_logic;
    data_32_i : in  std_logic_vector(31 downto 0);
    msg_o     : out std_logic;
    busy_o    : out std_logic;
    valid_o   : out std_logic;
    data_8_o  : out std_logic_vector(7 downto 0)
  );
end comm_protocol;

architecture comm_protocol of comm_protocol is
  type states is (IDLE, HDST, HSRC, HSIZE, SEND, PLD1, PLD2, PLD3, PLD4, CRC, CNT);
  signal current_state, next_state: states;
  signal counter: std_logic_vector(7 downto 0);
  signal buff_hdr: std_logic_vector(23 downto 0);
  signal buff_pld: std_logic_vector(31 downto 0);
  signal buff_crc: std_logic_vector(7 downto 0);
  signal buff_cnt: std_logic_vector(7 downto 0);
begin


        -- buff_hdr(7  downto  0) <= data_32_i(31 downto 24);      -- Source Address 
        -- buff_hdr(15 downto  8) <= data_32_i(23 downto 16);      -- Destination Address 

  -------------------------------------------------
  -------------------------------------------------
  -- Coloque abaixo as suas assercoes em PSL
  -------------------------------------------------
  -------------------------------------------------
  -- PSL default clock is (rising_edge(clk));
  -- PSL property rst_clean is always ( rst_n -> { not valid_o; not busy_o; not msg_o } );
  -- PSL property send_1clk is always ( true -> next (send_i)) @(rising_edge(clk));
  -- property msg_start is always ( send_i -> next () ) @(falling_edge(clk)); (Nao vejo nada um ciclo depois)
  -- property msg_size 
  -- property msg_inv_dst is always ( send_i -> next (data_32_i(31 downto 24) /= data_32_i(23 downto 16))) @(falling_edge(clk));
  --
  -- PSL rst_clean_assertion: assert rst_clean;
  -- PSL send_1clk_assertion: assert send_1clk;
  -- msg_start_assertion: assert msg_start;
  -- msg_size_assertion: assert msg_size;
  -------------------------------------------------
  -------------------------------------------------

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      current_state <= IDLE;
    elsif clk'event and clk = '1' then
      current_state <= next_state;
    end if;
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      next_state <= IDLE;

    elsif clk'event and clk = '1' then
      case next_state is
        when IDLE =>
          if send_i = '1' and data_32_i(15 downto 8) = x"01" then
            next_state <= HDST;
          elsif send_i = '1' and data_32_i(15 downto 8) = x"02" then
            next_state <= CNT;
          else
            next_state <= IDLE;
          end if;
        when HDST  => next_state <= HSRC;
        when HSRC  => next_state <= HSIZE;
        when HSIZE => next_state <= SEND;
        when SEND =>
          if send_i = '1' then
            next_state <= PLD1;
          else
            next_state <= SEND;
          end if;
        when PLD1 => next_state <= PLD2;
        when PLD2 => next_state <= PLD3;
        when PLD3 => next_state <= PLD4;
        when PLD4 => 
          if counter = x"00" then
            next_state <= CRC;
          else
            next_state <= SEND;
          end if;
        when CRC  => next_state <= IDLE;
        when CNT  => next_state <= IDLE;
      end case;
    end if;
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      counter <= (others => '0');
    elsif clk'event and clk = '1' then
      if current_state = IDLE and send_i = '1' and data_32_i(15 downto 8) = x"01" then
        counter <= data_32_i(7 downto 0);
      elsif current_state = PLD4 and counter /= x"00" then
        counter <= counter - 1;
      end if;
    end if;
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      buff_hdr <= (others => '0');
    elsif clk'event and clk = '1' then
      if current_state = IDLE and send_i = '1' and data_32_i(15 downto 8) = x"01" then
        buff_hdr(7  downto  0) <= data_32_i(31 downto 24);      -- Source Address 
        buff_hdr(15 downto  8) <= data_32_i(23 downto 16);      -- Destination Address 
        buff_hdr(23 downto 16) <= data_32_i(5 downto 0) & "01"; -- Msg Size (Payload + CRC) 
      end if;
    end if;
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      buff_pld <= (others => '0');
    elsif clk'event and clk = '1' then
      if current_state = SEND and send_i = '1' then
        buff_pld <= data_32_i;
      end if;
    end if;
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      buff_crc <= (others => '0');
    elsif clk'event and clk = '1' then
      if current_state = SEND and send_i = '1' then
        buff_crc <= data_32_i(31 downto 24) xor data_32_i(23 downto 16) xor
                    data_32_i(15 downto  8) xor data_32_i(7  downto  0);
      elsif current_state = CRC then
        buff_crc <= (others => '0');
      end if;
    end if;
  end process;

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      buff_cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if current_state = CNT then
        buff_cnt <= buff_cnt + 1;
      end if;
    end if;
  end process;

  msg_o    <= '0' when (current_state = IDLE or current_state = CNT)  else '1';

  busy_o   <= '0' when (current_state = IDLE or current_state = SEND) else '1';

  valid_o  <= '1' when (current_state = CRC  or current_state = HSRC  or rst_n = '0' or
                        current_state = HDST or current_state = HSIZE or
                        current_state = PLD1 or current_state = PLD2  or
                        current_state = PLD3 or current_state = PLD4) else '0';

  data_8_o <= buff_hdr(7  downto  0) when current_state = HSRC  else 
              buff_hdr(15 downto  8) when current_state = HDST  else
              buff_hdr(23 downto 16) when current_state = HSIZE else
              buff_crc               when current_state = CRC   else
              buff_cnt               when current_state = CNT   else
              buff_pld(7  downto  0) when current_state = PLD1  else
              buff_pld(15 downto  8) when current_state = PLD2  else
              buff_pld(23 downto 16) when current_state = PLD3  else
              buff_pld(31 downto 24) when current_state = PLD4  else (others => '0');

end comm_protocol;
