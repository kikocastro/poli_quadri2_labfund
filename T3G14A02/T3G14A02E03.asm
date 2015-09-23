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
					@ 			/0000
					JP 			INI 

;ENTRADAS
SIZE 				K 			/0000		;Numero de words a ser copiado
ORIGIN				K 			/0008		;Endereço de origem da lista que sera copiada
DESTINATION			K 			/0012		;Endereço para onde vai a lista copiada

;Alocação de memória
;MEM				    $ 			/0009 		;Alocando 16 posições a partir de AUX
TEST_LIST			K			/0001		;0008
					K			/0002	 	;000A
					K			/0003		;000C
					K			/0004		;000E
					K			/FFFF		;0010
					K			/FFFF		;0012
					K			/FFFF	 	;0014
					K			/FFFF	 	;0016
					K			/FFFF	 	;0018
INI					LV			SIZE
					MM			MEMCPY_SIZE_PTR
					LV			ORIGIN
					MM			MEMCPY_ORIGIN_PTR
					LV			DESTINATION
					MM			MEMCPY_DESTINATION_PTR
					SC 			MEMCPY
END					HM			END
;
; SUB-ROTINA MEMCPY
;VARIAVEIS
COUNT 					K 			/0000
MEMCPY_ORIGIN_PTR	 	K			/0000
MEMCPY_DESTINATION_PTR  K			/0000
MEMCPY_SIZE_PTR 		K			/0000
MEMCPY_ORIGIN		 	K			/0000
MEMCPY_DESTINATION		K			/0000
MEMCPY_SIZE				K			/0000

;CONSTANTES
LOAD				LD			/0000
WRITE				MM			/0000
INCREMENT 			K			/0002

CONST_1				K 			/0001
CONST_FFFF			K 			/FFFF
CONST_0				K			/0000
RANGE_START			K			/0008 ; Inicio do intervalo determinado
RANGE_END			K			/0018 ; Fim do intervalo determinado
; Rotina
MEMCPY				K			/0000
					; Carrega valores de entrada
	                LD 			MEMCPY_ORIGIN_PTR ; carrega o endereço
	                + 			LOAD ; Soma load
	                MM 			EXEC1 ; Armazena em EXEC1
EXEC1   			K 			/0000 ; Carrega valor do endereço
					MM 			MEMCPY_ORIGIN ; Armazena
	                LD 			MEMCPY_DESTINATION_PTR ; carrega o endereço
	                + 			LOAD ; Soma load
	                MM 			EXEC2 ; Armazena em EXEC2
EXEC2   			K 			/0000 ; Carrega valor do endereço
					MM 			MEMCPY_DESTINATION ; Armazena
	                LD 			MEMCPY_SIZE_PTR ; carrega o endereço
	                + 			LOAD ; Soma load
	                MM 			EXEC3 ; Armazena em EXEC3
EXEC3   			K 			/0000 ; Carrega valor do endereço
					MM 			MEMCPY_SIZE ; Armazena
					; Tratamento de erros de Input
					; 1) Endereço inicial + o numero de palavras > endereço maximo
					LD      	RANGE_END		; Carrega o endereço maximo de destino
					-			MEMCPY_SIZE
					-			MEMCPY_SIZE	; Subtrai numero de enderecos de words que serao copiadas (Duas vezes pois cada palavra ocupa 2 Bytes)
					-			MEMCPY_DESTINATION 	; Subtrai o endereço inicial do destino
					JN			END_FAIL	; Caso o endereço inicial + o numero de palavras > endereço maximo, ERRO
					; 2) Endereço de destino esta antes do intervalo
					LD 			MEMCPY_DESTINATION
					-			RANGE_START		
					JN			END_FAIL	
					; 3) Origem esta antes do intervalo
					LD 			MEMCPY_ORIGIN
					-			RANGE_START
					JN			END_FAIL	 
					; 4) Origem esta a frente do intervalo
					LD 			RANGE_END
					-			MEMCPY_ORIGIN
					-			MEMCPY_SIZE
					-			MEMCPY_SIZE
					JN			END_FAIL 	
					; Comeco de MEMCPY
LOOP				LD			MEMCPY_SIZE	; Carrega o numero de words no acumulador
					- 			COUNT 		; Subtrai o contador do acumulador
					JZ			END_SUCCESS	; Caso o contador seja igual ao numero de words, encerra

					LD			MEMCPY_DESTINATION ; Carrega endereco de destino
					+			WRITE		; Adiciona comando MM
					MM 			EXEC		; Armazena em EXEC

					LD			MEMCPY_ORIGIN	; Carrega endereço de origem
					MM 			TARGET_ADDRESS 
					SC			LOAD_VALUE ; Carrega valor no endereco de origem

EXEC				K			/0000 ; Armazena o valor no endereco de destino
					LD			MEMCPY_DESTINATION	; Carrega o endereço de destino
					+			INCREMENT 	; Avança 2 posições na memoria
					MM 			MEMCPY_DESTINATION	; Atualiza MEMCPY_DESTINATION

					LD			MEMCPY_ORIGIN	; Carrega o endereço de origem
					+			INCREMENT 	; Avança 2 posições na memoria
					MM 			MEMCPY_ORIGIN	; Atualiza MEMCPY_ORIGIN

					LD 			COUNT 		; Carrega o contador no acumulador
					+			CONST_1 		; Soma 1
					MM 			COUNT 		; Atualiza CONT

					JP			LOOP

END_SUCCESS			LD 			CONST_0 	; Se o programa finalizar com sucesso, coloca 0x0000 no acumulador
					JP 			RETURN_MEMCPY 
END_FAIL			LD 			CONST_FFFF ; Se o programa finalizar com falhas, coloca 0xFFFF no acumulador
					
RETURN_MEMCPY		RS 			MEMCPY

# INI

;
; Subrotina para carregar um valor no endereço ADDRESS
;
; Variaveis
TARGET_ADDRESS  K /0000 ; Endereço em que esta o valor desejado
;
LOAD_VALUE      K /0000
                LD TARGET_ADDRESS ; carrega o endereço
                + LOAD ; Soma load
                MM EXEC_LOAD ; Armazena em EXEC_LOAD
EXEC_LOAD       K /0000 ; Carrega valor do endereço
                RS LOAD_VALUE ; END da sub rotina