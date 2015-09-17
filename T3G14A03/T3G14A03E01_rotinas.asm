; Importa constantes
;
LOAD        <
WRITE       < 
CONST_0     <                
CONST_1     <               
CONST_2     <    
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
; PACK
PACK >
PACK_INPUT_1_PTR >
PACK_INPUT_2_PTR >
PACK_OUTPUT <
; 
; UNPACK
UNPACK >
UNPACK_INPUT_PTR >
UNPACK_OUTPUT_1 <
UNPACK_OUTPUT_2 <
;
; MEMCPY
MEMCPY >
MEMCPY_ORIGIN_PTR >
MEMCPY_DESTINATION_PTR >
MEMCPY_SIZE_PTR >
;
& /0000 ; Origem relocavel
;
; Rotinas
;
; ###################################
; PACK
; ###################################
;
; Variaveis
;
PACK_INPUT_1_PTR    K /0000 ; Endereco da entrada 1
PACK_INPUT_2_PTR    K /0000 ; Endereco da entrada 2
SUM                 K /0000
;
; Rotina 
;
PACK                K  /0000
                    LD PACK_INPUT_1_PTR ; carrega valor do endereco contido em PACK_INPUT_1_PTR 
                    MM TARGET_ADDRESS
                    SC LOAD_VALUE ; Carrega valor de PACK_INPUT_1
                    *  CONST_100 ; Realiza shift de duas casa para esquerda
                    MM SUM ; armazena valor em SUM
                    LD PACK_INPUT_2_PTR ; carrega valor do endereco contido em PACK_INPUT_2 
                    MM TARGET_ADDRESS
                    SC LOAD_VALUE ; Carrega valor de PACK_INPUT_2 
                    +  SUM ; soma PACK_INPUT_1 + PACK_INPUT_2
                    MM PACK_OUTPUT ; armazena na saida
                    RS PACK ; Fim da sub rotina
;
;
; ###################################
; UNPACK
; ###################################
;
; Variaveis
;
UNPACK_INPUT_PTR    K  /0000 ; Ponteiro para endereço da entrada
UNPACK_INPUT        K  /0000 ; Endereco de entrada
TEMP                K  /0000
;
; Rotina
;
UNPACK              K  /0000
                    ; Carrega valor do endereco apontado por UNPACK_INPUT_PTR
                    LD UNPACK_INPUT_PTR ; Carrega endereco contido em UNPACK_INPUT_PTR
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
                    MM UNPACK_OUTPUT_1 ; Armazena valor 00XY
                    ; Parte ZT
                    LD TEMP ; Carrega valor em temp [71]
                    * CONST_100 ; Shift para esquerda [7100]
                    MM TEMP ; Salva em temp
                    LD UNPACK_INPUT ; Carrega valor inicial
                    + CONST_8000 ; [F123 + 8000 = 7123] 
                    - TEMP ; Obtem 00ZT [7123 - 7100 = 23]
                    MM UNPACK_OUTPUT_2 ; Armazena 00 ZT em UNPACK_OUTPUT_2
                    RS UNPACK ; END da sub rotina
                    ; Caso positivo
                    ; Parte XY
POSITIVE_CASE       LD UNPACK_INPUT ; Carrega valor inicial
                    / CONST_100 ; Realiza shift de duas casa para direita
                    MM UNPACK_OUTPUT_1 ; Salva em UNPACK_OUTPUT_1 00XY
                    ; Parte ZT
                    * CONST_100 ; Realiza shift de duas casa para esquerda, obtendo XY00
                    MM TEMP ; Salva valor temporario
                    LD UNPACK_INPUT ; Carrega valor inicial
                    - TEMP ; Realiza XYZT - XY00 obtendo ZT
                    MM UNPACK_OUTPUT_2 ; Salva resultado
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
MEMCPY_ORIGIN_PTR       K       /0000
MEMCPY_DESTINATION_PTR  K       /0000
MEMCPY_SIZE_PTR         K       /0000
MEMCPY_ORIGIN           K       /0000
MEMCPY_DESTINATION      K       /0000
MEMCPY_SIZE             K       /0000
;
; Rotina
;
MEMCPY                  K       /0000
                        ; Carrega valores de entrada
                        LD      MEMCPY_ORIGIN_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC1 ; Armazena em UNPACK_EXEC1
UNPACK_EXEC1            K       /0000 ; Carrega valor do endereço
                        MM      MEMCPY_ORIGIN ; Armazena
                        LD      MEMCPY_DESTINATION_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC2 ; Armazena em UNPACK_EXEC2
UNPACK_EXEC2            K       /0000 ; Carrega valor do endereço
                        MM      MEMCPY_DESTINATION ; Armazena
                        LD      MEMCPY_SIZE_PTR ; carrega o endereço
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

# PACK