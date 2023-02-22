library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.cache_type.all;

entity cache_fsm is
  port( CLK  : in std_logic;
        RESET : in std_logic;
        
        EN    : in std_logic;
        RW    : in std_logic; -- 0 for Rd, 1 for Wr
        ADDR  : in std_logic_vector(9 downto 0);
        WDATA : in std_logic_vector(15 downto 0);
        RDATA : out std_logic_vector(15 downto 0);
        BUSY  : out std_logic;
        
        CACHE_EN   : out std_logic;
        CACHE_RW   : out std_logic; -- 0 for Rd, 1 for Wr
        CACHE_ADDR : out integer; -- Index for direct-mapped cache
        CACHE_WBLK : out cache_blk;
        CACHE_RBLK : in cache_blk;
        CACHE_BUSY : in std_logic;
        
        MEM_EN    : out std_logic;
        MEM_RW    : out std_logic; -- 0 for Rd, 1 for Wr
        MEM_ADDR  : out std_logic_vector(9 downto 0);
        MEM_WDATA : out std_logic_vector(15 downto 0);
        MEM_RDATA : in std_logic_vector(15 downto 0);
        MEM_BUSY  : in std_logic;
        
        HIT : out std_logic;
        MISS : out std_logic );
end cache_fsm;

architecture behavioral of cache_fsm is
  
  component memory_system is
    port( CLK   : in std_logic;
          RESET : in std_logic;
          EN    : in std_logic;
          RW    : in std_logic; -- 0 for Rd, 1 for Wr
          ADDR  : in std_logic_vector(9 downto 0);
          WDATA : in std_logic_vector(15 downto 0);
          RDATA : out std_logic_vector(15 downto 0);
          BUSY  : out std_logic );
  end component memory_system;
  
  signal word0 : std_logic_vector(15 downto 0);
  signal word1 : std_logic_vector(15 downto 0);
  signal blk : cache_blk;
  
  type fsm_states_t is (
    st_Idle,
    st_CompareTag,
    st_WriteBackWord0,
    st_WriteBackWord1,
    st_AllocateWord0,
    st_AllocateWord1
  );
  signal pstate, nstate : fsm_states_t;
  
begin
  
  HIT <= '1' when ( pstate = st_CompareTag and CACHE_RBLK.valid = '1' and CACHE_RBLK.tag = ADDR(9 downto 3) ) else '0'; -- defining tag bits from the address 
  
  MISS <= '1' when ( ( pstate = st_CompareTag and CACHE_RBLK.valid = '0' ) or
                     ( pstate = st_CompareTag and CACHE_RBLK.valid = '1' and CACHE_RBLK.tag /= ADDR(9 downto 3) ) ) else '0'; -- defining tag bits from the address
  
  state_reg: process( CLK, RESET )
  begin
    if( RESET = '1' ) then
      pstate <= st_Idle;
    elsif( rising_edge(CLK) ) then
      pstate <= nstate;
    end if;
  end process state_reg;
  
  ns_out_logic: process( pstate, EN, MEM_RDATA, CACHE_RBLK  )
  begin
      case pstate is
        when st_Idle =>
          if( EN = '1' ) then
            nstate <= st_CompareTag;
            
            RDATA <= (others => 'Z');
            BUSY <= '1';
            
            -- Start process of reading the cache
            CACHE_EN <= '1'; -- Reading from cache i.e. some process s getting started for cache so cache enable will be high
            CACHE_RW <= '0'; -- As mentioned earlier for read operation RW is 0
            CACHE_ADDR <= to_integer(unsigned(ADDR(2 downto 1))); --defing cache index (already given explanation for it)
            CACHE_WBLK <= hiZ_blk;
            
            blk <= CACHE_RBLK;
            
            MEM_EN <= '0';
            MEM_RW <= '0';
            MEM_ADDR <= (others => '0');
            MEM_WDATA <= (others => 'Z');
            
          else -- if EN = '0'
            nstate <= st_Idle;
            
            RDATA <= (others => 'Z');
            BUSY <= '0';
            
            CACHE_EN <= '0';
            CACHE_RW <= '0';
            CACHE_ADDR <= 0;
            CACHE_WBLK <= hiZ_blk;
            
            MEM_EN <= '0';
            MEM_RW <= '0';
            MEM_ADDR <= (others => '0');
            MEM_WDATA <= (others => 'Z');
            
          end if;
          
        when st_CompareTag =>
          if( blk.valid = '1' and blk.tag = ADDR(9 downto 3) ) then -- tag bits
            -- Cache Hit :D
            nstate <= st_Idle;
            
            BUSY <= '0';
            
            if( RW = '0' ) then
              -- Read hit
              case ADDR(0) is
                when '0' =>
                  RDATA <= blk.word0;
                when '1' =>
                  RDATA <= blk.word1;
                when others =>
                  RDATA <= (others => 'X');
              end case;
              
              CACHE_EN <= '0';
              CACHE_RW <= '0';
              CACHE_ADDR <= 0;
              CACHE_WBLK <= hiZ_blk;
              
            else
              -- Write hit
              RDATA <= (others => 'Z');
              
              CACHE_EN <= '1';
              CACHE_RW <= '1';
              CACHE_ADDR <= to_integer(unsigned(ADDR(2 downto 1))); -- cache index as explained earlier
              case ADDR(0) is
                when '0' =>
                  CACHE_WBLK <= ( valid => '1', dirty => '1', tag => blk.tag,
                                  word0 => WDATA, word1 => blk.word1 );
                when '1' =>
                  CACHE_WBLK <= ( valid => '1', dirty => '1', tag => blk.tag,
                                  word0 => blk.word0, word1 => WDATA );
                when others =>
                  CACHE_WBLK <= hiZ_blk;
              end case;              
            end if;
            
            MEM_EN <= '0';
            MEM_RW <= '0';
            MEM_ADDR <= (others => '0');
            MEM_WDATA <= (others => 'Z');
            
          elsif( blk.valid = '1' and blk.dirty = '1' ) then
            -- Conflict Miss, and need to write-back dirty block :(
            nstate <= st_WriteBackWord0;
            
            RDATA <= (others => 'Z');
            BUSY <= '1';
            
            CACHE_EN <= '0';
            CACHE_RW <= '0';
            CACHE_ADDR <= 0;
            CACHE_WBLK <= hiZ_blk;
            
            -- Start with write back of word 0
            MEM_EN <= '1'; -- write back to memory, so memory enable will be high
            MEM_RW <= '1'; -- for write operation RW is 1
            MEM_ADDR <= blk.tag & ADDR(2 downto 1) & '0'; -- gettng memory address from the corresponding tag, index and offset respectively
            MEM_WDATA <= blk.word0;
            
          else
            -- Either a compulsory miss (valid = 0) or a conflict miss with dirty = 0 (no write-back) :/
            nstate <= st_AllocateWord0;
            
            BUSY <= '1';
            
            CACHE_EN <= '0';
            CACHE_RW <= '0';
            CACHE_ADDR <= 0;
            CACHE_WBLK <= hiZ_blk;
            
            if( RW = '1' and ADDR = (ADDR(9 downto 1) & '0') ) then
              -- Must write word 0
              --   Prepare new value to go to cache block's word 0
              MEM_EN <= '1';
              MEM_RW <= '1';
              MEM_ADDR <= (others => '0');
              MEM_WDATA <= (others => 'Z');
              
              word0 <= WDATA;
              RDATA <= (others => 'Z');
              
            else
              -- Must read word 0
              --   Read value from memory and prepare it for cache block's word 0
              MEM_EN <= '1'; -- reading value from memory hence memory enable has to be high
              MEM_RW <= '0'; -- for read operation RW is 0 as deifned earlier in vhdl files
              MEM_ADDR <= ADDR(9 downto 1) & '0';
              MEM_WDATA <= (others => 'Z');
              
              word0 <= MEM_RDATA;
              if( RW = '0' and ADDR = (ADDR(9 downto 1) & '0') ) then
                -- This is a read operation of this word (word 0)
                --   Go ahead and output the result of the read
                RDATA <= MEM_RDATA;
              else
                RDATA <= (others => 'Z');
              end if;
            end if;
          end if;
          
        when st_WriteBackWord0 =>
          nstate <= st_WriteBackWord1;
          
          RDATA <= (others => 'Z');
          BUSY <= '1';
          
          CACHE_EN <= '0';
          CACHE_RW <= '0';
          CACHE_ADDR <= 0;
          CACHE_WBLK <= hiZ_blk;
          
          -- Start with write back of word 1
          MEM_EN <= '1'; -- write back to mmemory, hence memory has to do some operation hence memory enable has to be high
          MEM_RW <= '1'; -- for write RW is 1.
          MEM_ADDR <= blk.tag & ADDR(2 downto 1) & '1'; -- see comment for line number 180.
          MEM_WDATA <= blk.word1;
          
        when st_WriteBackWord1 =>
          -- This is similar to starting to allocate the cache block in the Compare Tag state
          nstate <= st_AllocateWord0;
          
          BUSY <= '1';
          
          CACHE_EN <= '0';
          CACHE_RW <= '0';
          CACHE_ADDR <= 0;
          CACHE_WBLK <= hiZ_blk;
          
          if( RW = '1' and ADDR = (ADDR(9 downto 1) & '0') ) then
            -- Must write word 0
            --   Prepare new value to go to cache block's word 0
            MEM_EN <= '0';
            MEM_RW <= '0';
            MEM_ADDR <= (others => '0');
            MEM_WDATA <= (others => 'Z');
            
            word0 <= WDATA;
            RDATA <= (others => 'Z');
            
          else
            -- Must read word 0
            --   Read value from memory and prepare it for cache block's word 0
            MEM_EN <= '1'; -- reading value from memory, that means we need to enable the memory, hence MEM_EN has to be high
            MEM_RW <= '0' ; -- for read RW is 0 
            MEM_ADDR <= ADDR(9 downto 1) & '0';
            MEM_WDATA <= (others => 'Z');
            
            word0 <= MEM_RDATA;
            if( RW = '0' and ADDR = (ADDR(9 downto 1) & '0') ) then
              -- This is a read operation of this word (word 0)
              --   Go ahead and output the result of the read
              RDATA <= MEM_RDATA;
            else
              RDATA <= (others => 'Z');
            end if;
          end if;
          
        when st_AllocateWord0 =>
          nstate <= st_AllocateWord1;
          
          BUSY <= '1';
          
          CACHE_EN <= '0';
          CACHE_RW <= '0';
          CACHE_ADDR <= 0;
          CACHE_WBLK <= hiZ_blk;
          
          if( RW = '1' and ADDR = (ADDR(9 downto 1) & '1') ) then
            -- Must write word 1
            --   Prepare new value to go to cache block's word 1
            MEM_EN <= '0';
            MEM_RW <= '0';
            MEM_ADDR <= (others => '0');
            MEM_WDATA <= (others => 'Z');
            
            word1 <= WDATA;
            
          else
            -- Must read word 1
            --   Read value from memory and prepare it for cache block's word 1
            MEM_EN <= '1'; -- see comment for line 266
            MEM_RW <= '0' ; -- see comment for line 267
            MEM_ADDR <= ADDR(9 downto 1) & '1';
            MEM_WDATA <= (others => 'Z');
            
            word1 <= MEM_RDATA;
            if( RW = '0' and ADDR = (ADDR(9 downto 1) & '1') ) then
              -- This is a read operation of this word (word 1)
              --   Go ahead and output the result of the read
              RDATA <= MEM_RDATA;
            end if;
          end if;
          
        when st_AllocateWord1 =>
          nstate <= st_Idle;
          
          BUSY <= '0';
          
          -- Finish allocating the cache block; write the new block into the cache
          CACHE_EN <= '1'; -- write the new block into the cache, so cache need to be enabled, hence CACHE_EN has to high
          CACHE_RW <= '1'; -- for write RW is 1
          CACHE_ADDR <= to_integer(unsigned(ADDR(2 downto 1))); -- defining cache index
          CACHE_WBLK <= ( valid => '1', dirty => RW, tag => ADDR(9 downto 3), word0 => word0, word1 => word1 ); -- defing tag bits
          
          MEM_EN <= '0';
          MEM_RW <= '0';
          MEM_ADDR <= (others => '0');
          MEM_WDATA <= (others => 'Z');
          
        when others => -- Should not get here
          nstate <= st_Idle;
          
          RDATA <= (others => 'Z');
          BUSY <= '0';
          
          CACHE_EN <= '0';
          CACHE_RW <= '0';
          CACHE_ADDR <= 0;
          CACHE_WBLK <= hiZ_blk;
          
          MEM_EN <= '0';
          MEM_RW <= '0';
          MEM_ADDR <= (others => '0');
          MEM_WDATA <= (others => 'Z');
          
      end case;
  end process ns_out_logic;
  
end behavioral;
