; T3G14A02E02
; -UNPACK: Extrai os bytes de uma word contida no acumulador 
; colocando-os em dois endereços da memória. Parâmetros: os dois
; endereços em que os byes serão armazenados.
; Retorno (acumulador): não.
; - Se a word for denotada por XYZT (valores binários) e os
; endereços que conterão seus bytes forem denotados por B1 e B2,
; devemos ter:B1 = 00XY  e B2 = 00ZT Endereço de início do programa
; principal: 0000 Endereço da word de entrada: 0002 Endereço das 
; words de saída: 0004 e 00006
@ /0000
MAIN       JP INI
INPUT      K /FA10
B1         K /0000
B2         K /0000
INI        LV INPUT ; Carrega o endereço de INPUT
    	   MM UNPACK_INI ; Armazena esse valor em UNPACK_INI 
    	   SC UNPACK ; Chama sub rotina UNPACK
END        HM END
; Variaveis
UNPACK_INI      K /0000
;
LOAD            LD /0000
TEMP            K /0000
SHIFT           K /0100
NEGATIVEREF     K /8000
NEGATIVEFIX     K /0080
;
; Sub rotina UNPACK
;
UNPACK          K /0000
                SC LOAD_INI_VALUE ; Carrega valor inicial
                + NEGATIVEREF ; soma 8000
                JN POSITIVE_CASE ; Caso < 0, o numero é positivo
                ; caso negativo [ex: F123. Atualmente: F123 + 8000 = 7123]
NEGATIVE_CASE   / SHIFT ; sem o sinal negativo com shift a direita [71]
                MM TEMP ; Armazena na variavel temp
                ; Parte XY
                + NEGATIVEFIX ; soma 80 para devolver o bit de sinal negativo [F1]
                MM B1 ; Armazena valor 00XY
                ; Parte ZT
                LD TEMP ; Carrega valor em temp [71]
                * SHIFT ; Shift para esquerda [7100]
                MM TEMP ; Salva em temp
                SC LOAD_INI_VALUE ; Carrega valor inicial
                + NEGATIVEREF ; [F123 + 8000 = 7123] 
                - TEMP ; Obtem 00ZT [7123 - 7100 = 23]
                MM B2 ; Armazena 00 ZT em B2
                RS UNPACK ; END da sub rotina
                ; Caso positivo
                ; Parte XY
POSITIVE_CASE   SC LOAD_INI_VALUE ; Carrega valor inicial
                / SHIFT ; Realiza shift de duas casa para direita
                MM B1 ; Salva em B1 00XY
                ; Parte ZT
                * SHIFT ; Realiza shift de duas casa para esquerda, obtendo XY00
                MM TEMP ; Salva valor temporario
                SC LOAD_INI_VALUE ; Carrega valor inicial
                - TEMP ; Realiza XYZT - XY00 obtendo ZT
                MM B2 ; Salva resultado
                RS UNPACK ; END da sub rotina
;
; Subrotina para carregar um valor no endereço ADDRESS
;
; Variaveis
ADDRESS         K /0000 ; Endereço em que esta o valor desejado
;
LOAD_VALUE      K /0000
                LD ADDRESS ; carrega o endereço
                + LOAD ; Soma load
                MM EXEC_LOAD ; Armazena em EXEC_LOAD
EXEC_LOAD       K /0000 ; Carrega valor do endereço
                RS LOAD_VALUE ; END da sub rotina
;
; Sub rotina para carregar valor inicial
;
LOAD_INI_VALUE  K /0000
                LD UNPACK_INI ; Carrega endereço do UNPACK_INI
                MM ADDRESS ; Salva na variavel Address
                SC LOAD_VALUE ; Carrega valor inicial
                RS LOAD_INI_VALUE
;
;
# MAIN