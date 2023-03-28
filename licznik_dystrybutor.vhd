library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith;
entity main is
   PORT(
      reset       : in       STD_LOGIC;
      clk_50Mhz   : in       STD_LOGIC;
      LCD_RS      : out      STD_LOGIC;
      LCD_E       : out      STD_LOGIC;
      start       : in       STD_LOGIC;
      stop        : in       STD_LOGIC;
      paliwo      : in       std_logic_vector(1 downto 0);
      postep      : out      std_logic;
      dioda       : out      std_logic;
      DATA_BUS    : out      STD_LOGIC_VECTOR (7 DOWNTO 4)
    );
end main;
architecture Behavioral of main is
   TYPE STATE_TYPE IS   (
                        HOLD, FUNC_SET, DISPLAY_ON, MODE_SET, WRITE_CHAR, 
                        RETURN_HOME, SEND_UPPER, SEND_LOWER, TOGGLE_E, TOGGLE_E2, INIT1, INIT2,   INIT3, 
                        DISPLAY_OFF, DISPLAY_CLEAR, LINE2, COLON, SPACE,DISPLAY_CLEAR1,DISPLAY_CLEAR2,DISPLAY_CLEAR3,DISPLAY_CLEAR4,
                        wg1,wg2, wg3,lineg, koszty_g,koszty_g2,koszty_g3,spacebr,
                        ks1,ks2, ks3, ks4 ,ks5, ks6,dz1,dz2,dz3,dz4,dz5,dz6,dz7,dz8,dz9,dz10,
                        nb1,nb2,nb3,nb4,nb5,nb6,nb7,nb8,nb9,nb10,nb11,nb12,nb13,nb14,nb15,nb16,nb17,nb18,
                        b1,b2, b3, b4 ,b5, b6, b7,lineb, koszty_b, koszty_b2, koszty_b3,SPACEB,
                        d1,d2, d3, d4 ,d5, d6,SPACED,lined, koszty_d, koszty_d2,koszty_d3                         
                        );
   signal state              : STATE_TYPE;
   signal next_state         : STATE_TYPE;
   signal DATA_BUS_VALUE     : STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal CLK_200HZ          : STD_LOGIC:='0'; -- 400Hz / 2
   signal CLK_200HZCNT       : integer range 0 to 130000;
   signal CLK_400HZ          : std_logic:='0'; -- 800Hz / 2 
   signal CLK_400HZCNT       : integer range 0 to 500000;
   signal char_no            : STD_LOGIC_VECTOR (4 downto 0):="00000";
   signal reset_cnt          : STD_LOGIC_VECTOR (3 downto 0):="0000";
   signal licznik_j: std_logic_vector(7 downto 0):=x"30";
   signal licznik_d: std_logic_vector(7 downto 0):=x"30";
   signal licznik_s: std_logic_vector(7 downto 0):=x"30";
   signal postep1: std_logic:='0';
   signal licznik_litry: std_logic_vector(7 downto 0);
   --- ASCI CHARS ---
   signal A: std_logic_vector(7 downto 0):=x"41";
   signal B: std_logic_vector(7 downto 0):=x"42";
   signal C: std_logic_vector(7 downto 0):=x"43";
   signal D: std_logic_vector(7 downto 0):=x"44";
   signal E: std_logic_vector(7 downto 0):=x"45";
   signal F: std_logic_vector(7 downto 0):=x"46";
   signal G: std_logic_vector(7 downto 0):=x"47";
   signal H: std_logic_vector(7 downto 0):=x"48";
   signal I: std_logic_vector(7 downto 0):=x"49";
   signal J: std_logic_vector(7 downto 0):=x"4A";
   signal K: std_logic_vector(7 downto 0):=x"4B";
   signal L: std_logic_vector(7 downto 0):=x"4C";
   signal M: std_logic_vector(7 downto 0):=x"4D";
   signal N: std_logic_vector(7 downto 0):=x"4E";
   signal O: std_logic_vector(7 downto 0):=x"4F";
   signal P: std_logic_vector(7 downto 0):=x"50";
   signal Q: std_logic_vector(7 downto 0):=x"51";
   signal R: std_logic_vector(7 downto 0):=x"52";
   signal S: std_logic_vector(7 downto 0):=x"53";
   signal T: std_logic_vector(7 downto 0):=x"54";
   signal U: std_logic_vector(7 downto 0):=x"55";
   signal V: std_logic_vector(7 downto 0):=x"56";
   signal W: std_logic_vector(7 downto 0):=x"57";
   signal X: std_logic_vector(7 downto 0):=x"58";
   signal Y: std_logic_vector(7 downto 0):=x"59";
   signal Z: std_logic_vector(7 downto 0):=x"5A";
   signal dwukropek: std_logic_vector(7 downto 0):=x"3A";
   signal spacja: std_logic_vector(7 downto 0):=x"20";
   signal kropka: std_logic_vector(7 downto 0):=x"2E";
   signal enter: std_logic_vector(7 downto 0):=x"c0";
   
BEGIN
licznik_proc:process(CLK_400HZ,reset,paliwo) -- zliczanie ilosc paliwa oraz kosztow
	begin
		if (reset='1') then 
		      licznik_litry<= (others => '0');
		      --- zmiany tu byly
		     licznik_s<=x"30";
             licznik_d<=x"30";
             licznik_j<=x"30";
		elsif (rising_edge(CLK_400HZ)) then -- 1 takt zegara tankuje 1 litr paliwa i dolicza odpowiednia kwote za wybrany rodzaj paliwa
					if (state=koszty_g or state=koszty_g2 or state=koszty_g3 or state=koszty_b or state=koszty_d) then
						if (paliwo="10") then -- benzyna - 4 zl/litr 
                               	licznik_litry<=licznik_litry+1;
                                    licznik_j<=licznik_j+2;
                                        if(licznik_j=x"38") then
                                           licznik_j<=x"30";
                                           licznik_s<=licznik_s+1;
                                           if(licznik_s=x"39") then
                                              licznik_s<=x"30";
                                              licznik_d<=licznik_d+1;
                                              if (licznik_d=x"39") then
                                                 licznik_s<=x"30";
                                                 licznik_d<=x"30";
                                                 licznik_j<=x"30";
                                              end if;
                                           end if;
                                        end if;		
						elsif (paliwo="01") then -- LPG - 2 zl/litr
							licznik_litry<=licznik_litry+1;
                                    licznik_j<=licznik_j+1;
                                        if(licznik_j=x"39") then
                                           licznik_j<=x"30";
                                           licznik_s<=licznik_s+1;
                                           if(licznik_s=x"39") then
                                              licznik_s<=x"30";
                                              licznik_d<=licznik_d+1;
                                              if (licznik_d=x"39") then
                                                 licznik_s<=x"30";
                                                 licznik_d<=x"30";
                                                 licznik_j<=x"30";
                                              end if;
                                           end if;
                                        end if;	
						elsif (paliwo="11") then --diesel - 6 zl/litr
					                licznik_litry<=licznik_litry+1;
                                    licznik_j<=licznik_j+3;
                                        if(licznik_j=x"39") then
                                       licznik_j<=x"30";
                                           licznik_s<=licznik_s+1;
                                           if(licznik_s=x"39") then
                                              licznik_s<=x"30";
                                              licznik_d<=licznik_d+1;
                                              if (licznik_d=x"39") then
                                                 licznik_s<=x"30";
                                                 licznik_d<=x"30";
                                                 licznik_j<=x"30";
                                              end if;
                                           end if;
                                        end if;	
						else
							licznik_litry <="00000000";
						end if;
					else
						licznik_litry<=(others=>'0');   
					end if;
			end if;
		end process licznik_proc;

   process (clk_50Mhz) is begin
      if(rising_edge(clk_50Mhz))then
         if(reset = '1')then
            CLK_200HZCNT <= 0;
            CLK_200HZ <= '0';
         else
            CLK_200HZCNT <= CLK_200HZCNT + 1;
            if(CLK_200HZCNT = 67500)then
               CLK_200HZCNT <= 0;
               CLK_200HZ <= not CLK_200HZ;
            end if;
         end if;
      end if;
   end process;
   
  process (clk_50Mhz) is begin
      if(rising_edge(clk_50Mhz))then
         if(reset = '1')then
            CLK_400HZCNT <= 0;
            CLK_400HZ <= '0';
         else
            CLK_400HZCNT <= CLK_400HZCNT + 1;
            if(CLK_400HZCNT = 250000)then
               CLK_400HZCNT <= 0;
               CLK_400HZ <= not CLK_400HZ;
            end if;
         end if;
      end if;
   end process;
   
   process(CLK_200HZ,reset) is begin
    if(reset = '1')then
        reset_cnt<="0000";
    elsif(rising_edge(CLK_200HZ)) then
            if(state=INIT1) then
            reset_cnt <= reset_cnt + 1; 
                    if(reset_cnt="1111") then
                        reset_cnt<="0000";
                    end if;
            elsif (state=INIT2) then
                reset_cnt <= reset_cnt + 1; 
                    if(reset_cnt="1000") then
                        reset_cnt<="0000";
                    end if;
            else
            reset_cnt<="0000";
            end if;
    end if;
     end process;
        
   process (CLK_200HZ, reset) is begin
      if(reset = '1')then
         state <= INIT1;
         DATA_BUS_VALUE <= X"01";
         next_state <= INIT2;
         LCD_E <= '1';
         LCD_RS <= '0';
      elsif(rising_edge(CLK_200HZ))then
         case(state)is
            when INIT1 =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00000011";
               if reset_cnt = "1111" then 
                  next_state <= INIT2;
                  state <= SEND_LOWER;
               else 
                  next_state <= INIT1;
               end if;    
            when INIT2 =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00000011";
               if reset_cnt = "1000" then 
                  next_state <= INIT3;
                  state <= SEND_LOWER;
               else 
                  next_state <= INIT2;
               end if;
            when INIT3 =>   
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00110010";
               state <= SEND_LOWER;
               next_state <= FUNC_SET;
            when FUNC_SET =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00101100";-- 0 0 1 DL N F ** - DL data lenght, N no of lines, F 5x10 or 5x8 font
               --x"38" -- do sprawdzenia
               state <= SEND_UPPER;
               next_state <= DISPLAY_OFF;
            when DISPLAY_OFF =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00001100";--0 0 0 0 1 D C B - D display on/off, C - cursor on/off, B - blink on/off
               state <= SEND_UPPER;
               next_state <= DISPLAY_CLEAR;
            when DISPLAY_CLEAR =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00000001";-- Display clear
               state <= SEND_UPPER;
               next_state <= DISPLAY_ON;
         
            when DISPLAY_ON =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00000110";-- 
               state <= SEND_UPPER;
               next_state <= MODE_SET;
            when MODE_SET =>
               LCD_RS <= '0';
               DATA_BUS_VALUE <= "00001100";-- 000001 I/D S - I/D inc/dec, S - Shift display on/off
               --x"06" do sprawdzenia 
               state <= SEND_UPPER;
               next_state <= WRITE_CHAR;
            when WRITE_CHAR =>
                    if (char_no < 31) then
                            char_no <= char_no +1;                            
                    else
                            char_no <= "00000";
                    end if;
                     
                    if (char_no = 15) then 
                          next_state <= line2;
                     elsif (char_no = 31)  then
                          next_state <= RETURN_HOME;
                     else 
                           next_state <= WRITE_CHAR; 
                     end if;
           case(paliwo) is 
           when "01" => --LPG
                     LCD_RS <= '1';
                     LCD_E <= '1';
                     data_bus_value<=G;
                     state <= SEND_UPPER;
                     next_state<= WG2;
               
            when "10" => --95 
                     LCD_RS <= '1';
                     LCD_E <= '1';
                     data_bus_value<=B;
                     state <= SEND_UPPER;
                     next_state<= b1;
    
            when "11" => -- diesel
           
                     LCD_RS <= '1';
                     LCD_E <= '1';
                     data_bus_value<=D;
                     state <= SEND_UPPER;
                     next_state<= d1;
            when "00" => -- diesel
           
                     LCD_RS <= '1';
                     LCD_E <= '1';
                     data_bus_value<=N;
                     state <= SEND_UPPER;
                     next_state<= nb2;
    
            when others =>
                     LCD_RS <= '1';
                     LCD_E <= '1';
                     --data_bus_value<=test;
                     next_state <= SEND_UPPER;     
          end case;         
          
            when RETURN_HOME =>
               LCD_RS <= '0';
               LCD_E<='1';
               DATA_BUS_VALUE <= X"80";
               state <= SEND_UPPER;
               next_state <= WRITE_CHAR;
            when SEND_UPPER =>
               LCD_E <= '1';
               DATA_BUS <= DATA_BUS_VALUE(7 downto 4);
               state <= TOGGLE_E;         
            when SEND_LOWER =>
               LCD_E <= '1';
               DATA_BUS <= DATA_BUS_VALUE(3 downto 0);
               state <= TOGGLE_E2;
            when TOGGLE_E =>
               LCD_E <= '0';
               state <= SEND_LOWER;       
            when TOGGLE_E2 =>
               LCD_E <= '0';
               state <= HOLD;
           when HOLD => 
               state <= next_state;
               LCD_E<='0'; 
              
           when wg2 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=A;
               state <= SEND_UPPER;
               next_state<= WG3;
          when wg3 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=Z;
               state <= SEND_UPPER;
               next_state<= lineg; 
         when b1 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=E;
               state <= SEND_UPPER;
               next_state<= b2;
         when b2 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=N;
               state <= SEND_UPPER;
               next_state<= b3;  
          when b3 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=Z;
               state <= SEND_UPPER;
               next_state<= b4;  
          when b4 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=Y;
               state <= SEND_UPPER;
               next_state<= b5; 
          when b5 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=N;
               state <= SEND_UPPER;
               next_state<= b6;  
          when b6 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=A;
               state <= SEND_UPPER;
               next_state<= lineb;  
          when d1 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=I;
               state <= SEND_UPPER;
               next_state<= d2; 
          when d2 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=E;
               state <= SEND_UPPER;
               next_state<= d3;
          when d3 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=S;
               state <= SEND_UPPER;
               next_state<= d4;  
          when d4 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=E;
               state <= SEND_UPPER;
               next_state<= d5; 
           when d5 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=L;
               state <= SEND_UPPER;
               next_state<= lined;  
           
            when dz1 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=D;
               state <= SEND_UPPER;
               next_state<= dz2;
            when dz2 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=Z;
               state <= SEND_UPPER;
               next_state<= dz3;
            when dz3 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=I;
               state <= SEND_UPPER;
               next_state<= dz4;
            when dz4 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=E;
               state <= SEND_UPPER;
               next_state<= dz5;
            when dz5 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=K;
               state <= SEND_UPPER;
               next_state<= dz6;
           when dz6 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=U;
               state <= SEND_UPPER;
               next_state<= dz7;
           when dz7 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=J;
               state <= SEND_UPPER;
               next_state<= dz8;
          when dz8 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=E;
               state <= SEND_UPPER;
               next_state<= dz9;
          when dz9 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=M;
               state <= SEND_UPPER;
               next_state<= dz10;
         when dz10 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=Y;
               state <= SEND_UPPER;
               next_state<= return_home;           
           when nb1 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=N;
               state <= SEND_UPPER;
               next_state<= nb2;
           when nb2 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=I;
                   state <= SEND_UPPER;
                   next_state<= nb3;
           when nb3 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=E;
                   state <= SEND_UPPER;
                   next_state<= nb4;
           when nb4 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=SPACJA;
                   state <= SEND_UPPER;
                   next_state<= nb5;
           when nb5 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=W;
                   state <= SEND_UPPER;
                   next_state<= nb6;
            when nb6 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=Y;
                   state <= SEND_UPPER;
                   next_state<= nb7;
             when nb7 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=B;
                   state <= SEND_UPPER;
                   next_state<= nb8;
             when nb8 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=R;
                   state <= SEND_UPPER;
                   next_state<= nb9;
              when nb9 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=A;
                   state <= SEND_UPPER;
                   next_state<= nb10;
              when nb10 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=N;
                   state <= SEND_UPPER;
                   next_state<= nb11;
              when nb11 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=o;
                   state <= SEND_UPPER;
                   next_state<= nb12;
              when nb12 =>
                   LCD_RS <= '0';
                   LCD_E <= '1';
                   data_bus_value<=x"c0";
                   state <= SEND_UPPER;
                   next_state<= nb13;
                  
              when nb13 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=P;
                   state <= SEND_UPPER;
                   next_state<= nb14;
              when nb14 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=A;
                   state <= SEND_UPPER;
                   next_state<= nb15;
              when nb15 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=L;
                   state <= SEND_UPPER;
                   next_state<= nb16;
               when nb16 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=I;
                   state <= SEND_UPPER;
                   next_state<= nb17;
               when nb17 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=W;
                   state <= SEND_UPPER;
                   next_state<= nb18;
               when nb18 =>
                   LCD_RS <= '1';
                   LCD_E <= '1';
                   data_bus_value<=A;
                   state <= SEND_UPPER;
                   next_state<= return_home;
        when lineg =>  
                LCD_E <= '1';
                LCD_RS <= '0';
                DATA_BUS_VALUE <= x"c0";
                state <= SEND_UPPER;
                next_state <= ks1;  
        when lineb =>  
                LCD_E <= '1';
                LCD_RS <= '0';
                DATA_BUS_VALUE <= x"c0";
                state <= SEND_UPPER;
                next_state <= ks1;         
        when lined => 
                 LCD_E <= '1';
                 LCD_RS <= '0';
                 DATA_BUS_VALUE <= x"c0";
                 state <= SEND_UPPER;
                 next_state <= ks1;    
                 
          when KS1 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=K;
               state <= SEND_UPPER;
               next_state<= KS2;         
          when KS2 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=O;
               state <= SEND_UPPER;
               next_state<= KS3; 
          when KS3 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=S;
               state <= SEND_UPPER;
               next_state<= KS4;          
         when KS4 =>
               LCD_RS <= '1';
               LCD_E <= '1';
               data_bus_value<=Z;
               state <= SEND_UPPER;
               next_state<= KS5;   
         when KS5 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=T;
                state <= SEND_UPPER;
                next_state<= KS6; 
         when KS6 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=Y;
                state <= SEND_UPPER;
                next_state<= COLON;  
         when COLON =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=dwukropek;
                state <= SEND_UPPER;
                if(paliwo="01") then -- LPG
                     next_state<= SPACE; 
                elsif (paliwo="10") then --95 
                     next_state<= SPACEB;
                elsif (paliwo="11") then --diesel
                     next_state<= SPACED; 
                end if; 
         when SPACE =>
             LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=spacja;
                state <= SEND_UPPER;
                    if (start='1') then
                     next_state<= koszty_g2; 
                    elsif(stop='1') then 
                        next_state<=DISPLAY_CLEAR1;
                    elsif(stop='0') then
                     next_state<=return_home;
                   elsif(start='0') then 
                     next_state<=return_home;
      
                end if;
         when SPACEB =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=spacja;
                state <= SEND_UPPER;
                    if (start='1') then
                     next_state<= koszty_d2; 
                    elsif(stop='1') then 
                        next_state<=DISPLAY_CLEAR;
                    elsif(stop='0') then
                     next_state<=return_home;
                   elsif(start='0') then 
                     next_state<=return_home;
                end if;
               
         when SPACED =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=spacja;
                state <= SEND_UPPER;
                    if (start='1') then
                     next_state<= koszty_d2; 
                    elsif(stop='1') then 
                        next_state<=DISPLAY_CLEAR;
                    elsif(stop='0') then
                     next_state<=return_home;
                   elsif(start='0') then 
                     next_state<=return_home;
                end if;
                
         when koszty_g =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_j;
                state <= SEND_UPPER;    
         if(licznik_j=x"39" and char_no=27) then
                   next_state<=koszty_g2 ;
         else
                 next_state<= return_home;
         end if;  
         
         when koszty_g2 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_d;
                state <= SEND_UPPER;    
         if(licznik_d/=x"39" and char_no=26) then
                   next_state<= return_home;
         else
                next_state<= koszty_g3;
         end if;
                  
         when koszty_g3 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_s;
                state <= SEND_UPPER;    
         if(licznik_s/=x"39" and char_no=25) then
                   next_state<= return_home;
         else
                 next_state<= koszty_g;
         end if;    
           when koszty_d =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_j;
                state <= SEND_UPPER;    
         if(licznik_j=x"39" and char_no=27) then
                   next_state<=koszty_d2 ;
         else
                 next_state<= return_home;
         end if;  
         
         when koszty_d2 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_d;
                state <= SEND_UPPER;    
         if(licznik_d/=x"39" and char_no=26) then
                   next_state<= return_home;
         else
                   next_state<= koszty_d3;
         end if;
                  
         when koszty_d3 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_s;
                state <= SEND_UPPER;    
         if(licznik_s/=x"39" and char_no=25) then
                   next_state<= return_home;
         else
                 next_state<= koszty_d;
         end if;    
           when koszty_b =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_j;
                state <= SEND_UPPER;    
         if(licznik_j=x"38" and char_no=27) then
                   next_state<=koszty_b2 ;
         else
                 next_state<= return_home;
         end if;  
         
         when koszty_b2 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_d;
                state <= SEND_UPPER;    
         if(licznik_d/=x"39" and char_no=26) then
                next_state<= return_home;
         else
                next_state<= koszty_b3;
         end if;
                  
         when koszty_b3 =>
                LCD_RS <= '1';
                LCD_E <= '1';
                data_bus_value<=licznik_s;
                state <= SEND_UPPER;    
         if(licznik_s/=x"39" and char_no=25) then
                   next_state<= return_home;
         else
                 next_state<= koszty_b;
         end if;   
           when DISPLAY_CLEAR1 =>
               LCD_RS <= '0';
               LCD_E<='0';
               DATA_BUS_VALUE <= "00000001";-- Display clear
               state <= SEND_UPPER;
               next_state <= init1; 
         
            when others =>
               state <= next_state;
                           
         end case;
      end if;
     
   end process;

dioda<='1' when stop='1' else '0';  

 
 
  
   end Behavioral;