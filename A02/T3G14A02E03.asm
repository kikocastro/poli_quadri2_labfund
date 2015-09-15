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
NUM_WORDS			K 			/0005		;Numero de words a ser copiado
END_ORIGEM			K 			/0008		;Endereço de origem da lista que sera copiada
END_DEST			K 			/0014		;Endereço para onde vai a lista copiada

;Alocação de memória
MEM				    $ 			/0009 		;Alocando 16 posições a partir de AUX
LISTA 				K			/0001		;0008
					K			/0002	 	;000A
					K			/0003		;000C
					K			/0004		;000E
					K			/FFFF		;0010
					K			/FFFF		;0012
					K			/FFFF	 	;0014
					K			/FFFF	 	;0016
					K			/FFFF	 	;0018

;VARIAVEIS
CONT				K 			/0000
INC					K 			/0002

;CONSTANTES
LOAD				LD			/0000
WRITE				MM			/0000

CTE_1				K 			/0001
CTE_FFFF			K 			/FFFF
CTE_ZERO			K			/0000
MIN_END				K			/0008
MAX_END				K			/0018
	
INI					LD      	MAX_END		;Carrega o endereço maximo de destino
					-			NUM_WORDS
					-			NUM_WORDS	;Subtrai numero de enderecos de words que serao copiadas
					-			END_DEST 	;Subtrai o endereço inicial do destino
					JN			END_FAIL	;Caso o endereço inicial + o numero de palavras > endereço maximo, ERRO

					LD 			END_DEST
					-			MIN_END		
					JN			END_FAIL	;Endereço de destino esta antes do intervalo

					LD 			END_ORIGEM
					-			MIN_END
					JN			END_FAIL	;Origem esta antes do intervalo

					LD 			MAX_END
					-			END_ORIGEM
					-			NUM_WORDS
					-			NUM_WORDS
					JN			END_FAIL 	;Origem esta a frente do intervalo
					
LOOP				LD			NUM_WORDS	;Carrega o numero de words no acumulador
					- 			CONT 		;Subtrai o contador do acumulador
					JZ			END_SUCCESS	;Caso o contador seja igual ao numero de words, encerra

					LD			END_DEST
					+			WRITE		;Armazena o valor no endereco de destino
					MM 			EXEC

					LD			END_ORIGEM	;Carrega endereço de origem
					+ 			LOAD		;Acrescenta a instrução de LOAD
					MM			MEM_ADDR	;Passa a instrução para a sub-rotina MEM_READ
					SC			MEM_READ	;Chama a sub-rotina

EXEC				K			/0000
					LD			END_DEST	;Carrega o endereço de destino
					+			INC 		;Avança 2 posições na memoria
					MM 			END_DEST	;Atualiza END_DEST

					LD			END_ORIGEM	;Carrega o endereço de origem
					+			INC 		;Avança 2 posições na memoria
					MM 			END_ORIGEM	;Atualiza END_ORIGEM

					LD 			CONT 		;Carrega o contador no acumulador
					+			CTE_1 		;Soma 1
					MM 			CONT 		;Atualiza CONT

					JP			LOOP

END_SUCCESS			LD 			CTE_ZERO 	;Se o programa finalizar com sucesso, coloca 0x0000 no acumulador

FIM					HM			FIM

END_FAIL			LD 			CTE_FFFF ;Se o programa finalizar com falhas, coloca 0xFFFF no acumulador
					JP			FIM

;SUB-ROTINA MEM_READ
MEM_READ			K 			/0000
MEM_ADDR			K 			/0000
					RS 			MEM_READ
					# INI

