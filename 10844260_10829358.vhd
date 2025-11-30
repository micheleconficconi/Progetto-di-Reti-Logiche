library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;       


entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
        );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    --variabile enum per gli stati della fsm
    type S is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16);
    signal curr_state: S;

    --contatore per scorrere il numero di parole K1.K2=K
    signal delta_add_seq: std_logic_vector(15 downto 0):= (others => '0'); --sequenziale
    signal delta_add_inc: std_logic_vector(15 downto 0) := (others => '0'); --combinatorio

    --contatore j da 0 a 7 per somme parziali
    signal j_seq: std_logic_vector(2 downto 0):= (others =>'0');
    signal j_inc: std_logic_vector(2 downto 0):= (others =>'0');

    --segnale dove salvare l'ordine del filtro
    signal ORDER : std_logic := '0';
    signal ORDER_seq : std_logic :='0';

    --numero di parole in memoria
    signal k: std_logic_vector(15 downto 0):= (others => '0');
    signal k_seq: std_logic_vector(15 downto 0):= (others => '0');

    --vettori per i coefficienti del filtro
    signal c1: std_logic_vector(7 downto 0):= (others => '0');
    signal c1_seq: std_logic_vector(7 downto 0):= (others => '0');

    signal c2: std_logic_vector(7 downto 0):= (others => '0');
    signal c2_seq: std_logic_vector(7 downto 0):= (others => '0');

    signal c3: std_logic_vector(7 downto 0):= (others => '0');
    signal c3_seq: std_logic_vector(7 downto 0):= (others => '0');

    signal c4: std_logic_vector(7 downto 0):= (others => '0');
    signal c4_seq: std_logic_vector(7 downto 0):= (others => '0');

    signal c5: std_logic_vector(7 downto 0):= (others => '0');
    signal c5_seq: std_logic_vector(7 downto 0):= (others => '0');

    signal c6: std_logic_vector(7 downto 0):= (others => '0');
    signal c6_seq: std_logic_vector(7 downto 0):= (others => '0');

    signal c7: std_logic_vector(7 downto 0):= (others => '0');
    signal c7_seq: std_logic_vector(7 downto 0):= (others => '0');

    --vettori per i prodotti parziali (coefficiente_i*valore_memoria)
    signal p1: std_logic_vector(17 downto 0):= (others => '0');
    signal p1_seq: std_logic_vector(17 downto 0):= (others => '0');

    signal p2: std_logic_vector(17 downto 0):= (others => '0');
    signal p2_seq: std_logic_vector(17 downto 0):= (others => '0');

    signal p3: std_logic_vector(17 downto 0):= (others => '0');
    signal p3_seq: std_logic_vector(17 downto 0):= (others => '0');

    signal p4: std_logic_vector(17 downto 0):= (others => '0');
    signal p4_seq: std_logic_vector(17 downto 0):= (others => '0');

    signal p5: std_logic_vector(17 downto 0):= (others => '0');
    signal p5_seq: std_logic_vector(17 downto 0):= (others => '0');

    signal p6: std_logic_vector(17 downto 0):= (others => '0');
    signal p6_seq: std_logic_vector(17 downto 0):= (others => '0');

    signal p7: std_logic_vector(17 downto 0) := (others => '0');
    signal p7_seq: std_logic_vector(17 downto 0) := (others => '0');

    --valori intermedi per somme parziali
    signal SUM_partial_1: std_logic_vector(17 downto 0) := (others => '0');
    signal SUM_partial_1_seq: std_logic_vector(17 downto 0) := (others => '0');

    signal SUM_partial_2: std_logic_vector(17 downto 0) := (others => '0');
    signal SUM_partial_2_seq: std_logic_vector(17 downto 0) := (others => '0');

    --valore finale delle somme parziali
    signal SUM: std_logic_vector(17 downto 0) := (others => '0');
    signal SUM_seq: std_logic_vector(17 downto 0) := (others => '0');

    --segnali intermedi per gli shift logici
    signal sh1: std_logic_vector(17 downto 0) := (others => '0');
    signal sh1_seq: std_logic_vector(17 downto 0) := (others => '0');

    signal sh2: std_logic_vector(17 downto 0) := (others => '0');
    signal sh2_seq: std_logic_vector(17 downto 0) := (others => '0');

    signal sh3: std_logic_vector(17 downto 0) := (others => '0');
    signal sh3_seq: std_logic_vector(17 downto 0) := (others => '0');
    
    signal sh4: std_logic_vector(17 downto 0) := (others => '0');
    signal sh4_seq: std_logic_vector(17 downto 0) := (others => '0');

    --segnali parziali per gli shift
    signal SUM_SHIFT_partial_1: std_logic_vector(17 downto 0) := (others => '0');
    signal SUM_SHIFT_partial_1_seq: std_logic_vector(17 downto 0) := (others => '0');

    signal SUM_SHIFT_partial_2: std_logic_vector(17 downto 0) := (others => '0');
    signal SUM_SHIFT_partial_2_seq: std_logic_vector(17 downto 0) := (others => '0');

    --segnale finale per il valore shiftato
    signal SUM_SHIFT: std_logic_vector(17 downto 0) := (others => '0');
    signal SUM_SHIFT_seq: std_logic_vector(17 downto 0) := (others => '0');

    --segnali intermedi per gestire gli output verso la memoria
    signal o_done_int: std_logic := '0';
    signal o_done_int_seq: std_logic := '0';

    signal o_mem_data_int : std_logic_vector(7 downto 0) := (others => '0');
    signal o_mem_data_int_seq : std_logic_vector(7 downto 0) := (others => '0');

    signal o_mem_we_int : std_logic := '0';
    signal o_mem_we_int_seq : std_logic := '0';

    signal o_mem_en_int : std_logic := '0';
    signal o_mem_en_int_seq : std_logic := '0'; 

    signal o_mem_addr_int : std_logic_vector(15 downto 0) := (others => '0');
    signal o_mem_addr_int_seq : std_logic_vector(15 downto 0) := (others => '0');
    
    

begin
    --processo che gestisce sequenzialmente i valori e il cambio di stato
    delta_function: process(i_clk, i_rst)
    begin
        --reset dei valori sequenziali
        if i_rst='1' then 
            curr_state<=S1;
            o_mem_data_int_seq <= (others => '0');
            o_mem_addr_int_seq <= (others => '0');
            o_mem_we_int_seq <= '0';
            o_mem_en_int_seq <= '0';
            c1_seq <= (others => '0');
            c2_seq <= (others => '0');
            c3_seq <= (others => '0');
            c4_seq <= (others => '0');
            c5_seq <= (others => '0');
            c6_seq <= (others => '0');
            c7_seq <= (others => '0');
            p1_seq <= (others => '0');
            p2_seq <= (others => '0');
            p3_seq <= (others => '0');
            p4_seq <= (others => '0');
            p5_seq <= (others => '0');
            p6_seq <= (others => '0');
            p7_seq <= (others => '0');
            SUM_seq <= (others => '0');
            SUM_SHIFT_seq <= (others => '0'); 
            ORDER_seq <= '0';
            k_seq <= (others => '0');
            j_seq <= (others => '0');
            delta_add_seq <= (others => '0');
            o_done_int_seq <= '0';
            SUM_partial_1_seq <= (others => '0');
            SUM_partial_2_seq <= (others => '0');
            SUM_SHIFT_partial_1_seq <= (others => '0');
            SUM_SHIFT_partial_2_seq <= (others => '0');
            sh1_seq <= (others => '0');
            sh2_seq <= (others => '0');
            sh3_seq <= (others => '0');
            sh4_seq <= (others => '0');
        elsif(i_clk'event and i_clk='1') then  
            --aggiorna il segnale sequenziale sul fronte di salita con il valore del segnale combinatorio
            o_mem_data_int_seq <= o_mem_data_int;
            o_mem_addr_int_seq <= o_mem_addr_int;
            o_mem_we_int_seq <= o_mem_we_int;
            o_mem_en_int_seq <= o_mem_en_int;
            c1_seq <= c1;
            c2_seq <= c2;
            c3_seq <= c3;
            c4_seq <= c4;
            c5_seq <= c5;
            c6_seq <= c6;
            c7_seq <= c7;
            p1_seq <= p1;
            p2_seq <= p2;
            p3_seq <= p3;
            p4_seq <= p4;
            p5_seq <= p5;
            p6_seq <= p6;
            p7_seq <= p7;
            SUM_seq <= SUM;
            SUM_SHIFT_seq <= SUM_SHIFT; 
            ORDER_seq <= ORDER;
            k_seq <= k;
            j_seq <= j_inc; 
            delta_add_seq <= delta_add_inc;
            o_done_int_seq <= o_done_int;
            SUM_partial_1_seq <= SUM_partial_1;
            SUM_partial_2_seq <= SUM_partial_2;
            SUM_SHIFT_partial_1_seq <= SUM_SHIFT_partial_1;
            SUM_SHIFT_partial_2_seq <= SUM_SHIFT_partial_2;
            sh1_seq <= sh1;
            sh2_seq <= sh2;
            sh3_seq <= sh3;
            sh4_seq <= sh4;
            --logica del cambio di stato
            if(curr_state=S1 and i_rst='0' and i_start='1') then
                curr_state<=S2;
            elsif(curr_state=S1 and i_rst='0' and i_start='0') then
                curr_state<=s1;    
            elsif(curr_state=S2) then --salvare i primi 17 valori della sequenza, se terminati vai in S6
                if(unsigned(delta_add_seq)<=16) then
                    curr_state<=S3;
                else 
                    curr_state<=S6;
                end if;
            elsif(curr_state=S3) then --salva K1, K2, order con S4, poi i coefficienti con S5
                if(unsigned(delta_add_seq)<=2) then
                    curr_state<=S4;    
                else
                    curr_state<=S5;
                end if;     
            elsif(curr_state=S4) then
                curr_state<=S2;
            elsif(curr_state=S5) then
                curr_state<=S2;
            elsif(curr_state=S6) then --se tutte le somme parziali sono state computate vai in S10, altrimenti elabora il prossimo valore da memoria
                if(unsigned(j_seq)<7) then 
                    curr_state<=S7;
                else 
                    curr_state<=S9;
                end if;
            elsif(curr_state=S7) then
                curr_state<=S8;
            elsif(curr_state=S8) then
                curr_state<=S6;
            elsif(curr_state=S9) then
                curr_state<=S10;
            elsif(curr_state=S10) then
                curr_state<=S11;
            elsif(curr_state=S11) then
                curr_state<=S12;
            elsif(curr_state=S12) then
                curr_state<=S13;
            elsif(curr_state=S13) then 
                curr_state<=S14;
            elsif(curr_state=S14) then
                curr_state<=S15;
            elsif(curr_state=S15) then --se non sono state elaborate tutte le K parole torna in S7, altrimenti se i_start è tornato basso vai in S17, altrimenti rimani in attesa
                if((unsigned(delta_add_seq) -16) < (unsigned(K))) then
                    curr_state<=S6;
                elsif(i_start='0') then
                    curr_state<=S16;
                else 
                    curr_state<=S15;
                end if;
            elsif(curr_state=S16) then
                curr_state<=S1;
            else --stato di default
                curr_state<=S0;
            end if;
        end if;
    end process;
    
    
    lambda_function: process(curr_state) 
    begin
       --casi di default per mantenere il segnale e assegnare il valore sequenziale a quello combinatorio
        o_mem_data_int <= o_mem_data_int_seq;
        o_mem_addr_int <= o_mem_addr_int_seq;
        o_mem_we_int <= o_mem_we_int_seq;
        o_mem_en_int <= o_mem_en_int_seq;
        j_inc <= j_seq;
        c1 <= c1_seq;
        c2 <= c2_seq;
        c3 <= c3_seq;
        c4 <= c4_seq;
        c5 <= c5_seq;
        c6 <= c6_seq;
        c7 <= c7_seq;
        p1 <= p1_seq;
        p2 <= p2_seq;
        p3 <= p3_seq;
        p4 <= p4_seq;
        p5 <= p5_seq;
        p6 <= p6_seq;
        p7 <= p7_seq;
        SUM <= SUM_seq;
        SUM_SHIFT <= SUM_SHIFT_seq;
        o_done_int <= o_done_int_seq;
        ORDER <= ORDER_seq;
        k <= k_seq;
        delta_add_inc <= delta_add_seq;
        SUM_partial_1 <= SUM_partial_1_seq;
        SUM_partial_2 <= SUM_partial_2_seq;
        SUM_SHIFT_partial_1 <= SUM_SHIFT_partial_1_seq;
        SUM_SHIFT_partial_2 <= SUM_SHIFT_partial_2_seq;
        sh1 <= sh1_seq;
        sh2 <= sh2_seq;
        sh3 <= sh3_seq;
        sh4 <= sh4_seq;
        --reset dei segnali combinatori
        if (curr_state = S1) then  
            o_done_int <= '0';
            o_mem_data_int <= (others => '0');
            o_mem_addr_int <= (others => '0');
            o_mem_we_int <= '0';
            o_mem_en_int <= '0';
            j_inc <= (others => '0');
            c1 <= (others => '0');
            c2 <= (others => '0');
            c3 <= (others => '0');
            c4 <= (others => '0');
            c5 <= (others => '0');
            c6 <= (others => '0');
            c7 <= (others => '0');
            p1 <= (others => '0');
            p2 <= (others => '0');
            p3 <= (others => '0');
            p4 <= (others => '0');
            p5 <= (others => '0');
            p6 <= (others => '0');
            p7 <= (others => '0');
            SUM <= (others => '0');
            SUM_SHIFT <= (others => '0');
            ORDER <= '0';
            k <= (others => '0');
            delta_add_inc <= (others => '0');
            SUM_partial_1 <= (others => '0');
            SUM_partial_2 <= (others => '0');
            SUM_SHIFT_partial_1 <= (others => '0');
            SUM_SHIFT_partial_2 <= (others => '0');
            sh1 <= (others => '0');
            sh2 <= (others => '0');
            sh3 <= (others => '0');
            sh4 <= (others => '0');

        elsif(curr_state = S2) then --richiesta di lettura alla memoria per i 17 byte di configurazione iniziali
            o_mem_addr_int <= std_logic_vector(unsigned(i_add)+ unsigned(delta_add_seq)); 
            o_mem_we_int <= '0';
            o_mem_en_int <= '1';  

        elsif(curr_state = S4) then --salva K1, K2, Order
            if(unsigned(delta_add_seq) = 0) then
                K (15 downto 8) <= std_logic_vector(unsigned(i_mem_data));
            elsif(unsigned(delta_add_seq)=1) then
                K (7 downto 0) <= std_logic_vector(unsigned(i_mem_data));
            else
                order <= std_logic(i_mem_data(0)); 
            end if;   
            delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);

        elsif(curr_state = S5) then --salva tutti i coefficienti, in base all'ordine del filtro. Se ordine 3 salva i primi 7 e forza delta_add_inc a 17, altrimenti forza delta_add_inc a 10 per salvare i coefficienti di ordine 5                       
            if(order ='0' and unsigned(delta_add_seq)<10) then
                if(unsigned(delta_add_seq)=3) then
                    c1 <= "00000000";
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                elsif(unsigned(delta_add_seq)=4) then
                    c2 <= std_logic_vector(signed(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                elsif(unsigned(delta_add_seq)=5) then
                    c3 <= std_logic_vector(signed(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                elsif(unsigned(delta_add_seq)=6) then
                    c4 <= std_logic_vector(signed(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);   
                elsif(unsigned(delta_add_seq)=7) then
                    c5 <= std_logic_vector(signed(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);   
                elsif(unsigned(delta_add_seq)=8) then
                    c6 <= std_logic_vector(signed(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);  
                elsif(unsigned(delta_add_seq)=9) then
                    c7 <= "00000000";
                    delta_add_inc<="0000000000010001";
                end if;    
            else  
                if(unsigned(delta_add_seq)=3) then
                    delta_add_inc<="0000000000001010";       
                elsif(unsigned(delta_add_seq)=10) then
                    c1 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                elsif(unsigned(delta_add_seq)=11) then
                    c2 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                elsif(unsigned(delta_add_seq)=12) then
                    c3 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                elsif(unsigned(delta_add_seq)=13) then
                    c4 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);   
                elsif(unsigned(delta_add_seq)=14) then
                    c5 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);   
                elsif(unsigned(delta_add_seq)=15) then
                    c6 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);  
                else --if(unsigned(delta_add_seq)=16) then
                    c7 <= std_logic_vector(unsigned(i_mem_data));
                    delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1);
                end if;
            end if;
            o_mem_we_int <= '0';
            o_mem_en_int <= '0';     
        elsif(curr_state=S6) then --richiesta di lettura alla memoria per il prodotto parziale alla (delta_add+j-3)-esima parola
            o_mem_addr_int <=std_logic_vector(unsigned(i_add) + unsigned(delta_add_seq) + unsigned(j_seq) - 3);
            o_mem_we_int<='0';
            o_mem_en_int<='1';    

        elsif(curr_state=S8) then --calcolo del prodotto parziale pi=ci*valore_memoria, con gestione degli estremi della sequenza
            if(unsigned(j_seq) = 0) then
                if(unsigned(delta_add_seq)<=19) then
                    p1<="000000000000000000";
                else    
                    p1<=std_logic_vector(resize(signed(c1_seq) * (signed(i_mem_data)), 18));
                end if;    
            elsif(unsigned(j_seq) = 1) then
                if(unsigned(delta_add_seq)<=18) then
                    p2<="000000000000000000";
                else        
                    p2<=std_logic_vector(resize(signed(c2_seq) * (signed(i_mem_data)), 18));
                end if;    
            elsif(unsigned(j_seq) = 2) then
                if(unsigned(delta_add_seq)=17) then
                    p3<="000000000000000000";
                else    
                    p3<=std_logic_vector(resize(signed(c3_seq) * (signed(i_mem_data)), 18));
                end if;    
            elsif(unsigned(j_seq) = 3) then
                p4<=std_logic_vector(resize(signed(c4_seq) * (signed(i_mem_data)), 18));
            elsif(unsigned(j_seq) = 4) then
                if((unsigned(delta_add_seq) -16) = (unsigned(K))) then 
                    p5<="000000000000000000";
                else    
                    p5<=std_logic_vector(resize(signed(c5_seq) * (signed(i_mem_data)), 18));
                end if;    
            elsif(unsigned(j_seq) = 5) then
                if((unsigned(delta_add_seq) -16) >= (unsigned(K) -1)) then 
                    p6<="000000000000000000";
                else    
                    p6<=std_logic_vector(resize(signed(c6_seq) * (signed(i_mem_data)), 18));
                end if;    
            elsif(unsigned(j_seq) = 6) then              
                if((unsigned(delta_add_seq) -16) >= (unsigned(K)-2)) then 
                    p7<="000000000000000000";
                else    
                    p7<=std_logic_vector(resize(signed(c7_seq) * (signed(i_mem_data)), 18));
                end if;
            end if; 
            j_inc <= std_logic_vector(unsigned(j_seq) + 1);

        elsif(curr_state=S9) then --calcolo parziale della somma dei pi
            SUM_partial_1 <= std_logic_vector(signed(p1_seq) + signed(p2_seq) + signed(p3_seq));
            SUM_partial_2 <= std_logic_vector(signed(p4_seq) + signed(p5_seq) + signed(p6_seq) + signed(p7_seq));

        elsif(curr_state=S10) then --calcolo finale della somma dei pi
            SUM <= std_logic_vector(signed(SUM_partial_1_seq) + signed(SUM_partial_2_seq));

        elsif(curr_state=S11) then --shift logici per approssimare la divisione
            sh1 <= std_logic_vector(shift_right(signed(SUM_seq), 4));
            sh2 <= std_logic_vector(shift_right(signed(SUM_seq), 6));
            sh3 <= std_logic_vector(shift_right(signed(SUM_seq), 8));
            sh4 <= std_logic_vector(shift_right(signed(SUM_seq), 10));

        elsif(curr_state=S12) then --calcolo parziale del valore normalizzato
            SUM_SHIFT_partial_1 <= std_logic_vector(signed(sh1_seq) + signed(sh3_seq));
            SUM_SHIFT_partial_2 <= std_logic_vector(signed(sh2_seq) + signed(sh4_seq));   

        elsif(curr_state=S13) then --calcolo finale del valore normalizzato, con distinzione tra ordine 3/5 e </> 0
            if(order = '0') then --ordine 3
                if(SUM_seq(17) = '0') then --bit piu significativo per distinguere da positivo/negativo
                    SUM_SHIFT <= std_logic_vector(signed(SUM_SHIFT_partial_1_seq) + signed(SUM_SHIFT_partial_2_seq));                                                
                else 
                    SUM_SHIFT <= std_logic_vector(signed(SUM_SHIFT_partial_1_seq) + signed(SUM_SHIFT_partial_2_seq) + 4);                                                
                end if;    
            else --ordine 5
                if(SUM_seq(17) = '0') then
                    SUM_SHIFT <= SUM_SHIFT_partial_2_seq;
                else
                    SUM_SHIFT <= std_logic_vector(signed(SUM_SHIFT_partial_2_seq) + 2);
                end if;
            end if;     

        elsif(curr_state=S14) then --salvare il valore normalizzato in memoria, eventualmente saturando in [-128, +127]
            j_inc <= (others => '0');
            if(signed(SUM_SHIFT_seq) > 127) then
                o_mem_data_int <= "01111111";
            elsif(signed(SUM_SHIFT_seq) < -128) then
                o_mem_data_int <= "10000000";
            else 
                o_mem_data_int <= SUM_SHIFT(7 downto 0);
            end if;
            o_mem_we_int <= '1';
            o_mem_en_int <= '1'; 
            o_mem_addr_int <= std_logic_vector( unsigned(i_add) + unsigned(delta_add_seq) + unsigned(K_seq));

        elsif(curr_state=S15)then --reset dei valori per la computazione delle somme parziali e degli shift. Se la sequenza è finita alzare il segnale di done
            o_mem_we_int <= '0';
            o_mem_en_int <= '0';
            SUM_SHIFT <= (others => '0');
            SUM <= (others => '0');
            sh1 <= (others => '0');
            sh2 <= (others => '0');
            sh3 <= (others => '0');
            sh4 <= (others => '0');
            SUM_partial_1 <= (others => '0');
            SUM_partial_2 <= (others => '0');
            SUM_SHIFT_partial_1 <= (others => '0');
            SUM_SHIFT_partial_2 <= (others => '0');
            if((unsigned(delta_add_seq) -16) = (unsigned(K))) then
                o_done_int <= '1';
            else    
                delta_add_inc <= std_logic_vector(unsigned(delta_add_seq) +1); 
            end if;  

        elsif(curr_state=S16) then --abbassa il segnale di done
            o_done_int <= '0';   

        else --mantieni i valori salvati cosi come sono
            o_mem_data_int <= o_mem_data_int_seq;
            o_mem_addr_int <= o_mem_addr_int_seq;
            o_mem_we_int <= o_mem_we_int_seq;
            o_mem_en_int <= o_mem_en_int_seq;
            j_inc <= j_seq;
            c1 <= c1_seq;
            c2 <= c2_seq;
            c3 <= c3_seq;
            c4 <= c4_seq;
            c5 <= c5_seq;
            c6 <= c6_seq;
            c7 <= c7_seq;
            p1 <= p1_seq;
            p2 <= p2_seq;
            p3 <= p3_seq;
            p4 <= p4_seq;
            p5 <= p5_seq;
            p6 <= p6_seq;
            p7 <= p7_seq;
            SUM <= SUM_seq;
            SUM_SHIFT <= SUM_SHIFT_seq;
            o_done_int <= o_done_int_seq;
            ORDER <= ORDER_seq;
            k <= k_seq;
            delta_add_inc <= delta_add_seq;    
            SUM_partial_1 <= SUM_partial_1_seq;
            SUM_partial_2 <= SUM_partial_2_seq;
            SUM_SHIFT_partial_1 <= SUM_SHIFT_partial_1_seq;
            SUM_SHIFT_partial_2 <= SUM_SHIFT_partial_2_seq;
            sh1 <= sh1_seq;
            sh2 <= sh2_seq;
            sh3 <= sh3_seq;
            sh4 <= sh4_seq;
        end if;                       
    end process;
    
    --aggiornamenti combinatori per interfacciarsi con la memoria
    o_mem_en <= o_mem_en_int;
    o_mem_addr <= o_mem_addr_int;
    o_mem_we <= o_mem_we_int;
    o_mem_data <= o_mem_data_int;
    o_done <= o_done_int;
end architecture;