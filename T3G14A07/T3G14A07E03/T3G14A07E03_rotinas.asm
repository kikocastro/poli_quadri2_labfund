; Importa constantes
;
LOAD        <
WRITE       <
SUBTRACT    <
GETDATA     <
PUTDATA     <

CONST_0                 <
CONST_1                 <
CONST_2                 <
CONST_7                 <
CONST_9                 <
CONST_A                 <
CONST_10                <
CONST_F                 <
CONST_30                <
CONST_3A                <
CONST_40                <
CONST_47                <
CONST_80                <
CONST_FF                <
CONST_100               <
CONST_300               <
CONST_FFE               <
CONST_1000              <
CONST_8000              <
CONST_FFFF              <

MEM_START   <
MEM_END     <
;
; Entradas e saidas
;
INPUT_1_PTR >
INPUT_2_PTR >
INPUT_3_PTR >

;OUTPUT_1    <
;OUTPUT_2    <
;OUTPUT_3    <
;
; Rotinas
;
PACK        >
UNPACK      >
MEMCPY      >
CHTOI       >
UITOCH      >
HALF_PACK   >
GETLINEF    >
DUMPER 		>
;
; DUMPER
DUMP_INI 	>
DUMP_TAM 	>
DUMP_UL 	>
DUMP_BL 	>
DUMP_EXE 	>
;
& /0000 ; Origem relocavel
;
INPUT_1_PTR    K /0000 ; Endereco da entrada 1
INPUT_2_PTR    K /0000 ; Endereco da entrada 2
INPUT_3_PTR    K /0000 ; Endereco da entrada 3
;
OUTPUT_1    K /0000 ; Endereco da entrada 1
OUTPUT_2    K /0000 ; Endereco da entrada 2
OUTPUT_3    K /0000 ; Endereco da entrada 3
;
DUMP_INI		K	/0400	; Endere�o onde come�a o dump
DUMP_TAM	    K	/0032	; Numero total de palavras a serem "dumpadas"
DUMP_UL			K	/0000	; Unidade logica do disco a ser usado
DUMP_BL 		K	/0010	; Tamanho do bloco
DUMP_EXE 		K	/0400	; Endere�o onde come�aria a execu��o (valor dummy, apenas para manter o formato)
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
UNPACK_INPUT_LOCAL  K  /0000
;
; Rotina
;
UNPACK              K  /0000
                    ; Carrega valor do endereco apontado por INPUT_1_PTR
                    LD INPUT_1_PTR ; Carrega endereco contido em INPUT_1_PTR
                    MM TARGET_ADDRESS
                    SC LOAD_VALUE ; Carrega conteudo de entrada de UNPACK
                    MM UNPACK_INPUT_LOCAL ; Salva na variavel local
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
                    LD UNPACK_INPUT_LOCAL ; Carrega valor inicial
                    + CONST_8000 ; [F123 + 8000 = 7123]
                    - TEMP ; Obtem 00ZT [7123 - 7100 = 23]
                    MM OUTPUT_2 ; Armazena 00 ZT em OUTPUT_2
                    RS UNPACK ; END da sub rotina
                    ; Caso positivo
                    ; Parte XY
POSITIVE_CASE       LD UNPACK_INPUT_LOCAL ; Carrega valor inicial
                    / CONST_100 ; Realiza shift de duas casas para direita
                    MM OUTPUT_1 ; Salva em OUTPUT_1 00XY
                    ; Parte ZT
                    * CONST_100 ; Realiza shift de duas casa para esquerda, obtendo XY00
                    MM TEMP ; Salva valor temporario
                    LD UNPACK_INPUT_LOCAL ; Carrega valor inicial
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
SIZE                    K       /0000
ORIGIN                  K       /0000
DESTINATION             K       /0000
;
; Rotina
;
MEMCPY                  K       /0000
                        ; Carrega valores de entrada
                        LD      INPUT_1_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC1 ; Armazena em UNPACK_EXEC1
UNPACK_EXEC1            K       /0000 ; Carrega valor do endereço
                        MM      SIZE ; Armazena
                        LD      INPUT_2_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC2 ; Armazena em UNPACK_EXEC2
UNPACK_EXEC2            K       /0000 ; Carrega valor do endereço
                        MM      ORIGIN ; Armazena
                        LD      INPUT_3_PTR ; carrega o endereço
                        +       LOAD ; Soma load
                        MM      UNPACK_EXEC3 ; Armazena em UNPACK_EXEC3
UNPACK_EXEC3            K       /0000 ; Carrega valor do endereço
                        MM      DESTINATION ; Armazena
                        ; Tratamento de erros de Input
                        ; 1) Endereço inicial + o numero de palavras > endereço maximo
                        LD      MEM_END   ; Carrega o endereço maximo de destino
                        -       SIZE
                        -       SIZE ; Subtrai numero de enderecos de words que serao copiadas (Duas vezes pois cada palavra ocupa 2 Bytes)
                        -       DESTINATION  ; Subtrai o endereço inicial do destino
                        JN      END_FAIL  ; Caso o endereço inicial + o numero de palavras > endereço maximo, ERRO
                        ; 2) Endereço de destino esta antes do intervalo
                        LD      DESTINATION
                        -       MEM_START
                        JN      END_FAIL
                        ; 3) Origem esta antes do intervalo
                        LD      ORIGIN
                        -       MEM_START
                        JN      END_FAIL
                        ; 4) Origem esta a frente do intervalo
                        LD      MEM_END
                        -       ORIGIN
                        -       SIZE
                        -       SIZE
                        JN      END_FAIL
                        ; Comeco de MEMCPY
LOOP                    LD      SIZE ; Carrega o numero de words no acumulador
                        -       COUNT     ; Subtrai o contador do acumulador
                        JZ      END_SUCCESS ; Caso o contador seja igual ao numero de words, encerra

                        LD      DESTINATION ; Carrega endereco de destino
                        +       WRITE   ; Adiciona comando MM
                        MM      MEMCPY_EXEC   ; Armazena em MEMCPY_EXEC

                        LD      ORIGIN ; Carrega endereço de origem
                        MM      TARGET_ADDRESS
                        SC      LOAD_VALUE ; Carrega valor no endereco de origem

MEMCPY_EXEC             K       /0000 ; Armazena o valor no endereco de destino
                        LD      DESTINATION  ; Carrega o endereço de destino
                        +       CONST_2   ; Avança 2 posições na memoria
                        MM      DESTINATION  ; Atualiza DESTINATION

                        LD      ORIGIN ; Carrega o endereço de origem
                        +       CONST_2   ; Avança 2 posições na memoria
                        MM      ORIGIN ; Atualiza ORIGIN

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
; UITOCH
; ###################################
;
; Converte um numero intero para duas words contendo caracteres ASCII
; correspondentes. [exemplo: entra 79AB e saem 3739 e 4142]
;
; Variaveis
;
UITOCH_INPUT_PTR        K /0000
UITOCH_TEMP_1           K /0000
UITOCH_TEMP_2           K /0000
;
; Rotina
;
UITOCH                  K       /0000

                        ; nesse ponto o endereço da entrada ja esta em INPUT_1_PTR,
                        ; entao, chama-se UNPACK diretamente.
                        SC      UNPACK ; Chama a rotina

                        LD      OUTPUT_2 ; Carrega a segunda metade [Ex: Se int = 79AB, carrega 00AB]
                        MM      UITOCH_TEMP_2 ; Armazena temporariamente

                        ; Primeira palavra
                        LV      OUTPUT_1 ; Carrega endereco que contem [0079]
                        MM      INPUT_1_PTR ; Armazena
                        SC      HALF_UNPACK ; Chama rotina
                        LD      OUTPUT_1 ; [0007]
                        MM      UITOCH_WORD_1
                        LD      OUTPUT_2 ; [0009]
                        MM      UITOCH_WORD_2
                        SC      UITOCH_PROCESS_WORD ; Chama sub-rotina
                        MM      UITOCH_TEMP_1 ; [3739]

                        ; Verifica se houve erro
                        -       CONST_FFFF
                        JZ      UITOCH_ERROR

                        ; Segunda palavra
                        LV      UITOCH_TEMP_2 ; Carrega endereco que tem [00AB]
                        MM      INPUT_1_PTR ; Armazena
                        SC      HALF_UNPACK ; Chama rotina
                        LD      OUTPUT_1
                        MM      UITOCH_WORD_1 ; [000A]
                        LD      OUTPUT_2
                        MM      UITOCH_WORD_2 ; [000B]
                        SC      UITOCH_PROCESS_WORD ; Chama sub-rotina
                        MM      UITOCH_TEMP_2 ; [4142]

                        ; Verifica se houve erro
                        -       CONST_FFFF
                        JZ      UITOCH_ERROR

                        ; Se nao houve, armazena na saida
                        LD      UITOCH_TEMP_1
                        MM      OUTPUT_1
                        LD      UITOCH_TEMP_2
                        MM      OUTPUT_2

UITOCH_ERROR            LD      CONST_FFFF ; Carrega valor de erro

END_UITOCH              RS      UITOCH ; END da sub rotina
;
;
; ###################################
; UITOCH_PROCESS_WORD
; ###################################
;
; Sub rotina de UITOCH que carrega os inteiros [ex 0007 e 0009]
; e devolve o caracter ASCII correspondente [ex 3739]
;
UITOCH_WORD_1               K       /0000
UITOCH_WORD_2               K       /0000
;
UITOCH_PROCESS_WORD         K       /0000

                            LD      UITOCH_WORD_1 ; Carrega valor  [exemplo: 0007]
                            MM      UITOCH_TEMP_CHAR ; Armazena
                            SC      UITOCH_PROCESS_CHAR ; Chama sub-rotina
                            MM      UITOCH_WORD_1 ; Armazena [0037]

                            LD      UITOCH_WORD_2 ; Carrega valor  [exemplo: 0009]
                            MM      UITOCH_TEMP_CHAR ; Armazena
                            SC      UITOCH_PROCESS_CHAR ; Cahama sub-rotina
                            MM      UITOCH_WORD_2 ; Armazena [0039]

                            LV      UITOCH_WORD_1 ; Carrega endereco [0037]
                            MM      INPUT_1_PTR ; Armazena na entrada
                            LV      UITOCH_WORD_2 ; Carrega endereco [0039]
                            MM      INPUT_2_PTR ; Armazena na entrada

                            SC      PACK ; Chama rotina [recebe 3739]

END_UITOCH_PROCESS_WORD     RS      UITOCH_PROCESS_WORD
;
;
; ###################################
; UITOCH_PROCESS_CHAR
; ###################################
;
; Sub rotina de UITOCH_CHTOI que recebe uma metade de palavra ASCII [ se palavra original XYZT, recebe 00XY]
; e devolve o inteiro correspondente
;
;
UITOCH_TEMP_CHAR            K       /0000
UITOCH_CHAR_TEMP            K       /0000

UITOCH_PROCESS_CHAR         K       /0000
                            LD      UITOCH_TEMP_CHAR ; Carrega valor  [exemplo: 0007]
                            +       CONST_30 ; [0037]
                            MM      UITOCH_TEMP_CHAR ; Armazena em variavel temporaria
                            -       CONST_3A ; UITOCH_TEMP_CHAR - 3A
                            JN      UITOCH_IS_NUMBER ; Se negativo, trata-se de um numero, caso contrario char de A a F
                            ; Caso char
                            LD      UITOCH_TEMP_CHAR ; Carrega o valor de char [0037]
                            +       CONST_7 ; soma 7 para encontrar o valor inteiro [0041]
                            JP      END_UITOCH_PROCESS_CHAR ; Encerra

UITOCH_IS_NUMBER            LD      UITOCH_TEMP_CHAR ; carrega o numero
                            JP      END_UITOCH_PROCESS_CHAR

UITOCH_PROCESS_CHAR_ERROR   LD      CONST_FFFF ; Carrega erro

END_UITOCH_PROCESS_CHAR     RS      UITOCH_PROCESS_CHAR
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
;
; ###################################
; HALF_UNPACK
; ###################################
;
; Recebe numero no format [00XY] e retorna [000X] e [000Y]
;
; Variaveis
;
HALF_UNPACK_TEMP1           K       /0000
HALF_UNPACK_TEMP2           K       /0000
;
; Rotina
;
HALF_UNPACK                 K       /0000
                            ; Carrega valor do endereco apontado por INPUT_1_PTR
                            LD      INPUT_1_PTR ; Carrega endereco contido em INPUT_1_PTR
                            MM      TARGET_ADDRESS
                            SC      LOAD_VALUE ; Carrega conteudo de entrada de HALF_UNPACK
                            MM      HALF_UNPACK_TEMP1 ; Salva na variavel local [00XY]
                            ; Parte 000X
                            /       CONST_10 ; Realiza shift de uma casa para direita [000X]
                            MM      OUTPUT_1 ; Salva em OUTPUT_1 [000X]
                            ; Parte 000Y
                            *       CONST_10 ; Shif para esquerda [00X0]
                            MM      HALF_UNPACK_TEMP2
                            LV      HALF_UNPACK_TEMP2
                            +       SUBTRACT
                            MM      HALF_PACK_EXEC
                            LD      HALF_UNPACK_TEMP1 ; [00XY]
HALF_PACK_EXEC              K       /0000 ; [00XY - 000Y = 00X0]

                            MM OUTPUT_2 ; Salva resultado
                            RS HALF_UNPACK ; END da sub rotina

;
;
; ###################################
; GETLINEF
; ###################################
;
; Recebe Unidade logica, Tamanho do buffer, endereço do buffer
; Le uma linha de um arquivo texto, que contem numero par de caracteres, visto como disco pela mvn.
; Termina quando encontra final da linha (0A) ou final de arquivo (FF)
; Retorna 1 (true) se não chegar ao final do arquivo (EOF)
; Retorna 0 (false) se chegar ao final do arquivo.
;
; Variaveis
GL_BUFFER_SIZE              K       /0000 ; tamanho do buffer
GL_BUFFER_ADDRESS           K       /0000 ; endereco do buffer
EOS                         K       /0000 ; Palavra de finalizacao
GL_TEMP                     K       /0000
;
; Rotina
;
GETLINEF                    K       /0000
                            ; Prepara instrucao de GD no disco para unidade logica do parametro
                            LD      INPUT_1_PTR ; Carrega endereco contido em INPUT_1_PTR
                            MM      TARGET_ADDRESS
                            SC      LOAD_VALUE ; Carrega a Unidade Logica
                            +       CONST_300 ; soma dispositivo tipo disco
                            +       GETDATA ; soma instrucao GD
                            MM      READ_WORD ; Armazena instrucao completa

                            ; Carrega valor do tamanho do buffer
                            LD      INPUT_2_PTR ; Carrega endereco contido em INPUT_2_PTR
                            MM      TARGET_ADDRESS
                            SC      LOAD_VALUE ; Carrega o tamanho do buffer
                            MM      GL_BUFFER_SIZE ; Salva na variavel local

                            ; Carrega endereço do buffer
                            LD      INPUT_3_PTR ; Carrega endereco contido em INPUT_3_PTR
                            MM      TARGET_ADDRESS
                            SC      LOAD_VALUE ; Carrega o endereço do buffer
                            MM      GL_BUFFER_ADDRESS ; Salva na variavel local

GL_LOOP                     LD      GL_BUFFER_ADDRESS ; carrega endereco atual do buffer
                            +       WRITE ; adiciona comando de escrita
                            MM      GL_STORE_VALUE ; armazena instrucao
READ_WORD                   K       /0000 ; executa leitura do proximo valor
GL_STORE_VALUE              K       /0000 ; Salva valor lido no endereco atual do buffer

                            ; Chama UNPACK para separar as duas palavras
                            LD      GL_BUFFER_ADDRESS ; carrega endereco GL_BUFFER_ADDRESS
                            MM      INPUT_1_PTR ; armazena em INPUT_1_PTR
                            SC      UNPACK ; chama rotina
                            LD      OUTPUT_1 ; carrega primeira palavra
                            MM      GL_TEMP

                            ; verifica se é EOL
                            -       CONST_A ; subtrai A
                            JZ      GT_EOL
                            ; verifica se é EOF
                            LD      GL_TEMP ; recarrega palavra
                            -       CONST_FF
                            JZ      GT_EOF

                            LD      OUTPUT_2 ; Carrega segunda palavra
                            MM      GL_TEMP

                            ; verifica se é EOL
                            -       CONST_A ; subtrai A
                            JZ      GT_EOL
                            ; verifica se é EOF
                            LD      GL_TEMP ; recarrega palavra
                            -       CONST_FF
                            JZ      GT_EOF

                            ; se nao for EOL nem EOF, continua
                            LD      GL_BUFFER_SIZE ; carrega tamanho atual do buffer
                            -       CONST_1 ; Atualiza tamanho do buffer subtraindo 1
                            JZ      GT_END_NOT_EOF ; Se tamanho é zero, vai para final
                            MM      GL_BUFFER_SIZE ; se nao, armazena novo tamanho do buffer
                            LD      GL_BUFFER_ADDRESS ; atualiza endereco do buffer
                            +       CONST_2 ; soma 2 ao endereco atual
                            ; MM      GL_BUFFER_ADDRESS ; armazena endereco atualizado
                            ; JP      SKIP
                            ; NUM     K /0002
                            ; LU      K /0000
                            ; SKIP    OS /02FE
                            JP      GL_LOOP ; vai para proxima leitura

GT_EOL                      SC      GT_PUT_EOS
                            JP      GT_END_NOT_EOF

GT_EOF                      SC      GT_PUT_EOS
                            LD      CONST_0 ; Retorna 0 se chegou no final do arquivo
                            JP      GT_END

GT_END_NOT_EOF              LD      CONST_1 ; Retorna 1 se nao chegou no final do arquivo

GT_END                      RS GETLINEF ; END da sub rotina

;
;
; ###################################
; GT_PUT_EOS
; ###################################
;
; Sub rotina de GETLINEF
; Coloca EOS - End of string no ultimo endereco do buffer
;
GT_PUT_EOS                  K       /0000
                            LD      GL_BUFFER_ADDRESS ; carrega endereco atual do buffer
                            +       WRITE ; adiciona comando de escrita
                            MM      GL_FIX_EOL ; armazena instrucao
                            LD      EOS ; carrega end of string
GL_FIX_EOL                  K       /0000 ; Salva valor lido no endereco atual do buffer
                            RS      GT_PUT_EOS ; retorna

;
; ###################################
; DUMPER
; ###################################
;
;
; Variaveis
;
DUMP_CURRENT_ADDR               K       /0000
DUMP_COUNTER                    K       /0000
; Rotina
;
DUMPER                          K       /0000
                                ; comando PD
                                LD      DUMP_UL ; Carrega unidade logica
                                +       CONST_300 ; soma dispositivo tipo disco
                                +       PUTDATA ; Adiciona comando de escrita no arquivo
                                MM      DUMP_PD_COMMAND ; Armazena comando PD

                                ; Inicio do arquivo
                                LD      DUMP_INI ; Carrega endereco inicial a ser lido
                                MM      DUMP_CURRENT_ADDR ; Salva em variavel temporaria
DUMP_PD_COMMAND                 K       /0000 ; Escreve no arquivo endereço inicial

                                LD      DUMP_PD_COMMAND
                                MM      DUMP_SIZE_PD

                                LD      DUMP_TAM ; Carrega tamanho do dumper
                                MM      DUMP_COUNTER ; Salva em variavel temporaria
DUMP_SIZE_PD                    K       /0000 ; Escreve tamanho em arquivo



                                ; ------------- LOOP -------------------
DUMP_LOOP                       LD      DUMP_PD_COMMAND
                                MM      DUMP_PD

                                LD      DUMP_CURRENT_ADDR ; carrega endereco atual
                                MM      TARGET_ADDRESS ; armazena na variavel
                                SC      LOAD_VALUE ; chama subrotina que carrega conteudo

DUMP_PD                         K /0000 ; Escreve valor no arquivo

                                LD      DUMP_CURRENT_ADDR ; carrega endereco atual
                                -       CONST_FFE ; subtrai endereco maximo disponivel

                                JZ      DUMPER_END ; pula para o fim se atingiu o maximo  enderço disponivel na memoria (FFE)

                                LD      DUMP_COUNTER ; carrega valor do contador
                                -       CONST_1 ; subtrai 1

                                JZ      DUMPER_END ; pula para o fim se atingiu o maximo numero de palavras (DUMP_TAM)

                                MM      DUMP_COUNTER ; atualiza valor do contador

                                LD      DUMP_CURRENT_ADDR ; carrega valor do endereco
                                +       CONST_2 ; soma 2
                                MM      DUMP_CURRENT_ADDR ; atualiza valor do endereco

                                JP      DUMP_LOOP
                                ; ------------- END LOOP -------------------

DUMPER_END                      RS      DUMPER ; END da sub rotina

;
;
# PACK