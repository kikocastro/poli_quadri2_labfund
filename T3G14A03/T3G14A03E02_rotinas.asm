; Importa constantes
;
LOAD        <
WRITE       < 
SUBTRACT    <

CONST_0     <                 
CONST_1     <                 
CONST_2     <                 
CONST_7     <                 
CONST_9     <                 
CONST_10    <                
CONST_30    <                
CONST_40    <                
CONST_47    <                
CONST_80    <                
CONST_100   <               
CONST_1000  <              
CONST_8000  <              
CONST_FFFF  <        

RANGE_START <
RANGE_END   <
; 
; Entradas e saidas
;
INPUT_1_PTR >
INPUT_2_PTR >
INPUT_3_PTR >

OUTPUT_1    <
OUTPUT_2    <
OUTPUT_3    <
;
; Rotinas
;
PACK        >
UNPACK      >
MEMCPY      >
CHTOI       >
HALF_PACK   >
;
& /0000 ; Origem relocavel
;
INPUT_1_PTR    K /0000 ; Endereco da entrada 1
INPUT_2_PTR    K /0000 ; Endereco da entrada 2
INPUT_3_PTR    K /0000 ; Endereco da entrada 3
;
; Rotinas
;
; ###################################
; PACK
; ###################################
;
; Variaveis
;
SUM                 K /0000
;
; Rotina 
;
PACK                K  /0000
                    LD INPUT_1_PTR ; carrega valor do endereco contido em INPUT_1_PTR 
                    MM TARGET_ADDRESS
                    SC LOAD_VALUE ; Carrega valor de PACK_INPUT_1
                    *  CONST_100 ; Realiza shift de duas casa para esquerda
                    MM SUM ; armazena valor em SUM
                    LD INPUT_2_PTR ; carrega valor do endereco contido em PACK_INPUT_2 
                    MM TARGET_ADDRESS
                    SC LOAD_VALUE ; Carrega valor de PACK_INPUT_2 
                    +  SUM ; soma PACK_INPUT_1 + PACK_INPUT_2
                    MM OUTPUT_1 ; armazena na saida
                    RS PACK ; Fim da sub rotina
;
;
; ###################################
; UNPACK
; ###################################
;
; Variaveis
;
TEMP                K  /0000
UNPACK_INPUT        K  /0000
;
; Rotina
;
UNPACK              K  /0000
                    ; Carrega valor do endereco apontado por INPUT_1_PTR
                    LD INPUT_1_PTR ; Carrega endereco contido em INPUT_1_PTR
                    MM TARGET_ADDRESS
                    SC LOAD_VALUE ; Carrega conteudo de entrada de UNPACK
                    MM UNPACK_INPUT ; Salva na variavel local
                    + CONST_8000 ; soma 8000
                    JN POSITIVE_CASE ; Caso < 0, o numero é positivo
                    ; caso negativo [ex: F123. Atualmente: F123 + 8000 = 7123]
NEGATIVE_CASE       / CONST_100 ; sem o sinal negativo com shift a direita [71]
                    MM TEMP ; Armazena na variavel temp
                    ; Parte XY
                    + CONST_80 ; soma 80 para devolver o bit de sinal negativo [F1]
                    MM OUTPUT_1 ; Armazena valor 00XY
                    ; Parte ZT
                    LD TEMP ; Carrega valor em temp [71]
                    * CONST_100 ; Shift para esquerda [7100]
                    MM TEMP ; Salva em temp
                    LD UNPACK_INPUT ; Carrega valor inicial
                    + CONST_8000 ; [F123 + 8000 = 7123] 
                    - TEMP ; Obtem 00ZT [7123 - 7100 = 23]
                    MM OUTPUT_2 ; Armazena 00 ZT em OUTPUT_2
                    RS UNPACK ; END da sub rotina
                    ; Caso positivo
                    ; Parte XY
POSITIVE_CASE       LD UNPACK_INPUT ; Carrega valor inicial
                    / CONST_100 ; Realiza shift de duas casa para direita
                    MM OUTPUT_1 ; Salva em OUTPUT_1 00XY
                    ; Parte ZT
                    * CONST_100 ; Realiza shift de duas casa para esquerda, obtendo XY00
                    MM TEMP ; Salva valor temporario
                    LD UNPACK_INPUT ; Carrega valor inicial
                    - TEMP ; Realiza XYZT - XY00 obtendo ZT
                    MM OUTPUT_2 ; Salva resultado
                    RS UNPACK ; END da sub rotina
;
;
; ###################################
; MEMCPY
; ###################################
;
; Variaveis
;
COUNT                   K       /0000
MEMCPY_ORIGIN           K       /0000
MEMCPY_DESTINATION      K       /0000
MEMCPY_SIZE             K       /0000
;
; Rotina
;
MEMCPY                  K       /0000
                        ; Carrega valores de entrada
                        LD      INPUT_1_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC1 ; Armazena em UNPACK_EXEC1
UNPACK_EXEC1            K       /0000 ; Carrega valor do endereço
                        MM      MEMCPY_ORIGIN ; Armazena
                        LD      INPUT_2_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC2 ; Armazena em UNPACK_EXEC2
UNPACK_EXEC2            K       /0000 ; Carrega valor do endereço
                        MM      MEMCPY_DESTINATION ; Armazena
                        LD      INPUT_3_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC3 ; Armazena em UNPACK_EXEC3
UNPACK_EXEC3            K       /0000 ; Carrega valor do endereço
                        MM      MEMCPY_SIZE ; Armazena
                        ; Tratamento de erros de Input
                        ; 1) Endereço inicial + o numero de palavras > endereço maximo
                        LD      RANGE_END   ; Carrega o endereço maximo de destino
                        -       MEMCPY_SIZE
                        -       MEMCPY_SIZE ; Subtrai numero de enderecos de words que serao copiadas (Duas vezes pois cada palavra ocupa 2 Bytes)
                        -       MEMCPY_DESTINATION  ; Subtrai o endereço inicial do destino
                        JN      END_FAIL  ; Caso o endereço inicial + o numero de palavras > endereço maximo, ERRO
                        ; 2) Endereço de destino esta antes do intervalo
                        LD      MEMCPY_DESTINATION
                        -       RANGE_START   
                        JN      END_FAIL  
                        ; 3) Origem esta antes do intervalo
                        LD      MEMCPY_ORIGIN
                        -       RANGE_START
                        JN      END_FAIL   
                        ; 4) Origem esta a frente do intervalo
                        LD      RANGE_END
                        -       MEMCPY_ORIGIN
                        -       MEMCPY_SIZE
                        -       MEMCPY_SIZE
                        JN      END_FAIL  
                        ; Comeco de MEMCPY
LOOP                    LD      MEMCPY_SIZE ; Carrega o numero de words no acumulador
                        -       COUNT     ; Subtrai o contador do acumulador
                        JZ      END_SUCCESS ; Caso o contador seja igual ao numero de words, encerra
                        
                        LD      MEMCPY_DESTINATION ; Carrega endereco de destino
                        +       WRITE   ; Adiciona comando MM
                        MM      MEMCPY_EXEC   ; Armazena em MEMCPY_EXEC
                        
                        LD      MEMCPY_ORIGIN ; Carrega endereço de origem
                        MM      TARGET_ADDRESS 
                        SC      LOAD_VALUE ; Carrega valor no endereco de origem

MEMCPY_EXEC             K       /0000 ; Armazena o valor no endereco de destino
                        LD      MEMCPY_DESTINATION  ; Carrega o endereço de destino
                        +       CONST_2   ; Avança 2 posições na memoria
                        MM      MEMCPY_DESTINATION  ; Atualiza MEMCPY_DESTINATION
                        
                        LD      MEMCPY_ORIGIN ; Carrega o endereço de origem
                        +       CONST_2   ; Avança 2 posições na memoria
                        MM      MEMCPY_ORIGIN ; Atualiza MEMCPY_ORIGIN
                        
                        LD      COUNT     ; Carrega o contador no acumulador
                        +       CONST_1     ; Soma 1
                        MM      COUNT     ; Atualiza CONT
                        
                        JP      LOOP

END_SUCCESS             LD      CONST_0   ; Se o programa finalizar com sucesso, coloca 0x0000 no acumulador
                        JP      RETURN_MEMCPY 
END_FAIL                LD      CONST_FFFF ; Se o programa finalizar com falhas, coloca 0xFFFF no acumulador
          
RETURN_MEMCPY           RS      MEMCPY
;
;
; ###################################
; LOAD_VALUE
; ###################################
;
; Subrotina para carregar um valor que esta no endereço TARGET_ADDRESS
;
; Variaveis
;
TARGET_ADDRESS  K /0000 ; Endereço em que esta o valor desejado
;
; Rotina
;
LOAD_VALUE      K /0000
                LD TARGET_ADDRESS ; carrega o endereço
                + LOAD ; Soma load
                MM EXEC_LOAD ; Armazena em EXEC_LOAD
EXEC_LOAD       K /0000 ; Carrega valor do endereço
                RS LOAD_VALUE ; END da sub rotina
;
;
; ###################################
; CHTOI
; ###################################
;
; Converte duas words contendo caracteres ASCII hexadecimais para o numero 
; inteiro correspondente. [exemplo: entram 3739 e 4142 e sai 79AB]
;
; Variaveis
;
CHTOI_INPUT_1_PTR       K /0000
CHTOI_INPUT_2_PTR       K /0000
UNPACKED_TEMP_1         K /0000
UNPACKED_TEMP_2         K /0000
;
; Rotina
;
CHTOI                   K       /0000

                        LD      INPUT_1_PTR ; Carrega endereco da primeira word
                        MM      CHTOI_INPUT_1_PTR ; Armazena localmente
                        LD      INPUT_2_PTR ; Carrega endereco da segunda word
                        MM      CHTOI_INPUT_2_PTR ; Armazena localmente
                        
                        ; Primeira word
                        LD      CHTOI_INPUT_1_PTR
                        MM      CHTOI_TEMP_WORD ; Salva endereco na variavel
                        SC      CHTOI_PROCESS_WORD ; Chama sub rotina que processa a palavra
                        MM      UNPACKED_TEMP_1 ; Armazena na variavel local
                            
                        ; Verifica se houve erro
                        -       CONST_FFFF 
                        JZ      CHTOI_ERROR
                           
                        ; Segunda word
                        LD      CHTOI_INPUT_2_PTR ; Carrega endereco da segunda word
                        MM      CHTOI_TEMP_WORD ; Salva endereco na variavel
                        SC      CHTOI_PROCESS_WORD ; Chama sub rotina que processa a palavra
                        MM      UNPACKED_TEMP_2 ; Armazena na variavel local
                            
                        ; Verifica se houve erro
                        -       CONST_FFFF 
                        JZ      CHTOI_ERROR
                        
                        ; PACK
                        LV      UNPACKED_TEMP_1 ; Carrega endereco da primeira word
                        MM      INPUT_1_PTR ; Armazena na variavel de PACK
                        LV      UNPACKED_TEMP_2 ; Carrega endereco da segunda word
                        MM      INPUT_2_PTR ; Armazena na variavel de PACK
                        SC      PACK ; Chama rotina
                        LD      OUTPUT_1 ; Carrega resultado
                        JP      END_CHTOI ; Encerra rotina
                        
CHTOI_ERROR             LD      CONST_FFFF ; Carrega valor de erro
                        
END_CHTOI               RS      CHTOI ; END da sub rotina
;
;
;
; ###################################
; CHTOI_PROCESS_WORD
; ###################################
;
; Sub rotina de CHTOI que recebe uma palavra em ASCII, chama UNPACK, processa e devolve o numero interio de cada
;
;
CHTOI_TEMP_WORD             K       /0000
CHTOI_TEMP_1                K       /0000
CHTOI_TEMP_2                K       /0000

CHTOI_PROCESS_WORD          K       /0000
                            LD      CHTOI_TEMP_WORD ; Carrega endereco da palavra
                            MM      INPUT_1_PTR ; Armazena na entrada de UNPACK
                            SC      UNPACK ; Chama rotina UNPACK [exemplo: 4132]    
                            
                            LD      OUTPUT_1 ; Carrega primeira metade [0041]
                            MM      CHTOI_TEMP_1 ; Armazena na variavel
                            LD      OUTPUT_2 ; Carrega segunda metade [0041]
                            MM      CHTOI_TEMP_2 ; Armazena na variavel
                            
                            ; inicio do processamento mas duas metades obtidas com UNPACK
                            
                            ; primeira metade
                            LD      CHTOI_TEMP_1 ; Carrega primeira metade [0041]
                            MM      CHTOI_TEMP_CHAR ; Armazena na variavel da sub rotina CHTOI_PROCESS_CHAR
                            SC      CHTOI_PROCESS_CHAR ; Chama sub rotina CHTOI_PROCESS_CHAR e recebe de volta a letra [000A]
                            MM      CHTOI_TEMP_1 ; Armazena na variavel
                            
                            ; Verifica se houve erro
                            -       CONST_FFFF 
                            JZ      CHTOI_PROCESS_WORD_ERROR
                           
                            ;segunda metade
                            LD      CHTOI_TEMP_2 ; Carrega segunda metade [0032]
                            MM      CHTOI_TEMP_CHAR ; Armazena na variavel
                            SC      CHTOI_PROCESS_CHAR ; Chama sub rotina e recebe o numero [0002]
                            MM      CHTOI_TEMP_2 ; Armazena na variavel
                            
                            ; Verifica se houve erro
                            -       CONST_FFFF 
                            JZ      CHTOI_PROCESS_WORD_ERROR
                            
                            ; Inicio da juncao das duas metades [000A e 0002 viram 00A2]
                            LV      CHTOI_TEMP_1 ; Carrega endereco da primeira metade
                            MM      INPUT_1_PTR ; Armazena na variavel de HALF_PACK [000A]
                            LV      CHTOI_TEMP_2 ; Carrega endereco da segunda metade
                            MM      INPUT_2_PTR ; Armazena na variavel de HALF_PACK [0002]
                            SC      HALF_PACK ; Chama sub rotina [obtem 00A2]
                            LD      OUTPUT_1 ; Carrega resultado
                            JP      END_CHTOI_PROCESS_WORD
                        
CHTOI_PROCESS_WORD_ERROR    LD      CONST_FFFF ; Carrega valor de erro 
                        
END_CHTOI_PROCESS_WORD      RS      CHTOI_PROCESS_WORD 
;
;
; ###################################
; CHTOI_PROCESS_CHAR
; ###################################
;
; Sub rotina de CHTOI que recebe uma metade de palavra ASCII [ se palavra original XYZT, recebe 00XY]
; e devolve o inteiro correspondente
;
;
CHTOI_TEMP_CHAR             K       /0000

CHTOI_PROCESS_CHAR          K       /0000
                            LD      CHTOI_TEMP_CHAR ; Carrega valor  [exemplo: 0041]
                            ; Verificacao de char fora dos intervalos [30,39] ou [41,46]
                            ; < 30
                            -       CONST_30
                            JN      CHTOI_PROCESS_CHAR_ERROR
                            ; x == 40
                            LD      CHTOI_TEMP_CHAR ; Carrega valor
                            -       CONST_40
                            JZ      CHTOI_PROCESS_CHAR_ERROR
                            ; x > 46
                            LD      CHTOI_TEMP_CHAR ; Carrega valor
                            -       CONST_47
                            JN      VALID_INPUT ; Se negativo, é valido
                            JP      CHTOI_PROCESS_CHAR_ERROR  ; Caso contrario da erro
                            
                            ; Caso positivo, continua
VALID_INPUT                 LD      CHTOI_TEMP_CHAR ; Carrega valor  [exemplo: 0041]
                            -       CONST_30 ; Subtrai 30 para encontrar o valor inteiro [0011]
                            MM      CHTOI_TEMP_CHAR ; Armazena em variavel temporaria
                            -       CONST_10 ; CHTOI_TEMP_CHAR - 10
                            JN      IS_NUMBER ; Se negativo, trata-se de um numero, caso contrario letra de A a F
                            
IS_CHAR                     LD      CHTOI_TEMP_CHAR ; Carrega o valor de char [0011]
                            LD      CHTOI_TEMP_CHAR ; [0011]
                            -       CONST_7 ; subtrai 7 para encontrar a letra hexadecimal [000A]
                            JP      END_CHTOI_PROCESS_CHAR ; Encerra
                        
IS_NUMBER                   LD      CHTOI_TEMP_CHAR ; carrega o numero
                            JP      END_CHTOI_PROCESS_CHAR
                        
CHTOI_PROCESS_CHAR_ERROR    LD      CONST_FFFF ; Carrega erro

END_CHTOI_PROCESS_CHAR      RS      CHTOI_PROCESS_CHAR    

; ###################################
; HALF_PACK
; ###################################
;
; Recebe as entradas 000X e 000Y e retorna 00XY
;
; Variaveis
;
HALF_PACK_PARTIAL_SUM   K /0000
;
; Rotina 
;
HALF_PACK               K  /0000
                        LD INPUT_1_PTR ; carrega valor do endereco contido em INPUT_1_PTR 
                        MM TARGET_ADDRESS
                        SC LOAD_VALUE ; Carrega valor de HALF_PACK_INPUT_1
                        *  CONST_10 ; Realiza shift de uma casa para esquerda
                        MM HALF_PACK_PARTIAL_SUM ; armazena valor em HALF_PACK_PARTIAL_SUM
                        
                        LD INPUT_2_PTR ; carrega valor do endereco contido em HALF_PACK_INPUT_2 
                        MM TARGET_ADDRESS
                        SC LOAD_VALUE ; Carrega valor de HALF_PACK_INPUT_2 
                        +  HALF_PACK_PARTIAL_SUM ; soma HALF_PACK_INPUT_1 + HALF_PACK_INPUT_2
                        MM OUTPUT_1 ; armazena na saida
                        
                        RS HALF_PACK ; Fim da sub rotina
;
; Ponteiros de entrada
OUTPUT_1_PTR    K /0000 ; Endereco da entrada 1
OUTPUT_2_PTR    K /0000 ; Endereco da entrada 2
OUTPUT_3_PTR    K /0000 ; Endereco da entrada 3
;
;

# PACK