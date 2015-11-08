; Importa constantes
;
LOAD        <
WRITE       <
SUBTRACT    <
SUM         <
DIVIDE      <
MULTIPLY    <
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
CONST_1001              <
CONST_8000              <
CONST_FFFC              <
CONST_FFFE              <
CONST_FFFF              <

MEM_START   <
MEM_END     <
;
; Entradas e saidas
;

;
; Rotinas
;
DUMPER 		>
LOADER		>
;
; DUMPER
DUMP_INI 	>
DUMP_TAM 	>
DUMP_UL 	>
DUMP_BL 	>
DUMP_EXE 	>
;
; LOADER
LOADER_UL 	>
& /0000 ; Origem relocavel
;
;
DUMP_INI		K	/0400	; Endere�o onde come�a o dump
DUMP_TAM	    K	/0032	; Numero total de palavras a serem "dumpadas"
DUMP_UL			K	/0000	; Unidade logica do disco a ser usado
DUMP_BL 		K	/0010	; Tamanho do bloco
DUMP_EXE 		K	/0400	; Endere�o onde come�aria a execu��o (valor dummy, apenas para manter o formato)
;
; LOADER
LOADER_UL	    K	/0000
; Rotinas

; ###################################
; DUMPER
; ###################################
;
;
; Variaveis
;
DUMP_CURRENT_ADDR               K       /0000
DUMP_COUNTER                    K       /0000
DUMP_LAST_BLOCK_SIZE            K       /0000
DUMP_TEMP                       K       /0000
DUMP_LAST_BLOCK_ADDRESS         K       /0000
DUMP_CHECKSUM                   K       /0000
DUMP_CURR_BLOCK_SIZE            K       /0000 ; funciona como counter de um bloco
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

                                ; LAST BLOCK SIZE
                                ; lastBlockSize = tamanho - (tamanho/blockSize)  [ 7 - 7/3 = 1]
                                ; se > 0
                                ;   lastBlockInitAddress = initialAddress + ((tamanho -1 )* 2)
                                ; Exemplo
                                ; tamanho 7
                                ; blockSize = 3
                                ; 01 23 45    67 89 AB    CD
                                ; lastBlockSize = 3 - (7/3) = 1
                                ; lastBlockInitAddress = 0 + ((7 -1) * 2) C
                                ; ie, qd chegar no C, escrevo lastBlockSize palavras (1)

                                ; calcula resto da divisao de tamanho do buffer por tamanho do bloco
                                LV      DUMP_BL ; carrega enderço do tamanho do bloco
                                +       DIVIDE ; adiciona operador de divisao
                                MM      DUMP_DIVIDE_BY_BLOCK_SIZE ; armazena comando para a divisao por counter
                                LD      DUMP_TAM ; carrega tamanho do buffer
DUMP_DIVIDE_BY_BLOCK_SIZE       K       /0000 ; Divide tamanho do buffer por tamanho do bloco
                                MM      DUMP_TEMP
                                LV      DUMP_TEMP
                                +       MULTIPLY
                                MM      DUMP_MULT_BY_DIVISOR
                                LD      DUMP_BL ;
DUMP_MULT_BY_DIVISOR            K       /0000
                                MM      DUMP_TEMP
                                LV      DUMP_TEMP
                                +       SUBTRACT ; add comando de subtracao
                                MM      DUMP_SUBTRACT ; armazena

;                                 ; tamanho do bloco
                                LD      DUMP_TAM ; carrega tamanho do buffer
DUMP_SUBTRACT                   K       /0000 ; resultado sera TAM % BL
                                MM      DUMP_LAST_BLOCK_SIZE ; armazena tamanho do ultimo bloco

                                JZ      DUMP_LOOP ; inicia o loop se resto igual a zero (ultimo bloco é completo)

;                                 ; LAST BLOCK ADDRESS
                                LV      DUMP_INI ; carrega endereço do endereço inicial
                                +       SUM ; comando soma
                                MM      DUMP_SUM1 ; armazena comando

                                LV      CONST_2
                                +       MULTIPLY
                                MM      DUMP_MULTIPLY

                                LD      DUMP_TAM ; carrega tamanho do buffer
                                -       CONST_2
DUMP_MULTIPLY                   K       /0000 ; multiplica (tamanho do buffer - 2) por 2
DUMP_SUM1                       K       /0000 ; soma endereco inincial
                                MM      DUMP_LAST_BLOCK_ADDRESS ; armazena endereço de inicio do ultimo bloco

                                ; Armazena endereco de inicio do primeiro bloco
                                LD      DUMP_INI ; Carrega endereco inicial a ser lido
                                MM      DUMP_CURRENT_ADDR ; Salva em variavel temporaria

;                                 ; ------------- MAIN LOOP -------------------
                       ; Verifica se esta no ultimo bloco
DUMP_LOOP                       LV      DUMP_CURRENT_ADDR
                                +       SUBTRACT
                                MM      DUMP_SUBTRACT1
                                LD      DUMP_LAST_BLOCK_ADDRESS
DUMP_SUBTRACT1                  K       /0000

                                JZ      DUMP_LAST_BLOCK

                                ; se nao é ultimo bloco, DUMP_CURR_BLOCK_SIZE = DUMP_BL
                                LD      DUMP_BL
                                MM      DUMP_CURR_BLOCK_SIZE
                                JP      DUMP_BLOCK_CONTINUE ; continua programa

                                ; se ultimo bloco, corrige DUMP_CURR_BLOCK_SIZE para DUMP_LAST_BLOCK_SIZE
DUMP_LAST_BLOCK                 LD      DUMP_LAST_BLOCK_SIZE
                                MM      DUMP_CURR_BLOCK_SIZE

                                ; atualiza contador do loop principal
DUMP_BLOCK_CONTINUE             LV      DUMP_CURR_BLOCK_SIZE
                                +       SUBTRACT
                                MM      DUMP_SUBTRACT2
                                LD      DUMP_COUNTER
DUMP_SUBTRACT2                  K       /0000 ; subtrai tamanho do bloco do counter
                                JN      DUMPER_END_LOOP ; pula para o fim se atingiu o maximo numero de palavras (DUMP_TAM)

                                MM      DUMP_COUNTER ; se nao, atualiza counter

                                ; zera CHECKSUM
                                ; LD      CONST_0
                                ; MM      DUMP_CHECKSUM

                                ; INICIO DO BLOCO
                                ; ESCREVE ENDERECO INICIAL
                                LD      DUMP_PD_COMMAND
                                MM      DUMP_BLOCK_PD
                                LV      DUMP_CURRENT_ADDR
                                MM      TARGET_ADDRESS
                                SC      LOAD_VALUE
DUMP_BLOCK_PD                   K       /0000 ; Escreve no arquivo endereço atual

                                ; atualiza CHECKSUM para endereco
                                LD      DUMP_CURRENT_ADDR
                                MM      CHECKSUM_CURRENT ; salva valor atual

                                ; ESCREVE TAMANHO DO BLOCO
                                LD      DUMP_PD_COMMAND
                                MM      DUMP_BLOCK_PD1
                                LV      DUMP_CURR_BLOCK_SIZE
                                MM      TARGET_ADDRESS
                                SC      LOAD_VALUE
DUMP_BLOCK_PD1                  K       /0000 ; Escreve no arquivo tamanho do bloco atual

                                ; atualiza CHECKSUM para tamanho do bloco
                                LD      DUMP_CURR_BLOCK_SIZE
                                MM      CHECKSUM_ADD ; salva valor atual
                                SC      UPDATE_CHECKSUM

                                ; ----****** BLOCK LOOP ******----
DUMP_BLOCK_LOOP                 LD      DUMP_CURR_BLOCK_SIZE ; carrega tamanho do bloco atual
                                -       CONST_1 ; subtrai 1
                                JN      DUMP_LOOP_UPDATE ; sai do loop do bloco
                                MM      DUMP_CURR_BLOCK_SIZE ; atualiza contador

                                LD      DUMP_CURRENT_ADDR ; carrega endereco atual
                                -       CONST_FFE ; subtrai endereco maximo disponivel
                                JZ      DUMPER_END_LOOP ; pula para o fim se atingiu o maximo  endereço disponivel na memoria (FFE)

                                ; ESCRITA NO ARQUIVO
                                LD      DUMP_PD_COMMAND
                                MM      DUMP_PD
                                LD      DUMP_CURRENT_ADDR ; carrega endereco atual
                                MM      TARGET_ADDRESS ; armazena na variavel
                                SC      LOAD_VALUE ; chama subrotina que carrega conteudo
DUMP_PD                         K       /0000 ; Escreve valor no arquivo

                                ; atualiza CHECKSUM
                                MM      CHECKSUM_ADD ; salva valor atual
                                SC      UPDATE_CHECKSUM

                                ; atualiza proximo endereço
                                LD      DUMP_CURRENT_ADDR ; carrega valor do endereco
                                +       CONST_2 ; soma 2
                                MM      DUMP_CURRENT_ADDR ; atualiza valor do endereco

                                JP      DUMP_BLOCK_LOOP

                                ; ----****** END BLOCK LOOP ******----

                                ; escreve CHECKSUM
DUMP_LOOP_UPDATE                LD      DUMP_PD_COMMAND
                                MM      DUMP_PD1
                                LD      CHECKSUM_CURRENT ; carrega checksum do bloco atual
DUMP_PD1                        K       /0000 ; Escreve valor no arquivo


                                JP      DUMP_LOOP

                                ; ------------- END MAIN LOOP -------------------
DUMPER_END_LOOP                 LD      DUMP_PD_COMMAND
                                MM      DUMP_PD2
                                LD      DUMP_EXE
DUMP_PD2                        K       /0000 ; Escreve valor no arquivo

DUMPER_END                      RS      DUMPER ; END da sub rotina
;
;
; ###################################
; LOADER
; ###################################
;
;
; Variaveis
;
LOADER_CURRENT_ADDR               K       /0000
LOADER_TOTAL_WORDS                K       /0000
LOADER_BLOCK_SIZE                 K       /0000
LOADER_CURRENT_VALUE              K       /0000
LOADER_TEMP                       K       /0000
LOADER_LAST_BLOCK_ADDRESS         K       /0000
LOADER_CHECKSUM                   K       /0000
LOADER_CURR_BLOCK_SIZE            K       /0000 ; funciona como counter de um bloco
; Rotina
;
LOADER                          K       /0000
                                ; comando GD
                                LD      LOADER_UL ; Carrega unidade logica
                                +       CONST_300 ; soma dispositivo tipo disco
                                +       GETDATA ; Adiciona comando de escrita no arquivo
                                MM      LOADER_GD_COMMAND ; Armazena comando PD

                                ; le endereço inicial
LOADER_GD_COMMAND               K       /0000 ; Le do arquivo endereço inicial
                                MM      LOADER_CURRENT_ADDR ; Salva em variavel temporaria

                                ; le comprimento total da imagem do texto
                                LD      LOADER_GD_COMMAND ; Carrega comando de leitura
                                MM      LOADER_SIZE_PD ; Salva em variavel temporaria
LOADER_SIZE_PD                  K       /0000 ; le comprimento total
                                MM      LOADER_TOTAL_WORDS

                                ; END_INITCIAL+ 2 * #WORD < 1001
                                ; Verifica se a imagem cabe na memória, emitindo uma mensagem de erro (FFFE no acumulador) e parando se não for o caso.
                                LV      LOADER_TOTAL_WORDS
                                +       MULTIPLY
                                MM      LOADER_VERIFY_SIZE1
                                LD      CONST_2
LOADER_VERIFY_SIZE1             K       /0000 ; 2 x numero de palavras
                                MM      LOADER_TEMP

                                LV      LOADER_TEMP
                                +       SUM
                                MM      LOADER_VERIFY_SIZE2
                                LD      LOADER_CURRENT_ADDR
LOADER_VERIFY_SIZE2             K       /0000 ; (2x num de palavras) + end inicial = A
                                MM      LOADER_TEMP

                                LV      LOADER_TEMP
                                +       SUBTRACT
                                MM      LOADER_VERIFY_SIZE3
                                LD      CONST_1001
LOADER_VERIFY_SIZE3             K       /0000 ; 1001 - A
                                ; se nao couber, termina programa
                                JN      LOADER_SIZE_ERROR


                                ;  ------------- MAIN LOOP -------------------

                                ; verifica se ja leu todas as palavas
LOADER_MAIN_LOOP                LD      LOADER_TOTAL_WORDS
                                JZ      LOADER_END_SUCCESS

                                ; le proximo endereco do bloco
                                LD      LOADER_GD_COMMAND ; Carrega comando  de leitura
                                MM      LOADER_GET_ADRESS ; Salva em variavel temporaria
LOADER_GET_ADRESS               K       /0000 ; le endereço do arquivo
                                MM      LOADER_CURRENT_ADDR ; armazena
                                MM      CHECKSUM_CURRENT ; armazena tamanho do bloco no checksum

                                ; le numero de words do bloco
                                LD      LOADER_GD_COMMAND ; Carrega comando  de leitura
                                MM      LOADER_GET_NUMBER ; Salva em variavel temporaria
LOADER_GET_NUMBER               K       /0000 ; le endereço do arquivo
                                MM      LOADER_BLOCK_SIZE ; armazena
                                MM      CHECKSUM_ADD

                                ; realiza checksum do bloco
                                SC      UPDATE_CHECKSUM ; soma endereco inicial do bloco e tamanho do bloco ao checksum

                                ; ----****** BLOCK LOOP ******----

                                ; verifica se ja terminou bloco atual
LOADER_BLOCK_LOOP               LD      LOADER_BLOCK_SIZE
                                JZ      END_BLOCK_LOOP

                                ; le valor atual
                                LD      LOADER_GD_COMMAND ; Carrega comando de leitura
                                MM      LOADER_GET_NEXT_VALUE ; Salva em variavel temporaria
LOADER_GET_NEXT_VALUE           K       /0000 ; le VALOR
                                MM      LOADER_CURRENT_VALUE ; armazena

                                LD      LOADER_CURRENT_ADDR
                                +       WRITE
                                MM      LOADER_WRITE_VALUE
                                LD      LOADER_CURRENT_VALUE
LOADER_WRITE_VALUE              K       /0000 ; salva conteudo lido no endereço atual

                                ; ---- ATUALIZACOES -----

                                ; atualiza checksum
                                MM      CHECKSUM_ADD ; armazena
                                SC      UPDATE_CHECKSUM

                                ; atualiza endereco atual
                                LV      LOADER_CURRENT_ADDR
                                +       SUM
                                MM      LOADER_UPDATE_CURR_ADDRESS
                                LD      CONST_2
LOADER_UPDATE_CURR_ADDRESS      K       /0000 ; soma 2 ao endereçø atual
                                MM      LOADER_CURRENT_ADDR

                                ; atualiza contador do bloco
                                LD      LOADER_BLOCK_SIZE
                                -       CONST_1
                                MM      LOADER_BLOCK_SIZE

                                ; atualiza contador de palavras total
                                LD      LOADER_TOTAL_WORDS
                                -       CONST_1
                                MM      LOADER_TOTAL_WORDS

                                JP      LOADER_BLOCK_LOOP

                                ; ----****** END BLOCK LOOP ******----

                                ; le checksum do arquivo
END_BLOCK_LOOP                  LD      LOADER_GD_COMMAND ; Carrega comando de leitura
                                MM      LOADER_MAKE_CHECKSUM ; Salva em variavel temporaria
LOADER_MAKE_CHECKSUM            K       /0000 ; le VALOR
                                MM      LOADER_TEMP

                                ; checa checksum do bloco
                                LV      LOADER_TEMP
                                +       SUBTRACT
                                MM      LOADER_VERIFY_CHECKSUM
                                LD      CHECKSUM_CURRENT
LOADER_VERIFY_CHECKSUM          K       /0000

                                JZ      LOADER_MAIN_LOOP ; retorna loop principal

                                JP      LOADER_CHECKSUM_ERROR ; caso contrario, da erro de checksum
                                ;  ------------- MAIN LOOP -------------------
                                JP      LOADER_END
                                ; tamanho da imagem maior do que espaço disponivel na memoria, carrega erro FFFE e termina
LOADER_SIZE_ERROR               LD      CONST_FFFE
                                JP      LOADER_END
                                ; erro de checksum
LOADER_CHECKSUM_ERROR           LD      CONST_FFFC
                                JP      LOADER_END
                                ; fim com sucesso
LOADER_END_SUCCESS              LD      LOADER_GD_COMMAND ; Carrega comando de leitura
                                MM      LOADER_EXE ; Salva em variavel temporaria
LOADER_EXE                      K       /0000 ; le VALOR da proxima instrucao executavel

LOADER_END                      RS      LOADER ; END da sub rotina
;
;
; ###################################
; UPDATE_CHECKSUM
; ###################################
;
; Sub rotina de DUMPER e LOADER que realiza a soma de CHECKSUM_ADD a CHECKSUM_CURRENT
;
CHECKSUM_CURRENT                K       /0000
CHECKSUM_ADD                    K       /0000
                                ; atualiza CHECKSUM
UPDATE_CHECKSUM                 K       /0000
                                LV      CHECKSUM_CURRENT
                                +       SUM
                                MM      CHECKUSUM_SUM
                                LD      CHECKSUM_ADD
CHECKUSUM_SUM                   K       /0000
                                MM      CHECKSUM_CURRENT
                                RS      UPDATE_CHECKSUM
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