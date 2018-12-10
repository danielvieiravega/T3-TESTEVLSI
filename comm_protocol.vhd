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
  -- PSL property rst_clean1 is never ( not rst_n and valid_o and  busy_o and msg_o );
  -- PSL property send_1clk1 is always clk and send_i -> next not send_i @(rising_edge(clk));
  -- PSL property msg_start1 is always ( send_i = '1' and data_32_i(15 downto 8) = x"01" -> next (msg_o) ) @(falling_edge(clk));
  -- PSL property msg_size1 is always ( send_i = '1' and data_32_i(15 downto 8) = x"01" -> next (data_32_i(7 downto 6) = x"00")) @(falling_edge(clk));
  -- PSL property msg_inv_dst1 is always ( data_32_i(15 downto 8) = x"01" and current_state = IDLE-> (data_32_i(31 downto 24) /= data_32_i(23 downto 16))) @(falling_edge(clk));
  -- PSL property serv_msg1 is always ( send_i = '1' and data_32_i(15 downto 8) = x"01" -> next (msg_o and busy_o and valid_o) abort rst_n) @(falling_edge(clk));
  -- PSL property serv_cnt1 is always ( send_i = '1' and data_32_i(15 downto 8) = x"02" -> next (not msg_o and (busy_o[*1]) and not valid_o) abort rst_n) @(falling_edge(clk));
  -- PSL property fsm_hdr1 is always ( {send_i = '1' and data_32_i(15 downto 8) = x"01"} |=> ({current_state = HDST} |=> {current_state = HSRC} |=> {current_state = HSIZE}) abort not rst_n)  @(falling_edge(clk));
  
  -- PSL property fsm_crc1 is forall i in 0..(4*data_32_i(5 downto 0)*8+8):
  -- always (current_state = CRC and ) abort rst_n  @(rising_edge(clk));
  
  --  property fsm_crc1 is always next_event(send_i = '1' and data_32_i(15 downto 8) = x"01")[(4*data_32_i(7 downto 0)*8+8)](current_state = CRC) abort rst_n  @(rising_edge(clk));
  
  
  
  --
  -- ASSERCOES BUFFERS
  --
  -- PSL property buf_cnt1 is always ({current_state = CNT} |=> data_8_o <= buff_cnt )  @(falling_edge(clk));
  -- PSL property buf_crc1 is always ({current_state = CRC} |=> data_8_o <= buff_crc )  @(falling_edge(clk));
  -- PSL property buf_src1 is always (current_state = HSRC -> data_8_o <= buff_hdr(7  downto  0) )  @(falling_edge(clk));
  -- PSL property buf_dst1 is always (current_state = HDST -> data_8_o <= buff_hdr(15 downto  8) )  @(falling_edge(clk));
  -- PSL property buf_size1 is always (current_state = HSIZE -> data_8_o <= buff_hdr(23 downto 16) )  @(falling_edge(clk));
  -- PSL property buf_pld11 is always (current_state = PLD1 -> data_8_o <= buff_pld(7  downto  0) )  @(falling_edge(clk));
  -- PSL property buf_pld21 is always (current_state = PLD2 -> data_8_o <= buff_pld(15  downto  8) )  @(falling_edge(clk));
  -- PSL property buf_pld31 is always (current_state = PLD3 -> data_8_o <= buff_pld(23 downto  16) )  @(falling_edge(clk));
  -- PSL property buf_pld41 is always (current_state = PLD4 -> data_8_o <= buff_pld(31  downto  24) )  @(falling_edge(clk));
  --
  -- PSL rst_clean: assert rst_clean1;
  -- PSL send_1clk: assert send_1clk1;
  -- PSL msg_start: assert msg_start1;  
  -- PSL msg_size: assert msg_size1;
  -- PSL msg_inv_dst: assert msg_inv_dst1;
  -- PSL serv_msg: assert serv_msg1;
  -- PSL serv_cnt: assert serv_cnt1;
  -- PSL fsm_hdr: assert fsm_hdr1;
  -- PSL fsm_crc: assert fsm_crc1;
  -- PSL buf_cnt: assert buf_cnt1;
  -- PSL buf_crc: assert buf_crc1;
  -- PSL buf_src: assert buf_src1;
  -- PSL buf_dst: assert buf_dst1;
  -- PSL buf_size: assert buf_size1;
  -- PSL buf_pld1: assert buf_pld11;
  -- PSL buf_pld2: assert buf_pld21;
  -- PSL buf_pld3: assert buf_pld31;
  -- PSL buf_pld4: assert buf_pld41;
  
  
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
        counter <= data_32_i(7 downto 0)-1;
      elsif current_state = PLD4 and counter > x"00" then
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

