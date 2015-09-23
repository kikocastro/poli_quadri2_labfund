; - PACK: Compõe uma word a partir de seus bytes. O
; resultado está no acumulador.
; Parâmetros: os dois endereços que contêm os bytes.
; Retorno (acumulador): a palavra.
; - Se os endereços que contêm os bytes (valores
; binários) forem denotados por B1 e B2, sendo:
; B1 = 00XY e B2 = 00ZT,
; a word resultante será XYZT (valor binário).
; Endereço de início do programa principal: 0000
; Endereço das words de entrada: 0002 e 0004
; Endereço da word de saída: 0006
@ /0000
MAIN       JP INI
B1         K /00FA
B2         K /0010
OUT        K /0000
INI        LV B1 ; Carrega o endereço de B1
    	   MM PACK_INI1 ; Armazena esse valor em PACK_INI1 
    	   LV B2 ; Carrega o endereço de B2
    	   MM PACK_INI2 ; Armazena esse valor em PACK_INI2
    	   SC PACK ; Chama sub rotina PACK
    	   MM OUT
FIM        HM FIM
; Variaveis
PACK_INI1   K /0000
PACK_INI2   K /0000
LOAD        LD /0000 
SOMA        K /0000 
SHIFT       K /0100
; Sub rotina PACK
PACK        K /0000
            LD PACK_INI1 ; carrega valor de PACK_INI1 (Endereço de B1 0x0002)
            + LOAD ; Soma load resultando em 8002
            MM EXEC1 ; Armazena em EXEC1
EXEC1       K /0000 ; Carrega valor de B1
            * SHIFT ; Realiza shift de duas casa para esquerda
            MM SOMA ; armazena valor em SOMA
            LD PACK_INI2 ; carrega valor de PACK_INI2 (Endereço de B2 0x0004)
            + LOAD ; Soma load resultando em 8004
            MM EXEC2 ; Armazena em EXEC2
EXEC2       K /0000 ; Carrega valor de B2
            + SOMA ; soma B1 e B2
            RS PACK ; Fim da sub rotina
            # MAIN
