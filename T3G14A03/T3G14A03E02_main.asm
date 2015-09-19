; Main
; 
; Importa/ Exporta
;
; PACK
PACK <
PACK_INPUT_1_PTR <
PACK_INPUT_2_PTR <
PACK_OUTPUT >
; 
; UNPACK
UNPACK <
UNPACK_INPUT_PTR <
UNPACK_OUTPUT_1 >
UNPACK_OUTPUT_2 >
;
; MEMCPY
MEMCPY <
MEMCPY_ORIGIN_PTR <
MEMCPY_DESTINATION_PTR <
MEMCPY_SIZE_PTR <
;
; CHTOI
CHTOI <
CHTOI_INPUT_1_PTR <   
CHTOI_INPUT_2_PTR <
CHTOI_OUTPUT >
;
;
; HALF_PACK
HALF_PACK <
HALF_PACK_INPUT_1_PTR <
HALF_PACK_INPUT_2_PTR <

HALF_PACK_OUTPUT >
;
&   /0000
MAIN                JP  INI
; Entradas / Saidas
;
; CHTOI
;
CHTOI_INPUT_1		K	/3739  
CHTOI_INPUT_2 		K	/4142
CHTOI_OUTPUT 		K 	/0000
; Entradas / Saidas
;
; PACK
;
PACK_INPUT_1        K   /00FA       ; 0002
PACK_INPUT_2        K   /00FF       ; 0004
PACK_OUTPUT         K   /0000       ; 0006
;
; UNPACK
;
UNPACK_INPUT        K   /8001       ; 0008
UNPACK_OUTPUT_1     K   /0000       ; 000A
UNPACK_OUTPUT_2     K   /0000       ; 000C
;
; MEMCPY
;
MEMCPY_SIZE         K   /0003       ; 000E
MEMCPY_ORIGIN       K   /0014       ; 0010
MEMCPY_DESTINATION  K   /001c       ; 0012
TEST_LIST			K   /0001		; 0014
					K	/0002	 	; 0016
					K	/0003		; 0018
					K	/0004		; 001A
					K	/FFFF		; 001C
					K	/FFFF		; 001E
					K	/FFFF	 	; 0020
					K	/FFFF	 	; 0022
					K	/FFFF	 	; 0024
;
; Programa
; 
; PACK
;
INI                 LV CHTOI_INPUT_1 ; Carrega o endereço de CHTOI_INPUT_1
    	            MM CHTOI_INPUT_1_PTR ; Armazena esse valor em CHTOI_INPUT_1_PTR 
    	            
    	            LV CHTOI_INPUT_2 ; Carrega o endereço de CHTOI_INPUT_2
                    MM CHTOI_INPUT_2_PTR ; Armazena esse valor em CHTOI_INPUT_2_PTR
                    
                    SC CHTOI ; Chama sub rotina CHTOI
                    
                    MM CHTOI_OUTPUT ; Salva na saida

END                 HM END
# MAIN