; T3G14A02E03
; MEMCPY: Copia uma sequência de tamanho arbitrário de wordsda memória de uma
; posição em outra. Retorna 0000 em caso de sucesso e FFFF em caso de erro 
; (ex.: endereço de destino inválido).  Parâmetros: o número de words a ser
; copiado, o endereço da sequência de origem e o endereço da sequência de 
; destino.Retorno (acumulador): 0000 em caso de sucesso; FFFF caso contrário.
; Endereço de início do programa principal: 0000Endereço do número de words
; a ser copiado: 0002Endereço inicial da sequência de origem: 0004Endereço
; inicial da sequência de destino: 0006Endereço  reservado  para  sequências
; de  origem  e  destino:0008..0018
@ /0000
MAIN            JP INI
NUMBER_OF_WORDS K /0004
SEQUENCE_START  K /0028
SEQUENCE_END    K /0018
                $ /0011 ; endereços reservados para as sequencias
INI             LD NUMBER_OF_WORDS
                ; Verificacao de sequencia de tamanho 0
                SC SAMPLE_SEQUENCE ; carrega lista de exemplo para teste
                JZ EXIT_SUCCESS ; sequencia de tamanho zero
                JP CONTINUE
EXIT_SUCCESS    LD SUCCESS
                JP END ; termina com sucesso
EXIT_FAILURE    LD FAILURE
                JP END ; termina com erro
                ; continua se sequencia nao nula
                ; Verificacoes de erro
                ; 1) Inicio + #palavras deve ser menor que fim
CONTINUE        LD SEQUENCE_END
                - NUMBER_OF_WORDS
                - NUMBER_OF_WORDS ; numero de enderecos necessarios para palavras
                - SEQUENCE_START
                JZ EXIT_FAILURE
                
                ; MM CURRENT_ADDRESS
                ; MM ADDRESS
                ; SC LOAD_VALUE ; carrega valor
                ; MM CURRENT_VALUE
                ; LD NUMBER_OF_WORDS
                ; +  SEQUENCE_START ; calcula endereço de destino
                ; +  ADDRESS_INCREMENT
                ; MM DESTINATION_ADDRESS ; guarda endereço de destino
                ; LD CURRENT_VALUE
                ; MM DESTINATION_ADDRESS
                

END             HM END
; Constantes
ADDRESS_INCREMENT   K /0002
SUCCESS             K /0000
FAILURE             K /FFFF
; Variaveis
LOAD                LD /0000
DESTINATION_ADDRESS K  /0000
CURRENT_VALUE       K  /0000
CURRENT_ADDRESS     K  /0000
NEXT_ADDRESS        K  /0000
TEMP                K  /0000

;
SAMPLE_SEQUENCE     K  /0000
                    LV /0009
                    MM /0008
                    LV /0008
                    MM /000A
                    LV /0007
                    MM /000C
                    LV /0006
                    MM /000E
                    RS SAMPLE_SEQUENCE
;
; Subrotina GET_NEXT
;
GET_NEXT        K /0000
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
# MAIN