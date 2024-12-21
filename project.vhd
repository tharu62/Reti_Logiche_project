library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port(
    
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_done  : out std_logic;  
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in std_logic_vector(7 downto 0);
        o_mem_data  : out std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
        
    );
end project_reti_logiche;

architecture prl_arch of project_reti_logiche is
    signal c_line : std_logic_vector(7 downto 0);
    signal select_line : std_logic_vector(2 downto 0);
    signal counter_line : std_logic_vector(10 downto 0);
    
    signal reg_data_enable_line : std_logic;
    signal reg_data_stored_value_line : std_logic_vector(7 downto 0);
    
    signal reg_c_reset_line : std_logic;
    signal reg_c_decrease_line : std_logic;
    
    signal reg_counter_reset_line : std_logic;
    signal reg_counter_increase_line : std_logic;
    
    component FSM is
        port(
            i_clk           : in std_logic;
            i_rst           : in std_logic;
            i_start         : in std_logic;
            i_mem_data      : in std_logic_vector(7 downto 0);
            i_k             : in std_logic_vector(9 downto 0);
            i_counter       : in std_logic_vector(10 downto 0);
            
            o_done          : out std_logic;
            
            o_read_en       : out std_logic;
            o_mem_en        : out std_logic;
            o_mem_we        : out std_logic;
            o_decrease_c        : out std_logic;
            o_reset_c           : out std_logic;
            o_increase_counter  : out std_logic;
            o_reset_counter     : out std_logic;
            o_sel               : out std_logic_vector(2 downto 0)
        );
    end component;
        
    component register_data is
        port(
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_enable : in std_logic;
            i_mem_data : in std_logic_vector(7 downto 0);
                    
            o_stored_value : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component mux_scrittura is
        port(
            i_rst   : in std_logic;
            i_c     : in std_logic_vector(7 downto 0);
            i_data  : in std_logic_vector(7 downto 0);
            i_add   : in std_logic_vector(15 downto 0);
            i_sel   : in std_logic_vector(2 downto 0);
            i_counter : in std_logic_vector(10 downto 0);      
            
            o_mem_addr : out std_logic_vector(15 downto 0);
            o_mem_data : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component register_c is
        Port ( 
            i_clk           : in std_logic;
            i_rst           : in std_logic;
            i_decrease      : in std_logic;
        
            o_c             : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component register_counter is
        Port ( 
            i_clk           : in std_logic;
            i_rst           : in std_logic;
            i_increase      : in std_logic;
            
            o_counter       : out std_logic_vector(10 downto 0)
        );
    
    
    end component;
          
    begin 
        
        fsm_1 : FSM port map(
            i_clk   => i_clk,
            i_rst   => i_rst, 
            i_start => i_start,
            i_mem_data => i_mem_data,
            i_k     => i_k,
            i_counter  => counter_line,
            
            o_done => o_done,
                
            o_read_en   => reg_data_enable_line,
            o_mem_en    => o_mem_en,
            o_mem_we    => o_mem_we,
            o_decrease_c => reg_c_decrease_line,
            o_reset_c  => reg_c_reset_line,
            o_increase_counter  => reg_counter_increase_line,
            o_reset_counter => reg_counter_reset_line,
            o_sel       => select_line
        );
        
        modulo_1 : register_data port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_enable => reg_data_enable_line,
            i_mem_data => i_mem_data,
            
            o_stored_value => reg_data_stored_value_line   
        );
        
       module_2 : register_c port map ( 
            i_clk => i_clk,
            i_rst => reg_c_reset_line,
            i_decrease => reg_c_decrease_line,
            
            o_c => c_line
        );
       
       module_3 : register_counter port map(
            i_clk => i_Clk,
            i_rst => reg_counter_reset_line,
            i_increase => reg_counter_increase_line,
            
            o_counter => counter_line
       );
       
       modulo_4 : mux_scrittura port map(
            i_rst => i_rst,
            i_c => c_line,
            i_data => reg_data_stored_value_line,     
            i_add => i_add,
            i_sel => select_line,
            i_counter => counter_line,
                   
            o_mem_addr => o_mem_addr,
            o_mem_data => o_mem_data
        );
       
end prl_arch;

-- FSM CODE

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity FSM is
port(
        i_clk           : in std_logic;
        i_start         : in std_logic;
        i_rst           : in std_logic;
        i_mem_data      : in std_logic_vector(7 downto 0);
        i_k             : in std_logic_vector(9 downto 0);
        i_counter       : in std_logic_vector(10 downto 0);
        
        o_done              : out std_logic;
        
        o_read_en           : out std_logic;
        o_mem_en            : out std_logic;
        o_mem_we            : out std_logic;
        o_decrease_c        : out std_logic;
        o_reset_c           : out std_logic;
        o_increase_counter  : out std_logic;
        o_reset_counter     : out std_logic;
        o_sel               : out std_logic_vector(2 downto 0)      
    );
end FSM;

architecture fsm_arch of FSM is

    type state_type  is (reset_trigger, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14); 
    signal next_state, current_state: state_type;
    begin 
    
    state_reg: process(i_clk, i_rst) 
    begin 
        if i_rst = '1' then
            current_state <= S0;
        elsif rising_edge(i_clk) then 
            current_state <= next_state; 
        end if; 
    end process;
    
    lambda: process(current_state, i_start) 
    begin 
        
        case current_state is 
            
             when reset_trigger =>       
                if i_rst = '1' then
                    next_state <= S0;
                else
                    next_state <= reset_trigger;
                end if;

            when S0 =>   
                if i_start = '1' then
                    if i_k = "0000000000" then
                        next_state <= S14;
                    else
                        next_state <= S1;  
                    end if;
                else
                    next_state <= S0;
                end if;
                
            when S1 =>
                next_state <= S2;
                
            when S2 =>
                next_state <= S3;    
                    
            when S3 =>
                if i_mem_data = "00000000" then
                    next_state <= S4;
                else
                    next_state <= S9;
                end if;
            
            when S4 => 
                next_state <= S5;
                    
            when S5 =>
                next_state <= S6;        
            
            when S6 =>
                -- se i_counter = i_k allora...
                if (unsigned(i_k) - unsigned(i_counter)) = 0 then
                    next_state <= S14;
                else
                    next_state <= S1;
                end if;
       
            when S7 =>
                next_state <= S8;
            
            when S8 =>
                next_state <= S9;
                
            when S9 =>
                if i_mem_data = "00000000" then
                    next_state <= S11;
                else
                    next_state <= S10;
                end if;   
            
            when S10 =>
                next_state <= S13;
                
            when S11 =>
                next_state <= S12;
                
            when S12 =>
                next_state <= S13;
                
            when S13 =>
                -- se i_counter = i_k allora...
                if (unsigned(i_k) - unsigned(i_counter)) = 0 then
                    next_state <= S14;
                else
                    next_state <= S7;
                end if;
                
            when S14 =>
                if i_start = '1' then
                    next_state <= S14;
                else
                    next_state <= S0;
                end if;
                
        end case;
    end process;
    
    delta: process(current_state) 
    begin 
        case current_state is 
            
            when reset_trigger =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_sel <= "000";
                o_decrease_c <= '0';
                o_reset_c <= '1';
                o_increase_counter <= '0';
                o_reset_counter <= '1';
                
            when S0 => 
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_sel <= "000";
                o_decrease_c <= '0';
                o_reset_c <= '1';
                o_increase_counter <= '0';
                o_reset_counter <= '1';
            
            when S1 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_sel <= "001";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
                
            when S2 =>
                o_done <= '0';
                o_read_en <= '1';
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_sel <= "001";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
            
            when S3 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_sel <= "001";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
            
            when S4 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_sel <= "101";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
                o_increase_counter <= '1';
                o_reset_counter <= '0';
            
            when S5 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_sel <= "101";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
            
            when S6 =>  
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_sel <= "000";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
            
            when S7 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_sel <= "001";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
            
            when S8 =>
                o_done <= '0';
                o_read_en <= '1';
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_sel <= "001";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
                
            when S9 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                o_sel <= "001";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
        
            when S10 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_sel <= "100";
                o_decrease_c <= '0';
                o_reset_c <= '1';
                o_increase_counter <= '1';
                o_reset_counter <= '0';
            
            when S11 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_sel <= "011";
                o_decrease_c <= '1';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0'; 
            
            when S12 =>
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                o_sel <= "010";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '1';
                o_reset_counter <= '0';
            
            when S13 =>  
                o_done <= '0';
                o_read_en <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_sel <= "000";
                o_decrease_c <= '0';
                o_reset_c <= '0';
                o_increase_counter <= '0';
                o_reset_counter <= '0';
                
            when S14 =>
                o_done <= '1';
                o_read_en <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_sel <= "000";
                o_decrease_c <= '0';
                o_reset_c <= '1';
                o_increase_counter <= '0';
                o_reset_counter <= '1'; 
                
        end case;
    end process;
end fsm_arch;

--  reg_data

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_data is
    Port ( 
        i_clk           : in std_logic;
        i_rst           : in std_logic;
        i_enable        : in std_logic;
        i_mem_data      : in std_logic_vector(7 downto 0);
                
        o_stored_value  : out std_logic_vector(7 downto 0)      
    );
end register_data;

architecture Behavioral of register_data is
    signal stored_value : std_logic_vector(7 downto 0) := "00000000";
    begin
    
    o_stored_value <= stored_value;
    
    process(i_rst, i_clk)
    begin
    
    if rising_edge(i_clk) then     
        
        if i_rst = '1' then
        
            stored_value <= "00000000";
        
        else
        
            if i_enable = '1' then
                if i_mem_data /= "00000000" then   
                    stored_value <= i_mem_data;
                end if;
        
            end if; 
        
        end if;
          
    end if;
         
    end process;
end Behavioral;

-- reg_c

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity register_c is
    Port ( 
        i_clk           : in std_logic;
        i_rst           : in std_logic;
        i_decrease      : in std_logic;
        
        o_c             : out std_logic_vector(7 downto 0)
    );
end register_c;

architecture Behavioral of register_c is
    signal c : std_logic_vector(7 downto 0) := "00011111";
    begin
    
    o_c <= c;
    
    process(i_clk)
    begin
        
        if rising_edge(i_clk) then
        
            if i_rst = '1' then
                c <= "00011111";
            elsif i_decrease = '1' and c > "00000000" then
                c <= std_logic_vector(unsigned(c) - 1);
            end if;
                
        end if;
    
    end process;

end Behavioral;

-- reg_counter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity register_counter is
    Port ( 
        i_clk           : in std_logic;
        i_rst           : in std_logic;
        i_increase      : in std_logic;
        
        o_counter       : out std_logic_vector(10 downto 0)
    );
end register_counter;

architecture Behavioral of register_counter is
    signal counter : std_logic_vector(10 downto 0) := (others => '0');
    begin
    
    o_counter <= counter;
    
    process(i_clk)
    begin
    
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                counter <= (others => '0');
            elsif i_increase = '1' then
                counter <= std_logic_vector(unsigned(counter) + 1);
            end if;    
        end if;
        
    end process;

end Behavioral;

-- mux_scrittura

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mux_scrittura is
    Port ( 
        i_rst       : in std_logic;
        i_c         : in std_logic_vector(7 downto 0);
        i_data      : in std_logic_vector(7 downto 0);
        i_add       : in std_logic_vector(15 downto 0);
        i_sel       : in std_logic_vector(2 downto 0);
        i_counter   : in std_logic_vector(10 downto 0);      
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        o_mem_data  : out std_logic_vector(7 downto 0)
    );
end mux_scrittura;

architecture Behavioral of mux_scrittura is
    begin
    process(i_sel, i_rst)
    begin    
            
        if i_rst = '0' then
            case i_sel is
            
            when "000" =>
                o_mem_addr <= (others => '0');
                o_mem_data <= (others => '0');
        
            when "001" =>
                 
                if i_counter /= "00000000000" then
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + shift_left(unsigned(i_counter), 1));
                else
                    o_mem_addr <= std_logic_vector(unsigned(i_add));
                end if;
                o_mem_data <= (others => '0');
                
            when "010" =>
                if i_counter /= "00000000000" then
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + shift_left(unsigned(i_counter), 1) + 1);
                else
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + 1);
                end if;
                o_mem_data <= i_c;
            
            when "011" =>
                if i_counter /= "00000000000" then
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + shift_left(unsigned(i_counter), 1));
                
                else
                    o_mem_addr <= std_logic_vector(unsigned(i_add));
                end if;
                o_mem_data <= i_data;
            
            when "100" =>
                if i_counter /= "00000000000" then
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + shift_left(unsigned(i_counter), 1) + 1);
                else
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + 1);
                end if;
                o_mem_data <= "00011111";
            
            when "101" =>
                if i_counter /= "00000000000" then
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + shift_left(unsigned(i_counter), 1) + 1);
                else
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + 1);
                end if;
                o_mem_data <= (others => '0');
            
            when others =>
                o_mem_addr <= (others => '0');
                o_mem_data <= (others => '0');
    
            end case;
        
        else
            o_mem_addr <= (others => '0');
            o_mem_data <= (others => '0');
        end if;
          
    end process;
   
end Behavioral;
